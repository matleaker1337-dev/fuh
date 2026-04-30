--!strict
--[[
    File:    ResultsUI.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.UI.ResultsUI
    Purpose: Экран итогов забега с подробной статистикой.
]]

local Players = game:GetService("Players")
local ResultsUI = {}

local screen: ScreenGui

local function formatTime(s: number): string
	local m = math.floor(s / 60)
	local sec = math.floor(s % 60)
	return string.format("%d:%02d", m, sec)
end

local function makeStatRow(parent, label: string, value: string, posY: number)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(0, 360, 0, 32)
	row.Position = UDim2.new(0.5, -180, 0.5, posY)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = label
	lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
	lbl.Font = Enum.Font.Gotham
	lbl.TextScaled = true
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row

	local val = Instance.new("TextLabel")
	val.Size = UDim2.new(0.5, 0, 1, 0)
	val.Position = UDim2.new(0.5, 0, 0, 0)
	val.BackgroundTransparency = 1
	val.Text = value
	val.TextColor3 = Color3.fromRGB(255, 255, 255)
	val.Font = Enum.Font.GothamBold
	val.TextScaled = true
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Parent = row
end

function ResultsUI.build()
	local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
	screen = Instance.new("ScreenGui")
	screen.Name = "Results"
	screen.Enabled = false
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 30
	screen.Parent = pg
end

function ResultsUI.show(stats, onContinue: () -> ())
	if not screen then return end
	screen:ClearAllChildren()

	local dim = Instance.new("Frame")
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	dim.BackgroundTransparency = 0.4
	dim.BorderSizePixel = 0
	dim.Parent = screen

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 400, 0, 60)
	title.Position = UDim2.new(0.5, -200, 0.5, -180)
	title.BackgroundTransparency = 1
	title.Text = "MATCH OVER"
	title.TextColor3 = Color3.fromRGB(255, 220, 120)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBlack
	title.Parent = dim

	makeStatRow(dim, "Time Survived", formatTime(stats.time or 0), -100)
	makeStatRow(dim, "Enemies Killed", tostring(stats.kills or 0), -60)
	makeStatRow(dim, "Level Reached", tostring(stats.level or 1), -20)

	local coins = stats.coins or 0
	if coins > 0 then
		makeStatRow(dim, "Coins Earned", "+" .. tostring(coins), 20)
	end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 220, 0, 50)
	btn.Position = UDim2.new(0.5, -110, 0.5, 100)
	btn.Text = "CONTINUE"
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(40, 80, 60)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Parent = dim
	btn.MouseButton1Click:Connect(onContinue)

	screen.Enabled = true
end

function ResultsUI.hide()
	if screen then screen.Enabled = false end
end

return ResultsUI
