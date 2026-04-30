--!strict
--[[
    File:    EnemyService.lua
    Type:    ModuleScript
    Place:   game.ServerScriptService.Services.EnemyService
    Purpose: Спавн, тик и уничтожение врагов. Использует EnemyAI для логики.
             Каждый враг — анкоред Part в Workspace.Enemies, чьи координаты
             синкаются с enemy.position на сервером тике (Heartbeat).
]]

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EntityRegistry = require(ReplicatedStorage.Modules.EntityRegistry)
local EnemyAI = require(ReplicatedStorage.Modules.EnemyAI)

local EnemyService = {}

local enemies = EntityRegistry.new()
local container: Folder? = nil

local function getContainer(): Folder
	if container and container.Parent then
		return container
	end
	local existing = Workspace:FindFirstChild("Enemies")
	if existing and existing:IsA("Folder") then
		container = existing
	else
		local f = Instance.new("Folder")
		f.Name = "Enemies"
		f.Parent = Workspace
		container = f
	end
	return container :: Folder
end

function EnemyService.init()
	-- Тиковый луп AI + синк позиции в Workspace. Безопасно к остановкам:
	-- если registry пустой, никого не дёргаем.
	RunService.Heartbeat:Connect(function(dt)
		enemies:forEach(function(enemy)
			-- pcall чтобы один кривой враг не валил весь луп.
			local ok, err = pcall(EnemyAI.update, enemy, dt)
			if not ok then
				warn(("[EnemyService] AI error for %s: %s"):format(
					tostring(enemy.def and enemy.def.id), tostring(err)))
			end
			if enemy.part and enemy.part.Parent then
				enemy.part.Position = enemy.position
			end
		end)
	end)
end

function EnemyService.getRegistry()
	return enemies
end

function EnemyService.spawn(def, position: Vector3)
	if not def then return nil end

	local id = enemies:nextId()

	local part = Instance.new("Part")
	part.Name = (def.id or "enemy") .. "_" .. tostring(id)
	part.Size = def.size or Vector3.new(2, 4, 2)
	part.Color = def.color or Color3.fromRGB(180, 60, 60)
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Position = position
	part.Parent = getContainer()

	local enemy = {
		id = id,
		def = def,
		hp = def.hp,
		maxHp = def.hp,
		speed = def.speed,
		damage = def.damage,
		position = position,
		velocity = Vector3.zero,
		aiState = def.aiState,
		bossPhase = (def.aiState == "boss_brute") and "seek" or nil,
		bossPhaseTimer = 0,
		chargeDir = Vector3.zero,
		part = part,
		cooldowns = {},
		statusEffects = {},
	}
	enemies:add(id, enemy)
	return enemy
end

function EnemyService.kill(enemyId: number)
	local e = enemies:get(enemyId)
	if not e then return end
	if e.part then
		pcall(function() e.part:Destroy() end)
	end
	enemies:remove(enemyId)
end

function EnemyService.clearAll()
	enemies:forEach(function(enemy)
		if enemy.part then
			pcall(function() enemy.part:Destroy() end)
		end
	end)
	enemies:clear()
end

return EnemyService
