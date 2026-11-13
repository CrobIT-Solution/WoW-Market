# WoW-Market Alpha 0.0.30 – Design V2, Revision C

**13.11.2026 · Maintainer Blackiron · Entwickler-Teststand**

## Verbindliche Mastervorlage
Das zweite vom Nutzer bereitgestellte Konzeptbild »WoW-Market Händlerübersicht in Azeroth« bleibt die verbindliche Sollvorlage. Der tatsächliche Alpha-0.0.29-Ingame-Screenshot zeigte WuarK / Abgenutzter Langschild, echte Händlerwaren und den Preisvergleich. Allerdings waren Schrift und Karten weiterhin deutlich kleiner als im Sollbild. **Design V2 ist daher noch nicht abschließend visuell abgenommen.**

## Änderungen in 0.0.30
- Ergebnisliste: statt sechs schmaler Tabellenspalten 70 UI-Einheiten hohe zweizeilige Quellenkarten; Name, Zone/Item, Preis und Status besser gewichtet.
- Rechte Warenliste: 54 Einheiten hohe Kacheln mit 44×44 Item-Icons und 17er Leseschrift, zwei Spalten und höhenabhängige Pagination (2/4/6/8).
- Große Item-/Händlerüberschriften, klarere Preisanzeigen, responsive kurze Labels, dunkler abgestimmte Steinflächen und etwas breitere Navigation.
- Dezente große dekorative Darstellung nur mit dem **echten Icon des ausgewählten Items**. Keine Demo-Händler, Beispielpreise, erfundene Quellen oder synthetische Itembilder.
- Neue Installationen nutzen 1600×860 UI-Einheiten, soweit der Bildschirm Platz hat. **Bereits gespeicherte Fenstermaße bleiben erhalten.**
- Zuvor versteckter Maximieren-Knopf ist sichtbar und nutzt ca. 96,5 % Bildbreite / 95,5 % Bildhöhe; zweiter Klick stellt die bisherige Fenstergröße wieder her.
- Netzwerkmodul, Item-Shift-Klick, tatsächliche Daten und SavedVariables unverändert.

## Prüfung
- 16 Lua-Dateien syntaktisch geprüft: PASS.
- UI-Mock mit allen vier Quellreitern, Itemauswahl, Händlerdetail und sichtbarer Großansicht samt Restore: PASS.
- Shift-Klick-Mock und Zwei-Client-PING/ACK-Netzwerk-Mock: PASS.
- Designcontract und SHA-256-Artwork-Prüfung: PASS.
- **50/54 gemeinsame Dateien der Installations-ZIPs sind bytegleich**, inklusive sämtlicher 32 TGA-Bilder, Daten, NetProbe, ItemLink und Lizenzen.
- ZIP-CRC, TOC-Einträge, SavedVariables und reproduzierter Build: PASS.
- Entwickler-Tests verbleiben im Git-Quellstand und werden nicht in das Installations-ZIP gepackt.
- **Die echte WoW-Forever-Sichtabnahme ist noch offen.**

## Vollständig gesicherter lokaler Git-Stand
- Vollständiger lokaler Commit: f41685fc0f9d14393360400bfbda594416fe9b31; Elterncommit bf5fb107cc1406e54bdb07d5a97ac68b60cfc6c5; Author Blackiron.
- Lokales Tag: alpha-0.0.30-design-v2-test.
- ZIP: WoW-Market_0.0.30-alpha_Design-V2-Lesbarkeit.zip, 2.321.197 Bytes, SHA-256 e32dbf96985379a5e61f11ff727a6ad7b5383cf78a56fcd68c029810bf7d56b5.
- Vollständiges Git-Bundle: WoW-Market_0.0.30-alpha_Design-V2_Vollbackup.git.bundle, 6.471.563 Bytes, SHA-256 16e25b571089406bd4f978b1bdd3c41417b2872af731814442a08428e3e01f26. Bundle verify: PASS.
- Lokaler Git-Quellstand enthält das unveränderte originale Sollbild, Testskripte und einen aus der eigenen Checkout-Dateiliste reproduzierbaren ZIP-Build.

**GitHub-Einschränkung:** Dieser Remote-Archivbranch enthält nur Design-/Versionsnachweise. Der vollständige aktuelle Code samt Binärgrafiken liegt im geprüften lokalen Git-Bundle. GitHub-main ist unverändert und älter; weder Release noch CI, Merge oder Deployment ausgelöst.

## Nächster echter Test
Beim geschlossenen WoW das WoWMarket-Installationsverzeichnis durch 0.0.30 ersetzen (SavedVariables behalten), Item Abgenutzter Langschild / Händler WuarK öffnen, lesbare Ergebnis- und Warenzeilen prüfen, einmal Großansicht ein- und wieder ausschalten und den Ingame-Screenshot mit dem Masterbild vergleichen.