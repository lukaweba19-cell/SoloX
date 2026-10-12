return function(library)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local S = {autoFarm=false, autoChop=false, selectedTree=nil, selectedWood=nil, woodColor=nil}

local function msg(t,x) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=x,Duration=3}) end) end
local function hrp() local c=player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function tp(p) local h=hrp() if h then h.CFrame=CFrame.new(p) end end

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
    if not axe then msg("Dark X","need axe") return end
    local ev=tree:FindFirstChild("CutEvent")
    if not ev then return end
    local remote=RS:FindFirstChild("Interaction") and RS.Interaction:FindFirstChild("RemoteProxy")
    if not remote then return end
    for s=1,4 do remote:FireServer(ev,{tool=axe,hitPoints=10,faceVector=Vector3.new(1,0,0),height=0.3,sectionId=s,cooldown=0}) task.wait(0.05) end
end

local function bring(m)
    local h=hrp() if not h or not m.PrimaryPart then return end
    m:SetPrimaryPartCFrame(h.CFrame*CFrame.new(0,0,-8))
end

local locs = {
    ["Wood R Us"]=Vector3.new(270,4,60),["Spawn"]=Vector3.new(174,10.5,66),["Land Store"]=Vector3.new(270,3,-98),
    ["Bridge"]=Vector3.new(112,37,-892),["Dock"]=Vector3.new(1136,0,-206),["Palm"]=Vector3.new(2614,-4,-34),
    ["Cave"]=Vector3.new(3590,-177,415),["Volcano"]=Vector3.new(-1588,623,1069),["Swamp"]=Vector3.new(-1216,131,-822),
    ["Fancy Furnishings"]=Vector3.new(486,3,-1722),["Ice Mountain"]=Vector3.new(1487,415,3259),
    ["Bobs Shack"]=Vector3.new(292,8,-2544),["Ski Lodge"]=Vector3.new(1244,59,2290),
}

local woodTypes = {"Pine","Fir","Birch","Oak","Koa","Palm","Cherry","Walnut","Spooky","Fur Wood","Maple","Cedar","Elm","Ash","Mahogany"}
local colors = {Pine=Color3.fromRGB(163,162,165),Fir=Color3.fromRGB(86,66,54),Birch=Color3.fromRGB(255,255,255),Oak=Color3.fromRGB(139,90,43),Koa=Color3.fromRGB(101,67,33),Palm=Color3.fromRGB(194,178,128),Cherry=Color3.fromRGB(128,0,0),Walnut=Color3.fromRGB(92,64,51),Spooky=Color3.fromRGB(50,0,50),["Fur Wood"]=Color3.fromRGB(139,69,19)}

local win = library:new("Dark X")

-- Wood tab
local woodTab = win:Tab("Wood", "0")
local woodActions = woodTab:section("Actions")
woodActions:Button("Bring Tree", function()
    local ts=getTrees() local h=hrp()
    if not h or #ts==0 then msg("Dark X","no tree") return end
    local best,d=nil,math.huge
    for _,t in pairs(ts) do if t.PrimaryPart then local dd=(t.PrimaryPart.Position-h.Position).Magnitude if dd<d then best,d=t,dd end end end
    if best then S.selectedTree=best bring(best) msg("Dark X","brought") end
end)
woodActions:Button("Sell Plank", function()
    for _,item in pairs(getOwned()) do
        if item.Name:find("Plank") or (item:FindFirstChild("ItemName") and tostring(item.ItemName.Value):find("Plank")) then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Sell") end
        end
    end
    msg("Dark X","click to sell plank")
end)
woodActions:Button("Bring All Plank", function()
    local h=hrp()
    if not h then return end
    local i=0
    for _,item in pairs(getOwned()) do
        if item.PrimaryPart then
            item:SetPrimaryPartCFrame(h.CFrame*CFrame.new((i%5)*4,2,-8-math.floor(i/5)*4))
            i=i+1
        end
    end
end)
woodActions:Button("Sell All Tree", function()
    for _,t in pairs(getTrees()) do
        local r=t:FindFirstChildWhichIsA("RemoteEvent",true)
        if r then r:FireServer("Sell") end
    end
    msg("Dark X","Sell All Tree")
end)
woodActions:Button("Bring All", function()
    local h=hrp() if not h then return end
    for i,t in ipairs(getTrees()) do if t.PrimaryPart then t:SetPrimaryPartCFrame(h.CFrame*CFrame.new((i%4)*6,0,-10)) end end
end)
woodActions:Toggle("Auto Chop", false, function(s)
    S.autoChop=s
    if s then task.spawn(function() while S.autoChop do local h=hrp() if h then for _,t in pairs(getTrees()) do if not S.autoChop then break end if t.PrimaryPart and (t.PrimaryPart.Position-h.Position).Magnitude<60 then chop(t) end end end task.wait(1) end end) end
end)
woodActions:Toggle("Auto Farm", false, function(s)
    S.autoFarm=s
    if s then task.spawn(function() while S.autoFarm do local ts=getTrees() if #ts>0 then bring(ts[1]) task.wait(0.3) chop(ts[1]) end task.wait(2) end end) end
end)
woodActions:Button("Mod Wood", function()
    if not getAxe() then msg("Dark X","u need an axe") return end
    if not S.selectedSawmill then msg("Dark X","select sawmill first") return end
    msg("Dark X","click tree")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t then
                local m=t:FindFirstAncestorOfClass("Model")
                if m and m:FindFirstChild("TreeClass") then
                    local tc=tostring(m.TreeClass.Value)
                    if tc~="Pine" and tc~="Fir" then msg("Dark X","u cant mod this wood") c:Disconnect() return end
                    local sections=0
                    local target=nil
                    for _,ch in pairs(m:GetChildren()) do
                        if ch.Name=="WoodSection" then
                            sections=sections+1
                            local id=ch:FindFirstChild("ID")
                            local cids=ch:FindFirstChild("ChildIDs")
                            local pid=ch:FindFirstChild("ParentID")
                            if id and id.Value==1 and cids and #cids:GetChildren()==0 and pid and pid.Value==1 then
                                target=ch
                            end
                        end
                    end
                    if not target then msg("Dark X","u cant mod this wood") c:Disconnect() return end
                    local box=Instance.new("BoxHandleAdornment",target)
                    box.Name="Selection" box.Adornee=target box.AlwaysOnTop=true box.Size=target.Size
                    box.Transparency=0 box.Color=BrickColor.new("Lime green")
                    local h=hrp()
                    if h and m:FindFirstChild("WoodSection") then h.CFrame=m.WoodSection.CFrame end
                    local drag=RS:FindFirstChild("Interaction") and RS.Interaction:FindFirstChild("ClientIsDragging")
                    if drag then
                        for i=1,20 do
                            drag:FireServer(m)
                            m:PivotTo(CFrame.new(-1406,312,-24))
                            task.wait()
                        end
                        if h then h.CFrame=target.CFrame end
                        drag:FireServer(m)
                        target:PivotTo(CFrame.new(315,5,85.5))
                        task.wait()
                    end
                    local ev=m:FindFirstChild("CutEvent")
                    if ev then
                        local axe=getAxe()
                        local remote=RS:FindFirstChild("Interaction") and RS.Interaction:FindFirstChild("RemoteProxy")
                        if remote and axe then remote:FireServer(ev,{tool=axe,hitPoints=0.3,sectionId=1}) end
                    end
                    if h then h.CFrame=h.CFrame end
                    msg("Dark X","modded")
                    c:Disconnect()
                end
            end
        end
    end)
end)

