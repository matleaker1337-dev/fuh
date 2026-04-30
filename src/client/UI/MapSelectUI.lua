--!strict
--[[
    File:    MapSelectUI.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.UI.MapSelectUI
    Purpose: Сетка карточек карт с превью и кнопкой Play.
]]

local Players = game:GetService("Players")
local MapSelectUI = {}

local screen: ScreenGui
local mapSelectedCb: ((string) -> ())? = nil
local backCb: (() -> ())? = nil

function MapSelectUI.build()
	local pg = Players.LocalPlayer:WaitForChild("PlayerGui")

	for _, child in ipairs(pg:GetChildren()) do
		if child:IsA("ScreenGui") and child.Name == "MapSelect" then
			child:Destroy()
		end
	end

	screen = Instance.new("ScreenGui")
	screen.Name = "MapSelect"
	screen.Enabled = false
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 10
	screen.Parent = pg
end

function MapSelectUI.populate(maps)
	if not screen then return end
	for _, child in ipairs(screen:GetChildren()) do child:Destroy() end

	-- Заголовок
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 60)
	header.Position = UDim2.new(0, 0, 0, 20)
	header.BackgroundTransparency = 1
	header.Text = "SELECT MAP"
	header.TextColor3 = Color3.fromRGB(255, 255, 255)
	header.TextScaled = true
	header.Font = Enum.Font.GothamBlack
	header.Parent = screen

	-- Кнопка BACK
	local back = Instance.new("TextButton")
	back.Size = UDim2.new(0, 120, 0, 40)
	back.Position = UDim2.new(0, 30, 0, 30)
	back.Text = "← BACK"
	back.Font = Enum.Font.GothamBold
	back.TextScaled = true
	back.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
	back.TextColor3 = Color3.fromRGB(255, 255, 255)
	back.Parent = screen
	back.MouseButton1Click:Connect(function()
		if backCb then backCb() end
	end)

	local i = 0
	for id, def in pairs(maps) do
		local card = Instance.new("TextButton")
		card.Size = UDim2.new(0, 220, 0, 140)
		card.Position = UDim2.new(0, 40 + (i % 4) * 240, 0, 120 + math.floor(i / 4) * 160)
		card.Text = def.displayName .. "\nDifficulty " .. def.difficulty
		card.Font = Enum.Font.Gotham
		card.TextScaled = true
		card.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
		card.TextColor3 = Color3.fromRGB(255, 255, 255)
		card.Parent = screen
		card.MouseButton1Click:Connect(function()
			if mapSelectedCb then mapSelectedCb(id) end
		end)
		i += 1
	end
end

function MapSelectUI.setVisible(v: boolean)
	if screen then screen.Enabled = v end
end

function MapSelectUI.onMapSelected(cb) mapSelectedCb = cb end
function MapSelectUI.onBackClicked(cb) backCb = cb end

return MapSelectUI
