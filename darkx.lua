-- Dark X using SoloX UI
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/lukaweba19-cell/SoloX/refs/heads/main/ui.lua"))()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local Remote = RS:WaitForChild("Interaction"):WaitForChild("RemoteProxy")

local S = {autoFarm=false, autoChop=false, autoBuy=false, selectedTree=nil, selectedSawmill=nil, selectedWood=nil, woodColor=nil}

local function msg(t,x) game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=x,Duration=3}) end
local function hrp() local c=player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c=player.Character return c and c:FindFirstChildOfClass("Humanoid") end

local function getAxe()
    for _,t in pairs(player.Backpack:GetChildren()) do if t:FindFirstChild("AxeClass") or t.Name:find("Axe") then return t end end
    local c=player.Character
    if c then for _,t in pairs(c:GetChildren()) do if t:FindFirstChild("AxeClass") or t.Name:find("Axe") then return t end end end
end

local function getTrees()
    local o={}
    for _,r in pairs(workspace:GetChildren()) do
        if r.Name=="TreeRegion" then
            for _,t in pairs(r:GetChildren()) do
                if t:FindFirstChild("TreeClass") and t:FindFirstChild("CutEvent") then table.insert(o,t) end
            end
        end
    end
    return o
end

local function getOwned()
    local o={}
    for _,i in pairs(workspace:GetChildren()) do
        if i:FindFirstChild("Owner") and i.Owner.Value==player then table.insert(o,i) end
    end
    return o
end

local function chop(tree)
    local axe=getAxe()
    if not axe then msg("Dark X","u need an axe") return end
    local ev=tree:FindFirstChild("CutEvent")
    if not ev then return end
    for s=1,4 do Remote:FireServer(ev,{tool=axe,hitPoints=10,faceVector=Vector3.new(1,0,0),height=0.3,sectionId=s,cooldown=0}) task.wait(0.05) end
    msg("Dark X","cut done")
end

local function bring(m)
    local h=hrp() if not h or not m.PrimaryPart then return end
    m:SetPrimaryPartCFrame(h.CFrame*CFrame.new(0,0,-8))
end

local function bringAll(list)
    local h=hrp() if not h then return end
    for i,m in ipairs(list) do if m.PrimaryPart then m:SetPrimaryPartCFrame(h.CFrame*CFrame.new((i%5)*4,2,-8-math.floor(i/5)*4)) end end
end

local function tp(p) local h=hrp() if h then h.CFrame=CFrame.new(p) end end

local function fireRemote(name)
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true) or rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then
        if r:IsA("RemoteFunction") then r:InvokeServer(name) else r:FireServer(name) end
    end
end

-- Locations from disassembly
local locs = {
    ["Wood R Us"] = Vector3.new(270, 4, 60),
    ["Spawn"] = Vector3.new(174, 10.5, 66),
    ["Land Store"] = Vector3.new(270, 3, -98),
    ["Bridge"] = Vector3.new(112, 37, -892),
    ["Dock"] = Vector3.new(1136, 0, -206),
    ["Palm"] = Vector3.new(2614, -4, -34),
    ["Cave"] = Vector3.new(3590, -177, 415),
    ["Volcano"] = Vector3.new(-1588, 623, 1069),
    ["Swamp"] = Vector3.new(-1216, 131, -822),
    ["Fancy Furnishings"] = Vector3.new(486, 3, -1722),
    ["Boxed Cars"] = Vector3.new(509, 3, -1458),
    ["Ice Mountain"] = Vector3.new(1487, 415, 3259),
    ["Links Logic"] = Vector3.new(4615, 7, -794),
    ["Bobs Shack"] = Vector3.new(292, 8, -2544),
    ["Fine Arts Store"] = Vector3.new(5217, -166, 721),
    ["Shrine Of Sight"] = Vector3.new(-1608, 195, 928),
    ["Strange Man"] = Vector3.new(1071, 16, 1141),
    ["Volcano Win"] = Vector3.new(-1667, 349, 1474),
    ["Ski Lodge"] = Vector3.new(1244, 59, 2290),
    ["Fur Wood"] = Vector3.new(-1080, -5, -942),
}

