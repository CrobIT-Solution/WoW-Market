# Manuelle WoW-Forever-Abnahme – Alpha 0.0.8

Nicht ausgefuehrt – diese Punkte koennen nur am echten WoW-Client geprueft werden.

- [ ] Altes `CrobITMarket` Addon-Verzeichnis entfernt, bestehende `CrobITMarketDB` SavedVariables gesichert und behalten.
- [ ] `WoWMarket` im tatsaechlichen Forever-Installationsordner aktiviert, ohne Lua-Fehlermeldungen gestartet.
- [ ] Minimap-Symbol bei Login sichtbar; Linksklick auf/zu, Rechtsklick Quellenreiter, Ziehen speichert Position nach /reload, Tooltip, Kompatibilitaet mit weiteren Minimap-Addons. Kein Chatbefehl erforderlich. Buttons/Popup und Anzeige bei verschiedenen Bildschirmgroessen korrekt.
- [ ] Drei echte Haendler (unterschiedliche Waren-/Bestands-/Rufpreise) nacheinander besucht und erfasst.
- [ ] Eigene SavedVariables nach Neustart vorhanden; Upgrade von 0.0.3 ohne Datenverlust (Backup vorher).
- [ ] Quellenreiter zeigt **keinen** angeblichen Fremddatenanbieter, solange die Datenbank leer ist.
- [ ] WoWHead-Item- und NPC-Adressen sind korrekt, Linkfenster laesst Strg+C zu.
- [ ] Kartenfunktion nur per Klick, Combat-Sperre, kein Wegpunkt ohne bekannte Koordinaten.
- [ ] Standard-Wegpunkt funktioniert auf geeigneter Karte und ersetzt Wegpunkte nur nach Klick.
- [ ] AH-Scan nur bei offenem Auktionshaus und Nutzerklick, kein automatischer Scan beim Betreten.
- [ ] 15-Minuten-Drossel, Abbruch beim Verlassen, Maximalanzahl und Serverlimit geprueft; bei grossem AH keine Performance-Probleme.
- [ ] Momentaufnahme nach Scan plausibel, Kaufmengen korrekt normalisiert; keine Gebote oder Einkaeufe.
- [ ] Keine Fehler mit parallel installierten gaengigen Addons und insbesondere keinen Geschwindigkeitsabfall bei 1k, 10k, 30k/100k synthetischen Referenz-Warenpositionen.
- [ ] Mehrere Zonen/Haendler, Fraktionen, Realmkontext und deutsch/englische Clienttexte pruefen.
- [ ] Datenschutz, Lizenzdatei, Logo-/Bildrechte, Quellenrechte und beabsichtigte CurseForge-Metadaten geprueft.
- [ ] Erst danach Ergebnis dokumentieren und oeffentliche Alpha-Freigabe entscheiden.

## Zusaetzlicher Testpunkt Alpha 0.0.8 (QuestieDB)

1. **Ohne QuestieDB:** WoW-Market ueber Minimap oeffnen; keine Ladefehler und keine Pflicht-Abhaengigkeit.
2. **Mit installiertem, kompatiblem QuestieDB:** Bei unbekannten NPC-/Item-IDs kann die Anzeige einen Namen vorschlagen; in der Detailansicht steht „QuestieDB-Zusatzinformation“.
3. QuestieDB-Zonen- und Spawn-Hinweise muessen als moeglich/unbestaetigt markiert sein. **Keinen Wegpunkt aus unbekannten QuestieDB-Zonen-IDs erzeugen.**
4. Bereits im Spiel beobachtete Namen und Standorte duerfen nicht von QuestieDB-Hinweisen ueberschrieben werden.
5. Im Quellen-Reiter den QuestieDB-Status und den unveraenderten, kopierbaren WoWHead-Link pruefen.

Dies sind **manuelle** Abnahmeschritte. Sie wurden in dieser Entwicklungsumgebung nicht in einem echten Forever-Client durchgefuehrt.
