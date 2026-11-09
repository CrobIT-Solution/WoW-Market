# WoW-Market – Installation (Alpha 0.0.8)

**Ein ZIP, ein Ordner zum Kopieren. Kein Git, Python oder Installer erforderlich.**

1. **[WoW-Market Installations-ZIP herunterladen](https://github.com/CrobIT-Solution/WoW-Market/raw/refs/heads/main/Downloads/WoW-Market_Alpha_0.0.8_Install.zip)**. Nicht den GitHub-Knopf „Code → Download ZIP“ verwenden.
2. ZIP entpacken. Den darin enthaltenen Ordner **`AddOns`** in den bestehenden WoW-Ordner **`Interface`** kopieren. Bei Nachfrage die Ordner **zusammenfuehren**; andere Addons nicht loeschen.
3. World of Warcraft Forever neu starten, WoW-Market in der Addon-Liste aktivieren. Im Spiel oeffnet die Goldmuenze an der Minimap das Addon.

**Kontrolle:** `World of Warcraft\Interface\AddOns\WoWMarket\WoWMarket.toc` muss vorhanden sein. Je nach WoW-Installation befindet sich `Interface` unter einem anderen Client-Unterordner. **`Interface\WoWMarket` direkt ist falsch.**

**Falls zuvor die sehr alte Alpha `CrobITMarket` installiert war:** Vorher SavedVariables sichern und nur den alten Addon-Ordner `Interface\AddOns\CrobITMarket` entfernen, damit nicht zwei Addons dieselbe Datenbank benutzen. Die Ordner `WTF` und `SavedVariables` nicht loeschen.

Das ZIP enthaelt ausschliesslich die WoW-Addon-Dateien (TOC, Lua, Quellenhinweise, GPL-3.0-only-Lizenz); keine Entwicklertools, Zugangskeys oder fremden Rohdaten. QuestieDB ist optional.

**Teststatus:** Dies ist eine bislang nicht im echten WoW-Forever-Client abgenommene Alpha-Testfassung. Die vorinstallierte Referenz-Haendlerdatenbank ist leer. Kein CurseForge-Release.
