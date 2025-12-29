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
-- EVENT TAB — AUTO ORB (TOUCHINTEREST)
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
                        -- 🔥 SIMULE LE CONTACT
                        firetouchinterest(hrp, orb, 0) -- Touch
                        firetouchinterest(hrp, orb, 1) -- Untouch
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


--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

--==================================================
-- RAYFIELD TOGGLE (ASSUME Window & MainTab EXIST)
--==================================================
local AutoIndexToggle = MainTab:CreateToggle({
    Name = "Auto Find Egg + Sell [Tween]",
    CurrentValue = false,
    Flag = "AutoEggSell",
    Callback = function() end
})

--==================================================
-- EGG PRIORITY LIST (TA LISTE, ORDRE = PRIORITÉ)
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
for i, v in ipairs(EggPriority) do
    AllowedEggs[v] = i
end

--==================================================
-- TWEEN WALK (REMPLACE TP / PATHFINDING)
--==================================================
local function tweenWalkTo(humanoid, hrp, destination)
    if not destination then return end

    humanoid.AutoRotate = true
    local speed = humanoid.WalkSpeed
    local stepTime = 0.12

    while AutoIndexToggle.CurrentValue
        and (hrp.Position - destination).Magnitude > 5 do

        local dir = (destination - hrp.Position)
        if dir.Magnitude < 1 then break end

        humanoid:Move(dir.Unit, false)

        local step = dir.Unit * math.min(dir.Magnitude, speed * stepTime)
        local tween = TweenService:Create(
            hrp,
            TweenInfo.new(stepTime, Enum.EasingStyle.Linear),
            { CFrame = CFrame.new(hrp.Position + step, destination) }
        )

        tween:Play()
        tween.Completed:Wait()
    end
end

--==================================================
-- MAIN LOOP
--==================================================
task.spawn(function()
    while true do
        if not AutoIndexToggle.CurrentValue then
            task.wait(0.2)
            continue
        end

        local char = getChar()
        local humanoid = char:WaitForChild("Humanoid")
        local hrp = char:WaitForChild("HumanoidRootPart")

        local eggsFolder = workspace:FindFirstChild("Eggs")
        if not eggsFolder then task.wait(0.2) continue end

        -- 🔎 choisir l’egg le plus prioritaire ACTUEL
        local target, bestPrio
        for _, egg in ipairs(eggsFolder:GetChildren()) do
            local p = AllowedEggs[egg.Name]
            if p and (not bestPrio or p < bestPrio) then
                target, bestPrio = egg, p
            end
        end
        if not target then task.wait(0.2) continue end

        -- 🧱 trouver la part réelle
        local eggPart =
            target:IsA("Model")
            and (target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true))
            or target

        local clickDetector = target:FindFirstChildWhichIsA("ClickDetector", true)
        if not (eggPart and clickDetector) then task.wait(0.2) continue end

        -- 🚶‍♂️ marcher vers l’egg
        tweenWalkTo(humanoid, hrp, eggPart.Position)

        if not (AutoIndexToggle.CurrentValue and target.Parent) then
            continue
        end

        -- 🖱️ click egg
        fireclickdetector(clickDetector)
        task.wait(0.2)

        -- 🏭 aller à la machine
        local crusher = workspace.Map.Crusher.Hitbox
        local prompt = crusher:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not prompt then continue end

        tweenWalkTo(humanoid, hrp, crusher.Position)

        -- 🔁 spam prompt
        while AutoIndexToggle.CurrentValue
            and (hrp.Position - crusher.Position).Magnitude <= 7 do
            pcall(function()
                fireproximityprompt(prompt)
            end)
            task.wait(0.1)
        end

        task.wait(0.2)
    end
end)

--==================================================
-- Mega index
--==================================================
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
        task.wait(0.4) -- vitesse de spam
    end
end)


