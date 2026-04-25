
-- Fisherman NPC Wandering Script
-- Makes the Fisherman walk around in a confined area

local fisherman = game.Workspace:FindFirstChild("FishMogger")

if not fisherman then
    warn("FishMogger not found in Workspace")
    return
end

local humanoid = fisherman:FindFirstChild("Humanoid")
local torso = fisherman:FindFirstChild("Torso")

if not humanoid or not torso then
    warn("Fisherman missing Humanoid or Torso")
    return
end

-- Configuration
local WANDER_RADIUS = 15  -- How far from center the fisherman can wander
local MIN_WAIT_TIME = 2    -- Minimum time to wait at each point
local MAX_WAIT_TIME = 5    -- Maximum time to wait at each point
local WALK_SPEED = 8       -- Walking speed (slower for natural feel)

-- Store the center position (starting location)
local centerPosition = torso.Position

-- Set walk speed
humanoid.WalkSpeed = WALK_SPEED

-- Function to get a random point within the wander radius
local function getRandomWanderPoint()
    local angle = math.random() * math.pi * 2
    local distance = math.random() * WANDER_RADIUS
    
    local offsetX = math.cos(angle) * distance
    local offsetZ = math.sin(angle) * distance
    
    return Vector3.new(
        centerPosition.X + offsetX,
        centerPosition.Y,
        centerPosition.Z + offsetZ
    )
end

-- Function to wait for a random amount of time
local function randomWait()
    local waitTime = MIN_WAIT_TIME + math.random() * (MAX_WAIT_TIME - MIN_WAIT_TIME)
    task.wait(waitTime)
end

-- Main wandering loop
task.spawn(function()
    while fisherman and fisherman.Parent do
        -- Get a random destination
        local destination = getRandomWanderPoint()
        
        -- Move to the destination
        humanoid:MoveTo(destination)
        
        -- Wait for the move to complete or timeout
        local moveTimeout = 10  -- Max time to spend walking to a point
        local startTime = tick()
        
        while tick() - startTime < moveTimeout do
            -- Check if we reached the destination or got stuck
            if humanoid.MoveDirection.Magnitude < 0.1 then
                -- Stopped moving, probably reached destination
                break
            end
            task.wait(0.1)
        end
        
        -- Wait at the current position before moving again
        randomWait()
    end
end)

print("Fisherman wandering script started!")