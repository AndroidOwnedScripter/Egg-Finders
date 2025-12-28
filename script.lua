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
-- AUTO FIND EGG + SELL (TP MODE FINAL)
--==================================================

local AutoIndexToggle = MainTab:CreateToggle({
    Name = "Auto Find Egg + Sell [TP]",
    CurrentValue = false,
    Flag = "AutoIndexTP",
    Callback = function(v)
        _G.AutoIndex = v
    end
})

--==================================================
-- PRIORITY LIST (INCHANGÉE)
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

local EggRank = {}
for i, v in ipairs(EggPriority) do
    EggRank[v] = i
end

--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

--==================================================
-- TP FUNCTION (SAFE + STABLE)
--==================================================
local function tpTo(hrp, pos)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero

    for i = 1, 2 do
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        task.wait()
    end
end

--==================================================
-- MAIN LOOP
--==================================================
task.spawn(function()
    while task.wait(0.15) do
        if not _G.AutoIndex then continue end

        local char = getChar()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local eggsFolder = workspace:FindFirstChild("Eggs")
        if not eggsFolder then continue end

        -- 🔍 SELECT BEST EGG
        local target, bestRank
        for _, egg in ipairs(eggsFolder:GetChildren()) do
            local r = EggRank[egg.Name]
            if r and (not bestRank or r < bestRank) then
                target = egg
                bestRank = r
            end
        end
        if not target then continue end

        -- 🎯 GET PART
        local eggPart =
            target:IsA("Model")
            and (target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true))
            or target

        local click = target:FindFirstChildWhichIsA("ClickDetector", true)
        if not (eggPart and click) then continue end

        -- 🥚 TP + CLICK EGG
        if target.Parent then
            tpTo(hrp, eggPart.Position)
            fireclickdetector(click)
        end

        task.wait(0.15)

        -- 🏭 MACHINE
        local crusher = workspace.Map
            and workspace.Map:FindFirstChild("Crusher")
            and workspace.Map.Crusher:FindFirstChild("Hitbox")

        if crusher then
            local prompt = crusher:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                -- TP DIRECT SUR LA PART (comme demandé)
                tpTo(hrp, crusher.Position)

                -- SPAM PROMPT
                local start = tick()
                while _G.AutoIndex and tick() - start < 6 do
                    pcall(function()
                        fireproximityprompt(prompt)
                    end)
                    task.wait(0.1)
                end
            end
        end
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
        task.wait(0.3) -- vitesse de spam
    end
end)


