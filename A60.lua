local function A60spawn()
	task.spawn(function()
		local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors%20Entity%20Spawner/Source.lua"))()
		
		local entity = Creator.createEntity({
			Model = "12263106166",
			Speed = 350,
			DelayTime = 3,
			HeightOffset = 0.5,
			CanKill = false,
			FlickerLights = {
				false,
				4,
			},
			Cycles = {
				Min = 4,
				Max = 4,
				WaitTime = 0.05,
			},
			CamShake = {
				true,
				{30, 30, 0.1, 1},
				50,
			},
			Jumpscare = {
				false,
				{
					Image1 = "rbxassetid://11394048190",
					Image2 = "rbxassetid://11395251069",
					Shake = true,
					Sound1 = {
						10483790459,
						{ Volume = 0.5 },
					},
					Sound2 = {
						10483837590,
						{ Volume = 0.5 },
					},
					Flashing = {
						true,
						Color3.fromRGB(255, 0, 0),
					},
					Tease = {
						true,
						Min = 1,
						Max = 3,
					},
				},
			},
			CustomDialog = {
				"You died to an entity designated as A-60",
				"It can appear at any moment, a loud scream will announce its presence",
				"When you hear it spawn you must stay out of its reach as soon as possible",
				"It knows exactly where you are so hiding in different places will not work.."
			}
		})
		local spawned = true

		entity.Debug.OnEntitySpawned = function()
			local function Kill()
				local ScreenGui = Instance.new("ScreenGui")
				local JumpscareEnd = Instance.new("ImageLabel")
				local Full = Instance.new("ImageLabel")

				ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
				ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

				JumpscareEnd.Name = "JumpscareEnd"
				JumpscareEnd.Parent = ScreenGui
				JumpscareEnd.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				JumpscareEnd.BackgroundTransparency = 1.000
				JumpscareEnd.Position = UDim2.new(0.468161434, 0, 0.455128193, 0)
				JumpscareEnd.Size = UDim2.new(0.0636771321, 0, 0.0884615406, 0)
				JumpscareEnd.Image = "rbxassetid://0"
				JumpscareEnd.ImageColor3 = Color3.fromRGB(255, 0, 4)

				Full.Name = "Full"
				Full.Parent = ScreenGui
				Full.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Full.BackgroundTransparency = 1.000
				Full.Position = UDim2.new(-0.0609865487, 0, -0.224358946, 0)
				Full.Size = UDim2.new(1.12197304, 0, 1.44743586, 0)
				Full.Image = "http://www.roblox.com/asset/?id=11151804223"
				Full.ImageTransparency = 1.000

				local function DKITLS_fake_script()
					local Gui = ScreenGui
					local Plr = game.Players.LocalPlayer
					local Char = Plr.Character
					local A60 = workspace:FindFirstChild("A-60")
					local Camera = workspace.CurrentCamera
					local cameraShaker = require(game.ReplicatedStorage.CameraShaker)
					local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(cf)
						Camera.CFrame = Camera.CFrame * cf
					end)

					camShake:Start()
					local Jumpscaring = true
					local monster1 = A60:FindFirstChild("RushNew"):Clone()
					
					local function ImageChange(Part)
						spawn(function()
							while game["Run Service"].Heartbeat:Wait() do
								local get = Part.IMAGEIDS:GetChildren()
								local randome = get[math.random(1,#get)]
								Part.Main.Face.Texture = randome.Image
								wait(Random.new():NextNumber(0,0.02))
							end
						end)
					end

					monster1.Parent = Camera 
					ImageChange(monster1) 
					monster1.Name = "A-60_SCARE"
					
					for i,v in pairs(monster1:GetDescendants()) do
						if v:IsA("Sound") then v:Destroy() end 
					end
					
					local EntityOffset = Vector3.new(0,-1.2,-5)
					local LerpAlpha = 0.8
					
					local JumpscareSound = Instance.new("Sound", workspace)
					JumpscareSound.SoundId = "rbxassetid://10483790459"
					JumpscareSound.Volume = 6
					JumpscareSound:Play()
					
					camShake:ShakeOnce(25,25,0,4,90,60)
					local JumpscareContrast = Instance.new("ColorCorrectionEffect", game.Lighting)
					game.TweenService:Create(JumpscareContrast, TweenInfo.new(0.5), {Brightness = 0.2, Contrast = 0.2, Saturation = -0.2, TintColor = Color3.fromRGB(255, 0, 4)}):Play()
					
					spawn(function()
						while Jumpscaring do 
							game["Run Service"].RenderStepped:Wait()
							monster1.CFrame = monster1.CFrame:Lerp(Camera.CFrame * CFrame.new(EntityOffset), LerpAlpha)
						end
						game.TweenService:Create(monster1, TweenInfo.new(1), {CFrame = Camera.CFrame * CFrame.new(Vector3.new(0,-1.2,45))}):Play()
					end)
					
					wait(0.5) 
					Jumpscaring = false
					Gui.JumpscareEnd.Image = monster1:FindFirstChild("Main"):FindFirstChild("Face").Texture
					game.TweenService:Create(Gui.JumpscareEnd, TweenInfo.new(0.5), {Size = Gui.Full.Size, Position = Gui.Full.Position, Rotation = math.random(-20,20)}):Play()
					game.TweenService:Create(JumpscareContrast, TweenInfo.new(10), {Brightness = 0, Contrast = 0, Saturation = 0, TintColor = Color3.fromRGB(255, 255, 255)}):Play()
					
					Char:FindFirstChildWhichIsA("Humanoid"):TakeDamage(100)
					
					DEATHMESSAGE({
						"You died to an entity designated as A-60",
						"It can appear at any moment, a loud scream will announce its presence",
						"When you hear it spawn you must stay out of its reach as soon as possible",
						"It knows exactly where you are so hiding in different places will not work.."
					}, "A-60")
					
					wait(0.5)
					game.TweenService:Create(Gui.JumpscareEnd, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
					game.Debris:AddItem(monster1, 1)
				end
				coroutine.wrap(DKITLS_fake_script)()
			end

			local A60 = workspace:FindFirstChild("A-60"):FindFirstChild("RushNew")
			local deb = false
			local function canSeeTarget(target, size)
				if deb == true then return end
				local origin = A60.Position
				local direction = (target.HumanoidRootPart.Position - A60.Position).unit * size
				local ray = Ray.new(origin, direction)
				local hit, pos = workspace:FindPartOnRay(ray, A60)

				if hit and hit:IsDescendantOf(target) then
					deb = true
					if workspace.Ambience_Seek.Playing == true then return end
					for i,v in pairs(A60:GetDescendants()) do
						if v:IsA("Sound") then v:Destroy() end 
					end
					spawn(function() Kill() end)
					return true
				else
					return false
				end
			end

			spawn(function()
				while entity ~= nil do wait(0.5)
					val = game.Players.LocalPlayer
					if val.Character ~= nil and not val.Character:GetAttribute("Hiding") then
						canSeeTarget(val.Character, 50)
					end
				end
			end)

			spawn(function()
				local Monster = workspace:FindFirstChild("A-60")
				local Part = Monster:FindFirstChild("RushNew")
				Part.Static:Play()
				Part.Static.Pitch = 1.6
				while game["Run Service"].Heartbeat:Wait() and spawned do
					local get = Part.IMAGEIDS:GetChildren()
					local random = get[math.random(1,#get)]
					Part.Main.Face.Texture = random.Image
					wait(Random.new():NextNumber(0,0.07))
				end
			end)
		end

		entity.Debug.OnEntityDespawned = function(entity)
			spawned = false
			local Snd = Instance.new("Sound")
			Snd.Volume = 10
			Snd.Pitch = 0.1
			Snd.SoundId = "rbxassetid://7757472223"
			Snd.Parent = workspace
			Snd:Play()
			game.Debris:AddItem(Snd, 25)

			local Reboundcolor = Instance.new("ColorCorrectionEffect", game.Lighting) 
			game.Debris:AddItem(Reboundcolor, 24)
			Reboundcolor.Name = "Despawn"
			Reboundcolor.TintColor = Color3.fromRGB(255, 0, 4) 
			Reboundcolor.Saturation = -0.7 
			Reboundcolor.Contrast = 0.2
			
			game.TweenService:Create(Reboundcolor, TweenInfo.new(15), {TintColor = Color3.fromRGB(255, 255, 255), Saturation = 0, Contrast = 0}):Play()
			game.TweenService:Create(Snd, TweenInfo.new(23), {Volume = 0}):Play()
			
			local cameraShaker = require(game.ReplicatedStorage.CameraShaker)
			local camera = workspace.CurrentCamera
			local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(cf)
				camera.CFrame = camera.CFrame * cf
			end)
			camShake:Start()
			camShake:ShakeOnce(5, 45, 0.1, 20, 2, 20)
		end

		Creator.runEntity(entity)
	end)
end
