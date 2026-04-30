--!strict
--[[
    File:    Utils.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Modules.Utils
    Purpose: Сборная папка хелперов: lerp, clamp, тасование таблиц.
]]

local Utils = {}

function Utils.lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

function Utils.clamp(v: number, lo: number, hi: number): number
	if v < lo then return lo elseif v > hi then return hi end
	return v
end

function Utils.shuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

function Utils.sign(x: number): number
	return x > 0 and 1 or (x < 0 and -1 or 0)
end

return Utils
