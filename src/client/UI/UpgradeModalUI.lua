--!strict
--[[
    File:    UpgradeModalUI.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.UI.UpgradeModalUI
    Purpose: Модал-окно с тремя апгрейдами при level-up.
]]

local Players = game:GetService("Players")
local UpgradeModalUI = {}

local screen: ScreenGui
local dim: Frame
local title: TextLabel
local pendingBadge: Frame
local pendingLabel: TextLabel

local RARITY_COLORS = {
	common    = Color3.fromRGB(120, 200, 255),
	uncommon  = Color3.fromRGB(120, 255, 140),
	rare      = Color3.fromRGB(255, 200, 80),
	epic      = Color3.fromRGB(220, 120, 255),
	legendary = Color3.fromRGB(255, 100, 100),
}

-- Фолбэк-описание, если у апгрейда не задан description в Upgrades.lua.
local function autoDescribe(opt): string
	local e = opt.effect or {}
	local parts = {}
	if e.unlock then table.insert(parts, "Unlock " .. tostring(e.unlock)) end
	if e.weaponDamage then table.insert(parts, "+" .. tostring(e.weaponDamage) .. " weapon damage") end
	if e.projectiles then table.insert(parts, "+" .. tostring(e.projectiles) .. " projectiles") end
	if e.maxHp then table.insert(parts, "+" .. tostring(e.maxHp) .. " max HP") end
	if e.moveSpeed then table.insert(parts, "+" .. math.floor(e.moveSpeed * 100) .. "% speed") end
	if e.pickupRadius then table.insert(parts, "+" .. tostring(e.pickupRadius) .. " pickup radius") end
	if e.damageMult then table.insert(parts, "+" .. math.floor(e.damageMult * 100) .. "% damage") end
	if e.luck then table.insert(parts, "+" .. math.floor(e.luck * 100) .. "% luck") end
	if e.critChance then table.insert(parts, "+" .. math.floor(e.critChance * 100) .. "% crit chance") end
	if e.critMult then table.insert(parts, "+" .. math.floor(e.critMult * 100) .. "% crit damage") end
	if e.bulletRadius then table.insert(parts, "+" .. tostring(e.bulletRadius) .. " bullet radius") end
	if e.aoeRadius then table.insert(parts, "+" .. tostring(e.aoeRadius) .. " AoE radius") end
	return table.concat(parts, "\n")
end

local function titleOf(opt): string
	if opt.displayName then return tostring(opt.displayName) end
	if opt.weapon then return string.upper(opt.weapon) end
	if opt.passive then return string.upper(opt.passive:gsub("_", " ")) end
	return tostring(opt.id)
end

local function describeOption(opt): (string, string)
	local name = titleOf(opt)
	local desc = opt.description or autoDescribe(opt)
	return name, desc
end

function UpgradeModalUI.build()
	local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
	screen = Instance.new("ScreenGui")
	screen.Name = "UpgradeModal"
	screen.Enabled = false
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 50
	screen.Parent = pg

	dim = Instance.new("Frame")
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	dim.BackgroundTransparency = 0.4
	dim.BorderSizePixel = 0
	dim.Parent = screen

	title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 600, 0, 60)
	title.Position = UDim2.new(0.5, -300, 0.5, -260)
	title.BackgroundTransparency = 1
	title.Text = "LEVEL UP!"
	title.TextColor3 = Color3.fromRGB(255, 220, 120)
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.Parent = dim

	-- Бейдж "+N" в правом верхнем углу: сколько ещё апгрейдов в очереди.
	pendingBadge = Instance.new("Frame")
	pendingBadge.Size = UDim2.new(0, 70, 0, 70)
	pendingBadge.Position = UDim2.new(1, -90, 0, 20)
	pendingBadge.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
	pendingBadge.BorderSizePixel = 0
	pendingBadge.Visible = false
	pendingBadge.Parent = dim
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = pendingBadge
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 3
	stroke.Parent = pendingBadge
	pendingLabel = Instance.new("TextLabel")
	pendingLabel.Size = UDim2.fromScale(1, 1)
	pendingLabel.BackgroundTransparency = 1
	pendingLabel.Text = "+1"
	pendingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	pendingLabel.Font = Enum.Font.GothamBlack
	pendingLabel.TextScaled = true
	pendingLabel.Parent = pendingBadge
end

-- Обновить бейдж "+N" без перерисовки модалки. Используется когда сервер
-- увеличивает очередь во время уже открытой модалки.
function UpgradeModalUI.setPending(n: number)
	if not pendingBadge or not pendingLabel then return end
	if (n or 0) > 0 then
		pendingLabel.Text = "+" .. tostring(n)
		pendingBadge.Visible = true
	else
		pendingBadge.Visible = false
	end
end

function UpgradeModalUI.show(options, onChoose: (string) -> (), pending: number?)
	if not screen then return end
	UpgradeModalUI.setPending(pending or 0)
	-- очистить предыдущие карточки
	for _, c in ipairs(dim:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	local count = #options
	local cardW = 240
	local gap = 20
	local totalW = count * cardW + (count - 1) * gap
	local startX = -totalW / 2
	for i, opt in ipairs(options) do
		local name, desc = describeOption(opt)
		local color = RARITY_COLORS[opt.rarity or "common"] or RARITY_COLORS.common
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, cardW, 0, 320)
		b.Position = UDim2.new(0.5, startX + (i - 1) * (cardW + gap), 0.5, -160)
		b.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
		b.BorderSizePixel = 0
		b.AutoButtonColor = true
		b.Text = ""
		b.Parent = dim

		local stroke = Instance.new("UIStroke")
		stroke.Color = color
		stroke.Thickness = 3
		stroke.Parent = b

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(1, -20, 0, 60)
		nameLbl.Position = UDim2.new(0, 10, 0, 14)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = string.upper(name)
		nameLbl.TextColor3 = color
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.TextScaled = true
		nameLbl.Parent = b

		local lvlLbl = Instance.new("TextLabel")
		lvlLbl.Size = UDim2.new(1, -20, 0, 30)
		lvlLbl.Position = UDim2.new(0, 10, 0, 80)
		lvlLbl.BackgroundTransparency = 1
		lvlLbl.Text = opt.level and ("Lvl " .. tostring(opt.level)) or (opt.rarity or "")
		lvlLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
		lvlLbl.Font = Enum.Font.Gotham
		lvlLbl.TextScaled = true
		lvlLbl.Parent = b

		local descLbl = Instance.new("TextLabel")
		descLbl.Size = UDim2.new(1, -20, 1, -150)
		descLbl.Position = UDim2.new(0, 10, 0, 120)
		descLbl.BackgroundTransparency = 1
		descLbl.Text = desc
		descLbl.TextColor3 = Color3.fromRGB(230, 230, 230)
		descLbl.Font = Enum.Font.Gotham
		descLbl.TextWrapped = true
		descLbl.TextSize = 16
		descLbl.TextYAlignment = Enum.TextYAlignment.Top
		descLbl.Parent = b

		b.MouseButton1Click:Connect(function() onChoose(opt.id) end)
	end
	screen.Enabled = true
end

function UpgradeModalUI.hide()
	if screen then screen.Enabled = false end
end

return UpgradeModalUI
