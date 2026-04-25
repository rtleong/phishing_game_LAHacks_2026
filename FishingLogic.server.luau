--[[
ROBLOX STUDIO SETUP REQUIRED:
  1. Place this script in ServerScriptService (handled by default.project.json via Rojo)
  2. No direct Workspace parts needed — FishingRod.client.luau handles
     click detection on the Water part (see that script's setup note)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes          = ReplicatedStorage:WaitForChild("Remotes")
local bfRollFish       = ReplicatedStorage:WaitForChild("RollFish")
local bfAddToInventory = ReplicatedStorage:WaitForChild("AddToInventory")
local bfGetRodTier     = ReplicatedStorage:WaitForChild("GetRodTier")

local reCastLine  = remotes:WaitForChild("CastLine")
local reCatchFish = remotes:WaitForChild("CatchFish")

local CAST_COOLDOWN = 2  -- seconds after catching before player can cast again

-- Bite delay range at minimum charge (0.0) and maximum charge (1.0).
-- A full-power cast drops bite time significantly and boosts rarity odds.
local BITE_MIN_AT_LOW  = 6   -- slow bite when cast is weak
local BITE_MAX_AT_LOW  = 10
local BITE_MIN_AT_HIGH = 2   -- fast bite when cast is far out
local BITE_MAX_AT_HIGH = 4

-- Rarity bonus: at full charge, this many percentage points are added to the
-- rod's Epic/Legendary weights via a second roll chance.
local MAX_RARITY_BONUS = 0.15  -- 15% extra chance of upgrading rarity at full charge

local pendingCasts  = {}  -- [userId] = true while line is in water
local castCooldowns = {}  -- [userId] = true during post-catch cooldown

-- charge is a 0.0–1.0 value sent by the client representing hold duration
reCastLine.OnServerEvent:Connect(function(player, charge)
	local userId = player.UserId
	if pendingCasts[userId] or castCooldowns[userId] then return end

	-- Clamp charge to valid range (never trust raw client values)
	charge = math.clamp(type(charge) == "number" and charge or 0, 0, 1)

	pendingCasts[userId] = true

	task.spawn(function()
		-- Interpolate bite delay: high charge = shorter wait
		local biteMin = BITE_MIN_AT_LOW  + (BITE_MIN_AT_HIGH - BITE_MIN_AT_LOW)  * charge
		local biteMax = BITE_MAX_AT_LOW  + (BITE_MAX_AT_HIGH - BITE_MAX_AT_LOW)  * charge
		local biteDelay = biteMin + math.random() * (biteMax - biteMin)
		task.wait(biteDelay)

		if not player.Parent then
			pendingCasts[userId] = nil
			return
		end

		local rodTier = bfGetRodTier:Invoke(player)
		local fish    = bfRollFish:Invoke(rodTier)

		-- Rarity bonus: at high charge, re-roll if the fish is Common and
		-- a bonus check passes, giving a second chance at a better fish.
		if charge > 0.5 and fish.rarity == "Common" then
			local bonusRoll = math.random()
			if bonusRoll < MAX_RARITY_BONUS * charge then
				local betterFish = bfRollFish:Invoke(rodTier)
				-- Only keep the re-roll if it actually produced a higher rarity
				local rarityRank = { Common = 1, Rare = 2, Epic = 3, Legendary = 4 }
				if (rarityRank[betterFish.rarity] or 1) > (rarityRank[fish.rarity] or 1) then
					fish = betterFish
				end
			end
		end

		bfAddToInventory:Invoke(player, fish)
		reCatchFish:FireClient(player, fish)

		pendingCasts[userId] = nil
		castCooldowns[userId] = true
		task.wait(CAST_COOLDOWN)
		castCooldowns[userId] = nil
	end)
end)
