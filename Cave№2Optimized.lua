--[[
        ONLY WORKS ON HOTEL-
        MADE BY iCherryKardess#0001
		FIXED BY GmdRipper
]]

-- Noticement
-- firesignal(game.ReplicatedStorage.Bricks.Caption.OnClientEvent, "Script made by iCherryKardes. Fixed by GmdRipper. You might need to reexecute if you are at door 51.")

-- Achievement
local CaveAchievement = {
    Title = "The Cave",
    Desc = "Deep in the Hotel!",
    Reason = 'Play "The Cave" Theme.',
    Image = "https://raw.githubusercontent.com/GmdRipper/hardcoreTest/main/TheCaveAchivement.jpg",
}
local Achievements = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MuhXd/Models/main/RegularVynixu's%20Achievement%20Modifyer"
))()
local function AchievementsGet(Achievement)
    Achievements.Get(Achievement)
end
local function GiveCaveAchievement()
    if workspace:FindFirstChild("CaveAchievement") then
        return
    end
    local success, err = pcall(function()
        AchievementsGet(CaveAchievement)
    end)
    if not success then
        warn("The Cave achievement error: " .. tostring(err))
        return
    end
    local obtainedBadge = Instance.new("BoolValue")
    obtainedBadge.Name = "CaveAchievement"
    obtainedBadge.Value = true
    obtainedBadge.Parent = workspace
end
task.spawn(GiveCaveAchievement)

pcall(function()
	spawn(function()
		while wait() do
			local currentroomnumber = game:GetService("ReplicatedStorage").GameData.LatestRoom.Value
			if workspace["CurrentRooms"][currentroomnumber]:FindFirstChild("Door") ~= nil then
				if workspace["CurrentRooms"][currentroomnumber]:FindFirstChild("Door"):FindFirstChild("Door") ~= nil then
					workspace["CurrentRooms"][currentroomnumber]:FindFirstChild("Door"):FindFirstChild("Door").Material = Enum.Material.Slate
					workspace["CurrentRooms"][currentroomnumber]:FindFirstChild("Door"):FindFirstChild("Door").Color = Color3.new(0.341176, 0.341176, 0.341176)
				end
			end
		end
	end)
	spawn(function()
		while wait() do
			local currentroomnumber = game:GetService("ReplicatedStorage").GameData.LatestRoom.Value
			if workspace["CurrentRooms"][currentroomnumber]:FindFirstChild("Door") ~= nil then
				if workspace["CurrentRooms"][currentroomnumber]:FindFirstChild("Door"):FindFirstChild("Door") ~= nil then
					if workspace["CurrentRooms"][currentroomnumber]:FindFirstChild("Door"):FindFirstChild("Door"):FindFirstChild("Sign") ~= nil then
						workspace["CurrentRooms"][currentroomnumber]:FindFirstChild("Door").Sign:Destroy()
						workspace["CurrentRooms"][currentroomnumber]:FindFirstChild("Door"):FindFirstChild("Door"):FindFirstChild("Sign"):Destroy()
					end
				end
			end
		end
	end)
end)

workspace["The Damned"]:Play()
workspace["The Damned"].SoundId = "rbxassetid://9113731836"
workspace["The Damned"].Pitch = 1
workspace["The Damned"].Looped = true
workspace["The Damned"].Volume = 1

function ambiance()
	while true do
		local ambiencefirst = Instance.new("Sound", workspace)
		ambiencefirst.SoundId = "rbxassetid://12229501"
		ambiencefirst.Pitch = 0.11
		ambiencefirst:Play()
		wait(120)
	end
end
task.spawn(ambiance)

