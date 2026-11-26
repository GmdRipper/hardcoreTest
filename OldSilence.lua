local G = getgenv()

G.LoadGithubModel = function(url)
    if not (writefile and getcustomasset and request) then
        return nil
    end

    local function generateFileName(u)
        local hash = 0
        for i = 1, #u do
            hash = (hash * 31 + string.byte(u, i)) % 2^32
        end
        return "silence_" .. tostring(hash) .. ".rbxm"
    end

    local fileName = generateFileName(url)

    local success, exists = pcall(function()
        return isfile and isfile(fileName)
    end)

    if success and exists then
        local assetId = getcustomasset(fileName)
        local loadSuccess, result = pcall(function()
            return game:GetObjects(assetId)[1]
        end)

        if loadSuccess and result then
            return result
        end
    end

    local response = request({
        Url = url,
        Method = "GET"
    })

    if response.StatusCode ~= 200 then
        return nil
    end

    writefile(fileName, response.Body)

    local assetId = getcustomasset(fileName)
    local loadSuccess, result = pcall(function()
        return game:GetObjects(assetId)[1]
    end)

    if loadSuccess and result then
        return result
    end

    return nil
end

-- SILENCE ACHIEVEMENT
local SilenceAchievement = {
    Title = "Eyes Closed Ears open",
    Desc = "Stay silent or I wont be heard",
    Reason = "Encounter Silence",
    Image = "rbxassetid://75011294666686",
}

local SILENCE_ACHIEVEMENT_FLAG = "SilenceAchievement"

local function GiveSilenceAchievement()
    if workspace:FindFirstChild(SILENCE_ACHIEVEMENT_FLAG) then
        return
    end

    local player = game:GetService("Players").LocalPlayer
    local tweenService = game:GetService("TweenService")
    local playerGui = player and player:FindFirstChild("PlayerGui")
    local mainUI = playerGui and playerGui:FindFirstChild("MainUI")
    local holder = mainUI and mainUI:FindFirstChild("AchievementsHolder")
    local template = holder and holder:FindFirstChild("Achievement")

    if not template then
        return
    end

    local obtainedBadge = Instance.new("BoolValue")
    obtainedBadge.Name = SILENCE_ACHIEVEMENT_FLAG
    obtainedBadge.Value = true
    obtainedBadge.Parent = workspace

    task.spawn(function()
        local frame = template:Clone()
        frame.Name = "LiveAchievement"
        frame.Frame.Details.Title.Text = SilenceAchievement.Title
        frame.Frame.Details.Desc.Text = SilenceAchievement.Desc
        frame.Frame.Details.Reason.Text = SilenceAchievement.Reason
        frame.Frame.ImageLabel.Image = SilenceAchievement.Image
        frame.Size = UDim2.new(0, 0, 0, 0)
        frame.Frame.Position = UDim2.new(1.1, 0, 0, 0)
        frame.Visible = true
        frame.Parent = holder

        if frame:FindFirstChild("Sound") then
            frame.Sound:Play()
        end

        frame:TweenSize(UDim2.new(1, 0, 0.2, 0), "In", "Quad", 0.8, true)
        task.wait(0.8)
        frame.Frame:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.5, true)
        tweenService:Create(frame.Frame.Glow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            ImageTransparency = 1
        }):Play()
        task.wait(8)
        frame.Frame:TweenPosition(UDim2.new(1.1, 0, 0, 0), "In", "Quad", 0.5, true)
        task.wait(0.5)
        frame:TweenSize(UDim2.new(1, 0, -0.1, 0), "InOut", "Quad", 0.5, true)
        task.wait(0.5)

        frame:Destroy()
    end)
end

