local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Charm = require(ReplicatedStorage.Packages.Charm)
local PlayerEntity = require(ReplicatedStorage.Shared.classes.Entity.PlayerEntity)

Charm.subscribe(PlayerEntity.GetAtom(), function(newData)
	print("atom changed!", newData)
end)
