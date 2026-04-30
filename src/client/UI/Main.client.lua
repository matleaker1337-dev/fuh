--!strict
--[[
    File:    Main.client.lua
    Type:    LocalScript (entry point)
    Place:   game.StarterPlayer.StarterPlayerScripts.Main
    Purpose: Клиентский bootstrap. Подгружает контроллеры, запрашивает
             BootstrapData, отдаёт управление MenuController.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Remotes.Remotes)

local Controllers = script.Parent.Parent:WaitForChild("Controllers")
local InputController    = require(Controllers.InputController)
local CameraController   = require(Controllers.CameraController)
local MenuController     = require(Controllers.MenuController)
local MapSelectController = require(Controllers.MapSelectController)
local HUDController      = require(Controllers.HUDController)
local UpgradeController  = require(Controllers.UpgradeController)
local CombatController   = require(Controllers.CombatController)
local EffectsController  = require(Controllers.EffectsController)
local PauseController    = require(Controllers.PauseController)

local player = Players.LocalPlayer

InputController.init()
CameraController.init()
EffectsController.init()
HUDController.init()
UpgradeController.init()
CombatController.init()
MapSelectController.init()
PauseController.init()
MenuController.init()

-- Запрос профиля. Сервер должен ответить мгновенно.
local boot = Remotes.invokeServer("BootstrapData", {})
MenuController.onBootstrap(boot)

print("[Bullet Heaven] Client boot complete for", player.Name)
