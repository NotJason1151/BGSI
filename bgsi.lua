--------------------------------
-- Project Lunar Bubble Gum Simulator
-- discord.gg/NbP9hmrqtC
--------------------------------

--------------------------------
-- WAIT FOR GAME & SETUP
--------------------------------
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer
task.wait(20)
print("Starting Project Lunar Bubble Gum Simulator...")

--------------------------------
-- SERVICES & REMOTES
--------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Framework = Shared:WaitForChild("Framework")
local Network = Framework:WaitForChild("Network")
local RemoteFunction = Network:WaitForChild("Remote"):WaitForChild("Function")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

RunService.Stepped:Connect(function()
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide == true then
            part.CanCollide = false
        end
    end
end)

local RemoteEvent = ReplicatedStorage:WaitForChild("Shared")
    :WaitForChild("Framework")
    :WaitForChild("Network")
    :WaitForChild("Remote")
    :WaitForChild("Event")

--------------------------------
-- GLOBAL CONFIG
--------------------------------

--------------------------------
-- DATA: GUM, FLAVORS, EGGS
--------------------------------
local GumFlavors = {
    ["Blueberry"]  = 25,
    ["Cherry"]     = 500,
    ["Pizza"]      = 1000,
    ["Watermelon"] = 3500,
    ["Chocolate"]  = 10000,
    ["Constract"]  = 35000,
    ["Gold"]       = 100000,
    ["Lemon"]      = 450000,
    ["Donut"]      = 1500000,
    ["Swirl"]      = 30000000,
    ["Molten"]     = 350000000
}

local StorageGum = {
    ["Stretchy Gum"]    = 25,
    ["Chewy Gum"]       = 250,
    ["Epic Gum"]        = 1500,
    ["Ultra Gum"]       = 5000,
    ["Omega Gum"]       = 12000,
    ["Unreal Gum"]      = 45000,
    ["Cosmic Gum"]      = 125000,
    ["XL Gum"]          = 650000,
    ["Mega Gum"]        = 1500000,
    ["Quantum Gum"]     = 5000000,
    ["Alien Gum"]       = 35000000,
    ["Radioactive Gum"] = 150000000,
    ["Experiment #52"]  = 1000000000
}


local Eggs = {
    ["Common Egg"]    = { price = 10,       pos = Vector3.new(-12.505, 6.636, -81.812), maxPower = 100 },
    ["Spotted Egg"]   = { price = 110,      pos = Vector3.new(-12.505, 10.465, -70.812), maxPower = 200 },
    ["Iceshard Egg"]  = { price = 450,      pos = Vector3.new(-12.505, 10.735, -59.812), maxPower = 400 },
    ["Spikey Egg"]    = { price = 5000,     pos = Vector3.new(-128.611, 11.097, 9.7908), maxPower = 1000 },
    ["Magma Egg"]     = { price = 15000,    pos = Vector3.new(-137.195, 11.181, 3.5343), maxPower = 1500 },
    ["Crystal Egg"]   = { price = 75000,    pos = Vector3.new(-144.172, 11.169, -4.9899), maxPower = 2500 },
    ["Lunar Egg"]     = { price = 100000,   pos = Vector3.new(-148.484, 10.948, -15.260), maxPower = 3500 },
    ["Void Egg"]      = { price = 175000,   pos = Vector3.new(-150.273, 10.985, -26.021), maxPower = 5000 },
    ["Hell Egg"]      = { price = 300000,   pos = Vector3.new(-149.327, 10.911, -36.887), maxPower = 6500 },
    ["Nightmare Egg"] = { price = 900000,   pos = Vector3.new(-146.009, 11.075, -46.994), maxPower = 8500 },
    ["Rainbow Egg"]   = { price = 1500000,  pos = Vector3.new(-140.054, 11.079, -56.058), maxPower = 12000 }
}

local function GetDefaultEggOrder()
    local coins = GetCurrency("coins")
    if coins > 100000000 then
         return {"Rainbow Egg"}, true   -- infinite mode: only Rainbow Egg
    elseif coins > 50000000 then
         return {"Nightmare Egg", "Rainbow Egg"}, false
    elseif coins > 20000000 then
         return {"Hell Egg", "Nightmare Egg", "Rainbow Egg"}, false
    elseif coins > 10000000 then
         return {"Void Egg", "Hell Egg", "Nightmare Egg", "Rainbow Egg"}, false
    elseif coins > 2000000 then
         return {"Crystal Egg", "Lunar Egg", "Void Egg", "Hell Egg", "Nightmare Egg", "Rainbow Egg"}, false
    elseif coins > 500000 then
         return {"Iceshard Egg", "Spikey Egg", "Magma Egg", "Crystal Egg", "Lunar Egg", "Void Egg", "Hell Egg", "Nightmare Egg", "Rainbow Egg"}, false
    else
         return {"Common Egg", "Spotted Egg", "Iceshard Egg", "Spikey Egg", "Magma Egg", "Crystal Egg", "Lunar Egg", "Void Egg", "Hell Egg", "Nightmare Egg", "Rainbow Egg"}, false
    end
