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
local NotificationUI = require(script.Parent.Parent.UI.NotificationUI)

local HUDController = {}

local lastWaveNotified = 0

function HUDController.init()
	HUDUI.build()
	NotificationUI.build()

	Remotes.onClientEvent("PlayerStats", function(payload)
		HUDUI.update(payload)
	end)
	Remotes.onClientEvent("MatchStateChanged", function(payload)
		local running = payload.state == "Running"
		HUDUI.setVisible(running)
		if running then
			MainMenuUI.setVisible(false)
			MapSelectUI.setVisible(false)
			lastWaveNotified = 0
		end
	end)
	Remotes.onClientEvent("Notification", function(payload)
		NotificationUI.show(payload.text or "", payload.color)
	end)
	Remotes.onClientEvent("WaveChanged", function(payload)
		local w = payload.index or payload.wave or 1
		if w == lastWaveNotified then return end
		lastWaveNotified = w
		if payload.isBoss then
			NotificationUI.show("BOSS WAVE " .. tostring(w), Color3.fromRGB(255, 80, 80))
		else
			NotificationUI.show("Wave " .. tostring(w), Color3.fromRGB(255, 220, 120))
		end
	end)
end

return HUDController
