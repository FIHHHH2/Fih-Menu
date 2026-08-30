-- Interface/MainMenu.lua
-- Translucent Main Hub GUI with Nav Rail, Cubed Aesthetic & Rich Multi-Tab Grid

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
    windows: { [string]: any }
)
    local HubWindow = windowBase.new("FIHMENU", UDim2.new(0, 640, 0, 420), UDim2.new(0.5, -320, 0.5, -210), Vector2.new(520, 340), screenHost, themeManager, signalMod)

    -- TopBar Ticker Banner & Quick Action Buttons
    local TopSongBanner = Instance.new("TextLabel")
    TopSongBanner.Size = UDim2.new(0, 200, 0, 18)
    TopSongBanner.Position = UDim2.new(0, 95, 0, 5)
    TopSongBanner.BackgroundColor3 = themeManager.Get("Surface")
    TopSongBanner.BackgroundTransparency = 0.3
    TopSongBanner.BorderSizePixel = 0
    TopSongBanner.Font = Enum.Font.Code
    TopSongBanner.Text = "♪ Song: Lo-Fi Study Beat"
    TopSongBanner.TextColor3 = themeManager.Get("TextSecondary")
    TopSongBanner.TextSize = 10
    TopSongBanner.Parent = HubWindow.TopBar

    local BannerCorner = Instance.new("UICorner")
    BannerCorner.CornerRadius = UDim.new(0, 3)
    BannerCorner.Parent = TopSongBanner

    local BannerStroke = Instance.new("UIStroke")
    BannerStroke.Thickness = 1
    BannerStroke.Color = themeManager.Get("Border")
    BannerStroke.Transparency = 0.4
    BannerStroke.Parent = TopSongBanner

    -- Quick Header Buttons: Settings & Keybinds
    local HeaderBtnContainer = Instance.new("Frame")
    HeaderBtnContainer.Size = UDim2.new(0, 150, 1, 0)
    HeaderBtnContainer.Position = UDim2.new(1, -220, 0, 0)
    HeaderBtnContainer.BackgroundTransparency = 1
    HeaderBtnContainer.Parent = HubWindow.TopBar

    local HeaderBtnLayout = Instance.new("UIListLayout")
    HeaderBtnLayout.FillDirection = Enum.FillDirection.Horizontal
    HeaderBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    HeaderBtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    HeaderBtnLayout.Padding = UDim.new(0, 4)
    HeaderBtnLayout.Parent = HeaderBtnContainer

    local function CreateHeaderBtn(name: string, onClick: () -> ())
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 68, 0, 20)
        b.BackgroundColor3 = themeManager.Get("Surface")
        b.BackgroundTransparency = 0.25
        b.BorderSizePixel = 0
        b.Font = Enum.Font.Code
        b.Text = name
        b.TextColor3 = themeManager.Get("TextPrimary")
        b.TextSize = 10
        b.Parent = HeaderBtnContainer

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 3)
        c.Parent = b

        local s = Instance.new("UIStroke")
        s.Thickness = 1
        s.Color = themeManager.Get("Border")
        s.Transparency = 0.4
        s.Parent = b

        windowBase.AttachMicroInteractions(b)
        b.MouseButton1Click:Connect(onClick)
    end

    -- Left Navigation Rail
    local NavRail = Instance.new("Frame")
    NavRail.Name = "NavRail"
    NavRail.Size = UDim2.new(0, 110, 1, 0)
    NavRail.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
    NavRail.BackgroundTransparency = 0.25
    NavRail.BorderSizePixel = 0
    NavRail.Parent = HubWindow.Content

    local NavLine = Instance.new("Frame")
    NavLine.Size = UDim2.new(0, 1, 1, 0)
    NavLine.Position = UDim2.new(1, -1, 0, 0)
    NavLine.BackgroundColor3 = themeManager.Get("Border")
    NavLine.BackgroundTransparency = 0.5
    NavLine.BorderSizePixel = 0
    NavLine.Parent = NavRail

    local NavTopList = Instance.new("Frame")
    NavTopList.Size = UDim2.new(1, 0, 1, -38)
    NavTopList.BackgroundTransparency = 1
    NavTopList.Parent = NavRail

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.Parent = NavTopList

    local NavPad = Instance.new("UIPadding")
    NavPad.PaddingTop = UDim.new(0, 8)
    NavPad.PaddingLeft = UDim.new(0, 6)
    NavPad.PaddingRight = UDim.new(0, 6)
    NavPad.Parent = NavTopList

    -- Bottom Pinned Themes Tab
    local NavBottomSection = Instance.new("Frame")
    NavBottomSection.Size = UDim2.new(1, -12, 0, 30)
    NavBottomSection.Position = UDim2.new(0, 6, 1, -34)
    NavBottomSection.BackgroundTransparency = 1
    NavBottomSection.Parent = NavRail

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -110, 1, 0)
    ContentArea.Position = UDim2.new(0, 110, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = HubWindow.Content

    -- Active Tab Title Banner Header
    local TabHeaderBanner = Instance.new("Frame")
    TabHeaderBanner.Size = UDim2.new(1, -16, 0, 24)
    TabHeaderBanner.Position = UDim2.new(0, 8, 0, 6)
    TabHeaderBanner.BackgroundColor3 = themeManager.Get("Surface")
    TabHeaderBanner.BackgroundTransparency = 0.35
    TabHeaderBanner.BorderSizePixel = 0
    TabHeaderBanner.Parent = ContentArea

    local HeaderBannerCorner = Instance.new("UICorner")
    HeaderBannerCorner.CornerRadius = UDim.new(0, 3)
    HeaderBannerCorner.Parent = TabHeaderBanner

    local HeaderBannerStroke = Instance.new("UIStroke")
    HeaderBannerStroke.Thickness = 1
    HeaderBannerStroke.Color = themeManager.Get("Border")
    HeaderBannerStroke.Transparency = 0.5
    HeaderBannerStroke.Parent = TabHeaderBanner

    local ActiveTabIndicator = Instance.new("TextLabel")
    ActiveTabIndicator.Size = UDim2.new(1, -12, 1, 0)
    ActiveTabIndicator.Position = UDim2.new(0, 8, 0, 0)
    ActiveTabIndicator.BackgroundTransparency = 1
    ActiveTabIndicator.Font = Enum.Font.Code
    ActiveTabIndicator.Text = "MAIN  T A B"
    ActiveTabIndicator.TextColor3 = themeManager.Get("Accent")
    ActiveTabIndicator.TextSize = 11
    ActiveTabIndicator.TextXAlignment = Enum.TextXAlignment.Left
    ActiveTabIndicator.Parent = TabHeaderBanner
    themeManager.RegisterBinding(ActiveTabIndicator, "TextColor3", "Accent")

    -- Tab Container Frame
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 1, -34)
    TabContainer.Position = UDim2.new(0, 0, 0, 34)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = ContentArea

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
        LeftCol.Size = UDim2.new(0.5, -10, 1, -12)
        LeftCol.Position = UDim2.new(0, 8, 0, 4)
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
        RightCol.Size = UDim2.new(0.5, -10, 1, -12)
        RightCol.Position = UDim2.new(0.5, 2, 0, 4)
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

        ActiveTabIndicator.Text = string.upper(tabName) .. "  T A B"
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

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 3)
        c.Parent = btn

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

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = card

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = themeManager.Get("Border")
        stroke.Transparency = 0.4
        stroke.Parent = card

        -- Card Header
        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 22)
        header.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
        header.BackgroundTransparency = 0.3
        header.BorderSizePixel = 0
        header.Parent = card

        local hCorner = Instance.new("UICorner")
        hCorner.CornerRadius = UDim.new(0, 4)
        hCorner.Parent = header

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, -12, 1, 0)
        titleLbl.Position = UDim2.new(0, 8, 0, 0)
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

    -- Toggle Row Builder
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

        local rCorner = Instance.new("UICorner")
        rCorner.CornerRadius = UDim.new(0, 3)
        rCorner.Parent = row

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

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 2)
        bCorner.Parent = box

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

    -- Slider Builder
    local function AddSlider(cardContainer: Instance, labelText: string, min: number, max: number, default: number, callback: (number) -> ())
        local currentVal = default
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
        frame.BackgroundTransparency = 0.4
        frame.BorderSizePixel = 0
        frame.Parent = cardContainer

        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(0, 3)
        fCorner.Parent = frame

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

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 2)
        bCorner.Parent = barBack

        local fill = Instance.new("Frame")
        local initRatio = math.clamp((default - min) / (max - min), 0, 1)
        fill.Size = UDim2.new(initRatio, 0, 1, 0)
        fill.BackgroundColor3 = themeManager.Get("Accent")
        fill.BorderSizePixel = 0
        fill.Parent = barBack

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 2)
        fillCorner.Parent = fill
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

    -- Button Builder
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

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 3)
        c.Parent = btn

        local s = Instance.new("UIStroke")
        s.Thickness = 1
        s.Color = themeManager.Get("Border")
        s.Transparency = 0.4
        s.Parent = btn

        windowBase.AttachMicroInteractions(btn)
        btn.MouseButton1Click:Connect(onClick)
    end

    -- Register All Navigation Tabs
    local NavItems = { "MAIN", "PLAYER", "TARGETS", "VISUALS", "MUSIC", "SCRIPTS" }
    for _, nav in ipairs(NavItems) do
        RegisterNavTab(nav)
    end
    RegisterNavTab("THEMES", true)

    ----------------------------------------------------------------------------
    -- POPULATE TAB: MAIN
    ----------------------------------------------------------------------------
    local mainLeft = CreateCard(TabPages["MAIN"].Left, "System Overview")
    AddToggle(mainLeft, "Metatable Guard Hook", true, function(s) end)
    AddToggle(mainLeft, "Event Streamer Active", true, function(s) end)
    AddToggle(mainLeft, "Anti-Afk KeepAlive", true, function(s)
        pcall(function()
            LocalPlayer.Idled:Connect(function()
                game:GetService("VirtualUser"):Button2Down(Vector2.zero, Workspace.CurrentCamera.CFrame)
                task.wait(1)
                game:GetService("VirtualUser"):Button2Up(Vector2.zero, Workspace.CurrentCamera.CFrame)
            end)
        end)
    end)

    local mainRight = CreateCard(TabPages["MAIN"].Right, "Modular Windows")
    AddToggle(mainRight, "Chat Overlay", true, function(s) if windows.Chat then windows.Chat.Frame.Visible = s end end)
    AddToggle(mainRight, "Player List Overlay", true, function(s) if windows.PlayerList then windows.PlayerList.Frame.Visible = s end end)
    AddToggle(mainRight, "Music Widget", true, function(s) if windows.Music then windows.Music.Frame.Visible = s end end)

    local serverCard = CreateCard(TabPages["MAIN"].Left, "Server Status")
    AddButton(serverCard, "Rejoin Server", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
    AddButton(serverCard, "Server Hop", function()
        pcall(function()
            local sf = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=10"))
            if sf and sf.data and #sf.data > 1 then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, sf.data[2].id, LocalPlayer)
            end
        end)
    end)

    ----------------------------------------------------------------------------
    -- POPULATE TAB: PLAYER
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
    AddToggle(pRight, "Walk Fling (Angular)", false, function(s) flingMod.Toggle(s) end)

    ----------------------------------------------------------------------------
    -- POPULATE TAB: TARGETS
    ----------------------------------------------------------------------------
    local tLeft = CreateCard(TabPages["TARGETS"].Left, "Target Interaction")
    AddButton(tLeft, "Spectate Viewport Reset", function()
        Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end)
    AddButton(tLeft, "Fling Random Player", function()
        local plrs = Players:GetPlayers()
        for _, p in ipairs(plrs) do
            if p ~= LocalPlayer then
                flingMod.FlingPlayer(p, 0.6)
                break
            end
        end
    end)

    local tRight = CreateCard(TabPages["TARGETS"].Right, "Target Utilities")
    AddToggle(tRight, "Auto-Follow Nearest", false, function(s) end)
    AddToggle(tRight, "Orbit Target Active", false, function(s) end)

    ----------------------------------------------------------------------------
    -- POPULATE TAB: VISUALS
    ----------------------------------------------------------------------------
    local vLeft = CreateCard(TabPages["VISUALS"].Left, "Player ESP")
    AddToggle(vLeft, "Box 2D ESP", false, function(s) visualsMod.SetBoxESP(s) end)
    AddToggle(vLeft, "Name & Distance Tags", false, function(s) visualsMod.SetNameESP(s) end)
    AddToggle(vLeft, "Chams Highlights", false, function(s) visualsMod.SetHighlights(s) end)

    local vRight = CreateCard(TabPages["VISUALS"].Right, "World & Lighting")
    AddToggle(vRight, "Fullbright Daylight", false, function(s) visualsMod.SetFullbright(s) end)
    AddSlider(vRight, "Camera FOV", 60, 120, 70, function(v) visualsMod.SetFOV(v) end)

    ----------------------------------------------------------------------------
    -- POPULATE TAB: MUSIC
    ----------------------------------------------------------------------------
    local mLeft = CreateCard(TabPages["MUSIC"].Left, "Media Daemon Interop")
    AddToggle(mLeft, "Localhost Sync (9000)", false, function(s) end)
    AddToggle(mLeft, "Simulate Audio Frequency", true, function(s) end)

    local mRight = CreateCard(TabPages["MUSIC"].Right, "Audio Visualizer Modes")
    AddToggle(mRight, "16-Bar Spectrum HUD", true, function(s) if windows.Music then windows.Music.Frame.Visible = s end end)
    AddToggle(mRight, "Synced Lyrics Scroller", true, function(s) end)

    ----------------------------------------------------------------------------
    -- POPULATE TAB: THEMES
    ----------------------------------------------------------------------------
    local thLeft = CreateCard(TabPages["THEMES"].Left, "Theme Presets")
    local presets = themeManager.GetPresets()
    for name, col in pairs(presets) do
        AddButton(thLeft, name, function()
            themeManager.ApplyPreset(name)
        end)
    end

    local thRight = CreateCard(TabPages["THEMES"].Right, "Dynamic Accent Modulation")
    AddToggle(thRight, "Album Art Color Sync", false, function(s) end)

    ----------------------------------------------------------------------------
    -- POPULATE TAB: SCRIPTS
    ----------------------------------------------------------------------------
    local sLeft = CreateCard(TabPages["SCRIPTS"].Left, "Universal Script Hub")
    AddButton(sLeft, "Infinite Yield", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
    AddButton(sLeft, "Dex Explorer", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end)
    AddButton(sLeft, "SimpleSpy v3", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/src/source.lua"))()
    end)

    local sRight = CreateCard(TabPages["SCRIPTS"].Right, "Custom Code Slot")
    AddButton(sRight, "Execute Potassium Hooks", function()
        print("[Fish Menu]: Hooks injected.")
    end)

    -- Header Button Actions
    CreateHeaderBtn("Keybinds", function() SwitchTab("MAIN") end)
    CreateHeaderBtn("Settings", function() SwitchTab("THEMES") end)

    -- Initial Tab Switch
    SwitchTab("MAIN")

    return HubWindow
end

return MainMenu
