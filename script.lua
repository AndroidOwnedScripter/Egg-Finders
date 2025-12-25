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

-- Toggle Auto Index Rare Eggs
local AutoIndexToggle = MainTab:CreateToggle({
    Name = "Auto Index Rare Eggs",
    CurrentValue = false,
    Flag = "AutoIndexRareEggs",
    Callback = function(Value)
        -- Rien à mettre ici, la boucle principale gère l'activation/désactivation
    end,
})

-- Boucle principale pour chercher et indexer les œufs
spawn(function()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    
    -- Fonction pour récupérer le personnage
    local function getCharacter()
        return player.Character or player.CharacterAdded:Wait()
    end
    
    while true do
        if AutoIndexToggle.CurrentValue then
            local character = getCharacter()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            
            local eggsFolder = workspace:FindFirstChild("Eggs")
            local indexArea = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Index") and workspace.Map.Index:FindFirstChild("IndexArea")
            
            if eggsFolder and indexArea then
                for _, egg in pairs(eggsFolder:GetChildren()) do
                    -- Vérifier si c'est un model ou mesh
                    if egg:IsA("Model") or egg:IsA("MeshPart") then
                        -- Récupérer la classe de l'œuf
                        local eggClass = egg:FindFirstChild("Class") and egg.Class.Value or egg:GetAttribute("Class")
                        
                        -- Ignorer Common, Uncommon, Rare et Epic
                        if eggClass and not (eggClass == "Common" or eggClass == "Uncommon" or eggClass == "Rare" or eggClass == "Epic") then
                            -- Détecter le ClickDetector
                            local click = egg:FindFirstChildWhichIsA("ClickDetector")
                            if click then
                                -- "Cliquer" sur l'œuf
                                click:FireServer()
                            end
                            
                            -- Déplacer l'œuf dans l'IndexArea
                            if egg:IsA("Model") then
                                egg:SetPrimaryPartCFrame(indexArea.CFrame + Vector3.new(0, 3, 0))
                            elseif egg:IsA("MeshPart") then
                                egg.CFrame = indexArea.CFrame + Vector3.new(0, 3, 0)
                            end
                            
                            break -- Prend un œuf à la fois
                        end
                    end
                end
            end
        end
        
        task.wait(0.3) -- pause pour éviter de surcharger
    end
end)
