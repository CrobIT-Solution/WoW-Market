# WoW-Market Alpha 0.0.32 – Design V2, Navigationskorrektur

Stand: 13.11.2026 · Maintainer: **Blackiron** · Entwickler-Testversion.

## Verbindliche Designbasis
Das **zweite vom Nutzer hochgeladene Referenzbild** bleibt der Master für Layout, Rahmen, Farben, Navigation und Typografie. Der Nutzer hat im echten Alpha-0.0.31-Ingame-Screenshot den linken zu kleinen bzw. unpassend eingerückten „Zurück“-Button und das optisch versetzte X oben rechts beanstandet. Diese zwei Fehler wurden gezielt korrigiert, ohne andere Bereiche neu zu gestalten.

## Korrekturen
- `UI.lua`: Vorhandenes Panoramabild `ReferenceHeaderV2.tga` enthält bereits Gold-X und Minus-Symbol. Zusätzliche sichtbare X-/`[ ]`-Beschriftungen entfernt. Native transparente WoW-Klickflächen anhand der Originalpixelkoordinaten 2048×128 verankert; die Hitboxen bewegen sich bei Größenänderung proportional mit dem Panorama. Schließen, Maximalansicht/Rückstellung und separates UI-Neuladen bleiben nutzbar.
- `UI.lua`: Linker Zurück-Knopf nutzt `NavNormal.tga` und `NavActive.tga`, goldene Beschriftung, Pfeil, sichtbare Innenabstände und responsive Breite. Drei Quellreiter werden daneben ohne Überlappung positioniert.
- `DetailPanel.lua`: Rechte Warenliste erhält entsprechend gestaltete Zurück-/Weiter-Knöpfe, mit unverändertem Paging.
- `DESIGN_STANDARD_V2.md`: Revision E hält diese Regeln verbindlich fest.
- `Core.lua` / `WoWMarket.toc` / Versionshinweise: Alpha 0.0.32.

## Nachgewiesene Prüfungen
- Alle 16 Lua-Dateien mit texlua/`loadfile`: PASS.
- Vollständiger UI-Mock, vier rechte Reiter, Händler- und Itemnavigation: PASS.
- Eigener Navigationstest: X-/Minus-Hitboxen, proportional zur Headerbreite, Fenster schließen/öffnen, Größe maximieren/wiederherstellen, linker Zurück-Knopf, Platzbedarf bei schmaler/breiter Ansicht: PASS.
- Item-Link-Mock und Zwei-Client-Netzwerk-PING/ACK-Mock: PASS.
- Detail-Pagination bei kleinen Fensterhöhen: PASS.
- Design-V2-Vertrag einschließlich originaler Grafik-Hashwerte: PASS.
- Installations-ZIP-CRC, TOC/SavedVariables, zweimaliger bitidentischer Paketbau: PASS.
- 50 der ursprünglichen 54 gemeinsamen ZIP-Dateien bytegleich, insbesondere sämtliche 32 Grafiken, Everloot/Community, NetProbe und ItemLink.
- Kein Testordner im ZIP, keine Demo-Angebote, keine Datenbankmigration, keine echte Ingame-Abnahme der Alpha 0.0.32.

## Reproduzierbare Dateien und Git
- Installations-ZIP: **WoW-Market_0.0.32-alpha_UI-Navigation-Fix.zip**; SHA256 **5ed141b5f789853a69263b7f17aece388f0eb9dfd532fc6013910f528083da15**; 55 ZIP-Einträge.
- Vollständiger lokaler Commit: **832ab74864cec3518efc8cf87a0ae11d37b3899c**, Elterncommit **96f9802686e21962ab2506b46bfaac7eb044fb4e**, Git-Author **Blackiron**.
- Git-Branch: `feature/wow-market-0.0.32-alpha-design-v2-navigation`; lokales Tag: `alpha-0.0.32-design-v2-navigation-test`.
- Vollständiges Git-Bundle: **WoW-Market_0.0.32-alpha_Design-V2_Vollbackup.git.bundle**; SHA256 **068655f639b33ca302330c228770e48d2d5ef855e0f6b1108e511aa8928b5e3f**; `git bundle verify` PASS.
- Vollständige Artefakte zusätzlich privat in der ChatGPT Library unter `/WoW-Forever/WoW-Market/`.

**GitHub-Abgrenzung:** Dieser GitHub-Archivbranch enthält diesen Prüfbericht und ältere Archivinhalte, nicht den vollständigen aktuellen Quellcode und die Binärgrafiken. Der vollständige versionierte Quellstand befindet sich im verifizierten Git-Bundle. `main` bleibt unverändert und älter. Keine GitHub CI, kein Release, kein Merge, keine bezahlten Dienste.

## Realer Sichttest
Bei geschlossenem WoW kompletten Ordner `Interface/AddOns/WoWMarket` ersetzen; SavedVariables behalten. Item **Angel** per Shift+Linksklick öffnen, Quellenleiste inkl. linker Zurück-Funktion testen, Händlerwaren-Seitenwechsel und Header-X/Minus sowie Großansicht prüfen. Danach Screenshot gegen das verbindliche zweite Konzeptbild auswerten.