end

-- The order we’ll use for hatching eggs
local EggOrder = {
    "Common Egg", "Spotted Egg", "Iceshard Egg", "Spikey Egg", "Magma Egg",
    "Crystal Egg", "Lunar Egg", "Void Egg", "Hell Egg", "Nightmare Egg", "Rainbow Egg"
}

--------------------------------
-- BUBBLE STATS & UI
--------------------------------
local BubbleStats = {
    CurrentBubble = "None",
    CurrentFlavor = "None",
    BubbleRate    = 0,
    Coins         = 0,
    Gems          = 0,
    Tokens        = 0,
    IslandsDiscovered = 0,
    LastActions   = {}
}

-- Global UI Container and Bubble Stats
local LunarUI = {}
local BubbleStats = {
    CurrentBubble = "None",
    CurrentFlavor = "None",
    BubbleRate = 0,
    Coins = 0,
    Gems = 0,
    Tokens = 0,
    IslandsDiscovered = 0,
    LastActions = {}
}

--------------------------------------------------------------------------------
-- UI Creation and Update Functions
--------------------------------------------------------------------------------

local function CreateUI()
    LunarUI.ScreenGui = Instance.new("ScreenGui")
    LunarUI.ScreenGui.Name = "LunarDashboard"
    LunarUI.ScreenGui.ResetOnSpawn = false
    LunarUI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    LunarUI.ScreenGui.IgnoreGuiInset = true

    -- Main frame positioned at top middle
    LunarUI.MainFrame = Instance.new("Frame")
    LunarUI.MainFrame.Name = "MainFrame"
    LunarUI.MainFrame.Size = UDim2.new(0.4, 0, 0.25, 0)
    LunarUI.MainFrame.Position = UDim2.new(0.3, 0, 0.05, 0)
    LunarUI.MainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
    LunarUI.MainFrame.BackgroundTransparency = 0.1
    LunarUI.MainFrame.BorderSizePixel = 0
    LunarUI.MainFrame.Parent = LunarUI.ScreenGui

    -- Magenta/purple border
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(180, 0, 255)
    UIStroke.Thickness = 3
    UIStroke.Transparency = 0.3
    UIStroke.Parent = LunarUI.MainFrame

    -- Title with RGB effect
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = "PROJECT LUNAR"
    Title.Size = UDim2.new(1, 0, 0.17, 0)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 30
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Center
    Title.Parent = LunarUI.MainFrame

    coroutine.wrap(function()
        local hue = 0
        while true do
            Title.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
            hue = (hue + 0.01) % 1
            task.wait(0.05)
        end
    end)()

    -- Subtitle
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Name = "SubTitle"
    SubTitle.Text = "BUBBLE GUM SIMULATOR INFINITY"
    SubTitle.Size = UDim2.new(1, 0, 0.15, 0)
    SubTitle.Position = UDim2.new(0, 0, 0.1, 0)
    SubTitle.Font = Enum.Font.GothamMedium
    SubTitle.TextSize = 16
    SubTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
    SubTitle.BackgroundTransparency = 1
    SubTitle.TextXAlignment = Enum.TextXAlignment.Center
    SubTitle.Parent = LunarUI.MainFrame

    local DiscordLink = Instance.new("TextLabel")
    DiscordLink.Name = "DiscordLink"
    DiscordLink.Text = "https://discord.gg/NbP9hmrqtC"
    DiscordLink.Size = UDim2.new(1, 0, 0.15, 0)
    DiscordLink.Position = UDim2.new(0, 0, 0.2, 0)
    DiscordLink.Font = Enum.Font.GothamMedium
    DiscordLink.TextSize = 25
    DiscordLink.TextColor3 = Color3.fromRGB(200, 200, 255)
    DiscordLink.BackgroundTransparency = 1
    DiscordLink.TextXAlignment = Enum.TextXAlignment.Center
    DiscordLink.Parent = LunarUI.MainFrame

    coroutine.wrap(function()
        local hue = 0
        while true do
            DiscordLink.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
            hue = (hue + 0.01) % 1
            task.wait(0.05)
        end
    end)()

    -- Divider line
    local Divider = Instance.new("Frame")
    Divider.Name = "Divider"
    Divider.Size = UDim2.new(0.9, 0, 0.002, 0)
    Divider.Position = UDim2.new(0.05, 0, 0.35, 0)
    Divider.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
    Divider.BorderSizePixel = 0
    Divider.Parent = LunarUI.MainFrame

    -- Stats frame
    LunarUI.StatsFrame = Instance.new("Frame")
    LunarUI.StatsFrame.Name = "StatsFrame"
    LunarUI.StatsFrame.Size = UDim2.new(0.9, 0, 0.5, 0)
    LunarUI.StatsFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
    LunarUI.StatsFrame.BackgroundTransparency = 1
    LunarUI.StatsFrame.Parent = LunarUI.MainFrame

    -- Current Bubble (centered)
    local CurrentBubble = Instance.new("TextLabel")
    CurrentBubble.Name = "CurrentBubble"
    CurrentBubble.Text = "BUBBLE: None"
    CurrentBubble.Size = UDim2.new(1, 0, 0.15, 0)
    CurrentBubble.Font = Enum.Font.GothamBold
    CurrentBubble.TextSize = 18
    CurrentBubble.TextColor3 = Color3.fromRGB(255, 255, 255)
    CurrentBubble.TextXAlignment = Enum.TextXAlignment.Center
    CurrentBubble.BackgroundTransparency = 1
    CurrentBubble.Parent = LunarUI.StatsFrame

    -- Current Flavor (centered)
    local CurrentFlavor = Instance.new("TextLabel")
    CurrentFlavor.Name = "CurrentFlavor"
    CurrentFlavor.Text = "FLAVOR: None"
    CurrentFlavor.Size = UDim2.new(1, 0, 0.15, 0)
    CurrentFlavor.Position = UDim2.new(0, 0, 0.15, 0)
    CurrentFlavor.Font = Enum.Font.GothamBold
    CurrentFlavor.TextSize = 18
    CurrentFlavor.TextColor3 = Color3.fromRGB(255, 255, 255)
    CurrentFlavor.TextXAlignment = Enum.TextXAlignment.Center
    CurrentFlavor.BackgroundTransparency = 1
    CurrentFlavor.Parent = LunarUI.StatsFrame

    -- Coins (centered)
    local CoinsEarned = Instance.new("TextLabel")
    CoinsEarned.Name = "CoinsEarned"
    CoinsEarned.Text = "COINS: 0"
    CoinsEarned.Size = UDim2.new(1, 0, 0.15, 0)
    CoinsEarned.Position = UDim2.new(0, 0, 0.3, 0)
    CoinsEarned.Font = Enum.Font.GothamBold
    CoinsEarned.TextSize = 18
    CoinsEarned.TextColor3 = Color3.fromRGB(255, 215, 0)
    CoinsEarned.TextXAlignment = Enum.TextXAlignment.Center
    CoinsEarned.BackgroundTransparency = 1
    CoinsEarned.Parent = LunarUI.StatsFrame

    -- Gems (centered)
    local GemsEarned = Instance.new("TextLabel")
    GemsEarned.Name = "GemsEarned"
    GemsEarned.Text = "GEMS: 0"
    GemsEarned.Size = UDim2.new(1, 0, 0.15, 0)
    GemsEarned.Position = UDim2.new(0, 0, 0.45, 0)
    GemsEarned.Font = Enum.Font.GothamBold
    GemsEarned.TextSize = 18
    GemsEarned.TextColor3 = Color3.fromRGB(0, 255, 255)
    GemsEarned.TextXAlignment = Enum.TextXAlignment.Center
    GemsEarned.BackgroundTransparency = 1
    GemsEarned.Parent = LunarUI.StatsFrame

    -- Tokens (centered)
    local TokensEarned = Instance.new("TextLabel")
    TokensEarned.Name = "TokensEarned"
    TokensEarned.Text = "TOKENS: 0"
    TokensEarned.Size = UDim2.new(1, 0, 0.15, 0)
    TokensEarned.Position = UDim2.new(0, 0, 0.6, 0)
    TokensEarned.Font = Enum.Font.GothamBold
    TokensEarned.TextSize = 18
    TokensEarned.TextColor3 = Color3.fromRGB(255, 100, 255)
    TokensEarned.TextXAlignment = Enum.TextXAlignment.Center
    TokensEarned.BackgroundTransparency = 1
    TokensEarned.Parent = LunarUI.StatsFrame

    -- Islands Discovered (centered)
    local IslandsDiscovered = Instance.new("TextLabel")
    IslandsDiscovered.Name = "IslandsDiscovered"
    IslandsDiscovered.Text = "ISLANDS: 0/5"
    IslandsDiscovered.Size = UDim2.new(1, 0, 0.15, 0)
    IslandsDiscovered.Position = UDim2.new(0, 0, 0.75, 0)
    IslandsDiscovered.Font = Enum.Font.GothamBold
    IslandsDiscovered.TextSize = 18
    IslandsDiscovered.TextColor3 = Color3.fromRGB(100, 255, 100)
    IslandsDiscovered.TextXAlignment = Enum.TextXAlignment.Center
    IslandsDiscovered.BackgroundTransparency = 1
    IslandsDiscovered.Parent = LunarUI.StatsFrame

    -- Status bar at bottom
    local StatusBar = Instance.new("TextLabel")
    StatusBar.Name = "StatusBar"
    StatusBar.Text = "Status: Ready"
    StatusBar.Size = UDim2.new(0.9, 0, 0.1, 0)
    StatusBar.Position = UDim2.new(0.05, 0, 0.9, 0)
    StatusBar.Font = Enum.Font.Gotham
    StatusBar.TextSize = 14
    StatusBar.TextColor3 = Color3.fromRGB(200, 200, 255)
    StatusBar.TextXAlignment = Enum.TextXAlignment.Left
    StatusBar.BackgroundTransparency = 1
    StatusBar.Parent = LunarUI.MainFrame

    LunarUI.ScreenGui.Parent = CoreGui
    return LunarUI
