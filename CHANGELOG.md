# Changelog

## 0.0.8-alpha – 09.11.2026
- Optionale, nur lesende QuestieDB-Lua-Anbindung zur Namenssuche und vorsichtigen Spawn-Hinweisen; keine Datenkopie oder ungeprueften Kartenmarker.
- Suchtreffer und Detailansicht kennzeichnen aus QuestieDB ergaenzte Namen und nicht bestaetigte Standorthinweise.
- Sicherer WoWHead-Provider-Gate: unautorisierter WoWHead-Datenimport am gemeinsamen Normalisierer gesperrt.
- Everloot-Konverter bietet einen aggregierten, pseudonymfreien Qualitaetsbericht (`--report`); weiterhin keine echten Fremddaten im Addon.
- Bestehendes Repository `CrobIT-Solution/WoW-Market` erkannt; Quellenarchitektur, README und Einfuehrungsdokumentation auf aktuellen Stand gebracht.
- Lokale synthetische Tests erweitern QuestieDB-Verhalten, Import-Sperren und Source-Provenienz.
- Ingame-Forever-Test, echte Datenaufnahme, Code-Lizenz und CurseForge-Release bleiben offen.

## 0.0.7-alpha – 09.11.2026
- Everloot-Importer: oeffentliche `pub-`-Pseudonyme statt interner Installations-IDs; fehlende Pseudonyme zaehlen nie als unabhaengiger Beleg.
- Gemischte `dataAsOf`-Snapshots werden zurueckgewiesen, kein stiller Teilimport.
- Manueller, kontingentbegrenzter Everloot-Corpus-Downloader als separates Python-Werkzeug; nie im WoW-Addon.
- Reproduzierbare Repo-Erstbefuellung und Datenquellen-/Lizenzhinweise vorbereitet.
- Minimap-Funktion unveraendert, erneut synthetisch getestet; echter Forever-Client-Test weiterhin offen.


## 0.0.6-alpha – 09.11.2026
- Eigenstaendiger, beweglicher Minimap-Button ohne zusaetzliche Addon-Bibliotheken.
- Linksklick schaltet Hauptfenster um, Rechtsklick oeffnet Quellen & Rechtliches, Ziehen speichert die Minimap-Position.
- Kein Chatbefehl mehr noetig; bisherige Aliasse bleiben fuer Kompatibilitaet.
- WoWHead-Quellen-/Lizenzrecherche inklusive expliziter Anbieter-Aussage zum untersagten Datenexport dokumentiert.
- Everloot-Offlinedatenimport aus Alpha 0.0.5 bleibt erhalten; keine fremden Daten im Release-ZIP.

## 0.0.5-alpha – 09.11.2026
- Umbenennung in WoW-Market mit unveraenderter SavedVariables-Identitaet.
- Everloot-Spielerbeobachtungen offline konvertierbar; nur mehrfach belegte Datensaetze.

## 0.0.4-alpha – 09.11.2026
- Read-only AH-Momentaufnahme auf **ausdruecklichen Klick**, lokale Drossel, Batching und Abbruchgrenze.
- Weltkarten-Zonenanzeige und manuelles Setzen eines Benutzer-Wegpunkts bei vorhandenen Standortdaten.
- Suche durch begrenzte Top-Ergebnisliste und Totalzähler speicherschonender.
- Auktionshaus-Reiter; klare Hinweise zu Momentaufnahmen und Publikationsgates.
- Kein Webbrowser; externe Vollhaendlerdatenbank bleibt leer.

## 0.0.3-alpha – 09.11.2026
- Quellen- und Rechtshinweisreiter, kopierbare WoWHead-Gegenstands- und NPC-Adressen.

## 0.0.2-alpha – 09.11.2026
- Erste Oberflaeche, lokale Haendlerbeobachtungen, deterministischer Offline-Importer.
