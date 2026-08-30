-- Modules/FlingController.lua
-- Rotational Physics Desync & Collision Fling

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local FlingController = {
    Enabled = false,
    SimulationConn = nil :: RBXScriptConnection?,
}

local function GetRoot(char: Model?): BasePart?
    local character = char or LocalPlayer.Character
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")) :: BasePart?
end

function FlingController.Enable()
    if FlingController.Enabled then return end
    FlingController.Enabled = true

    FlingController.SimulationConn = RunService.PostSimulation:Connect(function()
        local root = GetRoot()
        if root then
            root.AssemblyAngularVelocity = Vector3.new(0, 999999, 0)
        end
    end)
end

function FlingController.Disable()
    FlingController.Enabled = false
    if FlingController.SimulationConn then
        FlingController.SimulationConn:Disconnect()
        FlingController.SimulationConn = nil
    end
    local root = GetRoot()
    if root then
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

function FlingController.Toggle(state: boolean)
    if state then
        FlingController.Enable()
    else
        FlingController.Disable()
    end
end

function FlingController.FlingPlayer(targetPlayer: Player, duration: number?)
    local d = duration or 0.6
    if targetPlayer and targetPlayer.Character then
        local tRoot = GetRoot(targetPlayer.Character)
        local myRoot = GetRoot()
        if tRoot and myRoot then
            FlingController.Enable()
            myRoot.CFrame = tRoot.CFrame
            task.wait(d)
            FlingController.Disable()
        end
    end
end

return FlingController
