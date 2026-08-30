-- Fih_Menu.lua
-- Standalone Fih Menu Modular GUI Engine (Cyberpunk Neon Match)

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Target Parent
local TargetParent: Instance = CoreGui
pcall(function()
    local test = Instance.new("Folder")
    test.Parent = CoreGui
    test:Destroy()
end)
if TargetParent ~= CoreGui or not pcall(function() return CoreGui.Name end) then
    TargetParent = LocalPlayer:WaitForChild("PlayerGui")
end

if TargetParent:FindFirstChild("FishMenu_Host") then
    TargetParent.FishMenu_Host:Destroy()
end

local ScreenHost = Instance.new("ScreenGui")
ScreenHost.Name = "FishMenu_Host"
ScreenHost.ResetOnSpawn = false
ScreenHost.IgnoreGuiInset = true
ScreenHost.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenHost.DisplayOrder = 100
ScreenHost.Parent = TargetParent

--------------------------------------------------------------------------------
-- 1. THEME MANAGER
--------------------------------------------------------------------------------
local Tokens = {
    BackgroundPrimary   = Color3.fromRGB(18, 12, 26),
    BackgroundSecondary = Color3.fromRGB(26, 16, 36),
    Surface             = Color3.fromRGB(34, 20, 48),
    SurfaceHover        = Color3.fromRGB(52, 30, 74),
    Border              = Color3.fromRGB(80, 45, 110),
    BorderActive        = Color3.fromRGB(255, 60, 180),
    TextPrimary         = Color3.fromRGB(255, 255, 255),
    TextSecondary       = Color3.fromRGB(175, 155, 195),
    Accent              = Color3.fromRGB(255, 60, 180),
    AccentGlow          = Color3.fromRGB(255, 120, 210),
}

local Transparencies = {
    BackgroundPrimary   = 0.15,
    BackgroundSecondary = 0.20,
    Surface             = 0.30,
    Border              = 0.30,
}

local Presets = {
    ["Cyberpunk Neon"]   = Color3.fromRGB(255, 60, 180),
    ["Dark Cubed"]       = Color3.fromRGB(85, 170, 255),
    ["Acid Matrix"]      = Color3.fromRGB(0, 255, 130),
    ["Amber Sunset"]     = Color3.fromRGB(255, 160, 45),
    ["Monochrome Slate"] = Color3.fromRGB(190, 190, 205),
    ["Crimson Red"]      = Color3.fromRGB(255, 55, 75),
    ["Sakura Pink"]      = Color3.fromRGB(255, 135, 190),
    ["Deep Indigo"]      = Color3.fromRGB(140, 80, 255),
}

local Bindings = {}

local function GetColor(name: string): Color3
    return Tokens[name] or Color3.new(1, 1, 1)
end

local function GetTransparency(name: string): number
    return Transparencies[name] or 0
end

local function RegisterBinding(inst: Instance, prop: string, token: string)
    table.insert(Bindings, { Instance = inst, Property = prop, Key = token })
    pcall(function() (inst :: any)[prop] = Tokens[token] end)
end

local function SetAccent(col: Color3)
    Tokens.Accent = col
    Tokens.BorderActive = col
    for _, b in ipairs(Bindings) do
        if b.Instance and b.Instance.Parent then
            TweenService:Create(b.Instance, TweenInfo.new(0.30, Enum.EasingStyle.Quad), { [b.Property] = Tokens[b.Key] }):Play()
        end
    end
end

--------------------------------------------------------------------------------
-- 2. WINDOW BASE
--------------------------------------------------------------------------------
local TopZIndex = 30

