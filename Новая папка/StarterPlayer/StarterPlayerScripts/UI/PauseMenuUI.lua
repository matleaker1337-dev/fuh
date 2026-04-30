--!strict
--[[
    File:    PauseMenuUI.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.UI.PauseMenuUI
    Purpose: Меню паузы (Resume / Settings / Leave).
             Внимание: реальной паузы симуляции нет в multiplayer-сервере.
]]

local Players = game:GetService("Players")
local PauseMenuUI = {}

local screen: ScreenGui

function PauseMenuUI.build()
	local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
	screen = Instance.new("ScreenGui")
	screen.Name = "Pause"
	screen.Enabled = false
	screen.ResetOnSpawn = false
	screen.Parent = pg
end

function PauseMenuUI.setVisible(v: boolean)
	if screen then screen.Enabled = v end
end

return PauseMenuUI
