# WoW-Addon-Zentrale – verbindlicher Entwicklungs- und Sicherungsstandard

**Version:** 1.0 · **Beschluss:** 13.11.2026 · **Geltung:** neue und bestehende WoW-Addon-Projekte der WoW-Addon-Zentrale unter `CrobIT-Solution`.

**Kanonische Quelle:** Diese Datei in `CrobIT-Solution/WoW-Market` auf `main`. Weitere Addon-Repositories verweisen hierher; ihre Hinweise sind keine abweichenden Regelkopien. Diese WoW-Regeln sind eigenständig und ersetzen oder erweitern keine CrobIT-Ökosystem-Freigaben.

## 1. Grundsätze

- Ein eigenes öffentliches GitHub-Repository pro unabhängigem Addon-Projekt; zusammengehörige Module wie `AdiBagsForever` und dessen Konfigurationsmodul bleiben in einem Repository.
- Produktname und Repository nachvollziehbar; Maintainer-Angabe: **Blackiron**. Ursprüngliche Autoren und Lizenz-/Copyright-Hinweise erhalten.
- `README.md`, `LICENSE`, Änderungsverlauf und dauerhaft abrufbarer Entwicklungsstatus sind Pflicht, soweit Rechte und Bestand dies erlauben. Bestehende Dateien nicht unnötig duplizieren.
- GNU GPL v3 als gewünschte Lizenzlinie **nur im rechtlich erlaubten Umfang**; vorhandene Upstream-Lizenzen und gesonderte Rechte an Fremdcode, Bibliotheken, Bildmaterial und Daten bleiben maßgeblich. Keine automatische Freigabe fremder Datenbanken oder Spielgrafiken.
- Keine Geheimnisse, Zugangsdaten, Tokens oder privaten Spielerdaten in öffentliche Repositories, Commits oder Checkpoints.
- Keine unerlaubte Spielautomatisierung. WoW-Forever-Kompatibilität und Ingame-Verhalten separat nachweisen.

## 2. Vor JEDEM neuen Entwicklungsdurchgang

1. Das zugehörige Repository und die aktuelle `ARBEITSREGELN.md` lesen; diesen kanonischen Standard bei Bedarf neu prüfen.
2. Den **tatsächlich aktuellen** Zielbranch, Commit-HEAD, vorhandene Checkpoints, offene Fehler, erlaubten Änderungsumfang und anstehende Workflow-Auslöser prüfen.
3. Ausgangsstand sichern; keine ältere ZIP, Chatfassung oder frühere Design-Demo über einen neueren GitHub-Stand schreiben.
4. Bei widersprüchlichen, fehlenden oder nicht lesbaren Nachweisen **STOP** und die Lücke benennen. Eine Chat-Übergabe allein beauftragt keine Entwicklungsarbeit.

## 3. Jeder genehmigte Arbeitsdurchgang wird vollständig gesichert

1. Nur freigegebene Dateien auf dem passenden Entwicklungs-/Featurebranch ändern; Änderungen möglichst klein und nachvollziehbar halten.
2. Nur freigegebene, geeignete Prüfungen ausführen. **Quellprüfung, synthetische Tests, echter WoW-Forever-Ingame-Test und veröffentlichter Release sind getrennte Nachweisstufen.**
3. Vor GitHub-Schreibaktion aktuellen HEAD, Diff, betroffene Dateien, Branch, Rechte, Workflow-/CI-Auslöser und Kostenrisiko erneut prüfen.
4. Nach erfolgreicher Umsetzung einen nachvollziehbaren **atomaren Git-Commit** erstellen; Commit-SHA und geänderte Dateien auf GitHub **zurücklesen**. Nicht als gesichert melden, bevor das tatsächlich bestätigt ist.
5. **Nach jedem abgeschlossenen Arbeitsschritt** einen versionierten GitHub-Checkpoint bzw. eine Statusaktualisierung sichern, der/die mindestens enthält:
   - Projekt, Datum, Fachchat, Version, Branch, exakten Produkt-Commit-HEAD
   - was geändert wurde und was unverändert blieb
   - welche Tests **tatsächlich** durchgeführt wurden, mit Ergebnis; welche nur geplant oder simuliert sind
   - verbleibende Bugs, Lizenz-/Datenfragen und sonstige Stopps
   - präzisen nächsten Wiederaufnahmeschritt
