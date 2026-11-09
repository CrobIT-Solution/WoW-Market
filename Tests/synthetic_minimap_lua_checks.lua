-- WoW-Market Minimap-UI: rein synthetischer Test ohne WoW-Client.
local path = assert(...)
local frames = {}
local visible = false
local sourceCount = 0
local parent = {
    GetCenter = function() return 500, 400 end,
    GetEffectiveScale = function() return 1 end,
    GetFrameLevel = function() return 3 end,
}
Minimap = parent
local btn
function GetCursorPosition() return 500, 500 end
function CreateFrame(kind, name, frameParent)
    local f = {name=name, parent=frameParent, scripts={}}
    function f:RegisterEvent(event) self.events=self.events or {}; self.events[event]=true end
    function f:SetScript(event, fn) self.scripts[event] = fn end
    function f:GetScript(event) return self.scripts[event] end
    function f:SetSize() end
    function f:SetFrameStrata() end
    function f:SetFrameLevel(level) self.level=level end
    function f:EnableMouse() end
    function f:RegisterForClicks(...) self.clicks={...} end
    function f:RegisterForDrag(...) self.drags={...} end
    function f:SetNormalTexture(t) self.normal=t end
    function f:SetHighlightTexture(t) self.highlight=t end
    function f:ClearAllPoints() end
    function f:SetPoint(_, _, _, x, y) self.x, self.y=x,y end
    function f:CreateTexture()
        local t={}
        function t:SetTexture(v) self.path=v end
        function t:SetSize() end
        function t:SetPoint() end
        function t:SetTexCoord() end
        return t
    end
    frames[#frames+1]=f
    if name == "WoWMarketMinimapButton" then btn=f end
    return f
end
local ns={db={},ToggleUI=function() visible=not visible end,
    OpenSources=function() sourceCount=sourceCount+1 end}
assert(loadfile(path .. "/Minimap.lua"))("WoWMarket",ns)
for _,f in ipairs(frames) do
    if f.events and f.events.PLAYER_LOGIN then f.scripts.OnEvent(f,"PLAYER_LOGIN") end
end
assert(btn~=nil and btn.parent==Minimap and btn.level==9, "Minimap-Schaltflaeche fehlt")
assert(type(btn.x)=="number" and type(btn.y)=="number", "Minimap-Position fehlt")
assert(btn.clicks[1]=="LeftButtonUp" and btn.clicks[2]=="RightButtonUp", "Klickrichtungen falsch")
btn.scripts.OnClick(btn,"LeftButton")
assert(visible,"Linksklick muss oeffnen")
btn.scripts.OnClick(btn,"LeftButton")
assert(not visible,"Linksklick muss schliessen")
btn.scripts.OnClick(btn,"RightButton")
assert(sourceCount==1,"Rechtsklick muss Quellenreiter oeffnen")
local oldX=btn.x
btn.scripts.OnDragStart(btn)
assert(btn.scripts.OnUpdate~=nil and ns.db.minimapAngle==90, "Ziehen aktualisiert Winkel nicht")
assert(math.abs(btn.x)<0.001 and btn.y>0, "Position oben falsch")
btn.scripts.OnDragStop(btn)
assert(btn.scripts.OnUpdate==nil,"Drag muss Update stoppen")
-- Wiederinitialisierung erzeugt kein zweites Symbol; gueltige gespeicherte Position bleibt.
local count=#frames
ns.InitMinimap()
assert(#frames==count, "Mehrfachinitialisierung erzeugt Duplikate")
-- Keyboards/Commands are not needed: all UI actions are reachable from click handlers.
assert(not (btn.normal or ""):match("https"), "Minimap-Textur darf keine Webseite sein")
print("PASS: Minimap links/rechts, Drag/Persistenz, Position, ohne Chatbefehle oder Internet")
