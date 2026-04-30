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

local HUDController = {}

function HUDController.init()
	HUDUI.build()
	Remotes.onClientEvent("PlayerStats", function(payload)
		HUDUI.update(payload)
	end)
	Remotes.onClientEvent("MatchStateChanged", function(payload)
		HUDUI.setVisible(payload.state == "Running")
	end)
end

return HUDController
