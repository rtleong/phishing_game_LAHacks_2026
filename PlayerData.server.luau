local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for remotes to be created by 0_RemotesSetup
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local function makeRemoteEvent(name)
	local re = remotes:FindFirstChild(name)
	if not re then
		re = Instance.new("RemoteEvent")
		re.Name = name
		re.Parent = remotes
	end
	return re
end

local function makeRemoteFunction(name)
	local rf = remotes:FindFirstChild(name)
	if not rf then
		rf = Instance.new("RemoteFunction")
		rf.Name = name
		rf.Parent = remotes
	end
	return rf
end

-- Get RemoteFunctions
local rfGetData    = makeRemoteFunction("GetPlayerData")
local rfAddCoins   = makeRemoteFunction("AddCoins")
local rfSetRod     = makeRemoteFunction("SetRodTier")
local rfScanFish   = makeRemoteFunction("ScanFish")
local rfPlaceFish  = makeRemoteFunction("PlaceFish")
local rfRemoveFish = makeRemoteFunction("RemoveFish")
local rfPlaceInAquarium = makeRemoteFunction("PlaceInAquarium")
local rfRemoveFromAquarium = makeRemoteFunction("RemoveFromAquariumRF")
local rfGetAquariumValue = makeRemoteFunction("GetAquariumValue")
local rfScanFishByIndex = makeRemoteFunction("ScanFishByIndex")

-- Load fish data from module
local function loadFishData()
	local success, result = pcall(function()
		local fishDataModule = game:GetService("ServerScriptService"):FindFirstChild("FishData")
		if fishDataModule then
			return require(fishDataModule)
		end
		return nil
	end)
	
	if success and result then
		return result
	end
	
	-- Fallback fish data
	return {
		{ name = "Sardine", rarity = "Common", weights = {70, 50, 25}, coinValue = 1 },
		{ name = "Bass", rarity = "Common", weights = {65, 48, 22}, coinValue = 1 },
		{ name = "Trout", rarity = "Rare", weights = {25, 35, 30}, coinValue = 3 },
		{ name = "Salmon", rarity = "Rare", weights = {20, 35, 30}, coinValue = 3 },
		{ name = "Tuna", rarity = "Epic", weights = {5, 15, 30}, coinValue = 8 },
		{ name = "Swordfish", rarity = "Epic", weights = {5, 15, 30}, coinValue = 8 },
		{ name = "Coelacanth", rarity = "Legendary", weights = {1, 3, 12}, coinValue = 20 },
		{ name = "Megalodon", rarity = "Legendary", weights = {0.5, 2, 8}, coinValue = 25 },
	}
end

local FISH_TABLE = loadFishData()
local VIRUS_CHANCE = 0.20

-- Per-player state
local playerData = {}

local function newPlayerData()
	return {
		coins = 0,
		rodTier = 1,
		inventory = {},
		aquarium = {},
	}
end

-- Pick a random fish based on rod tier
local function rollFish(rodTier)
	local totalWeight = 0
	for _, fish in ipairs(FISH_TABLE) do
		totalWeight = totalWeight + (fish.weights[rodTier] or 1)
	end

	local roll = math.random(1, totalWeight)
	local cumulative = 0
	for _, fish in ipairs(FISH_TABLE) do
		cumulative = cumulative + (fish.weights[rodTier] or 1)
		if roll <= cumulative then
			return {
				name = fish.name,
				rarity = fish.rarity,
				coinValue = fish.coinValue,
				isVirus = math.random() < VIRUS_CHANCE,
				isScanned = false,
			}
		end
	end
	return { name = "Sardine", rarity = "Common", coinValue = 1, isVirus = false, isScanned = false }
end

-- Passive coin loop
local function startCoinLoop(player, coinsValue)
	task.spawn(function()
		while player.Parent do
			task.wait(30)
			local data = playerData[player.UserId]
			if not data then break end
			local earned = 0
			for _, fish in ipairs(data.aquarium) do
				if not fish.isVirus then
					earned = earned + fish.coinValue
				end
			end
			if earned > 0 then
				data.coins = data.coins + earned
				coinsValue.Value = data.coins
				remotes.CoinsUpdated:FireClient(player, data.coins)
			end
		end
	end)

	task.spawn(function()
		while player.Parent do
			task.wait(1)
			local data = playerData[player.UserId]
			if not data then break end
			data.coins = data.coins + 1
			coinsValue.Value = data.coins
			remotes.CoinsUpdated:FireClient(player, data.coins)
		end
	end)
end

-- Create leaderstats
local function createLeaderstats(player, initialCoins)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local coinsValue = Instance.new("IntValue")
	coinsValue.Name = "Coins"
	coinsValue.Value = initialCoins
	coinsValue.Parent = leaderstats
	
	return coinsValue
end