end

local function UpdateUI()
    if not LunarUI or not LunarUI.StatsFrame then return end
    
    if LunarUI.StatsFrame:FindFirstChild("CurrentBubble") then
        LunarUI.StatsFrame.CurrentBubble.Text = "BUBBLE: " .. BubbleStats.CurrentBubble
    end
    if LunarUI.StatsFrame:FindFirstChild("CurrentFlavor") then
        LunarUI.StatsFrame.CurrentFlavor.Text = "FLAVOR: " .. BubbleStats.CurrentFlavor
    end
    if LunarUI.StatsFrame:FindFirstChild("CoinsEarned") then
        LunarUI.StatsFrame.CoinsEarned.Text = "COINS: " .. BubbleStats.Coins
    end
    if LunarUI.StatsFrame:FindFirstChild("GemsEarned") then
        LunarUI.StatsFrame.GemsEarned.Text = "GEMS: " .. BubbleStats.Gems
    end
    if LunarUI.StatsFrame:FindFirstChild("TokensEarned") then
        LunarUI.StatsFrame.TokensEarned.Text = "TOKENS: " .. BubbleStats.Tokens
    end
    if LunarUI.StatsFrame:FindFirstChild("IslandsDiscovered") then
        LunarUI.StatsFrame.IslandsDiscovered.Text = "ISLANDS: " .. BubbleStats.IslandsDiscovered .. "/5"
    end
    if LunarUI.MainFrame:FindFirstChild("StatusBar") then
        LunarUI.MainFrame.StatusBar.Text = "Status: " .. (BubbleStats.LastActions[1] or "Ready")
    end
