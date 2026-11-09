-- SPDX-License-Identifier: GPL-3.0-only
local _, ns = ...
local function lower(value)
    return string.lower(tostring(value or ""))
end

function ns.GetCounts()
    local referenceCount, observedCount, itemCount = 0, 0, 0
    for _, vendor in pairs(ns.reference.vendors or {}) do
        referenceCount = referenceCount + 1
        for _ in pairs(vendor.items or {}) do itemCount = itemCount + 1 end
    end
    for _ in pairs((ns.db and ns.db.observedVendors) or {}) do
        observedCount = observedCount + 1
    end
    return referenceCount, observedCount, itemCount
end

local function mergedEntries(visitor)
    local refs = ns.reference.vendors or {}
    local observed = (ns.db and ns.db.observedVendors) or {}
    for vendorKey, reference in pairs(refs) do
        local localRecord = observed[vendorKey]
        local base = localRecord or reference
        local allItems = {}
        for id, item in pairs(reference.items or {}) do
            allItems[id] = {item = item, status = reference.seenInForever and "Forever bestaetigt" or "Referenz"}
        end
        if localRecord then
            for id, item in pairs(localRecord.items or {}) do
                allItems[id] = {item = item, status = "Im Spiel gesehen"}
            end
        end
        visitor(base, allItems, (localRecord and "Im Spiel gesehen") or
            (reference.seenInForever and "Forever bestaetigt" or "Referenz"))
    end
    for vendorKey, localRecord in pairs(observed) do
        if not refs[vendorKey] then
            local items = {}
            for id, item in pairs(localRecord.items or {}) do
                items[id] = {item = item, status = "Im Spiel gesehen"}
            end
            visitor(localRecord, items, "Im Spiel gesehen")
        end
    end
end

-- Bounded best-results heap: never retain an unbounded number of search hits.
-- Order is deterministic: observed first, then confirmed, then reference;
-- for equal quality, ordinary copper-only prices before unknown/extra costs.
local priority = { ["Im Spiel gesehen"] = 1, ["Forever bestaetigt"] = 2, ["Referenz"] = 3 }
local function better(a, b)
    local ap, bp = priority[a.status] or 4, priority[b.status] or 4
    if ap ~= bp then return ap < bp end
    local aUnit = (a.hasExtendedCost == false and type(a.priceCopper) == "number"
            and type(a.stackCount) == "number" and a.stackCount >= 1)
        and a.priceCopper / a.stackCount or math.huge
    local bUnit = (b.hasExtendedCost == false and type(b.priceCopper) == "number"
            and type(b.stackCount) == "number" and b.stackCount >= 1)
        and b.priceCopper / b.stackCount or math.huge
    if aUnit ~= bUnit then return aUnit < bUnit end
    if a.vendorName ~= b.vendorName then return a.vendorName < b.vendorName end
    if a.itemName ~= b.itemName then return a.itemName < b.itemName end
    return tostring(a.npcID or "") .. ":" .. tostring(a.itemID or "") <
        tostring(b.npcID or "") .. ":" .. tostring(b.itemID or "")
end

function ns.Search(input, limit)
    -- Keep memory bounded, even with tens of thousands of vendor entries.
    limit = math.max(1, math.min(tonumber(limit) or 250, 500))
    local query = lower(input):gsub("^%s+", ""):gsub("%s+$", "")
    local numericQuery = tonumber(query)
    local heap, matched = {}, 0
    local function collect(result)
        matched = matched + 1
        if #heap < limit then
            local i = #heap + 1
            heap[i] = result
            -- Root is worst candidate.
            while i > 1 do
                local parent = math.floor(i / 2)
                if not better(heap[parent], heap[i]) then break end
                heap[i], heap[parent] = heap[parent], heap[i]
                i = parent
            end
        elseif better(result, heap[1]) then
            heap[1] = result
            local i = 1
            while true do
                local left, right = i * 2, i * 2 + 1
                local worst = i
                if left <= #heap and better(heap[worst], heap[left]) then worst = left end
                if right <= #heap and better(heap[worst], heap[right]) then worst = right end
                if worst == i then break end
                heap[i], heap[worst] = heap[worst], heap[i]
                i = worst
            end
        end
    end
    mergedEntries(function(vendor, items, vendorStatus)
        local vendorName = tostring(vendor.name or "Unbekannt")
        local zone = tostring(vendor.zone or "Unbekannt")
        local questieNPC
        local vendorFromQuestie = false
        -- Only supplement obviously unresolved data, never override local observations.
        if type(vendor.id) == "number" and ns.QuestieNPC and
           (vendorName:find("(Name unbekannt)", 1, true) or zone == "Standort nicht belegt" or zone == "Unbekannt") then
            questieNPC = ns.QuestieNPC(vendor.id)
            if questieNPC and questieNPC.name and vendorName:find("(Name unbekannt)", 1, true) then
                vendorName = questieNPC.name
                vendorFromQuestie = true
            end
        end
        if query == "" then
            local total = 0
            for _ in pairs(items) do total = total + 1 end
            collect({
                vendorName = vendorName, zone = zone, itemName = total .. " Warenpositionen",
                priceCopper = nil, stackCount = 1, status = vendorStatus,
                mapID = vendor.mapID, x = vendor.x, y = vendor.y, npcID = vendor.id,
                questieNPC = questieNPC, vendorFromQuestie = vendorFromQuestie,
            })
        else
            local vendorMatch = lower(vendorName):find(query, 1, true) ~= nil
            for itemID, info in pairs(items) do
                local itemName = tostring(info.item.name or "Unbekannt")
                local itemFromQuestie = false
                if itemName:find("(Name unbekannt)", 1, true) and ns.QuestieItemName then
                    local resolved = ns.QuestieItemName(itemID)
                    if resolved then itemName, itemFromQuestie = resolved, true end
                end
                if vendorMatch or (numericQuery and numericQuery == itemID) or
                    lower(itemName):find(query, 1, true) ~= nil then
                    collect({
                        vendorName = vendorName, zone = zone, itemID = itemID,
                        itemName = itemName, priceCopper = info.item.priceCopper,
                        stackCount = info.item.stackCount or 1,
                        numAvailable = info.item.numAvailable,
                        hasExtendedCost = info.item.hasExtendedCost,
                        status = info.status, mapID = vendor.mapID,
                        npcID = vendor.id, x = vendor.x, y = vendor.y,
                        questieNPC = questieNPC, vendorFromQuestie = vendorFromQuestie,
                        itemFromQuestie = itemFromQuestie,
                    })
                end
            end
        end
    end)
    table.sort(heap, better)
    return heap, matched
end
