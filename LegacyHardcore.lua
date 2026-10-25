repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local LatestRoom = game.ReplicatedStorage.GameData.LatestRoom
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Fog: approximately 25% stronger than the original
Lighting.FogStart = 7.5
Lighting.FogEnd = 56.25

local activeCaptionGui = nil
local captionGeneration = 0

local function IsPaintingTitle(obj)
    return obj:IsA("TextLabel")
        and string.find(
            string.lower(obj.Text or ""),
            "this painting is titled",
            1,
            true
        ) ~= nil
end

local function ShowCaption(text, duration)
    local pGui = Player:WaitForChild("PlayerGui")

    captionGeneration += 1
    local myGeneration = captionGeneration

    if activeCaptionGui then
        activeCaptionGui:Destroy()
        activeCaptionGui = nil
    end

    duration = duration or 4
    local endTime = os.clock() + duration

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OldHardcoreCaption"
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999
    screenGui.Parent = pGui
    activeCaptionGui = screenGui

    local captionLabel = Instance.new("TextLabel")
    captionLabel.Size = UDim2.new(0.94, 0, 0.12, 0)
    captionLabel.Position = UDim2.new(0.5, 0, 0.89, -60)
    captionLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    captionLabel.BackgroundTransparency = 1
    captionLabel.Text = text
    captionLabel.TextColor3 = Color3.fromRGB(255, 222, 189)
    captionLabel.TextSize = 46
    captionLabel.Font = Enum.Font.Oswald
    captionLabel.TextStrokeTransparency = 1
    captionLabel.TextWrapped = true
    captionLabel.Parent = screenGui

    local alertSound = Instance.new("Sound")
    alertSound.SoundId = "rbxassetid://3848738542"
    alertSound.Parent = game.SoundService
    alertSound:Play()
    game.Debris:AddItem(alertSound, 2)

    task.spawn(function()
        local paintingTitles = {}
        local titleConnections = {}
        local paintingTitleActiveUntil = 0

        local function TrackPaintingTitle(obj)
            if not IsPaintingTitle(obj) or paintingTitles[obj] then
                return
            end

            paintingTitles[obj] = true
            titleConnections[obj] = {}

            table.insert(
                titleConnections[obj],
                obj:GetPropertyChangedSignal("Text"):Connect(function()
                    if IsPaintingTitle(obj) then
                        paintingTitleActiveUntil = os.clock() + 0.25
                    end
                end)
            )

            table.insert(
                titleConnections[obj],
                obj:GetPropertyChangedSignal("Visible"):Connect(function()
                    if obj.Visible and IsPaintingTitle(obj) then
                        paintingTitleActiveUntil = os.clock() + 0.25
                    end
                end)
            )
        end

        for _, obj in ipairs(pGui:GetDescendants()) do
            TrackPaintingTitle(obj)
        end

        local descendantConnection = pGui.DescendantAdded:Connect(function(obj)
            if obj:IsA("TextLabel") then
                TrackPaintingTitle(obj)
            end
        end)

        while myGeneration == captionGeneration
            and screenGui.Parent
            and os.clock() < endTime do

            local paintingTitleVisible = false

            for obj in pairs(paintingTitles) do
                if not obj.Parent then
                    paintingTitles[obj] = nil

                    if titleConnections[obj] then
                        for _, connection in ipairs(titleConnections[obj]) do
                            connection:Disconnect()
                        end
                        titleConnections[obj] = nil
                    end
                elseif IsPaintingTitle(obj) and obj.Visible then
                    paintingTitleVisible = true
                end
            end

            if paintingTitleVisible then
                paintingTitleActiveUntil = os.clock() + 0.25
            end

            captionLabel.Visible =
                not paintingTitleVisible
                and os.clock() >= paintingTitleActiveUntil

            task.wait(0.05)
        end

        descendantConnection:Disconnect()

        for _, connections in pairs(titleConnections) do
            for _, connection in ipairs(connections) do
                connection:Disconnect()
            end
        end

        if myGeneration ~= captionGeneration or not screenGui.Parent then
            return
        end

        TS:Create(
            captionLabel,
            TweenInfo.new(0.5),
            {TextTransparency = 1}
        ):Play()

        task.wait(0.5)

        if myGeneration == captionGeneration and screenGui.Parent then
            screenGui:Destroy()
            activeCaptionGui = nil
        end
    end)
