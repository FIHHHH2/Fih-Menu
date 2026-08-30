-- Storage/KeybindRegistry.lua
-- Global Hotkey Dispatcher

local UserInputService = game:GetService("UserInputService")

local KeybindRegistry = {
    Bindings = {},
}

function KeybindRegistry.Register(name: string, keyCode: Enum.KeyCode, callback: () -> ())
    KeybindRegistry.Bindings[name] = { KeyCode = keyCode, Callback = callback }
end

function KeybindRegistry.Unregister(name: string)
    KeybindRegistry.Bindings[name] = nil
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        for _, bind in pairs(KeybindRegistry.Bindings) do
            if bind.KeyCode == input.KeyCode then
                pcall(bind.Callback)
            end
        end
    end
end)

return KeybindRegistry
