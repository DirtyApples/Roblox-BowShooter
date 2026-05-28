local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profilestore = require(ReplicatedStorage.Packages.Profilestore)
local Players = game:GetService("Players")

export type PlayerProfile = {
	kills: number,
	coins: number,
}

local DATA: PlayerProfile = {
	kills = 0,
	coins = 0,
}

local Profiles = {}
local PlayerStore = Profilestore.New("PlayerData", DATA)
local ServerPlayerData = {}

-- Custom error for upstream callers to handle
local ERRORS = {
	PROFILE_LOAD_FAILED = "PROFILE_LOAD_FAILED",
	PROFILE_NOT_FOUND = "PROFILE_NOT_FOUND",
}

local function RemovePlayer(UserId: number)
	local profile = Profiles[UserId]
	if profile == nil then
		warn(string.format("Player %d profile was nil on leave.", UserId))
		return
	end
	profile:EndSession()
	Profiles[UserId] = nil
end

function ServerPlayerData.GetProfile(UserId: number)
	local profile = Profiles[UserId]
	if profile == nil then
		error(ERRORS.PROFILE_NOT_FOUND, 2) -- 2 = blame the caller in the stack trace
	end
	return profile
end

function ServerPlayerData.GetData(UserId: number)
	local profile = ServerPlayerData.GetProfile(UserId)
	return profile.Data
end

-- Returns true on success, false if player was kicked
function ServerPlayerData.PlayerJoined(robloxPlayer: Player): boolean
	local profile = PlayerStore:StartSessionAsync(tostring(robloxPlayer.UserId), {
		Cancel = function()
			return not robloxPlayer:IsDescendantOf(Players)
		end,
	})

	if not profile then
		robloxPlayer:Kick("Failed to load your data. Please rejoin.")
		return false
	end

	-- Player left before profile loaded
	if not robloxPlayer:IsDescendantOf(Players) then
		profile:EndSession()
		return false
	end

	profile:AddUserId(robloxPlayer.UserId)
	Profiles[robloxPlayer.UserId] = profile

	robloxPlayer.AncestryChanged:Connect(function()
		if not robloxPlayer:IsDescendantOf(Players) then
			RemovePlayer(robloxPlayer.UserId)
		end
	end)

	return true
end

function ServerPlayerData.PlayerLeave(robloxPlayer: Player)
	RemovePlayer(robloxPlayer.UserId)
end

return ServerPlayerData
