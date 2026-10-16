
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
sg.Parent = game.CoreGui

local bar = Instance.new("Frame")
bar.Name = "Sprint"
bar.Size = UDim2.new(0, 200, 0, 20)
bar.Position = UDim2.new(0.5, -100, 0.9, 0)
bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
bar.BorderSizePixel = 0
bar.Parent = sg

local fill = Instance.new("Frame")
fill.Name = "Bar"
fill.Size = UDim2.new(1, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
fill.BorderSizePixel = 0
fill.Parent = bar

local overlayGui = Instance.new("ImageLabel")
overlayGui.Name = "erm"
overlayGui.Size = UDim2.new(1, 0, 1, 0)
overlayGui.BackgroundTransparency = 1
overlayGui.Image = ""
overlayGui.Parent = bar

local mobileBtn

if UIS.TouchEnabled then
    mobileBtn = Instance.new("TextButton")
    mobileBtn.Name = "SprintButton"
    mobileBtn.Size = UDim2.new(0, 100, 0, 50)
    mobileBtn.Position = UDim2.new(1, -120, 1, -180)
    mobileBtn.Text = "SPRINT"
    mobileBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mobileBtn.TextColor3 = Color3.new(1, 1, 1)
    mobileBtn.Parent = sg

    mobileBtn.MouseButton1Down:Connect(function()
        if not isExhausted then
            sprinting = true
        end
    end)

    mobileBtn.MouseButton1Up:Connect(function()
        sprinting = false
    end)
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.Q and not isExhausted then
        sprinting = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        sprinting = false
    end
end)

task.spawn(function()
    while task.wait() do
        local character = Player.Character
        local hum = character and character:FindFirstChildOfClass("Humanoid")

        if hum then
            if sprinting and stamina > 0 and not isExhausted and not crouching then
                hum.WalkSpeed = 20
                stamina = math.max(0, stamina - 1)

                if stamina <= 0 then
                    isExhausted = true
                    sprinting = false
                end
            else
                if crouching then
                    hum.WalkSpeed = 9
                else
                    hum.WalkSpeed = 12
                end

                if not sprinting then
                    stamina = math.min(maxStamina, stamina + 0.5)
                end

                if stamina >= maxStamina then
                    isExhausted = false
                end
            end

            fill.Size = UDim2.new(stamina / maxStamina, 0, 1, 0)

            if stamina > 50 then
                fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            elseif stamina > 25 then
                fill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
            else
                fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            end
        end
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
