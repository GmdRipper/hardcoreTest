-- XENO GITHUB MODEL LOADER (.rbxm / .rbxmx)

local G = getgenv()
local ReplicatedStorage = game.ReplicatedStorage

G.LoadGithubModel = function(url)
    if not (writefile and getcustomasset and request) then
        return nil
    end

    local function generateFileName(url)
        local hash = 0

        for i = 1, #url do
            hash = (hash * 31 + string.byte(url, i)) % 2^32
        end

        return "deer_god_" .. tostring(hash) .. ".rbxm"
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


-- ============================================
-- AUDIO LOADER
-- ============================================

G.LoadGithubAudio = function(url)
    if not (writefile and getcustomasset and request) then
        return nil
    end

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

    local fileName = "deergodchase_" .. tick() .. ".mp3"

    writefile(fileName, response.Body)

    local success, assetId = pcall(function()
        return getcustomasset(fileName)
    end)

    if success then
        return assetId
    end

    warn("Erro no getcustomasset: " .. tostring(assetId))
    return nil
end


-- ============================================
-- DEER GOD
-- ============================================

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


    -- ============================================
    -- LOAD ENTITY
    -- ============================================

    local deergodId = "rbxassetid://12262883448"

    local entity = game:GetObjects(deergodId)[1]

    if not entity then
        warn("DeerGod: failed to load entity")
        return
    end

    entity.Parent = workspace

    local entityPart =
        entity:FindFirstChildWhichIsA("BasePart")

    if not entityPart then
        warn("DeerGod: no BasePart found")
        entity:Destroy()
        return
    end


    -- ============================================
    -- LOAD MODULE_EVENTS
    -- ============================================

    local moduleEvents

    for _, obj in ipairs(
        ReplicatedStorage:GetDescendants()
    ) do

        if obj.Name == "Module_Events" then
            moduleEvents = obj
            break
        end

    end

    local moduleScripts = {}

    if moduleEvents then
        moduleScripts.Module_Events =
            require(moduleEvents)
    end


    -- ============================================
    -- CHASE MUSIC
    -- ============================================

    local chaseTheme =
        G.LoadGithubAudio(
            "https://raw.githubusercontent.com/Francisco1692qzd/Doors-Hotel-Hardcore/main/DeerGodChaseTheme.mp3"
        )


    local chaseMusic

    if chaseTheme then

        chaseMusic = Instance.new("Sound")
        chaseMusic.Parent = workspace
        chaseMusic.SoundId = chaseTheme
        chaseMusic.Volume = 3
        chaseMusic.Looped = true
        chaseMusic:Play()

    end


    -- ============================================
    -- CAMERA SHAKE
    -- ============================================

    local cameraShaker =
        require(
            game.ReplicatedStorage.CameraShaker
        )

    local camera =
        workspace.CurrentCamera

    local camShake =
        cameraShaker.new(
            Enum.RenderPriority.Camera.Value,
            function(cf)
                camera.CFrame =
                    camera.CFrame * cf
            end
        )

    camShake:Start()


    -- ============================================
    -- TARGET DETECTION
    -- ============================================

    local function canSeeTarget(
        target,
        size
    )

        if killed == true then
            return
        end


        local function isBossActive()

            local room =
                latestRoom.Value

            if room == 50
                or room == 100 then

                return true

            end


            for _, sound in pairs(
                ReplicatedStorage:GetDescendants()
            ) do

                if sound:IsA("Sound")
                    and sound.IsPlaying
                    and (
                        sound.Name:find("Music")
                        or sound.Name == "Shade"
                    ) then

                    return true

                end

            end

            return false

        end


        if isBossActive() then
            return
        end


        local origin =
            entityPart.Position


        local direction =
            (
                target.HumanoidRootPart.Position
                - origin
            ).Unit * size


        local ray =
            Ray.new(
                origin,
                direction
            )


        local hit, pos =
            workspace:FindPartOnRay(
                ray,
                entityPart
            )


        if hit then

            if hit:IsDescendantOf(
                target
            ) then

                killed = true

                return true

            end

        else

            return false

        end

    end


    -- ============================================
    -- MOVEMENT TIME
    -- ============================================

    local function GetTime(
        dist,
        speed
    )

        return dist / speed

    end


    task.wait(1)


    -- ============================================
    -- PLAYER DAMAGE
    -- ============================================

    task.spawn(function()

        while entity ~= nil
            and entityPart ~= nil do

            task.wait(0.01)

            local player =
                game.Players.LocalPlayer


            if player.Character ~= nil
                and player.Character:FindFirstChild(
                    "HumanoidRootPart"
                ) then

                local character =
                    player.Character


                if canSeeTarget(
                    character,
                    50
                )
                and not character:GetAttribute(
                    "Hiding"
                ) then

                    local humanoid =
                        character:FindFirstChildOfClass(
                            "Humanoid"
                        )


                    if humanoid then
                        humanoid:TakeDamage(100)
                    end


                    local stats =
                        ReplicatedStorage.GameStats
                        :FindFirstChild(
                            "Player_"
                            .. character.Name
                        )


                    if stats
                        and stats:FindFirstChild(
                            "Total"
                        )
                        and stats.Total:FindFirstChild(
                            "DeathCause"
                        ) then

                        stats.Total.DeathCause.Value =
                            "Deer God"

                    end


                    local hints = {
                        "You died to Dear god...",
                        "Hide wont work, so try running",
                        "Avoid eye contact!"
                    }


                    local remotesFolder =
                        ReplicatedStorage:FindFirstChild(
                            "RemotesFolder"
                        )


                    if not remotesFolder then

                        remotesFolder =
                            ReplicatedStorage:FindFirstChild(
                                "Bricks"
                            )

                    end


                    if remotesFolder
                        and remotesFolder:FindFirstChild(
                            "DeathHint"
                        ) then

                        firesignal(
                            remotesFolder.DeathHint.OnClientEvent,
                            hints,
                            "Blue"
                        )

                    end

                end

            end

        end

    end)


    -- ============================================
    -- EARTHQUAKE
    -- ============================================

    task.spawn(function()

        while entity ~= nil
            and entityPart ~= nil do

            task.wait(1.6)

            if entity.Parent ~= nil
                and entityPart.Parent ~= nil then

                camShake:Shake(
                    cameraShaker.Presets.Earthquake
                )

            end

        end

    end)


    -- ============================================
    -- MOVE THROUGH ROOMS
    -- AND BREAK LIGHTS
    -- ============================================

    ambruhspeed = DEF_SPEED


    for i = 1, latestRoom.Value + 1 do

        if currentRooms:FindFirstChild(
            tostring(i)
        ) then

            local room =
                currentRooms[
                    tostring(i)
                ]


            if room
                and room:FindFirstChild(
                    "Nodes"
                ) then


                -- ====================================
                -- BREAK LIGHTS IN THIS ROOM
                -- ====================================

                if moduleScripts.Module_Events
                    and moduleScripts.Module_Events.breakLights then

                    moduleScripts.Module_Events.breakLights(
                        room
                    )

                end


                -- ====================================
                -- MOVE THROUGH NODES
                -- ====================================

                local nodes =
                    room:FindFirstChild(
                        "Nodes"
                    )


                for v = 1, #nodes:GetChildren() do

                    local node =
                        nodes:FindFirstChild(
                            tostring(v)
                        )


                    if node then

                        local dist =
                            (
                                entityPart.Position
                                - node.Position
                            ).Magnitude


                        local jerk =
                            game.TweenService:Create(

                                entityPart,

                                TweenInfo.new(
                                    GetTime(
                                        dist,
                                        ambruhspeed
                                    ),

                                    Enum.EasingStyle.Linear,
                                    Enum.EasingDirection.Out,
                                    0,
                                    false,
                                    0
                                ),

                                {
                                    CFrame =
                                        node.CFrame
                                        + ambruhheight
                                }

                            )


                        jerk:Play()
                        jerk.Completed:Wait()

                        ambruhspeed =
                            storer

                    end

                end

            end

        end

    end


    -- ============================================
    -- REMOVE DEER GOD
    -- ============================================

    if entityPart
        and entityPart.Parent then

        local disappearTween =
            game.TweenService:Create(

                entityPart,

                TweenInfo.new(1.5),

                {
                    CFrame =
                        entityPart.CFrame
                        * CFrame.new(
                            0,
                            -80,
                            0
                        )
                }

            )

        disappearTween:Play()

    end


    game.Debris:AddItem(
        entity,
        1.5
    )


    task.wait(1.5)


    if chaseMusic then
        chaseMusic:Destroy()
    end


    task.wait(2)


    -- ============================================
    -- ACHIEVEMENT
    -- ============================================

    local player =
        game.Players.LocalPlayer

    local playerGui =
        player:FindFirstChild(
            "PlayerGui"
        )

    if not playerGui then
        return
    end


    local mainUI =
        playerGui:FindFirstChild(
            "MainUI"
        )

    if not mainUI then
        return
    end


    local initiator =
        mainUI:FindFirstChild(
            "Initiator"
        )

    if not initiator then
        return
    end


    local mainGame =
        initiator:FindFirstChild(
            "Main_Game"
        )

    if not mainGame then
        return
    end


    local remoteListener =
        mainGame:FindFirstChild(
            "RemoteListener"
        )

    if not remoteListener then
        return
    end


    local modules =
        remoteListener:FindFirstChild(
            "Modules"
        )

    if not modules then
        return
    end


    local AchievementModule =
        modules:FindFirstChild(
            "AchievementUnlock"
        )

    if not AchievementModule then
        return
    end


    if workspace:FindFirstChild(
        "DeerGodAchievement"
    ) then

        return

    end


    local modulesShared =
        ReplicatedStorage:FindFirstChild(
            "ModulesShared"
        )

    if not modulesShared then
        return
    end


    local achievements =
        modulesShared:FindFirstChild(
            "Achievements"
        )

    if not achievements then
        return
    end


    local unlockFunc =
        require(AchievementModule)


    if not workspace:FindFirstChild(
        "DeerGodAchievement"
    ) then

        unlockFunc(
            nil,
            "DeerGod"
        )

    end


    local ObtainedBadge =
        Instance.new("BoolValue")

    ObtainedBadge.Name =
        "DeerGodAchievement"

    ObtainedBadge.Value =
        true

    ObtainedBadge.Parent =
        workspace

end


-- ============================================
-- START DEER GOD
-- ============================================

local success, err =
    pcall(DeerGod)

if not success then
    warn(
        "DeerGod ERROR:",
        err
    )
end
