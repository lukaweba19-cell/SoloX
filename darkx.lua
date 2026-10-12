return function(library)
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

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
    local remote=RS:FindFirstChild("Interaction") and RS.Interaction:FindFirstChild("RemoteProxy")
    if not remote then return end
    for s=1,4 do remote:FireServer(ev,{tool=axe,hitPoints=10,faceVector=Vector3.new(1,0,0),height=0.3,sectionId=s,cooldown=0}) task.wait(0.05) end
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
    local r=RS:FindFirstChildWhichIsA("RemoteEvent",true) or RS:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then if r:IsA("RemoteFunction") then r:InvokeServer(name) else r:FireServer(name) end end
end

local locs = {
    ["Wood R Us"]=Vector3.new(270,4,60), ["Spawn"]=Vector3.new(174,10.5,66), ["Land Store"]=Vector3.new(270,3,-98),
    ["Bridge"]=Vector3.new(112,37,-892), ["Dock"]=Vector3.new(1136,0,-206), ["Palm"]=Vector3.new(2614,-4,-34),
    ["Cave"]=Vector3.new(3590,-177,415), ["Volcano"]=Vector3.new(-1588,623,1069), ["Swamp"]=Vector3.new(-1216,131,-822),
    ["Fancy Furnishings"]=Vector3.new(486,3,-1722), ["Boxed Cars"]=Vector3.new(509,3,-1458), ["Ice Mountain"]=Vector3.new(1487,415,3259),
    ["Links Logic"]=Vector3.new(4615,7,-794), ["Bobs Shack"]=Vector3.new(292,8,-2544), ["Fine Arts Store"]=Vector3.new(5217,-166,721),
    ["Shrine Of Sight"]=Vector3.new(-1608,195,928), ["Strange Man"]=Vector3.new(1071,16,1141), ["Volcano Win"]=Vector3.new(-1667,349,1474),
    ["Ski Lodge"]=Vector3.new(1244,59,2290), ["Fur Wood"]=Vector3.new(-1080,-5,-942),
}

local colors = {Pine=Color3.fromRGB(163,162,165), Fir=Color3.fromRGB(86,66,54), Birch=Color3.fromRGB(255,255,255),
    ["Lime green"]=Color3.fromRGB(0,255,0), ["Dark red"]=Color3.fromRGB(140,0,0), ["Really red"]=Color3.fromRGB(255,0,0),
    ["Deep blue"]=Color3.fromRGB(0,0,140), ["Dark grey"]=Color3.fromRGB(50,50,50)}

-- Manual UI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "DarkX"
gui.ResetOnSpawn = false
local f = Instance.new("Frame", gui)
f.Size = UDim2.new(0, 280, 0, 400)
f.Position = UDim2.new(0.5, -140, 0.3, 0)
f.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
f.Active = true
f.Draggable = true
local corner = Instance.new("UICorner", f)
corner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", f)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Dark X"
title.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
local titleC = Instance.new("UICorner", title)
titleC.CornerRadius = UDim.new(0, 8)

local tabs = Instance.new("Frame", f)
tabs.Size = UDim2.new(1, 0, 0, 28)
tabs.Position = UDim2.new(0, 0, 0, 30)
tabs.BackgroundTransparency = 1
local tabLayout = Instance.new("UIListLayout", tabs)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 2)

local content = Instance.new("ScrollingFrame", f)
content.Size = UDim2.new(1, -8, 1, -66)
content.Position = UDim2.new(0, 4, 0, 62)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 3
content.CanvasSize = UDim2.new(0, 0, 0, 800)
local contentLayout = Instance.new("UIListLayout", content)
contentLayout.Padding = UDim.new(0, 3)

local currentTab = "Wood"
local tabButtons = {}
local tabContents = {}

local function clearContent()
    for _, c in pairs(content:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
end

local function addBtn(text, cb)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.new(1, -4, 0, 26)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.MouseButton1Click:Connect(cb)
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 4)
end

local function showTab(name)
    currentTab = name
    clearContent()
    for n, btn in pairs(tabButtons) do
        btn.BackgroundColor3 = n == name and Color3.fromRGB(140, 80, 255) or Color3.fromRGB(40, 40, 48)
    end
    if tabContents[name] then tabContents[name]() end
end

local function makeTab(name, fn)
    local b = Instance.new("TextButton", tabs)
    b.Size = UDim2.new(0, 44, 1, 0)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 10
    b.MouseButton1Click:Connect(function() showTab(name) end)
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 4)
    tabButtons[name] = b
    tabContents[name] = fn
