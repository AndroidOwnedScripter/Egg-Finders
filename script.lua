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
    Name = "broken auto find egg",
    CurrentValue = false,
    Flag = "AutoIndex",
    Callback = function() end
})

--==================================================
-- 🥚 WHITELIST DES ŒUFS (TA LISTE FINALE)
--==================================================
local AllowedEggs = {
    ["Money"]=true,["Tix"]=true,["Rich"]=true,["Timeless"]=true,["Grunch"]=true,
    ["Richest"]=true,["Mustard"]=true,["Chiken Stars"]=true,["Fake God"]=true,
    ["London"]=true,["Celebration"]=true,["Mango"]=true,["Crabegg PRIME"]=true,
    ["2025 Meme Trophy"]=true,["Reverie"]=true,["Seraphim"]=true,["Winning Egg"]=true,
    ["Admegg"]=true,["Capybaregg"]=true,["JackoLantegg"]=true,["Doodle’s"]=true,
    ["Veri Epik Eg"]=true,["StarFall"]=true,["Shiny Quantum"]=true,["Malware"]=true,
    ["Quantum"]=true,["G̶l̷i̷t̸c̷h̷e̴d̸ ̸F̵r̴a̶g̸m̷e̸n̵t̴"]=true,
    ["ERR0R"]=true,["God"]=true,["Angel"]=true,["Alien"]=true,["Evil"]=true,
    ["Golden Santegg"]=true,["Ice Candy"]=true,["Matterless"]=true,["Royal"]=true,
    ["Santegg"]=true,["Ruby Faberge"]=true,["Cerials"]=true,["Sapphire"]=true,
    ["Darkness"]=true,["Gingerbread"]=true,["Infinitegg"]=true,["Rudolf"]=true,
    ["Ruby"]=true,["Blackhole"]=true,["Burger"]=true,["Layered"]=true,
    ["Golden Ornament"]=true,["Draculegg"]=true,["DogEgg"]=true,["Bellegg"]=true,
    ["Super Ghost"]=true,["Paradox"]=true,["Holy"]=true,["Squid"]=true,["Grave"]=true,
    ["Shiny Golden"]=true,["Golden"]=true,["Blue Ornament"]=true,
    ["Green Ornament"]=true,["Red Ornament"]=true,["RoEgg"]=true,
    ["Shiny Blueberregg"]=true,["Nutcracker"]=true,["Blueberregg"]=true,
    ["Hellish"]=true,["Crabegg"]=true,["CartRide"]=true,["Appegg"]=true,
    ["Witch"]=true,["Ice"]=true,["Eggday"]=true,["Sun"]=true,["Orangegg"]=true,
    ["Candle"]=true,["Electricitegg"]=true,["Banana"]=true,["Shiny Rategg"]=true,
    ["Rategg"]=true,["Corrupted"]=true,["Iglegg"]=true,["Cheese"]=true,
    ["Magma"]=true,["Wild"]=true,["Core"]=true,["Crow"]=true,["Seedlegg"]=true,
    ["Paintegg"]=true,["Eg"]=true,["Pull"]=true,["Bee"]=true,["Frogg"]=true,
    ["Angry"]=true,["Shiny Wategg"]=true,["Elf"]=true,["Fruitcake"]=true,
    ["Wegg"]=true,["Pouch"]=true,["Bategg"]=true,["Shiny Fire"]=true,
    ["Zombegg"]=true,["Snowglobe"]=true,["Mummy"]=true,
    ["Shiny Ghost"]=true,["Penguin Egg"]=true,
    ["Colorful Lights"]=true,["Spidegg"]=true,["Shiny Iron"]=true,
    ["Skeleton"]=true,["Shiny Fish"]=true,["Candy Corn"]=true,["Pumpegg"]=true,
    ["Wreath"]=true,["Shiny Glass"]=true,["Orange"]=true,
    ["Shiny Corroded"]=true,["Festive Egg"]=true,["Shiny Grass"]=true,
    ["Shiny Egg"]=true
}

--==================================================
-- PATHFINDING MOVE (INCHANGÉ)
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
-- AUTO INDEX LOOP (WHITELIST)
--==================================================
task.spawn(function()
    while true do
        if AutoIndexToggle.CurrentValue then
            local char = getCharacter()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local humanoid = char:WaitForChild("Humanoid")

            local eggsFolder = workspace:FindFirstChild("Eggs")
            local indexArea = workspace.Map
                and workspace.Map:FindFirstChild("Index")
                and workspace.Map.Index:FindFirstChild("IndexArea")

            if eggsFolder and indexArea then
                for _, egg in ipairs(eggsFolder:GetChildren()) do
                    if not AutoIndexToggle.CurrentValue then break end
                    if not AllowedEggs[egg.Name] then continue end
                    if not (egg:IsA("Model") or egg:IsA("MeshPart")) then continue end

                    local eggPart = egg:IsA("Model")
                        and (egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart", true))
                        or egg
                    if not eggPart then continue end

                    local clickDetector = egg:FindFirstChildWhichIsA("ClickDetector", true)
                    if not clickDetector then continue end

                    -- 🧭 WALK TO EGG
                    moveToPosition(humanoid, hrp, eggPart.Position)

                    while AutoIndexToggle.CurrentValue and egg.Parent do
                        if (hrp.Position - eggPart.Position).Magnitude <= 4 then break end
                        task.wait(0.1)
                    end

                    if not egg.Parent then break end

                    -- 🖱️ CLICK
                    fireclickdetector(clickDetector)
                    task.wait(0.2)

                    -- 🧭 WALK TO INDEX
                    moveToPosition(humanoid, hrp, indexArea.Position)

                    local start = tick()
                    while AutoIndexToggle.CurrentValue and egg.Parent and tick() - start < 6 do
                        task.wait(0.1)
                    end

                    task.wait(1)
                    break
                end
            end
        end
        task.wait(0.3)
    end
end)

--==================================================
-- RAYFIELD TOGGLE INDEX AREA
--==================================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Mega Index Toggle",
    Icon = 0,
    LoadingTitle = "Mega Index Toggle",
    LoadingSubtitle = "by AndroidOwnedScripter",
    ShowText = "Rayfield",
    Theme = "Default",
    ToggleUIKeybind = "K",
})



-- Toggle
local MegaIndexToggle = MainTab:CreateToggle({
    Name = "Click to index",
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
            indexArea.Transparency = 0.6
            indexArea.CanCollide = false
            indexArea.Anchored = true
            indexArea.Material = Enum.Material.ForceField
            indexArea.Color = Color3.fromRGB(0, 255, 255)
            print("✅ Mega Index activé")
        else
            -- Rétablir taille normale
            indexArea.Size = Vector3.new(20, 20, 20) -- adapte selon la taille originale
            indexArea.Transparency = 1
            indexArea.CanCollide = true
            indexArea.Anchored = true
            indexArea.Material = Enum.Material.SmoothPlastic
            indexArea.Color = Color3.fromRGB(255, 255, 255)
            print("❌ Mega Index désactivé")
        end
    end
})