end

local function AddAction(action)
    table.insert(BubbleStats.LastActions, 1, os.date("%H:%M") .. ": " .. action)
    if #BubbleStats.LastActions > 5 then
        table.remove(BubbleStats.LastActions, 6)
    end
    UpdateUI()
end
--------------------------------
-- CURRENCY FUNCTIONS --License Owned by Project Lunar ( nesa ), dont skid hahahahaahaha
--------------------------------
local function ParseCurrency(txt)
    local cleaned = txt:gsub("[,%$%s]", "")
    if cleaned:lower():find("k") then
        cleaned = tonumber(cleaned:gsub("[kK]", "")) * 1000
    elseif cleaned:lower():find("m") then
        cleaned = tonumber(cleaned:gsub("[mM]", "")) * 1000000
    elseif cleaned:lower():find("b") then
        cleaned = tonumber(cleaned:gsub("[bB]", "")) * 1000000000
    end
    return tonumber(cleaned) or 0
end

local function GetCurrency(currencyType)
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return 0 end
    local screenGui = gui:FindFirstChild("ScreenGui")
    if not screenGui then return 0 end

    local hud = screenGui:FindFirstChild("HUD")
    if not hud or not hud:FindFirstChild("Left") then return 0 end
    local currencyFrame = hud.Left:FindFirstChild("Currency")
    if not currencyFrame then return 0 end

    local label
    if currencyType == "coins" then
        if currencyFrame:FindFirstChild("Coins") and currencyFrame.Coins:FindFirstChild("Frame") then
            label = currencyFrame.Coins.Frame:FindFirstChild("Label")
        end
    elseif currencyType == "gems" then
        if currencyFrame:FindFirstChild("Gems") and currencyFrame.Gems:FindFirstChild("Frame") then
            label = currencyFrame.Gems.Frame:FindFirstChild("Label")
        end
    elseif currencyType == "tokens" then
        if currencyFrame:FindFirstChild("Tokens") and currencyFrame.Tokens:FindFirstChild("Frame") then
            label = currencyFrame.Tokens.Frame:FindFirstChild("Label")
        end
    end

    if not label or not label:IsA("TextLabel") then
        return 0
    end
    return ParseCurrency(label.Text)
