--!strict
--[[
    File:    PauseController.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.Controllers.PauseController
    Purpose: Обрабатывает Esc → показ/скрытие PauseMenuUI во время матча.
             Resume закрывает меню, Leave отправляет LeaveMatch на сервер.
]]

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Remotes.Remotes)

local PauseMenuUI = require(script.Parent.Parent.UI.PauseMenuUI)

local PauseController = {}

local paused = false
local inMatch = false

function PauseController.init()
	PauseMenuUI.build()

	PauseMenuUI.onResume(function()
		paused = false
		PauseMenuUI.setVisible(false)
	end)

	PauseMenuUI.onLeave(function()
		paused = false
		PauseMenuUI.setVisible(false)
		Remotes.fireServer("LeaveMatch", {})
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.Escape and inMatch then
			paused = not paused
			PauseMenuUI.setVisible(paused)
		end
	end)

	Remotes.onClientEvent("MatchStateChanged", function(payload)
		if payload.state == "Running" then
			inMatch = true
			paused = false
			PauseMenuUI.setVisible(false)
		else
			inMatch = false
			paused = false
			PauseMenuUI.setVisible(false)
		end
	end)
end

return PauseController
