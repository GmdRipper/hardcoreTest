--=============================================================================
-- AUTONOMOUS DOORS ENTITY SPAWNER V1 - REPAIRED & UPDATED (2026 EDITION)
--=============================================================================

local Players = game:GetService("Players")
local ReSt = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local CG = game:GetService("CoreGui")

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

local StaticRushSpeed = 60

local FindPartOnRayWithIgnoreList = workspace.FindPartOnRayWithIgnoreList
local WorldToViewportPoint = Camera.WorldToViewportPoint

local BuiltInDefaultConfig = {
    CustomName = "Entity",
    Model = "rbxassetid://0",
    Speed = 100,
    DelayTime = 0,
    HeightOffset = 0,
    CanKill = true,
    KillRange = 4,
    BackwardsMovement = false,
    BreakLights = true,
    FlickerLights = {true, 1},
    Cycles = {Min = 1, Max = 1, WaitTime = 0},
    CamShake = {true, {3.5, 20, 0.1, 1}, 100},
    Jumpscare = {false, {
        Image1 = "rbxassetid://0",
        Image2 = "rbxassetid://0",
        Shake = false,
        Sound1 = {0, {Volume = 0.5}},
        Sound2 = {0, {Volume = 0.5}},
        Flashing = {false, Color3.new(1, 1, 1)},
        Tease = {false, Min = 1, Max = 1}
    }},
    CustomDialog = {}
}

local SelfModules = {
    DefaultConfig = BuiltInDefaultConfig,
    Functions = loadstring(game:HttpGet("https://githubusercontent.com"))(),
}

local ModuleScripts = {
    ModuleEvents = {
        flicker = function(...) print("[Effects]: Flicker triggered") end,
        shatter = function(...) print("[Effects]: Shatter triggered") end,
    }
}

local EntityConnections = {}
local Spawner = {}

function onCharacterAdded(char)
    Char, Hum = char, char:WaitForChild("Humanoid")
end

function getPlayerRoot()
    return Char:FindFirstChild("HumanoidRootPart") or Char:FindFirstChild("Head")
end

function dragEntity(entityModel, pos, speed)
    local entityConnections = EntityConnections[entityModel]

    if entityConnections.movementNode then
        entityConnections.movementNode:Disconnect()
    end

    entityConnections.movementNode = RS.Stepped:Connect(function(_, step)
        if entityModel.Parent and not entityModel:GetAttribute("NoAI") then
            local rootPos = entityModel.PrimaryPart.Position
            local diff = Vector3.new(pos.X, pos.Y, pos.Z) - rootPos

            if diff.Magnitude > 0.1 then
                entityModel:PivotTo(CFrame.new(rootPos + diff.Unit * math.min(step * speed, diff.Magnitude)))
            else
                entityConnections.movementNode:Disconnect()
            end
        end
    end)

    repeat task.wait() until not entityConnections.movementNode.Connected
end

function loadSound(soundData)
    local sound = Instance.new("Sound")
    local soundId = tostring(soundData)
    local properties = soundData

    for i, v in next, properties do
        if i ~= "SoundId" and i ~= "Parent" then
            sound[i] = v
        end
    end

    if soundId:find("rbxasset://") then
        sound.SoundId = soundId
    else
        local numberId = soundId:gsub("%D", "")
        sound.SoundId = "rbxassetid://".. numberId
    end
    
    sound.Parent = workspace
    return sound
end

Spawner.createEntity = function(config)
    for i, v in next, SelfModules.DefaultConfig do
        if config[i] == nil then
            config[i] = v
        end
    end

    config.Speed = StaticRushSpeed / 100 * config.Speed

    local entityModel = LoadCustomInstance(config.Model)

    if typeof(entityModel) == "Instance" and entityModel.ClassName == "Model" then
        entityModel.PrimaryPart = entityModel.PrimaryPart or entityModel:FindFirstChildWhichIsA("BasePart")
        
        if entityModel.PrimaryPart then
            entityModel.PrimaryPart.Anchored = true
            
            if config.CustomName then
                entityModel.Name = config.CustomName
            end

            entityModel:SetAttribute("IsCustomEntity", true)
            entityModel:SetAttribute("NoAI", false)

            local entityTable = {
                Model = entityModel,
                Config = config,
                Debug = {
                    OnEntitySpawned = function() end,
                    OnEntityDespawned = function() end,
                    OnEntityStartMoving = function() end,
                    OnEntityFinishedRebound = function() end,
                    OnEntityEnteredRoom = function() end,
                    OnLookAtEntity = function() end,
                    OnDeath = function() end
                }
            }

            return entityTable
        end
    end
