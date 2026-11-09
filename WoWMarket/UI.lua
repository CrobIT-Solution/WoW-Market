-- SPDX-License-Identifier: GPL-3.0-only
local _, ns = ...
local main, searchInput, titleText, summaryText, footerText, detailText
local resultRows = {}
local visibleResults = {}
local page = 1
local pageSize = 6
local mode = "search"
local currentQuery = ""
local pageLabel, prevButton, nextButton
local itemLinkButton, npcLinkButton, sourceLinkButton, mapButton, waypointButton, ahScanButton, targetedAHButton
local selectedResult, showURL
local detailScroll, detailScrollContent
local navButtons = {}
local previewIcon, previewTitle, previewSubtitle, previewStatus
local previewVendorPrice, previewAHPrice, previewDifference, emptyHint
local mapPreview, mapTiles, mapPin, mapNote
local displayPreview
local searchNotice, lookupOnly = "", nil
local function cacheItemByQuery(query)
    if type(query) ~= "string" or query == "" then return nil end
    local id = tonumber(query)
    if id and (id < 1 or id > 2147483647 or id ~= math.floor(id)) then return nil end
    local getInfo = (C_Item and C_Item.GetItemInfo) or GetItemInfo
    if type(getInfo) ~= "function" then return nil end
    local ok, name, link = pcall(getInfo, id or query)
    if not ok or type(name) ~= "string" or name == "" then return nil end
    if not id and type(link) == "string" then
        id = tonumber(link:match("item:(%d+)"))
    end
    if not id then return nil end
    return {itemID=id, itemName=name, vendorName="Kein Haendlernachweis",
        zone="Unbekannt", status="Clientcache (keine Haendlerdaten)",
        hasExtendedCost=nil, stackCount=nil}
end

local GREEN = {0.49, 0.94, 0.20}
local GOLD = {0.94, 0.77, 0.41}
local WHITE = {0.95, 0.88, 0.73}
local MUTED = {0.69, 0.62, 0.49}
local BRONZE = {0.65, 0.43, 0.21}

-- Original fantasy skin built with WoW's own UI textures. No unlicensed art
-- or pre-rendered screenshot is included in this addon.
local function applyBackdrop(frame, color)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 24,
        insets = {left = 7, right = 7, top = 7, bottom = 7},
    })
    frame:SetBackdropColor(unpack(color or {0.075, 0.059, 0.043, 0.98}))
    frame:SetBackdropBorderColor(0.71, 0.50, 0.24, 0.97)
end

local function rule(parent, anchor, x, y, width, r, g, b)
    local texture = parent:CreateTexture(nil, "ARTWORK")
    texture:SetTexture("Interface\\Buttons\\WHITE8X8")
    texture:SetVertexColor(r or 0.57, g or 0.42, b or 0.19, 0.75)
    texture:SetSize(width, 2)
    texture:SetPoint(anchor, parent, anchor, x, y)
    return texture
end

local function safeItemIcon(itemID)
    if type(itemID) == "number" and itemID > 0 then
        if C_Item and type(C_Item.GetItemIconByID) == "function" then
            local ok, icon = pcall(C_Item.GetItemIconByID, itemID)
            if ok and icon then return icon end
        end
        if type(GetItemIcon) == "function" then
            local ok, icon = pcall(GetItemIcon, itemID)
            if ok and icon then return icon end
        end
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
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
    b:EnableMouse(true)
    b:RegisterForClicks("LeftButtonUp")
    applyBackdrop(b, {0.14, 0.098, 0.055, 0.98})
    local font = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    font:SetPoint("CENTER", b, "CENTER", 0, 0)
    font:SetText(caption)
    font:SetTextColor(unpack(GOLD))
    b.text = font
    b:SetScript("OnClick", action)
    b:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(GREEN))
        if not self.active then self:SetBackdropColor(0.20, 0.16, 0.07, 1) end
    end)
    b:SetScript("OnLeave", function(self)
        if not self.active then
            self:SetBackdropBorderColor(unpack(BRONZE))
            self:SetBackdropColor(0.14, 0.098, 0.055, 0.98)
        end
    end)
    return b
end

local function navButton(parent, caption, iconPath, modeName, y)
    local b = button(parent, caption, 172, 51, function()
        mode = modeName
        page = 1
        if ns.RefreshUI then ns.RefreshUI() end
    end)
    b:SetPoint("TOPLEFT", 9, y)
    b.text:ClearAllPoints()
    b.text:SetPoint("LEFT", b, "LEFT", 45, 0)
    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(iconPath)
    icon:SetSize(26, 26)
    icon:SetPoint("LEFT", b, "LEFT", 13, 0)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    navButtons[modeName] = b
    return b
end

local function updateNavigation()
    for key, tab in pairs(navButtons) do
        tab.active = (key == mode)
        if tab.active then
            tab:SetBackdropColor(0.15, 0.23, 0.055, 0.98)
            tab:SetBackdropBorderColor(unpack(GREEN))
            tab.text:SetTextColor(unpack(GREEN))
        else
            tab:SetBackdropColor(0.14, 0.098, 0.055, 0.98)
            tab:SetBackdropBorderColor(unpack(BRONZE))
            tab.text:SetTextColor(unpack(GOLD))
        end
    end
