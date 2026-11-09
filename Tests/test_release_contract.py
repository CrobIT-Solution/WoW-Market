# SPDX-License-Identifier: GPL-3.0-only
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
A = ROOT / "WoWMarket"

class ReleaseContractTests(unittest.TestCase):
    def test_optional_questie_api_loaded_before_search(self):
        toc = (A / "WoWMarket.toc").read_text(encoding="utf-8")
        self.assertIn("## OptionalDeps: QuestieDB", toc)
        self.assertLess(toc.index("OptionalQuestie.lua"), toc.index("VendorSearch.lua"))
        optional = (A / "OptionalQuestie.lua").read_text(encoding="utf-8")
        self.assertIn('LibQuestieDB', optional)
        self.assertNotIn('C_Map.SetUserWaypoint', optional)

    def test_wowhead_import_disabled_until_permission(self):
        source = (ROOT / "DataAgent/import_vendors.py").read_text(encoding="utf-8")
        self.assertIn("WoWHead-Datenimport gesperrt", source)
        self.assertIn("WoWHead", (A / "QUELLEN.txt").read_text(encoding="utf-8"))

    def test_toc_loads_link_provider_before_ui(self):
        toc = (A / "WoWMarket.toc").read_text(encoding="utf-8")
        self.assertLess(toc.index("Links.lua"), toc.index("UI.lua"))
        self.assertIn("## Interface: 16001", toc)
        self.assertIn("## Title: WoW-Market", toc)
        self.assertLess(toc.index("UI.lua"), toc.index("Minimap.lua"))

    def test_minimap_entry_is_clickable_and_does_not_need_chat(self):
        ui = (A / "UI.lua").read_text(encoding="utf-8")
        minimap = (A / "Minimap.lua").read_text(encoding="utf-8")
        self.assertIn("function ns.ToggleUI()", ui)
        self.assertIn("function ns.OpenSources()", ui)
        self.assertIn('"WoWMarketMinimapButton"', minimap)
        self.assertIn('"LeftButtonUp", "RightButtonUp"', minimap)
        self.assertIn('ns.db.minimapAngle = degrees', minimap)
        self.assertIn('"PLAYER_LOGIN"', minimap)
        self.assertNotIn("LaunchURL", minimap)

    def test_sources_tab_and_item_button(self):
        ui = (A / "UI.lua").read_text(encoding="utf-8")
        self.assertIn('"Quellen & Recht", "sources"', ui)
        self.assertIn('"WoWHead: Gegenstand"', ui)
        self.assertIn('"WoWHead: Haendler"', ui)
        self.assertIn("urlEdit:HighlightText()", ui)
        self.assertIn("Strg+C", ui)

    def test_no_executable_web_or_bot_operations(self):
        content = "\n".join(path.read_text(encoding="utf-8") for path in A.rglob("*.lua"))
        for forbidden in ("RunProgram(", "os.execute(", "io.popen(", "C_AuctionHouse.PlaceBid(", "BuyMerchantItem("):
            self.assertNotIn(forbidden, content)

    def test_manual_map_and_auction_controls(self):
        toc = (A / "WoWMarket.toc").read_text(encoding="utf-8")
        ui = (A / "UI.lua").read_text(encoding="utf-8")
        self.assertIn("MapActions.lua", toc)
        self.assertIn("AuctionScanner.lua", toc)
        self.assertIn('"Wegpunkt setzen"', ui)
        self.assertIn('"AH-Scan manuell starten"', ui)
        ah = (A / "AuctionScanner.lua").read_text(encoding="utf-8")
        self.assertIn('MAX_AUCTIONS = 30000', ah)
        self.assertIn('lastAuctionRequest', ah)

    def test_gpl3_only_license_in_source_and_addon_package(self):
        root_text = (ROOT / "LICENSE").read_text(encoding="utf-8")
        addon_text = (A / "LICENSE.txt").read_text(encoding="utf-8")
        self.assertEqual(root_text, addon_text)
        self.assertTrue(root_text.startswith("GNU GENERAL PUBLIC LICENSE"))
        self.assertIn("Version 3, 29 June 2007", root_text)
        toc = (A / "WoWMarket.toc").read_text(encoding="utf-8")
        self.assertIn("## X-License: GPL-3.0-only", toc)
        ui = (A / "UI.lua").read_text(encoding="utf-8")
        self.assertIn("WoW-Market-Code: GPL-3.0-only", ui)
        # Generated/imported data are intentionally NOT blanket-licensed as GPL.
        data = (A / "Data" / "Vendors.lua").read_text(encoding="utf-8")
        self.assertNotIn("SPDX-License-Identifier: GPL-3.0-only", data)

    def test_release_package_has_no_import_tools_or_credentials(self):
        self.assertTrue((A / "QUELLEN.txt").is_file())
        self.assertFalse(any(A.rglob("*.py")))
        self.assertFalse(any(A.rglob("*.json")))

if __name__ == "__main__": unittest.main()