local woodTypes_sec = woodTab:section("Wood Types")
for _,w in ipairs(woodTypes) do woodTypes_sec:Button(w, function() S.selectedWoodType=w msg("Dark X",w) end) end
local woodColors = woodTab:section("Colors")
for n,c in pairs(colors) do woodColors:Button(n, function() S.woodColor=c msg("Dark X",n) end) end

-- Sawmill tab
local sawTab = win:Tab("Sawmill", "0")
local saw = sawTab:section("Sawmill")
saw:Button("Select", function()
    msg("Dark X","click sawmill")
    local c c=UIS.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then local t=player:GetMouse().Target if t then local m=t:FindFirstAncestorOfClass("Model") if m and m.Name:find("Sawmill") then S.selectedSawmill=m msg("Dark X","selected") c:Disconnect() end end end end)
end)
saw:Button("Max", function() if S.selectedSawmill then for _,v in pairs(S.selectedSawmill:GetDescendants()) do if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value=100 end end end end)
saw:Button("Hard Dragger", function()
    msg("Dark X","Hard Dragger")
end)
saw:Button("Mod Sawmill", function()
    if not S.selectedSawmill then msg("Dark X","select Sawmail At First") return end
    if S.woodColor then
        for _,p in pairs(S.selectedSawmill:GetDescendants()) do
            if p:IsA("BasePart") then p.Color=S.woodColor end
        end
    end
    msg("Dark X","Mod Sawmill")
end)
saw:Button("Max Settings", function()
    if not S.selectedSawmill then msg("Dark X","select Sawmail At First") return end
    for _,v in pairs(S.selectedSawmill:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value=100 end
    end
    msg("Dark X","Max Sawmill Settings")
end)
saw:Button("Min Settings", function()
    if not S.selectedSawmill then msg("Dark X","select Sawmail At First") return end
    for _,v in pairs(S.selectedSawmill:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value=1 end
    end
    msg("Dark X","Lowest Sawmill Settings")
end)
saw:Button("Plank Size 1", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("Main") and item.Main:IsA("BasePart") then item.Main.Size=Vector3.new(1,1,1) end
    end
    msg("Dark X","Make Selected Plank Size To 1")
end)
saw:Button("Floor2", function()
    local has=false
    for _,item in pairs(getOwned()) do if item.Name:find("Floor2") then has=true break end end
    if not has then msg("Dark x","u need to buy floor2") return end
    msg("Dark X","Floor2")
end)
saw:Button("Min", function() if S.selectedSawmill then for _,v in pairs(S.selectedSawmill:GetDescendants()) do if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value=1 end end end end)
saw:Button("Plank Size 1", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("Main") and item.Main:IsA("BasePart") then item.Main.Size=Vector3.new(1,1,1) end
    end
    msg("Dark X","Make Selected Plank Size To 1")
end)
saw:Button("Sell Plank", function()
    for _,item in pairs(getOwned()) do
        if item.Name:find("Plank") or (item:FindFirstChild("ItemName") and tostring(item.ItemName.Value):find("Plank")) then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Sell") end
        end
    end
    msg("Dark X","click to sell plank")
end)

-- Axe tab
local axeTab = win:Tab("Axe", "0")
local axe = axeTab:section("Axe")
axe:Button("Auto Pick Up", function()
    task.spawn(function()
        while true do
            for _,item in pairs(workspace:GetChildren()) do
                local owner=item:FindFirstChild("Owner")
                local tn=item:FindFirstChild("ToolName")
                if owner and owner.Value==player and tn then
                    local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
                    if r then r:FireServer("Pick up tool") end
                end
            end
            task.wait(2)
        end
    end)
    msg("Dark X","Auto Pick Up Axe")
end)
axe:Button("Select Axe", function()
    local axe=getAxe()
    if axe then S.selectedAxe=axe msg("Dark X","Select the Axe") else msg("Dark X","need axe") end
end)
axe:Button("Dupe Power", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then r:InvokeServer() end
    msg("Dark X","Dupe Power To Build With ease")
end)
axe:Button("Endtimes Check", function()
    local axe=getAxe()
    if not axe then msg("Dark X","you need a axe") return end
    if not axe.Name:find("Endtimes") then msg("Dark x","you need a EndtimesAxe") return end
    msg("Dark X","Endtimes ok")
end)
axe:Button("Calm Rukiryaxe", function()
    local axe=getAxe()
    if not axe then msg("Dark X","need axe") return end
    if not axe.Name:find("Rukiryaxe") then return end
    local r=axe:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Calm") end
    msg("Dark X","Calming Rukiryaxe")
end)
axe:Button("Calm Rukiryaxe", function()
    local axe=getAxe()
    if not axe then msg("Dark X","need axe") return end
    if axe.Name:find("Rukiryaxe") then
        local r=axe:FindFirstChildWhichIsA("RemoteEvent",true)
        if r then r:FireServer("Calm") end
    end
    msg("Dark X","Auto Calm Rukiryaxe")
end)
axe:Button("Dupe", function()
    if not getAxe() then msg("Dark X","need axe") return end
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then
        local ok=pcall(function() r:InvokeServer() end)
        if not ok then msg("Dark X","You need to own the power to be able to dupe it") return end
    end
    msg("Dark X","now u can save the slot")
end)
axe:Button("Pick Up", function()
    for _,item in pairs(workspace:GetChildren()) do
        local owner=item:FindFirstChild("Owner")
        local tn=item:FindFirstChild("ToolName")
        if owner and owner.Value==player and tn then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Pick up tool") end
        end
    end
end)

-- Build tab
local buildTab = win:Tab("Build", "0")
local build = buildTab:section("Base")
build:Button("Save", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then r:InvokeServer(game:GetService("Players"):GetPlayers(), 0) end
    msg("Dark X","Save Base success")
end)
build:Button("Slot Save", function()
    local rs=game:GetService("ReplicatedStorage")
    local rf=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if rf then rf:InvokeServer() end
    msg("Dark X","Slot saved successfully")
end)
build:Button("Get Blueprint", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Open box") end
    msg("Dark X","Open box")
end)
build:Button("Load", function()
    local rs=game:GetService("ReplicatedStorage")
    local rf=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if rf then
        local ok=rf:InvokeServer()
        if not ok then msg("Dark X","Load is on cooldown. Waiting...") return end
    end
    msg("Dark X","Load Base")
end)
build:Button("Loop Auto Buy", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then task.spawn(function() while true do r:FireServer("Buy") task.wait(0.3) end end) end
    msg("Dark X","Loop Auto Buy")
end)
build:Button("Auto Filler", function()
    msg("Dark X","Auto Filler")
end)
build:Button("Select Store", function()
    msg("Dark X","Select Store")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t then S.selectedStore=t:FindFirstAncestorOfClass("Model") msg("Dark X","selected") c:Disconnect() end
        end
    end)
end)
build:Button("Check Money", function()
    local ls=player:FindFirstChild("leaderstats")
    local money=ls and ls:FindFirstChild("Money")
    if money and money.Value<100 then msg("Dark x","u not have enough money") return end
    msg("Dark X","money ok")
end)
build:Button("Auto Buy", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then
        task.spawn(function()
            for i=1,10 do r:FireServer("Buy") task.wait(0.5) end
        end)
    end
    msg("Dark X","Auto Buy")
end)
build:Button("Load Preview", function()
    if not isfile or not isfile("build.txt") then msg("Dark x","not find file") return end
    msg("Dark x","load ur file at first")
end)
build:Button("Get Blueprint Tool", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Open box") end
    msg("Dark X","Get Blueprint Tool")
end)
build:Button("Execute Build", function()
    if not S.selectedBlueprint then msg("Dark x","select blueprint at first") return end
    msg("Dark x","Click Build if u already build done and fill it then click this button again")
end)
build:Button("Get All Blueprint", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Get All blueprint") end
    msg("Dark X","Get All blueprint")
end)
build:Button("Fill All", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Fill All blueprint") end
    msg("Dark X","Fill All blueprint")
end)
build:Button("Fast Load", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then r:InvokeServer() end
    msg("Dark X","Fast Load")
end)
build:Button("Deload", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then r:InvokeServer() end
    msg("Dark X","Deload")
end)
build:Button("Slot Save", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then r:InvokeServer() end
    msg("Dark X","Slot saved successfully")
end)
build:Button("Dupe Slot", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if r then r:InvokeServer() end
    msg("Dark X","Dupe Slot")
end)
build:Button("Select Blueprint", function()
    msg("Dark x","select blueprint at first")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t then
                local m=t:FindFirstAncestorOfClass("Model")
                if m then S.selectedBlueprint=m msg("Dark x","selected") c:Disconnect() end
            end
        end
    end)
end)
build:Button("Open Box", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Open box") end
    msg("Dark X","Open box")
end)
local land = buildTab:section("Land")
land:Button("Free Land", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Free Land") end
    msg("Dark X","Free Land")
end)
land:Button("Max Land", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Max Land") end
    msg("Dark X","Max Land")
end)
land:Button("Land Art", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Land Art") end
end)
land:Button("Auto Farm Sold Sign", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("ItemName") then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Take down sold sign") end
        end
    end
    msg("Dark X","Auto Farm Sold Sign")
end)
land:Button("Sell Sold Sign", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("ItemName") then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Sell") end
        end
    end
    msg("Dark X","Sell Sold Sign")
end)
land:Button("Click to Fill", function()
    msg("Dark X","Click to Fill")
end)
land:Button("Sold Sign Dupe", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Sold Sign Dupe") end
    msg("Dark X","Sold Sign Dupe")
end)
land:Button("Stand Plank", function()
    for _,item in pairs(getOwned()) do
        if item.PrimaryPart then item.PrimaryPart.Anchored=true end
    end
    msg("Dark X","Stand Plank")
end)
land:Button("Box Sort", function()
    local items=getOwned()
    table.sort(items, function(a,b) return a.Name<b.Name end)
    local h=hrp()
    if h then for i,m in ipairs(items) do if m.PrimaryPart then m:SetPrimaryPartCFrame(h.CFrame*CFrame.new((i%5)*4,2,-8-math.floor(i/5)*4)) end end end
    msg("Dark X","Box Sort")
end)
land:Button("Set Plank Name", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("ItemName") then item.ItemName.Value="Plank" end
    end
    msg("Dark X","Set Plank Name")
end)
land:Button("Delete", function()
    for _,item in pairs(getOwned()) do item:Destroy() end
    msg("Dark X","click to Delete")
end)
land:Button("Auto Buy", function()
    S.autoBuy=not S.autoBuy
    msg("Dark X", S.autoBuy and "Auto Buy on" or "off")
    if S.autoBuy then
        task.spawn(function()
            while S.autoBuy do
                local rs=game:GetService("ReplicatedStorage")
                local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
                if re then re:FireServer("Buy") end
                task.wait(1)
            end
        end)
    end
end)
land:Button("Take Down Sold Sign", function()
    for _,item in pairs(workspace:GetChildren()) do
        local owner=item:FindFirstChild("Owner")
        local iname=item:FindFirstChild("ItemName")
        if owner and owner.Value==player and iname then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Take down sold sign") end
        end
    end
    msg("Dark X","Take down sold sign")
end)

