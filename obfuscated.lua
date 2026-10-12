-- Dark X LT2 Complete Rebuild
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local Remote = RS:WaitForChild("Interaction"):WaitForChild("RemoteProxy")

local S = {
    autoFarm=false, autoChop=false, autoBuy=false, autoFiller=false,
    fly=false, infJump=false, walkWater=false,
    selectedTree=nil, selectedSawmill=nil, selectedWood=nil, woodColor=nil,
}

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

local colors={
    Pine=Color3.fromRGB(163,162,165), Fir=Color3.fromRGB(86,66,54), Birch=Color3.fromRGB(255,255,255),
    ["Lime green"]=Color3.fromRGB(0,255,0), ["Dark red"]=Color3.fromRGB(140,0,0), ["Really red"]=Color3.fromRGB(255,0,0),
    ["Deep blue"]=Color3.fromRGB(0,0,140), ["Dark grey"]=Color3.fromRGB(50,50,50), ["Earth orange"]=Color3.fromRGB(200,100,0),
    ["Earth yellow"]=Color3.fromRGB(200,180,0), ["Sand green"]=Color3.fromRGB(120,140,80), ["Sand red"]=Color3.fromRGB(180,100,80),
    ["Hot pink"]=Color3.fromRGB(255,100,180), ["Faded green"]=Color3.fromRGB(100,150,100), Frost=Color3.fromRGB(200,230,255),
}

local locs={
    ["Wood R Us"]=Vector3.new(270,4,60), Spawn=Vector3.new(174,10.5,66), ["Land Store"]=Vector3.new(270,3,-98),
    ["Ice Mountain"]=Vector3.new(112,37,-892), Cave=Vector3.new(1136,0,-206), Swamp=Vector3.new(2614,-4,-34),
    Volcano=Vector3.new(3590,-177,415), ["Shrine"]=Vector3.new(-1588,623,1069), ["Ski Lodge"]=Vector3.new(-1216,131,-822),
    Dock=Vector3.new(486,3,-1722), Bridge=Vector3.new(509,3,-1458), ["Bobs Shack"]=Vector3.new(1487,415,3259),
    ["Fancy Furnishings"]=Vector3.new(4615,7,-794), ["The Den"]=Vector3.new(292,8,-2544),
    ["Strange Man"]=Vector3.new(5217,-166,721), ["Fine Arts"]=Vector3.new(-1608,195,928),
    ["Furniture"]=Vector3.new(1071,16,1141), Ferry=Vector3.new(-1667,349,1474),
    ["Toll Bridge"]=Vector3.new(1244,59,2290), Palm=Vector3.new(-1080,-5,-942),
}

-- GUI
local gui=Instance.new("ScreenGui",player.PlayerGui)
gui.Name="DarkX" gui.ResetOnSpawn=false
local f=Instance.new("Frame",gui)
f.Size=UDim2.new(0,250,0,520) f.Position=UDim2.new(0,10,0.1,0)
f.BackgroundColor3=Color3.fromRGB(16,16,16) f.Active=true f.Draggable=true
local tl=Instance.new("TextLabel",f)
tl.Size=UDim2.new(1,0,0,26) tl.Text="Dark X" tl.BackgroundColor3=Color3.fromRGB(30,30,30)
tl.TextColor3=Color3.new(1,1,1) tl.Font=Enum.Font.SourceSansBold tl.TextSize=15
local sc=Instance.new("ScrollingFrame",f)
sc.Size=UDim2.new(1,0,1,-26) sc.Position=UDim2.new(0,0,0,26) sc.BackgroundTransparency=1
sc.CanvasSize=UDim2.new(0,0,0,2200) sc.ScrollBarThickness=3

local y=2
local function b(t,cb)
    local btn=Instance.new("TextButton",sc)
    btn.Size=UDim2.new(1,-6,0,20) btn.Position=UDim2.new(0,3,0,y) btn.Text=t
    btn.BackgroundColor3=Color3.fromRGB(35,35,35) btn.TextColor3=Color3.new(1,1,1)
    btn.Font=Enum.Font.SourceSans btn.TextSize=12 btn.MouseButton1Click:Connect(cb)
    y=y+22
