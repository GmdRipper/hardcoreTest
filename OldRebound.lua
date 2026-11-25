local G = getgenv()

-- Achievement configuration
local ReboundAchievement = {
	Title = "Out Of Many Rebounds",
	Desc = "Back for more!",
	Reason = "Encounter Rebound.",
	Image = "rbxassetid://118331374348396",
}

local ACHIEVEMENT_FLAG_NAME = "ReboundAchievement"

local function GiveReboundAchievement()
	if workspace:FindFirstChild(ACHIEVEMENT_FLAG_NAME) then
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
	obtainedBadge.Name = ACHIEVEMENT_FLAG_NAME
	obtainedBadge.Value = true
	obtainedBadge.Parent = workspace

	task.spawn(function()
		local frame = template:Clone()
		frame.Name = "LiveAchievement"
		frame.Frame.Details.Title.Text = ReboundAchievement.Title
		frame.Frame.Details.Desc.Text = ReboundAchievement.Desc
		frame.Frame.Details.Reason.Text = ReboundAchievement.Reason
		frame.Frame.ImageLabel.Image = ReboundAchievement.Image
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

-- Ensuring the function exists in the global environment
G.LoadGithubModel = function(url, retryCount, retryDelay)
	retryCount = retryCount or 0
	retryDelay = retryDelay or 1

	if retryCount >= 3 then
		return nil
	end

	if not (writefile and getcustomasset and request and isfile and delfile) then
		return nil
	end

	local function getHash(str)
		local hash = 0
		for i = 1, #str do
			hash = (hash * 31 + string.byte(str, i)) % 2^32
		end
		return tostring(hash)
	end

	local fileName = "rebound_" .. getHash(url) .. ".rbxm"

	if retryCount > 0 then
		pcall(function()
			if isfile(fileName) then
				delfile(fileName)
			end
		end)
		wait(retryDelay)
	end

	local fileExists = false
	local fileCheckSuccess, fileExistsResult = pcall(function()
		return isfile(fileName)
	end)

	if fileCheckSuccess and fileExistsResult then
		fileExists = true
	end

	if not fileExists then
		local response = request({Url = url, Method = "GET"})

		if response.StatusCode ~= 200 then
			return G.LoadGithubModel(url, retryCount + 1, retryDelay)
		end

		writefile(fileName, response.Body)
	end

	local assetId = getcustomasset(fileName)
	local success, result = pcall(function()
		local objects = game:GetObjects(assetId)
		if objects and #objects > 0 then
			return objects[1]
		end
		return nil
	end)

	if success and result then
		local cloneSuccess, cloned = pcall(function()
			return result:Clone()
		end)

		if cloneSuccess and cloned then
			return cloned
		end
	end

	pcall(function()
		if delfile and isfile(fileName) then
			delfile(fileName)
		end
	end)

	return G.LoadGithubModel(url, retryCount + 1, retryDelay)
end

G.LoadGithubAudio = function(url, forceRefresh)
	if not (writefile and getcustomasset and request and isfile) then
		return nil
	end

	forceRefresh = forceRefresh or false

	local function getHash(str)
		local hash = 0
		for i = 1, #str do
			hash = (hash * 31 + string.byte(str, i)) % 2^32
		end
		return tostring(hash)
	end

	local function getAudioFormat(url)
		if url:match("%.mp3$") then
			return "mp3"
		elseif url:match("%.ogg$") then
			return "ogg"
		elseif url:match("%.wav$") then
			return "wav"
		else
			return "mp3"
		end
	end

	local audioFormat = getAudioFormat(url)
	local fileName = "rebound_audio_" .. getHash(url) .. "." .. audioFormat

	if forceRefresh and isfile(fileName) and delfile then
		pcall(function()
			delfile(fileName)
		end)
	end

	local fileExists = isfile(fileName)

	if not fileExists then
		local downloadUrl = url .. "?t=" .. math.random(1, 100000)

		local response = request({
			Url = downloadUrl,
			Method = "GET",
			Headers = {
				["Accept"] = "audio/mpeg, audio/ogg, application/octet-stream"
			}
		})

		if response.StatusCode ~= 200 then
			return nil
		end

		writefile(fileName, response.Body)
	end

	local success, assetId = pcall(function()
		return getcustomasset(fileName)
	end)

	if success and assetId then
		return assetId
	end

	pcall(function()
		if delfile then
			delfile(fileName)
		end
	end)

	return nil
end

local wavesRemaining = 0
local currentReboundEntity = nil
local cancelCurrentWave = false

local function abortCurrentWaveAndReset()
	cancelCurrentWave = true
	wavesRemaining = 0
	if currentReboundEntity and currentReboundEntity.Parent then
		pcall(function()
			currentReboundEntity:Destroy()
		end)
	end
	currentReboundEntity = nil
end

local hookedSeekSounds = {}

local function bindSeekSound(soundObj)
	if not soundObj or not soundObj:IsA("Sound") or hookedSeekSounds[soundObj] then
		return
	end
	hookedSeekSounds[soundObj] = true

	soundObj.Played:Connect(function()
		abortCurrentWaveAndReset()
	end)
end

local function isSeekMusicPlaying()
	local ambienceSeek = workspace:FindFirstChild("Ambience_Seek")
	if ambienceSeek and ambienceSeek:IsA("Sound") then
		bindSeekSound(ambienceSeek)
		if ambienceSeek.IsPlaying or ambienceSeek.Playing then
			return true
		end
	end

	for soundObj in pairs(hookedSeekSounds) do
		if soundObj.Parent and (soundObj.IsPlaying or soundObj.Playing) then
			return true
		end
	end

	return false
end

local function getCurrentRoom()
	local gameData = game:GetService("ReplicatedStorage"):FindFirstChild("GameData")
	local latestRoom = gameData and gameData:FindFirstChild("LatestRoom")
	local roomsFolder = workspace:FindFirstChild("CurrentRooms")
	if not latestRoom or not roomsFolder then
		return nil
	end
	return roomsFolder:FindFirstChild(tostring(latestRoom.Value))
end

local function isRoom50()
	local gameData = game:GetService("ReplicatedStorage"):FindFirstChild("GameData")
	local latestRoom = gameData and gameData:FindFirstChild("LatestRoom")
	if latestRoom and latestRoom.Value == 50 then
		return true
	end

	local currentRoom = getCurrentRoom()
	return currentRoom ~= nil and currentRoom.Name == "50"
end

local function cannotKillNow()
	return isSeekMusicPlaying() or isRoom50()
end

local existingSeek = workspace:FindFirstChild("Ambience_Seek")
if existingSeek then
	bindSeekSound(existingSeek)
end

workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("Sound") and descendant.Name == "Ambience_Seek" then
		bindSeekSound(descendant)
		if descendant.IsPlaying or descendant.Playing then
			abortCurrentWaveAndReset()
		end
	end
end)

