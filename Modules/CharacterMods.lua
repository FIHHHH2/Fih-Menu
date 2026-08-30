-- Modules/CharacterMods.lua
-- Speed, Jump, Infinite Jump, and Stepped Noclip Subsystem

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local CharacterMods = {
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    Noclip = false,
    NoclipConn = nil :: RBXScriptConnection?,
}

local function GetHumanoid(): Humanoid?
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

function CharacterMods.SetWalkSpeed(speed: number)
    CharacterMods.WalkSpeed = speed
    local hum = GetHumanoid()
    if hum then hum.WalkSpeed = speed end
end

function CharacterMods.SetJumpPower(power: number)
    CharacterMods.JumpPower = power
    local hum = GetHumanoid()
    if hum then hum.JumpPower = power end
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
                        if p:IsA("BasePart") then
                            p.CanCollide = false
                        end
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

UserInputService.JumpRequest:Connect(function()
    if CharacterMods.InfiniteJump then
        local hum = GetHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

return CharacterMods
