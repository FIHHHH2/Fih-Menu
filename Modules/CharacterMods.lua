-- Modules/CharacterMods.lua
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local CharacterMods = {
    WalkSpeed = 16,
    JumpPower = 50,
    Gravity = 196.2,
    InfiniteJump = false,
    Noclip = false,
    Spinbot = false,
    NoclipConn = nil :: RBXScriptConnection?,
    SpinConn = nil :: RBXScriptConnection?,
}

local function GetHumanoid(): Humanoid?
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot(): BasePart?
    local char = LocalPlayer.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")) :: BasePart?
end

function CharacterMods.SetWalkSpeed(speed: number)
    CharacterMods.WalkSpeed = speed
    local hum = GetHumanoid()
    if hum then hum.WalkSpeed = speed end
end

function CharacterMods.SetJumpPower(power: number)
    CharacterMods.JumpPower = power
    local hum = GetHumanoid()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = power
    end
end

function CharacterMods.SetGravity(grav: number)
    CharacterMods.Gravity = grav
    Workspace.Gravity = grav
end

function CharacterMods.SetInfiniteJump(enable: boolean)
    CharacterMods.InfiniteJump = enable
end

function CharacterMods.SetNoclip(enable: boolean)
    CharacterMods.Noclip = enable
    if enable then
        if not CharacterMods.NoclipConn then
            CharacterMods.NoclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
    else
        if CharacterMods.NoclipConn then
            CharacterMods.NoclipConn:Disconnect()
            CharacterMods.NoclipConn = nil
        end
    end
end

function CharacterMods.SetSpinbot(enable: boolean)
    CharacterMods.Spinbot = enable
    if enable then
        if not CharacterMods.SpinConn then
            CharacterMods.SpinConn = RunService.RenderStepped:Connect(function()
                local root = GetRoot()
                if root and CharacterMods.Spinbot then
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(22), 0)
                end
            end)
        end
    else
        if CharacterMods.SpinConn then
            CharacterMods.SpinConn:Disconnect()
            CharacterMods.SpinConn = nil
        end
    end
end

UserInputService.JumpRequest:Connect(function()
    if CharacterMods.InfiniteJump then
        local hum = GetHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

return CharacterMods
