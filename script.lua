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
-- MAIN TAB — AUTO FIND EGG + AUTO SELL (STABLE)
--==================================================
local MainTab = Window:CreateTab("Main", 4483362458)

local AutoIndexToggle = MainTab:CreateToggle({
    Name = "auto find egg + sell",
    CurrentValue = false,
    Flag = "AutoIndex",
    Callback = function(value)
        _G.AutoSellEggs = value
    end
})

--==================================================
-- 🥚 PRIORITY LIST DES ŒUFS
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
    "Electricitegg","Banana","Corrupted","Iglegg","Cheese","Magma","Wild","Core","Seedlegg",
    "Paintegg","Eg","Pull","Bee","Frogg","Angry","Grass"
}

local AllowedEggs = {}
for i, name in ipairs(EggPriority) do
    AllowedEggs[name] = i
end

--==================================================
-- SERVICES & UTILS
--==================================================
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local player = Players.LocalPlayer

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

--==================================================
-- AUTO SELL CONFIG
--==================================================
local SELL_DELAY = 0.1
local prompt = workspace.Map.Crusher.Hitbox:WaitForChild("ProximityPrompt")
prompt.MaxActivationDistance = math.huge
prompt.HoldDuration = 0

if not fireproximityprompt then
    warn("fireproximityprompt non supporté par ton exécuteur")
end

_G.AutoSellEggs = false
task.spawn(function()
    while true do
        if _G.AutoSellEggs then
            pcall(function() fireproximityprompt(prompt) end)
        end
        task.wait(SELL_DELAY)
    end
end)

--==================================================
-- PATHFINDING UTILS
--==================================================
local function moveToDestination(humanoid, hrp, getTargetPos)
    local reached = false
    while not reached and AutoIndexToggle.CurrentValue do
        local targetPos = getTargetPos()
        if not targetPos then break end

        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            AgentJumpHeight = 7,
            AgentMaxSlope = 45
        })
        path:ComputeAsync(hrp.Position, targetPos)
        if path.Status ~= Enum.PathStatus.Success then
            task.wait(0.1)
            continue
        end

        local waypoints = path:GetWaypoints()
        for _, wp in ipairs(waypoints) do
            if not AutoIndexToggle.CurrentValue then break end
            humanoid:MoveTo(wp.Position)
            if wp.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end

            while (hrp.Position - wp.Position).Magnitude > 2 and AutoIndexToggle.CurrentValue do
                local newTarget = getTargetPos()
                if newTarget and (newTarget - wp.Position).Magnitude > 2 then
                    break -- Refaire le path
                end
                task.wait(0.05)
            end
        end

        -- Vérifier si proche
        if (hrp.Position - targetPos).Magnitude <= 4 then
            reached = true
        end
    end
end

--==================================================
-- AUTO INDEX LOOP (PRIORITY + CLICK + AUTOSELL)
--==================================================
task.spawn(function()
    while true do
        if AutoIndexToggle.CurrentValue then
            local char = getCharacter()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local humanoid = char:WaitForChild("Humanoid")
            local eggsFolder = workspace:FindFirstChild("Eggs")
            if eggsFolder then

                -- Trouver l’œuf le plus prioritaire
                local function getHighestPriorityEgg()
                    local target = nil
                    local bestPrio = math.huge
                    for _, egg in ipairs(eggsFolder:GetChildren()) do
                        if AllowedEggs[egg.Name] then
                            local prio = AllowedEggs[egg.Name]
                            if prio < bestPrio then
                                target = egg
                                bestPrio = prio
                            end
                        end
                    end
                    return target, bestPrio
                end

                local targetEgg, highestPriority = getHighestPriorityEgg()
                if targetEgg then
                    local eggPart = targetEgg:IsA("Model")
                        and (targetEgg.PrimaryPart or targetEgg:FindFirstChildWhichIsA("BasePart", true))
                        or targetEgg
                    local clickDetector = targetEgg:FindFirstChildWhichIsA("ClickDetector", true)

                    if eggPart and clickDetector then
                        -- Suivre œuf avec pathfinding fluide
                        moveToDestination(humanoid, hrp, function()
                            -- Recheck priorité
                            local newTarget, newPrio = getHighestPriorityEgg()
                            if newTarget and newPrio < highestPriority then
                                targetEgg = newTarget
                                eggPart = targetEgg:IsA("Model")
                                    and (targetEgg.PrimaryPart or targetEgg:FindFirstChildWhichIsA("BasePart", true))
                                    or targetEgg
                                clickDetector = targetEgg:FindFirstChildWhichIsA("ClickDetector", true)
                                highestPriority = newPrio
                            end
                            return eggPart.Position
                        end)

                        -- Click sur l’œuf
                        if targetEgg.Parent then
                            fireclickdetector(clickDetector)
                            task.wait(0.2)

              -- Aller vers la machine pour vendre
moveToDestination(humanoid, hrp, function()
    return prompt.Parent.Position
end)

-- Surveiller la vente SANS bloquer le script
task.spawn(function()
    while AutoIndexToggle.CurrentValue do
        if not targetEgg or not targetEgg.Parent then
            -- L'œuf a disparu → relancer immédiatement la recherche
            break
        end
        task.wait(0.05)
    end
end)


                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Mega index
local MegaIndexToggle = MainTab:CreateToggle({
    Name = "Mega Index Area",
    CurrentValue = false,
    Flag = "MegaIndex",
    Callback = function(state)
        local indexArea =
            workspace:WaitForChild("Map")
            :WaitForChild("Index")
            :WaitForChild("IndexArea")

        if not indexArea:IsA("BasePart") then
            warn("IndexArea n'est pas une BasePart")
            return
        end

        if state then
            -- Activer mega index
            indexArea.Size = Vector3.new(5000, 2000, 5000)
            indexArea.CFrame = CFrame.new(indexArea.Position)
            indexArea.Transparency = 1
            indexArea.CanCollide = false
            indexArea.Anchored = true
            indexArea.Material = Enum.Material.ForceField
            indexArea.Color = Color3.fromRGB(0, 0, 0)
            print("✅ Mega Index activé")
        else
            -- Rétablir taille normale
            indexArea.Size = Vector3.new(20, 20, 20) -- adapte selon la taille originale
            indexArea.Transparency = 1
            indexArea.CanCollide = false
            indexArea.Anchored = true
            indexArea.Material = Enum.Material.SmoothPlastic
            indexArea.Color = Color3.fromRGB(255, 255, 255)
            print("❌ Mega Index désactivé")
        end
    end
})
