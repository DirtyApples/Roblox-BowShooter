local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = require(ReplicatedStorage.Shared.Network.Events)
local SwapTable = require(ReplicatedStorage.Shared.classes.DataStructures.SwapTable)
local CollisionGroup = require(ReplicatedStorage.Shared.classes.Wrappers.CollisionGroup)

local TeamManager = {}

type SwapTable<T> = SwapTable.SwapTable<T>
local _teams: SwapTable<string> = SwapTable.new()

local _teamsPlayers: { [string]: SwapTable<Player> } = {}
local _playersTeams: { [Player]: string } = {}

local _teamsRaycastParams: { [string]: RaycastParams } = {}

function TeamManager.AssignModelToTeam(model: Model, teamName: string)
	if _teamsRaycastParams[teamName] == nil then
		warn("Tried To Assign Model To Nonexistant Team %s", teamName)
		return
	end
	CollisionGroup.assignModel(model, teamName)
end

function TeamManager.InitializeTeams(teams: { string })
	for _, team in teams do
		_teams:Add(team)
		_teamsPlayers[team] = SwapTable.new()

		local params = RaycastParams.new()
		params.CollisionGroup = team
		_teamsRaycastParams[team] = params
	end
end

function TeamManager.RemovePlayer(robloxPlayer: Player)
	local teamName = _playersTeams[robloxPlayer]
	if teamName == nil then
		return
	end

	_teamsPlayers[teamName]:Remove(robloxPlayer)
	_playersTeams[robloxPlayer] = nil
end

function TeamManager.AddPlayer(robloxPlayer: Player, teamName: string)
	local team = _teamsPlayers[teamName]
	if team == nil then
		warn("Tried To Assign Player To Nonexistant Team %s", teamName)
		return
	end

	team:Add(robloxPlayer)
	_playersTeams[robloxPlayer] = teamName
end

function TeamManager.AssignPlayer(robloxPlayer: Player, teamName: string)
	TeamManager.RemovePlayer(robloxPlayer)
	TeamManager.AddPlayer(robloxPlayer, teamName)
end

function TeamManager.GetTeams()
	-- TODO: Check For Team Fullness
	return _teamsPlayers
end

function TeamManager.GetTeamNames()
	-- TODO: Check For Team Fullness
	return _teams:GetTable()
end

function TeamManager.SwapTeams(robloxPlayer: Player, targetTeam: string)
	-- TODO: Check For Team Fullness
	TeamManager.RemovePlayer(robloxPlayer)
	TeamManager.AssignPlayer(robloxPlayer, targetTeam)
end

function TeamManager.GetRaycastParams(robloxPlayer: Player)
	print(_playersTeams)
	print(_teamsRaycastParams)
	local team = _playersTeams[robloxPlayer]
	return _teamsRaycastParams[team]
end

function TeamManager.GetPlayerTeam(robloxPlayer: Player)
	return _playersTeams[robloxPlayer]
end

return TeamManager
