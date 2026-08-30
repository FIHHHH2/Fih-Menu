-- Fih_Menu.lua
-- Complete Fih Menu Suite: Player Context Menu Popup, Troll Target Dropdown & Arrow Cycler, Reactive Theming, Interactive Audio Engine

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
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera

-- Safe GUI container
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
-- 1. GLOBAL THEME ENGINE
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

local function ApplyTheme(col: Color3)
    Tokens.Accent = col
    Tokens.BorderActive = col
    Tokens.AccentGlow = Color3.new(
        math.clamp(col.R * 1.2, 0, 1),
        math.clamp(col.G * 1.2, 0, 1),
        math.clamp(col.B * 1.2, 0, 1)
    )

    for _, b in ipairs(Bindings) do
        if b.Instance and b.Instance.Parent then
            TweenService:Create(b.Instance, TweenInfo.new(0.30, Enum.EasingStyle.Quad), { [b.Property] = Tokens[b.Key] }):Play()
        end
    end
end

--------------------------------------------------------------------------------
-- 2. BACKEND CHEAT ENGINE
--------------------------------------------------------------------------------
local State = {
    InfiniteJump = false,
    Flight = false,
    FlySpeed = 55,
    Noclip = false,
    ClickTP = false,
    AntiRagdoll = false,
    Floater = false,
    FloatY = 0,
    Spinbot = false,
    WalkFling = false,
    OrbitTarget = false,
    AttachTarget = false,
    BoxESP = false,
    NameESP = false,
    Highlights = false,
    Fullbright = false,
    OriginalBrightness = Lighting.Brightness,
    OriginalClockTime = Lighting.ClockTime,
    OriginalFogEnd = Lighting.FogEnd,
    SelectedTarget = nil :: Player?,
}

local function GetRoot(char: Model?): BasePart?
    local character = char or LocalPlayer.Character
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")) :: BasePart?
end

local function GetHumanoid(char: Model?): Humanoid?
    local character = char or LocalPlayer.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = GetHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if State.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local mouse = LocalPlayer:GetMouse()
        local root = GetRoot()
        if mouse and mouse.Hit and root then
            root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)

RunService.Stepped:Connect(function()
    if State.Noclip and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

local OrbitAngle = 0
RunService.PostSimulation:Connect(function(dt)
    local root = GetRoot()
    local hum = GetHumanoid()
    if root and hum then
        if State.Spinbot then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(22), 0)
        end
        if State.WalkFling then
            root.AssemblyAngularVelocity = Vector3.new(0, 999999, 0)
            if hum.Sit then hum.Sit = false end
        end
        if State.OrbitTarget and State.SelectedTarget and State.SelectedTarget.Character then
            local tRoot = GetRoot(State.SelectedTarget.Character)
            if tRoot then
                OrbitAngle += dt * 4
                local offset = Vector3.new(math.cos(OrbitAngle) * 6, 2, math.sin(OrbitAngle) * 6)
                root.CFrame = CFrame.new(tRoot.Position + offset, tRoot.Position)
            end
        end
        if State.AttachTarget and State.SelectedTarget and State.SelectedTarget.Character then
            local tRoot = GetRoot(State.SelectedTarget.Character)
            if tRoot then
                root.CFrame = tRoot.CFrame * CFrame.new(0, 1.5, 2.5)
            end
        end
    end
end)

local FlightAtt, FlightLV, FlightConn = nil, nil, nil
local function ToggleFlight(enable: boolean)
    State.Flight = enable
    if enable then
        local root = GetRoot()
        if not root then return end
        FlightAtt = Instance.new("Attachment", root)
        FlightLV = Instance.new("LinearVelocity", root)
        FlightLV.Attachment0 = FlightAtt
        FlightLV.MaxForce = 1e6
        FlightLV.VectorVelocity = Vector3.zero
        FlightLV.RelativeTo = Enum.ActuatorRelativeTo.World

        FlightConn = RunService.RenderStepped:Connect(function()
            if not State.Flight or not FlightLV then return end
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0, 1, 0) end

            FlightLV.VectorVelocity = move.Magnitude > 0 and (move.Unit * State.FlySpeed) or Vector3.zero
        end)
    else
        if FlightConn then FlightConn:Disconnect(); FlightConn = nil end
        if FlightLV then FlightLV:Destroy(); FlightLV = nil end
        if FlightAtt then FlightAtt:Destroy(); FlightAtt = nil end
    end
end

local FloaterPart, FloaterConn = nil, nil
local function ToggleFloater(enable: boolean)
    State.Floater = enable
    if enable then
        local root = GetRoot()
        if not root then return end
        State.FloatY = root.Position.Y - 3.6
        FloaterPart = Instance.new("Part", Workspace)
        FloaterPart.Size = Vector3.new(6, 1, 6)
        FloaterPart.Anchored = true
        FloaterPart.CanCollide = true
        FloaterPart.Transparency = 0.35
        FloaterPart.Material = Enum.Material.Neon
        FloaterPart.Color = GetColor("Accent")
        FloaterPart.CFrame = CFrame.new(root.Position.X, State.FloatY, root.Position.Z)

        local t = 0
        FloaterConn = RunService.Heartbeat:Connect(function(dt)
            local r = GetRoot()
            if not r or not FloaterPart then return end
            t += dt
            if t >= 0.25 then t = 0; State.FloatY -= 0.45 end
            local h = GetHumanoid()
            if h and h:GetState() == Enum.HumanoidStateType.Jumping then
                State.FloatY = r.Position.Y - 3.6
            end
            FloaterPart.CFrame = CFrame.new(r.Position.X, State.FloatY, r.Position.Z)
        end)
    else
        if FloaterConn then FloaterConn:Disconnect(); FloaterConn = nil end
        if FloaterPart then FloaterPart:Destroy(); FloaterPart = nil end
    end
end

local function UpdateHighlights(enable: boolean)
    State.Highlights = enable
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hl = plr.Character:FindFirstChild("FihHighlight")
            if enable then
                if not hl then
                    hl = Instance.new("Highlight", plr.Character)
                    hl.Name = "FihHighlight"
                    hl.FillColor = GetColor("Accent")
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Adornee = plr.Character
                end
            else
                if hl then hl:Destroy() end
            end
        end
    end
end

local function UpdateBoxESP(enable: boolean)
    State.BoxESP = enable
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local bg = root:FindFirstChild("FihESP_Box")
                if enable then
                    if not bg then
                        local b = Instance.new("BillboardGui", root)
                        b.Name = "FihESP_Box"
                        b.Adornee = root
                        b.Size = UDim2.new(4, 0, 5.5, 0)
                        b.AlwaysOnTop = true

                        local f = Instance.new("Frame", b)
                        f.Size = UDim2.new(1, 0, 1, 0)
                        f.BackgroundTransparency = 0.85
                        f.BackgroundColor3 = GetColor("Accent")
                        f.BorderSizePixel = 0

                        local s = Instance.new("UIStroke", f)
                        s.Thickness = 1.5
                        s.Color = GetColor("Accent")
                    end
                else
                    if bg then bg:Destroy() end
                end
            end
        end
    end
end

local function UpdateNameESP(enable: boolean)
    State.NameESP = enable
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local bg = head:FindFirstChild("FihESP_Name")
                if enable then
                    if not bg then
                        local b = Instance.new("BillboardGui", head)
                        b.Name = "FihESP_Name"
                        b.Adornee = head
                        b.Size = UDim2.new(0, 120, 0, 24)
                        b.StudsOffset = Vector3.new(0, 2.2, 0)
                        b.AlwaysOnTop = true

                        local lbl = Instance.new("TextLabel", b)
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Font = Enum.Font.Code
                        lbl.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
                        lbl.TextColor3 = Color3.new(1, 1, 1)
                        lbl.TextSize = 10
                    end
                else
                    if bg then bg:Destroy() end
                end
            end
        end
    end
end

local function ToggleFullbright(enable: boolean)
    State.Fullbright = enable
    if enable then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = State.OriginalBrightness
        Lighting.ClockTime = State.OriginalClockTime
        Lighting.FogEnd = State.OriginalFogEnd
        Lighting.GlobalShadows = true
    end
end

