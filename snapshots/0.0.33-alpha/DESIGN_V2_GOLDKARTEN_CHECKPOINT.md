# WoW-Market – Alpha 0.0.33, Design V2/F (Goldkarten)

**13. November 2026 · Maintainer: Blackiron · Status: Entwickler-Testversion.**

## Verbindliches Designziel
Maßgeblich bleibt das zweite vom Nutzer bereitgestellte Referenzbild `WoW-Market_ Händlerübersicht in Azeroth(2).png`, SHA-256 `27f507eef2bad9f101ca1c5abec63e9b76f3c453e3e60962a178e90278bd557c`.
Das unveränderte Original ist im vollständigen lokalen Git-Quellstand unter `design/reference/WoW-Market_SOLL_Design_V2.png` versioniert. Alle Beispielhändler und Beispielpreise aus dem Bild sind *nur* Designvorlage; keine erfundenen Spielwerte.

## Umgesetzt
- Neun neue, rein dekorative TGA-Grafiken für geprägte Gold-/Steinkarten (Ergebnisliste, zweispaltige Händlerwaren, Itemkarte, Händlerkopf, Iconrahmen, Footer und Separatoren).
- Ergebnisstatus optisch differenziert: tatsächlich gesperrter Zugang rot; unbekannt gold; tatsächlich beobachtet oder aktiv ausgewählt grün.
- Item-ID in der Itemkarte deutlicher; Preisfeld-Kanten und untere Informationsreiter neu gestaltet.
- Footer in Status / Datenquelle / Version gegliedert, weiterhin ohne erfundene Aktualisierungszeitpunkte.
- Vorherige Art-Dateien, Item-Link-Handling, NetProbe, echte lokale Daten, SavedVariables unverändert.

## Installations-ZIP
**`WoW-Market_0.0.33-alpha_Design-V2-Goldkarten.zip`**
- SHA-256 `53487adb82f9aad0532506157244cdecab0dda4cd354126608236fbc0c33b147`
- **2.357.983 Bytes**, 62 Paketdateien, 16 Lua-Dateien, 41 TGA-Dateien.
- Keine `tests/`-, README-, Installations- oder Test-TXT. Vier notwendige Quellen-/Lizenz-/Urheber-TXT verbleiben: `LICENSE.txt`, `EVERLOOT_DATENLIZENZ.txt`, `QUELLEN.txt`, `ART_HERKUNFT.txt`.

## Tatsächlich geprüfte Gates
- Syntax `texlua loadfile` für 16 Module: PASS.
- UI-Initialisierung, vier rechte Reiter, Shift-Klick->Item->Händleransicht, die neun V2/F-Texturen und Statuskarten-Farben: PASS.
- Alpha-0.0.32-Fenstersteuerung und Navigation: PASS.
- Rechte Waren-Pagination bei niedriger Höhe: PASS.
- Itemlink/Chat-Priorität und synthetische Zwei-Client-PING/ACK-Regressionen: PASS.
- 32 frühere Grafikdateien anhand vorliegender SHA-Hashes unverändert; Daten, NetProbe, ItemLink und Lizenztexte bytegleich zu 0.0.32: PASS.
- Alle neun neuen TGA-Texturen: RGBA, Power-of-two-Abmessungen: PASS.
- ZIP CRC/TOC/Legal-only-TXT, reproduzierbarer zweiter ZIP-Build mit identischem SHA-256: PASS.
- **Noch keine visuelle Ingame-Abnahme von Alpha 0.0.33.** Keine Behauptung pixelgenauer Übereinstimmung mit dem Referenzbild.

## Vollständige lokale Git-Sicherung
- Quell-Commit: `782401943fa9449b9bc86c493e795ce8fd50e15a`, Author `Blackiron`.
- Branch: `feature/wow-market-0.0.33-alpha-design-v2-art-polish`; Tag: `alpha-0.0.33-design-v2-goldkarten-test`.
- Bundle: `WoW-Market_0.0.33-alpha_Design-V2_Vollbackup.git.bundle`, SHA-256 `490f47e8c096babebcbef88025f5251b60a2ffc440f9d26e6557893d2ac64b03`.
- `git bundle verify`: PASS; vollständige Historie; frischer Bundle-Checkout auf exakt obigen Commit geprüft.
- Die vollständigen ZIP-/Bundle-Dateien liegen in der ChatGPT Library unter `/WoW-Forever/WoW-Market/`.

**GitHub-Einschränkung:** Dieser *GitHub-Archivbranch* enthält nur Design-/Versionsdokumentation, **nicht** die vollständige neue 0.0.33-Quelle oder Grafikbytes. Die gesamte versionierte Quelle einschließlich Original-Referenz befindet sich im verifizierten lokalen Git-Bundle. Das alte `main` bleibt unverändert. Keine CI, Merges, Releases oder kostenpflichtigen Aktionen.

## Nächster Test
Bei geschlossenem WoW den bisherigen `Interface/AddOns/WoWMarket`-Ordner sichern und vollständig durch den Ordner aus der ZIP ersetzen. `WTF/SavedVariables` nicht löschen. Im Spiel die leere Marktübersicht und anschließend ein bekanntes Item mit Händlerwaren (z. B. `Angel` bei Flakk) öffnen. Goldrahmen, Statusfarben, Preisvergleich, Footer und Seitennavigation anhand eines echten Ingame-Screenshots mit dem Masterbild vergleichen.