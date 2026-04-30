--!strict
--[[
    File:    EnemyService.lua
    Type:    ModuleScript
    Place:   game.ServerScriptService.Services.EnemyService
    Purpose: Спавн, тик и уничтожение врагов. Использует EnemyAI для логики.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EntityRegistry = require(ReplicatedStorage.Modules.EntityRegistry)

local EnemyService = {}

local enemies = EntityRegistry.new()

function EnemyService.init()
	-- TODO: implement enemy spawn loop and tick
end

function EnemyService.getRegistry()
	return enemies
end

return EnemyService
