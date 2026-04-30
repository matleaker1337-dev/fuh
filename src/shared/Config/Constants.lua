--!strict
--[[
    File:    Constants.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Config.Constants
    Purpose: Глобальные константы геймплея.
]]

return {
	SERVER_TICK_RATE = 20,
	CLIENT_RENDER_RATE = 60,
	MAX_ENEMIES = 200,
	MAX_BULLETS = 500,
	MAX_PICKUPS = 300,
	DEFAULT_PICKUP_RADIUS = 6,
	SPAWN_RING_INNER = 60,
	SPAWN_RING_OUTER = 90,
	UPGRADE_OFFER_TIMEOUT = 15,
}
