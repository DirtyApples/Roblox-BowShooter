local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

local ServerEntityManager = require(ServerScriptService.Server.Services.ServerEntityManager)
local ServerPlayerData = require(ServerScriptService.Server.Services.ServerPlayerData)
local ServerCharacterLoader = require(ServerScriptService.Server.Services.ServerCharacterLoader)
local ServerPlayerManager = require(ServerScriptService.Server.Services.ServerPlayerManager)
local ServerProjectileManager = require(ServerScriptService.Server.Services.ServerProjectileManager)
local Red = require(ReplicatedStorage.Packages.Red)
local Events = require(ReplicatedStorage.Shared.Network.Events)
local PlayerEntity = require(ReplicatedStorage.Shared.classes.Entity.PlayerEntity)

local function onPlayerAdded(robloxPlayer)
	if not ServerPlayerData.PlayerJoined(robloxPlayer) then
		warn("No Player Data Loaded For %s", robloxPlayer.Name)
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
	Events.Player.Leave:Server():FireAll(robloxPlayer)
	robloxPlayer:Destroy()
end

local function onUpdate(dt)
	--ServerEntityManager.Update(dt)
	ServerProjectileManager.Update(dt)
end

------------------
--Player Actions--
------------------

local function onPlayerRespawnReuest(robloxPlayer)
	robloxPlayer:LoadCharacter()
	ServerEntityManager.SpawnPlayer(robloxPlayer)
	print(ServerEntityManager.GetPlayers())
end

local function onPlayerShoot(robloxPlayer: Player, origin: CFrame, timestamp: number)
	local player = ServerEntityManager.GetPlayer(robloxPlayer)
	if player == nil then
		warn("Player attempted to shoot with no playerEntity.")
		return
	end
	ServerProjectileManager.CreateProjectile(robloxPlayer, origin, player:GunStats(), timestamp)
end

---------------
--Connections--
---------------

RunService.Heartbeat:Connect(onUpdate)

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

Events.Player.Shoot:Server():On(onPlayerShoot)
Events.Player.RespawnRequest:Server():On(onPlayerRespawnReuest)

-- Catch players who joined before this script ran (common in Studio)
for _, robloxPlayer in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, robloxPlayer)
end
