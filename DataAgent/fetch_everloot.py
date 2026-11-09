#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Bounded, explicit download of Everloot public vendor pages (stdlib only).

User-initiated network operation, not a background agent. No credentials,
no uploads, no automatic retries, no access to the WoW client. Raw JSON is
retained only locally and is excluded from the GitHub publication package.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import time
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qs, urlsplit, urlencode
from urllib.request import Request, build_opener, HTTPRedirectHandler

BASE_URL = "https://everloot.app/api/corpus/public"
MAX_BYTES_PER_PAGE = 12 * 1024 * 1024
MAX_PAGES_PER_RUN = 25  # Below anonymous quota of 30/hour (shared by other endpoints)
PAGE_SIZE = 500


class FetchError(RuntimeError):
    pass


class NoRedirects(HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        raise FetchError("Weiterleitung abgebrochen: fest vorgegebener API-Host erforderlich")


def checked_url(url: str, *, expected_offset: int) -> None:
    parts = urlsplit(url)
    if (parts.scheme != "https" or parts.netloc != "everloot.app" or
            parts.path != "/api/corpus/public" or parts.fragment or
            parts.username or parts.password):
        raise FetchError("Unerwartete Hostadresse/Weiterleitung im Corpus")
    q = parse_qs(parts.query, strict_parsing=True)
    if (set(q) != {"kinds", "limit", "offset"} or
            q["kinds"] != ["vendor"] or
            q["limit"] != [str(PAGE_SIZE)] or
            q["offset"] != [str(expected_offset)]):
        raise FetchError("Unerwartete Paginierung; kein externer URL-Aufruf")


def get_page(url: str, opener=None) -> dict:
    if opener is None:
        opener = build_opener(NoRedirects())
    req = Request(url, headers={"User-Agent": "WoW-Market/0.0.8 (noncommercial, contact via repository)",
                                "Accept": "application/json"})
    try:
        with opener.open(req, timeout=20) as response:
            if response.status != 200:
                raise FetchError(f"HTTP {response.status}; keine automatischen Wiederholungen")
            raw = response.read(MAX_BYTES_PER_PAGE + 1)
    except HTTPError as e:
        if e.code == 429:
            raise FetchError("HTTP 429: Rate-Limit erreicht. Retry-After beachten, nicht sofort erneut versuchen") from e
        raise FetchError(f"API-Fehler HTTP {e.code}") from e
    except URLError as e:
        raise FetchError("Netzwerkverbindung fehlgeschlagen") from e
    if len(raw) > MAX_BYTES_PER_PAGE:
        raise FetchError("API-Seite ueber 12 MiB; Download abgebrochen")
    try:
        obj = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as e:
        raise FetchError("API lieferte kein gueltiges UTF-8-JSON") from e
    if not isinstance(obj, dict) or obj.get("ok") is not True or not isinstance(obj.get("records"), list) or obj.get("unreachable"):
        raise FetchError("Unvollstaendige oder fehlerhafte API-Antwort")
    return obj


def collect_pages(*, max_pages: int, getter=get_page, sleeper=time.sleep) -> list[dict]:
    if type(max_pages) is not int or not 1 <= max_pages <= MAX_PAGES_PER_RUN:
        raise FetchError("Anfragelimit muss zwischen 1 und 25 liegen")
    offset = 0
    pages: list[dict] = []
    snapshot: str | None = None
    while True:
        url = BASE_URL + "?" + urlencode({"kinds":"vendor", "limit":PAGE_SIZE, "offset":offset})
        checked_url(url, expected_offset=offset)
        obj = getter(url)
        if obj.get("offset") != offset or type(obj.get("total")) is not int:
            raise FetchError("API-Paginierung passt nicht zum angefragten Offset")
        if snapshot is None:
            snapshot = obj.get("dataAsOf")
        elif snapshot != obj.get("dataAsOf"):
            raise FetchError("Snapshot hat waehrend des Downloads gewechselt; keine Daten publizieren")
        records = obj["records"]
        if len(records) > PAGE_SIZE or len(records) == 0 and obj.get("next") is not None:
            raise FetchError("Unplausible Anzahl an Records")
        pages.append(obj)
        offset += len(records)
        if obj.get("next") is None:
            if offset != obj["total"]:
                raise FetchError("Unvollstaendiger Corpus (total ungleich heruntergeladene Zeilen)")
            return pages
        if len(pages) >= max_pages:
            raise FetchError("Corpus zu gross fuer sicheres Tageskontingent; kein Teilimport. Freien API-Key bzw. kontrollierte Fortsetzung klaeren")
        checked_url(obj["next"], expected_offset=offset)
        sleeper(3)


def main() -> int:
    parser = argparse.ArgumentParser(description="User-initiated, bounded Everloot public vendor snapshot download")
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--max-pages", type=int, default=20)
    args = parser.parse_args()
    try:
        # Nothing is written until *all* pages pass the basic safeguards.
        pages = collect_pages(max_pages=args.max_pages)
        if any(x.get("next") is not None for x in pages[-1:]):
            raise FetchError("Corpus unvollstaendig")
        args.output_dir.mkdir(parents=True, exist_ok=True)
        for i, obj in enumerate(pages):
            target = args.output_dir / f"vendor_page_{i:04}.json"
            if target.exists():
                raise FetchError(f"Zieldatei existiert bereits: {target}")
            target.write_text(json.dumps(obj, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"Abgeschlossen: {len(pages)} Seiten, {sum(len(p['records']) for p in pages)} oeffentliche Beobachtungen. Jetzt OFFLINE validieren.")
        return 0
    except FetchError as e:
        parser.error(str(e))
    return 2

if __name__ == "__main__":
    raise SystemExit(main())