end

Spawner.runEntity = function(entityTable)
    local nodes = {}
    local RoomsFolder = workspace:FindFirstChild("Rooms") or workspace:FindFirstChild("CurrentRooms")
    
    if RoomsFolder then
        local latestRoomVal = 0
        pcall(function() latestRoomVal = ReSt.GameData.LatestRoom.Value end)
        
        for i = 1, latestRoomVal + 1 do
            local room = RoomsFolder:FindFirstChild(tstring(i))
            if room then
                local pathfindNodes = room:FindFirstChild("PathfindNodes") or room:FindFirstChild("Nodes") or room:FindFirstChild("Parts")
                
                if pathfindNodes and #pathfindNodes:GetChildren() > 0 then
                    local children = pathfindNodes:GetChildren()
                    table.sort(children, function(a, b)
                        local numA = tonumber(a.Name:match("%d+")) or 0
                        local numB = tonumber(b.Name:match("%d+")) or 0
                        return numA < numB
                    end)
                    for _, node in next, children do
                        if node:IsA("BasePart") then
                            nodes[#nodes + 1] = node
                        end
                    end
                else
                    local basePart = room:FindFirstChild("Base") or room:FindFirstChildWhichIsA("BasePart")
                    if basePart then
                        nodes[#nodes + 1] = basePart
                    end
                end
            end
        end
    end

    if #nodes == 0 then print("[Spawner]: Error, movement nodes not found!") return end

    local entityModel = entityTable.Model:Clone()
    local startNodeIndex = entityTable.Config.BackwardsMovement and #nodes or 1
    local startNodeOffset = entityTable.Config.BackwardsMovement and -50 or 50

    EntityConnections[entityModel] = {}
    local entityConnections = EntityConnections[entityModel]
    
    entityModel:PivotTo(nodes[startNodeIndex].CFrame * CFrame.new(0, 0, startNodeOffset) + Vector3.new(0, 3.5 + entityTable.Config.HeightOffset, 0))
    entityModel.Parent = workspace
    task.spawn(entityTable.Debug.OnEntitySpawned)

    if entityTable.Config.FlickerLights then
        ModuleScripts.ModuleEvents.flicker()
    end

    task.wait(entityTable.Config.DelayTime)
    local enteredRooms = {}

    entityConnections.movementTick = RS.Stepped:Connect(function()
        if entityModel.Parent and not entityModel:GetAttribute("NoAI") then
            local entityPos = entityModel.PrimaryPart.Position
            local rootPos = getPlayerRoot().Position
            local floorRay = FindPartOnRayWithIgnoreList(workspace, Ray.new(entityPos, Vector3.new(0, -10, 0)), {entityModel, Char})
            local playerInSight = FindPartOnRayWithIgnoreList(workspace, Ray.new(entityPos, rootPos - entityPos), {entityModel, Char}) == nil
            
            if floorRay ~= nil and floorRay.Name == "Floor" and RoomsFolder then
                for _, room in next, RoomsFolder:GetChildren() do
                    if floorRay:IsDescendantOf(room) and not table.find(enteredRooms, room) then
                        enteredRooms[#enteredRooms + 1] = room
                        task.spawn(entityTable.Debug.OnEntityEnteredRoom, room)
                        if entityTable.Config.BreakLights then
                            ModuleScripts.ModuleEvents.shatter(room)
                        end
                        break
                    end
                end
            end

            local shakeConfig = entityTable.Config.CamShake
            local shakeMag = (getPlayerRoot().Position - entityModel.PrimaryPart.Position).Magnitude
            if shakeConfig and shakeMag <= 100 then
                pcall(function()
                    ReSt.RemotesFolder.CamShakeClient:FireServer()
                end)
            end

            if playerInSight then
                local _, onScreen = WorldToViewportPoint(Camera, entityModel.PrimaryPart.Position)
                if onScreen then
                    task.spawn(entityTable.Debug.OnLookAtEntity)
                end

                if entityTable.Config.CanKill and not Char:GetAttribute("IsDead") and not Char:GetAttribute("Invincible") and not Char:GetAttribute("Hiding") and (getPlayerRoot().Position - entityModel.PrimaryPart.Position).Magnitude <= entityTable.Config.KillRange then
                    task.spawn(function()
                        Char:SetAttribute("IsDead", true)
                        for _, v in next, entityModel:GetDescendants() do
                            if v.ClassName == "Sound" and v.Playing then
                                v:Stop()
                            end
                        end
                        if entityTable.Config.Jumpscare then
                            Spawner.runJumpscare(entityTable.Config.Jumpscare)
                        end
                        task.spawn(entityTable.Debug.OnDeath)
                        Hum.Health = 0
                        
                        pcall(function()
                        ReSt.RemotesFolder.PlayerDied:FireServer()
                    end)
                    if #entityTable.Config.CustomDialog > 0 then
                        pcall(function()
                            ReSt.RemotesFolder.DeathHint:FireServer(entityTable.Config.CustomDialog)
                        end)
                    end
                end)
            end
        end
    end)

    task.spawn(entityTable.Debug.OnEntityStartMoving)
    local cyclesConfig = entityTable.Config.Cycles
    if entityTable.Config.BackwardsMovement then
        local inverseNodes = {}
        for nodeIdx = #nodes, 1, -1 do
            inverseNodes[#inverseNodes + 1] = nodes[nodeIdx]
        end
        nodes = inverseNodes
    end

    for cycle = 1, math.max(math.random(cyclesConfig.Min, cyclesConfig.Max), 1) do
        for nodeIdx = 1, #nodes, 1 do
            dragEntity(entityModel, nodes[nodeIdx].Position + Vector3.new(0, 3.5 + entityTable.Config.HeightOffset, 0), entityTable.Config.Speed)
        end
        if cyclesConfig.Max > 1 then
            for nodeIdx = #nodes, 1, -1 do
                dragEntity(entityModel, nodes[nodeIdx].Position + Vector3.new(0, 3.5 + entityTable.Config.HeightOffset, 0), entityTable.Config.Speed)
            end
        end
        task.spawn(entityTable.Debug.OnEntityFinishedRebound)
        if cycle < cyclesConfig.Max then
            task.wait(cyclesConfig.WaitTime)
        end
    end

    if not entityModel:GetAttribute("NoAI") then
        for _, v in next, entityConnections do
            v:Disconnect()
        end
        entityModel:Destroy()
        task.spawn(entityTable.Debug.OnEntityDespawned)
    end
end

Spawner.runJumpscare = function(config)
    local image1 = LoadCustomAsset(config.Image1)
    local image2 = LoadCustomAsset(config.Image2)
    local sound1, sound2 = nil, nil
    if config.Sound1 then sound1 = loadSound(config.Sound1) end
    if config.Sound2 then sound2 = loadSound(config.Sound2) end

    local JumpscareGui = Instance.new("ScreenGui")
    local Background = Instance.new("Frame")
    local Face = Instance.new("ImageLabel")

    JumpscareGui.Name = "JumpscareGui"
    JumpscareGui.IgnoreGuiInset = true
    JumpscareGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    Background.Name = "Background"
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.BorderSizePixel = 0
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.ZIndex = 999

    Face.Name = "Face"
    Face.AnchorPoint = Vector2.new(0.5, 0.5)
    Face.BackgroundTransparency = 1
    Face.Position = UDim2.new(0.5, 0, 0.5, 0)
    Face.ResampleMode = Enum.ResamplerMode.Pixelated
    Face.Size = UDim2.new(0, 150, 0, 150)
    Face.Image = image1

    Face.Parent = Background
    Background.Parent = JumpscareGui
    JumpscareGui.Parent = CG

    if sound2 then sound2:Play() end
    task.wait(1.5)
    JumpscareGui:Destroy()
end

Plr.CharacterAdded:Connect(onCharacterAdded)
return Spawner