-- World tab
local worldTab = win:Tab("World", "0")
local world = worldTab:section("World")
world:Toggle("Always Day", false, function(s)
    if s then task.spawn(function() while s do Lighting.ClockTime=14 task.wait(1) end end) end
end)
world:Toggle("Always Night", false, function(s)
    if s then task.spawn(function() while s do Lighting.ClockTime=0 task.wait(1) end end) end
end)
world:Button("No Fog", function() Lighting.FogEnd=100000 end)
world:Button("Remove Water", function()
    for _,p in pairs(workspace:GetDescendants()) do
        if p:IsA("BasePart") and p.Name=="Water" then p:Destroy() end
    end
end)
world:Button("Remove Boulders", function()
    for _,p in pairs(workspace:GetDescendants()) do
        if p.Name:find("Boulder") or p.Name:find("Rock") then p:Destroy() end
    end
end)
world:Button("Shadows", function() Lighting.GlobalShadows=not Lighting.GlobalShadows end)
world:Button("Remove Water", function()
    for _,p in pairs(workspace:GetDescendants()) do
        if p:IsA("BasePart") and p.Name=="Water" then p:Destroy() end
    end
end)
world:Button("Abort", function()
    S.autoFarm=false S.autoChop=false
    msg("Dark X","Abort")
end)
world:Button("Anti BlackList", function()
    local rs=game:GetService("ReplicatedStorage")
    local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if r then r:FireServer("Anti BlackList") end
end)
world:Button("Shadows", function() Lighting.GlobalShadows=not Lighting.GlobalShadows end)
world:Button("Remove Boulders", function()
    for _,p in pairs(workspace:GetDescendants()) do
        if p.Name:find("Boulder") or p.Name:find("Rock") then p:Destroy() end
    end
end)
world:Button("Walk Water", function()
    local p=workspace:FindFirstChild("WaterWalk")
    if p then p:Destroy() else
        p=Instance.new("Part",workspace) p.Name="WaterWalk" p.Size=Vector3.new(2000,1,2000)
        p.Anchored=true p.CanCollide=true p.Transparency=1 p.Position=Vector3.new(0,0,0)
    end
end)
local playerSec = worldTab:section("Player")
playerSec:Button("Inf Jump", function()
    UIS.JumpRequest:Connect(function()
        local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
    msg("Dark X","Inf Jump")
end)
playerSec:Button("Zoom", function() player.CameraMaxZoomDistance=500 end)
playerSec:Button("Safe Death", function()
    local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if h then h.Health=h.MaxHealth end
end)
playerSec:Button("Fly", function() local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand=not h.PlatformStand end end)
playerSec:Button("Inf Jump", function()
    UIS.JumpRequest:Connect(function()
        local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)
playerSec:Button("Zoom", function() player.CameraMaxZoomDistance=500 end)
playerSec:Button("Walk Water", function()
    local p=Instance.new("Part",workspace)
    p.Name="WaterWalk" p.Size=Vector3.new(500,1,500) p.Anchored=true p.CanCollide=true p.Transparency=1 p.Position=Vector3.new(0,0,0)
end)
playerSec:Button("Flip Vehicle", function()
    for _,v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Owner") and v.Owner.Value==player and v.PrimaryPart then
            v:SetPrimaryPartCFrame(v.PrimaryPart.CFrame * CFrame.Angles(math.pi,0,0))
        end
    end
    msg("Dark X","Flip Vehicle")
end)
playerSec:Button("Vehicle Speed", function()
    for _,v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Owner") and v.Owner.Value==player and v.PrimaryPart then
            local bv=Instance.new("BodyVelocity",v.PrimaryPart)
            bv.Velocity=Vector3.new(0,0,80)
            task.delay(2, function() bv:Destroy() end)
        end
    end
end)
playerSec:Button("Spawn Vehicle", function()
    msg("Dark X","Click a spawn pad")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t and t.Name:find("Spawn") then
                local rs=game:GetService("ReplicatedStorage")
                local r=rs:FindFirstChildWhichIsA("RemoteEvent",true)
                if r then r:FireServer("Spawn") end
                msg("Dark X","Finished spawning vehicle")
                c:Disconnect()
            end
        end
    end)
end)
playerSec:Button("Set Position", function()
    msg("Dark x","u need set Position")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t then S.setPos=t.Position msg("Dark X","position set") c:Disconnect() end
        end
    end)
end)
playerSec:Button("Tp All Items", function()
    local h=hrp()
    if h then
        local i=0
        for _,item in pairs(getOwned()) do
            if item.PrimaryPart then
                item:SetPrimaryPartCFrame(h.CFrame*CFrame.new((i%5)*4,2,-8-math.floor(i/5)*4))
                i=i+1
            end
        end
    end
    msg("Dark X","Tp All Selected Item")
end)
playerSec:Button("Tp Player", function()
    local ps=game:GetService("Players"):GetPlayers()
    if #ps>1 and ps[2].Character and ps[2].Character:FindFirstChild("HumanoidRootPart") then
        tp(ps[2].Character.HumanoidRootPart.Position)
    end
end)
playerSec:Button("Leave", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    msg("Dark X","Leave without save")
end)
playerSec:Button("Tp Player", function()
    local players=game:GetService("Players"):GetPlayers()
    if #players>1 then
        local t=players[2]
        if t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            tp(t.Character.HumanoidRootPart.Position)
        end
    end
    msg("Dark X","Tp to Player")
end)
playerSec:Button("Safe Death", function()
    local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if h then h.Health=h.MaxHealth end
    msg("Dark X","Safe Death")
end)
playerSec:Button("Tp Base", function()
    for _,item in pairs(getOwned()) do if item.PrimaryPart then tp(item.PrimaryPart.Position) return end end
    msg("Dark X","no base")
end)

