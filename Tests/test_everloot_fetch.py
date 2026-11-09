# SPDX-License-Identifier: GPL-3.0-only
import sys
from pathlib import Path
import unittest
sys.path.insert(0, str(Path(__file__).resolve().parents[1]/"DataAgent"))
from fetch_everloot import checked_url, collect_pages, FetchError

BASE="https://everloot.app/api/corpus/public?kinds=vendor&limit=500&offset="

def page(offset, size, total, next_=None, stamp="2026-11-09T01:00:00Z"):
    return {"ok":True,"offset":offset,"total":total,"records":[{"kind":"vendor"} for _ in range(size)],
            "dataAsOf":stamp,"next":next_}

class FetchTests(unittest.TestCase):
    def test_valid_two_pages(self):
        pages=[page(0,2,3,BASE+"2"), page(2,1,3)]
        def getter(url):
            return pages[0 if url.endswith('offset=0') else 1]
        self.assertEqual(len(collect_pages(max_pages=3,getter=getter,sleeper=lambda _: None)),2)

    def test_rejects_host_switch(self):
        with self.assertRaises(FetchError): checked_url("https://evil.example/api/corpus/public?kinds=vendor&limit=500&offset=0",expected_offset=0)

    def test_rejects_extra_parameters(self):
        with self.assertRaises(FetchError): checked_url(BASE+"0&token=secret",expected_offset=0)

    def test_snapshot_mismatch_stops(self):
        pages=[page(0,2,3,BASE+"2"),page(2,1,3,stamp="2026-11-09T02:00:00Z")]
        with self.assertRaises(FetchError): collect_pages(max_pages=3,getter=lambda u: pages[0 if u.endswith('offset=0') else 1],sleeper=lambda _:None)

    def test_budget_fails_before_partial_output(self):
        with self.assertRaises(FetchError):collect_pages(max_pages=1,getter=lambda _:page(0,1,5,BASE+"1"),sleeper=lambda _:None)

    def test_unexpected_redirect_url_stops(self):
        with self.assertRaises(FetchError):collect_pages(max_pages=2,getter=lambda _:page(0,1,2,"https://example.com"),sleeper=lambda _:None)

if __name__ == '__main__': unittest.main()