local colors = {
    Pine=Color3.fromRGB(163,162,165), Fir=Color3.fromRGB(86,66,54), Birch=Color3.fromRGB(255,255,255),
    ["Lime green"]=Color3.fromRGB(0,255,0), ["Dark red"]=Color3.fromRGB(140,0,0), ["Really red"]=Color3.fromRGB(255,0,0),
    ["Deep blue"]=Color3.fromRGB(0,0,140), ["Dark grey"]=Color3.fromRGB(50,50,50),
}

-- UI
local win = library:new("Dark X")
local woodTab = win:Tab("Wood", "rbxassetid://0")
local sawTab = win:Tab("Sawmill", "rbxassetid://0")
local axeTab = win:Tab("Axe", "rbxassetid://0")
local buildTab = win:Tab("Build", "rbxassetid://0")
local worldTab = win:Tab("World", "rbxassetid://0")
local tpTab = win:Tab("Teleport", "rbxassetid://0")

-- Wood tab
woodTab:Button("Bring Tree", function()
    local ts=getTrees() local h=hrp()
    if not h or #ts==0 then msg("Dark X","not find tree") return end
    local best,d=nil,math.huge
    for _,t in pairs(ts) do if t.PrimaryPart then local dd=(t.PrimaryPart.Position-h.Position).Magnitude if dd<d then best,d=t,dd end end end
    if best then S.selectedTree=best bring(best) msg("Dark X","Wood Selected") end
end)
woodTab:Button("Bring All Tree", function() bringAll(getTrees()) end)
woodTab:Button("Bring All Plank", function() bringAll(getOwned()) end)
woodTab:Button("Sell All Tree", function() for _,t in pairs(getTrees()) do local r=t:FindFirstChildWhichIsA("RemoteEvent",true) if r then r:FireServer("Sell") end end msg("Dark X","Sell All Tree") end)
woodTab:Toggle("Auto Chop", false, function(s)
    S.autoChop=s
    if s then task.spawn(function() while S.autoChop do local h=hrp() if h then for _,t in pairs(getTrees()) do if not S.autoChop then break end if t.PrimaryPart and (t.PrimaryPart.Position-h.Position).Magnitude<60 then chop(t) end end end task.wait(1) end end) end
end)
woodTab:Toggle("Auto Farm", false, function(s)
    S.autoFarm=s
    if s then task.spawn(function() while S.autoFarm do local ts=getTrees() if #ts>0 then bring(ts[1]) task.wait(0.3) chop(ts[1]) end task.wait(2) end end) end
end)
woodTab:Button("Click one Wood", function()
    msg("Dark X","Click one Wood")
    local c c=UIS.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then local t=player:GetMouse().Target if t then local m=t:FindFirstAncestorOfClass("Model") if m and m:FindFirstChild("TreeClass") then S.selectedWood=m msg("Dark X","Wood Selected") c:Disconnect() end end end end)
end)
woodTab:Button("Mod Wood", function()
    if not S.selectedWood then msg("Dark X","select Wood At First") return end
    if not S.woodColor then msg("Dark X","u cant mod this wood") return end
    for _,p in pairs(S.selectedWood:GetDescendants()) do if p:IsA("BasePart") and (p.Name=="BuildDependentWood" or p.Name=="Main") then p.Color=S.woodColor end end
end)
woodTab:Button("Cut Tree Joints", function() if not S.selectedTree then msg("Dark X","select Wood At First") return end chop(S.selectedTree) end)
woodTab:Button("Find Spooky Wood", function()
    for _,t in pairs(getTrees()) do if t:FindFirstChild("TreeClass") and t.TreeClass.Value:find("Spooky") then bring(t) msg("Dark X","Found") return end end
    msg("Dark X","Not Found")
end)
for n,c in pairs(colors) do woodTab:Button(n, function() S.woodColor=c msg("Dark X",n) end) end

-- Sawmill tab
sawTab:Button("Select Sawmill", function()
    msg("Dark X","Click one Sawmill")
    local c c=UIS.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then local t=player:GetMouse().Target if t then local m=t:FindFirstAncestorOfClass("Model") if m and m.Name:find("Sawmill") then S.selectedSawmill=m msg("Dark X","Sawmill Selected") c:Disconnect() end end end end)
