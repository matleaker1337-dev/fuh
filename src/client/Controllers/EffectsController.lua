--!strict
--[[
    File:    EffectsController.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.Controllers.EffectsController
    Purpose: VFX/SFX: damage numbers, particles, screen shake. Полностью
             на клиенте, серверу не платим.
]]

local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local EffectsController = {}

function EffectsController.init() end

function EffectsController.spawnDamageNumber(pos: Vector3, value: number, crit: boolean?)
	local part = Instance.new("Part")
	part.Anchored = true; part.CanCollide = false; part.Transparency = 1
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Position = pos + Vector3.new(0, 3, 0)
	part.Parent = Workspace

	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.new(0, 80, 0, 30)
	bg.AlwaysOnTop = true
	bg.Parent = part
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Text = tostring(value)
	label.TextColor3 = crit and Color3.fromRGB(255, 220, 80) or Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = bg

	TweenService:Create(part, TweenInfo.new(0.6), { Position = part.Position + Vector3.new(0, 4, 0) }):Play()
	TweenService:Create(label, TweenInfo.new(0.6), { TextTransparency = 1 }):Play()
	task.delay(0.7, function() part:Destroy() end)
end

return EffectsController
