# WoW-Market Alpha 0.0.31 – Design V2 Detailbereich

13. November 2026 · Maintainer: **Blackiron** · Entwickler-Testversion

## Reale Fehlergrundlage
Auf dem Ingame-Screenshot von Alpha 0.0.30 (WuarK / Abgenutzter Langschild) überlappen rechts unten Händlerinformationen und Preisvergleich die untere Panelkante und die Links. **Das zweite vom Nutzer vorgegebene Referenzbild bleibt das verbindliche Soll-Design.**

## Implementierte Revision D
- Rechter Warenbereich reserviert nun mindestens 174 UI-Einheiten für Händler- und Preisdetails. Bei geringerer Höhe werden 2/4/6/8 reale Angebote pro Seite gezeigt, weitere über die Seitennavigation.
- Untere zwei Schnelllinks werden bei wenig Platz ausgeblendet; dieselben Ziele bleiben über den Reiter Links erreichbar.
- Preisvergleich auf drei kompakte Informationszeilen verkürzt, Schrift und Höhe begrenzt; Händlerinformationen verdichtet. Kein Preis erfunden.
- Netzwerkmodul, Itemlink-Modul, 32 Grafiken, Everloot-/Communitydaten, SavedVariables und Lizenzen unverändert.

## Lokale Tests
- 55 Installationsdateien (16 Lua-Dateien), ZIP/TOC/CRC: PASS; tests/ nicht ausgeliefert.
- 16 Lua-Module syntaktisch geprüft: PASS.
- Neues Testskript für die tatsächlich implementierte Waren-/Detailhöhenplanung bei verschiedenen Panelhöhen: PASS.
- UI-Mock und Max/Restore, Shift-Klick-/Item-ID-Regressionsprüfung, Zwei-Client-PING/ACK-Mock, Design-V2-Arthashes: PASS.
- 50 von 54 gemeinsamen Installerdateien zu Alpha 0.0.30 byteidentisch; geändert nur Core.lua, DetailPanel.lua, UI.lua, WoWMarket.toc und separater Installationshinweis.
- **Die Ingame-Sichtabnahme von Alpha 0.0.31 ist noch offen.**

## Versionierter Quellstand
- Vollständiger lokaler Git-Commit: 96f9802686e21962ab2506b46bfaac7eb044fb4e (Blackiron), Parent: f41685fc0f9d14393360400bfbda594416fe9b31.
- Vollständiges lokales Git-Bundle: WoW-Market_0.0.31-alpha_Design-V2_Vollbackup.git.bundle; SHA-256: bb1fd9b01924870d3649a5341a4de56b2d3c71ccefd86c1c1b6ecb77b9c82c06.
- ZIP: WoW-Market_0.0.31-alpha_Design-V2-Detailfix.zip; 2.321.769 Bytes, SHA-256: 3ed3d2f2a1736d4f031a2bbf6e0e155028556ebaddf81094b3c0b72765f56c26.
- Vollständige ZIP und Git-Bundle auch privat in ChatGPT Library unter /WoW-Forever/WoW-Market/ gesichert.

**GitHub-Hinweis:** Dieser GitHub-Archivbranch enthält nur Design- und Versionsdokumentation, **nicht** den vollständigen aktuellen Quellcode samt TGA-Bildern. Dieser liegt im verifizierten lokalen Git-Bundle. Der alte main-Branch wurde nicht überschrieben. Kein CI, Merge, Release oder Deployment.

## Nächster echter Test
WoW vollständig schließen, kompletten WoWMarket-Installationsordner ersetzen, WTF/SavedVariables behalten. WuarK / Abgenutzter Langschild öffnen, rechte untere Panels und die Waren-Pagination kontrollieren, einmal maximieren und wiederherstellen. Das Design bleibt bis zur erfolgreichen Sichtprüfung nicht endgültig abgenommen.