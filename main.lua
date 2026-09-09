local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local ACCENT = Color3.fromRGB(0, 110, 255)
local ACCENT_DIM = Color3.fromRGB(60, 140, 255)
local SUCCESS = Color3.fromRGB(80, 200, 120)
local WARN = Color3.fromRGB(255, 200, 60)
local DANGER = Color3.fromRGB(255, 80, 80)

local window = Rayfield:CreateWindow({
    name = "Prison Life",
    subtitle = "Private Testing Suite",
    loadingTitle = "Loading Prison Life...",
    loadingSubtitle = "Initializing modules...",
    sidebarLayout = true,
    accentColor = ACCENT,
    keySystem = false,
})


--------------------------------------------------
-- TABS
--------------------------------------------------

local homeTab = window:CreateTab({
    name = "Home",
    icon = "rbxassetid://130819894305691",
})

local playerTab = window:CreateTab({
    name = "Player",
    icon = "rbxassetid://130819897123675",
})

local combatTab = window:CreateTab({
    name = "Combat",
    icon = "rbxassetid://130819899876543",
})

local visualsTab = window:CreateTab({
    name = "Visuals",
    icon = "rbxassetid://130819902145678",
})

local othersTab = window:CreateTab({
    name = "Others",
    icon = "rbxassetid://130819904567890",
})

local settingsTab = window:CreateTab({
    name = "Settings",
    icon = "rbxassetid://130819906789012",
})


--------------------------------------------------
-- ESP
--------------------------------------------------

local espEnabled = false
local espBox = false
local espName = false
local espHealth = false
local espDistance = false
local espHighlight = false
local espTeamColor = false
local espObjects = {}

local function getTeamColor(player)
    if not player.Team then return Color3.fromRGB(255, 255, 255) end
    return player.TeamColor.Color
end

local function createESP(player)
    if player == LocalPlayer then return end

    local ok1, boxOutline = pcall(function()
        local obj = Drawing.new("Quad")
        obj.Filled = false
        obj.Thickness = 3
        obj.Color = Color3.fromRGB(0, 0, 0)
        obj.Transparency = 0.5
        obj.Visible = false
        return obj
    end)

    local ok2, box = pcall(function()
        local obj = Drawing.new("Quad")
        obj.Filled = false
        obj.Thickness = 1
        obj.Color = Color3.fromRGB(255, 255, 255)
        obj.Visible = false
        return obj
    end)

    local ok3, nameObj = pcall(function()
        local obj = Drawing.new("Text")
        obj.Size = 13
        obj.Center = true
        obj.Outline = true
        obj.Color = Color3.fromRGB(255, 255, 255)
        obj.Visible = false
        return obj
    end)

    local ok4, hpBg = pcall(function()
        local obj = Drawing.new("Line")
        obj.Thickness = 4
        obj.Color = Color3.fromRGB(0, 0, 0)
        obj.Transparency = 0.5
        obj.Visible = false
        return obj
    end)

    local ok5, hpBar = pcall(function()
        local obj = Drawing.new("Line")
        obj.Thickness = 2
        obj.Color = Color3.fromRGB(0, 255, 0)
        obj.Visible = false
        return obj
    end)

    local ok6, distObj = pcall(function()
        local obj = Drawing.new("Text")
        obj.Size = 12
        obj.Center = true
        obj.Outline = true
        obj.Color = Color3.fromRGB(200, 200, 200)
        obj.Visible = false
        return obj
    end)

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.Enabled = false
    highlight.Parent = nil

    espObjects[player] = {
        boxOutline = ok1 and boxOutline or nil,
        box = ok2 and box or nil,
        name = ok3 and nameObj or nil,
        hpBg = ok4 and hpBg or nil,
        hpBar = ok5 and hpBar or nil,
        distance = ok6 and distObj or nil,
        highlight = highlight,
    }
end

local function removeESP(player)
    local objects = espObjects[player]
    if not objects then return end
    pcall(function() if objects.boxOutline then objects.boxOutline:Remove() end end)
    pcall(function() if objects.box then objects.box:Remove() end end)
    pcall(function() if objects.name then objects.name:Remove() end end)
    pcall(function() if objects.hpBg then objects.hpBg:Remove() end end)
    pcall(function() if objects.hpBar then objects.hpBar:Remove() end end)
    pcall(function() if objects.distance then objects.distance:Remove() end end)
    pcall(function() if objects.highlight then objects.highlight:Destroy() end end)
    espObjects[player] = nil
end

local function updateESP()
    local camera = workspace.CurrentCamera
    if not camera then return end

    for player, objects in pairs(espObjects) do
        if not player.Parent or player == LocalPlayer then continue end

        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if not character or not humanoid or not rootPart or humanoid.Health <= 0 then
            pcall(function() if objects.boxOutline then objects.boxOutline.Visible = false end end)
            pcall(function() if objects.box then objects.box.Visible = false end end)
            pcall(function() if objects.name then objects.name.Visible = false end end)
            pcall(function() if objects.hpBg then objects.hpBg.Visible = false end end)
            pcall(function() if objects.hpBar then objects.hpBar.Visible = false end end)
            pcall(function() if objects.distance then objects.distance.Visible = false end end)
            pcall(function() if objects.highlight then objects.highlight.Enabled = false end end)
            continue
        end

        local screenPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)

        if not onScreen then
            pcall(function() if objects.boxOutline then objects.boxOutline.Visible = false end end)
            pcall(function() if objects.box then objects.box.Visible = false end end)
            pcall(function() if objects.name then objects.name.Visible = false end end)
            pcall(function() if objects.hpBg then objects.hpBg.Visible = false end end)
            pcall(function() if objects.hpBar then objects.hpBar.Visible = false end end)
            pcall(function() if objects.distance then objects.distance.Visible = false end end)
            pcall(function() if objects.highlight then objects.highlight.Enabled = false end end)
            continue
        end

        local teamColor = getTeamColor(player)
        local color = espTeamColor and teamColor or Color3.fromRGB(255, 255, 255)

        if espBox and objects.boxOutline and objects.box then
            local headPos = camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
            local legPos = camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height * 0.6
            local tl = Vector2.new(screenPos.X - width / 2, headPos.Y)
            local tr = Vector2.new(screenPos.X + width / 2, headPos.Y)
            local br = Vector2.new(screenPos.X + width / 2, legPos.Y)
            local bl = Vector2.new(screenPos.X - width / 2, legPos.Y)

            objects.boxOutline.PointA = tl
            objects.boxOutline.PointB = tr
            objects.boxOutline.PointC = br
            objects.boxOutline.PointD = bl
            objects.boxOutline.Visible = true

            objects.box.PointA = tl
            objects.box.PointB = tr
            objects.box.PointC = br
            objects.box.PointD = bl
            objects.box.Color = color
            objects.box.Visible = true
        else
            pcall(function() if objects.boxOutline then objects.boxOutline.Visible = false end end)
            pcall(function() if objects.box then objects.box.Visible = false end end)
        end

        if espName and objects.name then
            objects.name.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
            objects.name.Text = player.DisplayName
            objects.name.Color = color
            objects.name.Visible = true
        elseif objects.name then
            objects.name.Visible = false
        end

        if espHealth and objects.hpBg and objects.hpBar then
            local headPos = camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
            local legPos = camera:WorldToViewportPoint(rootPart.Position - Vector3.new(3, 0, 0))
            local height = math.abs(headPos.Y - legPos.Y)
            local barX = screenPos.X - height * 0.6 / 2 - 4
            local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local barTop = headPos.Y
            local barBot = legPos.Y
            local barCurrent = barBot - (barBot - barTop) * hpPercent

            objects.hpBg.From = Vector2.new(barX, barTop)
            objects.hpBg.To = Vector2.new(barX, barBot)
            objects.hpBg.Visible = true

            objects.hpBar.From = Vector2.new(barX, barCurrent)
            objects.hpBar.To = Vector2.new(barX, barBot)

            if hpPercent > 0.5 then
                objects.hpBar.Color = Color3.fromRGB(0, 255, 0)
            elseif hpPercent > 0.25 then
                objects.hpBar.Color = Color3.fromRGB(255, 255, 0)
            else
                objects.hpBar.Color = Color3.fromRGB(255, 0, 0)
            end
            objects.hpBar.Visible = true
        else
            pcall(function() if objects.hpBg then objects.hpBg.Visible = false end end)
            pcall(function() if objects.hpBar then objects.hpBar.Visible = false end end)
        end

        if espDistance and objects.distance then
            local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if localRoot then
                local dist = math.floor((localRoot.Position - rootPart.Position).Magnitude)
                objects.distance.Position = Vector2.new(screenPos.X, screenPos.Y + 10)
                objects.distance.Text = dist .. " studs"
                objects.distance.Visible = true
            else
                objects.distance.Visible = false
            end
        elseif objects.distance then
            objects.distance.Visible = false
        end

        if espHighlight then
            objects.highlight.FillColor = color
            objects.highlight.OutlineColor = color
            objects.highlight.Parent = character
            objects.highlight.Enabled = true
        else
            objects.highlight.Enabled = false
            objects.highlight.Parent = nil
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then createESP(player) end
end

