--[[
ROBLOX STUDIO SETUP REQUIRED:
  1. Place this script in StarterPlayerScripts
  2. No additional Workspace parts needed — shop opens via ShopStand ProximityPrompt
     (see ShopLogic.server.luau for the stand setup)
]]

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player  = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local reShopOpened  = remotes:WaitForChild("ShopOpened")
local reRodUpgraded = remotes:WaitForChild("RodUpgraded")
local rePurchaseRod = remotes:WaitForChild("PurchaseRod")
local reCoinsUpdated = remotes:WaitForChild("CoinsUpdated")

-- ── Rod definitions (must match PlayerData weights) ───────────────────────────
local RODS = {
	{ tier = 1, name = "Common Rod",  cost = 0,    color = Color3.fromRGB(180, 130, 80),  desc = "Standard rod. Catches mostly Common fish." },
	{ tier = 2, name = "Silver Rod",  cost = 500,  color = Color3.fromRGB(180, 200, 220), desc = "Better odds for Rare and Epic fish." },
	{ tier = 3, name = "Golden Rod",  cost = 2000, color = Color3.fromRGB(255, 200, 50),  desc = "Best odds. Legendary fish become reachable." },
}

-- ── State ─────────────────────────────────────────────────────────────────────
local currentTier  = 1
local currentCoins = 0
local shopOpen     = false

-- ── UI root ───────────────────────────────────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name           = "ShopGui"
screenGui.ResetOnSpawn   = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent         = player.PlayerGui

-- Dim overlay
local overlay = Instance.new("Frame")
overlay.Size                   = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3       = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 0.5
overlay.BorderSizePixel        = 0
overlay.ZIndex                 = 30
overlay.Visible                = false
overlay.Parent                 = screenGui

-- Shop panel
local panel = Instance.new("Frame")
panel.Size                   = UDim2.new(0.58, 0, 0.62, 0)
panel.Position               = UDim2.new(0.21, 0, 0.19, 0)
panel.BackgroundColor3       = Color3.fromRGB(20, 20, 32)
panel.BorderSizePixel        = 0
panel.ZIndex                 = 31
panel.Visible                = false
panel.Parent                 = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 16)
panelCorner.Parent       = panel

-- Header bar
local header = Instance.new("Frame")
header.Size            = UDim2.new(1, 0, 0.13, 0)
header.BackgroundColor3 = Color3.fromRGB(40, 100, 180)
header.BorderSizePixel = 0
header.ZIndex          = 32
header.Parent          = panel

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent       = header

