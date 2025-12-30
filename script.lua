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
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local noclipConn
local activeTween

local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

--==================================================
-- TOGGLE SANTA
--==================================================
local SantaBypassToggle = EventTab:CreateToggle({
    Name = "[🎅] Go To Santa",
    CurrentValue = false,
    Flag = "SantaBypass",
    Callback = function(state)
        local char = getChar()
        local humanoid = char:WaitForChild("Humanoid")
        local hrp = char:WaitForChild("HumanoidRootPart")

        if state then
            ------------------------------------------------
            -- NOCLIP (SAFE)
            ------------------------------------------------
            if not noclipConn then
                noclipConn = RunService.Stepped:Connect(function()
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end)
            end

            ------------------------------------------------
            -- DELETE OBJECT (workspace.Eggs)
            ------------------------------------------------
            pcall(function()
                local eggsFolder = workspace:FindFirstChild("Eggs")
                if eggsFolder then
                    local obj = eggsFolder:FindFirstChild("Dont delete this brah")
                    if obj then
                        obj:Destroy()
                    end
                end
            end)

            ------------------------------------------------
            -- TWEEN TO SANTA (NORMAL, NO STATE CHANGE)
            ------------------------------------------------
            local santaFolder = workspace:FindFirstChild("NPCs")
            local santa = santaFolder and santaFolder:FindFirstChild("Santa")

            if santa then
                local santaPart =
                    santa:IsA("Model")
                    and (santa.PrimaryPart or santa:FindFirstChildWhichIsA("BasePart", true))
                    or santa

                if santaPart then
                    if activeTween then
                        activeTween:Cancel()
                        activeTween = nil
                    end

                    local distance = (hrp.Position - santaPart.Position).Magnitude
                    local tweenTime = math.clamp(distance / 25, 0.3, 5)

                    activeTween = TweenService:Create(
                        hrp,
                        TweenInfo.new(
                            tweenTime,
                            Enum.EasingStyle.Linear,
                            Enum.EasingDirection.Out
                        ),
                        { CFrame = santaPart.CFrame * CFrame.new(0, 0, -3) }
                    )

                    activeTween:Play()
                end
            end

        else
            ------------------------------------------------
            -- DISABLE CLEAN
            ------------------------------------------------
            if noclipConn then
                noclipConn:Disconnect()
                noclipConn = nil
            end

            if activeTween then
                activeTween:Cancel()
                activeTween = nil
            end
        end
    end
})

--==================================================
-- MAIN TAB
--==================================================
local MainTab = Window:CreateTab("Main", 4483362458)


--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

--==================================================
-- Auto Sell Egg
--==================================================
local AutoIndexToggle = MainTab:CreateToggle({
    Name = "Auto Find Egg + Sell [Dynamic Pathfinding]",
    CurrentValue = false,
    Flag = "AutoEggSellDynamicPath",
    Callback = function() end
})

--==================================================
-- EGG PRIORITY LIST
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
for i,v in ipairs(EggPriority) do
    AllowedEggs[v] = i
end

--==================================================
-- PATHFINDING CONTINUOUS (DYNAMIC)
--==================================================
local function moveToDynamic(humanoid, hrp, targetPos)
    local path, waypoints, wpIndex

    local function computePath()
        local newPath = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
            AgentJumpHeight = 7,
            AgentMaxSlope = 45
        })
        newPath:ComputeAsync(hrp.Position, targetPos)
        if newPath.Status == Enum.PathStatus.Success then
            return newPath, newPath:GetWaypoints()
        else
            return nil, {}
        end
    end

    path, waypoints = computePath()
    wpIndex = 1
    if not path then return false end

    while AutoIndexToggle.CurrentValue and (hrp.Position - targetPos).Magnitude > 5 do
        local wp = waypoints[wpIndex]
        if not wp then
            path, waypoints = computePath()
            wpIndex = 1
            task.wait(0.1)
            continue
        end

        humanoid:MoveTo(wp.Position)
        if wp.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end

        local reached = false
        while not reached and AutoIndexToggle.CurrentValue do
            local dist = (hrp.Position - wp.Position).Magnitude

            -- recalcul si joueur s'éloigne du chemin
            if dist > 4 then
                path, waypoints = computePath()
                wpIndex = 1
                break
            end

            if dist <= 2 then
                reached = true
            end
            task.wait(0.03)
        end

        wpIndex += 1
    end

    return true
end

--==================================================
-- TROUVER L’EGG PRIORITAIRE DYNAMIQUE
--==================================================
local function findTopEgg()
    local eggsFolder = workspace:FindFirstChild("Eggs")
    if not eggsFolder then return nil end

    local topEgg, bestPrio
    for _, egg in ipairs(eggsFolder:GetChildren()) do
        local p = AllowedEggs[egg.Name]
        if p and (not bestPrio or p < bestPrio) then
            topEgg, bestPrio = egg, p
        end
    end
    return topEgg
