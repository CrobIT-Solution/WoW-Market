-- SPDX-License-Identifier: GPL-3.0-only
-- WoW-Market: explicitly user-requested, read-only AH snapshot.
-- Blizzard enforces an account-wide cooldown on successful ReplicateItems calls.
local _, ns = ...
local frame = CreateFrame("Frame")
local isOpen, waiting, scanning = false, false, false
local requestId = 0
local lastAttemptAt = 0
local statusMessage = nil
local progress, expected = 0, 0
local targetedPendingID, targetedPendingKey = nil, nil
local targetedLastAttempt = 0
local targetedRequestSerial = 0
local TARGETED_QUERY_GUARD = 6  -- conservative guard, far below WoW's 100/min limit
local TARGETED_MAX_ROWS = 500  -- avoid long frame stalls on busy servers
local FULL_SCAN_COOLDOWN = 900 -- Server-side ~15 min; never try to bypass.
local FAILED_RETRY_GUARD = 30 -- Prevent request spam after timeout/error.
local RESPONSE_TIMEOUT = 25
local MAX_PROCESS_AUCTIONS = 80000 -- Safety limit; partial results are never labelled full.
local BATCH = 70

local function now()
    if type(GetServerTime) == "function" then return GetServerTime() end
    return 0
end

local function hasAPI()
    return C_AuctionHouse and type(C_AuctionHouse.ReplicateItems) == "function" and
        type(C_AuctionHouse.GetNumReplicateItems) == "function" and
        type(C_AuctionHouse.GetReplicateItemInfo) == "function"
end

local function scope()
    local realm = GetNormalizedRealmName and GetNormalizedRealmName() or "?"
    local faction = UnitFactionGroup and UnitFactionGroup("player") or "?"
    return tostring(realm) .. ":" .. tostring(faction)
end

local function message(text)
    statusMessage = text
    if ns.Log then ns.Log(text) end
    if ns.RefreshUI then ns.RefreshUI() end
end

