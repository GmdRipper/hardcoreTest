local hints = {
    "You died to an entity designated as A-60",
    "It can appear at any moment, a loud scream will announce its presence",
    "When you hear it spawn you must stay out of its reach as soon as possible",
    "It knows exactly where you are so hiding in different places will not work"
}

local rep = game.ReplicatedStorage

local function loadModel(id)
    local obj = nil
    local attempts = 0
    local maxAttempts = 20

    while obj == nil and attempts < maxAttempts do
        attempts = attempts + 1
        local success, result = pcall(function()
            return game:GetObjects("rbxassetid://" .. id)
        end)

        if success and result and result[1] then
            obj = result[1]
        else
            task.wait(0.5)
        end
    end

    if not obj then
        warn("Failed to load model after max attempts.")
    end
    
    return obj
end

local function GetGitSound(GithubSnd, SoundName)
    local url = GithubSnd
    if not isfile(SoundName .. ".mp3") then
        writefile(SoundName .. ".mp3", game:HttpGet(url))
    end
    local sound = Instance.new("Sound")
    sound.SoundId = (getcustomasset or getsynasset)(SoundName .. ".mp3")
    return sound
end

local function isBossActive()
    local gameData = game.ReplicatedStorage:FindFirstChild("GameData")
    if not gameData then return false end
    local latestRoom = gameData:FindFirstChild("LatestRoom")
    
    local room = latestRoom.Value
    if room == 48 or room == 99 then return true end
    
    for _, sound in pairs(game.ReplicatedStorage:GetDescendants()) do
        if sound:IsA("Sound") and sound.IsPlaying and (sound.Name:find("Music") or sound.Name == "Shade") then
            return true
        end
    end
    return false
end

