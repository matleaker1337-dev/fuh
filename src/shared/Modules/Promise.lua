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
		_errCallbacks = {},
	}, Promise)
	local function resolve(v)
		if self._state ~= "pending" then return end
		self._state = "resolved"; self._value = v
		for _, cb in ipairs(self._callbacks) do task.spawn(cb, v) end
	end
	local function reject(reason)
		if self._state ~= "pending" then return end
		self._state = "rejected"; self._value = reason
		for _, cb in ipairs(self._errCallbacks) do task.spawn(cb, reason) end
	end
	local ok, err = pcall(executor, resolve, reject)
	if not ok then reject(err) end
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

function Promise:catch(cb)
	if self._state == "rejected" then
		task.spawn(cb, self._value)
	else
		table.insert(self._errCallbacks, cb)
	end
	return self
end

return Promise