end

local function UpdateCurrencies()
    BubbleStats.Coins  = GetCurrency("coins")
    BubbleStats.Gems   = GetCurrency("gems")
    BubbleStats.Tokens = GetCurrency("tokens")
end --License Owned by Project Lunar ( nesa ), dont skid hahahahaahaha

--------------------------------
-- ISLAND UNLOCK SYSTEM
--------------------------------
-- Safe access to "Rendered.Generic"
local function SafeGeneric()
    if workspace:FindFirstChild("Rendered") and workspace.Rendered:FindFirstChild("Generic") then
        return workspace.Rendered.Generic
    end
    return nil
end

local function IsIslandUnlocked(displayName)
    local rg = SafeGeneric()
    if not rg then return false end
    local disp = rg:FindFirstChild(displayName)
    if not disp then return false end

    local displayPart = disp:FindFirstChild("Display")
    if not displayPart then return false end

    -- If it's Crimson or (177,0,0) => locked
    if displayPart.BrickColor == BrickColor.new("Crimson") or
       (displayPart:IsA("BasePart") and displayPart.Color == Color3.fromRGB(177, 0, 0)) then
        return false
    end
    return true
end

local Islands = {
    {
        Name = "Floating Island",
        Hitbox = workspace.Worlds["The Overworld"].Islands["Floating Island"].Island.UnlockHitbox
    },
    {
        Name = "Outer Space",
        Hitbox = workspace.Worlds["The Overworld"].Islands["Outer Space"].Island.UnlockHitbox
    },
    {
        Name = "Twilight",
        Hitbox = workspace.Worlds["The Overworld"].Islands.Twilight.Island.UnlockHitbox
    },
    {
        Name = "The Void",
        Hitbox = workspace.Worlds["The Overworld"].Islands["The Void"].Island.UnlockHitbox
    },
    {
        Name = "Zen",
        Hitbox = workspace.Worlds["The Overworld"].Islands.Zen.Island.UnlockHitbox
    }
}

local function FastTeleport(cf)
    if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
        LocalPlayer.Character:SetPrimaryPartCFrame(cf)
        task.wait(0.3)
    end
end --License Owned by Project Lunar ( nesa ), dont skid hahahahaahaha

local MaxHatchAttempts = 100  -- Hatch 100 times per egg before moving to next
local ESpamDuration = 2       -- Duration (in seconds) to spam the "E" key per hatch cycle
local HatchDistance = 10      -- Threshold distance (in studs) to consider arrived at egg

-- SpamEKey sends key events for the "E" key for a specific duration
local function SpamEKey(duration)
    local startTime = tick()
    while (tick() - startTime) < duration do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.05)
    end
end

-- Reliable character loading function
local function WaitForCharacter()
    if not player.Character or not player.Character.Parent then
        player.CharacterAdded:Wait()
    end
    local char = player.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")
    return char, hrp, humanoid
end

-- Move to target position
local function MoveToPosition(targetPos, distanceThreshold)
    local _, hrp, humanoid = WaitForCharacter()
    humanoid:MoveTo(targetPos)

    -- Wait until we get within distance threshold
    while (hrp.Position - targetPos).Magnitude > (distanceThreshold or 5) do
        RunService.Stepped:Wait()
    end

    print("Arrived at position:", targetPos)
end

local TeleportService = game:GetService("TeleportService")

local function AttemptUnlock(island)
    for attempt = 1, getgenv().Config.IslandUnlockAttempts do
        print(string.format("Attempt %d/%d for %s", attempt, getgenv().Config.IslandUnlockAttempts, island.Name))
        FastTeleport(island.Hitbox.CFrame)
        task.wait(1)
        if IsIslandUnlocked(island.Name) then
            print(island.Name .. " is unlocked!")
            AddAction("Unlocked Island: " .. island.Name)
            return true
        end
    end
    AddAction("Failed to unlock: " .. island.Name)
    return false
end