end

local function section(name) b("--- "..name.." ---", function() end) end

section("Wood")
b("Bring Tree", function()
    local ts=getTrees() local h=hrp()
    if not h or #ts==0 then msg("Dark X","not find tree") return end
    local best,d=nil,math.huge
    for _,t in pairs(ts) do if t.PrimaryPart then local dd=(t.PrimaryPart.Position-h.Position).Magnitude if dd<d then best,d=t,dd end end end
    if best then S.selectedTree=best bring(best) msg("Dark X","Wood Selected") end
end)
b("Bring All Tree", function() bringAll(getTrees()) end)
b("Bring All Plank", function() bringAll(getOwned()) end)
b("Sell All Tree", function()
    for _,t in pairs(getTrees()) do
        local r=t:FindFirstChildWhichIsA("RemoteEvent",true)
        if r then r:FireServer("Sell") end
    end
    msg("Dark X","Sell All Tree")
end)
b("Auto Chop", function()
    S.autoChop=not S.autoChop msg("Dark X", S.autoChop and "on" or "off")
    if S.autoChop then task.spawn(function() while S.autoChop do local h=hrp() if h then for _,t in pairs(getTrees()) do if not S.autoChop then break end if t.PrimaryPart and (t.PrimaryPart.Position-h.Position).Magnitude<60 then chop(t) end end end task.wait(1) end end) end
end)
b("Auto Farm", function()
    S.autoFarm=not S.autoFarm msg("Dark X", S.autoFarm and "on" or "off")
    if S.autoFarm then task.spawn(function() while S.autoFarm do local ts=getTrees() if #ts>0 then bring(ts[1]) task.wait(0.3) chop(ts[1]) end task.wait(2) end end) end
end)
b("Click one Wood", function()
    msg("Dark X","Click one Wood")
    local c c=UIS.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then local t=player:GetMouse().Target if t then local m=t:FindFirstAncestorOfClass("Model") if m and m:FindFirstChild("TreeClass") then S.selectedWood=m msg("Dark X","Wood Selected") c:Disconnect() end end end end)
end)
b("Mod Wood", function() if not S.selectedWood then msg("Dark X","select Wood At First") return end if not S.woodColor then msg("Dark X","u cant mod this wood") return end for _,p in pairs(S.selectedWood:GetDescendants()) do if p:IsA("BasePart") and (p.Name=="BuildDependentWood" or p.Name=="Main") then p.Color=S.woodColor end end end)
b("Mod Cut Wood", function()
    if not S.selectedWood then msg("Dark X","select Wood At First") return end
    if not S.woodColor then return end
    for _,p in pairs(S.selectedWood:GetDescendants()) do
        if p:IsA("BasePart") then p.Color=S.woodColor end
    end
    msg("Dark X","Mod Cut Wood")
end)
b("Cut Tree Joints", function() if not S.selectedTree then msg("Dark X","select Wood At First") return end chop(S.selectedTree) end)
b("Find Spooky Wood", function()
    for _,t in pairs(getTrees()) do
        if t:FindFirstChild("TreeClass") and (t.TreeClass.Value:find("Spooky") or t.TreeClass.Value:find("Spook")) then
            bring(t) msg("Dark X","Found Spooky") return
        end
    end
    msg("Dark X","Not Found Phantom Tree")
end)
b("View Phantom Tree", function()
    for _,t in pairs(getTrees()) do
        if t:FindFirstChild("TreeClass") and t.TreeClass.Value:find("Phantom") then
            bring(t) msg("Dark X","View phantom tree") return
        end
    end
    msg("Dark X","Not Found Phantom Tree")
end)
b("One Unit Cutter", function()
    if not S.selectedTree then msg("Dark X","select Wood At First") return end
    chop(S.selectedTree)
    msg("Dark X","One Unit Cutter")
end)

