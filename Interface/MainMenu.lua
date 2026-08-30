-- Interface/MainMenu.lua
-- Main Menu UI: Navigation Rail, Categorized Cards, Toggles, and Sliders

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local MainMenu = {}

function MainMenu.new(
    windowBase: any,
    screenHost: ScreenGui,
    themeManager: any,
    signalMod: any,
    flightMod: any,
    platformMod: any,
    flingMod: any,
    charMod: any,
    windows: { [string]: any }
)
    local HubWindow = windowBase.new("FIHMENU", UDim2.new(0, 520, 0, 340), UDim2.new(0.5, -260, 0.5, -170), Vector2.new(460, 280), screenHost, themeManager, signalMod)

    -- TopBar Song Banner
    local TopSongBanner = Instance.new("TextLabel")
    TopSongBanner.Size = UDim2.new(0, 180, 0, 18)
    TopSongBanner.Position = UDim2.new(0, 90, 0, 5)
    TopSongBanner.BackgroundColor3 = themeManager.Get("Surface")
    TopSongBanner.BorderSizePixel = 0
    TopSongBanner.Font = Enum.Font.Code
    TopSongBanner.Text = "♪ Song: Lo-Fi Study Beat"
    TopSongBanner.TextColor3 = themeManager.Get("TextSecondary")
    TopSongBanner.TextSize = 10
    TopSongBanner.Parent = HubWindow.TopBar

    local BannerStroke = Instance.new("UIStroke")
    BannerStroke.Thickness = 1
    BannerStroke.Color = themeManager.Get("Border")
    BannerStroke.Parent = TopSongBanner

    -- Left Navigation Rail
    local NavRail = Instance.new("Frame")
    NavRail.Name = "NavRail"
    NavRail.Size = UDim2.new(0, 100, 1, 0)
    NavRail.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
    NavRail.BorderSizePixel = 0
    NavRail.Parent = HubWindow.Content

    local NavLine = Instance.new("Frame")
    NavLine.Size = UDim2.new(0, 1, 1, 0)
    NavLine.Position = UDim2.new(1, -1, 0, 0)
    NavLine.BackgroundColor3 = themeManager.Get("Border")
    NavLine.BorderSizePixel = 0
    NavLine.Parent = NavRail

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Padding = UDim.new(0, 3)
    NavLayout.Parent = NavRail

    local NavPad = Instance.new("UIPadding")
    NavPad.PaddingTop = UDim.new(0, 6)
    NavPad.PaddingLeft = UDim.new(0, 6)
    NavPad.PaddingRight = UDim.new(0, 6)
    NavPad.Parent = NavRail

    -- Content Area
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -100, 1, 0)
    TabContainer.Position = UDim2.new(0, 100, 0, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = HubWindow.Content

    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Size = UDim2.new(0, 80, 0, 16)
    VersionLabel.Position = UDim2.new(1, -85, 1, -18)
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Font = Enum.Font.Code
    VersionLabel.Text = "Version 0.1"
    VersionLabel.TextColor3 = themeManager.Get("TextSecondary")
    VersionLabel.TextSize = 10
    VersionLabel.Parent = HubWindow.Content

    local TabPages = {}
    local TabButtons = {}
    local CurrentActiveTab = ""

    local function CreateTabPage(name: string)
        local Page = Instance.new("CanvasGroup")
        Page.Name = "Page_" .. name
        Page.Size = UDim2.new(1, 0, 1, -20)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.GroupTransparency = 1
        Page.Parent = TabContainer

        local LeftCol = Instance.new("ScrollingFrame")
        LeftCol.Name = "LeftCol"
        LeftCol.Size = UDim2.new(0.5, -6, 1, 0)
        LeftCol.Position = UDim2.new(0, 4, 0, 4)
        LeftCol.BackgroundTransparency = 1
        LeftCol.BorderSizePixel = 0
        LeftCol.ScrollBarThickness = 2
        LeftCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
        LeftCol.Parent = Page

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 6)
        LeftLayout.Parent = LeftCol

        local RightCol = Instance.new("ScrollingFrame")
        RightCol.Name = "RightCol"
        RightCol.Size = UDim2.new(0.5, -6, 1, 0)
        RightCol.Position = UDim2.new(0.5, 2, 0, 4)
        RightCol.BackgroundTransparency = 1
        RightCol.BorderSizePixel = 0
        RightCol.ScrollBarThickness = 2
        RightCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
        RightCol.Parent = Page

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 6)
        RightLayout.Parent = RightCol

        TabPages[name] = { Page = Page, Left = LeftCol, Right = RightCol }
        return TabPages[name]
    end

    local function SwitchTab(tabName: string)
        if CurrentActiveTab == tabName then return end

        for name, btn in pairs(TabButtons) do
            if name == tabName then
                btn.BackgroundColor3 = themeManager.Get("Surface")
                btn.TextColor3 = themeManager.Get("Accent")
            else
                btn.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
                btn.TextColor3 = themeManager.Get("TextSecondary")
            end
        end

        local oldPage = TabPages[CurrentActiveTab]
        local newPage = TabPages[tabName]

        if oldPage then
            local tw = TweenService:Create(oldPage.Page, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(-0.08, 0, 0, 0),
                GroupTransparency = 1
            })
            tw:Play()
            tw.Completed:Connect(function() oldPage.Page.Visible = false end)
        end

        if newPage then
            newPage.Page.Visible = true
            newPage.Page.Position = UDim2.new(0.08, 0, 0, 0)
            newPage.Page.GroupTransparency = 1
            TweenService:Create(newPage.Page, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 0),
                GroupTransparency = 0
            }):Play()
        end

        CurrentActiveTab = tabName
    end

    local function RegisterNavTab(name: string)
        local btn = Instance.new("TextButton")
        btn.Name = "Nav_" .. name
        btn.Size = UDim2.new(1, 0, 0, 24)
        btn.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Code
        btn.Text = name
        btn.TextColor3 = themeManager.Get("TextSecondary")
        btn.TextSize = 10
        btn.Parent = NavRail

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = themeManager.Get("Border")
        stroke.Parent = btn

        windowBase.AttachMicroInteractions(btn)
        btn.MouseButton1Click:Connect(function() SwitchTab(name) end)

        TabButtons[name] = btn
        CreateTabPage(name)
    end

    local function CreateCard(parent: Instance, cardTitle: string)
        local card = Instance.new("Frame")
        card.Name = "Card_" .. cardTitle
        card.Size = UDim2.new(1, 0, 0, 0)
        card.AutomaticSize = Enum.AutomaticSize.Y
        card.BackgroundColor3 = themeManager.Get("Surface")
        card.BorderSizePixel = 0
        card.Parent = parent

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = themeManager.Get("Border")
        stroke.Parent = card

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -12, 0, 20)
        titleLbl.Position = UDim2.new(0, 6, 0, 2)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Font = Enum.Font.Code
        titleLbl.Text = string.upper(cardTitle)
        titleLbl.TextColor3 = themeManager.Get("Accent")
        titleLbl.TextSize = 10
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Parent = card
        themeManager.RegisterBinding(titleLbl, "TextColor3", "Accent")

        local itemContainer = Instance.new("Frame")
        itemContainer.Size = UDim2.new(1, -12, 0, 0)
        itemContainer.Position = UDim2.new(0, 6, 0, 22)
        itemContainer.AutomaticSize = Enum.AutomaticSize.Y
        itemContainer.BackgroundTransparency = 1
        itemContainer.Parent = card

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        layout.Parent = itemContainer

        local pad = Instance.new("UIPadding")
        pad.PaddingBottom = UDim.new(0, 6)
        pad.Parent = itemContainer

        return itemContainer
    end

    local function AddToggle(cardContainer: Instance, labelText: string, default: boolean, callback: (boolean) -> ())
        local state = default
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, 0, 0, 22)
        row.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
        row.BorderSizePixel = 0
        row.AutoButtonColor = false
        row.Text = ""
        row.Parent = cardContainer

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = themeManager.Get("Border")
        stroke.Parent = row

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -30, 1, 0)
        title.Position = UDim2.new(0, 6, 0, 0)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.Code
        title.Text = labelText
        title.TextColor3 = themeManager.Get("TextPrimary")
        title.TextSize = 10
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = row

        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 14, 0, 14)
        box.Position = UDim2.new(1, -18, 0.5, -7)
        box.BackgroundColor3 = state and themeManager.Get("Accent") or themeManager.Get("Surface")
        box.BorderSizePixel = 0
        box.Parent = row

        local boxStroke = Instance.new("UIStroke")
        boxStroke.Thickness = 1
        boxStroke.Color = themeManager.Get("Border")
        boxStroke.Parent = box

        local checkMark = Instance.new("TextLabel")
        checkMark.Size = UDim2.new(1, 0, 1, 0)
        checkMark.BackgroundTransparency = 1
        checkMark.Font = Enum.Font.Code
        checkMark.Text = state and "✓" or ""
        checkMark.TextColor3 = Color3.new(1, 1, 1)
        checkMark.TextSize = 10
        checkMark.Parent = box

        row.MouseButton1Click:Connect(function()
            state = not state
            box.BackgroundColor3 = state and themeManager.Get("Accent") or themeManager.Get("Surface")
            checkMark.Text = state and "✓" or ""
            callback(state)
        end)
    end

    local function AddSlider(cardContainer: Instance, labelText: string, min: number, max: number, default: number, callback: (number) -> ())
        local currentVal = default
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
        frame.BorderSizePixel = 0
        frame.Parent = cardContainer

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = themeManager.Get("Border")
        stroke.Parent = frame

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -40, 0, 14)
        title.Position = UDim2.new(0, 6, 0, 2)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.Code
        title.Text = labelText
        title.TextColor3 = themeManager.Get("TextPrimary")
        title.TextSize = 9
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = frame

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0, 34, 0, 14)
        valLbl.Position = UDim2.new(1, -38, 0, 2)
        valLbl.BackgroundTransparency = 1
        valLbl.Font = Enum.Font.Code
        valLbl.Text = tostring(default)
        valLbl.TextColor3 = themeManager.Get("TextSecondary")
        valLbl.TextSize = 9
        valLbl.Parent = frame

        local barBack = Instance.new("TextButton")
        barBack.Size = UDim2.new(1, -12, 0, 8)
        barBack.Position = UDim2.new(0, 6, 0, 18)
        barBack.BackgroundColor3 = themeManager.Get("Surface")
        barBack.BorderSizePixel = 0
        barBack.Text = ""
        barBack.AutoButtonColor = false
        barBack.Parent = frame

        local fill = Instance.new("Frame")
        local initRatio = math.clamp((default - min) / (max - min), 0, 1)
        fill.Size = UDim2.new(initRatio, 0, 1, 0)
        fill.BackgroundColor3 = themeManager.Get("Accent")
        fill.BorderSizePixel = 0
        fill.Parent = barBack
        themeManager.RegisterBinding(fill, "BackgroundColor3", "Accent")

        local sliding = false
        local function Update(input: InputObject)
            local posX = math.clamp((input.Position.X - barBack.AbsolutePosition.X) / barBack.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(posX, 0, 1, 0)
            currentVal = math.floor(min + (max - min) * posX)
            valLbl.Text = tostring(currentVal)
            callback(currentVal)
        end

        barBack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                Update(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                Update(input)
            end
        end)
    end

    local NavItems = { "MAIN", "PLAYER", "TARGETS", "VISUALS", "MUSIC", "THEMES", "SCRIPTS" }
    for _, nav in ipairs(NavItems) do
        RegisterNavTab(nav)
    end

    -- Tab: MAIN
    local mainLeft = CreateCard(TabPages["MAIN"].Left, "System Status")
    AddToggle(mainLeft, "Active Event Stream", true, function(s) end)
    AddToggle(mainLeft, "Metatable Guard", true, function(s) end)

    local mainRight = CreateCard(TabPages["MAIN"].Right, "Quick Windows")
    AddToggle(mainRight, "Chat Overlay", true, function(s) if windows.Chat then windows.Chat.Frame.Visible = s end end)
    AddToggle(mainRight, "Player List Overlay", true, function(s) if windows.PlayerList then windows.PlayerList.Frame.Visible = s end end)
    AddToggle(mainRight, "Music Widget", true, function(s) if windows.Music then windows.Music.Frame.Visible = s end end)

    -- Tab: PLAYER
    local pLeft = CreateCard(TabPages["PLAYER"].Left, "Locomotion")
    AddToggle(pLeft, "Linear Flight", false, function(s) flightMod.Toggle(s) end)
    AddSlider(pLeft, "Flight Speed", 16, 200, 50, function(v) flightMod.SetSpeed(v) end)
    AddToggle(pLeft, "Stepped Floater", false, function(s) platformMod.Toggle(s, themeManager.Get("Accent")) end)
    AddToggle(pLeft, "Noclip Stepped", false, function(s) charMod.SetNoclip(s) end)

    local pRight = CreateCard(TabPages["PLAYER"].Right, "Character Modifications")
    AddSlider(pRight, "WalkSpeed", 16, 250, 16, function(v) charMod.SetWalkSpeed(v) end)
    AddSlider(pRight, "JumpPower", 50, 300, 50, function(v) charMod.SetJumpPower(v) end)
    AddToggle(pRight, "Infinite Jump", false, function(s) charMod.SetInfiniteJump(s) end)
    AddToggle(pRight, "Walk Fling (Desync)", false, function(s) flingMod.Toggle(s) end)

    -- Tab: TARGETS
    local tLeft = CreateCard(TabPages["TARGETS"].Left, "Target Utilities")
    AddToggle(tLeft, "Spectate Target", false, function(s) end)

    -- Tab: MUSIC
    local mLeft = CreateCard(TabPages["MUSIC"].Left, "Media Bridge")
    AddToggle(mLeft, "Localhost Sync (9000)", false, function(s) end)
    AddToggle(mLeft, "Simulate Audio Noise", true, function(s) end)

    -- Tab: THEMES
    local thLeft = CreateCard(TabPages["THEMES"].Left, "Presets")
    local presets = themeManager.GetPresets()
    for name, _ in pairs(presets) do
        AddToggle(thLeft, name, false, function(s)
            if s then themeManager.ApplyPreset(name) end
        end)
    end

    SwitchTab("MAIN")
    return HubWindow
end

return MainMenu
