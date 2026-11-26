local G = getgenv()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [1] MODEL LOADER
G.LoadGithubModel = function(url)
    if not (writefile and getcustomasset and request) then
        return nil
    end

    local rawUrl = url
        :gsub("github.com", "raw.githubusercontent.com")
        :gsub("/blob/", "/")

    local function generateFileName(u)
        local hash = 0

        for i = 1, #u do
            hash = (hash * 31 + string.byte(u, i)) % 2^32
        end

        return "shocker_final_fix_" .. tostring(hash) .. ".rbxm"
    end

    local fileName = generateFileName(rawUrl)

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
        Url = rawUrl,
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

-- [2] SHOCKER ACHIEVEMENT
local ShockerAchievement = {
    Title = "Shocking Experience",
    Desc = "Look at me.",
    Reason = "Encounter Shocker",
    Image = "rbxassetid://94570710506307",
}

local SHOCKER_ACHIEVEMENT_FLAG = "ShockerAchievement"

local function GiveShockerAchievement()
    if workspace:FindFirstChild(SHOCKER_ACHIEVEMENT_FLAG) then
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
    obtainedBadge.Name = SHOCKER_ACHIEVEMENT_FLAG
    obtainedBadge.Value = true
    obtainedBadge.Parent = workspace

    task.spawn(function()
        local frame = template:Clone()
        frame.Name = "LiveAchievement"
        frame.Frame.Details.Title.Text = ShockerAchievement.Title
        frame.Frame.Details.Desc.Text = ShockerAchievement.Desc
        frame.Frame.Details.Reason.Text = ShockerAchievement.Reason
        frame.Frame.ImageLabel.Image = ShockerAchievement.Image
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

local function ForceShockerDeathHint(char)
    local hints = {
        "You died to who you call Shocker...",
        "Don't look at it or it stuns you!"
    }

    pcall(function()
        local statsFolder = ReplicatedStorage:FindFirstChild("GameStats")
        if statsFolder then
            local playerStat = statsFolder:FindFirstChild("Player_" .. char.Name)
            if playerStat and playerStat:FindFirstChild("Total") then
                local total = playerStat.Total
                if total:FindFirstChild("DeathCause") then
                    total.DeathCause.Value = "Shocker"
                end
            end
        end
    end)

    pcall(function()
        if ReplicatedStorage:FindFirstChild("RemotesFolder") then
            local remotesFolder = ReplicatedStorage:FindFirstChild("RemotesFolder")
            if remotesFolder:FindFirstChild("DeathHint") then
                firesignal(
                    remotesFolder.DeathHint.OnClientEvent,
                    hints,
                    "Blue"
                )
            end
        elseif ReplicatedStorage:FindFirstChild("Bricks") then
            local remotesFolder = ReplicatedStorage:FindFirstChild("Bricks")
            if remotesFolder:FindFirstChild("DeathHint") then
                firesignal(
                    remotesFolder.DeathHint.OnClientEvent,
                    hints
                )
            end
        end
    end)
end

-- [3] ENTITY: SHOCKER
local function SpawnShocker()
    local LP = game.Players.LocalPlayer
    local Char = LP.Character or LP.CharacterAdded:Wait()
    local Hum = Char:WaitForChild("Humanoid")
    local Root = Char:WaitForChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    local tweenService = game:GetService("TweenService")

    local cameraShaker = require(ReplicatedStorage.CameraShaker)

    local camShake = cameraShaker.new(
        Enum.RenderPriority.Camera.Value,
        function(cf)
            cam.CFrame = cam.CFrame * cf
        end
    )

    camShake:Start()

    local modelUrl = "https://github.com/Francisco1692qzd/RevivedOldHardcore/blob/main/oldShocker.rbxm"
    local entity = G.LoadGithubModel(modelUrl)

    if not entity then
        return
    end

    local mainPart = entity:FindFirstChild("OOGA BOOGAAAA")

    if not mainPart then
        entity:Destroy()
        return
    end

    entity.PrimaryPart = mainPart
    mainPart.Anchored = true
    mainPart.CanCollide = true

    entity:PivotTo(Root.CFrame * CFrame.new(0, 0, -12))
    entity.Parent = workspace

    local spawnSound = entity:FindFirstChild("PlaySound")
    local attackSound = mainPart:FindFirstChild("HORROR SCREAM 15")

    if spawnSound then
        spawnSound:Play()
    end

    local lookingTime = 0
    local hasAttacked = false

    local function isPlayerLooking()
        local entityPos = mainPart.Position
        local _, onScreen = cam:WorldToViewportPoint(entityPos)

        if not onScreen then
            return false
        end

        local cameraToEntity = (entityPos - cam.CFrame.Position).Unit
        local dotProduct = cameraToEntity:Dot(cam.CFrame.LookVector)

        return dotProduct > 0.7
    end

    for _, v in pairs(entity:GetChildren()) do
        if v:IsA("Sound") and v.Name == "PlaySound" then
            if v.PlayOnRemove == true then
                v.PlayOnRemove = false
            end
        end
    end

    local function dropDownAndDestroy(dropY)
        mainPart.Anchored = true
        mainPart.CanCollide = false

        tweenService:Create(
            mainPart,
            TweenInfo.new(0.4, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
            {
                CFrame = mainPart.CFrame + Vector3.new(0, dropY, 0)
            }
        ):Play()

        if spawnSound and spawnSound:IsA("Sound") then
            tweenService:Create(
                spawnSound,
                TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
                {
                    Volume = 0
                }
            ):Play()
        end

        task.wait(1)

        if entity then
            entity:Destroy()
        end
    end

    task.wait(0.1)

    if not isPlayerLooking() then
        GiveShockerAchievement()
        dropDownAndDestroy(-20)
        return
    end

    task.spawn(function()
        local lastLookState = isPlayerLooking()
        local timeSinceLastLook = 0

        while entity and entity.Parent and not hasAttacked do
            task.wait(0.05)

            local currentLookState = isPlayerLooking()

            if currentLookState then
                if not lastLookState then
                    lookingTime = 0
                end

                lookingTime = lookingTime + 0.05
                timeSinceLastLook = 0
            else
                timeSinceLastLook = timeSinceLastLook + 0.05

                if lookingTime > 0.00001
                    and lookingTime < 1.9
                    and timeSinceLastLook > 0.00001 then

                    GiveShockerAchievement()
                    dropDownAndDestroy(-20)
                    break
                end

                if timeSinceLastLook > 0.5 then
                    lookingTime = 0
                end
            end

            lastLookState = currentLookState

            -- ATTACK LOGIC
            if lookingTime >= 1.9 and not hasAttacked then
                hasAttacked = true

                pcall(function()
                    local statsFolder = ReplicatedStorage:FindFirstChild("GameStats")
                    if statsFolder then
                        local playerStat = statsFolder:FindFirstChild("Player_" .. Char.Name)
                        if playerStat and playerStat:FindFirstChild("Total") then
                            local total = playerStat.Total
                            if total:FindFirstChild("DeathCause") then
                                total.DeathCause.Value = "Shocker"
                            end
                        end
                    end
                end)

                if attackSound then
                    attackSound:Play()
                end

                mainPart.Anchored = true
                mainPart.CanCollide = true

                local attackTween = tweenService:Create(
                    mainPart,
                    TweenInfo.new(
                        0.5,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.In
                    ),
                    {
                        CFrame = Root.CFrame
                    }
                )

                attackTween:Play()

                task.delay(0.37, function()
                    if Hum and Hum.Health > 0 then
                        local diedFromShocker = (Hum.Health - 30) <= 0
                        Hum:TakeDamage(30)
                        camShake:Shake(cameraShaker.Presets.Explosion)

                        if diedFromShocker or Hum.Health <= 0 then
                            ForceShockerDeathHint(Char)
                            task.delay(0.05, function()
                                ForceShockerDeathHint(Char)
                            end)
                            task.delay(0.25, function()
                                ForceShockerDeathHint(Char)
                            end)
                        end
                    end
                end)

                attackTween.Completed:Wait()
                dropDownAndDestroy(-10)
                break
            end
        end
    end)
end

task.spawn(SpawnShocker)
