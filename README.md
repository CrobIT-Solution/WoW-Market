# WoW-Market

**Free, independent World of Warcraft: Forever addon – ALPHA 0.0.8, not yet verified in the live game client.**

WoW-Market lets players record merchant inventory while opening merchants normally, search collected information, inspect zones and compare optional manually collected auction snapshots. Click the **coin icon on the minimap** to open the interface. No chat command required. The addon does not automate any in-game action, browse the web, fetch APIs or upload player information. If QuestieDB is already installed, the addon can use its public Lua API for optional, clearly labelled NPC/item name and possible spawn hints; this data is not bundled or represented as a verified map point.

**Currently shipped vendor database is empty.** Third-party observation data will only be shipped once tested and correctly licensed. A separate local Python tool can fetch the documented Everloot public observations on the user's explicit request, validate them, generate a provenance/quality report and create an attributed Lua vendor dataset. Wowhead remains link-only until redistribution permission is documented.

## Read first

- [German setup and use](README_DE.md)
- [Precise Everloot import plan](EVERLOOT_IMPORT_DE.md)
- [Live-client acceptance checklist](ABNAHME_CHECKLISTE_DE.md)
- [Publication and Blizzard policy](VEROEFFENTLICHUNG_DE.md)
- [Sources and third-party notices](DATENQUELLEN_UND_RECHTE.md)
- [Source architecture and Wowhead integration gates](QUELLEN_ARCHITEKTUR_DE.md)
- [Changelog](CHANGELOG.md)

**Licence:** Original WoW-Market addon code, Python tools and tests are released under [GNU GPL v3.0 only](LICENSE) (`GPL-3.0-only`). Copyright (C) 2026 CrobIT-Solution and WoW-Market contributors for their respective original contributions. A full licence copy is shipped as `WoWMarket/LICENSE.txt`. See [licence scope (German)](LIZENZ_ENTSCHEIDUNG_DE.md). **Excluded:** third-party vendor observations (future Everloot-derived data remain CC BY-SA 4.0), Blizzard game artwork and trademarks, and unlicensed Wowhead/QuestieDB datasets. Not affiliated with or endorsed by Blizzard, Wowhead, Everloot, ForeverDB or QuestieDB.
