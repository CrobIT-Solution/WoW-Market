# WoW-Market 0.0.24-alpha – RGB-Fehlerbehebung
Stand: 12.11.2026. **Entwickler-Testversion, kein öffentlicher Release.**

## Echte Ingame-Beobachtung
Beim Start meldete WoW-Market: **„Addon aktiv; Netzwerkmodul: geladen“**. Der separate Netzwerk-Diagnoseweg wird also geladen.

Beim Öffnen der Benutzeroberfläche trat im aktuellen Forever-Client tatsächlich auf:
```
WoWMarket/UI.lua:551
SetBackdropBorderColor -> bad argument #1 to 'SetVertexColor'
r=0.730000, g=nil, b=nil
```

## Technische Ursache und Korrektur
`b:SetBackdropBorderColor(b.active and unpack(GREEN) or unpack(BRONZE))` überträgt wegen der Lua-Ausdruckregeln nur **einen** Wert des gewählten `unpack`-Aufrufs. Der grüne bzw. bronzene Farbvektor muss zuerst als **Tabelle** gewählt und erst dann direkt zu Argumenten expandiert werden.

Der vollständige lokale 0.0.24-Stand enthält ausschließlich diesen Zweizeilen-Fix, Versionskorrekturen und Testdokumentation. Der auf diesem Branch archivierte Patch zeigt den echten Quelltext-Hunk. Der **ältere GitHub-`main`-Quellstand (0.0.8)** enthält den UI-Code der aktuellen 0.0.24 **nicht**; der Patch darf nicht ungeprüft darauf angewendet werden.

## Vollständiger, getrennt gespeicherter Git-Stand
- ZIP `WoW-Market_0.0.24-alpha_UI-Farbfix.zip`
- SHA256 ZIP: `5931323e36221e337dfa68c52599c35c3f3c77a5051523f98f97a135fbf730ee`
- 1.388.230 Bytes, 50 Dateien, 15 Lua-Module.
- Vollständiges lokales Git-Backup `WoW-Market_0.0.24-alpha_Vollbackup.git.bundle`
- SHA256 Bundle: `3306296e1650e6053795820ae286fd812d3da6cde9f7286833eb02a2119bd62b`.
- Tatsächlich vorhandener **lokaler Git-Commit**: `2a2f3d0f273c16d95cc56ca162e2fb35edbcba52`; Elternstand: `deb2ea3`.
- ZIP und Bundle sind zusätzlich in der ChatGPT-Library unter `/WoW-Forever/WoW-Market/` gesichert.
- **Dieser GitHub-Branch enthält den Fehlerbehebungs-Patch und die Dokumentation, nicht die vollständigen aktuellen Lua-/TGA-Dateien.** Keine fälschliche Behauptung eines vollständigen Remote-Code-Releases.

## Validiert
- ZIP CRC und TOC-Einträge: PASS.
- 15 Lua-Dateien via `texlua` als ladbarer Quelltext: PASS.
- Gezielter echter Lua-RGB-Mock für beide Zustände (aktiv/inaktiv): PASS.
- Unveränderte Dateien bytegleich zum lokalen 0.0.23-Paket: PASS.
- `NetProbe.lua`, Everloot-`Data/Community.lua`, alle TGA-Art-Dateien unverändert.
- **Nach dem Farbfix ist ein realer Forever-Ingame-Test noch offen**, insbesondere Menü öffnen, ohne Lua-Fehler, und Netzwerkstatus.

## Weiteres Vorgehen
1. Lokale 0.0.24-ZIP bei geschlossenem WoW vollständig in den aktiven `AddOns/WoWMarket`-Ordner einsetzen. SavedVariables nicht löschen.
2. `/wowmarketdiag`, Hauptfenster, Quellenauswahl und `/wowmarketnet status` testen.
3. Erst nach stabiler UI einen synthetischen PING-/ACK-Test mit zwei freiwilligen Spielern beginnen.
4. Für einen vollständig buildbaren GitHub-Stand die vollständigen lokalen Quellen und binären Art-Dateien getrennt übertragen und gegen SHA-/TOC-Gates vergleichen, bevor ein Release in Frage kommt.
