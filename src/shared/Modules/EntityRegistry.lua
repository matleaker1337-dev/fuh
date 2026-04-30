--!strict
--[[
    File:    EntityRegistry.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Modules.EntityRegistry
    Purpose: Лёгкий контейнер «id → entity table». Используется EnemyService
             и потенциально другими реестрами (пули, эффекты).
]]

local EntityRegistry = {}
EntityRegistry.__index = EntityRegistry

function EntityRegistry.new()
	return setmetatable({ items = {}, _next = 1, _count = 0 }, EntityRegistry)
end

function EntityRegistry:nextId(): number
	local id = self._next
	self._next += 1
	return id
end

function EntityRegistry:add(id: number, item: any)
	self.items[id] = item
	self._count += 1
end

function EntityRegistry:get(id: number)
	return self.items[id]
end

function EntityRegistry:remove(id: number)
	if self.items[id] then
		self.items[id] = nil
		self._count -= 1
	end
end

function EntityRegistry:count(): number
	return self._count
end

function EntityRegistry:clear()
	self.items = {}
	self._count = 0
end

function EntityRegistry:forEach(fn)
	for id, item in pairs(self.items) do
		fn(item, id)
	end
end

return EntityRegistry
