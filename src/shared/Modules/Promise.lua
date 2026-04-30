--!strict
--[[
    File:    Promise.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Modules.Promise
    Purpose: Минимальная Promise-реализация (для удобства async-цепочек).
             В проде заменить на evaera/roblox-lua-promise.
]]

local Promise = {}
Promise.__index = Promise

function Promise.new(executor)
	local self = setmetatable({
		_state = "pending",
		_value = nil,
		_callbacks = {},
	}, Promise)
	local function resolve(v)
		if self._state ~= "pending" then return end
		self._state = "resolved"; self._value = v
		for _, cb in ipairs(self._callbacks) do task.spawn(cb, v) end
	end
	local ok, err = pcall(executor, resolve)
	if not ok then warn("[Promise]", err) end
	return self
end

function Promise:andThen(cb)
	if self._state == "resolved" then
		task.spawn(cb, self._value)
	else
		table.insert(self._callbacks, cb)
	end
	return self
end

return Promise
