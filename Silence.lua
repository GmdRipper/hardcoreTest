-- XENO GITHUB MODEL LOADER (.rbxm / .rbxmx)
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

-- SILENCE ACHIEVEMENT
local SilenceAchievement = {
    Title = "Careful Listener",
    Desc = "Shhh.. do you hear that?",
    Reason = "Survive Silence",
    Image = "https://raw.githubusercontent.com/GmdRipper/hardcoreTest/main/SilenceAchievement.png",
    id = 600,
}

local AchievementFolder = "SilenceAchievementSaves"

if not isfolder(AchievementFolder) then
    makefolder(AchievementFolder)
end

local AchievementFile = AchievementFolder .. "/Save.txt"

if not isfile(AchievementFile) then
    writefile(AchievementFile, "")
end

local Achievements = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MuhXd/Models/main/RegularVynixu's%20Achievement%20Modifyer"
))()

local function AchievementsGet(Achievement)
    local saved = string.split(readfile(AchievementFile), "|")
    local id = " " .. tostring(Achievement.id)

    if table.find(saved, id) then
        warn("SILENCE: achievement already saved")
        return
    end

    warn("SILENCE: calling Achievements.Get")

    local result = Achievements.Get(Achievement)

    warn("SILENCE: Achievements.Get returned", result)

    appendfile(AchievementFile, id .. "|")
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

    local latestRoomInt = game.ReplicatedStorage.GameData.LatestRoom
    local latestRoomModel = currentRooms:FindFirstChild(latestRoomInt.Value)

    -- local rawUrl = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/main/oldSilence.rbxm"
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
            return
        end

        local origin = entityPart.Position
        local direction = (target.HumanoidRootPart.Position - origin).Unit * size
        local ray = Ray.new(origin, direction)

        local hit, pos = workspace:FindPartOnRay(ray, entity)

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
        while entity ~= nil and entityPart ~= nil and entity.Parent do
            task.wait(0.7)

            local v = game.Players.LocalPlayer

            if v.Character ~= nil
                and v.Character:FindFirstChild("HumanoidRootPart")
                and v.Character:FindFirstChild("Humanoid") then

                if canSeeTarget(v.Character, 50)
                    and not v.Character:GetAttribute("Hiding") then

                    v.Character.Humanoid:TakeDamage(100)

                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local playerStats = ReplicatedStorage.GameStats:FindFirstChild("Player_" .. v.Character.Name)

                    if playerStats and playerStats:FindFirstChild("Total")
                        and playerStats.Total:FindFirstChild("DeathCause") then
                        playerStats.Total.DeathCause.Value = "Silence"
                    end

                    local hints = {
                        "You died to who you call Silence",
                        "Stay as silent as possible when you suspect its coming, so you know when to hide!",
                        "Its slow, but hard to hear",
                        "so hide!"
                    }

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
                end
            end
        end
    end)

    ambruhspeed = DEF_SPEED

    for i = 1, latestRoom.Value + 2 do
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

    local despawnTween = game.TweenService:Create(
        entityPart,
        TweenInfo.new(1.5),
        {
            CFrame = entityPart.CFrame * CFrame.new(0, -80, 0)
        }
    )

    despawnTween:Play()
    game.Debris:AddItem(entity, 1.5)

    -- Show the custom achievement after Silence finishes
    warn("SILENCE: reached achievement section")
    
    task.wait(1.5)
    
    warn("SILENCE: calling AchievementsGet")
    
    local success, err = pcall(function()
        AchievementsGet(SilenceAchievement)
    end)
    
    warn("SILENCE: AchievementsGet success =", success)
    
    if not success then
        warn("SILENCE achievement error: " .. tostring(err))
    end
end

local ok, err = pcall(Silence)

if not ok then
    warn("SILENCE SCRIPT ERROR: " .. tostring(err))
else
    warn("SILENCE SCRIPT FINISHED")
end