local function CreateWindow(title: string, defaultSize: UDim2, initialPos: UDim2, minSize: Vector2?)
    local minS = minSize or Vector2.new(200, 120)
    local vp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local initX = initialPos.X.Scale * vp.X + initialPos.X.Offset
    local initY = initialPos.Y.Scale * vp.Y + initialPos.Y.Offset

    local Frame = Instance.new("Frame")
    Frame.Name = title .. "_Window"
    Frame.Size = defaultSize
    Frame.Position = UDim2.new(0, math.clamp(initX, 0, vp.X - 100), 0, math.clamp(initY, 0, vp.Y - 50))
    Frame.BackgroundColor3 = GetColor("BackgroundPrimary")
    Frame.BackgroundTransparency = GetTransparency("BackgroundPrimary")
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.ClipsDescendants = false
    Frame.ZIndex = TopZIndex
    Frame.Parent = ScreenHost

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = GetColor("Accent")
    Stroke.Transparency = 0.15
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Frame
    RegisterBinding(Stroke, "Color", "Accent")

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 22)
    TopBar.BackgroundColor3 = GetColor("BackgroundSecondary")
    TopBar.BackgroundTransparency = GetTransparency("BackgroundSecondary")
    TopBar.BorderSizePixel = 0
    TopBar.Active = true
    TopBar.Parent = Frame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 6, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.Text = title
    TitleLabel.TextColor3 = GetColor("TextPrimary")
    TitleLabel.TextSize = 11
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.Size = UDim2.new(0, 48, 1, 0)
    Controls.Position = UDim2.new(1, -50, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.ZIndex = 40
    Controls.Parent = TopBar

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 2)
    Layout.Parent = Controls

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 18, 0, 16)
    MinBtn.BackgroundColor3 = GetColor("Surface")
    MinBtn.BackgroundTransparency = 0.2
    MinBtn.BorderSizePixel = 0
    MinBtn.Font = Enum.Font.Code
    MinBtn.Text = "—"
    MinBtn.TextColor3 = GetColor("TextPrimary")
    MinBtn.TextSize = 10
    MinBtn.AutoButtonColor = false
    MinBtn.ZIndex = 41
    MinBtn.Parent = Controls

    local MinStroke = Instance.new("UIStroke")
    MinStroke.Thickness = 1
    MinStroke.Color = GetColor("Border")
    MinStroke.Transparency = 0.4
    MinStroke.Parent = MinBtn

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 18, 0, 16)
    CloseBtn.BackgroundColor3 = GetColor("Surface")
    CloseBtn.BackgroundTransparency = 0.2
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = GetColor("TextPrimary")
    CloseBtn.TextSize = 10
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 41
    CloseBtn.Parent = Controls

    local CloseStroke = Instance.new("UIStroke")
    CloseStroke.Thickness = 1
    CloseStroke.Color = GetColor("Border")
    CloseStroke.Transparency = 0.4
    CloseStroke.Parent = CloseBtn

    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, -22)
    Content.Position = UDim2.new(0, 0, 0, 22)
    Content.BackgroundTransparency = 1
    Content.ClipsDescendants = true
    Content.Parent = Frame

    local Grip = Instance.new("TextButton")
    Grip.Name = "ResizeGrip"
    Grip.Size = UDim2.new(0, 14, 0, 14)
    Grip.AnchorPoint = Vector2.new(1, 1)
    Grip.Position = UDim2.new(1, 0, 1, 0)
    Grip.BackgroundTransparency = 1
    Grip.Text = "◢"
    Grip.Font = Enum.Font.Code
    Grip.TextColor3 = GetColor("TextSecondary")
    Grip.TextSize = 11
    Grip.ZIndex = 35
    Grip.Parent = Frame

    local function BringToFront()
        TopZIndex += 1
        Frame.ZIndex = TopZIndex
    end

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            BringToFront()
        end
    end)

    local Dragging = false
    local DragStartMouse = Vector2.zero
    local DragStartPos = Vector2.zero

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStartMouse = Vector2.new(input.Position.X, input.Position.Y)
            DragStartPos = Vector2.new(Frame.AbsolutePosition.X, Frame.AbsolutePosition.Y)
            BringToFront()
        end
    end)

    local Resizing = false
    local ResizeStartMouse = Vector2.zero
    local ResizeStartSize = Vector2.zero

    Grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Resizing = true
            ResizeStartMouse = Vector2.new(input.Position.X, input.Position.Y)
            ResizeStartSize = Frame.AbsoluteSize
            BringToFront()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local currentVp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
            if Dragging then
                local currentMouse = Vector2.new(input.Position.X, input.Position.Y)
                local delta = currentMouse - DragStartMouse
                local targetX = math.clamp(DragStartPos.X + delta.X, 0, currentVp.X - Frame.AbsoluteSize.X)
                local targetY = math.clamp(DragStartPos.Y + delta.Y, 0, currentVp.Y - Frame.AbsoluteSize.Y)
                if targetX < 14 then targetX = 0 end
                if targetY < 14 then targetY = 0 end
                if math.abs((targetX + Frame.AbsoluteSize.X) - currentVp.X) < 14 then targetX = currentVp.X - Frame.AbsoluteSize.X end
                if math.abs((targetY + Frame.AbsoluteSize.Y) - currentVp.Y) < 14 then targetY = currentVp.Y - Frame.AbsoluteSize.Y end
                Frame.Position = UDim2.new(0, targetX, 0, targetY)
            elseif Resizing then
                local currentMouse = Vector2.new(input.Position.X, input.Position.Y)
                local delta = currentMouse - ResizeStartMouse
                local newW = math.clamp(ResizeStartSize.X + delta.X, minS.X, currentVp.X - Frame.AbsolutePosition.X)
                local newH = math.clamp(ResizeStartSize.Y + delta.Y, minS.Y, currentVp.Y - Frame.AbsolutePosition.Y)
                Frame.Size = UDim2.new(0, newW, 0, newH)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            Resizing = false
        end
    end)

    local isMin = false
    local storedSize = defaultSize
    MinBtn.MouseButton1Click:Connect(function()
        isMin = not isMin
        if isMin then
            storedSize = Frame.Size
            Content.Visible = false
            Grip.Visible = false
            Frame.Size = UDim2.new(0, Frame.AbsoluteSize.X, 0, 22)
            MinBtn.Text = "□"
        else
            Frame.Size = storedSize
            Content.Visible = true
            Grip.Visible = true
            MinBtn.Text = "—"
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function() Frame.Visible = false end)

    RegisterBinding(Frame, "BackgroundColor3", "BackgroundPrimary")
    RegisterBinding(TopBar, "BackgroundColor3", "BackgroundSecondary")

    return { Frame = Frame, TopBar = TopBar, Content = Content, TitleLabel = TitleLabel }
end

--------------------------------------------------------------------------------
-- 3. CHAT OVERLAY (Top-Left, Natural Top-to-Bottom Flow)
--------------------------------------------------------------------------------
pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false) end)

local ChatWin = CreateWindow("Chat", UDim2.new(0, 310, 0, 180), UDim2.new(0, 15, 0, 15), Vector2.new(240, 140))

local ChatTopControls = Instance.new("Frame")
ChatTopControls.Size = UDim2.new(0, 110, 1, 0)
ChatTopControls.Position = UDim2.new(0, 44, 0, 0)
ChatTopControls.BackgroundTransparency = 1
ChatTopControls.Parent = ChatWin.TopBar

local WaveformBar = Instance.new("Frame")
WaveformBar.Size = UDim2.new(0, 32, 0, 10)
WaveformBar.Position = UDim2.new(0, 48, 0.5, -5)
WaveformBar.BackgroundColor3 = GetColor("Surface")
WaveformBar.BorderSizePixel = 0
WaveformBar.Parent = ChatTopControls