end

makeTab("Wood", function()
    addBtn("Bring Tree", function()
        local ts=getTrees() local h=hrp()
        if not h or #ts==0 then msg("Dark X","not find tree") return end
        local best,d=nil,math.huge
        for _,t in pairs(ts) do if t.PrimaryPart then local dd=(t.PrimaryPart.Position-h.Position).Magnitude if dd<d then best,d=t,dd end end end
        if best then S.selectedTree=best bring(best) msg("Dark X","Wood Selected") end
    end)
    addBtn("Bring All", function() bringAll(getTrees()) end)
    addBtn("Bring Planks", function() bringAll(getOwned()) end)
    addBtn("Auto Chop", function()
        S.autoChop=not S.autoChop msg("Dark X", S.autoChop and "on" or "off")
        if S.autoChop then task.spawn(function() while S.autoChop do local h=hrp() if h then for _,t in pairs(getTrees()) do if not S.autoChop then break end if t.PrimaryPart and (t.PrimaryPart.Position-h.Position).Magnitude<60 then chop(t) end end end task.wait(1) end end) end
    end)
    addBtn("Auto Farm", function()
        S.autoFarm=not S.autoFarm msg("Dark X", S.autoFarm and "on" or "off")
        if S.autoFarm then task.spawn(function() while S.autoFarm do local ts=getTrees() if #ts>0 then bring(ts[1]) task.wait(0.3) chop(ts[1]) end task.wait(2) end end) end
    end)
    addBtn("Select Wood", function()
        msg("Dark X","Click wood")
        local c c=UIS.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then local t=player:GetMouse().Target if t then local m=t:FindFirstAncestorOfClass("Model") if m and m:FindFirstChild("TreeClass") then S.selectedWood=m msg("Dark X","Selected") c:Disconnect() end end end end)
    end)
    addBtn("Mod Wood", function()
        if not S.selectedWood or not S.woodColor then msg("Dark X","select wood and color") return end
        for _,p in pairs(S.selectedWood:GetDescendants()) do if p:IsA("BasePart") and (p.Name=="BuildDependentWood" or p.Name=="Main") then p.Color=S.woodColor end end
    end)
    for n,c in pairs(colors) do addBtn(n, function() S.woodColor=c msg("Dark X",n) end) end
end)

makeTab("Saw", function()
    addBtn("Select Sawmill", function()
        msg("Dark X","Click sawmill")
        local c c=UIS.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then local t=player:GetMouse().Target if t then local m=t:FindFirstAncestorOfClass("Model") if m and m.Name:find("Sawmill") then S.selectedSawmill=m msg("Dark X","Selected") c:Disconnect() end end end end)
    end)
    addBtn("Max Settings", function()
        if not S.selectedSawmill then return end
        for _,v in pairs(S.selectedSawmill:GetDescendants()) do if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value=100 end end
    end)
    addBtn("Min Settings", function()
        if not S.selectedSawmill then return end
        for _,v in pairs(S.selectedSawmill:GetDescendants()) do if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value=1 end end
    end)
end)

makeTab("Axe", function()
    addBtn("Dupe Axe", function() if not getAxe() then msg("Dark X","need axe") return end fireRemote("Dupe") msg("Dark X","save slot") end)
    addBtn("Pick Up", function()
        for _,item in pairs(getOwned()) do
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Pick up tool") end
        end
    end)
end)

makeTab("Build", function()
    addBtn("Save Base", function() fireRemote("Save") msg("Dark X","saved") end)
    addBtn("Load Base", function() fireRemote("Load") end)
    addBtn("Free Land", function() fireRemote("Free Land") end)
    addBtn("Max Land", function() fireRemote("Max Land") end)
    addBtn("Get Blueprint", function() fireRemote("Open box") end)
end)

makeTab("World", function()
    addBtn("Day", function() Lighting.ClockTime=14 end)
    addBtn("Night", function() Lighting.ClockTime=0 end)
    addBtn("No Fog", function() Lighting.FogEnd=100000 end)
    addBtn("Fly", function() local h=hum() if h then h.PlatformStand=not h.PlatformStand end end)
    addBtn("Tp Base", function()
        for _,item in pairs(getOwned()) do if item.PrimaryPart then tp(item.PrimaryPart.Position) return end end
        msg("Dark X","no base")
    end)
end)

makeTab("TP", function()
    for name, pos in pairs(locs) do addBtn(name, function() tp(pos) end) end
end)

showTab("Wood")
print("Dark X loaded")
end
