from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
A = ROOT / "WoWMarket"

class ReleaseContractTests(unittest.TestCase):
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
        self.assertIn('"Quellen & Recht"', ui)
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
        self.assertIn('MAX_PROCESS_AUCTIONS = 80000', ah)
        self.assertIn('StartTargetedAuctionSearch', ah)
        self.assertIn('ITEM_SEARCH_RESULTS_UPDATED', ah)
        self.assertIn('lastSuccessfulReplicateAt', ah)
        self.assertIn('FAILED_RETRY_GUARD', ah)

    def test_search_and_esc_and_new_ah_actions_are_exposed(self):
        ui = (A / "UI.lua").read_text(encoding="utf-8")
        self.assertIn("Keine Treffer fuer '", ui)
        self.assertIn("cacheItemByQuery", ui)
        self.assertIn("UISpecialFrames", ui)
        self.assertIn("root:Hide()", ui)
        self.assertIn("AH-Preis zu diesem Item", ui)
        self.assertIn("row.zone:SetText", ui)
        self.assertIn("row.coord:SetText", ui)

    def test_release_package_has_no_import_tools_or_credentials(self):
        self.assertTrue((A / "QUELLEN.txt").is_file())
        self.assertFalse(any(A.rglob("*.py")))
        self.assertFalse(any(A.rglob("*.json")))

if __name__ == "__main__": unittest.main()
