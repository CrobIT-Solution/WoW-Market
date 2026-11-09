# GitHub-Status – WoW-Market

Stand: 09.11.2026. Verbindliches Repository: https://github.com/CrobIT-Solution/WoW-Market

- **Sichtbarkeit: PUBLIC** (am 09.11.2026 ueber die GitHub-Repository-API verifiziert).
- **Branch: main**, Quellcode-Import Alpha 0.0.8: `26d88a8050c66a834b8f3dfde02efae4b9219184`.
- Enthalten: eigene Lua-Addonquellen, `.toc`, eigene Python-Importer, synthetische Tests und Dokumentation.
- Nicht enthalten: API-Schluessel, SavedVariables, Rohdaten mit Reporterkennungen, fremde WoWHead-/QuestieDB-Datensammlungen und ungepruefte Grafikdateien.
- Keine automatisierten GitHub-Actions, Builds oder kostenpflichtigen Dienste notwendig.
- Das Repository liegt bei der Organisation CrobIT-Solution, der **Addon- und Produktname lautet ausschliesslich WoW-Market**.

## Aktuell offene Schritte

1. **Erledigt:** Eigener Code: GPL-3.0-only; Lizenztext in `LICENSE` und `WoWMarket/LICENSE.txt`. Siehe [LIZENZ_ENTSCHEIDUNG_DE.md](LIZENZ_ENTSCHEIDUNG_DE.md).
2. Echten WoW-Forever-Client-Test und Performancepruefung anhand [ABNAHME_CHECKLISTE_DE.md](ABNAHME_CHECKLISTE_DE.md) durchfuehren. **Nicht erfolgt.**
3. Vor einem echten Fremddatenimport Herkunft, Weiterverbreitungsrechte, korrekte Attribution und Datenlizenz getrennt pruefen. Referenz-Haendlerbestand derzeit leer.
4. Erst nach den erforderlichen Gates ueber eine CurseForge-Alpha entscheiden.

**Wichtig:** Public GitHub-Code ist nicht gleich CurseForge-Release oder eine formale Freigabe durch Blizzard.
## Endnutzer-Installationspaket

Fuer manuelle Testinstallationen gibt es jetzt [Downloads/WoW-Market_Alpha_0.0.8_Install.zip](Downloads/WoW-Market_Alpha_0.0.8_Install.zip). Der Benutzer entpackt es und kopiert ausschliesslich den Ordner `AddOns` in den vorhandenen WoW-Ordner `Interface`. Im `AddOns`-Ordner liegt nur `WoWMarket` mit seinen benoetigten Dateien. Anleitung: [INSTALLATION_DE.md](INSTALLATION_DE.md).

**Nicht mit dem GitHub-Quellcode-ZIP verwechseln.** Das Archiv wird ohne CI aus dem `WoWMarket`-Ordner erstellt; der Buildhelfer `Tools/build_install_package.py` verwendet nur Python-Standardbibliothek. Das spaetere CurseForge-Upload-ZIP braucht dagegen den obersten Ordner `WoWMarket/` statt `AddOns/`. Der echte Client-Test ist unveraendert ausstehend.
