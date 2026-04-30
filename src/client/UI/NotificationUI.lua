--!strict
--[[
    File:    NotificationUI.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.UI.NotificationUI
    Purpose: Тост-уведомления (weapon unlocked, wave started, и т.д.).
             Появляются сверху-по-центру и исчезают через 3 секунды.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local NotificationUI = {}

local screen: ScreenGui
local nextY = 0

function NotificationUI.build()
	local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
	screen = Instance.new("ScreenGui")
	screen.Name = "Notifications"
	screen.Enabled = true
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 60
	screen.Parent = pg
end

function NotificationUI.show(text: string, color: Color3?)
	if not screen then return end
	local c = color or Color3.fromRGB(255, 255, 255)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 400, 0, 36)
	label.Position = UDim2.new(0.5, -200, 0, 90 + nextY)
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	label.BackgroundTransparency = 0.3
	label.TextColor3 = c
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextTransparency = 0
	label.Parent = screen

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = label

	nextY += 42

	task.delay(2.0, function()
		TweenService:Create(label, TweenInfo.new(0.5), { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
		task.delay(0.6, function()
			label:Destroy()
			nextY = math.max(0, nextY - 42)
		end)
	end)
end

return NotificationUI
