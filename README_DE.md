# WoW-Market – WoW Forever

**Alpha 0.0.8 (lokale Testfassung, 09.11.2026)** · Ziel: World of Warcraft Forever 1.60.1 / Interface 16001.  
**WICHTIG: Nicht im echten Forever-Client getestet; noch keine oeffentliche Release-Freigabe.**

## Bedienung

1. Den Verzeichnisordner `WoWMarket` in den *aktiven* Spielclient-Ordner `Interface/AddOns/` kopieren (z. B. `World of Warcraft/_forever_/Interface/AddOns/`; bei Beta ggf. anderer Clientordner). Vor dem Austausch eigene SavedVariables sichern.
**WICHTIG BEIM UPGRADE:** Den alten Addon-Ordner `Interface/AddOns/CrobITMarket/` nach Sicherung **entfernen** (nur den Addon-Ordner, nicht `WTF/` oder SavedVariables). Sonst laufen zwei Addons gleichzeitig und greifen auf dieselben Daten zu. Bestehende `CrobITMarketDB`-SavedVariables vorher sichern; der interne Name bleibt bewusst erhalten.
2. Spiel neu starten, Addon in der Charakterauswahl aktivieren.
3. Auf der Minimap das **Goldmuenzen-Symbol** anklicken (links: Fenster zeigen/verbergen; rechts: Quellen & Recht; mit linker Maustaste ziehen: Position speichern). Keine Chateingabe erforderlich. Die bisherigen Slash-Aliasse bleiben als Notfalloption vorhanden.
4. Ein Haendlerbesuch speichert dessen lesbare Waren und Standortinformationen lokal. Das Addon kauft und verkauft nichts.
5. Reiter **Haendler** zeigt bekannte NPCs; **Karte** zeigt Haendlerliste und bei einem ausgewaehlten NPC einen Button zum Oeffnen der Zone sowie optional *Wegpunkt setzen* (nur nach Klick, nur bei vorhandenen Kartenkoordinaten und unterstuetzter Spiel-API). Kein Routenbot.
6. Reiter **Auktionshaus** zeigt eine lokale Momentaufnahme. Mit offenem Auktionshaus kann der Nutzer bewusst auf **AH-Scan manuell starten** klicken. Die Abfrage ist serverseitig gedrosselt; lokal ist sie maximal einmal in 15 Minuten moeglich. 30.000 Auktionen sind die Verarbeitungsobergrenze. Keine stillen Wiederholungen, keine Gebote oder Kauefe. Aus dem AH abgeleitete Preise sind nicht live und koennen veralten. Eine alte Momentaufnahme wird bei Abbruch nicht ersetzt.
7. In der Gegenstandsdetailansicht wird ein verfuegbarer AH-Mindestpreis je Stueck angezeigt (nur wenn aktuell derselbe Realm/Faktionskontext erkannt wird). Achtung: Keine Gewinnzusage, keine AH-Gebuehren einberechnet, weder Angebote noch Verfuegbarkeit garantiert.
8. Reiter **Quellen & Recht** nennt den tatsaechlichen Datenprovider bzw. zeigt, dass noch keiner importiert wurde. WoWHead-Schaltflaechen geben nur die passende Website-Adresse zum Kopieren (Strg+C) aus.

## Was diese Alpha bewusst NICHT enthaelt

- Keine importierte Komplettdatenbank: `Data/Vendors.lua` ist leer, bis Nutzungs- und Weitergaberechte fuer eine echte Datenquelle feststehen.
- Keine bildlichen Marker fuer *alle* NPCs auf der Weltkarte: stattdessen kann die jeweilige Zone geoeffnet und bei Eignung ein Standard-Wegpunkt gesetzt werden.
- Keine automatischen Webabrufe oder API-Key-Dateien innerhalb des Addons.
- Kein durchgehender Client-Test und kein Nachweis von Leistung bei echtem Vollimport.
- Keine echte Browserintegration, kein eigener Installationsdienst, keine Hintergrundagenten.

## Offliner Datenimport (nur Entwicklungspaket)

Der lokale Python-Importer validiert ein **normalisiertes, von uns definiertes JSON-Schema** und erstellt deterministisches Lua; er ruft KEINE Webseite ab. Das beiliegende Beispiel ist rein synthetisch.

```powershell
python DataAgent\import_vendors.py --input zugelassene_daten.json --output WoWMarket\Data\Vendors.lua
```

