--[[
AQUARIUM LOGIC SERVER
Thin server layer for aquarium visual feedback.
All data operations (PlaceInAquarium, RemoveFromAquariumRF, GetAquariumValue,
ScanFishByIndex) are handled directly in PlayerData.server.luau via
RemoteFunction handlers. This script only manages the FishScanned visual
feedback event used by the scanner desk animation.

ROBLOX STUDIO SETUP REQUIRED:
  - Aquarium Part in Workspace named "Aquarium" with a ProximityPrompt child
    (already referenced by ScannerLogic.server.luau)
  - Place this script in ServerScriptService
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes      = ReplicatedStorage:WaitForChild("Remotes")
local reFishScanned = remotes:WaitForChild("FishScanned")
local scannerDesk   = workspace:WaitForChild("FishMogger")

-- FishScannerUI fires this to trigger the desk color animation
-- nil argument = scanning in progress (yellow), fish argument = result (red/green)
reFishScanned.OnServerEvent:Connect(function(player, fish)
	if fish == nil then
		-- Scanning started — pulse yellow
		scannerDesk.BrickColor = BrickColor.new("Bright yellow")
	elseif fish and fish.isVirus then
		scannerDesk.BrickColor = BrickColor.new("Bright red")
		task.wait(1.5)
		scannerDesk.BrickColor = BrickColor.new("Medium stone grey")
	else
		scannerDesk.BrickColor = BrickColor.new("Bright green")
		task.wait(1.5)
		scannerDesk.BrickColor = BrickColor.new("Medium stone grey")
	end
end)
