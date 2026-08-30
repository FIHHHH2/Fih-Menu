-- Core/ThemeManager.lua
-- Dynamic Adaptive Theme Token Manager and Animation Engine

local TweenService = game:GetService("TweenService")

local ThemeManager = {}
ThemeManager.__index = ThemeManager

local Tokens = {
    BackgroundPrimary   = Color3.fromRGB(18, 18, 22),
    BackgroundSecondary = Color3.fromRGB(26, 26, 32),
    Surface             = Color3.fromRGB(34, 34, 42),
    Border              = Color3.fromRGB(50, 50, 62),
    TextPrimary         = Color3.fromRGB(240, 240, 245),
    TextSecondary       = Color3.fromRGB(150, 150, 165),
    Accent              = Color3.fromRGB(85, 170, 255),
    AccentHover         = Color3.fromRGB(115, 185, 255),
    BorderActive        = Color3.fromRGB(85, 170, 255),
    Success             = Color3.fromRGB(75, 210, 140),
    Danger              = Color3.fromRGB(240, 70, 70),
}

local Presets = {
    ["Dark Cubed"] = Color3.fromRGB(85, 170, 255),
    ["Cyberpunk Neon"] = Color3.fromRGB(255, 0, 128),
    ["Acid Matrix"] = Color3.fromRGB(0, 255, 128),
    ["Amber Sunset"] = Color3.fromRGB(255, 160, 40),
    ["Monochrome Slate"] = Color3.fromRGB(180, 180, 195),
}

local Bindings = {}

function ThemeManager.Get(tokenName: string): Color3
    return Tokens[tokenName] or Color3.fromRGB(255, 255, 255)
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
    for _, b in ipairs(Bindings) do
        if b.Key == "Accent" or b.Key == "BorderActive" then
            if b.Instance and b.Instance.Parent then
                TweenService:Create(b.Instance, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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
