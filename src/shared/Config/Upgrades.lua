--!strict
--[[
    File:    Upgrades.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Config.Upgrades
    Purpose: Каталог апгрейдов с рандомным роллом значений.
             Поддерживает два типа:
               fixed  — фиксированный эффект (unlock, +1 projectile)
               random — значение в диапазоне [min, max], редкость зависит
                        от того, насколько высоко выпал ролл.

             Поля шаблона:
               id            — уникальный id шаблона
               weapon        — id оружия (опц.)
               passive       — категория пассивки (опц.)
               displayName   — название в UI
               weight        — вес в weighted random pool
               maxTaken      — сколько раз можно взять (default 1)
               prerequisites — список id шаблонов, которые должны быть взяты
               fixed         — true → эффект не рандомится
               effect        — (для fixed) таблица эффектов

             Для рандомных апгрейдов:
               effectKey     — ключ эффекта (weaponDamage, maxHp, etc.)
               min, max      — диапазон ролла
               isPercent     — true → значение отображается как процент
               descTemplate  — шаблон описания (%s заменяется на значение)
]]

local Upgrades = {}

Upgrades.templates = {
	-- ═══════════ WEAPON UNLOCKS (fixed) ═══════════
	{ id = "knife_unlock", fixed = true, weapon = "knife", weight = 100,
		displayName = "KNIFE",
		description = "Throws a homing knife that pierces through every enemy in its path.",
		effect = { unlock = "knife" } },
	{ id = "fireball_unlock", fixed = true, weapon = "fireball", weight = 100,
		displayName = "FIREBALL",
		description = "Drops a fireball from the sky onto the nearest enemy. Explodes for AoE damage.",
		effect = { unlock = "fireball" } },

	-- ═══════════ WEAPON PROJECTILES (fixed, stackable) ═══════════
	{ id = "knife_count", fixed = true, weapon = "knife", weight = 60, maxTaken = 2,
		prerequisites = { "knife_unlock" },
		displayName = "+1 KNIFE",
		description = "Throw 1 extra knife per attack.",
		effect = { projectiles = 1 } },
	{ id = "fireball_count", fixed = true, weapon = "fireball", weight = 50, maxTaken = 1,
		prerequisites = { "fireball_unlock" },
		displayName = "+1 FIREBALL",
		description = "Drops 1 extra fireball each cast.",
		effect = { projectiles = 1 } },
	{ id = "amount", fixed = true, passive = "amount", weight = 30, maxTaken = 1,
		displayName = "AMOUNT",
		description = "+1 projectile to ALL weapons at once.",
		effect = { amount = 1 } },

	-- ═══════════ WEAPON DAMAGE (random) ═══════════
	{ id = "knife_damage", weapon = "knife", weight = 65, maxTaken = 3,
		prerequisites = { "knife_unlock" },
		displayName = "KNIFE DAMAGE",
		effectKey = "weaponDamage", min = 1, max = 8, isPercent = false,
		descTemplate = "+%s damage to every knife you throw." },
	{ id = "fireball_damage", weapon = "fireball", weight = 65, maxTaken = 3,
		prerequisites = { "fireball_unlock" },
		displayName = "FIREBALL DAMAGE",
		effectKey = "weaponDamage", min = 5, max = 25, isPercent = false,
		descTemplate = "+%s damage to fireball explosions." },

	-- ═══════════ PASSIVES (random) ═══════════
	{ id = "max_hp", passive = "max_hp", weight = 70, maxTaken = 3,
		displayName = "VITALITY",
		effectKey = "maxHp", min = 10, max = 50, isPercent = false,
		descTemplate = "+%s max HP. Heals you immediately." },
	{ id = "speed", passive = "move_speed", weight = 60, maxTaken = 2,
		displayName = "AGILITY",
		effectKey = "moveSpeed", min = 0.05, max = 0.20, isPercent = true,
		descTemplate = "+%s%% movement speed." },
	{ id = "damage_mult", passive = "damage_mult", weight = 55, maxTaken = 3,
		displayName = "EMPOWER",
		effectKey = "damageMult", min = 0.05, max = 0.25, isPercent = true,
		descTemplate = "+%s%% damage from ALL weapons." },
	{ id = "luck", passive = "luck", weight = 45, maxTaken = 2,
		displayName = "LUCK",
		effectKey = "luck", min = 0.03, max = 0.12, isPercent = true,
		descTemplate = "+%s%% luck. Better upgrade rolls." },
	{ id = "crit_chance", passive = "crit_chance", weight = 50, maxTaken = 3,
		displayName = "CRIT CHANCE",
		effectKey = "critChance", min = 0.05, max = 0.18, isPercent = true,
		descTemplate = "+%s%% chance for any hit to crit." },
	{ id = "crit_mult", passive = "crit_mult", weight = 40, maxTaken = 2,
		prerequisites = { "crit_chance" },
		displayName = "CRIT POWER",
		effectKey = "critMult", min = 0.20, max = 0.80, isPercent = true,
		descTemplate = "+%s%% crit damage multiplier." },
	{ id = "aoe_radius", weapon = "fireball", passive = "aoe_radius", weight = 45, maxTaken = 2,
		prerequisites = { "fireball_unlock" },
		displayName = "BLAST RADIUS",
		effectKey = "aoeRadius", min = 1, max = 5, isPercent = false,
		descTemplate = "+%s fireball explosion radius." },
	{ id = "xp_gain", passive = "xp_gain", weight = 55, maxTaken = 2,
		displayName = "+XP GAIN",
		effectKey = "xpGain", min = 0.10, max = 0.40, isPercent = true,
		descTemplate = "+%s%% XP from every kill." },
	{ id = "regen", passive = "regen", weight = 50, maxTaken = 2,
		displayName = "REGEN",
		effectKey = "regen", min = 1, max = 4, isPercent = false,
		descTemplate = "+%s HP recovered per second." },
	{ id = "armor", passive = "armor", weight = 50, maxTaken = 2,
		displayName = "ARMOR",
		effectKey = "armor", min = 1, max = 6, isPercent = false,
		descTemplate = "-%s incoming damage (min 1)." },
	{ id = "cooldown", passive = "cooldown", weight = 50, maxTaken = 2,
		displayName = "COOLDOWN",
		effectKey = "cooldown", min = 0.05, max = 0.18, isPercent = true,
		descTemplate = "-%s%% cooldown on ALL weapons." },
}

