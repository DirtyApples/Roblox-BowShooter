local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServiceLoader = require(ReplicatedStorage.Shared.ServiceLoader)

local Utility = require(ReplicatedStorage.Shared.Network.Utility)
local SpacialStorage = require(ReplicatedStorage.Shared.classes.DataStructures.SpacialStorage)
local SwapTable = require(ReplicatedStorage.Shared.classes.DataStructures.SwapTable)
local Projectile = require(ReplicatedStorage.Shared.classes["Projectile.luau"].Projectile)
local Constants = require(ReplicatedStorage.Shared.Utility.Constants)
local EventBuss = require(ReplicatedStorage.Shared.Utility.EventBuss)
local ProjectileModel = require(ReplicatedStorage.Shared.classes["Projectile.luau"].ProjectileModel)
local ProjectileManager = {}

local _projectiles = SwapTable.new()

---------------------
----- CallBacks -----
---------------------

-------------------
-- Local Helpers --
-------------------

-------------------
----- Utility -----
-------------------

---------------
----- API -----
---------------

-- ProjectileManager.lua

function ProjectileManager.AddProjectile(projectile: Projectile)
	_projectiles:Add(projectile)
end

function ProjectileManager.RemoveProjectile(projectile: Projectile)
	_projectiles:Remove(projectile)
end

local _entityHits = {}
function ProjectileManager.Update(dt: number)
	table.clear(_entityHits)
	for _, projectile in _projectiles:GetTable() do
		local result = projectile:Update(dt)
		local hit = result.hit or nil

		if hit then
			ProjectileManager.RemoveProjectile(projectile)
			if hit.model then
				table.insert(_entityHits, { projectile = projectile, hit = hit })
			end
		end

		if projectile:Expired() then
			ProjectileManager.RemoveProjectile(projectile)
		end
	end
	EventBuss.Publish(EventBuss.Events.projectileHits, _entityHits)
end

return ProjectileManager
