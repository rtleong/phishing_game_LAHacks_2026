--[[
ROBLOX STUDIO SETUP REQUIRED:
  1. ScannerDesk
       - A Part (or Model PrimaryPart) named exactly "ScannerDesk" in Workspace
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
local reScanResult      = remotes:WaitForChild("ScanResult")
local rePlaceFishInTank = remotes:WaitForChild("PlaceFishInTank")

local bfScanFishServer  = ReplicatedStorage:WaitForChild("ScanFishServer")
local bfPlaceFishServer = ReplicatedStorage:WaitForChild("PlaceFishServer")

local scannerDesk    = workspace:WaitForChild("ScannerDesk")
local moggerPrompt   = scannerDesk:WaitForChild("ProximityPrompt")

local aquariumPart   = workspace:WaitForChild("Aquarium")
local aquariumPrompt = aquariumPart:WaitForChild("ProximityPrompt")

local SCAN_DURATION  = 2.5
local scanningActive = {}  -- [userId] = true while scan animation plays

-- Fish Mogger scan
moggerPrompt.Triggered:Connect(function(player)
	if scanningActive[player.UserId] then return end
	scanningActive[player.UserId] = true

	scannerDesk.BrickColor = BrickColor.new("Bright yellow")
	task.wait(SCAN_DURATION)

	local fish = bfScanFishServer:Invoke(player)

	if fish then
		scannerDesk.BrickColor = fish.isVirus
			and BrickColor.new("Bright red")
			or  BrickColor.new("Bright green")
	else
		scannerDesk.BrickColor = BrickColor.new("Medium stone grey")
	end

	reScanResult:FireClient(player, fish)

	task.wait(1.5)
	scannerDesk.BrickColor = BrickColor.new("Medium stone grey")
	scanningActive[player.UserId] = nil
end)

-- Aquarium placement
aquariumPrompt.Triggered:Connect(function(player)
	local ok, result = bfPlaceFishServer:Invoke(player)
	-- result is the fish table on success, or an error string on failure
	rePlaceFishInTank:FireClient(player, ok, ok and result or nil, not ok and result or nil)
end)
