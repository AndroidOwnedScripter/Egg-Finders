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

--==================================================
-- AUTO FIND EGG + SELL (FALLBACK DIRECT + NOCLIP + TOUS TYPES)
--==================================================
local AutoIndexToggle = MainTab:CreateToggle({
    Name = "Auto find egg + sell",
    CurrentValue = false,
    Flag = "AutoIndex",
    Callback = function(v)
        _G.AutoSellEggs = v
    end
})

-- liste des œufs inchangée
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
for i,v in ipairs(EggPriority) do
    AllowedEggs[v] = i
end

--==================================================
-- SERVICES
--==================================================
local player = game:GetService("Players").LocalPlayer

local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

--==================================================
-- NOCLIP
--==================================================
local function noclip(enable)
    local char = getChar()
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enable
        end
    end
end

--==================================================
-- MOVE DIRECT + FALLBACK + NOCLIP
--==================================================
local function fallbackMove(h, hrp, getDestination)
    noclip(true)
    h.PlatformStand = false
    h.AutoRotate = true

    local stuckTimer = 0
    local lastPos = hrp.Position

    while AutoIndexToggle.CurrentValue do
        local dest = getDestination()
        if not dest then break end

        h:MoveTo(dest)
        h.MoveToFinished:Wait(1.5)

        -- détection blocage
        if (hrp.Position - lastPos).Magnitude < 1 then
            stuckTimer += 1
        else
            stuckTimer = 0
        end
        lastPos = hrp.Position

        -- mini TP si bloqué
        if stuckTimer >= 3 then
            hrp.CFrame = CFrame.new(dest + Vector3.new(0,3,0))
            stuckTimer = 0
        end

        -- arrivé proche
        if (hrp.Position - dest).Magnitude < 5 then break end
        task.wait(0.1)
    end
    noclip(false)
end

--==================================================
-- AUTO FIND EGG + SELL LOOP
--==================================================
task.spawn(function()
    while true do
        if AutoIndexToggle.CurrentValue then
            local char = getChar()
            local humanoid = char:WaitForChild("Humanoid")
            local hrp = char:WaitForChild("HumanoidRootPart")

            local eggsFolder = workspace:FindFirstChild("Eggs")
            if not eggsFolder then task.wait(0.3) continue end

            -- choisir meilleur œuf
            local target, bestPrio = nil, math.huge
            for _, egg in ipairs(eggsFolder:GetChildren()) do
                local p = AllowedEggs[egg.Name]
                if p and p < bestPrio then
                    target, bestPrio = egg, p
                end
            end
            if not target then task.wait(0.3) continue end

            -- détecter Part ou Mesh du Model
            local eggPart
            if target:IsA("Model") then
                eggPart = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true) or target:FindFirstChildWhichIsA("MeshPart", true)
            elseif target:IsA("BasePart") or target:IsA("MeshPart") then
                eggPart = target
            end

            local clickDetector = target:FindFirstChildWhichIsA("ClickDetector", true)
            if not (eggPart and clickDetector) then task.wait(0.3) continue end

            -- déplacement fallback direct + noclip
            fallbackMove(humanoid, hrp, function()
                return target.Parent and eggPart.Position or nil
            end)

            -- clic sur l’œuf
            if target.Parent then
                fireclickdetector(clickDetector)
                task.wait(0.2)

                -- aller vers la machine pour vendre
                local prompt = workspace.Map.Crusher.Hitbox:WaitForChild("ProximityPrompt")
                fallbackMove(humanoid, hrp, function()
                    return prompt.Parent.Position
                end)
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
                    -- Fix : gère ClickDetector dans BasePart ou Model
                    local part = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart", true)
                    if part and (part.Position - hrp.Position).Magnitude <= radius then
                        pcall(function()
                            fireclickdetector(obj)
                        end)
                    end
                end
            end
        end
        task.wait(0.1) -- vitesse de spam
    end
end)

