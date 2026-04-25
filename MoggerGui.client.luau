local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player  = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local reScanResult      = remotes:WaitForChild("ScanResult")
local rePlaceFishInTank = remotes:WaitForChild("PlaceFishInTank")
local reVirusSpread     = remotes:WaitForChild("VirusSpread")

-- ── UI root ──────────────────────────────────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name          = "MoggerGui"
screenGui.ResetOnSpawn  = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent        = player.PlayerGui

-- Fullscreen flash overlay (used for virus/clean flashes)
local flash = Instance.new("Frame")
flash.Size                  = UDim2.new(1, 0, 1, 0)
flash.BackgroundColor3      = Color3.new(1, 1, 1)
flash.BackgroundTransparency = 1
flash.BorderSizePixel       = 0
flash.ZIndex                = 10
flash.Parent                = screenGui

-- Central result card
local card = Instance.new("Frame")
card.Size                  = UDim2.new(0.55, 0, 0.28, 0)
card.Position              = UDim2.new(0.225, 0, 0.36, 0)
card.BackgroundColor3      = Color3.fromRGB(18, 18, 28)
card.BackgroundTransparency = 1  -- hidden by default
card.BorderSizePixel       = 0
card.ZIndex                = 11
card.Parent                = screenGui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 16)
cardCorner.Parent       = card

local resultIcon = Instance.new("TextLabel")
resultIcon.Size                 = UDim2.new(0.18, 0, 1, 0)
resultIcon.Position             = UDim2.new(0, 0, 0, 0)
resultIcon.BackgroundTransparency = 1
resultIcon.Font                 = Enum.Font.GothamBold
resultIcon.TextScaled           = true
resultIcon.ZIndex               = 12
resultIcon.Parent               = card

local resultTitle = Instance.new("TextLabel")
resultTitle.Size                 = UDim2.new(0.82, 0, 0.5, 0)
resultTitle.Position             = UDim2.new(0.18, 0, 0, 0)
resultTitle.BackgroundTransparency = 1
resultTitle.Font                 = Enum.Font.GothamBold
resultTitle.TextColor3           = Color3.new(1, 1, 1)
resultTitle.TextScaled           = true
resultTitle.TextXAlignment       = Enum.TextXAlignment.Left
resultTitle.ZIndex               = 12
resultTitle.Parent               = card

local resultSub = Instance.new("TextLabel")
resultSub.Size                 = UDim2.new(0.82, 0, 0.45, 0)
resultSub.Position             = UDim2.new(0.18, 0, 0.5, 0)
resultSub.BackgroundTransparency = 1
resultSub.Font                 = Enum.Font.Gotham
resultSub.TextColor3           = Color3.fromRGB(190, 200, 220)
resultSub.TextScaled           = true
resultSub.TextXAlignment       = Enum.TextXAlignment.Left
resultSub.ZIndex               = 12
resultSub.Parent               = card

-- ── Helpers ──────────────────────────────────────────────────────────────────
local function fadeFlash(color, peakAlpha, duration)
	flash.BackgroundColor3 = color
	local tweenIn = TweenService:Create(flash,
		TweenInfo.new(duration * 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 - peakAlpha }
	)
	tweenIn:Play()
	tweenIn.Completed:Wait()
	local tweenOut = TweenService:Create(flash,
		TweenInfo.new(duration * 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ BackgroundTransparency = 1 }
	)
	tweenOut:Play()
end

local function showCard(icon, iconColor, title, sub, duration)
	resultIcon.Text       = icon
	resultIcon.TextColor3 = iconColor
	resultTitle.Text      = title
	resultSub.Text        = sub
	card.BackgroundTransparency = 0.1

	task.delay(duration, function()
		card.BackgroundTransparency = 1
		resultIcon.Text  = ""
		resultTitle.Text = ""
		resultSub.Text   = ""
	end)
end

-- ── Scan result handler ───────────────────────────────────────────────────────
reScanResult.OnClientEvent:Connect(function(fish)
	if not fish then
		showCard("?", Color3.fromRGB(180, 180, 180),
			"No fish to scan",
			"Catch a fish first, then bring it here.",
			4)
		return
	end

	if fish.isVirus then
		fadeFlash(Color3.fromRGB(220, 40, 40), 0.55, 1.2)
		showCard("⚠", Color3.fromRGB(255, 80, 80),
			"VIRUS DETECTED — " .. fish.name,
			"This fish is infected! Put it in your tank and watch what happens... or discard it.",
			6)
	else
		fadeFlash(Color3.fromRGB(40, 200, 100), 0.45, 1.0)
		showCard("✓", Color3.fromRGB(80, 220, 120),
			"CLEAN — " .. fish.name,
			"Safe to add to your aquarium. Walk up to your tank and press E.",
			5)
	end
end)

-- ── Aquarium placement handler ────────────────────────────────────────────────
rePlaceFishInTank.OnClientEvent:Connect(function(ok, fish, errMsg)
	if ok and fish then
		showCard("🐟", Color3.fromRGB(100, 180, 255),
			fish.name .. " added to aquarium!",
			string.format("[%s] — earning %d coin%s every 30s",
				fish.rarity, fish.coinValue, fish.coinValue == 1 and "" or "s"),
			4)
	else
		local reason = errMsg or "Something went wrong."
		showCard("✗", Color3.fromRGB(220, 100, 60),
			"Cannot place fish",
			reason,
			4)
	end
end)

-- ── Virus spread handler ──────────────────────────────────────────────────────
reVirusSpread.OnClientEvent:Connect(function(deletedFishName)
	fadeFlash(Color3.fromRGB(180, 0, 200), 0.6, 1.5)
	showCard("💀", Color3.fromRGB(200, 60, 255),
		"FISH DELETED",
		deletedFishName .. " was corrupted and removed from your aquarium by a virus fish!",
		6)
end)