section("Colors")
for n,c in pairs(colors) do b(n, function() S.woodColor=c msg("Dark X",n) end) end

section("Sawmill")
b("Select Sawmill", function()
    msg("Dark X","Click one Sawmill")
    local c c=UIS.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then local t=player:GetMouse().Target if t then local m=t:FindFirstAncestorOfClass("Model") if m and m.Name:find("Sawmill") then S.selectedSawmill=m msg("Dark X","Sawmill Selected") c:Disconnect() end end end end)
end)
b("Mod Sawmill", function()
    if not S.selectedSawmill then msg("Dark X","select Sawmail At First") return end
    for _,p in pairs(S.selectedSawmill:GetDescendants()) do
        if p:IsA("BasePart") and S.woodColor then p.Color=S.woodColor end
    end
    msg("Dark X","Mod Sawmill")
end)
b("Max Sawmill Settings", function()
    if not S.selectedSawmill then msg("Dark X","select Sawmail At First") return end
    for _,v in pairs(S.selectedSawmill:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value=100 end
    end
    msg("Dark X","Max Sawmill Settings")
end)
b("Lowest Sawmill Settings", function()
    if not S.selectedSawmill then msg("Dark X","select Sawmail At First") return end
    for _,v in pairs(S.selectedSawmill:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value=1 end
    end
    msg("Dark X","Lowest Sawmill Settings")
end)
b("Make Plank Size 1", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("Main") and item.Main:IsA("BasePart") then
            item.Main.Size=Vector3.new(1,1,1)
        end
    end
    msg("Dark X","Make Selected Plank Size To 1")
end)

section("Axe")
b("Auto Dupe Axe", function()
    if not getAxe() then msg("Dark X","u need one axe") return end
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then r:InvokeServer() end
    msg("Dark X","now u can save the slot")
end)
b("Dupe Power", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then r:InvokeServer() end
    msg("Dark X","Dupe Power To Build With ease")
end)
b("Auto Pick Up Axe", function()
    for _, item in pairs(workspace:GetChildren()) do
        if item:FindFirstChild("Owner") and item.Owner.Value==player then
            local remote=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if remote then remote:FireServer("Pick up tool") end
        end
    end
    msg("Dark X","Pick up tool")
end)
b("Auto Calm Rukiryaxe", function()
    local axe=getAxe()
    if not axe then msg("Dark X","u need an axe") return end
    if axe.Name:find("Rukiryaxe") then
        local r=axe:FindFirstChildWhichIsA("RemoteEvent",true)
        if r then r:FireServer("Calm") end
    end
    msg("Dark X","Auto Calm Rukiryaxe")
end)
b("Select the Axe", function()
    local axe=getAxe()
    if axe then S.selectedAxe=axe msg("Dark X","Select the Axe") else msg("Dark X","u need an axe") end
end)

section("Sell / Plank")
b("Click to Sell Plank", function()
    for _,item in pairs(getOwned()) do
        if item.Name:find("Plank") or (item:FindFirstChild("ItemName") and item.ItemName.Value:find("Plank")) then
            local r=item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Sell") end
        end
    end
    msg("Dark X","click to sell plank")
end)
b("Stand Plank", function()
    for _,item in pairs(getOwned()) do
        if item.PrimaryPart then item.PrimaryPart.Anchored=true end
    end
    msg("Dark X","Stand Plank")
end)
b("Click to Delete", function()
    for _,item in pairs(getOwned()) do item:Destroy() end
    msg("Dark X","click to Delete")
end)
b("Set Plank Name", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("ItemName") then item.ItemName.Value="Plank" end
    end
    msg("Dark X","Set Plank Name")
end)
b("Box Sort", function()
    local items=getOwned()
    table.sort(items, function(a,b) return a.Name<b.Name end)
    bringAll(items)
    msg("Dark X","Box Sort")
end)

section("Build")
b("Load Build Preview", function()
    if not isfile or not isfile("build.txt") then msg("Dark x","not find file") return end
    local data=readfile("build.txt")
    msg("Dark x","load ur file at first")
end)
b("Execute Build", function()
    if not S.buildPreview then msg("Dark x","execute ur build preview at first") return end
    msg("Dark x","Click Build if u already build done and fill it then click this button again")
end)
b("Select Blueprint", function()
    msg("Dark x","select blueprint at first")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t then
                local m=t:FindFirstAncestorOfClass("Model")
                if m then S.selectedBlueprint=m msg("Dark x","select blueprint") c:Disconnect() end
            end
        end
    end)
end)
b("Get Blueprint Tool", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Open box") end
    msg("Dark X","Open box")
end)
b("Get All Blueprint", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Get All blueprint") end
    msg("Dark X","Get All blueprint")
end)
b("Fill All Blueprint", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Fill All blueprint") end
    msg("Dark X","Fill All blueprint")
end)
b("Auto Filler", function() S.autoFiller=not S.autoFiller msg("Dark X","Auto Filler") end)
b("Save Base", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then r:InvokeServer() end
    msg("Dark X","Save Base success")
end)
b("Load Base", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then
        local ok=r:InvokeServer()
        if not ok then msg("Dark X","Load is on cooldown. Waiting...") return end
    end
    msg("Dark X","Load Base")
end)
b("Fast Load", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then r:InvokeServer() end
    msg("Dark X","Fast Load")
end)
b("Deload", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then r:InvokeServer() end
    msg("Dark X","Deload(no load cooldown)")
end)

section("Buy")
b("Auto Buy", function()
    S.autoBuy=not S.autoBuy
    msg("Dark X","Auto Buy")
    if S.autoBuy then
        task.spawn(function()
            while S.autoBuy do
                local rs=game:GetService("ReplicatedStorage")
                local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
                if r then r:FireServer("Buy") end
                task.wait(1)
            end
        end)
    end
end)
b("Auto Buy All BluePrints", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Auto Buy All BluePrints") end
    msg("Dark X","Auto Buy All BluePrints")
end)
b("Loop Auto Buy", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then
        task.spawn(function()
            while true do r:FireServer("Buy") task.wait(0.5) end
        end)
    end
    msg("Dark X","Loop Auto Buy")
end)
b("Select Store", function()
    msg("Dark X","Select Store")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t then S.selectedStore=t:FindFirstAncestorOfClass("Model") msg("Dark X","Store selected") c:Disconnect() end
        end
    end)
end)

