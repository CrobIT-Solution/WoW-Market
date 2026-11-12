# WoW-Market 0.0.26-alpha – Item per Shift + Linksklick übernehmen

**Status:** Entwickler-Testversion, 13.11.2026. Noch nicht im echten Forever-Client abgenommen.

## Ausgangsbasis
- Die zuletzt real getestete **0.0.25-alpha** hat PARTY, WHISPER und CHANNEL jeweils mit PING/ACK erfolgreich abgeschlossen. GUILD mangels gemeinsamer Gilde ungeprüft.
- Neue Anforderung: Ein Item per Shift+Linksklick aus dem Spiel direkt in die WoW-Market-Suche übernehmen; vollständiger Name sichtbar, intern nach Item-ID exakt suchen.
- Keine neue Datensynchronisierung oder Hintergrundkommunikation in diesem Schritt.

## Umsetzung 0.0.26
- Neues passives `WoWMarket/ItemLink.lua`: Secure Post-Hooks auf verfügbare `HandleModifiedItemClick`, `ChatEdit_InsertLink` und `ChatFrameUtil.InsertLink`. Kein Austausch/Überschreiben der Blizzard-Funktionen.
- Nur bei offenem WoW-Market und Shift-Betätigung; Chat-Eingabefeld mit Fokus hat Vorrang.
- Nur echte `item:`-Hyperlinks, keine Zauber-/Quest-/Charakterlinks.
- Zeigt den gecachten Itemnamen oder den Namen aus dem angeklickten Link im Suchfeld; falls beides fehlt, einen eindeutig markierten Item-ID-Fallback.
- Sucht intern nach der tatsächlichen Item-ID, nicht nur nach dem gegebenenfalls mehrdeutigen Namen.
- Bei manuellem Tippen wird die Item-ID-Übernahme verworfen.
- Modernere und ältere Interface-Hooks werden nur bei vorhandenen Funktionen installiert; Duplikat-Ereignisse derselben Nutzeraktion kurz entprellt.
- Versionsangaben in `Core.lua`, `UI.lua`, `WoWMarket.toc` und Testdokumentation angepasst.
- Keine Änderung am SavedVariables-Schema, der Everloot-/Community-DB, Lizenzen, Artwork oder `NetProbe.lua`.

## Prüfnachweise
- **Alle 16 Lua-Module** mit `texlua` kompiliert: PASS.
- Gezielter Lua-Mock: Cache-Itemname, Namen aus Link, nackte Item-ID, exakte Suche nach ID, Duplikat-Unterdrückung, Chat-Vorrang, nur Shift, Nicht-Items nicht übernehmen, geschlossenes Hauptfenster ignorieren: PASS.
- ZIP-CRC und `.toc`-Einträge: PASS.
- Vergleich mit 0.0.25: **46 bestehende Dateien bytegleich**, einschließlich aller Grafiken, Daten, Netzwerkmodul und Lizenzen.
- **Kein echter Ingame-Shift-Klick-Test durchgeführt.**

## Vollständiger lokaler Git-Stand
- Lokaler Commit: `4868c7770ec0b9dfcbf33b866317ae43124b5f55`, Elterncommit `c305bf94d5785c9f5c0fbf413144321b1dfecb00`; Author/Maintainer: Blackiron.
- Installations-ZIP: `WoW-Market_0.0.26-alpha_Item-Shift-Klick.zip` (54 Einträge, 1.390.674 Bytes), SHA-256: `1b1c2e46b471e0ad08b58ab17cc4510326206a3eac3e4df5ce8156890a31d005`.
- Vollständiges Git-Backup: `WoW-Market_0.0.26-alpha_Vollbackup.git.bundle`, SHA-256: `06e5ec7cf0ca75fa9409f3444a28ffb126241a83466c3661646a1a6c09623c57`; per `git bundle verify` bestätigt.
- Beide Artefakte in ChatGPT Library unter `/WoW-Forever/WoW-Market/` gesichert.

**GitHub-Hinweis:** Dieser GitHub-Archivbranch enthält derzeit das Versionsmanifest, **nicht** sämtliche aktuellen 0.0.26-Lua- und Grafikdateien. Die komplette, git-versionierte Quelle befindet sich im gesicherten Bundle; der historische GitHub-`main`-Stand bleibt unverändert. Nicht als Release oder vollständigen Remote-Code-Checkout ausgeben.

## Nächster Ingame-Test
1. 🟩 **BEIDE ACCOUNTS:** Nur falls nötig: Alpha 0.0.26 installieren. Zur ersten Funktionsprüfung reicht zunächst **der Hauptaccount**.
2. 🟥 **Washakie Sturmrufer:** WoW-Market öffnen, normales Chat-Eingabefeld schließen, Item in Tasche **Shift + Linksklick**: korrekter Name ins Suchfeld übernommen und automatisch gesucht?
3. 🟥 Test mit einem zweiten Item. Danach Chat-Eingabe bewusst aktivieren und dort Shift+Klick: Chat muss normal funktionieren.
4. 🟩 Netzwerk-Regression optional: `/wowmarketnet status`, später einmal kontrollierter PARTY-PING/ACK. Für den Shift-Klick-Test ist kein zweiter Account nötig.
5. Screenshots dokumentieren, **keine sofortige Folgeversion** bei einem Einzelbefund.

Begleitdateien im ZIP: `ITEM_SHIFT_KLICK_START_HIER.txt` und `WoWMarket/SHIFT_KLICK_0.0.26.txt`.
