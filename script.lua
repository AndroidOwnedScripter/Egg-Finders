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
