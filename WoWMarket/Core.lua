-- SPDX-License-Identifier: GPL-3.0-only
local addonName, ns = ...

ns.version = "0.0.8-alpha"
ns.reference = (CrobITMarketData and CrobITMarketData.schema == 1) and CrobITMarketData or {
    schema = 1, provider = "keine", attributionUrl = "", license = "", licenseUrl = "", credit = "", dataAsOf = "", vendors = {},
}

function ns.Log(message)
    print("|cff62e454WoW-Market:|r " .. tostring(message))
end

function ns.IsReadable(value)
    return value ~= nil and (not issecretvalue or not issecretvalue(value))
end

function ns.Money(copper)
    if type(copper) ~= "number" or copper < 0 then return "Preis unbekannt" end
    copper = math.floor(copper)
    local g = math.floor(copper / 10000)
    local s = math.floor(copper / 100) % 100
    local c = copper % 100
    return string.format("%dg %02ds %02dc", g, s, c)
end

function ns.InitDatabase()
    if type(CrobITMarketDB) ~= "table" then
        CrobITMarketDB = {}
    end
    if CrobITMarketDB.schema ~= nil and CrobITMarketDB.schema ~= 1 then
        -- Unknown future format: don't write to it or risk destroying data.
        ns.Log("Unbekannte SavedVariables-Version: Beobachtungsspeicher gesperrt (Fail-Closed).")
        return
    end
    if CrobITMarketDB.schema == nil and next(CrobITMarketDB) ~= nil then
        ns.Log("Aeltere SavedVariables erkannt: unberuehrt beibehalten, keine automatische Migration.")
    end
    CrobITMarketDB.schema = 1
    if type(CrobITMarketDB.observedVendors) ~= "table" then
        CrobITMarketDB.observedVendors = {}
    end
    ns.db = CrobITMarketDB
end

local function printSearch(text)
    local results = ns.Search(text, 8)
    if #results == 0 then
        ns.Log("Keine passenden Haendler/Waren bekannt. Importbestand ggf. noch leer.")
        return
    end
    for _, result in ipairs(results) do
        local cost = result.priceCopper and ns.Money(result.priceCopper) or "-"
        if result.hasExtendedCost then cost = cost .. " + Sonderkosten" end
        if result.stackCount and result.stackCount > 1 then
            cost = cost .. " / " .. result.stackCount .. " Stk."
        end
        ns.Log(result.vendorName .. " - " .. result.itemName .. " - " .. cost ..
            " (" .. result.zone .. ", " .. result.status .. ")")
    end
end

SLASH_CROBITMARKET1 = "/wowmarket"
SLASH_CROBITMARKET2 = "/wm"
SLASH_CROBITMARKET3 = "/crobmarket" -- Legacy: bestehende Nutzer behalten ihre Aliase.
SLASH_CROBITMARKET4 = "/cvm"
SlashCmdList.CROBITMARKET = function(raw)
    if not ns.db then return end
    local command, argument = (raw or ""):match("^(%S*)%s*(.-)%s*$")
    command = string.lower(command or "")
    if command == "" or command == "show" then
        ns.ShowUI()
    elseif command == "find" or command == "item" then
        printSearch(argument or "")
    elseif command == "status" then
        local refCount, ownCount, itemCount = ns.GetCounts()
        ns.Log(string.format("%d Referenzhaendler, %d selbst beobachtet, %d Referenz-Warenpositionen.",
            refCount, ownCount, itemCount))
        ns.Log("Externe Quelle: " .. tostring(ns.reference.provider))
        if ns.AuctionStatus then ns.Log(ns.AuctionStatus()) end
    else
        ns.Log("Befehle: /wm, /wm find <Name oder ItemID>, /wm status")
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(_, event, loadedName)
    if loadedName ~= addonName then return end
    ns.InitDatabase()
    ns.InitUI()
    ns.Log("Alpha " .. ns.version .. " geladen. Aufruf ueber das Minimap-Symbol.")
end)
