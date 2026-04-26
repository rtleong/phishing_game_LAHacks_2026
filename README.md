# Fishing & Aquarium Simulator - LAHacks 2026

A relaxing fishing and aquarium simulator where players catch and collect fish while protecting their digital collection from malware and social engineering scams.

## 🎣 Fish System Features

### 50 Unique Fish Species
The game now includes 50 different fish with varying rarities:
- **Common (8 species)**: Sardine, Mackerel, Herring, Anchovy, Dace, Roach, Bleak, Perch, Sculpin, Mullet
- **Rare (16 species)**: ClownFish, Snapper, Tuna, Grouper, Flounder, Triggerfish, Angelfish, Parrotfish, Catfish, Seahorse, Lionfish, Pufferfish, Moray Eel, and 3 more
- **Epic (12 species)**: Swordfish, Anglerfish, Marlin, Manta Ray, Barracuda, Hammerhead Shark, Electric Eel, Piranha, Stingray, Great White Shark, Tiger Shark, and more
- **Legendary (14 species)**: Coelacanth, Megalodon, Dragon Fish, Goblin Shark, Golden Koi, Phoenix Fish, Void Swimmer, and more mythical creatures

Each fish has:
- **Name**: Unique species identifier
- **Rarity**: Affects spawn rates and coin values
- **Model Asset ID**: Reference to 3D model
- **Color**: Visual description
- **Size**: Relative scale in aquarium
- **Coin Value**: Passive income when in aquarium

### Aquarium System
- 📦 **Inventory System**: Automatically stores caught fish
- 🐠 **Aquarium Display**: Visual management interface for your collection
- 🔍 **Scan Fish**: Check if caught fish are viruses before placing in aquarium
- 💰 **Passive Income**: Fish in aquarium generate coins based on their rarity level
- 🎣 **Catch & Release**: Move fish between inventory and aquarium

### Fishing Mechanics
- **Rod Tiers**: Common, Silver, Gold rods with different fish chances
- **Charge System**: Longer cast = shorter bite time = better rarity chances
- **Rarity Bonus**: Full charge casts get extra rolls for epic/legendary fish at Common drops

## 📂 File Structure

### Core Scripts
- **PlayerData.server.luau**: Manages player state, inventory, aquarium, coins, and all remote handlers
- **FishingLogic.server.luau**: Handles the fishing cast mechanics and fish spawning
- **FishData.luau**: Module containing all 50 fish definitions (place in ServerScriptService)

### New Aquarium System Scripts
- **AquariumLogic.server.luau**: Server-side aquarium data management and remote handlers
- **AquariumDisplay.client.luau**: Client-side aquarium UI with fish visualization
- **InventoryGui.client.luau**: Inventory interface for managing caught fish

### GUI Scripts
- **MoggerGui.client.luau**: Main game UI for scan results
- **ShopGui.client.luau**: Shop interface for rod upgrades
- **ScammerGui.client.luau**: Scammer interaction UI

### Utility Scripts
- **FishingRod.client.luau**: Fishing rod interaction mechanics
- **ScannerLogic.server.luau**: Fish scanning system for virus detection
- **ScammerAI.server.luau**: Scammer AI system
- **ShopLogic.server.luau**: Shop purchase system

## 🚀 Setup Instructions

### 1. Import All Scripts
Place the following files in your Roblox game:
- Core server scripts in **ServerScriptService**
- Client scripts in **StarterPlayer > StarterCharacterScripts** or **StarterPlayer > StarterPlayer Scripts**
- FishData.luau as a **ModuleScript** in **ServerScriptService**

### 2. Create Remote Events/Functions
All remotes are automatically created by PlayerData.server.luau. Required remotes:
```
Remotes (Folder)
├── CastLine (RemoteEvent)
├── CatchFish (RemoteEvent)
├── ScanResult (RemoteEvent)
├── PlaceFishInTank (RemoteEvent)
├── AquariumUpdated (RemoteEvent)
├── RemoveFromAquarium (RemoteEvent)
├── GetPlayerData (RemoteFunction)
├── AddCoins (RemoteFunction)
├── ScanFish (RemoteFunction)
├── PlaceFish (RemoteFunction)
├── PlaceInAquarium (RemoteFunction)
├── RemoveFromAquariumRF (RemoteFunction)
└── GetAquariumValue (RemoteFunction)
```

### 3. Setup Workspace Parts
- **Water Part**: A part named "Water" where players can fish (add this to your workspace)
- Ensure FishingRod.client.luau can detect clicks on the Water part

## 💻 How to Play

### Fishing
1. Click on the water to cast your fishing line
2. Hold longer for better rarity chances (faster bites)
3. Wait for the fish to bite
4. Caught fish automatically go to your inventory

