--!strict
--[[
    File:    DataService.lua
    Type:    ModuleScript
    Place:   game.ServerScriptService.Services.DataService
    Purpose: Загрузка / сохранение профиля игрока через DataStore.
]]

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStoreSafe = require(ReplicatedStorage.Modules.DataStoreSafe)

local DataService = {}

local STORE_NAME = "PlayerProfiles_v1"
local store = DataStoreService:GetDataStore(STORE_NAME)

local profiles: { [Player]: any } = {}

local DEFAULT_PROFILE = {
	version = 1,
	coins = 0,
	unlockedChars = { "warrior" },
	unlockedMaps = { "forest_01" },
	bestRuns = {},
	settings = { music = 0.8, sfx = 1.0 },
	updatedAt = 0,
}

function DataService.init()
	-- nothing to pre-initialize
end

function DataService.loadProfile(player: Player)
	local key = "player_" .. tostring(player.UserId)
	local data = DataStoreSafe.get(store, key)
	if data and typeof(data) == "table" then
		profiles[player] = data
	else
		profiles[player] = table.clone(DEFAULT_PROFILE)
	end
end

function DataService.saveProfile(player: Player)
	local p = profiles[player]
	if not p then return end
	p.updatedAt = os.time()
	local key = "player_" .. tostring(player.UserId)
	DataStoreSafe.set(store, key, p)
	profiles[player] = nil
end

function DataService.getProfile(player: Player)
	return profiles[player]
end

function DataService.update(player: Player, transform: (any) -> any)
	local p = profiles[player]
	if not p then return end
	profiles[player] = transform(p)
end

return DataService
