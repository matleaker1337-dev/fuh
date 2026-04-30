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

return MapSelectUI
