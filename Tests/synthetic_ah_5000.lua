-- Reproduces user's ~5,000-auction scenario without connecting to WoW/AH server.
local path=assert(...)
local frame
function CreateFrame()
    local f={events={}}
    function f:RegisterEvent(e) self.events[e]=true end
    function f:SetScript(e,fn) self[e]=fn end
    frame=f
    return f
end
local timestamp=1700001000
function GetServerTime() return timestamp end
function InCombatLockdown() return false end
function GetNormalizedRealmName() return "Testrealm" end
function UnitFactionGroup() return "Horde" end
local queue={}
C_Timer={After=function(seconds,fn)queue[#queue+1]=fn end}
local count=5000
local incomplete=false
local replicateCalls=0
C_AuctionHouse={
    ReplicateItems=function() replicateCalls=replicateCalls+1 end,
    GetNumReplicateItems=function() return count end,
    GetReplicateItemInfo=function(i)
        return "Item", nil, 5,nil,nil,nil,nil,nil,nil,15000,
               nil,nil,nil,nil,nil,nil,900001, not incomplete or i~=0
    end,
}
local ns={db={observedVendors={}},Log=function()end,RefreshUI=function()end,
    Money=function(n) return tostring(n).." copper" end}
assert(loadfile(path.."/AuctionScanner.lua"))("WoWMarket",ns)
frame.OnEvent(frame,"AUCTION_HOUSE_SHOW")
local function drain()
    local processed=0
    while #queue>0 do
        local f=table.remove(queue,1)
        f()
        processed=processed+1
        assert(processed<=5000,"unexpected loop")
    end
end
assert(ns.StartAuctionScan(),"full scan request not started")
frame.OnEvent(frame,"REPLICATE_ITEM_LIST_UPDATE")
drain()
assert(replicateCalls==1,"unexpected multiple server requests")
assert(ns.db.auctionSnapshot and ns.db.auctionSnapshot.auctions==5000 and not ns.db.auctionSnapshot.partial,
    "5,000 auctions were not fully processed")
assert(ns.AuctionPrice(900001).minUnitCopper==3000,"incorrect 5k unit price")
local original=ns.db.auctionSnapshot
assert(not ns.StartAuctionScan(),"server cooldown should remain after success")
-- A later incomplete response must not destroy the last valid snapshot.
timestamp=timestamp+901
incomplete=true
assert(ns.StartAuctionScan(),"new scan after successful cooldown did not start")
frame.OnEvent(frame,"REPLICATE_ITEM_LIST_UPDATE")
drain()
assert(ns.db.auctionSnapshot==original,"partial scan overwrote usable snapshot")
assert(ns.AuctionPrice(900001).minUnitCopper==3000,"valid older quote lost")
-- A failed request does not create a new 15min lock or corrupt the previous result.
timestamp=timestamp+901
C_AuctionHouse.ReplicateItems=function() error("simulated request failure") end
assert(not ns.StartAuctionScan(),"failed server call incorrectly reported as success")
assert(ns.db.auctionSnapshot==original,"failed call damaged snapshot")
assert(not ns.StartAuctionScan(),"request-spam guard did not apply")
print("PASS: 5,000 auctions; server cooldown on success; partial result preserves old prices; failed call remains safe")
