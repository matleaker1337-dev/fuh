--!strict
--[[
    File:    BulletSimulator.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Modules.BulletSimulator
    Purpose: Двигает массив пуль и убирает истёкшие. Hit detection делает
             CombatService на сервере (через свой реестр врагов).
             См. PLAN §5.3.
]]

local BulletSimulator = {}

-- Двигает пули, уменьшает ttl, удаляет истёкшие. Перед удалением вызывает
-- onExpire(bullet) — например чтобы CombatService уничтожил Part.
function BulletSimulator.step(bullets, dt: number, onExpire)
	for i = #bullets, 1, -1 do
		local b = bullets[i]
		b.pos += b.vel * dt
		b.ttl -= dt
		if b.ttl <= 0 then
			if onExpire then onExpire(b) end
			if b.part then b.part:Destroy() end
			table.remove(bullets, i)
		end
	end
end

return BulletSimulator
