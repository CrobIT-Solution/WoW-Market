-- Synthetic WoW UI test. Does not replace an actual game-client test.
local path = assert(..., "WoWMarket addon folder required")
_G.unpack=table.unpack
local frames,texts,edits={}, {}, {}
local function fake(kind,name,parent)
    local f={kind=kind,name=name,parent=parent,shown=false,scripts={},value="",width=1920,height=1080}
    function f:SetText(t) self.value=t end
    function f:GetText() return self.value end
    function f:SetScript(k,fn) self.scripts[k]=fn end
    function f:GetScript(k) return self.scripts[k] end
    function f:Show() self.shown=true; if self.scripts.OnShow then self.scripts.OnShow(self) end end
    function f:Hide() self.shown=false; if self.scripts.OnHide then self.scripts.OnHide(self) end end
    function f:SetShown(value) if value then self:Show() else self:Hide() end end
    function f:IsShown() return self.shown end
    function f:CreateFontString() local t=fake("FontString",nil,self);texts[#texts+1]=t;return t end
    function f:CreateTexture() return fake("Texture",nil,self) end
    function f:CreateAnimationGroup() return fake("AnimGroup",nil,self) end
    function f:RegisterEvent(event) self.events=rawget(self,"events") or {};self.events[event]=true end
    function f:SetFrameLevel(l) self.level=l end
    function f:GetFrameLevel() return self.level or 1 end
    function f:GetWidth() return self.width end
    function f:GetHeight() return self.height end
    function f:SetSize(w,h) self.width,self.height=w,h end
    function f:SetHeight(h) self.height=h end
    function f:SetWidth(w) self.width=w end
    function f:GetStringHeight() return 100 end
    function f:GetVerticalScroll() return self.scroll or 0 end
    function f:SetVerticalScroll(v) self.scroll=v end
    function f:ClearFocus() self.focus=false end
    function f:SetFocus() self.focus=true end
    function f:HighlightText() end
    local noop=function() end
    setmetatable(f,{__index=function(_,key) return noop end})
    return f
end
function CreateFrame(kind,name,parent,template)
    local f=fake(kind,name,parent)
    frames[#frames+1]=f
    if kind=="EditBox" then edits[#edits+1]=f end
    return f
end
UIParent=fake("Frame","UIParent",nil)
UISpecialFrames={}
SlashCmdList={}
function GetServerTime()return 1700000000 end
function InCombatLockdown()return false end
CrobITMarketData={schema=1, provider="noch nicht importiert", attributionUrl="", credit="", license="", licenseUrl="", vendors={}}
CrobITMarketDB={schema=1,observedVendors={}}
local ns={}
assert(loadfile(path.."/Core.lua"))("WoWMarket",ns)
assert(loadfile(path.."/VendorSearch.lua"))("WoWMarket",ns)
assert(loadfile(path.."/Links.lua"))("WoWMarket",ns)
ns.AuctionStatus=function()return "Keine AH-Daten" end
ns.AuctionPrice=function()return nil end
ns.StartAuctionScan=function()return true end
local requestedItem
ns.StartTargetedAuctionSearch=function(id)requestedItem=id;return true end
ns.ShowVendorMap=function()return true end
ns.SetVendorWaypoint=function()return true end
ns.VendorCaptureStatus=function()return "Noch kein Haendler besucht." end
assert(loadfile(path.."/UI.lua"))("WoWMarket",ns)
ns.InitDatabase()
ns.InitUI()
local main
for _,f in ipairs(frames) do if f.name=="CrobITMarketWindow" then main=f end end
assert(main,"main game window missing")
local registered=false
for _,name in ipairs(UISpecialFrames) do if name=="CrobITMarketWindow" then registered=true end end
assert(registered,"ESC registration missing")
local function btn(caption)
    for _,f in ipairs(frames) do
        if f.kind=="Button" and rawget(f,"text") and f.text.value==caption then return f end
    end
    error("button not found: "..caption)
end
local function anyText(needle)
    for _,f in ipairs(texts) do
        if type(f.value)=="string" and f.value:find(needle,1,true) then return f.value end
    end
    return nil
end
assert(#edits >= 2,"expected URL and search editboxes")
ns.ShowUI()
assert(main:IsShown(),"UI did not open")
edits[2]:SetText("Rezept")
btn("Suchen").scripts.OnClick(btn("Suchen"))
assert(anyText("Keine Treffer fuer 'Rezept'"),"search did not explain missing data")
assert(anyText("Suche: Rezept"),"preview did not reflect query")
CrobITMarketDB.observedVendors[123]={id=123,name="Herbalist",zone="Waldtal",x=42.6,y=65.3,mapID=15,
    items={[9001]={name="Rezept: Test",priceCopper=9000,stackCount=1,numAvailable=-1,hasExtendedCost=false}}}
ns.RefreshUI()
assert(anyText("Rezept: Test"),"observed vendor search did not update")
assert(btn("AH-Preis zu diesem Item"):IsShown(),"manual targeted quote button hidden")
btn("AH-Preis zu diesem Item").scripts.OnClick(btn("AH-Preis zu diesem Item"))
assert(requestedItem==9001,"targeted AH query did not use selected item ID")
-- The map pane uses existing game map art only when a real mapID is known.
C_Map={
    GetMapArtLayers=function(mapID)
        assert(mapID==15)
        return {{layerWidth=512,layerHeight=512,tileWidth=256,tileHeight=256}}
    end,
    GetMapArtLayerTextures=function(mapID,layerIndex)
        assert(mapID==15 and layerIndex==1)
        return {20001,20002,20003,20004}
    end,
}
btn("Karte").scripts.OnClick(btn("Karte"))
assert(anyText("Waldtal  |  42.6 / 65.3"),"real map preview or coordinate marker not shown")
btn("Suche").scripts.OnClick(btn("Suche"))
-- A client-cached item may be displayed only as a separate, unverified item.
C_Item={GetItemInfo=function(query)
    if query==2589 then return "Leinenstoff", "|Hitem:2589:0|h[Leinenstoff]|h" end
    return nil
end}
edits[2]:SetText("2589")
btn("Suchen").scripts.OnClick(btn("Suchen"))
assert(anyText("Leinenstoff"),"cached ID lookup failed")
assert(anyText("kein Haendler"),"client-cache result incorrectly claimed verified vendor")
assert(not btn("Zone auf Weltkarte"):IsShown(),"unverified cache result claimed a map")
edits[2].scripts.OnEscapePressed(edits[2])
assert(not main:IsShown(),"ESC in search field did not close")
ns.ShowUI()
btn("X").scripts.OnClick(btn("X"))
assert(not main:IsShown(),"X click did not close main window")
print("PASS: UI startup, search no-data feedback, local vendor result, cached item notice, targeted AH button, ESC and X")
