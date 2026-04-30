--!strict
--[[
    File:    MapSelectController.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.Controllers.MapSelectController
    Purpose: Чтение Config.Maps, рендер карточек, отправка RequestStartMatch.
             См. PLAN §2.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maps = require(ReplicatedStorage.Config.Maps)
local Remotes = require(ReplicatedStorage.Remotes.Remotes)

local MapSelectUI = require(script.Parent.Parent.UI.MapSelectUI)
local MainMenuUI = require(script.Parent.Parent.UI.MainMenuUI)
local MenuController = require(script.Parent.MenuController)

local MapSelectController = {}

function MapSelectController.init()
	MapSelectUI.build()
	MapSelectUI.populate(Maps)
	MapSelectUI.onBackClicked(function()
		MenuController.goto("MainMenu")
	end)
	MapSelectUI.onMapSelected(function(mapId)
		-- Скрываем все меню ДО отправки запроса на сервер (invokeServer yield'ится)
		MapSelectUI.setVisible(false)
		MainMenuUI.setVisible(false)

		local ok = Remotes.invokeServer("RequestStartMatch", {
			mapId = mapId, charId = "warrior",
		})
		if not ok then
			warn("[MapSelectController] start match rejected")
			MenuController.goto("MapSelect")
		end
	end)
end

return MapSelectController
