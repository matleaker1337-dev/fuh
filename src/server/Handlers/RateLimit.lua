--!strict
--[[
    File:    RateLimit.lua
    Type:    ModuleScript
    Place:   game.ServerScriptService.Handlers.RateLimit
    Purpose: Скользящий rate limit на каждого игрока и каждый remote.
             См. PLAN §7.3.
]]

local RateLimit = {}

local buckets: { [Player]: { [string]: { count: number, t: number } } } = {}

-- Лимит: maxPerSec вызовов в секунду.
function RateLimit.allow(player: Player, key: string, maxPerSec: number): boolean
	local now = os.clock()
	buckets[player] = buckets[player] or {}
	local b = buckets[player][key]
	if not b or now - b.t >= 1 then
		buckets[player][key] = { count = 1, t = now }
		return true
	end
	b.count += 1
	return b.count <= maxPerSec
end

function RateLimit.reset(player: Player)
	buckets[player] = nil
end

return RateLimit
