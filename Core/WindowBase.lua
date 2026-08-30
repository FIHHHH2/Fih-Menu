-- Core/WindowBase.lua
-- Robust Draggable & Resizable Translucent Base Window Architecture

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local TopZIndex = 25
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
        TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.03 }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.0 }):Play()
    end)
    button.MouseButton1Down:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.96 }):Play()
    end)
    button.MouseButton1Up:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.03 }):Play()
    end)
end

function WindowBase.new(titleText: string, defaultSize: UDim2, initialPos: UDim2, minSize: Vector2?, screenHost: ScreenGui, themeManager: any, signalMod: any)
    local self = setmetatable({}, WindowBase)
    self.MinSize = minSize or Vector2.new(240, 160)
    self.MaxSize = Vector2.new(1920, 1080)
    self.IsMinimized = false
    self.StoredSize = defaultSize
    self.OnClose = signalMod.new()

    -- Compute Pure Absolute Pixel Starting Position (Resolves Mixed Scale Bugs)
    local vp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local initX = initialPos.X.Scale * vp.X + initialPos.X.Offset
    local initY = initialPos.Y.Scale * vp.Y + initialPos.Y.Offset

    -- Root Translucent Window Frame
    local Frame = Instance.new("Frame")
    Frame.Name = titleText .. "_Window"
    Frame.Size = defaultSize
    Frame.Position = UDim2.new(0, math.clamp(initX, 0, vp.X - 100), 0, math.clamp(initY, 0, vp.Y - 50))
    Frame.BackgroundColor3 = themeManager.Get("BackgroundPrimary")
    Frame.BackgroundTransparency = themeManager.GetTransparency("BackgroundPrimary")
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.ClipsDescendants = false
    Frame.ZIndex = TopZIndex
    Frame.Parent = screenHost
    self.Frame = Frame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = themeManager.Get("Border")
    Stroke.Transparency = themeManager.GetTransparency("Border")
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Frame
    self.Stroke = Stroke

    -- Top Bar (Drag Handle)
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 28)
    TopBar.BackgroundColor3 = themeManager.Get("BackgroundSecondary")
    TopBar.BackgroundTransparency = themeManager.GetTransparency("BackgroundSecondary")
    TopBar.BorderSizePixel = 0
    TopBar.Active = true
    TopBar.Parent = Frame
    self.TopBar = TopBar

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 4)
    TopCorner.Parent = TopBar

    local TopBarBottomLine = Instance.new("Frame")
    TopBarBottomLine.Size = UDim2.new(1, 0, 0, 1)
    TopBarBottomLine.Position = UDim2.new(0, 0, 1, -1)
    TopBarBottomLine.BackgroundColor3 = themeManager.Get("Border")
    TopBarBottomLine.BackgroundTransparency = 0.5
    TopBarBottomLine.BorderSizePixel = 0
    TopBarBottomLine.Parent = TopBar
    themeManager.RegisterBinding(TopBarBottomLine, "BackgroundColor3", "Border")

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -120, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.Text = string.upper(titleText)
    TitleLabel.TextColor3 = themeManager.Get("TextPrimary")
    TitleLabel.TextSize = 12
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar
    self.TitleLabel = TitleLabel

    -- Controls (Min & Close)
    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.Size = UDim2.new(0, 58, 1, 0)
    Controls.Position = UDim2.new(1, -62, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.ZIndex = 15
    Controls.Parent = TopBar

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 3)
    Layout.Parent = Controls

    local MinBtn = Instance.new("TextButton")
    MinBtn.Name = "MinBtn"
    MinBtn.Size = UDim2.new(0, 22, 0, 20)
    MinBtn.BackgroundColor3 = themeManager.Get("Surface")
    MinBtn.BackgroundTransparency = 0.3
    MinBtn.BorderSizePixel = 0
    MinBtn.Font = Enum.Font.Code
    MinBtn.Text = "—"
    MinBtn.TextColor3 = themeManager.Get("TextSecondary")
    MinBtn.TextSize = 11
    MinBtn.AutoButtonColor = false
    MinBtn.ZIndex = 16
    MinBtn.Parent = Controls

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 3)
    MinCorner.Parent = MinBtn

    local MinStroke = Instance.new("UIStroke")
    MinStroke.Thickness = 1
    MinStroke.Color = themeManager.Get("Border")
    MinStroke.Transparency = 0.4
    MinStroke.Parent = MinBtn

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 22, 0, 20)
    CloseBtn.BackgroundColor3 = themeManager.Get("Surface")
    CloseBtn.BackgroundTransparency = 0.3
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = themeManager.Get("TextSecondary")
    CloseBtn.TextSize = 11
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 16
    CloseBtn.Parent = Controls

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 3)
    CloseCorner.Parent = CloseBtn

    local CloseStroke = Instance.new("UIStroke")
    CloseStroke.Thickness = 1
    CloseStroke.Color = themeManager.Get("Border")
    CloseStroke.Transparency = 0.4
    CloseStroke.Parent = CloseBtn

    -- Content Viewport
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
    Grip.Size = UDim2.new(0, 16, 0, 16)
    Grip.AnchorPoint = Vector2.new(1, 1)
    Grip.Position = UDim2.new(1, -2, 1, -2)
    Grip.BackgroundTransparency = 1
    Grip.Text = "◢"
    Grip.Font = Enum.Font.Code
    Grip.TextColor3 = themeManager.Get("TextSecondary")
    Grip.TextSize = 13
    Grip.ZIndex = 20
    Grip.Parent = Frame
    self.Grip = Grip

    -- Focus Layering
    local function BringToFront()
        TopZIndex += 1
        Frame.ZIndex = TopZIndex
        Stroke.Color = themeManager.Get("BorderActive")
        Stroke.Transparency = 0
        task.delay(0.5, function()
            if Frame and Frame.Parent and Stroke then
                Stroke.Color = themeManager.Get("Border")
                Stroke.Transparency = themeManager.GetTransparency("Border")
            end
        end)
    end

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            BringToFront()
        end
    end)

    -- Normalized Pixel-Accurate Window Dragging
    local Dragging = false
    local DragStartMouse = Vector2.zero
    local DragStartPos = Vector2.zero

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStartMouse = Vector2.new(input.Position.X, input.Position.Y)
            DragStartPos = Vector2.new(Frame.AbsolutePosition.X, Frame.AbsolutePosition.Y)
            BringToFront()
        end
    end)

    -- Normalized Pixel-Accurate Resizing
    local Resizing = false
    local ResizeStartMouse = Vector2.zero
    local ResizeStartSize = Vector2.zero

    Grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Resizing = true
            ResizeStartMouse = Vector2.new(input.Position.X, input.Position.Y)
            ResizeStartSize = Frame.AbsoluteSize
            BringToFront()
        end
    end)

    -- Global Input Changed
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local currentVp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)

            if Dragging then
                local currentMouse = Vector2.new(input.Position.X, input.Position.Y)
                local delta = currentMouse - DragStartMouse
                local targetX = DragStartPos.X + delta.X
                local targetY = DragStartPos.Y + delta.Y

                -- Clamp within Viewport
                targetX = math.clamp(targetX, 0, currentVp.X - Frame.AbsoluteSize.X)
                targetY = math.clamp(targetY, 0, currentVp.Y - Frame.AbsoluteSize.Y)

                -- Viewport Edge Snapping (< 14px)
                if targetX < 14 then targetX = 0 end
                if targetY < 14 then targetY = 0 end
                if math.abs((targetX + Frame.AbsoluteSize.X) - currentVp.X) < 14 then
                    targetX = currentVp.X - Frame.AbsoluteSize.X
                end
                if math.abs((targetY + Frame.AbsoluteSize.Y) - currentVp.Y) < 14 then
                    targetY = currentVp.Y - Frame.AbsoluteSize.Y
                end

                Frame.Position = UDim2.new(0, targetX, 0, targetY)
            elseif Resizing then
                local currentMouse = Vector2.new(input.Position.X, input.Position.Y)
                local delta = currentMouse - ResizeStartMouse
                local newW = math.clamp(ResizeStartSize.X + delta.X, self.MinSize.X, currentVp.X - Frame.AbsolutePosition.X)
                local newH = math.clamp(ResizeStartSize.Y + delta.Y, self.MinSize.Y, currentVp.Y - Frame.AbsolutePosition.Y)

                Frame.Size = UDim2.new(0, newW, 0, newH)
            end
        end
    end)

    -- Global Input Ended (Never Drops Drag/Resize)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            Resizing = false
        end
    end)

    -- Minimize Action
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

    -- Close Action
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
