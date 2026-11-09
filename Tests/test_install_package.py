# SPDX-License-Identifier: GPL-3.0-only
"""Contract: a user ZIP contains only one drop-in WoWMarket addon."""
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from zipfile import ZipFile

ROOT = Path(__file__).resolve().parents[1]
PREFIX = "AddOns/WoWMarket/"


class InstallerTests(unittest.TestCase):
    def test_one_folder_install_bundle(self):
        with tempfile.TemporaryDirectory() as td:
            output = Path(td) / "install.zip"
            subprocess.run(
                [sys.executable, str(ROOT / "Tools/build_install_package.py"),
                 "--output", str(output)],
                cwd=ROOT, capture_output=True, text=True, check=True,
            )
            with ZipFile(output) as zf:
                self.assertIsNone(zf.testzip())
                entries = zf.namelist()
                self.assertEqual(len(entries), len(set(entries)))
                self.assertTrue(entries and all(s.startswith(PREFIX) for s in entries))
                for rel in ("WoWMarket.toc", "Core.lua", "UI.lua",
                            "Data/Vendors.lua", "LICENSE.txt", "QUELLEN.txt"):
                    self.assertIn(PREFIX + rel, entries)
                toc = zf.read(PREFIX + "WoWMarket.toc").decode("utf-8")
                for line in toc.splitlines():
                    if line.strip() and not line.startswith("##"):
                        self.assertIn(PREFIX + line.strip(), entries)
                self.assertEqual(
                    zf.read(PREFIX + "LICENSE.txt"),
                    (ROOT / "LICENSE").read_bytes(),
                )
                for name in entries:
                    self.assertFalse(name.endswith((".py", ".json", ".pem", ".env", ".key")))
                    self.assertFalse(any(p in name.split("/") for p in
                                         ("Tests", "Tools", "DataAgent", ".git")))


if __name__ == "__main__":
    unittest.main()