--------------------------------------------------------------------------------
-- 3. AUDIO STREAM & INTERACTIVE PLAYLIST
--------------------------------------------------------------------------------
local AudioStream = Instance.new("Sound")
AudioStream.Name = "FihMenu_AudioStream"
AudioStream.Looped = true
AudioStream.Volume = 1.0
AudioStream.PlaybackSpeed = 1.0
AudioStream.Parent = SoundService

local Playlist = {
    { Title = "Lo-Fi Study Beats", Artist = "Universal Audio [Local]", Id = 9048375035, Cover = "rbxassetid://10849911991", Lyric = "Chill lo-fi study rhythm flowing..." },
    { Title = "Synthwave Neon Sunset", Artist = "Retro Wave [Spotify]", Id = 9043887091, Cover = "rbxassetid://10849911991", Lyric = "Cruising down the digital highway at night" },
    { Title = "Chill Ambient Rain", Artist = "Atmospheric Study [Local]", Id = 1837849285, Cover = "rbxassetid://10849911991", Lyric = "Gentle rain tapping against the glass pane" },
    { Title = "Cyber Arcade 8-Bit", Artist = "Pixel Beats [Chiptune]", Id = 1845499092, Cover = "rbxassetid://10849911991", Lyric = "Insert coin to continue stage 01" },
}

local CurrentTrackIndex = 0
local IsAudioPlaying = false
local SpeedCycle = { 1.0, 1.25, 1.5, 2.0, 0.5 }
local CurrentSpeedIndex = 1

local OnTrackUpdated = Instance.new("BindableEvent")

local function PlayTrackByIndex(idx: number)
    if idx < 1 then idx = #Playlist end
    if idx > #Playlist then idx = 1 end
    CurrentTrackIndex = idx
    local track = Playlist[idx]

    AudioStream.SoundId = "rbxassetid://" .. tostring(track.Id)
    AudioStream:Play()
    IsAudioPlaying = true
    OnTrackUpdated:Fire(track, true)
end

local function TogglePlayPause()
    if CurrentTrackIndex == 0 then
        PlayTrackByIndex(1)
        return
    end

    if IsAudioPlaying then
        AudioStream:Pause()
        IsAudioPlaying = false
        OnTrackUpdated:Fire(Playlist[CurrentTrackIndex], false)
    else
        AudioStream:Resume()
        IsAudioPlaying = true
        OnTrackUpdated:Fire(Playlist[CurrentTrackIndex], true)
    end
end

local function NextTrack()
    PlayTrackByIndex(CurrentTrackIndex == 0 and 1 or (CurrentTrackIndex + 1))
end

local function PrevTrack()
    PlayTrackByIndex(CurrentTrackIndex == 0 and 1 or (CurrentTrackIndex - 1))
end

local function CycleSpeed()
    CurrentSpeedIndex = (CurrentSpeedIndex % #SpeedCycle) + 1
    local speed = SpeedCycle[CurrentSpeedIndex]
    AudioStream.PlaybackSpeed = speed
    if CurrentTrackIndex > 0 then
        OnTrackUpdated:Fire(Playlist[CurrentTrackIndex], IsAudioPlaying)
    end
end

--------------------------------------------------------------------------------
-- 4. WINDOW BASE FACTORY
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

    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Thickness = 1
    Stroke.Color = GetColor("Accent")
    Stroke.Transparency = 0.15
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    RegisterBinding(Stroke, "Color", "Accent")

    local TopBar = Instance.new("Frame", Frame)
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 22)
    TopBar.BackgroundColor3 = GetColor("BackgroundSecondary")
    TopBar.BackgroundTransparency = GetTransparency("BackgroundSecondary")
    TopBar.BorderSizePixel = 0
    TopBar.Active = true

    local TitleLabel = Instance.new("TextLabel", TopBar)
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 6, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.Text = title
    TitleLabel.TextColor3 = GetColor("TextPrimary")
    TitleLabel.TextSize = 11
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local Controls = Instance.new("Frame", TopBar)
    Controls.Name = "Controls"
    Controls.Size = UDim2.new(0, 48, 1, 0)
    Controls.Position = UDim2.new(1, -50, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.ZIndex = 40

    local Layout = Instance.new("UIListLayout", Controls)
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.Padding = UDim.new(0, 2)

    local MinBtn = Instance.new("TextButton", Controls)
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

    local MinStroke = Instance.new("UIStroke", MinBtn)
    MinStroke.Thickness = 1
    MinStroke.Color = GetColor("Border")

    local CloseBtn = Instance.new("TextButton", Controls)
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

    local CloseStroke = Instance.new("UIStroke", CloseBtn)
    CloseStroke.Thickness = 1
    CloseStroke.Color = GetColor("Border")

    local Content = Instance.new("Frame", Frame)
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, -22)
    Content.Position = UDim2.new(0, 0, 0, 22)
    Content.BackgroundTransparency = 1
    Content.ClipsDescendants = true

    local Grip = Instance.new("TextButton", Frame)
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

    local function BringToFront()
        TopZIndex += 1
        Frame.ZIndex = TopZIndex
    end

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            BringToFront()
        end
    end)

    local Dragging, DragStartMouse, DragStartPos = false, Vector2.zero, Vector2.zero
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStartMouse = Vector2.new(input.Position.X, input.Position.Y)
            DragStartPos = Vector2.new(Frame.AbsolutePosition.X, Frame.AbsolutePosition.Y)
            BringToFront()
        end
    end)

    local Resizing, ResizeStartMouse, ResizeStartSize = false, Vector2.zero, Vector2.zero
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
-- 5. CHAT OVERLAY (Top-Left)
--------------------------------------------------------------------------------
pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false) end)

local ChatWin = CreateWindow("Chat", UDim2.new(0, 310, 0, 180), UDim2.new(0, 15, 0, 15), Vector2.new(240, 140))

local ChatTopControls = Instance.new("Frame", ChatWin.TopBar)
ChatTopControls.Size = UDim2.new(0, 110, 1, 0)
ChatTopControls.Position = UDim2.new(0, 44, 0, 0)
ChatTopControls.BackgroundTransparency = 1

local WaveformBar = Instance.new("Frame", ChatTopControls)
WaveformBar.Size = UDim2.new(0, 32, 0, 10)
WaveformBar.Position = UDim2.new(0, 48, 0.5, -5)
WaveformBar.BackgroundColor3 = GetColor("Surface")
WaveformBar.BorderSizePixel = 0

local WaveFill = Instance.new("Frame", WaveformBar)
WaveFill.Size = UDim2.new(0.5, 0, 1, 0)
WaveFill.BackgroundColor3 = GetColor("Accent")
WaveFill.BorderSizePixel = 0
RegisterBinding(WaveFill, "BackgroundColor3", "Accent")

task.spawn(function()
    while true do
        task.wait(0.1)
        WaveFill.Size = UDim2.new(math.clamp(math.noise(tick() * 3, 0, 0) * 1.5, 0.15, 1.0), 0, 1, 0)
    end
end)

local MessageScroll = Instance.new("ScrollingFrame", ChatWin.Content)
MessageScroll.Size = UDim2.new(1, -10, 1, -30)
MessageScroll.Position = UDim2.new(0, 5, 0, 4)
MessageScroll.BackgroundTransparency = 1
MessageScroll.BorderSizePixel = 0
MessageScroll.ScrollBarThickness = 2
MessageScroll.ScrollBarImageColor3 = GetColor("Border")
MessageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
MessageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local MsgLayout = Instance.new("UIListLayout", MessageScroll)
MsgLayout.SortOrder = Enum.SortOrder.LayoutOrder
MsgLayout.Padding = UDim.new(0, 2)
MsgLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local function AddChatMessage(sender: string, text: string, isSelf: boolean)
    local hex = isSelf and "FF3CB4" or "55AAFF"
    local lbl = Instance.new("TextLabel", MessageScroll)
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

local ChatInputBar = Instance.new("Frame", ChatWin.Content)
ChatInputBar.Size = UDim2.new(1, -10, 0, 20)
ChatInputBar.Position = UDim2.new(0, 5, 1, -22)
ChatInputBar.BackgroundColor3 = GetColor("Surface")
ChatInputBar.BorderSizePixel = 0

