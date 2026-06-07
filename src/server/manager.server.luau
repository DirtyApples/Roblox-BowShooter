local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

local ServerEntityManager = require(ServerScriptService.Server.Services.ServerEntityManager)
local ServerPlayerData = require(ServerScriptService.Server.Services.ServerPlayerData)
local ServerCharacterLoader = require(ServerScriptService.Server.Services.ServerCharacterLoader)
local ServerProjectileManager = require(ServerScriptService.Server.Services.ServerProjectileManager)
local ServerTeamManager = require(ServerScriptService.Server.Services.ServerTeamManager)
local Red = require(ReplicatedStorage.Packages.Red)
local Events = require(ReplicatedStorage.Shared.Network.Events)
local TeamManager = require(ReplicatedStorage.Shared.Services.TeamManager)
local Constants = require(ReplicatedStorage.Shared.Utility.Constants)
local PlayerEntity = require(ReplicatedStorage.Shared.classes.Entity.PlayerEntity)
local CollisionGroup = require(ReplicatedStorage.Shared.classes.Wrappers.CollisionGroup)

local ServerCharms = require(ServerScriptService.Server.Services.ServerCharms)

------------------
--Initilization--
------------------

Players.CharacterAutoLoads = false
ServerTeamManager.InitializeTeams(Constants.TEAMS)

------------------
-- On Functions --
------------------

local function onPlayerAdded(robloxPlayer)
	if not ServerPlayerData.PlayerJoined(robloxPlayer) then
		warn("No Player Data Loaded For %s", robloxPlayer.Name)
		return
	end

	Events.Teams.Init:Server():Fire(robloxPlayer, Constants.TEAMS)
	--ServerTeamManager.AssignPlayer(robloxPlayer, Constants.TEAMS.BLUE)
	ServerTeamManager.AssigneBest(robloxPlayer)

	-- CHARACTER LOAD
	robloxPlayer.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		ServerCharacterLoader.ApplyDescription(humanoid, robloxPlayer)

		local playerTeam = ServerTeamManager.GetPlayerTeam(robloxPlayer)
		TeamManager.AssignModelToTeam(character, playerTeam)

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

	--TODO: COLLISION GROUP FOR PROJECTILES
	local collisionInfo = ServerTeamManager.GetRaycastParams(robloxPlayer)
	print(ServerTeamManager.GetPlayerTeam(robloxPlayer))
	print(collisionInfo)
	ServerProjectileManager.CreateProjectile(
		robloxPlayer,
		origin,
		player:GunStats().projectile,
		collisionInfo,
		timestamp
	)
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

local time = 1
local rate = 1

local playersData = PlayerEntity.GetAtom()
RunService.Heartbeat:Connect(function(deltaTime)
	time += deltaTime
	if time >= rate then
		time = time - rate
		print(playersData())
	end
end)
