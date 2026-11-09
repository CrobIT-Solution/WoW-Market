# SPDX-License-Identifier: GPL-3.0-only
import copy
import json
import tempfile
import unittest
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "DataAgent"))
from import_vendors import ValidationError, export_lua, normalize, publish_atomic


class ImportTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.sample = json.loads((Path(__file__).parent / "sample_synthetic.json").read_text(encoding="utf-8"))

    def test_wowhead_bulk_import_requires_clearance(self):
        payload = copy.deepcopy(self.sample)
        for name in ("Wowhead", "WoWHead.com", "www.wowhead.com"):
            payload["provider"] = name
            with self.assertRaisesRegex(ValidationError, "WoWHead-Datenimport gesperrt"):
                normalize(payload)

    def test_rejects_boolean_schema(self):
        payload = copy.deepcopy(self.sample)
        payload["schema"] = True
        with self.assertRaises(ValidationError): normalize(payload)

    def test_accepts_synthetic_data(self):
        result = normalize(self.sample)
        self.assertEqual(len(result["vendors"]), 2)
        self.assertIn("[90000001]", export_lua(result))

    def test_deterministic_vendor_and_item_order(self):
        payload = copy.deepcopy(self.sample)
        payload["vendors"].reverse()
        payload["vendors"][1]["items"].reverse()
        self.assertEqual(export_lua(normalize(self.sample)), export_lua(normalize(payload)))

    def test_duplicate_vendor_rejected(self):
        payload = copy.deepcopy(self.sample)
        payload["vendors"].append(copy.deepcopy(payload["vendors"][0]))
        with self.assertRaises(ValidationError): normalize(payload)

    def test_duplicate_item_rejected(self):
        payload = copy.deepcopy(self.sample)
        payload["vendors"][0]["items"].append(copy.deepcopy(payload["vendors"][0]["items"][0]))
        with self.assertRaises(ValidationError): normalize(payload)

    def test_negative_price_rejected(self):
        payload = copy.deepcopy(self.sample)
        payload["vendors"][0]["items"][0]["priceCopper"] = -1
        with self.assertRaises(ValidationError): normalize(payload)

    def test_wrong_boolean_rejected(self):
        payload = copy.deepcopy(self.sample)
        payload["vendors"][0]["seenInForever"] = "yes"
        with self.assertRaises(ValidationError): normalize(payload)

    def test_invalid_coordinates_rejected(self):
        payload = copy.deepcopy(self.sample)
        payload["vendors"][0]["x"] = 101
        with self.assertRaises(ValidationError): normalize(payload)

    def test_missing_map_for_position_rejected(self):
        payload = copy.deepcopy(self.sample)
        payload["vendors"][0]["mapID"] = None
        with self.assertRaises(ValidationError): normalize(payload)

    def test_foreverdb_attribution_required(self):
        payload = copy.deepcopy(self.sample)
        payload["provider"] = "ForeverDB.net"
        with self.assertRaises(ValidationError): normalize(payload)
        payload["attributionUrl"] = "https://foreverdb.net"
        self.assertEqual(normalize(payload)["provider"], "ForeverDB.net")

    def test_escapes_lua_strings(self):
        payload = copy.deepcopy(self.sample)
        payload["vendors"][0]["name"] = 'Vendor "quoted" \\ slash'
        lua = export_lua(normalize(payload))
        self.assertIn(r'\"quoted\"', lua)
        self.assertIn(r'\\ slash', lua)

    def test_rejects_control_characters(self):
        payload = copy.deepcopy(self.sample)
        payload["vendors"][0]["name"] = 'bad\nname'
        with self.assertRaises(ValidationError): normalize(payload)

    def test_rejects_wow_markup_in_provider(self):
        payload = copy.deepcopy(self.sample)
        payload["provider"] = "|cff00ffffFalsche Quelle|r"
        with self.assertRaises(ValidationError): normalize(payload)

    def test_rejects_attribution_redirects_and_urls_with_credentials(self):
        for url in ("http://foreverdb.net", "https://example.test/?next=bad", "https://user:pass@example.test"):
            payload = copy.deepcopy(self.sample)
            payload["attributionUrl"] = url
            with self.subTest(url=url), self.assertRaises(ValidationError): normalize(payload)

    def test_publishing_replaces_atomically(self):
        with tempfile.TemporaryDirectory() as temp:
            target = Path(temp) / "Vendors.lua"
            target.write_text("old", encoding="utf-8")
            content = export_lua(normalize(self.sample))
            publish_atomic(target, content)
            self.assertEqual(target.read_text(encoding="utf-8"), content)
            self.assertFalse(list(Path(temp).glob(".crobmarket-*.tmp")))


if __name__ == "__main__": unittest.main()