end

local function ShowSmoothCredits()
    task.wait(3)

    local creditGui = Instance.new("ScreenGui")
    creditGui.Name = "OldHardcoreCredits"
    creditGui.Parent = Player.PlayerGui

    local creditLabel = Instance.new("TextLabel")
    creditLabel.Text = "Original Old Hardcore By Noonie and Ping."
    creditLabel.Font = Enum.Font.Oswald
    creditLabel.TextSize = 22
    creditLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    creditLabel.TextStrokeTransparency = 0.5
    creditLabel.BackgroundTransparency = 1
    creditLabel.TextXAlignment = Enum.TextXAlignment.Left
    creditLabel.Position = UDim2.new(-0.6, 0, 0.05, 0)
    creditLabel.Size = UDim2.new(0.4, 0, 0.05, 0)
    creditLabel.Parent = creditGui

    local slideIn = TS:Create(
        creditLabel,
        TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.02, 0, 0.05, 0)}
    )

    local slideBack = TS:Create(
        creditLabel,
        TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {Position = UDim2.new(-0.6, 0, 0.05, 0)}
    )

    slideIn:Play()
    task.wait(5)
    slideBack:Play()
    slideBack.Completed:Wait()
    creditGui:Destroy()
end

local alreadyExecuted = workspace:FindFirstChild("ExecutedOldHard")

if not alreadyExecuted then
    if LatestRoom.Value ~= 0 then
        ShowCaption("EXECUTOR: Error. Please go to Door 0 to begin.", 6)
        task.wait(1)

        if Player.Character then
            local hum = Player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:TakeDamage(100)
            end
        end

        return
    else
        local modeInit = Instance.new("BoolValue")
        modeInit.Name = "ExecutedOldHard"
        modeInit.Value = true
        modeInit.Parent = workspace
    end
else
    ShowCaption("EXECUTOR: Already Running.", 3)
    return
end

-- Frostbite is completely removed
local entityURLs = {
    Ripper = "https://raw.githubusercontent.com/GmdRipper/hardcoreTest/refs/heads/main/OldRipper.lua",
    Rebound = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/refs/heads/main/oldRebound.lua",
    DeerGod = "https://raw.githubusercontent.com/GmdRipper/hardcoreTest/refs/heads/main/OldDeerGod.lua",
    Cease = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/refs/heads/main/oldCease.lua",
    Shocker = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/refs/heads/main/oldShocker.lua",
    Silence = "https://raw.githubusercontent.com/GmdRipper/hardcoreTest/refs/heads/main/Silence.lua",
    A60 = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/refs/heads/main/oldA60.lua"
}

local startTimeValue = workspace:FindFirstChild("OldHardcoreStartTime")

if not startTimeValue then
    startTimeValue = Instance.new("NumberValue")
    startTimeValue.Name = "OldHardcoreStartTime"
    startTimeValue.Parent = workspace
end

local UIS = game:GetService("UserInputService")
local stamina = 100
local maxStamina = 100
local isExhausted = false
local sprinting = false
local crouching = false

local sprintTime = 6
local drainInterval = sprintTime / 100
local recoveryInterval = sprintTime / 50

local sg = Instance.new("ScreenGui")
sg.Name = "StaminaGui"
sg.ResetOnSpawn = false
sg.Parent = Player:WaitForChild("PlayerGui")

local container = Instance.new("Frame")
container.Name = "Sprint"
container.Size = UDim2.new(0, 220, 0, 12)
container.Position = UDim2.new(0.98, 0, 0.95, 0)
container.AnchorPoint = Vector2.new(1, 1)
container.BackgroundColor3 = Color3.fromRGB(55, 43, 35)
container.BackgroundTransparency = 0.15
container.BorderSizePixel = 0
container.ClipsDescendants = true
container.Parent = sg

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 4)
containerCorner.Parent = container

