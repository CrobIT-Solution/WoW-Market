-- SPDX-License-Identifier: GPL-3.0-only
-- Mocked public QuestieDB API; the addon must never copy QuestieDB into its own data.
local path = assert(...)
local ns = {}
assert(loadfile(path .. "/OptionalQuestie.lua"))("WoWMarket", ns)
assert(not ns.QuestieAvailable(), "Absent optional QuestieDB should be harmless")
assert(ns.QuestieNPC(123) == nil and ns.QuestieItemName(456) == nil)
LibQuestieDB = {
    Npc = {
        name = function(id)
            if id == 123 then return "Quartermaster Sample" end
            if id == 124 then return "Danger|cff00ff00markup" end
            if id == 125 then error("Deliberate bad third-party API") end
        end,
        zoneID = function(id) return (id == 123) and 17 or 0 end,
        spawns = function(id)
            if id == 123 then return {[17] = {{52.2, 41.1}}} end
            if id == 124 then return {[19] = {{1, 2}, {30, 40}}} end
        end,
    },
    Item = { name = function(id) if id == 456 then return "Questie Item" end end },
}
assert(ns.QuestieAvailable(), "Available optional public API should be detected")
local v = ns.QuestieNPC(123)
assert(v.name == "Quartermaster Sample" and v.zoneID == 17, "NPC name/zone missing")
assert(v.spawnZoneID == 17 and v.spawnX == 52.2 and v.spawnY == 41.1, "Possible spawn hint missing")
assert(v.mapID == nil, "Questie zone IDs must NOT be used as uiMapIDs")
assert(ns.QuestieItemName(456) == "Questie Item", "Optional item name missing")
local suspicious = ns.QuestieNPC(124)
assert(suspicious == nil or suspicious.name == nil, "WoW formatting injection accepted")
assert(suspicious == nil or suspicious.spawnZoneID == nil, "Multiple spawns must not imply a unique marker")
assert(ns.QuestieNPC(125) == nil, "Third-party exception should not crash addon")
assert(ns.QuestieNPC("123") == nil and ns.QuestieItemName(0) == nil, "Bad IDs accepted")

-- Search uses supplemental names only for unknown placeholders, with no copied database.
CrobITMarketData = {schema = 1, provider = "Everloot", vendors = {
    [123] = {id = 123, name = "NPC-ID 123 (Name unbekannt)", zone = "Standort nicht belegt",
        seenInForever = true, items = {[456] = {
            name = "Item-ID 456 (Name unbekannt)", priceCopper = 1234, stackCount = nil,
        }}},
    [124] = {id = 124, name = "Observed Custom Name", zone = "Known Zone",
        seenInForever = true, items = {[457] = {name = "Observed Item Name", priceCopper = 50}}},
}}
ns.reference = CrobITMarketData
ns.db = {observedVendors={}}
assert(loadfile(path .. "/VendorSearch.lua"))("WoWMarket", ns)
local a = ns.Search("Questie Item", 5)
assert(#a == 1 and a[1].vendorName == "Quartermaster Sample", "Supplemental search failed")
assert(a[1].itemFromQuestie == true, "Item source not marked")
assert(a[1].zone == "Standort nicht belegt" and a[1].mapID == nil and a[1].x == nil,
    "Questie guess contaminated confirmed map fields")
local byNPC = ns.Search("Quartermaster", 5)
assert(#byNPC == 1, "Supplemental NPC name not searchable")
local prior = ns.Search("Observed Custom Name", 5)
assert(#prior == 1 and prior[1].vendorName == "Observed Custom Name", "Local source overwritten")
assert(CrobITMarketData.vendors[123].name:find("unbekannt",1,true), "Reference database mutated")
print("PASS: optional QuestieDB hints, safe name search, provenance, missing API, no fabricated map IDs, no source mutation")
