-- Modules/PlatformFloater.lua
-- Stepped Timed Descent Platform Floater

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local PlatformFloater = {
    Enabled = false,
    PlatformPart = nil :: BasePart?,
    HeartbeatConn = nil :: RBXScriptConnection?,
    PlatformY = 0,
    StepHeight = 0.45,
}

local function GetRoot(): BasePart?
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")) :: BasePart?
end

local function GetHumanoid(): Humanoid?
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

function PlatformFloater.Enable(accentColor: Color3?)
    if PlatformFloater.Enabled then return end
    local root = GetRoot()
    if not root then return end

    PlatformFloater.Enabled = true
    PlatformFloater.PlatformY = root.Position.Y - 3.6

    local part = Instance.new("Part")
    part.Name = "FihPlatform_Part"
    part.Size = Vector3.new(6, 1, 6)
    part.Anchored = true
    part.CanCollide = true
    part.Transparency = 0.35
    part.Material = Enum.Material.Neon
    part.Color = accentColor or Color3.fromRGB(85, 170, 255)
    part.CFrame = CFrame.new(root.Position.X, PlatformFloater.PlatformY, root.Position.Z)
    part.Parent = Workspace
    PlatformFloater.PlatformPart = part

    local stepTimer = 0
    PlatformFloater.HeartbeatConn = RunService.Heartbeat:Connect(function(dt)
        local curRoot = GetRoot()
        if not curRoot or not PlatformFloater.PlatformPart then return end

        stepTimer += dt
        if stepTimer >= 0.25 then
            stepTimer = 0
            PlatformFloater.PlatformY -= PlatformFloater.StepHeight
        end

        local hum = GetHumanoid()
        if hum and hum:GetState() == Enum.HumanoidStateType.Jumping then
            PlatformFloater.PlatformY = curRoot.Position.Y - 3.6
        end

        PlatformFloater.PlatformPart.CFrame = CFrame.new(curRoot.Position.X, PlatformFloater.PlatformY, curRoot.Position.Z)
    end)
end

function PlatformFloater.Disable()
    PlatformFloater.Enabled = false
    if PlatformFloater.HeartbeatConn then
        PlatformFloater.HeartbeatConn:Disconnect()
        PlatformFloater.HeartbeatConn = nil
    end
    if PlatformFloater.PlatformPart then
        PlatformFloater.PlatformPart:Destroy()
        PlatformFloater.PlatformPart = nil
    end
end

function PlatformFloater.Toggle(state: boolean, accentColor: Color3?)
    if state then
        PlatformFloater.Enable(accentColor)
    else
        PlatformFloater.Disable()
    end
end

return PlatformFloater