local function Rebound()
	if cancelCurrentWave or isRoom50() then
		return
	end

	local repStorage = game.ReplicatedStorage
	local gameData = repStorage.GameData
	local latestRoom = gameData.LatestRoom
	local plusRoom = latestRoom.Value + 1
	local currentRooms = workspace.CurrentRooms
	local killed = false
	local speed = 2.2
	local entity = nil
	local cameraShaker = require(game.ReplicatedStorage.CameraShaker)
	local camera = workspace.CurrentCamera

	local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(cf)
		camera.CFrame = camera.CFrame * cf
	end)
	camShake:Start()

	local rawUrl = "https://github.com/Francisco1692qzd/RevivedOldHardcore/blob/main/oldRebound.rbxm?raw=true"

	if G.LoadGithubModel then
		entity = G.LoadGithubModel(rawUrl)
		if entity then
			entity.Parent = workspace
			currentReboundEntity = entity
		end
	end

	if not entity then
		return
	end

	if cancelCurrentWave or isRoom50() then
		if entity.Parent then
			entity:Destroy()
		end
		return
	end

	local function GetLastRoom()
		return currentRooms:FindFirstChild(plusRoom)
	end

	local entityPart = entity.PrimaryPart

	if GetLastRoom() ~= nil then
		entityPart.CFrame = GetLastRoom().RoomEnd.CFrame
	else
		entityPart.CFrame = currentRooms:FindFirstChild(latestRoom.Value).RoomEnd.CFrame
	end

	entityPart.CanCollide = false
	entityPart.Anchored = true

	wait(4)

	if cancelCurrentWave or isRoom50() then
		if entity.Parent then
			entity:Destroy()
		end
		return
	end

	local rebmoving = G.LoadGithubAudio("https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/main/MovingRebound.mp3")
	local moving = Instance.new("Sound")
	moving.SoundId = rebmoving
	moving.Parent = entityPart
	moving.Volume = 10
	moving:Play()

	local function canSeeTarget(target, size)
		if killed == true or cancelCurrentWave or cannotKillNow() then
			return false
		end

		local origin = entityPart.Position
		local direction = (target.HumanoidRootPart.Position - origin).Unit * size
		local ray = Ray.new(origin, direction)

		local hit, pos = workspace:FindPartOnRay(ray, entityPart)

		if hit then
			if hit:IsDescendantOf(target) then
				if cancelCurrentWave or cannotKillNow() then
					return false
				end
				killed = true
				return true
			end
		else
			return false
		end
	end

	spawn(function()
		while entityPart ~= nil and entity ~= nil and entity.Parent ~= nil and not cancelCurrentWave do
			wait(0.5)

			if cancelCurrentWave then
				break
			end

			local v = game.Players.LocalPlayer

			if v.Character ~= nil and v.Character:FindFirstChild("HumanoidRootPart") then
				if canSeeTarget(v.Character, 50) and not v.Character:GetAttribute("Hiding") and not cannotKillNow() then
					moving:Stop()

					local ReboundJs = Instance.new("ScreenGui")
					local Static = Instance.new("ImageLabel")
					local ReboundImage = Instance.new("ImageLabel")
					local JSSIZE = Instance.new("ImageLabel")

					ReboundJs.Name = "ReboundJs"
					ReboundJs.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

					Static.Name = "Static"
					Static.Parent = ReboundJs
					Static.BackgroundTransparency = 1
					Static.Size = UDim2.new(11, 0, 111, 0)
					Static.Image = "rbxassetid://236543215"
					Static.ImageTransparency = 1

					ReboundImage.Name = "Rebound"
					ReboundImage.Parent = ReboundJs
					ReboundImage.BackgroundTransparency = 1
					ReboundImage.Position = UDim2.new(0.4866, 0, 0.4793, 0)
					ReboundImage.Size = UDim2.new(0.0267, 0, 0.0387, 0)
					ReboundImage.Image = "rbxassetid://10914800940"

					JSSIZE.Name = "JSSIZE"
					JSSIZE.Parent = ReboundJs
					JSSIZE.BackgroundTransparency = 1
					JSSIZE.Position = UDim2.new(-0.586, 0, -1.251, 0)
					JSSIZE.Size = UDim2.new(2.128, 0, 3.081, 0)
					JSSIZE.Visible = false
					JSSIZE.Image = "rbxassetid://10914800940"

					coroutine.wrap(function()
						local script = Static

						while true do
							script.Image = "rbxassetid://236543215"
							task.wait(0.002)
							script.Rotation = 0
							task.wait(0.002)
							script.Rotation = 180
							task.wait(0.002)
							script.Image = "rbxassetid://236777652"
							task.wait(0.002)
							script.Rotation = 0
							task.wait(0.002)
							script.Rotation = 180
							task.wait(0.002)
						end
					end)()

					coroutine.wrap(function()
						local Plr = game.Players.LocalPlayer
						local gui = ReboundJs
						local static = gui.Static
						local jspos = gui.JSSIZE

						local rebjumpscare = G.LoadGithubAudio("https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/main/JumpscareReb.mp3")
						local jumpscare = Instance.new("Sound")
						jumpscare.SoundId = rebjumpscare
						jumpscare.Parent = workspace
						jumpscare.Volume = 5
						jumpscare:Play()
						game.Debris:AddItem(jumpscare, 10)

						game.TweenService:Create(static, TweenInfo.new(0.5), {
							ImageTransparency = 0.8
						}):Play()

						game.TweenService:Create(gui.Rebound, TweenInfo.new(0.5), {
							Size = jspos.Size,
							Position = jspos.Position
						}):Play()

						task.spawn(function()
							wait(0.3)
							if cancelCurrentWave or cannotKillNow() then
								return
							end
							Plr.Character:FindFirstChildWhichIsA("Humanoid"):TakeDamage(100)
							game.ReplicatedStorage.GameStats["Player_" .. Plr.Character.Name].Total.DeathCause.Value = "Rebound"
							game.ReplicatedStorage.GameStats["Player_" .. Plr.Character.Name]["1"].DeathCause.Value = "Rebound"

							firesignal(game.ReplicatedStorage.Bricks.DeathHint.OnClientEvent, {
								"You died to who you call Rebound...",
								"He makes his presence known and keeps coming back...",
								"Hide when this happens!"
							})
						end)

						wait(0.5)

						game.TweenService:Create(static, TweenInfo.new(1), {
							ImageTransparency = 1
						}):Play()

						game.TweenService:Create(gui.Rebound, TweenInfo.new(0.3), {
							ImageTransparency = 1
						}):Play()

						wait(1)
						gui:Destroy()
					end)()
				end
			end

			if entityPart and entityPart.Parent and v.Character and v.Character:FindFirstChild("HumanoidRootPart")
				and (entityPart.Position - v.Character.HumanoidRootPart.Position).Magnitude <= 60 then
				camShake:Start()
				camShake:ShakeOnce(17, 6, 0.1, 1)
			end
		end
	end)

	for i = latestRoom.Value, 1, -1 do
		if cancelCurrentWave or isRoom50() then
			if entity and entity.Parent then
				entity:Destroy()
			end
			return
		end

		if currentRooms:FindFirstChild(i) then
			local room = currentRooms[i]

			if room and room:FindFirstChild("RoomStart") then
				local abc = room:FindFirstChild("RoomEnd")
				local jerk = game.TweenService:Create(
					entityPart,
					TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{CFrame = abc.CFrame + Vector3.new(0, 0.4, 0)}
				)

				jerk:Play()
				jerk.Completed:Wait()
			end
		end
	end

	if entityPart and entityPart.Parent then
		entityPart.Anchored = false
		entityPart.CanCollide = false
	end
	if entity and entity.Parent then
		game.Debris:AddItem(entity, 5)
	end
	if currentReboundEntity == entity then
		currentReboundEntity = nil
	end
