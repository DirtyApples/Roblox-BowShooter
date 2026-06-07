local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Charm = require(ReplicatedStorage.Packages.Charm)
local CharmSync = require(ReplicatedStorage.Packages["charm-sync"])
local Charms = require(ReplicatedStorage.Shared.Charm.Charms)
local Events = require(ReplicatedStorage.Shared.Network.Events)

ServerCharms = {}

print("Initializing Server Charms")
print(Charms.atoms)
local syncer = CharmSync.server({
	-- A dictionary of the atoms to sync, matching the client's
	atoms = Charms.atoms,
	-- The minimum interval between state updates
	interval = 0,
	-- Whether to send a full history of changes made to the atoms (slower)
	preserveHistory = false,
	-- Whether to apply fixes for remote event limitations. Disable this option
	-- when using a network library with custom ser/des, like ByteNet or Zap.
	autoSerialize = true,
})

local function filterPlayer(data: {}, key: string, userId: number) end

-- Sends state updates to clients when a synced atom changes.
-- Omitting sensitive information and data serialization can be done here.
syncer:connect(function(player, ...)
	local filteredPayloads = {}
	for _, payload in { ... } do
		if payload.data == nil then
			continue
		end

		local newData = Charms.FilterPayload(payload, player.UserId)

		table.insert(filteredPayloads, {
			type = payload.type,
			data = newData,
		})
	end

	if #filteredPayloads > 0 then
		Events.Charm.SyncState:Server():Fire(player, table.unpack(filteredPayloads))
	end
end)

-- Sends the initial state to a player upon request. This should fire when a
-- player joins the game.
Events.Charm.RequestState:Server():On(function(player)
	syncer:hydrate(player)
end)

return ServerCharms
