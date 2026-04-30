--!strict
--[[
    File:    CameraController.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.Controllers.CameraController
    Purpose: Top-down камера, фиксированный угол, следует за персонажем.
             См. PLAN §5.2.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local CameraController = {}

local camera = Workspace.CurrentCamera
local HEIGHT = 50
local ANGLE_DEG = 65

function CameraController.init()
	camera.CameraType = Enum.CameraType.Scriptable
	RunService.RenderStepped:Connect(function()
		local char = Players.LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local target = hrp.Position
		local cf = CFrame.new(target + Vector3.new(0, HEIGHT, HEIGHT * 0.4), target)
		camera.CFrame = cf * CFrame.Angles(math.rad(-ANGLE_DEG + 90), 0, 0) * CFrame.new()
	end)
end

return CameraController
