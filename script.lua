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
    Name = "Auto Index (Smart + Anti-Stuck)",
    CurrentValue = false,
    Flag = "AutoIndex",
    Callback = function() end
})

--==================================================
-- 🥚 WHITELIST
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
    ["Shiny Glass"]=true,["Orange"]=true,
    ["Shiny Corroded"]=true,["Shiny Grass"]=true,
    ["Shiny Egg"]=true
}

--==================================================
-- 📚 EGG INFO + PRIORITY
--==================================================
local EggInfo = require(ReplicatedStorage.Modules.EggInfo)

local EggInfoByName = {}
for _, info in ipairs(EggInfo) do
    EggInfoByName[info.Name] = info
end

local ClassPriority = {
    Shiny = 4,
    Admin = 3,
    Special = 2
}

local function isHigherPriority(a, b)
    if not b then return true end
    local ia, ib = EggInfoByName[a.Name], EggInfoByName[b.Name]
    if not ia then return false end
    if not ib then return true end

    local pa = ClassPriority[ia.Class] or 1
    local pb = ClassPriority[ib.Class] or 1
    if pa ~= pb then return pa > pb end

    if ia.Chance and ib.Chance then
        return ia.Chance < ib.Chance
    end
    return false
end

--==================================================
-- 🧭 PATHFINDING
--==================================================
local function moveTo(humanoid, hrp, destination)
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
-- 🧠 AUTO INDEX (ANTI-STUCK)
--==================================================
task.spawn(function()
    local lastPos
    local stuckTime = 0

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
                local bestEgg

                -- 🔍 Scan intelligent
                for _, egg in ipairs(eggsFolder:GetChildren()) do
                    if AllowedEggs[egg.Name] and EggInfoByName[egg.Name] then
                        if isHigherPriority(egg, bestEgg) then
                            bestEgg = egg
                        end
                    end
                end

                if bestEgg then
                    local eggPart = bestEgg:IsA("Model")
                        and (bestEgg.PrimaryPart or bestEgg:FindFirstChildWhichIsA("BasePart", true))
                        or bestEgg
                    if not eggPart then goto continue end

                    local click = bestEgg:FindFirstChildWhichIsA("ClickDetector", true)
                    if not click then goto continue end

                    -- 🚶 Move to egg
                    moveTo(humanoid, hrp, eggPart.Position)

                    -- 🧠 Anti-stuck detection
                    if lastPos and (hrp.Position - lastPos).Magnitude < 0.5 then
                        stuckTime += 1
                        if stuckTime >= 15 then
                            humanoid.Jump = true
                            stuckTime = 0
                        end
                    else
                        stuckTime = 0
                    end
                    lastPos = hrp.Position

                    -- Click
                    if (hrp.Position - eggPart.Position).Magnitude <= 4 then
                        fireclickdetector(click)
                    end

                    -- 🚶 Move to index
                    moveTo(humanoid, hrp, indexArea.Position)

                    -- Wait egg disappear
                    local t = tick()
                    while bestEgg.Parent and tick() - t < 8 do
                        fireclickdetector(click)
                        task.wait(0.5)
                    end

                    task.wait(1)
                end
            end
        end
        ::continue::
        task.wait(0.3)
    end
end)
