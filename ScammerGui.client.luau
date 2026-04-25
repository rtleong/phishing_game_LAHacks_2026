--[[
ROBLOX STUDIO SETUP REQUIRED:
  1. Place this script in StarterPlayerScripts
  2. No additional Workspace parts needed — dialog is triggered by ScammerAI proximity detection
]]

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player  = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local reScamEvent    = remotes:WaitForChild("ScamEvent")
local reScamResponse = remotes:WaitForChild("ScamResponse")
local reCoinsUpdated = remotes:WaitForChild("CoinsUpdated")

-- ── UI root ───────────────────────────────────────────────────────────────────
local screenGui = Instance.new("ScreenGui")
screenGui.Name          = "ScammerGui"
screenGui.ResetOnSpawn  = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent        = player.PlayerGui

-- Dim overlay behind dialog
local overlay = Instance.new("Frame")
overlay.Size                   = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3       = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 1
overlay.BorderSizePixel        = 0
overlay.ZIndex                 = 20
overlay.Visible                = false
overlay.Parent                 = screenGui

-- Dialog box
local dialog = Instance.new("Frame")
dialog.Size                   = UDim2.new(0.6, 0, 0.48, 0)
dialog.Position               = UDim2.new(0.2, 0, 0.26, 0)
dialog.BackgroundColor3       = Color3.fromRGB(22, 22, 35)
dialog.BorderSizePixel        = 0
dialog.ZIndex                 = 21
dialog.Visible                = false
dialog.Parent                 = screenGui

local dialogCorner = Instance.new("UICorner")
dialogCorner.CornerRadius = UDim.new(0, 14)
dialogCorner.Parent       = dialog

-- Red warning stripe at top
local stripe = Instance.new("Frame")
stripe.Size            = UDim2.new(1, 0, 0.12, 0)
stripe.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
stripe.BorderSizePixel = 0
stripe.ZIndex          = 22
stripe.Parent          = dialog

local stripeCorner = Instance.new("UICorner")
stripeCorner.CornerRadius = UDim.new(0, 14)
stripeCorner.Parent       = stripe

-- Fix bottom corners of stripe so they're square (merges into dialog body)
local stripeBottomFix = Instance.new("Frame")
stripeBottomFix.Size            = UDim2.new(1, 0, 0.5, 0)
stripeBottomFix.Position        = UDim2.new(0, 0, 0.5, 0)
stripeBottomFix.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
stripeBottomFix.BorderSizePixel = 0
stripeBottomFix.ZIndex          = 22
stripeBottomFix.Parent          = stripe

local warningLabel = Instance.new("TextLabel")
warningLabel.Size                 = UDim2.new(1, 0, 1, 0)
warningLabel.BackgroundTransparency = 1
warningLabel.Font                 = Enum.Font.GothamBold
warningLabel.TextColor3           = Color3.new(1, 1, 1)
warningLabel.TextScaled           = true
warningLabel.Text                 = "⚠  SUSPICIOUS PLAYER APPROACHING"
warningLabel.ZIndex               = 23
warningLabel.Parent               = stripe

-- NPC name label
local npcNameLabel = Instance.new("TextLabel")
npcNameLabel.Size                 = UDim2.new(0.9, 0, 0.12, 0)
npcNameLabel.Position             = UDim2.new(0.05, 0, 0.14, 0)
npcNameLabel.BackgroundTransparency = 1
npcNameLabel.Font                 = Enum.Font.GothamBold
npcNameLabel.TextColor3           = Color3.fromRGB(255, 160, 60)
npcNameLabel.TextScaled           = true
npcNameLabel.TextXAlignment       = Enum.TextXAlignment.Left
npcNameLabel.ZIndex               = 22
npcNameLabel.Parent               = dialog

-- Scam message
local messageLabel = Instance.new("TextLabel")
messageLabel.Size                 = UDim2.new(0.9, 0, 0.32, 0)
messageLabel.Position             = UDim2.new(0.05, 0, 0.27, 0)
messageLabel.BackgroundTransparency = 1
messageLabel.Font                 = Enum.Font.Gotham
messageLabel.TextColor3           = Color3.new(1, 1, 1)
messageLabel.TextScaled           = true
messageLabel.TextWrapped          = true
messageLabel.TextXAlignment       = Enum.TextXAlignment.Left
messageLabel.ZIndex               = 22
messageLabel.Parent               = dialog

-- Educational tip (shown after response)
local tipLabel = Instance.new("TextLabel")
tipLabel.Size                 = UDim2.new(0.9, 0, 0.12, 0)
tipLabel.Position             = UDim2.new(0.05, 0, 0.6, 0)
tipLabel.BackgroundTransparency = 1
tipLabel.Font                 = Enum.Font.GothamItalic
tipLabel.TextColor3           = Color3.fromRGB(140, 200, 140)
tipLabel.TextScaled           = true
tipLabel.TextWrapped          = true
tipLabel.TextXAlignment       = Enum.TextXAlignment.Left
tipLabel.Text                 = ""
tipLabel.ZIndex               = 22
tipLabel.Parent               = dialog

