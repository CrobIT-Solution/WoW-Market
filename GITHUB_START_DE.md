# GitHub – aktueller Stand am 09.11.2026

**Verbindliches Repository:** https://github.com/CrobIT-Solution/WoW-Market

- Das Repo **existiert** und der GitHub-Connector kann es mittlerweile lesen.
- `main` wird mit dem vollstaendigen Alpha-0.0.8-Quellstand initialisiert.
- Sichtbarkeit aktuell: **Internal**, nicht Public. Fuer eine spaetere oeffentliche Addon-Verteilung ist nach Blizzard-Richtlinien **oeffentlich einsehbarer Code** erforderlich.
- Eine Oeffentlichkeitsumstellung ist **noch nicht** beauftragt oder durchgefuehrt.
- Es sind keine Actions-Workflows, CI-Builds oder kostenpflichtigen Dienste fuer WoW-Market erforderlich.

## Vorgepruefter Quellstand

Der Stand **Alpha 0.0.8** liegt im ZIP `WoWMarket_Alpha_0.0.8_Repo_Erstimport.zip` vor. Es enthaelt `WoWMarket/`, `DataAgent/`, `Tests/`, die Projekt-READMEs, Datenquellen- und Lizenzinformationen, Changelog und die Abnahmedokumentation. Es enthaelt **keine** echten Everloot-Rohdaten, SavedVariables, Zugangsschluessel, privaten Daten oder WoWHead-Kopien.

Manueller Upload bei Bedarf: ZIP lokal entpacken; im Repository **Add file -> Upload files** waehlen und die Ordner/Dateien des entpackten Pakets angeben. GitHub kann auch mehrere Dateien/Ordner per Drag-and-Drop annehmen. Die vorhandene README soll dabei durch die neue Alpha-0.0.8-README ersetzt werden. Noch keine Actions und keinen Release ausloesen. Sicherer waere eine isolierte Branch-/PR-Erstbefuellung, wenn ein geeignetes Upload-Werkzeug zur Verfuegung steht.

**Wichtig:** Ein GitHub-Code-Upload ist keine Freigabe auf CurseForge. Code-Lizenz, Third-Party-Rechte, Echt-Client-Test und Release-Gates bleiben offen.
