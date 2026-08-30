-- Core/Signal.lua
-- Fast Signal / Event Dispatcher for Luau

local Signal = {}
Signal.__index = Signal

export type Connection = {
    Disconnect: (self: Connection) -> (),
    Connected: boolean,
}

export type SignalType = {
    Connect: (self: SignalType, fn: (...any) -> ()) -> Connection,
    Fire: (self: SignalType, ...any) -> (),
    Destroy: (self: SignalType) -> (),
}

function Signal.new(): SignalType
    local self = setmetatable({}, Signal)
    self._bindable = Instance.new("BindableEvent")
    return (self :: any)
end

function Signal:Connect(fn: (...any) -> ())
    local conn = self._bindable.Event:Connect(fn)
    return {
        Disconnect = function()
            conn:Disconnect()
        end,
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
