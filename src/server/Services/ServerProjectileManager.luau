local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProjectileManager = require(ReplicatedStorage.Shared.Services.ProjectileManager)
local SwapTable = require(ReplicatedStorage.Shared.classes.DataStructures.SwapTable)
local Projectile = require(ReplicatedStorage.Shared.classes["Projectile.luau"].Projectile)
local Constants = require(ReplicatedStorage.Shared.Utility.Constants)
local EventBuss = require(ReplicatedStorage.Shared.Utility.EventBuss)
local ProjectileModel = require(ReplicatedStorage.Shared.classes["Projectile.luau"].ProjectileModel)
local ServerProjectileManager = {}

local _projectiles = SwapTable.new()

-------------------
-- Local Helpers --
-------------------

EventBuss.Subscribe(EventBuss.Events.projectileHits, fn)

-------------------
----- Utility -----
-------------------

---------------
----- API -----
---------------

function ServerProjectileManager.Update(dt: number)
	ProjectileManager.Update(dt)
end

function ServerProjectileManager.CreateProjectile(
	robloxPlayer: Player,
	origin: CFrame,
	config: Projectile.Config,
	timeStamp: number
)
	local projectile = nil
	if Constants.DEBUG_PROJECTILES then
		projectile = ProjectileModel.new(origin, config, robloxPlayer, Constants.DEBUG_PROJECTILE_MODEL)
	else
		projectile = Projectile.new(origin, config, robloxPlayer)
	end

	local deltaTime = workspace:GetServerTimeNow() - timeStamp

	local result = projectile:Update(deltaTime)
	local hit = result.hit
	if hit then
		EventBuss.Publish(EventBuss.Events.projectileHits, { projectile = projectile, hit = hit })
		return
	end

	ProjectileManager.AddProjectile(projectile)
end

return ServerProjectileManager
