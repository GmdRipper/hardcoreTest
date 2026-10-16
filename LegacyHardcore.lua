
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local LatestRoom = game.ReplicatedStorage.GameData.LatestRoom
local TS = game:GetService("TweenService")

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

            paintingTitles[obj] = {
                visible = obj.Visible,
                text = obj.Text
            }

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

            for obj, info in pairs(paintingTitles) do
                if not obj.Parent then
                    paintingTitles[obj] = nil

                    if titleConnections[obj] then
                        for _, connection in ipairs(titleConnections[obj]) do
                            connection:Disconnect()
                        end

                        titleConnections[obj] = nil
                    end

                    continue
                end

                if IsPaintingTitle(obj) and obj.Visible then
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

    local creditGui = Instance.new("ScreenGui", Player.PlayerGui)
    creditGui.Name = "OldHardcoreCredits"

    local creditLabel = Instance.new("TextLabel", creditGui)
    creditLabel.Text = "Original Old Hardcore By Noonie and Ping."
    creditLabel.Font = Enum.Font.Oswald
    creditLabel.TextSize = 22
    creditLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    creditLabel.TextStrokeTransparency = 0.5
    creditLabel.BackgroundTransparency = 1
    creditLabel.TextXAlignment = Enum.TextXAlignment.Left
    creditLabel.Position = UDim2.new(-0.6, 0, 0.05, 0)
    creditLabel.Size = UDim2.new(0.4, 0, 0.05, 0)

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
            Player.Character.Humanoid:TakeDamage(100)
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

local entityURLs = {
    Ripper = "https://raw.githubusercontent.com/GmdRipper/hardcoreTest/refs/heads/main/OldRipper.lua",
    Rebound = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/refs/heads/main/oldRebound.lua",
    DeerGod = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/refs/heads/main/oldDeerGod.lua",
    Cease = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/refs/heads/main/oldCease.lua",
    Shocker = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/refs/heads/main/oldShocker.lua",
    Silence = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/refs/heads/main/oldSilence.lua",
    A60 = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/refs/heads/main/oldA60.lua",
    Frostbite = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/refs/heads/main/oldFrostbite.lua"
}

local startTimeValue = workspace:FindFirstChild("OldHardcoreStartTime")

if not startTimeValue then
    startTimeValue = Instance.new("NumberValue")
    startTimeValue.Name = "OldHardcoreStartTime"
    startTimeValue.Parent = workspace
end

local door51Generation = 0
local door51StartTime = 0

local function SyncWait(seconds)
    if startTimeValue.Value == 0 then
        return
    end

    local targetTime = startTimeValue.Value + seconds

    while workspace:GetServerTimeNow() < targetTime do
        task.wait(0.5)
    end
end

local function ResettableSyncWait(seconds, baseTime, generation)
    local targetTime = baseTime + seconds

    while workspace:GetServerTimeNow() < targetTime do
        if generation ~= door51Generation then
            return false
        end

        task.wait(0.1)
    end

    return generation == door51Generation
end

local function ResettableRoomWait(generation)
    local previousRoom = LatestRoom.Value

    while LatestRoom.Value == previousRoom do
        if generation ~= door51Generation then
            return false
        end

        task.wait(0.1)
    end

    return generation == door51Generation
end

local function GetTargetSchedule()
    if door51StartTime > 0 then
        return door51StartTime
    end

    return startTimeValue.Value
end


local sg = Instance.new("ScreenGui")
sg.Name = "StaminaGui"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.Parent = Player:WaitForChild("PlayerGui")

local container = Instance.new("Frame")
container.Name = "Sprint"
container.BackgroundTransparency = 1
container.AnchorPoint = Vector2.new(0, 1)
container.Position = UDim2.new(0.931555569, 0, 0.987179458, 0)
container.Size = UDim2.new(0.0556001104, 0, 0.0756410286, 0)
container.SizeConstraint = Enum.SizeConstraint.RelativeYY
container.ZIndex = 1005
container.Parent = sg

local image = Instance.new("ImageLabel")
image.Name = "ImageLabel"
image.BackgroundColor3 = Color3.fromRGB(255, 222, 189)
image.BackgroundTransparency = 1
image.Size = UDim2.new(1, 0, 1, 0)
image.Visible = false
image.Parent = container

local imageCorner = Instance.new("UICorner")
imageCorner.CornerRadius = UDim.new(1, 0)
imageCorner.Parent = image

