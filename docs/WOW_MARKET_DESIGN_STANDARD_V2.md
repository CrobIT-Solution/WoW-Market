# WoW-Market – verbindlicher Designstandard V2

**Verbindliches Sollbild: das vom Nutzer bereitgestellte zweite Screenshotbild „WoW-Market_ Händlerübersicht in Azeroth(1).png“.**

Stand: 13.11.2026. Maintainer: **Blackiron**. Version: **0.0.28-alpha**. **Der ältere Designstandard V1 (0.0.27) ist als finales Designziel abgelöst.** Design V2 ist im Addon implementiert und lokal getestet; eine abschließende visuelle WoW-Forever-Abnahme steht noch aus.

## Verbindliche Vorgaben
- Das vollständige Panorama mit Horde-/Stadtmotiv und „WoW-Market“-Titel aus dem **vom Nutzer bereitgestellten Referenzbild** als dekorativer Header; spielbare Widgets und Schließen/Größe/Neuladen bleiben echte UI-Elemente.
- Dunkelblaue Steinflächen mit Goldrahmen, große original bebilderte linke Navigation, gut lesbare Suche, permanente Pergament-Itemkarte, drei starke Preisfelder, strukturierte Ergebniskarten mit Icons.
- Rechts breite Fläche für Händler-/Mob-/Karten-/Linkinformationen, zwei Waren-Spalten mit Paging und bei genügend Platz zwei Informationsbereiche. Fehlende Daten klar und attraktiv kennzeichnen.
- Unten eine sichtbare, datenbasierte Offline-/Quellen-/Versionsstatusleiste. Grün nur für Zustände, Gold für Hervorhebung, hoher Schriftkontrast. Keine global skalierte Mikroschrift.
- **Keinerlei Demo-Händler, NPC-Porträts, Fantasiepreise, erfundene Items, Karten/Standorte oder fälschlicher „Aktuell“-Status aus dem Referenzbild**. Ausschließlich bereits vorhandene Beobachtungen und rechtmäßig eingebundene Quellen darstellen.
- Item-Shift-Klick, echte Item-ID-Suche, Netzwerk PING/ACK, alle gespeicherten Beobachtungen und Lizenzhinweise erhalten. Kein HTTP, Upload, automatische Handelsaktion oder zusätzlicher Hintergrundverkehr.
- Keine ungefragten grundsätzlichen Designwechsel bei Funktionsversionen. Anpassungen nur aufgrund nachgewiesener Fehler, notwendigen Funktionsausbaus oder ausdrücklicher Freigabe.

## Referenz und technische Checks
Der vollständige Quellbaum liegt in der vom Nutzer gesicherten **lokalen Git-Historie** als Commit `03cda02e8282fda7c3802c3c6afa964fbebb9a61` und im verifizierten Git-Bundle `WoW-Market_0.0.28-alpha_Design-V2_Vollbackup.git.bundle`.

Die Installations-ZIP `WoW-Market_0.0.28-alpha_Design-V2_Referenzbild-2.zip` enthält `WoWMarket/DESIGN_STANDARD_V2.md`, `DESIGN_ART_HASHES_V2.sha256` und `tests/check_design_v2.py`. Alle 16 Lua-Module bestehen Syntaxprüfung, der simulierte UI-Aufbau und der Item-Shift-Klick–Händler-Flow funktionieren, und vorhandene Netzwerk-/Shift-Klick-Regressionstests bleiben bestanden. **Kein echter Forever-Sichttest der V2 erfolgt.**

**GitHub-Abgrenzung:** Dieses GitHub-Archiv enthält zunächst die verbindlichen Designvorgaben und Prüfmetadaten, nicht sämtliche aktuellen binären Grafikdateien und Lua-Dateien. Der ältere `main`-Branch bleibt unverändert. Für einen vollständigen Remote-Source-Checkout muss das separat gesicherte Git-Bundle explizit integriert werden.
