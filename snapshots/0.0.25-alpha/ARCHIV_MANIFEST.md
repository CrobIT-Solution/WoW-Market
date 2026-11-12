# WoW-Market Alpha 0.0.25 – Forever-Netzwerkfix

**Status:** Entwickler-Testversion, 12.11.2026. Noch keine echte Ingame-Abnahme der Korrektur.

## Zugrundeliegende Echtbefunde (Alpha 0.0.24)

- WoW Forever meldet für `CHAT_MSG_ADDON` vollständige Absendernamen wie **Washakie Sturmrufer** und **Washakie Sturmbringer** (Vornamen identisch, Nachnamen verschieden).
- PARTY und CHANNEL liefern nachweislich synthetische PINGs zwischen den Accounts; der Sender sieht außerdem sein eigenes PING-Echo.
- ACK-Zähler blieben auf beiden Accounts bei 0. Ein konkreter Codefehler war `not target:find("%s")` in `NetProbe.lua`: Ein Absender mit Leerzeichen konnte kein ACK-Ziel sein.
- Die Gildenübertragung blieb mangels gemeinsamer Gilde ungeprüft.

## Gebündelte Änderungen

1. Vollständige Forever-Namen mit Leerzeichen werden als WHISPER-Ziel akzeptiert; weiterhin sichere Kontrolle gegen Steuerzeichen/Markup.
2. Ein empfangener fremder PING wird per privatem **WHISPER an den exakten `CHAT_MSG_ADDON`-Absender** bestätigt; API-Fehler werden lokal geloggt. Kein Replay über GROUP/GUILD/CHANNEL.
3. Eigene PARTY-/CHANNEL-PING-Echos werden mithilfe der **vollständigen** Spieleridentität erkannt, nicht anhand des bloßen Vornamens. Der Status zeigt eigene ignorierte und fremde empfangene PINGs getrennt. Eigene Echos erzeugen keine ACKs.
4. Version in `Core.lua`, `UI.lua`, TOC und Begleittexten auf **0.0.25-alpha** angehoben. Kein SavedVariables-Schemawechsel, kein Daten-Reset.

## Lokaler vollständiger, überprüfter Git-Commit

- Branch: `feature/wow-market-0.0.25-alpha-forever-netzwerk`
- **Lokaler Commit:** `c305bf94d5785c9f5c0fbf413144321b1dfecb00`, Vorgänger `2a2f3d0f273c16d95cc56ca162e2fb35edbcba52`.
- Vollständige lokale Version als Git-Bundle `WoW-Market_0.0.25-alpha_Vollbackup.git.bundle`, **SHA256** `da8be2e926183b933e1e4a4fa51903db26e8ad077c0d20393a63560d12c50811`. Verifiziert mit `git bundle verify`.
- Installation: `WoW-Market_0.0.25-alpha_Forever-Netzwerkfix.zip`, 51 ZIP-Dateien / 15 Lua-Module / **1.387.104 Bytes**, **SHA256** `d85ec16c13da406d91a77309ecc6c678d8207b5cce7b0712b2d6a2075c2e21c9`.
- Beide Dateien liegen in der ChatGPT Library: `/WoW-Forever/WoW-Market/`.

**WICHTIG:** Dieser GitHub-Branch dokumentiert den Entwicklungsstand, enthält aber **nicht die vollständigen aktuellen 0.0.25-Addonquellen und Binärgrafiken**. Das Git-Bundle enthält den vollständigen echten Git-Commit. Keine irreführende Behauptung, GitHub-`main` enthalte schon das komplette Addon. Der ältere GitHub-`main`-Branch ist nicht verändert. Der lokale Bundle-Commit lässt sich später separat vollständig in die GitHub-Repositorygeschichte übernehmen.

## Nachweise

- 15 Lua-Module plus Mock-Test syntaktisch kompiliert: **PASS**.
- Synthetischer Zwei-Client-Forever-Test: gleiche Vornamen, andere Nachnamen; PARTY, direkter WHISPER, CHANNEL, GUILD-Mock; korrektes ACK über WHISPER; ignorierte eigene Echos; Sender-/Namensvalidierung; opt-in/opt-out; keine Veränderung der vorhandenen SavedVariables: **PASS**.
- ZIP-CRC, TOC-Einträge, Versionskonsistenz: **PASS**.
- Bytevergleich mit Alpha 0.0.24: Nur 7 bestehende Dateien verändert (NetProbe, Versionstexte/-anzeige); 1 neuer Hinweistext. **43 ursprüngliche Dateien bytegleich**, einschließlich aller Grafiken, Everloot- und Lizenzdateien.
- **Noch nicht bestätigt im echten WoW-Forever-Client**: Lieferung von ACK an zweiteiligen Absender, Auswertungen nach Update, Gruppentest ohne Selbstzähler.

## Nächster echter Test

🟩 BEIDE: WoW schließen, vollen `Interface/AddOns/WoWMarket`-Ordner ersetzen, **SavedVariables behalten**. `/wowmarketdiag` und `/wowmarketnet an`.

🟥 HAUPTACCOUNT: **Washakie Sturmrufer** – mit beiden Charakteren in Gruppe **einmal** `/wowmarketnet gruppe`.

🟩 BEIDE: Nach 12 Sekunden `/wowmarketnet status`. Fremd-PING-Zähler des Empfängers und ACK-Zähler des Senders sollten steigen; eigene Echos nur im separaten Eigenzähler.

🟪 ZWEITACCOUNT: **Washakie Sturmbringer** – keine eigene Sendung für diesen Einzeltest.

Echte Spielbeobachtungen werden NICHT automatisch geteilt. Die Testkommunikation bleibt vollständig synthetisch und explizit freigabepflichtig.
