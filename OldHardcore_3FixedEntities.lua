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
    Silence = "https://raw.githubusercontent.com/GmdRipper/hardcoreTest/refs/heads/main/Silence.lua",
    DeerGod = "https://raw.githubusercontent.com/GmdRipper/hardcoreTest/refs/heads/main/OldDeerGod.lua"
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

-- A-60
task.spawn(function()
    local nextTime = 0

    while true do
        nextTime = nextTime + 680
        SyncWait(nextTime)
        LoadEntity("A60")

        task.wait(1)
    end
end)

-- Silence
task.spawn(function()
    local nextTime = 0

    while true do
        nextTime = nextTime + 560
        SyncWait(nextTime)
        LoadEntity("Silence")

        task.wait(1)
    end
end)

-- Deer God
task.spawn(function()
    local nextTime = 0

    while true do
        nextTime = nextTime + 30
        SyncWait(nextTime)

        if LatestRoom.Value ~= 50 then
            LoadEntity("DeerGod")
        end

        task.wait(1)
    end
end)
