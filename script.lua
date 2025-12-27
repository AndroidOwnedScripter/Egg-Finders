--==================================================
-- RAYFIELD
--==================================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Egg Finders",
    Icon = 4483362458,
    LoadingTitle = "Egg Finders",
    LoadingSubtitle = "AndroidOwnedScripter",
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
-- EVENT TAB — AUTO ORB
--==================================================
local EventTab = Window:CreateTab("Event", 4483362458)

local AutoOrbToggle = EventTab:CreateToggle({
    Name = "Auto Orb [❄️]",
    CurrentValue = false,
    Flag = "AutoOrb"
})

task.spawn(function()
    while true do
        if AutoOrbToggle.CurrentValue then
            local char = getCharacter()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local orbs = workspace:FindFirstChild("Orbs")

            if orbs then
                for _, orb in ipairs(orbs:GetChildren()) do
                    if orb:IsA("BasePart") and orb.Name == "ItemOrb" then
                        hrp.CFrame = orb.CFrame + Vector3.new(0,3,0)
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
    Name = "Auto Index",
    CurrentValue = false,
    Flag = "AutoIndex",
    Callback = function(v)
        _G.AutoSellEggs = v
    end
})


-- MEGA INDEX

local MegaIndexToggle = MainTab:CreateToggle({
    Name = "Mega Index",
    CurrentValue = false,
    Flag = "MegaIndex",
    Callback = function(v)
        _G.MegaIndex = v
    end
})

_G.MegaIndex = false

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
for i,name in ipairs(EggPriority) do
    AllowedEggs[name] = i
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
-- PATHFINDING STABLE
--==================================================
local function moveToDestination(humanoid, hrp, getTargetPos, abortCheck)
    local lastRepath = 0
    while AutoIndexToggle.CurrentValue or _G.MegaIndex do
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
            if wp.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
            local timeout = tick() + 1.5
            while (hrp.Position - wp.Position).Magnitude > 2 do
                if abortCheck and abortCheck() then return false end
                if tick() > timeout then break end
                task.wait(0.05)
            end
        end

        if (hrp.Position - targetPos).Magnitude <= 4 then return true end
    end
    return false
end

--==================================================
-- AUTO INDEX LOOP (FINAL)
--==================================================
task.spawn(function()
    while true do
        if AutoIndexToggle.CurrentValue or _G.MegaIndex then
            local char = getCharacter()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local humanoid = char:WaitForChild("Humanoid")
            local eggsFolder = workspace:FindFirstChild("Eggs")
            if eggsFolder then
                local bestEgg, bestPrio = nil, math.huge
                for _, egg in ipairs(eggsFolder:GetChildren()) do
                    if AllowedEggs[egg.Name] and AllowedEggs[egg.Name] < bestPrio then
                        bestEgg = egg
                        bestPrio = AllowedEggs[egg.Name]
                    end
                end

                if bestEgg then
                    local part = bestEgg:IsA("Model") and (bestEgg.PrimaryPart or bestEgg:FindFirstChildWhichIsA("BasePart", true)) or bestEgg
                    local click = bestEgg:FindFirstChildWhichIsA("ClickDetector", true)

                    if part and click then
                        local reached = moveToDestination(humanoid, hrp, function() return part.Position end, function() return not bestEgg.Parent end)
                        if reached and bestEgg.Parent then
                            fireclickdetector(click)
                            task.wait(0.25)
                            moveToDestination(humanoid, hrp, function() return prompt.Parent.Position end, function() return not bestEgg.Parent end)
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
