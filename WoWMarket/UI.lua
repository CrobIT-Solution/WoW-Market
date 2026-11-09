-- SPDX-License-Identifier: GPL-3.0-only
local _, ns = ...
local main, searchInput, titleText, summaryText, footerText, detailText
local resultRows = {}
local visibleResults = {}
local page = 1
local pageSize = 9
local mode = "search"
local currentQuery = ""
local pageLabel, prevButton, nextButton
local itemLinkButton, npcLinkButton, sourceLinkButton, mapButton, waypointButton, ahScanButton
local selectedResult, showURL
local detailScroll, detailScrollContent

local GREEN = {0.34, 0.89, 0.28}
local WHITE = {0.93, 0.90, 0.79}

local function applyBackdrop(frame, color)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 14,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    frame:SetBackdropColor(unpack(color or {0.04, 0.055, 0.05, 0.95}))
    frame:SetBackdropBorderColor(0.24, 0.46, 0.20, 0.85)
end

local function label(parent, text, font, r, g, b)
    local line = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlight")
    line:SetText(text or "")
    if r then line:SetTextColor(r, g, b) end
    line:SetJustifyH("LEFT")
    return line
end

local function button(parent, caption, width, height, action)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(width, height)
    applyBackdrop(b, {0.09, 0.12, 0.09, 0.98})
    local font = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    font:SetPoint("CENTER", b, "CENTER", 0, 0)
    font:SetText(caption)
    b.text = font
    b:SetScript("OnClick", action)
    b:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(0.43, 0.96, 0.37, 1) end)
    b:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(0.24, 0.46, 0.20, 0.85) end)
    return b
end

local function setDetail(value)
    detailText:SetText(value)
    if detailScroll and detailScrollContent then
        local required = (detailText.GetStringHeight and detailText:GetStringHeight() or 300) + 30
        detailScrollContent:SetHeight(math.max(304, required))
        detailScroll:SetVerticalScroll(0)
    end
end

