local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModelDestroyer = require(ReplicatedStorage.Shared.Scripts.ModelDestroyer)
local Projectile = require(script.Parent.Projectile)

local ProjectileModel = setmetatable({}, { __index = Projectile })
ProjectileModel.__index = ProjectileModel

function ProjectileModel.new(origin: CFrame, config, owner, raycastParams: RaycastParams, model: Model)
	local self = setmetatable(Projectile.new(origin, config, owner, raycastParams), ProjectileModel)

	-- Clone and anchor the model
	self._model = model:Clone()
	self._model:PivotTo(origin)
	self._model.Parent = workspace

	-- Destroy model on geometry hit or expiry
	local function cleanup()
		if self._model and self._model.Parent then
			if self._geoHit then
				self._model.Parent = self._geoHit
				ModelDestroyer.destroyAfter(self._model, 5)
				return
			end

			self._model:Destroy()
			self._model = nil
		end
	end

	self:OnGeometryHit(cleanup)
	self:OnExpired(cleanup)
	self:OnDestroy(cleanup)

	return self
end

-- Override Update to sync model position each frame
function ProjectileModel:Update(dt: number, geometryFilter: RaycastParams?)
	local result = Projectile.Update(self, dt, geometryFilter)
	print("Update")
	if result and self._model and self._model.Parent then
		-- Face the model along the travel direction
		local cf = CFrame.new(result.endPosition, result.endPosition + result.direction)
		self._model:PivotTo(cf)
	end

	return result
end

function ProjectileModel:Destroy()
	if self._model and self._model.Parent then
		self._model:Destroy()
		self._model = nil
	end
	Projectile.Destroy(self) -- don't forget to pass self
end

function ProjectileModel:GetModel(): Model?
	return self._model
end

return ProjectileModel
