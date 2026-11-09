-- SPDX-License-Identifier: GPL-3.0-only
-- Standalone synthetic Lua behavior test: no WoW client or real game data.
local path = assert(..., "addon path required")
_G.unpack = table.unpack
local frames = {}
function CreateFrame()
    local f = {}
    function f:RegisterEvent(event) self.registered = self.registered or {}; self.registered[event] = true end
    function f:SetScript(event, callback) self[event] = callback end
    frames[#frames + 1] = f
    return f
end
function GetServerTime() return 1700000000 end
function InCombatLockdown() return false end
function UnitGUID(unit) if unit == "npc" then return "Creature-0-0-0-0-101-007" end end
function UnitName(unit) if unit == "npc" then return "Testmerchant" end end
function GetZoneText() return "Testzone" end
function GetMerchantNumItems() return 2 end
function GetMerchantItemID(index) return (index == 1) and 900001 or 900002 end
C_MerchantFrame = {
    GetItemInfo = function(index)
        if index == 1 then return {name = "Testware", price = 3000, stackCount = 5, numAvailable = -1, hasExtendedCost = false} end
        return {name = "Tokenware", price = 0, stackCount = 1, numAvailable = 3, hasExtendedCost = true}
    end
}
C_Map = {
    GetBestMapForUnit = function() return 15 end,
    GetPlayerMapPosition = function() return {x = 0.426, y = 0.653} end
}
function strsplit(delimiter, value)
    local result = {}
    for segment in (value .. delimiter):gmatch("(.-)" .. delimiter) do result[#result+1] = segment end
    return table.unpack(result)
end
SLASH_CROBITMARKET1 = nil
SlashCmdList = {}
CrobITMarketData = {
    schema = 1, provider = "SYNTHETIC", vendors = {
        [101] = {name = "Testmerchant", zone = "Oldzone", mapID = 15, x = 22, y = 21,
            seenInForever = false, items = {[900001] = {name = "Testware", priceCopper = 5000, stackCount = 1}}},
        [102] = {name = "Reference only", zone = "Somewhere", seenInForever = true,
            items = {[900003] = {name = "Otherware", priceCopper = 12000, stackCount = 1}}}
    }
}
CrobITMarketDB = {vendors = {old = "preserve me"}}
local ns = {}
assert(loadfile(path .. "/Core.lua"))("CrobITMarket", ns)
assert(loadfile(path .. "/VendorScanner.lua"))("CrobITMarket", ns)
assert(loadfile(path .. "/VendorSearch.lua"))("CrobITMarket", ns)
assert(loadfile(path .. "/Links.lua"))("CrobITMarket", ns)
C_Timer = { After = function(_, callback) callback() end }
assert(loadfile(path .. "/MapActions.lua"))("CrobITMarket", ns)
local auctionCalls = 0
C_AuctionHouse = {
    ReplicateItems = function() auctionCalls = auctionCalls + 1 end,
    GetNumReplicateItems = function() return 3 end,
    GetReplicateItemInfo = function(index)
        if index == 0 then return "Testware", nil, 5, nil, nil, nil, nil, nil, nil, 15000,
            nil, nil, nil, nil, nil, nil, 900001, true end
        if index == 1 then return "Testware", nil, 1, nil, nil, nil, nil, nil, nil, 5000,
            nil, nil, nil, nil, nil, nil, 900001, true end
        return "No buyout", nil, 2, nil, nil, nil, nil, nil, nil, 0,
            nil, nil, nil, nil, nil, nil, 900003, true
    end,
}
assert(loadfile(path .. "/AuctionScanner.lua"))("CrobITMarket", ns)
ns.InitUI = function() end
for _, frame in ipairs(frames) do
    if frame.registered and frame.registered.ADDON_LOADED then frame.OnEvent(frame, "ADDON_LOADED", "CrobITMarket") end
end
assert(CrobITMarketDB.vendors.old == "preserve me", "legacy data lost")
assert(ns.db.schema == 1, "new DB schema missing")
for _, frame in ipairs(frames) do
    if frame.registered and frame.registered.MERCHANT_SHOW then frame.OnEvent(frame, "MERCHANT_SHOW") end
end
assert(ns.db.observedVendors[101] ~= nil, "visit not captured")
assert(ns.db.observedVendors[101].items[900001].priceCopper == 3000, "observed price missing")
-- Simulate filtered stock on the next MERCHANT_UPDATE: do not delete unseen items.
GetMerchantNumItems = function() return 1 end
for _, frame in ipairs(frames) do
    if frame.registered and frame.registered.MERCHANT_UPDATE then frame.OnEvent(frame, "MERCHANT_UPDATE") end
end
assert(ns.db.observedVendors[101].items[900002] ~= nil, "partial update erased earlier observed item")
assert(ns.WowheadURL("item", 2589) == "https://www.wowhead.com/forever/item=2589", "incorrect item URL")
assert(ns.WowheadURL("npc", 3255) == "https://www.wowhead.com/forever/npc=3255", "incorrect vendor URL")
assert(ns.WowheadURL("item", 0) == nil, "invalid ID accepted")
assert(ns.WowheadURL("item", "2589") == nil, "untrusted ID accepted")
assert(ns.WowheadURL("achievement", 2589) == nil, "unsupported URL category accepted")
assert(ns.SourceURL() == nil, "missing provider URL should not be linked")
ns.reference.attributionUrl = "https://foreverdb.net"
assert(ns.SourceURL() == "https://foreverdb.net", "valid source URL missing")
ns.reference.attributionUrl = "https://unsafe.example/@evil"
assert(ns.SourceURL() == nil, "unsafe attribution URL accepted")
local results = ns.Search("900001", 15)
assert(#results == 1, "should find item by ID")
assert(results[1].npcID == 101 and results[1].itemID == 900001, "link IDs missing")
assert(results[1].priceCopper == 3000, "local observation must win")
assert(results[1].stackCount == 5, "vendor purchase quantity must be stored")
assert(results[1].status == "Im Spiel gesehen", "source status wrong")
local other = ns.Search("Otherware", 5)
assert(#other == 1 and other[1].status == "Forever bestaetigt", "reference provenance wrong")
local special = ns.Search("Tokenware", 5)
assert(#special == 1 and special[1].hasExtendedCost == true, "extra costs must be flagged")
local reference, observed = ns.GetCounts()
assert(reference == 2 and observed == 1, "counts wrong")
-- Bounded best-result collection. Observed results must not disappear behind references.
ns.reference.vendors[103] = {name="Far Merchant", zone="Example", seenInForever=true,
    items = {[900004]={name="Testware", priceCopper=4500, stackCount=1}}}
ns.reference.vendors[104] = {name="Unknown Merchant", zone="Example", seenInForever=false,
    items = {[900005]={name="Testware", priceCopper=100, stackCount=1}}}
local best, hits = ns.Search("Testware", 2)
assert(#best == 2 and hits >= 3, "bounded search lost total hit count")
assert(best[1].vendorName == "Testmerchant" and best[2].vendorName == "Far Merchant",
    "best-results priority or ordering wrong")
-- World map: only explicit action. Never auto-navigate or move the character.
local openedMap
C_Map.OpenWorldMap = function(id) openedMap = id end
C_Map.CanSetUserWaypointOnMap = function(id) return id == 15 end
C_Map.SetUserWaypoint = function(point) return point.uiMapID == 15 end
UiMapPoint = { CreateFromCoordinates = function(mapID, x, y)
    assert(x >= 0 and x <= 1 and y >= 0 and y <= 1)
    return {uiMapID = mapID, x = x, y = y}
end }
assert(ns.ShowVendorMap(results[1]) and openedMap == 15, "map not opened on click")
assert(ns.SetVendorWaypoint(results[1]), "waypoint not set")
assert(not ns.SetVendorWaypoint({mapID=15, x=101, y=12}), "invalid coords accepted")
-- AH: user-triggered, realm/faction scoped, throttled and never trades.
for _, frame in ipairs(frames) do
    if frame.registered and frame.registered.AUCTION_HOUSE_SHOW then
        frame.OnEvent(frame, "AUCTION_HOUSE_SHOW")
    end
end
assert(ns.StartAuctionScan(), "manual AH scan not started")
assert(auctionCalls == 1 and not ns.StartAuctionScan(), "AH repeated without new user request")
for _, frame in ipairs(frames) do
    if frame.registered and frame.registered.REPLICATE_ITEM_LIST_UPDATE then
        frame.OnEvent(frame, "REPLICATE_ITEM_LIST_UPDATE")
    end
end
assert(ns.db.auctionSnapshot.auctions == 3, "AH snapshot missing")
assert(ns.AuctionPrice(900001).minUnitCopper == 3000, "AH unit-price math wrong")
assert(ns.AuctionPrice(900003) == nil, "auction with no buyout should be excluded")
assert(not ns.StartAuctionScan() and auctionCalls == 1, "15min cooldown not enforced")
print("PASS: bounded priority search, explicit safe map/waypoint, manual AH snapshot, buyout math, scan throttle, plus source links and Wowhead IDs validated, preserved legacy data, captured merchant, non-destructive partial updates, observed price priority, ID search, batch size, provenance, special costs")
