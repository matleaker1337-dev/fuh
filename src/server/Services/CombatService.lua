--!strict
--[[
    File:    CombatService.lua
    Type:    ModuleScript
    Place:   game.ServerScriptService.Services.CombatService
    Purpose: Hit detection, нанесение урона, спавн пуль.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BulletSimulator = require(ReplicatedStorage.Modules.BulletSimulator)
local DamageCalc = require(ReplicatedStorage.Modules.DamageCalc)

local CombatService = {}

function CombatService.init()
	-- TODO: implement combat tick loop with bullet simulation and hit detection
end

return CombatService
