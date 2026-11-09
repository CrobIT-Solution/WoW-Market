-- SPDX-License-Identifier: GPL-3.0-only
-- WoW-Market: eigenstaendiger Minimap-Einstieg ohne externe Bibliotheken.
-- Links: Fenster anzeigen/verbergen; rechts: Quellen & Rechtliches.
-- Linke Maustaste ziehen: Symbol um die Minimap verschieben (Winkel wird gespeichert).
-- Nur UI, keine automatisierten Spielaktionen oder Internetverbindungen.
local _, ns = ...
local iconButton
local PI = math.pi
local DEFAULT_ANGLE = 220
local DISTANCE = 80

local function usableAngle(value)
    return type(value) == "number" and value == value and value >= 0 and value <= 360
end

local function angleFromCursor()
    if not Minimap or type(GetCursorPosition) ~= "function" then return nil end
    local mx, my = Minimap:GetCenter()
    local scale = Minimap:GetEffectiveScale()
    local cx, cy = GetCursorPosition()
    if type(mx) ~= "number" or type(my) ~= "number" or
       type(scale) ~= "number" or scale <= 0 or
       type(cx) ~= "number" or type(cy) ~= "number" then return nil end
    local dx, dy = (cx / scale) - mx, (cy / scale) - my
    -- Lua 5.1 ist mit math.atan(y, x) nicht durchgaengig kompatibel.
    -- Vier Quadranten ohne Abhaengigkeit von atan2 abdecken.
    local degrees
    if dx == 0 then
        degrees = dy >= 0 and 90 or 270
    else
        degrees = math.deg(math.atan(dy / dx))
        if dx < 0 then degrees = degrees + 180 end
        if degrees < 0 then degrees = degrees + 360 end
    end
    return degrees % 360
end

local function applyAngle(degrees)
    if not iconButton or not usableAngle(degrees) then return end
    iconButton:ClearAllPoints()
    local radians = math.rad(degrees)
    iconButton:SetPoint("CENTER", Minimap, "CENTER",
        math.cos(radians) * DISTANCE, math.sin(radians) * DISTANCE)
end

local function updateDrag()
    local degrees = angleFromCursor()
    if degrees then
        applyAngle(degrees)
        if ns.db then ns.db.minimapAngle = degrees end
    end
end

function ns.InitMinimap()
    if iconButton or not ns.db or not Minimap or not Minimap.GetCenter then return end
    local b = CreateFrame("Button", "WoWMarketMinimapButton", Minimap)
    b:SetSize(32, 32)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(Minimap:GetFrameLevel() + 6)
    b:EnableMouse(true)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")
    b:SetNormalTexture("Interface\\Minimap\\UI-Minimap-TrackingBackground")
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local artwork = b:CreateTexture(nil, "ARTWORK")
    artwork:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
    artwork:SetSize(18, 18)
    artwork:SetPoint("CENTER", b, "CENTER", 0, 1)
    artwork:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local border = b:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
    iconButton = b
    local degrees = usableAngle(ns.db.minimapAngle) and ns.db.minimapAngle or DEFAULT_ANGLE
    applyAngle(degrees)

    b:SetScript("OnClick", function(_, click)
        if click == "RightButton" then
            if ns.OpenSources then ns.OpenSources() end
        elseif ns.ToggleUI then
            ns.ToggleUI()
        end
    end)
    b:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", updateDrag)
        updateDrag()
    end)
    b:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        updateDrag()
    end)
    b:SetScript("OnEnter", function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("WoW-Market", 0.34, 0.89, 0.28)
        GameTooltip:AddLine("Linksklick: Market anzeigen/verbergen", 1, 1, 1)
        GameTooltip:AddLine("Rechtsklick: Quellen & Recht", 1, 1, 1)
        GameTooltip:AddLine("Ziehen: Symbol verschieben", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
end

local listener = CreateFrame("Frame")
listener:RegisterEvent("PLAYER_LOGIN")
listener:SetScript("OnEvent", function() ns.InitMinimap() end)
