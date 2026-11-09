#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Optional one-vendor API schema probe (no bulk downloads).

Runs ONLY when user has a provider-approved FOREVERDB_API_KEY.
The response stays raw; it is NOT automatically trusted/imported.
"""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


API_BASE = "https://foreverdb.net/api/v1/vendors/"


def main() -> int:
    parser = argparse.ArgumentParser(description="ForeverDB: einen Haendlerdatensatz zur Schema-Pruefung abrufen")
    parser.add_argument("--vendor-id", type=int, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    key = os.environ.get("FOREVERDB_API_KEY", "").strip()
    if not key:
        parser.error("STOP: kein freigegebener API-Key in FOREVERDB_API_KEY")
    if not 1 <= args.vendor_id < 2**31:
        parser.error("Ungueltige Vendor-ID")
    req = Request(API_BASE + str(args.vendor_id), headers={
        "X-API-Key": key,
        "Accept": "application/json",
        "User-Agent": "CrobIT-Market-SourceInspector/0.0.2",
    }, method="GET")
    try:
        with urlopen(req, timeout=15) as response:
            body = response.read(2 * 1024 * 1024 + 1)
            if len(body) > 2 * 1024 * 1024:
                parser.error("STOP: Antwort groesser als 2 MiB")
    except HTTPError as exc:
        if exc.code == 429:
            parser.error("STOP: API-Ratenlimit erreicht; kein automatischer Retry")
        parser.error(f"STOP: API HTTP {exc.code}; keine Wiederholung")
    except (URLError, TimeoutError) as exc:
        parser.error(f"STOP: API nicht erreichbar: {type(exc).__name__}")
    try:
        obj = json.loads(body.decode("utf-8"))
    except (UnicodeError, json.JSONDecodeError):
        parser.error("STOP: Antwort ist kein gueltiges UTF-8/JSON")
    if not isinstance(obj, dict) or "data" not in obj:
        parser.error("STOP: nicht erwartetes API-Format")
    args.out.parent.mkdir(parents=True, exist_ok=True)
    if args.out.exists():
        parser.error("STOP: Ausgabedatei existiert bereits; Ueberschreiben gesperrt")
    # The raw response is deliberately quarantined and not addon-loadable.
    with args.out.open("x", encoding="utf-8") as fh:
        json.dump(obj, fh, ensure_ascii=False, indent=2, sort_keys=True)
    print(f"Antwort gespeichert: {args.out}. Schema manuell pruefen; KEIN automatischer Import.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
