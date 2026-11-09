-- Optional, read-only QuestieDB hints. No QuestieDB data are redistributed.
-- QuestieDB zone IDs and spawn pairs are NOT WoW C_Map uiMapIDs/user waypoints.
local _, ns = ...
local npcCache, itemCache, cacheSize = {}, {}, 0
local MAX_CACHE = 4000

local function validID(id)
    return type(id) == "number" and id >= 1 and id <= 2147483647 and id == math.floor(id)
end

local function cleanName(value)
    if type(value) ~= "string" or #value == 0 or #value > 150 or value:find("|", 1, true) then
        return nil
    end
    for i = 1, #value do
        if value:byte(i) < 32 then return nil end
    end
    return value
end

local function readGetter(entity, field, id)
    if type(entity) ~= "table" then return nil end
    local getter = entity[field]
    if type(getter) ~= "function" then return nil end
    local ok, value = pcall(getter, id)
    if not ok then return nil end
    return value
end

local function remember(cache, key, value)
    if cacheSize >= MAX_CACHE then
        npcCache, itemCache, cacheSize = {}, {}, 0
        cache = value.kind == "npc" and npcCache or itemCache
    end
    cache[key] = value
    cacheSize = cacheSize + 1
end

local function apiEntity(name)
    -- Depend on the public API, not on internal QuestieDB tables/files.
    local root = LibQuestieDB
    if type(root) ~= "table" then return nil end
    local entity = root[name]
    if type(entity) ~= "table" then return nil end
    return entity
end

function ns.QuestieAvailable()
    return apiEntity("Npc") ~= nil
end

function ns.QuestieNPC(id)
    if not validID(id) then return nil end
    local api = apiEntity("Npc")
    if not api then return nil end
    if npcCache[id] then return npcCache[id].result end
    local name = cleanName(readGetter(api, "name", id))
    local zoneID = readGetter(api, "zoneID", id)
    if not validID(zoneID) then zoneID = nil end
    -- One spawn is only a possible location; do NOT treat the zone ID as a uiMapID.
    local spawnZone, spawnX, spawnY
    local raw = readGetter(api, "spawns", id)
    if type(raw) == "table" then
        local found = 0
        for zone, locations in pairs(raw) do
            if type(locations) == "table" then
                for _, pair in pairs(locations) do
                    if type(pair) == "table" and type(pair[1]) == "number" and
                       type(pair[2]) == "number" and pair[1] >= 0 and pair[1] <= 100 and
                       pair[2] >= 0 and pair[2] <= 100 then
                        found = found + 1
                        if found == 1 then
                            spawnZone, spawnX, spawnY = zone, pair[1], pair[2]
                        else
                            spawnZone, spawnX, spawnY = nil, nil, nil
                            break
                        end
                    end
                end
            end
            if found > 1 then break end
        end
        if not validID(spawnZone) then spawnZone, spawnX, spawnY = nil, nil, nil end
    end
    local result
    if name or zoneID or spawnZone then
        result = {name = name, zoneID = zoneID, spawnZoneID = spawnZone,
                  spawnX = spawnX, spawnY = spawnY}
    end
    remember(npcCache, id, {kind = "npc", result = result})
    return result
end

function ns.QuestieItemName(id)
    if not validID(id) then return nil end
    local api = apiEntity("Item")
    if not api then return nil end
    if itemCache[id] then return itemCache[id].result end
    local result = cleanName(readGetter(api, "name", id))
    remember(itemCache, id, {kind = "item", result = result})
    return result
end
