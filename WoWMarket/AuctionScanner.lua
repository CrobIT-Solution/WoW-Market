-- Read-only, manually requested AH snapshot. Never posts, bids or buys.
local _, ns = ...
local frame = CreateFrame("Frame")
local isOpen, waiting, scanning = false, false, false
local startedAt = nil
local MAX_AUCTIONS = 30000 -- skip very large queries; safety/performance gate
local BATCH = 40
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
function ns.AuctionStatus()
    local snap = ns.db and ns.db.auctionSnapshot
    if not snap then return "AH: noch keine lokale Momentaufnahme." end
    return "AH: " .. tostring(snap.auctions or 0) .. " Auktionen aus " ..
        tostring(snap.scope or "unbekannt") .. " (Zeitstempel " ..
        tostring(snap.scannedAt or "?") .. "). Preise sind nicht live."
end
function ns.AuctionPrice(itemID)
    local snap = ns.db and ns.db.auctionSnapshot
    if not snap or snap.scope ~= scope() then return nil end
    return snap.items and snap.items[itemID]
end
function ns.StartAuctionScan()
    if not ns.db or not isOpen or not hasAPI() then
        ns.Log("AH-Scan nur im offenen Auktionshaus mit unterstuetzter API moeglich.")
        return false
    end
    if waiting or scanning then ns.Log("AH-Abfrage laeuft bereits."); return false end
    if InCombatLockdown and InCombatLockdown() then return false end
    local now = GetServerTime()
    if now < (ns.db.lastAuctionRequest or 0) + 900 then
        ns.Log("AH-Scan: lokale 15-Minuten-Sperre aktiv; Blizzard kann laenger sperren.")
        return false
    end
    -- Only user-triggered, once; no timer-based automatic retries.
    ns.db.lastAuctionRequest = now
    waiting, startedAt = true, now
    C_AuctionHouse.ReplicateItems()
    ns.Log("AH-Momentaufnahme angefordert. Kann serverseitig gedrosselt werden.")
    return true
end
local function process()
    if not hasAPI() or scanning or not waiting then return end
    local count = C_AuctionHouse.GetNumReplicateItems()
    if type(count) ~= "number" or count < 1 then return end
    if count > MAX_AUCTIONS then
        waiting = false
        ns.Log("AH-Abbruch: ueber 30000 Auktionen. Performance-Schutz greift.")
        return
    end
    waiting, scanning = false, true
    local index, items = 0, {}
    local function nextBatch()
        if not isOpen then scanning = false; ns.Log("AH-Scan abgebrochen: Auktionshaus geschlossen."); return end
        local last = math.min(count, index + BATCH)
        while index < last do
            -- Only non-sensitive summary fields; no player names stored.
            local _, _, quantity, _, _, _, _, _, _, buyout,
                _, _, _, _, _, _, itemID = C_AuctionHouse.GetReplicateItemInfo(index)
            if type(itemID) == "number" and itemID > 0 and
                type(quantity) == "number" and quantity > 0 and
                type(buyout) == "number" and buyout > 0 then
                local unit = buyout / quantity
                local old = items[itemID]
                if not old then
                    items[itemID] = { minUnitCopper = unit, quantity = quantity, auctions = 1 }
                else
                    old.minUnitCopper = math.min(old.minUnitCopper, unit)
                    old.quantity = old.quantity + quantity
                    old.auctions = old.auctions + 1
                end
            end
            index = index + 1
        end
        if index < count then
            C_Timer.After(0.03, nextBatch)
        else
            ns.db.auctionSnapshot = { scope = scope(), scannedAt = GetServerTime(),
                auctions = count, items = items }
            scanning = false
            ns.Log("AH-Momentaufnahme abgeschlossen: " .. count .. " Auktionen.")
            if ns.RefreshUI then ns.RefreshUI() end
        end
    end
    nextBatch()
end
frame:RegisterEvent("AUCTION_HOUSE_SHOW")
frame:RegisterEvent("AUCTION_HOUSE_CLOSED")
frame:RegisterEvent("REPLICATE_ITEM_LIST_UPDATE")
frame:SetScript("OnEvent", function(_, event)
    if event == "AUCTION_HOUSE_SHOW" then isOpen = true
    elseif event == "AUCTION_HOUSE_CLOSED" then
        isOpen, waiting = false, false
    elseif event == "REPLICATE_ITEM_LIST_UPDATE" and waiting then
        process()
    end
end)
