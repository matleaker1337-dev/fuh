--!strict
--[[
    File:    HUDUI.lua
    Type:    ModuleScript
    Place:   game.StarterPlayer.StarterPlayerScripts.UI.HUDUI
    Purpose: HP/XP бары, таймер, счётчик килов, индикатор уровня.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local HUDUI = {}

local screen: ScreenGui
local hpBar: Frame
local hpText: TextLabel
local xpBar: Frame
local xpText: TextLabel
local timerLabel: TextLabel
local killsLabel: TextLabel
local levelLabel: TextLabel
local waveLabel: TextLabel

local XP_TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HP_TWEEN_INFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local lastLevel = 1

function HUDUI.build()
	local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
	screen = Instance.new("ScreenGui")
	screen.Name = "HUD"
	screen.Enabled = false
	screen.ResetOnSpawn = false
	screen.Parent = pg

	local hpBg = Instance.new("Frame")
	hpBg.Size = UDim2.new(0, 320, 0, 22)
	hpBg.Position = UDim2.new(0, 20, 1, -64)
	hpBg.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
	hpBg.BorderSizePixel = 0
	hpBg.Parent = screen
	hpBar = Instance.new("Frame")
	hpBar.Size = UDim2.fromScale(1, 1)
	hpBar.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
	hpBar.BorderSizePixel = 0
	hpBar.Parent = hpBg
	hpText = Instance.new("TextLabel")
	hpText.Size = UDim2.fromScale(1, 1)
	hpText.BackgroundTransparency = 1
	hpText.Text = "0 / 0"
	hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
	hpText.TextStrokeTransparency = 0.4
	hpText.Font = Enum.Font.GothamBold
	hpText.TextSize = 14
	hpText.ZIndex = 2
	hpText.Parent = hpBg

	local xpBg = Instance.new("Frame")
	xpBg.Size = UDim2.new(0, 320, 0, 14)
	xpBg.Position = UDim2.new(0, 20, 1, -38)
	xpBg.BackgroundColor3 = Color3.fromRGB(0, 30, 30)
	xpBg.BorderSizePixel = 0
	xpBg.Parent = screen
	xpBar = Instance.new("Frame")
	xpBar.Size = UDim2.fromScale(0, 1)
	xpBar.BackgroundColor3 = Color3.fromRGB(60, 200, 240)
	xpBar.BorderSizePixel = 0
	xpBar.Parent = xpBg
	xpText = Instance.new("TextLabel")
	xpText.Size = UDim2.fromScale(1, 1)
	xpText.BackgroundTransparency = 1
	xpText.Text = "Lv 1   0 / 0"
	xpText.TextColor3 = Color3.fromRGB(255, 255, 255)
	xpText.TextStrokeTransparency = 0.5
	xpText.Font = Enum.Font.GothamBold
	xpText.TextSize = 12
	xpText.ZIndex = 2
	xpText.Parent = xpBg

	timerLabel = Instance.new("TextLabel")
	timerLabel.Size = UDim2.new(0, 200, 0, 36)
	timerLabel.Position = UDim2.new(0.5, -100, 0, 10)
	timerLabel.BackgroundTransparency = 1
	timerLabel.Text = "00:00"
	timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	timerLabel.TextScaled = true
	timerLabel.Font = Enum.Font.GothamBold
	timerLabel.Parent = screen

	killsLabel = Instance.new("TextLabel")
	killsLabel.Size = UDim2.new(0, 120, 0, 24)
	killsLabel.Position = UDim2.new(1, -140, 0, 10)
	killsLabel.BackgroundTransparency = 1
	killsLabel.Text = "Kills: 0"
	killsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	killsLabel.TextScaled = true
	killsLabel.Font = Enum.Font.Gotham
	killsLabel.Parent = screen

	-- Номер волны и прогресс убийств.
	waveLabel = Instance.new("TextLabel")
	waveLabel.Size = UDim2.new(0, 240, 0, 28)
	waveLabel.Position = UDim2.new(0.5, -120, 0, 50)
	waveLabel.BackgroundTransparency = 1
	waveLabel.Text = "Wave 1   0 / 25"
	waveLabel.TextColor3 = Color3.fromRGB(255, 220, 120)
	waveLabel.TextStrokeTransparency = 0.4
	waveLabel.TextScaled = true
	waveLabel.Font = Enum.Font.GothamBlack
	waveLabel.Parent = screen

	-- levelLabel оставлен скрытым: xpText уже показывает "Lv N" внутри бара.
	levelLabel = Instance.new("TextLabel")
	levelLabel.Visible = false
	levelLabel.Parent = screen
end

function HUDUI.setVisible(v: boolean)
	if screen then screen.Enabled = v end
end

local function tweenSize(frame: Frame, target: UDim2, info: TweenInfo)
	TweenService:Create(frame, info, { Size = target }):Play()
end

function HUDUI.update(stats)
	if hpBar and stats.hp and stats.maxHp and stats.maxHp > 0 then
		local pct = math.clamp(stats.hp / stats.maxHp, 0, 1)
		tweenSize(hpBar, UDim2.fromScale(pct, 1), HP_TWEEN_INFO)
		if hpText then
			hpText.Text = string.format("%d / %d", math.floor(stats.hp + 0.5), math.floor(stats.maxHp + 0.5))
		end
	end
	if xpBar and stats.xp and stats.xpToNext and stats.xpToNext > 0 then
		local pct = math.clamp(stats.xp / stats.xpToNext, 0, 1)
		-- Если уровень изменился — XP-бар уже сбросился на 0 в state, тянем плавно.
		if stats.level and stats.level ~= lastLevel then
			lastLevel = stats.level
			-- мгновенно "схлопываем" в 0 чтобы не тянуло справа налево
			xpBar.Size = UDim2.fromScale(0, 1)
		end
		tweenSize(xpBar, UDim2.fromScale(pct, 1), XP_TWEEN_INFO)
		if xpText then
			xpText.Text = string.format("Lv %d   %d / %d",
				stats.level or 1,
				math.floor(stats.xp + 0.5),
				math.floor(stats.xpToNext + 0.5))
		end
	end
	if timerLabel and stats.time then
		-- Счётчик идёт ВВЕРХ (elapsed). Прогресс определяется волнами, не временем.
		local elapsed = math.max(0, math.floor(stats.time))
		timerLabel.Text = string.format("%02d:%02d", elapsed // 60, elapsed % 60)
	end
	if waveLabel and stats.wave then
		local w = stats.wave
		if w.isBoss then
			waveLabel.Text = string.format("BOSS WAVE %d", w.index or 1)
			waveLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		else
			waveLabel.Text = string.format("Wave %d   %d / %d",
				w.index or 1, w.killed or 0, w.total or 0)
			waveLabel.TextColor3 = Color3.fromRGB(255, 220, 120)
		end
	end
	if killsLabel and stats.kills then
		killsLabel.Text = "Kills: " .. tostring(stats.kills)
	end
	if levelLabel and stats.level then
		levelLabel.Text = "Lv " .. tostring(stats.level)
	end
end

return HUDUI