-- Рарность по перцентилю ролла: чем выше значение, тем реже.
local function rarityFromPercentile(pct: number): string
	if pct >= 0.95 then return "legendary" end
	if pct >= 0.80 then return "epic" end
	if pct >= 0.55 then return "rare" end
	if pct >= 0.25 then return "uncommon" end
	return "common"
end

-- Ролл одного случайного значения для шаблона.
function Upgrades.roll(template)
	if template.fixed then
		return {
			id = template.id,
			weapon = template.weapon,
			passive = template.passive,
			level = template.level,
			displayName = template.displayName,
			description = template.description,
			rarity = "common",
			weight = template.weight,
			effect = template.effect,
		}
	end

	local range = template.max - template.min
	local raw = math.random() * range + template.min
	local percentile = (raw - template.min) / range

	local value
	if template.isPercent then
		value = math.floor(raw * 100 + 0.5) / 100
	else
		value = math.floor(raw + 0.5)
	end
	value = math.max(value, template.min)

	local rarity = rarityFromPercentile(percentile)
	local displayValue
	if template.isPercent then
		displayValue = tostring(math.floor(value * 100 + 0.5))
	else
		displayValue = tostring(value)
	end

	local desc = string.format(template.descTemplate or "+%s", displayValue)

	return {
		id = template.id,
		weapon = template.weapon,
		passive = template.passive,
		displayName = template.displayName,
		description = desc,
		rarity = rarity,
		weight = template.weight,
		effect = { [template.effectKey] = value },
	}
end

function Upgrades.poolFor(match)
	local pool = {}
	local taken = match.takenUpgrades or {}
	local hasWeapon: { [string]: boolean } = {}
	for _, w in ipairs(match.loadout.weapons) do
		hasWeapon[w.id] = true
	end

	for _, t in ipairs(Upgrades.templates) do
		local skip = false
		local takenCount = taken[t.id] or 0
		local maxT = t.maxTaken or 1
		if takenCount >= maxT then skip = true end
		if not skip and t.fixed and t.effect and t.effect.unlock and hasWeapon[t.effect.unlock] then
			skip = true
		end
		if not skip and t.weapon and not (t.fixed and t.effect and t.effect.unlock)
			and not hasWeapon[t.weapon]
		then
			skip = true
		end
		if not skip and t.prerequisites then
			for _, prereq in ipairs(t.prerequisites) do
				if not taken[prereq] or taken[prereq] == 0 then skip = true; break end
			end
		end
		if not skip then
			table.insert(pool, Upgrades.roll(t))
		end
	end
	return pool
end

return Upgrades
