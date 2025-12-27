--==================================================
-- RAYFIELD
--==================================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Egg Finders",
    Icon = 0,
    LoadingTitle = "Egg Finders",
    LoadingSubtitle = "AndroidOwnedScripter",
    ShowText = "Rayfield",
    Theme = "Default",
    ToggleUIKeybind = "K",
})

--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local player = Players.LocalPlayer

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

--==================================================
-- EVENT TAB — AUTO ORB (INCHANGÉ)
--==================================================
local EventTab = Window:CreateTab("Event", 4483362458)

local AutoOrbToggle = EventTab:CreateToggle({
    Name = "Auto Orb [❄️]",
    CurrentValue = false,
    Flag = "AutoOrb",
    Callback = function() end
})

task.spawn(function()
    while true do
        if AutoOrbToggle.CurrentValue then
            local char = getCharacter()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local orbsFolder = workspace:FindFirstChild("Orbs")

            if orbsFolder then
                for _, orb in ipairs(orbsFolder:GetChildren()) do
                    if orb:IsA("BasePart") and orb.Name == "ItemOrb" then
                        hrp.CFrame = orb.CFrame + Vector3.new(0, 3, 0)
                        break
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)

--==================================================
-- MAIN TAB
--==================================================
local MainTab = Window:CreateTab("Main", 4483362458)

local AutoIndexToggle = MainTab:CreateToggle({
    Name = "auto find egg + sell",
    CurrentValue = false,
    Flag = "AutoIndex",
    Callback = function(v)
        _G.AutoSellEggs = v
    end
})

--==================================================
-- 🥚 PRIORITY LIST
--==================================================
local EggPriority = {
    "Malware","Quantum","ERR0R","Shiny Quantum","Shiny Golden","Shiny Blueberregg",
    "Shiny Rategg","Shiny Wategg","Shiny Fire","Shiny Ghost","Shiny Iron","Shiny Fish",
    "Shiny Glass","Shiny Corroded","Shiny Grass","Shiny Egg","Angel","Golden Santegg",
    "Ice Candy","Santegg","Gingerbread","Nutcracker","Elf","Fruitcake","Penguin Egg",
    "Evil","Cerials","Draculegg","Grave","Hellish","Witch","Zombegg","Candy Corn",
    "Spidegg","Skeleton","Pumpegg","Orange","God","Alien","Matterless","Royal",
    "Ruby Faberge","Sapphire","Darkness","Infinitegg","Ruby","Blackhole","Burger",
    "Layered","Mustard","Chiken Stars","Fake God","London","Mango","Crabegg PRIME",
    "Money","Tix","Rich","Timeless","Grunch","Richest","Celebration","2025 Meme Trophy",
    "Reverie","Seraphim","Winning Egg","Admegg","Capybaregg","JackoLantegg","Doodle’s",
    "Veri Epik Eg","StarFall","DogEgg","Super Ghost","Paradox","Holy","Squid","Golden",
    "RoEgg","Blueberregg","Crabegg","CartRide","Appegg","Ice","Eggday","Sun","Orangegg",
    "Electricitegg","Banana","Corrupted","Iglegg","Cheese","Magma","Wild","Core",
    "Seedlegg","Paintegg","Eg","Pull","Bee","Frogg","Angry","Grass"
}

local AllowedEggs = {}
for i, n in ipairs(EggPriority) do
    AllowedEggs[n] = i
end

--==================================================
-- AUTO SELL
--==================================================
local prompt = workspace.Map.Crusher.Hitbox:WaitForChild("ProximityPrompt")
prompt.MaxActivationDistance = math.huge
prompt.HoldDuration = 0

_G.AutoSellEggs = false
task.spawn(function()
    while true do
        if _G.AutoSellEggs then
            pcall(function()
                fireproximityprompt(prompt)
            end)
        end
        task.wait(0.1)
    end
end)

--==================================================
-- PATHFINDING (FINAL & STABLE)
--==================================================
local function moveToDestination(humanoid, hrp, getTargetPos, abortCheck)
    local lastRepath = 0

    while AutoIndexToggle.CurrentValue do
        if abortCheck and abortCheck() then return false end

        local targetPos = getTargetPos()
        if not targetPos then return false end

        if tick() - lastRepath < 0.25 then
            task.wait(0.05)
            continue
        end
        lastRepath = tick()

        local path = PathfindingService:CreatePath({
            AgentRadius = 3,
            AgentHeight = 6,
            AgentCanJump = true,
            AgentJumpHeight = 10,
            AgentMaxSlope = 50
        })

        path:ComputeAsync(hrp.Position, targetPos)
        if path.Status ~= Enum.PathStatus.Success then
            task.wait(0.1)
            continue
        end

        for _, wp in ipairs(path:GetWaypoints()) do
            if abortCheck and abortCheck() then return false end
            humanoid:MoveTo(wp.Position)
            if wp.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end

            local timeout = tick() + 1
            while (hrp.Position - wp.Position).Magnitude > 2 do
                if abortCheck and abortCheck() then return false end
                if tick() > timeout then break end
                task.wait(0.05)
            end
        end

        if (hrp.Position - targetPos).Magnitude <= 4 then
            return true
        end
    end
    return false
end

--==================================================
-- AUTO INDEX LOOP (FINAL)
--==================================================
task.spawn(function()
    while true do
        if AutoIndexToggle.CurrentValue then
            local char = getCharacter()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local humanoid = char:WaitForChild("Humanoid")
            local eggsFolder = workspace:FindFirstChild("Eggs")

            if eggsFolder then
                local function getBestEgg()
                    local best, prio = nil, math.huge
                    for _, e in ipairs(eggsFolder:GetChildren()) do
                        if AllowedEggs[e.Name] and AllowedEggs[e.Name] < prio then
                            best = e
                            prio = AllowedEggs[e.Name]
                        end
                    end
                    return best
                end

                local egg = getBestEgg()
                if egg then
                    local part = egg:IsA("Model") and (egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart", true)) or egg
                    local click = egg:FindFirstChildWhichIsA("ClickDetector", true)

                    if part and click then
                        local reached = moveToDestination(
                            humanoid,
                            hrp,
                            function() return part.Position end,
                            function() return not egg.Parent end
                        )

                        if reached and egg.Parent then
                            fireclickdetector(click)
                            task.wait(0.2)

                            moveToDestination(
                                humanoid,
                                hrp,
                                function() return prompt.Parent.Position end,
                                function() return not egg.Parent end
                            )
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