end

local function setDetail(value)
    detailText:SetText(value)
    if detailScroll and detailScrollContent then
        local required = (detailText.GetStringHeight and detailText:GetStringHeight() or 300) + 30
        detailScrollContent:SetHeight(math.max(304, required))
        detailScroll:SetVerticalScroll(0)
    end
end

-- The prominent item card uses only actual local observations or manual AH
-- snapshots. Unknown prices, vendor positions and savings are never invented.
displayPreview = function(result)
    if not previewTitle then return end
    previewIcon:SetTexture(safeItemIcon(result and result.itemID))
    if mode == "sources" then
        previewTitle:SetText("Quellen und Rechte")
        previewSubtitle:SetText("GPL-3.0-only  |  Freies Community-Addon")
    elseif mode == "auction" then
        previewTitle:SetText("Auktionshaus - Momentaufnahme")
        previewSubtitle:SetText("Nur auf ausdruecklichen Klick; kein automatischer Handel")
    elseif mode == "status" then
        previewTitle:SetText("Datenbestand")
        previewSubtitle:SetText("Eigene Beobachtungen und erlaubte Referenzdaten")
    elseif not result then
        if mode == "search" and currentQuery ~= "" then
            previewTitle:SetText("Suche: " .. currentQuery)
            previewSubtitle:SetText("Keine passenden bekannten Haendler oder Waren")
        else
            previewTitle:SetText("WoW-Market – Haendlerkatalog")
            previewSubtitle:SetText("Haendler besuchen, um den lokalen Katalog aufzubauen")
        end
    elseif result.itemID then
        previewTitle:SetText(result.itemName or "Unbekannter Gegenstand")
        previewSubtitle:SetText((result.vendorName or "Haendler unbekannt") .. "  |  " ..
            (result.zone or "Standort unbekannt"))
    else
        previewTitle:SetText(result.vendorName or "Unbekannter Haendler")
        previewSubtitle:SetText(result.zone or "Standort unbekannt")
    end
    previewStatus:SetText(result and result.status or (mode == "search" and searchNotice ~= "" and searchNotice
        or "Noch keine externen Referenzdaten"))
    local price, unit, auction = nil, nil, nil
    if result and result.itemID then
        price = result.priceCopper
        if result.hasExtendedCost == false and type(price) == "number" and
           type(result.stackCount) == "number" and result.stackCount >= 1 then
            unit = price / result.stackCount
        end
        if ns.AuctionPrice then auction = ns.AuctionPrice(result.itemID) end
    end
    previewVendorPrice:SetText(type(price) == "number" and ns.Money(price) or "Unbekannt")
    local auctionUnit = auction and auction.minUnitCopper
    previewAHPrice:SetText(type(auctionUnit) == "number" and ns.Money(auctionUnit) or "Keine Daten")
    if unit and type(auctionUnit) == "number" then
        local delta = auctionUnit - unit
        local sign = delta > 0 and "+" or ""
        previewDifference:SetText(sign .. ns.Money(math.abs(delta)))
        if delta >= 0 then
            previewDifference:SetTextColor(unpack(GREEN))
        else
            previewDifference:SetTextColor(1, 0.38, 0.28)
        end
        -- Negative differences must remain visible as negative; no false profit promise.
        if delta < 0 then previewDifference:SetText("-" .. ns.Money(math.abs(delta))) end
    else
        previewDifference:SetText("Nicht verfuegbar")
        previewDifference:SetTextColor(unpack(MUTED))
    end
end

