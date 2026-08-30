-- Modules/VisualsController.lua
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera

local VisualsController = {
    BoxESP = false,
    NameESP = false,
    Highlights = false,
    Fullbright = false,
    FOV = 70,
    OriginalBrightness = Lighting.Brightness,
    OriginalClockTime = Lighting.ClockTime,
    OriginalFogEnd = Lighting.FogEnd,
}

function VisualsController.SetFOV(fov: number)
    VisualsController.FOV = fov
    Camera.FieldOfView = fov
end

function VisualsController.SetFullbright(enable: boolean)
    VisualsController.Fullbright = enable
    if enable then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = VisualsController.OriginalBrightness
        Lighting.ClockTime = VisualsController.OriginalClockTime
        Lighting.FogEnd = VisualsController.OriginalFogEnd
        Lighting.GlobalShadows = true
    end
end

function VisualsController.SetHighlights(enable: boolean)
    VisualsController.Highlights = enable
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hl = plr.Character:FindFirstChild("FihHighlight")
            if enable then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "FihHighlight"
                    hl.FillColor = Color3.fromRGB(255, 60, 180)
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.OutlineTransparency = 0.1
                    hl.Adornee = plr.Character
                    hl.Parent = plr.Character
                end
            else
                if hl then hl:Destroy() end
            end
        end
    end
end

function VisualsController.SetBoxESP(enable: boolean)
    VisualsController.BoxESP = enable
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local bg = root:FindFirstChild("FihESP_Box")
                if enable then
                    if not bg then
                        local b = Instance.new("BillboardGui")
                        b.Name = "FihESP_Box"
                        b.Adornee = root
                        b.Size = UDim2.new(4, 0, 5.5, 0)
                        b.AlwaysOnTop = true
                        b.Parent = root

                        local frame = Instance.new("Frame")
                        frame.Size = UDim2.new(1, 0, 1, 0)
                        frame.BackgroundTransparency = 0.85
                        frame.BackgroundColor3 = Color3.fromRGB(255, 60, 180)
                        frame.BorderSizePixel = 0
                        frame.Parent = b

                        local s = Instance.new("UIStroke")
                        s.Thickness = 1.5
                        s.Color = Color3.fromRGB(255, 60, 180)
                        s.Parent = frame
                    end
                else
                    if bg then bg:Destroy() end
                end
            end
        end
    end
end

function VisualsController.SetNameESP(enable: boolean)
    VisualsController.NameESP = enable
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local bg = head:FindFirstChild("FihESP_Name")
                if enable then
                    if not bg then
                        local b = Instance.new("BillboardGui")
                        b.Name = "FihESP_Name"
                        b.Adornee = head
                        b.Size = UDim2.new(0, 120, 0, 24)
                        b.StudsOffset = Vector3.new(0, 2.2, 0)
                        b.AlwaysOnTop = true
                        b.Parent = head

                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Font = Enum.Font.Code
                        lbl.Text = plr.DisplayName
                        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                        lbl.TextSize = 10
                        lbl.Parent = b
                    end
                else
                    if bg then bg:Destroy() end
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        if VisualsController.Highlights then VisualsController.SetHighlights(true) end
        if VisualsController.BoxESP then VisualsController.SetBoxESP(true) end
        if VisualsController.NameESP then VisualsController.SetNameESP(true) end
    end)
end)

return VisualsController
