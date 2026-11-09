-- Only explicit user clicks can open the map / replace a user waypoint.
local _, ns = ...
local function validPosition(result)
    if type(result) ~= "table" or type(result.mapID) ~= "number" or
       result.mapID <= 0 or result.mapID ~= math.floor(result.mapID) then
        return false
    end
    return type(result.x) == "number" and type(result.y) == "number" and
        result.x >= 0 and result.x <= 100 and result.y >= 0 and result.y <= 100
end
function ns.ShowVendorMap(result)
    if type(result) ~= "table" or type(result.mapID) ~= "number" then
        ns.Log("Fuer diesen Haendler ist keine Karten-ID bekannt.")
        return false
    end
    if InCombatLockdown and InCombatLockdown() then
        ns.Log("Weltkarte erst nach dem Kampf oeffnen.")
        return false
    end
    if not C_Map or type(C_Map.OpenWorldMap) ~= "function" then
        ns.Log("Karten-API in dieser Spielversion nicht verfuegbar.")
        return false
    end
    C_Map.OpenWorldMap(result.mapID)
    ns.Log("Zone geoeffnet: " .. tostring(result.zone or result.mapID) ..
        (validPosition(result) and string.format(" (%.1f / %.1f)", result.x, result.y) or ""))
    return true
end
function ns.SetVendorWaypoint(result)
    if not validPosition(result) then
        ns.Log("Kein bestaetigter Kartenpunkt fuer diesen Haendler bekannt.")
        return false
    end
    if InCombatLockdown and InCombatLockdown() then
        ns.Log("Wegpunkt erst nach dem Kampf setzen.")
        return false
    end
    if not C_Map or type(C_Map.SetUserWaypoint) ~= "function" or
       type(C_Map.CanSetUserWaypointOnMap) ~= "function" or
       not UiMapPoint or type(UiMapPoint.CreateFromCoordinates) ~= "function" or
       not C_Map.CanSetUserWaypointOnMap(result.mapID) then
        ns.Log("Wegpunktfunktion fuer diese Karte nicht verfuegbar.")
        return false
    end
    local point = UiMapPoint.CreateFromCoordinates(result.mapID, result.x / 100, result.y / 100)
    if not point or not C_Map.SetUserWaypoint(point) then
        ns.Log("Wegpunkt konnte nicht gesetzt werden.")
        return false
    end
    ns.Log("Wegpunkt fuer " .. tostring(result.vendorName or "Haendler") .. " gesetzt.")
    return true
end
