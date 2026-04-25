local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvents/Functions folder
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local function makeRemoteEvent(name)
	local re = Instance.new("RemoteEvent")
	re.Name = name
	re.Parent = remotes
	return re
end

local function makeRemoteFunction(name)
	local rf = Instance.new("RemoteFunction")
	rf.Name = name
	rf.Parent = remotes
	return rf
end

-- Events (server → client notifications)
makeRemoteEvent("CastLine")
makeRemoteEvent("CatchFish")
makeRemoteEvent("ScanResult")
makeRemoteEvent("PlaceFishInTank")
makeRemoteEvent("VirusSpread")
makeRemoteEvent("ScamEvent")
makeRemoteEvent("CoinsUpdated")

-- Functions (client → server requests)
local rfGetData    = makeRemoteFunction("GetPlayerData")
local rfAddCoins   = makeRemoteFunction("AddCoins")
local rfSetRod     = makeRemoteFunction("SetRodTier")
local rfScanFish   = makeRemoteFunction("ScanFish")
local rfPlaceFish  = makeRemoteFunction("PlaceFish")
local rfRemoveFish = makeRemoteFunction("RemoveFish")

-- Fish definitions: name, rarity weight per rod tier, base coin value
-- rodTier 1 = Common Rod, 2 = Silver Rod, 3 = Gold Rod
local FISH_TABLE = {
	{ name = "Sardine",       rarity = "Common", weights = {70, 50, 25}, coinValue = 1  },
	{ name = "Mackerel",      rarity = "Common", weights = {60, 45, 20}, coinValue = 1  },
	{ name = "Snapper",       rarity = "Rare",   weights = {25, 35, 30}, coinValue = 3  },
	{ name = "Tuna",          rarity = "Rare",   weights = {20, 35, 30}, coinValue = 3  },
	{ name = "Swordfish",     rarity = "Epic",   weights = { 5, 15, 30}, coinValue = 8  },
	{ name = "Anglerfish",    rarity = "Epic",   weights = { 3, 12, 28}, coinValue = 8  },
	{ name = "Coelacanth",    rarity = "Legendary", weights = { 1,  3, 12}, coinValue = 20 },
}

local VIRUS_CHANCE = 0.20  -- 20% of caught fish are infected

-- Per-player state
local playerData = {}

local function newPlayerData()
	return {
		coins    = 0,
		rodTier  = 1,         -- 1=Common, 2=Silver, 3=Gold
		inventory = {},        -- fish not yet placed in tank
		aquarium  = {},        -- fish placed in tank
	}
end

-- Pick a random fish based on the player's rod tier
local function rollFish(rodTier)
	local totalWeight = 0
	for _, fish in ipairs(FISH_TABLE) do
		totalWeight += fish.weights[rodTier]
	end

	local roll = math.random(1, totalWeight)
	local cumulative = 0
	for _, fish in ipairs(FISH_TABLE) do
		cumulative += fish.weights[rodTier]
		if roll <= cumulative then
			return {
				name      = fish.name,
				rarity    = fish.rarity,
				coinValue = fish.coinValue,
				isVirus   = math.random() < VIRUS_CHANCE,
				isScanned = false,
			}
		end
	end
	-- Fallback (should never hit)
	return { name = "Sardine", rarity = "Common", coinValue = 1, isVirus = false, isScanned = false }
end

-- Passive coin loop: awards coins every 30s based on aquarium contents
local function startCoinLoop(player)
	task.spawn(function()
		while player.Parent do
			
			
			task.wait(30)
			local data = playerData[player.UserId]
			if not data then break end

			local earned = 0
			local virusFishIndex = nil

			for i, fish in ipairs(data.aquarium) do
				if fish.isVirus then
					virusFishIndex = i
				else
					earned += fish.coinValue
				end
			end

			-- Virus fish deletes one clean fish each tick
			if virusFishIndex then
				for i, fish in ipairs(data.aquarium) do
					if not fish.isVirus then
						table.remove(data.aquarium, i)
						remotes.VirusSpread:FireClient(player, fish.name)
						break
					end
				end
			end

			if earned > 0 then
				data.coins += earned
				remotes.CoinsUpdated:FireClient(player, data.coins)
			end
		end
	end)
end

-- Player join/leave
Players.PlayerAdded:Connect(function(player)
	playerData[player.UserId] = newPlayerData()
	startCoinLoop(player)
end)

Players.PlayerRemoving:Connect(function(player)
	playerData[player.UserId] = nil
end)

-- Seed data for players already in-game when this script loads
for _, player in ipairs(Players:GetPlayers()) do
	playerData[player.UserId] = newPlayerData()
	startCoinLoop(player)
end

-- RemoteFunction handlers

rfGetData.OnServerInvoke = function(player)
	return playerData[player.UserId]
end

rfAddCoins.OnServerInvoke = function(player, amount)
	local data = playerData[player.UserId]
	if not data then return false end
	data.coins = math.max(0, data.coins + amount)
	remotes.CoinsUpdated:FireClient(player, data.coins)
	return data.coins
end

rfSetRod.OnServerInvoke = function(player, tier)
	local data = playerData[player.UserId]
	if not data then return false end
	if tier < 1 or tier > 3 then return false end

	local cost = { 0, 500, 2000 }
	local price = cost[tier]
	if data.coins < price then return false, "Not enough coins" end

	data.coins -= price
	data.rodTier = tier
	remotes.CoinsUpdated:FireClient(player, data.coins)
	return true
end

-- Called by ScannerLogic: marks the first unscanned fish in inventory as scanned
rfScanFish.OnServerInvoke = function(player)
	local data = playerData[player.UserId]
	if not data or #data.inventory == 0 then return nil end

	local fish = data.inventory[1]
	fish.isScanned = true
	return fish  -- caller reads fish.isVirus to show green/red UI
end

-- Move scanned fish from inventory into aquarium
rfPlaceFish.OnServerInvoke = function(player, fishIndex)
	local data = playerData[player.UserId]
	if not data then return false end

	fishIndex = fishIndex or 1
	local fish = data.inventory[fishIndex]
	if not fish then return false, "No fish at that index" end
	if not fish.isScanned then return false, "Fish has not been scanned" end

	table.remove(data.inventory, fishIndex)
	table.insert(data.aquarium, fish)
	return true
end

-- Add a newly caught fish to inventory (called by FishingLogic)
rfRemoveFish.OnServerInvoke = function(player, fish)
	local data = playerData[player.UserId]
	if not data then return false end
	table.insert(data.inventory, fish)
	return true
end

-- Expose rollFish so FishingLogic can call it from the same server context
-- by requiring this module — but since .server scripts aren't requireable,
-- we store it in a shared table on script globals instead.
-- FishingLogic should call rfRemoveFish via server-side direct invocation pattern;
-- for now, expose rollFish through a BindableFunction.
local bfRollFish = Instance.new("BindableFunction")
bfRollFish.Name = "RollFish"
bfRollFish.Parent = ReplicatedStorage

bfRollFish.OnInvoke = function(rodTier)
	return rollFish(rodTier)
end
