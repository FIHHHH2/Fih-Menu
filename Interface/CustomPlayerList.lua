-- Interface/CustomPlayerList.lua
-- Translucent Domino-Animated Leaderboard & Player Context Drawer

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local CustomPlayerList = {}

function CustomPlayerList.new(windowBase: any, screenHost: ScreenGui, themeManager: any, signalMod: any, flingMod: any)
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) end)

    local PlrWindow = windowBase.new("Players : 0 online", UDim2.new(0, 230, 0, 280), UDim2.new(1, -250, 0, 30), Vector2.new(200, 180), screenHost, themeManager, signalMod)

    local PlayerScroll = Instance.new("ScrollingFrame")
    PlayerScroll.Size = UDim2.new(1, -12, 1, -12)
    PlayerScroll.Position = UDim2.new(0, 6, 0, 6)
    PlayerScroll.BackgroundTransparency = 1
    PlayerScroll.BorderSizePixel = 0
    PlayerScroll.ScrollBarThickness = 3
    PlayerScroll.ScrollBarImageColor3 = themeManager.Get("Border")
    PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    PlayerScroll.Parent = PlrWindow.Content

    local PlrLayout = Instance.new("UIListLayout")
    PlrLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PlrLayout.Padding = UDim.new(0, 4)
    PlrLayout.Parent = PlayerScroll

    -- Context Drawer Window (Translucent & Movable)
    local DrawerWindow = windowBase.new("Select Plr", UDim2.new(0, 180, 0, 230), UDim2.new(1, -440, 0, 30), Vector2.new(160, 180), screenHost, themeManager, signalMod)
    DrawerWindow.Frame.Visible = false

    local DrawerContent = DrawerWindow.Content
    local AvatarImg = Instance.new("ImageLabel")
    AvatarImg.Size = UDim2.new(0, 52, 0, 52)
    AvatarImg.Position = UDim2.new(0, 8, 0, 8)
    AvatarImg.BackgroundColor3 = themeManager.Get("Surface")
    AvatarImg.BackgroundTransparency = 0.3
    AvatarImg.BorderSizePixel = 0
    AvatarImg.Parent = DrawerContent

    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(0, 4)
    AvatarCorner.Parent = AvatarImg

    local AvatarStroke = Instance.new("UIStroke")
    AvatarStroke.Thickness = 1
    AvatarStroke.Color = themeManager.Get("Border")
    AvatarStroke.Parent = AvatarImg

    local PlrNameLabel = Instance.new("TextLabel")
    PlrNameLabel.Size = UDim2.new(1, -70, 0, 24)
    PlrNameLabel.Position = UDim2.new(0, 66, 0, 8)
    PlrNameLabel.BackgroundTransparency = 1
    PlrNameLabel.Font = Enum.Font.Code
    PlrNameLabel.Text = "Name"
    PlrNameLabel.TextColor3 = themeManager.Get("TextPrimary")
    PlrNameLabel.TextSize = 11
    PlrNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    PlrNameLabel.Parent = DrawerContent

    local PlrIdLabel = Instance.new("TextLabel")
    PlrIdLabel.Size = UDim2.new(1, -70, 0, 20)
    PlrIdLabel.Position = UDim2.new(0, 66, 0, 32)
    PlrIdLabel.BackgroundTransparency = 1
    PlrIdLabel.Font = Enum.Font.Code
    PlrIdLabel.Text = "ID: 0"
    PlrIdLabel.TextColor3 = themeManager.Get("TextSecondary")
    PlrIdLabel.TextSize = 9
    PlrIdLabel.TextXAlignment = Enum.TextXAlignment.Left
    PlrIdLabel.Parent = DrawerContent

    local DrawerActionContainer = Instance.new("Frame")
    DrawerActionContainer.Size = UDim2.new(1, -16, 1, -68)
    DrawerActionContainer.Position = UDim2.new(0, 8, 0, 64)
    DrawerActionContainer.BackgroundTransparency = 1
    DrawerActionContainer.Parent = DrawerContent

    local DrawerActionLayout = Instance.new("UIListLayout")
    DrawerActionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DrawerActionLayout.Padding = UDim.new(0, 3)
    DrawerActionLayout.Parent = DrawerActionContainer

    local SelectedTargetPlayer: Player? = nil

    local function CreateDrawerButton(label: string, onClick: () -> ())
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 22)
        btn.BackgroundColor3 = themeManager.Get("Surface")
        btn.BackgroundTransparency = 0.25
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Code
        btn.Text = label
        btn.TextColor3 = themeManager.Get("TextPrimary")
        btn.TextSize = 10
        btn.Parent = DrawerActionContainer

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 3)
        c.Parent = btn

        local s = Instance.new("UIStroke")
        s.Thickness = 1
        s.Color = themeManager.Get("Border")
        s.Transparency = 0.4
        s.Parent = btn

        windowBase.AttachMicroInteractions(btn)
        btn.MouseButton1Click:Connect(onClick)
    end

    CreateDrawerButton("Add Friend", function()
        if SelectedTargetPlayer then
            pcall(function() StarterGui:SetCore("PromptSendFriendRequest", SelectedTargetPlayer) end)
        end
    end)
    CreateDrawerButton("Look At Avatar", function()
        if SelectedTargetPlayer then
            pcall(function() GuiService:InspectPlayerFromUserId(SelectedTargetPlayer.UserId) end)
        end
    end)
    CreateDrawerButton("Spectate", function()
        if SelectedTargetPlayer and SelectedTargetPlayer.Character then
            local hum = SelectedTargetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                Workspace.CurrentCamera.CameraSubject = hum
            end
        end
    end)
    CreateDrawerButton("Teleport To", function()
        if SelectedTargetPlayer and SelectedTargetPlayer.Character then
            local tRoot = SelectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
            if tRoot and myRoot then
                myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 2, 0)
            end
        end
    end)
    CreateDrawerButton("Fling Player", function()
        if SelectedTargetPlayer and flingMod then
            flingMod.FlingPlayer(SelectedTargetPlayer, 0.6)
        end
    end)

    local function OpenDrawer(target: Player)
        SelectedTargetPlayer = target
        DrawerWindow.TitleLabel.Text = string.upper(target.DisplayName)
        PlrNameLabel.Text = target.DisplayName
        PlrIdLabel.Text = "ID: " .. tostring(target.UserId)
        DrawerWindow.Frame.Visible = true

        task.spawn(function()
            local thumb, isReady = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            if isReady then
                AvatarImg.Image = thumb
            end
        end)
    end

    -- Domino Rows
    local PlayerRows = {}
    local function RefreshList()
        local all = Players:GetPlayers()
        PlrWindow.TitleLabel.Text = string.format("PLAYERS : %d ONLINE", #all)

        for _, row in pairs(PlayerRows) do
            row:Destroy()
        end
        table.clear(PlayerRows)

        for i, plr in ipairs(all) do
            local row = Instance.new("TextButton")
            row.Name = "Row_" .. plr.Name
            row.Size = UDim2.new(1, 0, 0, 26)
            row.Position = UDim2.new(1.3, 0, 0, 0)
            row.BackgroundColor3 = themeManager.Get("Surface")
            row.BackgroundTransparency = 0.3
            row.BorderSizePixel = 0
            row.AutoButtonColor = false
            row.Text = ""
            row.Parent = PlayerScroll
            PlayerRows[plr] = row

            local rCorner = Instance.new("UICorner")
            rCorner.CornerRadius = UDim.new(0, 3)
            rCorner.Parent = row

            local rowStroke = Instance.new("UIStroke")
            rowStroke.Thickness = 1
            rowStroke.Color = themeManager.Get("Border")
            rowStroke.Transparency = 0.4
            rowStroke.Parent = row

            local userIcon = Instance.new("TextLabel")
            userIcon.Size = UDim2.new(0, 20, 1, 0)
            userIcon.Position = UDim2.new(0, 4, 0, 0)
            userIcon.BackgroundTransparency = 1
            userIcon.Font = Enum.Font.Code
            userIcon.Text = "👤"
            userIcon.TextColor3 = themeManager.Get("TextSecondary")
            userIcon.TextSize = 11
            userIcon.Parent = row

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, -50, 1, 0)
            nameLbl.Position = UDim2.new(0, 26, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Font = Enum.Font.Code
            nameLbl.Text = plr.DisplayName
            nameLbl.TextColor3 = themeManager.Get("TextPrimary")
            nameLbl.TextSize = 11
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Parent = row

            local indexLbl = Instance.new("TextLabel")
            indexLbl.Size = UDim2.new(0, 20, 1, 0)
            indexLbl.Position = UDim2.new(1, -24, 0, 0)
            indexLbl.BackgroundTransparency = 1
            indexLbl.Font = Enum.Font.Code
            indexLbl.Text = tostring(i)
            indexLbl.TextColor3 = themeManager.Get("TextSecondary")
            indexLbl.TextSize = 10
            indexLbl.Parent = row

            row.MouseButton1Click:Connect(function()
                OpenDrawer(plr)
            end)

            task.delay((i - 1) * 0.035, function()
                if row and row.Parent then
                    TweenService:Create(row, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, 0, 0, 0)
                    }):Play()
                end
            end)
        end
    end

    RefreshList()
    Players.PlayerAdded:Connect(RefreshList)
    Players.PlayerRemoving:Connect(function(plr)
        if PlayerRows[plr] then
            local row = PlayerRows[plr]
            local tw = TweenService:Create(row, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1.3, 0, 0, 0)
            })
            tw:Play()
            tw.Completed:Connect(function()
                row:Destroy()
                PlayerRows[plr] = nil
                PlrWindow.TitleLabel.Text = string.format("PLAYERS : %d ONLINE", #Players:GetPlayers())
            end)
        end
    end)

    return PlrWindow
end

return CustomPlayerList
