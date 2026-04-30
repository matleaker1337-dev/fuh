--!strict
--[[
    File:    Maps.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Config.Maps
    Purpose: Декларативный список карт. Доступен и серверу, и клиенту.
             См. PLAN §2.
]]

return {
	forest_01 = {
		id = "forest_01",
		displayName = "Old Forest",
		difficulty = 1,
		unlockRequirement = { type = "level", value = 1 },
		duration = 900,
		spawnTable = "forest_basic",
		bossSchedule = { [300] = "brute", [600] = "treant" },
		modelName = "Forest01",
		spawnRadius = 80,
	},
	desert_01 = {
		id = "desert_01",
		displayName = "Burning Sands",
		difficulty = 2,
		unlockRequirement = { type = "complete_map", value = "forest_01" },
		duration = 900,
		spawnTable = "desert_basic",
		bossSchedule = { [300] = "scorpion_king", [900] = "sand_wraith" },
		modelName = "Desert01",
		spawnRadius = 120,
	},
}