local function AutoUnlockIslands()
    while getgenv().Config.AutoUnlockIslands do
        AddAction("Checking & Unlocking Islands...")

        local unlockedThisSession = 0

        for _, island in ipairs(Islands) do
            if not IsIslandUnlocked(island.Name) then
                local success = AttemptUnlock(island)
                if success then
                    unlockedThisSession += 1
                end
            else
                print(island.Name .. " is already unlocked.")
            end
        end

        -- Count how many are unlocked total
        local discovered = 0
        local rg = SafeGeneric()
        if rg then
            for _, island in ipairs(Islands) do
                if IsIslandUnlocked(island.Name) then
                    discovered += 1
                end
            end
        end
        BubbleStats.IslandsDiscovered = discovered

        -- If all unlocked and at least one was just unlocked now → rejoin
        if discovered == #Islands and unlockedThisSession > 0 then
            AddAction("✅ All islands unlocked this session. Rejoining once to fix movement...")
            task.wait(2)
            TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
            break
        end

        task.wait(60)
    end
end


--------------------------------
-- AUTO BUBBLE FARM
--------------------------------
local function AutoBlowBubble()
    local lastUpdate = tick()
    local bubblesBlown = 0
    while getgenv().Config.AutoBlowBubble do
        RemoteEvent:FireServer("BlowBubble")
        bubblesBlown += 1
        if tick() - lastUpdate >= 1 then
            BubbleStats.BubbleRate = bubblesBlown * 60
            bubblesBlown = 0
            lastUpdate = tick()
            AddAction("Blowing bubbles...")
        end
        task.wait(0.05)
    end
end

local function AutoSellBubble()
    while getgenv().Config.AutoSellBubble do
        RemoteEvent:FireServer("SellBubble")
        AddAction("Selling bubbles...")
        task.wait(getgenv().Config.SellInterval)
    end
end

--------------------------------
-- AUTO BUY GUM/FLAVORS
--------------------------------
local function AutoBuyGum()
    while getgenv().Config.AutoBuyGum do
        UpdateCurrencies()
        local coins = BubbleStats.Coins
        -- Find the most expensive gum + flavor user can afford
        local bestGum, bestFlavor = nil, nil

        for gumName, price in pairs(StorageGum) do
            if coins >= price then
                if not bestGum or price > StorageGum[bestGum] then
                    bestGum = gumName
                end
            end --License Owned by Project Lunar ( nesa ), dont skid hahahahaahaha
        end
        for flavorName, price in pairs(GumFlavors) do
            if coins >= price then
                if not bestFlavor or price > GumFlavors[bestFlavor] then
                    bestFlavor = flavorName
                end
            end
        end
        -- Purchase if found
        if bestGum then
            RemoteEvent:FireServer("GumShopPurchase", bestGum)
            BubbleStats.CurrentBubble = bestGum
            AddAction("Purchased gum: " .. bestGum)
            task.wait(0.5)
        end
        if bestFlavor then
            RemoteEvent:FireServer("GumShopPurchase", bestFlavor)
            BubbleStats.CurrentFlavor = bestFlavor
            AddAction("Purchased flavor: " .. bestFlavor)
            task.wait(0.5)
        end
        -- Wait 10 seconds before re-checking
        task.wait(10)
    end
end

--------------------------------
-- AUTO HATCH EGGS
--------------------------------

-- 🧠 Helper: Get best multipliers from inventory
local function GetBestPetMultipliers()
    local best = {
        Bubble = 0,
        Coin = 0,
        Gem = 0
    }
    local pets = LocalPlayer:FindFirstChild("Pets")
    if pets then
        for _, pet in pairs(pets:GetChildren()) do
            local b = pet:FindFirstChild("Bubble") and tonumber(pet.Bubble.Value) or 0
            local c = pet:FindFirstChild("Coin") and tonumber(pet.Coin.Value) or 0
            local g = pet:FindFirstChild("Gem") and tonumber(pet.Gem.Value) or 0
            if b > best.Bubble then best.Bubble = b end
            if c > best.Coin then best.Coin = c end
            if g > best.Gem then best.Gem = g end
        end
    end
    return best
end

