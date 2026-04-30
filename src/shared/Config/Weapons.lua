--!strict
--[[
    File:    Weapons.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Config.Weapons
    Purpose: База оружий. Behavior пишется отдельно в Modules/Weapons/<id>.lua,
             этот файл — только данные.
             См. PLAN §5.3.

             Поля:
               behavior        — "projectile" (default) или "fall_aoe"
               asset           — имя Model в ReplicatedStorage.Assets.Weapons
                                 (если не задано — используется дефолтный шарик)
               homing          — true/false: подкручивает к ближайшему врагу
               pierce          — сколько врагов пробивает; -1 = бесконечно
               aoeRadius       — для behavior "fall_aoe": радиус взрыва
               fallSpeed       — для behavior "fall_aoe": скорость падения
]]

return {
	basic_bolt = {
		id = "basic_bolt",
		displayName = "Bolt",
		behavior = "projectile",
		damage = 4,
		cooldown = 0.6,
		projectileSpeed = 50,
		lifetime = 1.0,
		projectiles = 1,
		pierce = 0,
		homing = true,
		element = "physical",
	},
	fireball = {
		id = "fireball",
		displayName = "Fireball",
		behavior = "fall_aoe",
		asset = "FireBall",
		damage = 36,
		cooldown = 1.0,
		fallSpeed = 80,
		lifetime = 2.0,
		aoeRadius = 6,
		showTelegraph = true,
		crater = true,
		spin = true,
		spinSpeed = 12,
		element = "fire",
	},
	knife = {
		id = "knife",
		displayName = "Knife",
		behavior = "projectile",
		asset = "KNIFE",
		damage = 5,
		cooldown = 0.5,
		projectileSpeed = 60,
		lifetime = 5.0,
		projectiles = 1,
		pierce = -1,
		homing = true,
		spin = true,
		spinSpeed = 25,
		showHitbox = true,
		element = "physical",
	},
	aura = {
		id = "aura",
		displayName = "Holy Aura",
		behavior = "aura",
		damage = 3,
		cooldown = 0.2,
		radius = 6,
		lifetime = 0,
		element = "holy",
	},
}
