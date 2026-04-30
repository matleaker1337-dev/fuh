--!strict
--[[
    File:    UpgradeService.lua
    Type:    ModuleScript
    Place:   game.ServerScriptService.Services.UpgradeService
    Purpose: Предложение и применение апгрейдов при level-up.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Upgrades = require(ReplicatedStorage.Config.Upgrades)
local Remotes = require(ReplicatedStorage.Remotes.Remotes)

local UpgradeService = {}

function UpgradeService.init()
	-- TODO: implement upgrade offering logic
end

function UpgradeService.offer(player: Player, level: number)
	-- TODO: generate upgrade pool and send to client
end

function UpgradeService.choose(player: Player, upgradeId: string)
	-- TODO: apply chosen upgrade to player's match state
end

return UpgradeService