local WaveFill = Instance.new("Frame")
WaveFill.Size = UDim2.new(0.5, 0, 1, 0)
WaveFill.BackgroundColor3 = GetColor("Accent")
WaveFill.BorderSizePixel = 0
WaveFill.Parent = WaveformBar
RegisterBinding(WaveFill, "BackgroundColor3", "Accent")

task.spawn(function()
    while true do
        task.wait(0.1)
        WaveFill.Size = UDim2.new(math.clamp(math.noise(tick() * 3, 0, 0) * 1.5, 0.15, 1.0), 0, 1, 0)
    end
end)

local MessageScroll = Instance.new("ScrollingFrame")
MessageScroll.Size = UDim2.new(1, -10, 1, -32)
MessageScroll.Position = UDim2.new(0, 5, 0, 4)
MessageScroll.BackgroundTransparency = 1
MessageScroll.BorderSizePixel = 0
MessageScroll.ScrollBarThickness = 2
MessageScroll.ScrollBarImageColor3 = GetColor("Border")
MessageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
MessageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
MessageScroll.Parent = ChatWin.Content

local MsgLayout = Instance.new("UIListLayout")
MsgLayout.SortOrder = Enum.SortOrder.LayoutOrder
MsgLayout.Padding = UDim.new(0, 2)
MsgLayout.VerticalAlignment = Enum.VerticalAlignment.Top
MsgLayout.Parent = MessageScroll

local function AddChatMessage(sender: string, text: string, isSelf: boolean)
    local hex = isSelf and "FF3CB4" or "55AAFF"
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -6, 0, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.RichText = true
    lbl.Text = string.format("<font color=\"#%s\"><b>%s</b></font>: %s", hex, sender, text)
    lbl.TextColor3 = GetColor("TextPrimary")
    lbl.TextSize = 10
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = MessageScroll

    task.defer(function()
        MessageScroll.CanvasPosition = Vector2.new(0, MessageScroll.AbsoluteCanvasSize.Y)
    end)
end

pcall(function()
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.MessageReceived:Connect(function(msg)
            if msg.TextSource then
                local p = Players:GetPlayerByUserId(msg.TextSource.UserId)
                AddChatMessage(p and p.DisplayName or msg.TextSource.Name, msg.Text, p == LocalPlayer)
            end
        end)
    else
        local sayEvent = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents", 3)
        if sayEvent and sayEvent:FindFirstChild("OnMessageDoneFiltering") then
            (sayEvent.OnMessageDoneFiltering :: any).OnClientEvent:Connect(function(data)
                if data and data.FromSpeaker and data.Message then
                    AddChatMessage(tostring(data.FromSpeaker), tostring(data.Message), tostring(data.FromSpeaker) == LocalPlayer.Name)
                end
            end)
        end
    end
end)

local ChatInputBar = Instance.new("Frame")
ChatInputBar.Size = UDim2.new(1, -10, 0, 20)
ChatInputBar.Position = UDim2.new(0, 5, 1, -24)
ChatInputBar.BackgroundColor3 = GetColor("Surface")
ChatInputBar.BorderSizePixel = 0
ChatInputBar.Parent = ChatWin.Content

local QuickBtn = Instance.new("TextButton")
QuickBtn.Size = UDim2.new(0, 40, 1, 0)
QuickBtn.BackgroundColor3 = GetColor("BackgroundSecondary")
QuickBtn.BorderSizePixel = 0
QuickBtn.Font = Enum.Font.Code
QuickBtn.Text = "Quick"
QuickBtn.TextColor3 = GetColor("TextSecondary")
QuickBtn.TextSize = 9
QuickBtn.Parent = ChatInputBar

local ChatBox = Instance.new("TextBox")
ChatBox.Size = UDim2.new(1, -84, 1, 0)
ChatBox.Position = UDim2.new(0, 42, 0, 0)
ChatBox.BackgroundTransparency = 1
ChatBox.Font = Enum.Font.Code
ChatBox.PlaceholderText = "To chat click here or press / key"
ChatBox.PlaceholderColor3 = GetColor("TextSecondary")
ChatBox.Text = ""
ChatBox.TextColor3 = GetColor("TextPrimary")
ChatBox.TextSize = 9
ChatBox.ClearTextOnFocus = false
ChatBox.TextXAlignment = Enum.TextXAlignment.Left
ChatBox.Parent = ChatInputBar

local SendBtn = Instance.new("TextButton")
SendBtn.Size = UDim2.new(0, 40, 1, 0)
SendBtn.Position = UDim2.new(1, -40, 0, 0)
SendBtn.BackgroundColor3 = GetColor("Accent")
SendBtn.BorderSizePixel = 0
SendBtn.Font = Enum.Font.Code
SendBtn.Text = "Send"
SendBtn.TextColor3 = Color3.new(1, 1, 1)
SendBtn.TextSize = 9
SendBtn.Parent = ChatInputBar
RegisterBinding(SendBtn, "BackgroundColor3", "Accent")

local function Transmit(msg: string)
    if #msg == 0 then return end
    ChatBox.Text = ""
    task.spawn(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local general = TextChatService:WaitForChild("TextChannels", 2)
            if general and general:FindFirstChild("RBXGeneral") then
                (general.RBXGeneral :: any):SendAsync(msg)
            end
        else
            local sayEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if sayEvent and sayEvent:FindFirstChild("SayMessageRequest") then
                sayEvent.SayMessageRequest:FireServer(msg, "All")
            end
        end
    end)
