--[[
ROBLOX STUDIO SETUP REQUIRED:
  1. Water / Fishing Zone — pick ONE approach:
       Option A (Part):    Add a Part to Workspace named exactly "Water".
                           Set material to Water, make it semi-transparent.
                           Place it at the end of the pier over the ocean.
       Option B (Terrain): Use Roblox Terrain water — the script raycasts for
                           Enum.Material.Water automatically, no extra setup needed.
       Option C (Tag):     Name any part whatever you like, then open the Tag Editor
                           in Studio and add the tag "FishingZone" to it.
  2. This script lives in StarterPlayerScripts (wired via default.project.json / Rojo)

CAST MECHANIC:
  - Hold left-click on water to charge the cast (max 3 seconds).
  - A power bar grows while holding — release to cast.
  - Longer hold = farther cast = shorter bite wait + small rarity bonus.
]]

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse  = player:GetMouse()
local camera = workspace.CurrentCamera

local remotes    = ReplicatedStorage:WaitForChild("Remotes")
local reCastLine = remotes:WaitForChild("CastLine")
local reCatchFish = remotes:WaitForChild("CatchFish")

local MAX_CHARGE_TIME = 3   -- seconds to reach full charge
local CAST_COOLDOWN   = 2   -- must match FishingLogic server value

-- ── State ─────────────────────────────────────────────────────────────────────
local isHolding   = false   -- mouse button currently held over water
local isCasting   = false   -- line is in the water waiting for a bite
local onCooldown  = false
local chargeStart = 0       -- tick() when hold began

-- ── UI root ───────────────────────────────────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name          = "FishingGui"
screenGui.ResetOnSpawn  = false
screenGui.Parent        = player.PlayerGui

-- ── Power bar (shown while holding) ──────────────────────────────────────────
local barBg = Instance.new("Frame")
barBg.Size                   = UDim2.new(0.25, 0, 0.035, 0)
barBg.Position               = UDim2.new(0.375, 0, 0.82, 0)
barBg.BackgroundColor3       = Color3.fromRGB(30, 30, 40)
barBg.BackgroundTransparency = 0.3
barBg.BorderSizePixel        = 0
barBg.Visible                = false
barBg.Parent                 = screenGui

local barBgCorner = Instance.new("UICorner")
barBgCorner.CornerRadius = UDim.new(0, 8)
barBgCorner.Parent       = barBg

local barFill = Instance.new("Frame")
barFill.Size            = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(60, 180, 255)
barFill.BorderSizePixel = 0
barFill.Parent          = barBg

local barFillCorner = Instance.new("UICorner")
barFillCorner.CornerRadius = UDim.new(0, 8)
barFillCorner.Parent       = barFill

local barLabel = Instance.new("TextLabel")
barLabel.Size                 = UDim2.new(1, 0, 1, 0)
barLabel.BackgroundTransparency = 1
barLabel.Font                 = Enum.Font.GothamBold
barLabel.TextColor3           = Color3.new(1, 1, 1)
barLabel.TextScaled           = true
barLabel.Text                 = "HOLD TO CHARGE"
barLabel.ZIndex               = 2
barLabel.Parent               = barBg

-- Power bar label above the bar
local powerLabel = Instance.new("TextLabel")
powerLabel.Size                 = UDim2.new(0.25, 0, 0.04, 0)
powerLabel.Position             = UDim2.new(0.375, 0, 0.775, 0)
powerLabel.BackgroundTransparency = 1
powerLabel.Font                 = Enum.Font.GothamBold
powerLabel.TextColor3           = Color3.fromRGB(180, 230, 255)
powerLabel.TextScaled           = true
powerLabel.Text                 = "Cast Power"
powerLabel.Visible              = false
powerLabel.Parent               = screenGui

-- ── Hint bar ─────────────────────────────────────────────────────────────────
local hintFrame = Instance.new("Frame")
hintFrame.Size                   = UDim2.new(0.4, 0, 0.055, 0)
hintFrame.Position               = UDim2.new(0.3, 0, 0.9, 0)
hintFrame.BackgroundColor3       = Color3.fromRGB(15, 15, 25)
hintFrame.BackgroundTransparency = 0.3
hintFrame.BorderSizePixel        = 0
hintFrame.Parent                 = screenGui

local hintCorner = Instance.new("UICorner")
hintCorner.CornerRadius = UDim.new(0, 10)
hintCorner.Parent       = hintFrame

local hintLabel = Instance.new("TextLabel")
hintLabel.Size                 = UDim2.new(1, 0, 1, 0)
hintLabel.BackgroundTransparency = 1
hintLabel.Font                 = Enum.Font.Gotham
hintLabel.TextColor3           = Color3.fromRGB(200, 220, 255)
hintLabel.TextScaled           = true
hintLabel.Text                 = "Hold click on the water to cast your line!"
hintLabel.Parent               = hintFrame