section("Land")
b("Free Land", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Free Land") end
    msg("Dark X","Free Land")
end)
b("Max Land", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Max Land") end
    msg("Dark X","Max Land")
end)
b("Land Art", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Land Art") end
    msg("Dark X","Land Art")
end)
b("Tp to Base", function()
    for _,item in pairs(getOwned()) do
        if item.PrimaryPart then tp(item.PrimaryPart.Position) msg("Dark X","Tp to Base") return end
    end
    msg("Dark X","Player Not Have Base")
end)

section("Sold Sign")
b("Take Down Sold Sign", function()
    for _, item in pairs(workspace:GetChildren()) do
        if item:FindFirstChild("Owner") and item.Owner.Value==player and item:FindFirstChild("ItemName") then
            local remote=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if remote then remote:FireServer("Take down sold sign") end
        end
    end
    msg("Dark X","Take down sold sign")
end)
b("Auto Farm Sold Sign", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("ItemName") then
            local r=item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Take down sold sign") end
        end
    end
    msg("Dark X","Auto Farm Sold Sign")
end)
b("Sold Sign Dupe", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Sold Sign Dupe") end
    msg("Dark X","Sold Sign Dupe")
end)
b("Sell Sold Sign", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("ItemName") then
            local r=item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Sell") end
        end
    end
    msg("Dark X","Sell Sold Sign")
end)