Players.PlayerAdded:Connect(function(player) createESP(player) end)
Players.PlayerRemoving:Connect(function(player) removeESP(player) end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        if espEnabled then
            updateESP()
        else
            for _, objects in pairs(espObjects) do
                pcall(function()
                    if objects.boxOutline then objects.boxOutline.Visible = false end
                    if objects.box then objects.box.Visible = false end
                    if objects.name then objects.name.Visible = false end
                    if objects.hpBg then objects.hpBg.Visible = false end
                    if objects.hpBar then objects.hpBar.Visible = false end
                    if objects.distance then objects.distance.Visible = false end
                    if objects.highlight then
                        objects.highlight.Enabled = false
                        objects.highlight.Parent = nil
                    end
                end)
            end
        end
    end)
end)

visualsTab:CreateDivider({ text = "ESP" })

local espToggleRef = visualsTab:CreateToggle({
    name = "Enable ESP",
    description = "Show player boxes, names, health, and distance",
    currentValue = false,
    callback = function(value)
        espEnabled = value
        window:Toast({ title = "ESP", subtitle = value and "Enabled" or "Disabled", duration = 2 })
    end,
})

visualsTab:CreateDropdown({
    name = "ESP Features",
    description = "Choose what ESP elements to display",
    options = {"Box", "Name", "Health", "Distance", "Highlight", "Team Color"},
    value = {},
    multiSelect = true,
    callback = function(options)
        local selected = type(options) == "table" and options or {}
        espBox = table.find(selected, "Box") ~= nil
        espName = table.find(selected, "Name") ~= nil
        espHealth = table.find(selected, "Health") ~= nil
        espDistance = table.find(selected, "Distance") ~= nil
        espHighlight = table.find(selected, "Highlight") ~= nil
        espTeamColor = table.find(selected, "Team Color") ~= nil
    end,
})


--------------------------------------------------
-- FULLBRIGHT
--------------------------------------------------

local fullbrightEnabled = false
local originalBrightness = nil
local originalAmbient = nil
local originalOutdoorAmbient = nil
local originalFogEnd = nil
local originalFogStart = nil
local originalFogColor = nil

visualsTab:CreateDivider({ text = "Lighting" })

visualsTab:CreateToggle({
    name = "Fullbright",
    description = "Max brightness, remove fog — see everything clearly",
    currentValue = false,
    callback = function(value)
        fullbrightEnabled = value
        if value then
            originalBrightness = Lighting.Brightness
            originalAmbient = Lighting.Ambient
            originalOutdoorAmbient = Lighting.OutdoorAmbient
            originalFogEnd = Lighting.FogEnd
            originalFogStart = Lighting.FogStart
            originalFogColor = Lighting.FogColor

            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
            Lighting.FogColor = Color3.fromRGB(255, 255, 255)
            window:Toast({ title = "Fullbright", subtitle = "Enabled", duration = 2 })
        else
            if originalBrightness then Lighting.Brightness = originalBrightness end
            if originalAmbient then Lighting.Ambient = originalAmbient end
            if originalOutdoorAmbient then Lighting.OutdoorAmbient = originalOutdoorAmbient end
            if originalFogEnd then Lighting.FogEnd = originalFogEnd end
            if originalFogStart then Lighting.FogStart = originalFogStart end
            if originalFogColor then Lighting.FogColor = originalFogColor end
            window:Toast({ title = "Fullbright", subtitle = "Disabled", duration = 2 })
        end
    end,
})


--------------------------------------------------
-- CROSSHAIR
--------------------------------------------------

local crosshairEnabled = false
local crosshairSize = 2
local crosshairGap = 6
local crosshairColor = Color3.fromRGB(255, 255, 255)
local crosshairObjects = {}

local function createCrosshair()
    local lines = {}
    for _ = 1, 4 do
        local success, line = pcall(function() return Drawing.new("Line") end)
        if success and line then
            line.Thickness = crosshairSize
            line.Color = crosshairColor
            line.Visible = false
            table.insert(lines, line)
        end
    end
    crosshairObjects = lines
end

local function removeCrosshair()
    for _, line in ipairs(crosshairObjects) do
        pcall(function() line:Remove() end)
    end
    crosshairObjects = {}
end

local function updateCrosshair()
    if not crosshairEnabled or #crosshairObjects == 0 then
        for _, line in ipairs(crosshairObjects) do line.Visible = false end
        return
    end

    local mousePos = UserInputService:GetMouseLocation()
    local isShiftLock = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
    if isShiftLock then
        for _, line in ipairs(crosshairObjects) do line.Visible = false end
        return
    end

    local x, y = mousePos.X, mousePos.Y
    if crosshairObjects[1] then
        crosshairObjects[1].From = Vector2.new(x, y - crosshairGap)
        crosshairObjects[1].To = Vector2.new(x, y - crosshairGap - 10)
        crosshairObjects[1].Color = crosshairColor
        crosshairObjects[1].Visible = true
    end
    if crosshairObjects[2] then
        crosshairObjects[2].From = Vector2.new(x, y + crosshairGap)
        crosshairObjects[2].To = Vector2.new(x, y + crosshairGap + 10)
        crosshairObjects[2].Color = crosshairColor
        crosshairObjects[2].Visible = true
    end
    if crosshairObjects[3] then
        crosshairObjects[3].From = Vector2.new(x - crosshairGap, y)
        crosshairObjects[3].To = Vector2.new(x - crosshairGap - 10, y)
        crosshairObjects[3].Color = crosshairColor
        crosshairObjects[3].Visible = true
    end
    if crosshairObjects[4] then
        crosshairObjects[4].From = Vector2.new(x + crosshairGap, y)
        crosshairObjects[4].To = Vector2.new(x + crosshairGap + 10, y)
        crosshairObjects[4].Color = crosshairColor
        crosshairObjects[4].Visible = true
    end
end

createCrosshair()

visualsTab:CreateDivider({ text = "Crosshair" })

visualsTab:CreateToggle({
    name = "Enable Crosshair",
    description = "Draw a custom crosshair on your screen",
    currentValue = false,
    callback = function(value)
        crosshairEnabled = value
        if not value then
            for _, line in ipairs(crosshairObjects) do line.Visible = false end
        end
        window:Toast({ title = "Crosshair", subtitle = value and "Enabled" or "Disabled", duration = 2 })
    end,
})

visualsTab:CreateSlider({
    name = "Crosshair Gap",
    description = "Distance from center to crosshair lines",
    range = {2, 20},
    increment = 1,
    suffix = " px",
    currentValue = 6,
    callback = function(value) crosshairGap = value end,
})

visualsTab:CreateSlider({
    name = "Crosshair Size",
    description = "Thickness of each crosshair line",
    range = {1, 5},
    increment = 1,
    suffix = " px",
    currentValue = 2,
    callback = function(value)
        crosshairSize = value
        for _, line in ipairs(crosshairObjects) do line.Thickness = value end
    end,
})


--------------------------------------------------
-- PLAYER HIGHLIGHT
--------------------------------------------------

local highlightEnabled = false
local highlightObjects = {}

local function addHighlight(player)
    if player == LocalPlayer then return end
    local existing = player.Character and player.Character:FindFirstChild("TeamHighlight")
    if existing then existing:Destroy() end

    local highlight = Instance.new("Highlight")
    highlight.Name = "TeamHighlight"
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0

    if player.Team then
        highlight.FillColor = player.TeamColor.Color
        highlight.OutlineColor = player.TeamColor.Color
    else
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    end

    if player.Character then highlight.Parent = player.Character end
    highlightObjects[player] = highlight
end

local function removeHighlight(player)
    local highlight = highlightObjects[player]
    if highlight then
        highlight:Destroy()
        highlightObjects[player] = nil
    end
end

local function refreshHighlights()
    for player, highlight in pairs(highlightObjects) do
        if player.Team then
            highlight.FillColor = player.TeamColor.Color
            highlight.OutlineColor = player.TeamColor.Color
        end
    end
end

visualsTab:CreateDivider({ text = "Player Highlight" })

visualsTab:CreateToggle({
    name = "Team Highlights",
    description = "Outline all players with their team color",
    currentValue = false,
    callback = function(value)
        highlightEnabled = value
        if value then
            for _, player in ipairs(Players:GetPlayers()) do addHighlight(player) end
        else
            for player, _ in pairs(highlightObjects) do removeHighlight(player) end
        end
        window:Toast({ title = "Highlights", subtitle = value and "Enabled" or "Disabled", duration = 2 })
    end,
})

Players.PlayerAdded:Connect(function(player)
    player:GetPropertyChangedSignal("Team"):Connect(function()
        if highlightEnabled then refreshHighlights() end
    end)
    if highlightEnabled then task.wait(0.5) addHighlight(player) end
end)

