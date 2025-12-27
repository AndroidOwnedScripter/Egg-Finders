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
-- MAIN TAB — AUTO FIND EGG + AUTO SELL (PATHFINDING DYNAMIQUE)
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
local EggPriority = { -- ta liste complète
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
for i, name in ipairs(EggPriority) do AllowedEggs[name] = i end

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
-- PATHFINDING DYNAMIQUE
--==================================================
local function goTo(humanoid, hrp, getDestination)
    while AutoIndexToggle.CurrentValue do
        local dest = getDestination()
        if not dest then break end

        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            AgentJumpHeight = 7,
            AgentMaxSlope = 45
        })

        path:ComputeAsync(hrp.Position, dest)
        if path.Status ~= Enum.PathStatus.Success then
            task.wait(0.3)
        else
            local blocked = false
            for _, wp in ipairs(path:GetWaypoints()) do
                humanoid:MoveTo(wp.Position)
                if wp.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end

                local startTime = tick()
                while (hrp.Position - wp.Position).Magnitude > 2 do
                    if not AutoIndexToggle.CurrentValue then return end

                    -- Recalculer la destination si elle a bougé
                    local newDest = getDestination()
                    if (newDest - wp.Position).Magnitude > 2 then
                        blocked = true
                        break
                    end

                    -- Timeout pour éviter blocage sur obstacle
                    if tick() - startTime > 2 then
                        blocked = true
                        break
                    end

                    task.wait(0.05)
                end

                if blocked then break end
            end
        end
        task.wait(0.05)
    end
end

--==================================================
-- AUTO SELL CONFIG
--==================================================
local SELL_DELAY = 0.1
local prompt = workspace.Map.Crusher.Hitbox:WaitForChild("ProximityPrompt")
prompt.MaxActivationDistance = math.huge
prompt.HoldDuration = 0

if not fireproximityprompt then warn("fireproximityprompt non supporté") end
_G.AutoSellEggs = false
task.spawn(function()
    while true do
        if _G.AutoSellEggs then pcall(function() fireproximityprompt(prompt) end) end
        task.wait(SELL_DELAY)
    end
end)

--==================================================
-- AUTO FIND EGG + SELL
--==================================================
task.spawn(function()
    while true do
        if AutoIndexToggle.CurrentValue then
            local char = getCharacter()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local humanoid = char:WaitForChild("Humanoid")
            local eggsFolder = workspace:FindFirstChild("Eggs")
            if not eggsFolder then task.wait(0.3) continue end

            local function getHighestPriorityEgg()
                local target, bestPrio = nil, math.huge
                for _, egg in ipairs(eggsFolder:GetChildren()) do
                    if AllowedEggs[egg.Name] then
                        local prio = AllowedEggs[egg.Name]
                        if prio < bestPrio then
                            target, bestPrio = egg, prio
                        end
                    end
                end
                return target, bestPrio
            end

            local targetEgg, highestPriority = getHighestPriorityEgg()
            if not targetEgg then task.wait(0.3) continue end

            local eggPart = targetEgg:IsA("Model") and (targetEgg.PrimaryPart or targetEgg:FindFirstChildWhichIsA("BasePart", true)) or targetEgg
            local clickDetector = targetEgg:FindFirstChildWhichIsA("ClickDetector", true)
            if not (eggPart and clickDetector) then task.wait(0.3) continue end

            -- Suivi vers l’œuf
            goTo(humanoid, hrp, function()
                if not targetEgg.Parent then return nil end
                return eggPart.Position
            end)

            if targetEgg.Parent then
                fireclickdetector(clickDetector)
                task.wait(0.2)

                -- Aller vers la machine
                goTo(humanoid, hrp, function() return prompt.Parent.Position end)
            end
        else
            task.wait(0.1)
        end
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



--==================================================
-- AURA CLICK TOGGLE
--==================================================
local AuraClickToggle = MainTab:CreateToggle({
    Name = "AuraClick",
    CurrentValue = false,
    Flag = "AuraClick",
    Callback = function(v)
        _G.AuraClick = v
    end
})

_G.AuraClick = false

task.spawn(function()
    while true do
        if _G.AuraClick then
            local char = getCharacter()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local radius = 10 -- rayon de l'aura (à ajuster)

            -- Chercher tous les ClickDetectors dans la zone
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ClickDetector") and obj.Parent then
                    local part = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart", true)
                    if part and (part.Position - hrp.Position).Magnitude <= radius then
                        pcall(function()
                            fireclickdetector(obj)
                        end)
                    end
                end
            end
        end
        task.wait(0.05) -- vitesse de spam
    end
end)
