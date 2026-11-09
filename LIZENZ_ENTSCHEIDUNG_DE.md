# Lizenzentscheidung fuer den eigenen WoW-Market-Code

**Status: Eigentuemerauswahl offen; noch KEINE Lizenzdatei aktiviert.** Das Repository ist zwar oeffentlich lesbar, aber Sichtbarkeit alleine erlaubt Dritten keine freie Weiterverbreitung oder Veraenderung.

## Zwei praktikable Optionen

| Option | Bedeutung | Beachten |
| --- | --- | --- |
| **MIT** | Einfach; Nutzung, Veraenderung und Verteilung unter Erhalt des Urheber-/Lizenzhinweises | Erlaubt auch kommerzielle Weiterverwendung und geschlossene Ableitungen. Keine dauerhafte Pflicht, eigenen Fork-Quellcode zu veroeffentlichen |
| **GPL-3.0-only** | Copyleft bei Verteilung abgeleiteter Programme; Lizenz- und Source-Anforderungen | Ebenfalls kommerzielle Nutzung erlaubt; weitergehende Pflichten fuer Weitergabe und Lizenzkompatibilitaet |

Eine dritte Moeglichkeit ist, den selbst entwickelten Code sichtbar, aber **ohne Open-Source-Lizenz** bereitzustellen. Blizzards Richtlinie verlangt Sichtbarkeit und Kostenfreiheit, nicht MIT/GPL. Fuer Community-Beitraege, Forks und CurseForge ist eine klar geregelte Lizenz zweckmaessiger.

## Nicht Teil der eigenen Code-Lizenz

- **Everloot-Beobachtungsdaten:** Falls aufgenommen, eigene Herkunftsnachweise, CC BY-SA 4.0, Bearbeitungsvermerk und ShareAlike-Bedingungen. Derzeit KEINE eingebunden.
- **Everloot-Programmcode:** AGPL-3.0; hier keine Kopie enthalten.
- **QuestieDB:** Optionale Laufzeit-API, keine eingebetteten Daten.
- **WoWHead:** Derzeit nur kopierbare Links, keine Datenrechte fuer Vollimport.
- **World of Warcraft, Namen, Grafiken, UI-Kunst:** Rechte der jeweiligen Eigentuemer.

## Naechster Schritt nach Entscheidung

1. Gewaehlten offiziellen, vollstaendigen Lizenztext als `LICENSE` in den Repo-Stamm aufnehmen, samt Jahr 2026 und korrekt benanntem Rechteinhaber.
2. In `README.md`, Addon-`.toc`, Quellenreiter und CurseForge-Metadaten die Lizenz korrekt benennen, ohne fremde Daten darunter zu deklarieren.
3. Lizenzhinweise sowie eventuelle Rechte an von Dritten beigetragenem Code vor dem ersten CurseForge-Release ueberpruefen.

Die Lizenzwahl kann fuer bereits veroeffentlichte Kopien faktisch dauerhaft wirken. Deshalb keine automatische Aktivierung ohne ausdrueckliche Eigentuemerauswahl.

## Primärquellen

- Blizzard UI Add-On Development Policy: https://eu.forums.blizzard.com/en/wow/t/wow-user-interface-add-on-development-policy/1642
- MIT: https://choosealicense.com/licenses/mit/
- GPL-3.0: https://choosealicense.com/licenses/gpl-3.0/
- Everloot: https://everloot.app/terms