end

local function SpawnReb()
	if isRoom50() then
		return
	end

	cancelCurrentWave = false
	wavesRemaining = 3

	local rebarrival = G.LoadGithubAudio("https://raw.githubusercontent.com/Francisco1692qzd/RevivedOldHardcore/main/Warning.mp3")
	local arrival = Instance.new("Sound")
	arrival.SoundId = rebarrival
	arrival.Parent = workspace
	arrival.Volume = 7
	arrival:Play()
	game.Debris:AddItem(arrival, 10)

	local cameraShaker = require(game.ReplicatedStorage.CameraShaker)
	local camera = workspace.CurrentCamera

	local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(cf)
		camera.CFrame = camera.CFrame * cf
	end)

	local Warn = Instance.new("ColorCorrectionEffect", game.Lighting)
	Warn.TintColor = Color3.fromRGB(65, 138, 255)
	Warn.Saturation = -0.7
	Warn.Contrast = 0.2

	game.TweenService:Create(Warn, TweenInfo.new(15), {
		TintColor = Color3.fromRGB(255, 255, 255),
		Saturation = 0,
		Contrast = 0
	}):Play()

	game.Debris:AddItem(Warn, 15)

	camShake:Start()
	camShake:ShakeOnce(10, 3, 0.1, 6, 2, 0.5)

	pcall(Rebound)

	while wavesRemaining > 0 and not cancelCurrentWave do
		game.ReplicatedStorage.GameData.LatestRoom.Changed:Wait()

		if cancelCurrentWave or isRoom50() then
			break
		end

		wait(2)

		if cancelCurrentWave or isRoom50() then
			break
		end

		pcall(Rebound)
		if cancelCurrentWave then
			break
		end
		wavesRemaining = wavesRemaining - 1
	end

	if not cancelCurrentWave and not isRoom50() then
		GiveReboundAchievement()
	end
end

spawn(SpawnReb)
