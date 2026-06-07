local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Charm = require(ReplicatedStorage.Packages.Charm)

local Charms = {}

Charms.atoms = {}
local _filters = {}

function Charms.Get(key: string)
	return Charms.atoms[key]()
end

function Charms.AddAtom(key: string, atom: Charm.Atom<any>, filter: (newData: {}, key: string, userId: number) -> ())
	Charms.atoms[key] = atom
	_filters[key] = filter
end

function Charms.Update(key: string, update: any)
	Charms.atoms[key](update)
end

function Charms.FilterPlayer(newData: {}, key: string, userId: number)
	if newData[key] ~= nil and newData[key][userId] ~= nil then
		newData[key] = {
			[userId] = newData[key][userId],
		}
	else
		newData[key] = {}
	end
end

function Charms.FilterPayload(payload, userId)
	if payload.data == nil then
		return nil
	end

	local newData = table.clone(payload.data)
	for key, filter in pairs(_filters) do
		filter(newData, key, userId)
	end

	return newData
end

return Charms