-- Vehicle
local vehTab = win:Tab("Vehicle", "0")
local veh = vehTab:section("Vehicle")
veh:Button("Spawn", function()
    msg("Dark X","Click a spawn pad")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t and t.Name:find("Spawn") then
                local rs=game:GetService("ReplicatedStorage")
                local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
                if re then re:FireServer("Spawn Vehicle") end
                msg("Dark X","Finished spawning vehicle")
                c:Disconnect()
            end
        end
    end)
end)
veh:Button("Flip", function()
    for _,v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Owner") and v.Owner.Value==player and v.PrimaryPart then
            v:SetPrimaryPartCFrame(v.PrimaryPart.CFrame * CFrame.Angles(math.pi,0,0))
        end
    end
end)

-- Teleport tab
local tpTab = win:Tab("TP", "0")
local tpSec = tpTab:section("Locations")
for name, pos in pairs(locs) do tpSec:Button(name, function() tp(pos) end) end


-- Extra features
local extraTab = win:Tab("Extra", "0")
local extra = extraTab:section("Extra")
extra:Button("Auto Filler", function()
    msg("Dark X","Auto Filler")
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Fill") end
end)
extra:Button("Hard Dragger", function() msg("Dark X","Hard Dragger") end)
extra:Button("Anti BlackList", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Anti BlackList") end
    msg("Dark X","Anti BlackList")
end)
extra:Button("Check Money", function()
    local ls=player:FindFirstChild("leaderstats")
    if ls then
        local m=ls:FindFirstChild("Money") or ls:FindFirstChild("Cash")
        if m then msg("Dark X",tostring(m.Value)) end
    end
end)
extra:Button("Leave", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    msg("Dark X","Leave without save")
end)
extra:Button("Deload", function()
    local rs=game:GetService("ReplicatedStorage")
    local rf=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if rf then rf:InvokeServer() end
    msg("Dark X","Deload(no load cooldown)")
end)
extra:Button("Fast Load", function()
    local rs=game:GetService("ReplicatedStorage")
    local rf=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if rf then rf:InvokeServer() end
    msg("Dark X","Fast Load")
end)
extra:Button("Dupe Slot", function()
    local rs=game:GetService("ReplicatedStorage")
    local rf=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if rf then rf:InvokeServer() end
    msg("Dark X","Dupe Slot")
end)
extra:Button("Dupe Power", function()
    local rs=game:GetService("ReplicatedStorage")
    local rf=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if rf then rf:InvokeServer() end
    msg("Dark X","Dupe Power To Build With ease")
end)
extra:Button("Land Art", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Land Art") end
    msg("Dark X","Land Art")
end)
extra:Button("Get All Blueprint", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Get All blueprint") end
    msg("Dark X","Get All blueprint")
end)
extra:Button("Fill All", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Fill All blueprint") end
    msg("Dark X","Fill All blueprint")
end)
extra:Button("Loop Auto Buy", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then task.spawn(function() while true do re:FireServer("Buy") task.wait(0.5) end end) end
    msg("Dark X","Loop Auto Buy")
end)
extra:Button("Sold Sign Dupe", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Sold Sign Dupe") end
    msg("Dark X","Sold Sign Dupe")
end)
extra:Button("Auto Farm Sold Sign", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("ItemName") then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Take down sold sign") end
        end
    end
    msg("Dark X","Auto Farm Sold Sign")
end)
extra:Button("Sell Sold Sign", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("ItemName") then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Sell") end
        end
    end
    msg("Dark X","Sell Sold Sign")
end)
extra:Button("Vehicle Speed", function()
    for _,v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Owner") and v.Owner.Value==player and v.PrimaryPart then
            local bv=v.PrimaryPart:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity",v.PrimaryPart)
            bv.Velocity=Vector3.new(0,0,50)
        end
    end
    msg("Dark X","Vehicle Speed")
end)
extra:Button("Box Sort", function()
    local items=getOwned()
    table.sort(items, function(a,b) return a.Name<b.Name end)
    local h=hrp()
    if h then
        for i,item in ipairs(items) do
            if item.PrimaryPart then item:SetPrimaryPartCFrame(h.CFrame*CFrame.new((i%5)*4,2,-8-math.floor(i/5)*4)) end
        end
    end
    msg("Dark X","Box Sort")
end)
extra:Button("Set Plank Name", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("ItemName") then item.ItemName.Value="Plank" end
    end
    msg("Dark X","Set Plank Name")
end)
extra:Button("Stand Plank", function()
    for _,item in pairs(getOwned()) do
        if item.PrimaryPart then item.PrimaryPart.Anchored=true end
    end
    msg("Dark X","Stand Plank")
end)
extra:Button("Click to Delete", function()
    for _,item in pairs(getOwned()) do item:Destroy() end
    msg("Dark X","click to Delete")
end)
extra:Button("Tp All Items", function()
    local h=hrp()
    if h then
        for i,item in ipairs(getOwned()) do
            if item.PrimaryPart then item:SetPrimaryPartCFrame(h.CFrame*CFrame.new((i%5)*4,2,-8-math.floor(i/5)*4)) end
        end
    end
    msg("Dark X","Tp All Selected Item")
end)
extra:Button("Mod Sawmill", function()
    if not S.selectedSawmill then msg("Dark X","select sawmill first") return end
    for _,p in pairs(S.selectedSawmill:GetDescendants()) do
        if p:IsA("BasePart") and S.woodColor then p.Color=S.woodColor end
    end
    msg("Dark X","Mod Sawmill")
end)
extra:Button("One Unit Cutter", function()
    if not S.selectedTree then msg("Dark X","select wood first") return end
    chop(S.selectedTree)
    msg("Dark X","One Unit Cutter")
end)
extra:Button("View Phantom", function()
    for _,t in pairs(getTrees()) do
        if t:FindFirstChild("TreeClass") and tostring(t.TreeClass.Value):find("Phantom") then
            local h=hrp()
            if h and t.PrimaryPart then t:SetPrimaryPartCFrame(h.CFrame*CFrame.new(0,0,-8)) msg("Dark X","View phantom tree") return end
        end
    end
    msg("Dark X","Not Found Phantom Tree")
end)
extra:Button("Select Axe", function()
    local axe=getAxe()
    if axe then S.selectedAxe=axe msg("Dark X","Select the Axe") else msg("Dark X","need axe") end
end)
extra:Button("Select Store", function()
    msg("Dark X","Select Store")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t then S.selectedStore=t:FindFirstAncestorOfClass("Model") msg("Dark X","Store selected") c:Disconnect() end
        end
    end)
