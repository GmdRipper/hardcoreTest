local hints = {
    "You died to who you call Dread...",
    "He punishes those who stay in one place or look right at him.",
    "Don't look at it when it appears!"
}

local rep = game.ReplicatedStorage
local G = getgenv()

G.LoadDreadModel = function(url)
    if not (writefile and getcustomasset and request) then return nil end
    local response = request({Url = url, Method = "GET"})
    if response.StatusCode ~= 200 then return nil end
    local fileName = "dread_" .. tick() .. ".rbxm"
    writefile(fileName, response.Body)
    local assetId = getcustomasset(fileName)
    local success, result = pcall(function()
        return game:GetObjects(assetId)[1]
    end)
    if success and result then return result end
    return nil
end

task.spawn(function()
    local camera = workspace.CurrentCamera
    local cameraShaker = require(game.ReplicatedStorage.CameraShaker)
    local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(cf)
        camera.CFrame = camera.CFrame * cf
    end)
    camShake:Start()

    local gameData = game.ReplicatedStorage:WaitForChild("GameData")
    local latestRoom = gameData:WaitForChild("LatestRoom")
    local player = game.Players.LocalPlayer
    local entity = nil
    local killed = false

    local function isBossActive()
        local room = latestRoom.Value
        if room == 48 or room == 99 or workspace:FindFirstChild("SeekMoving") or workspace.CurrentRooms:FindFirstChild("50") then return true end
        for _, sound in pairs(game.ReplicatedStorage:GetDescendants()) do
            if sound:IsA("Sound") and sound.IsPlaying and (sound.Name:find("Music") or sound.Name == "Shade") then
                return true
            end
        end
        return false
    end

    if isBossActive() then return end

    local successLoad, modelResult = pcall(function()
        return game:GetObjects("rbxassetid://12654337720")[1]
    end)
    
    if successLoad and modelResult then
        entity = modelResult
    end

    if not entity then return end
    entity.Parent = workspace

    local room = workspace.CurrentRooms:FindFirstChild(tostring(latestRoom.Value))
    local main = entity:FindFirstChild("RushNew") or entity:FindFirstChildWhichIsA("BasePart")
    if not main then entity:Destroy() return end

    if room and room:FindFirstChild("Nodes") then
        local nodes = room.Nodes:GetChildren()
        local midNode = nodes[math.floor(#nodes / 2)]
        if midNode then
            main.CFrame = midNode.CFrame + Vector3.new(0, 6, 0)
        end
    end

    camShake:ShakeOnce(2, 10, 1, 1)

    local dreadLight = game.Lighting:FindFirstChild("Ambience_Dread")
    if dreadLight then
        dreadLight.Enabled = true
        dreadLight.Brightness = 0
        dreadLight.Contrast = 0
        dreadLight.Saturation = 0
        game.TweenService:Create(dreadLight, TweenInfo.new(2), {
            Brightness = 0.1,
            Contrast = 0.2,
            Saturation = -0.7
        }):Play()
    end

    local function IsVisible(part)
        local vec, found = camera:WorldToViewportPoint(part.Position)
        local onscreen = found and vec.Z > 0
        local char = player.Character
        if not char or not char:FindFirstChild("UpperTorso") then return false end
        
        local cfg = RaycastParams.new()
        cfg.FilterType = Enum.RaycastFilterType.Blacklist
        cfg.FilterDescendantsInstances = {part}

        local cast = workspace:Raycast(part.Position, (char.UpperTorso.Position - part.Position), cfg)
        return onscreen and cast and cast.Instance and cast.Instance:IsDescendantOf(char)
    end

    task.spawn(function()
        while entity and entity.Parent and not killed do
            task.wait(0.1)
            if IsVisible(main) and not player.Character:GetAttribute("Hiding") then
                killed = true

                local mainGameModule = require(player.PlayerGui.MainUI.Initiator.Main_Game)
                mainGameModule.stopcam = true
                
                local ccf = camera.CFrame
                camera.CameraType = Enum.CameraType.Scriptable
                
                local tweenCam = game.TweenService:Create(camera, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                    CFrame = CFrame.lookAt(ccf.p, main.Position)
                })
                tweenCam:Play()
                task.wait(0.15)

                local deathSound = Instance.new("Sound", workspace)
                deathSound.SoundId = "rbxassetid://10483790459"
                deathSound.Volume = 6
                deathSound:Play()
                
                tweenCam:Pause()

                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") then
                        v.TimeScale = 0
                    end
                end

                task.wait(2)

                game.Lighting.MainColorCorrection.Brightness = -1
                game.Lighting.MainColorCorrection.Contrast = -4
                game.Lighting.MainColorCorrection.Saturation = -1

                camShake:ShakeOnce(10, 100, 0.1, 2)
                task.wait(1)

                mainGameModule.stopcam = false

                local char = player.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    char.Humanoid:TakeDamage(100)
                end

                pcall(function()
                    local stats = rep:FindFirstChild("GameStats")
                    if stats and stats:FindFirstChild("Player_".. player.Name) then
                        stats["Player_".. player.Name].Total.DeathCause.Value = "Dread"
                    end
                    
                    local remotes = rep:FindFirstChild("Bricks") or rep:FindFirstChild("RemotesFolder")
                    if remotes and remotes:FindFirstChild("DeathHint") then
                        firesignal(remotes.DeathHint.OnClientEvent, hints, "Blue")
                    end
                end)

                entity:Destroy()
                if dreadLight then dreadLight.Enabled = false end
                break
            end
        end
    end)

    task.delay(12, function()
        if entity and entity.Parent then
            if dreadLight then dreadLight.Enabled = false end
            entity:Destroy()
        end
    end)
end)
