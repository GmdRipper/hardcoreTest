-- Simplified Hotel / Mines style + Candle
-- Recreated from the available fragments
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

-- 1. Lighting
Lighting.FogStart = 10
Lighting.FogEnd = 75
Lighting.Ambient = Color3.fromRGB(62, 64, 71)
Lighting.OutdoorAmbient = Color3.fromRGB(45, 47, 54)

-- 2. Dark stone style for room parts
local rooms = workspace:WaitForChild("CurrentRooms")

local function styleRoom(room)
    for _, part in ipairs(room:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Basic approximation of the stone appearance
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

-- 3. Add the candle model
local success, candle = pcall(function()
    return game:GetObjects("rbxassetid://11630702537")[1]
end)

if success and candle then
    candle.Parent = backpack

    for _, part in ipairs(candle:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
else
    warn("Could not load the candle model.")
end
