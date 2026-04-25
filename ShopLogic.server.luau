--[[
ROBLOX STUDIO SETUP REQUIRED:
  1. ShopStand
       - A Part (or Model PrimaryPart) named exactly "ShopStand" in Workspace
       - Place it on the pier near the Fish Mogger area
       - Add a ProximityPrompt child:
           ActionText  = "Browse Rods"
           ObjectText  = "Rod Shop"
           MaxDistance = 8
       - Optional: use a free marketplace fishing shop / crate model for visuals
  2. Place this script in ServerScriptService
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes            = ReplicatedStorage:WaitForChild("Remotes")
local reShopOpened       = remotes:WaitForChild("ShopOpened")
local reRodUpgraded      = remotes:WaitForChild("RodUpgraded")

local bfGetRodTier       = ReplicatedStorage:WaitForChild("GetRodTier")
local bfGetCoins         = ReplicatedStorage:WaitForChild("GetCoins")
local bfDeductCoins      = ReplicatedStorage:WaitForChild("DeductCoins")
local bfSetRodTierServer = ReplicatedStorage:WaitForChild("SetRodTierServer")

local shopStand  = workspace:WaitForChild("ShopStand")
local shopPrompt = shopStand:WaitForChild("ProximityPrompt")

local ROD_COSTS = { [1] = 0, [2] = 500, [3] = 2000 }

-- Open shop UI when player presses E at the stand
shopPrompt.Triggered:Connect(function(player)
	local currentTier = bfGetRodTier:Invoke(player)
	local currentCoins = bfGetCoins:Invoke(player)
	reShopOpened:FireClient(player, currentTier, currentCoins)
end)

-- Handle purchase requests from the client
local rePurchaseRod = Instance.new("RemoteEvent")
rePurchaseRod.Name   = "PurchaseRod"
rePurchaseRod.Parent = remotes

rePurchaseRod.OnServerEvent:Connect(function(player, tier)
	if type(tier) ~= "number" or tier < 1 or tier > 3 then return end

	local currentTier = bfGetRodTier:Invoke(player)

	if tier <= currentTier then
		local msg = tier == currentTier and "You already own this rod." or "You own a better rod."
		reRodUpgraded:FireClient(player, false, msg, currentTier)
		return
	end

	local price        = ROD_COSTS[tier]
	local currentCoins = bfGetCoins:Invoke(player)

	if currentCoins < price then
		reRodUpgraded:FireClient(player, false, "Not enough coins! Need " .. price .. ".", currentTier)
		return
	end

	bfDeductCoins:Invoke(player, price)
	bfSetRodTierServer:Invoke(player, tier)

	reRodUpgraded:FireClient(player, true, nil, tier)
end)
