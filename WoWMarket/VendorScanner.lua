-- SPDX-License-Identifier: GPL-3.0-only
local _, ns = ...
local listener = CreateFrame("Frame")
local observedLast = "Noch kein Haendler besucht."
function ns.VendorCaptureStatus() return observedLast end
local function safeText(value)
    return ns.IsReadable(value) and type(value) == "string" and value or nil
end
local function safeNumber(value)
    return ns.IsReadable(value) and type(value) == "number" and value or nil
end

local function position()
    if not C_Map or not C_Map.GetBestMapForUnit or not C_Map.GetPlayerMapPosition then
        return nil, nil, nil
    end
    local mapID = safeNumber(C_Map.GetBestMapForUnit("player"))
    if not mapID then return nil, nil, nil end
    local location = C_Map.GetPlayerMapPosition(mapID, "player")
    if not ns.IsReadable(location) then return mapID, nil, nil end
    local x = safeNumber(location.x)
    local y = safeNumber(location.y)
    if not x or not y then return mapID, nil, nil end
    return mapID, math.floor(x * 1000 + 0.5) / 10,
        math.floor(y * 1000 + 0.5) / 10
end

local function npcID()
    local guid = UnitGUID("npc")
    if not safeText(guid) then return nil end
    -- In some client builds the GUID no longer exposes a parseable NPC ID.
    local kind, _, _, _, _, id = strsplit("-", guid)
    if kind ~= "Creature" and kind ~= "Vehicle" then return nil end
    return tonumber(id)
end

local function merchantCount()
    local getter = C_MerchantFrame and C_MerchantFrame.GetNumItems
    if type(getter) == "function" then
        local ok, value = pcall(getter)
        if ok and ns.IsReadable(value) and type(value) == "number" then return value end
    end
    if type(GetMerchantNumItems) == "function" then
        local ok, value = pcall(GetMerchantNumItems)
        if ok and ns.IsReadable(value) and type(value) == "number" then return value end
    end
    return nil
end

local function merchantItemID(index, info)
    local direct = info and safeNumber(info.itemID)
    if direct and direct > 0 then return direct end
    if type(GetMerchantItemID) == "function" then
        local ok, value = pcall(GetMerchantItemID, index)
        if ok and safeNumber(value) and value > 0 then return value end
    end
    -- Some Forever builds expose item links rather than a usable legacy ID getter.
    local getter = C_MerchantFrame and C_MerchantFrame.GetItemLink
    if type(getter) ~= "function" then getter = GetMerchantItemLink end
    if type(getter) == "function" then
        local ok, link = pcall(getter, index)
        if ok and safeText(link) then
            local id = tonumber(link:match("item:(%d+)"))
            if id and id >= 1 and id <= 2147483647 then return id end
        end
    end
    return nil
end

local function scanVendor()
    if not ns.db or (InCombatLockdown and InCombatLockdown()) then return end
    if not C_MerchantFrame or type(C_MerchantFrame.GetItemInfo) ~= "function" then return end
    local count = safeNumber(merchantCount())
    if not count then
        observedLast = "Haendler-API liefert keine lesbare Warenanzahl."
        return
    end
    local name = safeText(UnitName("npc"))
    if not name or name == "" then return end
    if count < 1 or count > 2000 then
        observedLast = "Haendler hat noch keine lesbaren Waren (oder zu viele Eintraege)."
        return
    end
    local id = npcID()
    local mapID, x, y = position()
    local key = id
    if not key then
        -- Avoid assigning a made-up NPC ID when GUIDs are obfuscated.
        key = "local:" .. name .. ":" .. tostring(mapID or "unknown") .. ":" ..
              tostring(x or "?") .. ":" .. tostring(y or "?")
    end
    local items = {}
    local recorded = 0
    for index = 1, count do
        local okInfo, info = pcall(C_MerchantFrame.GetItemInfo, index)
        if okInfo and ns.IsReadable(info) and type(info) == "table" then
            local itemID = merchantItemID(index, info)
            if itemID and itemID > 0 then
            local label = safeText(info.name)
            local price = safeNumber(info.price)
            local quantity = safeNumber(info.stackCount)
            local available = safeNumber(info.numAvailable)
            local extra = ns.IsReadable(info.hasExtendedCost) and info.hasExtendedCost == true
            if label and price and price >= 0 then
                items[itemID] = {
                    name = label,
                    priceCopper = price, -- price for entire vendor purchase, not one unit
                    stackCount = (quantity and quantity >= 1) and quantity or 1,
                    numAvailable = available, -- nil = unbekannt, -1 nur wenn tatsaechlich gemeldet
                    hasExtendedCost = extra,
                }
                recorded = recorded + 1
            end
            end
        end
    end
    if recorded == 0 then
        observedLast = "Haendler geoeffnet, aber keine gueltigen Wareninformationen geladen."
        return
    end
    local zone = (GetZoneText and safeText(GetZoneText())) or "Unbekannt"
    local previous = ns.db.observedVendors[key]
    -- A merchant update may show only filtered/partially loaded stock.
    -- Never erase earlier observations just because a later scan lists fewer slots.
    if previous and type(previous.items) == "table" then
        for itemID, item in pairs(items) do previous.items[itemID] = item end
        items = previous.items
    end
    ns.db.observedVendors[key] = {
        name = name, zone = zone, mapID = mapID or (previous and previous.mapID),
        x = x or (previous and previous.x), y = y or (previous and previous.y),
        items = items, observedAt = GetServerTime(),
        observed = true, id = id,
    }
    observedLast = "Erfasst: " .. name .. " (" .. tostring(recorded) .. " Warenpositionen)"
    if ns.RefreshUI then ns.RefreshUI() end
end

listener:RegisterEvent("MERCHANT_SHOW")
listener:RegisterEvent("MERCHANT_UPDATE")
listener:SetScript("OnEvent", function(_, event)
    scanVendor()
    if event == "MERCHANT_SHOW" and C_Timer and C_Timer.After then
        C_Timer.After(0.2, scanVendor)
    end
end)
