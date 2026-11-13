# WoW-Addon-Zentrale – Checkpoint: Sicherungsstandard V1.0 eingerichtet

**Datum:** 13.11.2026 (MEZ; genaue Uhrzeit nicht verifiziert)  
**Auftrag:** Zentrale WoW-Addon-Arbeitsregeln aus dem Chat „WoW-Addon-Zentrale“ in allen vier bestehenden Repositories sichern.  
**Typ:** Ausschließlich Dokumentation, keine Produktentwicklung.

## Gesicherte Quelle

[Zentrale ARBEITSREGELN.md](../../ARBEITSREGELN.md), Version 1.0.  
**Regel-Commit:** `d45f375b4bbcf41517706994a795ca55226db830` auf `CrobIT-Solution/WoW-Market/main`.

## Repositories und bestätigte Dokumentationscommits

| Repository | Branch | Commit | Geänderter Dateipfad |
|---|---|---|---|
| [WoW-Market](https://github.com/CrobIT-Solution/WoW-Market) | `main` | [`d45f375b`](https://github.com/CrobIT-Solution/WoW-Market/commit/d45f375b4bbcf41517706994a795ca55226db830) | Neue `ARBEITSREGELN.md` (kanonisch) |
| [AdiBagsForever](https://github.com/CrobIT-Solution/AdiBagsForever) | `main` | [`74d83d5c`](https://github.com/CrobIT-Solution/AdiBagsForever/commit/74d83d5cddffa34018f60c6a3fc670dc1ad4d4df) | Neue `ARBEITSREGELN.md` (Verweis) |
| [LootOwner](https://github.com/CrobIT-Solution/LootOwner) | `main` | [`9de82caa`](https://github.com/CrobIT-Solution/LootOwner/commit/9de82caa56359e2ef06ba4a83067e570d4049861) | Neue `ARBEITSREGELN.md` (Verweis) |
| [QuestCompendiumForever](https://github.com/CrobIT-Solution/QuestCompendiumForever) | `main` | [`67999e8d`](https://github.com/CrobIT-Solution/QuestCompendiumForever/commit/67999e8d715bf6c6e4bebdf9b74485e3f477d708) | Neue `ARBEITSREGELN.md` (Verweis) |

**Kontrollnachweis:** Die vier neuen Dateien wurden direkt von GitHub zurückgelesen und ihr Inhalt als vollständig bestätigt. Für jeden Commit wurde nachgelesen, dass exakt **eine neue Dokumentationsdatei** hinzukam; vorhandene Dateien wurden nicht geändert oder gelöscht. Auf den geprüften Defaultbranches waren keine `.github/workflows/`-Dateien vorhanden. Es wurden keine Tests, CI, Builds, PRs, Merges, Releases, CurseForge-Uploads oder kostenpflichtigen Aktionen beauftragt oder ausgeführt.

## Geltung und nächste Arbeit

- Die neue Regel gilt künftig bei jedem **genehmigten** Addon-Entwicklungsdurchgang. Sie erzeugt keine Hintergrund-Automatisierung und keine neue Entwicklungsfreigabe.
- Jeder Fachchat liest vor der nächsten Umsetzung den neuesten GitHub-Stand und bewahrt die bereits aktuellen Entwicklungs-/Designbranches. Nicht aus historischen Chats auf Versionen zurücksetzen.
- **WoW-Market:** aktuell mehrere archivierte Alpha-Entwicklungsbranches, vor Produktarbeit tatsächlichen neuesten Stand statt des Defaultbranches feststellen.
- **AdiBagsForever:** bestehende `develop`-/Featurebranches und öffentliche Release-Version getrennt behandeln.
- **Quest Compendium Forever:** Design-Demo v1.6.1 auf vorhandenem Featurebranch nicht mit `main` verwechseln.
- **LootOwner:** vor Änderungen den jeweils aktuellen `main`-Stand und die Ingame-Testlage prüfen.

**Offen:** Noch keine vollständigen neuen projektspezifischen `docs/PROJEKTSTATUS.md`- und Checkpoint-Historien für alle Projekte eingerichtet. Bestehende Dokumente bleiben gültig; neue Checkpoints werden bei den jeweils nächsten Entwicklungsdurchgängen aufgebaut.

**Abschluss:** Gemeinsame Regeln dauerhaft hinterlegt und in allen vier Repositories verlinkt. Dieser Nachweis ist selbst ein gesonderter Dokumentationscommit; der Commit des Standards bleibt der oben genannte Referenz-HEAD.
