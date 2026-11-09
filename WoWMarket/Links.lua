-- SPDX-License-Identifier: GPL-3.0-only
-- Deterministische, rein lokale URL-Erzeugung. Keine Web-Anfragen, kein Browserstart.
local _, ns = ...

local function validID(value)
    if type(value) ~= "number" or value ~= math.floor(value) or
        value < 1 or value > 2147483647 then
        return nil
    end
    return tostring(value)
end

-- Nur feste Wowhead-Forever-Ziele; nie Freitext zu einer URL zusammensetzen.
function ns.WowheadURL(kind, id)
    local safeID = validID(id)
    if not safeID or (kind ~= "item" and kind ~= "npc") then return nil end
    return "https://www.wowhead.com/forever/" .. kind .. "=" .. safeID
end

-- Externe Attribution als reiner Textlink; kein externer Aufruf aus Lua.
function ns.SourceURL()
    local value = ns.reference and ns.reference.attributionUrl
    if type(value) ~= "string" or #value > 220 or
       not value:match("^https://[%w%.%-]+[%w%./%-_]*$") then
        return nil
    end
    -- Keine URL mit Zugangsdaten, Query, Fragment, Ports oder Sonderzeichen.
    return value
end
