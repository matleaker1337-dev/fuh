--!strict
--[[
    File:    AntiCheat.lua
    Type:    ModuleScript
    Place:   game.ServerScriptService.Handlers.AntiCheat
    Purpose: Валидация и санитайзинг данных, приходящих с клиента.
             Никогда не доверяем клиенту — только проверяем.
]]

local AntiCheat = {}

function AntiCheat.validateStartMatch(player: Player, payload): boolean
	if typeof(payload) ~= "table" then return false end
	if typeof(payload.mapId) ~= "string" then return false end
	if typeof(payload.charId) ~= "string" then return false end
	if #payload.mapId > 32 or #payload.charId > 32 then return false end
	-- TODO: проверить что mapId/charId в Config и что игрок их разблокировал
	return true
end

function AntiCheat.sanitizeSettings(s)
	if typeof(s) ~= "table" then return {} end
	local out = {}
	if typeof(s.music) == "number" then out.music = math.clamp(s.music, 0, 1) end
	if typeof(s.sfx) == "number" then out.sfx = math.clamp(s.sfx, 0, 1) end
	return out
end

return AntiCheat
