-- XENO GITHUB MODEL LOADER (.rbxm / .rbxmx)
local G = getgenv()
G.LoadGithubModel = function(url, forceRefresh, retryCount)
    retryCount = retryCount or 0

    if retryCount >= 3 then
        warn("Failed to load model after 3 attempts")
        return nil
    end

    if not (writefile and getcustomasset and request and isfile and delfile) then
        warn("Missing required functions: writefile, getcustomasset, request, isfile, or delfile")
        return nil
    end

    forceRefresh = forceRefresh or false

    local function getFileNameFromUrl(url)
        local modelName = url:match("([^/]+)%.rbxm$")
            or url:match("([^/]+)%.rbxmx$")
            or "model"

        modelName = modelName:gsub("[^%w_%-]", "_")
        return "deer_god_" .. modelName .. ".rbxm"
    end

    local fileName = getFileNameFromUrl(url)

    if retryCount > 0 then
        print("Retry " .. retryCount .. ": Cleaning up...")
        task.wait(1)

        if isfile(fileName) then
            pcall(function()
                delfile(fileName)
            end)
        end
    end

    if forceRefresh and isfile(fileName) then
        pcall(function()
            delfile(fileName)
        end)
    end

    local fileExists = isfile(fileName)

    if fileExists then
        print("Using cached file: " .. fileName)
    else
        print("Downloading model from: " .. url)

        local response = request({
            Url = url,
            Method = "GET"
        })

        if response.StatusCode ~= 200 then
            warn("Failed to download model. Status code: " .. response.StatusCode)
            return G.LoadGithubModel(url, forceRefresh, retryCount + 1)
        end

        local writeSuccess, writeError = pcall(function()
            writefile(fileName, response.Body)
        end)

        if not writeSuccess then
            warn("Failed to write file: " .. tostring(writeError))
            return G.LoadGithubModel(url, forceRefresh, retryCount + 1)
        end

        print("File saved: " .. fileName)
    end

    local assetId
    local assetSuccess, assetResult = pcall(function()
        return getcustomasset(fileName)
    end)

    if not assetSuccess then
        warn("Failed to get custom asset: " .. tostring(assetResult))

        pcall(function()
            delfile(fileName)
        end)

        return G.LoadGithubModel(url, forceRefresh, retryCount + 1)
    end

    assetId = assetResult

    local model
    local loadSuccess, loadResult = pcall(function()
        local objects = game:GetObjects(assetId)

        if objects and #objects > 0 then
            return objects[1]:Clone()
        end

        return nil
    end)

    if not loadSuccess or not loadResult then
        warn("Failed to load model: " .. tostring(loadResult))

        pcall(function()
            delfile(fileName)
        end)

        return G.LoadGithubModel(url, forceRefresh, retryCount + 1)
    end

    model = loadResult
    print("Model loaded successfully: " .. fileName)

    return model
end

-- Achievement loader
local Achievements = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MuhXd/Models/main/RegularVynixu's%20Achievement%20Modifyer"
))()

local function AchievementsGet(Achievement)
    Achievements.Get(Achievement)
end

local DearGodAchievement = {
    Title = "Last Chance To Look Away",
    Desc = "Why are you running?",
    Reason = "Survive the rare Entity called Dear God",
    Image = "rbxassetid://2129311966",
}

local deerGodThread = nil
local currentEntity = nil

-- DeerGod jumpscare
-- Adapted from the image, sound, shake and flashing settings
-- supplied for CometV4's DeerGod.
local function playDeerGodJumpscare()
    local player = game:GetService("Players").LocalPlayer

    if not player then
        return
    end

    local playerGui = player:FindFirstChildOfClass("PlayerGui")

    if not playerGui then
        return
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeerGodJumpscare"
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

    -- Second image uses the same asset as the original settings
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
    sound1.Name = "DeerGodSound1"
    sound1.SoundId = "rbxassetid://10483790459"
    sound1.Volume = 1
    sound1.Parent = screenGui

    -- Sound 2
    local sound2 = Instance.new("Sound")
    sound2.Name = "DeerGodSound2"
    sound2.SoundId = "rbxassetid://10483837590"
    sound2.Volume = 1
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
    
    -- Start the jumpscare sound immediately
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

            -- Shake the currently visible image
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

    -- Keep the jumpscare visible before applying damage
    task.wait(1.0)

    active = false

    restoreOtherSounds()
    if screenGui then
        screenGui:Destroy()
    end