end)
extra:Button("Select Blueprint", function()
    msg("Dark X","select blueprint")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t then S.selectedBlueprint=t:FindFirstAncestorOfClass("Model") msg("Dark X","selected") c:Disconnect() end
        end
    end)
end)
extra:Button("Load Preview", function()
    if not isfile or not isfile("build.txt") then msg("Dark x","not find file") return end
    msg("Dark x","load ur file at first")
end)
extra:Button("Execute Build", function()
    if not S.selectedBlueprint then msg("Dark x","execute ur build preview at first") return end
    msg("Dark x","Click Build if u already build done")
end)
extra:Button("Set Position", function()
    msg("Dark x","u need set Position")
end)
extra:Button("Endtimes Check", function()
    local axe=getAxe()
    if axe and axe.Name:find("Endtimes") then msg("Dark X","have EndtimesAxe") else msg("Dark X","you need a EndtimesAxe") end
end)
extra:Button("Floor2 Check", function()
    local has=false
    for _,item in pairs(getOwned()) do if item.Name:find("Floor2") then has=true break end end
    if not has then msg("Dark x","u need to buy floor2") else msg("Dark x","have floor2") end
end)
extra:Button("Open Box", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Open box") end
    msg("Dark X","Open box")
end)
extra:Button("Click to Fill", function()
    msg("Dark X","Click to Fill")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t then
                local m=t:FindFirstAncestorOfClass("Model")
                if m then
                    local rs=game:GetService("ReplicatedStorage")
                    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
                    if re then re:FireServer("Fill", m) end
                    msg("Dark X","filled")
                    c:Disconnect()
                end
            end
        end
    end)
