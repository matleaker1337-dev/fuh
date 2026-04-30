--!strict
--[[
    File:    PauseMenuUI.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.UI.PauseMenuUI
    Purpose: Меню паузы (Resume / Leave Match).
]]

local Players = game:GetService("Players")
local PauseMenuUI = {}

local screen: ScreenGui
local resumeCb: (() -> ())? = nil
local leaveCb: (() -> ())? = nil

local function makeButton(parent, text, posY, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 260, 0, 50)
	b.Position = UDim2.new(0.5, -130, 0.5, posY)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Parent = parent
	return b
end

function PauseMenuUI.build()
	local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
	screen = Instance.new("ScreenGui")
	screen.Name = "Pause"
	screen.Enabled = false
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 40
	screen.Parent = pg

	local dim = Instance.new("Frame")
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	dim.BackgroundTransparency = 0.5
	dim.BorderSizePixel = 0
	dim.Parent = screen

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 400, 0, 60)
	title.Position = UDim2.new(0.5, -200, 0.5, -120)
	title.BackgroundTransparency = 1
	title.Text = "PAUSED"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBlack
	title.Parent = dim

	local resumeBtn = makeButton(dim, "RESUME", -30, Color3.fromRGB(40, 80, 60))
	resumeBtn.MouseButton1Click:Connect(function()
		if resumeCb then resumeCb() end
	end)

	local leaveBtn = makeButton(dim, "LEAVE MATCH", 40, Color3.fromRGB(120, 40, 40))
	leaveBtn.MouseButton1Click:Connect(function()
		if leaveCb then leaveCb() end
	end)
end

function PauseMenuUI.setVisible(v: boolean)
	if screen then screen.Enabled = v end
end

function PauseMenuUI.onResume(cb) resumeCb = cb end
function PauseMenuUI.onLeave(cb) leaveCb = cb end

return PauseMenuUI