local bar = Instance.new("Frame")
bar.Name = "Bar"
bar.Size = UDim2.new(1, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(213, 185, 158)
bar.BorderSizePixel = 0
bar.Parent = container

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 4)
barCorner.Parent = bar

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.2
stroke.Color = Color3.fromRGB(25, 20, 17)
stroke.Transparency = 0.15
stroke.Parent = container

local overlay = Instance.new("ImageLabel")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundTransparency = 1
overlay.Image = "rbxassetid://190596490"
overlay.ImageTransparency = 0.65
overlay.ScaleType = Enum.ScaleType.Stretch
overlay.ZIndex = 2
overlay.Parent = container

local mobileBtn

if UIS.TouchEnabled then
    mobileBtn = Instance.new("ImageButton")
    mobileBtn.Name = "SprintButton"
    mobileBtn.Size = UDim2.new(0, 80, 0, 80)
    mobileBtn.Position = UDim2.new(0.85, 0, 0.80, 0)
    mobileBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 28)
    mobileBtn.BackgroundTransparency = 0.25
    mobileBtn.Image = "rbxassetid://89190879948216"
    mobileBtn.Parent = sg

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = mobileBtn

    mobileBtn.MouseButton1Down:Connect(function()
        sprinting = true
    end)

    mobileBtn.MouseButton1Up:Connect(function()
        sprinting = false
    end)

    mobileBtn.TouchEnded:Connect(function()
        sprinting = false
    end)
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.Q then
        sprinting = true
    elseif input.KeyCode == Enum.KeyCode.C
        or input.KeyCode == Enum.KeyCode.LeftControl then
        crouching = not crouching
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        sprinting = false
    end
end)

local breathSound

local function SetupCharacter(char)
    local head = char:WaitForChild("Head")

    if breathSound then
        breathSound:Destroy()
        breathSound = nil
    end

    breathSound = Instance.new("Sound")
    breathSound.Name = "ExhaustionBreathing"
    breathSound.SoundId = "rbxassetid://8258601891"
    breathSound.Volume = 2.3
    breathSound.Looped = true
    breathSound.Parent = head
end

Player.CharacterAdded:Connect(SetupCharacter)

if Player.Character then
    task.spawn(SetupCharacter, Player.Character)
end

task.spawn(function()
    local drainTimer = 0
    local recoveryTimer = 0

    while true do
        task.wait(0.06)

        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if not hum or hum.Health <= 0 then
            continue
        end

        local isMoving = hum.MoveDirection.Magnitude > 0
        local seekActive = workspace:FindFirstChild("SeekMoving")

        if seekActive then
            container.Visible = false
            stamina = maxStamina
            isExhausted = false
            drainTimer = 0
            recoveryTimer = 0

            if breathSound and breathSound.IsPlaying then
                breathSound:Stop()
            end

            continue
        end

        container.Visible = true

        if isExhausted then
            hum.WalkSpeed = 12
            drainTimer = 0
            recoveryTimer += 0.06

            if breathSound and not breathSound.IsPlaying then
                breathSound:Play()
            end

            if recoveryTimer >= recoveryInterval then
                recoveryTimer = 0
                stamina = math.min(maxStamina, stamina + 1)
            end

            bar.BackgroundColor3 = Color3.fromRGB(180, 65, 55)

            if stamina >= maxStamina then
                isExhausted = false
                recoveryTimer = 0

                if breathSound and breathSound.IsPlaying then
                    breathSound:Stop()
                end
            end

        elseif crouching then
            hum.WalkSpeed = 9
            drainTimer = 0
            recoveryTimer += 0.06

            if recoveryTimer >= recoveryInterval then
                recoveryTimer = 0
                stamina = math.min(maxStamina, stamina + 1)
            end

            bar.BackgroundColor3 = Color3.fromRGB(213, 185, 158)

            if breathSound and breathSound.IsPlaying then
                breathSound:Stop()
            end

        elseif sprinting and isMoving and stamina > 0 then
            hum.WalkSpeed = 20
            hum:SetAttribute("SpeedBoost", 4)
            recoveryTimer = 0
            drainTimer += 0.06

            if drainTimer >= drainInterval then
                drainTimer = 0
                stamina = math.max(0, stamina - 1)
            end

            bar.BackgroundColor3 = Color3.fromRGB(213, 185, 158)

            if stamina <= 0 then
                isExhausted = true
                sprinting = false
                recoveryTimer = 0
            end

            if breathSound and breathSound.IsPlaying then
                breathSound:Stop()
            end

        else
            hum.WalkSpeed = 12
            drainTimer = 0
            recoveryTimer += 0.06

            if recoveryTimer >= recoveryInterval then
                recoveryTimer = 0
                stamina = math.min(maxStamina, stamina + 1)
            end

            bar.BackgroundColor3 = Color3.fromRGB(213, 185, 158)

            if breathSound and breathSound.IsPlaying then
                breathSound:Stop()
            end
        end

        bar.Size = UDim2.new(
            math.clamp(stamina / maxStamina, 0, 1),
            0, 1, 0
        )
    end
end)

