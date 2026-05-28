-- Player.lua
-- Represents a player-controlled entity.
-- Wraps a Roblox Player + their Character model.

local Entity = require(script.Parent.Entity)

---@class PlayerEntity : Entity
local PlayerEntity = setmetatable({}, { __index = Entity })
PlayerEntity.__index = PlayerEntity

-- ─────────────────────────────────────────────
--  Gun Stats
-- ─────────────────────────────────────────────

export type GunStats = {
	mag: number,
	damage: number,

	rof: number,
	projVelocity: number,
	projGravity: number,
}

local DEFAULT_GUN_STATS: GunStats = {
	mag = 7,
	damage = 7,
	rof = 0.3,

	projVelocity = 200,
	projGravity = 9.8,
}

-- ─────────────────────────────────────────────
--  Constructor
-- ─────────────────────────────────────────────

---@param robloxPlayer Player   The Roblox Player instance (from Players service).
---@param maxHealth number?
---@return Player
function PlayerEntity.new(robloxPlayer: Player, maxHealth: number?): PlayerEntity
	assert(robloxPlayer and robloxPlayer:IsA("Player"), "[Player] Must pass a valid Roblox Player instance.")
	assert(robloxPlayer.Character, "[Player] Character must be loaded before constructing Player.")

	local self = Entity.new(robloxPlayer.Character, maxHealth) :: any
	setmetatable(self, PlayerEntity)

	self._player = robloxPlayer
	self._userId = robloxPlayer.UserId
	self._name = robloxPlayer.Name

	self._gunStats = table.clone(DEFAULT_GUN_STATS)

	-- Respawn / death handling
	self._characterConnection = robloxPlayer.CharacterAdded:Connect(function(newCharacter)
		self:_onCharacterAdded(newCharacter)
	end)

	return self
end

-- ─────────────────────────────────────────────
--  Serialization
-- ─────────────────────────────────────────────

function Serialize(): {}
	return {}
end

-- ─────────────────────────────────────────────
--  Accessors
-- ─────────────────────────────────────────────

---Returns the underlying Roblox Player instance.
function PlayerEntity:GetPlayer(): Player
	return self._player
end

---Returns the player's UserId.
function PlayerEntity:GetUserId(): number
	return self._userId
end

---Returns the player's display name.
function PlayerEntity:GetName(): string
	return self._name
end

---Returns the player's gun stats
function PlayerEntity:GunStats(): {}
	return self._gunStats
end

-- ─────────────────────────────────────────────
--  Overrides
-- ─────────────────────────────────────────────

---Called when the entity takes damage. Override point for subclasses.
function PlayerEntity:OnTakeDamage(damage: number, source)
	-- e.g. update a client-side health bar via a RemoteEvent here
end

---Called when the player dies.
function PlayerEntity:OnDied(killer)
	-- e.g. fire a respawn sequence, log stats, etc.
end

-- ─────────────────────────────────────────────
--  Cleanup
-- ─────────────────────────────────────────────

function PlayerEntity:Destroy()
	if self._characterConnection then
		self._characterConnection:Disconnect()
		self._characterConnection = nil
	end
	Entity.Destroy(self)
end

-- ─────────────────────────────────────────────
--  Private
-- ─────────────────────────────────────────────

function PlayerEntity:_onCharacterAdded(newCharacter: Model)
	self._instance = newCharacter
	self._health = self._maxHealth
	self._isDead = false
end

-- ─────────────────────────────────────────────
--  Debug
-- ─────────────────────────────────────────────

function PlayerEntity:__tostring(): string
	return string.format(
		"PlayerEntity(%s, uid=%d, health=%d/%d)",
		self._name,
		self._userId,
		self._health,
		self._maxHealth
	)
end

return PlayerEntity
