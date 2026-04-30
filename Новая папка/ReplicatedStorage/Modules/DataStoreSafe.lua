--!strict
--[[
    File:    DataStoreSafe.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Modules.DataStoreSafe
    Purpose: Обёртка над DataStore с retry и backoff. См. PLAN §6.2.
]]

local DataStoreSafe = {}

local MAX_RETRIES = 3

function DataStoreSafe.get(store, key)
	local err
	for attempt = 1, MAX_RETRIES do
		local ok, data = pcall(function() return store:GetAsync(key) end)
		if ok then return data, nil end
		err = data
		task.wait(2 ^ attempt)
	end
	return nil, err
end

function DataStoreSafe.set(store, key, value)
	local err
	for attempt = 1, MAX_RETRIES do
		local ok = pcall(function() store:SetAsync(key, value) end)
		if ok then return true, nil end
		err = "set_failed"
		task.wait(2 ^ attempt)
	end
	return false, err
end

function DataStoreSafe.update(store, key, transform)
	local err
	for attempt = 1, MAX_RETRIES do
		local ok, value = pcall(function()
			return store:UpdateAsync(key, transform)
		end)
		if ok then return value, nil end
		err = "update_failed"
		task.wait(2 ^ attempt)
	end
	return nil, err
end

return DataStoreSafe