-- Square off bottom of header
local headerFix = Instance.new("Frame")
headerFix.Size            = UDim2.new(1, 0, 0.5, 0)
headerFix.Position        = UDim2.new(0, 0, 0.5, 0)
headerFix.BackgroundColor3 = Color3.fromRGB(40, 100, 180)
headerFix.BorderSizePixel = 0
headerFix.ZIndex          = 32
headerFix.Parent          = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size                 = UDim2.new(0.85, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font                 = Enum.Font.GothamBold
titleLabel.TextColor3           = Color3.new(1, 1, 1)
titleLabel.TextScaled           = true
titleLabel.Text                 = "🎣  Rod Shop"
titleLabel.ZIndex               = 33
titleLabel.Parent               = header

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size            = UDim2.new(0.1, 0, 0.8, 0)
closeBtn.Position        = UDim2.new(0.88, 0, 0.1, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Font            = Enum.Font.GothamBold
closeBtn.TextColor3      = Color3.new(1, 1, 1)
closeBtn.TextScaled      = true
closeBtn.Text            = "✕"
closeBtn.ZIndex          = 33
closeBtn.Parent          = header

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent       = closeBtn

-- Coins label inside panel
local coinsLabel = Instance.new("TextLabel")
coinsLabel.Size                 = UDim2.new(0.9, 0, 0.08, 0)
coinsLabel.Position             = UDim2.new(0.05, 0, 0.15, 0)
coinsLabel.BackgroundTransparency = 1
coinsLabel.Font                 = Enum.Font.GothamBold
coinsLabel.TextColor3           = Color3.fromRGB(255, 210, 60)
coinsLabel.TextScaled           = true
coinsLabel.TextXAlignment       = Enum.TextXAlignment.Left
coinsLabel.Text                 = "🪙 0"
coinsLabel.ZIndex               = 32
coinsLabel.Parent               = panel

-- Feedback label (purchase result messages)
local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Size                 = UDim2.new(0.9, 0, 0.07, 0)
feedbackLabel.Position             = UDim2.new(0.05, 0, 0.91, 0)
feedbackLabel.BackgroundTransparency = 1
feedbackLabel.Font                 = Enum.Font.GothamItalic
feedbackLabel.TextColor3           = Color3.fromRGB(200, 200, 200)
feedbackLabel.TextScaled           = true
feedbackLabel.TextXAlignment       = Enum.TextXAlignment.Left
feedbackLabel.Text                 = ""
feedbackLabel.ZIndex               = 32
feedbackLabel.Parent               = panel

-- ── Rod card builder ──────────────────────────────────────────────────────────
local rodCards = {}  -- [tier] = { frame, buyBtn, statusLabel }

local function buildRodCard(rod, index)
	local yOffset = 0.25 + (index - 1) * 0.22

	local card = Instance.new("Frame")
	card.Size            = UDim2.new(0.9, 0, 0.19, 0)
	card.Position        = UDim2.new(0.05, 0, yOffset, 0)
	card.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
	card.BorderSizePixel = 0
	card.ZIndex          = 32
	card.Parent          = panel

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 10)
	cardCorner.Parent       = card

	-- Color stripe on the left
	local stripe = Instance.new("Frame")
	stripe.Size            = UDim2.new(0.015, 0, 1, 0)
	stripe.BackgroundColor3 = rod.color
	stripe.BorderSizePixel = 0
	stripe.ZIndex          = 33
	stripe.Parent          = card

	local stripeCorner = Instance.new("UICorner")
	stripeCorner.CornerRadius = UDim.new(0, 6)
	stripeCorner.Parent       = stripe

	-- Rod name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size                 = UDim2.new(0.55, 0, 0.45, 0)
	nameLabel.Position             = UDim2.new(0.04, 0, 0.05, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font                 = Enum.Font.GothamBold
	nameLabel.TextColor3           = rod.color
	nameLabel.TextScaled           = true
	nameLabel.TextXAlignment       = Enum.TextXAlignment.Left
	nameLabel.Text                 = rod.name
	nameLabel.ZIndex               = 33
	nameLabel.Parent               = card

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Size                 = UDim2.new(0.55, 0, 0.42, 0)
	descLabel.Position             = UDim2.new(0.04, 0, 0.52, 0)
	descLabel.BackgroundTransparency = 1
	descLabel.Font                 = Enum.Font.Gotham
	descLabel.TextColor3           = Color3.fromRGB(170, 180, 200)
	descLabel.TextScaled           = true
	descLabel.TextXAlignment       = Enum.TextXAlignment.Left
	descLabel.TextWrapped          = true
	descLabel.Text                 = rod.desc
	descLabel.ZIndex               = 33
	descLabel.Parent               = card

	-- Buy / status button on the right
	local buyBtn = Instance.new("TextButton")
	buyBtn.Size            = UDim2.new(0.3, 0, 0.65, 0)
	buyBtn.Position        = UDim2.new(0.67, 0, 0.175, 0)
	buyBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
	buyBtn.BorderSizePixel = 0
	buyBtn.Font            = Enum.Font.GothamBold
	buyBtn.TextColor3      = Color3.new(1, 1, 1)
	buyBtn.TextScaled      = true
	buyBtn.Text            = rod.cost == 0 and "FREE" or "🪙 " .. rod.cost
	buyBtn.ZIndex          = 33
	buyBtn.Parent          = card

	local buyBtnCorner = Instance.new("UICorner")
	buyBtnCorner.CornerRadius = UDim.new(0, 8)
	buyBtnCorner.Parent       = buyBtn

	buyBtn.MouseButton1Click:Connect(function()
		if not shopOpen then return end
		rePurchaseRod:FireServer(rod.tier)
	end)

	rodCards[rod.tier] = { frame = card, buyBtn = buyBtn }
end

for i, rod in ipairs(RODS) do
	buildRodCard(rod, i)
end

-- ── Card state refresh ────────────────────────────────────────────────────────
local function refreshCards()
	for _, rod in ipairs(RODS) do
		local entry = rodCards[rod.tier]
		if not entry then continue end
		local btn = entry.buyBtn

		if rod.tier < currentTier then
			btn.Text            = "Owned ✓"
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
			btn.Active          = false
		elseif rod.tier == currentTier then
			btn.Text            = "Equipped ✓"
			btn.BackgroundColor3 = Color3.fromRGB(40, 100, 180)
			btn.Active          = false
		elseif currentCoins >= rod.cost then
			btn.Text            = rod.cost == 0 and "FREE" or "🪙 " .. rod.cost
			btn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
			btn.Active          = true
		else
			btn.Text            = "🪙 " .. rod.cost
			btn.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
			btn.Active          = false
		end
	end
	coinsLabel.Text = "🪙 " .. currentCoins
end

-- ── Open / close ──────────────────────────────────────────────────────────────
local function openShop(tier, coins)
	currentTier  = tier
	currentCoins = coins
	feedbackLabel.Text = ""
	refreshCards()
	overlay.Visible = true
	panel.Visible   = true
	shopOpen        = true
end

local function closeShop()
	overlay.Visible = false
	panel.Visible   = false
	shopOpen        = false
end

closeBtn.MouseButton1Click:Connect(closeShop)
overlay.MouseButton1Click:Connect(closeShop)

-- ── Remote handlers ───────────────────────────────────────────────────────────
reShopOpened.OnClientEvent:Connect(function(tier, coins)
	openShop(tier, coins)
end)

reRodUpgraded.OnClientEvent:Connect(function(success, errMsg, newTier)
	if success then
		currentTier = newTier
		feedbackLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
		feedbackLabel.Text = "Purchase successful! New rod equipped."
	else
		feedbackLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
		feedbackLabel.Text = errMsg or "Purchase failed."
	end
	refreshCards()
end)

reCoinsUpdated.OnClientEvent:Connect(function(newTotal)
	currentCoins = newTotal
	if shopOpen then
		refreshCards()
	end
end)
