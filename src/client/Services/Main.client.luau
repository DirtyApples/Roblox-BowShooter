local ReplicatedStorage = game:GetService("ReplicatedStorage")
--- Charm Loads
local PlayerEntity = require(ReplicatedStorage.Shared.classes.Entity.PlayerEntity)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local userId = Players.LocalPlayer.UserId

local Events = require(ReplicatedStorage.Shared.Network.Events)
local CharmSync = require(ReplicatedStorage.Packages["charm-sync"])
local Charm = require(ReplicatedStorage.Packages.Charm)
local Charms = require(ReplicatedStorage.Shared.Charm.Charms)

local ClientCharmSync = require(script.Parent.ClientCharmSync)

local playerData = PlayerEntity.GetAtom()
Events.Charm.RequestState:Client():Fire()

local time = 1
local rate = 1

RunService.Heartbeat:Connect(function(deltaTime)
	time += deltaTime
	if time >= rate then
		time = time - rate
		print(playerData())
	end
end)
