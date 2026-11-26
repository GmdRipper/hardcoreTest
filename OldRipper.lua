local G = getgenv()
G.LoadGithubModel = function(url, retryCount)
    retryCount = retryCount or 0

    if retryCount > 3 then
        return nil
    end

    if not (writefile and getcustomasset and request and isfile and delfile) then
        return nil
    end

    local function getHash(str)
        local hash = 0
        for i = 1, #str do
            hash = (hash * 31 + string.byte(str, i)) % 2^32
        end
        return tostring(hash)
    end

    local fileName = "ripper_" .. getHash(url) .. ".rbxm"

    if retryCount > 0 and isfile(fileName) then
        pcall(function()
            delfile(fileName)
        end)
    end

    if not isfile(fileName) then
        local response = request({
            Url = url,
            Method = "GET"
        })

        if response.StatusCode ~= 200 then
            if retryCount < 3 then
                return G.LoadGithubModel(url, retryCount + 1)
            end
            return nil
        end

        writefile(fileName, response.Body)
    end

    local assetId = getcustomasset(fileName)
    local success, result = pcall(function()
        local objects = game:GetObjects(assetId)
        if objects and #objects > 0 then
            return objects[1]:Clone()
        end
        return nil
    end)

    if success and result then
        return result
    end

    return G.LoadGithubModel(url, retryCount + 1)
end

local function DownloadRipperScareSound()
    local url = "https://github.com/fernandesdasilvamariainez-coder/Roblox-Doors-Entities-Sounds/blob/main/ripperscare.mp3?raw=true"
    local fileName = "ripper_scare_sound.mp3"

    if not (writefile and getcustomasset and isfile) then
        return ""
    end

    if not isfile(fileName) then
        local ok, data = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and data and #data > 0 then
            pcall(function()
                writefile(fileName, data)
            end)
        end
    end

    if isfile(fileName) then
        local ok, asset = pcall(function()
            return getcustomasset(fileName)
        end)
        if ok and asset then
            return asset
        end
    end

    return ""
end

local ripperScareAssetId = DownloadRipperScareSound()

-- АЧИВКА В СТИЛЕ REBOUND
local RipperAchievement = {
    Title = "Torn Apart",
    Desc = "Dont leave too early..",
    Reason = "Encounter Ripper",
    Image = "rbxassetid://112562469367494",
}

local RIPPER_ACHIEVEMENT_FLAG = "RipperAchievementUnlocked"

