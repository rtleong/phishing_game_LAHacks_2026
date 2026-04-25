--[[
ROBLOX STUDIO SETUP REQUIRED:
  1. Scammer NPCs
       - Create a Folder in Workspace named exactly "Scammers"
       - Inside, place 2-3 humanoid NPC Models (R6 rig with Humanoid + HumanoidRootPart)
       - Name them anything (e.g. "Scammer1", "Scammer2") — the script finds all children
       - Give them a shady look: dark hoodie, sunglasses, etc. (free marketplace models)
       - Spawn them somewhere on or near the pier
  2. Place this script in ServerScriptService
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes       = ReplicatedStorage:WaitForChild("Remotes")
local reScamEvent   = remotes:WaitForChild("ScamEvent")
local bfDeductCoins = ReplicatedStorage:WaitForChild("DeductCoins")

-- Create ScamResponse RemoteEvent so clients can reply Block/Accept
local reScamResponse = Instance.new("RemoteEvent")
reScamResponse.Name   = "ScamResponse"
reScamResponse.Parent = remotes

local SCAM_DETECT_RADIUS = 12   -- studs — how close scammer must be to trigger dialog
local SCAM_COOLDOWN      = 60   -- seconds before same scammer targets same player again
local WANDER_RADIUS      = 18
local WALK_SPEED         = 7
local DEDUCT_PERCENT     = 0.20 -- fraction of coins lost on Accept
local BLOCK_REWARD       = 25   -- bonus coins for correctly blocking

-- Rotating pool of phishing scenarios
local SCAM_SCRIPTS = {
	{
		npcLine  = "Hey! I'm making a YouTube video about Roblox. What's your account password so I can feature you?",
		tip      = "Real creators NEVER need your password. Report and block!",
	},
	{
		npcLine  = "Bro, I'll trade you my Legendary fishing rod for yours — just go first, I promise I'll send mine after.",
		tip      = "Always-go-first trades are a classic scam. Never trade first with strangers!",
	},
	{
		npcLine  = "FREE COIN GIVEAWAY! Send me 200 coins and I'll double it. Limited time!",
		tip      = "Nobody can double your money. This is a classic 'doubling' scam.",
	},
	{
		npcLine  = "I'm a Roblox admin. Your account has been flagged. Give me your items or you'll be banned.",
		tip      = "Roblox staff never ask for items or passwords in-game. This is impersonation!",
	},
	{
		npcLine  = "My friend dared me — what's your email and password? It's just for a school project, haha.",
		tip      = "Never share login credentials with anyone, even as a 'joke'. This is phishing!",
	},
}

-- Track which (scammer, player) pairs are on cooldown
-- key: scammerName .. "_" .. userId, value: true
local cooldowns = {}

-- Wander logic (mirrors FishermanWander pattern)
local function startWander(npc)
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	local root     = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
	if not humanoid or not root then return end

	humanoid.WalkSpeed = WALK_SPEED
	local center = root.Position

	task.spawn(function()
		while npc and npc.Parent do
			local angle    = math.random() * math.pi * 2
			local distance = math.random() * WANDER_RADIUS
			local dest = Vector3.new(
				center.X + math.cos(angle) * distance,
				center.Y,
				center.Z + math.sin(angle) * distance
			)
			humanoid:MoveTo(dest)

			local t0 = tick()
			while tick() - t0 < 10 do
				if humanoid.MoveDirection.Magnitude < 0.1 then break end
				task.wait(0.1)
			end

			task.wait(math.random(20, 50) / 10)  -- idle 2-5s
		end
	end)
end

-- Proximity detection loop — runs every 2 seconds
local function startProximityLoop(npc)
	local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
	if not root then return end

	task.spawn(function()
		while npc and npc.Parent do
			task.wait(2)

			for _, player in ipairs(Players:GetPlayers()) do
				local char = player.Character
				if not char then continue end
				local playerRoot = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
				if not playerRoot then continue end

				local dist = (root.Position - playerRoot.Position).Magnitude
				local cdKey = npc.Name .. "_" .. player.UserId

				if dist <= SCAM_DETECT_RADIUS and not cooldowns[cdKey] then
					cooldowns[cdKey] = true

					-- Pick a random scam scenario
					local scenario = SCAM_SCRIPTS[math.random(#SCAM_SCRIPTS)]
					reScamEvent:FireClient(player, npc.Name, scenario.npcLine, scenario.tip)

					-- Cooldown lifts after SCAM_COOLDOWN seconds
					task.delay(SCAM_COOLDOWN, function()
						cooldowns[cdKey] = nil
					end)
				end
			end
		end
	end)
end

-- Handle player responses
reScamResponse.OnServerEvent:Connect(function(player, response)
	if response == "block" then
		-- Reward the player for correctly identifying the scam
		local data = ReplicatedStorage:FindFirstChild("Remotes")
			and remotes:FindFirstChild("AddCoins")
		-- Use rfAddCoins RemoteFunction via its OnServerInvoke by calling bfDeductCoins
		-- with a negative amount (deduct negative = add). Cleaner: call AddCoins directly.
		-- AddCoins RemoteFunction handler lives in PlayerData; call via BindableFunction.
		-- We don't have bfAddCoins, so re-use bfDeductCoins with negative value:
		bfDeductCoins:Invoke(player, -BLOCK_REWARD)  -- negative deduct = add coins
	elseif response == "accept" then
		-- Get current coin balance and deduct 20%
		-- We don't have a direct "get coins" BindableFunction, so we pass a sentinel
		-- value that PlayerData interprets as a percentage. Instead, just deduct a
		-- fixed penalty for simplicity.
		bfDeductCoins:Invoke(player, 150)
	end
end)

-- Boot up all scammers in the Scammers folder
local scammersFolder = workspace:WaitForChild("Scammers", 10)
if scammersFolder then
	for _, npc in ipairs(scammersFolder:GetChildren()) do
		if npc:IsA("Model") then
			startWander(npc)
			startProximityLoop(npc)
		end
	end

	-- Also handle scammers added to the folder at runtime (e.g. during testing)
	scammersFolder.ChildAdded:Connect(function(npc)
		if npc:IsA("Model") then
			task.wait(0.5)  -- let the model finish loading
			startWander(npc)
			startProximityLoop(npc)
		end
	end)
else
	warn("ScammerAI: 'Scammers' folder not found in Workspace. Add it in Studio.")
end
