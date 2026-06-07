local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = require(ReplicatedStorage.Shared.Network.Events)
local TeamManager = require(ReplicatedStorage.Shared.Services.TeamManager)
local SwapTable = require(ReplicatedStorage.Shared.classes.DataStructures.SwapTable)
local CollisionGroup = require(ReplicatedStorage.Shared.classes.Wrappers.CollisionGroup)

local ServerTeamManager = {}

-- TODO REPLACE WITH ATOMS

function ServerTeamManager.InitializeTeams(teams: { string })
	for _, team in teams do
		CollisionGroup.registerGroup(team)
		CollisionGroup.setCollidable(team, team, false)
	end

	TeamManager.InitializeTeams(teams)
	Events.Teams.Init:Server():FireAll(teams)
end

function ServerTeamManager.RemovePlayer(robloxPlayer: Player)
	TeamManager.RemovePlayer(robloxPlayer)
end

function ServerTeamManager.AssignPlayer(robloxPlayer: Player, teamName: string)
	TeamManager.AssignPlayer(robloxPlayer, teamName)
	Events.Teams.Joined:Server():FireAll(robloxPlayer, teamName)
end

function ServerTeamManager.AssigneBest(robloxPlayer: Player)
	local teams = TeamManager.GetTeams()

	local smallest = { name = "", size = 999 }
	for name, team in pairs(teams) do
		local size = #team._data
		if smallest.size >= size then
			smallest.name = name
			smallest.size = size
		end
	end
	if smallest.name == "" then
		ServerTeamManager.AssigneRandom(robloxPlayer)
		return
	end

	ServerTeamManager.AssignPlayer(robloxPlayer, smallest.name)
end

function ServerTeamManager.AssigneRandom(robloxPlayer: Player)
	local teams = TeamManager.GetTeamNames()

	local randomTeam = teams[math.random(#teams)]
	ServerTeamManager.AssignPlayer(robloxPlayer, randomTeam)
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