local function GiveRipperAchievement()
    if workspace:FindFirstChild(RIPPER_ACHIEVEMENT_FLAG) then
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
    obtainedBadge.Name = RIPPER_ACHIEVEMENT_FLAG
    obtainedBadge.Value = true
    obtainedBadge.Parent = workspace

    task.spawn(function()
        local frame = template:Clone()
        frame.Name = "LiveAchievement"
        frame.Frame.Details.Title.Text = RipperAchievement.Title
        frame.Frame.Details.Desc.Text = RipperAchievement.Desc
        frame.Frame.Details.Reason.Text = RipperAchievement.Reason
        frame.Frame.ImageLabel.Image = RipperAchievement.Image
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

local function Ripper()
    local breakMove = false
    local killed = false
    local repStorage = game.ReplicatedStorage
    local gameData = repStorage.GameData
    local latestRoom = gameData.LatestRoom
    local currentRooms = workspace.CurrentRooms
    local entity = nil
    local ambruhspeed = 100
    local DEF_SPEED = 99999
    local storer = ambruhspeed
    local ambruhheight = Vector3.new(0, 1.2, 0)

    local cameraShaker = require(repStorage.CameraShaker)
    local camera = workspace.CurrentCamera

    local camShake = cameraShaker.new(
        Enum.RenderPriority.Camera.Value,
        function(cf)
            camera.CFrame = camera.CFrame * cf
        end
    )

    camShake:Start()
    camShake:Shake(cameraShaker.Presets.Earthquake)

    local rawUrl = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/main/oldRipper.rbxml.rbxm"

    if G.LoadGithubModel then
        entity = G.LoadGithubModel(rawUrl)

        if entity then
            entity.Parent = workspace
        end
    end

    if not entity then
        return
    end

    local tweenLights = TweenInfo.new(1)
    local color = {
        Color = Color3.fromRGB(255, 0, 0)
    }

    local spawnSound = Instance.new("Sound")
    spawnSound.Parent = workspace
    spawnSound.SoundId = "rbxassetid://9125713501"
    spawnSound.PlaybackSpeed = 0.6
    spawnSound.Volume = 10

    local pitchShift = Instance.new("PitchShiftSoundEffect")
    pitchShift.Parent = spawnSound
    pitchShift.Octave = 0.875

    spawnSound:Play()
    game.Debris:AddItem(spawnSound, 16)

    local entityPart = entity:FindFirstChildWhichIsA("BasePart")

    if not entityPart then
        entity:Destroy()
        return
    end

    for _, v in pairs(currentRooms:GetDescendants()) do
        if v:IsA("Light") then
            game.TweenService:Create(v, tweenLights, color):Play()

            if v.Parent.Name == "LightFixture" then
                game.TweenService:Create(v.Parent, tweenLights, color):Play()
            end
        end
    end

    local function canSeeTarget(target, size)
        if killed then
            return
        end

        local targetRoot = target:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            return false
        end

        local origin = entityPart.Position
        local direction = (targetRoot.Position - origin).Unit * size
        local ray = Ray.new(origin, direction)
        local hit = workspace:FindPartOnRay(ray, entityPart)

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

    local function ForceRipperDeathHint(char)
        local deathLines = {
            "You died to who you call Ripper...",
            "It's presence is known by the red lights...",
            "Hide when this happens!"
        }

        pcall(function()
            repStorage.GameStats[
                "Player_" .. char.Name
            ].Total.DeathCause.Value = "Ripper"
        end)

        pcall(function()
            firesignal(
                repStorage.Bricks.DeathHint.OnClientEvent,
                deathLines
            )
        end)
    end

    task.spawn(function()
        while entityPart ~= nil and entity ~= nil and entity.Parent do
            task.wait(0.2)

            local v = game.Players.LocalPlayer

            if v.Character ~= nil and v.Character:FindFirstChild("HumanoidRootPart") then
                if canSeeTarget(v.Character, 50)
                    and not v.Character:GetAttribute("Hiding") then

                    breakMove = true

                    local Noise = Instance.new("ScreenGui")
                    local ImageLabel = Instance.new("ImageLabel")
                    Noise.Name = "Noise"
                    Noise.Parent = v:WaitForChild("PlayerGui")
                    Noise.IgnoreGuiInset = true

                    ImageLabel.Parent = Noise
                    ImageLabel.BackgroundTransparency = 1.000
                    ImageLabel.Size = UDim2.new(1, 0, 1, 0)
                    ImageLabel.Image = "rbxassetid://236542974"
                    ImageLabel.ImageTransparency = 1.000

                    coroutine.wrap(function()
                        local char = v.Character
                        local ripper = entityPart

                        pcall(function()
                            repStorage.GameStats[
                                "Player_" .. char.Name
                            ].Total.DeathCause.Value = "Ripper"
                        end)

                        local ripperscare = ripper:Clone()
                        ripperscare.Parent = workspace
                        ripperscare.Position = ripper.Position

                        local ripePart = ripperscare:FindFirstChild("ripe")
                        if ripePart and ripePart:FindFirstChild("ParticleEmitter") then
                            ripePart.ParticleEmitter.Texture = "rbxassetid://11816152645"
                        end

                        for _, x in ipairs(ripperscare:GetDescendants()) do
                            if x:IsA("ParticleEmitter") then
                                task.spawn(function()
                                    x.Rate = 9999
                                    task.wait(0.25)
                                    x.TimeScale = 0.0
                                end)
                            elseif x:IsA("Sound") then
                                x.Volume = 0
                            end
                        end

                        entity:Destroy()

                        local static = Instance.new("Sound", workspace)
                        static.SoundId = "rbxassetid://372770465"
                        static.Volume = 0
                        static.Pitch = 0.7

                        local crash = Instance.new("Sound", workspace)
                        crash.SoundId = ripperScareAssetId
                        crash.Volume = 3
                        crash.Pitch = 1

                        local make = Instance.new("Part", workspace)
                        make.Transparency = 1
                        make.CanCollide = false
                        make.CanTouch = false
                        make.Anchored = true
                        make.Name = "pants pooper"

                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.Anchored = true
                        end

                        make.CFrame = workspace.CurrentCamera.CFrame

                        if crash.SoundId ~= "" then
                            crash:Play()
                        end

                        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

                        local sceneing = true
                        local sillybilly = {8482795900, 236542974, 184251462, 236777652}

                        task.spawn(function()
                            while game:GetService("RunService").RenderStepped:Wait() and sceneing do
                                workspace.CurrentCamera.CFrame = make.CFrame
                                ImageLabel.Image = "rbxassetid://" .. sillybilly[math.random(1, #sillybilly)]
                            end
                        end)

                        local t = game.TweenService:Create(
                            make,
                            TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut),
                            {
                                CFrame = CFrame.lookAt(make.Position, ripperscare.Position)
                            }
                        )
                        t:Play()
                        t.Completed:Wait()

                        task.wait(1)

                        game.TweenService:Create(
                            ImageLabel,
                            TweenInfo.new(2),
                            {
                                ImageTransparency = 0
                            }
                        ):Play()

                        static:Play()
                        static.Volume = 0
                        game.TweenService:Create(
                            static,
                            TweenInfo.new(2),
                            {
                                Volume = 10
                            }
                        ):Play()

                        task.wait(2)

                        sceneing = false

                        game.TweenService:Create(
                            ImageLabel,
                            TweenInfo.new(1),
                            {
                                ImageTransparency = 1
                            }
                        ):Play()

                        game.TweenService:Create(
                            static,
                            TweenInfo.new(1),
                            {
                                Volume = 0
                            }
                        ):Play()

                        ripperscare.Anchored = false
                        ripperscare.CanCollide = false

                        if root then
                            root.Anchored = false
                        end

                        ForceRipperDeathHint(char)

                        local humanoid = char:FindFirstChildWhichIsA("Humanoid")

                        if humanoid and humanoid.Health > 0 then
                            humanoid:TakeDamage(100)

                            if humanoid.Health > 0 then
                                humanoid.Health = 0
                            end
                        end

                        task.delay(0.05, function()
                            ForceRipperDeathHint(char)
                        end)
                        task.delay(0.25, function()
                            ForceRipperDeathHint(char)
                        end)
                    end)()
                end
            end

            if v.Character ~= nil
                and v.Character:FindFirstChild("HumanoidRootPart")
                and (entityPart.Position - v.Character.HumanoidRootPart.Position).Magnitude <= 60 then

                camShake:Start()
                camShake:ShakeOnce(15, 25, 0, 2, 1, 6)
            end

            if breakMove then
                break
            end
        end
    end)

    if entityPart:FindFirstChild("Ambush") then
        entityPart.Ambush:Stop()
        entityPart.Ambush.Volume = 10
        task.wait(8)
        entityPart.Ambush:Play()

        game.TweenService:Create(
            entityPart.Ambush,
            TweenInfo.new(6),
            {
                Volume = 0.8
            }
        ):Play()
    end

    ambruhspeed = DEF_SPEED

    for i = 1, latestRoom.Value do
        local room = currentRooms:FindFirstChild(tostring(i))

        if room and room:FindFirstChild("Nodes") then
            local nodes = room.Nodes

            for v_idx = 1, #nodes:GetChildren() do
                local node = nodes:FindFirstChild(tostring(v_idx))

                if node then
                    if breakMove then
                        break
                    end

                    local dist = (entityPart.Position - node.Position).Magnitude

                    local bruh = game.TweenService:Create(
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

                    bruh:Play()
                    bruh.Completed:Wait()

                    ambruhspeed = storer

                    if room.Name == tostring(latestRoom.Value) then
                        pcall(function()
                            room.Door.ClientOpen:FireServer()
                        end)
                    end
                end
            end
        end

        if breakMove then
            break
        end
    end

    local slam = Instance.new("Sound", entityPart)
    slam.Volume = 10
    slam.SoundId = "rbxassetid://1837829565"

    camShake:Shake(cameraShaker.Presets.Explosion)
    slam:Play()

    task.wait(1)

    entityPart.Anchored = false
    entityPart.CanCollide = false

    game.Debris:AddItem(entity, 5)

    task.wait(0.1)
    GiveRipperAchievement()
end

task.spawn(Ripper)
