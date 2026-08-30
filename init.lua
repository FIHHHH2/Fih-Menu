-- init.lua
-- Fih Menu Modular & Standalone Universal Loader
-- Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/FIHHHH2/Fih-Menu/main/Fih_Menu.lua?t=" .. tick()))()

local url = "https://raw.githubusercontent.com/FIHHHH2/Fih-Menu/main/Fih_Menu.lua?t=" .. tostring(os.time()) .. tostring(math.random(1000, 9999))
local ok, src = pcall(function() return game:HttpGet(url) end)
if ok and type(src) == "string" and #src > 100 then
    local chunk, err = loadstring(src)
    if type(chunk) == "function" then
        chunk()
    else
        error("[Fih Menu] Syntax error: " .. tostring(err))
    end
else
    error("[Fih Menu] Failed to fetch script: " .. tostring(src))
end
