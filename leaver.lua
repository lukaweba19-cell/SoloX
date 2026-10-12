local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RS = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local minimized = false

local function msg(t, m)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title=t, Text=m, Duration=4})
    end)
end

local function leaveWithoutSave()
    local data = player:FindFirstChild("PlayerData") or player:FindFirstChild("Data")
    if data then
        local saving = data:FindFirstChild("CurrentlySavingOrLoading")
        if saving then
            while saving.Value do task.wait() end
        end
    end
    local trans = RS:FindFirstChild("Transactions")
    if trans then
        local cts = trans:FindFirstChild("ClientToServer")
        if cts then
            local donate = cts:FindFirstChild("Donate")
            if donate then
                local players = Players:GetPlayers()
                local target = players[2] or players[1]
                local slot = data and data:FindFirstChild("CurrentSaveSlot") and data.CurrentSaveSlot.Value or 1
                donate:InvokeServer(target, 0, slot)
                msg("Dark X", "Save Base success")
                msg("Dark X", "u have 8mins to give items")
                return
            end
        end
    end
    msg("Dark X", "Leave without save")
end

local function leaveNow()
    local req = request or (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request)
    if not req then
        msg("Dark X", "no request")
        return
    end
    local ok, res = pcall(function()
        return req({
            Url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", game.PlaceId),
            Method = "GET"
        })
    end)
    if not ok or not res or not res.Body then
        msg("Dark X", "request failed")
        return
    end
    local data = HttpService:JSONDecode(res.Body)
    if data and data.data and #data.data > 0 then
        local servers = {}
        for _, s in pairs(data.data) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then
                table.insert(servers, s.id)
            end
        end
        if #servers > 0 then
            local id = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, id, player)
            msg("Dark X", "Leaving...")
            return
        end
    end
    TeleportService:Teleport(game.PlaceId, player)
    msg("Dark X", "Leave now")
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

local gui = Instance.new("ScreenGui")
gui.Name = "Leaver"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game:GetService("CoreGui")

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
title.Text = "Leaver"
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

makeBtn("Turn Save Off", leaveWithoutSave)
makeBtn("Leave Now", leaveNow)

drag(main, top)

print("Leaver loaded")
