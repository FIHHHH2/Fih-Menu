-- Modules/MusicEngine.lua
-- Built-in Roblox Sound Player, Presets & Audio Visualizer Frequency Engine

local SoundService = game:GetService("SoundService")

local MusicEngine = {
    SoundInstance = nil :: Sound?,
    IsPlaying = false,
    Volume = 1.0,
    Pitch = 1.0,
    CurrentSongTitle = "Track 01 - Study Beats",
    Presets = {
        { Name = "Lo-Fi Beats 1", Id = 9048375035 },
        { Name = "Chill Study 2", Id = 1837849285 },
        { Name = "Synthwave 3",   Id = 9043887091 },
    }
}

function MusicEngine.Init()
    if not MusicEngine.SoundInstance then
        local snd = Instance.new("Sound")
        snd.Name = "FihMenu_AudioStream"
        snd.Looped = true
        snd.Volume = MusicEngine.Volume
        snd.PlaybackSpeed = MusicEngine.Pitch
        snd.Parent = SoundService
        MusicEngine.SoundInstance = snd
    end
end

function MusicEngine.PlaySound(soundId: number, title: string?)
    MusicEngine.Init()
    if MusicEngine.SoundInstance then
        MusicEngine.SoundInstance.SoundId = "rbxassetid://" .. tostring(soundId)
        MusicEngine.SoundInstance:Play()
        MusicEngine.IsPlaying = true
        if title then
            MusicEngine.CurrentSongTitle = title
        end
    end
end

function MusicEngine.Pause()
    if MusicEngine.SoundInstance then
        MusicEngine.SoundInstance:Pause()
        MusicEngine.IsPlaying = false
    end
end

function MusicEngine.Resume()
    if MusicEngine.SoundInstance then
        MusicEngine.SoundInstance:Resume()
        MusicEngine.IsPlaying = true
    end
end

function MusicEngine.SetVolume(v: number)
    MusicEngine.Volume = v
    if MusicEngine.SoundInstance then
        MusicEngine.SoundInstance.Volume = v
    end
end

function MusicEngine.SetPitch(p: number)
    MusicEngine.Pitch = p
    if MusicEngine.SoundInstance then
        MusicEngine.SoundInstance.PlaybackSpeed = p
    end
end

return MusicEngine