Players.PlayerRemoving:Connect(function(player) removeHighlight(player) end)

for _, player in ipairs(Players:GetPlayers()) do
    player:GetPropertyChangedSignal("Team"):Connect(function()
        if highlightEnabled then refreshHighlights() end
    end)
end


--------------------------------------------------
-- REMOVE TEXTURES
--------------------------------------------------

local texturesRemoved = false
local removedInstances = {}

visualsTab:CreateDivider({ text = "Performance" })

visualsTab:CreateButton({
    name = "Remove Textures",
    description = "Strip all textures/decals for a massive FPS boost",
    callback = function()
        if texturesRemoved then
            for inst, parent in pairs(removedInstances) do
                if inst and inst.Parent == nil then inst.Parent = parent end
            end
            removedInstances = {}
            texturesRemoved = false
            window:Toast({ title = "Textures", subtitle = "Restored", duration = 2 })
        else
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") then
                    removedInstances[obj] = obj.Parent
                    obj.Parent = nil
                end
            end
            texturesRemoved = true
            window:Toast({ title = "Textures", subtitle = "Removed", duration = 2 })
        end
    end,
})


--------------------------------------------------
-- FREECAM
--------------------------------------------------

local freecamEnabled = false
local freecamSpeed = 50
local fcConn = nil
local fcConn2 = nil
local oldCameraType = nil

local FC_WASD = {
    [Enum.KeyCode.W] = Vector3.new(0, 0, -1),
    [Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
    [Enum.KeyCode.S] = Vector3.new(0, 0, 1),
    [Enum.KeyCode.D] = Vector3.new(1, 0, 0),
    [Enum.KeyCode.Space] = Vector3.new(0, 1, 0),
    [Enum.KeyCode.LeftShift] = Vector3.new(0, -1, 0),
}

local fcKeysDown = {}
local fcDelta = Vector2.new(0, 0)

local function enableFreecam()
    local camera = workspace.CurrentCamera
    oldCameraType = camera.CameraType
    camera.CameraType = Enum.CameraType.Scriptable
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

    fcConn = RunService.RenderStepped:Connect(function(dt)
        if not freecamEnabled then return end
        local moveDir = Vector3.new(0, 0, 0)
        for key, dir in pairs(FC_WASD) do
            if fcKeysDown[key] then moveDir = moveDir + dir end
        end
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end

        local camCF = camera.CFrame
        local forward = camCF.LookVector
        local right = camCF.RightVector
        local up = Vector3.new(0, 1, 0)
        local speed = freecamSpeed
        if fcKeysDown[Enum.KeyCode.LeftControl] then speed = speed * 2 end

        local movement = (right * moveDir.X + up * moveDir.Y + forward * -moveDir.Z) * speed
        local yaw = -fcDelta.X * 0.003
        local pitch = -fcDelta.Y * 0.003
        fcDelta = Vector2.new(0, 0)

        local newCF = camCF * CFrame.Angles(pitch, yaw, 0)
        camera.CFrame = newCF + movement * dt
    end)

    fcConn2 = UserInputService.InputChanged:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            fcDelta = Vector2.new(input.Delta.X, input.Delta.Y)
        end
    end)
end

local function disableFreecam()
    if fcConn then fcConn:Disconnect(); fcConn = nil end
    if fcConn2 then fcConn2:Disconnect(); fcConn2 = nil end
    local camera = workspace.CurrentCamera
    camera.CameraType = oldCameraType or Enum.CameraType.Custom
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    fcKeysDown = {}
    fcDelta = Vector2.new(0, 0)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        freecamEnabled = not freecamEnabled
        if freecamEnabled then enableFreecam() else disableFreecam() end
        return
    end
    if freecamEnabled and FC_WASD[input.KeyCode] then fcKeysDown[input.KeyCode] = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if freecamEnabled and FC_WASD[input.KeyCode] then fcKeysDown[input.KeyCode] = nil end
end)

visualsTab:CreateDivider({ text = "Freecam" })

freecamToggleRef = visualsTab:CreateToggle({
    name = "Enable Freecam",
    description = "WASD + mouse to fly around (Shift+P to toggle)",
    currentValue = false,
    callback = function(value)
        if diedRecently and value then
            window:Popup({
                title = "Rejoin Server?",
                content = "You died recently. Freecam may break after respawn. Rejoin for the best experience.",
                options = {
                    { text = "Continue", style = "primary" },
                    { text = "Rejoin", style = "danger", callback = function()
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end },
                },
            })
            diedRecently = false
        end
        freecamEnabled = value
        if value then
            enableFreecam()
            window:Toast({ title = "Freecam", subtitle = "Enabled — WASD to move", duration = 3 })
        else
            disableFreecam()
            window:Toast({ title = "Freecam", subtitle = "Disabled", duration = 2 })
        end
    end,
})

visualsTab:CreateSlider({
    name = "Freecam Speed",
    description = "Movement studs per second",
    range = {10, 200},
    increment = 5,
    suffix = " studs/s",
    currentValue = 50,
    callback = function(value) freecamSpeed = value end,
})


--------------------------------------------------
-- OTHERS - AUTO GRAB & C4 ESP
--------------------------------------------------

local autoGrabEnabled = false
local autoGrabDistance = 12
local autoGrabCount = 0
local autoGrabWindowStart = 0
local autoGrabMaxPerMinute = 10
local c4EspEnabled = false
local c4EspObjects = {}
local trackedC4s = {}
local trackedGrabbables = {}
local firstSeenGrabbables = {}
local lastAutoGrab = 0
local giverPressedRemote
pcall(function()
    giverPressedRemote = ReplicatedStorage:FindFirstChild("Remotes")
        and ReplicatedStorage.Remotes:FindFirstChild("GiverPressed")
end)

local function isSupportedGrabbable(obj)
    if not obj or not obj:IsA("Model") then return false end
    local name = obj.Name:lower()
    return name:find("keycard", 1, true) ~= nil or name == "m9"
end

local function isOwnedGrabbable(obj)
    local ancestor = obj and obj.Parent
    while ancestor and ancestor ~= workspace do
        if ancestor:FindFirstChildOfClass("Humanoid") then return true end
        if ancestor.Name == "Backpack" then return true end
        ancestor = ancestor.Parent
    end
    return false
end

local function trackGrabbable(obj)
    if isSupportedGrabbable(obj) then trackedGrabbables[obj] = true end
end

local function untrackGrabbable(obj)
    trackedGrabbables[obj] = nil
    firstSeenGrabbables[obj] = nil
end

for _, desc in ipairs(workspace:GetDescendants()) do trackGrabbable(desc) end
workspace.DescendantAdded:Connect(trackGrabbable)
workspace.DescendantRemoving:Connect(untrackGrabbable)

local function updateAutoGrab(now)
    if not autoGrabEnabled or not giverPressedRemote then return end
    if now - lastAutoGrab < 0.05 then return end

    if now - autoGrabWindowStart >= 60 then
        autoGrabCount = 0
        autoGrabWindowStart = now
    end

    if autoGrabCount >= autoGrabMaxPerMinute then
        if now - autoGrabWindowStart < 60 then return end
    end

    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local grabDistanceSq = autoGrabDistance * autoGrabDistance

    for item in pairs(trackedGrabbables) do
        if not item or not item.Parent then
            trackedGrabbables[item] = nil
            firstSeenGrabbables[item] = nil
        elseif isOwnedGrabbable(item) then
            firstSeenGrabbables[item] = nil
        else
            local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true)
            if part then
                local delta = root.Position - part.Position
                local distSq = delta.X * delta.X + delta.Y * delta.Y + delta.Z * delta.Z
                if distSq <= grabDistanceSq then
                    if not firstSeenGrabbables[item] then
                        firstSeenGrabbables[item] = now
                    elseif now - firstSeenGrabbables[item] >= 1 then
                        lastAutoGrab = now
                        autoGrabCount = autoGrabCount + 1
                        firstSeenGrabbables[item] = nil
                        pcall(function() giverPressedRemote:FireServer(item) end)
                        return
                    end
                else
                    firstSeenGrabbables[item] = nil
                end
            end
        end
    end
end

local function isC4Part(part)
    if not part or not part:IsA("BasePart") then return false end
    local name = part.Name:lower()
    local parentName = part.Parent and part.Parent.Name:lower() or ""
    return name == "explosive" or name == "c4" or name == "clientc4"
        or parentName:find("c4") or name:find("c4")
end

