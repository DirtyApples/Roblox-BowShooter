---@class PersistantPlayer
local PersistantPlayer = {}
PersistantPlayer.__index = PersistantPlayer

-- ─────────────────────────────────────────────
--  Constructor
-- ─────────────────────────────────────────────

---@param robloxPlayer Player   The Roblox Player instance (from Players service).
function PersistantPlayer.new(robloxPlayer: Player): PersistantPlayer
	assert(robloxPlayer and robloxPlayer:IsA("Player"), "[Player] Must pass a valid Roblox Player instance.")

	local self = setmetatable({}, PersistantPlayer)
	setmetatable(self, PersistantPlayer)

	self._player = robloxPlayer

	-- Respawn / death handling
	self._characterConnection = robloxPlayer.CharacterAdded:Connect(function(newCharacter)
		self:_onCharacterAdded(newCharacter)
	end)

	return self
end

return PersistantPlayer
