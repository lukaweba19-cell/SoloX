local library = {
    flags = {}
}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Current = nil
local minimized = false

local function ChangeTab(Holder)
    if Current == Holder then return end
    if Current then
        Current:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Sine", 0.3, false)
        task.wait(0.3)
        Current.Visible = false
    end
    Holder.Visible = true
    Holder:TweenSize(UDim2.new(1, -140, 1, -50), "Out", "Sine", 0.35, false)
    Current = Holder
end

local function UIMinimize(Main)
    if minimized then
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 520, 0, 340)
        }):Play()
        minimized = false
    else
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        minimized = true
    end
end

local function drag(frame, hold)
    if not hold then hold = frame end
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

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

    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            update(input)
        end
    end)
end

function library:new(Name)
    assert(Name, "A name is required")

    local SoloX = Instance.new("ScreenGui")
    SoloX.Name = "SoloX"
    SoloX.ResetOnSpawn = false
    SoloX.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    SoloX.Parent = game:GetService("CoreGui")

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = SoloX
    Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -260, 0.5, -170)
    Main.Size = UDim2.new(0, 520, 0, 340)
    Main.ClipsDescendants = true
    Main.Active = true

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(40, 40, 50)
    MainStroke.Thickness = 1
    MainStroke.Parent = Main

    -- Top Bar
    local Top = Instance.new("Frame")
    Top.Name = "Top"
    Top.Parent = Main
    Top.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 42)
    Top.ZIndex = 5

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = Top

    local Title = Instance.new("TextLabel")
    Title.Parent = Top
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 48, 0, 0)
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "SoloX"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Parent = Top
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0, 100, 0, 0)
    Subtitle.Size = UDim2.new(0, 200, 1, 0)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "by Solodolosouls"
    Subtitle.TextColor3 = Color3.fromRGB(160, 160, 180)
    Subtitle.TextSize = 12
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left

    local Logo = Instance.new("TextLabel")
    Logo.Parent = Top
    Logo.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
    Logo.Position = UDim2.new(0, 10, 0.5, -12)
    Logo.Size = UDim2.new(0, 28, 0, 28)
    Logo.Font = Enum.Font.GothamBold
    Logo.Text = "X"
    Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    Logo.TextSize = 16
    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 6)
    LogoCorner.Parent = Logo

    -- Close & Minimize
    local Close = Instance.new("TextButton")
    Close.Parent = Top
    Close.BackgroundTransparency = 1
    Close.Position = UDim2.new(1, -40, 0, 0)
    Close.Size = UDim2.new(0, 40, 1, 0)
    Close.Font = Enum.Font.GothamBold
    Close.Text = "×"
    Close.TextColor3 = Color3.fromRGB(200, 200, 200)
    Close.TextSize = 20
    Close.ZIndex = 6
    Close.MouseButton1Click:Connect(function()
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.35)
        SoloX:Destroy()
    end)

    local Reduce = Instance.new("TextButton")
    Reduce.Parent = Top
    Reduce.BackgroundTransparency = 1
    Reduce.Position = UDim2.new(1, -80, 0, 0)
    Reduce.Size = UDim2.new(0, 40, 1, 0)
    Reduce.Font = Enum.Font.GothamBold
    Reduce.Text = "–"
    Reduce.TextColor3 = Color3.fromRGB(200, 200, 200)
    Reduce.TextSize = 20
    Reduce.ZIndex = 6
    Reduce.MouseButton1Click:Connect(function()
        UIMinimize(Main)
    end)

    -- Open Button (mobile friendly)
    local Open = Instance.new("TextButton")
    Open.Name = "Open"
    Open.Parent = SoloX
    Open.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Open.Position = UDim2.new(0, 12, 0.5, -20)
    Open.Size = UDim2.new(0, 90, 0, 36)
    Open.Font = Enum.Font.GothamMedium
    Open.Text = "SoloX"
    Open.TextColor3 = Color3.fromRGB(255, 255, 255)
    Open.TextSize = 14
    Open.Active = true
    local OpenCorner = Instance.new("UICorner")
    OpenCorner.CornerRadius = UDim.new(0, 8)
    OpenCorner.Parent = Open
    Open.MouseButton1Click:Connect(function()
        UIMinimize(Main)
    end)

    -- Left Tabs
    local TabBG = Instance.new("Frame")
    TabBG.Parent = Main
    TabBG.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    TabBG.BorderSizePixel = 0
    TabBG.Position = UDim2.new(0, 0, 0, 42)
    TabBG.Size = UDim2.new(0, 130, 1, -42)

    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Parent = TabBG
    TabHolder.BackgroundTransparency = 1
    TabHolder.BorderSizePixel = 0
    TabHolder.Position = UDim2.new(0, 6, 0, 8)
    TabHolder.Size = UDim2.new(1, -12, 1, -16)
    TabHolder.ScrollBarThickness = 0
    TabHolder.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabHolderLL = Instance.new("UIListLayout")
    TabHolderLL.Parent = TabHolder
    TabHolderLL.Padding = UDim.new(0, 4)
    TabHolderLL.SortOrder = Enum.SortOrder.LayoutOrder

    TabHolderLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolderLL.AbsoluteContentSize.Y + 10)
    end)

    drag(Main, Top)

    local Tabs = {}

    function Tabs:Tab(Name, IconID)
        assert(Name, "A name is required")

        local Holder = Instance.new("ScrollingFrame")
        Holder.Name = "Holder"
        Holder.Parent = Main
        Holder.BackgroundTransparency = 1
        Holder.BorderSizePixel = 0
        Holder.Position = UDim2.new(0, 140, 0, 50)
        Holder.Size = UDim2.new(1, -150, 1, -60)
        Holder.ScrollBarThickness = 3
        Holder.ScrollBarImageColor3 = Color3.fromRGB(140, 80, 255)
        Holder.Visible = false
        Holder.CanvasSize = UDim2.new(0, 0, 0, 0)

        local HolderLL = Instance.new("UIListLayout")
        HolderLL.Parent = Holder
        HolderLL.Padding = UDim.new(0, 8)
        HolderLL.SortOrder = Enum.SortOrder.LayoutOrder
        HolderLL.HorizontalAlignment = Enum.HorizontalAlignment.Center

        HolderLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Holder.CanvasSize = UDim2.new(0, 0, 0, HolderLL.AbsoluteContentSize.Y + 16)
        end)

        local Tab = Instance.new("TextButton")
        Tab.Parent = TabHolder
        Tab.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        Tab.Size = UDim2.new(1, 0, 0, 36)
        Tab.Font = Enum.Font.GothamMedium
        Tab.Text = "  " .. Name
        Tab.TextColor3 = Color3.fromRGB(200, 200, 210)
        Tab.TextSize = 13
        Tab.TextXAlignment = Enum.TextXAlignment.Left
        Tab.AutoButtonColor = false

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = Tab

        if IconID then
            local Icon = Instance.new("ImageLabel")
            Icon.Parent = Tab
            Icon.BackgroundTransparency = 1
            Icon.Position = UDim2.new(0, 8, 0.5, -9)
            Icon.Size = UDim2.new(0, 18, 0, 18)
            Icon.Image = "rbxassetid://" .. tostring(IconID)
            Icon.ScaleType = Enum.ScaleType.Fit
            Tab.Text = "    " .. Name
        end

        Tab.MouseButton1Click:Connect(function()
            ChangeTab(Holder)
            for _, v in pairs(TabHolder:GetChildren()) do
                if v:IsA("TextButton") then
                    v.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
                    v.TextColor3 = Color3.fromRGB(200, 200, 210)
                end
            end
            Tab.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
            Tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        if not Current then
            ChangeTab(Holder)
            Tab.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
            Tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        local Sections = {}

        function Sections:section(Name)
            assert(Name, "A Name is required")

            local Section = Instance.new("TextLabel")
            Section.Parent = Holder
            Section.BackgroundTransparency = 1
            Section.Size = UDim2.new(1, -16, 0, 28)
            Section.Font = Enum.Font.GothamBold
            Section.Text = Name
            Section.TextColor3 = Color3.fromRGB(255, 255, 255)
            Section.TextSize = 15
            Section.TextXAlignment = Enum.TextXAlignment.Left

            local Content = {}

            function Content:Label(text)
                local lbl = Instance.new("TextLabel")
                lbl.Parent = Holder
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.new(1, -16, 0, 22)
                lbl.Font = Enum.Font.Gotham
                lbl.Text = "  " .. text
                lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
                lbl.TextSize = 13
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                return lbl
            end

            function Content:Button(Name, Callback)
                local Btn = Instance.new("TextButton")
                Btn.Parent = Holder
                Btn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
                Btn.Size = UDim2.new(1, -16, 0, 36)
                Btn.Font = Enum.Font.GothamMedium
                Btn.Text = "  " .. Name
                Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                Btn.TextSize = 13
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                Btn.AutoButtonColor = false

                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8)
                Corner.Parent = Btn

                local Stroke = Instance.new("UIStroke")
                Stroke.Color = Color3.fromRGB(50, 50, 60)
                Stroke.Thickness = 1
                Stroke.Parent = Btn

                Btn.MouseButton1Click:Connect(function()
                    TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(140, 80, 255)}):Play()
                    task.wait(0.12)
                    TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 32, 40)}):Play()
                    if Callback then task.spawn(Callback) end
                end)

                return Btn
            end

            function Content:Toggle(Name, Default, Callback)
                local Btn = self:Button(Name, nil)
                local Tog = Instance.new("Frame")
                Tog.Parent = Btn
                Tog.BackgroundColor3 = Default and Color3.fromRGB(140, 80, 255) or Color3.fromRGB(50, 50, 60)
                Tog.Position = UDim2.new(1, -42, 0.5, -10)
                Tog.Size = UDim2.new(0, 36, 0, 20)
                Tog.AnchorPoint = Vector2.new(0, 0)

                local TogCorner = Instance.new("UICorner")
                TogCorner.CornerRadius = UDim.new(1, 0)
                TogCorner.Parent = Tog

                local Knob = Instance.new("Frame")
                Knob.Parent = Tog
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.Size = UDim2.new(0, 16, 0, 16)
                Knob.Position = Default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)

                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = Knob

                local state = Default or false

                local function setState(newState)
                    state = newState
                    local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    local targetColor = state and Color3.fromRGB(140, 80, 255) or Color3.fromRGB(50, 50, 60)
                    TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
                    TweenService:Create(Tog, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                    if Callback then task.spawn(Callback, state) end
                end

                Btn.MouseButton1Click:Connect(function()
                    setState(not state)
                end)

                if Default then setState(true) end

                return {SetState = setState, CurrentState = function() return state end}
            end

            function Content:Slider(Name, Default, Min, Max, Callback)
                local Container = Instance.new("Frame")
                Container.Parent = Holder
                Container.BackgroundTransparency = 1
                Container.Size = UDim2.new(1, -16, 0, 48)

                local Title = Instance.new("TextLabel")
                Title.Parent = Container
                Title.BackgroundTransparency = 1
                Title.Size = UDim2.new(1, 0, 0, 18)
                Title.Font = Enum.Font.GothamMedium
                Title.Text = "  " .. Name
                Title.TextColor3 = Color3.fromRGB(220, 220, 230)
                Title.TextSize = 13
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local Back = Instance.new("Frame")
                Back.Parent = Container
                Back.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                Back.Position = UDim2.new(0, 8, 0, 26)
                Back.Size = UDim2.new(1, -70, 0, 6)

                local BackCorner = Instance.new("UICorner")
                BackCorner.CornerRadius = UDim.new(1, 0)
                BackCorner.Parent = Back

                local Fill = Instance.new("Frame")
                Fill.Parent = Back
                Fill.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
                Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = Fill

                local Knob = Instance.new("Frame")
                Knob.Parent = Back
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.Size = UDim2.new(0, 14, 0, 14)
                Knob.Position = UDim2.new((Default - Min) / (Max - Min), -7, 0.5, -7)
                Knob.AnchorPoint = Vector2.new(0, 0.5)

                local KnobCorner = Instance.new("UICorner")
                KnobCorner.CornerRadius = UDim.new(1, 0)
                KnobCorner.Parent = Knob

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Parent = Container
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Position = UDim2.new(1, -50, 0, 22)
                ValueLabel.Size = UDim2.new(0, 42, 0, 18)
                ValueLabel.Font = Enum.Font.GothamMedium
                ValueLabel.Text = tostring(Default)
                ValueLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
                ValueLabel.TextSize = 12
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

                local dragging = false

                local function update(value)
                    value = math.clamp(value, Min, Max)
                    local percent = (value - Min) / (Max - Min)
                    Fill.Size = UDim2.new(percent, 0, 1, 0)
                    Knob.Position = UDim2.new(percent, -7, 0.5, -7)
                    ValueLabel.Text = tostring(math.floor(value * 100) / 100)
                    if Callback then Callback(value) end
                end

                Back.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        local percent = math.clamp((input.Position.X - Back.AbsolutePosition.X) / Back.AbsoluteSize.X, 0, 1)
                        update(Min + (Max - Min) * percent)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local percent = math.clamp((input.Position.X - Back.AbsolutePosition.X) / Back.AbsoluteSize.X, 0, 1)
                        update(Min + (Max - Min) * percent)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                update(Default)
                return {SetValue = update}
            end

            function Content:TextBox(Name, Placeholder, Callback)
                local Btn = self:Button(Name, nil)
                local Box = Instance.new("TextBox")
                Box.Parent = Btn
                Box.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
                Box.Position = UDim2.new(1, -120, 0.5, -12)
                Box.Size = UDim2.new(0, 110, 0, 24)
                Box.Font = Enum.Font.Gotham
                Box.Text = Placeholder or ""
                Box.PlaceholderText = Placeholder or ""
                Box.TextColor3 = Color3.fromRGB(255, 255, 255)
                Box.TextSize = 12
                Box.ClearTextOnFocus = false

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 6)
                BoxCorner.Parent = Box

                Box.FocusLost:Connect(function()
                    if Callback then Callback(Box.Text) end
                end)

                return Box
            end

            function Content:KeyBind(Name, DefaultKey, Callback)
                local Btn = self:Button(Name, nil)
                local KeyLabel = Instance.new("TextLabel")
                KeyLabel.Parent = Btn
                KeyLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
                KeyLabel.Position = UDim2.new(1, -90, 0.5, -12)
                KeyLabel.Size = UDim2.new(0, 80, 0, 24)
                KeyLabel.Font = Enum.Font.GothamMedium
                KeyLabel.Text = DefaultKey or "None"
                KeyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                KeyLabel.TextSize = 12

                local KeyCorner = Instance.new("UICorner")
                KeyCorner.CornerRadius = UDim.new(0, 6)
                KeyCorner.Parent = KeyLabel

                local binding = false
                local currentKey = DefaultKey

                KeyLabel.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        binding = true
                        KeyLabel.Text = "..."
                    end
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if binding and not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
                        binding = false
                        currentKey = input.KeyCode.Name
                        KeyLabel.Text = currentKey
                        if Callback then Callback(currentKey) end
                    end
                end)

                return {GetKey = function() return currentKey end}
            end

            function Content:DropDown(Name, Options, Callback)
                local Btn = self:Button(Name, nil)
                local Arrow = Instance.new("TextLabel")
                Arrow.Parent = Btn
                Arrow.BackgroundTransparency = 1
                Arrow.Position = UDim2.new(1, -28, 0, 0)
                Arrow.Size = UDim2.new(0, 24, 1, 0)
                Arrow.Font = Enum.Font.GothamBold
                Arrow.Text = "▼"
                Arrow.TextColor3 = Color3.fromRGB(180, 180, 190)
                Arrow.TextSize = 12

                local List = Instance.new("Frame")
                List.Parent = Holder
                List.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
                List.Size = UDim2.new(1, -16, 0, 0)
                List.Visible = false
                List.ClipsDescendants = true
                List.ZIndex = 10

                local ListCorner = Instance.new("UICorner")
                ListCorner.CornerRadius = UDim.new(0, 8)
                ListCorner.Parent = List

                local ListLL = Instance.new("UIListLayout")
                ListLL.Parent = List
                ListLL.Padding = UDim.new(0, 2)

                local open = false
                local selected = Options[1] or ""

                local function toggle()
                    open = not open
                    List.Visible = open
                    local target = open and (#Options * 28 + 8) or 0
                    TweenService:Create(List, TweenInfo.new(0.2), {Size = UDim2.new(1, -16, 0, target)}):Play()
                    Arrow.Text = open and "▲" or "▼"
                end

                Btn.MouseButton1Click:Connect(toggle)

                for _, opt in ipairs(Options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Parent = List
                    OptBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
                    OptBtn.Size = UDim2.new(1, -8, 0, 26)
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.Text = "  " .. opt
                    OptBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
                    OptBtn.TextSize = 12
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptBtn.AutoButtonColor = false

                    local OptCorner = Instance.new("UICorner")
                    OptCorner.CornerRadius = UDim.new(0, 6)
                    OptCorner.Parent = OptBtn

                    OptBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        Btn.Text = "  " .. Name .. ": " .. opt
                        toggle()
                        if Callback then Callback(opt) end
                    end)
                end

                return {GetSelected = function() return selected end}
            end

            return Content
        end

        return Sections
    end

    return Tabs
end

return library
