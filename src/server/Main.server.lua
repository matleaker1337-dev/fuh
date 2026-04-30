--!strict
--[[
    File:    Main.server.lua
    Type:    ServerScript (Script с RunContext = Server)
    Place:   game.ServerScriptService.Main
    Purpose: Точка входа серверной логики. Инициализирует все Services
             в нужном порядке, поднимает Remote'ы, ловит игроков.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService:WaitForChild("Services")
local Handlers = ServerScriptService:WaitForChild("Handlers")

local Remotes         = require(ReplicatedStorage.Remotes.Remotes)
local DataService     = require(Services.DataService)
local MatchService    = require(Services.MatchService)
local EnemyService    = require(Services.EnemyService)
local SpawnService    = require(Services.SpawnService)
local ProgressionService = require(Services.ProgressionService)
local UpgradeService  = require(Services.UpgradeService)
local MapService      = require(Services.MapService)
local CombatService   = require(Services.CombatService)
local PickupService   = require(Services.PickupService)
local RemoteHandler   = require(Handlers.RemoteHandler)
local RateLimit       = require(Handlers.RateLimit)

-- Порядок важен: сначала то, у чего нет зависимостей.
Remotes.init()
DataService.init()
MapService.init()
EnemyService.init()
SpawnService.init()
CombatService.init()
PickupService.init()
ProgressionService.init()
UpgradeService.init()
MatchService.init()
RemoteHandler.init()

-- Связываем level-up в MatchService с системой выбора апгрейдов.
-- Делается ПОСЛЕ инициализации обоих сервисов, чтобы избежать циклической
-- зависимости при загрузке модулей.
MatchService.onLevelUp = UpgradeService.offer

Players.PlayerAdded:Connect(function(player)
	DataService.loadProfile(player)
	-- Дальше клиент сам запросит BootstrapData через RemoteFunction
end)

Players.PlayerRemoving:Connect(function(player)
	MatchService.onPlayerLeft(player)
	DataService.saveProfile(player)
	RateLimit.reset(player)
end)

game:BindToClose(function()
	-- Сейв всем оставшимся, дождаться записи перед выключением сервера
	for _, player in ipairs(Players:GetPlayers()) do
		DataService.saveProfile(player)
	end
	task.wait(3)
end)

print("[Bullet Heaven] Server boot complete.")
