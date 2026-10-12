local library = {
    flags = {}
}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Current = nil
local minimized = false
local OpenBtn = nil

local function updateOpenButton()
    if OpenBtn then
        OpenBtn.Text = minimized and "OPEN" or "CLOSE"
    end
end

local function ChangeTab(Holder)
    if Current == Holder then return end
    if Current then
        Current.Visible = false
    end
    Holder.Visible = true
    Current = Holder
end

local function UIMinimize(Main)
    minimized = not minimized
    local targetSize = minimized and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 480, 0, 293)
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = targetSize
    }):Play()
    updateOpenButton()
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

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
    Main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -240, 0.5, -146)
    Main.Size = UDim2.new(0, 480, 0, 293)
    Main.ClipsDescendants = true
    Main.Active = true

    local MainC = Instance.new("UICorner")
    MainC.CornerRadius = UDim.new(0, 8)
    MainC.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(40, 40, 50)
    MainStroke.Thickness = 1
    MainStroke.Parent = Main

    -- Top Bar
    local Top = Instance.new("Frame")
    Top.Name = "Top"
    Top.Parent = Main
    Top.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 38)
    Top.ZIndex = 5

    local TopC = Instance.new("UICorner")
    TopC.CornerRadius = UDim.new(0, 8)
    TopC.Parent = Top

    -- Custom Logo
    local Logo = Instance.new("Frame")
    Logo.Parent = Top
    Logo.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    Logo.Position = UDim2.new(0, 8, 0.5, -12)
    Logo.Size = UDim2.new(0, 24, 0, 24)
    local LogoC = Instance.new("UICorner")
    LogoC.CornerRadius = UDim.new(0, 6)
    LogoC.Parent = Logo
    local LogoStroke = Instance.new("UIStroke")
    LogoStroke.Color = Color3.fromRGB(140, 80, 255)
    LogoStroke.Thickness = 1.5
    LogoStroke.Parent = Logo

    local LogoText = Instance.new("TextLabel")
    LogoText.Parent = Logo
    LogoText.BackgroundTransparency = 1
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.Font = Enum.Font.GothamBold
    LogoText.Text = "SX"
    LogoText.TextColor3 = Color3.fromRGB(140, 80, 255)
    LogoText.TextSize = 11

    local Title = Instance.new("TextLabel")
    Title.Parent = Top
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 40, 0, 0)
    Title.Size = UDim2.new(0, 180, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "SoloX v2"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Sub = Instance.new("TextLabel")
    Sub.Parent = Top
    Sub.BackgroundTransparency = 1
    Sub.Position = UDim2.new(0, 95, 0, 0)
    Sub.Size = UDim2.new(0, 130, 1, 0)
    Sub.Font = Enum.Font.Gotham
    Sub.Text = "by Solodolosouls • NEW"
    Sub.TextColor3 = Color3.fromRGB(160, 160, 175)
    Sub.TextSize = 11
    Sub.TextXAlignment = Enum.TextXAlignment.Left

    local Close = Instance.new("TextButton")
    Close.Parent = Top
    Close.BackgroundTransparency = 1
    Close.Position = UDim2.new(1, -38, 0, 0)
    Close.Size = UDim2.new(0, 38, 1, 0)
    Close.Font = Enum.Font.GothamBold
    Close.Text = "×"
    Close.TextColor3 = Color3.fromRGB(200, 200, 200)
    Close.TextSize = 18
    Close.ZIndex = 6
    Close.MouseButton1Click:Connect(function()
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.delay(0.3, function() SoloX:Destroy() end)
    end)

    local Reduce = Instance.new("TextButton")
    Reduce.Parent = Top
    Reduce.BackgroundTransparency = 1
    Reduce.Position = UDim2.new(1, -76, 0, 0)
    Reduce.Size = UDim2.new(0, 38, 1, 0)
    Reduce.Font = Enum.Font.GothamBold
    Reduce.Text = "–"
    Reduce.TextColor3 = Color3.fromRGB(200, 200, 200)
    Reduce.TextSize = 18
    Reduce.ZIndex = 6
    Reduce.MouseButton1Click:Connect(function()
        UIMinimize(Main)
    end)

    -- Floating Open/Close button
    OpenBtn = Instance.new("TextButton")
    OpenBtn.Name = "Open"
    OpenBtn.Parent = SoloX
    OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    OpenBtn.Position = UDim2.new(0, 12, 0.5, -16)
    OpenBtn.Size = UDim2.new(0, 70, 0, 32)
    OpenBtn.Font = Enum.Font.GothamMedium
    OpenBtn.Text = "CLOSE"
    OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    OpenBtn.TextSize = 13
    OpenBtn.Active = true
    local OpenC = Instance.new("UICorner")
    OpenC.CornerRadius = UDim.new(0, 6)
    OpenC.Parent = OpenBtn
    local OpenStroke = Instance.new("UIStroke")
    OpenStroke.Color = Color3.fromRGB(50, 50, 60)
    OpenStroke.Thickness = 1
    OpenStroke.Parent = OpenBtn

    OpenBtn.MouseButton1Click:Connect(function()
        UIMinimize(Main)
    end)

    -- Top Tabs
    local TabBG = Instance.new("Frame")
    TabBG.Parent = Main
    TabBG.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    TabBG.BorderSizePixel = 0
    TabBG.Position = UDim2.new(0, 0, 0, 38)
    TabBG.Size = UDim2.new(1, 0, 0, 36)

    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Parent = TabBG
    TabHolder.BackgroundTransparency = 1
    TabHolder.BorderSizePixel = 0
    TabHolder.Position = UDim2.new(0, 6, 0, 4)
    TabHolder.Size = UDim2.new(1, -12, 1, -8)
    TabHolder.ScrollBarThickness = 0
    TabHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabHolder.ScrollingDirection = Enum.ScrollingDirection.X

    local TabHolderLL = Instance.new("UIListLayout")
    TabHolderLL.Parent = TabHolder
    TabHolderLL.Padding = UDim.new(0, 4)
    TabHolderLL.SortOrder = Enum.SortOrder.LayoutOrder
    TabHolderLL.FillDirection = Enum.FillDirection.Horizontal

    TabHolderLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabHolder.CanvasSize = UDim2.new(0, TabHolderLL.AbsoluteContentSize.X + 8, 0, 0)
    end)

    drag(Main, Top)

    local Tabs = {}

    function Tabs:Tab(Name, IconID)
        assert(Name, "A name is required")
        assert(IconID, "An Icon is required")

        local Holder = Instance.new("ScrollingFrame")
        Holder.Name = "Holder"
        Holder.Parent = Main
        Holder.BackgroundTransparency = 1
        Holder.BorderSizePixel = 0
        Holder.Position = UDim2.new(0, 8, 0, 82)
        Holder.Size = UDim2.new(1, -16, 1, -90)
        Holder.ScrollBarThickness = 2
        Holder.ScrollBarImageColor3 = Color3.fromRGB(140, 80, 255)
        Holder.Visible = false
        Holder.CanvasSize = UDim2.new(0, 0, 0, 0)

        local HolderLL = Instance.new("UIListLayout")
        HolderLL.Parent = Holder
        HolderLL.Padding = UDim.new(0, 5)
        HolderLL.SortOrder = Enum.SortOrder.LayoutOrder
        HolderLL.HorizontalAlignment = Enum.HorizontalAlignment.Center

        HolderLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Holder.CanvasSize = UDim2.new(0, 0, 0, HolderLL.AbsoluteContentSize.Y + 10)
        end)

        local Tab = Instance.new("TextButton")
        Tab.Parent = TabHolder
        Tab.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        Tab.Size = UDim2.new(0, 90, 1, 0)
        Tab.Font = Enum.Font.GothamMedium
        Tab.Text = ""
        Tab.AutoButtonColor = false

        local TabC = Instance.new("UICorner")
        TabC.CornerRadius = UDim.new(0, 6)
        TabC.Parent = Tab

        local Icon = Instance.new("ImageLabel")
        Icon.Parent = Tab
        Icon.BackgroundTransparency = 1
        Icon.Position = UDim2.new(0, 6, 0.5, -7)
        Icon.Size = UDim2.new(0, 14, 0, 14)
        Icon.Image = "rbxassetid://" .. tostring(IconID)
        Icon.ScaleType = Enum.ScaleType.Fit

        local TabText = Instance.new("TextLabel")
        TabText.Parent = Tab
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(0, 24, 0, 0)
        TabText.Size = UDim2.new(1, -28, 1, 0)
        TabText.Font = Enum.Font.GothamMedium
        TabText.Text = Name
        TabText.TextColor3 = Color3.fromRGB(190, 190, 200)
        TabText.TextSize = 11
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.TextTruncate = Enum.TextTruncate.AtEnd

        Tab.MouseButton1Click:Connect(function()
            ChangeTab(Holder)
            for _, v in ipairs(TabHolder:GetChildren()) do
                if v:IsA("TextButton") then
                    v.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
                    local lbl = v:FindFirstChild("TextLabel")
                    if lbl then lbl.TextColor3 = Color3.fromRGB(190, 190, 200) end
                end
            end
            Tab.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
            TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        if not Current then
            ChangeTab(Holder)
            Tab.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
            TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        local Sections = {}

        function Sections:section(Name)
            assert(Name, "A Name is required")

            local Section = Instance.new("TextLabel")
            Section.Parent = Holder
            Section.BackgroundTransparency = 1
            Section.Size = UDim2.new(1, -10, 0, 22)
            Section.Font = Enum.Font.GothamBold
            Section.Text = Name
            Section.TextColor3 = Color3.fromRGB(220, 220, 230)
            Section.TextSize = 14
            Section.TextXAlignment = Enum.TextXAlignment.Left

            local Content = {}

            function Content:Label(Name)
                assert(Name, "A name is required")
                local lbl = Instance.new("TextLabel")
                lbl.Parent = Holder
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.new(1, -10, 0, 20)
                lbl.Font = Enum.Font.Gotham
                lbl.Text = Name
                lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
                lbl.TextSize = 12
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                return lbl
            end

            function Content:Button(Name, Callback)
                assert(Name, "A name is required")
                local Btn = Instance.new("TextButton")
                Btn.Parent = Holder
                Btn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
                Btn.Size = UDim2.new(1, -10, 0, 32)
                Btn.Font = Enum.Font.GothamMedium
                Btn.Text = Name
                Btn.TextColor3 = Color3.fromRGB(230, 230, 240)
                Btn.TextSize = 12
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                Btn.AutoButtonColor = false
                local C = Instance.new("UICorner")
                C.CornerRadius = UDim.new(0, 6)
                C.Parent = Btn
                local Pad = Instance.new("UIPadding")
                Pad.PaddingLeft = UDim.new(0, 8)
                Pad.Parent = Btn

                Btn.MouseButton1Click:Connect(function()
                    if Callback then task.spawn(Callback) end
                end)
                return Btn
            end

            function Content:Toggle(Name, Default, Callback)
                assert(Name, "A name is required")
                local Toggle = self:Button(Name, nil)
                local Tog = Instance.new("Frame")
                Tog.Parent = Toggle
                Tog.BackgroundColor3 = Default and Color3.fromRGB(140, 80, 255) or Color3.fromRGB(45, 45, 55)
                Tog.Position = UDim2.new(1, -36, 0.5, -8)
                Tog.Size = UDim2.new(0, 30, 0, 16)
                local TogC = Instance.new("UICorner")
                TogC.CornerRadius = UDim.new(1, 0)
                TogC.Parent = Tog

                local Knob = Instance.new("Frame")
                Knob.Parent = Tog
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.Size = UDim2.new(0, 12, 0, 12)
                Knob.Position = Default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                local KnobC = Instance.new("UICorner")
                KnobC.CornerRadius = UDim.new(1, 0)
                KnobC.Parent = Knob

                local Funcs = {}
                Funcs.CurrentState = Default or false

                function Funcs:SetState(State)
                    if State == nil then State = not Funcs.CurrentState end
                    if State == Funcs.CurrentState then return end
                    Funcs.CurrentState = State
                    local pos = State and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                    local col = State and Color3.fromRGB(140, 80, 255) or Color3.fromRGB(45, 45, 55)
                    TweenService:Create(Knob, TweenInfo.new(0.15), {Position = pos}):Play()
                    TweenService:Create(Tog, TweenInfo.new(0.15), {BackgroundColor3 = col}):Play()
                    if Callback then task.spawn(Callback, State) end
                end

                if Default then Funcs:SetState(true) end

                Toggle.MouseButton1Click:Connect(function()
                    Funcs:SetState()
                end)

                return Funcs
            end

            function Content:TextBox(Name, Text, Callback)
                assert(Name, "A name is required")
                local TextBox = self:Button(Name, nil)
                local Input = Instance.new("TextBox")
                Input.Parent = TextBox
                Input.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
                Input.Position = UDim2.new(1, -105, 0.5, -10)
                Input.Size = UDim2.new(0, 95, 0, 20)
                Input.Font = Enum.Font.Gotham
                Input.Text = Text or ""
                Input.TextColor3 = Color3.fromRGB(255, 255, 255)
                Input.TextSize = 11
                Input.ClearTextOnFocus = false
                local C = Instance.new("UICorner")
                C.CornerRadius = UDim.new(0, 4)
                C.Parent = Input

                Input.FocusLost:Connect(function()
                    if Input.Text == "" then Input.Text = Text or "" end
                    if Callback then Callback(Input.Text) end
                end)
                return TextBox
            end

            function Content:KeyBind(Name, Key, Callback)
                assert(Name, "A name is required")
                local KeyBind = self:Button(Name, nil)
                local Input = Instance.new("TextButton")
                Input.Parent = KeyBind
                Input.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
                Input.Position = UDim2.new(1, -85, 0.5, -10)
                Input.Size = UDim2.new(0, 75, 0, 20)
                Input.Font = Enum.Font.GothamMedium
                Input.Text = (typeof(Key) == "string" and Key) or (Key and Key.Name) or "None"
                Input.TextColor3 = Color3.fromRGB(255, 255, 255)
                Input.TextSize = 11
                Input.AutoButtonColor = false
                local C = Instance.new("UICorner")
                C.CornerRadius = UDim.new(0, 4)
                C.Parent = Input

                local bindKey = (typeof(Key) == "string" and Enum.KeyCode[Key]) or Key
                local binding = false

                Input.MouseButton1Click:Connect(function()
                    binding = true
                    Input.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(inp, gpe)
                    if binding and not gpe and inp.UserInputType == Enum.UserInputType.Keyboard then
                        binding = false
                        bindKey = inp.KeyCode
                        Input.Text = inp.KeyCode.Name
                        if Callback then Callback(inp.KeyCode.Name) end
                    elseif not binding and bindKey and inp.KeyCode == bindKey and not gpe then
                        if Callback then Callback(bindKey.Name) end
                    end
                end)
                return KeyBind
            end

            function Content:Slider(Name, Default, min, max, test, Callback)
                assert(Name, "A name is required")
                local Slider = self:Button("", nil)
                Slider.Size = UDim2.new(1, -10, 0, 42)
                Slider.Text = ""

                local Title = Instance.new("TextLabel")
                Title.Parent = Slider
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 8, 0, 2)
                Title.Size = UDim2.new(1, -50, 0, 14)
                Title.Font = Enum.Font.GothamMedium
                Title.Text = Name
                Title.TextColor3 = Color3.fromRGB(220, 220, 230)
                Title.TextSize = 12
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local Back = Instance.new("Frame")
                Back.Parent = Slider
                Back.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                Back.Position = UDim2.new(0, 8, 0, 24)
                Back.Size = UDim2.new(1, -60, 0, 5)
                local BackC = Instance.new("UICorner")
                BackC.CornerRadius = UDim.new(1, 0)
                BackC.Parent = Back

                local Inner = Instance.new("Frame")
                Inner.Parent = Back
                Inner.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
                Inner.Size = UDim2.new(0, 0, 1, 0)
                local InnerC = Instance.new("UICorner")
                InnerC.CornerRadius = UDim.new(1, 0)
                InnerC.Parent = Inner

                local Number = Instance.new("TextLabel")
                Number.Parent = Slider
                Number.BackgroundTransparency = 1
                Number.Position = UDim2.new(1, -48, 0, 18)
                Number.Size = UDim2.new(0, 40, 0, 16)
                Number.Font = Enum.Font.Gotham
                Number.Text = tostring(Default or min)
                Number.TextColor3 = Color3.fromRGB(180, 180, 190)
                Number.TextSize = 11
                Number.TextXAlignment = Enum.TextXAlignment.Right

                local funcs = {
                    SetValue = function(self, value)
                        value = value or Default or min
                        local percent = math.clamp((value - min) / (max - min), 0, 1)
                        value = min + (max - min) * percent
                        Number.Text = tostring(math.floor(value * 10) / 10)
                        Inner.Size = UDim2.new(percent, 0, 1, 0)
                        if Callback then Callback(value) end
                    end
                }

                funcs:SetValue(Default)

                local dragging = false
                Back.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        local p = math.clamp((input.Position.X - Back.AbsolutePosition.X) / Back.AbsoluteSize.X, 0, 1)
                        funcs:SetValue(min + (max - min) * p)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local p = math.clamp((input.Position.X - Back.AbsolutePosition.X) / Back.AbsoluteSize.X, 0, 1)
                        funcs:SetValue(min + (max - min) * p)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                return Slider
            end

            function Content:DropDown(Name, Options, playerlib, test, Callback)
                assert(Name, "A name is required")
                local Dropdown = Instance.new("TextButton")
                Dropdown.Parent = Holder
                Dropdown.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
                Dropdown.Size = UDim2.new(1, -10, 0, 32)
                Dropdown.Font = Enum.Font.GothamMedium
                Dropdown.Text = Name
                Dropdown.TextColor3 = Color3.fromRGB(230, 230, 240)
                Dropdown.TextSize = 12
                Dropdown.TextXAlignment = Enum.TextXAlignment.Left
                Dropdown.AutoButtonColor = false
                local DC = Instance.new("UICorner")
                DC.CornerRadius = UDim.new(0, 6)
                DC.Parent = Dropdown
                local Pad = Instance.new("UIPadding")
                Pad.PaddingLeft = UDim.new(0, 8)
                Pad.Parent = Dropdown

                local Plus = Instance.new("TextButton")
                Plus.Parent = Dropdown
                Plus.BackgroundTransparency = 1
                Plus.Position = UDim2.new(1, -32, 0, 0)
                Plus.Size = UDim2.new(0, 32, 1, 0)
                Plus.Font = Enum.Font.GothamBold
                Plus.Text = "+"
                Plus.TextColor3 = Color3.fromRGB(170, 170, 180)
                Plus.TextSize = 14

                local DropdownBack = Instance.new("Frame")
                DropdownBack.Parent = Dropdown
                DropdownBack.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
                DropdownBack.Position = UDim2.new(0, 0, 1, 2)
                DropdownBack.Size = UDim2.new(1, 0, 0, 0)
                DropdownBack.Visible = false
                DropdownBack.ClipsDescendants = true
                DropdownBack.ZIndex = 10
                local DBC = Instance.new("UICorner")
                DBC.CornerRadius = UDim.new(0, 6)
                DBC.Parent = DropdownBack

                local DropdownLL = Instance.new("UIListLayout")
                DropdownLL.Parent = DropdownBack
                DropdownLL.Padding = UDim.new(0, 1)

                local open = false
                local PlayerList = function()
                    local t = {}
                    for _, p in ipairs(Players:GetPlayers()) do table.insert(t, p.Name) end
                    return t
                end
                Options = playerlib and PlayerList() or Options or {}

                local function Open()
                    open = not open
                    Plus.Text = open and "-" or "+"
                    DropdownBack.Visible = open
                    local h = open and math.min(DropdownLL.AbsoluteContentSize.Y + 4, 120) or 0
                    TweenService:Create(DropdownBack, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, h)}):Play()
                end

                Plus.MouseButton1Click:Connect(Open)

                local Funcs = {}
                function Funcs:AddOption(Name2)
                    local Opt = Instance.new("TextButton")
                    Opt.Parent = DropdownBack
                    Opt.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
                    Opt.Size = UDim2.new(1, -4, 0, 24)
                    Opt.Font = Enum.Font.Gotham
                    Opt.Text = Name2
                    Opt.TextColor3 = Color3.fromRGB(210, 210, 220)
                    Opt.TextSize = 11
                    Opt.TextXAlignment = Enum.TextXAlignment.Left
                    Opt.AutoButtonColor = false
                    local OC = Instance.new("UICorner")
                    OC.CornerRadius = UDim.new(0, 4)
                    OC.Parent = Opt
                    local OP = Instance.new("UIPadding")
                    OP.PaddingLeft = UDim.new(0, 6)
                    OP.Parent = Opt
                    Opt.MouseButton1Click:Connect(function()
                        Open()
                        Dropdown.Text = Name2
                        if Callback then Callback(Name2) end
                    end)
                end

                function Funcs:SetOptions(opts)
                    for _, c in ipairs(DropdownBack:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    for _, v in ipairs(opts) do Funcs:AddOption(tostring(v)) end
                end

                Funcs:SetOptions(Options)
                return Funcs
            end

            return Content
        end

        return Sections
    end

    return Tabs
end

return library
