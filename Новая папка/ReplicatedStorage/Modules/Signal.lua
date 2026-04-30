--!strict
--[[
    File:    Signal.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Modules.Signal
    Purpose: Простой PubSub. Аналог BindableEvent, но без overhead'а Roblox event-системы.
]]

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ listeners = {} }, Signal)
end

function Signal:Connect(fn)
	table.insert(self.listeners, fn)
	return function()
		for i, v in ipairs(self.listeners) do
			if v == fn then table.remove(self.listeners, i); return end
		end
	end
end

function Signal:Fire(...)
	for _, fn in ipairs(self.listeners) do
		task.spawn(fn, ...)
	end
end

return Signal
