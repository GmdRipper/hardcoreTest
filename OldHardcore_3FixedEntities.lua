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
    Silence = "https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/refs/heads/main/oldSilence.lua",
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
    if workspace:FindFirstChild("SeekMoving") then
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
        SyncWait(c + 850)
        LoadEntity("Silence")

        SyncWait(c + 1530)
        LoadEntity("Silence")

        c = c + 600
        task.wait(1)
    end
end)

-- DeerGod
task.spawn(function()
    task.wait(40)

    if LatestRoom.Value ~= 50
        and not workspace:FindFirstChild("SeekMoving") then
        LoadEntity("DeerGod")
    else
        warn("[ThreeEntityAddon] DeerGod test skipped: room 50 or Seek active")
    end
end)
