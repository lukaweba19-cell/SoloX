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
        Current:TweenSize(UDim2.new(0, 347, 0, 0), "Out", "Sine", 0.35, false)
        task.wait(0.35)
        Current.Visible = false
    end
    Holder.Visible = true
    Holder:TweenSize(UDim2.new(0, 347, 0, 236), "Out", "Sine", 0.35, false)
    Current = Holder
end

local function UIMinimize(Main)
    if minimized then
        TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 480, 0, 293)
        }):Play()
        minimized = false
    else
        TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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
    Main.Position = UDim2.new(0.5, -240, 0.5, -146)
    Main.Size = UDim2.new(0, 480, 0, 293)
    Main.ClipsDescendants = true
    Main.Active = true

    local MainC = Instance.new("UICorner")
    MainC.CornerRadius = UDim.new(0, 10)
    MainC.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(50, 50, 60)
    MainStroke.Thickness = 1
    MainStroke.Parent = Main

    local Top = Instance.new("Frame")
    Top.Name = "Top"
    Top.Parent = Main
    Top.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 42)
    Top.ZIndex = 4

    local TopC = Instance.new("UICorner")
    TopC.CornerRadius = UDim.new(0, 10)
    TopC.Parent = Top

    local Logo = Instance.new("TextLabel")
    Logo.Parent = Top
    Logo.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
    Logo.Position = UDim2.new(0, 8, 0.5, -13)
    Logo.Size = UDim2.new(0, 26, 0, 26)
    Logo.Font = Enum.Font.GothamBold
    Logo.Text = "X"
    Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    Logo.TextSize = 15
    local LogoC = Instance.new("UICorner")
    LogoC.CornerRadius = UDim.new(0, 6)
    LogoC.Parent = Logo

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = Top
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 42, 0, 0)
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "SoloX"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Sub = Instance.new("TextLabel")
    Sub.Parent = Top
    Sub.BackgroundTransparency = 1
    Sub.Position = UDim2.new(0, 95, 0, 0)
    Sub.Size = UDim2.new(0, 140, 1, 0)
    Sub.Font = Enum.Font.Gotham
    Sub.Text = "by Solodolosouls"
    Sub.TextColor3 = Color3.fromRGB(170, 170, 185)
    Sub.TextSize = 11
    Sub.TextXAlignment = Enum.TextXAlignment.Left

    local Close = Instance.new("TextButton")
    Close.Name = "Close"
    Close.Parent = Top
    Close.BackgroundTransparency = 1
    Close.Position = UDim2.new(1, -40, 0, 0)
    Close.Size = UDim2.new(0, 40, 1, 0)
    Close.Font = Enum.Font.GothamBold
    Close.Text = "×"
    Close.TextColor3 = Color3.fromRGB(220, 220, 220)
    Close.TextSize = 20
    Close.ZIndex = 5
    Close.MouseButton1Click:Connect(function()
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.35)
        SoloX:Destroy()
    end)

    local Reduce = Instance.new("TextButton")
    Reduce.Name = "Reduce"
    Reduce.Parent = Top
    Reduce.BackgroundTransparency = 1
    Reduce.Position = UDim2.new(1, -80, 0, 0)
    Reduce.Size = UDim2.new(0, 40, 1, 0)
    Reduce.Font = Enum.Font.GothamBold
    Reduce.Text = "–"
    Reduce.TextColor3 = Color3.fromRGB(220, 220, 220)
    Reduce.TextSize = 20
    Reduce.ZIndex = 5
    Reduce.MouseButton1Click:Connect(function()
        UIMinimize(Main)
    end)

    local Open = Instance.new("TextButton")
    Open.Name = "Open"
    Open.Parent = SoloX
    Open.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Open.Position = UDim2.new(0, 10, 0.5, -18)
    Open.Size = UDim2.new(0, 80, 0, 32)
    Open.Font = Enum.Font.GothamMedium
    Open.Text = "SoloX"
    Open.TextColor3 = Color3.fromRGB(255, 255, 255)
    Open.TextSize = 13
    Open.Active = true
    local OpenC = Instance.new("UICorner")
    OpenC.CornerRadius = UDim.new(0, 8)
    OpenC.Parent = Open
    Open.MouseButton1Click:Connect(function()
        UIMinimize(Main)
    end)

    local TabBG = Instance.new("Frame")
    TabBG.Name = "TabBG"
    TabBG.Parent = Main
    TabBG.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    TabBG.BorderSizePixel = 0
    TabBG.Position = UDim2.new(0, 0, 0, 42)
    TabBG.Size = UDim2.new(0, 113, 1, -42)

    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Name = "TabHolder"
    TabHolder.Parent = TabBG
    TabHolder.BackgroundTransparency = 1
    TabHolder.BorderSizePixel = 0
    TabHolder.Position = UDim2.new(0, 4, 0, 6)
    TabHolder.Size = UDim2.new(1, -8, 1, -12)
    TabHolder.ScrollBarThickness = 0
    TabHolder.CanvasSize = UDim2.new(0, 0, 0, 0)

    local TabHolderLL = Instance.new("UIListLayout")
    TabHolderLL.Parent = TabHolder
    TabHolderLL.Padding = UDim.new(0, 4)
    TabHolderLL.SortOrder = Enum.SortOrder.LayoutOrder

    TabHolderLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolderLL.AbsoluteContentSize.Y + 8)
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
        Holder.Position = UDim2.new(0, 120, 0, 50)
        Holder.Size = UDim2.new(0, 347, 0, 236)
        Holder.ScrollBarThickness = 3
        Holder.ScrollBarImageColor3 = Color3.fromRGB(140, 80, 255)
        Holder.Visible = false
        Holder.CanvasSize = UDim2.new(0, 0, 0, 0)

        local HolderLL = Instance.new("UIListLayout")
        HolderLL.Parent = Holder
        HolderLL.HorizontalAlignment = Enum.HorizontalAlignment.Center
        HolderLL.Padding = UDim.new(0, 6)
        HolderLL.SortOrder = Enum.SortOrder.LayoutOrder

        HolderLL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Holder.CanvasSize = UDim2.new(0, 0, 0, HolderLL.AbsoluteContentSize.Y + 12)
        end)

        local Tab = Instance.new("TextButton")
        Tab.Name = "Tab"
        Tab.Parent = TabHolder
        Tab.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
        Tab.Size = UDim2.new(1, 0, 0, 34)
        Tab.Font = Enum.Font.GothamMedium
        Tab.Text = "    " .. Name
        Tab.TextColor3 = Color3.fromRGB(200, 200, 210)
        Tab.TextSize = 13
        Tab.TextXAlignment = Enum.TextXAlignment.Left
        Tab.AutoButtonColor = false

        local TabC = Instance.new("UICorner")
        TabC.CornerRadius = UDim.new(0, 6)
        TabC.Parent = Tab

        local Icon = Instance.new("ImageLabel")
        Icon.Name = "Icon"
        Icon.Parent = Tab
        Icon.BackgroundTransparency = 1
        Icon.Position = UDim2.new(0, 6, 0.5, -9)
        Icon.Size = UDim2.new(0, 18, 0, 18)
        Icon.Image = "rbxassetid://" .. tostring(IconID)
        Icon.ScaleType = Enum.ScaleType.Fit

        Tab.MouseButton1Click:Connect(function()
            ChangeTab(Holder)
            for _, v in ipairs(TabHolder:GetChildren()) do
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
            Section.Name = "Section"
            Section.Parent = Holder
            Section.BackgroundTransparency = 1
            Section.Size = UDim2.new(1, -12, 0, 26)
            Section.Font = Enum.Font.GothamBold
            Section.Text = Name
            Section.TextColor3 = Color3.fromRGB(255, 255, 255)
            Section.TextSize = 15
            Section.TextXAlignment = Enum.TextXAlignment.Left

            local Content = {}

            function Content:Label(Name)
                assert(Name, "A name is required")
                local Btn = Instance.new("TextButton")
                Btn.Name = "Btn"
                Btn.Parent = Holder
                Btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
                Btn.Size = UDim2.new(1, -12, 0, 30)
                Btn.Font = Enum.Font.Gotham
                Btn.Text = "  " .. Name
                Btn.TextColor3 = Color3.fromRGB(200, 200, 210)
                Btn.TextSize = 13
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                Btn.AutoButtonColor = false
                local C = Instance.new("UICorner")
                C.CornerRadius = UDim.new(0, 6)
                C.Parent = Btn
                return Btn
            end

            function Content:Button(Name, Callback)
                assert(Name, "A name is required")
                local Btn = Instance.new("TextButton")
                Btn.Name = "Btn"
                Btn.Parent = Holder
                Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
                Btn.Size = UDim2.new(1, -12, 0, 36)
                Btn.Font = Enum.Font.GothamMedium
                Btn.Text = "  " .. Name
                Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                Btn.TextSize = 13
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                Btn.AutoButtonColor = false
                local C = Instance.new("UICorner")
                C.CornerRadius = UDim.new(0, 6)
                C.Parent = Btn
                local Stroke = Instance.new("UIStroke")
                Stroke.Color = Color3.fromRGB(50, 50, 60)
                Stroke.Thickness = 1
                Stroke.Parent = Btn

                Btn.MouseButton1Click:Connect(function()
                    TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(140, 80, 255)}):Play()
                    task.wait(0.1)
                    TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(28, 28, 36)}):Play()
                    if Callback then task.spawn(Callback) end
                end)
                return Btn
            end

            function Content:Toggle(Name, Default, Callback)
                assert(Name, "A name is required")
                local Toggle = self:Button(Name, false)
                local Tog = Instance.new("Frame")
                Tog.Name = "Tog"
                Tog.Parent = Toggle
                Tog.BackgroundColor3 = Default and Color3.fromRGB(140, 80, 255) or Color3.fromRGB(50, 50, 60)
                Tog.Position = UDim2.new(1, -38, 0.5, -10)
                Tog.Size = UDim2.new(0, 32, 0, 18)
                local TogC = Instance.new("UICorner")
                TogC.CornerRadius = UDim.new(1, 0)
                TogC.Parent = Tog

                local Knob = Instance.new("Frame")
                Knob.Parent = Tog
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.Size = UDim2.new(0, 14, 0, 14)
                Knob.Position = Default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                local KnobC = Instance.new("UICorner")
                KnobC.CornerRadius = UDim.new(1, 0)
                KnobC.Parent = Knob

                local Funcs = {}
                Funcs.CurrentState = Default or false

                function Funcs:SetState(State)
                    if State == nil then State = not Funcs.CurrentState end
                    if State == Funcs.CurrentState then return end
                    Funcs.CurrentState = State
                    local pos = State and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                    local col = State and Color3.fromRGB(140, 80, 255) or Color3.fromRGB(50, 50, 60)
                    TweenService:Create(Knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = pos}):Play()
                    TweenService:Create(Tog, TweenInfo.new(0.18), {BackgroundColor3 = col}):Play()
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
                local TextBox = self:Button(Name, false)
                local Input = Instance.new("TextBox")
                Input.Name = "Input"
                Input.Parent = TextBox
                Input.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
                Input.Position = UDim2.new(1, -110, 0.5, -11)
                Input.Size = UDim2.new(0, 100, 0, 22)
                Input.Font = Enum.Font.Gotham
                Input.Text = Text or ""
                Input.TextColor3 = Color3.fromRGB(255, 255, 255)
                Input.TextSize = 12
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
                local KeyBind = self:Button(Name, false)
                local Input = Instance.new("TextButton")
                Input.Name = "Input"
                Input.Parent = KeyBind
                Input.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
                Input.Position = UDim2.new(1, -90, 0.5, -11)
                Input.Size = UDim2.new(0, 80, 0, 22)
                Input.Font = Enum.Font.GothamMedium
                Input.Text = (typeof(Key) == "string" and Key) or (Key and Key.Name) or "None"
                Input.TextColor3 = Color3.fromRGB(255, 255, 255)
                Input.TextSize = 12
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
                local Slider = self:Button("", false)
                Slider.Size = UDim2.new(1, -12, 0, 46)

                local Title = Instance.new("TextLabel")
                Title.Parent = Slider
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 6, 0, 4)
                Title.Size = UDim2.new(1, -60, 0, 16)
                Title.Font = Enum.Font.GothamMedium
                Title.Text = Name
                Title.TextColor3 = Color3.fromRGB(230, 230, 240)
                Title.TextSize = 13
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local Back = Instance.new("Frame")
                Back.Parent = Slider
                Back.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                Back.Position = UDim2.new(0, 8, 0, 28)
                Back.Size = UDim2.new(1, -70, 0, 6)
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

                local Number = Instance.new("TextBox")
                Number.Parent = Slider
                Number.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
                Number.Position = UDim2.new(1, -52, 0, 22)
                Number.Size = UDim2.new(0, 42, 0, 20)
                Number.Font = Enum.Font.Gotham
                Number.Text = tostring(Default or min)
                Number.TextColor3 = Color3.fromRGB(255, 255, 255)
                Number.TextSize = 12
                local NumC = Instance.new("UICorner")
                NumC.CornerRadius = UDim.new(0, 4)
                NumC.Parent = Number

                local funcs = {
                    SetValue = function(self, value)
                        value = value or Default or min
                        local percent = math.clamp((value - min) / (max - min), 0, 1)
                        value = min + (max - min) * percent
                        Number.Text = tostring(math.floor(value * 100) / 100)
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
                Dropdown.Name = "Dropdown"
                Dropdown.Parent = Holder
                Dropdown.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
                Dropdown.Size = UDim2.new(1, -12, 0, 36)
                Dropdown.Font = Enum.Font.GothamMedium
                Dropdown.Text = "  " .. Name
                Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
                Dropdown.TextSize = 13
                Dropdown.TextXAlignment = Enum.TextXAlignment.Left
                Dropdown.AutoButtonColor = false
                local DC = Instance.new("UICorner")
                DC.CornerRadius = UDim.new(0, 6)
                DC.Parent = Dropdown

                local Plus = Instance.new("TextButton")
                Plus.Parent = Dropdown
                Plus.BackgroundTransparency = 1
                Plus.Position = UDim2.new(1, -36, 0, 0)
                Plus.Size = UDim2.new(0, 36, 1, 0)
                Plus.Font = Enum.Font.GothamBold
                Plus.Text = "+"
                Plus.TextColor3 = Color3.fromRGB(180, 180, 190)
                Plus.TextSize = 16

                local DropdownBack = Instance.new("Frame")
                DropdownBack.Parent = Dropdown
                DropdownBack.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
                DropdownBack.Position = UDim2.new(0, 0, 1, 2)
                DropdownBack.Size = UDim2.new(1, 0, 0, 0)
                DropdownBack.Visible = false
                DropdownBack.ClipsDescendants = true
                DropdownBack.ZIndex = 8
                local DBC = Instance.new("UICorner")
                DBC.CornerRadius = UDim.new(0, 6)
                DBC.Parent = DropdownBack

                local DropdownLL = Instance.new("UIListLayout")
                DropdownLL.Parent = DropdownBack
                DropdownLL.Padding = UDim.new(0, 2)

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
                    local h = open and (DropdownLL.AbsoluteContentSize.Y + 6) or 0
                    TweenService:Create(DropdownBack, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, h)}):Play()
                end

                Plus.MouseButton1Click:Connect(function()
                    if playerlib then
                        Options = PlayerList()
                        -- rebuild options if needed
                    end
                    Open()
                end)

                local Funcs = {}
                function Funcs:AddOption(Name2)
                    local Opt = Instance.new("TextButton")
                    Opt.Name = "Option_" .. Name2
                    Opt.Parent = DropdownBack
                    Opt.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
                    Opt.Size = UDim2.new(1, -6, 0, 26)
                    Opt.Font = Enum.Font.Gotham
                    Opt.Text = "  " .. Name2
                    Opt.TextColor3 = Color3.fromRGB(220, 220, 230)
                    Opt.TextSize = 12
                    Opt.TextXAlignment = Enum.TextXAlignment.Left
                    Opt.AutoButtonColor = false
                    local OC = Instance.new("UICorner")
                    OC.CornerRadius = UDim.new(0, 4)
                    OC.Parent = Opt
                    Opt.MouseButton1Click:Connect(function()
                        Open()
                        Dropdown.Text = "  " .. Name2
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