6. Vor dem nächsten Schritt den neuesten Checkpoint wieder einlesen. Bei fehlendem Schreibzugang den vollständigen Stand im Chat liefern und die GitHub-Sicherung ausdrücklich als **offen** kennzeichnen.

**Ablage:** Vorhandene Status-/Testdateien weiterverwenden; andernfalls `docs/PROJEKTSTATUS.md` und bei Bedarf `docs/CHECKPOINTS/`. Die konkrete Struktur darf einfach bleiben. Bei selbstreferenziellen Commit-Hashes dürfen Code-Commit und nachfolgender Checkpoint getrennte Commits sein; beide sind nachzuweisen.

## 4. Frühe Übergabe statt Chat-Verlust

- Nach jedem wesentlichen Durchgang einen kurzen Checkpoint; spätestens nach **drei größeren Durchgängen oder fünf längeren Wechseln** eine vollständige, sofort verwendbare Übergabe aktualisieren. Bei drohendem Chatlimit früher handeln.
- Eine Übergabe nennt Quellenlinks, Versions-/Branch-/HEAD-Nachweise, Testergebnisse, offene Aufgaben und den exakten nächsten Schritt.
- Der Nachfolge-Fachchat **liest zunächst ausschließlich** die Übergabe und prüft die GitHub-Fakten. Die Übergabe ist **kein automatischer Auftrag** für neuen Code, Tests, CI, Builds oder Releases.

## 5. Eigenverantwortung und Freigabegrenzen

- Notwendige technische Detailentscheidungen innerhalb bereits erteilter Freigaben selbstständig treffen; keine unnötigen Rückfragen bei Routineschritten.
- **Keine** zusätzliche Architektur, neue Kosten, neuen Funktionsumfang oder Änderung von Sicherheits-/Lizenzgrenzen ohne Eigentümerentscheidung.
- **Kein** automatischer Merge nach `main`, kein Tag/Release, CurseForge-Upload, CI-/Build-Lauf oder Deployment allein wegen der Dokumentations- oder Checkpoint-Regel.
- Bestehende ausdrückliche Nur-lesend-, Nur-lokal-, Kein-Commit- und andere STOP-Vorgaben gehen vor. Scheitert ein Gate, nicht behaupten, es sei erfolgreich gesichert.

## 6. Abschluss jedes Arbeitsdurchgangs

Kurz festhalten: **Was ist abgeschlossen oder warum STOP? Was folgt als Nächstes? Was empfiehlt Buddy?** Nur nachgewiesene Ergebnisse als fertig bezeichnen.

## 7. WoW-Addon-Projekte beim Beschluss

- `CrobIT-Solution/WoW-Market`
- `CrobIT-Solution/AdiBagsForever` (inklusive Konfigurationsmodul)
- `CrobIT-Solution/LootOwner`
- `CrobIT-Solution/QuestCompendiumForever`

**Quelle des Verfahrens:** Für WoW angepasst nach den CrobIT-Ökosystem-Mechanismen DEC-040 (Abschluss), DEC-041 (Checkpoints/Übergaben), DEC-045/047 (gebündelte Eigenverantwortung), DEC-050 (Commit und Nachweis). Keine Übernahme produktspezifischer CrobIT-Sicherheits-/Infrastrukturfreigaben.

**Änderungsregel:** Änderungen dieses Standards erfolgen ausschließlich bewusst, nachvollziehbar und mit einer neuen Version dieser kanonischen Datei. Verweisdateien in den anderen Repositories bleiben Verweise.
