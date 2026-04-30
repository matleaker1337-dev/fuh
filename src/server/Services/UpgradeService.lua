--!strict
--[[
    File:    UpgradeService.lua
    Type:    ModuleScript
    Place:   game.ServerScriptService.Services.UpgradeService
    Purpose: Предложение и применение апгрейдов при level-up.
             Очередь оферов на игрока + защита от ipairs(nil) когда клиент
             шлёт ChooseUpgrade без активного пула (двойной клик, рассинхрон).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Upgrades = require(ReplicatedStorage.Config.Upgrades)
local Remotes = require(ReplicatedStorage.Remotes.Remotes)

local UpgradeService = {}

-- Очередь пулов на игрока: каждый элемент — массив из ~3 опций,
-- которые мы в данный момент показываем клиенту. Когда игрок выбирает —
-- pop с начала и, если что-то осталось, шлём следующий пул.
local pendingPools: { [Player]: { { any } } } = {}

local NUM_OPTIONS = 3

-- Weighted random pick без повторов. Возвращает до n элементов.
local function pickWeighted(pool: { any }, n: number): { any }
	local result = {}
	if not pool or #pool == 0 then
		return result
	end

	-- Копия, чтобы можно было удалять выбранные.
	local remaining = table.clone(pool)
	for _ = 1, math.min(n, #pool) do
		local total = 0
		for _, opt in ipairs(remaining) do
			total += (opt.weight or 1)
		end
		if total <= 0 then break end

		local roll = math.random() * total
		local acc = 0
		for i, opt in ipairs(remaining) do
			acc += (opt.weight or 1)
			if roll <= acc then
				table.insert(result, opt)
				table.remove(remaining, i)
				break
			end
		end
	end
	return result
end

local function pendingCount(player: Player): number
	local q = pendingPools[player]
	return q and #q or 0
end

local function sendNextOrPending(player: Player)
	local q = pendingPools[player]
	if q and q[1] then
		Remotes.fireClient(player, "OfferUpgrades", {
			options = q[1],
			pending = #q - 1,
		})
	else
		Remotes.fireClient(player, "PendingUpgrades", { pending = 0 })
	end
end

-- Применить эффект апгрейда к match-стейту. Только бухгалтерия —
-- симуляция/боёвка читает эти поля сама.
local function applyEffect(match, option)
	if not match or not option or not option.effect then return end
	local effect = option.effect

	match.passives = match.passives or {}
	match.loadout = match.loadout or { weapons = {} }
	match.loadout.weapons = match.loadout.weapons or {}

	-- Разблокировка нового оружия.
	if effect.unlock then
		local already = false
		for _, w in ipairs(match.loadout.weapons) do
			if w.id == effect.unlock then already = true; break end
		end
		if not already then
			table.insert(match.loadout.weapons, {
				id = effect.unlock,
				projectiles = 1,
				damageBonus = 0,
			})
		end
	end

	-- +N снарядов конкретному оружию (option.weapon задан в Upgrades.lua).
	if effect.projectiles and option.weapon then
		for _, w in ipairs(match.loadout.weapons) do
			if w.id == option.weapon then
				w.projectiles = (w.projectiles or 1) + effect.projectiles
			end
		end
	end

	-- "Amount": +N снарядов всем оружиям сразу.
	if effect.amount then
		for _, w in ipairs(match.loadout.weapons) do
			w.projectiles = (w.projectiles or 1) + effect.amount
		end
	end

	-- Урон конкретному оружию.
	if effect.weaponDamage and option.weapon then
		for _, w in ipairs(match.loadout.weapons) do
			if w.id == option.weapon then
				w.damageBonus = (w.damageBonus or 0) + effect.weaponDamage
			end
		end
	end

	-- Пассивные накопительные эффекты: maxHp / regen / armor / moveSpeed /
	-- damageMult / luck / critChance / critMult / xpGain / aoeRadius / cooldown.
	local PASSIVE_KEYS = {
		"maxHp", "regen", "armor",
		"moveSpeed", "damageMult", "luck",
		"critChance", "critMult", "xpGain",
		"aoeRadius", "cooldown",
	}
	for _, key in ipairs(PASSIVE_KEYS) do
		local v = effect[key]
		if v then
			match.passives[key] = (match.passives[key] or 0) + v
		end
	end
end

function UpgradeService.init()
	-- Чистим состояние при выходе игрока, чтобы не утекало.
	Players.PlayerRemoving:Connect(function(player)
		pendingPools[player] = nil
	end)
end

function UpgradeService.offer(player: Player, level: number)
	if not player or not player.Parent then return end

	-- Ленивый require, чтобы избежать циклов при загрузке модулей.
	local MatchService = require(ServerScriptService.Services.MatchService)
	local match = MatchService.getMatch(player)
	if not match then return end

	local pool = Upgrades.poolFor(match)
	if not pool or #pool == 0 then return end

	local options = pickWeighted(pool, NUM_OPTIONS)
	if #options == 0 then return end

	local q = pendingPools[player]
	if not q then
		q = {}
		pendingPools[player] = q
	end
	table.insert(q, options)

	-- Если это первый офер в очереди — шлём оптом сразу. Иначе клиент уже
	-- видит модалку, обновим только бейдж "+N".
	if #q == 1 then
		Remotes.fireClient(player, "OfferUpgrades", {
			options = options,
			pending = 0,
		})
	else
		Remotes.fireClient(player, "PendingUpgrades", { pending = #q - 1 })
	end
end

function UpgradeService.choose(player: Player, upgradeId: string)
	if not player or typeof(upgradeId) ~= "string" then return end

	local q = pendingPools[player]
	-- Самый частый источник ipairs(nil): клиент дабл-кликает или шлёт
	-- ChooseUpgrade без активного оффера. Просто игнорируем.
	if not q or not q[1] then return end

	local current = q[1]
	local chosen
	for _, opt in ipairs(current) do
		if opt and opt.id == upgradeId then
			chosen = opt
			break
		end
	end
	if not chosen then
		warn(("[UpgradeService] %s tried to pick unknown upgrade %q"):format(
			player.Name, tostring(upgradeId)
		))
		return
	end

	local MatchService = require(ServerScriptService.Services.MatchService)
	local match = MatchService.getMatch(player)
	if match then
		applyEffect(match, chosen)
		match.takenUpgrades = match.takenUpgrades or {}
		match.takenUpgrades[chosen.id] = (match.takenUpgrades[chosen.id] or 0) + 1
	end

	-- Pop текущий пул и переходим к следующему, если он есть.
	table.remove(q, 1)
	if #q == 0 then
		pendingPools[player] = nil
	end
	sendNextOrPending(player)
end

-- Для тестов / ручной очистки (например, после окончания матча).
function UpgradeService.clear(player: Player)
	pendingPools[player] = nil
end

function UpgradeService.getPendingCount(player: Player): number
	return pendingCount(player)
end

return UpgradeService