ForeverDB beschreibt eine Read-only-Haendler-API unter https://foreverdb.net/developers . Zum Zugriff ist eine genehmigte Kennung noetig. Der Anbieter verlangt Sichtbarkeit von `https://foreverdb.net` und definiert Abruflimits. **Ob die vollstaendige Weiterverbreitung der Daten im oeffentlichen Addon-ZIP zulaessig ist, muss vor dem Import ausdruecklich geklaert werden.** Der Inspector kann mit einem rechtmaessigen Schluessel einen einzelnen Datensatz zur strukturellen Pruefung abrufen; kein Massendownload.

## Tests / Grenzen

`python -m unittest discover -s Tests -v` testet Import, Validierung und Releasevertrag synthetisch.  
`python Tests/run_lua_syntax_and_behavior.py` benoetigt eine bereits installierte liblua5.4 und prueft Lua-Syntax sowie isolierte Verhaltenstests.

**Tests im echten Spiel bleiben PFLICHT**: Laden/Slash/Optik, Haendlername/GUID, Kartenfunktion und Wegpunkte, AH-Ereignisse, 15-Minuten-Sperre, Performance, Konflikte mit anderen Addons, SavedVariables/Upgrade, deutsche und englische Client-Versionen. Sichere bestehende SavedVariables vor der Installation.

Siehe `VEROEFFENTLICHUNG_DE.md` und `ABNAHME_CHECKLISTE_DE.md`. Die Addon-ZIP-Datei enthaelt nur die Installationsdateien; das Entwicklungspaket enthaelt auch Tests, Importer und Dokumentation.

## Neu seit 0.0.5: Minimap-Button

- Runder **Goldmuenzen-Button** an der Minimap. **Linksklick** oeffnet oder schliesst WoW-Market. **Rechtsklick** zeigt Quellen & Recht an. **Ziehen mit linker Maustaste** verschiebt das Symbol um die Minimap; die Position wird in den bisherigen SavedVariables gespeichert.
- Keine Chateingabe noetig. Alte Befehle existieren nur als optionale Rueckfallebene.
- Die Standard-Minimap muss von der Spiel-UI bereitgestellt werden. Bei anderen Minimap-Mods und beim ersten Start im echten Forever-Client ist ein Funktions- und Layouttest erforderlich.
- Details zur WoWHead-Erlaubnis, Alternativquellen und einer Kontaktvorlage siehe `WOWHEAD_RECHERCHE_DE.md` (nur im Entwicklungspaket).

## Alpha 0.0.8: optionale QuestieDB-API, Quellenarchitektur und Datenqualitaet

- Korrigierte Verarbeitung oeffentlicher `pub-`-Pseudonyme: fehlende Identitaetsmerkmale zaehlen nicht als Beleg, blockieren aber keine bereits anderweitig bestaetigten Daten.
- Mischungen verschiedener Corpus-Snapshots werden abgelehnt.
- Benutzerinitiierter, auf maximal 25 Seiten pro Lauf begrenzter Everloot-Downloader ohne Schluessel, Hintergrunddienst oder weitere Python-Bibliotheken (nicht Teil des WoW-Installations-ZIPs).
- Die genauen Schritte stehen in `EVERLOOT_IMPORT_DE.md` und `GITHUB_START_DE.md`.
- Keine realen Everloot-Daten heruntergeladen, keine Live-Client-Abnahme. Minimap-Button ist bereits enthalten und im Lua-Test simuliert; ein echter Ingame-Test benoetigt den laufenden Forever-Client.

## Neue Funktion in 0.0.8

QuestieDB ist **optional** (`## OptionalDeps: QuestieDB`); WoW-Market funktioniert ohne QuestieDB. Wenn die dokumentierte `LibQuestieDB`-API vorhanden ist, werden lediglich bei sonst unbekannten NPC-/Item-Namen lesende Zusatzinformationen abgerufen. Moegliche Spawn-Hinweise bleiben als **unbestaetigt** markiert; QuestieDB-Zonen-IDs werden nicht in WoW-Karten-IDs umgewandelt und niemals automatisch als Wegpunkt verwendet. Namen werden nur zur Anzeige eingesetzt und nicht in den Referenzbestand kopiert.

Der Everloot-Importer kann mit `--report <Pfad>` eine **aggregierte** Qualitaetsstatistik ohne Reporterkennungen erzeugen. WoWHead bleibt bei ID-Links: Sein Import ist bis zur schriftlichen Freigabe in der Normalisierung gesperrt. Die Quellenarchitektur steht in `QUELLEN_ARCHITEKTUR_DE.md`.
