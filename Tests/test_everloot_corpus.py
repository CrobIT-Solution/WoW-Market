# SPDX-License-Identifier: GPL-3.0-only
"""Faked-only validation of Everloot public vendor record converter."""
from pathlib import Path
import sys, unittest, copy
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "DataAgent"))
from convert_everloot_corpus import convert, ValidationError


def record(install, vendor=120, item=250, price=1000):
    import hashlib
    pseudonym = "pub-" + hashlib.md5(install.encode()).hexdigest() if install is not None else None
    row = {"kind": "vendor",
            "vendorNpcId": vendor, "capturedAt": "2026-11-08T12:00:00Z",
            "items": [{"itemId": item, "priceCopper": price}]}
    if pseudonym is not None:
        row["installId"] = pseudonym
    return row


def page(records, *, offset=0, total=None, next_=None):
    return {"ok": True, "offset": offset, "total": total if total is not None else len(records),
            "next": next_, "records": records, "dataAsOf": "2026-11-08T13:00:00Z",
            "attribution": {"licence": "CC BY-SA 4.0", "source": "https://everloot.app",
                            "licenceUrl": "https://creativecommons.org/licenses/by-sa/4.0/",
                            "credit": "Data from Everloot", "terms": "https://everloot.app/terms"}}


class EverlootTests(unittest.TestCase):
    def setUp(self):
        self.valid = [record("reporter-A"), record("reporter-B"), record("reporter-C")]

    def test_quality_report_contains_aggregates_not_reporters(self):
        import json
        report = {}
        convert([page(self.valid + [record(None)])], report=report)
        self.assertEqual(report["observationRecords"], 4)
        self.assertEqual(report["recordsWithPublicPseudonym"], 3)
        self.assertEqual(report["recordsWithoutPublicPseudonym"], 1)
        self.assertEqual(report["publishedNpcItemPairs"], 1)
        self.assertEqual(report["vendorNamesUnresolved"], 1)
        self.assertNotIn("pub-", json.dumps(report))

    def test_three_independent_reports_confirm(self):
        result = convert([page(self.valid)])
        self.assertEqual(len(result["vendors"]), 1)
        self.assertEqual(result["vendors"][0]["items"][0]["priceCopper"], 1000)
        self.assertEqual(result["vendors"][0]["items"][0]["stackCount"], None)
        self.assertTrue(result["vendors"][0]["seenInForever"])
        self.assertEqual(result["license"], "CC BY-SA 4.0")
        self.assertEqual(result["dataAsOf"], "2026-11-08")

    def test_missing_public_pseudonym_is_skipped(self):
        mixed = self.valid + [record(None)]
        self.assertEqual(convert([page(mixed)])["vendors"][0]["items"][0]["priceCopper"], 1000)

    def test_only_missing_pseudonyms_cannot_confirm(self):
        with self.assertRaises(ValidationError):
            convert([page([record(None) for _ in range(5)])])

    def test_invalid_raw_install_id_fails_closed(self):
        bad = self.valid.copy()
        bad[0] = dict(bad[0], installId="sensitive-raw-id")
        with self.assertRaises(ValidationError): convert([page(bad)])

    def test_cross_snapshot_pages_fail_closed(self):
        p1 = page(self.valid[:2], total=3, next_="https://everloot.app/api/corpus/public?offset=2")
        p2 = page(self.valid[2:], offset=2, total=3)
        p2["dataAsOf"] = "2026-11-08T14:00:00Z"
        with self.assertRaises(ValidationError): convert([p1, p2])

    def test_duplicate_reporter_not_corroboration(self):
        with self.assertRaises(ValidationError):
            convert([page([record("reporter-A")] * 3)])

    def test_two_reports_not_corroboration(self):
        with self.assertRaises(ValidationError): convert([page(self.valid[:2])])

    def test_price_conflict_excluded(self):
        records = self.valid + [record("reporter-D", price=2000), record("reporter-E", price=2000), record("reporter-F", price=2000)]
        with self.assertRaises(ValidationError): convert([page(records)])

    def test_incomplete_pagination_rejected(self):
        with self.assertRaises(ValidationError):
            convert([page(self.valid[:2], total=3, next_="https://everloot.app/api/corpus/public?offset=2")])

    def test_complete_two_pages(self):
        p1=page(self.valid[:2], offset=0, total=3, next_="https://everloot.app/api/corpus/public?offset=2")
        p2=page(self.valid[2:], offset=2, total=3)
        self.assertEqual(len(convert([p2,p1])["vendors"]), 1)

    def test_rejects_unreachable(self):
        broken = page(self.valid)
        broken["unreachable"] = True
        with self.assertRaises(ValidationError): convert([broken])

    def test_rejects_wrong_license(self):
        broken = page(self.valid)
        broken["attribution"]["licence"] = "Public domain"
        with self.assertRaises(ValidationError): convert([broken])

    def test_catalog_enriches_names_only_when_supplied(self):
        cat={"vendors":{"120":{"name":"Synthetischer Haendler", "zone":"Testgebiet", "mapID":999, "x":40, "y":50}},
             "items":{"250":"Synthetische Ware"}}
        result = convert([page(self.valid)], cat)
        self.assertEqual(result["vendors"][0]["name"],"Synthetischer Haendler")
        self.assertEqual(result["vendors"][0]["items"][0]["name"],"Synthetische Ware")
        self.assertEqual(result["vendors"][0]["mapID"],999)

    def test_placeholder_without_catalog_is_explicit(self):
        result=convert([page(self.valid)])
        self.assertIn("Name unbekannt",result["vendors"][0]["name"])
        self.assertIsNone(result["vendors"][0]["mapID"])

    def test_wow_markup_in_catalog_fails(self):
        with self.assertRaises(ValidationError):
            convert([page(self.valid)], {"vendors":{"120":{"name":"|cffabcdbad"}}})

    def test_no_unconfirmed_stock_or_extended_cost(self):
        result=convert([page(self.valid)])
        item=result["vendors"][0]["items"][0]
        self.assertIsNone(item["numAvailable"])
        self.assertIsNone(item["hasExtendedCost"])


if __name__ == "__main__": unittest.main()
