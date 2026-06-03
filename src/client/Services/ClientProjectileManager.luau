local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProjectileManager = require(ReplicatedStorage.Shared.Services.ProjectileManager)
local SwapTable = require(ReplicatedStorage.Shared.classes.DataStructures.SwapTable)
local Projectile = require(ReplicatedStorage.Shared.classes["Projectile.luau"].Projectile)
local Constants = require(ReplicatedStorage.Shared.Utility.Constants)
local ProjectileModel = require(ReplicatedStorage.Shared.classes["Projectile.luau"].ProjectileModel)
local ServerProjectileManager = {}

local _projectiles = SwapTable.new()

-------------------
-- Local Helpers --
-------------------

-------------------
----- Utility -----
-------------------

---------------
----- API -----
---------------

function ServerProjectileManager.Update(dt: number)
	ProjectileManager.Update(dt)
end

function ServerProjectileManager.CreateProjectile(robloxPlayer: Player, origin: CFrame, config: Projectile.Config)
	local projectile = nil
	projectile = ProjectileModel.new(origin, config, robloxPlayer, Constants.PROJECTILE_MODEL)
	ProjectileManager.AddProjectile(projectile)
end

return ServerProjectileManager
