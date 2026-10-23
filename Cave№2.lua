--[[

	NOTICEMENT!!!! (READ)
		YOU ARE ALLOWED TO PUBLISH IT AT YOUR SERVER.
		YOU ARE ALLOWED TO MODIFY IT BUT YOU ARE NOT ALLOWED TO PUBLISH MODIFIED VERSION.
		Authorized People (can do anything): BasicallyAlex#8579, MuhammadGames#0017, Seek#4541, yessir12112131#0628
		I recommend you publishing this script with loadstring.
		MADE BY iCherryKardess#0001

]]

-- Noticement
firesignal(game.ReplicatedStorage.Bricks.Caption.OnClientEvent, "Script made by iCherryKardes. You might need to reexecute if you are at door 51.")


































-- Sounds
game.Workspace.Ambience_Figure.SoundId = game.Workspace.Ambience_FigureIntense.SoundId
game.Workspace.Ambience_Figure.Volume = "0.7"
game.Workspace.Ambience_Seek.SoundId = "rbxassetid://1846862303"
if game.ReplicatedStorage.GameData.LatestRoom.Value == "50" then
	game.Workspace.Ambience_Seek.SoundId = "rbxassetid://1848156876"
end
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

-- Figure Room Setup (100)
if game.ReplicatedStorage.GameData.LatestRoom.Value == 100 then
	warn("Player reached room 100")
	game.Players.LocalPlayer.PlayerGui.MainUI.ToBeContinued.Visible = true
	wait(7)
	game.Players.LocalPlayer:Kick("Reached Room 100, room 100 is unavailable so we kicked you. Room 100 is soon. Thanks for using floor 2 mod by iCherryKardess!")
end

-- Room Setup (Loop)
while task.wait(0.000005) do
game.Players.LocalPlayer.PlayerGui.MainUI.Statistics.Frame["Floors Escaped"].Text = "Floors Escaped (2)" -- if you escaped it will make it floors escaped 2
    for i,v in pairs(workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Parts:GetDescendants()) do
  if v:IsA("BasePart") then
        v.Material = Enum.Material.Limestone
        v.Color = Color3.new(0.243137, 0.25098, 0.278431) -- sets the color
        end
    end
	game.Lighting.Ambient = Color3.new(0, 0, 0)
	game.Lighting.Caves.Enabled = true
	game.Lighting.Bloom.Enabled = true
	game.Lighting.FogEnd = "75"
	game.Lighting.FogStart = "10"
	-- Door Setup
	local roomdoor = game.Workspace.CurrentRooms[game.ReplicatedStorage.GameData.LatestRoom.Value].Door.Door
		roomdoor.Material = "Slate"
		roomdoor.Sign.Material = "Slate"
		game.Lighting.FogEnd = "75"
		game.Lighting.FogStart = "10"
	end
