# Datenquellen und rechtliche Grenzen – WoW-Market

## Im unveraenderten Addon-Paket enthalten

- **Eigener Lua-Code und leere Referenzhaendlerdatenbank.** Keine von Everloot, Wowhead, ForeverDB oder QuestieDB uebernommenen Datensaetze.
- **Eigene lokale Beobachtungen** nach manuell geoeffneten NPC-Haendlerfenstern. Diese bleiben beim Spieler in den SavedVariables, werden nicht an uns uebertragen.
- **Wowhead:** Nur ID-basierte URLs zum Nachschlagen (`https://www.wowhead.com/forever/item=...`, `npc=...`). Kein Datenscraping und kein verdeckter Webclient.

## Erlaubter, optionaler und noch nicht ausgefuehrter Import

- **Everloot, oeffentliche Spielerbeobachtungen:** CC BY-SA 4.0. 
  **Verpflichtende Nennung, falls Datenauszug eingebunden:** `Data from Everloot (https://everloot.app), CC BY-SA 4.0.` 
  Lizenz: https://creativecommons.org/licenses/by-sa/4.0/ . Aenderungen (Filterung, Aggregation, Ergaenzung) kenntlich machen; abgeleitete Daten unter kompatibler ShareAlike-Lizenz bereitstellen. Siehe https://everloot.app/docs/licence .
- **Nicht von dieser Erlaubnis umfasst:** Everloot-Programmcode (AGPL-3.0), Blizzards Spieldateien, Kunst und Tooltip-Texte. Der Python-Importer ist von uns geschrieben, kopiert keinen Everloot-Code.
- **QuestieDB:** Nur spaetere optionale, lesende Nutzung der dokumentierten Lua-Schnittstelle. Keine QuestieDB-Daten ins Repository kopiert. QuestieDB hat selbst eine ungeklaerte historische Datenlizenz und ist nicht unsere primaere Quelle.
- **ForeverDB:** Noch keine Daten oder API-Schluessel; API-Zugangs- und Redistributierbedingungen vorher ausdruecklich abklaeren.
- **Wowhead:** Anfrage nach ausdruecklich genehmigtem Forever-Datenzugang geplant; bis dahin nur Nachschlagelinks.

## Verantwortung bei Veroeffentlichung

Eine sichtbare Quellenzeile allein erteilt keine Rechte zur Uebernahme von fremden Datenbanken. Herkunft und Lizenz muessen je *tatsaechlich* verwendeter Quelle dokumentiert werden. Der eigene Lua- und Python-Code sowie die Tests stehen unter GPL-3.0-only (vollstaendiger Text in `LICENSE` und `WoWMarket/LICENSE.txt`). Fremdinhalte sind ausgenommen.

## Trennung von Code- und Datenlizenz

Der eigene WoW-Market-Code ist seit 09.11.2026 oeffentlich einsehbar und wird unter **GPL-3.0-only** lizenziert. Die Codelizenz gilt **nicht** fuer Spielerbeobachtungen von Everloot (CC BY-SA 4.0), fuer Marken oder fuer Blizzard-Spieldaten. Noch sind keine Everloot-Beobachtungen im Repository enthalten. Jede zukuenftige Datenauslieferung braucht Lizenz- und Herkunftsnachweise inklusive Bearbeitungskennzeichnung.
