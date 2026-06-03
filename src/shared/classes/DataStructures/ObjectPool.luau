--!strict
-- Last in first out dictionary of list.
-- Will be used for recycling model objects in roblox.

type Stack = { any }

export type ObjectPoolImpl = {
	__index: ObjectPoolImpl,
	new: (size: number) -> ObjectPool,
	add: (self: ObjectPool, key: any, value: any) -> (),
	pop: (self: ObjectPool, key: any) -> any?,
	clear: (self: ObjectPool, key: any?) -> (),
	size: (self: ObjectPool, key: any) -> number,
}

export type ObjectPool = typeof(setmetatable(
	{} :: {
		_maxSize: number,
		_stacks: { [any]: Stack },
	},
	{} :: ObjectPoolImpl
))

local ObjectPool = {} :: ObjectPoolImpl
ObjectPool.__index = ObjectPool

-- Creates a new ObjectPool. `size` controls the max size of each per-key stack.
function ObjectPool.new(size: number): ObjectPool
	assert(type(size) == "number" and size >= 0, "ObjectPool.new: size must be a non-negative number")

	local self = setmetatable({
		_maxSize = size,
		_stacks = {} :: { [any]: Stack },
	}, ObjectPool)

	return self
end

-- Pushes a value onto the stack for `key`.
-- If the stack is already at capacity, the value is dropped (returned to caller's responsibility to destroy).
function ObjectPool:add(key: any, value: any)
	assert(key ~= nil, "ObjectPool:add: key cannot be nil")
	assert(value ~= nil, "ObjectPool:add: value cannot be nil")

	local stack = self._stacks[key]
	if not stack then
		stack = {}
		self._stacks[key] = stack
	end

	if #stack >= self._maxSize then
		-- At capacity; caller should handle/destroy the value themselves.
		return
	end

	stack[#stack + 1] = value
end

-- Pops the most recently added value for `key`. Returns nil if none available.
function ObjectPool:pop(key: any): any?
	assert(key ~= nil, "ObjectPool:pop: key cannot be nil")

	local stack = self._stacks[key]
	if not stack then
		return nil
	end

	local n = #stack
	if n == 0 then
		return nil
	end

	local value = stack[n]
	stack[n] = nil

	return value
end

-- Returns the current number of pooled values for `key`.
function ObjectPool:size(key: any): number
	local stack = self._stacks[key]
	return if stack then #stack else 0
end

return ObjectPool
