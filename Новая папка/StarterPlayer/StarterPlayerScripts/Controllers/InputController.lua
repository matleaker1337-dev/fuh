--!strict
--[[
    File:    InputController.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.Controllers.InputController
    Purpose: WASD / стик → отправка MoveInput на сервер 20 Hz, локальное
             предсказание позиции.
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes.Remotes)

local InputController = {}

local seq = 0
local sendAccum = 0

function InputController.init()
	RunService.Heartbeat:Connect(function(dt)
		sendAccum += dt
		if sendAccum < 1/20 then return end
		local d = sendAccum
		sendAccum = 0

		local dir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Vector3.new(0,0,-1) end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir += Vector3.new(0,0,1) end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir += Vector3.new(-1,0,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Vector3.new(1,0,0) end
		if dir.Magnitude > 0 then dir = dir.Unit end

		seq += 1
		Remotes.fireServer("MoveInput", { dir = dir, dt = d, seq = seq })
	end)
end

return InputController
