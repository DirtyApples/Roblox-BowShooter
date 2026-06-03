local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ─────────────────────────────────────────────
--  Types
-- ─────────────────────────────────────────────

export type Config = {
	velocity: number?,
	lifetime: number?,
	gravity: number?,
	drag: number?,
	size: number?,
	damage: number?,
}

-- The segment the projectile traveled this frame.
-- The manager uses this to query spatial storage for entity hits.
export type TravelResult = {
	startPosition: Vector3,
	endPosition: Vector3,
	direction: Vector3, -- unit vector of travel this frame
	distance: number, -- world-space distance traveled
	hit: RaycastResult?, -- geometry hit, nil if open air
}

export type HitResult = {
	position: Vector3,
	normal: Vector3,
	instance: Instance?,
	model: Model?,
	distance: number,
}

-- ─────────────────────────────────────────────
--  Constants
-- ─────────────────────────────────────────────

local DEFAULTS: Config = {
	velocity = 200,
	lifetime = 2,
	gravity = 9.8,
	drag = 0,
	size = 0.5,
	damage = 0,
}

-- ─────────────────────────────────────────────
--  Class definition
-- ─────────────────────────────────────────────

---@class Projectile
local Projectile = {}
Projectile.__index = Projectile

-- ─────────────────────────────────────────────
--  Constructor
-- ─────────────────────────────────────────────

---Creates a new partless Projectile. Visual representation is handled client-side.
---Entity collision is resolved externally using the TravelResult returned by Update.
---@param origin CFrame        Starting position and facing direction.
---@param config Config?       Optional physics overrides.
---@param owner Player?        The player who fired the projectile.
---@return Projectile
function Projectile.new(origin: CFrame, config: Config?, owner: Player?): Projectile
	local cfg = config or {}
	local self = setmetatable({}, Projectile)

	self._owner = owner
	self._damage = cfg.damage or DEFAULTS.damage

	-- ── Physics state ───────────────────────
	self._position = origin.Position
	self._direction = origin.LookVector -- updated each frame to follow arc
	self._speed = cfg.velocity or DEFAULTS.velocity
	self._gravity = cfg.gravity or DEFAULTS.gravity
	self._drag = cfg.drag or DEFAULTS.drag
	self._size = cfg.size or DEFAULTS.size

	self._verticalVelocity = 0 -- accumulates gravity over time

	-- ── Lifetime ────────────────────────────
	self._lifetime = cfg.lifetime or DEFAULTS.lifetime
	self._time = 0
	self._expired = false

	-- ── Callbacks ───────────────────────────
	self._onGeometryHitCallbacks = {} :: { (hit: HitResult) -> () }
	self._onExpiredCallbacks = {} :: { () -> () }
	self._onDestroyCallbacks = {} :: { () -> () }

	return self
end

-- ─────────────────────────────────────────────
--  Accessors
-- ─────────────────────────────────────────────

function Projectile:GetOwner(): Player?
	return self._owner
end

function Projectile:GetPosition(): Vector3
	return self._position
end

function Projectile:GetDirection(): Vector3
	return self._direction
end

function Projectile:GetSize(): number
	return self._size
end

function Projectile:GetDamage(): number
	return self._damage
end

---Normalised 0-1 progress through lifetime. Useful for client-side VFX lerping.
function Projectile:GetLifetimeAlpha(): number
	return math.clamp(self._time / self._lifetime, 0, 1)
end

function Projectile:Expired(): boolean
	return self._expired
end

-- ─────────────────────────────────────────────
--  Update loop
-- ─────────────────────────────────────────────

---Called every Heartbeat by the owning manager.
---
---Advances physics and raycasts against geometry only.
---Returns a TravelResult describing the segment traveled this frame.
---The manager is responsible for querying spatial storage with this segment
---to resolve entity hits — the projectile has no knowledge of the entity registry.
---
---@param dt number                  Delta time in seconds.
---@param geometryFilter RaycastParams?   Filters for static world geometry only.
---@return TravelResult?             nil if already expired before this frame.
function Projectile:Update(dt: number, geometryFilter: RaycastParams?): TravelResult?
	if self._expired then
		return nil
	end

	self._time += dt

	-- Clamp effective dt so physics don't overshoot past lifetime
	local elapsed = self._time - dt
	local remaining = self._lifetime - elapsed
	local effectiveDt = math.min(dt, remaining)

	local result = self:_travel(effectiveDt, geometryFilter)

	if self._time >= self._lifetime then
		self:_expire()
	end

	return result
