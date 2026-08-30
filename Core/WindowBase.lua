-- Core/WindowBase.lua
-- Base Window Architecture: Draggable, Scalable, Layer-Aware Base Window

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local TopZIndex = 10
local WindowBase = {}
WindowBase.__index = WindowBase

function WindowBase.AttachMicroInteractions(button: GuiButton)
    local scale = button:FindFirstChildOfClass("UIScale")
    if not scale then
        scale = Instance.new("UIScale")
        scale.Scale = 1.0
        scale.Parent = button
    end

    button.MouseEnter:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.04 }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.0 }):Play()
    end)
    button.MouseButton1Down:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.94 }):Play()
    end)
    button.MouseButton1Up:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.04 }):Play()
    end)
end

function WindowBase.new(titleText: string, defaultSize: UDim2, defaultPos: UDim2, minSize: Vector2?, screenHost: ScreenGui, themeManager: any, signalMod: any)
    local self = setmetatable({}, WindowBase)
    self.MinSize = minSize or Vector2.new(240, 160)
    self.MaxSize = Vector2.new(1920, 1080)
    self.IsMinimized = false
    self.StoredSize = defaultSize
    self.OnClose = signalMod.new()

    -- Root Window Frame
    local Frame = Instance.new("Frame")
    Frame.Name = titleText .. "_Window"
    Frame.Size = defaultSize
    Frame.Position = defaultPos
    Frame.BackgroundColor3 = themeManager.Get("BackgroundPrimary")
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.ClipsDescendants = false
    Frame.Parent = screenHost
    self.Frame = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = themeManager.Get("Border")
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Frame
    self.Stroke = Stroke

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 28)
    TopBar.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Frame
    self.TopBar = TopBar

    local TopBarBottomLine = Instance.new("Frame")
    TopBarBottomLine.Size = UDim2.new(1, 0, 0, 1)
    TopBarBottomLine.Position = UDim2.new(0, 0, 1, -1)
    TopBarBottomLine.BackgroundColor3 = themeManager.Get("Border")
    TopBarBottomLine.BorderSizePixel = 0
    TopBarBottomLine.Parent = TopBar
    themeManager.RegisterBinding(TopBarBottomLine, "BackgroundColor3", "Border")

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 8, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.Text = string.upper(titleText)
    TitleLabel.TextColor3 = themeManager.Get("TextPrimary")
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar
    self.TitleLabel = TitleLabel

    -- Controls (Min/Close)
    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.Size = UDim2.new(0, 60, 1, 0)
    Controls.Position = UDim2.new(1, -60, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.Parent = TopBar

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 2)
    Layout.Parent = Controls

    local MinBtn = Instance.new("TextButton")
    MinBtn.Name = "MinBtn"
    MinBtn.Size = UDim2.new(0, 24, 0, 20)
    MinBtn.BackgroundColor3 = themeManager.Get("Surface")
    MinBtn.BorderSizePixel = 0
    MinBtn.Font = Enum.Font.Code
    MinBtn.Text = "—"
    MinBtn.TextColor3 = themeManager.Get("TextSecondary")
    MinBtn.TextSize = 11
    MinBtn.AutoButtonColor = false
    MinBtn.Parent = Controls

    local MinStroke = Instance.new("UIStroke")
    MinStroke.Thickness = 1
    MinStroke.Color = themeManager.Get("Border")
    MinStroke.Parent = MinBtn

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 24, 0, 20)
    CloseBtn.BackgroundColor3 = themeManager.Get("Surface")
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = themeManager.Get("TextSecondary")
    CloseBtn.TextSize = 11
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = Controls

    local CloseStroke = Instance.new("UIStroke")
    CloseStroke.Thickness = 1
    CloseStroke.Color = themeManager.Get("Border")
    CloseStroke.Parent = CloseBtn

    -- Main Content Viewport
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, -28)
    Content.Position = UDim2.new(0, 0, 0, 28)
    Content.BackgroundTransparency = 1
    Content.ClipsDescendants = true
    Content.Parent = Frame
    self.Content = Content

    -- Corner Resize Grip
    local Grip = Instance.new("TextButton")
    Grip.Name = "ResizeGrip"
    Grip.Size = UDim2.new(0, 14, 0, 14)
    Grip.AnchorPoint = Vector2.new(1, 1)
    Grip.Position = UDim2.new(1, 0, 1, 0)
    Grip.BackgroundTransparency = 1
    Grip.Text = "◢"
    Grip.Font = Enum.Font.Code
    Grip.TextColor3 = themeManager.Get("TextSecondary")
    Grip.TextSize = 12
    Grip.ZIndex = 5
    Grip.Parent = Frame
    self.Grip = Grip

    -- Focus Layering
    local function BringToFront()
        TopZIndex += 1
        Frame.ZIndex = TopZIndex
        Stroke.Color = themeManager.Get("BorderActive")
    end
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            BringToFront()
        end
    end)

    -- Window Dragging with Viewport Snapping
    local Dragging = false
    local DragStart = Vector2.zero
    local StartPos = UDim2.new()

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = Frame.Position
            BringToFront()

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - DragStart
            local vp = Workspace.CurrentCamera.ViewportSize
            local targetX = StartPos.X.Offset + delta.X
            local targetY = StartPos.Y.Offset + delta.Y

            if targetX < 12 then targetX = 0 end
            if targetY < 12 then targetY = 0 end
            if math.abs((targetX + Frame.AbsoluteSize.X) - vp.X) < 12 then
                targetX = vp.X - Frame.AbsoluteSize.X
            end
            if math.abs((targetY + Frame.AbsoluteSize.Y) - vp.Y) < 12 then
                targetY = vp.Y - Frame.AbsoluteSize.Y
            end

            Frame.Position = UDim2.new(StartPos.X.Scale, targetX, StartPos.Y.Scale, targetY)
        end
    end)

    -- Resizing Logic
    local Resizing = false
    local ResizeStartMouse = Vector2.zero
    local ResizeStartSize = Vector2.zero

    Grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Resizing = true
            ResizeStartMouse = Vector2.new(input.Position.X, input.Position.Y)
            ResizeStartSize = Frame.AbsoluteSize
            BringToFront()

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Resizing = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = Vector2.new(input.Position.X, input.Position.Y)
            local delta = mousePos - ResizeStartMouse
            local newW = math.clamp(ResizeStartSize.X + delta.X, self.MinSize.X, self.MaxSize.X)
            local newH = math.clamp(ResizeStartSize.Y + delta.Y, self.MinSize.Y, self.MaxSize.Y)
            Frame.Size = UDim2.new(0, newW, 0, newH)
        end
    end)

    -- Window Actions
    MinBtn.MouseButton1Click:Connect(function()
        self.IsMinimized = not self.IsMinimized
        if self.IsMinimized then
            self.StoredSize = Frame.Size
            Content.Visible = false
            Grip.Visible = false
            Frame.Size = UDim2.new(0, Frame.AbsoluteSize.X, 0, 28)
            MinBtn.Text = "□"
        else
            Frame.Size = self.StoredSize
            Content.Visible = true
            Grip.Visible = true
            MinBtn.Text = "—"
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        self.OnClose:Fire()
        Frame.Visible = false
    end)

    for _, btn in ipairs({ MinBtn, CloseBtn }) do
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = themeManager.Get("Border")
            btn.TextColor3 = themeManager.Get("TextPrimary")
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = themeManager.Get("Surface")
            btn.TextColor3 = themeManager.Get("TextSecondary")
        end)
    end

    themeManager.RegisterBinding(Frame, "BackgroundColor3", "BackgroundPrimary")
    themeManager.RegisterBinding(TopBar, "BackgroundColor3", "BackgroundSecondary")
    themeManager.RegisterBinding(TitleLabel, "TextColor3", "TextPrimary")
    themeManager.RegisterBinding(Stroke, "Color", "Border")

    return self
end

return WindowBase