### Inventory Management
1. Open the inventory panel (left side of screen)
2. Click **Scan** to check if a fish is a virus
3. If it's clean (✓ mark), click **Place** to add it to your aquarium
4. If it's a virus (☠️ mark), it will damage other fish if placed

### Aquarium
1. Click the **🐠 Aquarium** button in the top-right
2. View your collection of placed fish
3. See total collection value (coins/minute earned)
4. Click **Release** to move fish back to inventory if needed

### Coins & Upgrades
- Fish in aquarium generate coins passively (based on rarity)
- Visit the shop to upgrade your rod for better fishing
- Better rods have higher chances of catching rare fish

## 🎨 Customization

### Adding Custom Fish Models
1. Create or upload a 3D model for your fish (mesh + texture)
2. Get the Roblox Asset ID (rbxassetid://xxxxx)
3. Edit FishData.luau and update the `model` field:
   ```lua
   { name = "YourFish", rarity = "Rare", weights = {25, 35, 30}, coinValue = 3, 
     model = "rbxassetid://YOUR_ASSET_ID", size = 0.4, color = "Blue" }
   ```

### Adjusting Spawn Weights
The `weights` array controls fish spawn chances for each rod tier:
```lua
weights = {tier1Weight, tier2Weight, tier3Weight}
```
- **Tier 1**: Common Rod (early game)
- **Tier 2**: Silver Rod (mid game)
- **Tier 3**: Gold Rod (late game)

Higher weights = more common spawns. Adjust to balance your economy.

### Changing Coin Values
Modify the `coinValue` field to adjust passive coin generation:
```lua
{ name = "CommonFish", rarity = "Common", coinValue = 1 },    -- 1 coin/30s
{ name = "RareFish",   rarity = "Rare",   coinValue = 3 },    -- 3 coins/30s
{ name = "EpicFish",   rarity = "Epic",   coinValue = 8 },    -- 8 coins/30s
{ name = "LegendaryFish", rarity = "Legendary", coinValue = 20 }, -- 20 coins/30s
```

## 🔧 Technical Details

### Fish Data Structure
```lua
{
  name = "Fish Name",               -- Display name
  rarity = "Common|Rare|Epic|Legendary", -- Determines spawn rarity
  weights = {70, 50, 25},          -- Spawn weights per rod tier
  coinValue = 1,                    -- Coins earned per earning cycle
  model = "rbxassetid://xxxxx",    -- 3D model asset reference
  size = 0.3,                       -- Relative size (0.25-1.4)
  color = "Silver"                  -- Color description
}
```

### Inventory & Aquarium Data
Each player stores:
```lua
playerData = {
  coins = 0,                  -- Current coin balance
  rodTier = 1,               -- Current rod (1-3)
  inventory = {},            -- Uncaught fish awaiting scanning
  aquarium = {}              -- Fish in the aquarium (earning coins)
}
```

### Remote Events/Functions Reference

#### Server → Client Events
- **CatchFish**: Fired when player catches a fish
- **ScanResult**: Fired when fish scanning completes
- **AquariumUpdated**: Fired when aquarium contents change
- **CoinsUpdated**: Fired when coins change
- **VirusSpread**: Fired when virus damages a fish

#### Client → Server Functions
- **GetPlayerData()**: Returns player's inventory + aquarium data
- **ScanFish()**: Scans first inventory fish for viruses
- **PlaceFish(index)**: Moves scanned fish to aquarium
- **PlaceInAquarium(index)**: Alternative aquarium placement
- **RemoveFromAquariumRF(index)**: Moves fish back to inventory
- **GetAquariumValue()**: Returns total collection value

## 📊 Spawn Rate Probabilities

### Common Rod (Tier 1)
- Common: ~70% chance
- Rare: ~25% chance
- Epic: ~5% chance
- Legendary: ~1% chance

### Silver Rod (Tier 2)
- Common: ~50% chance
- Rare: ~35% chance
- Epic: ~13% chance
- Legendary: ~3% chance

### Gold Rod (Tier 3)
- Common: ~25% chance
- Rare: ~30% chance
- Epic: ~30% chance
- Legendary: ~12% chance

## 🐛 Troubleshooting

**Inventory not showing fish?**
- Make sure AquariumDisplay.client.luau and InventoryGui.client.luau are in StarterPlayer scripts
- Check that GetPlayerData remote function exists

**Aquarium not displaying?**
- Verify all remotes are created in ReplicatedStorage > Remotes
- Check that FishData.luau is a ModuleScript in ServerScriptService

**Fish not spawning with correct rarity?**
- Check FishData.luau weights are numeric (not strings)
- Verify rod tier is between 1-3

**Can't place fish in aquarium?**
- Fish must be scanned first (click Scan button)
- Only non-virus fish can be placed
- Fish automatically go to inventory when caught
