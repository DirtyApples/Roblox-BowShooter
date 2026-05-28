-- Entity.lua
-- Base class for all interactive world objects.
-- Extend this class to build NPCs, props, hazards, interactables, etc.

local RunService = game:GetService("RunService")

-- ─────────────────────────────────────────────
--  Constants
-- ─────────────────────────────────────────────

local DEFAULT_MAX_HEALTH = 100

-- ─────────────────────────────────────────────
--  Class definition
-- ─────────────────────────────────────────────

---@class Entity
local Entity = {}
Entity.__index = Entity

-- ─────────────────────────────────────────────
--  Constructor
-- ─────────────────────────────────────────────

---Creates a new Entity.
---@param instance BasePart | Model   The Roblox instance that represents this entity in the world.
---@param maxHealth number?           Maximum (and starting) health. Defaults to 100.
---@return Entity
function Entity.new(instance: BasePart | Model, maxHealth: number?): Entity
	assert(instance, "[Entity] 'instance' must not be nil.")

	local self = setmetatable({}, Entity)

	-- ── Instance reference ──────────────────
	self._instance = instance

	-- ── Health ─────────────────────────────
	self._maxHealth = maxHealth or DEFAULT_MAX_HEALTH
	self._health = self._maxHealth
	self._isDead = false

	-- ── Signal callbacks ────────────────────
	-- Consumers attach functions here; Entity fires them at the right moment.
	self._onDamagedCallbacks = {} :: { (damage: number, source: Entity?) -> () }
	self._onHealedCallbacks = {} :: { (amount: number) -> () }
	self._onDeathCallbacks = {} :: { (killer: Entity?) -> () }
	self._onDestroyCallbacks = {} :: { () -> () }

	return self
end

-- ─────────────────────────────────────────────
--  Health API
-- ─────────────────────────────────────────────

---Returns the entity's current health.
function Entity:GetHealth(): number
	return self._health
end

---Returns the entity's maximum health.
function Entity:GetMaxHealth(): number
	return self._maxHealth
end

---Returns true if the entity is dead.
function Entity:IsDead(): boolean
	return self._isDead
end

---Applies damage to the entity.
---@param amount number      Positive value. Negative amounts are clamped to 0.
---@param source Entity?     Optional entity that caused the damage (for kill-credit, etc.)
function Entity:TakeDamage(amount: number, source: Entity?)
	print("ntity:TakeDamage")
	if self._isDead then
		return
	end
	amount = math.max(0, amount)
	if amount == 0 then
		return
	end

	self._health = math.max(0, self._health - amount)
	self:_fireCallbacks(self._onDamagedCallbacks, amount, source)

	if self._health <= 0 then
		self:_die(source)
	end
end

---Restores health up to the maximum.
---@param amount number   Positive value. Negative amounts are clamped to 0.
function Entity:Heal(amount: number)
	if self._isDead then
		return
	end
	amount = math.max(0, amount)
	if amount == 0 then
		return
	end

	self._health = math.min(self._maxHealth, self._health + amount)
	self:_fireCallbacks(self._onHealedCallbacks, amount)
end

---Sets health directly (clamped to [0, maxHealth]).
---Useful for loading saved state or forced resets.
---Does NOT trigger death if set to 0 – use TakeDamage for gameplay damage.
---@param value number
function Entity:SetHealth(value: number)
	self._health = math.clamp(value, 0, self._maxHealth)
end

---Changes the maximum health and optionally scales current health proportionally.
---@param newMax number
---@param scaleCurrentHealth boolean?  Default false.
function Entity:SetMaxHealth(newMax: number, scaleCurrentHealth: boolean?)
	assert(newMax > 0, "[Entity] maxHealth must be > 0.")
	if scaleCurrentHealth then
		local ratio = self._health / self._maxHealth
		self._maxHealth = newMax
		self._health = math.floor(self._maxHealth * ratio)
	else
		self._maxHealth = newMax
		self._health = math.min(self._health, self._maxHealth)
	end
end

-- ─────────────────────────────────────────────
--  Transform API
-- ─────────────────────────────────────────────

---Returns the entity's world CFrame (position + rotation combined).
---Works for both BasePart and Model (via PrimaryPart).
---@return CFrame
function Entity:GetCFrame(): CFrame
	local inst = self._instance
	if inst:IsA("BasePart") then
		return inst.CFrame
	elseif inst:IsA("Model") then
		assert(inst.PrimaryPart, "[Entity] Model must have a PrimaryPart set.")
		return inst.PrimaryPart.CFrame
	end
	error("[Entity] Unsupported instance type for GetCFrame.")
