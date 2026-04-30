--!strict
--[[
    File:    Enemies.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Config.Enemies
    Purpose: Базы данных врагов. Поля интерпретируются EnemyAI и EnemyService.
             См. PLAN §3.

    Поля:
      hp, speed, damage  — базовые статы.
      aiState            — "seek" | "swarm" | "ranged" | "boss_brute" и т.д.
      xp                 — сколько XP даёт за смерть.
      size               — Vector3 размера BasePart (опц.).
      color              — Color3 (опц.).
      isBoss             — флаг для повышенного HP-бара / xp / drop.
      splitOnDeath       — { type = "splitter_mini", count = 3 } (опц.).
]]

return {
	basic_zombie = {
		id = "basic_zombie",
		displayName = "Zombie",
		hp = 35, speed = 8, damage = 8,
		aiState = "seek",
		xp = 1,
		size = Vector3.new(2, 4, 2),
		color = Color3.fromRGB(80, 60, 60),
		assetName = "Zombie",
	},
	fast_skeleton = {
		id = "fast_skeleton",
		displayName = "Skeleton",
		hp = 22, speed = 14, damage = 7,
		aiState = "swarm",
		xp = 2,
		size = Vector3.new(1.8, 3.5, 1.8),
		color = Color3.fromRGB(220, 220, 200),
		assetName = "Skeleton",
	},
	archer_goblin = {
		id = "archer_goblin",
		displayName = "Goblin Archer",
		hp = 25, speed = 6, damage = 8,
		aiState = "ranged",
		rangedRange = { 18, 28 },
		rangedCooldown = 2.0,
		xp = 3,
		size = Vector3.new(1.8, 3.5, 1.8),
		color = Color3.fromRGB(120, 180, 80),
	},
	runner = {
		id = "runner",
		displayName = "Runner",
		hp = 16, speed = 18, damage = 7,
		aiState = "seek",
		xp = 2,
		size = Vector3.new(1.4, 3, 1.4),
		color = Color3.fromRGB(230, 180, 80),
	},
	tank = {
		id = "tank",
		displayName = "Tank",
		hp = 220, speed = 5, damage = 18,
		aiState = "seek",
		xp = 6,
		size = Vector3.new(3, 5.5, 3),
		color = Color3.fromRGB(60, 60, 70),
		assetName = "Tank Zombie",
	},
	splitter = {
		id = "splitter",
		displayName = "Splitter",
		hp = 60, speed = 9, damage = 10,
		aiState = "seek",
		xp = 4,
		size = Vector3.new(2.4, 3.6, 2.4),
		color = Color3.fromRGB(80, 200, 90),
		splitOnDeath = { type = "splitter_mini", count = 3 },
	},
	splitter_mini = {
		id = "splitter_mini",
		displayName = "Spore",
		hp = 12, speed = 13, damage = 5,
		aiState = "swarm",
		xp = 1,
		size = Vector3.new(1.1, 2, 1.1),
		color = Color3.fromRGB(120, 240, 130),
	},
	brute = {
		id = "brute",
		displayName = "Brute (Boss)",
		hp = 3000, speed = 5, damage = 40,
		aiState = "boss_brute",
		xp = 200,
		size = Vector3.new(5, 8, 5),
		color = Color3.fromRGB(180, 50, 50),
		isBoss = true,
		assetName = "Brute",
		chargeRange = 18,
		chargeWindup = 1.0,
		chargeDuration = 0.6,
		chargeSpeedMult = 4,
		chargeCooldown = 2.5,
	},
	treant = {
		id = "treant",
		displayName = "Treant (Boss)",
		hp = 2500, speed = 6, damage = 30,
		aiState = "boss_brute",
		xp = 100,
		size = Vector3.new(5, 8, 5),
		color = Color3.fromRGB(60, 110, 60),
		isBoss = true,
		assetName = "Treant",
		chargeRange = 18,
		chargeWindup = 1.0,
		chargeDuration = 0.6,
		chargeSpeedMult = 4,
		chargeCooldown = 2.5,
	},
}
