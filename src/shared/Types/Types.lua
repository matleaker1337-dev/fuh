--!strict
--[[
    File:    Types.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Types.Types
    Purpose: Общие Luau-типы, которые используют и сервер, и клиент.
             В Luau типы из ModuleScript можно re-export'ить, но проще
             держать как комментарий-документацию + return пустой таблицы.
]]

export type Vector3Lite = { x: number, y: number, z: number }

export type Profile = {
	version: number,
	coins: number,
	unlockedChars: { string },
	unlockedMaps: { string },
	bestRuns: { [string]: { time: number, level: number } },
	settings: { music: number, sfx: number },
	updatedAt: number,
}

export type Enemy = {
	id: number,
	def: any,
	hp: number, maxHp: number,
	speed: number, damage: number,
	position: Vector3, velocity: Vector3,
	aiState: string,
	model: Model?, part: BasePart?,
	cooldowns: { [string]: number },
	statusEffects: { any },
}

export type Bullet = {
	id: number, ownerId: number, weaponDef: any,
	pos: Vector3, vel: Vector3,
	ttl: number, damage: number,
}

export type UpgradeOption = {
	id: string, weapon: string?, passive: string?, level: number?,
	weight: number, effect: any, prerequisites: { string }?,
}

return {}
