--[[
ROBLOX STUDIO SETUP REQUIRED:
  1. Place this script in ServerScriptService
  2. No direct Workspace parts needed — FishingRod.client.luau handles
     click detection on the Water part (see that script's setup note)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes         = ReplicatedStorage:WaitForChild("Remotes")
local bfRollFish      = ReplicatedStorage:WaitForChild("RollFish")
local bfAddToInventory = ReplicatedStorage:WaitForChild("AddToInventory")
local bfGetRodTier    = ReplicatedStorage:WaitForChild("GetRodTier")

local reCastLine  = remotes:WaitForChild("CastLine")
local reCatchFish = remotes:WaitForChild("CatchFish")

local CAST_COOLDOWN = 2   -- seconds after catching before player can cast again
local BITE_MIN      = 3   -- min seconds until a fish bites
local BITE_MAX      = 8   -- max seconds until a fish bites

local pendingCasts  = {}  -- [userId] = true while line is in water
local castCooldowns = {}  -- [userId] = true during post-catch cooldown

reCastLine.OnServerEvent:Connect(function(player)
	local userId = player.UserId

	-- Ignore if already casting or on cooldown
	if pendingCasts[userId] or castCooldowns[userId] then return end

	pendingCasts[userId] = true

	task.spawn(function()
		-- Random bite delay
		local biteDelay = math.random(BITE_MIN * 10, BITE_MAX * 10) / 10
		task.wait(biteDelay)

		-- Player may have left during the wait
		if not player.Parent then
			pendingCasts[userId] = nil
			return
		end

		local rodTier = bfGetRodTier:Invoke(player)
		local fish    = bfRollFish:Invoke(rodTier)

		bfAddToInventory:Invoke(player, fish)

		-- Notify client so the catch UI can display
		reCatchFish:FireClient(player, fish)

		pendingCasts[userId] = nil

		castCooldowns[userId] = true
		task.wait(CAST_COOLDOWN)
		castCooldowns[userId] = nil
	end)
end)