local QuickBtn = Instance.new("TextButton", ChatInputBar)
QuickBtn.Size = UDim2.new(0, 40, 1, 0)
QuickBtn.BackgroundColor3 = GetColor("BackgroundSecondary")
QuickBtn.BorderSizePixel = 0
QuickBtn.Font = Enum.Font.Code
QuickBtn.Text = "Quick"
QuickBtn.TextColor3 = GetColor("TextSecondary")
QuickBtn.TextSize = 9

local ChatBox = Instance.new("TextBox", ChatInputBar)
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

local SendBtn = Instance.new("TextButton", ChatInputBar)
SendBtn.Size = UDim2.new(0, 40, 1, 0)
SendBtn.Position = UDim2.new(1, -40, 0, 0)
SendBtn.BackgroundColor3 = GetColor("Accent")
SendBtn.BorderSizePixel = 0
SendBtn.Font = Enum.Font.Code
SendBtn.Text = "Send"
SendBtn.TextColor3 = Color3.new(1, 1, 1)
SendBtn.TextSize = 9
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
-- 6. PLAYER LIST OVERLAY WITH CONTEXT POPUP CARD
--------------------------------------------------------------------------------
pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) end)

local PlrWin = CreateWindow("Players (0)", UDim2.new(0, 220, 0, 180), UDim2.new(1, -235, 0, 15), Vector2.new(180, 100))

-- Player Profile Popup Card (Appears directly next to the player list)
local ProfilePopup = Instance.new("Frame", ScreenHost)
ProfilePopup.Name = "Fih_PlayerProfilePopup"
ProfilePopup.Size = UDim2.new(0, 210, 0, 200)
ProfilePopup.Position = UDim2.new(1, -455, 0, 15)
ProfilePopup.BackgroundColor3 = GetColor("BackgroundPrimary")
ProfilePopup.BackgroundTransparency = 0.1
ProfilePopup.BorderSizePixel = 0
ProfilePopup.ZIndex = 80
ProfilePopup.Visible = false

local PopupStroke = Instance.new("UIStroke", ProfilePopup)
PopupStroke.Thickness = 1
PopupStroke.Color = GetColor("Accent")
RegisterBinding(PopupStroke, "Color", "Accent")

local PopupHeader = Instance.new("Frame", ProfilePopup)
PopupHeader.Size = UDim2.new(1, 0, 0, 20)
PopupHeader.BackgroundColor3 = GetColor("BackgroundSecondary")
PopupHeader.BorderSizePixel = 0
PopupHeader.ZIndex = 81

local PopupTitle = Instance.new("TextLabel", PopupHeader)
PopupTitle.Size = UDim2.new(1, -25, 1, 0)
PopupTitle.Position = UDim2.new(0, 6, 0, 0)
PopupTitle.BackgroundTransparency = 1
PopupTitle.Font = Enum.Font.Code
PopupTitle.Text = "Player Details"
PopupTitle.TextColor3 = GetColor("Accent")
PopupTitle.TextSize = 9
PopupTitle.TextXAlignment = Enum.TextXAlignment.Left
PopupTitle.ZIndex = 82
RegisterBinding(PopupTitle, "TextColor3", "Accent")

local PopupClose = Instance.new("TextButton", PopupHeader)
PopupClose.Size = UDim2.new(0, 16, 0, 14)
PopupClose.Position = UDim2.new(1, -18, 0.5, -7)
PopupClose.BackgroundColor3 = GetColor("Surface")
PopupClose.BorderSizePixel = 0
PopupClose.Font = Enum.Font.Code
PopupClose.Text = "✕"
PopupClose.TextColor3 = Color3.new(1, 1, 1)
PopupClose.TextSize = 9
PopupClose.ZIndex = 83
PopupClose.MouseButton1Click:Connect(function() ProfilePopup.Visible = false end)

local PopAvatar = Instance.new("ImageLabel", ProfilePopup)
PopAvatar.Size = UDim2.new(0, 36, 0, 36)
PopAvatar.Position = UDim2.new(0, 6, 0, 26)
PopAvatar.BackgroundColor3 = GetColor("Surface")
PopAvatar.BorderSizePixel = 0
PopAvatar.ZIndex = 81

local PopDName = Instance.new("TextLabel", ProfilePopup)
PopDName.Size = UDim2.new(1, -50, 0, 13)
PopDName.Position = UDim2.new(0, 46, 0, 25)
PopDName.BackgroundTransparency = 1
PopDName.Font = Enum.Font.Code
PopDName.Text = "DisplayName"
PopDName.TextColor3 = GetColor("TextPrimary")
PopDName.TextSize = 10
PopDName.TextXAlignment = Enum.TextXAlignment.Left
PopDName.ZIndex = 81

local PopUName = Instance.new("TextLabel", ProfilePopup)
PopUName.Size = UDim2.new(1, -50, 0, 12)
PopUName.Position = UDim2.new(0, 46, 0, 38)
PopUName.BackgroundTransparency = 1
PopUName.Font = Enum.Font.Code
PopUName.Text = "@Username"
PopUName.TextColor3 = GetColor("Accent")
PopUName.TextSize = 8
PopUName.TextXAlignment = Enum.TextXAlignment.Left
PopUName.ZIndex = 81
RegisterBinding(PopUName, "TextColor3", "Accent")

local PopInfo = Instance.new("TextLabel", ProfilePopup)
PopInfo.Size = UDim2.new(1, -50, 0, 12)
PopInfo.Position = UDim2.new(0, 46, 0, 50)
PopInfo.BackgroundTransparency = 1
PopInfo.Font = Enum.Font.Code
PopInfo.Text = "Age: 0d | ID: 0"
PopInfo.TextColor3 = GetColor("TextSecondary")
PopInfo.TextSize = 8
PopInfo.TextXAlignment = Enum.TextXAlignment.Left
PopInfo.ZIndex = 81

local ActionBtnList = Instance.new("Frame", ProfilePopup)
ActionBtnList.Size = UDim2.new(1, -12, 0, 125)
ActionBtnList.Position = UDim2.new(0, 6, 0, 68)
ActionBtnList.BackgroundTransparency = 1
ActionBtnList.ZIndex = 81

local ActionLayout = Instance.new("UIListLayout", ActionBtnList)
ActionLayout.SortOrder = Enum.SortOrder.LayoutOrder
ActionLayout.Padding = UDim.new(0, 3)

local ContextSelectedPlr: Player? = nil
local TargetDropdownLabel = nil
local UpdateTrollDropdownDisplay = function() end

local function CreateActionBtn(txt: string, onClick: () -> ())
    local b = Instance.new("TextButton", ActionBtnList)
    b.Size = UDim2.new(1, 0, 0, 20)
    b.BackgroundColor3 = GetColor("Surface")
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Code
    b.Text = txt
    b.TextColor3 = GetColor("TextPrimary")
    b.TextSize = 8
    b.ZIndex = 82
    b.MouseButton1Click:Connect(onClick)
end

CreateActionBtn("🎯 Set As Troll Target", function()
    if ContextSelectedPlr then
        State.SelectedTarget = ContextSelectedPlr
        UpdateTrollDropdownDisplay()
        ProfilePopup.Visible = false
    end
end)

CreateActionBtn("⚡ Teleport To Player", function()
    if ContextSelectedPlr and ContextSelectedPlr.Character then
        local tRoot = GetRoot(ContextSelectedPlr.Character)
        local myRoot = GetRoot()
        if tRoot and myRoot then myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 2, 0) end
    end
end)

CreateActionBtn("👁 Spectate Player", function()
    if ContextSelectedPlr and ContextSelectedPlr.Character then
        local hum = GetHumanoid(ContextSelectedPlr.Character)
        if hum then Camera.CameraSubject = hum end
    end
end)

CreateActionBtn("👥 Send Friend Request", function()
    if ContextSelectedPlr then
        pcall(function() StarterGui:SetCore("PromptSendFriendRequest", ContextSelectedPlr) end)
    end
end)

CreateActionBtn("👕 Inspect Roblox Avatar", function()
    if ContextSelectedPlr then
        pcall(function() GuiService:InspectPlayerFromUserId(ContextSelectedPlr.UserId) end)
    end
end)