end)
extra:Button("Hard Dragger", function()
    msg("Dark X","Hard Dragger on")
end)
extra:Button("Auto Buy All BluePrints", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Auto Buy All BluePrints") end
    msg("Dark X","Auto Buy All BluePrints")
end)
extra:Button("Get Blueprint Tool", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Open box") end
    msg("Dark X","Get Blueprint Tool")
end)
extra:Button("Max Settings", function()
    if not S.selectedSawmill then msg("Dark X","select sawmill first") return end
    for _,v in pairs(S.selectedSawmill:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value=100 end
    end
    msg("Dark X","Max Sawmill Settings")
end)
extra:Button("Min Settings", function()
    if not S.selectedSawmill then msg("Dark X","select sawmill first") return end
    for _,v in pairs(S.selectedSawmill:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value=1 end
    end
    msg("Dark X","Lowest Sawmill Settings")
end)
extra:Button("Auto Pick Up", function()
    for _,item in pairs(workspace:GetChildren()) do
        local owner=item:FindFirstChild("Owner")
        local tn=item:FindFirstChild("ToolName")
        if owner and owner.Value==player and tn then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Pick up tool") end
        end
    end
    msg("Dark X","Auto Pick Up Axe")
end)
extra:Button("Spawn Vehicle", function()
    msg("Dark X","Click a spawn pad")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t and (t.Name:find("Spawn") or t.Name:find("Pad")) then
                local rs=game:GetService("ReplicatedStorage")
                local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
                if re then re:FireServer("Spawn Vehicle") end
                msg("Dark X","Finished spawning vehicle")
                c:Disconnect()
            end
        end
    end)
end)
extra:Button("Flip Vehicle", function()
    for _,v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Owner") and v.Owner.Value==player and v.PrimaryPart then
            v:SetPrimaryPartCFrame(v.PrimaryPart.CFrame * CFrame.Angles(math.pi,0,0))
        end
    end
    msg("Dark X","Flip Vehicle")
end)
extra:Button("Bring All Plank", function()
    local h=hrp()
    if h then
        for i,item in ipairs(getOwned()) do
            if item.PrimaryPart then item:SetPrimaryPartCFrame(h.CFrame*CFrame.new((i%5)*4,2,-8-math.floor(i/5)*4)) end
        end
    end
    msg("Dark X","Bring All Plank")
end)
extra:Button("Cut Tree Joints", function()
    if not S.selectedTree then msg("Dark X","select wood first") return end
    chop(S.selectedTree)
    msg("Dark X","cut done")
end)
extra:Button("Find Spooky Wood", function()
    for _,t in pairs(getTrees()) do
        if t:FindFirstChild("TreeClass") and tostring(t.TreeClass.Value):find("Spooky") then
            local h=hrp()
            if h and t.PrimaryPart then t:SetPrimaryPartCFrame(h.CFrame*CFrame.new(0,0,-8)) msg("Dark X","Found Spooky") return end
        end
    end
    msg("Dark X","Not Found Phantom Tree")
end)
extra:Button("View Phantom Tree", function()
    for _,t in pairs(getTrees()) do
        if t:FindFirstChild("TreeClass") and tostring(t.TreeClass.Value):find("Phantom") then
            local h=hrp()
            if h and t.PrimaryPart then t:SetPrimaryPartCFrame(h.CFrame*CFrame.new(0,0,-8)) msg("Dark X","View phantom tree") return end
        end
    end
    msg("Dark X","Not Found Phantom Tree")
end)
extra:Button("One Unit Cutter", function()
    if not S.selectedTree then msg("Dark X","select wood first") return end
    chop(S.selectedTree)
    msg("Dark X","One Unit Cutter")
end)
extra:Button("Mod Sawmill", function()
    if not S.selectedSawmill then msg("Dark X","select sawmill first") return end
    for _,p in pairs(S.selectedSawmill:GetDescendants()) do
        if p:IsA("BasePart") and S.woodColor then p.Color=S.woodColor end
    end
    msg("Dark X","Mod Sawmill")
end)
extra:Button("Plank Size 1", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("Main") and item.Main:IsA("BasePart") then item.Main.Size=Vector3.new(1,1,1) end
    end
    msg("Dark X","Make Selected Plank Size To 1")
end)
extra:Button("Sell Plank", function()
    for _,item in pairs(getOwned()) do
        if item.Name:find("Plank") or (item:FindFirstChild("ItemName") and tostring(item.ItemName.Value):find("Plank")) then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Sell") end
        end
    end
    msg("Dark X","click to sell plank")
end)
extra:Button("Calm Rukiryaxe", function()
    local axe=getAxe()
    if not axe then msg("Dark X","need axe") return end
    if axe.Name:find("Rukiryaxe") then
        local r=axe:FindFirstChildWhichIsA("RemoteEvent",true)
        if r then r:FireServer("Calm") end
    end
    msg("Dark X","Auto Calm Rukiryaxe")
end)
extra:Button("Dupe Power", function()
    local rs=game:GetService("ReplicatedStorage")
    local rf=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if rf then rf:InvokeServer() end
    msg("Dark X","Dupe Power To Build With ease")
end)
extra:Button("Slot Save", function()
    local rs=game:GetService("ReplicatedStorage")
    local rf=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if rf then rf:InvokeServer() end
    msg("Dark X","Slot saved successfully")
end)
extra:Button("Dupe Slot", function()
    local rs=game:GetService("ReplicatedStorage")
    local rf=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if rf then rf:InvokeServer() end
    msg("Dark X","Dupe Slot")
end)
extra:Button("Land Art", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Land Art") end
    msg("Dark X","Land Art")
end)
extra:Button("Leave", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    msg("Dark X","Leave without save")
end)
extra:Button("Deload", function()
    local rs=game:GetService("ReplicatedStorage")
    local rf=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if rf then rf:InvokeServer() end
    msg("Dark X","Deload(no load cooldown)")
end)
extra:Button("Fast Load", function()
    local rs=game:GetService("ReplicatedStorage")
    local rf=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if rf then rf:InvokeServer() end
    msg("Dark X","Fast Load")
end)
extra:Button("Anti BlackList", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Anti BlackList") end
    msg("Dark X","Anti BlackList")
end)
extra:Button("Check Money", function()
    local ls=player:FindFirstChild("leaderstats")
    if ls then
        local m=ls:FindFirstChild("Money") or ls:FindFirstChild("Cash")
        if m then msg("Dark X",tostring(m.Value)) end
    end
end)
extra:Button("Hard Dragger", function()
    msg("Dark X","Hard Dragger on")
end)
extra:Button("Auto Filler", function()
    msg("Dark X","Auto Filler")
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Fill") end
end)
extra:Button("Click to Fill", function()
    msg("Dark X","Click to Fill")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t then
                local m=t:FindFirstAncestorOfClass("Model")
                if m then
                    local rs=game:GetService("ReplicatedStorage")
                    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
                    if re then re:FireServer("Fill", m) end
                    msg("Dark X","filled")
                    c:Disconnect()
                end
            end
        end
    end)
end)
extra:Button("Get All Blueprint", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Get All blueprint") end
    msg("Dark X","Get All blueprint")
end)
extra:Button("Fill All", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Fill All blueprint") end
    msg("Dark X","Fill All blueprint")
end)
extra:Button("Loop Auto Buy", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then task.spawn(function() while true do re:FireServer("Buy") task.wait(0.5) end end) end
    msg("Dark X","Loop Auto Buy")
end)
extra:Button("Auto Buy All BluePrints", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Auto Buy All BluePrints") end
    msg("Dark X","Auto Buy All BluePrints")
end)
extra:Button("Get Blueprint Tool", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Open box") end
    msg("Dark X","Get Blueprint Tool")
end)
extra:Button("Sold Sign Dupe", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Sold Sign Dupe") end
    msg("Dark X","Sold Sign Dupe")
end)
extra:Button("Auto Farm Sold Sign", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("ItemName") then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Take down sold sign") end
        end
    end
    msg("Dark X","Auto Farm Sold Sign")
end)
extra:Button("Sell Sold Sign", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("ItemName") then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Sell") end
        end
    end
    msg("Dark X","Sell Sold Sign")
end)
extra:Button("Vehicle Speed", function()
    for _,v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Owner") and v.Owner.Value==player and v.PrimaryPart then
            local bv=v.PrimaryPart:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity",v.PrimaryPart)
            bv.Velocity=Vector3.new(0,0,50)
        end
    end
    msg("Dark X","Vehicle Speed")
end)
extra:Button("Box Sort", function()
    local items=getOwned()
    table.sort(items, function(a,b) return a.Name<b.Name end)
    local h=hrp()
    if h then
        for i,item in ipairs(items) do
            if item.PrimaryPart then item:SetPrimaryPartCFrame(h.CFrame*CFrame.new((i%5)*4,2,-8-math.floor(i/5)*4)) end
        end
    end
    msg("Dark X","Box Sort")
end)
extra:Button("Set Plank Name", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("ItemName") then item.ItemName.Value="Plank" end
    end
    msg("Dark X","Set Plank Name")
end)
extra:Button("Stand Plank", function()
    for _,item in pairs(getOwned()) do
        if item.PrimaryPart then item.PrimaryPart.Anchored=true end
    end
    msg("Dark X","Stand Plank")
end)
extra:Button("Click to Delete", function()
    for _,item in pairs(getOwned()) do item:Destroy() end
    msg("Dark X","click to Delete")
end)
extra:Button("Tp All Items", function()
    local h=hrp()
    if h then
        for i,item in ipairs(getOwned()) do
            if item.PrimaryPart then item:SetPrimaryPartCFrame(h.CFrame*CFrame.new((i%5)*4,2,-8-math.floor(i/5)*4)) end
        end
    end
    msg("Dark X","Tp All Selected Item")
end)
extra:Button("Select Axe", function()
    local axe=getAxe()
    if axe then S.selectedAxe=axe msg("Dark X","Select the Axe") else msg("Dark X","need axe") end
end)
extra:Button("Select Store", function()
    msg("Dark X","Select Store")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t then S.selectedStore=t:FindFirstAncestorOfClass("Model") msg("Dark X","Store selected") c:Disconnect() end
        end
    end)