task.spawn(function()
    local camera = workspace.CurrentCamera
    local shakerModule = game.ReplicatedStorage:FindFirstChild("CameraShaker")
    if not shakerModule then return end
    
    local cameraShaker = require(shakerModule)
    local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(cf)
        camera.CFrame = camera.CFrame * cf
    end)
    camShake:Start()

    local gameData = game.ReplicatedStorage:WaitForChild("GameData")
    local latestRoom = gameData:WaitForChild("LatestRoom")
    local ambruhheight = Vector3.new(0, 3, 0)
    local ambruhspeed = 160
    local DEF_SPEED = 9999
    local randomizedtimes = 4
    local killed = false

    local entity = loadModel(15972282065)
    if not entity then return end
    
    entity.Parent = workspace
    local pr = entity:FindFirstChildWhichIsA("BasePart") or entity:FindFirstChildWhichIsA("MeshPart")
    if not pr then return end

    local function GetTime(dist, speed)
        return dist / speed
    end

    local function TriggerJumpscare()
        local ScreenGui = Instance.new("ScreenGui")
        local JumpscareEnd = Instance.new("ImageLabel")
        local Full = Instance.new("ImageLabel")

        ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        JumpscareEnd.Name = "JumpscareEnd"
        JumpscareEnd.Parent = ScreenGui
        JumpscareEnd.BackgroundTransparency = 1.000
        JumpscareEnd.Position = UDim2.new(0.468161434, 0, 0.455128193, 0)
        JumpscareEnd.Size = UDim2.new(0.0636771321, 0, 0.0884615406, 0)
        JumpscareEnd.Image = "rbxassetid://0"
        JumpscareEnd.ImageColor3 = Color3.fromRGB(255, 0, 4)

        Full.Name = "Full"
        Full.Parent = ScreenGui
        Full.BackgroundTransparency = 1.000
        Full.Position = UDim2.new(-0.0609865487, 0, -0.224358946, 0)
        Full.Size = UDim2.new(1.12197304, 0, 1.44743586, 0)
        Full.Image = "http://www.roblox.com/asset/?id=11151804223"
        Full.ImageTransparency = 1.000

        local Jumpscaring = true
        local monster1 = pr:Clone()
        
        local function ImageChange(Part)
            task.spawn(function()
                while game["Run Service"].Heartbeat:Wait() do
                    local idsHolder = Part:FindFirstChild("IMAGEIDS")
                    if idsHolder then
                        local get = idsHolder:GetChildren()
                        if #get > 0 then
                            local randome = get[math.random(1, #get)]
                            local face = Part:FindFirstChild("Main", true) and Part:FindFirstChild("Main", true):FindFirstChild("Face")
                            if face and randome:IsA("ImageLabel") then
                                face.Texture = randome.Image
                            end
                        end
                    end
                    task.wait(Random.new():NextNumber(0, 0.02))
                end
            end)
        end

        monster1.Parent = Camera 
        ImageChange(monster1) 
        monster1.Name = "A-60_SCARE"
        
        for _, v in pairs(monster1:GetDescendants()) do
            if v:IsA("Sound") then v:Destroy() end 
        end
        
        local EntityOffset = Vector3.new(0, -1.2, -5)
        local LerpAlpha = 0.8
        
        local JumpscareSound = GetGitSound("https://github.com/eoyoustme/Script/raw/beb0e7ff0479ee1eb63b18a0355c740f01b10336/A60Jumpscare", "asixtyScareOmg") 
        JumpscareSound.Parent = workspace
        JumpscareSound.Volume = 6
        JumpscareSound:Play()
        
        camShake:ShakeOnce(25, 25, 0, 4, 90, 60)
        local JumpscareContrast = Instance.new("ColorCorrectionEffect", game.Lighting)
        game.TweenService:Create(JumpscareContrast, TweenInfo.new(0.5), {Brightness = 0.2, Contrast = 0.2, Saturation = -0.2, TintColor = Color3.fromRGB(255, 0, 4)}):Play()
        
        task.spawn(function()
            while Jumpscaring do 
                game["Run Service"].RenderStepped:Wait()
                monster1.CFrame = monster1.CFrame:Lerp(Camera.CFrame * CFrame.new(EntityOffset), LerpAlpha)
            end
            game.TweenService:Create(monster1, TweenInfo.new(1), {CFrame = Camera.CFrame * CFrame.new(Vector3.new(0, -1.2, 45))}):Play()
        end)
        
        task.wait(0.5) 
        Jumpscaring = false
        
        local mainFace = monster1:FindFirstChild("Main", true) and monster1:FindFirstChild("Main", true):FindFirstChild("Face")
        if mainFace then
            JumpscareEnd.Image = mainFace.Texture
        end
        
        game.TweenService:Create(JumpscareEnd, TweenInfo.new(0.5), {Size = Full.Size, Position = Full.Position, Rotation = math.random(-20, 20)}):Play()
        game.TweenService:Create(JumpscareContrast, TweenInfo.new(10), {Brightness = 0, Contrast = 0, Saturation = 0, TintColor = Color3.fromRGB(255, 255, 255)}):Play()
        
        local v = game.Players.LocalPlayer
        if v.Character and v.Character:FindFirstChildOfClass("Humanoid") then
            v.Character:FindFirstChildOfClass("Humanoid"):TakeDamage(100)
        end
        
        local stats = rep:FindFirstChild("GameStats")
        if stats and stats:FindFirstChild("Player_".. v.Name) then
            stats["Player_".. v.Name].Total.DeathCause.Value = "A-60"
        end
        
        local remotes = rep:FindFirstChild("RemotesFolder") or rep:FindFirstChild("Bricks")
        if remotes and remotes:FindFirstChild("DeathHint") then
            if remotes.Name == "RemotesFolder" then
                firesignal(remotes.DeathHint.OnClientEvent, hints, "Blue")
            else
                firesignal(remotes.DeathHint.OnClientEvent, hints)
            end
        end
        
        task.wait(0.5)
        game.TweenService:Create(JumpscareEnd, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
        game.Debris:AddItem(monster1, 1)
    end

    local function canSeeTarget(target, size)
        if killed then return end
        local origin = pr.Position
        local targetPos = target.HumanoidRootPart.Position
        local direction = (targetPos - pr.Position).unit * size
        local ray = Ray.new(origin, direction)
        local hit = workspace:FindPartOnRay(ray, pr)
        
        if hit and hit:IsDescendantOf(target) then
            return true
        end
        return false
    end

    task.wait(1)

    task.spawn(function()
        while entity and entity.Parent do 
            task.wait(0.1)
            local v = game.Players.LocalPlayer
            if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local root = v.Character.HumanoidRootPart
                
                if canSeeTarget(v.Character, 70) and not v.Character:GetAttribute("Hiding") then
                    killed = true
                    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Francisco1692qzd/Doors-Hotel-Hardcore/refs/heads/main/wow!.lua"))() end)
                    task.spawn(TriggerJumpscare)
                    break
                end

                if (pr.Position - root.Position).magnitude <= 70 then
                    camShake:ShakeOnce(43, 20, 0.1, 2.3, 1, 6)
                end
            end
        end
    end)

    local gruh = workspace.CurrentRooms
    ambruhspeed = DEF_SPEED

    local function Forward()
        local limit = latestRoom.Value
        for i = 1, limit do
            if killed then break end
            local room = gruh:FindFirstChild(tostring(i))
            if room and room:FindFirstChild("Nodes") then
                local nodes = room.Nodes:GetChildren()
                table.sort(nodes, function(a,b) return tonumber(a.Name) < tonumber(b.Name) end)
                for _, node in ipairs(nodes) do
                    if killed then break end
                    local distance = (pr.Position - node.Position).magnitude
                    local jerk = game.TweenService:Create(pr, TweenInfo.new(GetTime(distance, ambruhspeed), Enum.EasingStyle.Linear), {CFrame = node.CFrame + ambruhheight})
                    jerk:Play()
                    jerk.Completed:Wait()
                    if ambruhspeed ~= 160 then ambruhspeed = 160 end
                end
            end
        end
    end

    local function Backward()
        local limit = latestRoom.Value
        for i = limit, 1, -1 do
            if killed then break end
            local room = gruh:FindFirstChild(tostring(i))
            if room and room:FindFirstChild("Nodes") then
                local nodes = room.Nodes:GetChildren()
                table.sort(nodes, function(a,b) return tonumber(a.Name) < tonumber(b.Name) end)
                for n = #nodes, 1, -1 do
                    if killed then break end
                    local node = nodes[n]
                    local distance = (pr.Position - node.Position).magnitude
                    local jerk = game.TweenService:Create(pr, TweenInfo.new(GetTime(distance, ambruhspeed), Enum.EasingStyle.Linear), {CFrame = node.CFrame + ambruhheight})
                    jerk:Play()
                    jerk.Completed:Wait()
                    if ambruhspeed ~= 160 then ambruhspeed = 160 end
                end
            end
        end
    end

    for i = 1, randomizedtimes do
        if killed then break end
        pcall(Forward)
        task.wait(1)
        if killed then break end
        pcall(Backward)
        task.wait(1)
    end

    if entity and entity.Parent then
        entity:Destroy()
    end
    
    local light = Instance.new("ColorCorrectionEffect", game.Lighting)
    light.Brightness, light.Saturation, light.Contrast = -0.4, 0.4, -0.5
    light.TintColor = Color3.fromRGB(255, 0, 0)
    
    game.TweenService:Create(light, TweenInfo.new(20), {
        Brightness = 0, Contrast = 0, Saturation = 0, TintColor = Color3.fromRGB(255, 255, 255)
    }):Play()
    
    game.Debris:AddItem(light, 20)
    camShake:ShakeOnce(23, 45, 0, 16, 1, 6)
end)