local function makeC4Esp(c4Part)
    if c4EspObjects[c4Part] then return c4EspObjects[c4Part] end
    local ok, esp = pcall(function()
        local gui = Instance.new("BillboardGui")
        gui.Name = "C4ESP"
        gui.AlwaysOnTop = true
        gui.Size = UDim2.new(0, 24, 0, 24)
        gui.StudsOffset = Vector3.new(0, 1, 0)
        gui.LightInfluence = 0

        local icon = Instance.new("Frame")
        icon.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        icon.BorderSizePixel = 0
        icon.Size = UDim2.new(0, 14, 0, 14)
        icon.Position = UDim2.new(0.5, -7, 0.5, -7)
        icon.Rotation = 45
        icon.Parent = gui

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.new(0, 0, 0)
        stroke.Thickness = 2
        stroke.Transparency = 0.2
        stroke.Parent = icon

        local pulse = Instance.new("UIStroke")
        pulse.Color = DANGER
        pulse.Thickness = 1
        pulse.Transparency = 0.5
        pulse.Parent = icon

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(0, 60, 0, 14)
        label.Position = UDim2.new(0.5, -30, 1, 2)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextColor3 = DANGER
        label.TextStrokeTransparency = 0.5
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.Text = "C4"
        label.Parent = gui

        return gui
    end)
    if ok and esp then
        c4EspObjects[c4Part] = esp
        return esp
    end
    return nil
end

local function updateC4Esp()
    if not c4EspEnabled then
        for _, e in pairs(c4EspObjects) do pcall(function() e.Parent = nil end) end
        return
    end

    for _, desc in ipairs(workspace:GetDescendants()) do
        if isC4Part(desc) and not trackedC4s[desc] then
            trackedC4s[desc] = true
        end
    end

    for part in pairs(trackedC4s) do
        if part and part:IsDescendantOf(workspace) then
            local esp = makeC4Esp(part)
            if esp then
                esp.Adornee = part
                esp.Parent = (gethui and gethui()) or CoreGui
            end
        else
            trackedC4s[part] = nil
            if c4EspObjects[part] then
                pcall(function() c4EspObjects[part]:Destroy() end)
                c4EspObjects[part] = nil
            end
        end
    end
end

othersTab:CreateDivider({ text = "Auto Grab" })

othersTab:CreateToggle({
    name = "Auto Grab Keycards/M9",
    description = "Automatically pick up nearby keycards and M9s",
    currentValue = false,
    callback = function(value)
        autoGrabEnabled = value
        window:Toast({ title = "Auto Grab", subtitle = value and "Enabled" or "Disabled", duration = 2 })
    end,
})

othersTab:CreateSlider({
    name = "Grab Distance",
    description = "Max distance to grab items from",
    range = {1, 12},
    increment = 1,
    suffix = " studs",
    currentValue = 12,
    callback = function(value) autoGrabDistance = value end,
})

othersTab:CreateDivider({ text = "C4 ESP" })

othersTab:CreateToggle({
    name = "C4 ESP",
    description = "Highlight all deployed C4 with a red marker",
    currentValue = false,
    callback = function(value)
        c4EspEnabled = value
        if not value then
            for _, e in pairs(c4EspObjects) do pcall(function() e.Parent = nil end) end
        end
        window:Toast({ title = "C4 ESP", subtitle = value and "Enabled" or "Disabled", duration = 2 })
    end,
})


--------------------------------------------------
-- HOME
--------------------------------------------------

homeTab:CreateDivider({ text = "Welcome" })

local welcomeText = homeTab:CreateText({
    name = "Welcome home, " .. LocalPlayer.DisplayName .. ".",
    text = "Your private testing dashboard is ready.",
})

task.defer(function()
    local tabPage = homeTab.tabPage
    local element = tabPage:FindFirstChild(welcomeText.name)
    if not element then return end

    local titleRow = element:FindFirstChild("Title")
    if not titleRow then return end

    local titleLabel = titleRow:FindFirstChildWhichIsA("TextLabel")
    if not titleLabel then return end

    titleLabel.Text = ""

    local prefix = Instance.new("TextLabel")
    prefix.Name = "WelcomePrefix"
    prefix.BackgroundTransparency = 1
    prefix.Size = UDim2.new(0, 0, 1, 0)
    prefix.AutomaticSize = Enum.AutomaticSize.X
    prefix.Position = UDim2.new(0, 0, 0, 0)
    prefix.Font = titleLabel.Font
    prefix.TextSize = titleLabel.TextSize
    prefix.TextColor3 = titleLabel.TextColor3
    prefix.TextYAlignment = titleLabel.TextYAlignment
    prefix.Text = "Welcome home, "
    prefix.Parent = titleLabel

    local username = Instance.new("TextLabel")
    username.Name = "GradientUsername"
    username.BackgroundTransparency = 1
    username.Size = UDim2.new(0, 0, 1, 0)
    username.AutomaticSize = Enum.AutomaticSize.X
    username.Position = UDim2.new(0, prefix.TextBounds.X, 0, 0)
    username.Font = titleLabel.Font
    username.TextSize = titleLabel.TextSize
    username.TextColor3 = Color3.new(1, 1, 1)
    username.TextYAlignment = titleLabel.TextYAlignment
    username.Text = LocalPlayer.DisplayName
    username.Parent = titleLabel

    local gradient = Instance.new("UIGradient")
    gradient.Name = "UsernameGradient"
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 110, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 110, 255)),
    })
    gradient.Offset = Vector2.new(-1, 0)
    gradient.Parent = username

    local stroke = Instance.new("UIStroke")
    stroke.Name = "UsernameGlow"
    stroke.Color = ACCENT_DIM
    stroke.Thickness = 1
    stroke.Transparency = 0.35
    stroke.Parent = username

    task.spawn(function()
        while username.Parent do
            gradient.Offset = Vector2.new(-1, 0)
            local tween = TweenService:Create(
                gradient,
                TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
                { Offset = Vector2.new(1, 0) }
            )
            tween:Play()
            tween.Completed:Wait()
        end
    end)
end)


--------------------------------------------------
-- SERVER INFORMATION
--------------------------------------------------

homeTab:CreateDivider({ text = "Information & Actions" })

local serverInfo = homeTab:CreateText({
    name = "Server Information",
    text =
        "Players: Loading...\n" ..
        "Prisoners: Loading...\n" ..
        "Criminals: Loading...\n" ..
        "Cops: Loading...\n" ..
        "Ping: Loading...\n" ..
        "FPS: Loading...",
})

local serverInfoBody = nil

task.defer(function()
    local tabPage = homeTab.tabPage
    local element = tabPage:FindFirstChild(serverInfo.name)
    if not element then return end
    local labels = {}
    for _, child in ipairs(element:GetDescendants()) do
        if child:IsA("TextLabel") then table.insert(labels, child) end
    end
    if #labels >= 2 then serverInfoBody = labels[2] end
end)

task.spawn(function()
    local frames = 0
    local lastFPSUpdate = os.clock()

    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = os.clock()

        if now - lastFPSUpdate >= 1 then
            local fps = frames
            frames = 0
            lastFPSUpdate = now

            local playerCount = #Players:GetPlayers()
            local maxPlayers = Players.MaxPlayers
            local prisoners = 0
            local criminals = 0
            local cops = 0

            for _, player in ipairs(Players:GetPlayers()) do
                if player.Team then
                    local teamName = player.Team.Name:lower()
                    if teamName == "criminals" or teamName == "criminal" then
                        criminals = criminals + 1
                    elseif teamName == "guards" or teamName == "guard" or teamName == "cops" or teamName == "cop" then
                        cops = cops + 1
                    elseif teamName == "inmates" or teamName == "inmate" or teamName == "prisoners" or teamName == "prisoner" then
                        prisoners = prisoners + 1
                    end
                end
            end

            local ping = 0
            local pingSuccess, pingValue = pcall(function() return LocalPlayer:GetNetworkPing() end)
            if pingSuccess and type(pingValue) == "number" then ping = math.floor(pingValue * 1000) end

            if serverInfoBody then
                serverInfoBody.Text = string.format(
                    "Players: %d / %d\n" ..
                    "Prisoners: %d\n" ..
                    "Criminals: %d\n" ..
                    "Cops: %d\n" ..
                    "Ping: %dms\n" ..
                    "FPS: %d",
                    playerCount, maxPlayers, prisoners, criminals, cops, ping, fps
                )
            end
        end
    end)
end)


--------------------------------------------------
-- QUICK ACTIONS
--------------------------------------------------