local padding = Instance.new("UIPadding")
padding.PaddingBottom = UDim.new(0.3, -5)
padding.PaddingTop = UDim.new(0.3, -5)
padding.PaddingLeft = UDim.new(0.02, 0)
padding.PaddingRight = UDim.new(0.05, -15)
padding.Parent = container

local bar = Instance.new("Frame")
bar.Name = "Bar"
bar.AnchorPoint = Vector2.new(0, 0.5)
bar.BackgroundColor3 = Color3.fromRGB(56, 46, 39)
bar.BackgroundTransparency = 0.7
bar.Position = UDim2.new(-2.72600269, 0, 0.499999672, 0)
bar.Size = UDim2.new(3.60599804, 0, 0.600000083, 0)
bar.ZIndex = 0
bar.Parent = container

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0.25, 0)
barCorner.Parent = bar

local barPadding = Instance.new("UIPadding")
barPadding.PaddingBottom = UDim.new(0, 4)
barPadding.PaddingTop = UDim.new(0, 4)
barPadding.PaddingLeft = UDim.new(0, 4)
barPadding.PaddingRight = UDim.new(0, 4)
barPadding.Parent = bar

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.AnchorPoint = Vector2.new(0, 0.5)
fill.BackgroundColor3 = Color3.fromRGB(213, 185, 158)
fill.Position = UDim2.new(0, 0, 0.5, 0)
fill.Size = UDim2.new(1, 0, 1, 0)
fill.ZIndex = 2
fill.Parent = bar

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0.25, 0)
fillCorner.Parent = fill

local overlayGui = Instance.new("ScreenGui")
overlayGui.Name = "erm"
overlayGui.IgnoreGuiInset = true
overlayGui.ResetOnSpawn = false
overlayGui.Parent = Player:WaitForChild("PlayerGui")

local overlay = Instance.new("ImageLabel")
overlay.Name = "Overlay"
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 1
overlay.Image = "rbxassetid://190596490"
overlay.ImageColor3 = Color3.new(0, 0, 0)
overlay.ImageTransparency = 1
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.Position = UDim2.new(0, 0, 0, 0)
overlay.Parent = overlayGui

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

            fill.BackgroundColor3 = Color3.fromRGB(180, 65, 55)

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

            fill.BackgroundColor3 = Color3.fromRGB(213, 185, 158)

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

            fill.BackgroundColor3 = Color3.fromRGB(213, 185, 158)

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

            fill.BackgroundColor3 = Color3.fromRGB(213, 185, 158)

            if breathSound and breathSound.IsPlaying then
                breathSound:Stop()
            end
        end

        fill.Size = UDim2.new(
            math.clamp(stamina / maxStamina, 0, 1),
            0,
            1,
            0
        )
    end
end)

local function LoadEntity(name)
    if workspace:FindFirstChild("SeekMoving") then
        return
    end

    if LatestRoom.Value == 50 and name ~= "A60" then
        return
    end

    if LatestRoom.Value == 100 then
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

local waitRipper = 140
local waitRebound = 550
local waitCease = 74
local waitA60 = 32
local waitFrostbite = 195

local canSpawnRipper = false
local canSpawnRebound = false
local canSpawnCease = false
local canSpawnA60 = false
local canSpawnFrostbite = false

local reboundForceRequested = false
local opened = false

LatestRoom.Changed:Connect(function()
    if LatestRoom.Value == 51 and door51StartTime == 0 then
        door51StartTime = workspace:GetServerTimeNow()
        door51Generation += 1
        reboundForceRequested = false

        canSpawnRipper = false
        canSpawnFrostbite = false
    end
end)

