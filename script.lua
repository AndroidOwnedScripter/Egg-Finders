local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Création de la fenêtre
local Window = Rayfield:CreateWindow({
    Name = "Egg Finders",
    Icon = 0,
    LoadingTitle = "Egg Finders",
    LoadingSubtitle = "by someone",
    ShowText = "Rayfield",
    Theme = "Default",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false
})

-- Création de l'onglet PlayerTab
local PlayerTab = Window:CreateTab("Event", 4483362458)

-- Création du toggle Auto Orb
local AutoOrbToggle = PlayerTab:CreateToggle({
    Name = "Auto Orb Egglings",
    CurrentValue = false,
    Flag = "AutoOrbToggle",
    Callback = function(Value)
        -- Rien à mettre ici, la boucle principale gère l'activation/désactivation
    end,
})

-- Boucle principale qui tourne en permanence
spawn(function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    local function getCharacter()
        return player.Character or player.CharacterAdded:Wait()
    end

    while true do
        if AutoOrbToggle.CurrentValue then
            local character = getCharacter()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

            local orbsFolder = workspace:FindFirstChild("Orbs")
            if orbsFolder then
                for _, orb in pairs(orbsFolder:GetChildren()) do
                    if orb.Name == "ItemOrb" and orb:IsA("BasePart") then
                        -- Téléporte le joueur sur l'orb
                        humanoidRootPart.CFrame = orb.CFrame + Vector3.new(0, 3, 0)
                        break
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)


local MainTab = Window:CreateTab("Main", 4483362458)

-- Toggle
local AutoIndexToggle = MainTab:CreateToggle({
    Name = "Auto Index Rare Eggs",
    CurrentValue = false,
    Flag = "AutoIndexRareEggs",
    Callback = function() end
})

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- EggInfo (source officielle des classes)
local EggInfo = require(ReplicatedStorage.Modules.EggInfo)

-- Classes à ignorer
local IgnoredClasses = {
    Common = true,
    Uncommon = true,
    Rare = true,
    Epic = true
}

-- Character helper
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- Récupérer la classe depuis EggInfo
local function getEggClass(eggName)
    for _, info in pairs(EggInfo) do
        if info.Name == eggName then
            return info.Class
        end
    end
end

-- Boucle principale
task.spawn(function()
    while true do
        if AutoIndexToggle.CurrentValue then
            local character = getCharacter()
            local hrp = character:WaitForChild("HumanoidRootPart")

            local eggsFolder = workspace:FindFirstChild("Eggs")
            local indexArea = workspace.Map and workspace.Map.Index and workspace.Map.Index:FindFirstChild("IndexArea")

            if eggsFolder and indexArea then
                for _, egg in ipairs(eggsFolder:GetChildren()) do
                    if egg:IsA("Model") or egg:IsA("MeshPart") then
                        local eggName = egg.Name
                        local eggClass = getEggClass(eggName)

                        -- Ignore les classes basiques
                        if eggClass and not IgnoredClasses[eggClass] then
                            -- Trouver la position de l'œuf
                            local eggCFrame
                            if egg:IsA("Model") then
                                local primary = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
                                if not primary then continue end
                                eggCFrame = primary.CFrame
                            else
                                eggCFrame = egg.CFrame
                            end

                            -- TP sur l'œuf
                            hrp.CFrame = eggCFrame + Vector3.new(0, 3, 0)
                            task.wait(0.1)

                            -- Click instant (ignore distance)
                            local click = egg:FindFirstChildWhichIsA("ClickDetector", true)
                            if click then
                                fireclickdetector(click)
                            end

                            task.wait(0.1)

                            -- TP vers l'Index
                            hrp.CFrame = indexArea.CFrame + Vector3.new(0, 3, 0)

                            break -- 1 œuf à la fois
                        end
                    end
                end
            end
        end

        task.wait(0.3)
    end
end)