end

local function DeerGod()
    if deerGodThread then
        pcall(function()
            if currentEntity then
                currentEntity:Destroy()
                currentEntity = nil
            end
        end)

        deerGodThread = nil
    end

    local repStorage = game:GetService("ReplicatedStorage")
    local workspace = game:GetService("Workspace")

    if not repStorage:FindFirstChild("ClientModules") then
        warn("ClientModules not found")
        return
    end

    if not repStorage.ClientModules:FindFirstChild("Module_Events") then
        warn("Module_Events not found")
        return
    end

    if not workspace:FindFirstChild("CurrentRooms") then
        warn("CurrentRooms not found")
        return
    end

    local required = require(repStorage.ClientModules.Module_Events)
    local currentRooms = workspace.CurrentRooms
    local gameData = repStorage:FindFirstChild("GameData")

    if not gameData then
        warn("GameData not found")
        return
    end

    local latestRoomInt = gameData:FindFirstChild("LatestRoom")

    if not latestRoomInt then
        warn("LatestRoom not found in GameData")
        return
    end

    local latestRoomValue = latestRoomInt.Value
    local latestRoomModel = currentRooms:FindFirstChild(tostring(latestRoomValue))

    if required.init then
        pcall(function()
            required.init()
        end)
    end

    if latestRoomModel and required.flickerLights then
        pcall(function()
            required.flickerLights(latestRoomModel, 52)
        end)
    end

    local cameraShakerModule = repStorage:FindFirstChild("CameraShaker")

    if not cameraShakerModule then
        warn("CameraShaker module not found")
        return
    end

    local cameraShaker = require(cameraShakerModule)
    local camera = workspace.CurrentCamera

    if not camera then
        warn("CurrentCamera not found")
        return
    end

    local camShake = cameraShaker.new(
        Enum.RenderPriority.Camera.Value,
        function(cf)
            if camera then
                camera.CFrame = camera.CFrame * cf
            end
        end
    )

    camShake:Start()

    local entity = nil
    local killed = false
    local ambruhspeed = 15
    local DEF_SPEED = 9999
    local storer = ambruhspeed
    local ambruhheight = Vector3.new(0, 3.4, 0)

    local rawUrl =
        "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/main/oldDeerGod.rbxm"

    if G.LoadGithubModel then
        local success, result = pcall(function()
            return G.LoadGithubModel(rawUrl, false)
        end)

        if success and result then
            entity = result
            entity.Parent = workspace
            currentEntity = entity
        else
            warn("Failed to load model: " .. tostring(result))
            return
        end
    end

    if not entity then
        warn("Entity is nil, exiting DeerGod")
        return
    end

    local entityPart = entity:FindFirstChildWhichIsA("BasePart")

    if not entityPart then
        warn("Entity has no BasePart")
        entity:Destroy()
        currentEntity = nil
        return
    end

    -- Visibility check: a wall or another obstacle blocks the ray.
    -- Hiding is checked separately before an attack is triggered.
    local function canSeeTarget(target, size)
        if killed then
            return false
        end

        local humanoidRootPart = target:FindFirstChild("HumanoidRootPart")

        if not humanoidRootPart or not entityPart or not entityPart.Parent then
            return false
        end

        local offset = humanoidRootPart.Position - entityPart.Position

        if offset.Magnitude == 0 or offset.Magnitude > size then
            return false
        end

        local ray = Ray.new(entityPart.Position, offset)
        local hit = workspace:FindPartOnRay(ray, entity)

        return hit ~= nil and hit:IsDescendantOf(target)
    end

    local function GetTime(dist, speed)
        if speed <= 0 then
            speed = 1
        end

        return dist / speed
    end

    task.wait(1)

    -- Death detection
    local deathThread = task.spawn(function()
        while entity ~= nil
            and entityPart ~= nil
            and entityPart.Parent ~= nil do

            task.wait(0.1)

            local player = game.Players.LocalPlayer

            if not player then
                continue
            end

            local character = player.Character

            if character
                and character:FindFirstChild("HumanoidRootPart")
                and character:FindFirstChild("Humanoid") then

                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local isHiding = character:GetAttribute("Hiding")

                if humanoid
                    and humanoid.Health > 0
                    and not isHiding
                    and canSeeTarget(character, 50) then

                    -- Mark as caught before starting the jumpscare
                    killed = true

                    -- NEW: Play the jumpscare before dealing lethal damage
                    playDeerGodJumpscare()

                    -- Apply damage after the jumpscare
                    if humanoid.Parent and humanoid.Health > 0 then
                        humanoid:TakeDamage(100)
                    end

                    local gameStats = repStorage:FindFirstChild("GameStats")

                    if gameStats then
                        local playerStats =
                            gameStats:FindFirstChild("Player_" .. character.Name)

                        if playerStats and playerStats:FindFirstChild("Total") then
                            local deathCause =
                                playerStats.Total:FindFirstChild("DeathCause")

                            if deathCause then
                                deathCause.Value = "Deer God"
                            end
                        end
                    end

                    local bricks = repStorage:FindFirstChild("Bricks")

                    if bricks then
                        local deathHint = bricks:FindFirstChild("DeathHint")

                        if deathHint and deathHint.OnClientEvent then
                            pcall(function()
                                firesignal(deathHint.OnClientEvent, {
                                    "You died to whom you call The Deer God",
                                    "Closets Wont work! So try running",
                                    "Its form is incomprehensible to a human upclose...",
                                    "..-so avoid Eye Contact"
                                })
                            end)
                        end
                    end

                    break
                end
            end
        end
    end)

    -- Camera shake
    local shakeThread = task.spawn(function()
        while entity ~= nil
            and entityPart ~= nil
            and entityPart.Parent ~= nil do

            task.wait(1.8)

            if camShake then
                pcall(function()
                    camShake:Shake(cameraShaker.Presets.Earthquake)
                end)
            end
        end
    end)

    -- Movement
    ambruhspeed = DEF_SPEED

    for i = 1, latestRoomValue + 1 do
        if not entityPart or not entityPart.Parent then
            break
        end

        local room = currentRooms:FindFirstChild(tostring(i))

        if room and room:FindFirstChild("Nodes") then
            local nodes = room.Nodes

            if required.breakLights then
                pcall(function()
                    required.breakLights(room)
                end)
            end

            local nodeList = {}

            for _, node in ipairs(nodes:GetChildren()) do
                table.insert(nodeList, node)
            end

            table.sort(nodeList, function(a, b)
                local numA = tonumber(a.Name) or 0
                local numB = tonumber(b.Name) or 0

                return numA < numB
            end)

            for _, node in ipairs(nodeList) do
                if not entityPart or not entityPart.Parent then
                    break
                end

                local dist = (entityPart.Position - node.Position).Magnitude
                local tweenService = game:GetService("TweenService")

                local jerk = tweenService:Create(
                    entityPart,
                    TweenInfo.new(
                        GetTime(dist, ambruhspeed),
                        Enum.EasingStyle.Linear,
                        Enum.EasingDirection.Out,
                        0,
                        false,
                        0
                    ),
                    {CFrame = node.CFrame + ambruhheight}
                )

                jerk:Play()
                jerk.Completed:Wait()

                ambruhspeed = storer
            end
        end
    end

    -- Cleanup
    if entityPart and entityPart.Parent then
        local tweenService = game:GetService("TweenService")

        local fallTween = tweenService:Create(
            entityPart,
            TweenInfo.new(1.5),
            {CFrame = entityPart.CFrame * CFrame.new(0, -80, 0)}
        )

        fallTween:Play()
        fallTween.Completed:Wait()
    end

    -- Award achievement if the player survived and was not caught.
    local player = game.Players.LocalPlayer
    local character = player and player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not killed and humanoid and humanoid.Health > 0 then
        pcall(function()
            AchievementsGet(DearGodAchievement)
        end)
    end

    game:GetService("Debris"):AddItem(entity, 1.5)
    currentEntity = nil
end

-- Start the script
if deerGodThread then
    pcall(function()
        if currentEntity then
            currentEntity:Destroy()
        end
    end)
end

deerGodThread = task.spawn(DeerGod)