LatestRoom.Changed:Connect(function()
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

    task.spawn(function()
        local firstAppearance = true
        local seenGeneration = door51Generation
        local baseTime = GetTargetSchedule()

        while true do
            if seenGeneration ~= door51Generation then
                seenGeneration = door51Generation
                firstAppearance = true
                canSpawnRipper = false
                baseTime = GetTargetSchedule()
            end

            if not canSpawnRipper then
                canSpawnRipper = true

                local generation = door51Generation
                local delayTime = firstAppearance and 130 or 167

                local valid = ResettableSyncWait(delayTime, baseTime, generation)

                if valid then
                    valid = ResettableRoomWait(generation)
                end

                if valid then
                    LoadEntity("Ripper")
                    firstAppearance = false
                    baseTime = workspace:GetServerTimeNow()

                    task.delay(waitRipper, function()
                        canSpawnRipper = false
                    end)
                else
                    canSpawnRipper = false
                    firstAppearance = true
                    baseTime = GetTargetSchedule()
                end
            end

            task.wait(0.2)
        end
    end)

    task.spawn(function()
        local c = 0
        local stage = 1
        local nextAllowedTime = 0
        local seenGeneration = door51Generation

        while true do
            if seenGeneration ~= door51Generation then
                seenGeneration = door51Generation
                c = 0
                stage = 1
                nextAllowedTime = 0
                reboundForceRequested = false
            end

            local generation = door51Generation
            local baseTime = GetTargetSchedule()

            if reboundForceRequested then
                reboundForceRequested = false
                LoadEntity("Rebound")
                nextAllowedTime = workspace:GetServerTimeNow() + waitRebound
            else
                local offset = stage == 1 and 670 or 1100
                local targetTime = baseTime + c + offset

                while workspace:GetServerTimeNow() < targetTime
                    or workspace:GetServerTimeNow() < nextAllowedTime do

                    if generation ~= door51Generation or reboundForceRequested then
                        break
                    end

                    task.wait(0.1)
                end

                if generation ~= door51Generation then
                elseif reboundForceRequested then
                    reboundForceRequested = false
                    LoadEntity("Rebound")
                    nextAllowedTime = workspace:GetServerTimeNow() + waitRebound
                else
                    local valid = ResettableRoomWait(generation)

                    if valid then
                        LoadEntity("Rebound")
                        nextAllowedTime = workspace:GetServerTimeNow() + waitRebound

                        if stage == 1 then
                            stage = 2
                        else
                            c = c + 930
                            stage = 1
                        end
                    end
                end
            end

            task.wait(0.1)
        end
    end)

    task.spawn(function()
        local c = 0

        while true do
            if not canSpawnCease then
                canSpawnCease = true

                SyncWait(c + 160)
                LoadEntity("Cease")

                SyncWait(c + 390)
                LoadEntity("Cease")

                c = c + 390

                task.delay(waitCease, function()
                    canSpawnCease = false
                end)
            end

            task.wait(1)
        end
    end)

    task.spawn(function()
        local c = 0

        while true do
            if not canSpawnA60 then
                canSpawnA60 = true

                SyncWait(c + 730)
                LoadEntity("A60")

                SyncWait(c + 1200)
                LoadEntity("A60")

                c = c + 910

                task.delay(waitA60, function()
                    canSpawnA60 = false
                end)
            end

            task.wait(1)
        end
    end)

    task.spawn(function()
        local c = 0
        local seenGeneration = door51Generation

        while true do
            if seenGeneration ~= door51Generation then
                seenGeneration = door51Generation
                c = 0
                canSpawnFrostbite = false
            end

            if not canSpawnFrostbite then
                canSpawnFrostbite = true

                local generation = door51Generation
                local baseTime = GetTargetSchedule()
                local valid = ResettableSyncWait(c + 330, baseTime, generation)

                if valid then
                    valid = ResettableRoomWait(generation)
                end

                if valid then
                    LoadEntity("Frostbite")

                    if math.random(1, 100) <= 95 then
                        reboundForceRequested = true
                    end

                    valid = ResettableSyncWait(c + 645, baseTime, generation)
                end

                if valid then
                    valid = ResettableRoomWait(generation)
                end

                if valid then
                    LoadEntity("Frostbite")

                    if math.random(1, 100) <= 95 then
                        reboundForceRequested = true
                    end

                    c = c + 900

                    task.delay(waitFrostbite, function()
                        canSpawnFrostbite = false
                    end)
                else
                    c = 0
                    canSpawnFrostbite = false
                end
            end

            task.wait(0.2)
        end
    end)

    task.spawn(function()
        local c = 0

        while true do
            SyncWait(c + 850)
            LoadEntity("Silence")
            SyncWait(c + 1530)
            LoadEntity("Silence")
            c = c + 600
            task.wait(1)
        end
    end)

    task.spawn(function()
        local c = 0

        while true do
            SyncWait(c + 1500)

            repeat
                if LatestRoom.Value ~= 50
                    and not workspace:FindFirstChild("SeekMoving") then
                    LoadEntity("DeerGod")
                    break
                end

                task.wait(100)
            until false

            c = c + 2100
            task.wait(1)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(math.random(30, 70))
            LoadEntity("Shocker")
        end
    end)
end)
