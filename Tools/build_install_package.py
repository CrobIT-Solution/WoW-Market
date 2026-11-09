#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Build a one-folder manual install ZIP. No network, no third-party libraries."""
from __future__ import annotations

import argparse
import os
from pathlib import Path, PurePosixPath
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "WoWMarket"
OUTPUT = ROOT / "Downloads" / "WoW-Market_Alpha_0.0.8_Install.zip"
PREFIX = "AddOns/WoWMarket/"
STAMP = (2026, 11, 9, 0, 0, 0)


def manifest() -> list[tuple[str, Path]]:
    toc = ADDON / "WoWMarket.toc"
    if not toc.is_file() or toc.is_symlink():
        raise ValueError("WoWMarket.toc missing or unsafe")
    text = toc.read_text(encoding="utf-8")
    for marker in ("## Interface: 16001", "## Version: 0.0.8-alpha",
                   "## X-License: GPL-3.0-only"):
        if marker not in text:
            raise ValueError("Unexpected TOC: " + marker)
    entries = ["WoWMarket.toc"]
    entries += [line.strip() for line in text.splitlines()
                if line.strip() and not line.startswith("##")]
    entries += ["QUELLEN.txt", "LICENSE.txt"]
    if len(entries) != len(set(entries)):
        raise ValueError("Duplicate file in TOC/manifest")
    if (ADDON / "LICENSE.txt").read_bytes() != (ROOT / "LICENSE").read_bytes():
        raise ValueError("Addon GPL licence does not match repository LICENSE")
    result, total_bytes = [], 0
    for rel in entries:
        p = PurePosixPath(rel)
        if (p.is_absolute() or ".." in p.parts or str(p) != rel
                or p.suffix not in (".lua", ".toc", ".txt")):
            raise ValueError("Unsafe addon path: " + rel)
        src = ADDON.joinpath(*p.parts)
        if not src.is_file() or src.is_symlink():
            raise ValueError("Missing or symlinked addon file: " + rel)
        total_bytes += src.stat().st_size
        if total_bytes > 20 * 1024 * 1024:
            raise ValueError("Addon exceeds safe size limit")
        result.append((rel, src))
    return result


def build(output: Path) -> int:
    files = manifest()
    output.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            prefix=".wowmarket-", suffix=".zip", dir=output.parent, delete=False
        ) as handle:
            temporary = Path(handle.name)
        with zipfile.ZipFile(temporary, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
            for rel, source in files:
                entry = zipfile.ZipInfo(PREFIX + rel, STAMP)
                entry.compress_type = zipfile.ZIP_DEFLATED
                entry.external_attr = 0o644 << 16
                zf.writestr(entry, source.read_bytes(), compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
        with zipfile.ZipFile(temporary, "r") as zf:
            expected = {PREFIX + rel for rel, _ in files}
            if set(zf.namelist()) != expected or zf.testzip() is not None:
                raise ValueError("Invalid ZIP contents or CRC")
        os.replace(temporary, output)
        print(f"OK: {len(files)} files in {output}")
        return len(files)
    finally:
        if temporary and temporary.exists():
            temporary.unlink()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build single-folder WoW-Market install ZIP")
    parser.add_argument("--output", type=Path, default=OUTPUT)
    args = parser.parse_args()
    build(args.output.resolve())