section("Vehicle")
b("Start Vehicle Spawner", function()
    msg("Dark X","Click a spawn pad")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t and t.Name:find("Spawn") then
                local rs=game:GetService("ReplicatedStorage")
                local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
                if r then r:FireServer("Spawn Vehicle") end
                msg("Dark X","Finished spawning vehicle")
                c:Disconnect()
            end
        end
    end)
end)
b("Flip Vehicle", function()
    local h=hrp()
    if h then
        for _,v in pairs(workspace:GetChildren()) do
            if v:FindFirstChild("Owner") and v.Owner.Value==player and v.PrimaryPart then
                v:SetPrimaryPartCFrame(v.PrimaryPart.CFrame * CFrame.Angles(math.pi,0,0))
            end
        end
    end
    msg("Dark X","Flip Vehicle")
end)
b("Vehicle Speed", function()
    for _,v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Owner") and v.Owner.Value==player then
            local bv=v:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity",v.PrimaryPart or v)
            if bv then bv.Velocity=Vector3.new(0,0,50) end
        end
    end
    msg("Dark X","Vehicle Speed")
end)

section("Player")
b("Fly", function()
    S.fly=not S.fly
    local h=hum() if h then h.PlatformStand=S.fly end
    msg("Dark X", S.fly and "Fly on" or "off")
end)
b("Infinite Jump", function()
    S.infJump=not S.infJump
    if S.infJump then UIS.JumpRequest:Connect(function() if S.infJump then local h=hum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end) end
end)
b("Walk On Water", function()
    S.walkWater=not S.walkWater
    if S.walkWater then
        local p=Instance.new("Part",workspace)
        p.Name="WaterWalk" p.Size=Vector3.new(500,1,500) p.Anchored=true p.CanCollide=true p.Transparency=1
        p.Position=Vector3.new(0,0,0)
    else
        local p=workspace:FindFirstChild("WaterWalk")
        if p then p:Destroy() end
    end
    msg("Dark X","Walk On Water")
end)
b("Safe Death", function()
    local h=hum()
    if h then h.Health=h.MaxHealth end
    msg("Dark X","Safe Death")
end)
b("Zoom Distance", function() player.CameraMaxZoomDistance=500 msg("Dark X","Zoom Distance") end)
b("Tp to Player", function()
    local players=game:GetService("Players"):GetPlayers()
    if #players>1 then
        local target=players[2]
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            tp(target.Character.HumanoidRootPart.Position)
        end
    end
    msg("Dark X","Tp to Player")
end)
b("Tp All Selected Item", function() bringAll(getOwned()) end)

section("World")
b("Always Day", function() Lighting.ClockTime=14 end)
b("Always Night", function() Lighting.ClockTime=0 end)
b("Always Shadows", function() Lighting.GlobalShadows=not Lighting.GlobalShadows end)
b("Remove Fog", function() Lighting.FogEnd=100000 end)
b("Remove Water", function()
    for _,p in pairs(workspace:GetDescendants()) do
        if p:IsA("BasePart") and p.Name=="Water" then p:Destroy() end
    end
    msg("Dark X","Remove Water")
end)
b("Remove Volcano Boulders", function()
    for _,p in pairs(workspace:GetDescendants()) do
        if p.Name:find("Boulder") or p.Name:find("Rock") then p:Destroy() end
    end
    msg("Dark X","Remove Volcano Boulders")
end)
b("Anti BlackList", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Anti BlackList") end
    msg("Dark X","Anti BlackList")
end)

section("Teleport")
for n,p in pairs(locs) do b("TP "..n, function() tp(p) end) end

section("Slot")
b("Dupe Slot", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then r:InvokeServer() end
    msg("Dark X","now u can save the slot")
end)
b("Slot Saved", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then r:InvokeServer() end
    msg("Dark X","Slot saved successfully")
end)
b("Leave Without Save", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    msg("Dark X","Leave without save")
end)
b("Abort", function() S.autoFarm=false S.autoChop=false S.autoBuy=false msg("Dark X","Abort") end)

b("Close", function() gui:Destroy() end)
print("Dark X complete loaded")
