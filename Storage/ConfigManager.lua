-- Storage/ConfigManager.lua
-- Persistent Configuration Storage (writefile / readfile)

local HttpService = game:GetService("HttpService")

local ConfigManager = {
    FolderName = "FihMenu",
    Cache = {},
}

function ConfigManager.Save(configName: string, data: any)
    ConfigManager.Cache[configName] = data
    local writeFn = rawget(getfenv and getfenv(0) or _G, "writefile")
    if type(writeFn) == "function" then
        pcall(function()
            local makeDir = rawget(getfenv and getfenv(0) or _G, "makefolder")
            if type(makeDir) == "function" then
                pcall(makeDir, ConfigManager.FolderName)
            end
            writeFn(ConfigManager.FolderName .. "/" .. configName .. ".json", HttpService:JSONEncode(data))
        end)
    end
end

function ConfigManager.Load(configName: string): any?
    local readFn = rawget(getfenv and getfenv(0) or _G, "readfile")
    local isFileFn = rawget(getfenv and getfenv(0) or _G, "isfile")
    local path = ConfigManager.FolderName .. "/" .. configName .. ".json"

    if type(readFn) == "function" and type(isFileFn) == "function" and isFileFn(path) then
        local ok, res = pcall(function()
            return HttpService:JSONDecode(readFn(path))
        end)
        if ok and res then
            ConfigManager.Cache[configName] = res
            return res
        end
    end
    return ConfigManager.Cache[configName]
end

return ConfigManager
