-- Interface/MusicWidget.lua
-- Translucent Draggable Music HUD with Audio Spectrum Visualizer & Lyrics

local TweenService = game:GetService("TweenService")

local MusicWidget = {}

function MusicWidget.new(windowBase: any, screenHost: ScreenGui, themeManager: any, signalMod: any, mediaBridge: any)
    local MusicWindow = windowBase.new("Music Player", UDim2.new(0, 360, 0, 160), UDim2.new(0, 20, 0, 30), Vector2.new(300, 140), screenHost, themeManager, signalMod)

    local MusicContent = MusicWindow.Content

    local CoverArt = Instance.new("ImageLabel")
    CoverArt.Name = "SongCover"
    CoverArt.Size = UDim2.new(0, 92, 0, 92)
    CoverArt.Position = UDim2.new(0, 8, 0, 8)
    CoverArt.BackgroundColor3 = themeManager.Get("Surface")
    CoverArt.BackgroundTransparency = 0.3
    CoverArt.BorderSizePixel = 0
    CoverArt.Image = "rbxassetid://10849911991"
    CoverArt.Parent = MusicContent

    local CoverCorner = Instance.new("UICorner")
    CoverCorner.CornerRadius = UDim.new(0, 4)
    CoverCorner.Parent = CoverArt

    local CoverStroke = Instance.new("UIStroke")
    CoverStroke.Thickness = 1
    CoverStroke.Color = themeManager.Get("Border")
    CoverStroke.Parent = CoverArt

    local CoverLabel = Instance.new("TextLabel")
    CoverLabel.Size = UDim2.new(1, 0, 1, 0)
    CoverLabel.BackgroundTransparency = 1
    CoverLabel.Font = Enum.Font.Code
    CoverLabel.Text = "SONG\nCOVER"
    CoverLabel.TextColor3 = themeManager.Get("TextSecondary")
    CoverLabel.TextSize = 11
    CoverLabel.Parent = CoverArt

    local SongDetails = Instance.new("Frame")
    SongDetails.Size = UDim2.new(1, -116, 1, -16)
    SongDetails.Position = UDim2.new(0, 108, 0, 8)
    SongDetails.BackgroundTransparency = 1
    SongDetails.Parent = MusicContent

    local SongTitleLabel = Instance.new("TextLabel")
    SongTitleLabel.Size = UDim2.new(1, 0, 0, 18)
    SongTitleLabel.BackgroundTransparency = 1
    SongTitleLabel.Font = Enum.Font.Code
    SongTitleLabel.Text = "Song Title : Track 01"
    SongTitleLabel.TextColor3 = themeManager.Get("Accent")
    SongTitleLabel.TextSize = 12
    SongTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SongTitleLabel.Parent = SongDetails
    themeManager.RegisterBinding(SongTitleLabel, "TextColor3", "Accent")

    local LyricsBox = Instance.new("Frame")
    LyricsBox.Size = UDim2.new(1, 0, 0, 40)
    LyricsBox.Position = UDim2.new(0, 0, 0, 22)
    LyricsBox.BackgroundColor3 = themeManager.Get("Surface")
    LyricsBox.BackgroundTransparency = 0.3
    LyricsBox.BorderSizePixel = 0
    LyricsBox.Parent = SongDetails

    local LyricsCorner = Instance.new("UICorner")
    LyricsCorner.CornerRadius = UDim.new(0, 3)
    LyricsCorner.Parent = LyricsBox

    local LyricsStroke = Instance.new("UIStroke")
    LyricsStroke.Thickness = 1
    LyricsStroke.Color = themeManager.Get("Border")
    LyricsStroke.Transparency = 0.4
    LyricsStroke.Parent = LyricsBox

    local LyricsLabel = Instance.new("TextLabel")
    LyricsLabel.Size = UDim2.new(1, -8, 1, 0)
    LyricsLabel.Position = UDim2.new(0, 4, 0, 0)
    LyricsLabel.BackgroundTransparency = 1
    LyricsLabel.Font = Enum.Font.Code
    LyricsLabel.Text = "♪ (Synced lyrics stream active...)"
    LyricsLabel.TextColor3 = themeManager.Get("TextPrimary")
    LyricsLabel.TextSize = 10
    LyricsLabel.TextWrapped = true
    LyricsLabel.Parent = LyricsBox

    -- 16-Bar Visualizer
    local VisualizerFrame = Instance.new("Frame")
    VisualizerFrame.Size = UDim2.new(1, 0, 0, 36)
    VisualizerFrame.Position = UDim2.new(0, 0, 0, 68)
    VisualizerFrame.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
    VisualizerFrame.BackgroundTransparency = 0.3
    VisualizerFrame.BorderSizePixel = 0
    VisualizerFrame.Parent = SongDetails

    local VisCorner = Instance.new("UICorner")
    VisCorner.CornerRadius = UDim.new(0, 3)
    VisCorner.Parent = VisualizerFrame

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
        bar.Size = UDim2.new(0, 8, 0, 6)
        bar.BackgroundColor3 = themeManager.Get("Accent")
        bar.BorderSizePixel = 0
        bar.Parent = VisualizerFrame

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 1)
        bCorner.Parent = bar

        themeManager.RegisterBinding(bar, "BackgroundColor3", "Accent")
        table.insert(VisualizerBars, bar)
    end

    task.spawn(function()
        while true do
            task.wait(0.08)
            local t = tick()
            for idx, bar in ipairs(VisualizerBars) do
                local noiseVal = math.noise(idx * 0.35, t * 4, 0)
                local norm = math.clamp(math.abs(noiseVal) * 32, 4, 30)
                TweenService:Create(bar, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
                    Size = UDim2.new(0, 8, 0, norm)
                }):Play()
            end
        end
    end)

    return MusicWindow
end

return MusicWidget