end)
sawTab:Button("Max Settings", function()
    if not S.selectedSawmill then msg("Dark X","select Sawmail At First") return end
    for _,v in pairs(S.selectedSawmill:GetDescendants()) do if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value=100 end end
end)
sawTab:Button("Lowest Settings", function()
    if not S.selectedSawmill then msg("Dark X","select Sawmail At First") return end
    for _,v in pairs(S.selectedSawmill:GetDescendants()) do if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value=1 end end
end)
sawTab:Button("Plank Size 1", function()
    for _,item in pairs(getOwned()) do if item:FindFirstChild("Main") and item.Main:IsA("BasePart") then item.Main.Size=Vector3.new(1,1,1) end end
end)

-- Axe tab
axeTab:Button("Auto Dupe Axe", function()
    if not getAxe() then msg("Dark X","u need one axe") return end
    fireRemote("Dupe") msg("Dark X","now u can save the slot")
end)
axeTab:Button("Dupe Power", function() fireRemote("Dupe Power") msg("Dark X","Dupe Power") end)
axeTab:Button("Pick Up Axe", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("ToolName") then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Pick up tool") end
        end
    end
end)
axeTab:Button("Calm Rukiryaxe", function()
    local axe=getAxe()
    if axe and axe.Name:find("Rukiryaxe") then local r=axe:FindFirstChildWhichIsA("RemoteEvent",true) if r then r:FireServer("Calm") end end
end)

-- Build tab
buildTab:Button("Save Base", function() fireRemote("Save") msg("Dark X","Save Base success") end)
buildTab:Button("Load Base", function() fireRemote("Load") msg("Dark X","Load Base") end)
buildTab:Button("Fast Load", function() fireRemote("FastLoad") msg("Dark X","Fast Load") end)
buildTab:Button("Free Land", function() fireRemote("Free Land") msg("Dark X","Free Land") end)
buildTab:Button("Max Land", function() fireRemote("Max Land") msg("Dark X","Max Land") end)
buildTab:Button("Land Art", function() fireRemote("Land Art") msg("Dark X","Land Art") end)
buildTab:Button("Get Blueprint", function() fireRemote("Open box") msg("Dark X","Open box") end)
buildTab:Button("Get All Blueprint", function() fireRemote("Get All blueprint") end)
buildTab:Button("Fill All Blueprint", function() fireRemote("Fill All blueprint") end)
buildTab:Toggle("Auto Buy", false, function(s) S.autoBuy=s if s then task.spawn(function() while S.autoBuy do fireRemote("Buy") task.wait(1) end end) end end)
buildTab:Button("Take Down Sold Sign", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("ItemName") then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Take down sold sign") end
        end
    end
end)
buildTab:Button("Slot Save", function() fireRemote("Slot") msg("Dark X","Slot saved successfully") end)

-- World tab
worldTab:Button("Always Day", function() Lighting.ClockTime=14 end)
worldTab:Button("Always Night", function() Lighting.ClockTime=0 end)
worldTab:Button("Toggle Shadows", function() Lighting.GlobalShadows=not Lighting.GlobalShadows end)
worldTab:Button("Remove Fog", function() Lighting.FogEnd=100000 end)
worldTab:Button("Remove Water", function() for _,p in pairs(workspace:GetDescendants()) do if p:IsA("BasePart") and p.Name=="Water" then p:Destroy() end end end)
worldTab:Button("Remove Boulders", function() for _,p in pairs(workspace:GetDescendants()) do if p.Name:find("Boulder") then p:Destroy() end end end)
worldTab:Toggle("Fly", false, function(s) local h=hum() if h then h.PlatformStand=s end end)
worldTab:Toggle("Inf Jump", false, function(s) if s then UIS.JumpRequest:Connect(function() local h=hum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) end end)
worldTab:Button("Zoom", function() player.CameraMaxZoomDistance=500 end)
worldTab:Button("Tp to Base", function()
    for _,item in pairs(getOwned()) do if item.PrimaryPart then tp(item.PrimaryPart.Position) return end end
    msg("Dark X","Player Not Have Base")
end)

-- Teleport tab
for name, pos in pairs(locs) do
    tpTab:Button(name, function() tp(pos) end)
end

print("Dark X SoloX loaded")
