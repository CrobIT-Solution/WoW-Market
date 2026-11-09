# WoW-Market – Veroeffentlichung und Blizzard-Konformitaet

Stand 09.11.2026 · Entwicklungsstand Alpha 0.0.8, **KEINE Rechts-/Blizzard-Abnahme**.

## Primaerquellen

- Blizzard UI Add-On Development Policy (Blizzard-Mitarbeiter Kaivax): https://us.forums.blizzard.com/en/wow/t/ui-add-on-development-policy/24534/1
- Blizzard EULA: https://www.blizzard.com/de-de/legal/
- CurseForge – Projekt erstellen / moderieren: https://support.curseforge.com/support/solutions/articles/9000197241-creating-and-submitting-a-project
- ForeverDB API/Quellenpflicht: https://foreverdb.net/developers
- Wowhead-Link-Prinzip: https://www.curseforge.com/wow/addons/forever-wowhead-search

## Was Blizzard tatsaechlich verlangt

1. **Kostenlos**, keine Premium-/Bezahlfunktionen, keine kostenpflichtigen Dienste als Voraussetzung fuer den Addon-Zugang.
2. **Quellcode komplett oeffentlich sichtbar, unverhuellt**. Ein GitHub-Repository ist NICHT vorgeschrieben. Es ist aber fuer Source- und Versionsnachweise empfehlenswert. Auch ein oeffentlich frei herunterladbares Addon-ZIP mit vollstaendig sichtbarem Quellcode erfuellt grundsaetzlich das Sichtbarkeitsziel. Keine obfuskierten oder kompilierten Lua-Dateien.
3. **Keine Werbung und Spendenaufrufe im Spiel**. Sachliche Quellenattribution ist zulassig; keine Anbieterwerbung oder Affiliate-Links.
4. **Keine Performance-/Serverbelastung**, Bots, geschuetzte Aktionen oder Eingriffe ausserhalb der Addon-UI. AH-Scan nur manuell, throttled, mit Sicherheitslimit. Kein automatisierter Kaufen/Verkaufen-Workflow.
5. **Keine rechtswidrigen/beleidigenden Inhalte**; EULA/Terms beachten.
6. Blizzard kann Funktionen nach eigenem Ermessen sperren. Eine CurseForge-Zulassung ist KEINE ausdrueckliche Blizzard-Genehmigung.

## Externe Daten und Rechte

**Hinweis:** Der Betreiber von WoWHead untersagt in einer ausdruecklichen Forenantwort Scraping/Export der Daten. Einzelgegenstands-XML und Webseiten-Tooltips sind keine Generallizenz. Siehe `WOWHEAD_RECHERCHE_DE.md` und https://www.wowhead.com/forever/forums/topic/export-of-wowhead-data-346592 .


- Dieses Paket enthaelt keine echten Referenzhaendler. Die Datenquelle `ForeverDB.net` verlangt API-Key-Zugang, sichtbaren Link und 60 Anfragen/Minute sowie 10.000/Tag. Diese Bedingungen **allein** sind keine ausdrueckliche Erlaubnis zur Veroeffentlichung einer vollstaendigen Kopie seiner Inhalte im Addon-ZIP.
- Vor dem grossen Import eine nachweisbare Zustimmung fuer Abruf, Zwischenspeicherung und Veroeffentlichung des Datenauszugs **im WoW-Addon** einholen; idealerweise schriftlich. Ohne diese Freigabe nur selbst beobachtete Spielinformationen oder separat klar lizenzierte Daten einsetzen.
- WoWHead fungiert nur als Suchziel fuer Gegenstands-/NPC-IDs. Das Addon erzeugt statische URLs, die Spieler selbst kopieren; es scraped, speichert und integriert keine WoWHead-Seiteninhalte.
- API-Schluessel nie im Repository, im Addon-ZIP oder in commit-/CI-Logs speichern. Keine weitere Beschaffung fuer den oeffentlichen Einsatz in diesem Auftrag.
- Namen/Marken "World of Warcraft", "Blizzard" und "Wowhead" nur identifizierend nutzen, keine Logos oder Aussagen, die eine Partnerschaft suggerieren.

## Lizenz- und Repositoryentscheidung