-- Room 50: A60 and Shocker are allowed.
-- Room 100: no room-specific restriction.
-- Seek still blocks all entities.
local function LoadEntity(name)
    if workspace:FindFirstChild("SeekMoving") then
        return
    end

    if LatestRoom.Value == 50
        and name ~= "A60"
        and name ~= "Shocker" then
        return
    end

    local url = entityURLs[name]

    if url then
        task.spawn(function()
            pcall(function()
                loadstring(game:HttpGet(url))()
            end)
        end)
    end
end

-- Every scheduler uses this generation.
-- Entering room 51 increments it and resets all spawn timers.
local scheduleGeneration = 0
local opened = false
local resetRoom51Handled = false

local function WaitSecondsOrReset(seconds, generation)
    local endTime = os.clock() + seconds

    while os.clock() < endTime do
        if generation ~= scheduleGeneration then
            return false
        end

        task.wait(0.1)
    end

    return generation == scheduleGeneration
end

local function WaitForNextDoor(generation)
    local previousRoom = LatestRoom.Value

    while LatestRoom.Value == previousRoom do
        if generation ~= scheduleGeneration then
            return false
        end

        task.wait(0.05)
    end

    return generation == scheduleGeneration
end

local function StartRandomDoorEntity(name, minTime, maxTime)
    task.spawn(function()
        while true do
            local generation = scheduleGeneration
            local delayTime = math.random(minTime, maxTime)

            local valid = WaitSecondsOrReset(delayTime, generation)

            if valid then
                valid = WaitForNextDoor(generation)
            end

            if generation ~= scheduleGeneration then
                continue
            end

            if valid then
                LoadEntity(name)
            end
        end
    end)
end

local function StartShocker()
    task.spawn(function()
        while true do
            local generation = scheduleGeneration
            local delayTime = math.random(30, 70)

            local valid = WaitSecondsOrReset(delayTime, generation)

            if generation == scheduleGeneration and valid then
                LoadEntity("Shocker")
            end
        end
    end)
end

LatestRoom.Changed:Connect(function()
    if LatestRoom.Value == 51 and not resetRoom51Handled then
        resetRoom51Handled = true
        scheduleGeneration += 1
    elseif LatestRoom.Value ~= 51 then
        resetRoom51Handled = false
    end

    if opened or LatestRoom.Value ~= 1 then
        return
    end

    opened = true
    startTimeValue.Value = workspace:GetServerTimeNow()

    ShowCaption("Hardcore Initiated", 5)
    task.wait(5.5)

    ShowCaption(
        "Made by noonie#0001 (Scripter) and Ping#1841 (Music composer and Modeler)",
        7
    )
    task.wait(7.5)

    local messages = {
        "Do not.",
        "Good luck!",
        "Have fun! (you wont)"
    }

    ShowCaption(messages[math.random(1, #messages)], 5)

    StartRandomDoorEntity("Ripper", 90, 130)
    StartRandomDoorEntity("Rebound", 160, 180)
    StartRandomDoorEntity("Cease", 180, 230)
    StartRandomDoorEntity("A60", 350, 400)
    StartRandomDoorEntity("Silence", 230, 300)
    StartRandomDoorEntity("DeerGod", 150, 200)

    StartShocker()
end)