end

SendBtn.MouseButton1Click:Connect(function() Transmit(ChatBox.Text) end)
ChatBox.FocusLost:Connect(function(enter) if enter then Transmit(ChatBox.Text) end end)

--------------------------------------------------------------------------------
-- 4. PLAYER LIST OVERLAY (Right Side, Headshot Mugshots, Dynamic Scaling)
--------------------------------------------------------------------------------
pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) end)

local PlrWin = CreateWindow("Players (0)", UDim2.new(0, 220, 0, 180), UDim2.new(1, -235, 0, 15), Vector2.new(180, 100))

local PlrScroll = Instance.new("ScrollingFrame")
PlrScroll.Size = UDim2.new(1, -8, 1, -8)
PlrScroll.Position = UDim2.new(0, 4, 0, 4)
PlrScroll.BackgroundTransparency = 1
PlrScroll.BorderSizePixel = 0
PlrScroll.ScrollBarThickness = 2
PlrScroll.ScrollBarImageColor3 = GetColor("Border")
PlrScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlrScroll.Parent = PlrWin.Content

local PlrLayout = Instance.new("UIListLayout")
PlrLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlrLayout.Padding = UDim.new(0, 2)
PlrLayout.Parent = PlrScroll

local function RefreshPlayerList()
    local all = Players:GetPlayers()
    PlrWin.TitleLabel.Text = string.format("Players (%d)", #all)

    local targetH = math.clamp(28 + (#all * 26), 90, 520)
    TweenService:Create(PlrWin.Frame, TweenInfo.new(0.20, Enum.EasingStyle.Quad), { Size = UDim2.new(0, PlrWin.Frame.AbsoluteSize.X, 0, targetH) }):Play()

    for _, c in ipairs(PlrScroll:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end

    for _, plr in ipairs(all) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 24)
        row.BackgroundColor3 = GetColor("Surface")
        row.BackgroundTransparency = 0.3
        row.BorderSizePixel = 0
        row.Parent = PlrScroll

        local mugshot = Instance.new("ImageLabel")
        mugshot.Size = UDim2.new(0, 18, 0, 18)
        mugshot.Position = UDim2.new(0, 3, 0.5, -9)
        mugshot.BackgroundColor3 = GetColor("BackgroundSecondary")
        mugshot.BorderSizePixel = 0
        mugshot.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(plr.UserId) .. "&w=100&h=100"
        mugshot.Parent = row

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -26, 1, 0)
        nameLbl.Position = UDim2.new(0, 24, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.Code
        nameLbl.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
        nameLbl.TextColor3 = GetColor("TextPrimary")
        nameLbl.TextSize = 9
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.Parent = row
    end
end

RefreshPlayerList()
Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)

--------------------------------------------------------------------------------
-- 5. MUSIC HUD (Bottom Left)
--------------------------------------------------------------------------------
local MusicWin = CreateWindow("Fih HUD :: Now Playing & Synced Lyrics", UDim2.new(0, 320, 0, 130), UDim2.new(0, 15, 1, -145), Vector2.new(280, 110))

local CoverArt = Instance.new("ImageLabel")
CoverArt.Size = UDim2.new(0, 80, 1, -10)
CoverArt.Position = UDim2.new(0, 5, 0, 5)
CoverArt.BackgroundColor3 = GetColor("Surface")
CoverArt.BorderSizePixel = 0
CoverArt.Image = "rbxassetid://10849911991"
CoverArt.Parent = MusicWin.Content

local SongDetails = Instance.new("Frame")
SongDetails.Size = UDim2.new(1, -95, 1, -10)
SongDetails.Position = UDim2.new(0, 90, 0, 5)
SongDetails.BackgroundTransparency = 1
SongDetails.Parent = MusicWin.Content

local SongTitleLabel = Instance.new("TextLabel")
SongTitleLabel.Size = UDim2.new(1, 0, 0, 14)
SongTitleLabel.BackgroundTransparency = 1
SongTitleLabel.Font = Enum.Font.Code
SongTitleLabel.Text = "you make me sick bitch!!"
SongTitleLabel.TextColor3 = GetColor("Accent")
SongTitleLabel.TextSize = 9
SongTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SongTitleLabel.Parent = SongDetails
RegisterBinding(SongTitleLabel, "TextColor3", "Accent")

local ArtistLabel = Instance.new("TextLabel")
ArtistLabel.Size = UDim2.new(1, 0, 0, 12)
ArtistLabel.Position = UDim2.new(0, 0, 0, 14)
ArtistLabel.BackgroundTransparency = 1
ArtistLabel.Font = Enum.Font.Code
ArtistLabel.Text = "Ashnikko [Spotify]"
ArtistLabel.TextColor3 = Color3.fromRGB(85, 170, 255)
ArtistLabel.TextSize = 8
ArtistLabel.TextXAlignment = Enum.TextXAlignment.Left
ArtistLabel.Parent = SongDetails

local LyricsLabel = Instance.new("TextLabel")
LyricsLabel.Size = UDim2.new(1, 0, 0, 14)
LyricsLabel.Position = UDim2.new(0, 0, 0, 28)
LyricsLabel.BackgroundTransparency = 1
LyricsLabel.Font = Enum.Font.Code
LyricsLabel.Text = "Starting to tell me that it's okay"
LyricsLabel.TextColor3 = GetColor("TextSecondary")
LyricsLabel.TextSize = 8
LyricsLabel.TextXAlignment = Enum.TextXAlignment.Left
LyricsLabel.Parent = SongDetails

local ControlsBar = Instance.new("TextLabel")
ControlsBar.Size = UDim2.new(1, 0, 0, 14)
ControlsBar.Position = UDim2.new(0, 0, 0, 44)
ControlsBar.BackgroundTransparency = 1
ControlsBar.Font = Enum.Font.Code
ControlsBar.Text = "[|<]  [||]  [>|]   VOL [====] SPEED [1x]"
ControlsBar.TextColor3 = GetColor("TextPrimary")
ControlsBar.TextSize = 8
ControlsBar.TextXAlignment = Enum.TextXAlignment.Left
ControlsBar.Parent = SongDetails

local VisualizerFrame = Instance.new("Frame")
VisualizerFrame.Size = UDim2.new(1, 0, 0, 22)
VisualizerFrame.Position = UDim2.new(0, 0, 1, -22)
VisualizerFrame.BackgroundColor3 = GetColor("BackgroundSecondary")
VisualizerFrame.BorderSizePixel = 0
VisualizerFrame.ClipsDescendants = true
VisualizerFrame.Parent = SongDetails

local VisLayout = Instance.new("UIListLayout")
VisLayout.FillDirection = Enum.FillDirection.Horizontal
VisLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
VisLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
VisLayout.Padding = UDim.new(0, 2)
VisLayout.Parent = VisualizerFrame

local VisualizerBars = {}
for i = 1, 16 do
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 7, 0, 4)
    bar.BackgroundColor3 = GetColor("Accent")
    bar.BorderSizePixel = 0
    bar.Parent = VisualizerFrame
    RegisterBinding(bar, "BackgroundColor3", "Accent")
    table.insert(VisualizerBars, bar)
end

task.spawn(function()
    while true do
        task.wait(0.08)
        local t = tick()
        for idx, bar in ipairs(VisualizerBars) do
            local noiseVal = math.noise(idx * 0.35, t * 4, 0)
            bar.Size = UDim2.new(0, 7, 0, math.clamp(math.abs(noiseVal) * 20, 3, 20))
        end
    end
end)

--------------------------------------------------------------------------------
-- 6. MAIN HUB WINDOW (Center Screen, Hero Banner, Inside-Tab SubHeader, 2-Column Categories)
--------------------------------------------------------------------------------
local MainWin = CreateWindow("Fih Ui", UDim2.new(0, 560, 0, 340), UDim2.new(0.5, -280, 0.5, -170), Vector2.new(480, 280))

-- Nav Rail
local NavRail = Instance.new("Frame")
NavRail.Size = UDim2.new(0, 85, 1, -8)
NavRail.Position = UDim2.new(0, 4, 0, 4)
NavRail.BackgroundColor3 = GetColor("BackgroundSecondary")
NavRail.BorderSizePixel = 0
NavRail.Parent = MainWin.Content

local NavRailStroke = Instance.new("UIStroke")
NavRailStroke.Thickness = 1
NavRailStroke.Color = GetColor("Border")
NavRailStroke.Parent = NavRail

local NavTopList = Instance.new("Frame")
NavTopList.Size = UDim2.new(1, 0, 1, -26)
NavTopList.BackgroundTransparency = 1
NavTopList.Parent = NavRail

local NavLayout = Instance.new("UIListLayout")
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Padding = UDim.new(0, 3)
NavLayout.Parent = NavTopList

local NavPad = Instance.new("UIPadding")
NavPad.PaddingTop = UDim.new(0, 4)
NavPad.PaddingLeft = UDim.new(0, 4)
NavPad.PaddingRight = UDim.new(0, 4)
NavPad.Parent = NavTopList

local NavBottomSection = Instance.new("Frame")
NavBottomSection.Size = UDim2.new(1, -8, 0, 20)
NavBottomSection.Position = UDim2.new(0, 4, 1, -22)
NavBottomSection.BackgroundTransparency = 1
NavBottomSection.Parent = NavRail

-- Right Content Area
local RightContent = Instance.new("Frame")
RightContent.Size = UDim2.new(1, -98, 1, -8)
RightContent.Position = UDim2.new(0, 93, 0, 4)
RightContent.BackgroundTransparency = 1
RightContent.ClipsDescendants = true
RightContent.Parent = MainWin.Content

-- Sub-Header (Inside Right Tab Content)
local SubHeader = Instance.new("Frame")
SubHeader.Size = UDim2.new(1, 0, 0, 20)
SubHeader.BackgroundTransparency = 1
SubHeader.Parent = RightContent

local TabTag = Instance.new("Frame")
TabTag.Size = UDim2.new(0, 65, 1, 0)
TabTag.BackgroundColor3 = GetColor("Surface")
TabTag.BorderSizePixel = 0
TabTag.Parent = SubHeader

local TabTagStroke = Instance.new("UIStroke")
TabTagStroke.Thickness = 1
TabTagStroke.Color = GetColor("Accent")
TabTagStroke.Parent = TabTag
RegisterBinding(TabTagStroke, "Color", "Accent")

local TabTagLabel = Instance.new("TextLabel")
TabTagLabel.Size = UDim2.new(1, 0, 1, 0)
TabTagLabel.BackgroundTransparency = 1
TabTagLabel.Font = Enum.Font.Code
TabTagLabel.Text = "Main"
TabTagLabel.TextColor3 = GetColor("Accent")
TabTagLabel.TextSize = 10
TabTagLabel.Parent = TabTag
RegisterBinding(TabTagLabel, "TextColor3", "Accent")

local SubHeaderRight = Instance.new("Frame")
SubHeaderRight.Size = UDim2.new(0, 140, 1, 0)
SubHeaderRight.Position = UDim2.new(1, -140, 0, 0)
SubHeaderRight.BackgroundTransparency = 1
SubHeaderRight.Parent = SubHeader

local SubLayout = Instance.new("UIListLayout")
SubLayout.FillDirection = Enum.FillDirection.Horizontal
SubLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
SubLayout.Padding = UDim.new(0, 3)
SubLayout.Parent = SubHeaderRight

local function CreateSubBtn(txt: string, onClick: () -> ())
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 65, 1, 0)
    b.BackgroundColor3 = GetColor("Surface")
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Code
    b.Text = txt
    b.TextColor3 = GetColor("TextPrimary")
    b.TextSize = 9
    b.Parent = SubHeaderRight
    b.MouseButton1Click:Connect(onClick)
