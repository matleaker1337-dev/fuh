--!strict
--[[
    File:    ProgressionService.lua
    Type:    ModuleScript
    Place:   game.ServerScriptService.Services.ProgressionService
    Purpose: XP, level-up, разблокировка контента.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Progression = require(ReplicatedStorage.Config.Progression)

local ProgressionService = {}

function ProgressionService.init()
	-- TODO: implement XP tracking and level-up logic
end

return ProgressionService
