# WoW-Market 0.0.28-alpha – Design V2 Snapshot

**Entwickler-Testversion**, 13.11.2026. Verbindliche visuelle Referenz: **zweiter Screenshot des Nutzers**, nicht die tatsächlich im Spiel gezeigte alte V1-Oberfläche.

## Prüfbarkeit und Sicherung
- Installations-ZIP: `WoW-Market_0.0.28-alpha_Design-V2_Referenzbild-2.zip`
- ZIP SHA-256: `251f8badfe4940f95d9b8c65a53633e518a10442f426c8b0dc2c4af91de93635`
- **65 ZIP-Einträge**, 16 Lua-Module; vollständiger Ordner `WoWMarket`.
- Vollständiges Git-Backup: `WoW-Market_0.0.28-alpha_Design-V2_Vollbackup.git.bundle`
- Bundle SHA-256: `29c213865a79827ea9222196410105f3ba0725532c1bef9aa74799a51999fe94`
- **Vollständiger lokaler Git-Commit**: `03cda02e8282fda7c3802c3c6afa964fbebb9a61` (Branch `feature/wow-market-0.0.28-alpha-design-v2`, Author Blackiron). Vorgänger `315083c414e55152cef6f1e48af3fcfcdcf64316` (Alpha 0.0.27).
- ZIP und Bundle gesichert in ChatGPT Library `/WoW-Forever/WoW-Market/`.
- **50/57 Ausgangsdateien bytegleich zu 0.0.27**, einschließlich Daten, Netzmodul `NetProbe.lua`, Item-Link-Modul `ItemLink.lua`, bestehender TGA-Grafiken, Lizenzdateien.
- Neue ausschließlich dekorative TGA: `ReferenceHeaderV2.tga` (vom Nutzerscreenshot abgeleiteter Kopfbereich), `AzureStoneV2.tga` und `GoldRailV2.tga`.

## Prüfung und offener Punkt
- 16 Lua-Dateien: `texlua loadfile` **PASS**
- UI-Mock: Fensteraufbau, Fensteranzeige, Shift+Item-Link, Klick auf Item-Ergebnis, Händlerquellen und Waren-Detailpanel **PASS**
- Netzwerk-Mock 0.0.25: PARTY/WHISPER/CHANNEL, ACK, Selbst-Echo, opt-in **PASS**
- Item-Link-Mock 0.0.26: Shift-Klick, Chat-Vorrang, Item-ID, Deduplizierung **PASS**
- V2 Design Guard / Artwork Hashes **PASS**
- ZIP-CRC und TOC **PASS**
- **Ingame-Sichtabnahme von 0.0.28 offen**; keine Behauptung pixelgenauer Übereinstimmung ohne echten WoW-Client.
- **GitHub-Archiv enthält die Design- und Versionsdokumentation, noch nicht alle Binär-/Quelldateien.** Kein Merge, CI-Run, Signing, Release oder Upload zu einem Drittanbieter.

## Installations-/Freigabegate
1. Bei geschlossenem Spiel den ganzen aktiven `Interface/AddOns/WoWMarket`-Ordner sichern und durch das ZIP ersetzen. SavedVariables **nicht** löschen.
2. Im echten Spiel Kopf, Navigation, Itemkarte, Händler-/Moblisten, rechte Details und Footer gegen das zweite Referenzbild vergleichen; sowohl mit bekannter Ware als auch ohne Angebotsdaten prüfen.
3. Einmal Shift+Item-Link testen. Keine neue Alpha wegen einzelner optischer Auffälligkeiten; Befunde sammeln und gezielt korrigieren.
4. Design V2 erst nach expliziter Ingame-Sichtfreigabe als endgültig abgenommen markieren.