function ns.AuctionStatus()
    local lines = {}
    if waiting then
        lines[#lines + 1] = "Serverantwort ausstehend (keine automatische Wiederholung)."
    elseif scanning then
        lines[#lines + 1] = "Verarbeitung: " .. tostring(progress) .. " / " .. tostring(expected) .. " Auktionen."
    end
    if statusMessage then lines[#lines + 1] = statusMessage end
    local snap = ns.db and ns.db.auctionSnapshot
    if snap then
        local text = "Letzte AH-Momentaufnahme: " .. tostring(snap.auctions or 0) .. " Auktionen aus " ..
            tostring(snap.scope or "unbekannt") .. " (" .. tostring(snap.scannedAt or "?") .. ")."
        if snap.partial then
            text = text .. " ACHTUNG: Unvollstaendig, nicht fuer Preisvergleich freigegeben."
        else
            text = text .. " Nicht live."
        end
        lines[#lines + 1] = text
    elseif #lines == 0 then
        lines[#lines + 1] = "Noch keine AH-Momentaufnahme."
    end
    local lastSuccess = ns.db and ns.db.lastSuccessfulReplicateAt
    local remaining = (type(lastSuccess) == "number") and math.max(0, FULL_SCAN_COOLDOWN - (now() - lastSuccess)) or 0
    if remaining > 0 then
        lines[#lines + 1] = "Naechster vollstaendiger Serverabruf fruehestens in ca. " ..
            tostring(math.ceil(remaining / 60)) .. " Minuten (Blizzard-Sperre)."
    end
    return table.concat(lines, "\n")
end

function ns.AuctionPrice(itemID)
    if not ns.db then return nil end
    -- Targeted, manually requested quotes take precedence over an older full snapshot.
    local quote = ns.db.targetedAuctionPrices and ns.db.targetedAuctionPrices[itemID]
    if quote and quote.scope == scope() and quote.minUnitCopper and not quote.partial then
        return quote
    end
    local snap = ns.db.auctionSnapshot
    if not snap or snap.partial or snap.scope ~= scope() then return nil end
    return snap.items and snap.items[itemID]
end

function ns.TargetedAuctionStatus()
    if targetedPendingID then
        return "Einzelabfrage fuer Item-ID " .. targetedPendingID .. " laeuft."
    end
    return nil
end

local function itemKeyFor(id)
    if C_AuctionHouse and type(C_AuctionHouse.MakeItemKey) == "function" then
        local ok, key = pcall(C_AuctionHouse.MakeItemKey, id)
        if ok and type(key) == "table" then return key end
    end
    return {itemID=id, itemLevel=0, itemSuffix=0, battlePetSpeciesID=0}
end

-- Only from a deliberate UI click; no looping through items or automatic trading.
function ns.StartTargetedAuctionSearch(id)
    if type(id) ~= "number" or id < 1 or id ~= math.floor(id) or id > 2147483647 then
        message("Einzelabfrage braucht eine gueltige Item-ID.")
        return false
    end
    if not isOpen or not ns.db or not C_AuctionHouse or
       type(C_AuctionHouse.SendSearchQuery) ~= "function" then
        message("Einzelabfrage nur im offenen AH mit unterstuetzter API moeglich.")
        return false
    end
    if InCombatLockdown and InCombatLockdown() then
        message("AH-Abfrage im Kampf nicht moeglich.")
        return false
    end
    local timestamp = now()
    if targetedPendingID then
        message("Eine Einzelabfrage laeuft bereits.")
        return false
    end
    if waiting or scanning then
        message("Vollscan laeuft. Bitte zuerst die aktuelle AH-Abfrage abwarten.")
        return false
    end
    if targetedLastAttempt > 0 and timestamp < targetedLastAttempt + TARGETED_QUERY_GUARD then
        message("Bitte noch kurz warten: Schutz vor zu vielen Einzelabfragen.")
        return false
    end
    local key = itemKeyFor(id)
    targetedRequestSerial = targetedRequestSerial + 1
    local serial = targetedRequestSerial
    targetedLastAttempt, targetedPendingID, targetedPendingKey = timestamp, id, key
    -- Normal addon UI click, not a /run script. No automated follow-up searches.
    local ok, err = pcall(C_AuctionHouse.SendSearchQuery, key, {}, false)
    if not ok then
        targetedPendingID, targetedPendingKey = nil, nil
        message("AH-Einzelabfrage konnte nicht gestartet werden: " .. tostring(err))
        return false
    end
    local serialID = id
    if C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(15, function()
            if targetedPendingID == serialID and targetedRequestSerial == serial then
                targetedPendingID, targetedPendingKey = nil, nil
                message("Keine Antwort auf die AH-Einzelabfrage. Bitte spaeter manuell neu versuchen.")
            end
        end)
    end
    message("Gezielte AH-Abfrage fuer Item-ID " .. id .. " gesendet.")
    return true
end

local function finishTargetedSearch(kind, id, key)
    if id ~= targetedPendingID or not ns.db then return end
    local ah = C_AuctionHouse
    local countFn, infoFn
    if kind == "commodity" then
        countFn, infoFn = ah.GetNumCommoditySearchResults, ah.GetCommoditySearchResultInfo
    else
        countFn, infoFn = ah.GetNumItemSearchResults, ah.GetItemSearchResultInfo
    end
    if type(countFn) ~= "function" or type(infoFn) ~= "function" then return end
    local lookupKey = kind == "commodity" and id or key
    local okCount, count = pcall(countFn, lookupKey)
    if not okCount or type(count) ~= "number" or count < 0 then return end
    local rows = math.min(count, TARGETED_MAX_ROWS)
    local minUnit, quantity = nil, 0
    for i=1,rows do
        local okInfo, result = pcall(infoFn, lookupKey, i)
        if okInfo and type(result) == "table" then
            local itemQuantity = result.quantity
            local unit
            if kind == "commodity" then
                unit = result.unitPrice
            elseif type(itemQuantity) == "number" and itemQuantity > 0 and
                   type(result.buyoutAmount) == "number" then
                unit = result.buyoutAmount / itemQuantity
            end
            if type(unit) == "number" and unit > 0 and unit < math.huge and
               type(itemQuantity) == "number" and itemQuantity > 0 then
                minUnit = (not minUnit) and unit or math.min(minUnit, unit)
                quantity = quantity + itemQuantity
            end
        end
    end
    if not ns.db.targetedAuctionPrices then ns.db.targetedAuctionPrices = {} end
    if minUnit then
        ns.db.targetedAuctionPrices[id] = {
            minUnitCopper=minUnit, quantity=quantity, auctions=rows,
            scannedAt=now(), scope=scope(), source="Einzelabfrage", partial=count>rows,
        }
    else
        -- No offers does not mean a zero-price item.
        ns.db.targetedAuctionPrices[id] = nil
    end
    targetedPendingID, targetedPendingKey = nil, nil
    message("AH-Einzelabfrage Item " .. id .. ": " ..
       (minUnit and ("ab " .. ns.Money(minUnit) .. "/Stueck") or "keine gueltigen Kaufangebote") ..
       (count>rows and " (Teilergebnis, nicht als Mindestpreis verwenden)" or "") .. ".")
end

function ns.StartAuctionScan()
    if not ns.db or not isOpen or not hasAPI() then
        message("AH-Scan braucht ein offenes Auktionshaus mit ReplicateItems-API.")
        return false
    end
    if waiting or scanning then
        message("AH-Abfrage oder Auswertung laeuft bereits.")
        return false
    end
    if InCombatLockdown and InCombatLockdown() then
        message("AH-Scan waehrend des Kampfes nicht gestartet.")
        return false
    end
    local timestamp = now()
    local lastSuccess = ns.db.lastSuccessfulReplicateAt
    if type(lastSuccess) == "number" and timestamp < lastSuccess + FULL_SCAN_COOLDOWN then
        message("Blizzard erlaubt den naechsten Vollscan erst in ca. " ..
            math.ceil((lastSuccess + FULL_SCAN_COOLDOWN - timestamp) / 60) ..
            " Minuten. Die bestehende Momentaufnahme bleibt erhalten.")
        return false
    end
    if lastAttemptAt > 0 and timestamp < lastAttemptAt + FAILED_RETRY_GUARD then
        message("Bitte noch " .. tostring(lastAttemptAt + FAILED_RETRY_GUARD - timestamp) ..
            " Sekunden warten; Schutz vor wiederholten Serveranfragen.")
        return false
    end
    -- No 15-minute lock on mere request. It starts only when the server answers.
    -- The old lastAuctionRequest field (set by previous alpha even on errors)
    -- is deliberately ignored, but preserved in SavedVariables.
    requestId = requestId + 1
    local thisRequest = requestId
    lastAttemptAt, waiting, progress, expected = timestamp, true, 0, 0
    statusMessage = "Vollscan beim Server angefordert."
    local ok, err = pcall(C_AuctionHouse.ReplicateItems)
    if not ok then
        waiting = false
        message("AH-API-Fehler, kein Vollscan gestartet: " .. tostring(err))
        return false
    end
    if C_Timer and type(C_Timer.After) == "function" then
        C_Timer.After(RESPONSE_TIMEOUT, function()
            if waiting and requestId == thisRequest then
                waiting = false
                message("Keine AH-Serverantwort. Bitte spaeter manuell erneut versuchen; " ..
                    "ein anderes Addon kann die Blizzard-Sperre bereits ausgeloest haben.")
            end
        end)
    end
    if ns.RefreshUI then ns.RefreshUI() end
    return true
end

local function startProcessing()
    if not hasAPI() or scanning or not waiting then return end
    local ok, count = pcall(C_AuctionHouse.GetNumReplicateItems)
    if not ok or type(count) ~= "number" or count < 0 or count ~= math.floor(count) then
        waiting = false
        message("Unbrauchbare AH-Serverantwort, kein Snapshot gespeichert.")
        return
    end
    if count == 0 then
        -- Some clients fire before entries are cached. Let the timeout handle it.
        return
    end
    waiting, scanning = false, true
    ns.db.lastSuccessfulReplicateAt = now()
    requestId = requestId + 1 -- Cancel stale timeout callbacks.
    local limit = math.min(count, MAX_PROCESS_AUCTIONS)
    expected, progress = limit, 0
    local items, incomplete, errors = {}, 0, 0
    local partial = count > limit
    local serial = requestId
    local function nextBatch()
        if requestId ~= serial or not scanning then return end
        local last = math.min(limit, progress + BATCH)
        while progress < last do
            local index = progress -- Forever's replicate list is zero-indexed.
            local okInfo, _, _, quantity, _, _, _, _, _, _, buyout,
                _, _, _, _, _, _, itemID, hasAllInfo = pcall(C_AuctionHouse.GetReplicateItemInfo, index)
            if not okInfo then
                errors = errors + 1
                incomplete = incomplete + 1
            elseif hasAllInfo == false then
                incomplete = incomplete + 1
            elseif type(itemID) == "number" and itemID > 0 and
                type(quantity) == "number" and quantity > 0 and
                type(buyout) == "number" and buyout > 0 then
                local unit = buyout / quantity
                local old = items[itemID]
                if not old then
                    items[itemID] = {minUnitCopper = unit, quantity = quantity, auctions = 1}
                else
                    old.minUnitCopper = math.min(old.minUnitCopper, unit)
                    old.quantity = old.quantity + quantity
                    old.auctions = old.auctions + 1
                end
            end
            progress = progress + 1
        end
        if progress < limit then
            if not C_Timer or type(C_Timer.After) ~= "function" then
                scanning = false
                message("AH-Verarbeitung abgebrochen: WoW-Timer-API fehlt.")
                return
            end
            C_Timer.After(0.035, nextBatch)
        else
            scanning = false
            if incomplete > 0 then partial = true end
            -- Keep the last usable snapshot if this request yielded incomplete data.
            if not partial then
                ns.db.auctionSnapshot = {
                    scope = scope(), scannedAt = now(), auctions = count,
                    processed = limit, incomplete = 0, partial = false, items = items,
                }
            end
            if partial then
                message("AH-Daten teilweise gelesen (" .. tostring(limit) .. "/" .. tostring(count) ..
                    ", unvollstaendig: " .. tostring(incomplete) .. ", API-Fehler: " .. tostring(errors) ..
                    "). Keine falschen Vollscan-Preise anzeigen.")
            else
                message("AH-Momentaufnahme abgeschlossen: " .. tostring(count) ..
                    " Auktionen. Kein weiterer Serverabruf fuer die Auswertung erforderlich.")
            end
        end
    end
    nextBatch()
end

frame:RegisterEvent("AUCTION_HOUSE_SHOW")
frame:RegisterEvent("AUCTION_HOUSE_CLOSED")
frame:RegisterEvent("REPLICATE_ITEM_LIST_UPDATE")
frame:RegisterEvent("ITEM_SEARCH_RESULTS_UPDATED")
frame:RegisterEvent("COMMODITY_SEARCH_RESULTS_UPDATED")
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "AUCTION_HOUSE_SHOW" then
        isOpen = true
    elseif event == "AUCTION_HOUSE_CLOSED" then
        isOpen = false
        -- Do not throw away an already received full snapshot simply because
        -- the AH window closed while its local cached rows are processed.
        targetedPendingID, targetedPendingKey = nil, nil
        if waiting then
            waiting = false
            requestId = requestId + 1
            message("Auktionshaus vor der Serverantwort geschlossen; Anfrage beendet.")
        end
    elseif event == "REPLICATE_ITEM_LIST_UPDATE" and waiting then
        startProcessing()
    elseif event == "ITEM_SEARCH_RESULTS_UPDATED" and targetedPendingID then
        local key = select(1, ...)
        if type(key) == "table" and key.itemID == targetedPendingID then
            finishTargetedSearch("item", targetedPendingID, key)
        end
    elseif event == "COMMODITY_SEARCH_RESULTS_UPDATED" and targetedPendingID then
        local id = select(1, ...)
        if id == targetedPendingID then
            finishTargetedSearch("commodity", id, targetedPendingKey)
        end
    end
end)