end

-- Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 1, -24)
TabContainer.Position = UDim2.new(0, 0, 0, 24)
TabContainer.BackgroundTransparency = 1
TabContainer.ClipsDescendants = true
TabContainer.Parent = RightContent

-- Drawer Overlay (Contained inside Tab, Animates Top-To-Bottom)
local DrawerOverlay = Instance.new("Frame")
DrawerOverlay.Size = UDim2.new(1, 0, 1, 0)
DrawerOverlay.Position = UDim2.new(0, 0, -1, 0)
DrawerOverlay.BackgroundColor3 = GetColor("BackgroundPrimary")
DrawerOverlay.BackgroundTransparency = 0.05
DrawerOverlay.BorderSizePixel = 0
DrawerOverlay.ZIndex = 50
DrawerOverlay.Visible = false
DrawerOverlay.Parent = TabContainer

local DrawerStroke = Instance.new("UIStroke")
DrawerStroke.Thickness = 1
DrawerStroke.Color = GetColor("Accent")
DrawerStroke.Parent = DrawerOverlay

local DrawerHeader = Instance.new("Frame")
DrawerHeader.Size = UDim2.new(1, 0, 0, 22)
DrawerHeader.BackgroundColor3 = GetColor("BackgroundSecondary")
DrawerHeader.BorderSizePixel = 0
DrawerHeader.ZIndex = 51
DrawerHeader.Parent = DrawerOverlay

