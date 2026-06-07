local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CharmSync = require(ReplicatedStorage.Packages["charm-sync"])
local Charms = require(ReplicatedStorage.Shared.Charm.Charms)
local Events = require(ReplicatedStorage.Shared.Network.Events)

print("Initializing Charm Client")
print(Charms.atoms)
local syncer = CharmSync.client({
	atoms = Charms.atoms, -- A dictionary of the atoms to sync, matching the server's
	ignoreUnhydrated = true, -- Whether to ignore state updates before the initial update
})

-- Applies state updates from the server to the client's atoms.
-- Data deserialization can be done here.
Events.Charm.SyncState:Client():On(function(...)
	print("SYNICING")
	print(...)
	syncer:sync(...)
end)

return {}
