# WoW-Market – Tiefenrecherche WoWHead-Daten und praktikable Alternativen

**Stand 09.11.2026, 01:xx MEZ.** Technische und quellengestützte Prüfung; keine juristische Freigabe. Dieses Dokument enthält **keine fremden WoWHead-Datensätze**.

## Prüfung 1: Blizzard-Addon-Regeln

Die offizielle Addon-Richtlinie verlangt kostenloses Addon, öffentlich einsehbaren Quellcode, keine Werbung oder Spendenaufrufe im Spiel und keine spürbare Beeinträchtigung von Realm/Client. Dass eine Aktion theoretisch mit Lua geschrieben werden kann, ist keine umfassende Regel-Ausnahme.

Quelle: https://eu.forums.blizzard.com/en/wow/t/wow-user-interface-add-on-development-policy/1642

## Prüfung 2: WoWHead-Nutzung und technische Wege

1. **Links auf `https://www.wowhead.com/forever/item=<ID>` oder `npc=<ID>`**: als Querverweise nutzbar. Das Addon baut nur URLs mit validierter numerischer ID und bietet ein Feld für manuelles Kopieren. Keine Weiterleitung, kein eigener Browser und kein Seitenabruf.
2. **WoWHead-Tooltip-JavaScript**: Von WoWHead für externe **Webseiten** dokumentiert; benötigt HTML-/JavaScript-Einbindung und Internetzugriff. Das WoW-Lua-Addon unterstützt dies nicht wie ein Browser. Quelle: https://www.wowhead.com/forever/de/tooltips
3. **WoWHead-Item-XML (`item=<ID>&xml`)**: Als Einzelgegenstandsfeed öffentlich dokumentiert; keine dokumentierte Komplett-NPC-/Händler-API. Die technische Erreichbarkeit ist **keine Nutzungs-/Exportfreigabe**. Quelle: https://www.wowhead.com/forever/de/tooltips
4. **Undokumentierte Webseiten-Endpunkte, Listen-JSON oder HTML-Auswertung**: Technisch existieren einige über den Browser genutzte Datenstrukturen. Aus bloßer Erreichbarkeit folgt keine Lizenz. Nicht als automatisierter Massendownload implementiert.
5. **Offizielle Auskunft im WoWHead-Forum:** Eine Moderationsantwort zum Export von WoWHead-Daten sagt ausdrücklich: „We do not allow scraping or exporting of data from Wowhead“. Das ist der entscheidende belegte STOP für ungefragtes Kopieren. Quelle: https://www.wowhead.com/forever/forums/topic/export-of-wowhead-data-346592
6. **Kontaktaufnahme zur Freigabe:** In WoWHeads Forum und Tooltip-Hilfe wird `feedback@wowhead.com` als Anlaufstelle für Datenabfragen und Feature-Kooperationen genannt. Quellen: https://www.wowhead.com/forums/topic/data-mining-screen-scraping-106641 und https://www.wowhead.com/forever/de/tooltips
7. **Wowhead Client/Looter:** WoWHead erklärt den Aufbau seiner Daten durch ein Ingame-Addon plus separates Clientprogramm, das Nutzerbeobachtungen einsendet. Dass WoWHead selbst aggregiert, gibt Dritten keine Rechte zur Kopie seiner Datenbank. Quelle: https://www.wowhead.com/faq

**Entscheid:** Vor schriftlicher, für unser Vorhaben passender Freigabe kein WoWHead-Scraping, kein automatisierter XML-Massenimport, kein Kopieren der Händlerverkaufslisten. Zulässig und implementiert: nutzerinitiierte verlinkte Gegenstands-/NPC-IDs.

## Prüfung 3: Alternative Datenquellen

### Everloot – konkrete nutzbare Beobachtungen

Projekt: https://github.com/Everloot/everloot , Webseite: https://everloot.app

Everloot veröffentlicht Spielerbeobachtungen als CC BY-SA 4.0; deren **Code** steht separat unter AGPL-3.0. Quellenunterscheidung ist verbindlich: Eigene Spiel-/Datei-/Fremdmaterialien sind nicht automatisch durch die Datensatz-Lizenz abgedeckt. Vorhandener Offline-Konverter `DataAgent/convert_everloot_corpus.py` verarbeitet ausschließlich zuvor rechtmäßig bezogene vendor-Beobachtungen. Er prüft den abgeschlossenen Seitensatz und benötigt für gleiche NPC-/Item-/Preis-Tupel drei unterschiedliche Installationsmeldungen. Fehlen Namen oder Kartenkoordinaten, bleibt dies als unbekannt markiert. Quellennennung, Lizenz, Datenstand und Bearbeitungsvermerk werden exportiert. **Der aktuelle Installations-ZIP enthält keinen importierten Datensatz.**

### QuestieDB – sehr interessanter Daten-/Standort-Helfer