local function OpenPlayerPopup(plr: Player, rowBtn: TextButton)
    ContextSelectedPlr = plr
    PopDName.Text = plr.DisplayName
    PopUName.Text = "@" .. plr.Name
    PopInfo.Text = "Age: " .. tostring(plr.AccountAge) .. "d | ID: " .. tostring(plr.UserId)
    PopAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(plr.UserId) .. "&w=100&h=100"

    local rowPos = rowBtn.AbsolutePosition
    local vp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local targetX = math.clamp(PlrWin.Frame.AbsolutePosition.X - 215, 5, vp.X - 220)
    local targetY = math.clamp(rowPos.Y - 10, 5, vp.Y - 210)

    ProfilePopup.Position = UDim2.new(0, targetX, 0, targetY)
    ProfilePopup.Visible = true
end

local PlrScroll = Instance.new("ScrollingFrame", PlrWin.Content)
PlrScroll.Size = UDim2.new(1, -8, 1, -8)
PlrScroll.Position = UDim2.new(0, 4, 0, 4)
PlrScroll.BackgroundTransparency = 1
PlrScroll.BorderSizePixel = 0
PlrScroll.ScrollBarThickness = 2
PlrScroll.ScrollBarImageColor3 = GetColor("Border")
PlrScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local PlrLayout = Instance.new("UIListLayout", PlrScroll)
PlrLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlrLayout.Padding = UDim.new(0, 2)

