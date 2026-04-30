--!strict
--[[
    File:    ResultsUI.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.UI.ResultsUI
    Purpose: Экран итогов забега.
]]

local Players = game:GetService("Players")
local ResultsUI = {}

local screen: ScreenGui

function ResultsUI.build()
	local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
	screen = Instance.new("ScreenGui")
	screen.Name = "Results"
	screen.Enabled = false
	screen.ResetOnSpawn = false
	screen.Parent = pg
end

function ResultsUI.show(stats, onContinue: () -> ())
	if not screen then return end
	screen:ClearAllChildren()
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 400, 0, 200)
	label.Position = UDim2.new(0.5, -200, 0.5, -100)
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = string.format("Time %ds\nKills %d\nLevel %d",
		stats.time or 0, stats.kills or 0, stats.level or 1)
	label.Parent = screen

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 200, 0, 50)
	btn.Position = UDim2.new(0.5, -100, 0.5, 120)
	btn.Text = "CONTINUE"
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(40, 80, 60)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Parent = screen
	btn.MouseButton1Click:Connect(onContinue)

	screen.Enabled = true
end

function ResultsUI.hide()
	if screen then screen.Enabled = false end
end

return ResultsUI
