local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)

local Expect = require(script.Parent.Utility).Expect

return {
	Charm = {
		RequestState = Red.Event("CharmRequestState", function(...)
			return ...
		end),
		SyncState = Red.Event("CharmSyncState", function(...)
			return ...
		end),
	},
	Teams = {
		Init = Red.Event("TeamsInit", function(data)
			Expect(data, "data", "table")
			return data
		end),
		Joined = Red.Event("TeamsJoined", function(player, teamName)
			Expect(player, "player", "Instance")
			Expect(teamName, "teamName", "string")
			return player, teamName
		end),
	},
	Player = {
		Sync = Red.Event("PlayerInit", function(data)
			Expect(data, "data", "table")
			return data
		end),

		Join = Red.Event("PlayerJoin", function(player, data)
			Expect(player, "player", "Instance")
			Expect(data, "data", "table")
			return player, data
		end),

		Leave = Red.Event("PlayerLeave", function(player)
			Expect(player, "player", "Instance")
			return player
		end),

		Killed = Red.Event("PlayerKilled", function(player)
			Expect(player, "player", "Instance")
			return player
		end),

		Respawned = Red.Event("PlayerRespawned", function(player)
			Expect(player, "player", "Instance")
			return player
		end),

		RespawnRequest = Red.Event("RespawnRequest", function(player)
			Expect(player, "player", "Instance")
			return player
		end),

		Shoot = Red.Event("PlayerShootRequest", function(shootCFrame, timestamp)
			Expect(shootCFrame, "shootCFrame", "CFrame")
			Expect(timestamp, "timestamp", "number")
			return shootCFrame, timestamp
		end),

		Damage = Red.Event("PlayerDamage", function(player, value)
			Expect(player, "player", "Instance")
			Expect(value, "value", "number")
			return player, value
		end),

		Heal = Red.Event("PlayerHeal", function(player, value)
			Expect(player, "player", "Instance")
			Expect(value, "value", "number")
			return player, value
		end),
	},
	Projectile = {
		created = Red.Event("ProjectileCreated", function(data, timestamp)
			Expect(data, "data", "{}")
			Expect(timestamp, "timestamp", "number")
			return data, timestamp
		end),
	},
}
