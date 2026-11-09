#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Offline-only conversion of complete Everloot public *vendor* corpus pages.

Everloot public player observations are CC BY-SA 4.0 (not its game-file layer).
No network, install-id export, game control or hidden API access. Only a vendor
and item/price tuple independently reported by >=3 distinct installations is
exported as confirmed. Names/positions are NOT present in the vendor feed and
are deliberately unknown unless an independently curated optional catalog is
provided. This is a conservative subset, NOT a complete Forever vendor DB.

Snapshots can be saved, without automation, from documented public API:
  https://everloot.app/api/corpus/public?kinds=vendor&limit=500&offset=0
Additional pages have offset=500,1000,... . Import only once every page has
been acquired. Respect 30 requests/hour without a key, 429 and terms.
"""
from __future__ import annotations
import argparse
from collections import defaultdict
from datetime import datetime
import json
import re
from pathlib import Path
from import_vendors import ValidationError, normalize, publish_atomic, export_lua

URL = "https://everloot.app"
LICENSE = "CC BY-SA 4.0"
LICENSE_URL = "https://creativecommons.org/licenses/by-sa/4.0/"
MAX_INPUT_BYTES = 30 * 1024 * 1024


def integer(value: object, desc: str, *, lo: int = 0) -> int:
    if type(value) is not int or not lo <= value <= 2147483647:
        raise ValidationError(f"{desc}: ungueltige positive ID/Ganzzahl")
    return value


def validate_page(page: object, n: int) -> dict:
    if not isinstance(page, dict) or page.get("ok") is not True or page.get("unreachable") is True:
        raise ValidationError(f"Seite {n}: keine gueltige, erreichbare Antwort")
    attr = page.get("attribution")
    if (not isinstance(attr, dict) or attr.get("licence") != LICENSE or
            attr.get("source") != URL):
        raise ValidationError(f"Seite {n}: Everloot-Lizenz/Attribution fehlt")
    if not isinstance(page.get("records"), list):
        raise ValidationError(f"Seite {n}: records fehlt")
    off = integer(page.get("offset"), f"Seite {n}.offset")
    total = integer(page.get("total"), f"Seite {n}.total")
    # Avoid falsely treating errors/empty as complete data.
    if off > total or len(page["records"]) > total or off + len(page["records"]) > total:
        raise ValidationError(f"Seite {n}: unplausible Zaehler")
    return page


def convert(pages: list[dict], catalog: dict | None = None, report: dict | None = None) -> dict:
    if not pages:
        raise ValidationError("Keine Eingabeseiten")
    if catalog is None:
        catalog = {}
    if not isinstance(catalog, dict) or not isinstance(catalog.get("vendors", {}), dict) or not isinstance(catalog.get("items", {}), dict):
        raise ValidationError("Katalog: vendors/items muessen Objekte sein")
    checked = [validate_page(p, i) for i, p in enumerate(pages)]
    checked.sort(key=lambda x: x["offset"])
    expected = 0
    total = checked[0]["total"]
    for page in checked:
        if page["total"] != total or page["offset"] != expected:
            raise ValidationError("Seiten fehlen, sind doppelt oder Snapshot-Gesamtzahl ist verschieden")
        expected += len(page["records"])
    if expected != total or checked[-1].get("next") is not None:
        raise ValidationError("Nicht alle Seiten des Corpus-Snapshots vorhanden")
    if total == 0:
        raise ValidationError("Leerer Corpus ist keine bestaetigte Haendlerdatenbank")

    votes: dict[tuple[int,int,int], set[str]] = defaultdict(set)
    dates = []
    snapshots = set()
    skipped_without_pseudonym = 0
    rows_with_pseudonym = 0
    for page in checked:
        timestamp = page.get("dataAsOf")
        if isinstance(timestamp, str):
            try:
                dt = datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
                if not dt.tzinfo:
                    raise ValueError("timezone fehlt")
                dates.append(dt.date().isoformat())
                snapshots.add(timestamp)
            except ValueError as exc:
                raise ValidationError("dataAsOf: ungueltiges ISO-Datum") from exc
        for record in page["records"]:
            if not isinstance(record, dict) or record.get("kind") != "vendor":
                raise ValidationError("Fremder Datensatz: kinds=vendor aufrufen")
            reporter = record.get("installId")
            # Everloot's PUBLIC feed replaces original IDs with pub-<32 hex>.
            # Some historical records have no public pseudonym: such records
            # cannot count as independent corroboration, but are not an error.
            if reporter is not None and (not isinstance(reporter, str) or
                    re.fullmatch(r"pub-[0-9a-fA-F]{32}", reporter) is None):
                raise ValidationError("Unerwartete Installationskennung (oeffentliches Pseudonym erwartet)")
            if reporter is not None:
                rows_with_pseudonym += 1
            vendor_id = integer(record.get("vendorNpcId"), "vendorNpcId", lo=1)
            products = record.get("items")
            if not isinstance(products, list) or not (1 <= len(products) <= 200):
                raise ValidationError("vendor.items: 1 bis 200 Eintraege erforderlich")
            for item in products:
                if not isinstance(item, dict):
                    raise ValidationError("vendor.items: Objekt erwartet")
                item_id = integer(item.get("itemId"), "itemId", lo=1)
                price = integer(item.get("priceCopper"), "priceCopper")
                if reporter is not None:
                    votes[(vendor_id, item_id, price)].add(reporter)
                else:
                    skipped_without_pseudonym += 1

    # When pages belong to different corpus builds, the offset-based walk is
    # not a consistent snapshot. Never silently mix different snapshots.
    if len(snapshots) > 1 or (snapshots and len(dates) != len(checked)):
        raise ValidationError("Verschiedene dataAsOf-Snapshots: erneut vollstaendig laden")

    corroborated: dict[tuple[int,int], list[int]] = defaultdict(list)
    for (vendor_id, item_id, price), reporters in votes.items():
        if len(reporters) >= 3:
            corroborated[(vendor_id, item_id)].append(price)

    groups: dict[int, list[dict]] = defaultdict(list)
    conflicted_pairs = 0
    for (vendor_id, item_id), prices in sorted(corroborated.items()):
        if len(prices) != 1:
            conflicted_pairs += 1
            continue  # competing confirmed prices => ambiguity, no arbitrary selection
        item_name = catalog.get("items", {}).get(str(item_id), f"Item-ID {item_id} (Name unbekannt)")
        groups[vendor_id].append({"id": item_id, "name": item_name,
                                  "priceCopper": prices[0], "stackCount": None,
                                  "numAvailable": None, "hasExtendedCost": None})

    vendors = []
    for vendor_id, items in sorted(groups.items()):
        v = catalog.get("vendors", {}).get(str(vendor_id), {})
        if not isinstance(v, dict):
            raise ValidationError("Katalogeintrag vendor muss Objekt sein")
        vendors.append({"id": vendor_id, "name": v.get("name", f"NPC-ID {vendor_id} (Name unbekannt)"),
                        "zone": v.get("zone", "Standort nicht belegt"),
                        "mapID": v.get("mapID"), "x": v.get("x"), "y": v.get("y"),
                        "seenInForever": True, "items": items})
    if not vendors:
        raise ValidationError("Weniger als drei unabhaengige gleiche Meldungen je Preis; nichts freigeben")
    normalized = normalize({"schema": 1, "provider": "Everloot", "attributionUrl": URL,
                      "credit": "Daten aus Spielerbeobachtungen von Everloot (https://everloot.app), CC BY-SA 4.0; bearbeitet fuer WoW-Market",
                      "license": LICENSE, "licenseUrl": LICENSE_URL,
                      "dataAsOf": min(dates) if dates else "", "vendors": vendors})
    # Report contains aggregate counts only; never raw/public installation IDs.
    if report is not None:
        report.update({
            "provider": "Everloot",
            "licence": LICENSE,
            "dataAsOf": min(dates) if dates else None,
            "observationRecords": total,
            "recordsWithPublicPseudonym": rows_with_pseudonym,
            "recordsWithoutPublicPseudonym": total - rows_with_pseudonym,
            "itemObservationsExcludedWithoutPseudonym": skipped_without_pseudonym,
            "distinctNpcItemPriceTriples": len(votes),
            "confirmedNpcItemPairsBeforeConflicts": len(corroborated),
            "conflictingConfirmedNpcItemPairs": conflicted_pairs,
            "publishedVendors": len(vendors),
            "publishedNpcItemPairs": sum(len(v["items"]) for v in vendors),
            "vendorNamesUnresolved": sum("(Name unbekannt)" in v["name"] for v in vendors),
            "vendorMapPositionsUnresolved": sum(v["mapID"] is None for v in vendors),
        })
    return normalized


def main() -> int:
    parser = argparse.ArgumentParser(description="Everloot: vollstaendige offline gespeicherte vendor-Corpus-Seiten konvertieren")
    parser.add_argument("--input", type=Path, nargs="+", required=True, help="Alle Seiten desselben Snapshots in JSON")
    parser.add_argument("--catalog", type=Path, help="Optional: freigegebener Katalog mit NPC-/Itemnamen und Standorten")
    parser.add_argument("--output", type=Path, required=True, help="Ziel fuer generierte Vendors.lua")
    parser.add_argument("--report", type=Path, help="Optionaler aggregierter Qualitaetsbericht als JSON (ohne Reporter-IDs)")
    args = parser.parse_args()
    try:
        pages = []
        for path in args.input:
            if not path.is_file() or path.stat().st_size > MAX_INPUT_BYTES:
                raise ValidationError("Input fehlt oder ist zu gross")
            pages.append(json.loads(path.read_text(encoding="utf-8")))
        catalog = None
        if args.catalog:
            if not args.catalog.is_file() or args.catalog.stat().st_size > MAX_INPUT_BYTES:
                raise ValidationError("Katalog fehlt oder ist zu gross")
            catalog = json.loads(args.catalog.read_text(encoding="utf-8"))
        report = {}
        normalized = convert(pages, catalog, report=report)
        sources = {p.resolve() for p in args.input}
        if args.catalog: sources.add(args.catalog.resolve())
        if args.output.resolve() in sources:
            raise ValidationError("Output darf Input oder Katalog nicht ueberschreiben")
        if args.report and (args.report.resolve() in sources or args.report.resolve() == args.output.resolve()):
            raise ValidationError("Report darf Input, Katalog und Output nicht ueberschreiben")
        # Preserve existing target on invalid inputs. Written files are explicitly
        # separate outputs, and only produced after full validation succeeds.
        publish_atomic(args.output, export_lua(normalized))
        if args.report:
            publish_atomic(args.report, json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n")
        print(f"PASS: {len(normalized['vendors'])} Haendler, best. Warenpositionen: "
              f"{sum(len(v['items']) for v in normalized['vendors'])}")
        return 0
    except (ValidationError, json.JSONDecodeError, UnicodeError) as exc:
        parser.error(str(exc))
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
