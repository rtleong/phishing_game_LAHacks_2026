--[[
RemotesSetup - Creates all RemoteEvents and RemoteFunctions needed for the game
This script MUST run before any client scripts that use these remotes.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create the Remotes folder
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

-- Create all RemoteEvents
makeRemoteEvent("CastLine")
makeRemoteEvent("CatchFish")
makeRemoteEvent("ScanResult")
makeRemoteEvent("PlaceFishInTank")
makeRemoteEvent("VirusSpread")
makeRemoteEvent("ScamEvent")
makeRemoteEvent("CoinsUpdated")
makeRemoteEvent("ShopOpened")
makeRemoteEvent("RodUpgraded")
makeRemoteEvent("AquariumUpdated")
makeRemoteEvent("RemoveFromAquarium")
makeRemoteEvent("FishScanned")
makeRemoteEvent("OpenAquariumMenu")
makeRemoteEvent("ScamResponse")
makeRemoteEvent("PurchaseRod")

-- Create all RemoteFunctions
makeRemoteFunction("GetPlayerData")
makeRemoteFunction("AddCoins")
makeRemoteFunction("SetRodTier")
makeRemoteFunction("ScanFish")
makeRemoteFunction("PlaceFish")
makeRemoteFunction("RemoveFish")
makeRemoteFunction("PlaceInAquarium")
makeRemoteFunction("RemoveFromAquariumRF")
makeRemoteFunction("GetAquariumValue")
makeRemoteFunction("ScanFishByIndex")

print("[RemotesSetup] All remotes created successfully!")
