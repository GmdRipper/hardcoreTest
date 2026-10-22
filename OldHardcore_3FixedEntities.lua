repeat task.wait() until game:IsLoaded()

local LatestRoom = game.ReplicatedStorage.GameData.LatestRoom

if workspace:FindFirstChild("ThreeEntityAddonRunning") then
    return
end

local runMarker = Instance.new("BoolValue")
runMarker.Name = "ThreeEntityAddonRunning"
runMarker.Value = true
runMarker.Parent = workspace

local entityURLs = {
    A60 = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/refs/heads/main/oldA60.lua",
    Silence = "https://raw.githubusercontent.com/GmdRipper/hardcoreTest/refs/heads/main/OldSilence.lua",
    DeerGod = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/refs/heads/main/oldDeerGod.lua"
}

if LatestRoom.Value == 0 then
    repeat
        LatestRoom.Changed:Wait()
    until LatestRoom.Value == 1
end

local startTime = workspace:GetServerTimeNow()

local function SyncWait(seconds)
    local targetTime = startTime + seconds

    while workspace:GetServerTimeNow() < targetTime do
        task.wait(0.5)
    end
end

local function LoadEntity(name)
    if workspace:FindFirstChild("SeekMoving")
        and name ~= "DeerGod" then
        return
    end

    if LatestRoom.Value == 50 and name ~= "A60" then
        return
    end

    if LatestRoom.Value == 100 then
        return
    end

    local url = entityURLs[name]
    if not url then
        return
    end

    task.spawn(function()
        local success, err = pcall(function()
            loadstring(game:HttpGet(url))()
        end)

        if not success then
            warn("[ThreeEntityAddon] " .. name .. ": " .. tostring(err))
        end
    end)
end

-- A60
task.spawn(function()
    local c = 0
    local canSpawnA60 = false
    local waitA60 = 32

    while true do
        if not canSpawnA60 then
            canSpawnA60 = true

            SyncWait(c + 730)
            LoadEntity("A60")

            SyncWait(c + 1200)
            LoadEntity("A60")

            c = c + 910

            task.delay(waitA60, function()
                canSpawnA60 = false
            end)
        end

        task.wait(1)
    end
end)

-- Silence
task.spawn(function()
    local c = 0

    while true do
        SyncWait(c + 40)
        LoadEntity("Silence")

        SyncWait(c + 800)
        LoadEntity("Silence")

        c = c + 1200
        task.wait(1)
    end
end)

-- DeerGod
task.spawn(function()
    local c = 0
    local first = true

    while true do
        if first then
            SyncWait(c + 400)
            first = false
            c = c + 750
        else
            SyncWait(c + 1000)
            c = c + 1000
        end

        if LatestRoom.Value ~= 50 then
            LoadEntity("DeerGod")
        end

        task.wait(1)
    end
end)
