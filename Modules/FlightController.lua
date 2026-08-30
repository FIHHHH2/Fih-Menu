-- Modules/FlightController.lua
-- LinearVelocity 3D Vector Flight Module

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local FlightController = {
    Enabled = false,
    Speed = 50,
    LinearVelocity = nil :: LinearVelocity?,
    Attachment = nil :: Attachment?,
    RenderConnection = nil :: RBXScriptConnection?,
}

local function GetRoot(): BasePart?
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")) :: BasePart?
end

function FlightController.SetSpeed(speed: number)
    FlightController.Speed = speed
end

function FlightController.Enable()
    if FlightController.Enabled then return end
    local root = GetRoot()
    if not root then return end

    FlightController.Enabled = true

    local att = Instance.new("Attachment")
    att.Name = "FihFly_Att"
    att.Parent = root
    FlightController.Attachment = att

    local lv = Instance.new("LinearVelocity")
    lv.Name = "FihFly_LV"
    lv.Attachment0 = att
    lv.MaxForce = 1e6
    lv.VectorVelocity = Vector3.zero
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.Parent = root
    FlightController.LinearVelocity = lv

    FlightController.RenderConnection = RunService.RenderStepped:Connect(function()
        if not FlightController.Enabled or not FlightController.LinearVelocity then return end

        local cam = Workspace.CurrentCamera
        local moveDir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then
            FlightController.LinearVelocity.VectorVelocity = moveDir.Unit * FlightController.Speed
        else
            FlightController.LinearVelocity.VectorVelocity = Vector3.zero
        end
    end)
end

function FlightController.Disable()
    FlightController.Enabled = false
    if FlightController.RenderConnection then
        FlightController.RenderConnection:Disconnect()
        FlightController.RenderConnection = nil
    end
    if FlightController.LinearVelocity then
        FlightController.LinearVelocity:Destroy()
        FlightController.LinearVelocity = nil
    end
    if FlightController.Attachment then
        FlightController.Attachment:Destroy()
        FlightController.Attachment = nil
    end
end

function FlightController.Toggle(state: boolean)
    if state then
        FlightController.Enable()
    else
        FlightController.Disable()
    end
end

return FlightController
