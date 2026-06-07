local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = require(ReplicatedStorage.Shared.Network.Events)
local TeamManager = require(ReplicatedStorage.Shared.Services.TeamManager)
local SwapTable = require(ReplicatedStorage.Shared.classes.DataStructures.SwapTable)
local CollisionGroup = require(ReplicatedStorage.Shared.classes.Wrappers.CollisionGroup)

local ClientTeamManager = {}

type SwapTable<T> = SwapTable.SwapTable<T>
local _teams: SwapTable<string> = SwapTable.new()
local _teamsPlayers: { [string]: SwapTable<Player> } = {}
local _playersTeams: { [Player]: string } = {}
local _teamsRaycastParams: { [string]: RaycastParams } = {}

Events.Teams.Init:Client():On(function(teams)
	print("TEAMS INIT")
	print(teams)
	TeamManager.InitializeTeams(teams)
end)

Events.Teams.Joined:Client():On(function(player, team)
	print("TEAM CHABNGED: " .. team)
	TeamManager.AssignPlayer(player, team)
end)

function ClientTeamManager.GetRaycastParams(robloxPlayer: Player)
	return TeamManager.GetRaycastParams(robloxPlayer)
end

return ClientTeamManager
