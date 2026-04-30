--!strict
--[[
    File:    MenuController.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.Controllers.MenuController
    Purpose: State machine UI: MainMenu / CharacterSelect / MapSelect /
             InMatch / Pause / Results. Управляет какой UI показан.
             См. PLAN §1.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Remotes.Remotes)

local MainMenuUI = require(script.Parent.Parent.UI.MainMenuUI)
local MapSelectUI = require(script.Parent.Parent.UI.MapSelectUI)

local MenuController = {}

local state: string = "MainMenu"
local profile: any = nil

function MenuController.init()
	MainMenuUI.build()
	MainMenuUI.onPlayClicked(function() MenuController.goto("MapSelect") end)
	MainMenuUI.onSettingsClicked(function() MenuController.goto("Settings") end)

	-- Скрытие MapSelect и переход в матч после клика по карте — обрабатывает
	-- MapSelectController. Он же вызывает Remotes.invokeServer("RequestStartMatch").
	-- Здесь просто слушаем смену состояния матча с сервера.
	Remotes.onClientEvent("MatchStateChanged", function(payload)
		if payload.state == "Running" then
			MenuController.goto("InMatch")
		elseif payload.state == "Results" then
			MenuController.goto("Results")
		end
	end)
end

function MenuController.onBootstrap(boot)
	profile = boot and boot.profile
	MainMenuUI.setProfile(profile)
	MenuController.goto("MainMenu")
end

function MenuController.goto(newState: string)
	state = newState
	MainMenuUI.setVisible(state == "MainMenu")
	MapSelectUI.setVisible(state == "MapSelect")
	-- Прочие UI (HUD, Pause, Results) управляются своими контроллерами
	-- через подписку на MatchStateChanged.
end

function MenuController.getState() return state end

return MenuController
