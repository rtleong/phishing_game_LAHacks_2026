local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function setupLeaderboard(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    
    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 0
    coins.Parent = leaderstats
end

local function giveCoinsPerSecond(player)
    local coins = player:WaitForChild("leaderstats"):WaitForChild("Coins")
    
    while player.Parent do
        wait(1)
        coins.Value += 1
    end
end

Players.PlayerAdded:Connect(function(player)
    setupLeaderboard(player)
    task.spawn(giveCoinsPerSecond, player)
end)