end

-- ─────────────────────────────────────────────
--  Lifecycle
-- ─────────────────────────────────────────────

function Projectile:Destroy()
	self:_fireCallbacks(self._onDestroyCallbacks)
	self._onGeometryHitCallbacks = {}
	self._onExpiredCallbacks = {}
	self._onDestroyCallbacks = {}
end

-- ─────────────────────────────────────────────
--  Event subscription
-- ─────────────────────────────────────────────

---Fired when the projectile hits static geometry (walls, terrain, props).
---Entity hits are resolved externally by the manager via TravelResult.
---@param fn fun(hit: HitResult)
function Projectile:OnGeometryHit(fn: (hit: HitResult) -> ())
	table.insert(self._onGeometryHitCallbacks, fn)
end

---Fired when the projectile reaches the end of its lifetime with no geometry hit.
---@param fn fun()
function Projectile:OnExpired(fn: () -> ())
	table.insert(self._onExpiredCallbacks, fn)
end

---Fired just before the projectile is destroyed.
---@param fn fun()
function Projectile:OnDestroy(fn: () -> ())
	table.insert(self._onDestroyCallbacks, fn)
end

-- ─────────────────────────────────────────────
--  Private — physics & geometry collision
-- ─────────────────────────────────────────────

---Advances physics by `dt`, spherecasts against geometry, updates internal state,
---and returns the TravelResult for this frame.
---@param dt number
---@param geometryFilter RaycastParams?
---@return TravelResult
function Projectile:_travel(dt: number, geometryFilter: RaycastParams?): TravelResult
	local startPosition = self._position

	-- ── Drag: exponential decay on speed ────────────────────────────────
	local drag = math.clamp(self._drag, 0, 0.99)
	self._speed = self._speed * (1 - drag * dt)

	-- ── Gravity: accumulate downward velocity ────────────────────────────
	self._verticalVelocity -= self._gravity * dt

	-- ── Displacement this frame ──────────────────────────────────────────
	local horizontalDelta = self._direction * (self._speed * dt)
	local verticalDelta = Vector3.new(0, self._verticalVelocity * dt, 0)
	local totalDelta = horizontalDelta + verticalDelta
	local travelDir = totalDelta.Unit
	local distance = totalDelta.Magnitude

	-- ── Geometry spherecast ──────────────────────────────────────────────
	local raycastResult = workspace:Spherecast(startPosition, self._size, travelDir * distance, geometryFilter)

	local endPosition: Vector3
	local geometryHit: HitResult? = nil
	local model = nil

	if raycastResult then
		model = if raycastResult.Instance then raycastResult.Instance:FindFirstAncestorOfClass("Model") else nil
	end
	if raycastResult and model ~= self:GetOwner().Character then
		endPosition = raycastResult.Position
		geometryHit = {
			position = raycastResult.Position,
			normal = raycastResult.Normal,
			instance = raycastResult.Instance,
			material = raycastResult.Material,
			model = if raycastResult.Instance then raycastResult.Instance:FindFirstAncestorOfClass("Model") else nil,
			distance = raycastResult.Distance,
		}

		self._position = endPosition
		self._direction = travelDir

		self:_fireCallbacks(self._onGeometryHitCallbacks, geometryHit)
		self:_expire()
	else
		endPosition = startPosition + totalDelta
		self._position = endPosition
		self._direction = travelDir
	end

	return {
		startPosition = startPosition,
		endPosition = endPosition,
		direction = travelDir,
		distance = (endPosition - startPosition).Magnitude,
		hit = geometryHit,
	}
end

function Projectile:_expire()
	if self._expired then
		return
	end
	self._expired = true
	self:_fireCallbacks(self._onExpiredCallbacks)
end

function Projectile:_fireCallbacks(list: {}, ...)
	for _, fn in ipairs(list) do
		local ok, err = pcall(fn, ...)
		if not ok then
			warn("[Projectile] Callback error: " .. tostring(err))
		end
	end
end

-- ─────────────────────────────────────────────
--  Debug
-- ─────────────────────────────────────────────

function Projectile:__tostring(): string
	return string.format(
		"Projectile(pos=%s, speed=%.1f, time=%.2f/%.2f, expired=%s)",
		tostring(self._position),
		self._speed,
		self._time,
		self._lifetime,
		tostring(self._expired)
	)
end

return Projectile
