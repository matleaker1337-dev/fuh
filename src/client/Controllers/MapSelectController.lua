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

local MapSelectController = {}

function MapSelectController.init()
	MapSelectUI.build()
	MapSelectUI.populate(Maps)
	MapSelectUI.onMapSelected(function(mapId)
		local ok = Remotes.invokeServer("RequestStartMatch", {
			mapId = mapId, charId = "warrior",
		})
		if not ok then
			warn("[MapSelectController] start match rejected")
		end
	end)
end

return MapSelectController
