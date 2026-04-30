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
local coinsLabel: TextLabel
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

	-- Уничтожаем дубликаты (напр. от старых скриптов в Studio)
	for _, child in ipairs(pg:GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "MainMenu" then
			child:Destroy()
		end
	end

	screen = Instance.new("ScreenGui")
	screen.Name = "MainMenu"
	screen.Enabled = false
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 10
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

	-- Монеты
	coinsLabel = Instance.new("TextLabel")
	coinsLabel.Size = UDim2.new(0, 200, 0, 36)
	coinsLabel.Position = UDim2.new(1, -220, 0, 20)
	coinsLabel.BackgroundTransparency = 1
	coinsLabel.Text = ""
	coinsLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
	coinsLabel.Font = Enum.Font.GothamBold
	coinsLabel.TextScaled = true
	coinsLabel.TextXAlignment = Enum.TextXAlignment.Right
	coinsLabel.Parent = screen

	local play = makeButton(screen, "PLAY", 320)
	local sett = makeButton(screen, "SETTINGS", 380)

	play.MouseButton1Click:Connect(function() if playClickedCb then playClickedCb() end end)
	sett.MouseButton1Click:Connect(function() if settingsClickedCb then settingsClickedCb() end end)
end

function MainMenuUI.setVisible(v: boolean)
	if screen then screen.Enabled = v end
end

function MainMenuUI.setProfile(p)
	if not p or not coinsLabel then return end
	local coins = p.coins or 0
	coinsLabel.Text = "Coins: " .. tostring(coins)
end

function MainMenuUI.onPlayClicked(cb) playClickedCb = cb end
function MainMenuUI.onSettingsClicked(cb) settingsClickedCb = cb end

return MainMenuUI