-- 🥚 Updated AutoHatchEggs with multiplier logic
local function AutoHatchEggs()
    local function SafeMoveTo(position)
        local _, hrp, humanoid = WaitForCharacter()
        humanoid:MoveTo(position)
        while (hrp.Position - position).Magnitude > (getgenv().Config.HatchDistance or 10) do
            task.wait(0.1)
        end
    end

    local orderToUse, infinite
    if getgenv().Config.SetDefaultEggToHatch then
        orderToUse, infinite = GetDefaultEggOrder()
    else
        orderToUse = EggOrder
        infinite = false
    end

    local bestStats = GetBestPetMultipliers()
    print("Best Bubble:", bestStats.Bubble, "| Coin:", bestStats.Coin, "| Gem:", bestStats.Gem)

    for _, eggName in ipairs(orderToUse) do
        local eggData = Eggs[eggName]
        if eggData and eggData.maxMultipliers then
            local max = eggData.maxMultipliers
            if max.Bubble > bestStats.Bubble or max.Coin > bestStats.Coin or max.Gem > bestStats.Gem then
                print("✅ Hatching " .. eggName .. " (Bubble: " .. max.Bubble .. ", Coin: " .. max.Coin .. ", Gem: " .. max.Gem .. ")")
                SafeMoveTo(eggData.pos)
                for i = 1, getgenv().Config.MaxHatchAttempts do
                    SpamEKey(getgenv().Config.ESpamDuration)
                    RemoteEvent:FireServer("EggHatch", eggName)
                    task.wait(0.1)
                end
            else
                print("⚠️ Skipping " .. eggName .. " (Max multipliers too weak)")
            end
        end
    end
    print("🎉 Finished filtered egg hatching.")
end



--------------------------------
-- AUTO EQUIP BEST PETS
--------------------------------
local function AutoEquipBestPets()
    while getgenv().Config.AutoEquipBestPets do
        local success, err = pcall(function()
            RemoteEvent:FireServer("EquipBestPets")
        end)
        if not success then
            warn("EquipBestPets call failed:", err)
        else
            AddAction("Equipping best pets...")
        end
        task.wait(2)
    end
end --License Owned by Project Lunar ( nesa ), dont skid hahahahaahaha

--------------------------------
-- AUTO CLAIM REWARDS
--------------------------------
local function AutoClaimRewards()
    while getgenv().Config.AutoClaimRewards do
        for questNumber = 1, 15 do
            local args = {"ClaimPrize", questNumber}
            local success, err = pcall(function()
                RemoteEvent:FireServer(unpack(args))
            end)
            if success then
                AddAction("Claimed quest: " .. questNumber)
            else
                warn("Failed to claim quest", questNumber, ":", err)
            end
            task.wait(1.5)
        end
        AddAction("Cycle complete. Waiting 2 minutes...")
        task.wait(10)
    end
end

-- Add this inside your AutoHatchEggs function (at the top)
local function IsChestReady(label)
    local text = label and (label.Text or label.ContentText)
    local num = tonumber(text)
    return num and (num <= 3)
end

-- Reuse this logic to check Giant/Void Chest
local function CheckAndClaimChests()
    local generic = workspace:FindFirstChild("Rendered") and workspace.Rendered:FindFirstChild("Generic")
    if not generic then return false end

    local function claim(chestName, cframeList)
        local chest = generic:FindFirstChild(chestName)
        if not chest then return false end
        local label = chest:FindFirstChild("Countdown") and chest.Countdown:FindFirstChild("BillboardGui") and chest.Countdown.BillboardGui:FindFirstChild("Label")
        if IsChestReady(label) then
            print("⚠️ Claiming " .. chestName .. "...")

            if cframeList then
                for _, cf in ipairs(cframeList) do
                    FastTeleport(cf)
                    task.wait(1)
                end
            end

            RemoteEvent:FireServer("ClaimChest", chestName)
            AddAction("Claimed " .. chestName)
            task.wait(1)
            player.Character:BreakJoints() -- reset --License Owned by Project Lunar ( nesa ), dont skid hahahahaahaha
            return true
        end
        return false
    end

    local giantClaimed = claim("Giant Chest", {
        CFrame.new(100.961258, 11.0323887, -103.668503, -0.557912946, 0, 0.829899907, 0, 1, 0, -0.829899907, 0, -0.557912946),
        CFrame.new(17.8845139, 425.281189, 169.2836, 0.90629667, 0, 0.422642082, 0, 1, 0, -0.422642082, 0, 0.90629667)
    })

    local voidClaimed = claim("Void Chest")

    return giantClaimed or voidClaimed
end



-- Function: Auto Upgrade Mastery & Claim Playtime (runs every 10 seconds)
local function AutoUpgradeMasteryAndClaim()
    while true do
        local argsPets = { [1] = "UpgradeMastery", [2] = "Pets" }
        RemoteEvent:FireServer(unpack(argsPets))
        
        local argsBuffs = { [1] = "UpgradeMastery", [2] = "Buffs" }
        RemoteEvent:FireServer(unpack(argsBuffs))
        
        local argsPlaytime = { [1] = "ClaimPlaytime", [2] = 2 }  -- Change the number from 1 to 10 as needed
        RemoteFunction:InvokeServer(unpack(argsPlaytime))
        
        task.wait(2)
    end