end

---Returns just the world position of the entity.
---@return Vector3
function Entity:GetPosition(): Vector3
	return self:GetCFrame().Position
end

---Returns the entity's rotation as a CFrame with no translation component.
---@return CFrame
function Entity:GetRotation(): CFrame
	return CFrame.fromMatrix(Vector3.zero, self:GetCFrame().XVector, self:GetCFrame().YVector)
end

---Teleports the entity to a new CFrame instantly.
---@param cf CFrame
function Entity:SetCFrame(cf: CFrame)
	local inst = self._instance
	if inst:IsA("BasePart") then
		inst.CFrame = cf
	elseif inst:IsA("Model") then
		assert(inst.PrimaryPart, "[Entity] Model must have a PrimaryPart set.")
		inst:PivotTo(cf)
	else
		error("[Entity] Unsupported instance type for SetCFrame.")
	end
end

---Moves the entity to a world position while preserving its current rotation.
---@param position Vector3
function Entity:SetPosition(position: Vector3)
	local current = self:GetCFrame()
	self:SetCFrame(CFrame.new(position) * CFrame.fromMatrix(Vector3.zero, current.XVector, current.YVector))
end

---Translates the entity by an offset in world space.
---@param offset Vector3
function Entity:Translate(offset: Vector3)
	self:SetCFrame(self:GetCFrame() + offset)
end

---Rotates the entity by the given CFrame delta (applied in world space).
---@param rotationDelta CFrame
function Entity:Rotate(rotationDelta: CFrame)
	self:SetCFrame(rotationDelta * self:GetCFrame())
end

-- ─────────────────────────────────────────────
--  Instance access
-- ─────────────────────────────────────────────

---Returns the underlying Roblox instance.
---@return BasePart | Model
function Entity:GetInstance()
	return self._instance
end

-- ─────────────────────────────────────────────
--  Lifecycle
-- ─────────────────────────────────────────────

---Called once per Heartbeat if the entity is registered with an update loop.
---Override in subclasses to add per-frame behaviour.
---@param dt number   Delta time in seconds.
function Entity:Update(dt: number) end

---Override in subclasses to add cleanup logic (disconnect events, tween handles, etc.).
---Always call Entity.Destroy(self) at the end of a subclass override.
function Entity:Destroy()
	self:_fireCallbacks(self._onDestroyCallbacks)

	-- Clear callback tables to release references
	self._onDamagedCallbacks = {}
	self._onHealedCallbacks = {}
	self._onDeathCallbacks = {}
	self._onDestroyCallbacks = {}

	if self._instance and self._instance.Parent then
		self._instance:Destroy()
	end
	self._instance = nil
end

-- ─────────────────────────────────────────────
--  Event subscription
-- ─────────────────────────────────────────────

---Registers a callback fired whenever the entity takes damage.
---@param fn fun(damage: number, source: Entity?)
function Entity:OnDamaged(fn: (damage: number, source: Entity) -> ())
	table.insert(self._onDamagedCallbacks, fn)
end

---Registers a callback fired whenever the entity is healed.
---@param fn fun(amount: number)
function Entity:OnHealed(fn: (amount: number) -> ())
	table.insert(self._onHealedCallbacks, fn)
end

---Registers a callback fired when the entity dies.
---@param fn fun(killer: Entity?)
function Entity:OnDeath(fn: (victim: Entity, killer: Entity) -> ())
	table.insert(self._onDeathCallbacks, fn)
end

---Registers a callback fired just before the entity is destroyed.
---@param fn fun()
function Entity:OnDestroy(fn: () -> ())
	table.insert(self._onDestroyCallbacks, fn)
end

-- ─────────────────────────────────────────────
--  Private helpers
-- ─────────────────────────────────────────────

function Entity:_die(killer)
	if self._isDead then
		return
	end
	self._isDead = true
	self._health = 0
	self:_fireCallbacks(self._onDeathCallbacks, self, killer)
end

function Entity:_fireCallbacks(list: {}, ...)
	for _, fn in ipairs(list) do
		local ok, err = pcall(fn, ...)
		if not ok then
			warn("[Entity] Callback error: " .. tostring(err))
		end
	end
end

-- ─────────────────────────────────────────────
--  Utility / Debug
-- ─────────────────────────────────────────────

---Returns a human-readable summary of the entity's current state.
function Entity:__tostring(): string
	return string.format(
		"Entity(health=%d/%d, dead=%s, pos=%s)",
		self._health,
		self._maxHealth,
		tostring(self._isDead),
		tostring(self:GetPosition())
	)
end

return Entity
