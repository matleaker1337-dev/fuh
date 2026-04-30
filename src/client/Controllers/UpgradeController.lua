--!strict
--[[
    File:    UpgradeController.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.Controllers.UpgradeController
    Purpose: Слушает OfferUpgrades, показывает modal, шлёт ChooseUpgrade.
             См. PLAN §4.3.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Remotes.Remotes)
local UpgradeModalUI = require(script.Parent.Parent.UI.UpgradeModalUI)

local UpgradeController = {}

function UpgradeController.init()
	UpgradeModalUI.build()
	Remotes.onClientEvent("OfferUpgrades", function(payload)
		UpgradeModalUI.show(payload.options, function(chosenId)
			Remotes.fireServer("ChooseUpgrade", { id = chosenId })
			UpgradeModalUI.hide()
		end, payload.pending)
	end)
	-- Сервер шлёт это когда уровень получен во время открытой модалки —
	-- надо просто обновить бейдж "+N" без перерисовки.
	Remotes.onClientEvent("PendingUpgrades", function(payload)
		UpgradeModalUI.setPending(payload.pending or 0)
	end)
end

return UpgradeController
