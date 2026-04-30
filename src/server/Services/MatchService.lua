--!strict
--[[
    File:    MatchService.lua
    Type:    ModuleScript
    Place:   game.ServerScriptService.Services.MatchService
    Purpose: Управление жизненным циклом матча: старт, тик, завершение.
             Тиковый луп считает время матча, обновляет волну и шлёт
             PlayerStats клиенту (5 Hz). LoadCharacter / Destroy
             выполняются здесь, чтобы вне матча у игрока не было
             персонажа (и значит — нечем было ходить по меню).
]]

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes.Remotes)
local Maps = require(ReplicatedStorage.Config.Maps)
local Characters = require(ReplicatedStorage.Config.Characters)
local Progression = require(ReplicatedStorage.Config.Progression)

local MatchService = {}

MatchService.onLevelUp = nil :: ((player: Player, level: number) -> ())?

local activeMatches: { [Player]: any } = {}

local STATS_INTERVAL = 0.2
local WAVE_DURATION = 30

local function destroyCharacter(player: Player)
	local char = player.Character
	if char then
		pcall(function() char:Destroy() end)
	end
	player.Character = nil
end

local function fireWave(player: Player, match)
	local map = Maps[match.mapId]
	local isBoss = false
	if map and map.bossSchedule then
		for t in pairs(map.bossSchedule) do
			if math.abs(match.time - t) < 1 then isBoss = true; break end
		end
	end
	Remotes.fireClient(player, "WaveChanged", {
		index = match.wave,
		isBoss = isBoss,
	})
end

local function fireStats(player: Player, match)
	Remotes.fireClient(player, "PlayerStats", {
		time = match.time or 0,
		level = match.level or 1,
		xp = match.xp or 0,
		xpToNext = Progression.xpToLevel(match.level or 1),
		kills = match.kills or 0,
		hp = match.hp or 100,
		maxHp = match.maxHp or 100,
		wave = {
			index = match.wave or 1,
			killed = match.waveKills or 0,
			total = (match.wave or 1) * 10,
			isBoss = false,
		},
	})
end

function MatchService.init()
	local statsAccum = 0

	RunService.Heartbeat:Connect(function(dt)
		-- Накапливаем время матча и выкатываем волну каждые WAVE_DURATION сек.
		for player, match in pairs(activeMatches) do
			if not player.Parent then
				activeMatches[player] = nil
			else
				match.time = (match.time or 0) + dt
				local newWave = math.floor((match.time or 0) / WAVE_DURATION) + 1
				if newWave ~= match.wave then
					match.wave = newWave
					match.waveKills = 0
					fireWave(player, match)
				end
			end
		end

		-- PlayerStats шлём 5 Hz, чтобы не спамить ремоут.
		statsAccum += dt
		if statsAccum >= STATS_INTERVAL then
			statsAccum = 0
			for player, match in pairs(activeMatches) do
				fireStats(player, match)
			end
		end
	end)
end

function MatchService.start(player: Player, mapId: string, charId: string)
	local charDef = Characters[charId or "warrior"] or Characters.warrior
	local maxHp = (charDef and charDef.baseStats and charDef.baseStats.maxHp) or 100

	activeMatches[player] = {
		player = player,
		mapId = mapId,
		charId = charId,
		startTime = os.clock(),
		time = 0,
		wave = 0, -- первый тик выкатит wave=1 и пошлёт WaveChanged
		waveKills = 0,
		level = 1,
		xp = 0,
		kills = 0,
		hp = maxHp,
		maxHp = maxHp,
		loadout = { weapons = {} },
		takenUpgrades = {},
		passives = {},
	}

	-- CharacterAutoLoads отключён в Main.server.lua, поэтому персонаж
	-- появляется только при старте матча.
	pcall(function() player:LoadCharacter() end)

	Remotes.fireClient(player, "MatchStateChanged", { state = "Running" })
	-- Сразу же шлём первый PlayerStats, чтобы HUD не показывал 00:00 / 0/0
	-- ещё 200 мс до первого тикового апдейта.
	fireStats(player, activeMatches[player])

	return true
end

function MatchService.leave(player: Player)
	if not activeMatches[player] then return end
	activeMatches[player] = nil
	-- Убираем персонажа, чтобы в меню игрок не мог ходить по плейту.
	destroyCharacter(player)
	-- Если матчей больше нет — чистим врагов, чтобы они не ходили по
	-- пустому стейджу. Lazy-require, как и в SpawnService.
	if next(activeMatches) == nil then
		local ok, EnemyService = pcall(function()
			local SSS = game:GetService("ServerScriptService")
			return require(SSS.Services.EnemyService)
		end)
		if ok and EnemyService and EnemyService.clearAll then
			EnemyService.clearAll()
		end
	end
	Remotes.fireClient(player, "MatchStateChanged", { state = "Ended" })
end

function MatchService.onPlayerLeft(player: Player)
	activeMatches[player] = nil
end

function MatchService.getMatch(player: Player)
	return activeMatches[player]
end

function MatchService.getAllMatches(): { [Player]: any }
	return activeMatches
end

return MatchService