local DrawerTitle = Instance.new("TextLabel")
DrawerTitle.Size = UDim2.new(1, -30, 1, 0)
DrawerTitle.Position = UDim2.new(0, 6, 0, 0)
DrawerTitle.BackgroundTransparency = 1
DrawerTitle.Font = Enum.Font.Code
DrawerTitle.Text = "SETTINGS"
DrawerTitle.TextColor3 = GetColor("Accent")
DrawerTitle.TextSize = 10
DrawerTitle.TextXAlignment = Enum.TextXAlignment.Left
DrawerTitle.ZIndex = 52
DrawerTitle.Parent = DrawerHeader

local DrawerClose = Instance.new("TextButton")
DrawerClose.Size = UDim2.new(0, 18, 0, 16)
DrawerClose.Position = UDim2.new(1, -22, 0.5, -8)
DrawerClose.BackgroundColor3 = GetColor("Surface")
DrawerClose.BorderSizePixel = 0
DrawerClose.Font = Enum.Font.Code
DrawerClose.Text = "✕"
DrawerClose.TextColor3 = Color3.new(1, 1, 1)
DrawerClose.TextSize = 10
DrawerClose.ZIndex = 53
DrawerClose.Parent = DrawerHeader

local DrawerScroll = Instance.new("ScrollingFrame")
DrawerScroll.Size = UDim2.new(1, -8, 1, -26)
DrawerScroll.Position = UDim2.new(0, 4, 0, 24)
DrawerScroll.BackgroundTransparency = 1
DrawerScroll.BorderSizePixel = 0
DrawerScroll.ScrollBarThickness = 2
DrawerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
DrawerScroll.ZIndex = 51
DrawerScroll.Parent = DrawerOverlay

local DrawerLayout = Instance.new("UIListLayout")
DrawerLayout.SortOrder = Enum.SortOrder.LayoutOrder
DrawerLayout.Padding = UDim.new(0, 4)
DrawerLayout.Parent = DrawerScroll

local function OpenDrawer(title: string, buildFn: (Instance) -> ())
    DrawerTitle.Text = string.upper(title)
    for _, ch in ipairs(DrawerScroll:GetChildren()) do
        if ch:IsA("GuiObject") then ch:Destroy() end
    end
    buildFn(DrawerScroll)

    DrawerOverlay.Visible = true
    DrawerOverlay.Position = UDim2.new(0, 0, -1, 0)
    TweenService:Create(DrawerOverlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Position = UDim2.new(0, 0, 0, 0) }):Play()
end

DrawerClose.MouseButton1Click:Connect(function()
    local tw = TweenService:Create(DrawerOverlay, TweenInfo.new(0.20, Enum.EasingStyle.Quad), { Position = UDim2.new(0, 0, -1, 0) })
    tw:Play()
    tw.Completed:Connect(function() DrawerOverlay.Visible = false end)
end)

CreateSubBtn("Adapt", function()
    OpenDrawer("Adaptive Themes", function(p)
        local c = Instance.new("TextLabel")
        c.Size = UDim2.new(1, 0, 0, 20)
        c.BackgroundTransparency = 1
        c.Font = Enum.Font.Code
        c.Text = "Dynamic Album Art Adaptation: Active"
        c.TextColor3 = GetColor("TextPrimary")
        c.TextSize = 9
        c.ZIndex = 52
        c.Parent = p
    end)
end)

