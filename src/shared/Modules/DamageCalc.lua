--!strict
--[[
    File:    DamageCalc.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Modules.DamageCalc
    Purpose: Чистая функция: входной урон + цель → итоговый урон.
             См. PLAN §5.4.
]]

local DamageCalc = {}

function DamageCalc.compute(base: number, target): number
	local armorReduction = 0
	if target.armor and target.armor > 0 then
		armorReduction = target.armor / (target.armor + 50)
	end
	local crit = 1
	-- TODO: критический урон из stats оружия / игрока
	return math.max(1, math.floor(base * (1 - armorReduction) * crit))
end

return DamageCalc
