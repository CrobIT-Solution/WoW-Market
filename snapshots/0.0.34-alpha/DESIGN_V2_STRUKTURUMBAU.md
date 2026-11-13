# WoW-Market Alpha 0.0.34 – echter Design-V2-Strukturumbau

**Stand: 13.11.2026 · Entwickler Blackiron · Status: Entwickler-Testversion, Ingame-Abnahme offen.**

## Verbindlicher Bezug
Das zweite vom Nutzer bereitgestellte Referenzbild ist weiterhin die **Sollvorlage**. Der reale Ingame-Screenshot der Alpha 0.0.33 zeigte zwar Goldrahmen, aber weiterhin die alte strukturelle Aufteilung. Deshalb Revision **V2/G mit tatsächlichen nativen Datenkarten statt nur zusätzlichen Texturen**. Kein erfundener Händler, Item-Eintrag, Portrait, Preis oder Datum aus dem Sollbild übernommen.

## Funktionsänderungen
- Größere Itemkarte mit nativer Client-Attributzeile. Qualitätsangabe, Subtyp, maximale Stapelmenge und Mindeststufe ausschließlich bei tatsächlich geladenen `GetItemInfo`-Daten.
- Größere, getrennte zweizeilige Such-/Händler-Ergebniskarten und responsive Pagination.
- Rechter Händlerkopf größer; echte Händlerwaren mit lesbareren Icons/Zeilen. Händler-/Mobeinzelinformationen erhalten **eigene Datenfelder** statt einen unstrukturierten Textblock.
- Preisvergleich mit separaten Feldern. Differenz nur bei bekanntem AH-Preis, bekanntem Händler-Kaufmengenfaktor und ausdrücklich `hasExtendedCost == false`; sonst *Nicht vergleichbar*.
- Bei eindeutig passendem NPC-GUID darf das tatsächliche Blizzard-Zielportrait verwendet werden, andernfalls neutrales Icon.
- Informationsreiter mit echten Blizzard-Icons.
- Vier strukturierte Footersegmente: Datenstatus, Quellen, Preis-Hinweis, Version. Keine erfundene letzte Aktualisierung.
- **Alle bisherigen Grafiken, SavedVariables, Netzwerk- und Item-Übertragungsfunktionen bleiben unverändert.** Keine Installation-/Test-TXT im Spieler-ZIP (nur vier Lizenz-/Quellen-TXT).

## Verifizierte Artefakte
- **Spieler-ZIP:** `WoW-Market_0.0.34-alpha_Design-V2-Echte-Karten.zip`; **SHA256** `d6b321bdc890d604e703a4027f3da093cf1b6e719f8efbe79368f05ee95cfde5`; 2.360.415 Bytes, 62 Dateien, 16 Lua und 41 TGA.
- **Vollständiges Git-Bundle:** `WoW-Market_0.0.34-alpha_Design-V2_Vollbackup.git.bundle`; **SHA256** `3d6f5930ccf4f69e23ebd7ac8b3e6cf7c698eea4a6e17770c6c8dab0ced8e0d3`. `git bundle verify` PASS, vollständige History.
- **Vollständiger lokaler Quellcommit:** `5c7002904df934e1cf707c34d665f934f26fe589` (Blackiron); Parent `782401943fa9449b9bc86c493e795ce8fd50e15a`.
- Sourcebranch: `feature/wow-market-0.0.34-alpha-design-v2-layout`; lokales Tag `alpha-0.0.34-design-v2-layout-test`.
- ZIP aus frischem Checkout **identisch** nachgebaut; Hash stimmt. 58/62 Installer-Dateien bytegleich zu Alpha 0.0.33; einzige Änderungen im Installationspaket: `WoWMarket/Core.lua`, `UI.lua`, `DetailPanel.lua`, `WoWMarket.toc`.
- Vollständige Quellen enthalten die unveränderte Original-Designvorlage, Tests `test_design_structure034.lua`, `check_design_v2_034.py` und das reproduzierbare Buildskript.
- Offlineprüfungen: 16 Lua-Syntax, GUI-Mocks, Quellnavigation, native Detailfelder und Footer, echte Client-Attributanzeige, sichere Preisberechnung, Höhenplanung, Shift-Klick, PING/ACK, ZIP/TOC und Artwork-Hashes **PASS**.
- **Kein echter WoW-Forever-Ingame-Sichttest von 0.0.34. Kein Release.**

## Wichtige GitHub-Grenze
**Dieser GitHub-Branch ist nur ein dokumentierter Versionsnachweis, NICHT der vollständige 0.0.34-Quellbaum.** Die vollständige versionierte Codehistorie samt originalem Sollbild liegt im geprüften **lokalen Git-Bundle**. Der alte GitHub-`main`-Branch wurde nicht verändert. Keine CI, Merges, Builds, Deployments oder kostenpflichtigen Dienste.

## Nächster Ingame-Test
Bei geschlossenem Spiel ganzen aktiven `Interface/AddOns/WoWMarket`-Ordner durch das ZIP ersetzen und SavedVariables behalten. **Angel** beim echten Händler **Flakk** aufrufen, den rechten Händler-/Preisbereich, die größere Itemkarte und vierteiligen Footer gegen das zweite Referenzbild prüfen. Zweitaccount nicht erforderlich. Auffälligkeiten gesammelt auswerten, Design V2 erst nach realer Sichtabnahme freigeben.