CreateSubBtn("Settings", function()
    OpenDrawer("Settings & Keybinds", function(p)
        local c = Instance.new("TextLabel")
        c.Size = UDim2.new(1, 0, 0, 20)
        c.BackgroundTransparency = 1
        c.Font = Enum.Font.Code
        c.Text = "RightControl : Toggle GUI\nF : Toggle Flight\nN : Toggle Noclip"
        c.TextColor3 = GetColor("TextPrimary")
        c.TextSize = 9
        c.ZIndex = 52
        c.Parent = p
    end)
end)

-- Tab Page Registration
local TabPages = {}
local TabButtons = {}
local CurrentTab = ""

local function CreateTabPage(name: string)
    local Page = Instance.new("Frame")
    Page.Name = "Page_" .. name
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = TabContainer

    local HeroBanner = Instance.new("Frame")
    HeroBanner.Size = UDim2.new(1, 0, 0, 36)
    HeroBanner.BackgroundColor3 = GetColor("Surface")
    HeroBanner.BackgroundTransparency = 0.4
    HeroBanner.BorderSizePixel = 0
    HeroBanner.Parent = Page

    local HeroTitle = Instance.new("TextLabel")
    HeroTitle.Size = UDim2.new(1, 0, 0, 18)
    HeroTitle.BackgroundTransparency = 1
    HeroTitle.Font = Enum.Font.Code
    HeroTitle.Text = "Fih Ui"
    HeroTitle.TextColor3 = GetColor("TextPrimary")
    HeroTitle.TextSize = 13
    HeroTitle.Parent = HeroBanner

    local HeroSub = Instance.new("TextLabel")
    HeroSub.Size = UDim2.new(1, 0, 0, 14)
    HeroSub.Position = UDim2.new(0, 0, 0, 18)
    HeroSub.BackgroundTransparency = 1
    HeroSub.Font = Enum.Font.Code
    HeroSub.Text = "Windows XP / 207 Modular Engine | T to Toggle"
    HeroSub.TextColor3 = GetColor("TextSecondary")
    HeroSub.TextSize = 8
    HeroSub.Parent = HeroBanner

    local LeftCol = Instance.new("ScrollingFrame")
    LeftCol.Size = UDim2.new(0.5, -3, 1, -40)
    LeftCol.Position = UDim2.new(0, 0, 0, 38)
    LeftCol.BackgroundTransparency = 1
    LeftCol.BorderSizePixel = 0
    LeftCol.ScrollBarThickness = 2
    LeftCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
    LeftCol.Parent = Page

    local LeftLayout = Instance.new("UIListLayout")
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LeftLayout.Padding = UDim.new(0, 4)
    LeftLayout.Parent = LeftCol

    local RightCol = Instance.new("ScrollingFrame")
    RightCol.Size = UDim2.new(0.5, -3, 1, -40)
    RightCol.Position = UDim2.new(0.5, 3, 0, 38)
    RightCol.BackgroundTransparency = 1
    RightCol.BorderSizePixel = 0
    RightCol.ScrollBarThickness = 2
    RightCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
    RightCol.Parent = Page

    local RightLayout = Instance.new("UIListLayout")
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Padding = UDim.new(0, 4)
    RightLayout.Parent = RightCol

    TabPages[name] = { Page = Page, Left = LeftCol, Right = RightCol }
    return TabPages[name]
end

local function SwitchTab(tabName: string)
    if CurrentTab == tabName then return end
    for name, btn in pairs(TabButtons) do
        if name == tabName then
            btn.BackgroundColor3 = GetColor("Surface")
            btn.TextColor3 = GetColor("Accent")
        else
            btn.BackgroundColor3 = GetColor("BackgroundSecondary")
            btn.TextColor3 = GetColor("TextSecondary")
        end
    end
    if TabPages[CurrentTab] then TabPages[CurrentTab].Page.Visible = false end
    if TabPages[tabName] then TabPages[tabName].Page.Visible = true end
    TabTagLabel.Text = tabName
    CurrentTab = tabName
end

local function RegisterTab(name: string, isBottom: boolean?)
    local parent = isBottom and NavBottomSection or NavTopList
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 20)
    btn.BackgroundColor3 = GetColor("BackgroundSecondary")
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Code
    btn.Text = name
    btn.TextColor3 = GetColor("TextSecondary")
    btn.TextSize = 9
    btn.AutoButtonColor = false
    btn.Parent = parent

    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    TabButtons[name] = btn
    CreateTabPage(name)
end

local function CreateCard(parent: Instance, title: string)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = GetColor("Surface")
    card.BackgroundTransparency = 0.35
    card.BorderSizePixel = 0
    card.Parent = parent

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 18)
    header.BackgroundColor3 = GetColor("BackgroundSecondary")
    header.BorderSizePixel = 0
    header.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 1, 0)
    lbl.Position = UDim2.new(0, 4, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.Text = title
    lbl.TextColor3 = GetColor("Accent")
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = header
    RegisterBinding(lbl, "TextColor3", "Accent")

    local items = Instance.new("Frame")
    items.Size = UDim2.new(1, -8, 0, 0)
    items.Position = UDim2.new(0, 4, 0, 20)
    items.AutomaticSize = Enum.AutomaticSize.Y
    items.BackgroundTransparency = 1
    items.Parent = card

    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 3)
    l.Parent = items

    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, 4)
    pad.Parent = items

    return items
end

