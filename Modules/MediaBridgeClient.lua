-- Modules/MediaBridgeClient.lua
-- Media Daemon Poller & Synced LRC Metadata Engine

local HttpService = game:GetService("HttpService")

local MediaBridgeClient = {}
MediaBridgeClient.__index = MediaBridgeClient

function MediaBridgeClient.new(signalMod: any)
    local self = setmetatable({}, MediaBridgeClient)
    self.OnTrackChange = signalMod.new()
    self.CurrentTrack = {
        Title = "Lo-Fi Beats (Local Mode)",
        Artist = "Universal Audio",
        AlbumArt = "rbxassetid://10849911991",
        DurationMs = 214000,
        ProgressMs = 0,
        IsPlaying = true,
        Lyrics = {},
    }
    return self
end

function MediaBridgeClient:PollDaemon()
    local req = (rawget(getfenv and getfenv(0) or _G, "http_request") or rawget(getfenv and getfenv(0) or _G, "request") or (syn and syn.request))
    if type(req) == "function" then
        pcall(function()
            local res = req({
                Url = "http://127.0.0.1:9000/state",
                Method = "GET",
            })
            if res and res.StatusCode == 200 and res.Body then
                local data = HttpService:JSONDecode(res.Body)
                self.CurrentTrack = data
                self.OnTrackChange:Fire(data)
            end
        end)
    end
end

return MediaBridgeClient