- **Erfuellt:** https://github.com/CrobIT-Solution/WoW-Market ist PUBLIC; der eigene Alpha-0.0.8-Quellcode liegt in `main` (verifiziert 09.11.2026, Quell-Commit `26d88a8050c66a834b8f3dfde02efae4b9219184`). Es wurden weder GitHub-Actions noch ein CurseForge-Release gestartet.
- **Code-Lizenz entschieden: `GPL-3.0-only`** fuer eigene Lua-/Python-Sourcen und Tests. Lizenzvolltext: `LICENSE` und fuer das separate Addon-Paket `WoWMarket/LICENSE.txt`. Fremde Daten, Spielkunst und Marken sind ausgenommen. Siehe `LIZENZ_ENTSCHEIDUNG_DE.md`. Die Blizzard-Regel erzwingt keine bestimmte OSI-Lizenz. Keine Fremdcode-Lizenzen stillschweigend uebernehmen.
- Fuer einen oeffentlichen Repo-Upload muss geprueft werden, dass nur eigene freigegebene Sourcen und lizenzierte Dateien enthalten sind. Externe Datensnapshots mit ungeklärten Rechten bleiben draussen.

## CurseForge-Schritte nach bestandenen Gates

1. Im Autorenportal https://authors.curseforge.com/#/projects/create/choose-game ein neues **World of Warcraft**-Addon anlegen.
2. Einzigartigen Titel **WoW-Market**, englische Kurz-/Langbeschreibung, passende Kategorien (Auction & Economy / Map & Minimap), eigene Icondatei (keine fremden Markenbilder), Lizenz und ggf. Source-Link angeben. CurseForge fordert laut seiner Hilfe Projektbeschreibung und Titel in **Englisch**.
3. Richtiges Flavor **Forever** und gepruefte Spielversion **1.60.1**, Interface **16001** waehlen. Nicht versehentlich Retail/Midnight auswaehlen.
4. Das **manuelle GitHub-Installations-ZIP** benutzt oben `AddOns/`, damit Spieler diesen Ordner nach `Interface/` kopieren koennen. Fuer CurseForge stattdessen ein **separates** ZIP mit `WoWMarket/` als oberstem Ordner vorbereiten; niemals das manuelle `AddOns/`-Archiv ungeprueft hochladen. `DataAgent`, Python-Skripte, Tests, API-Keys, Unterlagen und Design-Konzept gehoeren **nicht** in das Ingame-Installationspaket.
5. Echte Screenshots aus laufendem WoW nach Test nutzen. Die fruehere KI-Konzeptgrafik ist **kein echter Spiel-Screenshot** und darf nicht als Funktionsbeweis ausgegeben werden.
6. Als **Alpha** kennzeichnen; korrekte Funktionen und bekannte Grenzen offen beschreiben. Freigabe durch CurseForge-Moderation abwarten. Erst spaeter echte Beta/Release nach Live-Tests.

## Beispiele fuer englische Projektmetadaten (Entwurf)

**Summary:** A free, read-only vendor catalogue and optional manual auction snapshot companion for WoW Forever.

**Description:** WoW-Market is an independent, free WoW Forever interface addon. It records vendor information when players open merchant windows, lets players search known items and vendor locations, and prepares copyable Wowhead reference links. A manually triggered auction snapshot can be used for informational comparisons, subject to in-game API and throttle limits. No automated trading, no web browser, and no remote data upload. Full third-party vendor datasets are not bundled unless distribution rights are verified. This alpha has not yet passed an in-client acceptance test.

## Aktueller Release-Status

**STOP – oeffentliche Veroeffentlichung noch nicht freigegeben.** Offene Gates: reproduzierbarer Forever-Client-Test; Pruefung etwaiger Fremdassets und Marken; sachlicher Quellenhinweis; echte Performance-Messung; erst nach Datenerlaubnis ein oeffentlicher Vollimport. Der eigene Code ist GPL-3.0-only-lizenziert. Eine oeffentliche Nur-Local-Snapshot-Alpha kann nach Client-Test auch ohne externe Daten veroeffentlicht werden, muss aber die leere Referenzdatenbank klar benennen.

## Vereinfachte manuelle Testinstallation

[Downloads/WoW-Market_Alpha_0.0.8_Install.zip](Downloads/WoW-Market_Alpha_0.0.8_Install.zip) ist ausschliesslich fuer manuelle Testinstallationen vorgesehen. ZIP entpacken, Ordner `AddOns` nach `Interface` kopieren und vorhandene Ordner zusammenfuehren. Keine zusaetzlichen Werkzeuge oder Entwicklerdateien notwendig. Vollstaendige Beschreibung: [INSTALLATION_DE.md](INSTALLATION_DE.md). Das ist keine offizielle CurseForge-Veroeffentlichung; der echte Client-Test bleibt offen.