Repo: https://github.com/Questie/QuestieDB . Die öffentliche dokumentierte Lua-Schnittstelle bietet unter anderem `NpcDB.name`, `NpcDB.spawns`, `NpcDB.zoneID`, `NpcDB.subName`, `NpcDB.npcFlags`. Das Projekt unterstützt WoW Forever. In `src/meta/npcMeta.lua` ist **kein konkretes Händler-Sortiment** als NPC-Datenfeld dokumentiert; wir benötigen daher eine zweite Quelle für die Ware-NPC-Zuordnung.

**Lizenzrisiko:** `LICENSE.md` nennt historische Beitragsrechte als teilweise ungeklärt und schränkt pauschale Annahmen für ganze Datenkopien ein. Deshalb **keine QuestieDB-Daten kopieren/umverpacken**. Option für später: freiwilliges Vorhandensein von QuestieDB beim Spieler erkennen, die dokumentierte öffentliche API nur lesen, Namen/Zonen für bereits identifizierte NPCs als *unbestätigte Zusatzanzeige* ergänzen. Erst nach Kompatibilitäts-/Nutzungsprüfung, ohne Pflicht-Abhängigkeit.

Referenzen: https://github.com/Questie/QuestieDB/blob/master/docs/api.md , https://github.com/Questie/QuestieDB/blob/master/LICENSE.md

### ForeverDB – gezielte Genehmigung erforderlich

https://foreverdb.net/developers bietet eine Händler-API. API-Schlüssel, Nutzungslimits und Quellenhinweise müssen eingehalten werden. Eine Erlaubnis zum Lesen ist nicht gleichbedeutend mit einer ausdrücklichen Erlaubnis, einen vollständigen Datenbank-Auszug weltweit als frei herunterladbares Lua-Addon zu verbreiten. Vor der produktiven Distribution Rechte klären.

### Blizzard Developer-API und lokale Beobachtungen

Offizielle Developer-APIs stehen unter zusätzlichen Bedingungen zu Registrierung, Datenlebensdauer und Datennutzung. Nicht für unbeschränkte Händlerinventare unterstellen. Beim Spielbesuch per offizieller Lua-Händler-API gesammelte Informationen werden lokal gespeichert. Keine Fernabfrage aller Händler aus dem Addon.

Referenz: https://www.blizzard.com/de-de/legal/a2989b50-5f16-43b1-abec-2ae17cc09dd6/nutzungsbestimmungen-fur-die-entwickler-api-von-blizzard

## Empfohlener Weg

1. **Ohne fremde Genehmigung**: eigenes Addon kostenlos weiterentwickeln; Minimap-Button, lokaler Händlerscanner, manuelles AH und sichere Links. Rechtmäßig verfügbare Everloot-Spielerbeobachtungen offline importieren; Lizenzangaben im Addon anzeigen, CC-BY-SA-ShareAlike für bearbeitete Beobachtungsdatensätze beachten.
2. **WoWHead**: Schriftlich für *WoW Forever* um Lese- und Weiterverteilungsrechte bitten, die gewünschte Feldermenge und maximalen Abrufumfang angeben. Ohne schriftliches Ja bleibt Linkintegration bestehen.
3. **QuestieDB**: Kompatibilität, Laufzeitvertrag und Nutzungsbedingungen optional prüfen. Nicht kopieren; unbekannte Standortdaten nicht erfinden.
4. **ForeverDB**: Konkret nach einer Freigabe für frei verteilte Lua-Exportdatensätze samt Attribution und Updates fragen.
5. **Datengenauigkeit**: NPC-ID + Item-ID + Quelle + Datum + Preis-Kaufmenge + Standortbeleg getrennt sichern; Classic-Referenz nicht als in Forever bestätigt kennzeichnen.

## Nachrichtenvorlage an WoWHead (noch nicht versandt)

Betreff: Permission request – WoW Forever vendor catalogue for a free open-source addon

Hello Wowhead team,

We are developing WoW-Market, a free, non-commercial Lua UI addon for World of Warcraft: Forever. It displays vendor locations and inventory information, supports manually collected in-game observations and provides links back to the corresponding Wowhead item/NPC pages.

We would like to ask whether you offer an officially approved data feed, API or limited export for Forever vendor NPC IDs, item IDs, vendor stock and locations. In particular, would you grant permission for (a) periodic retrieval, (b) local caching/processing, and (c) redistribution of this derived dataset inside a freely downloadable addon? We would credit Wowhead prominently and comply with any reasonable attribution, rate, retention and update requirements. No paid features or in-game advertising are planned.

If redistribution is not permitted, we would be interested in a narrow lookup-only integration with explicit permission. Please let us know the appropriate terms, technical interfaces and any fees or restrictions.

Thank you.

## Abgrenzung

Kein rechtlicher „100 % Blizzard-konform“-Stempel ohne Blizzard-Bestätigung. Eine Verbindung über die Spiel-UI und eine Datenlizenz eines Drittanbieters sind **zwei getrennte Prüfbereiche**. Keine Web-Scraping-Umgehung, keine Bildschirm-/Speicher-/Netzwerkauslesung aus dem WoW-Client und keine versteckten Datenexporte.