-- Player join/leave
Players.PlayerAdded:Connect(function(player)
	playerData[player.UserId] = newPlayerData()
	local coinsValue = createLeaderstats(player, 0)
	startCoinLoop(player, coinsValue)
end)

Players.PlayerRemoving:Connect(function(player)
	playerData[player.UserId] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	playerData[player.UserId] = newPlayerData()
	local coinsValue = createLeaderstats(player, 0)
	startCoinLoop(player, coinsValue)
end

-- RemoteFunction handlers
rfGetData.OnServerInvoke = function(player)
	return playerData[player.UserId]
end

rfAddCoins.OnServerInvoke = function(player, amount)
	local data = playerData[player.UserId]
	if not data then return false end
	data.coins = math.max(0, data.coins + amount)
	
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coinsValue = leaderstats:FindFirstChild("Coins")
		if coinsValue then
			coinsValue.Value = data.coins
		end
	end
	
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

	data.coins = data.coins - price
	data.rodTier = tier
	
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coinsValue = leaderstats:FindFirstChild("Coins")
		if coinsValue then
			coinsValue.Value = data.coins
		end
	end
	
	remotes.CoinsUpdated:FireClient(player, data.coins)
	return true
end

rfScanFish.OnServerInvoke = function(player)
	local data = playerData[player.UserId]
	if not data or #data.inventory == 0 then return nil end
	local fish = data.inventory[1]
	fish.isScanned = true
	return fish
end

rfPlaceFish.OnServerInvoke = function(player, fishIndex)
	local data = playerData[player.UserId]
	if not data then return false end
	fishIndex = fishIndex or 1
	local fish = data.inventory[fishIndex]
	if not fish then return false, "No fish at that index" end
	if not fish.isScanned then return false, "Fish has not been scanned" end
	table.remove(data.inventory, fishIndex)
	table.insert(data.aquarium, fish)
	remotes.AquariumUpdated:FireClient(player, data.aquarium)
	return true
end

rfRemoveFish.OnServerInvoke = function(player, fish)
	local data = playerData[player.UserId]
	if not data then return false end
	table.insert(data.inventory, fish)
	return true
end

rfPlaceInAquarium.OnServerInvoke = function(player, fishIndex)
	local data = playerData[player.UserId]
	if not data then return false, "No player data" end
	fishIndex = fishIndex or 1
	local fish = data.inventory[fishIndex]
	if not fish then return false, "No fish at that index" end
	if not fish.isScanned then return false, "Fish has not been scanned" end
	table.remove(data.inventory, fishIndex)
	table.insert(data.aquarium, fish)
	remotes.AquariumUpdated:FireClient(player, data.aquarium)
	return true, fish
end

rfRemoveFromAquarium.OnServerInvoke = function(player, aquariumIndex)
	local data = playerData[player.UserId]
	if not data or not data.aquarium then
		return false, "No aquarium data"
	end
	local fish = data.aquarium[aquariumIndex]
	if not fish then
		return false, "No fish at that index"
	end
	table.remove(data.aquarium, aquariumIndex)
	table.insert(data.inventory, fish)
	remotes.AquariumUpdated:FireClient(player, data.aquarium)
	return true, fish
end

rfGetAquariumValue.OnServerInvoke = function(player)
	local data = playerData[player.UserId]
	if not data or not data.aquarium then
		return 0
	end
	local totalValue = 0
	for _, fish in ipairs(data.aquarium) do
		totalValue = totalValue + (fish.coinValue or 0)
	end
	return totalValue
end

rfScanFishByIndex.OnServerInvoke = function(player, fishIndex)
	local data = playerData[player.UserId]
	if not data then
		return nil, "No player data found"
	end
	if not fishIndex or fishIndex < 1 or fishIndex > #data.inventory then
		return nil, "Invalid fish index"
	end
	local fish = data.inventory[fishIndex]
	if not fish then
		return nil, "No fish found at that index"
	end
	fish.isScanned = true
	return fish
end

-- BindableFunctions for server-to-server calls
local bfRollFish = Instance.new("BindableFunction")
bfRollFish.Name = "RollFish"
bfRollFish.Parent = ReplicatedStorage
bfRollFish.OnInvoke = function(rodTier)
	return rollFish(rodTier)
end

local bfAddToInventory = Instance.new("BindableFunction")
bfAddToInventory.Name = "AddToInventory"
bfAddToInventory.Parent = ReplicatedStorage
bfAddToInventory.OnInvoke = function(player, fish)
	local data = playerData[player.UserId]
	if not data then return false end
	table.insert(data.inventory, fish)
	return true
end

local bfGetRodTier = Instance.new("BindableFunction")
bfGetRodTier.Name = "GetRodTier"
bfGetRodTier.Parent = ReplicatedStorage
bfGetRodTier.OnInvoke = function(player)
	local data = playerData[player.UserId]
	return data and data.rodTier or 1
end

print("[PlayerData] Initialized successfully!")
