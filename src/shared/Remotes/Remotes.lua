--!strict
--[[
    File:    Remotes.lua
    Type:    ModuleScript
    Place:   game.ReplicatedStorage.Remotes.Remotes
    Purpose: Единая точка создания и доступа к RemoteEvent / RemoteFunction.
             Сервер вызывает .init() для создания инстансов, обе стороны
             используют :fireClient/:invokeServer/:onEvent через обёртки.
             См. PLAN §7.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

local FOLDER_NAME = "RemoteInstances"

local EVENTS = {
	-- s2c
	"MatchStateChanged", "OfferUpgrades", "PendingUpgrades", "DamageNumbers",
	"PlayerStats", "Notification", "WaveChanged",
	-- c2s
	"MoveInput", "ChooseUpgrade", "PauseRequest", "LeaveMatch", "SaveSettings",
}

local FUNCTIONS = {
	"BootstrapData", "RequestStartMatch",
}

local folder: Folder
local events: { [string]: RemoteEvent } = {}
local functions: { [string]: RemoteFunction } = {}

function Remotes.init()
	if not RunService:IsServer() then return end
	folder = ReplicatedStorage:FindFirstChild(FOLDER_NAME) or Instance.new("Folder")
	folder.Name = FOLDER_NAME
	folder.Parent = ReplicatedStorage

	for _, name in ipairs(EVENTS) do
		local r = folder:FindFirstChild(name) or Instance.new("RemoteEvent")
		r.Name = name; r.Parent = folder
		events[name] = r
	end
	for _, name in ipairs(FUNCTIONS) do
		local r = folder:FindFirstChild(name) or Instance.new("RemoteFunction")
		r.Name = name; r.Parent = folder
		functions[name] = r
	end
end

local function getFolder(): Folder
	if folder then return folder end
	folder = ReplicatedStorage:WaitForChild(FOLDER_NAME)
	return folder
end

local function getEvent(name: string): RemoteEvent
	if events[name] then return events[name] end
	local r = getFolder():WaitForChild(name) :: RemoteEvent
	events[name] = r
	return r
end

local function getFunction(name: string): RemoteFunction
	if functions[name] then return functions[name] end
	local r = getFolder():WaitForChild(name) :: RemoteFunction
	functions[name] = r
	return r
end

function Remotes.fireClient(player: Player, name: string, payload)
	getEvent(name):FireClient(player, payload)
end

function Remotes.fireAllClients(name: string, payload)
	getEvent(name):FireAllClients(payload)
end

function Remotes.fireServer(name: string, payload)
	getEvent(name):FireServer(payload)
end

function Remotes.invokeServer(name: string, payload)
	return getFunction(name):InvokeServer(payload)
end

function Remotes.onEvent(name: string, callback: (Player, any) -> ())
	getEvent(name).OnServerEvent:Connect(callback)
end

function Remotes.onClientEvent(name: string, callback: (any) -> ())
	getEvent(name).OnClientEvent:Connect(callback)
end

function Remotes.onFunction(name: string, callback: (Player, any) -> any)
	getFunction(name).OnServerInvoke = callback
end

return Remotes
