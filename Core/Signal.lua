-- Core/Signal.lua
local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({}, Signal)
    self._bindable = Instance.new("BindableEvent")
    return self
end

function Signal:Connect(fn)
    local conn = self._bindable.Event:Connect(fn)
    return {
        Disconnect = function() conn:Disconnect() end,
        Connected = true,
    }
end

function Signal:Fire(...)
    self._bindable:Fire(...)
end

function Signal:Destroy()
    self._bindable:Destroy()
end

return Signal
