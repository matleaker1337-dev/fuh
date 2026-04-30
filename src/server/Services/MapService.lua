--!strict
--[[
    File:    MapService.lua
    Type:    ModuleScript
    Place:   game.ServerScriptService.Services.MapService
    Purpose: Загрузка и управление игровыми картами.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maps = require(ReplicatedStorage.Config.Maps)

local MapService = {}

function MapService.init()
	-- TODO: implement map loading and cleanup
end

return MapService
