# WoW-Market – verbindlicher Designstandard V1
Versioniert ab Alpha **0.0.27-alpha** am 13. November 2026. Maintainer: **Blackiron**.

## Zweck
Der reale Alpha-0.0.26-Screenshot zeigte ein technisch funktionierendes Shift+Linksklick-Item (Reisebeinkleider, Item-ID 9756), aber geringe Lesbarkeit, schwache Kontraste und eine große leere Fläche im rechten Informationspanel. Dies wird als eigenständiger Designmangel behandelt, **ohne** Netzwerk, Item-Lookup oder Datenbasis neu zu bauen.

## Designvertrag
- WoW-Market-Banner, ursprüngliche Fantasy-/Stein-/Pergament-/Gold-/Horde-Grafiken beibehalten. Keine neuen Bilder/externen Fonts/Skins.
- Navigation **links**, Suche, Itemkarte und Liste **mittig**, Details/Karte/Links **rechts**; Reihenfolge erhalten.
- Steinflächen mit warmem hellem Text; Pergamentflächen mit dunkelbraunem Text. Positiver/aktiver Zustand grün, Warnungen rot, Information gold-/cremefarben.
- Schrift direkt auf **FontStrings**, niemals via `root:SetScale()` verkleinern. Suche 15, große Titel 18, Kartenwerte 16, Tabellen-Haupttext 14, Haupt-Fließtext rechts 15, Schaltflächen rechts 13, kleine Beschriftungen mindestens 12 UI-Einheiten (ausgenommen in Grafiken eingebrannte Texte).
- Standardfenster **1230 × 735** (nur für Neuinstallation; vorhandene gespeicherte Fensterabmessungen bleiben!). Rechte Detailspalte **38 %** mit Grenzen **380–680**, Ergebnisliste bekommt mehr Platz.
- Keine leere fiktive Warenliste: Bei 0 bekannten Waren rücken Informationen hoch; bei schmalen/niedrigen Fenstern **4/6/8 Zeilen pro Seite**, weitere Produkte über Blättern erreichbar. Bei sehr wenig Breite kurze Reiternamen, nicht mikroskopische Schrift.
- Gespeicherte Händler-/AH-/Beobachtungsdaten dürfen weder gelöscht noch ausgedacht werden. Shift+Linksklick und Netzwerktests bleiben unverändert.
- Änderungen an der Oberfläche nach dieser Basisversion nur bei **konkret belegtem Fehler**, notwendiger neuer Funktion oder **expliziter Designfreigabe**. Kein ungefragtes Redesign bei anderen Funktionsreleases.

## Validierung und Status
25 ursprüngliche TGA-Grafiken per SHA-256 in der **vollständigen lokalen Git-Version** eingefroren (`WoWMarket/DESIGN_ART_HASHES_V1.sha256`); ein automatischer `tests/check_design_v1.py` überwacht Layout- und Textregeln. Mocktests prüfen UI-Erstellung, Leerzustand, großes/kleines Fenster, 4/8 Waren pro Seite. Lua-Syntax, vorheriger Shift-Klick und Netzwerktest sind geprüft.

**Wichtig: Die Ingame-Sichtprüfung der neuen 0.0.27 ist noch offen.** V1 ist technisch als Grundlage versioniert, aber nicht als vom Spieler visuell abgenommen behauptet.

**Quelle:** Vollständiger lokaler Git-Commit `315083c414e55152cef6f1e48af3fcfcdcf64316` in verifiziertem Git-Bundle `WoW-Market_0.0.27-alpha_Design-V1_Vollbackup.git.bundle` (SHA256 `00edba6627ce9a260137df4b569eb36332c8cf2e0278034195652ef151829acc`). GitHub-`main` ist **nicht** die vollständige aktuelle Quelle. Dieser GitHub-Branch ist ein **separater Dokumentationsstand**, bis das vollständige Bundle integriert wird.
