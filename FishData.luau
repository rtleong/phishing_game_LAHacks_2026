--[[
FISH DATA MODULE (Place this in ServerScriptService or as a ModuleScript)
Contains all 50 fish species with their properties:
- name: Fish species name
- rarity: Common, Rare, Epic, or Legendary
- weights: [tier1Weight, tier2Weight, tier3Weight] - spawn rates per rod tier
- coinValue: Coins earned when fish is in aquarium
- model: Asset ID for 3D model (can be customized)
- size: Relative size in aquarium display
- color: Color description for reference
]]

return {
	{ name = "Sardine",       rarity = "Common", weights = {70, 50, 25}, coinValue = 1,  model = "rbxassetid://placeholder_sardine", size = 0.3, color = "Silver" },
	{ name = "Mackerel",      rarity = "Common", weights = {60, 45, 20}, coinValue = 1,  model = "rbxassetid://placeholder_mackerel", size = 0.35, color = "DarkBlue" },
	{ name = "Herring",       rarity = "Common", weights = {65, 48, 22}, coinValue = 1,  model = "rbxassetid://placeholder_herring", size = 0.32, color = "Gray" },
	{ name = "Anchovy",       rarity = "Common", weights = {75, 55, 28}, coinValue = 1,  model = "rbxassetid://placeholder_anchovy", size = 0.25, color = "Green" },
	{ name = "Dace",          rarity = "Common", weights = {68, 52, 24}, coinValue = 1,  model = "rbxassetid://placeholder_dace", size = 0.28, color = "Brown" },
	{ name = "Roach",         rarity = "Common", weights = {62, 46, 21}, coinValue = 1,  model = "rbxassetid://placeholder_roach", size = 0.3, color = "Olive" },
	{ name = "Bleak",         rarity = "Common", weights = {72, 53, 26}, coinValue = 1,  model = "rbxassetid://placeholder_bleak", size = 0.27, color = "WhiteGray" },
	{ name = "Perch",         rarity = "Common", weights = {58, 42, 19}, coinValue = 1,  model = "rbxassetid://placeholder_perch", size = 0.35, color = "GreenBrown" },
	{ name = "ClownFish",     rarity = "Rare",   weights = {25, 35, 30}, coinValue = 3,  model = "rbxassetid://placeholder_clownfish", size = 0.4, color = "Orange" },
	{ name = "Snapper",       rarity = "Rare",   weights = {25, 35, 30}, coinValue = 3,  model = "rbxassetid://placeholder_snapper", size = 0.45, color = "Red" },
	{ name = "Tuna",          rarity = "Rare",   weights = {20, 35, 30}, coinValue = 3,  model = "rbxassetid://placeholder_tuna", size = 0.5, color = "DarkBlue" },
	{ name = "Grouper",       rarity = "Rare",   weights = {22, 32, 28}, coinValue = 3,  model = "rbxassetid://placeholder_grouper", size = 0.48, color = "Brown" },
	{ name = "Flounder",      rarity = "Rare",   weights = {23, 33, 29}, coinValue = 3,  model = "rbxassetid://placeholder_flounder", size = 0.42, color = "Tan" },
	{ name = "Triggerfish",   rarity = "Rare",   weights = {21, 31, 27}, coinValue = 3,  model = "rbxassetid://placeholder_triggerfish", size = 0.38, color = "Yellow" },
	{ name = "Angelfish",     rarity = "Rare",   weights = {26, 36, 31}, coinValue = 3,  model = "rbxassetid://placeholder_angelfish", size = 0.35, color = "Black" },
	{ name = "Parrotfish",    rarity = "Rare",   weights = {24, 34, 30}, coinValue = 3,  model = "rbxassetid://placeholder_parrotfish", size = 0.44, color = "Green" },
	{ name = "Swordfish",     rarity = "Epic",   weights = {5, 15, 30}, coinValue = 8,   model = "rbxassetid://placeholder_swordfish", size = 0.7, color = "DarkBlue" },
	{ name = "Anglerfish",    rarity = "Epic",   weights = {3, 12, 28}, coinValue = 8,   model = "rbxassetid://placeholder_anglerfish", size = 0.55, color = "Black" },
	{ name = "Marlin",        rarity = "Epic",   weights = {4, 14, 32}, coinValue = 8,   model = "rbxassetid://placeholder_marlin", size = 0.75, color = "Blue" },
	{ name = "Manta Ray",     rarity = "Epic",   weights = {6, 16, 25}, coinValue = 8,   model = "rbxassetid://placeholder_manta_ray", size = 0.8, color = "Black" },
	{ name = "Barracuda",     rarity = "Epic",   weights = {5, 13, 27}, coinValue = 8,   model = "rbxassetid://placeholder_barracuda", size = 0.68, color = "Silver" },
	{ name = "Hammerhead Shark", rarity = "Epic", weights = {2, 11, 24}, coinValue = 8,  model = "rbxassetid://placeholder_hammerhead", size = 0.85, color = "Gray" },
	{ name = "Electric Eel",  rarity = "Epic",   weights = {4, 12, 26}, coinValue = 8,   model = "rbxassetid://placeholder_electric_eel", size = 0.6, color = "Yellow" },
	{ name = "Piranha",       rarity = "Epic",   weights = {3, 10, 23}, coinValue = 8,   model = "rbxassetid://placeholder_piranha", size = 0.45, color = "Red" },
	{ name = "Stingray",      rarity = "Epic",   weights = {5, 14, 29}, coinValue = 8,   model = "rbxassetid://placeholder_stingray", size = 0.72, color = "Brown" },
	{ name = "Coelacanth",    rarity = "Legendary", weights = {1, 3, 12}, coinValue = 20, model = "rbxassetid://placeholder_coelacanth", size = 0.9, color = "Blue" },
	{ name = "Megalodon",     rarity = "Legendary", weights = {0.5, 2, 8}, coinValue = 25, model = "rbxassetid://placeholder_megalodon", size = 1.2, color = "DarkGray" },
	{ name = "Dragon Fish",   rarity = "Legendary", weights = {0.8, 2.5, 10}, coinValue = 22, model = "rbxassetid://placeholder_dragon_fish", size = 0.95, color = "Red" },
	{ name = "Goblin Shark",  rarity = "Legendary", weights = {0.6, 2.2, 9}, coinValue = 24, model = "rbxassetid://placeholder_goblin_shark", size = 1.0, color = "Pink" },
	{ name = "Golden Koi",    rarity = "Legendary", weights = {1.2, 3.5, 11}, coinValue = 21, model = "rbxassetid://placeholder_golden_koi", size = 0.85, color = "Gold" },
	{ name = "Phoenix Fish",  rarity = "Legendary", weights = {0.7, 2.3, 7}, coinValue = 26, model = "rbxassetid://placeholder_phoenix_fish", size = 1.1, color = "Orange" },
	{ name = "Void Swimmer",  rarity = "Legendary", weights = {0.4, 1.5, 6}, coinValue = 28, model = "rbxassetid://placeholder_void_swimmer", size = 1.15, color = "Purple" },
	{ name = "Luminous Bringer", rarity = "Legendary", weights = {0.5, 1.8, 7.5}, coinValue = 27, model = "rbxassetid://placeholder_luminous", size = 1.05, color = "Cyan" },
	{ name = "Sculpin",       rarity = "Common", weights = {64, 49, 23}, coinValue = 1,  model = "rbxassetid://placeholder_sculpin", size = 0.33, color = "DarkRed" },
	{ name = "Mullet",        rarity = "Common", weights = {66, 51, 25}, coinValue = 1,  model = "rbxassetid://placeholder_mullet", size = 0.36, color = "Gray" },
	{ name = "Catfish",       rarity = "Rare",   weights = {20, 30, 25}, coinValue = 3,  model = "rbxassetid://placeholder_catfish", size = 0.65, color = "Brown" },
	{ name = "Seahorse",      rarity = "Rare",   weights = {19, 29, 26}, coinValue = 3,  model = "rbxassetid://placeholder_seahorse", size = 0.3, color = "Purple" },
	{ name = "Lionfish",      rarity = "Rare",   weights = {21, 31, 27}, coinValue = 3,  model = "rbxassetid://placeholder_lionfish", size = 0.4, color = "Red" },
	{ name = "Pufferfish",    rarity = "Rare",   weights = {20, 30, 26}, coinValue = 3,  model = "rbxassetid://placeholder_pufferfish", size = 0.35, color = "Yellow" },
	{ name = "Moray Eel",     rarity = "Rare",   weights = {18, 28, 24}, coinValue = 3,  model = "rbxassetid://placeholder_moray_eel", size = 0.55, color = "Green" },
	{ name = "Great White Shark", rarity = "Epic", weights = {2, 9, 20}, coinValue = 8,  model = "rbxassetid://placeholder_great_white", size = 0.95, color = "Gray" },
	{ name = "Tiger Shark",   rarity = "Epic",   weights = {3, 10, 22}, coinValue = 8,   model = "rbxassetid://placeholder_tiger_shark", size = 0.88, color = "Gray" },
	{ name = "Venomous Jellyfish", rarity = "Epic", weights = {4, 11, 24}, coinValue = 8, model = "rbxassetid://placeholder_jellyfish", size = 0.5, color = "Pink" },
	{ name = "Angelic Whale", rarity = "Epic",   weights = {1.5, 8, 18}, coinValue = 8,  model = "rbxassetid://placeholder_whale", size = 1.3, color = "Blue" },
	{ name = "Zodiac Starfish", rarity = "Legendary", weights = {0.3, 1, 5}, coinValue = 30, model = "rbxassetid://placeholder_starfish", size = 0.75, color = "Silver" },
	{ name = "Dimensional Maw", rarity = "Legendary", weights = {0.2, 0.8, 4}, coinValue = 32, model = "rbxassetid://placeholder_dimensional", size = 1.25, color = "Black" },
	{ name = "Coral Guardian", rarity = "Legendary", weights = {0.4, 1.2, 6.5}, coinValue = 29, model = "rbxassetid://placeholder_coral", size = 0.92, color = "Pink" },
	{ name = "Starlight Flounder", rarity = "Legendary", weights = {0.6, 1.9, 8}, coinValue = 23, model = "rbxassetid://placeholder_starlight", size = 1.02, color = "Cyan" },
	{ name = "Hidden Leviathan", rarity = "Legendary", weights = {0.1, 0.5, 3}, coinValue = 35, model = "rbxassetid://placeholder_leviathan", size = 1.4, color = "DarkBlue" },
	{ name = "Ancient Sentinel", rarity = "Legendary", weights = {0.15, 0.7, 3.5}, coinValue = 33, model = "rbxassetid://placeholder_sentinel", size = 1.35, color = "Gold" },
}
