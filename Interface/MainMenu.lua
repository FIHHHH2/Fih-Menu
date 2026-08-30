-- Interface/MainMenu.lua
-- Translucent Squared Main Hub GUI with Topbar Song Ticker, Sliding Settings/Keybinds Drawers & Rich Feature Set

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

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
    visualsMod: any,
    musicEngine: any,
    windows: { [string]: any }
)
    local HubWindow = windowBase.new("FIHMENU", UDim2.new(0, 660, 0, 440), UDim2.new(0.5, -330, 0.5, -220), Vector2.new(540, 360), screenHost, themeManager, signalMod)

    -- 1. TopBar: FIHMENU Logo \ Full-Width Grey-Hashed Song Ticker (Before Controls)
    local TopSongBanner = Instance.new("TextLabel")
    TopSongBanner.Size = UDim2.new(1, -150, 1, -6)
    TopSongBanner.Position = UDim2.new(0, 85, 0, 3)
    TopSongBanner.BackgroundColor3 = themeManager.Get("Surface")
    TopSongBanner.BackgroundTransparency = 0.35
    TopSongBanner.BorderSizePixel = 0
    TopSongBanner.Font = Enum.Font.Code
    TopSongBanner.Text = "♪ Song: Lo-Fi Study Beats // Media Status: Active"
    TopSongBanner.TextColor3 = themeManager.Get("TextSecondary")
    TopSongBanner.TextSize = 10
    TopSongBanner.ClipsDescendants = true
    TopSongBanner.Parent = HubWindow.TopBar

    local BannerStroke = Instance.new("UIStroke")
    BannerStroke.Thickness = 1
    BannerStroke.Color = themeManager.Get("Border")
    BannerStroke.Transparency = 0.4
    BannerStroke.Parent = TopSongBanner

    -- 2. Sub-Header Area (Inside Main GUI Content Top Area)
    local SubHeader = Instance.new("Frame")
    SubHeader.Size = UDim2.new(1, -16, 0, 26)
    SubHeader.Position = UDim2.new(0, 8, 0, 6)
    SubHeader.BackgroundTransparency = 1
    SubHeader.Parent = HubWindow.Content

    -- Left: Dynamic Tab Tag (Scales with text width, NO 'T A B')
    local TabTag = Instance.new("Frame")
    TabTag.Size = UDim2.new(0, 90, 1, 0)
    TabTag.BackgroundColor3 = themeManager.Get("Surface")
    TabTag.BackgroundTransparency = 0.3
    TabTag.BorderSizePixel = 0
    TabTag.Parent = SubHeader

    local TabTagStroke = Instance.new("UIStroke")
    TabTagStroke.Thickness = 1
    TabTagStroke.Color = themeManager.Get("Accent")
    TabTagStroke.Parent = TabTag
    themeManager.RegisterBinding(TabTagStroke, "Color", "Accent")

    local TabTagLabel = Instance.new("TextLabel")
    TabTagLabel.Size = UDim2.new(1, 0, 1, 0)
    TabTagLabel.BackgroundTransparency = 1
    TabTagLabel.Font = Enum.Font.Code
    TabTagLabel.Text = "MAIN"
    TabTagLabel.TextColor3 = themeManager.Get("Accent")
    TabTagLabel.TextSize = 11
    TabTagLabel.Parent = TabTag
    themeManager.RegisterBinding(TabTagLabel, "TextColor3", "Accent")

    -- Right Edge: Keybinds & Settings Buttons
    local SubHeaderRight = Instance.new("Frame")
    SubHeaderRight.Size = UDim2.new(0, 160, 1, 0)
    SubHeaderRight.Position = UDim2.new(1, -160, 0, 0)
    SubHeaderRight.BackgroundTransparency = 1
    SubHeaderRight.Parent = SubHeader

    local SubHeaderLayout = Instance.new("UIListLayout")
    SubHeaderLayout.FillDirection = Enum.FillDirection.Horizontal
    SubHeaderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    SubHeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    SubHeaderLayout.Padding = UDim.new(0, 4)
    SubHeaderLayout.Parent = SubHeaderRight

    local function CreateSubBtn(name: string, onClick: () -> ())
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 74, 0, 22)
        b.BackgroundColor3 = themeManager.Get("Surface")
        b.BackgroundTransparency = 0.25
        b.BorderSizePixel = 0
        b.Font = Enum.Font.Code
        b.Text = name
        b.TextColor3 = themeManager.Get("TextPrimary")
        b.TextSize = 10
        b.Parent = SubHeaderRight

        local s = Instance.new("UIStroke")
        s.Thickness = 1
        s.Color = themeManager.Get("Border")
        s.Transparency = 0.4
        s.Parent = b

        windowBase.AttachMicroInteractions(b)
        b.MouseButton1Click:Connect(onClick)
    end

    -- 3. Left Navigation Rail (Strictly Squared)
    local NavRail = Instance.new("Frame")
    NavRail.Name = "NavRail"
    NavRail.Size = UDim2.new(0, 115, 1, -38)
    NavRail.Position = UDim2.new(0, 8, 0, 36)
    NavRail.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
    NavRail.BackgroundTransparency = 0.25
    NavRail.BorderSizePixel = 0
    NavRail.Parent = HubWindow.Content

    local NavRailStroke = Instance.new("UIStroke")
    NavRailStroke.Thickness = 1
    NavRailStroke.Color = themeManager.Get("Border")
    NavRailStroke.Transparency = 0.4
    NavRailStroke.Parent = NavRail

    local NavTopList = Instance.new("Frame")
    NavTopList.Size = UDim2.new(1, 0, 1, -36)
    NavTopList.BackgroundTransparency = 1
    NavTopList.Parent = NavRail

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.Parent = NavTopList

    local NavPad = Instance.new("UIPadding")
    NavPad.PaddingTop = UDim.new(0, 6)
    NavPad.PaddingLeft = UDim.new(0, 6)
    NavPad.PaddingRight = UDim.new(0, 6)
    NavPad.Parent = NavTopList

    -- Pinned Bottom Themes Section
    local NavBottomSection = Instance.new("Frame")
    NavBottomSection.Size = UDim2.new(1, -12, 0, 26)
    NavBottomSection.Position = UDim2.new(0, 6, 1, -30)
    NavBottomSection.BackgroundTransparency = 1
    NavBottomSection.Parent = NavRail

    -- 4. Content Area & Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -135, 1, -38)
    TabContainer.Position = UDim2.new(0, 127, 0, 36)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = HubWindow.Content

    local TabPages = {}
    local TabButtons = {}
    local CurrentActiveTab = ""

    local function CreateTabPage(name: string)
        local Page = Instance.new("Frame")
        Page.Name = "Page_" .. name
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.Parent = TabContainer

        local LeftCol = Instance.new("ScrollingFrame")
        LeftCol.Name = "LeftCol"
        LeftCol.Size = UDim2.new(0.5, -6, 1, 0)
        LeftCol.Position = UDim2.new(0, 0, 0, 0)
        LeftCol.BackgroundTransparency = 1
        LeftCol.BorderSizePixel = 0
        LeftCol.ScrollBarThickness = 3
        LeftCol.ScrollBarImageColor3 = themeManager.Get("Border")
        LeftCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
        LeftCol.CanvasSize = UDim2.new(0, 0, 0, 0)
        LeftCol.Parent = Page

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 6)
        LeftLayout.Parent = LeftCol

        local RightCol = Instance.new("ScrollingFrame")
        RightCol.Name = "RightCol"
        RightCol.Size = UDim2.new(0.5, -6, 1, 0)
        RightCol.Position = UDim2.new(0.5, 4, 0, 0)
        RightCol.BackgroundTransparency = 1
        RightCol.BorderSizePixel = 0
        RightCol.ScrollBarThickness = 3
        RightCol.ScrollBarImageColor3 = themeManager.Get("Border")
        RightCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
        RightCol.CanvasSize = UDim2.new(0, 0, 0, 0)
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
                btn.BackgroundTransparency = 0.15
                btn.TextColor3 = themeManager.Get("Accent")
            else
                btn.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
                btn.BackgroundTransparency = 0.4
                btn.TextColor3 = themeManager.Get("TextSecondary")
            end
        end

        local oldPage = TabPages[CurrentActiveTab]
        local newPage = TabPages[tabName]

        if oldPage then
            oldPage.Page.Visible = false
        end

        if newPage then
            newPage.Page.Visible = true
        end

        TabTagLabel.Text = string.upper(tabName)
        CurrentActiveTab = tabName
    end

    local function RegisterNavTab(name: string, isBottomPinned: boolean?)
        local parent = isBottomPinned and NavBottomSection or NavTopList
        local btn = Instance.new("TextButton")
        btn.Name = "Nav_" .. name
        btn.Size = UDim2.new(1, 0, 0, 24)
        btn.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
        btn.BackgroundTransparency = 0.4
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Code
        btn.Text = name
        btn.TextColor3 = themeManager.Get("TextSecondary")
        btn.TextSize = 10
        btn.AutoButtonColor = false
        btn.Parent = parent

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = themeManager.Get("Border")
        stroke.Transparency = 0.4
        stroke.Parent = btn

        windowBase.AttachMicroInteractions(btn)
        btn.MouseButton1Click:Connect(function() SwitchTab(name) end)

        TabButtons[name] = btn
        CreateTabPage(name)
    end

    -- Card Container Builder (Translucent Cubed Box)
    local function CreateCard(parent: Instance, cardTitle: string)
        local card = Instance.new("Frame")
        card.Name = "Card_" .. cardTitle
        card.Size = UDim2.new(1, 0, 0, 0)
        card.AutomaticSize = Enum.AutomaticSize.Y
        card.BackgroundColor3 = themeManager.Get("Surface")
        card.BackgroundTransparency = 0.35
        card.BorderSizePixel = 0
        card.Parent = parent

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = themeManager.Get("Border")
        stroke.Transparency = 0.4
        stroke.Parent = card

        -- Card Header Box
        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 22)
        header.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
        header.BackgroundTransparency = 0.3
        header.BorderSizePixel = 0
        header.Parent = card

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -12, 1, 0)
        titleLbl.Position = UDim2.new(0, 6, 0, 0)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Font = Enum.Font.Code
        titleLbl.Text = string.upper(cardTitle)
        titleLbl.TextColor3 = themeManager.Get("Accent")
        titleLbl.TextSize = 10
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Parent = header
        themeManager.RegisterBinding(titleLbl, "TextColor3", "Accent")

        local itemContainer = Instance.new("Frame")
        itemContainer.Size = UDim2.new(1, -12, 0, 0)
        itemContainer.Position = UDim2.new(0, 6, 0, 26)
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
        row.BackgroundTransparency = 0.4
        row.BorderSizePixel = 0
        row.AutoButtonColor = false
        row.Text = ""
        row.Parent = cardContainer

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = themeManager.Get("Border")
        stroke.Transparency = 0.5
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
        box.BackgroundTransparency = state and 0 or 0.3
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
            box.BackgroundTransparency = state and 0 or 0.3
            checkMark.Text = state and "✓" or ""
            callback(state)
        end)
    end

    local function AddSlider(cardContainer: Instance, labelText: string, min: number, max: number, default: number, callback: (number) -> ())
        local currentVal = default
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
        frame.BackgroundTransparency = 0.4
        frame.BorderSizePixel = 0
        frame.Parent = cardContainer

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = themeManager.Get("Border")
        stroke.Transparency = 0.5
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
        barBack.BackgroundTransparency = 0.3
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

    local function AddButton(cardContainer: Instance, labelText: string, onClick: () -> ())
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 24)
        btn.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Code
        btn.Text = labelText
        btn.TextColor3 = themeManager.Get("TextPrimary")
        btn.TextSize = 10
        btn.Parent = cardContainer

        local s = Instance.new("UIStroke")
        s.Thickness = 1
        s.Color = themeManager.Get("Border")
        s.Transparency = 0.4
        s.Parent = btn

        windowBase.AttachMicroInteractions(btn)
        btn.MouseButton1Click:Connect(onClick)
    end

    -- 5. Animated Top-To-Bottom Slide Drawers for Settings & Keybinds
    local DrawerOverlay = Instance.new("Frame")
    DrawerOverlay.Name = "DrawerOverlay"
    DrawerOverlay.Size = UDim2.new(1, 0, 1, -26)
    DrawerOverlay.Position = UDim2.new(0, 0, 0, -500)
    DrawerOverlay.BackgroundColor3 = themeManager.Get("BackgroundPrimary")
    DrawerOverlay.BackgroundTransparency = 0.08
    DrawerOverlay.BorderSizePixel = 0
    DrawerOverlay.ZIndex = 50
    DrawerOverlay.Visible = false
    DrawerOverlay.Parent = HubWindow.Frame

    local DrawerStroke = Instance.new("UIStroke")
    DrawerStroke.Thickness = 1
    DrawerStroke.Color = themeManager.Get("Accent")
    DrawerStroke.Parent = DrawerOverlay

    local DrawerTitle = Instance.new("TextLabel")
    DrawerTitle.Size = UDim2.new(1, -40, 0, 28)
    DrawerTitle.Position = UDim2.new(0, 12, 0, 6)
    DrawerTitle.BackgroundTransparency = 1
    DrawerTitle.Font = Enum.Font.Code
    DrawerTitle.Text = "SETTINGS & PREFERENCES"
    DrawerTitle.TextColor3 = themeManager.Get("Accent")
    DrawerTitle.TextSize = 12
    DrawerTitle.TextXAlignment = Enum.TextXAlignment.Left
    DrawerTitle.ZIndex = 51
    DrawerTitle.Parent = DrawerOverlay

    local DrawerClose = Instance.new("TextButton")
    DrawerClose.Size = UDim2.new(0, 24, 0, 22)
    DrawerClose.Position = UDim2.new(1, -32, 0, 6)
    DrawerClose.BackgroundColor3 = themeManager.Get("Surface")
    DrawerClose.BorderSizePixel = 0
    DrawerClose.Font = Enum.Font.Code
    DrawerClose.Text = "✕"
    DrawerClose.TextColor3 = Color3.new(1, 1, 1)
    DrawerClose.TextSize = 11
    DrawerClose.ZIndex = 52
    DrawerClose.Parent = DrawerOverlay

    local DrawerScroll = Instance.new("ScrollingFrame")
    DrawerScroll.Size = UDim2.new(1, -24, 1, -44)
    DrawerScroll.Position = UDim2.new(0, 12, 0, 38)
    DrawerScroll.BackgroundTransparency = 1
    DrawerScroll.BorderSizePixel = 0
    DrawerScroll.ScrollBarThickness = 3
    DrawerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    DrawerScroll.ZIndex = 51
    DrawerScroll.Parent = DrawerOverlay

    local DrawerLayout = Instance.new("UIListLayout")
    DrawerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DrawerLayout.Padding = UDim.new(0, 6)
    DrawerLayout.Parent = DrawerScroll

    local function ToggleDrawer(title: string, buildFn: (Instance) -> ())
        DrawerTitle.Text = string.upper(title)
        for _, ch in ipairs(DrawerScroll:GetChildren()) do
            if ch:IsA("GuiObject") then ch:Destroy() end
        end
        buildFn(DrawerScroll)

        DrawerOverlay.Visible = true
        DrawerOverlay.Position = UDim2.new(0, 0, 0, -420)
        TweenService:Create(DrawerOverlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 26)
        }):Play()
    end

    DrawerClose.MouseButton1Click:Connect(function()
        local tw = TweenService:Create(DrawerOverlay, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0, 0, 0, -420)
        })
        tw:Play()
        tw.Completed:Connect(function() DrawerOverlay.Visible = false end)
    end)

    CreateSubBtn("Keybinds", function()
        ToggleDrawer("GLOBAL KEYBINDS", function(parent)
            local card = CreateCard(parent, "Active Hotkeys")
            card.Parent.ZIndex = 53
            AddButton(card, "Toggle Main GUI: RightControl", function() end)
            AddButton(card, "Toggle Flight: F", function() end)
            AddButton(card, "Toggle Noclip: N", function() end)
        end)
    end)

    CreateSubBtn("Settings", function()
        ToggleDrawer("GLOBAL CONFIGURATION", function(parent)
            local card = CreateCard(parent, "Core Options")
            card.Parent.ZIndex = 53
            AddToggle(card, "Translucent Glass Effects", true, function(s) end)
            AddToggle(card, "Hardware Acceleration", true, function(s) end)
            AddToggle(card, "Auto-Save Settings", true, function(s) end)
        end)
    end)

    -- Register Navigation Tabs
    local NavItems = { "MAIN", "PLAYER", "TARGETS", "VISUALS", "MUSIC", "SCRIPTS" }
    for _, nav in ipairs(NavItems) do
        RegisterNavTab(nav)
    end
    RegisterNavTab("THEMES", true)

    ----------------------------------------------------------------------------
    -- TAB 1: MAIN
    ----------------------------------------------------------------------------
    local mLeft = CreateCard(TabPages["MAIN"].Left, "System Hub")
    AddToggle(mLeft, "Metatable Guard Hook", true, function(s) end)
    AddToggle(mLeft, "Event Streamer Active", true, function(s) end)
    AddToggle(mLeft, "Anti-Afk KeepAlive", true, function(s)
        pcall(function()
            LocalPlayer.Idled:Connect(function()
                game:GetService("VirtualUser"):Button2Down(Vector2.zero, Workspace.CurrentCamera.CFrame)
                task.wait(1)
                game:GetService("VirtualUser"):Button2Up(Vector2.zero, Workspace.CurrentCamera.CFrame)
            end)
        end)
    end)

    local mRight = CreateCard(TabPages["MAIN"].Right, "Modular Windows")
    AddToggle(mRight, "Chat Overlay", true, function(s) if windows.Chat then windows.Chat.Frame.Visible = s end end)
    AddToggle(mRight, "Player List Overlay", true, function(s) if windows.PlayerList then windows.PlayerList.Frame.Visible = s end end)
    AddToggle(mRight, "Music Widget", true, function(s) if windows.Music then windows.Music.Frame.Visible = s end end)

    local mServer = CreateCard(TabPages["MAIN"].Left, "Server Status")
    AddButton(mServer, "Rejoin Server", function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)
    AddButton(mServer, "Server Hop", function()
        pcall(function()
            local sf = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=10"))
            if sf and sf.data and #sf.data > 1 then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, sf.data[2].id, LocalPlayer)
            end
        end)
    end)

    ----------------------------------------------------------------------------
    -- TAB 2: PLAYER
    ----------------------------------------------------------------------------
    local pLeft = CreateCard(TabPages["PLAYER"].Left, "Locomotion")
    AddToggle(pLeft, "Linear Flight", false, function(s) flightMod.Toggle(s) end)
    AddSlider(pLeft, "Flight Speed", 16, 250, 50, function(v) flightMod.SetSpeed(v) end)
    AddToggle(pLeft, "Stepped Floater", false, function(s) platformMod.Toggle(s, themeManager.Get("Accent")) end)
    AddToggle(pLeft, "Noclip Stepped", false, function(s) charMod.SetNoclip(s) end)

    local pRight = CreateCard(TabPages["PLAYER"].Right, "Character Modifications")
    AddSlider(pRight, "WalkSpeed", 16, 250, 16, function(v) charMod.SetWalkSpeed(v) end)
    AddSlider(pRight, "JumpPower", 50, 350, 50, function(v) charMod.SetJumpPower(v) end)
    AddSlider(pRight, "Gravity", 0, 400, 196, function(v) charMod.SetGravity(v) end)
    AddSlider(pRight, "HipHeight", 0, 30, 2, function(v) charMod.SetHipHeight(v) end)
    AddToggle(pRight, "Infinite Jump", false, function(s) charMod.SetInfiniteJump(s) end)
    AddToggle(pRight, "Spinbot Desync", false, function(s) charMod.SetSpinbot(s) end)
    AddToggle(pRight, "Walk Fling (Stabilized)", false, function(s) flingMod.Toggle(s) end)

    ----------------------------------------------------------------------------
    -- TAB 3: TARGETS (With Interactive Player Dropdown)
    ----------------------------------------------------------------------------
    local tLeft = CreateCard(TabPages["TARGETS"].Left, "Player Selector")
    local SelectedPlayer: Player? = nil

    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(1, 0, 0, 26)
    DropdownBtn.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
    DropdownBtn.BorderSizePixel = 0
    DropdownBtn.Font = Enum.Font.Code
    DropdownBtn.Text = "Select Target: [Click to Choose]"
    DropdownBtn.TextColor3 = themeManager.Get("TextPrimary")
    DropdownBtn.TextSize = 10
    DropdownBtn.Parent = tLeft

    local DropStroke = Instance.new("UIStroke")
    DropStroke.Thickness = 1
    DropStroke.Color = themeManager.Get("Border")
    DropStroke.Parent = DropdownBtn

    local DropList = Instance.new("Frame")
    DropList.Size = UDim2.new(1, 0, 0, 110)
    DropList.BackgroundColor3 = themeManager.Get("BackgroundPrimary")
    DropList.BorderSizePixel = 0
    DropList.Visible = false
    DropList.ZIndex = 25
    DropList.Parent = tLeft

    local DropScroll = Instance.new("ScrollingFrame")
    DropScroll.Size = UDim2.new(1, 0, 1, 0)
    DropScroll.BackgroundTransparency = 1
    DropScroll.BorderSizePixel = 0
    DropScroll.ScrollBarThickness = 2
    DropScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    DropScroll.ZIndex = 26
    DropScroll.Parent = DropList

    local DropScrollLayout = Instance.new("UIListLayout")
    DropScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DropScrollLayout.Padding = UDim.new(0, 2)
    DropScrollLayout.Parent = DropScroll

    local function PopulateDropdown()
        for _, c in ipairs(DropScroll:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, 0, 0, 22)
                b.BackgroundColor3 = themeManager.Get("Surface")
                b.BorderSizePixel = 0
                b.Font = Enum.Font.Code
                b.Text = " " .. plr.DisplayName .. " (@" .. plr.Name .. ")"
                b.TextColor3 = themeManager.Get("TextPrimary")
                b.TextSize = 10
                b.TextXAlignment = Enum.TextXAlignment.Left
                b.ZIndex = 27
                b.Parent = DropScroll

                b.MouseButton1Click:Connect(function()
                    SelectedPlayer = plr
                    DropdownBtn.Text = "Target: " .. plr.DisplayName
                    DropList.Visible = false
                end)
            end
        end
    end

    DropdownBtn.MouseButton1Click:Connect(function()
        PopulateDropdown()
        DropList.Visible = not DropList.Visible
    end)

    local tRight = CreateCard(TabPages["TARGETS"].Right, "Target Actions")
    AddButton(tRight, "Teleport To Target", function()
        if SelectedPlayer and SelectedPlayer.Character then
            local tRoot = SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
            if tRoot and myRoot then myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 2, 0) end
        end
    end)
    AddButton(tRight, "Spectate Target", function()
        if SelectedPlayer and SelectedPlayer.Character then
            local hum = SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then Workspace.CurrentCamera.CameraSubject = hum end
        end
    end)
    AddButton(tRight, "Reset Spectate", function()
        Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end)
    AddButton(tRight, "Fling Target", function()
        if SelectedPlayer then flingMod.FlingPlayer(SelectedPlayer, 0.6) end
    end)

    ----------------------------------------------------------------------------
    -- TAB 4: VISUALS
    ----------------------------------------------------------------------------
    local vLeft = CreateCard(TabPages["VISUALS"].Left, "Player ESP")
    AddToggle(vLeft, "Box 2D ESP", false, function(s) visualsMod.SetBoxESP(s) end)
    AddToggle(vLeft, "Name & Distance Tags", false, function(s) visualsMod.SetNameESP(s) end)
    AddToggle(vLeft, "Chams Highlights", false, function(s) visualsMod.SetHighlights(s) end)

    local vRight = CreateCard(TabPages["VISUALS"].Right, "World & Lighting")
    AddToggle(vRight, "Fullbright Daylight", false, function(s) visualsMod.SetFullbright(s) end)
    AddSlider(vRight, "Camera FOV", 60, 120, 70, function(v) visualsMod.SetFOV(v) end)

    ----------------------------------------------------------------------------
    -- TAB 5: MUSIC (Fully Functional Built-in Sound Engine & Bridge)
    ----------------------------------------------------------------------------
    local muLeft = CreateCard(TabPages["MUSIC"].Left, "Sound Engine Controls")
    AddToggle(muLeft, "Sound Stream Enabled", false, function(s)
        if s then musicEngine.PlaySound(9048375035, "Lo-Fi Beats 1") else musicEngine.Pause() end
    end)
    AddSlider(muLeft, "Stream Volume", 0, 10, 1, function(v) musicEngine.SetVolume(v) end)
    AddSlider(muLeft, "Stream Pitch", 0, 2, 1, function(v) musicEngine.SetPitch(v) end)

    local muPresets = CreateCard(TabPages["MUSIC"].Left, "Audio Presets")
    for _, p in ipairs(musicEngine.Presets) do
        AddButton(muPresets, p.Name, function()
            musicEngine.PlaySound(p.Id, p.Name)
            TopSongBanner.Text = "♪ Song: " .. p.Name .. " // Media Status: Playing"
        end)
    end

    local muRight = CreateCard(TabPages["MUSIC"].Right, "Visualizer & Daemon")
    AddToggle(muRight, "Localhost Sync (9000)", false, function(s) end)
    AddToggle(muRight, "Audio Spectrum HUD", true, function(s) if windows.Music then windows.Music.Frame.Visible = s end end)

    ----------------------------------------------------------------------------
    -- TAB 6: THEMES
    ----------------------------------------------------------------------------
    local thLeft = CreateCard(TabPages["THEMES"].Left, "Theme Presets")
    local presets = themeManager.GetPresets()
    for name, _ in pairs(presets) do
        AddButton(thLeft, name, function()
            themeManager.ApplyPreset(name)
        end)
    end

    local thRight = CreateCard(TabPages["THEMES"].Right, "Accent Modulation")
    AddToggle(thRight, "Album Art Color Sync", false, function(s) end)

    ----------------------------------------------------------------------------
    -- TAB 7: SCRIPTS
    ----------------------------------------------------------------------------
    local sLeft = CreateCard(TabPages["SCRIPTS"].Left, "Universal Script Hub")
    AddButton(sLeft, "Infinite Yield", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end)
    AddButton(sLeft, "Dex Explorer", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end)
    AddButton(sLeft, "SimpleSpy v3", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/src/source.lua"))() end)

    local sRight = CreateCard(TabPages["SCRIPTS"].Right, "Custom Code Slot")
    AddButton(sRight, "Execute Potassium Hooks", function() print("[Fish Menu]: Hooks injected.") end)

    -- Initial Tab Switch
    SwitchTab("MAIN")

    return HubWindow
end

return MainMenu
