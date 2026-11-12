# WoW-Market 0.0.27-alpha – Lesbarkeit und stabiler UI-Standard

**Build:** `WoW-Market_0.0.27-alpha_Design-V1.zip`
- SHA-256: `2bec81cf13bc794ba885c79b8ec9fa53b1ab73a7667f9ad83440cea1a9420c78`
- 1.401.920 Bytes; **57 ZIP-Dateien**, **16 Lua-Module**.
- Vollständiger lokaler Git-Commit: `315083c414e55152cef6f1e48af3fcfcdcf64316`; Author Blackiron.
- Git-Bundle: `WoW-Market_0.0.27-alpha_Design-V1_Vollbackup.git.bundle`, SHA-256 `00edba6627ce9a260137df4b569eb36332c8cf2e0278034195652ef151829acc`.
- Vollständige Dateien zusätzlich in privater ChatGPT Library `/WoW-Forever/WoW-Market/` gesichert.

## Was tatsächlich geändert wurde
- Genau sechs bisherige Dateien geändert: `UI.lua`, `DetailPanel.lua`, `Core.lua`, `TESTHINWEISE.txt`, `VERSION_UND_INSTALLATION.txt`, `WoWMarket.toc`.
- Drei neue Dokumentationsdateien im ZIP: `TEST_START_HIER_0.0.27.txt`, `WoWMarket/DESIGN_ART_HASHES_V1.sha256`, `WoWMarket/DESIGN_STANDARD_V1.md`.
- **48 vorherige Dateien byteidentisch** zu Alpha 0.0.26, insbesondere 25 TGA-Artworks, `NetProbe.lua`, `ItemLink.lua`, Everloot-/Communitydaten, Lizenzhinweise.
- Mehr Lesbarkeit/Kontrast, rechte Spalte von 44,5 % auf 38 %, leere Bestandsflächen zusammengerückt, dynamische Warenpaginierung bei kleinerer Höhe, größere Preiswerte.

## Testbelege und Limit
- ZIP-CRC und `.toc`-Konsistenz **PASS**; alle 16 Lua-Module mit `texlua loadfile` **PASS**.
- Design-Check (12 Vertragsregeln/25 Grafiken) **PASS**.
- UI-Mock inklusive voller Fensterinitialisierung und rechter Warenansicht (0/4/8 Einträge) **PASS**.
- Bestehende Item-Shift-Klick-Regression **PASS**.
- Zwei-Client-Netzwerksimulation inklusive PARTY/WHISPER/CHANNEL **PASS**.
- **Echter WoW-Forever-Ingame-Sichttest für 0.0.27 noch nicht erfolgt.**

## GitHub-Grenze
Dieser GitHub-Branch dokumentiert den verbindlichen Designstandard sowie die Provenienz zum **vollständigen lokalen** Git-Commit, enthält aber noch nicht den vollständigen aktuellen Quellbaum mit binären Grafiken. `main` nicht überschrieben, kein CI, Release oder Deployment.