local function showDetail(result)
    if not detailText then return end
    selectedResult = result
    if itemLinkButton then itemLinkButton:SetShown(mode ~= "sources" and mode ~= "status" and result ~= nil and ns.WowheadURL("item", result.itemID) ~= nil) end
    if npcLinkButton then npcLinkButton:SetShown(mode ~= "sources" and mode ~= "status" and result ~= nil and ns.WowheadURL("npc", result.npcID) ~= nil) end
    if sourceLinkButton then sourceLinkButton:SetShown(mode == "sources" and ns.SourceURL() ~= nil) end
    if mapButton then mapButton:SetShown(mode ~= "sources" and mode ~= "status" and mode ~= "auction" and result ~= nil and type(result.mapID) == "number") end
    if waypointButton then waypointButton:SetShown(mode ~= "sources" and mode ~= "status" and mode ~= "auction" and result ~= nil and type(result.x) == "number" and type(result.y) == "number") end
    if ahScanButton then ahScanButton:SetShown(mode == "auction") end
    if mode == "auction" then
        setDetail("|cff62e454Auktionshaus|r\n\n" .. ns.AuctionStatus() ..
            "\n\nEin Scan ist nur bei geoeffnetem Auktionshaus moeglich und wird nur durch deinen Klick gestartet." ..
            "\n\nBlizzard begrenzt die Abfragen. Maximal 30000 Auktionen pro Scan; keine Hintergrund-Wiederholungen." ..
            "\n\nPreise sind Momentaufnahmen, keine garantierten Angebote.")
        return
    end
    if mode == "sources" then
        local refCount, observedCount = ns.GetCounts()
        local provider = (ns.reference and ns.reference.provider) or "Noch keine Quelle"
        local address = ns.SourceURL() or "kein Quellenlink vorhanden"
        setDetail("|cff62e454Quellen & Rechtliches|r\n\n" ..
            "Referenzdaten: " .. tostring(provider) .. "\n" ..
            "Quellenlink: " .. address .. "\n" ..
            "Quellenhinweis: " .. tostring(ns.reference.credit or "keiner") .. "\n" ..
            "Datenlizenz: " .. tostring(ns.reference.license or "nicht angegeben") .. "\n" ..
            "Lizenzlink: " .. tostring(ns.reference.licenseUrl or "-") .. "\n" ..
            "Datenstand: " .. tostring(ns.reference.dataAsOf or "unbekannt") .. "\n" ..
            "Referenzhaendler: " .. refCount .. "\n" ..
            "Lokal beobachtet: " .. observedCount .. "\n\n" ..
            "Lokale Waren/Preise stammen aus dem im Spiel geoeffneten Haendlerfenster. " ..
            "Referenzdaten sind gesondert gekennzeichnet.\n\n" ..
            "WoWHead dient nur als Nachschlagelink; Import erst nach Genehmigung.\n" ..
            "QuestieDB: optionale lesende API-Hinweise (" .. (ns.QuestieAvailable and ns.QuestieAvailable() and "aktiv" or "nicht aktiv") .. "); keine Datenkopie.\n" ..
            "Everloot: https://everloot.app - Spielerbeobachtungen CC BY-SA 4.0 (nur falls eingebunden).\n" ..
            "ForeverDB: https://foreverdb.net - API nur mit genehmigtem Zugang.\n\n" ..
            "WoW-Market-Code: GPL-3.0-only. Lizenztext: WoWMarket/LICENSE.txt\n" ..
            "Quellcode: https://github.com/CrobIT-Solution/WoW-Market\n\n" ..
            "WoW-Market ist ein inoffizielles, kostenloses Addon von CrobIT-Solution. " ..
            "Keine Verbindung zu Blizzard, WoWHead oder Datenanbietern. " ..
            "Keine automatischen Kaeufe, kein Datenversand aus dem Addon.")
        return
    end
    if mode == "status" then
        local reference, own, items = ns.GetCounts()
        local provider = ns.reference.provider or "keine"
        setDetail(string.format(
            "|cff62e454Datenstatus|r\n\n" ..
            "Referenzhaendler: %d\n" ..
            "Im Spiel beobachtet: %d\n" ..
            "Referenz-Warenpositionen: %d\n\n" ..
            "Quelle: %s\n\n" ..
            "Lokale Beobachtungen bleiben in SavedVariables und werden nicht vom Import ueberschrieben.",
            reference, own, items, provider))
        return
    end
    if not result then
        setDetail("|cff62e454Standort & Herkunft|r\n\n" ..
            "Waehle links einen Eintrag aus.\n\n" ..
            "Zurzeit werden Standorte als Karten-ID und Koordinaten angezeigt. " ..
            "Kartenmarker folgen in einer spaeteren Version.")
        return
    end
    local coords = "nicht bekannt"
    if type(result.x) == "number" and type(result.y) == "number" then
        coords = string.format("%.1f / %.1f", result.x, result.y)
    end
    local quantity = result.numAvailable
    local stock = "unbekannt"
    if quantity == -1 then stock = "unbegrenzt"
    elseif type(quantity) == "number" then stock = tostring(quantity) end
    local price = result.priceCopper and ns.Money(result.priceCopper) or "nicht bekannt"
    if result.hasExtendedCost then price = price .. " + Sonderkosten"
    elseif result.hasExtendedCost == nil then price = price .. " (Zusatzkosten ungeklaert)" end
    local batch = result.stackCount or "unbekannt"
    local auction = (result.itemID and ns.AuctionPrice) and ns.AuctionPrice(result.itemID) or nil
    local ahLine = ""
    if auction and auction.minUnitCopper then
        ahLine = "\nAH-Minimum/Stueck: " .. ns.Money(auction.minUnitCopper) .. " (Momentaufnahme)"
    end
    local questieNote = ""
    if result.questieNPC and result.questieNPC.zoneID then
        questieNote = "\nQuestieDB: moegliche Zone-ID " .. tostring(result.questieNPC.zoneID) .. " (kein Karten-ID-Nachweis)"
    end
    if result.questieNPC and result.questieNPC.spawnZoneID then
        questieNote = questieNote .. string.format("\nQuestieDB: moeglicher Spawn %.1f / %.1f (Zone-ID %d, unbestaetigt)",
            result.questieNPC.spawnX, result.questieNPC.spawnY, result.questieNPC.spawnZoneID)
    end
    if result.vendorFromQuestie then
        questieNote = questieNote .. "\nHaendlername: QuestieDB-Zusatzinformation"
    end
    if result.itemFromQuestie then
        questieNote = questieNote .. "\nGegenstandsname: QuestieDB-Zusatzinformation"
    end
    setDetail(string.format(
        "|cff62e454%s|r\n\n" ..
        "Gegenstand: %s\n\n" ..
        "Zone: %s\n" ..
        "Karten-ID: %s\n" ..
        "Koordinaten: %s\n\n" ..
        "Preis: %s\n" ..
        "Kaufmenge: %s\n" ..
        "Bestand: %s\n\n" ..
        "Datenstatus: %s%s%s",
        result.vendorName, result.itemName, result.zone,
        tostring(result.mapID or "?"), coords, price, tostring(batch), stock, result.status, ahLine, questieNote))
