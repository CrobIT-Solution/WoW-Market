local _, ns = ...
local listener = CreateFrame("Frame")
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

local function scanVendor()
    if not ns.db or (InCombatLockdown and InCombatLockdown()) then return end
    if not C_MerchantFrame or type(C_MerchantFrame.GetItemInfo) ~= "function" then return end
    if type(GetMerchantNumItems) ~= "function" or type(GetMerchantItemID) ~= "function" then
        ns.Log("Haendler-API unvollstaendig: kein Scan (Fail-Closed).")
        return
    end
    local name = safeText(UnitName("npc"))
    if not name or name == "" then return end
    local count = safeNumber(GetMerchantNumItems())
    if not count or count < 1 or count > 2000 then return end
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
        local itemID = safeNumber(GetMerchantItemID(index))
        local info = C_MerchantFrame.GetItemInfo(index)
        if itemID and itemID > 0 and ns.IsReadable(info) and type(info) == "table" then
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
    if recorded == 0 then return end
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