-- Real WoW map artwork is displayed only for a known client map ID.
-- Never use a synthetic map image as evidence of a merchant location.
local function updateMapPreview(result)
    if not mapPreview then return end
    if mode ~= "map" then
        mapPreview:Hide()
        if detailScroll then detailScroll:Show() end
        return
    end
    mapPreview:Show()
    if detailScroll then detailScroll:Hide() end
    for _,texture in ipairs(mapTiles) do texture:Hide() end
    mapPin:Hide()
    if not result or type(result.mapID) ~= "number" then
        mapNote:SetText("Kein belegter Kartenstandort ausgewaehlt")
        return
    end
    local zone = result.zone or "Unbekannte Zone"
    local layers, art
    if C_Map and type(C_Map.GetMapArtLayers) == "function" and
       type(C_Map.GetMapArtLayerTextures) == "function" then
        local ok, value = pcall(C_Map.GetMapArtLayers, result.mapID)
        if ok and type(value)=="table" then layers=value end
        if layers and type(layers[1]) == "table" then
            local ok2, values = pcall(C_Map.GetMapArtLayerTextures, result.mapID, 1)
            if ok2 and type(values)=="table" then art=values end
        end
    end
    local layer=layers and layers[1]
    if layer and art and type(layer.layerWidth)=="number" and layer.layerWidth>0 and
       type(layer.layerHeight)=="number" and layer.layerHeight>0 and
       type(layer.tileWidth)=="number" and layer.tileWidth>0 and
       type(layer.tileHeight)=="number" and layer.tileHeight>0 then
        local cols=math.ceil(layer.layerWidth/layer.tileWidth)
        local rows=math.ceil(layer.layerHeight/layer.tileHeight)
        local tiles=math.min(cols*rows, #mapTiles)
        if cols*rows <= #mapTiles and #art >= tiles then
            for n=1,tiles do
                local tx=(n-1)%cols
                local ty=math.floor((n-1)/cols)
                local rawW=math.min(layer.tileWidth, layer.layerWidth-tx*layer.tileWidth)
                local rawH=math.min(layer.tileHeight,layer.layerHeight-ty*layer.tileHeight)
                local tile=mapTiles[n]
                tile:SetTexture(art[n])
                tile:ClearAllPoints()
                tile:SetPoint("TOPLEFT",mapPreview,"TOPLEFT",6+(tx*layer.tileWidth/layer.layerWidth)*234,
                    -7-(ty*layer.tileHeight/layer.layerHeight)*205)
                tile:SetSize((rawW/layer.layerWidth)*234,(rawH/layer.layerHeight)*205)
                tile:SetTexCoord(0,rawW/layer.tileWidth,0,rawH/layer.tileHeight)
                tile:Show()
            end
        end
    end
    if type(result.x)=="number" and type(result.y)=="number" and
       result.x>=0 and result.x<=100 and result.y>=0 and result.y<=100 then
        mapPin:ClearAllPoints()
        mapPin:SetPoint("CENTER",mapPreview,"TOPLEFT",6+result.x/100*234,-7-result.y/100*205)
        mapPin:Show()
        mapNote:SetText(zone .. string.format("  |  %.1f / %.1f",result.x,result.y))
    else
        mapNote:SetText(zone .. " | Koordinaten unbekannt")
    end
end

local function showDetail(result)
    if not detailText then return end
    selectedResult = result
    displayPreview(result)
    updateMapPreview(result)
    for _, row in ipairs(resultRows) do
        if row.result and row.result == result then
            row:SetBackdropBorderColor(unpack(GREEN))
        else
            row:SetBackdropBorderColor(unpack(BRONZE))
        end
    end
    if itemLinkButton then itemLinkButton:SetShown(mode ~= "sources" and mode ~= "status" and result ~= nil and ns.WowheadURL("item", result.itemID) ~= nil) end
    if npcLinkButton then npcLinkButton:SetShown(mode ~= "sources" and mode ~= "status" and result ~= nil and ns.WowheadURL("npc", result.npcID) ~= nil) end
    if sourceLinkButton then sourceLinkButton:SetShown(mode == "sources" and ns.SourceURL() ~= nil) end
    if mapButton then mapButton:SetShown(mode ~= "sources" and mode ~= "status" and mode ~= "auction" and result ~= nil and type(result.mapID) == "number") end
    if waypointButton then waypointButton:SetShown(mode ~= "sources" and mode ~= "status" and mode ~= "auction" and result ~= nil and type(result.x) == "number" and type(result.y) == "number") end
    if ahScanButton then ahScanButton:SetShown(mode == "auction") end
    if targetedAHButton then
        targetedAHButton:SetShown(mode ~= "auction" and mode ~= "status" and mode ~= "sources" and mode ~= "map"
            and result ~= nil and type(result.itemID) == "number")
    end
    if mode == "auction" then
        setDetail("|cffffd47cAuktionshaus|r\n\n" .. ns.AuctionStatus() ..
            "\n\nEin Scan ist nur bei geoeffnetem Auktionshaus moeglich und wird nur durch deinen Klick gestartet." ..
            "\n\nBlizzard erlaubt einen erfolgreichen Vollscan nur ca. alle 15 Minuten." ..
            " Fehlerhafte Anfragen sperren nicht mehr fuer 15 Minuten; kein automatischer Neuversuch." ..
            " Einzelpreise kannst du mit einer bekannten Item-ID gezielt abfragen, ohne Vollscan." ..
            " Groessere Datenmengen werden schonend verarbeitet, unvollstaendige Ergebnisse klar markiert." ..
            "\n\nPreise sind Momentaufnahmen, keine garantierten Angebote.")
        return
    end
    if mode == "sources" then
        local refCount, observedCount = ns.GetCounts()
        local provider = (ns.reference and ns.reference.provider) or "Noch keine Quelle"
        local address = ns.SourceURL() or "kein Quellenlink vorhanden"
        setDetail("|cffffd47cQuellen & Rechtliches|r\n\n" ..
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
            "|cffffd47cDatenstatus|r\n\n" ..
            "Referenzhaendler: %d\n" ..
            "Im Spiel beobachtet: %d\n" ..
            "Referenz-Warenpositionen: %d\n\n" ..
            "Quelle: %s\n\n" ..
            "Lokale Beobachtungen bleiben in SavedVariables und werden nicht vom Import ueberschrieben.",
            reference, own, items, provider))
        return
    end
    if not result then
        local vendorStatus = ns.VendorCaptureStatus and ns.VendorCaptureStatus() or "Noch keine lokalen Haendlerdaten."
        setDetail("|cffffd47cStandort und Herkunft|r\n\n" ..
            (mode == "search" and currentQuery ~= "" and ("Suchbegriff: " .. currentQuery .. "\n\n") or "") ..
            "Eigene Haendler: " .. vendorStatus .. "\n\n" ..
            "Die Suche nutzt lokale Haendlerbesuche und genehmigte Referenzdaten. " ..
            "Die Referenzdatenbank ist derzeit leer.\n\n" ..
            "Bitte einen NPC-Haendler im Spiel oeffnen. Dann nochmals suchen.\n\n" ..
            "Kartenpunkte werden nur aus bekannten Koordinaten erzeugt.")
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
        ahLine = "\nAH-Minimum/Stueck: " .. ns.Money(auction.minUnitCopper) ..
            (auction.source == "Einzelabfrage" and " (gezielte Einzelabfrage)" or " (Vollscan-Momentaufnahme)")
    end
    local questieNote = ""
    if result.questieNPC and result.questieNPC.zoneID then
        questieNote = "\nQuestieDB: moegliche Zone-ID " .. tostring(result.questieNPC.zoneID) .. " (kein Karten-ID-Nachweis)"
    end
    if result.questieNPC and result.questieNPC.spawnZoneID then
        questieNote = questieNote .. string.format("\nQuestieDB: moeglicher Spawn %.1f / %.1f (Zone-ID %d, unbestaetigt)",
            result.questieNPC.spawnX, result.questieNPC.spawnY, result.questieNPC.spawnZoneID)
    end
    if result.status == "Clientcache (keine Haendlerdaten)" then
        questieNote = questieNote .. "\nNur Gegenstand aus dem Clientcache; kein Haendlerstandort oder Haendlerpreis bekannt."
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
    updateNavigation()
    local total = 0
    lookupOnly = nil
    if mode == "status" or mode == "sources" or mode == "auction" then
        visibleResults = {}
    elseif mode == "vendors" or mode == "map" then
        visibleResults, total = ns.Search("", 500)
    else
        visibleResults, total = ns.Search(currentQuery, 500)
        if #visibleResults == 0 and currentQuery ~= "" then
            -- A cached item is not a vendor record. Show it separately and truthfully.
            lookupOnly = cacheItemByQuery(currentQuery)
            if lookupOnly then
                visibleResults = {lookupOnly}
                total = 1
                searchNotice = "Nur lokale Iteminfo – kein Haendlernachweis"
            end
        end
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
        (lookupOnly and "1 Item im lokalen Cache – kein Haendler" or
        (tostring(#visibleResults) .. " von " .. tostring(total) .. " Eintraegen" ..
         (total > #visibleResults and " (begrenzt)" or ""))))
    pageLabel:SetText(page .. " / " .. maxPage)
    if emptyHint then
        emptyHint:SetShown(#visibleResults == 0)
        if mode == "auction" then
            emptyHint:SetText("Auktionshaus: Informationen und Scan rechts")
        elseif mode == "sources" then
            emptyHint:SetText("Quellen und Lizenzhinweise rechts lesen")
        elseif mode == "status" then
            emptyHint:SetText("Datenstatus und Herkunft rechts lesen")
        elseif mode == "search" and currentQuery ~= "" then
            local _, own = ns.GetCounts()
            emptyHint:SetText("Keine Treffer fuer '" .. currentQuery .. "'.\n\n" ..
                "Durchsucht: " .. tostring(own) .. " lokal erfasste Haendler.\n" ..
                "Es gibt noch keine allgemeine Item-Datenbank.\n" ..
                "Oeffne einen Haendler und versuche es erneut.")
        else
            emptyHint:SetText("Noch keine Haendler gefunden.\n\nOeffne einen NPC-Haendler im Spiel,\num seine Waren automatisch lokal zu erfassen.")
        end
    end
    prevButton:SetEnabled(page > 1)
    nextButton:SetEnabled(page < maxPage)
    for i = 1, pageSize do
        local row = resultRows[i]
        local result = visibleResults[(page - 1) * pageSize + i]
        row.result = result
        if result and mode ~= "sources" and mode ~= "status" and mode ~= "auction" then
            row:Show()
            row.vendor:SetText(result.vendorName)
            row.item:SetText(result.itemName or "")
            row.zone:SetText(result.zone or "?")
            if type(result.x) == "number" and type(result.y) == "number" then
                row.coord:SetText(string.format("%.1f, %.1f", result.x, result.y))
            else row.coord:SetText("-") end
            local amount = result.priceCopper and ns.Money(result.priceCopper) or "-"
            if result.hasExtendedCost then amount = amount .. "*" end
            if result.stackCount and result.stackCount > 1 then
                amount = amount .. " /" .. result.stackCount
            end
            row.price:SetText(amount)
            local color = (result.status == "Im Spiel gesehen") and "|cff62e454" or
                ((result.status == "Forever bestaetigt") and "|cffffd46a" or "|cffb9b9b9")
            local statusShort = result.status == "Im Spiel gesehen" and "Erfasst"
                or result.status == "Forever bestaetigt" and "Bestaetigt"
                or result.status == "Clientcache (keine Haendlerdaten)" and "Cache"
                or "Referenz"
            row.status:SetText(color .. statusShort .. "|r")
        else
            row:Hide()
        end
    end
    if mode == "search" and currentQuery ~= "" and #visibleResults == 0 then
        searchNotice = "Kein Treffer fuer '" .. currentQuery .. "'"
    end
    local chosen
    if selectedResult and mode ~= "sources" and mode ~= "status" and mode ~= "auction" then
        for i = (page - 1) * pageSize + 1, math.min(page * pageSize, #visibleResults) do
            local candidate = visibleResults[i]
            if candidate and candidate.itemID == selectedResult.itemID and
               candidate.npcID == selectedResult.npcID and
               candidate.vendorName == selectedResult.vendorName then
                chosen = candidate
                break
            end
        end
    end
    showDetail((mode == "status" or mode == "sources" or mode == "auction")
        and nil or (chosen or visibleResults[(page - 1) * pageSize + 1]))
end
ns.RefreshUI = updateResults

local function executeSearch()
    currentQuery = (searchInput:GetText() or ""):match("^%s*(.-)%s*$") or ""
    searchNotice = currentQuery ~= "" and ("Suche nach '" .. currentQuery .. "'") or ""
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
    root:SetSize(1120, 690)
    root:SetPoint("CENTER")
    root:SetFrameStrata("DIALOG")
    root:SetClampedToScreen(true)
    root:EnableMouse(true)
    root:Hide()
    applyBackdrop(root, {0.07, 0.048, 0.033, 0.99})
    -- Keep the complete window on smaller UI scales without hard-coded monitor size.
    if UIParent and UIParent.GetWidth and UIParent.GetHeight then
        local width, height = UIParent:GetWidth(), UIParent:GetHeight()
        if type(width) == "number" and type(height) == "number" and width > 0 and height > 0 then
            root:SetScale(math.min(1, (width - 45) / 1120, (height - 45) / 690))
        end
    end
    main = root
    -- WoW closes named special frames with Escape. Register exactly once.
    if type(UISpecialFrames) == "table" then
        local registered = false
        for _, name in ipairs(UISpecialFrames) do
            if name == "CrobITMarketWindow" then registered = true; break end
        end
        if not registered then table.insert(UISpecialFrames, "CrobITMarketWindow") end
    end

    -- Copyable links only; no programmatic website requests.
    local popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    popup:SetSize(700, 160)
    popup:SetPoint("CENTER")
    popup:SetFrameStrata("FULLSCREEN_DIALOG")
    popup:SetClampedToScreen(true)
    popup:EnableMouse(true)
    popup:Hide()
    applyBackdrop(popup, {0.09, 0.07, 0.045, 0.99})
    local hint = label(popup, "Link kopieren (Strg+C), dann im Browser oeffnen", "GameFontNormal", unpack(GOLD))
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

    local header = CreateFrame("Frame", nil, root, "BackdropTemplate")
    header:SetPoint("TOPLEFT", 17, -13)
    header:SetSize(1086, 58)
    applyBackdrop(header, {0.10, 0.076, 0.048, 0.98})
    header:EnableMouse(true)
    root:SetMovable(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() root:StartMoving() end)
    header:SetScript("OnDragStop", function() root:StopMovingOrSizing() end)
    local gem = header:CreateTexture(nil, "ARTWORK")
    gem:SetTexture("Interface\\Icons\\INV_Misc_Gem_Emerald_01")
    gem:SetSize(34, 34)
    gem:SetPoint("LEFT", 23, 0)
    local heading = label(header, "WoW-Market", "GameFontNormalHuge", unpack(GREEN))
    heading:SetPoint("LEFT", 70, 4)
    local tagline = label(header, "Haendler  |  Gegenstaende  |  Auktionshaus", "GameFontHighlightSmall", unpack(GOLD))
    tagline:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -3)
    local version = label(header, "ALPHA 0.0.10", "GameFontHighlightSmall", unpack(MUTED))
    version:SetPoint("RIGHT", -70, 0)
    -- Parent X to the draggable header: it must receive mouse clicks above
    -- the header's mouse-capturing surface.
    local close = button(header, "X", 34, 32, function() root:Hide() end)
    close:SetPoint("TOPRIGHT", root, "TOPRIGHT", -28, -26)
    local headerLevel = header:GetFrameLevel()
    close:SetFrameLevel((type(headerLevel) == "number" and headerLevel or 1) + 8)
    rule(root, "TOPLEFT", 32, -76, 1056, unpack(BRONZE))

    local sidebar = CreateFrame("Frame", nil, root, "BackdropTemplate")
    sidebar:SetPoint("TOPLEFT", 14, -86)
    sidebar:SetSize(192, 539)
    applyBackdrop(sidebar, {0.055, 0.044, 0.035, 0.99})
    navButton(sidebar, "Suche", "Interface\\Icons\\INV_Misc_Spyglass_02", "search", -13)
    navButton(sidebar, "Haendler", "Interface\\Icons\\INV_Misc_Coin_02", "vendors", -70)
    navButton(sidebar, "Auktionshaus", "Interface\\Icons\\INV_Hammer_15", "auction", -127)
    navButton(sidebar, "Karte", "Interface\\Icons\\INV_Misc_Map_01", "map", -184)
    navButton(sidebar, "Datenstatus", "Interface\\Icons\\INV_Misc_Coin_05", "status", -241)
    navButton(sidebar, "Quellen & Recht", "Interface\\Icons\\INV_Misc_Note_01", "sources", -298)
    rule(sidebar, "BOTTOMLEFT", 17, 96, 155, unpack(BRONZE))
    local guildMark = sidebar:CreateTexture(nil, "ARTWORK")
    guildMark:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
    guildMark:SetSize(42, 42)
    guildMark:SetPoint("BOTTOM", sidebar, "BOTTOM", 0, 37)
    local guildTitle = label(sidebar, "WoW Forever", "GameFontHighlightSmall", unpack(GOLD))
    guildTitle:SetPoint("BOTTOM", 0, 19)

    local searchLabel = label(root, "GEGENSTAND / NPC / ITEM-ID", "GameFontHighlightSmall", unpack(GOLD))
    searchLabel:SetPoint("TOPLEFT", 228, -89)
    local searchBar = CreateFrame("Frame", nil, root, "BackdropTemplate")
    searchBar:SetSize(470, 38)
    searchBar:SetPoint("TOPLEFT", 224, -111)
    applyBackdrop(searchBar, {0.085, 0.083, 0.052, 0.99})
    searchBar:SetBackdropBorderColor(0.43, 0.73, 0.15, 1)
    local loupe = searchBar:CreateTexture(nil, "ARTWORK")
    loupe:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_02")
    loupe:SetSize(21, 21)
    loupe:SetPoint("LEFT", 13, 0)
    searchInput = CreateFrame("EditBox", nil, searchBar, "InputBoxTemplate")
    searchInput:SetPoint("LEFT", 43, 0)
    searchInput:SetSize(410, 29)
    searchInput:SetAutoFocus(false)
    searchInput:SetMaxLetters(120)
    searchInput:SetScript("OnEnterPressed", function(self) self:ClearFocus(); executeSearch() end)
    searchInput:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        root:Hide()
    end)
    local searchBtn = button(root, "Suchen", 106, 38, executeSearch)
    searchBtn:SetPoint("TOPLEFT", 703, -111)

    local center = CreateFrame("Frame", nil, root, "BackdropTemplate")
    center:SetPoint("TOPLEFT", 215, -161)
    center:SetSize(598, 464)
    applyBackdrop(center, {0.105, 0.077, 0.052, 0.98})
    local card = CreateFrame("Frame", nil, center, "BackdropTemplate")
    card:SetPoint("TOPLEFT", 11, -11)
    card:SetSize(576, 142)
    applyBackdrop(card, {0.16, 0.11, 0.065, 0.98})
    previewIcon = card:CreateTexture(nil, "ARTWORK")
    previewIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    previewIcon:SetSize(55, 55)
    previewIcon:SetPoint("TOPLEFT", 17, -16)
    local iconBorder = card:CreateTexture(nil, "OVERLAY")
    iconBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    iconBorder:SetBlendMode("ADD")
    iconBorder:SetVertexColor(0.50, 0.90, 0.19, 0.80)
    iconBorder:SetSize(78, 78)
    iconBorder:SetPoint("CENTER", previewIcon, "CENTER")
    previewTitle = label(card, "Willkommen bei WoW-Market", "GameFontNormalLarge", unpack(GOLD))
    previewTitle:SetPoint("TOPLEFT", 87, -15)
    previewTitle:SetWidth(459)
    previewSubtitle = label(card, "Haendler besuchen oder suchen", "GameFontHighlightSmall", unpack(WHITE))
    previewSubtitle:SetPoint("TOPLEFT", 88, -44)
    previewSubtitle:SetWidth(456)
    previewStatus = label(card, "Keine importierten Referenzdaten", "GameFontHighlightSmall", unpack(MUTED))
    previewStatus:SetPoint("TOPLEFT", 88, -62)
    previewStatus:SetWidth(454)

    local function priceTile(x, caption)
        local tile = CreateFrame("Frame", nil, card, "BackdropTemplate")
        tile:SetSize(178, 49)
        tile:SetPoint("BOTTOMLEFT", x, 9)
        applyBackdrop(tile, {0.09, 0.075, 0.048, 0.96})
        local head = label(tile, caption, "GameFontHighlightSmall", unpack(GOLD))
        head:SetPoint("TOP", tile, "TOP", 0, -8)
        local value = label(tile, "Keine Daten", "GameFontNormal", unpack(WHITE))
        value:SetPoint("BOTTOM", tile, "BOTTOM", 0, 7)
        return value
    end
    previewAHPrice = priceTile(14, "AH-PREIS / STUECK")
    previewVendorPrice = priceTile(199, "HAENDLERPREIS / KAUF")
    previewDifference = priceTile(384, "DIFFERENZ / STUECK")

    titleText = label(center, "Suchergebnisse", "GameFontNormalLarge", unpack(GOLD))
    titleText:SetPoint("TOPLEFT", 20, -170)
    summaryText = label(center, "0 Eintraege", "GameFontHighlightSmall", unpack(MUTED))
    summaryText:SetPoint("TOPRIGHT", -18, -174)
    rule(center, "TOPLEFT", 17, -197, 564, unpack(BRONZE))
    local cols = label(center, "HAENDLER / WARE", "GameFontHighlightSmall", unpack(GOLD))
    cols:SetPoint("TOPLEFT", 23, -206)
    local zoneHeader = label(center, "ZONE", "GameFontHighlightSmall", unpack(GOLD))
    zoneHeader:SetPoint("TOPLEFT", 217, -206)
    local coordHeader = label(center, "ORT", "GameFontHighlightSmall", unpack(GOLD))
    coordHeader:SetPoint("TOPLEFT", 309, -206)
    local priceLabel = label(center, "PREIS", "GameFontHighlightSmall", unpack(GOLD))
    priceLabel:SetPoint("TOPLEFT", 389, -206)
    local stockHeader = label(center, "STATUS", "GameFontHighlightSmall", unpack(GOLD))
    stockHeader:SetPoint("TOPLEFT", 475, -206)
    for i = 1, pageSize do
        local row = CreateFrame("Button", nil, center, "BackdropTemplate")
        row:SetSize(562, 32)
        row:SetPoint("TOPLEFT", 18, -225 - (i - 1) * 35)
        applyBackdrop(row, i % 2 == 0 and {0.13, 0.096, 0.060, 0.96} or {0.18, 0.12, 0.072, 0.96})
        row:SetScript("OnClick", function(self) showDetail(self.result) end)
        row:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(GREEN)) end)
        row:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(unpack(self.result == selectedResult and GREEN or BRONZE))
        end)
        row.vendor = label(row, "", "GameFontNormalSmall", unpack(GOLD))
        row.vendor:SetPoint("TOPLEFT", 12, -3)
        row.vendor:SetWidth(187)
        row.item = label(row, "", "GameFontHighlightSmall", unpack(WHITE))
        row.item:SetPoint("BOTTOMLEFT", 12, 3)
        row.item:SetWidth(187)
        row.zone = label(row, "", "GameFontHighlightSmall", unpack(MUTED))
        row.zone:SetPoint("LEFT", 199, 0)
        row.zone:SetWidth(84)
        row.coord = label(row, "", "GameFontHighlightSmall", unpack(WHITE))
        row.coord:SetPoint("LEFT", 289, 0)
        row.coord:SetWidth(82)
        row.price = label(row, "", "GameFontNormalSmall", unpack(GOLD))
        row.price:SetPoint("LEFT", 376, 0)
        row.price:SetWidth(84)
        row.status = label(row, "", "GameFontHighlightSmall", unpack(GREEN))
        row.status:SetPoint("RIGHT", -8, 0)
        row.status:SetWidth(83)
        row.status:SetJustifyH("RIGHT")
        row:Hide()
        resultRows[i] = row
    end
    emptyHint = label(center, "Noch keine Treffer", "GameFontHighlight", unpack(MUTED))
    emptyHint:SetPoint("CENTER", center, "BOTTOM", 0, 129)
    emptyHint:SetWidth(470)
    emptyHint:SetJustifyH("CENTER")
    prevButton = button(center, "<", 38, 27, function() page = page - 1; updateResults() end)
    prevButton:SetPoint("BOTTOMLEFT", 18, 12)
    pageLabel = label(center, "1 / 1", "GameFontHighlightSmall", unpack(WHITE))
    pageLabel:SetPoint("BOTTOM", 0, 21)
    nextButton = button(center, ">", 38, 27, function() page = page + 1; updateResults() end)
    nextButton:SetPoint("BOTTOMRIGHT", -18, 12)

    local right = CreateFrame("Frame", nil, root, "BackdropTemplate")
    right:SetPoint("TOPLEFT", 825, -86)
    right:SetSize(280, 539)
    applyBackdrop(right, {0.092, 0.068, 0.049, 0.98})
    local rightHeading = label(right, "Standort & Herkunft", "GameFontNormalLarge", unpack(GOLD))
    rightHeading:SetPoint("TOPLEFT", 17, -15)
    rule(right, "TOPLEFT", 15, -46, 249, unpack(BRONZE))
    local mapSymbol = right:CreateTexture(nil, "ARTWORK")
    mapSymbol:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
    mapSymbol:SetSize(32, 32)
    mapSymbol:SetPoint("TOPRIGHT", -23, -58)
    local mapCaption = label(right, "Verifizierte Orte und Quellen", "GameFontHighlightSmall", unpack(MUTED))
    mapCaption:SetPoint("TOPLEFT", 17, -65)
    mapCaption:SetWidth(194)
    detailScroll = CreateFrame("ScrollFrame", nil, right)
    detailScroll:SetPoint("TOPLEFT", 18, -100)
    detailScroll:SetSize(244, 220)
    detailScroll:EnableMouseWheel(true)
    detailScrollContent = CreateFrame("Frame", nil, detailScroll)
    detailScrollContent:SetSize(238, 306)
    detailScroll:SetScrollChild(detailScrollContent)
    detailText = label(detailScrollContent, "", "GameFontHighlight", unpack(WHITE))
    detailText:SetPoint("TOPLEFT", 0, 0)
    detailText:SetWidth(238)
    detailText:SetJustifyH("LEFT")
    detailText:SetJustifyV("TOP")
    detailScroll:SetScript("OnMouseWheel", function(self, delta)
        local maximum = math.max(0, detailScrollContent:GetHeight() - self:GetHeight())
        local y = self:GetVerticalScroll() - delta * 45
        self:SetVerticalScroll(math.max(0, math.min(maximum, y)))
    end)
    mapPreview = CreateFrame("Frame",nil,right,"BackdropTemplate")
    mapPreview:SetSize(247,252)
    mapPreview:SetPoint("TOPLEFT",16,-99)
    applyBackdrop(mapPreview,{0.13,0.087,0.052,0.99})
    mapTiles={}
    for i=1,32 do
        local tile=mapPreview:CreateTexture(nil,"ARTWORK")
        tile:Hide()
        mapTiles[i]=tile
    end
    mapPin=mapPreview:CreateTexture(nil,"OVERLAY")
    mapPin:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
    mapPin:SetSize(24,24)
    mapPin:Hide()
    mapNote=label(mapPreview,"Standort unbekannt","GameFontHighlightSmall",unpack(GOLD))
    mapNote:SetPoint("BOTTOM",mapPreview,"BOTTOM",0,9)
    mapNote:SetWidth(235)
    mapNote:SetJustifyH("CENTER")
    mapPreview:Hide()
    itemLinkButton = button(right, "WoWHead: Gegenstand", 246, 29, function()
        if selectedResult then showURL(ns.WowheadURL("item", selectedResult.itemID)) end
    end)
    itemLinkButton:SetPoint("BOTTOMLEFT", 17, 60)
    itemLinkButton:Hide()
    npcLinkButton = button(right, "WoWHead: Haendler", 246, 29, function()
        if selectedResult then showURL(ns.WowheadURL("npc", selectedResult.npcID)) end
    end)
    npcLinkButton:SetPoint("BOTTOMLEFT", 17, 23)
    npcLinkButton:Hide()
    mapButton = button(right, "Zone auf Weltkarte", 246, 29, function()
        if selectedResult then ns.ShowVendorMap(selectedResult) end
    end)
    mapButton:SetPoint("BOTTOMLEFT", 17, 140)
    mapButton:Hide()
    waypointButton = button(right, "Wegpunkt setzen", 246, 29, function()
        if selectedResult then ns.SetVendorWaypoint(selectedResult) end
    end)
    waypointButton:SetPoint("BOTTOMLEFT", 17, 102)
    waypointButton:Hide()
    ahScanButton = button(right, "AH-Scan manuell starten", 246, 29, function()
        ns.StartAuctionScan()
        showDetail(nil)
    end)
    ahScanButton:SetPoint("BOTTOMLEFT", 17, 23)
    ahScanButton:Hide()
    targetedAHButton = button(right, "AH-Preis zu diesem Item", 246, 29, function()
        if selectedResult and selectedResult.itemID then
            local requestedItem = selectedResult.itemID
            ns.StartTargetedAuctionSearch(requestedItem)
        end
    end)
    targetedAHButton:SetPoint("BOTTOMLEFT", 17, 180)
    targetedAHButton:Hide()
    sourceLinkButton = button(right, "Quellenlink anzeigen", 246, 29, function()
        showURL(ns.SourceURL())
    end)
    sourceLinkButton:SetPoint("BOTTOMLEFT", 17, 23)
    sourceLinkButton:Hide()

    local footer = CreateFrame("Frame", nil, root, "BackdropTemplate")
    footer:SetPoint("BOTTOMLEFT", 14, 12)
    footer:SetSize(1090, 43)
    applyBackdrop(footer, {0.087, 0.068, 0.041, 0.98})
    local shield = footer:CreateTexture(nil, "ARTWORK")
    shield:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
    shield:SetSize(24, 24)
    shield:SetPoint("LEFT", 16, 0)
    footerText = label(footer, "", "GameFontHighlightSmall", unpack(WHITE))
    footerText:SetPoint("LEFT", 50, 0)
    footerText:SetWidth(1014)
    local provider = ns.reference.provider or "Keine Referenzdaten"
    local attribution = ns.SourceURL()
    footerText:SetText("Referenz: " .. provider ..
        (attribution and (" - " .. attribution) or "") ..
        "   |   Lokal erfasst: Haendlerbesuche   |   GPL-3.0-only")
    root:SetScript("OnHide", function() popup:Hide() end)
    root:SetScript("OnShow", updateResults)
end
