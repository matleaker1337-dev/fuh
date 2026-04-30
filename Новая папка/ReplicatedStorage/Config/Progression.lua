--!strict
--[[
    File:    Progression.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Config.Progression
    Purpose: Кривая XP и формулы уровней.
]]

local Progression = {}

function Progression.xpToLevel(level: number): number
	return math.floor(5 + level * 4 + level * level * 0.5)
end

function Progression.matchReward(stats): number
	return math.floor((stats.kills or 0) * 0.5 + (stats.time or 0) * 0.05 + (stats.level or 1) * 5)
end

return Progression
