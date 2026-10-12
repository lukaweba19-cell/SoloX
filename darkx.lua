return function(library)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RS = game:GetService("ReplicatedStorage")

local function msg(t,x) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=x,Duration=3}) end) end
local function hrp() local c=player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function tp(p) local h=hrp() if h then h.CFrame=CFrame.new(p) end end

local locs = {
    ["Wood R Us"]=Vector3.new(270,4,60),["Spawn"]=Vector3.new(174,10.5,66),["Land Store"]=Vector3.new(270,3,-98),
    ["Bridge"]=Vector3.new(112,37,-892),["Dock"]=Vector3.new(1136,0,-206),["Palm"]=Vector3.new(2614,-4,-34),
    ["Cave"]=Vector3.new(3590,-177,415),["Volcano"]=Vector3.new(-1588,623,1069),["Swamp"]=Vector3.new(-1216,131,-822),
    ["Fancy Furnishings"]=Vector3.new(486,3,-1722),["Ice Mountain"]=Vector3.new(1487,415,3259),
    ["Bobs Shack"]=Vector3.new(292,8,-2544),["Ski Lodge"]=Vector3.new(1244,59,2290),
}

local ok, err = pcall(function()
    local win = library:new("Dark X")
    local woodTab = win:Tab("Wood", "0")
    local wood = woodTab:section("Wood")
    wood:Button("Bring Tree", function() msg("Dark X","Bring") end)
    wood:Button("Auto Chop", function() msg("Dark X","Chop") end)
    wood:Button("Auto Farm", function() msg("Dark X","Farm") end)
    wood:Button("Select Wood", function() msg("Dark X","Click wood") end)

    local tpTab = win:Tab("TP", "0")
    local tpSec = tpTab:section("Locations")
    for name, pos in pairs(locs) do
        tpSec:Button(name, function() tp(pos) end)
    end

    local worldTab = win:Tab("World", "0")
    local world = worldTab:section("World")
    world:Button("Day", function() Lighting.ClockTime=14 end)
    world:Button("Night", function() Lighting.ClockTime=0 end)
    world:Button("No Fog", function() Lighting.FogEnd=100000 end)
    world:Button("Fly", function() local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand=not h.PlatformStand end end)
end)
if not ok then warn("DarkX:", err) end
print("Dark X done")
end