homeTab:CreateButton({
    name = "Rejoin Server",
    description = "Leave and rejoin the current server",
    callback = function()
        window:Toast({ title = "Rejoining...", subtitle = "Teleporting back", duration = 2 })
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

homeTab:CreateButton({
    name = "Server Hop",
    description = "Find and join a different server",
    callback = function()
        local success, result = pcall(function()
            return game:HttpGet(
                "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            )
        end)

        if not success then
            window:Toast({ title = "Server Hop", subtitle = "Failed to fetch servers", duration = 3 })
            return
        end

        local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(result) end)
        if not decodeSuccess or not data or not data.data then
            window:Toast({ title = "Server Hop", subtitle = "No servers found", duration = 3 })
            return
        end

        for _, server in ipairs(data.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                window:Toast({ title = "Server Hop", subtitle = "Joining new server...", duration = 2 })
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end,
})

homeTab:CreateButton({
    name = "Reset Character",
    description = "Kill your character to respawn",
    callback = function()
        window:Popup({
            title = "Reset Character?",
            content = "This will kill your character. All active features (noclip, infinite jump, freecam) will be toggled off.",
            options = {
                { text = "Cancel", style = "secondary" },
                { text = "Reset", style = "danger", callback = function()
                    local character = LocalPlayer.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid.Health = 0 end
                end },
            },
        })
    end,
})


--------------------------------------------------
-- PLAYER - MOVEMENT
--------------------------------------------------

playerTab:CreateDivider({ text = "Movement" })

local infiniteJump = false
local noclipStatus = false
local diedRecently = false
local noclipToggleRef = nil
local infiniteJumpToggleRef = nil
local freecamToggleRef = nil
local noclipUsageStart = 0
local noclipMaxDuration = 15

infiniteJumpToggleRef = playerTab:CreateToggle({
    name = "Infinite Jump",
    description = "Jump as many times as you want in mid-air",
    currentValue = false,
    callback = function(value)
        if diedRecently and value then
            window:Popup({
                title = "Rejoin Server?",
                content = "You died recently. Some features may break after respawn. Rejoin for the best experience.",
                options = {
                    { text = "Continue", style = "primary" },
                    { text = "Rejoin", style = "danger", callback = function()
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end },
                },
            })
            diedRecently = false
        end
        infiniteJump = value
        window:Toast({ title = "Infinite Jump", subtitle = value and "Enabled" or "Disabled", duration = 2 })
    end,
})

UserInputService.JumpRequest:Connect(function()
    if not infiniteJump then return end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)


--------------------------------------------------
-- NOCLIP (FIXED)
--------------------------------------------------

local function DisconnectHeadCollide()
    local character = LocalPlayer.Character
    if not character then return end

    local head = character:FindFirstChild("Head")
    if not head then return end

    local ok, conns = pcall(function() return getconnections(head:GetPropertyChangedSignal("CanCollide")) end)
    if ok and conns then
        for _, conn in ipairs(conns) do
            pcall(function() conn:Disconnect() end)
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    local head = character:WaitForChild("Head", 10)
    if head then
        task.wait(0.5)
        DisconnectHeadCollide()
        if noclipStatus then
            DisconnectHeadCollide()
        end
    end
end)

if LocalPlayer.Character then
    task.spawn(function()
        task.wait(0.5)
        DisconnectHeadCollide()
    end)
end

RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noclipStatus
        end
    end
end)

noclipToggleRef = playerTab:CreateToggle({
    name = "Noclip",
    description = "Walk through walls and objects (auto-disables after " .. noclipMaxDuration .. "s)",
    currentValue = false,
    callback = function(value)
        if diedRecently and value then
            window:Popup({
                title = "Rejoin Server?",
                content = "Noclip may not work properly after death. Rejoin for the best experience.",
                options = {
                    { text = "Continue", style = "primary" },
                    { text = "Rejoin", style = "danger", callback = function()
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end },
                },
            })
            diedRecently = false
        end

        noclipStatus = value

        if value then
            DisconnectHeadCollide()
            noclipUsageStart = os.clock()

            if noclipToggleRef then
                noclipToggleRef:Lock("Noclip active — max " .. noclipMaxDuration .. "s")
            end

            window:Toast({ title = "Noclip", subtitle = "Enabled — walk through walls", duration = 2 })

            task.spawn(function()
                while noclipStatus do
                    task.wait(1)
                    local elapsed = os.clock() - noclipUsageStart
                    if elapsed >= noclipMaxDuration then
                        noclipStatus = false
                        if noclipToggleRef then
                            noclipToggleRef:Unlock()
                        end
                        window:Notify({
                            title = "Noclip Auto-Disabled",
                            content = "Active for " .. noclipMaxDuration .. "s. Disabled for safety.",
                            duration = 4,
                        })
                        break
                    end
                    if noclipToggleRef then
                        local remaining = math.ceil(noclipMaxDuration - elapsed)
                        noclipToggleRef:Lock("Noclip active — " .. remaining .. "s left")
                    end
                end
            end)
        else
            noclipUsageStart = 0
            if noclipToggleRef then
                noclipToggleRef:Unlock()
            end
            window:Toast({ title = "Noclip", subtitle = "Disabled", duration = 2 })
        end
    end,
})


--------------------------------------------------
-- PLAYER TELEPORT
--------------------------------------------------

playerTab:CreateDivider({ text = "Player Teleport" })

local teleportPlayer = nil
local teleportDistance = 5
local lastTeleportTime = 0
local teleportCooldown = 4
local clickTpButton = nil
local playerTeleportButton = nil
local teleportCooldownActive = false

local function getPlayerOptions()
    local options = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local teamName = player.Team and player.Team.Name or "No Team"
            table.insert(options, player.DisplayName .. " — " .. teamName)
        end
    end
    table.sort(options)
    return options
end

local playerDropdown = playerTab:CreateDropdown({
    name = "Select Player",
    description = "Choose a player to teleport to",
    options = getPlayerOptions(),
    value = "",
    multiSelect = false,
    callback = function(option)
        teleportPlayer = nil
        local selectedStr = type(option) == "table" and option[1] or option
        if not selectedStr or selectedStr == "" then return end
        for _, player in ipairs(Players:GetPlayers()) do
            local teamName = player.Team and player.Team.Name or "No Team"
            local displayName = player.DisplayName .. " — " .. teamName
            if displayName == selectedStr then
                teleportPlayer = player
                break
            end
        end
    end,
})

playerTab:CreateSlider({
    name = "Teleport Distance",
    description = "Studs away from the target player",
    range = {3, 20},
    increment = 1,
    suffix = " studs",
    currentValue = 5,
    callback = function(value) teleportDistance = value end,
})

playerTeleportButton = playerTab:CreateButton({
    name = "Teleport to Player",
    description = "Teleport to the selected player",
    callback = function()
        if teleportCooldownActive then
            window:Toast({ title = "Teleport", subtitle = "Cooldown active", duration = 2 })
            return
        end
        if not teleportPlayer then
            window:Toast({ title = "Teleport", subtitle = "No player selected", duration = 2 })
            return
        end
        if not teleportPlayer.Parent then
            teleportPlayer = nil
            window:Toast({ title = "Teleport", subtitle = "Player left the game", duration = 2 })
            return
        end

        local character = LocalPlayer.Character
        local targetCharacter = teleportPlayer.Character
        if not character or not targetCharacter then return end

        local root = character:FindFirstChild("HumanoidRootPart")
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not root or not targetRoot then return end

        root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, teleportDistance)

        lastTeleportTime = os.clock()
        teleportCooldownActive = true

        if playerTeleportButton then playerTeleportButton:Lock("Cooldown — " .. teleportCooldown .. "s") end
        if clickTpButton then clickTpButton:Lock("Cooldown — " .. teleportCooldown .. "s") end

        window:Toast({ title = "Teleport", subtitle = "Teleported to " .. teleportPlayer.DisplayName, duration = 2 })

        task.delay(teleportCooldown, function()
            teleportCooldownActive = false
            if playerTeleportButton then playerTeleportButton:Unlock() end
            if clickTpButton then clickTpButton:Unlock() end
        end)
    end,
})


--------------------------------------------------
-- ANTI-AFK
--------------------------------------------------

playerTab:CreateDivider({ text = "Utilities" })

local antiAFKConnection = nil

playerTab:CreateToggle({
    name = "Anti-AFK",
    description = "Automatically prevent idle kick",
    currentValue = false,
    callback = function(value)
        if value then
            if antiAFKConnection then antiAFKConnection:Disconnect() end
            antiAFKConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
            window:Toast({ title = "Anti-AFK", subtitle = "Enabled", duration = 2 })
        else
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
            window:Toast({ title = "Anti-AFK", subtitle = "Disabled", duration = 2 })
        end
    end,
})


--------------------------------------------------
-- CLICK TP
--------------------------------------------------

playerTab:CreateDivider({ text = "Click TP" })

clickTpButton = playerTab:CreateButton({
    name = "Click TP (Click to Teleport)",
    description = "Click anywhere to teleport to that spot",
    callback = function()
        if teleportCooldownActive then
            window:Toast({ title = "Click TP", subtitle = "Cooldown active", duration = 2 })
            return
        end

        local camera = workspace.CurrentCamera
        local character = LocalPlayer.Character
        if not camera or not character then return end
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local mousePos = UserInputService:GetMouseLocation()
        local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {character}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude

        local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)
        if result then
            root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
        else
            root.CFrame = CFrame.new(ray.Origin + ray.Direction * 100)
        end

        lastTeleportTime = os.clock()
        teleportCooldownActive = true

        if clickTpButton then clickTpButton:Lock("Cooldown — " .. teleportCooldown .. "s") end
        if playerTeleportButton then playerTeleportButton:Lock("Cooldown — " .. teleportCooldown .. "s") end

        window:Toast({ title = "Click TP", subtitle = "Teleported", duration = 2 })

        task.delay(teleportCooldown, function()
            teleportCooldownActive = false
            if clickTpButton then clickTpButton:Unlock() end
            if playerTeleportButton then playerTeleportButton:Unlock() end
        end)
    end,
})