end

local function updateResults()
    if not main or not main:IsShown() then return end
    local total = 0
    if mode == "status" or mode == "sources" or mode == "auction" then
        visibleResults = {}
    elseif mode == "vendors" or mode == "map" then
        visibleResults, total = ns.Search("", 500)
    else
        visibleResults, total = ns.Search(currentQuery, 500)
    end
    local maxPage = math.max(1, math.ceil(#visibleResults / pageSize))
    page = math.min(page, maxPage)
    if mode == "sources" then
        titleText:SetText("Quellen und Hinweise")
    elseif mode == "auction" then
        titleText:SetText("Auktionshaus-Status")
    elseif mode == "map" then
        titleText:SetText("Haendlerstandorte")
    elseif mode == "status" then
        titleText:SetText("Datenbestand")
    elseif mode == "vendors" then
        titleText:SetText("Bekannte Haendler")
    else
        titleText:SetText("Suchergebnisse")
    end
    local adminMode = mode == "sources" or mode == "status" or mode == "auction"
    summaryText:SetText(adminMode and "Informationen" or
        (tostring(#visibleResults) .. " von " .. tostring(total) .. " Eintraegen" ..
         (total > #visibleResults and " (begrenzt)" or "")))
    pageLabel:SetText(page .. " / " .. maxPage)
    prevButton:SetEnabled(page > 1)
    nextButton:SetEnabled(page < maxPage)
    for i = 1, pageSize do
        local row = resultRows[i]
        local result = visibleResults[(page - 1) * pageSize + i]
        row.result = result
        if result and mode ~= "sources" and mode ~= "status" and mode ~= "auction" then
            row:Show()
            row.vendor:SetText(result.vendorName)
            row.item:SetText(result.itemName)
            local amount = result.priceCopper and ns.Money(result.priceCopper) or "-"
            if result.hasExtendedCost then amount = amount .. "*" end
            if result.stackCount and result.stackCount > 1 then
                amount = amount .. " /" .. result.stackCount
            end
            row.price:SetText(amount)
            local color = (result.status == "Im Spiel gesehen") and "|cff62e454" or
                ((result.status == "Forever bestaetigt") and "|cffffd46a" or "|cffb9b9b9")
            row.status:SetText(color .. result.status .. "|r")
        else
            row:Hide()
        end
    end
    showDetail((mode == "status" or mode == "sources" or mode == "auction") and nil or visibleResults[(page - 1) * pageSize + 1])
end
ns.RefreshUI = updateResults

local function executeSearch()
    currentQuery = searchInput:GetText() or ""
    mode = "search"
    page = 1
    updateResults()
end

function ns.ShowUI()
    if not main then return end
    main:Show()
    updateResults()
end

-- Regulare Bedienung per Minimap-Symbol; die alten Slash-Aliasse bleiben optional.
function ns.ToggleUI()
    if not main then return end
    if main:IsShown() then
        main:Hide()
    else
        ns.ShowUI()
    end
end

function ns.OpenSources()
    if not main then return end
    mode = "sources"
    page = 1
    ns.ShowUI()
end

function ns.InitUI()
    if main then return end
    local root = CreateFrame("Frame", "CrobITMarketWindow", UIParent, "BackdropTemplate")
    root:SetSize(1040, 624)
    root:SetPoint("CENTER")
    root:SetFrameStrata("DIALOG")
    root:SetClampedToScreen(true)
    root:EnableMouse(true)
    root:Hide()
    applyBackdrop(root)
    main = root

    -- Keine externe Browsersteuerung aus Lua; nur kopierbare HTTPS-Links.
    -- Deshalb nur ein sichtbares, markiertes EditBox-Feld zum manuellen Ctrl+C.
    local popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    popup:SetSize(700, 160)
    popup:SetPoint("CENTER")
    popup:SetFrameStrata("FULLSCREEN_DIALOG")
    popup:SetClampedToScreen(true)
    popup:EnableMouse(true)
    popup:Hide()
    applyBackdrop(popup, {0.035, 0.05, 0.04, 0.99})
    local hint = label(popup, "Link mit Strg+C kopieren und selbst im Browser oeffnen", "GameFontNormal", unpack(GREEN))
    hint:SetPoint("TOPLEFT", 20, -18)
    local urlEdit = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
    urlEdit:SetPoint("TOPLEFT", 26, -54)
    urlEdit:SetSize(640, 32)
    urlEdit:SetAutoFocus(false)
    urlEdit:SetMaxLetters(300)
    urlEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus(); popup:Hide() end)
    local done = button(popup, "Schliessen", 115, 28, function() popup:Hide() end)
    done:SetPoint("BOTTOMRIGHT", -22, 15)
    showURL = function(url)
        if type(url) ~= "string" or #url > 300 or not url:match("^https://") then return end
        urlEdit:SetText(url)
        popup:Show()
        urlEdit:SetFocus()
        urlEdit:HighlightText()
    end

    local header = CreateFrame("Frame", nil, root)
    header:SetPoint("TOPLEFT", 18, -10)
    header:SetPoint("TOPRIGHT", -18, -10)
    header:SetHeight(44)
    header:EnableMouse(true)
    root:SetMovable(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() root:StartMoving() end)
    header:SetScript("OnDragStop", function() root:StopMovingOrSizing() end)
    local heading = label(header, "WoW-Market", "GameFontNormalHuge", unpack(GREEN))
    heading:SetPoint("LEFT", 8, 0)
    local version = label(header, "Alpha 0.0.8", "GameFontHighlightSmall", unpack(WHITE))
    version:SetPoint("LEFT", heading, "RIGHT", 15, 0)
    local close = button(root, "X", 34, 28, function() root:Hide() end)
    close:SetPoint("TOPRIGHT", -16, -15)

    local sidebar = CreateFrame("Frame", nil, root, "BackdropTemplate")
    sidebar:SetPoint("TOPLEFT", 14, -65)
    sidebar:SetSize(158, 497)
    applyBackdrop(sidebar, {0.04, 0.05, 0.045, 0.98})
    local navData = {
        {"Suche", "search"}, {"Haendler", "vendors"},
        {"Auktionshaus", "auction"}, {"Karte", "map"},
        {"Datenstatus", "status"}, {"Quellen & Recht", "sources"},
    }
    for i, nav in ipairs(navData) do
        local tab = button(sidebar, nav[1], 138, 40, function()
            if nav[2] == "future" then return end
            mode = nav[2]
            page = 1
            updateResults()
        end)
        tab:SetPoint("TOPLEFT", 10, -12 - (i - 1) * 49)
        if nav[2] == "future" then
            tab:Disable()
            tab.text:SetTextColor(0.5, 0.5, 0.5)
        end
    end
    local logo = label(sidebar, "WoW-Market", "GameFontNormal", unpack(GREEN))
    logo:SetPoint("BOTTOM", 0, 45)
    local logo2 = label(sidebar, "WoW Forever", "GameFontHighlightSmall", unpack(WHITE))
    logo2:SetPoint("BOTTOM", 0, 22)

    local searchLabel = label(root, "Gegenstand / NPC / Item-ID", "GameFontHighlightSmall", unpack(WHITE))
    searchLabel:SetPoint("TOPLEFT", 192, -68)
    searchInput = CreateFrame("EditBox", nil, root, "InputBoxTemplate")
    searchInput:SetPoint("TOPLEFT", 198, -94)
    searchInput:SetSize(426, 30)
    searchInput:SetAutoFocus(false)
    searchInput:SetMaxLetters(120)
    searchInput:SetScript("OnEnterPressed", function(self) self:ClearFocus(); executeSearch() end)
    searchInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    local searchBtn = button(root, "Suchen", 100, 31, executeSearch)
    searchBtn:SetPoint("TOPLEFT", 634, -94)

    local center = CreateFrame("Frame", nil, root, "BackdropTemplate")
    center:SetPoint("TOPLEFT", 184, -139)
    center:SetSize(560, 422)
    applyBackdrop(center, {0.065, 0.07, 0.057, 0.97})
    titleText = label(center, "Suchergebnisse", "GameFontNormalLarge", unpack(GREEN))
    titleText:SetPoint("TOPLEFT", 15, -14)
    summaryText = label(center, "0 Eintraege", "GameFontHighlightSmall", unpack(WHITE))
    summaryText:SetPoint("TOPRIGHT", -15, -17)

    local cols = label(center, "Haendler / Ware", "GameFontNormal")
    cols:SetPoint("TOPLEFT", 18, -49)
    local priceLabel = label(center, "Preis", "GameFontNormal")
    priceLabel:SetPoint("TOPRIGHT", -128, -49)
    for i = 1, pageSize do
        local row = CreateFrame("Button", nil, center, "BackdropTemplate")
        row:SetSize(528, 35)
        row:SetPoint("TOPLEFT", 16, -65 - (i - 1) * 37)
        applyBackdrop(row, {0.11, 0.11, 0.085, 0.93})
        row:SetScript("OnClick", function(self) showDetail(self.result) end)
        row:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(GREEN)) end)
        row:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(0.24, 0.46, 0.20, 0.85) end)
        row.vendor = label(row, "", "GameFontNormalSmall")
        row.vendor:SetPoint("TOPLEFT", 10, -4)
        row.vendor:SetWidth(232)
        row.item = label(row, "", "GameFontHighlightSmall")
        row.item:SetPoint("BOTTOMLEFT", 10, 4)
        row.item:SetWidth(232)
        row.price = label(row, "", "GameFontNormalSmall")
        row.price:SetPoint("TOPLEFT", 245, -5)
        row.price:SetWidth(135)
        row.status = label(row, "", "GameFontHighlightSmall")
        row.status:SetPoint("TOPRIGHT", -8, -6)
        row.status:SetWidth(130)
        row.status:SetJustifyH("RIGHT")
        row:Hide()
        resultRows[i] = row
    end
    prevButton = button(center, "<", 40, 25, function() page = page - 1; updateResults() end)
    prevButton:SetPoint("BOTTOMLEFT", 17, 10)
    pageLabel = label(center, "1 / 1", "GameFontHighlightSmall")
    pageLabel:SetPoint("BOTTOM", 0, 17)
    nextButton = button(center, ">", 40, 25, function() page = page + 1; updateResults() end)
    nextButton:SetPoint("BOTTOMRIGHT", -17, 10)

    local right = CreateFrame("Frame", nil, root, "BackdropTemplate")
    right:SetPoint("TOPLEFT", 755, -65)
    right:SetSize(270, 496)
    applyBackdrop(right, {0.07, 0.07, 0.052, 0.97})
    -- Sources and licensing text must be scrollable on smaller screens.
    detailScroll = CreateFrame("ScrollFrame", nil, right)
    detailScroll:SetPoint("TOPLEFT", 14, -16)
    detailScroll:SetSize(244, 310)
    detailScroll:EnableMouseWheel(true)
    detailScrollContent = CreateFrame("Frame", nil, detailScroll)
    detailScrollContent:SetSize(230, 310)
    detailScroll:SetScrollChild(detailScrollContent)
    detailText = label(detailScrollContent, "", "GameFontHighlight")
    detailText:SetPoint("TOPLEFT", 0, 0)
    detailText:SetWidth(226)
    detailText:SetJustifyH("LEFT")
    detailText:SetJustifyV("TOP")
    detailScroll:SetScript("OnMouseWheel", function(self, delta)
        local maximum = math.max(0, detailScrollContent:GetHeight() - self:GetHeight())
        local y = self:GetVerticalScroll() - delta * 45
        self:SetVerticalScroll(math.max(0, math.min(maximum, y)))
    end)
    -- Nur fuer Treffer mit tatsaechlicher ID. Leer/fehlende IDs: Button ausblenden.
    itemLinkButton = button(right, "WoWHead: Gegenstand", 231, 29, function()
        if selectedResult then showURL(ns.WowheadURL("item", selectedResult.itemID)) end
    end)
    itemLinkButton:SetPoint("BOTTOMLEFT", 18, 60)
    itemLinkButton:Hide()
    npcLinkButton = button(right, "WoWHead: Haendler", 231, 29, function()
        if selectedResult then showURL(ns.WowheadURL("npc", selectedResult.npcID)) end
    end)
    npcLinkButton:SetPoint("BOTTOMLEFT", 18, 24)
    npcLinkButton:Hide()
    mapButton = button(right, "Zone auf Weltkarte", 231, 29, function()
        if selectedResult then ns.ShowVendorMap(selectedResult) end
    end)
    mapButton:SetPoint("BOTTOMLEFT", 18, 138)
    mapButton:Hide()
    waypointButton = button(right, "Wegpunkt setzen", 231, 29, function()
        if selectedResult then ns.SetVendorWaypoint(selectedResult) end
    end)
    waypointButton:SetPoint("BOTTOMLEFT", 18, 101)
    waypointButton:Hide()
    ahScanButton = button(right, "AH-Scan manuell starten", 231, 29, function()
        ns.StartAuctionScan()
        showDetail(nil)
    end)
    ahScanButton:SetPoint("BOTTOMLEFT", 18, 24)
    ahScanButton:Hide()
    sourceLinkButton = button(right, "Quellenlink anzeigen", 231, 29, function()
        showURL(ns.SourceURL())
    end)
    sourceLinkButton:SetPoint("BOTTOMLEFT", 18, 24)
    sourceLinkButton:Hide()

    local footer = CreateFrame("Frame", nil, root, "BackdropTemplate")
    footer:SetPoint("BOTTOMLEFT", 14, 13)
    footer:SetSize(1011, 39)
    applyBackdrop(footer, {0.07, 0.09, 0.06, 0.96})
    footerText = label(footer, "", "GameFontHighlightSmall", unpack(WHITE))
    footerText:SetPoint("LEFT", 13, 0)
    footerText:SetWidth(976)
    local provider = ns.reference.provider or "Keine Referenzdaten"
    local attribution = ns.SourceURL()
    footerText:SetText("Referenz: " .. provider ..
        (attribution and (" - " .. attribution) or "") ..
        "  |  Ingame-Beobachtung: beim Haendlerbesuch")
    root:SetScript("OnShow", updateResults)
end
