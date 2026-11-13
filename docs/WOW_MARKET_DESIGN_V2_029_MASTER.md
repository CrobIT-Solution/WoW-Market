# WoW-Market Design V2 – verbindliches Sollbild und Entwicklungsstand

**13. November 2026 · Blackiron · Alpha 0.0.29 (Testversion)**

## Master-Design
Das **zweite vom Auftraggeber bereitgestellte Referenzbild** `WoW-Market_ Händlerübersicht in Azeroth(1).png` ist das verbindliche Sollbild für die Oberfläche. Das reale Ingame-Bild der Alpha 0.0.28 ist **nicht** als abgenommenes Enddesign anzusehen.

- **SHA-256 des unveränderten Original-Sollbilds:** `27f507eef2bad9f101ca1c5abec63e9b76f3c453e3e60962a178e90278bd557c`.
- Das Original-Sollbild ist **im vollständigen lokalen Git-Commit als Datei** unter `design/reference/WoW-Market_SOLL_Design_V2.png` versioniert; es ist nicht in diesem GitHub-Dokumentationsbranch eingebettet.
- Die Bildinhalte wie Beispielhändler, Preise, Rufstände und ein „Aktuell“-Status sind **Illustrationen, keine echte Spiel- oder Datenquelle**. Sie dürfen nicht als Daten importiert werden.
- Kein künftiger Funktionsrelease darf Navigation, Header, Panels, Typografie oder die vier Reiter ohne nachvollziehbaren Grundsatzbeschluss in eine andere Designrichtung zurückbauen.

## Ziel und Umsetzung (V2 Revision B)
- Panoramaheader, linke bebilderte Navigation, Suche, Pergament-Itemkarte, drei Preisbereiche und ikonbasierte Ergebniskarten in dunklem blauem Stein mit sichtbarer Goldrahmung.
- **Vier eindeutige und interaktive rechte Reiter:** Händler, Mob, Karte, Links. Alpha 0.0.28 zeigte im leeren Zustand irrtümlich Links/Karte/Links.
- Geöffnete Händler und Items zeigen belegte Details inklusive zweispaltiger Warenansicht, wenn Daten tatsächlich vorhanden sind.
- Ohne gewählten Händler eine hochwertige Übersicht aus **tatsächlichen** Zählern für eigene Händler, Community-Händler, Community-Items und Mobdaten anstelle leerer Platzhalter.
- Erhöhte Kontraste, neue datenfreie Stein-/Pergament- und Goldleisten-Texturen; positive Zustände klar grün.
- Keine Änderung an `NetProbe.lua`, `ItemLink.lua`, `Data/` oder vorhandenen lokalen SavedVariables. Der unbeabsichtigte nil-Item-ID-Weg im rechten Preisvergleich wurde korrigiert.
- Der `tests`-Ordner und das vollständige Konzeptbild bleiben **nur im Git-Quellstand**, nicht im Installations-ZIP.

## Validierung
- Vollständiges Installationspaket Alpha 0.0.29, ZIP-CRC und alle 16 TOC-Lua-Module: **PASS**.
- 32 TGA-Dateien: 28 aus Alpha 0.0.28 erhalten und 4 neue, ausschließlich dekorative Texturen.
- Bytes von 45 unbetroffenen Dateien gegenüber Alpha 0.0.28 nach SHA-256: **identisch** (u. a. NetProbe/ItemLink, Daten, Lizenzhinweise).
- Zwei-Client-Netzwerksimulation (WHISPER/PARTY/CHANNEL, ACK, eigene PING-Echos und Opt-in): **PASS**.
- Shift+Linksklick-/Chat-Vorrang-/Item-ID-Regressionsprüfungen: **PASS**.
- WoW-UI-Mocks für Aufbau, 4 Reiter, Datenübersicht, Händleransicht, Item-Auswahl und Preisdetail: **PASS**.
- Designhashes und kompletter Git-Backup-Checkout einschließlich Original-Sollbild: **PASS**.
- **Im echten WoW Forever visuell noch nicht abgenommen.** Es wird **keine pixelgenaue Übereinstimmung behauptet**.

## Artefakte und Git
- Installations-ZIP: `WoW-Market_0.0.29-alpha_Design-V2-Politur.zip`; Größe **2.320.524 Bytes**, SHA-256 `9778670eeacda2d1ff538040b026ef22999f26ac2475038cbdf4355ecf98836d`, 55 ZIP-Einträge.
- Vollständiger **lokaler Git-Commit**: `bf5fb107cc1406e54bdb07d5a97ac68b60cfc6c5`; voriger Git-Commit `03cda02e8282fda7c3802c3c6afa964fbebb9a61`; Entwicklername `Blackiron`.
- Vollständiges, geprüftes Bundle: `WoW-Market_0.0.29-alpha_Design-V2_Vollbackup.git.bundle`; SHA-256 `3b3fcabe69a236dcf9cb40c4527fde0c169c2d868b49a4e84e864fc0c846affe`.
- **Dieser GitHub-Branch enthält bislang nur die dokumentierte Referenz-/Release-Sicherung, nicht den vollständigen aktuellen Lua-/TGA-Code.** Der vollständige Git-Quellstand mit Original-Referenz liegt im überprüften lokalen Git-Bundle. Der alte `main` bleibt unverändert.

## Nächste Ingame-Abnahme
Neues ZIP bei vollständig geschlossenem Spiel installieren, aktiven `WoWMarket`-Ordner ersetzen, SavedVariables behalten. Ein reales Item per Shift + Linksklick suchen, mit bekanntem Händler testen und den rechten Grundzustand prüfen. Screenshots der echten Forever-UI mit dem unveränderten Sollbild vergleichen. Erst danach den Designstatus als „visuell abgenommen“ kennzeichnen.
