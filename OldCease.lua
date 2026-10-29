-- XENO GITHUB MODEL LOADER (.rbxm / .rbxmx)
local G = getgenv()

G.LoadGithubModel = function(url, retryCount)
    retryCount = retryCount or 0
    
    if retryCount >= 3 then
        warn("Failed to load model after 3 attempts")
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
    
    local fileName = "cease_old_" .. getHash(url) .. ".rbxm"
    
    if retryCount > 0 and isfile(fileName) then
        pcall(function() delfile(fileName) end)
        task.wait(1)
    end
    
    if not isfile(fileName) then
        local response = request({Url = url, Method = "GET"})
        if response.StatusCode ~= 200 then 
            return G.LoadGithubModel(url, retryCount + 1)
        end
        writefile(fileName, response.Body)
    end
    
    local assetId = getcustomasset(fileName)
    local success, result = pcall(function()
        local objects = game:GetObjects(assetId)
        if objects and #objects > 0 then
            return objects[1]
        end
        return nil
    end)
    
    if success and result then 
        local cloneSuccess, cloned = pcall(function()
            return result:Clone()
        end)
        if cloneSuccess and cloned then
            return cloned
        end
    end
    
    pcall(function() 
        if delfile then delfile(fileName) end 
    end)
    
    return G.LoadGithubModel(url, retryCount + 1)
end

local function Cease()
    if (workspace:FindFirstChild("Ambience_Seek") and workspace.Ambience_Seek.Playing) then
        return
    end

    local killed = false
    local Plr = game.Players.LocalPlayer
    local ReSt = game.ReplicatedStorage
    local val = 80
    local cameraShaker = require(game.ReplicatedStorage.CameraShaker)
    local camera = workspace.CurrentCamera

    local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(cf)
        camera.CFrame = camera.CFrame * cf
    end)

    camShake:Start()

    local function GetTime(Distance, Speed)
        local Time = Distance / Speed
        return Time
    end

    local function MakeNormal(Light)
        spawn(function()
            local lightcolor = Light.Color
            task.wait(5)
            game.TweenService:Create(Light, TweenInfo.new(0.5), {Color = lightcolor}):Play()
        end)
    end

    local ambruhspeed = 40
    local DEF_SPEED = 99999
    local storer = ambruhspeed
    local ambushheight = Vector3.new(0, 3, 0)
    local redtweeninfo = TweenInfo.new(0.5)
    local redinfo = {Color = Color3.new(0.454902, 0.529412, 1)}

    camShake:Shake(cameraShaker.Presets.Earthquake)

    for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
        if v:IsA("Light") then
            pcall(MakeNormal, v)
            game.TweenService:Create(v, redtweeninfo, redinfo):Play()
            if v.Parent.Name == "LightFixture" then
                pcall(MakeNormal, v.Parent:FindFirstChild("Neon"))
                pcall(function()
                    game.TweenService:Create(v.Parent:FindFirstChild("Neon"), redtweeninfo, redinfo):Play()
                end)
            end
        end
    end

    local rawUrl = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/main/oldCease.rbxm"
    local entity = nil

    if G.LoadGithubModel then
        entity = G.LoadGithubModel(rawUrl)
        if entity then
            entity.Parent = workspace
        end
    end

    if not entity then return end

    local ambush = entity:FindFirstChildWhichIsA("BasePart")
    if not ambush then
        entity:Destroy()
        return
    end

    if ambush:FindFirstChild("Rush") then
        ambush.Rush.Volume = 10
        ambush.Rush.RollOffMinDistance = 2
        ambush.Rush.RollOffMaxDistance = 150
    end

    if ambush:FindFirstChild("Silence") then
        ambush.Silence:Play()
    end

    local function canSeeTarget(target, size)
        if killed == true then
            return false
        end
        local origin = ambush.Position
        local direction = (target.HumanoidRootPart.Position - ambush.Position).unit * size
        local ray = Ray.new(origin, direction)

        local hit, pos = workspace:FindPartOnRay(ray, ambush)

        if hit then
            if hit:IsDescendantOf(target) then
                killed = true
                return true
            end
        else
            return false
        end
    end

    spawn(function()
        task.wait(3)
        while entity ~= nil and entity.Parent ~= nil and ambush ~= nil do
            task.wait(0.2)
            local character = Plr.Character
            if character and character:FindFirstChildWhichIsA("Humanoid") then
                local hum = character:FindFirstChildWhichIsA("Humanoid")
                if hum.MoveDirection ~= Vector3.new(0, 0, 0) then
                    if character:GetAttribute("Hiding") or canSeeTarget(character, 50) then
                        if ambush:FindFirstChild("Rush") then
                            ambush.Rush:Stop()
                        end
                        
                        pcall(function()
                            ReSt.GameStats["Player_" .. Plr.Name].Total.DeathCause.Value = "Cease"
                            firesignal(ReSt.Bricks.DeathHint.OnClientEvent, {
                                "You died to who you call Cease...",
                                "Its tactic is appearing after rush...",
                                "It sees through movement and can see anyone in wardrobes."
                            })
                        end)
                        
                        hum:TakeDamage(100)
                    end
                end
            end

            if character and character:FindFirstChild("HumanoidRootPart") then
                if (ambush.Position - character.HumanoidRootPart.Position).magnitude < val then
                    camShake:ShakeOnce(6, 66, 0, 2, 1, 6)
                end
            end
        end
    end)

    if ambush:FindFirstChild("Rush") then
        ambush.Rush:Play()
        ambush.Rush.Pitch = 0.1
        game.TweenService:Create(ambush.Rush, TweenInfo.new(6), {Volume = 0.8}):Play()
    end

    local gruh = workspace.CurrentRooms
    ambruhspeed = DEF_SPEED

    for i = 1, ReSt.GameData.LatestRoom.Value do
        local room = gruh:FindFirstChild(tostring(i))
        if room then
            local nodes = room:FindFirstChild("Nodes")
            if nodes then
                for v = 1, #nodes:GetChildren() do
                    local waypoint = nodes:FindFirstChild(tostring(v))
                    if waypoint then
                        local Distance = (ambush.Position - waypoint.Position).magnitude
                        local fakejays = game.TweenService:Create(
                            ambush,
                            TweenInfo.new(GetTime(Distance, ambruhspeed), Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
                            {CFrame = waypoint.CFrame + ambushheight}
                        )
                        fakejays:Play()
                        fakejays.Completed:Wait()
                        ambruhspeed = storer

                        if room.Name == tostring(ReSt.GameData.LatestRoom.Value) then
                            pcall(function()
                                room:WaitForChild("Door").ClientOpen:FireServer()
                            end)
                        end
                    end
                end
            end
        end
    end

    pcall(function()
        workspace.CurrentRooms[tostring(ReSt.GameData.LatestRoom.Value)]:WaitForChild("Door").ClientOpen:FireServer()
    end)

    ambush.Anchored = false
    ambush.CanCollide = false
    task.wait(2)
    entity:Destroy()
end

spawn(Cease)
