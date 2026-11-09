-- Test a WoW Forever merchant API path without legacy GetMerchantItemID/Count.
local path=assert(...)
_G.unpack=table.unpack
GetMerchantNumItems=nil
GetMerchantItemID=nil
GetMerchantItemLink=nil
local events={}
function CreateFrame()
 local f={}
 function f:RegisterEvent(e) events[e]=self end
 function f:SetScript(k,fn) self[k]=fn end
 return f
end
CrobITMarketData={schema=1,vendors={}}
CrobITMarketDB={}
function GetServerTime()return 1700000000 end
function InCombatLockdown()return false end
function UnitGUID()return 'Creature-0-0-0-0-221-012' end
function UnitName()return 'ModernMerchant' end
function GetZoneText()return 'ModernZone' end
function strsplit(d,s)local t={} for x in (s..d):gmatch('(.-)'..d)do t[#t+1]=x end return table.unpack(t)end
C_MerchantFrame={
  GetNumItems=function()return 2 end,
  GetItemInfo=function(index)
    if index==1 then return {name='Rezept: Test',price=15000,stackCount=1,numAvailable=-1,hasExtendedCost=false} end
    return {name='Waren: Nahrung',price=250,stackCount=5,numAvailable=3,hasExtendedCost=false}
  end,
  GetItemLink=function(index)return 'item:'..(index==1 and 8888 or 9999)..':0' end,
}
local ns={}
SlashCmdList={}
assert(loadfile(path..'/Core.lua'))('WoWMarket',ns)
assert(loadfile(path..'/VendorScanner.lua'))('WoWMarket',ns)
assert(loadfile(path..'/VendorSearch.lua'))('WoWMarket',ns)
ns.InitUI=function()end
ns.RefreshUI=function()end
ns.InitDatabase()
events.MERCHANT_SHOW.OnEvent(events.MERCHANT_SHOW,'MERCHANT_SHOW')
local vendor=ns.db.observedVendors[221]
assert(vendor and vendor.name=='ModernMerchant','modern merchant not saved')
assert(vendor.items[8888].name=='Rezept: Test','recipe not indexed from item link')
local res,total=ns.Search('Rezept',10)
assert(total==1 and res[1].itemID==8888,'recipe text search broken in modern merchant path')
print('PASS: modern merchant API count/link fallback and recipe indexing')
