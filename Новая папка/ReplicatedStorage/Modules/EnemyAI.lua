--!strict
--[[
    File:    EnemyAI.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Modules.EnemyAI
    Purpose: Чистая логика поведения врагов. Без сторонних эффектов кроме
             мутации полей самого врага. Вызывается с серверного тика.
             См. PLAN §3.3.
]]

local Players = game:GetService("Players")

local EnemyAI = {}

local function nearestPlayerPos(from: Vector3): (Vector3?, Player?)
	local best, bestDist, bestPlayer = nil, math.huge, nil
	for _, p in ipairs(Players:GetPlayers()) do
		local char = p.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local d = (hrp.Position - from).Magnitude
			if d < bestDist then
				bestDist, best, bestPlayer = d, hrp.Position, p
			end
		end
	end
	return best, bestPlayer
end

function EnemyAI.update(enemy, dt: number)
	local target = nearestPlayerPos(enemy.position)
	if not target then return end

	if enemy.aiState == "seek" or enemy.aiState == "swarm" then
		local dir = (target - enemy.position)
		local mag = dir.Magnitude
		if mag > 0.001 then
			enemy.velocity = (dir / mag) * enemy.speed
			enemy.position += enemy.velocity * dt
		end
	elseif enemy.aiState == "ranged" then
		local d = (target - enemy.position).Magnitude
		local minR, maxR = enemy.def.rangedRange[1], enemy.def.rangedRange[2]
		if d > maxR then
			enemy.position += (target - enemy.position).Unit * enemy.speed * dt
		elseif d < minR then
			enemy.position -= (target - enemy.position).Unit * enemy.speed * dt
		end
		enemy.cooldowns.shoot = (enemy.cooldowns.shoot or 0) - dt
		if enemy.cooldowns.shoot <= 0 then
			enemy.cooldowns.shoot = enemy.def.rangedCooldown
			-- TODO: CombatService.spawnEnemyBullet(enemy, target)
		end
	elseif enemy.aiState == "boss" then
		-- TODO: phase machine, см. PLAN §3.3
	elseif enemy.aiState == "boss_brute" then
		-- Brute: обычно идёт к игроку. Когда близко — телеграфит, потом
		-- делает рывок ×4 скорости, затем кулдаун.
		local def = enemy.def
		local d = (target - enemy.position).Magnitude
		local phase = enemy.bossPhase or "seek"
		if phase == "seek" then
			local dir = (target - enemy.position)
			if dir.Magnitude > 0.001 then
				enemy.position += dir.Unit * enemy.speed * dt
			end
			enemy.cooldowns.charge = (enemy.cooldowns.charge or 0) - dt
			if d <= (def.chargeRange or 18) and (enemy.cooldowns.charge or 0) <= 0 then
				enemy.bossPhase = "windup"
				enemy.bossPhaseTimer = def.chargeWindup or 1.0
				-- Сохранить направление для рывка.
				enemy.chargeDir = (target - enemy.position).Unit
			end
		elseif phase == "windup" then
			-- Стоит, "заводится". (Визуал — в EnemyService через Highlight.)
			enemy.bossPhaseTimer -= dt
			if enemy.bossPhaseTimer <= 0 then
				enemy.bossPhase = "charge"
				enemy.bossPhaseTimer = def.chargeDuration or 0.6
				-- Перенацелим в момент срабатывания (немного честнее, но и
				-- не идеально точно — игрок может увернуться).
				enemy.chargeDir = (target - enemy.position).Unit
			end
		elseif phase == "charge" then
			if enemy.chargeDir then
				enemy.position += enemy.chargeDir * enemy.speed * (def.chargeSpeedMult or 4) * dt
			end
			enemy.bossPhaseTimer -= dt
			if enemy.bossPhaseTimer <= 0 then
				enemy.bossPhase = "seek"
				enemy.cooldowns.charge = def.chargeCooldown or 2.5
			end
		end
	end
end

return EnemyAI