end

--==================================================
-- LOOP PRINCIPAL DYNAMIQUE
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
        local crusher = workspace.Map.Crusher.Hitbox
        if not crusher then
            task.wait(0.3)
            continue
        end

        -- 🥚 chercher le meilleur œuf dynamique
        local target = findTopEgg()
        if not target then
            task.wait(0.2)
            continue
        end

        local eggPart =
            target:IsA("Model")
            and (target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true))
            or target
        local clickDetector = target:FindFirstChildWhichIsA("ClickDetector", true)
        if not (eggPart and clickDetector) then task.wait(0.2) continue end

        -- 🚶‍♂️ marcher vers l’œuf
        local reachedEgg = moveToDynamic(humanoid, hrp, eggPart.Position)
        if not (reachedEgg and target.Parent) then task.wait(0.2) continue end

        -- 🖱️ click egg
        fireclickdetector(clickDetector)
        task.wait(0.2)

        -- 🏭 aller à la machine
        local prompt = crusher:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not prompt then task.wait(0.2) continue end

        local reachedMachine = moveToDynamic(humanoid, hrp, crusher.Position)
        if not reachedMachine then task.wait(0.2) continue end

        -- 🔁 spam prompt tant qu'on est proche et que toggle activé
        while AutoIndexToggle.CurrentValue and target.Parent and (hrp.Position - crusher.Position).Magnitude <= 7 do
            pcall(function()
                fireproximityprompt(prompt)
            end)

            -- 🥚 vérifier si un œuf de priorité plus haute apparaît
            local newTopEgg = findTopEgg()
            if newTopEgg and newTopEgg ~= target then
                target = newTopEgg
                break -- recalcul dynamique vers le nouvel œuf
            end

            task.wait(0.1)
        end

        -- ✅ après spam, recommence immédiatement la recherche
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


--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

--==================================================
-- TOGGLE EGG ESP
--==================================================
local VisualEggToggle = MainTab:CreateToggle({
    Name = "Visual Egg ESP",
    CurrentValue = false,
    Flag = "VisualEggESP",
    Callback = function() end
})

--==================================================
-- EGG PRIORITY LIST
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
for i,v in ipairs(EggPriority) do
    AllowedEggs[v] = i
end

--==================================================
-- FONCTIONS ESP
--==================================================
local currentBeam

local function findTopEgg()
    local eggsFolder = workspace:FindFirstChild("Eggs")
    if not eggsFolder then return nil end

    local topEgg, bestPrio
    for _, egg in ipairs(eggsFolder:GetChildren()) do
        local p = AllowedEggs[egg.Name]
        if p and (not bestPrio or p < bestPrio) then
            topEgg, bestPrio = egg, p
        end
    end
    return topEgg
end

local function createBeam(hrp, targetPart)
    if not hrp or not targetPart then return nil end

    local attachment0 = Instance.new("Attachment", hrp)
    local attachment1 = Instance.new("Attachment", targetPart)

    local beam = Instance.new("Beam")
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.FaceCamera = true
    beam.Color = ColorSequence.new(Color3.fromRGB(255,0,0))
    beam.Width0 = 0.2
    beam.Width1 = 0.2
    beam.LightEmission = 1
    beam.Transparency = NumberSequence.new(0)
    beam.Parent = workspace

    return {beam = beam, att0 = attachment0, att1 = attachment1}
end

local function updateESP(hrp, targetPart)
    -- Supprime l'ancien Beam
    if currentBeam then
        if currentBeam.beam then currentBeam.beam:Destroy() end
        if currentBeam.att0 then currentBeam.att0:Destroy() end
        if currentBeam.att1 then currentBeam.att1:Destroy() end
        currentBeam = nil
    end

    if targetPart then
        currentBeam = createBeam(hrp, targetPart)
    end
end

--==================================================
-- LOOP PRINCIPAL ESP
--==================================================
task.spawn(function()
    while true do
        task.wait(0.1)
        if not VisualEggToggle.CurrentValue then
            if currentBeam then
                if currentBeam.beam then currentBeam.beam:Destroy() end
                if currentBeam.att0 then currentBeam.att0:Destroy() end
                if currentBeam.att1 then currentBeam.att1:Destroy() end
                currentBeam = nil
            end
            continue
        end

        local char = getChar()
        local hrp = char:WaitForChild("HumanoidRootPart")

        local target = findTopEgg()
        local targetPart = target and (target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true))
        updateESP(hrp, targetPart)
    end
end)
