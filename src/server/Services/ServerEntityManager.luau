local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = require(ReplicatedStorage.Shared.Network.Events)
local Entity = require(ReplicatedStorage.Shared.classes.Entity.Entity)
local PlayerEntity = require(ReplicatedStorage.Shared.classes.Entity.PlayerEntity)
local EventBuss = require(ReplicatedStorage.Shared.Utility.EventBuss)
local ServerEntityManager = {}

local _robloxPlayerMap = {}
local _modelPlayerMap = {}

local function playerAdd(robloxPlayer: Player, entity: PlayerEntity)
	print(robloxPlayer)
	_robloxPlayerMap[robloxPlayer] = entity
	_modelPlayerMap[robloxPlayer.Character] = entity
	print(_robloxPlayerMap)
end

local function playerRemove(robloxPlayer: Player)
	_robloxPlayerMap[robloxPlayer] = nil
	_modelPlayerMap[robloxPlayer.Character] = nil
end

-----------------
-- Event Hooks --
-----------------

local function onDeath(victim: Entity, killer: Entity)
	local robloxPlayer = victim:GetPlayer()
	victim:Destroy()
	playerRemove(robloxPlayer)
	Events.Player.Killed:Server():FireAll(victim, killer)
end

local function OnDamaged(damage: amount, source: Entity)
	print("OnDamaged")
end

-- EntityService.lua
EventBuss.Subscribe(EventBuss.Events.projectileHits, function(hits)
	for _, hit in hits do
		local model = hit.model
		local projectile = hit.projectile
		local entity = _modelPlayerMap[model]
		if entity then
			entity:TakeDamage(projectile:GetDamage(), projectile:GetOwner())
		end
	end
end)

-------------
-- Utility --
-------------

function ServerEntityManager.GetPlayers()
	return _robloxPlayerMap
end

function ServerEntityManager.GetPlayer(robloxPlayer: Player)
	return _robloxPlayerMap[robloxPlayer]
end

function ServerEntityManager.GetPlayerFromModel(robloxPlayer: Player)
	return _modelPlayerMap[robloxPlayer]
end

function ServerEntityManager.RemovePlayer(robloxPlayer: Player)
	local playerEntity = _robloxPlayerMap[robloxPlayer]
	playerEntity:Destroy()
	playerRemove(robloxPlayer)
end

function ServerEntityManager.SpawnPlayer(robloxPlayer: Player)
	local character = robloxPlayer.Character or robloxPlayer.CharacterAdded:Wait()
	local playerEntity = PlayerEntity.new(robloxPlayer, 100) -- new player entity

	playerEntity:OnDeath(onDeath)
	playerEntity:OnDamaged(OnDamaged)
	playerAdd(robloxPlayer, playerEntity)
end

function ServerEntityManager.OnPlayerDeath(robloxPlayer: Player) end

return ServerEntityManager
