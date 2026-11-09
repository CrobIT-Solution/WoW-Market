#!/usr/bin/env python3
"""Offline validator & deterministic Lua exporter for user-authorized vendor datasets.

Input is *our own normalized schema*, NOT a claim of ForeverDB's wire JSON layout.
No network I/O, no third party dependencies, no Python exec/eval.
"""
from __future__ import annotations

import argparse
import json
import math
import os
import re
import tempfile
from pathlib import Path
from datetime import date


class ValidationError(ValueError):
    pass


def _text(value: object, where: str, allow_empty: bool = False) -> str:
    if not isinstance(value, str) or isinstance(value, bool):
        raise ValidationError(f"{where}: Text erwartet")
    cleaned = value.strip()
    if (not cleaned and not allow_empty) or len(cleaned) > 220:
        raise ValidationError(f"{where}: ungueltige Laenge")
    if any(ord(c) < 32 for c in cleaned) or "|" in cleaned:
        raise ValidationError(f"{where}: Steuerzeichen/WoW-Markup unzulaessig")
    return cleaned


def _int(value: object, where: str, min_value: int = 0, max_value: int = 2**31 - 1) -> int:
    if type(value) is not int or not min_value <= value <= max_value:
        raise ValidationError(f"{where}: Ganzzahl {min_value}..{max_value} erwartet")
    return value


def _coord(value: object, where: str) -> float | None:
    if value is None:
        return None
    if type(value) not in (int, float) or not math.isfinite(value) or not 0 <= value <= 100:
        raise ValidationError(f"{where}: Koordinate 0..100 oder null erwartet")
    return round(float(value), 4)


def _flag(value: object, where: str) -> bool | None:
    if value is None:
        return None
    if type(value) is not bool:
        raise ValidationError(f"{where}: bool oder null erwartet")
    return value


def normalize(payload: object) -> dict:
    if not isinstance(payload, dict) or type(payload.get("schema")) is not int or payload.get("schema") != 1:
        raise ValidationError("schema: erwartet Version 1")
    provider = _text(payload.get("provider"), "provider")
    # WoWHead is currently only a link provider. A future authorized adapter
    # may use this same normalized schema, after documented rights review.
    if re.search(r"wow[\s.\-_]*head", provider, flags=re.IGNORECASE):
        raise ValidationError("WoWHead-Datenimport gesperrt: schriftliche Nutzungs-/Weitergabefreigabe fehlt")
    attribution_url = _text(payload.get("attributionUrl", ""), "attributionUrl", True)
    credit = _text(payload.get("credit", ""), "credit", True)
    license_name = _text(payload.get("license", ""), "license", True)
    license_url = _text(payload.get("licenseUrl", ""), "licenseUrl", True)
    data_as_of = _text(payload.get("dataAsOf", ""), "dataAsOf", True)
    if provider == "ForeverDB.net" and attribution_url != "https://foreverdb.net":
        raise ValidationError("ForeverDB.net braucht den Quellenlink https://foreverdb.net")
    if provider == "Everloot" and (attribution_url != "https://everloot.app" or
        license_name != "CC BY-SA 4.0" or
        license_url != "https://creativecommons.org/licenses/by-sa/4.0/" or
        "Everloot" not in credit):
        raise ValidationError("Everloot braucht CC BY-SA 4.0 und sichtbare Quellenangabe")
    if data_as_of:
        try:
            if date.fromisoformat(data_as_of).isoformat() != data_as_of:
                raise ValueError("kein ISO-Datum")
        except ValueError as exc:
            raise ValidationError("dataAsOf: ISO-Datum YYYY-MM-DD erwartet") from exc
    if attribution_url and not re.fullmatch(r"https://[A-Za-z0-9][A-Za-z0-9.-]*(?:/[A-Za-z0-9._~/-]*)?", attribution_url):
        raise ValidationError("attributionUrl: nur feste HTTPS-Domain/Pfad, keine Parameter")
    if license_url and not re.fullmatch(r"https://[A-Za-z0-9][A-Za-z0-9.-]*(?:/[A-Za-z0-9._~/-]*)?", license_url):
        raise ValidationError("licenseUrl: nur feste HTTPS-Domain/Pfad")
    incoming = payload.get("vendors")
    if not isinstance(incoming, list):
        raise ValidationError("vendors: Liste erwartet")
    if len(incoming) > 100000:
        raise ValidationError("vendors: groessenlimit ueberschritten")
    normalized = []
    vendor_ids = set()
    for n, vendor in enumerate(incoming):
        prefix = f"vendors[{n}]"
        if not isinstance(vendor, dict):
            raise ValidationError(f"{prefix}: Objekt erwartet")
        vid = _int(vendor.get("id"), f"{prefix}.id", 1)
        if vid in vendor_ids:
            raise ValidationError(f"{prefix}.id: doppelte Haendler-ID {vid}")
        vendor_ids.add(vid)
        x = _coord(vendor.get("x"), f"{prefix}.x")
        y = _coord(vendor.get("y"), f"{prefix}.y")
        if (x is None) != (y is None):
            raise ValidationError(f"{prefix}: x und y nur gemeinsam")
        map_id = vendor.get("mapID")
        if map_id is not None:
            map_id = _int(map_id, f"{prefix}.mapID", 1)
        if x is not None and map_id is None:
            raise ValidationError(f"{prefix}: Koordinaten brauchen mapID")
        item_list = vendor.get("items")
        if not isinstance(item_list, list):
            raise ValidationError(f"{prefix}.items: Liste erwartet")
        if len(item_list) > 20000:
            raise ValidationError(f"{prefix}.items: Groessenlimit ueberschritten")
        items, item_ids = [], set()
        for m, item in enumerate(item_list):
            itemp = f"{prefix}.items[{m}]"
            if not isinstance(item, dict):
                raise ValidationError(f"{itemp}: Objekt erwartet")
            iid = _int(item.get("id"), f"{itemp}.id", 1)
            if iid in item_ids:
                raise ValidationError(f"{itemp}.id: doppelte Artikel-ID {iid}")
            item_ids.add(iid)
            stack = item.get("stackCount")
            if stack is not None:
                stack = _int(stack, f"{itemp}.stackCount", 1, 100000)
            stock = item.get("numAvailable")
            if stock is not None:
                stock = _int(stock, f"{itemp}.numAvailable", -1, 100000000)
            items.append({
                "id": iid,
                "name": _text(item.get("name"), f"{itemp}.name"),
                "priceCopper": _int(item.get("priceCopper"), f"{itemp}.priceCopper"),
                "stackCount": stack,
                "numAvailable": stock,
                "hasExtendedCost": _flag(item.get("hasExtendedCost", False), f"{itemp}.hasExtendedCost"),
            })
        normalized.append({
            "id": vid,
            "name": _text(vendor.get("name"), f"{prefix}.name"),
            "zone": _text(vendor.get("zone", "Unbekannt"), f"{prefix}.zone"),
            "mapID": map_id,
            "x": x,
            "y": y,
            "seenInForever": _flag(vendor.get("seenInForever"), f"{prefix}.seenInForever"),
            "items": sorted(items, key=lambda i: i["id"]),
        })
    return {
        "schema": 1,
        "provider": provider,
        "attributionUrl": attribution_url,
        "credit": credit,
        "license": license_name,
        "licenseUrl": license_url,
        "dataAsOf": data_as_of,
        "vendors": sorted(normalized, key=lambda v: v["id"]),
    }


