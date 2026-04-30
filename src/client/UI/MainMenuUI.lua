--!strict
--[[
    File:    MainMenuUI.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.UI.MainMenuUI
    Purpose: Билд экрана главного меню (Play / Settings / ...).
             Чистая «view»-функция: callback'и наружу через MenuController.
]]

local Players = game:GetService("Players")
local MainMenuUI = {}

local screen: ScreenGui
local playClickedCb: () -> ()? = nil
local settingsClickedCb: () -> ()? = nil

local function makeButton(parent, text, posY)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 240, 0, 50)
	b.Position = UDim2.new(0.5, -120, 0, posY)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Parent = parent
	return b
end

function MainMenuUI.build()
	local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
	screen = Instance.new("ScreenGui")
	screen.Name = "MainMenu"
	screen.ResetOnSpawn = false
	screen.Parent = pg

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 80)
	title.Position = UDim2.new(0, 0, 0.15, 0)
	title.BackgroundTransparency = 1
	title.Text = "BULLET HEAVEN"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBlack
	title.Parent = screen

	local play = makeButton(screen, "PLAY", 320)
	local sett = makeButton(screen, "SETTINGS", 380)

	play.MouseButton1Click:Connect(function() if playClickedCb then playClickedCb() end end)
	sett.MouseButton1Click:Connect(function() if settingsClickedCb then settingsClickedCb() end end)
end

function MainMenuUI.setVisible(v: boolean)
	if screen then screen.Enabled = v end
end

function MainMenuUI.setProfile(p) end -- TODO: показать монеты, ник

function MainMenuUI.onPlayClicked(cb) playClickedCb = cb end
function MainMenuUI.onSettingsClicked(cb) settingsClickedCb = cb end

return MainMenuUI
