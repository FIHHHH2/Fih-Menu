-- Interface/MusicWidget.lua
-- Translucent Squared Music HUD with Large Cover Art & Gradient Audio Spectrum

local TweenService = game:GetService("TweenService")

local MusicWidget = {}

function MusicWidget.new(windowBase: any, screenHost: ScreenGui, themeManager: any, signalMod: any, mediaBridge: any)
    local MusicWindow = windowBase.new("Music Player", UDim2.new(0, 420, 0, 180), UDim2.new(0, 20, 0, 30), Vector2.new(340, 150), screenHost, themeManager, signalMod)

    local MusicContent = MusicWindow.Content

    -- Large Album Cover Art (Evened Out)
    local CoverArt = Instance.new("ImageLabel")
    CoverArt.Name = "SongCover"
    CoverArt.Size = UDim2.new(0, 130, 1, -16)
    CoverArt.Position = UDim2.new(0, 8, 0, 8)
    CoverArt.BackgroundColor3 = themeManager.Get("Surface")
    CoverArt.BackgroundTransparency = 0.25
    CoverArt.BorderSizePixel = 0
    CoverArt.Image = "rbxassetid://10849911991"
    CoverArt.Parent = MusicContent

    local CoverStroke = Instance.new("UIStroke")
    CoverStroke.Thickness = 1
    CoverStroke.Color = themeManager.Get("Border")
    CoverStroke.Parent = CoverArt

    local CoverLabel = Instance.new("TextLabel")
    CoverLabel.Size = UDim2.new(1, 0, 1, 0)
    CoverLabel.BackgroundTransparency = 1
    CoverLabel.Font = Enum.Font.Code
    CoverLabel.Text = "ALBUM\nCOVER"
    CoverLabel.TextColor3 = themeManager.Get("TextSecondary")
    CoverLabel.TextSize = 11
    CoverLabel.Parent = CoverArt

    -- Right Content Details
    local SongDetails = Instance.new("Frame")
    SongDetails.Size = UDim2.new(1, -154, 1, -16)
    SongDetails.Position = UDim2.new(0, 146, 0, 8)
    SongDetails.BackgroundTransparency = 1
    SongDetails.Parent = MusicContent

    local SongTitleLabel = Instance.new("TextLabel")
    SongTitleLabel.Size = UDim2.new(1, 0, 0, 20)
    SongTitleLabel.BackgroundTransparency = 1
    SongTitleLabel.Font = Enum.Font.Code
    SongTitleLabel.Text = "♪ Track 01 : Lo-Fi Study Beats"
    SongTitleLabel.TextColor3 = themeManager.Get("Accent")
    SongTitleLabel.TextSize = 11
    SongTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SongTitleLabel.Parent = SongDetails
    themeManager.RegisterBinding(SongTitleLabel, "TextColor3", "Accent")

    local LyricsBox = Instance.new("Frame")
    LyricsBox.Size = UDim2.new(1, 0, 0, 42)
    LyricsBox.Position = UDim2.new(0, 0, 0, 24)
    LyricsBox.BackgroundColor3 = themeManager.Get("Surface")
    LyricsBox.BackgroundTransparency = 0.3
    LyricsBox.BorderSizePixel = 0
    LyricsBox.Parent = SongDetails

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
    LyricsLabel.Text = "♪ (Synced lyrics active...)"
    LyricsLabel.TextColor3 = themeManager.Get("TextPrimary")
    LyricsLabel.TextSize = 10
    LyricsLabel.TextWrapped = true
    LyricsLabel.Parent = LyricsBox

    -- 16-Bar Spectrum Visualizer (With Gradient)
    local VisualizerFrame = Instance.new("Frame")
    VisualizerFrame.Size = UDim2.new(1, 0, 1, -74)
    VisualizerFrame.Position = UDim2.new(0, 0, 0, 72)
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
        bar.Size = UDim2.new(0, 10, 0, 6)
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
            local maxHeight = VisualizerFrame.AbsoluteSize.Y - 6
            if maxHeight < 10 then maxHeight = 30 end
            for idx, bar in ipairs(VisualizerBars) do
                local noiseVal = math.noise(idx * 0.35, t * 4, 0)
                local norm = math.clamp(math.abs(noiseVal) * maxHeight, 4, maxHeight)
                TweenService:Create(bar, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
                    Size = UDim2.new(0, 10, 0, norm)
                }):Play()
            end
        end
    end)

    return MusicWindow
end

return MusicWidget
