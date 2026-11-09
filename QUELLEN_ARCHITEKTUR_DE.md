# Datenquellen-Architektur – WoW-Market Alpha 0.0.8

## Verbindliche Unterscheidung

WoW-Market hat vier **getrennte** Datenwege. Keiner kann ohne ausdrueckliche Quellenpruefung stillschweigend in einen anderen umgewandelt werden.

| Datenweg | Ursprung | Einsatz | Rechte/Verifikation |
| --- | --- | --- | --- |
| Eigene Beobachtungen | Spieler oeffnet einen Haendler im WoW-Client | Lokale SavedVariables, hat in der Anzeige Vorrang | Nur beobachtete Waren, kein Fernzugriff |
| Everloot (primaer fuer belegte Waren) | Oeffentlicher `vendor`-Spielerbeobachtungs-Corpus | Manueller HTTPS-Download ausserhalb des Spiels, Offline-Konvertierung nach drei unabhaengigen identischen Preisbelegen | CC BY-SA 4.0, Quellennennung, Datenstand und Bearbeitungsvermerk; Blizzard-Spielinhalte sind getrennt |
| QuestieDB (optional) | Dokumentierte, bereits installierte `LibQuestieDB`-Lua-API | Nur Namens- und moegliche Spawn-Hinweise fuer nicht aufgeloeste NPCs/Items | Keine Daten kopiert. Standort-Hinweise sind *keine* bestaetigten `C_Map`-Punkte |
| WoWHead (vorbereitet) | Offizielle Item-/NPC-Webseiten | Kopierbare Links mit validierter ID | Kein Abfragedienst, kein Vollimport ohne ausdrueckliche Zustimmung |

## Datenmodell fuer jeden zukuenftigen freigegebenen Import

`DataAgent/import_vendors.py` ist die gemeinsame, offline arbeitende Endstufe mit Schema `1`. Ein autorisierter Quellenadapter muss mindestens liefern:

```json
{
  "schema": 1,
  "provider": "Name des erlaubten Datenanbieters",
  "attributionUrl": "https://example.org",
  "credit": "Anbieter, Lizenz-/Quellennachweis, Bearbeitung",
  "license": "Lizenz oder expliziter Nutzungsrahmen",
  "licenseUrl": "https://example.org/licence",
  "dataAsOf": "2026-11-09",
  "vendors": [
    {
      "id": 123,
      "name": "Belegter Name oder ausdruecklicher Platzhalter",
      "zone": "Belegte Zone oder unbekannt",
      "mapID": null,
      "x": null,
      "y": null,
      "seenInForever": null,
      "items": [
        { "id": 456, "name": "Belegter Name oder Platzhalter",
          "priceCopper": 1234, "stackCount": null,
          "numAvailable": null, "hasExtendedCost": null }
      ]
    }
  ]
}
```

Dies ist ein **Formatbeispiel mit erfundenen IDs**, keine importierte Datenbank. Die Pipeline validiert IDs, Preisdaten, Koordinaten, WoW-Textformatierung, Attributions-URLs und die Lizenzhinweise und schreibt erst dann `WoWMarket/Data/Vendors.lua` atomar.

**Wichtig bei WoWHead:** Der Endimport weist aktuell alle Anbieternamen mit `WoWHead` zurueck. Nach erteilter Erlaubnis braucht es einen gezielten Adapter fuer die tatsaechlich genehmigte Schnittstelle sowie eine gepruefte, begrenzte Freischaltung. Eine heute erfundene Endpunkt- oder Lizenzkonfiguration waere unzuverlaessig. Erst schriftlich klaeren: (1) erlaubte Forever-Felder, (2) Requestlimits, (3) lokale Zwischenspeicherung, (4) regelmaessige Aktualisierung, (5) Weiterverteilung im kostenlosen Addon, (6) Quellenangaben, (7) Ablauf/Widerruf. Bis dahin ist WoWHead **nur Referenzlink**.

## Everloot – Vollstaendigkeit und Qualitaetsbericht

**Nicht** jeder oeffentlich lesbare Record bestaetigt eine Warenposition. Der Offline-Konverter akzeptiert nur drei **verschiedene, oeffentliche Installationspseudonyme** mit identischer NPC-/Item-ID und identischem Preis. Fehlende Pseudonyme und Preis-Konflikte fuehren **nicht** zu einer Bestaetigung. Ortsangaben werden nie erfunden. Auf Wunsch schreibt `--report` eine JSON-Statistik mit Recordzahlen, unbekannten Namen/Positionen und Preis-Konflikten – **ohne Reporterkennungen**.

Ohne einen tatsaechlichen Download laesst sich weder die Groesse des verfuegbaren Corpus noch die reale Haendlerabdeckung angeben. Die lokal ausgelieferte `Vendors.lua` bleibt deshalb leer, bis ein konsistenter Lizenz-/Daten-/Qualitaetsnachweis vorliegt.

## Quellennachweise

- Everloot: https://everloot.app/docs/api und https://everloot.app/terms
- Everloot Datenlizenz: https://everloot.app/docs/licence
- QuestieDB API: https://github.com/Questie/QuestieDB/blob/master/docs/api.md
- QuestieDB Lizenzvorbehalt: https://github.com/Questie/QuestieDB/blob/master/LICENSE.md
- WoWHead: https://www.wowhead.com/forever/
- WoWHead Ansprechpartner: feedback@wowhead.com
