--!strict
--[[
    File:    HUDController.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.Controllers.HUDController
    Purpose: HP-бар, XP-бар, таймер матча, счётчик килов.
             Обновляется по событию PlayerStats (5 Hz).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Remotes.Remotes)
local HUDUI = require(script.Parent.Parent.UI.HUDUI)
local MainMenuUI = require(script.Parent.Parent.UI.MainMenuUI)
local MapSelectUI = require(script.Parent.Parent.UI.MapSelectUI)

local HUDController = {}

function HUDController.init()
	HUDUI.build()
	Remotes.onClientEvent("PlayerStats", function(payload)
		HUDUI.update(payload)
	end)
	Remotes.onClientEvent("MatchStateChanged", function(payload)
		local running = payload.state == "Running"
		HUDUI.setVisible(running)
		if running then
			MainMenuUI.setVisible(false)
			MapSelectUI.setVisible(false)
		end
	end)
end

return HUDController
