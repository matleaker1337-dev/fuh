--!strict
--[[
    File:    CombatController.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.Controllers.CombatController
    Purpose: Клиентская часть боя: рисует пули как Beam/BillboardGui,
             показывает damage numbers и эффекты попадания.
             Не считает урон — это сервер.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Remotes.Remotes)
local EffectsController -- lazy require

local CombatController = {}

function CombatController.init()
	EffectsController = require(script.Parent.EffectsController)
	Remotes.onClientEvent("DamageNumbers", function(payload)
		for _, dn in ipairs(payload) do
			EffectsController.spawnDamageNumber(dn.pos, dn.value, dn.crit)
		end
	end)
end

return CombatController