-- Shop Items
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
		local CustomShop = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))()
		local Candle = game:GetObjects("rbxassetid://11630702537")[1]
		Candle.Parent = game.Players.LocalPlayer.Backpack
		local plr = game.Players.LocalPlayer
		local Char = plr.Character or plr.CharacterAdded:Wait()
		local Hum = Char:FindFirstChild("Humanoid")
		local RightArm = Char:FindFirstChild("RightUpperArm")
		local LeftArm = Char:FindFirstChild("LeftUpperArm")
		local RightC1 = RightArm.RightShoulder.C1
		local LeftC1 = LeftArm.LeftShoulder.C1
		local AnimIdle = Instance.new("Animation")
		AnimIdle.AnimationId = "rbxassetid://9982615727"
		AnimIdle.Name = "IDleloplolo"
		local cam = workspace.CurrentCamera
		local candleLight = Candle.Handle.Top.Flame.GuidingLighteffect.EffectLight
		candleLight.LockedToPart = true
		if candleLight:IsA("PointLight") then
		    candleLight.Range = 100
		end
		Candle.Handle.Material = Enum.Material.Salt
		local track = Hum.Animator:LoadAnimation(AnimIdle)
		track.Looped = true
		local Equipped = false
		for i, v in pairs(Candle:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
		Candle.Equipped:Connect(function()
		    Equipped = true
		    track:Play()
		end)
		Candle.Unequipped:Connect(function()
		    track:Stop()
		    RightArm.Name = "RightUpperArm"
		    Equipped = false
		end)
		cam.ChildAdded:Connect(function(screech)
			if screech.Name == "Screech" and math.random(1, 400) ~= 1 then
				if not Equipped then
					return
				end
				if Equipped then
					game:GetService("Debris"):AddItem(screech, 0.05)
				end
			end
		end)
		Candle.TextureId = "rbxassetid://11622366799"
    -- Create custom shop item
        if plr.PlayerGui.MainUI.ItemShop.Visible then
			local item = CustomShop.CreateItem(Candle, {
				Title = "Guiding Candle",
				Desc = "\226\128\142קг๏ςєє๔ คՇ ץ๏ยг ๏ฬภ гเรк.",
				Image = "https://cdn.discordapp.com/attachments/1043448883407228961/1052275820275707954/Png_1.png",
				Price = 75,
				Stack = 1,
			})
			Candle.Parent = nil 
			if item and item.Button then
				item.Button.MouseButton1Click:Connect(function()
					local triumphs = plr:FindFirstChild("Triumphs") or plr:FindFirstChild("leaderstats")
					task.wait(0.1)
					if not plr.Backpack:FindFirstChild("Guiding Candle") and not (plr.Character and plr.Character:FindFirstChild("Guiding Candle")) then
						Candle.Parent = plr.Backpack
					end
				end)
			end
		else
			Candle:Destroy()
		end


































--[[ Sounds
game.Workspace.Ambience_Figure.SoundId = game.Workspace.Ambience_FigureIntense.SoundId
game.Workspace.Ambience_Figure.Volume = "0.7"
game.Workspace.Ambience_Seek.SoundId = "rbxassetid://1846862303"
if game.ReplicatedStorage.GameData.LatestRoom.Value == "50" then
	game.Workspace.Ambience_Seek.SoundId = "rbxassetid://1848156876"
end
]]
-- Settings
game.Players.LocalPlayer.PlayerGui.MainUI.Statistics.Frame["Floors Escaped"].Text = "Floors Escaped (2)"

--[[ Lighting Setup
while task.wait(0.00005) do
	game.Lighting.Ambient = Color3.new(0, 0, 0)
	game.Lighting.Caves.Enabled = true
	game.Lighting.Bloom.Enabled = true
	game.Lighting.FogEnd = "75"
	game.Lighting.FogStart = "10"
end
]]

-- Figure Room Setup (50)
if game.ReplicatedStorage.GameData.LatestRoom.Value == 50 then
	firesignal(game.ReplicatedStorage.Bricks.UseEventModule.OnClientEvent, "breakLights", workspace.CurrentRooms["50"], 0.416, 60)
	workspace.Ambience_Dark:Play()
end

--[[ Figure Room Setup (100)
if game.ReplicatedStorage.GameData.LatestRoom.Value == 100 then
	warn("Player reached room 100")
	game.Players.LocalPlayer.PlayerGui.MainUI.ToBeContinued.Visible = true
	wait(7)
	game.Players.LocalPlayer:Kick("Reached Room 100, room 100 is unavailable so we kicked you. Room 100 is soon. Thanks for using floor 2 mod by iCherryKardess!")
end
]]

-- Room Setup (Loop)
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Rooms = workspace:WaitForChild("CurrentRooms")
local LatestRoom = game.ReplicatedStorage.GameData.LatestRoom
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local function ApplyCave(room)
    if not room then
        return
    end

    local parts = room:FindFirstChild("Parts")
    if parts then
        for _, v in ipairs(parts:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.Limestone
                v.Color = Color3.new(0.243137, 0.25098, 0.278431)
            end
        end
    end

    local doorFolder = room:FindFirstChild("Door")
    local roomDoor = doorFolder and doorFolder:FindFirstChild("Door")
    if roomDoor then
        roomDoor.Material = Enum.Material.Slate
        local sign = roomDoor:FindFirstChild("Sign")
        if sign and sign:IsA("BasePart") then
            sign.Material = Enum.Material.Slate
        end
    end
end
local function ApplySettings()
    local mainUI = PlayerGui:FindFirstChild("MainUI")
    local statistics = mainUI
        and mainUI:FindFirstChild("Statistics")
    local frame = statistics
        and statistics:FindFirstChild("Frame")
    local floors = frame
        and frame:FindFirstChild("Floors Escaped")
    if floors then
        floors.Text = "Floors Escaped (2)"
    end

Lighting.Ambient = Color3.new(0, 0, 0)
local caves = Lighting:FindFirstChild("Caves")
if caves then
    caves.Enabled = true
end
local bloom = Lighting:FindFirstChild("Bloom")
if bloom then
    bloom.Enabled = false
end
Lighting.FogEnd = 75
Lighting.FogStart = 10
    local room = Rooms:FindFirstChild(tostring(LatestRoom.Value))
    if room then
        ApplyCave(room)
    end
end
ApplySettings()
LatestRoom.Changed:Connect(function()
    task.wait(0.15)
    ApplySettings()
end)
Rooms.ChildAdded:Connect(function(room)
    task.wait(0.15)
    if room.Name == tostring(LatestRoom.Value) then
        ApplyCave(room)
    end
end)
