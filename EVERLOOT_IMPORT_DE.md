# Everloot-Haendlerdaten – genauer, nachvollziehbarer Weg

## Primärquelle und Rechte

Offizielle Dokumentation: https://everloot.app/docs/api/corpus-public und https://everloot.app/docs/licence .

`GET https://everloot.app/api/corpus/public?kinds=vendor&limit=500&offset=0`

- **Ohne Konto und ohne API-Schluessel** lesbar. Freikontingent: maximal 30 Abfragen je Stunde fuer die betroffene Endpoint-Gruppe (auch durch andere dortige API-Operationen verbrauchbar); 500 Datensaetze je Seite.
- Die oeffentliche API liefert Beobachtungen, nicht automatisch ein gesamtes NPC-Warenlexikon. Fehlende Beobachtungen sind **unbekannt**, niemals das Gegenbeispiel "haendler verkauft nichts".
- `vendor`-Record: `vendorNpcId`; `items[]` mit `itemId`, `priceCopper`, optional `limitedStock`, plus `capturedAt` und (falls verfuegbar) oeffentliches `pub-`-Pseudonym fuer unabhaengige Meldungen.
- **Nicht enthalten** sind verlaessliche Haendlernamen, Kartenkoordinaten und Produktnamen. Diese muessen aus separat zulaessigen Quellen/ eigenen Beobachtungen ergaenzt werden. `npc_sighting` kann spaeter *unter derselben drei-Beleg-Regel* fuer Standortbeobachtungen ausgewertet werden.

## 1. Datensaetze auf deinem eigenen PC manuell anfordern

Ab dem Repository-Stammordner in PowerShell:

```powershell
python DataAgent\fetch_everloot.py --output-dir DataAgent\raw --max-pages 20
```

Der Downloader fragt nur die dokumentierte `everloot.app`-HTTPS-API ab, ohne Schluessel. Er hat ein hartes Requestlimit, laedt pro Seite maximal 12 MiB, prueft Host und Seitenreihenfolge und beendet sich bei 429, wechselnden Snapshots, Weiterleitungen oder unvollstaendiger Paginierung. **Er holt keine Daten aus dem WoW-Prozess und startet nur auf deinen Befehl.** Er laedt nicht automatisch weiter. Werden mehr Seiten benoetigt, STOP und API-Kontingent/Datensnapshot pruefen; keinen unvollstaendigen Datensatz publizieren. Ein Key ist optional und nicht erforderlich, solange der Datensatz ins Freikontingent passt.

## 2. Lokal filtern und pruefen (kein weiterer Webzugriff)

```powershell
python DataAgent\convert_everloot_corpus.py --input DataAgent\raw\vendor_page_*.json --output WoWMarket\Data\Vendors.lua
```

**Hinweis:** PowerShell uebergibt Wildcards an Python nicht auf allen Versionen als vollstaendige Dateiliste. Robust ist deshalb:

```powershell
$pages = @(Get-ChildItem -Path 'DataAgent\raw' -Filter 'vendor_page_*.json' | Sort-Object Name | ForEach-Object FullName)
if ($pages.Count -eq 0) { throw 'Keine Corpus-Seiten vorhanden.' }
python DataAgent\convert_everloot_corpus.py --input $pages --output WoWMarket\Data\Vendors.lua --report DataAgent\out\everloot_quality_report.json
```

Der Converter akzeptiert nur **vollstaendige und konsistente** Seiten und nur **identische Preise fuer denselben Gegenstand bei demselben NPC aus mindestens drei unterschiedlichen oeffentlichen Installationspseudonymen**. Datensaetze ohne Pseudonym zaehlen nicht; widerspruechliche bestaetigte Preise bleiben aus dem Export. `limitedStock` und Kaufmengen werden nicht frei erfunden; fehlen Daten, bleiben sie unbekannt. Es handelt sich um **beobachtete** Preise – Rufrabatte und Kaufumstaende koennen sie beeinflussen.

Beim Import werden nur die ausreichend belegten NPC-Waren-Paare als "in Forever beobachtet" gekennzeichnet. Fehlen Namen oder Positionen, zeigt WoW-Market ausdrücklich Platzhalter an. Unsere eigene lokale Haendlererfassung bleibt separat erhalten. Fuer vollstaendige Standortinformationen ist eine **getrennte** zulaessige Quelle oder eine eigene Beobachtung erforderlich.

## 3. Vor oeffentlicher Datenverteilung

- Gespeicherte `DataAgent/raw/`-Dateien und Pseudonyme nie ins GitHub-Repo stellen; `.gitignore` ist vorbereitet.
- Aus den verwendeten Endpunkten Source, Abrufdatum, Lizenz, `dataAsOf`, Modifikationen und Umfang nachvollziehbar dokumentieren.
- `Data from Everloot (https://everloot.app), CC BY-SA 4.0.` sichtbar im Addon und bei den betroffenen Datendateien; abgeleiteten Datenauszug unter CC BY-SA 4.0 weitergeben. Quelle und Lizenz: https://everloot.app/docs/licence
- **Weder im 0.0.7-Addon noch im Repository-Erstpaket** liegen reale Everloot-Daten vor. Das ist erst die validierte Importpipeline.

## 4. Reale Qualitaets- und Vollstaendigkeitsmessung

Nach einem echten Corpus-Abruf dokumentieren: Gesamtzahl Records, solche mit gueltigen Pseudonymen, Zahl bestaetigter NPC-/Item-/Preispaare (3+), Konflikte, Zahl unterschiedlicher Haendler, fehlende Namen und fehlende Koordinaten. Vor einem echten Datendurchgang gibt es **keine serioese Vollstaendigkeitsquote**.

### Qualitaetsbericht (Alpha 0.0.8)

Mit `--report DataAgent\out\everloot_quality_report.json` erzeugt der Offline-Importer eine ueberpruefbare Statistik ueber Beobachtungen, gueltige/fehlende oeffentliche Pseudonyme, Preis-Konflikte, publizierte NPC-/Item-Paare und fehlende Namen bzw. Kartenpositionen. Diese JSON-Datei enthaelt keine Reporterkennungen und wird nicht im Addon verwendet. **Die Ergebnisse sind erst nach echtem API-Abruf aussagekraeftig.** `DataAgent/out/` steht in `.gitignore`.
