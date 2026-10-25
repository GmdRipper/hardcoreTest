
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local LatestRoom = game.ReplicatedStorage.GameData.LatestRoom
local CaptionEvent = game.ReplicatedStorage:WaitForChild("Bricks"):WaitForChild("Caption")

local function ShowCaption(text, duration)
    firesignal(CaptionEvent.OnClientEvent, text)
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
