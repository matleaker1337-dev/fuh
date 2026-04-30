--!strict
--[[
    File:    RemoteHandler.lua
    Type:    ModuleScript
    Place:   game.ServerScriptService.Handlers.RemoteHandler
    Purpose: Привязывает входящие RemoteEvent / RemoteFunction'ы к Service'ам.
             Здесь же — rate limit и санитайзинг входов. См. PLAN §7.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage.Remotes.Remotes)
local RateLimit = require(ServerScriptService.Handlers.RateLimit)
local AntiCheat = require(ServerScriptService.Handlers.AntiCheat)

local MatchService = require(ServerScriptService.Services.MatchService)
local UpgradeService = require(ServerScriptService.Services.UpgradeService)
local DataService = require(ServerScriptService.Services.DataService)

local RemoteHandler = {}

function RemoteHandler.init()
	Remotes.onFunction("BootstrapData", function(player)
		local profile = DataService.getProfile(player)
		return { profile = profile, configHash = "TODO" }
	end)

	Remotes.onFunction("RequestStartMatch", function(player, payload)
		if not RateLimit.allow(player, "RequestStartMatch", 1) then return nil end
		if not AntiCheat.validateStartMatch(player, payload) then return nil end
		return MatchService.start(player, payload.mapId, payload.charId)
	end)

	Remotes.onEvent("ChooseUpgrade", function(player, payload)
		if not RateLimit.allow(player, "ChooseUpgrade", 5) then return end
		UpgradeService.choose(player, payload.id)
	end)

	Remotes.onEvent("MoveInput", function(player, payload)
		-- 60 Hz max
		if not RateLimit.allow(player, "MoveInput", 80) then return end
		-- TODO: forward to a MovementService
	end)

	Remotes.onEvent("SaveSettings", function(player, payload)
		if not RateLimit.allow(player, "SaveSettings", 2) then return end
		DataService.update(player, function(p)
			p.settings = AntiCheat.sanitizeSettings(payload.settings)
			return p
		end)
	end)
end

return RemoteHandler