--------------------------------------------------
-- PLAYER INFORMATION
--------------------------------------------------

playerTab:CreateDivider({ text = "Player Information" })

local selectedInfoPlayer = nil
local c4States = {}

local function getInfoPlayerOptions()
    local options = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local teamName = player.Team and player.Team.Name or "No Team"
            table.insert(options, player.DisplayName .. " — " .. teamName)
        end
    end
    table.sort(options)
    return options
end

local playerInfoDropdown = playerTab:CreateDropdown({
    name = "Select Player",
    description = "Choose a player to view detailed info",
    options = getInfoPlayerOptions(),
    value = "",
    multiSelect = false,
    callback = function(option)
        selectedInfoPlayer = nil
        local selectedStr = type(option) == "table" and option[1] or option
        if not selectedStr or selectedStr == "" then return end
        for _, player in ipairs(Players:GetPlayers()) do
            local teamName = player.Team and player.Team.Name or "No Team"
            local displayName = player.DisplayName .. " — " .. teamName
            if displayName == selectedStr then
                selectedInfoPlayer = player
                break
            end
        end
    end,
})

local playerInfo = playerTab:CreateText({
    name = "Player Information",
    text = "Select a player to view their information."
})

local function getCurrentItem(player)
    local character = player.Character
    if not character then return "None" end
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then return tool.Name end
    return "None"
end

local function getDistance(player)
    local character = LocalPlayer.Character
    local targetCharacter = player.Character
    if not character or not targetCharacter then return nil end
    local root = character:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then return nil end
    return math.floor((root.Position - targetRoot.Position).Magnitude)
end

