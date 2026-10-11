
local G = getgenv()

G.LoadGithubModel = function(url)
    if not (writefile and getcustomasset and request) then
        return nil
    end

    local function generateFileName(url)
        local hash = 0
        for i = 1, #url do
            hash = (hash * 31 + string.byte(url, i)) % 2^32
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

local function Silence()
    local currentRooms = workspace:FindFirstChild("CurrentRooms")
    local latestRoomInt = game.ReplicatedStorage.GameData.LatestRoom
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

    if not currentRooms then
        return
    end

    local moduleEvents

    for _, obj in ipairs(game.ReplicatedStorage:GetDescendants()) do
        if obj.Name == "Module_Events" then
            moduleEvents = obj
            break
        end
    end

    local moduleScripts = {}

    if moduleEvents then
        local success, result = pcall(require, moduleEvents)

        if success then
            moduleScripts.Module_Events = result
        end
    end

    local latestRoomModel = currentRooms:FindFirstChild(tostring(latestRoomInt.Value))

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
        if killed then
            return
        end

        local origin = entityPart.Position
        local direction = (target.HumanoidRootPart.Position - origin).Unit * size
        local ray = Ray.new(origin, direction)
        local hit = workspace:FindPartOnRay(ray, entity)

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

    task.spawn(function()
        while entity and entityPart and entity.Parent do
            task.wait(0.7)

            local v = game.Players.LocalPlayer
            local character = v.Character

            if character and character:FindFirstChild("HumanoidRootPart")
                and character:FindFirstChild("Humanoid") then

                if canSeeTarget(character, 50)
                    and not character:GetAttribute("Hiding") then

                    character.Humanoid:TakeDamage(100)

                    local stats = game.ReplicatedStorage.GameStats:FindFirstChild("Player_" .. character.Name)

                    if stats and stats:FindFirstChild("Total")
                        and stats.Total:FindFirstChild("DeathCause") then
                        stats.Total.DeathCause.Value = "Silence"
                    end

                    local hints = {
                        "You died to who you call Silence...",
                        "Its heard when you're quiet!",
                        "It's definitely not recommended to run... but run if you can!",
                        "Hiding in a far away spot should be safer."
                    }

                    local replicatedStorage = game:GetService("ReplicatedStorage")
                    local remotesFolder = replicatedStorage:FindFirstChild("RemotesFolder")
                        or replicatedStorage:FindFirstChild("Bricks")

                    if remotesFolder and remotesFolder:FindFirstChild("DeathHint") then
                        firesignal(remotesFolder.DeathHint.OnClientEvent, hints, "Blue")
                    end
                end
            end
        end
    end)

    ambruhspeed = DEF_SPEED

    for i = 1, latestRoomInt.Value do
        local room = currentRooms:FindFirstChild(tostring(i))

        if room and room:FindFirstChild("Nodes") then
            local nodes = room:FindFirstChild("Nodes")


            if moduleScripts.Module_Events
                and moduleScripts.Module_Events.shatter then
                pcall(function()
                    moduleScripts.Module_Events.shatter(room)
                end)
            end

            if moduleScripts.Module_Events
                and moduleScripts.Module_Events.breakLights then
                pcall(function()
                    moduleScripts.Module_Events.breakLights(room)
                end)
            end

            for v = 1, #nodes:GetChildren() do
                local node = nodes:FindFirstChild(tostring(v))

                if node and node:IsA("BasePart") then
                    local dist = (entityPart.Position - node.Position).Magnitude

                    local tween = game.TweenService:Create(
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

                    tween:Play()
                    tween.Completed:Wait()
                    ambruhspeed = storer
                end
            end
        end
    end

    game.TweenService:Create(
        entityPart,
        TweenInfo.new(1.5),
        {
            CFrame = entityPart.CFrame * CFrame.new(0, -80, 0)
        }
    ):Play()

    game.Debris:AddItem(entity, 1.5)

    local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    local mainUI = playerGui and playerGui:FindFirstChild("MainUI")
    local initiator = mainUI and mainUI:FindFirstChild("Initiator")
    local mainGame = initiator and initiator:FindFirstChild("Main_Game")
    local remoteListener = mainGame and mainGame:FindFirstChild("RemoteListener")
    local modules = remoteListener and remoteListener:FindFirstChild("Modules")
    local achievementModule = modules and modules:FindFirstChild("AchievementUnlock")

    if not achievementModule then
        return
    end

    if workspace:FindFirstChild("SilenceAchievement") then
        return
    end

    local replicatedStorage = game:GetService("ReplicatedStorage")
    local modulesShared = replicatedStorage:FindFirstChild("ModulesShared")

    if not modulesShared then
        return
    end

    local achievements = modulesShared:FindFirstChild("Achievements")

    if not achievements then
        return
    end

    local success, unlockFunc = pcall(require, achievementModule)

    if not success or type(unlockFunc) ~= "function" then
        return
    end

    local successAchievements = pcall(require, achievements)

    if successAchievements then
        pcall(function()
            unlockFunc(nil, "Silence")
        end)

        local obtainedBadge = Instance.new("BoolValue")
        obtainedBadge.Name = "SilenceAchievement"
        obtainedBadge.Value = true
        obtainedBadge.Parent = workspace
    end
end

pcall(Silence)