def lua_str(value: str) -> str:
    # Decimal escapes prevent arbitrary user strings from breaking Lua syntax.
    content = []
    for c in value:
        code = ord(c)
        if c == "\\": content.append("\\\\")
        elif c == '"': content.append('\\"')
        elif c == "\n": content.append("\\n")
        elif c == "\r": content.append("\\r")
        elif c == "\t": content.append("\\t")
        else: content.append(c)
    return '"' + ''.join(content) + '"'


def _lua_value(value: object) -> str:
    if value is None: return "nil"
    if isinstance(value, bool): return "true" if value else "false"
    if isinstance(value, int): return str(value)
    if isinstance(value, float): return format(value, ".4f").rstrip("0").rstrip(".") or "0"
    if isinstance(value, str): return lua_str(value)
    raise TypeError(type(value))


def export_lua(payload: dict) -> str:
    lines = [
        "-- Generated by WoW-Market DataAgent (offline). Do not edit manually.",
        "-- Data source must be authorized and properly credited.",
        "CrobITMarketData = {",
        "  schema = 1,",
        f"  provider = {lua_str(payload['provider'])},",
        f"  attributionUrl = {lua_str(payload['attributionUrl'])},",
        f"  credit = {lua_str(payload['credit'])},",
        f"  license = {lua_str(payload['license'])},",
        f"  licenseUrl = {lua_str(payload['licenseUrl'])},",
        f"  dataAsOf = {lua_str(payload['dataAsOf'])},",
        "  vendors = {",
    ]
    for vendor in payload["vendors"]:
        lines.append(f"    [{vendor['id']}] = {{")
        for field in ("name", "zone", "mapID", "x", "y", "seenInForever"):
            lines.append(f"      {field} = {_lua_value(vendor[field])},")
        lines.append("      items = {")
        for item in vendor["items"]:
            lines.append(f"        [{item['id']}] = {{")
            for field in ("name", "priceCopper", "stackCount", "numAvailable", "hasExtendedCost"):
                lines.append(f"          {field} = {_lua_value(item[field])},")
            lines.append("        },")
        lines += ["      },", "    },"]
    lines += ["  },", "}", ""]
    return "\n".join(lines)


def publish_atomic(target: Path, content: str) -> None:
    # Validated data are fully encoded before touching the destination file.
    target.parent.mkdir(parents=True, exist_ok=True)
    temp_name = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", newline="\n", delete=False,
                                         dir=target.parent, prefix=".crobmarket-", suffix=".tmp") as temp:
            temp_name = temp.name
            temp.write(content)
            temp.flush()
            os.fsync(temp.fileno())
        os.replace(temp_name, target)
    finally:
        if temp_name and os.path.exists(temp_name):
            os.unlink(temp_name)


def main() -> int:
    parser = argparse.ArgumentParser(description="WoW-Market: Offline-Haendlerdaten importieren")
    parser.add_argument("--input", type=Path, required=True, help="Normalisierte und freigegebene JSON-Daten")
    parser.add_argument("--output", type=Path, required=True, help="Ziel Vendors.lua")
    args = parser.parse_args()
    # Security: do not deserialize executable formats and do not fetch URLs.
    if not args.input.is_file() or args.input.stat().st_size > 30 * 1024 * 1024:
        parser.error("Eingabedatei fehlt oder ueberschreitet 30 MiB")
    if args.output.resolve() == args.input.resolve():
        parser.error("Input und Output duerfen nicht identisch sein")
    try:
        obj = json.loads(args.input.read_text(encoding="utf-8"))
        data = normalize(obj)
        if not data["vendors"]:
            raise ValidationError("Leere Datenbank wird nicht als Import veroeffentlicht")
        lua = export_lua(data)
    except (ValidationError, UnicodeError, json.JSONDecodeError) as exc:
        parser.error(str(exc))
    publish_atomic(args.output, lua)
    count = len(data["vendors"])
    total_items = sum(len(v["items"]) for v in data["vendors"])
    print(f"PASS: {count} Haendler / {total_items} Warenpositionen => {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
