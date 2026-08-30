-- Core/ThemeManager.lua
-- Translucent Glassmorphic Cyberpunk Neon Engine

local TweenService = game:GetService("TweenService")

local ThemeManager = {}
ThemeManager.__index = ThemeManager

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
    Success             = Color3.fromRGB(80, 225, 140),
    Danger              = Color3.fromRGB(255, 65, 85),
}

local Transparencies = {
    BackgroundPrimary   = 0.15,
    BackgroundSecondary = 0.20,
    Surface             = 0.30,
    SurfaceHover        = 0.15,
    Border              = 0.30,
    BorderActive        = 0.00,
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

function ThemeManager.Get(tokenName: string): Color3
    return Tokens[tokenName] or Color3.fromRGB(255, 255, 255)
end

function ThemeManager.GetTransparency(tokenName: string): number
    return Transparencies[tokenName] or 0
end

function ThemeManager.RegisterBinding(instance: Instance, property: string, tokenKey: string)
    table.insert(Bindings, { Instance = instance, Property = property, Key = tokenKey })
    pcall(function()
        (instance :: any)[property] = Tokens[tokenKey]
    end)
end

function ThemeManager.SetAccent(newAccent: Color3)
    Tokens.Accent = newAccent
    Tokens.BorderActive = newAccent
    Tokens.AccentGlow = Color3.new(
        math.clamp(newAccent.R * 1.2, 0, 1),
        math.clamp(newAccent.G * 1.2, 0, 1),
        math.clamp(newAccent.B * 1.2, 0, 1)
    )

    for _, b in ipairs(Bindings) do
        if b.Key == "Accent" or b.Key == "BorderActive" or b.Key == "AccentGlow" then
            if b.Instance and b.Instance.Parent then
                TweenService:Create(b.Instance, TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    [b.Property] = Tokens[b.Key]
                }):Play()
            end
        end
    end
end

function ThemeManager.ApplyPreset(presetName: string)
    local col = Presets[presetName]
    if col then
        ThemeManager.SetAccent(col)
    end
end

function ThemeManager.GetPresets()
    return Presets
end

return ThemeManager