-- ── Catch popup ───────────────────────────────────────────────────────────────
local RARITY_COLORS = {
	Common    = Color3.fromRGB(200, 200, 200),
	Rare      = Color3.fromRGB(80,  140, 255),
	Epic      = Color3.fromRGB(180, 80,  255),
	Legendary = Color3.fromRGB(255, 200, 50),
}

local catchFrame = Instance.new("Frame")
catchFrame.Size                   = UDim2.new(0.5, 0, 0.11, 0)
catchFrame.Position               = UDim2.new(0.25, 0, 0.38, 0)
catchFrame.BackgroundColor3       = Color3.fromRGB(20, 20, 30)
catchFrame.BackgroundTransparency = 1
catchFrame.BorderSizePixel        = 0
catchFrame.Parent                 = screenGui

local catchCorner = Instance.new("UICorner")
catchCorner.CornerRadius = UDim.new(0, 12)
catchCorner.Parent       = catchFrame

local catchLabel = Instance.new("TextLabel")
catchLabel.Size                 = UDim2.new(1, 0, 1, 0)
catchLabel.BackgroundTransparency = 1
catchLabel.Font                 = Enum.Font.GothamBold
catchLabel.TextColor3           = Color3.new(1, 1, 1)
catchLabel.TextScaled           = true
catchLabel.Text                 = ""
catchLabel.TextWrapped          = true
catchLabel.Parent               = catchFrame

local function showCatchPopup(fish)
	local color = RARITY_COLORS[fish.rarity] or Color3.new(1, 1, 1)
	catchLabel.TextColor3           = color
	catchLabel.Text                 = string.format("[%s] %s caught!\nTake it to the Fish Mogger to scan.", fish.rarity, fish.name)
	catchFrame.BackgroundTransparency = 0.15
	task.delay(5, function()
		catchFrame.BackgroundTransparency = 1
		catchLabel.Text = ""
	end)
end

-- ── Detect water clicks ───────────────────────────────────────────────────────
local function isTargetingWater()
	local target = mouse.Target
	if target then
		if target.Name == "Water"
			or (target.Parent and target.Parent.Name == "Water")
			or target:HasTag("FishingZone") then
			return true
		end
	end
	-- Terrain water raycast fallback
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { player.Character }
	local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)
	if result then
		if result.Material == Enum.Material.Water then return true end
		if result.Instance and result.Instance.Material == Enum.Material.Water then return true end
	end
	return false
end

-- ── Power bar update loop ─────────────────────────────────────────────────────
local function updateBarColor(charge)
	-- Shifts from blue → yellow → red as charge fills
	if charge < 0.5 then
		barFill.BackgroundColor3 = Color3.fromRGB(60, 180, 255):Lerp(Color3.fromRGB(255, 220, 40), charge * 2)
	else
		barFill.BackgroundColor3 = Color3.fromRGB(255, 220, 40):Lerp(Color3.fromRGB(255, 60, 60), (charge - 0.5) * 2)
	end
end

task.spawn(function()
	while true do
		task.wait(0.03)  -- ~30fps update
		if isHolding then
			local elapsed = tick() - chargeStart
			local charge  = math.min(elapsed / MAX_CHARGE_TIME, 1)
			barFill.Size  = UDim2.new(charge, 0, 1, 0)
			updateBarColor(charge)
			if charge >= 1 then
				barLabel.Text = "RELEASE TO CAST!"
			else
				barLabel.Text = "HOLD TO CHARGE"
			end
		end
	end
end)

-- ── Input handling ────────────────────────────────────────────────────────────
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if isCasting or onCooldown or isHolding then return end
	if not isTargetingWater() then return end

	-- Begin charging
	isHolding  = true
	chargeStart = tick()

	barFill.Size  = UDim2.new(0, 0, 1, 0)
	barBg.Visible     = true
	powerLabel.Visible = true
	hintLabel.Text    = "Release to cast!"
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if not isHolding then return end

	local elapsed = tick() - chargeStart
	local charge  = math.min(elapsed / MAX_CHARGE_TIME, 1)

	isHolding = false
	barBg.Visible      = false
	powerLabel.Visible = false

	-- Need at least a tiny charge to register as an intentional cast
	if charge < 0.05 then
		hintLabel.Text = "Hold longer to cast!"
		return
	end

	isCasting = true
	hintLabel.Text = string.format("Cast at %.0f%% power — waiting for a bite...", charge * 100)
	reCastLine:FireServer(charge)
end)

-- ── Catch response ────────────────────────────────────────────────────────────
reCatchFish.OnClientEvent:Connect(function(fish)
	isCasting  = false
	onCooldown = true
	showCatchPopup(fish)
	hintLabel.Text = "Take your fish to the Fish Mogger to scan it!"
	task.delay(CAST_COOLDOWN, function()
		onCooldown = false
		hintLabel.Text = "Hold click on the water to cast your line!"
	end)
end)