local function AddToggle(parent: Instance, label: string, default: boolean, cb: (boolean) -> ())
    local state = default
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 18)
    row.BackgroundColor3 = GetColor("BackgroundSecondary")
    row.BackgroundTransparency = 0.4
    row.BorderSizePixel = 0
    row.AutoButtonColor = false
    row.Text = ""
    row.Parent = parent

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(1, -22, 1, 0)
    tLbl.Position = UDim2.new(0, 4, 0, 0)
    tLbl.BackgroundTransparency = 1
    tLbl.Font = Enum.Font.Code
    tLbl.Text = label
    tLbl.TextColor3 = GetColor("TextPrimary")
    tLbl.TextSize = 8
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Parent = row

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 11, 0, 11)
    box.Position = UDim2.new(1, -14, 0.5, -5)
    box.BackgroundColor3 = state and GetColor("Accent") or GetColor("Surface")
    box.BorderSizePixel = 0
    box.Parent = row

    local check = Instance.new("TextLabel")
    check.Size = UDim2.new(1, 0, 1, 0)
    check.BackgroundTransparency = 1
    check.Font = Enum.Font.Code
    check.Text = state and "✓" or ""
    check.TextColor3 = Color3.new(1, 1, 1)
    check.TextSize = 8
    check.Parent = box

    row.MouseButton1Click:Connect(function()
        state = not state
        box.BackgroundColor3 = state and GetColor("Accent") or GetColor("Surface")
        check.Text = state and "✓" or ""
        cb(state)
    end)
end

local function AddSlider(parent: Instance, label: string, min: number, max: number, default: number, cb: (number) -> ())
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 24)
    frame.BackgroundColor3 = GetColor("BackgroundSecondary")
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(1, -30, 0, 10)
    tLbl.Position = UDim2.new(0, 4, 0, 2)
    tLbl.BackgroundTransparency = 1
    tLbl.Font = Enum.Font.Code
    tLbl.Text = label
    tLbl.TextColor3 = GetColor("TextPrimary")
    tLbl.TextSize = 8
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Parent = frame

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 26, 0, 10)
    valLbl.Position = UDim2.new(1, -28, 0, 2)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.Code
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = GetColor("Accent")
    valLbl.TextSize = 8
    valLbl.Parent = frame
    RegisterBinding(valLbl, "TextColor3", "Accent")

    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1, -8, 0, 5)
    bar.Position = UDim2.new(0, 4, 0, 14)
    bar.BackgroundColor3 = GetColor("Surface")
    bar.BorderSizePixel = 0
    bar.Text = ""
    bar.AutoButtonColor = false
    bar.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = GetColor("Accent")
    fill.BorderSizePixel = 0
    fill.Parent = bar
    RegisterBinding(fill, "BackgroundColor3", "Accent")

    local sliding = false
    local function Update(input: InputObject)
        local ratio = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        local val = math.floor(min + (max - min) * ratio)
        valLbl.Text = tostring(val)
        cb(val)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; Update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
    end)
end

local function AddButton(parent: Instance, label: string, onClick: () -> ())
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 18)
    btn.BackgroundColor3 = GetColor("BackgroundSecondary")
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Code
    btn.Text = label
    btn.TextColor3 = GetColor("TextPrimary")
    btn.TextSize = 8
    btn.Parent = parent
    btn.MouseButton1Click:Connect(onClick)
end

-- Register Tabs
for _, nav in ipairs({ "Main", "Esp", "Music", "Troll", "Scripts" }) do RegisterTab(nav) end
RegisterTab("Themes", true)

-- Populate Main
local mMove = CreateCard(TabPages["Main"].Left, "[Movement & Physics]")
AddToggle(mMove, "Infinite Jump", false, function(s) end)
AddToggle(mMove, "Flight", false, function(s) end)
AddSlider(mMove, "Flight Speed", 16, 250, 55, function(v) end)
AddToggle(mMove, "Noclip", false, function(s) end)
AddToggle(mMove, "Click TP (Ctrl + Click)", false, function(s) end)
AddToggle(mMove, "Anti Ragdoll", false, function(s) end)
AddToggle(mMove, "Fragile Player (Glass Mode)", false, function(s) end)
AddSlider(mMove, "Fragile Knockback Force", 0, 100, 50, function(v) end)
AddButton(mMove, "[ Force Respawn ]", function() if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end end)

local mStats = CreateCard(TabPages["Main"].Right, "[Stat Modifications]")
AddToggle(mStats, "Enable Custom Walk Speed", false, function(s) end)
AddSlider(mStats, "Walk Speed", 16, 250, 16, function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end end)
AddToggle(mStats, "Enable Custom Jump", false, function(s) end)
AddSlider(mStats, "Jump Height / Power", 50, 350, 50, function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = v end end)

local mWorld = CreateCard(TabPages["Main"].Right, "[World Modifiers]")
AddSlider(mWorld, "Gravity", 0, 400, 196, function(v) Workspace.Gravity = v end)
AddSlider(mWorld, "Reach Extender", 0, 50, 0, function(v) end)
AddToggle(mWorld, "Anti-Aim (Spin BOT)", false, function(s) end)

local mCam = CreateCard(TabPages["Main"].Right, "[Camera & Fov]")
AddSlider(mCam, "Fov", 60, 120, 70, function(v) Workspace.CurrentCamera.FieldOfView = v end)
AddToggle(mCam, "Full Bright", false, function(s) Lighting.Brightness = s and 2 or 1 end)

-- Populate Themes
local thLeft = CreateCard(TabPages["Themes"].Left, "[Theme Presets]")
for name, col in pairs(Presets) do
    AddButton(thLeft, name, function() SetAccent(col) end)
end

-- Populate Scripts
local scLeft = CreateCard(TabPages["Scripts"].Left, "[Universal Hubs]")
AddButton(scLeft, "Infinite Yield", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end)
AddButton(scLeft, "Dex Explorer", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end)
AddButton(scLeft, "SimpleSpy v3", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/src/source.lua"))() end)

SwitchTab("Main")

print("[Fih Menu]: Standalone pixel-perfect suite injected.")
