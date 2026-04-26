--[[
ROBLOX STUDIO SETUP REQUIRED:
  1. FishMogger
       - A Part (or Model PrimaryPart) named exactly "FishMogger" in Workspace
       - Add a ProximityPrompt child:
           ActionText  = "Scan Fish"
           ObjectText  = "Fish Mogger"
           MaxDistance = 8
  2. Aquarium
       - A Part (or Model PrimaryPart) named exactly "Aquarium" in Workspace
       - Add a ProximityPrompt child:
           ActionText  = "Place Fish"
           ObjectText  = "Aquarium"
           MaxDistance = 8
  3. Place this script in ServerScriptService
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes           = ReplicatedStorage:WaitForChild("Remotes")
local reScanResult       = remotes:WaitForChild("ScanResult")
local reOpenAquariumMenu = remotes:WaitForChild("OpenAquariumMenu")

local bfScanFishServer  = ReplicatedStorage:WaitForChild("ScanFishServer")

local fishMogger     = workspace:WaitForChild("FishMogger")
local moggerPrompt   = fishMogger:WaitForChild("ProximityPrompt")

local aquariumPart   = workspace:WaitForChild("Aquarium")
local aquariumPrompt = aquariumPart:WaitForChild("ProximityPrompt")

local SCAN_DURATION  = 2.5
local scanningActive = {}  -- [userId] = true while scan animation plays

-- Fish Mogger scan
moggerPrompt.Triggered:Connect(function(player)
	if scanningActive[player.UserId] then return end
	scanningActive[player.UserId] = true

	fishMogger.BrickColor = BrickColor.new("Bright yellow")
	task.wait(SCAN_DURATION)

	local fish = bfScanFishServer:Invoke(player)

	if fish then
		fishMogger.BrickColor = fish.isVirus
			and BrickColor.new("Bright red")
			or  BrickColor.new("Bright green")
	else
		fishMogger.BrickColor = BrickColor.new("Medium stone grey")
	end

	reScanResult:FireClient(player, fish)

	task.wait(1.5)
	fishMogger.BrickColor = BrickColor.new("Medium stone grey")
	scanningActive[player.UserId] = nil
end)

-- Aquarium: open fish-picker on the client so the player can choose which fish to place
aquariumPrompt.Triggered:Connect(function(player)
	reOpenAquariumMenu:FireClient(player)
end)
