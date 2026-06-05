local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeamManager = require(ReplicatedStorage.Shared.Services.TeamManager)
local SwapTable = require(ReplicatedStorage.Shared.classes.DataStructures.SwapTable)
local CollisionGroup = require(ReplicatedStorage.Shared.classes.Wrappers.CollisionGroup)

local ServerTeamManager = {}

function ServerTeamManager.InitializeTeams(teams: { string })
	for _, team in teams do
		CollisionGroup.registerGroup(team)
		CollisionGroup.setCollidable(team, team, false)
	end

	TeamManager.InitializeTeams(teams)
end

function ServerTeamManager.RemovePlayer(robloxPlayer: Player)
	TeamManager.RemovePlayer(robloxPlayer)
end

function ServerTeamManager.AssignPlayer(robloxPlayer: Player, teamName: string)
	TeamManager.AssignPlayer(robloxPlayer, teamName)
end

function ServerTeamManager.AssigneRandom(robloxPlayer: Player)
	local teams = TeamManager.GetTeams()
	local randomTeam = teams[math.random(#teams)]
	TeamManager.AssignPlayer(robloxPlayer, randomTeam)
end

function ServerTeamManager.SwapTeams(robloxPlayer: Player, targetTeam: string)
	-- TODO: Check For Team Fullness
	TeamManager.SwapTeams(robloxPlayer, targetTeam)
end

function ServerTeamManager.GetRaycastParams(robloxPlayer: Player)
	return TeamManager.GetRaycastParams(robloxPlayer)
end

function ServerTeamManager.GetPlayerTeam(robloxPlayer: Player)
	return TeamManager.GetPlayerTeam(robloxPlayer)
end

return ServerTeamManager