end)
extra:Button("Select Blueprint", function()
    msg("Dark X","select blueprint")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t then S.selectedBlueprint=t:FindFirstAncestorOfClass("Model") msg("Dark X","selected") c:Disconnect() end
        end
    end)
end)
extra:Button("Load Preview", function()
    if not isfile or not isfile("build.txt") then msg("Dark x","not find file") return end
    msg("Dark x","load ur file at first")
end)
extra:Button("Execute Build", function()
    if not S.selectedBlueprint then msg("Dark x","execute ur build preview at first") return end
    msg("Dark x","Click Build if u already build done")
end)
extra:Button("Set Position", function()
    msg("Dark x","u need set Position")
end)
extra:Button("Endtimes Check", function()
    local axe=getAxe()
    if axe and axe.Name:find("Endtimes") then msg("Dark X","have EndtimesAxe") else msg("Dark X","you need a EndtimesAxe") end
end)
extra:Button("Floor2 Check", function()
    local has=false
    for _,item in pairs(getOwned()) do if item.Name:find("Floor2") then has=true break end end
    if not has then msg("Dark x","u need to buy floor2") else msg("Dark x","have floor2") end
end)
extra:Button("Open Box", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Open box") end
    msg("Dark X","Open box")
end)
extra:Button("Max Settings", function()
    if not S.selectedSawmill then msg("Dark X","select sawmill first") return end
    for _,v in pairs(S.selectedSawmill:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value=100 end
    end
    msg("Dark X","Max Sawmill Settings")
end)
extra:Button("Min Settings", function()
    if not S.selectedSawmill then msg("Dark X","select sawmill first") return end
    for _,v in pairs(S.selectedSawmill:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value=1 end
    end
    msg("Dark X","Lowest Sawmill Settings")
end)
extra:Button("Auto Pick Up", function()
    for _,item in pairs(workspace:GetChildren()) do
        local owner=item:FindFirstChild("Owner")
        local tn=item:FindFirstChild("ToolName")
        if owner and owner.Value==player and tn then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Pick up tool") end
        end
    end
    msg("Dark X","Auto Pick Up Axe")
end)
extra:Button("Spawn Vehicle", function()
    msg("Dark X","Click a spawn pad")
    local c c=UIS.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            local t=player:GetMouse().Target
            if t and (t.Name:find("Spawn") or t.Name:find("Pad")) then
                local rs=game:GetService("ReplicatedStorage")
                local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
                if re then re:FireServer("Spawn Vehicle") end
                msg("Dark X","Finished spawning vehicle")
                c:Disconnect()
            end
        end
    end)
end)
extra:Button("Flip Vehicle", function()
    for _,v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("Owner") and v.Owner.Value==player and v.PrimaryPart then
            v:SetPrimaryPartCFrame(v.PrimaryPart.CFrame * CFrame.Angles(math.pi,0,0))
        end
    end
    msg("Dark X","Flip Vehicle")
end)
extra:Button("Bring All Plank", function()
    local h=hrp()
    if h then
        for i,item in ipairs(getOwned()) do
            if item.PrimaryPart then item:SetPrimaryPartCFrame(h.CFrame*CFrame.new((i%5)*4,2,-8-math.floor(i/5)*4)) end
        end
    end
    msg("Dark X","Bring All Plank")
end)
extra:Button("Cut Tree Joints", function()
    if not S.selectedTree then msg("Dark X","select wood first") return end
    chop(S.selectedTree)
    msg("Dark X","cut done")
end)
extra:Button("Find Spooky Wood", function()
    for _,t in pairs(getTrees()) do
        if t:FindFirstChild("TreeClass") and tostring(t.TreeClass.Value):find("Spooky") then
            local h=hrp()
            if h and t.PrimaryPart then t:SetPrimaryPartCFrame(h.CFrame*CFrame.new(0,0,-8)) msg("Dark X","Found Spooky") return end
        end
    end
    msg("Dark X","Not Found Phantom Tree")
end)
extra:Button("View Phantom Tree", function()
    for _,t in pairs(getTrees()) do
        if t:FindFirstChild("TreeClass") and tostring(t.TreeClass.Value):find("Phantom") then
            local h=hrp()
            if h and t.PrimaryPart then t:SetPrimaryPartCFrame(h.CFrame*CFrame.new(0,0,-8)) msg("Dark X","View phantom tree") return end
        end
    end
    msg("Dark X","Not Found Phantom Tree")
end)
extra:Button("One Unit Cutter", function()
    if not S.selectedTree then msg("Dark X","select wood first") return end
    chop(S.selectedTree)
    msg("Dark X","One Unit Cutter")
end)
extra:Button("Mod Sawmill", function()
    if not S.selectedSawmill then msg("Dark X","select sawmill first") return end
    for _,p in pairs(S.selectedSawmill:GetDescendants()) do
        if p:IsA("BasePart") and S.woodColor then p.Color=S.woodColor end
    end
    msg("Dark X","Mod Sawmill")
end)
extra:Button("Plank Size 1", function()
    for _,item in pairs(getOwned()) do
        if item:FindFirstChild("Main") and item.Main:IsA("BasePart") then item.Main.Size=Vector3.new(1,1,1) end
    end
    msg("Dark X","Make Selected Plank Size To 1")
end)
extra:Button("Sell Plank", function()
    for _,item in pairs(getOwned()) do
        if item.Name:find("Plank") or (item:FindFirstChild("ItemName") and tostring(item.ItemName.Value):find("Plank")) then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Sell") end
        end
    end
    msg("Dark X","click to sell plank")
end)
extra:Button("Sell All Tree", function()
    for _,t in pairs(getTrees()) do
        local r=t:FindFirstChildWhichIsA("RemoteEvent",true)
        if r then r:FireServer("Sell") end
    end
    msg("Dark X","Sell All Tree")
end)
extra:Button("Take Down Sold Sign", function()
    for _,item in pairs(workspace:GetChildren()) do
        local owner=item:FindFirstChild("Owner")
        local iname=item:FindFirstChild("ItemName")
        if owner and owner.Value==player and iname then
            local r=item:FindFirstChild("ButtonRemote_Toggle") or item:FindFirstChildWhichIsA("RemoteEvent",true)
            if r then r:FireServer("Take down sold sign") end
        end
    end
    msg("Dark X","Take down sold sign")
end)
extra:Button("Free Land", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Free Land") end
    msg("Dark X","Free Land")
end)
extra:Button("Max Land", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Max Land") end
    msg("Dark X","Max Land")
end)
extra:Button("Save Base", function()
    local rs=game:GetService("ReplicatedStorage")
    local rf=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if rf then rf:InvokeServer(game:GetService("Players"):GetPlayers(),0) end
    msg("Dark X","Save Base success")
end)
extra:Button("Load Base", function()
    local rs=game:GetService("ReplicatedStorage")
    local rf=rs:FindFirstChildWhichIsA("RemoteFunction",true)
    if rf then
        local ok=rf:InvokeServer()
        if not ok then msg("Dark X","Load is on cooldown. Waiting...") return end
    end
    msg("Dark X","Load Base")
end)
extra:Button("Get Blueprint", function()
    local rs=game:GetService("ReplicatedStorage")
    local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
    if re then re:FireServer("Open box") end
    msg("Dark X","Open box")
end)
extra:Button("Auto Buy", function()
    S.autoBuy=not S.autoBuy
    msg("Dark X", S.autoBuy and "Auto Buy on" or "off")
    if S.autoBuy then
        task.spawn(function()
            while S.autoBuy do
                local rs=game:GetService("ReplicatedStorage")
                local re=rs:FindFirstChildWhichIsA("RemoteEvent",true)
                if re then re:FireServer("Buy") end
                task.wait(1)
            end
        end)
    end
end)
extra:Button("Remove Water", function()
    for _,p in pairs(workspace:GetDescendants()) do
        if p:IsA("BasePart") and p.Name=="Water" then p:Destroy() end
    end
    msg("Dark X","Remove Water")
end)
extra:Button("Remove Boulders", function()
    for _,p in pairs(workspace:GetDescendants()) do
        if p.Name:find("Boulder") or p.Name:find("Rock") then p:Destroy() end
    end
    msg("Dark X","Remove Volcano Boulders")
end)
extra:Button("Shadows", function()
    Lighting.GlobalShadows=not Lighting.GlobalShadows
    msg("Dark X","Shadows")
end)
extra:Button("Inf Jump", function()
    UIS.JumpRequest:Connect(function()
        local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
    msg("Dark X","Inf Jump")
end)
extra:Button("Zoom", function()
    player.CameraMaxZoomDistance=500
    msg("Dark X","Zoom Distance")
end)
extra:Button("Walk Water", function()
    local p=Instance.new("Part",workspace)
    p.Name="WaterWalk" p.Size=Vector3.new(500,1,500) p.Anchored=true p.CanCollide=true p.Transparency=1 p.Position=Vector3.new(0,0,0)
    msg("Dark X","Walk On Water")
end)
extra:Button("Tp Player", function()
    local players=game:GetService("Players"):GetPlayers()
    if #players>1 then
        local t=players[2]
        if t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            tp(t.Character.HumanoidRootPart.Position)
        end
    end
    msg("Dark X","Tp to Player")
end)
extra:Button("Abort", function()
    S.autoFarm=false S.autoChop=false S.autoBuy=false
    msg("Dark X","Abort")
end)

print("Dark X loaded")
end
