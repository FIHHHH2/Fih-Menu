-- Interface/CustomChat.lua
-- CoreGui Chat Subsystem Replacement with Waveform Monitor and Quick Macros

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local CustomChat = {}

function CustomChat.new(windowBase: any, screenHost: ScreenGui, themeManager: any, signalMod: any)
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false) end)

    local ChatWindow = windowBase.new("Chat", UDim2.new(0, 320, 0, 240), UDim2.new(0, 20, 1, -260), Vector2.new(260, 180), screenHost, themeManager, signalMod)

    -- TopBar Voice Chat Waveform Monitor
    local ChatTopControls = Instance.new("Frame")
    ChatTopControls.Size = UDim2.new(0, 70, 1, 0)
    ChatTopControls.Position = UDim2.new(0, 50, 0, 0)
    ChatTopControls.BackgroundTransparency = 1
    ChatTopControls.Parent = ChatWindow.TopBar

    local WaveformBar = Instance.new("Frame")
    WaveformBar.Size = UDim2.new(0, 24, 0, 10)
    WaveformBar.Position = UDim2.new(0, 0, 0.5, -5)
    WaveformBar.BackgroundColor3 = themeManager.Get("Surface")
    WaveformBar.BorderSizePixel = 0
    WaveformBar.Parent = ChatTopControls

    local WaveStroke = Instance.new("UIStroke")
    WaveStroke.Thickness = 1
    WaveStroke.Color = themeManager.Get("Border")
    WaveStroke.Parent = WaveformBar

    local WaveFill = Instance.new("Frame")
    WaveFill.Size = UDim2.new(0.5, 0, 1, 0)
    WaveFill.BackgroundColor3 = themeManager.Get("Accent")
    WaveFill.BorderSizePixel = 0
    WaveFill.Parent = WaveformBar
    themeManager.RegisterBinding(WaveFill, "BackgroundColor3", "Accent")

    task.spawn(function()
        while true do
            task.wait(0.1)
            local amp = math.clamp(math.noise(tick() * 3, 0, 0) * 1.5, 0.1, 1.0)
            WaveFill.Size = UDim2.new(amp, 0, 1, 0)
        end
    end)

    -- Message Scroll Viewport
    local MessageScroll = Instance.new("ScrollingFrame")
    MessageScroll.Name = "Messages"
    MessageScroll.Size = UDim2.new(1, -8, 1, -34)
    MessageScroll.Position = UDim2.new(0, 4, 0, 4)
    MessageScroll.BackgroundTransparency = 1
    MessageScroll.BorderSizePixel = 0
    MessageScroll.ScrollBarThickness = 3
    MessageScroll.ScrollBarImageColor3 = themeManager.Get("Border")
    MessageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    MessageScroll.Parent = ChatWindow.Content

    local MsgLayout = Instance.new("UIListLayout")
    MsgLayout.SortOrder = Enum.SortOrder.LayoutOrder
    MsgLayout.Padding = UDim.new(0, 4)
    MsgLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    MsgLayout.Parent = MessageScroll

    local function AddChatMessage(sender: string, text: string, colorHex: string?)
        local hex = colorHex or "55AAFF"
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -6, 0, 0)
        lbl.AutomaticSize = Enum.AutomaticSize.Y
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Code
        lbl.RichText = true
        lbl.Text = string.format("[USER] <font color=\"#%s\"><b>%s</b></font>: %s", hex, sender, text)
        lbl.TextColor3 = themeManager.Get("TextPrimary")
        lbl.TextSize = 12
        lbl.TextWrapped = true
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = MessageScroll

        MessageScroll.CanvasPosition = Vector2.new(0, MessageScroll.AbsoluteCanvasSize.Y)
    end

    -- Bottom Chat Bar
    local ChatInputBar = Instance.new("Frame")
    ChatInputBar.Size = UDim2.new(1, -8, 0, 24)
    ChatInputBar.Position = UDim2.new(0, 4, 1, -26)
    ChatInputBar.BackgroundColor3 = themeManager.Get("Surface")
    ChatInputBar.BorderSizePixel = 0
    ChatInputBar.Parent = ChatWindow.Content

    local ChatInputStroke = Instance.new("UIStroke")
    ChatInputStroke.Thickness = 1
    ChatInputStroke.Color = themeManager.Get("Border")
    ChatInputStroke.Parent = ChatInputBar

    local QuickBtn = Instance.new("TextButton")
    QuickBtn.Size = UDim2.new(0, 46, 1, 0)
    QuickBtn.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
    QuickBtn.BorderSizePixel = 0
    QuickBtn.Font = Enum.Font.Code
    QuickBtn.Text = "Quick"
    QuickBtn.TextColor3 = themeManager.Get("TextSecondary")
    QuickBtn.TextSize = 10
    QuickBtn.Parent = ChatInputBar

    local ChatBox = Instance.new("TextBox")
    ChatBox.Size = UDim2.new(1, -94, 1, 0)
    ChatBox.Position = UDim2.new(0, 48, 0, 0)
    ChatBox.BackgroundTransparency = 1
    ChatBox.Font = Enum.Font.Code
    ChatBox.PlaceholderText = "TYPE HERE..."
    ChatBox.PlaceholderColor3 = themeManager.Get("TextSecondary")
    ChatBox.Text = ""
    ChatBox.TextColor3 = themeManager.Get("TextPrimary")
    ChatBox.TextSize = 11
    ChatBox.ClearTextOnFocus = false
    ChatBox.TextXAlignment = Enum.TextXAlignment.Left
    ChatBox.Parent = ChatInputBar

    local SendBtn = Instance.new("TextButton")
    SendBtn.Size = UDim2.new(0, 44, 1, 0)
    SendBtn.Position = UDim2.new(1, -44, 0, 0)
    SendBtn.BackgroundColor3 = themeManager.Get("Accent")
    SendBtn.BorderSizePixel = 0
    SendBtn.Font = Enum.Font.Code
    SendBtn.Text = "Send"
    SendBtn.TextColor3 = Color3.new(1, 1, 1)
    SendBtn.TextSize = 10
    SendBtn.Parent = ChatInputBar
    themeManager.RegisterBinding(SendBtn, "BackgroundColor3", "Accent")

    local function Transmit(msg: string)
        if string.len(msg) == 0 then return end
        AddChatMessage(LocalPlayer.DisplayName, msg, "55AAFF")
        ChatBox.Text = ""

        task.spawn(function()
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                local general = TextChatService:WaitForChild("TextChannels", 2)
                if general and general:FindFirstChild("RBXGeneral") then
                    (general.RBXGeneral :: any):SendAsync(msg)
                end
            else
                local sayEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                if sayEvent and sayEvent:FindFirstChild("SayMessageRequest") then
                    sayEvent.SayMessageRequest:FireServer(msg, "All")
                end
            end
        end)
    end

    SendBtn.MouseButton1Click:Connect(function() Transmit(ChatBox.Text) end)
    ChatBox.FocusLost:Connect(function(enter) if enter then Transmit(ChatBox.Text) end end)

    -- Quick Chat Macro Panel
    local MacroFrame = Instance.new("Frame")
    MacroFrame.Size = UDim2.new(0, 120, 0, 90)
    MacroFrame.Position = UDim2.new(0, 4, 1, -120)
    MacroFrame.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
    MacroFrame.BorderSizePixel = 0
    MacroFrame.Visible = false
    MacroFrame.ZIndex = 8
    MacroFrame.Parent = ChatWindow.Content

    local MacroStroke = Instance.new("UIStroke")
    MacroStroke.Thickness = 1
    MacroStroke.Color = themeManager.Get("Border")
    MacroStroke.Parent = MacroFrame

    local MacroLayout = Instance.new("UIListLayout")
    MacroLayout.SortOrder = Enum.SortOrder.LayoutOrder
    MacroLayout.Padding = UDim.new(0, 2)
    MacroLayout.Parent = MacroFrame

    local QuickMacros = { "gg", "nice shot!", "hello everyone", "lagging rn" }
    for _, macro in ipairs(QuickMacros) do
        local mBtn = Instance.new("TextButton")
        mBtn.Size = UDim2.new(1, 0, 0, 20)
        mBtn.BackgroundColor3 = themeManager.Get("Surface")
        mBtn.BorderSizePixel = 0
        mBtn.Font = Enum.Font.Code
        mBtn.Text = macro
        mBtn.TextColor3 = themeManager.Get("TextPrimary")
        mBtn.TextSize = 10
        mBtn.ZIndex = 9
        mBtn.Parent = MacroFrame
        mBtn.MouseButton1Click:Connect(function()
            Transmit(macro)
            MacroFrame.Visible = false
        end)
    end

    QuickBtn.MouseButton1Click:Connect(function()
        MacroFrame.Visible = not MacroFrame.Visible
    end)

    return ChatWindow
end

return CustomChat
