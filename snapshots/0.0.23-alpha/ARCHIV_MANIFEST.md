# WoW-Market 0.0.23-alpha – Netzwerktest/Diagnose (12.11.2026)

**Status: lokaler, nicht freigegebener Entwickler-Teststand.**

## Quelle und Integrität
- Vollständiges lokales ZIP: `WoW-Market_0.0.23-alpha_Netzwerk-Diagnose.zip`.
- SHA-256: `1196e007b5474a828cf71610e20c051f2fb5b32cc71f147b96463fb00332efe1`
- Dateigröße: **1.383.671 Bytes**; 49 Paketdateien, 15 Lua-Module.
- Vorgänger: `WoW-Market_0.0.22-alpha_Netzwerktest.zip`, SHA-256 `6012095c616d827fe489fe37a33e29d90fe89e53948f7bc9b369468c5d02a077`.
- Basis des Vorgängers: lokale `0.0.21-alpha_Everloot-Daten`.
- Vollständiges ZIP als unveränderlicher Artefaktstand im Chat bereitgestellt und in **ChatGPT Library** unter `/WoW-Forever/WoW-Market/` zu sichern. **Die vollständigen 1,38 MB ZIP-Bytes und die Artwork-Dateien sind NICHT in diesem Git-Branch abgelegt.** Dieser Commit dokumentiert derzeit nur den externen Versionsstand, nicht einen vollständig buildbaren Source-Snapshot. Kein falscher Git-Freeze.

## Delta 0.0.22 -> 0.0.23
- `WoWMarket/Core.lua`: zusätzlich `/wowmarketdiag` und `/wowmarketnet`, mit sichtbarer Meldung über `UIErrorsFrame` und Chat; bestehende `/wm`-Aliasse unverändert.
- `WoWMarket/NetProbe.lua`: `an`, `aus`, `status` melden zusätzlich Bildschirmstatus.
- `WoWMarket/WoWMarket.toc`, `UI.lua` und Versionstexte: 0.0.23-alpha.
- `NETZWERKTEST_START_HIER.txt`: Installationshinweise, neue Befehle und Diagnoseentscheidung.
- Andere Module, `Data/Community.lua`, `Data/Vendors.lua`, `Knowledge.lua`, `DetailPanel.lua`, alle Art-Dateien blieben **bytegleich** zum 0.0.22-Paket.
- SavedVariables `CrobITMarketDB` bleiben unverändert. Kein Datenreset/keine Migration.
- Keine echten Spielerbeobachtungen gesendet, nur explizite synthetische PING-/ACK-Testsignale. Keine automatischen Netzwerkversuche, kein Webupload und kein Kanaljoin.

## Tatsächlich ausgeführte lokale Prüfungen
- ZIP-CRC und `.toc`-Vollständigkeit PASS.
- 15 Lua-Dateien mit `texlua` per `loadfile` geprüft: PASS.
- Simulierter Netzwerktest: manuelle Freigabe, PING/ACK, Abschalten, Cooldowns, Route WHISPER/GUILD/PARTY/CHANNEL, SavedVariables-Erhalt: PASS.
- Simulierter unabhängiger Slash-Befehl und Bildschirmhinweis: PASS.
- **Echter WoW-Forever-Test noch ausstehend.** Vorläufer `0.0.22`: Anwender meldete für `/wm net an`, `/wm net status` keine sichtbare Chatmeldung. Ursache noch nicht bestätigt.

## Installations-/Diagnose-Gate
1. Bei geschlossenem Spiel aktiven `Interface/AddOns/WoWMarket` sichern und durch **vollständigen** `WoWMarket`-Ordner aus dem neuen ZIP ersetzen. SavedVariables nicht löschen.
2. In WoW-Addon-Liste Version `0.0.23-alpha` kontrollieren.
3. `/wowmarketdiag`: Version und Zustand des Netzmoduls im Chat und ggf. Bildschirm.
4. `/wowmarketnet status`: API-/Freigabestatus im Chat und auf dem Bildschirm.
5. Erst nach erfolgreichem Test zwei opt-in Teilnehmer mit synthetischen PING/ACK testen; kein produktiver Rollout.

## Git-Integrationsgrenze
`main` liegt bei Alpha `0.0.8`, und der ältere Featurebranch enthält Teile von `0.0.10`. **Weder hier noch auf `main` wurde die komplette lokale `0.0.21`-/`0.0.23`-Quellbasis integriert.** Für einen wirklichen, vollständig buildbaren Git-Snapshot müssen die 49 Dateien inklusive Binärgrafiken separat vollständig eingecheckt und die SHA-/TOC-Gates bestätigt werden. Keine Merges, CI, Actions, Deployments oder Releases in diesem Dokumentationsdurchgang.

## Parallel
- [WoW-Market Kommunikations-Issue #4](https://github.com/CrobIT-Solution/WoW-Market/issues/4)
- [Quest Compendium Datenübergabe](https://github.com/CrobIT-Solution/QuestCompendiumForever/issues/1)
- Wowhead/ZAM Ticket **#64652**, Datennutzung weiterhin ohne Freigabe.
