--!strict
--[[
    File:    MatchService.lua
    Type:    ModuleScript
    Place:   game.ServerScriptService.Services.MatchService
    Purpose: Управление жизненным циклом матча: старт, тик, завершение.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Remotes.Remotes)

local MatchService = {}

MatchService.onLevelUp = nil :: ((player: Player, level: number) -> ())?

local activeMatches: { [Player]: any } = {}

function MatchService.init()
	-- TODO: implement match tick loop
end

function MatchService.start(player: Player, mapId: string, charId: string)
	activeMatches[player] = {
		mapId = mapId,
		charId = charId,
		startTime = os.clock(),
		level = 1,
		xp = 0,
		kills = 0,
		loadout = { weapons = {} },
		takenUpgrades = {},
	}
	Remotes.fireClient(player, "MatchStateChanged", { state = "Running" })
	return true
end

function MatchService.onPlayerLeft(player: Player)
	activeMatches[player] = nil
end

function MatchService.getMatch(player: Player)
	return activeMatches[player]
end

return MatchService
