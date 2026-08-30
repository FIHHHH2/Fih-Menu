# Fih Menu (Fish Menu)

Modular Cubed-Style Universal GUI Architecture for Roblox client environments.

## Quick Execution

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/FIHHHH2/Fih-Menu/main/init.lua?t=" .. tick()))()
```

## Directory Structure

```
Fih-Menu/
├── Core/
│   ├── Signal.lua               -- Fast event dispatcher
│   ├── ThemeManager.lua         -- Color token state & adaptive styling
│   └── WindowBase.lua           -- Base dragging, resizing, and layering class
├── Interface/
│   ├── MainMenu.lua             -- Navigation rail, categorized card grid, toggles & sliders
│   ├── CustomChat.lua           -- CoreGui Chat replacement with waveform monitor
│   ├── CustomPlayerList.lua     -- Domino leaderboard & context drawer
│   └── MusicWidget.lua          -- 16-bar visualizer & lyrics scroller
├── Modules/
│   ├── FlightController.lua     -- LinearVelocity body mover flight
│   ├── PlatformFloater.lua      -- Stepped platform descent
│   ├── FlingController.lua      -- Rotational physics desync
│   ├── CharacterMods.lua        -- Speed, jump, infinite jump & noclip loop
│   └── MediaBridgeClient.lua    -- Localhost HTTP media synchronizer
├── Storage/
│   ├── ConfigManager.lua        -- JSON configuration save/load
│   └── KeybindRegistry.lua      -- Global hotkey manager
└── init.lua                     -- Dynamic module bootstrapper
```