local function getC4Deployed(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not character or not humanoid or humanoid.Health <= 0 then
        c4States[player] = nil
        return false
    end

    local state = c4States[player]
    if not state or state.character ~= character then
        state = { character = character, hadC4 = false, deployed = false }
        c4States[player] = state
    end

    local c4 = character:FindFirstChild("C4")
    if c4 then state.hadC4 = true; return false end
    if state.hadC4 then state.deployed = true end
    return state.deployed
end


--------------------------------------------------
-- FIND PLAYER INFORMATION BODY
--------------------------------------------------

local playerInfoBody = nil

task.defer(function()
    local tabPage = playerTab.tabPage
    local element = tabPage:FindFirstChild(playerInfo.name)
    if not element then return end

    for _, child in ipairs(element:GetDescendants()) do
        if child:IsA("TextLabel") and child.Text == "Select a player to view their information." then
            playerInfoBody = child
            break
        end
    end

    if not playerInfoBody then
        local labels = {}
        for _, child in ipairs(element:GetDescendants()) do
            if child:IsA("TextLabel") then table.insert(labels, child) end
        end
        if #labels >= 2 then playerInfoBody = labels[2] end
    end
end)


--------------------------------------------------
-- LIVE PLAYER INFORMATION
--------------------------------------------------

task.spawn(function()
    while true do
        task.wait(0.25)
        if playerInfoBody then
            local player = selectedInfoPlayer
            if not player or not player.Parent then
                playerInfoBody.Text = "Select a player to view their information."
            else
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local teamName = player.Team and player.Team.Name or "No Team"
                local distance = getDistance(player)
                local currentItem = getCurrentItem(player)
                local c4Deployed = getC4Deployed(player)
                local health = "N/A"
                if humanoid then health = string.format("%d / %d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth)) end

                playerInfoBody.Text = string.format(
                    "Display Name: %s\n" ..
                    "Username: @%s\n" ..
                    "Team: %s\n" ..
                    "Distance: %s studs\n" ..
                    "Health: %s\n" ..
                    "Current Weapon/Item: %s\n" ..
                    "C4 Deployed: %s",
                    player.DisplayName, player.Name, teamName,
                    distance and tostring(distance) or "N/A",
                    health, currentItem, c4Deployed and "Yes" or "No"
                )
            end
        end
    end
end)


--------------------------------------------------
-- COMBAT / SHIFTLOCK AIMLOCK & TARGETING
--------------------------------------------------

combatTab:CreateDivider({ text = "Shiftlock Aimlock" })

local aimlockEnabled = false
local targetPartName = "Head"
local selectedTeam = {"All"}
local specificTargetPlayers = {}
local fovVisible = false
local fovRadius = 150
local aimSmoothness = 0

local fovCircle = nil
pcall(function()
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.5
    fovCircle.Color = ACCENT
    fovCircle.Filled = false
    fovCircle.Transparency = 1
    fovCircle.Visible = false
end)

local pointerBillboard = Instance.new("BillboardGui")
pointerBillboard.Name = "TargetPointerIcon"
pointerBillboard.Size = UDim2.new(0, 32, 0, 32)
pointerBillboard.StudsOffset = Vector3.new(0, 3, 0)
pointerBillboard.AlwaysOnTop = true

local pointerImage = Instance.new("ImageLabel")
pointerImage.BackgroundTransparency = 1
pointerImage.Size = UDim2.new(1, 0, 1, 0)
pointerImage.Image = "rbxassetid://96977355415228"
pointerImage.Parent = pointerBillboard

local imageLoaded = false
task.spawn(function()
    local ContentProvider = game:GetService("ContentProvider")
    pcall(function()
        ContentProvider:PreloadAsync({pointerImage})
        imageLoaded = pointerImage.IsLoaded
    end)
end)

combatTab:CreateToggle({
    name = "Enable Shiftlock Aimlock",
    description = "Lock camera onto enemies when shiftlock is active",
    currentValue = false,
    callback = function(value)
        aimlockEnabled = value
        window:Toast({ title = "Aimlock", subtitle = value and "Enabled" or "Disabled", duration = 2 })
    end,
})

combatTab:CreateDropdown({
    name = "Target Part",
    description = "Which body part to aim at",
    options = {"Head", "Torso / Chest"},
    value = "Head",
    multiSelect = false,
    callback = function(option)
        targetPartName = type(option) == "table" and option[1] or option
    end,
})

combatTab:CreateDropdown({
    name = "Target Team",
    description = "Which teams to target",
    options = {"All", "Criminals", "Guards", "Inmates"},
    value = {"All"},
    multiSelect = true,
    callback = function(options)
        selectedTeam = type(options) == "table" and options or {options}
    end,
})

combatTab:CreateSlider({
    name = "Aim Smoothness",
    description = "0 = hard snap, 3 = smooth glide",
    range = {0, 3},
    increment = 0.1,
    suffix = "",
    currentValue = 0,
    callback = function(value) aimSmoothness = value end,
})


--------------------------------------------------
-- COMBAT FEATURES
--------------------------------------------------

combatTab:CreateDivider({ text = "Combat Features" })

local combatFeatures = {}
local hitChanceValue = 100
local missSpreadValue = 0
local shieldBreakerEnabled = false
local taserAlwaysHitEnabled = false
local combatSessionStart = 0
local combatWarningShown = false
local combatMaxSession = 180

local function getCurrentGun()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool:GetAttribute("ToolType") == "Gun" then return tool end
    end
    return nil
end

local function isLocalPlayerArrested()
    local character = LocalPlayer.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end

    if character:FindFirstChild("Handcuff")
        or character:FindFirstChild("Handcuffs")
        or character:FindFirstChild("Arrested")
        or character:FindFirstChild("IsArrested") then
        return true
    end

    local props = {"Arrested", "Handcuffed", "IsArrested", "IsHandcuffed"}
    for _, prop in ipairs(props) do
        local success, value = pcall(function() return humanoid:GetAttribute(prop) end)
        if success and value == true then return true end
    end
    return false
end

local function isTargetBehindWall(targetPart)
    if not targetPart then return false end
    local camera = workspace.CurrentCamera
    if not camera then return false end

    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local result = workspace:Raycast(origin, direction, rayParams)
    if result and result.Instance then
        local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
        local targetModel = targetPart:FindFirstAncestorOfClass("Model")
        if hitModel and targetModel and hitModel == targetModel then return false end
        return true
    end
    return false
end

local function isTeamValid(player)
    for _, team in ipairs(selectedTeam) do
        if team == "All" then return true end
    end
    if not player.Team then return false end
    local teamName = player.Team.Name:lower()

    for _, selected in ipairs(selectedTeam) do
        if selected == "Criminals" then
            if teamName == "criminals" or teamName == "criminal" then return true end
        elseif selected == "Guards" then
            if teamName == "guards" or teamName == "guard" or teamName == "cops" or teamName == "cop" then return true end
        elseif selected == "Inmates" then
            if teamName == "inmates" or teamName == "inmate" or teamName == "prisoners" or teamName == "prisoner" then return true end
        end
    end
    return false
end

local function getTargetPartFromCharacter(char)
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end

    if targetPartName == "Head" then
        return char:FindFirstChild("Head")
    else
        return char:FindFirstChild("HumanoidRootPart")
            or char:FindFirstChild("UpperTorso")
            or char:FindFirstChild("Torso")
    end
end

local function getTargetPartForAim(char)
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end

    if shieldBreakerEnabled then
        local shield = char:FindFirstChild("RiotShieldPart")
        if shield and shield:IsA("BasePart") then
            local hp = shield:GetAttribute("Health")
            if hp and hp > 0 then
                local myChar = LocalPlayer.Character
                local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local theirHrp = char:FindFirstChild("HumanoidRootPart")
                if myHrp and theirHrp then
                    local toMe = (myHrp.Position - theirHrp.Position).Unit
                    local dot = toMe:Dot(theirHrp.CFrame.LookVector)
                    if dot > 0.3 then return shield end
                end
            end
        end
    end

    if targetPartName == "Head" then
        return char:FindFirstChild("Head")
    else
        return char:FindFirstChild("HumanoidRootPart")
            or char:FindFirstChild("UpperTorso")
            or char:FindFirstChild("Torso")
    end
end

local function getClosestEnemyPart()
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local localCharacter = LocalPlayer.Character
    if not localCharacter then return nil end
    local localHumanoid = localCharacter:FindFirstChildOfClass("Humanoid")
    if not localHumanoid or localHumanoid.Health <= 0 then return nil end

    local hasWallCheck = table.find(combatFeatures, "Wall Check")
    local hasArrestedCheck = table.find(combatFeatures, "Arrested Check")
    if hasArrestedCheck and isLocalPlayerArrested() then return nil end

    local mousePos = UserInputService:GetMouseLocation()
    local closestPart = nil
    local shortestDist = fovRadius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isTeamValid(player) then
            local part = getTargetPartForAim(player.Character)
            if part then
                if hasWallCheck and isTargetBehindWall(part) then
                else
                    local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closestPart = part
                        end
                    end
                end
            end
        end
    end
    return closestPart
end

combatTab:CreateDropdown({
    name = "Combat Features",
    description = "Toggle silent aim, triggerbot, and more",
    options = {"Silent Aim", "Triggerbot", "Gun Firerate", "No Spread", "Wall Check", "Arrested Check"},
    value = {},
    multiSelect = true,
    callback = function(options)
        combatFeatures = type(options) == "table" and options or {}
    end,
})

combatTab:CreateDivider({ text = "Silent Aim Settings" })

combatTab:CreateSlider({
    name = "Hit Chance",
    description = "Percentage chance your shot redirects to the target",
    range = {0, 100},
    increment = 1,
    suffix = "%",
    currentValue = 100,
    callback = function(value) hitChanceValue = value end,
})

combatTab:CreateSlider({
    name = "Miss Spread",
    description = "How far missed shots spread from the target",
    range = {0, 20},
    increment = 1,
    suffix = "",
    currentValue = 0,
    callback = function(value) missSpreadValue = value end,
})

combatTab:CreateDivider({ text = "Special Features" })

combatTab:CreateToggle({
    name = "Shield Breaker",
    description = "Target riot shields when enemies face you",
    currentValue = false,
    callback = function(value)
        shieldBreakerEnabled = value
        window:Toast({ title = "Shield Breaker", subtitle = value and "Enabled" or "Disabled", duration = 2 })
    end,
})

combatTab:CreateToggle({
    name = "Taser Always Hit",
    description = "Guarantee taser shots connect",
    currentValue = false,
    callback = function(value)
        taserAlwaysHitEnabled = value
        window:Toast({ title = "Taser", subtitle = value and "Always Hit ON" or "Always Hit OFF", duration = 2 })
    end,
})


local function simulateClick()
    pcall(function() mouse1press() end)
    task.delay(0.05, function()
        pcall(function() mouse1release() end)
    end)
end

local triggerbotReactTime = 0
local triggerbotNextShot = 0
local triggerbotTarget = nil

local function handleCombatFeatures()
    local hasTriggerbot = table.find(combatFeatures, "Triggerbot")
    local hasFirerate = table.find(combatFeatures, "Gun Firerate")
    local hasNoSpread = table.find(combatFeatures, "No Spread")
    local hasAnyCombat = hasTriggerbot or table.find(combatFeatures, "Silent Aim")

    if hasAnyCombat then
        if combatSessionStart == 0 then
            combatSessionStart = os.clock()
            combatWarningShown = false
        end
        local elapsed = os.clock() - combatSessionStart
        if elapsed >= combatMaxSession and not combatWarningShown then
            combatWarningShown = true
            window:Notify({
                title = "Long Combat Session",
                content = "Combat features active for " .. math.floor(elapsed / 60) .. " min. Consider taking a break.",
                duration = 6,
            })
        end
    else
        combatSessionStart = 0
        combatWarningShown = false
    end

    local localCharacter = LocalPlayer.Character
    if not localCharacter then return end
    local localHumanoid = localCharacter:FindFirstChildOfClass("Humanoid")
    if not localHumanoid or localHumanoid.Health <= 0 then return end

    if hasTriggerbot then
        local now = os.clock()
        local camera = workspace.CurrentCamera
        if camera then
            local target = getClosestEnemyPart()
            local mousePos = UserInputService:GetMouseLocation()

            if target then
                local targetScreen, onScreen = camera:WorldToViewportPoint(target.Position)
                if onScreen then
                    local distToCrosshair = (Vector2.new(targetScreen.X, targetScreen.Y) - mousePos).Magnitude
                    if distToCrosshair < 80 then
                        if triggerbotTarget ~= target then
                            triggerbotTarget = target
                            triggerbotReactTime = now + math.random(15, 30) / 100
                        end

                        if now >= triggerbotReactTime and now >= triggerbotNextShot then
                            simulateClick()
                            local gun = getCurrentGun()
                            local fireDelay = 0.12
                            if gun then
                                local rate = gun:GetAttribute("FireRate")
                                if type(rate) == "number" and rate > 0 then fireDelay = rate end
                            end
                            local variation = fireDelay * (0.8 + math.random() * 0.4)
                            triggerbotNextShot = now + variation
                        end
                    else
                        triggerbotTarget = nil
                    end
                else
                    triggerbotTarget = nil
                end
            else
                triggerbotTarget = nil
            end
        end
    end

    if hasFirerate then
        local tool = localCharacter:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function()
                local rateKeywords = {"firerate", "fire rate", "cooldown", "delay", "firespeed", "fire speed", "refire", "speed", "rate", "interval", "recovery"}
                for _, child in ipairs(tool:GetDescendants()) do
                    if child:IsA("NumberValue") or child:IsA("IntValue") then
                        local lower = child.Name:lower()
                        for _, kw in ipairs(rateKeywords) do
                            if lower:find(kw) then child.Value = 0.001; break end
                        end
                    end
                end
                for _, attrName in ipairs(tool:GetAttributes()) do
                    local lower = attrName:lower()
                    for _, kw in ipairs(rateKeywords) do
                        if lower:find(kw) then tool:SetAttribute(attrName, 0.001); break end
                    end
                end
            end)
        end
    end

    if hasNoSpread then
        local tool = localCharacter:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function()
                local spreadKeywords = {"spread", "accuracy", "bloom", "cone", "drift", "deviation", "inaccuracy", "scatter", "precision", "wobble", "error"}
                for _, child in ipairs(tool:GetDescendants()) do
                    if child:IsA("NumberValue") or child:IsA("IntValue") then
                        local lower = child.Name:lower()
                        for _, kw in ipairs(spreadKeywords) do
                            if lower:find(kw) then child.Value = 0; break end
                        end
                    end
                end
                for _, attrName in ipairs(tool:GetAttributes()) do
                    local lower = attrName:lower()
                    for _, kw in ipairs(spreadKeywords) do
                        if lower:find(kw) then tool:SetAttribute(attrName, 0); break end
                    end
                end
            end)
        end
    end
end

local origCastRay
local castRayHooked = false

local function setupCastRayHook()
    if castRayHooked then return true end
    local castRayFunc = filtergc("function", {Name = "castRay"}, true)
    if not castRayFunc then return false end

    origCastRay = hookfunction(castRayFunc, function(startPos, targetPos, ...)
        if not table.find(combatFeatures, "Silent Aim") then
            return origCastRay(startPos, targetPos, ...)
        end

        local closestPart = getClosestEnemyPart()
        if closestPart then
            local shouldHit = true
            if hitChanceValue < 100 then
                shouldHit = math.random(1, 100) <= hitChanceValue
            end

            if shouldHit then
                return closestPart, closestPart.Position
            elseif missSpreadValue > 0 then
                local missPos = closestPart.Position + Vector3.new(
                    (math.random() - 0.5) * missSpreadValue,
                    (math.random() - 0.5) * missSpreadValue,
                    (math.random() - 0.5) * missSpreadValue
                )
                return origCastRay(startPos, missPos, ...)
            end
        end

        return origCastRay(startPos, targetPos, ...)
    end)
    return true
end

