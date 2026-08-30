-- Interface/MusicWidget.lua
-- Translucent Squared Music HUD with Album Art, Audio Controls & Visualizer

local TweenService = game:GetService("TweenService")

local MusicWidget = {}

function MusicWidget.new(windowBase: any, screenHost: ScreenGui, themeManager: any, signalMod: any, mediaBridge: any)
    local MusicWindow = windowBase.new("Fih HUD :: Now Playing & Synced Lyrics", UDim2.new(0, 360, 0, 140), UDim2.new(0, 20, 1, -160), Vector2.new(300, 130), screenHost, themeManager, signalMod)

    local MusicContent = MusicWindow.Content

    -- Album Cover Art
    local CoverArt = Instance.new("ImageLabel")
    CoverArt.Name = "SongCover"
    CoverArt.Size = UDim2.new(0, 90, 1, -12)
    CoverArt.Position = UDim2.new(0, 6, 0, 6)
    CoverArt.BackgroundColor3 = themeManager.Get("Surface")
    CoverArt.BackgroundTransparency = 0.25
    CoverArt.BorderSizePixel = 0
    CoverArt.Image = "rbxassetid://10849911991"
    CoverArt.Parent = MusicContent

    local CoverStroke = Instance.new("UIStroke")
    CoverStroke.Thickness = 1
    CoverStroke.Color = themeManager.Get("Border")
    CoverStroke.Parent = CoverArt

    -- Details & Controls
    local SongDetails = Instance.new("Frame")
    SongDetails.Size = UDim2.new(1, -108, 1, -12)
    SongDetails.Position = UDim2.new(0, 102, 0, 6)
    SongDetails.BackgroundTransparency = 1
    SongDetails.Parent = MusicContent

    local SongTitleLabel = Instance.new("TextLabel")
    SongTitleLabel.Size = UDim2.new(1, 0, 0, 16)
    SongTitleLabel.BackgroundTransparency = 1
    SongTitleLabel.Font = Enum.Font.Code
    SongTitleLabel.Text = "you make me sick bitch!!"
    SongTitleLabel.TextColor3 = themeManager.Get("Accent")
    SongTitleLabel.TextSize = 10
    SongTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SongTitleLabel.Parent = SongDetails
    themeManager.RegisterBinding(SongTitleLabel, "TextColor3", "Accent")

    local ArtistLabel = Instance.new("TextLabel")
    ArtistLabel.Size = UDim2.new(1, 0, 0, 14)
    ArtistLabel.Position = UDim2.new(0, 0, 0, 16)
    ArtistLabel.BackgroundTransparency = 1
    ArtistLabel.Font = Enum.Font.Code
    ArtistLabel.Text = "Ashnikko [Spotify]"
    ArtistLabel.TextColor3 = Color3.fromRGB(85, 170, 255)
    ArtistLabel.TextSize = 9
    ArtistLabel.TextXAlignment = Enum.TextXAlignment.Left
    ArtistLabel.Parent = SongDetails

    local LyricsLabel = Instance.new("TextLabel")
    LyricsLabel.Size = UDim2.new(1, 0, 0, 16)
    LyricsLabel.Position = UDim2.new(0, 0, 0, 32)
    LyricsLabel.BackgroundTransparency = 1
    LyricsLabel.Font = Enum.Font.Code
    LyricsLabel.Text = "Starting to tell me that it's okay"
    LyricsLabel.TextColor3 = themeManager.Get("TextSecondary")
    LyricsLabel.TextSize = 9
    LyricsLabel.TextWrapped = true
    LyricsLabel.TextXAlignment = Enum.TextXAlignment.Left
    LyricsLabel.Parent = SongDetails

    -- Controls Bar
    local ControlsBar = Instance.new("TextLabel")
    ControlsBar.Size = UDim2.new(1, 0, 0, 16)
    ControlsBar.Position = UDim2.new(0, 0, 0, 52)
    ControlsBar.BackgroundTransparency = 1
    ControlsBar.Font = Enum.Font.Code
    ControlsBar.Text = "[|<]  [||]  [>|]   VOL [====] SPEED [1x]"
    ControlsBar.TextColor3 = themeManager.Get("TextPrimary")
    ControlsBar.TextSize = 8
    ControlsBar.TextXAlignment = Enum.TextXAlignment.Left
    ControlsBar.Parent = SongDetails

    -- Visualizer Frame
    local VisualizerFrame = Instance.new("Frame")
    VisualizerFrame.Size = UDim2.new(1, 0, 0, 26)
    VisualizerFrame.Position = UDim2.new(0, 0, 1, -26)
    VisualizerFrame.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
    VisualizerFrame.BackgroundTransparency = 0.3
    VisualizerFrame.BorderSizePixel = 0
    VisualizerFrame.ClipsDescendants = true
    VisualizerFrame.Parent = SongDetails

    local VisStroke = Instance.new("UIStroke")
    VisStroke.Thickness = 1
    VisStroke.Color = themeManager.Get("Border")
    VisStroke.Transparency = 0.4
    VisStroke.Parent = VisualizerFrame

    local VisLayout = Instance.new("UIListLayout")
    VisLayout.FillDirection = Enum.FillDirection.Horizontal
    VisLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    VisLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    VisLayout.Padding = UDim.new(0, 2)
    VisLayout.Parent = VisualizerFrame

    local VisualizerBars = {}
    for i = 1, 16 do
        local bar = Instance.new("Frame")
        bar.Name = "Bar_" .. i
        bar.Size = UDim2.new(0, 8, 0, 4)
        bar.BackgroundColor3 = themeManager.Get("Accent")
        bar.BorderSizePixel = 0
        bar.Parent = VisualizerFrame

        local barGrad = Instance.new("UIGradient")
        barGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, themeManager.Get("Accent")),
        })
        barGrad.Rotation = 90
        barGrad.Parent = bar

        themeManager.RegisterBinding(bar, "BackgroundColor3", "Accent")
        table.insert(VisualizerBars, bar)
    end

    task.spawn(function()
        while true do
            task.wait(0.08)
            local t = tick()
            local maxHeight = VisualizerFrame.AbsoluteSize.Y - 4
            if maxHeight < 8 then maxHeight = 22 end
            for idx, bar in ipairs(VisualizerBars) do
                local noiseVal = math.noise(idx * 0.35, t * 4, 0)
                local norm = math.clamp(math.abs(noiseVal) * maxHeight, 3, maxHeight)
                TweenService:Create(bar, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
                    Size = UDim2.new(0, 8, 0, norm)
                }):Play()
            end
        end
    end)

    return MusicWindow
end

return MusicWidget
