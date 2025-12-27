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
-- MAIN TAB — AUTO INDEX
--==================================================
local MainTab = Window:CreateTab("Main", 4483362458)

local AutoIndexToggle = MainTab:CreateToggle({
    Name = "auto find egg",
    CurrentValue = false,
    Flag = "AutoIndex",
    Callback = function() end
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
    "Paintegg","Eg","Pull","Bee","Frogg","Angry"
}

-- Pour lookup rapide (priorité)
local AllowedEggs = {}
for i, name in ipairs(EggPriority) do
    AllowedEggs[name] = i
end

--==================================================
-- PATHFINDING MOVE
--==================================================
local function moveToPosition(humanoid, hrp, destination)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 7,
        AgentMaxSlope = 45
    })

    path:ComputeAsync(hrp.Position, destination)
    if path.Status ~= Enum.PathStatus.Success then return false end

    for _, wp in ipairs(path:GetWaypoints()) do
        if not AutoIndexToggle.CurrentValue then return false end
        humanoid:MoveTo(wp.Position)
        if wp.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end
        humanoid.MoveToFinished:Wait()
    end
    return true
end

--==================================================
-- AUTO INDEX LOOP (PRIORITY + CLICK + REPRISE)
--==================================================
task.spawn(function()
    while true do
        if AutoIndexToggle.CurrentValue then
            local char = getCharacter()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local humanoid = char:WaitForChild("Humanoid")

            local eggsFolder = workspace:FindFirstChild("Eggs")
            if eggsFolder then

                -- Cherche l’œuf le plus prioritaire actuellement présent
                local targetEgg = nil
                local highestPriority = math.huge
                for _, egg in ipairs(eggsFolder:GetChildren()) do
                    if not AutoIndexToggle.CurrentValue then break end
                    if not AllowedEggs[egg.Name] then continue end
                    local prio = AllowedEggs[egg.Name]
                    if prio < highestPriority then
                        targetEgg = egg
                        highestPriority = prio
                    end
                end

                if targetEgg then
                    local eggPart = targetEgg:IsA("Model")
                        and (targetEgg.PrimaryPart or targetEgg:FindFirstChildWhichIsA("BasePart", true))
                        or targetEgg
                    if eggPart then
                        local clickDetector = targetEgg:FindFirstChildWhichIsA("ClickDetector", true)
                        if clickDetector then

                            -- 🧭 Walk to egg avec reprise si le joueur bouge
                            local targetPos = eggPart.Position
                            while AutoIndexToggle.CurrentValue and targetEgg.Parent do
                                -- Vérifier si un œuf plus prioritaire apparaît
                                local newTarget = nil
                                local newHighestPriority = highestPriority
                                for _, egg2 in ipairs(eggsFolder:GetChildren()) do
                                    if not AllowedEggs[egg2.Name] then continue end
                                    local prio2 = AllowedEggs[egg2.Name]
                                    if prio2 < newHighestPriority then
                                        newTarget = egg2
                                        newHighestPriority = prio2
                                    end
                                end
                                if newTarget and newTarget ~= targetEgg then
                                    targetEgg = newTarget
                                    eggPart = targetEgg:IsA("Model")
                                        and (targetEgg.PrimaryPart or targetEgg:FindFirstChildWhichIsA("BasePart", true))
                                        or targetEgg
                                    clickDetector = targetEgg:FindFirstChildWhichIsA("ClickDetector", true)
                                    targetPos = eggPart.Position
                                end

                                -- Si proche, break
                                if (hrp.Position - targetPos).Magnitude <= 4 then break end

                                -- Bouger vers l’œuf
                                moveToPosition(humanoid, hrp, targetPos)

                                -- Recalculer position si l’œuf a bougé
                                if eggPart.Position ~= targetPos then
                                    targetPos = eggPart.Position
                                end

                                task.wait(0.1)
                            end

                            if targetEgg.Parent then
                                -- 🖱️ Click
                                fireclickdetector(clickDetector)
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.3)
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
