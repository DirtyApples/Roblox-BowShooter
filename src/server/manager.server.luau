local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

local ServerEntityManager = require(ServerScriptService.Server.Services.ServerEntityManager)
local ServerPlayerData = require(ServerScriptService.Server.Services.ServerPlayerData)
local ServerCharacterLoader = require(ServerScriptService.Server.Services.ServerCharacterLoader)
local Red = require(ReplicatedStorage.Packages.Red)
local Events = require(ReplicatedStorage.Shared.Network.Events)
local PlayerEntity = require(ReplicatedStorage.Shared.classes.Entity.PlayerEntity)

local activePlayers = {} -- [userId] = Player

local function onPlayerAdded(robloxPlayer)
	if not ServerPlayerData.PlayerJoined(robloxPlayer) then
		warn("Not Player Data Loaded For s%", robloxPlayer.Name)
		return
	end

	-- CHARACTER LOAD
	robloxPlayer.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		ServerCharacterLoader.ApplyDescription(humanoid, robloxPlayer)
		--ServerCharacterLoader.ConstructRig(character)
	end)
end

local function onPlayerRemoving(robloxPlayer)
	local player = activePlayers[robloxPlayer.UserId]
	if not player then
		return
	end

	Events.Player.Leave:Server():FireAll(robloxPlayer)

	player:Destroy()
	activePlayers[robloxPlayer.UserId] = nil
end

local function onPlayerRespawnReuest(robloxPlayer)
	print("respawn Trigger")
	robloxPlayer:LoadCharacter()
	print("Spawn Player")
	ServerEntityManager.SpawnPlayer(robloxPlayer)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

Events.Player.RespawnRequest:Server():On(onPlayerRespawnReuest)

-- Catch players who joined before this script ran (common in Studio)
for _, robloxPlayer in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, robloxPlayer)
end
