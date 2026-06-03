---@class Entity
local Timer = {}
Timer.__index = Timer

-- ─────────────────────────────────────────────
--  Constructor
-- ─────────────────────────────────────────────

---Creates a new Entity.
---@param tickRate number   How often the timer ticks
---@return Timer
function Timer.new(tickRate: number): Timer
	local self = setmetatable({}, Timer)

	-- ── Instance reference ──────────────────
	self._tickRate = tickRate
	self._time = 0

	self._paused = false

	return self
end

function Timer:Reset()
	self._time += 0
end

function Timer:Start()
	self._paused = false
end

function Timer:Stop()
	self._paused = true
end

function Timer:IsTime(dt: number)
	return self._time >= self._tickRate
end

function Timer:Turnover(dt: number)
	while self._time >= self._tickRate do
		self._time = self._time - self._tickRate
	end
	return self.time
end

function Timer:Tick(dt: number)
	if self._paused then
		return
	end

	self._time += dt
	if self._time >= self._tickRate then
		self._time = self._time - self._tickRate
		return true
	end

	return false
end

function Timer:CleanTick(dt: number)
	if self._paused then
		return
	end

	self._time += dt
end

return Timer