end

-- Function: Auto Claim Season (fires every 60 seconds)
local function AutoClaimSeason()
    while true do
        local argsSeason = { [1] = "ClaimSeason" }
        RemoteEvent:FireServer(unpack(argsSeason))
        task.wait(30)
    end
end

local function AutoRedeemCodeOnce()
    -- List of redeem codes (add more codes as needed)
    local codes = {"RELEASE", "THANKS", "LUCKY"}
    
    for _, code in ipairs(codes) do
        local argsRedeem = { [1] = "RedeemCode", [2] = code }
        RemoteFunction:InvokeServer(unpack(argsRedeem))
        print("RedeemCode executed for code: " .. code) --License Owned by Project Lunar ( nesa ), dont skid hahahahaahaha
        task.wait(1)  -- Optional pause between redemptions
    end
end

--------------------------------
-- PERFORMANCE MODE
--------------------------------
local function Disable3DRendering()
    if not getgenv().Config.PerformanceMode then return end
    RunService:Set3dRenderingEnabled(false)
    if workspace.CurrentCamera then
        workspace.CurrentCamera:Destroy()
    end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = 1
        end
    end
end

--------------------------------
-- BYPASS LOADING SCREEN
--------------------------------
local function BypassLoadingScreen()
    local plrGui = LocalPlayer:FindFirstChild("PlayerGui")
    if plrGui then
        local intro = plrGui:FindFirstChild("Intro")
        if intro then
            intro.Enabled = false
            print("Disabled Intro GUI")
        end
        local screenGui = plrGui:FindFirstChild("ScreenGui")
        if screenGui then
            screenGui.Enabled = true
        end
    end
end

--------------------------------
-- MAIN
--------------------------------
local function Main()
    humanoid.WalkSpeed = 40
print("WalkSpeed set to 40")
    BypassLoadingScreen()
    CreateUI()
    Disable3DRendering()

    -- Start concurrent processes --License Owned by Project Lunar ( nesa ), dont skid hahahahaahaha
    if getgenv().Config.AutoUnlockIslands then
        coroutine.wrap(AutoUnlockIslands)()
    end
    if getgenv().Config.AutoBlowBubble then
        coroutine.wrap(AutoBlowBubble)()
    end
    if getgenv().Config.AutoSellBubble then
        coroutine.wrap(AutoSellBubble)()
    end
    if getgenv().Config.AutoBuyGum then
        coroutine.wrap(AutoBuyGum)()
    end
    if getgenv().Config.AutoHatchEggs then
        coroutine.wrap(AutoHatchEggs)()
    end
    if getgenv().Config.AutoEquipBestPets then
        coroutine.wrap(AutoEquipBestPets)()
    end
    if getgenv().Config.AutoClaimRewards then
        coroutine.wrap(AutoClaimRewards)()
    end
    if getgenv().Config.AutoUpgradeMasteryAndClaim then
        coroutine.wrap(AutoUpgradeMasteryAndClaim)() --License Owned by Project Lunar ( nesa ), dont skid hahahahaahaha
    end
    if getgenv().Config.AutoClaimSeason then
        coroutine.wrap(AutoClaimSeason)()
    end

-- Execute the RedeemCode function one time
AutoRedeemCodeOnce()

for _, eggName in ipairs(orderToUse) do
    local eggData = Eggs[eggName]
    if eggData then
        print("Moving to " .. eggName)
        SafeMoveTo(eggData.pos)

        print("Hatching " .. eggName .. "...")
        for i = 1, getgenv().Config.MaxHatchAttempts do
            if CheckAndClaimChests() then
                print("⏳ Waiting for character to reload after chest claim...")
                WaitForCharacter()
                SafeMoveTo(eggData.pos)
                print("Back to hatching: " .. eggName)
            end

            SpamEKey(getgenv().Config.ESpamDuration)
            RemoteEvent:FireServer("EggHatch", eggName)
            print("Hatching " .. eggName .. ": " .. i .. "/" .. getgenv().Config.MaxHatchAttempts)
            task.wait(0.1)
        end
    end
end


    -- Update currency & islands discovered every 2s
    while true do
        UpdateCurrencies()
        BubbleStats.IslandsDiscovered = 0
        local rg = SafeGeneric()
        if rg then
            for _, island in ipairs(Islands) do
                if IsIslandUnlocked(island.Name) then
                    BubbleStats.IslandsDiscovered += 1
                end
            end
        end
        task.wait(0.5)
    end
end

Main()