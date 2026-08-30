-- Core/ThemeManager.lua
-- Translucent Glassmorphic Theme Engine with Dynamic Accent Transitions

local TweenService = game:GetService("TweenService")

local ThemeManager = {}
ThemeManager.__index = ThemeManager

local Tokens = {
    BackgroundPrimary   = Color3.fromRGB(16, 16, 22),
    BackgroundSecondary = Color3.fromRGB(22, 22, 30),
    Surface             = Color3.fromRGB(30, 30, 42),
    SurfaceHover        = Color3.fromRGB(42, 42, 58),
    Border              = Color3.fromRGB(65, 65, 85),
    BorderActive        = Color3.fromRGB(85, 170, 255),
    TextPrimary         = Color3.fromRGB(245, 245, 250),
    TextSecondary       = Color3.fromRGB(160, 160, 180),
    Accent              = Color3.fromRGB(85, 170, 255),
    AccentGlow          = Color3.fromRGB(120, 190, 255),
    Success             = Color3.fromRGB(80, 220, 140),
    Danger              = Color3.fromRGB(245, 75, 75),
}

local Transparencies = {
    BackgroundPrimary   = 0.18,
    BackgroundSecondary = 0.22,
    Surface             = 0.35,
    SurfaceHover        = 0.25,
    Border              = 0.30,
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
                TweenService:Create(b.Instance, TweenInfo.new(0.40, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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
