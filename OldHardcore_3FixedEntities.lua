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

    if name == "DeerGod" and (workspace:FindFirstChild("deer_god_oldDeerGod.rbxm") or workspace:FindFirstChild("OldDeerGod") or workspace:FindFirstChild("DeerGod")) then
        return
    end
    if name == "A60" and (workspace:FindFirstChild("A-60") or workspace:FindFirstChild("oldA60")) then
        return
    end
    if name == "Silence" and workspace:FindFirstChild("Silence") then
        return
    end

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

local function IsEventActive()
    return (workspace:FindFirstChild("SeekMoving") 
        or workspace:FindFirstChild("Ambience_Seek") and workspace.Ambience_Seek.Playing 
        or workspace:FindFirstChild("Ambience_Figure") and workspace.Ambience_Figure.Playing 
        or workspace:FindFirstChild("Ambience_FigureIntense") and workspace.Ambience_FigureIntense.Playing 
        or workspace:FindFirstChild("Ambience_FigureEnd") and workspace.Ambience_FigureEnd.Playing 
        or LatestRoom.Value == 50 
        or LatestRoom.Value == 100)
end

-- A-60
task.spawn(function()
    while true do
        SyncWait(680)
        
        if not IsEventActive() then
            LoadEntity("A60")
        end

        task.wait(5)
    end
end)

-- Silence
task.spawn(function()
    while true do
        SyncWait(560)

        if not IsEventActive() then
            LoadEntity("Silence")
        end

        task.wait(5)
    end
end)

-- Deer God
task.spawn(function()
    while true do
        SyncWait(30)

        if not IsEventActive() then
            LoadEntity("DeerGod")
        end

        task.wait(5)
    end
end)