-- SILENCE JUMPSCARE
local function playSilenceJumpscare()
    local player = game:GetService("Players").LocalPlayer

    if not player then
        return
    end

    local playerGui = player:FindFirstChildOfClass("PlayerGui")

    if not playerGui then
        return
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SilenceJumpscare"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999999
    screenGui.Parent = playerGui

    -- Purple flashing overlay
    local flash = Instance.new("Frame")
    flash.Name = "Flashing"
    flash.Size = UDim2.fromScale(1, 1)
    flash.Position = UDim2.fromScale(0, 0)
    flash.BackgroundColor3 = Color3.fromRGB(48, 25, 52)
    flash.BorderSizePixel = 0
    flash.ZIndex = 1
    flash.Parent = screenGui

    -- First jumpscare image
    local image1 = Instance.new("ImageLabel")
    image1.Name = "Image1"
    image1.AnchorPoint = Vector2.new(0.5, 0.5)
    image1.Position = UDim2.fromScale(0.5, 0.5)
    image1.Size = UDim2.fromScale(0.9, 0.9)
    image1.BackgroundTransparency = 1
    image1.Image = "rbxassetid://11395251069"
    image1.ScaleType = Enum.ScaleType.Fit
    image1.ImageTransparency = 0
    image1.ZIndex = 2
    image1.Parent = screenGui

    -- Second jumpscare image
    local image2 = Instance.new("ImageLabel")
    image2.Name = "Image2"
    image2.AnchorPoint = Vector2.new(0.5, 0.5)
    image2.Position = UDim2.fromScale(0.5, 0.5)
    image2.Size = UDim2.fromScale(0.9, 0.9)
    image2.BackgroundTransparency = 1
    image2.Image = "rbxassetid://11395251069"
    image2.ScaleType = Enum.ScaleType.Fit
    image2.ImageTransparency = 1
    image2.ZIndex = 3
    image2.Parent = screenGui

    -- Sound 1
    local sound1 = Instance.new("Sound")
    sound1.Name = "SilenceSound1"
    sound1.SoundId = "rbxassetid://10483790459"
    sound1.Volume = 0.5
    sound1.Parent = screenGui

    -- Sound 2
    local sound2 = Instance.new("Sound")
    sound2.Name = "SilenceSound2"
    sound2.SoundId = "rbxassetid://10483837590"
    sound2.Volume = 0.5
    sound2.Parent = screenGui

    -- Mute other game sounds during the jumpscare
    local originalVolumes = {}

    local function muteOtherSound(obj)
        if obj:IsA("Sound")
            and obj ~= sound1
            and obj ~= sound2
            and originalVolumes[obj] == nil then

            originalVolumes[obj] = obj.Volume
            obj.Volume = 0
        end
    end

    for _, obj in ipairs(game:GetDescendants()) do
        muteOtherSound(obj)
    end

    local muteConnection = game.DescendantAdded:Connect(function(obj)
        muteOtherSound(obj)
    end)

    local function restoreOtherSounds()
        if muteConnection then
            muteConnection:Disconnect()
            muteConnection = nil
        end

        for sound, oldVolume in pairs(originalVolumes) do
            pcall(function()
                if sound.Parent then
                    sound.Volume = oldVolume
                end
            end)
        end
    end

    -- Start both sounds together
    local active = true
    local startTime = os.clock()

    pcall(function()
        sound1:Play()
        sound2:Play()
    end)

    -- Image shake and flashing
    task.spawn(function()
        while active and screenGui.Parent do
            local elapsed = os.clock() - startTime

            -- Switch image after 0.35 seconds
            if elapsed >= 0.35 and image1.ImageTransparency == 0 then
                image1.ImageTransparency = 1
                image2.ImageTransparency = 0
            end

            -- Shake the visible image
            local offsetX = math.random(-15, 15)
            local offsetY = math.random(-15, 15)

            local currentImage

            if image2.ImageTransparency == 0 then
                currentImage = image2
            else
                currentImage = image1
            end

            currentImage.Position = UDim2.new(
                0.5, offsetX,
                0.5, offsetY
            )

            -- Purple and black flashes
            if math.floor(elapsed * 10) % 2 == 0 then
                flash.BackgroundColor3 = Color3.fromRGB(48, 25, 52)
            else
                flash.BackgroundColor3 = Color3.new(0, 0, 0)
            end

            flash.BackgroundTransparency = 0

            task.wait(0.04)
        end
    end)

    task.wait(0.75)

    active = false

    -- Remove the jumpscare instantly
    restoreOtherSounds()

    if screenGui then
        screenGui:Destroy()
    end
end

