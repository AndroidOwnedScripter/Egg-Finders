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

-- EggInfo
local EggInfo = require(ReplicatedStorage.Modules.EggInfo)

-- Classes ignorées
local IgnoredClasses = {
    Common = true,
    Uncommon = true,
    Rare = true,
    Epic = true
}

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getEggClass(name)
    for _, egg in pairs(EggInfo) do
        if egg.Name == name then
            return egg.Class
        end
    end
end

-- Boucle principale
task.spawn(function()
    while true do
        if AutoIndexToggle.CurrentValue then
            local char = getCharacter()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local eggsFolder = workspace:FindFirstChild("Eggs")
            local indexArea = workspace.Map and workspace.Map.Index and workspace.Map.Index:FindFirstChild("IndexArea")

            if eggsFolder and indexArea then
                for _, egg in ipairs(eggsFolder:GetChildren()) do
                    if egg:IsA("Model") or egg:IsA("MeshPart") then
                        local eggClass = getEggClass(egg.Name)

                        if eggClass and not IgnoredClasses[eggClass] then
                            -- Trouver la part physique de l'œuf
                            local eggPart
                            if egg:IsA("Model") then
                                eggPart = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart", true)
                            else
                                eggPart = egg
                            end
                            if not eggPart then continue end

                            -- TP sur l'œuf
                            hrp.CFrame = eggPart.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.15)

                            -- CLICK PHYSIQUE (FIABLE)
                            firetouchinterest(hrp, eggPart, 0)
                            firetouchinterest(hrp, eggPart, 1)

                            task.wait(0.2)

                            -- TP vers l'Index
                            hrp.CFrame = indexArea.CFrame + Vector3.new(0, 3, 0)

                            -- ⏱️ DÉLAI DEMANDÉ (1 SECONDE)
                            task.wait(1)

                            break -- 1 œuf à la fois
                        end
                    end
                end
            end
        end

        task.wait(0.3)
    end
end)

