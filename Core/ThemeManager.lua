-- Core/ThemeManager.lua
-- Translucent Glassmorphic Theme Engine with Adaptive Multi-Token Reactive Interpolation

local TweenService = game:GetService("TweenService")

local ThemeManager = {}
ThemeManager.__index = ThemeManager

local Tokens = {
    BackgroundPrimary   = Color3.fromRGB(14, 14, 20),
    BackgroundSecondary = Color3.fromRGB(20, 20, 28),
    Surface             = Color3.fromRGB(26, 26, 36),
    SurfaceHover        = Color3.fromRGB(38, 38, 52),
    Border              = Color3.fromRGB(55, 55, 75),
    BorderActive        = Color3.fromRGB(85, 170, 255),
    TextPrimary         = Color3.fromRGB(245, 245, 250),
    TextSecondary       = Color3.fromRGB(150, 150, 170),
    Accent              = Color3.fromRGB(85, 170, 255),
    AccentGlow          = Color3.fromRGB(120, 190, 255),
    Success             = Color3.fromRGB(75, 215, 135),
    Danger              = Color3.fromRGB(245, 70, 70),
}

local Transparencies = {
    BackgroundPrimary   = 0.12,
    BackgroundSecondary = 0.18,
    Surface             = 0.28,
    SurfaceHover        = 0.18,
    Border              = 0.35,
    BorderActive        = 0.00,
}

local Presets = {
    ["Dark Cubed"]       = Color3.fromRGB(85, 170, 255),
    ["Cyberpunk Neon"]   = Color3.fromRGB(255, 0, 135),
    ["Acid Matrix"]      = Color3.fromRGB(0, 255, 130),
    ["Amber Sunset"]     = Color3.fromRGB(255, 160, 45),
    ["Monochrome Slate"] = Color3.fromRGB(190, 190, 205),
    ["Crimson Red"]      = Color3.fromRGB(255, 55, 75),
    ["Sakura Pink"]      = Color3.fromRGB(255, 135, 190),
    ["Deep Indigo"]      = Color3.fromRGB(130, 90, 255),
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
                TweenService:Create(b.Instance, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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
