-- 1. Map out your variables (Find the objects)
local workspace = game:GetService("Workspace")
local scannerDesk = workspace:WaitForChild("ScannerDesk")
local prompt = scannerDesk:WaitForChild("ProximityPrompt")

-- 2. Write the Function (The action that will happen)
-- The prompt automatically passes the 'player' who pressed E into the function.
local function onScanTriggered(player)
	-- Print a message to your Output window to test if it works
	print(player.Name .. " is scanning a fish!")
	
	-- Change the desk color to simulate a scan
	scannerDesk.BrickColor = BrickColor.new("Bright green")
	
	-- Wait for 2 seconds
	task.wait(2)
	
	-- Return the desk to its normal color
	scannerDesk.BrickColor = BrickColor.new("Medium stone grey")
end

-- 3. Connect the Event to the Function
-- When the prompt is triggered, run the function we just wrote.
prompt.Triggered:Connect(onScanTriggered)