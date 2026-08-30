-- init.lua
-- Fih Menu Modular Universal Loader
-- Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/FIHHHH2/Fih-Menu/main/init.lua?t=" .. tick()))()

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local BASE_URL = "https://raw.githubusercontent.com/FIHHHH2/Fih-Menu/main"

-- Safe GUI container
local TargetParent: Instance = CoreGui
pcall(function()
    local test = Instance.new("Folder")
    test.Parent = CoreGui
    test:Destroy()
end)
if TargetParent ~= CoreGui or not pcall(function() return CoreGui.Name end) then
    TargetParent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Clear previous instance
if TargetParent:FindFirstChild("FishMenu_Host") then
    TargetParent.FishMenu_Host:Destroy()
end

local ScreenHost = Instance.new("ScreenGui")
ScreenHost.Name = "FishMenu_Host"
ScreenHost.ResetOnSpawn = false
ScreenHost.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenHost.DisplayOrder = 100
ScreenHost.Parent = TargetParent

local function RequireModule(subPath: string)
    local url = BASE_URL .. "/" .. subPath .. ".lua?t=" .. tostring(os.time()) .. tostring(math.random(1000, 9999))
    local ok, src = pcall(function() return game:HttpGet(url) end)
    if not ok or type(src) ~= "string" or #src == 0 then
        error("[Fih Menu] Failed to load module: " .. subPath .. " -> " .. tostring(src))
    end

    local ls = rawget(getfenv and getfenv(0) or _G, "loadstring") or loadstring
    local chunk, cerr = ls(src)
    if type(chunk) ~= "function" then
        error("[Fih Menu] Syntax error in module: " .. subPath .. " -> " .. tostring(cerr))
    end

    local ok2, mod = pcall(chunk)
    if not ok2 then
        error("[Fih Menu] Runtime error in module: " .. subPath .. " -> " .. tostring(mod))
    end
    return mod
end

-- 1. Core Modules
local Signal = RequireModule("Core/Signal")
local ThemeManager = RequireModule("Core/ThemeManager")
local WindowBase = RequireModule("Core/WindowBase")

-- 2. Advantage / Backend Feature Modules
local FlightController = RequireModule("Modules/FlightController")
local PlatformFloater = RequireModule("Modules/PlatformFloater")
local FlingController = RequireModule("Modules/FlingController")
local CharacterMods = RequireModule("Modules/CharacterMods")
local VisualsController = RequireModule("Modules/VisualsController")
local MediaBridgeClient = RequireModule("Modules/MediaBridgeClient")

-- 3. Storage
local ConfigManager = RequireModule("Storage/ConfigManager")
local KeybindRegistry = RequireModule("Storage/KeybindRegistry")

-- 4. GUI Interface Modules
local CustomChat = RequireModule("Interface/CustomChat")
local CustomPlayerList = RequireModule("Interface/CustomPlayerList")
local MusicWidget = RequireModule("Interface/MusicWidget")
local MainMenu = RequireModule("Interface/MainMenu")

-- Instantiate Subsystem Windows
local ChatWindow = CustomChat.new(WindowBase, ScreenHost, ThemeManager, Signal)
local PlayerListWindow = CustomPlayerList.new(WindowBase, ScreenHost, ThemeManager, Signal, FlingController)
local MediaClient = MediaBridgeClient.new(Signal)
local MusicWindow = MusicWidget.new(WindowBase, ScreenHost, ThemeManager, Signal, MediaClient)

-- Instantiate Main Hub GUI
local MainHub = MainMenu.new(
    WindowBase,
    ScreenHost,
    ThemeManager,
    Signal,
    FlightController,
    PlatformFloater,
    FlingController,
    CharacterMods,
    VisualsController,
    {
        Chat = ChatWindow,
        PlayerList = PlayerListWindow,
        Music = MusicWindow,
    }
)

print("[Fih Menu]: Modular Universal GUI Architecture successfully booted.")
