-- XENO GITHUB MODEL LOADER (.rbxm / .rbxmx)
local G = getgenv()
local ReplicatedStorage = game.ReplicatedStorage

-- Garantindo que a função exista no ambiente Global
G.LoadGithubModel = function(url)
    if not (writefile and getcustomasset and request) then
        return nil
    end
    local response = request({Url = url, Method = "GET"})
    if response.StatusCode ~= 200 then return nil end
    local fileName = "temp_model_" .. tick() .. ".rbxm"
    writefile(fileName, response.Body)
    local assetId = getcustomasset(fileName)
    local success, result = pcall(function()
        return game:GetObjects(assetId)[1]
    end)
    if success and result then return result end
    return nil
end

local G = getgenv()

G.LoadGithubAudio = function(url)
    if not (writefile and getcustomasset and request) then return nil end

    -- Bypass de Cache: Adiciona um número aleatório ao final para forçar o download limpo
    local cleanUrl = url .. "?t=" .. math.random(1, 100000)

    local response = request({
        Url = cleanUrl,
        Method = "GET",
        Headers = {
            ["Accept"] = "audio/mpeg, audio/ogg, application/octet-stream"
        }
    })

    if response.StatusCode ~= 200 then
        warn("Xeno: Falha no download. Status: " .. response.StatusCode)
        return nil
    end

    -- Nome único para evitar conflitos de escrita
    local fileName = "deergodchase_" .. tick() .. ".mp3"
    
    -- Salva e força a leitura
    writefile(fileName, response.Body)
    
    local success, assetId = pcall(function()
        return getcustomasset(fileName)
    end)

    if success then
        print("✅ Áudio Rebound carregado com sucesso!")
        return assetId
    end
    
    warn("Erro no getcustomasset: " .. tostring(assetId))
    return nil
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
    Image = "https://raw.githubusercontent.com/GmdRipper/hardcoreTest/main/DearGodAchivement.jpg",
}

-- Выдаёт ачивку Deer God только один раз за игровую сессию
local function GiveDearGodAchievement()
    if workspace:FindFirstChild("DearGodAchievement") then
        return
    end

    local success, err = pcall(function()
        AchievementsGet(DearGodAchievement)
    end)

    if not success then
        warn("Deer God achievement error: " .. tostring(err))
        return
    end

    local obtainedBadge = Instance.new("BoolValue")
    obtainedBadge.Name = "DearGodAchievement"
    obtainedBadge.Value = true
    obtainedBadge.Parent = workspace
end

-- DeerGod jumpscare
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
    task.wait(0.8)

    active = false

    restoreOtherSounds()
    if screenGui then
        screenGui:Destroy()
    end
end

local function DeerGod()
    local ambruhspeed = 15
    local DEF_SPEED = 99999
    local storer = ambruhspeed
    local ambruhheight = Vector3.new(0, 3.4, 0)
    local repStorage = game.ReplicatedStorage
    local gameData = repStorage.GameData
    local latestRoom = gameData.LatestRoom
    local currentRooms = workspace.CurrentRooms
    local killed = false
    local deergodId = "rbxassetid://12262883448"
    local entity = game:GetObjects(deergodId)[1]
    entity.Parent = workspace
    local chaseTheme = 123456789 -- Replace with your actual sound ID
    local chaseMusic = Instance.new("Sound")
    chaseMusic.Parent = workspace
    chaseMusic.SoundId = chaseTheme
    chaseMusic.Volume = 3
    chaseMusic.Looped = true
    chaseMusic:Play()

    if not entity then return end

    local entityPart = entity:FindFirstChildWhichIsA("BasePart")
    local function canSeeTarget(target, size)
        if killed == true then
            return
        end
        local function isBossActive()
            local room = latestRoom.Value
            if room == 50 or room == 100 then return true end
            
            for _, sound in pairs(game.ReplicatedStorage:GetDescendants()) do
                if sound:IsA("Sound") and sound.IsPlaying and (sound.Name:find("Music") or sound.Name == "Shade") then
                    return true
                end
            end
            return false
        end

        if isBossActive() then return end

        local origin = entityPart.Position
        local direction = (target.HumanoidRootPart.Position - origin).unit * size
        local ray = Ray.new(origin, direction)

        local hit, pos = workspace:FindPartOnRay(ray, entityPart)

        if hit then
            if hit:IsDescendantOf(target) then
                killed = true
                return true
            end
        else
            return false
        end
    end
    local function GetTime(dist, speed)
        return dist / speed
    end
    wait(1)
    spawn(function()
        while entity ~= nil and entityPart ~= nil do wait(0.01)
            local v = game.Players.LocalPlayer
            if v.Character ~= nil and v.Character.HumanoidRootPart then
                if canSeeTarget(v.Character, 50) and not v.Character:GetAttribute("Hiding") then
                    killed = true
                    
                    -- Вызов скримера из первого примера
                    playDeerGodJumpscare()

                    v.Character.Humanoid:TakeDamage(100)
                    game.ReplicatedStorage.GameStats["Player_".. v.Character.Name].Total.DeathCause.Value = "Deer God"
                    local hints = {
                        "You died to whom you call The Deer God",
                        "Closets Wont work! So try running",
                        "Its form is incomprehensible to a human upclose...",
                        "..-so avoid Eye Contact"
                    }
                    if ReplicatedStorage:FindFirstChild("RemotesFolder") then
                        local remotesFolder = ReplicatedStorage:FindFirstChild("RemotesFolder")
                        firesignal(remotesFolder.DeathHint.OnClientEvent, hints, "Blue")
                    elseif ReplicatedStorage:FindFirstChild("Bricks") then
                        local remotesFolder = ReplicatedStorage:FindFirstChild("Bricks")
                        firesignal(remotesFolder.DeathHint.OnClientEvent, hints, "Blue")
                    end
                end
            end
        end
    end)

    ambruhspeed = DEF_SPEED
    for i = 1, latestRoom.Value + 1 do
        if currentRooms:FindFirstChild(i) then
            local room = currentRooms[i]
            if room and room:FindFirstChild("Nodes") then
                local nodes = room:FindFirstChild("Nodes")
                for v = 1, #nodes:GetChildren() do
                    if nodes:FindFirstChild(v) then
                        local node = nodes[v]
                        local dist = (entityPart.Position - node.Position).magnitude
                        local jerk = game.TweenService:Create(entityPart, TweenInfo.new(GetTime(dist, ambruhspeed), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0,false,0), {CFrame = node.CFrame + ambruhheight})
                        jerk:Play()
                        jerk.Completed:Wait()
                        ambruhspeed = storer
                    end
                end
            end
        end
    end
    game.TweenService:Create(entityPart, TweenInfo.new(1.5), {CFrame = entityPart.CFrame * CFrame.new(0,-80,0)}):Play()
    
    -- Выдача достижения при успешном выживании
    local player = game.Players.LocalPlayer
    local character = player and player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if not killed and humanoid and humanoid.Health > 0 then
        GiveDearGodAchievement()
    end

    game:GetService("Debris"):AddItem(entity, 1.5)
    wait(1.5)
    chaseMusic:Destroy()
end
pcall(DeerGod)