local function Silence()
    local currentRooms = workspace.CurrentRooms
    local latestRoom = game.ReplicatedStorage.GameData.LatestRoom
    local ambruhspeed = 15
    local ambruhheight = Vector3.new(0, 3.4, 0)
    local DEF_SPEED = 99999
    local storer = ambruhspeed
    local entity = nil
    local killed = false

    if not game.ReplicatedStorage:FindFirstChild("ClientModules") then
        return
    end

    if not game.ReplicatedStorage.ClientModules:FindFirstChild("Module_Events") then
        return
    end

    if not workspace:FindFirstChild("CurrentRooms") then
        return
    end

    local required = require(game.ReplicatedStorage.ClientModules.Module_Events)
    currentRooms = workspace:FindFirstChild("CurrentRooms")

    local rawUrl = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/main/oldSilence.rbxm"

    if G.LoadGithubModel then
        entity = G.LoadGithubModel(rawUrl)

        if entity then
            entity.Parent = workspace
        end
    end

    if not entity then
        return
    end

    local entityPart = entity:FindFirstChildWhichIsA("BasePart")

    if not entityPart then
        entity:Destroy()
        return
    end

    task.wait(1)

    local function canSeeTarget(target, size)
        if killed == true then
            return false
        end

        if target:GetAttribute("Hiding") then
            return false
        end

        local targetRoot = target:FindFirstChild("HumanoidRootPart")

        if not targetRoot then
            return false
        end

        local offset = targetRoot.Position - entityPart.Position

        if offset.Magnitude == 0 or offset.Magnitude > size then
            return false
        end

        local ray = Ray.new(entityPart.Position, offset)
        local hit = workspace:FindPartOnRay(ray, entity)

        if hit and hit:IsDescendantOf(target) then
            return true
        end

        return false
    end

    local function GetTime(dist, speed)
        return dist / speed
    end

    local function ForceSilenceDeathHint(char)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local hints = {
            "You died to who you call Silence",
            "Stay as silent as possible when you suspect its coming, so you know when to hide!",
            "Its slow, but hard to hear",
            "so hide!"
        }

        pcall(function()
            local playerStats = ReplicatedStorage.GameStats:FindFirstChild("Player_" .. char.Name)
            if playerStats and playerStats:FindFirstChild("Total")
                and playerStats.Total:FindFirstChild("DeathCause") then
                playerStats.Total.DeathCause.Value = "Silence"
            end
        end)

        pcall(function()
            if ReplicatedStorage:FindFirstChild("RemotesFolder") then
                local remotesFolder = ReplicatedStorage:FindFirstChild("RemotesFolder")
                if remotesFolder:FindFirstChild("DeathHint") then
                    firesignal(remotesFolder.DeathHint.OnClientEvent, hints, "Blue")
                end
            elseif ReplicatedStorage:FindFirstChild("Bricks") then
                local remotesFolder = ReplicatedStorage:FindFirstChild("Bricks")
                if remotesFolder:FindFirstChild("DeathHint") then
                    firesignal(remotesFolder.DeathHint.OnClientEvent, hints)
                end
            end
        end)
    end

    -- Death detection
    task.spawn(function()
        while entity ~= nil and entityPart ~= nil and entity.Parent do
            task.wait(0.1)

            local player = game.Players.LocalPlayer

            if player.Character ~= nil
                and player.Character:FindFirstChild("HumanoidRootPart")
                and player.Character:FindFirstChild("Humanoid") then

                local character = player.Character
                local humanoid = character:FindFirstChildOfClass("Humanoid")

                if humanoid
                    and humanoid.Health > 0
                    and canSeeTarget(character, 50)
                    and not character:GetAttribute("Hiding") then

                    killed = true

                    pcall(function()
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local playerStats = ReplicatedStorage.GameStats:FindFirstChild("Player_" .. character.Name)
                        if playerStats and playerStats:FindFirstChild("Total")
                            and playerStats.Total:FindFirstChild("DeathCause") then
                            playerStats.Total.DeathCause.Value = "Silence"
                        end
                    end)

                    pcall(playSilenceJumpscare)

                    ForceSilenceDeathHint(character)

                    if humanoid.Parent and humanoid.Health > 0 then
                        humanoid:TakeDamage(100)
                        if humanoid.Health > 0 then
                            humanoid.Health = 0
                        end
                    end

                    task.delay(0.05, function()
                        ForceSilenceDeathHint(character)
                    end)
                    task.delay(0.25, function()
                        ForceSilenceDeathHint(character)
                    end)

                    break
                end
            end
        end
    end)

    ambruhspeed = DEF_SPEED

    for i = 1, latestRoom.Value + 4 do
        local room = currentRooms:FindFirstChild(tostring(i))

        if room and room:FindFirstChild("Nodes") then
            local nodes = room:FindFirstChild("Nodes")

            required.breakLights(room)

            for v = 1, #nodes:GetChildren() do
                local node = nodes:FindFirstChild(tostring(v))

                if node and node:IsA("BasePart") then
                    local dist = (entityPart.Position - node.Position).Magnitude

                    local movementTween = game.TweenService:Create(
                        entityPart,
                        TweenInfo.new(
                            GetTime(dist, ambruhspeed),
                            Enum.EasingStyle.Linear,
                            Enum.EasingDirection.Out,
                            0,
                            false,
                            0
                        ),
                        {
                            CFrame = node.CFrame + ambruhheight
                        }
                    )

                    movementTween:Play()
                    movementTween.Completed:Wait()

                    ambruhspeed = storer
                end
            end
        end
    end

    if entity then
        game:GetService("Debris"):AddItem(entity, 0.01)
    end
    task.wait(0.02)

    local player = game.Players.LocalPlayer
    local character = player and player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not killed and humanoid and humanoid.Health > 0 then
        GiveSilenceAchievement()
    end
end

pcall(Silence)
