return function(library)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

local function msg(t,x) game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=x,Duration=3}) end
local function hrp() local c=player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function tp(p) local h=hrp() if h then h.CFrame=CFrame.new(p) end end

local locs = {
    ["Wood R Us"]=Vector3.new(270,4,60), ["Spawn"]=Vector3.new(174,10.5,66), ["Land Store"]=Vector3.new(270,3,-98),
    ["Bridge"]=Vector3.new(112,37,-892), ["Dock"]=Vector3.new(1136,0,-206), ["Palm"]=Vector3.new(2614,-4,-34),
    ["Cave"]=Vector3.new(3590,-177,415), ["Volcano"]=Vector3.new(-1588,623,1069), ["Swamp"]=Vector3.new(-1216,131,-822),
    ["Fancy Furnishings"]=Vector3.new(486,3,-1722), ["Ice Mountain"]=Vector3.new(1487,415,3259),
    ["Bobs Shack"]=Vector3.new(292,8,-2544), ["Ski Lodge"]=Vector3.new(1244,59,2290),
}

local win = library:new("Dark X")

local wood = win:Tab("Wood", "0"):section("Wood")
wood:Button("Bring Tree", function() msg("Dark X", "Bring") end)
wood:Button("Auto Chop", function() msg("Dark X", "Chop") end)
wood:Button("Auto Farm", function() msg("Dark X", "Farm") end)

local tp = win:Tab("TP", "0"):section("Locations")
for name, pos in pairs(locs) do
    tp:Button(name, function() tp(pos) end)
end

local world = win:Tab("World", "0"):section("World")
world:Button("Day", function() Lighting.ClockTime=14 end)
world:Button("Night", function() Lighting.ClockTime=0 end)
world:Button("No Fog", function() Lighting.FogEnd=100000 end)

print("Dark X loaded")
end
