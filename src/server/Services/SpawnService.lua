--!strict
--[[
    File:    SpawnService.lua
    Type:    ModuleScript
    Place:   game.ServerScriptService.Services.SpawnService
    Purpose: Управление спавном волн врагов по расписанию карты.
             Минимально играбельный спавн: каждую SPAWN_INTERVAL сек на
             каждого активного игрока спавнит одного врага из пула в
             кольце SPAWN_RING_INNER..SPAWN_RING_OUTER вокруг HRP.
             После 60 сек подмешиваются «тяжёлые» враги.
]]

local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enemies = require(ReplicatedStorage.Config.Enemies)
local Constants = require(ReplicatedStorage.Config.Constants)

local SpawnService = {}

local SPAWN_INTERVAL = 1.0
local BASIC_POOL = { "basic_zombie", "fast_skeleton", "runner" }
local HEAVY_POOL = { "tank", "splitter", "archer_goblin" }
local HEAVY_AFTER_SECONDS = 60
local HEAVY_CHANCE = 0.25

local function pickEnemyId(matchTime: number): string
	if matchTime > HEAVY_AFTER_SECONDS and math.random() < HEAVY_CHANCE then
		return HEAVY_POOL[math.random(#HEAVY_POOL)]
	end
	return BASIC_POOL[math.random(#BASIC_POOL)]
end

local function spawnAround(player: Player, enemyId: string)
	local def = Enemies[enemyId]
	if not def then return end
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local angle = math.random() * math.pi * 2
	local rRange = Constants.SPAWN_RING_OUTER - Constants.SPAWN_RING_INNER
	local r = Constants.SPAWN_RING_INNER + math.random() * rRange
	local pos = (hrp :: BasePart).Position + Vector3.new(
		math.cos(angle) * r,
		0,
		math.sin(angle) * r
	)

	local EnemyService = require(ServerScriptService.Services.EnemyService)
	EnemyService.spawn(def, pos)
end

function SpawnService.init()
	local accum = 0
	RunService.Heartbeat:Connect(function(dt)
		accum += dt
		if accum < SPAWN_INTERVAL then return end
		accum = 0

		-- Lazy require, чтобы не было циклов при загрузке.
		local MatchService = require(ServerScriptService.Services.MatchService)
		local EnemyService = require(ServerScriptService.Services.EnemyService)

		if EnemyService.getRegistry():count() >= Constants.MAX_ENEMIES then
			return
		end

		for player, match in pairs(MatchService.getAllMatches()) do
			local enemyId = pickEnemyId(match.time or 0)
			spawnAround(player, enemyId)
		end
	end)
end

return SpawnService