task.spawn(function()
    while not castRayHooked do
        if setupCastRayHook() then
            castRayHooked = true
            window:Toast({ title = "Silent Aim", subtitle = "Hook installed", duration = 2 })
        end
        task.wait(1)
    end
end)


--------------------------------------------------
-- SPECIFIC TARGET POINTER
--------------------------------------------------

combatTab:CreateDivider({ text = "Specific Target Pointer" })

local function getSpecificPlayerOptions()
    local options = {"None"}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(options, player.DisplayName .. " (@" .. player.Name .. ")")
        end
    end
    table.sort(options, function(a, b)
        if a == "None" then return true end
        if b == "None" then return false end
        return a < b
    end)
    return options
end

local specificTargetDropdown = combatTab:CreateDropdown({
    name = "Target Specific Person",
    description = "Highlight and prioritize a specific player",
    options = getSpecificPlayerOptions(),
    value = {},
    multiSelect = true,
    callback = function(options)
        specificTargetPlayers = {}
        local selected = type(options) == "table" and options or {options}
        for _, selectedStr in ipairs(selected) do
            if selectedStr and selectedStr ~= "" and selectedStr ~= "None" then
                for _, player in ipairs(Players:GetPlayers()) do
                    local formattedName = player.DisplayName .. " (@" .. player.Name .. ")"
                    if formattedName == selectedStr then
                        table.insert(specificTargetPlayers, player)
                        break
                    end
                end
            end
        end
        if #specificTargetPlayers == 0 then pointerBillboard.Parent = nil end
    end,
})


--------------------------------------------------
-- FOV SETTINGS
--------------------------------------------------

combatTab:CreateDivider({ text = "FOV Settings" })

combatTab:CreateToggle({
    name = "Show FOV Circle",
    description = "Display the FOV radius around your cursor",
    currentValue = false,
    callback = function(value)
        fovVisible = value
        window:Toast({ title = "FOV Circle", subtitle = value and "Visible" or "Hidden", duration = 2 })
    end,
})

combatTab:CreateSlider({
    name = "FOV Size",
    description = "Radius of the FOV circle in pixels",
    range = {50, 500},
    increment = 5,
    suffix = " px",
    currentValue = 150,
    callback = function(value) fovRadius = value end,
})

local function isShiftLockActive()
    return UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
end

local function getClosestTarget()
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local localCharacter = LocalPlayer.Character
    if not localCharacter then return nil end
    local localHumanoid = localCharacter:FindFirstChildOfClass("Humanoid")
    if not localHumanoid or localHumanoid.Health <= 0 then return nil end

    for _, sp in ipairs(specificTargetPlayers) do
        if sp and sp.Parent and isTeamValid(sp) then
            local part = getTargetPartFromCharacter(sp.Character)
            if part then
                local hasWallCheck = table.find(combatFeatures, "Wall Check")
                if hasWallCheck and isTargetBehindWall(part) then
                else
                    local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                    local mousePos = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if onScreen and dist <= fovRadius then return part end
                end
            end
        end
    end

    local mousePos = UserInputService:GetMouseLocation()
    local closestTarget = nil
    local shortestDistance = fovRadius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isTeamValid(player) then
            local hasArrestedCheck = table.find(combatFeatures, "Arrested Check")
            if hasArrestedCheck and isLocalPlayerArrested() then break end

            local partToAim = getTargetPartFromCharacter(player.Character)
            if partToAim then
                local hasWallCheck = table.find(combatFeatures, "Wall Check")
                if hasWallCheck and isTargetBehindWall(partToAim) then
                else
                    local screenPos, onScreen = camera:WorldToViewportPoint(partToAim.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestTarget = partToAim
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end


--------------------------------------------------
-- MAIN RENDER LOOP
--------------------------------------------------

RunService.RenderStepped:Connect(function()
    pcall(function()
        local mousePos = UserInputService:GetMouseLocation()
        if fovCircle then
            fovCircle.Position = mousePos
            fovCircle.Radius = fovRadius
            fovCircle.Visible = fovVisible
        end

        local firstTarget = specificTargetPlayers[1]
        if firstTarget and firstTarget.Character then
            local head = firstTarget.Character:FindFirstChild("Head")
            local humanoid = firstTarget.Character:FindFirstChildOfClass("Humanoid")
            if head and humanoid and humanoid.Health > 0 and imageLoaded then
                pointerBillboard.Adornee = head
                pointerBillboard.Parent = head
            else
                pointerBillboard.Parent = nil
            end
        else
            pointerBillboard.Parent = nil
        end

        if aimlockEnabled and isShiftLockActive() then
            local target = getClosestTarget()
            local camera = workspace.CurrentCamera
            if target and camera then
                local targetCFrame = CFrame.new(camera.CFrame.Position, target.Position)
                if aimSmoothness == 0 then
                    camera.CFrame = targetCFrame
                else
                    local lerpAlpha = math.clamp(1 / (aimSmoothness * 6), 0.05, 1)
                    camera.CFrame = camera.CFrame:Lerp(targetCFrame, lerpAlpha)
                end
            end
        end

        handleCombatFeatures()

        local now = os.clock()
        updateAutoGrab(now)
        updateC4Esp()
    end)
end)


--------------------------------------------------
-- DEATH DETECTION & AUTO-DISABLE
--------------------------------------------------

local function onCharacterDied()
    diedRecently = true

    if noclipStatus then
        noclipStatus = false
        if noclipToggleRef then
            noclipToggleRef:Set(false)
            noclipToggleRef:Unlock()
        end
        window:Toast({ title = "Noclip", subtitle = "Toggled off (died)", duration = 3 })
    end

    if infiniteJump then
        infiniteJump = false
        if infiniteJumpToggleRef then
            infiniteJumpToggleRef:Set(false)
        end
        window:Toast({ title = "Infinite Jump", subtitle = "Toggled off (died)", duration = 3 })
    end

    if freecamEnabled then
        freecamEnabled = false
        disableFreecam()
        if freecamToggleRef then
            freecamToggleRef:Set(false)
        end
        window:Toast({ title = "Freecam", subtitle = "Toggled off (died)", duration = 3 })
    end

    task.delay(5, function()
        diedRecently = false
    end)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            onCharacterDied()
        end)
    end

    if noclipStatus then
        task.spawn(function()
            task.wait(0.5)
            DisconnectHeadCollide()
        end)
    end
end)

if LocalPlayer.Character then
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            onCharacterDied()
        end)
    end
end


--------------------------------------------------
-- PLAYER LIST REFRESHING
--------------------------------------------------

local function refreshPlayerDropdowns()
    playerDropdown:Refresh(getPlayerOptions())
    playerInfoDropdown:Refresh(getInfoPlayerOptions())
    specificTargetDropdown:Refresh(getSpecificPlayerOptions())
end

Players.PlayerAdded:Connect(function(player)
    player:GetPropertyChangedSignal("Team"):Connect(function()
        refreshPlayerDropdowns()
    end)
    task.wait(0.1)
    refreshPlayerDropdowns()
end)

Players.PlayerRemoving:Connect(function(player)
    if player == teleportPlayer then teleportPlayer = nil end
    if player == selectedInfoPlayer then selectedInfoPlayer = nil end
    for i, sp in ipairs(specificTargetPlayers) do
        if sp == player then
            table.remove(specificTargetPlayers, i)
            break
        end
    end
    if #specificTargetPlayers == 0 then pointerBillboard.Parent = nil end
    c4States[player] = nil
    task.wait(0.1)
    refreshPlayerDropdowns()
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player:GetPropertyChangedSignal("Team"):Connect(function()
            refreshPlayerDropdowns()
        end)
    end
end


--------------------------------------------------
-- SETTINGS
--------------------------------------------------

settingsTab:CreateDivider({ text = "Actions" })

settingsTab:CreateButton({
    name = "Unload Script",
    description = "Remove all ESP, hooks, and clean up the UI",
    callback = function()
        window:Popup({
            title = "Unload Script?",
            content = "This will remove all visual elements, hooks, and clean up. You will need to re-execute to use the script again.",
            options = {
                { text = "Cancel", style = "secondary" },
                { text = "Unload", style = "danger", callback = function()
                    pcall(function() pointerBillboard:Destroy() end)
                    pcall(function() if fovCircle then fovCircle:Remove() end end)
                    for _, e in pairs(c4EspObjects) do
                        pcall(function() e:Destroy() end)
                    end
                    c4EspObjects = {}
                    window:Unload()
                end },
            },
        })
    end,
})

settingsTab:CreateDivider({ text = "About" })

settingsTab:CreateText({
    name = "Script Info",
    text = "Prison Life Testing Suite\nVersion 2.0\n\nFeatures: ESP, Noclip, Silent Aim, Triggerbot, Freecam, Auto Grab, and more.\n\nBuilt with Rayfield Gen2.",
})

window:Notify({
    title = "Script Loaded",
    content = "Prison Life Testing Suite is ready. All modules initialized.",
    duration = 5,
})
