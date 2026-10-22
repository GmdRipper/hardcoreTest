-- Recreated Hotel / Mines Style + Guiding Candle
-- This is a recreation, not the original iCherryKardess script.
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

-- Prevent duplicate execution
if _G.HotelCandleRecreationRunning then
    warn("Hotel Candle Recreation is already running.")
    return
end
_G.HotelCandleRecreationRunning = true

-- 1. Lighting
Lighting.FogStart = 10
Lighting.FogEnd = 75
Lighting.Ambient = Color3.fromRGB(62, 64, 71)
Lighting.OutdoorAmbient = Color3.fromRGB(45, 47, 54)

-- 2. Hotel room appearance
local rooms = workspace:WaitForChild("CurrentRooms")

local function styleRoom(room)
    for _, part in ipairs(room:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = Enum.Material.Limestone
            part.Color = Color3.fromRGB(62, 64, 71)
        end
    end
end

for _, room in ipairs(rooms:GetChildren()) do
    styleRoom(room)
end

rooms.ChildAdded:Connect(function(room)
    task.wait(0.5)
    styleRoom(room)
end)

-- 3. Load the candle model
local success, candle = pcall(function()
    return game:GetObjects("rbxassetid://11630702537")[1]
end)

if not success or not candle then
    warn("Could not load candle model.")
    _G.HotelCandleRecreationRunning = nil
    return
end

local handle = candle:FindFirstChild("Handle")
if not handle then
    warn("Candle model has no Handle.")
    candle:Destroy()
    _G.HotelCandleRecreationRunning = nil
    return
end

-- Disable collisions
for _, part in ipairs(candle:GetDescendants()) do
    if part:IsA("BasePart") then
        part.CanCollide = false
    end
end

-- Original candle material and built-in light
pcall(function()
    handle.Material = Enum.Material.Salt
    handle.Top.Flame.GuidingLighteffect.EffectLight.LockedToPart = true
end)

candle.Parent = backpack

-- 4. Holding animation
local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    local animator = humanoid:FindFirstChildOfClass("Animator")

    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://9982615727"

    local loaded, track = pcall(function()
        return animator:LoadAnimation(animation)
    end)

    if not loaded or not track then
        warn("Could not load candle animation.")
        return
    end

    track.Looped = true

    candle.Equipped:Connect(function()
        if candle.Parent ~= character then
            return
        end
        track:Play()
    end)

    candle.Unequipped:Connect(function()
        track:Stop()
    end)

    humanoid.Died:Connect(function()
        track:Stop()
    end)
end

if player.Character then
    setupCharacter(player.Character)
end

player.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    setupCharacter(character)
end)

print("Hotel / Mines style and candle loaded.")
