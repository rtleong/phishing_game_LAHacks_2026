--[[
ROBLOX STUDIO SETUP REQUIRED:
  1. Water / Fishing Zone — pick ONE of these approaches:
       Option A (Part):  Add a Part to Workspace named exactly "Water".
                         Set its material to Water and make it semi-transparent.
                         Place it at the end of the pier over the ocean.
       Option B (Terrain): Use Roblox Terrain water. The script raycasts for
                           Enum.Material.Water automatically — no extra setup needed.
       Option C (Tag):   Name any clickable part whatever you like, then open
                         CollectionService in Studio and add the tag "FishingZone" to it.
  2. Place this script in StarterPlayerScripts
]]

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player   = Players.LocalPlayer
local mouse    = player:GetMouse()
local camera   = workspace.CurrentCamera

local remotes     = ReplicatedStorage:WaitForChild("Remotes")
local reCastLine  = remotes:WaitForChild("CastLine")
local reCatchFish = remotes:WaitForChild("CatchFish")

-- UI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishingGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

local function makeLabel(text, color, size)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0.5, 0, 0.12, 0)
	frame.Position = UDim2.new(0.25, 0, 0.38, 0)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	frame.BackgroundTransparency = 0.15
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Text = text
	label.Parent = frame

	return frame, label
end

-- Persistent hint bar at the bottom of the screen
local hintFrame = Instance.new("Frame")
hintFrame.Size = UDim2.new(0.4, 0, 0.06, 0)
hintFrame.Position = UDim2.new(0.3, 0, 0.88, 0)
hintFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
hintFrame.BackgroundTransparency = 0.3
hintFrame.BorderSizePixel = 0
hintFrame.Parent = screenGui

local hintCorner = Instance.new("UICorner")
hintCorner.CornerRadius = UDim.new(0, 10)
hintCorner.Parent = hintFrame

local hintLabel = Instance.new("TextLabel")
hintLabel.Size = UDim2.new(1, 0, 1, 0)
hintLabel.BackgroundTransparency = 1
hintLabel.Font = Enum.Font.Gotham
hintLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
hintLabel.TextScaled = true
hintLabel.Text = "Click the water to cast your line!"
hintLabel.Parent = hintFrame

-- Rarity colors for catch popup
local RARITY_COLORS = {
	Common    = Color3.fromRGB(200, 200, 200),
	Rare      = Color3.fromRGB(80,  140, 255),
	Epic      = Color3.fromRGB(180, 80,  255),
	Legendary = Color3.fromRGB(255, 200, 50),
}

local VIRUS_SUFFIX = " ⚠"  -- appended to fish name if virus (only shown after scan)

-- State
local isCasting   = false
local onCooldown  = false

-- Show a timed popup in the center of the screen
local function showPopup(text, color, duration)
	local frame, label = makeLabel(text, color)
	label.Text = text
	task.delay(duration or 3, function()
		frame:Destroy()
	end)
end

-- Detect if the mouse is clicking on water (parts or terrain)
local function isClickingWater()
	-- First check for parts named "Water" or tagged as "FishingZone"
	local target = mouse.Target
	if target then
		if target.Name == "Water"
			or (target.Parent and target.Parent.Name == "Water")
			or target:HasTag("FishingZone") then
			return true
		end
	end
	
	-- If no part found, check for terrain water using raycasting
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {player.Character} -- Ignore player's character
	
	-- Cast ray from camera through mouse position
	local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
	local rayResult = workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)
	
	if rayResult then
		-- Check if we hit terrain water
		local material = rayResult.Material
		if material == Enum.Material.Water then
			return true
		end
		
		-- Also check if we hit a part that's water
		local hitPart = rayResult.Instance
		if hitPart and (hitPart.Name == "Water" or hitPart.Material == Enum.Material.Water) then
			return true
		end
	end
	
	return false
end

-- Cast attempt on left click
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if isCasting or onCooldown then return end
	if not isClickingWater() then return end

	isCasting = true
	hintLabel.Text = "Line cast... waiting for a bite!"
	reCastLine:FireServer()
end)

-- Server tells us a fish was caught
reCatchFish.OnClientEvent:Connect(function(fish)
	isCasting   = false
	onCooldown  = true

	local color = RARITY_COLORS[fish.rarity] or Color3.new(1, 1, 1)
	local rarityTag = string.format("[%s]", fish.rarity)
	showPopup(rarityTag .. " " .. fish.name .. " caught!\nBring it to the Fish Mogger to scan.", color, 5)

	hintLabel.Text = "Take your fish to the Fish Mogger to scan it!"

	-- Cooldown hint reset
	task.delay(2, function()
		onCooldown = false
		hintLabel.Text = "Click the water to cast your line!"
	end)
end)
