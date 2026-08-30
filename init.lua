-- init.lua
-- Fih Menu Entry Point
-- Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/FIHHHH2/Fih-Menu/main/init.lua?t=" .. tick()))()

local ok, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/FIHHHH2/Fih-Menu/main/Fih_Menu.lua?t=" .. tick()))()
end)

if not ok then
    warn("[Fih Menu] Boot error: " .. tostring(err))
end
