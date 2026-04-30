--!strict
--[[
    File:    Characters.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Config.Characters
    Purpose: Стартовые персонажи: оружие, статы, разблокировка.
]]

return {
	warrior = {
		id = "warrior",
		displayName = "Warrior",
		startWeapon = "basic_bolt",
		baseStats = { maxHp = 100, moveSpeed = 16, armor = 2, pickupRadius = 6 },
		unlock = { type = "default" },
	},
	mage = {
		id = "mage",
		displayName = "Mage",
		startWeapon = "basic_bolt",
		baseStats = { maxHp = 80, moveSpeed = 14, armor = 0, pickupRadius = 7 },
		unlock = { type = "level", value = 5 },
	},
	paladin = {
		id = "paladin",
		displayName = "Paladin",
		startWeapon = "aura",
		baseStats = { maxHp = 120, moveSpeed = 13, armor = 4, pickupRadius = 6 },
		unlock = { type = "complete_map", value = "desert_01" },
	},
}
