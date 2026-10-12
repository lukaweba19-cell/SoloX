local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local minimized = false
local gui

local function msg(text)
    if not gui then return end
    local n = Instance.new("Frame")
    n.Parent = gui
    n.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
    n.BorderSizePixel = 0
    n.Position = UDim2.new(0.5, -120, 0, -40)
    n.Size = UDim2.new(0, 240, 0, 36)
    n.ZIndex = 20
    local nc = Instance.new("UICorner")
    nc.CornerRadius = UDim.new(0, 6)
    nc.Parent = n
    local ns = Instance.new("UIStroke")
    ns.Color = Color3.fromRGB(140, 80, 255)
    ns.Thickness = 1
    ns.Parent = n
    local nt = Instance.new("TextLabel")
    nt.Parent = n
    nt.BackgroundTransparency = 1
    nt.Size = UDim2.new(1, 0, 1, 0)
    nt.Font = Enum.Font.GothamMedium
    nt.Text = text
    nt.TextColor3 = Color3.fromRGB(200, 180, 255)
    nt.TextSize = 13
    nt.ZIndex = 21
    TweenService:Create(n, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -120, 0, 12)}):Play()
    task.delay(3, function()
        if n and n.Parent then
            TweenService:Create(n, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -120, 0, -40)}):Play()
            task.wait(0.3)
            n:Destroy()
        end
    end)
end

local function leaveNow()
    local req = request or (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request)
    if not req then return end
    local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
    local res = req(url)
    local data = game:GetService("HttpService"):JSONDecode(res.Body)
    local serverId
    if data and data.data then
        for _, s in pairs(data.data) do
            if s.playing < (s.maxPlayers - 2) and s.id ~= game.JobId then
                serverId = s.id
                break
            end
        end
    end
    if serverId then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, serverId, player)
    end
    task.wait()
    while not game:GetService("Players"):FindFirstChild(player.Name) do task.wait() end
    local ping = game:GetService("ReplicatedStorage"):FindFirstChild("TestPing")
    if ping then ping:InvokeServer() end
    player:Destroy()
    msg("leaving...")
end

local function turnSaveOff()
    local slot = player:FindFirstChild("CurrentSaveSlot", true)
    local saving = player:FindFirstChild("CurrentlySavingOrLoading", true)
    local slottoload = getgenv().slottoload or (slot and slot.Value) or 1
    local loadslot = getgenv().loadslot
    if slot and slot.Value ~= slottoload and loadslot then
        loadslot(slottoload)
        task.wait()
    end
    if saving then
        while saving.Value do task.wait() end
    end
    local donate = game:GetService("ReplicatedStorage"):FindFirstChild("Transactions")
    if donate then donate = donate:FindFirstChild("ClientToServer") end
    if donate then donate = donate:FindFirstChild("Donate") end
    if donate then
        local players = game:GetService("Players"):GetPlayers()
        donate:InvokeServer(players[2], 0, slottoload)
    end
    msg("save turned off")
    local startMin = os.date("*t").min
    local targetMin = startMin + 8
    if targetMin >= 60 then targetMin = targetMin - 60 end
    task.spawn(function()
        while true do
            task.wait(1)
            local now = os.date("*t").min
            if (targetMin > startMin and now >= targetMin) or (targetMin < startMin and (now >= targetMin or now < startMin)) then
                leaveNow()
                break
            end
        end
    end)
end

local function drag(frame, hold)
    if not hold then hold = frame end
    local dragging, dragStart, startPos
    hold.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

gui = Instance.new("ScreenGui")
gui.Name = "SoloXDupe"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game:GetService("CoreGui")

local openBtn = Instance.new("TextButton")
openBtn.Name = "Open"
openBtn.Parent = gui
openBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
openBtn.BorderSizePixel = 0
openBtn.Position = UDim2.new(1, -82, 0.5, -16)
openBtn.Size = UDim2.new(0, 70, 0, 32)
openBtn.Font = Enum.Font.GothamMedium
openBtn.Text = "CLOSE"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.TextSize = 13
openBtn.ZIndex = 10

local openC = Instance.new("UICorner")
openC.CornerRadius = UDim.new(0, 6)
openC.Parent = openBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(50, 50, 60)
openStroke.Thickness = 1
openStroke.Parent = openBtn

local main = Instance.new("Frame")
main.Name = "Main"
main.Parent = gui
main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
main.BorderSizePixel = 0
main.Position = UDim2.new(0.5, -140, 0.5, -90)
main.Size = UDim2.new(0, 280, 0, 180)
main.ClipsDescendants = true
main.Active = true

local mainC = Instance.new("UICorner")
mainC.CornerRadius = UDim.new(0, 8)
mainC.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(40, 40, 50)
stroke.Thickness = 1
stroke.Parent = main

local top = Instance.new("Frame")
top.Name = "Top"
top.Parent = main
top.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
top.BorderSizePixel = 0
top.Size = UDim2.new(1, 0, 0, 38)
top.ZIndex = 5

local topC = Instance.new("UICorner")
topC.CornerRadius = UDim.new(0, 8)
topC.Parent = top

local topFill = Instance.new("Frame")
topFill.Parent = top
topFill.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
topFill.BorderSizePixel = 0
topFill.Position = UDim2.new(0, 0, 0.5, 0)
topFill.Size = UDim2.new(1, 0, 0.5, 0)
topFill.ZIndex = 5

local title = Instance.new("TextLabel")
title.Parent = top
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 12, 0, 0)
title.Size = UDim2.new(1, -80, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "SoloX Dupe"
title.TextColor3 = Color3.fromRGB(220, 220, 230)
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = top
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Position = UDim2.new(1, -32, 0.5, -10)
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
closeBtn.TextSize = 12
closeBtn.ZIndex = 6

local closeC = Instance.new("UICorner")
closeC.CornerRadius = UDim.new(0, 4)
closeC.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local body = Instance.new("Frame")
body.Parent = main
body.BackgroundTransparency = 1
body.Position = UDim2.new(0, 0, 0, 38)
body.Size = UDim2.new(1, 0, 1, -38)

local layout = Instance.new("UIListLayout")
layout.Parent = body
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center

local pad = Instance.new("UIPadding")
pad.Parent = body
pad.PaddingTop = UDim.new(0, 12)
pad.PaddingBottom = UDim.new(0, 12)

local function makeBtn(text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = body
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(0, 240, 0, 40)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(210, 210, 220)
    btn.TextSize = 13
    btn.AutoButtonColor = false
    local btnC = Instance.new("UICorner")
    btnC.CornerRadius = UDim.new(0, 6)
    btnC.Parent = btn
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(50, 50, 60)
    btnStroke.Thickness = 1
    btnStroke.Parent = btn
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38, 38, 48)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28, 28, 36)}):Play()
    end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

makeBtn("Turn Save Off", turnSaveOff)
makeBtn("Leave Now", leaveNow)

local function toggle()
    minimized = not minimized
    local target = minimized and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 280, 0, 180)
    TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = target}):Play()
    openBtn.Text = minimized and "OPEN" or "CLOSE"
end

openBtn.MouseButton1Click:Connect(toggle)
drag(main, top)
drag(openBtn, openBtn)

print("SoloX Dupe loaded")
