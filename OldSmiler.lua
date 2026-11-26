local Creator = loadstring(game:HttpGet("https://raw.githubusercontent.com/fernandesdasilvamariainez-coder/Aaaaaaa/refs/heads/main/Old%20Vynixu%20Entity%20Spawner"))()

-- Create entity
local entity = Creator.createEntity({
    CustomName = "Smiler", -- Custom name of your entity
    Model = "https://github.com/reboundplayz/Doors-Fixed-Modes/raw/refs/heads/main/Smiler.rbxm", -- Can be GitHub file or rbxassetid
    Speed = 850, -- Percentage, 100 = default Rush speed
    DelayTime = 12, -- Time before starting cycles (seconds)
    HeightOffset = 1,
    CanKill = true,
    KillRange = 50,
    BreakLights = true,
    FlickerLights = {
        true, -- Enabled
        5, -- Time (seconds)
    },
    Cycles = {
        Min = 2,
        Max = 20,
        WaitTime = 0.3,
    },
    CamShake = {
        true, -- Enabled
        {20, 20, 1, 2}, -- Shake values (don't change if you don't know)
        100, -- Shake start distance (from Entity to you)
    },
    Jumpscare = {
         true, -- Enabled ('false' if you don't want jumpscare)
        {
            Image1 = "rbxassetid://11417375410", -- Image1 url
            Image2 = "rbxassetid://11417375410", -- Image2 url
            Shake = true,
            Sound1 = {
                5263560566, -- SoundId
                { Volume = 2.1 }, -- Sound properties
            },
            Sound2 = {
                5263560566, -- SoundId
                { Volume = 2.1 }, -- Sound properties
            },
            Flashing = {
                true, -- Enabled
                Color3.fromRGB(255, 0, 0), -- Color
            },
            Tease = {
                false, -- Enabled ('false' if you don't want tease)
                Min = 1,
                Max = 3,
            },
        },
    },
    CustomDialog = {"¡¡ THIS SMILE IS LIKE ABMUSH !!", "Hide and don't Smile", "Don't get Tricked"}, -- Custom death message (can be as long as you want)
})
    ------------------------

    -- Run the created entity
    Creator.runEntity(entity)