local function RefreshPlayerList()
    local all = Players:GetPlayers()
    PlrWin.TitleLabel.Text = string.format("Players (%d)", #all)

    local targetH = math.clamp(28 + (#all * 26), 90, 520)
    TweenService:Create(PlrWin.Frame, TweenInfo.new(0.20, Enum.EasingStyle.Quad), { Size = UDim2.new(0, PlrWin.Frame.AbsoluteSize.X, 0, targetH) }):Play()

    for _, c in ipairs(PlrScroll:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end

    for _, plr in ipairs(all) do
        local row = Instance.new("TextButton", PlrScroll)
        row.Size = UDim2.new(1, 0, 0, 24)
        row.BackgroundColor3 = GetColor("Surface")
        row.BackgroundTransparency = 0.3
        row.BorderSizePixel = 0
        row.AutoButtonColor = false
        row.Text = ""

        local mugshot = Instance.new("ImageLabel", row)
        mugshot.Size = UDim2.new(0, 18, 0, 18)
        mugshot.Position = UDim2.new(0, 3, 0.5, -9)
        mugshot.BackgroundColor3 = GetColor("BackgroundSecondary")
        mugshot.BorderSizePixel = 0
        mugshot.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(plr.UserId) .. "&w=100&h=100"

        local nameLbl = Instance.new("TextLabel", row)
        nameLbl.Size = UDim2.new(1, -26, 1, 0)
        nameLbl.Position = UDim2.new(0, 24, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.Code
        nameLbl.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
        nameLbl.TextColor3 = GetColor("TextPrimary")
        nameLbl.TextSize = 9
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left

        row.MouseButton1Click:Connect(function()
            OpenPlayerPopup(plr, row)
        end)
    end
end

RefreshPlayerList()
Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)

--------------------------------------------------------------------------------
-- 7. MUSIC HUD (Bottom-Left)
--------------------------------------------------------------------------------
local MusicWin = CreateWindow("Fih HUD :: Now Playing & Synced Lyrics", UDim2.new(0, 320, 0, 130), UDim2.new(0, 15, 1, -145), Vector2.new(280, 110))

local CoverArt = Instance.new("ImageLabel", MusicWin.Content)
CoverArt.Size = UDim2.new(0, 80, 1, -10)
CoverArt.Position = UDim2.new(0, 5, 0, 5)
CoverArt.BackgroundColor3 = GetColor("Surface")
CoverArt.BorderSizePixel = 0
CoverArt.Image = ""

local CoverPlaceholder = Instance.new("TextLabel", CoverArt)
CoverPlaceholder.Size = UDim2.new(1, 0, 1, 0)
CoverPlaceholder.BackgroundTransparency = 1
CoverPlaceholder.Font = Enum.Font.Code
CoverPlaceholder.Text = "NO AUDIO\nACTIVE"
CoverPlaceholder.TextColor3 = GetColor("TextSecondary")
CoverPlaceholder.TextSize = 9

local SongDetails = Instance.new("Frame", MusicWin.Content)
SongDetails.Size = UDim2.new(1, -95, 1, -10)
SongDetails.Position = UDim2.new(0, 90, 0, 5)
SongDetails.BackgroundTransparency = 1

local SongTitleLabel = Instance.new("TextLabel", SongDetails)
SongTitleLabel.Size = UDim2.new(1, 0, 0, 14)
SongTitleLabel.BackgroundTransparency = 1
SongTitleLabel.Font = Enum.Font.Code
SongTitleLabel.Text = "None Playing"
SongTitleLabel.TextColor3 = GetColor("Accent")
SongTitleLabel.TextSize = 9
SongTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
RegisterBinding(SongTitleLabel, "TextColor3", "Accent")

local ArtistLabel = Instance.new("TextLabel", SongDetails)
ArtistLabel.Size = UDim2.new(1, 0, 0, 12)
ArtistLabel.Position = UDim2.new(0, 0, 0, 14)
ArtistLabel.BackgroundTransparency = 1
ArtistLabel.Font = Enum.Font.Code
ArtistLabel.Text = "[Idle]"
ArtistLabel.TextColor3 = Color3.fromRGB(85, 170, 255)
ArtistLabel.TextSize = 8
ArtistLabel.TextXAlignment = Enum.TextXAlignment.Left

local LyricsLabel = Instance.new("TextLabel", SongDetails)
LyricsLabel.Size = UDim2.new(1, 0, 0, 14)
LyricsLabel.Position = UDim2.new(0, 0, 0, 28)
LyricsLabel.BackgroundTransparency = 1
LyricsLabel.Font = Enum.Font.Code
LyricsLabel.Text = "No lyrics available"
LyricsLabel.TextColor3 = GetColor("TextSecondary")
LyricsLabel.TextSize = 8
LyricsLabel.TextXAlignment = Enum.TextXAlignment.Left

local ControlsBar = Instance.new("Frame", SongDetails)
ControlsBar.Size = UDim2.new(1, 0, 0, 16)
ControlsBar.Position = UDim2.new(0, 0, 0, 44)
ControlsBar.BackgroundTransparency = 1

local ControlsLayout = Instance.new("UIListLayout", ControlsBar)
ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
ControlsLayout.Padding = UDim.new(0, 4)

local function CreateAudioBtn(txt: string, w: number, onClick: () -> ())
    local b = Instance.new("TextButton", ControlsBar)
    b.Size = UDim2.new(0, w, 1, 0)
    b.BackgroundColor3 = GetColor("Surface")
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Code
    b.Text = txt
    b.TextColor3 = GetColor("TextPrimary")
    b.TextSize = 8
    b.MouseButton1Click:Connect(onClick)
    return b
end

local PrevBtn = CreateAudioBtn("[|<]", 22, PrevTrack)
local PlayBtn = CreateAudioBtn("[▶]", 22, TogglePlayPause)
local NextBtn = CreateAudioBtn("[>|]", 22, NextTrack)
local SpeedBtn = CreateAudioBtn("SPD: 1x", 48, CycleSpeed)

local VisualizerFrame = Instance.new("Frame", SongDetails)
VisualizerFrame.Size = UDim2.new(1, 0, 0, 22)
VisualizerFrame.Position = UDim2.new(0, 0, 1, -22)
VisualizerFrame.BackgroundColor3 = GetColor("BackgroundSecondary")
VisualizerFrame.BorderSizePixel = 0
VisualizerFrame.ClipsDescendants = true

local VisLayout = Instance.new("UIListLayout", VisualizerFrame)
VisLayout.FillDirection = Enum.FillDirection.Horizontal
VisLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
VisLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
VisLayout.Padding = UDim.new(0, 2)

local VisualizerBars = {}
for i = 1, 16 do
    local bar = Instance.new("Frame", VisualizerFrame)
    bar.Size = UDim2.new(0, 7, 0, 3)
    bar.BackgroundColor3 = GetColor("Accent")
    bar.BorderSizePixel = 0
    RegisterBinding(bar, "BackgroundColor3", "Accent")
    table.insert(VisualizerBars, bar)
end

OnTrackUpdated.Event:Connect(function(track, isPlaying)
    if track then
        CoverArt.Image = track.Cover or ""
        CoverPlaceholder.Visible = (track.Cover == nil or track.Cover == "")
        SongTitleLabel.Text = track.Title
        ArtistLabel.Text = track.Artist
        LyricsLabel.Text = track.Lyric
        PlayBtn.Text = isPlaying and "[||]" or "[▶]"
        SpeedBtn.Text = "SPD: " .. tostring(SpeedCycle[CurrentSpeedIndex]) .. "x"
    else
        CoverArt.Image = ""
        CoverPlaceholder.Visible = true
        SongTitleLabel.Text = "None Playing"
        ArtistLabel.Text = "[Idle]"
        LyricsLabel.Text = "No lyrics available"
        PlayBtn.Text = "[▶]"
    end
end)

task.spawn(function()
    while true do
        task.wait(0.08)
        local t = tick()
        for idx, bar in ipairs(VisualizerBars) do
            if IsAudioPlaying then
                local noiseVal = math.noise(idx * 0.35, t * 4, 0)
                bar.Size = UDim2.new(0, 7, 0, math.clamp(math.abs(noiseVal) * 20, 3, 20))
            else
                bar.Size = UDim2.new(0, 7, 0, 3)
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- 8. MAIN HUB WINDOW (Hero on Main Only, Unified Scroll, Toggle Drawers)
--------------------------------------------------------------------------------
local MainWin = CreateWindow("Fih Ui", UDim2.new(0, 580, 0, 360), UDim2.new(0.5, -290, 0.5, -180), Vector2.new(480, 280))

-- Left Nav Rail
local NavRail = Instance.new("Frame", MainWin.Content)
NavRail.Size = UDim2.new(0, 85, 1, -8)
NavRail.Position = UDim2.new(0, 4, 0, 4)
NavRail.BackgroundColor3 = GetColor("BackgroundSecondary")
NavRail.BorderSizePixel = 0

local NavRailStroke = Instance.new("UIStroke", NavRail)
NavRailStroke.Thickness = 1
NavRailStroke.Color = GetColor("Border")

local NavTopList = Instance.new("Frame", NavRail)
NavTopList.Size = UDim2.new(1, 0, 1, -26)
NavTopList.BackgroundTransparency = 1

local NavLayout = Instance.new("UIListLayout", NavTopList)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Padding = UDim.new(0, 3)

local NavPad = Instance.new("UIPadding", NavTopList)
NavPad.PaddingTop = UDim.new(0, 4)
NavPad.PaddingLeft = UDim.new(0, 4)
NavPad.PaddingRight = UDim.new(0, 4)

local NavBottomSection = Instance.new("Frame", NavRail)
NavBottomSection.Size = UDim2.new(1, -8, 0, 20)
NavBottomSection.Position = UDim2.new(0, 4, 1, -22)
NavBottomSection.BackgroundTransparency = 1

-- Right Content Area
local RightContent = Instance.new("Frame", MainWin.Content)
RightContent.Size = UDim2.new(1, -98, 1, -8)
RightContent.Position = UDim2.new(0, 93, 0, 4)
RightContent.BackgroundTransparency = 1
RightContent.ClipsDescendants = true

-- Sub-Header (Inside Right Tab Content)
local SubHeader = Instance.new("Frame", RightContent)
SubHeader.Size = UDim2.new(1, 0, 0, 20)
SubHeader.BackgroundTransparency = 1

local TabTag = Instance.new("Frame", SubHeader)
TabTag.Size = UDim2.new(0, 65, 1, 0)
TabTag.BackgroundColor3 = GetColor("Surface")
TabTag.BorderSizePixel = 0

local TabTagStroke = Instance.new("UIStroke", TabTag)
TabTagStroke.Thickness = 1
TabTagStroke.Color = GetColor("Accent")
RegisterBinding(TabTagStroke, "Color", "Accent")

local TabTagLabel = Instance.new("TextLabel", TabTag)
TabTagLabel.Size = UDim2.new(1, 0, 1, 0)
TabTagLabel.BackgroundTransparency = 1
TabTagLabel.Font = Enum.Font.Code
TabTagLabel.Text = "Main"
TabTagLabel.TextColor3 = GetColor("Accent")
TabTagLabel.TextSize = 10
RegisterBinding(TabTagLabel, "TextColor3", "Accent")

local SubHeaderRight = Instance.new("Frame", SubHeader)
SubHeaderRight.Size = UDim2.new(0, 150, 1, 0)
SubHeaderRight.Position = UDim2.new(1, -150, 0, 0)
SubHeaderRight.BackgroundTransparency = 1

local SubLayout = Instance.new("UIListLayout", SubHeaderRight)
SubLayout.FillDirection = Enum.FillDirection.Horizontal
SubLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
SubLayout.Padding = UDim.new(0, 4)

-- Tab Container
local TabContainer = Instance.new("Frame", RightContent)
TabContainer.Size = UDim2.new(1, 0, 1, -24)
TabContainer.Position = UDim2.new(0, 0, 0, 24)
TabContainer.BackgroundTransparency = 1
TabContainer.ClipsDescendants = true

-- Drawer Overlay (Slides Top-to-Bottom inside Tab)
local DrawerOverlay = Instance.new("Frame", TabContainer)
DrawerOverlay.Size = UDim2.new(1, 0, 1, 0)
DrawerOverlay.Position = UDim2.new(0, 0, -1, 0)
DrawerOverlay.BackgroundColor3 = GetColor("BackgroundPrimary")
DrawerOverlay.BackgroundTransparency = 0.05
DrawerOverlay.BorderSizePixel = 0
DrawerOverlay.ZIndex = 50
DrawerOverlay.Visible = false

local DrawerStroke = Instance.new("UIStroke", DrawerOverlay)
DrawerStroke.Thickness = 1
DrawerStroke.Color = GetColor("Accent")
RegisterBinding(DrawerStroke, "Color", "Accent")

local DrawerHeader = Instance.new("Frame", DrawerOverlay)
DrawerHeader.Size = UDim2.new(1, 0, 0, 22)
DrawerHeader.BackgroundColor3 = GetColor("BackgroundSecondary")
DrawerHeader.BorderSizePixel = 0
DrawerHeader.ZIndex = 51

local DrawerTitle = Instance.new("TextLabel", DrawerHeader)
DrawerTitle.Size = UDim2.new(1, -30, 1, 0)
DrawerTitle.Position = UDim2.new(0, 6, 0, 0)
DrawerTitle.BackgroundTransparency = 1
DrawerTitle.Font = Enum.Font.Code
DrawerTitle.Text = "SETTINGS"
DrawerTitle.TextColor3 = GetColor("Accent")
DrawerTitle.TextSize = 10
DrawerTitle.TextXAlignment = Enum.TextXAlignment.Left
DrawerTitle.ZIndex = 52
RegisterBinding(DrawerTitle, "TextColor3", "Accent")

local DrawerClose = Instance.new("TextButton", DrawerHeader)
DrawerClose.Size = UDim2.new(0, 18, 0, 16)
DrawerClose.Position = UDim2.new(1, -22, 0.5, -8)
DrawerClose.BackgroundColor3 = GetColor("Surface")
DrawerClose.BorderSizePixel = 0
DrawerClose.Font = Enum.Font.Code
DrawerClose.Text = "✕"
DrawerClose.TextColor3 = Color3.new(1, 1, 1)
DrawerClose.TextSize = 10
DrawerClose.ZIndex = 53

local DrawerScroll = Instance.new("ScrollingFrame", DrawerOverlay)
DrawerScroll.Size = UDim2.new(1, -8, 1, -26)
DrawerScroll.Position = UDim2.new(0, 4, 0, 24)
DrawerScroll.BackgroundTransparency = 1
DrawerScroll.BorderSizePixel = 0
DrawerScroll.ScrollBarThickness = 2
DrawerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
DrawerScroll.ZIndex = 51

local DrawerLayout = Instance.new("UIListLayout", DrawerScroll)
DrawerLayout.SortOrder = Enum.SortOrder.LayoutOrder
DrawerLayout.Padding = UDim.new(0, 4)

local CurrentOpenDrawer = ""
local function CloseDrawer()
    CurrentOpenDrawer = ""
    local tw = TweenService:Create(DrawerOverlay, TweenInfo.new(0.20, Enum.EasingStyle.Quad), { Position = UDim2.new(0, 0, -1, 0) })
    tw:Play()
    tw.Completed:Connect(function() DrawerOverlay.Visible = false end)
end

local function OpenDrawer(mode: string, title: string, buildFn: (Instance) -> ())
    if CurrentOpenDrawer == mode and DrawerOverlay.Visible then
        CloseDrawer()
        return
    end

    CurrentOpenDrawer = mode
    DrawerTitle.Text = string.upper(title)
    for _, ch in ipairs(DrawerScroll:GetChildren()) do
        if ch:IsA("GuiObject") then ch:Destroy() end
    end
    buildFn(DrawerScroll)

    DrawerOverlay.Visible = true
    DrawerOverlay.Position = UDim2.new(0, 0, -1, 0)
    TweenService:Create(DrawerOverlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Position = UDim2.new(0, 0, 0, 0) }):Play()
end

DrawerClose.MouseButton1Click:Connect(CloseDrawer)

local function CreateSubBtn(txt: string, onClick: () -> ())
    local b = Instance.new("TextButton", SubHeaderRight)
    b.Size = UDim2.new(0, 70, 1, 0)
    b.BackgroundColor3 = GetColor("Surface")
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Code
    b.Text = txt
    b.TextColor3 = GetColor("TextPrimary")
    b.TextSize = 9
    b.MouseButton1Click:Connect(onClick)
end

CreateSubBtn("Keybinds", function()
    OpenDrawer("KEYBINDS", "HOTKEYS & SHORTCUTS", function(p)
        local c = Instance.new("TextLabel", p)
        c.Size = UDim2.new(1, 0, 0, 60)
        c.BackgroundTransparency = 1
        c.Font = Enum.Font.Code
        c.Text = "RightControl : Toggle GUI\nF : Toggle Flight Mode\nN : Toggle Stepped Noclip\nCtrl + Click : Raycast Teleport\nT : Quick Menu Reopen"
        c.TextColor3 = GetColor("TextPrimary")
        c.TextSize = 9
        c.ZIndex = 52
    end)
end)

CreateSubBtn("Settings", function()
    OpenDrawer("SETTINGS", "GLOBAL CONFIGURATION", function(p)
        local c = Instance.new("TextLabel", p)
        c.Size = UDim2.new(1, 0, 0, 40)
        c.BackgroundTransparency = 1
        c.Font = Enum.Font.Code
        c.Text = "Translucent Glass Rendering: Active\nHardware Acceleration: Enabled\nAuto-Save Config: Enabled"
        c.TextColor3 = GetColor("TextPrimary")
        c.TextSize = 9
        c.ZIndex = 52
    end)
end)

-- Tab Builder
local TabPages = {}
local TabButtons = {}
local CurrentTab = ""

local function CreateTabPage(name: string, hasHeroBanner: boolean)
    local Page = Instance.new("Frame", TabContainer)
    Page.Name = "Page_" .. name
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false

    local topOffset = 0
    if hasHeroBanner then
        local HeroBanner = Instance.new("Frame", Page)
        HeroBanner.Size = UDim2.new(1, 0, 0, 36)
        HeroBanner.BackgroundColor3 = GetColor("Surface")
        HeroBanner.BackgroundTransparency = 0.4
        HeroBanner.BorderSizePixel = 0

        local HeroTitle = Instance.new("TextLabel", HeroBanner)
        HeroTitle.Size = UDim2.new(1, 0, 0, 18)
        HeroTitle.BackgroundTransparency = 1
        HeroTitle.Font = Enum.Font.Code
        HeroTitle.Text = "Fih Ui"
        HeroTitle.TextColor3 = GetColor("TextPrimary")
        HeroTitle.TextSize = 13

        local HeroSub = Instance.new("TextLabel", HeroBanner)
        HeroSub.Size = UDim2.new(1, 0, 0, 14)
        HeroSub.Position = UDim2.new(0, 0, 0, 18)
        HeroSub.BackgroundTransparency = 1
        HeroSub.Font = Enum.Font.Code
        HeroSub.Text = "Windows XP / 207 Modular Engine | T to Toggle"
        HeroSub.TextColor3 = GetColor("TextSecondary")
        HeroSub.TextSize = 8

        topOffset = 38
    end

    local MainScroll = Instance.new("ScrollingFrame", Page)
    MainScroll.Name = "MainScroll"
    MainScroll.Size = UDim2.new(1, 0, 1, -topOffset)
    MainScroll.Position = UDim2.new(0, 0, 0, topOffset)
    MainScroll.BackgroundTransparency = 1
    MainScroll.BorderSizePixel = 0
    MainScroll.ScrollBarThickness = 2
    MainScroll.ScrollBarImageColor3 = GetColor("Border")
    MainScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    MainScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    local ColumnsContainer = Instance.new("Frame", MainScroll)
    ColumnsContainer.Size = UDim2.new(1, -4, 0, 0)
    ColumnsContainer.Position = UDim2.new(0, 0, 0, 0)
    ColumnsContainer.AutomaticSize = Enum.AutomaticSize.Y
    ColumnsContainer.BackgroundTransparency = 1

    local LeftCol = Instance.new("Frame", ColumnsContainer)
    LeftCol.Name = "LeftCol"
    LeftCol.Size = UDim2.new(0.5, -3, 0, 0)
    LeftCol.Position = UDim2.new(0, 0, 0, 0)
    LeftCol.AutomaticSize = Enum.AutomaticSize.Y
    LeftCol.BackgroundTransparency = 1

    local LeftLayout = Instance.new("UIListLayout", LeftCol)
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LeftLayout.Padding = UDim.new(0, 4)

    local RightCol = Instance.new("Frame", ColumnsContainer)
    RightCol.Name = "RightCol"
    RightCol.Size = UDim2.new(0.5, -3, 0, 0)
    RightCol.Position = UDim2.new(0.5, 3, 0, 0)
    RightCol.AutomaticSize = Enum.AutomaticSize.Y
    RightCol.BackgroundTransparency = 1

    local RightLayout = Instance.new("UIListLayout", RightCol)
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Padding = UDim.new(0, 4)

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

local function RegisterTab(name: string, isBottom: boolean?, hasHeroBanner: boolean?)
    local parent = isBottom and NavBottomSection or NavTopList
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 20)
    btn.BackgroundColor3 = GetColor("BackgroundSecondary")
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Code
    btn.Text = name
    btn.TextColor3 = GetColor("TextSecondary")
    btn.TextSize = 9
    btn.AutoButtonColor = false

    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    TabButtons[name] = btn
    CreateTabPage(name, hasHeroBanner or false)
end

local function CreateCard(parent: Instance, title: string)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = GetColor("Surface")
    card.BackgroundTransparency = 0.35
    card.BorderSizePixel = 0

    local header = Instance.new("Frame", card)
    header.Size = UDim2.new(1, 0, 0, 18)
    header.BackgroundColor3 = GetColor("BackgroundSecondary")
    header.BorderSizePixel = 0

    local lbl = Instance.new("TextLabel", header)
    lbl.Size = UDim2.new(1, -8, 1, 0)
    lbl.Position = UDim2.new(0, 4, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.Text = title
    lbl.TextColor3 = GetColor("Accent")
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    RegisterBinding(lbl, "TextColor3", "Accent")

    local items = Instance.new("Frame", card)
    items.Size = UDim2.new(1, -8, 0, 0)
    items.Position = UDim2.new(0, 4, 0, 20)
    items.AutomaticSize = Enum.AutomaticSize.Y
    items.BackgroundTransparency = 1

    local l = Instance.new("UIListLayout", items)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, 3)

    local pad = Instance.new("UIPadding", items)
    pad.PaddingBottom = UDim.new(0, 4)

    return items
end

local function AddToggle(parent: Instance, label: string, default: boolean, cb: (boolean) -> ())
    local state = default
    local row = Instance.new("TextButton", parent)
    row.Size = UDim2.new(1, 0, 0, 18)
    row.BackgroundColor3 = GetColor("BackgroundSecondary")
    row.BackgroundTransparency = 0.4
    row.BorderSizePixel = 0
    row.AutoButtonColor = false
    row.Text = ""

    local tLbl = Instance.new("TextLabel", row)
    tLbl.Size = UDim2.new(1, -22, 1, 0)
    tLbl.Position = UDim2.new(0, 4, 0, 0)
    tLbl.BackgroundTransparency = 1
    tLbl.Font = Enum.Font.Code
    tLbl.Text = label
    tLbl.TextColor3 = GetColor("TextPrimary")
    tLbl.TextSize = 8
    tLbl.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("Frame", row)
    box.Size = UDim2.new(0, 11, 0, 11)
    box.Position = UDim2.new(1, -14, 0.5, -5)
    box.BackgroundColor3 = state and GetColor("Accent") or GetColor("Surface")
    box.BorderSizePixel = 0
    RegisterBinding(box, "BackgroundColor3", state and "Accent" or "Surface")

    local check = Instance.new("TextLabel", box)
    check.Size = UDim2.new(1, 0, 1, 0)
    check.BackgroundTransparency = 1
    check.Font = Enum.Font.Code
    check.Text = state and "✓" or ""
    check.TextColor3 = Color3.new(1, 1, 1)
    check.TextSize = 8

    row.MouseButton1Click:Connect(function()
        state = not state
        box.BackgroundColor3 = state and GetColor("Accent") or GetColor("Surface")
        check.Text = state and "✓" or ""
        cb(state)
    end)
end

local function AddSlider(parent: Instance, label: string, min: number, max: number, default: number, cb: (number) -> ())
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, 0, 0, 24)
    frame.BackgroundColor3 = GetColor("BackgroundSecondary")
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0

    local tLbl = Instance.new("TextLabel", frame)
    tLbl.Size = UDim2.new(1, -30, 0, 10)
    tLbl.Position = UDim2.new(0, 4, 0, 2)
    tLbl.BackgroundTransparency = 1
    tLbl.Font = Enum.Font.Code
    tLbl.Text = label
    tLbl.TextColor3 = GetColor("TextPrimary")
    tLbl.TextSize = 8
    tLbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", frame)
    valLbl.Size = UDim2.new(0, 26, 0, 10)
    valLbl.Position = UDim2.new(1, -28, 0, 2)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.Code
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = GetColor("Accent")
    valLbl.TextSize = 8
    RegisterBinding(valLbl, "TextColor3", "Accent")

    local bar = Instance.new("TextButton", frame)
    bar.Size = UDim2.new(1, -8, 0, 5)
    bar.Position = UDim2.new(0, 4, 0, 14)
    bar.BackgroundColor3 = GetColor("Surface")
    bar.BorderSizePixel = 0
    bar.Text = ""
    bar.AutoButtonColor = false

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = GetColor("Accent")
    fill.BorderSizePixel = 0
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
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 18)
    btn.BackgroundColor3 = GetColor("BackgroundSecondary")
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Code
    btn.Text = label
    btn.TextColor3 = GetColor("TextPrimary")
    btn.TextSize = 8
    btn.MouseButton1Click:Connect(onClick)
end

--------------------------------------------------------------------------------
-- 9. TAB REGISTRATION & RICH CONTENT
--------------------------------------------------------------------------------
RegisterTab("Main", false, true)
RegisterTab("Esp", false, false)
RegisterTab("Music", false, false)
RegisterTab("Troll", false, false)
RegisterTab("Scripts", false, false)
RegisterTab("Themes", true, false)

----------------------------------------------------------------------------
-- TAB 1: MAIN
----------------------------------------------------------------------------
local mMove = CreateCard(TabPages["Main"].Left, "[Movement & Physics]")
AddToggle(mMove, "Infinite Jump", false, function(s) State.InfiniteJump = s end)
AddToggle(mMove, "Flight", false, function(s) ToggleFlight(s) end)
AddSlider(mMove, "Flight Speed", 16, 250, 55, function(v) State.FlySpeed = v end)
AddToggle(mMove, "Noclip", false, function(s) State.Noclip = s end)
AddToggle(mMove, "Click TP (Ctrl + Click)", false, function(s) State.ClickTP = s end)
AddToggle(mMove, "Stepped Floater", false, function(s) ToggleFloater(s) end)
AddButton(mMove, "[ Force Respawn ]", function() if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end end)

local mStats = CreateCard(TabPages["Main"].Right, "[Stat Modifications]")
AddToggle(mStats, "Enable Custom Walk Speed", false, function(s) end)
AddSlider(mStats, "Walk Speed", 16, 250, 16, function(v)
    local hum = GetHumanoid()
    if hum then hum.WalkSpeed = v end
end)
AddToggle(mStats, "Enable Custom Jump", false, function(s) end)
AddSlider(mStats, "Jump Height / Power", 50, 350, 50, function(v)
    local hum = GetHumanoid()
    if hum then hum.UseJumpPower = true; hum.JumpPower = v end
end)

local mWorld = CreateCard(TabPages["Main"].Right, "[World Modifiers]")
AddSlider(mWorld, "Gravity", 0, 400, 196, function(v) Workspace.Gravity = v end)
AddToggle(mWorld, "Anti-Aim (Spin BOT)", false, function(s) State.Spinbot = s end)

local mCam = CreateCard(TabPages["Main"].Right, "[Camera & Fov]")
AddSlider(mCam, "Fov", 60, 120, 70, function(v) Camera.FieldOfView = v end)
AddToggle(mCam, "Full Bright", false, function(s) ToggleFullbright(s) end)

----------------------------------------------------------------------------
-- TAB 2: ESP (Visuals)
----------------------------------------------------------------------------
local eLeft = CreateCard(TabPages["Esp"].Left, "[Player ESP]")
AddToggle(eLeft, "2D Box ESP", false, function(s) UpdateBoxESP(s) end)
AddToggle(eLeft, "Name & Distance Tags", false, function(s) UpdateNameESP(s) end)
AddToggle(eLeft, "Chams Highlights", false, function(s) UpdateHighlights(s) end)

local eRight = CreateCard(TabPages["Esp"].Right, "[World Lighting]")
AddToggle(eRight, "Full Bright Daylight", false, function(s) ToggleFullbright(s) end)
AddSlider(eRight, "Camera FOV", 60, 120, 70, function(v) Camera.FieldOfView = v end)
AddButton(eRight, "Remove Fog", function() Lighting.FogEnd = 100000 end)

----------------------------------------------------------------------------
-- TAB 3: MUSIC
----------------------------------------------------------------------------
local muLeft = CreateCard(TabPages["Music"].Left, "[Audio Streamer]")
AddToggle(muLeft, "Stream Play / Pause", false, function(s) TogglePlayPause() end)
AddSlider(muLeft, "Stream Volume", 0, 10, 1, function(v) AudioStream.Volume = v end)

local muPresets = CreateCard(TabPages["Music"].Left, "[Playlist Presets]")
for idx, p in ipairs(Playlist) do
    AddButton(muPresets, p.Title, function() PlayTrackByIndex(idx) end)
end

local muRight = CreateCard(TabPages["Music"].Right, "[Overlay Toggles]")
AddToggle(muRight, "Music HUD Visible", true, function(s) MusicWin.Frame.Visible = s end)
AddToggle(muRight, "Chat Overlay Visible", true, function(s) ChatWin.Frame.Visible = s end)
AddToggle(muRight, "Player List Visible", true, function(s) PlrWin.Frame.Visible = s end)

----------------------------------------------------------------------------
-- TAB 4: TROLL (Player Dropdown Selector & Cycling Arrows)
----------------------------------------------------------------------------
local tLeft = CreateCard(TabPages["Troll"].Left, "[Target Player]")

-- Interactive Player Selector Row (< [ Dropdown ] >)
local TargetSelRow = Instance.new("Frame", tLeft)
TargetSelRow.Size = UDim2.new(1, 0, 0, 22)
TargetSelRow.BackgroundColor3 = GetColor("BackgroundSecondary")
TargetSelRow.BorderSizePixel = 0

local PrevPlrBtn = Instance.new("TextButton", TargetSelRow)
PrevPlrBtn.Size = UDim2.new(0, 20, 1, 0)
PrevPlrBtn.BackgroundColor3 = GetColor("Surface")
PrevPlrBtn.BorderSizePixel = 0
PrevPlrBtn.Font = Enum.Font.Code
PrevPlrBtn.Text = "<"
PrevPlrBtn.TextColor3 = GetColor("TextPrimary")
PrevPlrBtn.TextSize = 9

local DropTriggerBtn = Instance.new("TextButton", TargetSelRow)
DropTriggerBtn.Size = UDim2.new(1, -44, 1, 0)
DropTriggerBtn.Position = UDim2.new(0, 22, 0, 0)
DropTriggerBtn.BackgroundColor3 = GetColor("Surface")
DropTriggerBtn.BorderSizePixel = 0
DropTriggerBtn.Font = Enum.Font.Code
DropTriggerBtn.Text = "▼ [ Closest Player ]"
DropTriggerBtn.TextColor3 = GetColor("Accent")
DropTriggerBtn.TextSize = 8
DropTriggerBtn.TextTruncate = Enum.TextTruncate.AtEnd
RegisterBinding(DropTriggerBtn, "TextColor3", "Accent")

local NextPlrBtn = Instance.new("TextButton", TargetSelRow)
NextPlrBtn.Size = UDim2.new(0, 20, 1, 0)
NextPlrBtn.Position = UDim2.new(1, -20, 0, 0)
NextPlrBtn.BackgroundColor3 = GetColor("Surface")
NextPlrBtn.BorderSizePixel = 0
NextPlrBtn.Font = Enum.Font.Code
NextPlrBtn.Text = ">"
NextPlrBtn.TextColor3 = GetColor("TextPrimary")
NextPlrBtn.TextSize = 9

local DropdownMenu = Instance.new("Frame", ScreenHost)
DropdownMenu.Name = "Fih_TrollDropdownMenu"
DropdownMenu.Size = UDim2.new(0, 180, 0, 120)
DropdownMenu.BackgroundColor3 = GetColor("BackgroundPrimary")
DropdownMenu.BorderSizePixel = 0
DropdownMenu.ZIndex = 90
DropdownMenu.Visible = false

local DropStroke = Instance.new("UIStroke", DropdownMenu)
DropStroke.Thickness = 1
DropStroke.Color = GetColor("Accent")
RegisterBinding(DropStroke, "Color", "Accent")

local DropScroll = Instance.new("ScrollingFrame", DropdownMenu)
DropScroll.Size = UDim2.new(1, -4, 1, -4)
DropScroll.Position = UDim2.new(0, 2, 0, 2)
DropScroll.BackgroundTransparency = 1
DropScroll.BorderSizePixel = 0
DropScroll.ScrollBarThickness = 2
DropScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
DropScroll.ZIndex = 91

local DropLayout = Instance.new("UIListLayout", DropScroll)
DropLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropLayout.Padding = UDim.new(0, 2)

UpdateTrollDropdownDisplay = function()
    if State.SelectedTarget then
        DropTriggerBtn.Text = "▼ " .. State.SelectedTarget.DisplayName .. " (@" .. State.SelectedTarget.Name .. ")"
    else
        DropTriggerBtn.Text = "▼ [ Closest Player ]"
    end
end

local function CyclePlayer(dir: number)
    local allOther = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(allOther, p) end
    end
    if #allOther == 0 then return end

    local curIdx = 0
    for i, p in ipairs(allOther) do
        if p == State.SelectedTarget then curIdx = i break end
    end

    local nextIdx = curIdx + dir
    if nextIdx > #allOther then nextIdx = 1 end
    if nextIdx < 1 then nextIdx = #allOther end

    State.SelectedTarget = allOther[nextIdx]
    UpdateTrollDropdownDisplay()
end

PrevPlrBtn.MouseButton1Click:Connect(function() CyclePlayer(-1) end)
NextPlrBtn.MouseButton1Click:Connect(function() CyclePlayer(1) end)

local function OpenTrollDropdown()
    if DropdownMenu.Visible then
        DropdownMenu.Visible = false
        return
    end

    for _, c in ipairs(DropScroll:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end

    local function MakeDropRow(label: string, onClick: () -> ())
        local r = Instance.new("TextButton", DropScroll)
        r.Size = UDim2.new(1, 0, 0, 20)
        r.BackgroundColor3 = GetColor("Surface")
        r.BorderSizePixel = 0
        r.Font = Enum.Font.Code
        r.Text = "  " .. label
        r.TextColor3 = GetColor("TextPrimary")
        r.TextSize = 8
        r.TextXAlignment = Enum.TextXAlignment.Left
        r.TextTruncate = Enum.TextTruncate.AtEnd
        r.ZIndex = 92
        r.MouseButton1Click:Connect(function()
            onClick()
            DropdownMenu.Visible = false
        end)
    end

    MakeDropRow("[ Closest Player ]", function()
        State.SelectedTarget = nil
        UpdateTrollDropdownDisplay()
    end)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            MakeDropRow(p.DisplayName .. " (@" .. p.Name .. ")", function()
                State.SelectedTarget = p
                UpdateTrollDropdownDisplay()
            end)
        end
    end

    local absPos = TargetSelRow.AbsolutePosition
    local absSize = TargetSelRow.AbsoluteSize
    DropdownMenu.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
    DropdownMenu.Size = UDim2.new(0, absSize.X, 0, math.clamp((#Players:GetPlayers() * 22), 60, 160))
    DropdownMenu.Visible = true
end

DropTriggerBtn.MouseButton1Click:Connect(OpenTrollDropdown)

AddButton(tLeft, "Teleport To Target", function()
    if State.SelectedTarget and State.SelectedTarget.Character then
        local tRoot = GetRoot(State.SelectedTarget.Character)
        local myRoot = GetRoot()
        if tRoot and myRoot then myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 2, 0) end
    end
end)

AddButton(tLeft, "Spectate Target", function()
    if State.SelectedTarget and State.SelectedTarget.Character then
        local hum = GetHumanoid(State.SelectedTarget.Character)
        if hum then Camera.CameraSubject = hum end
    end
end)

AddButton(tLeft, "Reset Spectate", function()
    Camera.CameraSubject = GetHumanoid()
end)

local tRight = CreateCard(TabPages["Troll"].Right, "[Fling & Physics]")
AddToggle(tRight, "Walk Fling (Stabilized)", false, function(s) State.WalkFling = s end)
AddButton(tRight, "Fling Selected Target", function()
    if State.SelectedTarget and State.SelectedTarget.Character then
        local tRoot = GetRoot(State.SelectedTarget.Character)
        local myRoot = GetRoot()
        if tRoot and myRoot then
            State.WalkFling = true
            myRoot.CFrame = tRoot.CFrame
            task.wait(0.6)
            State.WalkFling = false
        end
    end
end)
AddToggle(tRight, "Orbit Swarm Target", false, function(s) State.OrbitTarget = s end)
AddToggle(tRight, "Attach / Backpack Target", false, function(s) State.AttachTarget = s end)

----------------------------------------------------------------------------
-- TAB 5: SCRIPTS
----------------------------------------------------------------------------
local sLeft = CreateCard(TabPages["Scripts"].Left, "[Universal Hubs]")
AddButton(sLeft, "Infinite Yield", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end)
AddButton(sLeft, "Dex Explorer v4", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end)
AddButton(sLeft, "SimpleSpy v3", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/src/source.lua"))() end)

local sRight = CreateCard(TabPages["Scripts"].Right, "[Custom Code Slot]")
AddButton(sRight, "Execute Potassium Hooks", function() print("[Fih Menu]: Hooks active.") end)

----------------------------------------------------------------------------
-- TAB 6: THEMES
----------------------------------------------------------------------------
local thLeft = CreateCard(TabPages["Themes"].Left, "[Theme Presets]")
for name, col in pairs(Presets) do
    AddButton(thLeft, name, function() ApplyTheme(col) end)
end

-- Start on Main tab
SwitchTab("Main")

print("[Fih Menu]: Fully populated suite with player popup & troll dropdown booted.")