-- Button row
local function makeButton(text, bgColor, xPos)
	local btn = Instance.new("TextButton")
	btn.Size            = UDim2.new(0.42, 0, 0.16, 0)
	btn.Position        = UDim2.new(xPos, 0, 0.8, 0)
	btn.BackgroundColor3 = bgColor
	btn.BorderSizePixel = 0
	btn.Font            = Enum.Font.GothamBold
	btn.TextColor3      = Color3.new(1, 1, 1)
	btn.TextScaled      = true
	btn.Text            = text
	btn.ZIndex          = 22
	btn.Parent          = dialog
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = btn
	return btn
end

local blockBtn  = makeButton("🛡  Block & Report", Color3.fromRGB(40, 160, 80),  0.05)
local acceptBtn = makeButton("✓  Give Item",       Color3.fromRGB(160, 50, 50),  0.53)

-- Outcome card (replaces dialog body momentarily)
local outcomeLabel = Instance.new("TextLabel")
outcomeLabel.Size                 = UDim2.new(0.9, 0, 0.25, 0)
outcomeLabel.Position             = UDim2.new(0.05, 0, 0.35, 0)
outcomeLabel.BackgroundTransparency = 1
outcomeLabel.Font                 = Enum.Font.GothamBold
outcomeLabel.TextScaled           = true
outcomeLabel.TextWrapped          = true
outcomeLabel.Text                 = ""
outcomeLabel.ZIndex               = 22
outcomeLabel.Parent               = dialog

-- ── State ─────────────────────────────────────────────────────────────────────
local dialogOpen    = false
local AUTO_DISMISS  = 15  -- seconds before auto-block if player ignores

local function setDialogVisible(v)
	dialog.Visible  = v
	overlay.Visible = v
	dialogOpen      = v
end

local function showOutcome(text, color, duration)
	messageLabel.Visible = false
	blockBtn.Visible     = false
	acceptBtn.Visible    = false
	outcomeLabel.Text        = text
	outcomeLabel.TextColor3  = color
	outcomeLabel.Visible     = true

	task.delay(duration, function()
		setDialogVisible(false)
		messageLabel.Visible = true
		blockBtn.Visible     = true
		acceptBtn.Visible    = true
		outcomeLabel.Visible = false
		tipLabel.Text        = ""
	end)
end

-- ── Scam event handler ────────────────────────────────────────────────────────
reScamEvent.OnClientEvent:Connect(function(npcName, scamLine, educationalTip)
	if dialogOpen then return end

	npcNameLabel.Text = npcName .. " says:"
	messageLabel.Text = '"' .. scamLine .. '"'
	tipLabel.Text     = ""
	setDialogVisible(true)

	-- Auto-dismiss as block after timeout (fair to AFK players)
	task.delay(AUTO_DISMISS, function()
		if dialogOpen then
			reScamResponse:FireServer("block")
			tipLabel.Text = educationalTip
			showOutcome("You ignored the scammer. Smart move! +" .. 25 .. " coins",
				Color3.fromRGB(80, 200, 120), 3.5)
		end
	end)

	blockBtn.MouseButton1Click:Connect(function()
		if not dialogOpen then return end
		reScamResponse:FireServer("block")
		tipLabel.Text = educationalTip
		showOutcome("Nice! You blocked the scammer and earned +25 coins.\n\n" .. educationalTip,
			Color3.fromRGB(80, 220, 120), 5)
	end)

	acceptBtn.MouseButton1Click:Connect(function()
		if not dialogOpen then return end
		reScamResponse:FireServer("accept")
		tipLabel.Text = educationalTip
		showOutcome("You got scammed! You lost coins.\n\n" .. educationalTip,
			Color3.fromRGB(220, 80, 80), 5)
	end)
end)

-- Flash coin total when updated (so player sees the scam consequence)
local coinDisplay = Instance.new("TextLabel")
coinDisplay.Size                 = UDim2.new(0.2, 0, 0.06, 0)
coinDisplay.Position             = UDim2.new(0.79, 0, 0.02, 0)
coinDisplay.BackgroundColor3     = Color3.fromRGB(20, 20, 30)
coinDisplay.BackgroundTransparency = 0.2
coinDisplay.BorderSizePixel      = 0
coinDisplay.Font                 = Enum.Font.GothamBold
coinDisplay.TextColor3           = Color3.fromRGB(255, 210, 60)
coinDisplay.TextScaled           = true
coinDisplay.Text                 = "🪙 0"
coinDisplay.ZIndex               = 5
coinDisplay.Parent               = screenGui

local coinCorner = Instance.new("UICorner")
coinCorner.CornerRadius = UDim.new(0, 8)
coinCorner.Parent       = coinDisplay

reCoinsUpdated.OnClientEvent:Connect(function(newTotal)
	coinDisplay.Text = "🪙 " .. newTotal
	-- Brief white flash to signal the change
	local orig = coinDisplay.TextColor3
	coinDisplay.TextColor3 = Color3.new(1, 1, 1)
	task.delay(0.3, function()
		coinDisplay.TextColor3 = orig
	end)
end)
