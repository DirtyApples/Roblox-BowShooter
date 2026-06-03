--[[
	CumulationPool
	Inherits from ReferenceTable. Designed for batching amount per frame.

	When a reference (key) is added with a amount value:
	  - If the key is new, it's inserted normally.
	  - If the key already exists, the amount is added to the existing value.

	This coalesces multiple hits on the same enemy into a single entry,
	so you only process each enemy once per frame.

	Usage:
		local CumulationPool = require(path.to.CumulationPool)
		local pool = CumulationPool.new()

		pool:Add(enemyA, 25)
		pool:Add(enemyA, 10)  -- accumulates: enemyA now has 35
		pool:Add(enemyB, 50)

		for i, enemy, totalamount in pool:Iterate() do
			enemy:Takeamount(totalamount)
		end

		pool:Clear()
]]

local ReferenceTable = require(script.Parent.ReferenceTable)

local CumulationPool = {}
CumulationPool.__index = CumulationPool
setmetatable(CumulationPool, { __index = ReferenceTable })

function CumulationPool.new(size: number)
	local self = ReferenceTable.new(size)
	return setmetatable(self, CumulationPool)
end

--- Add amount for a reference. If the reference already exists,
--- the amount is accumulated onto the existing total.
function CumulationPool:Add(reference: any, amount: number)
	assert(reference ~= nil, "Reference must not be nil")

	local index = self._keyToIndex[reference]
	if index then
		self._values[index] = self._values[index] + amount
	else
		local newIndex = self._size + 1
		self._size = newIndex

		self._keys[newIndex] = reference
		self._values[newIndex] = amount
		self._keyToIndex[reference] = newIndex
	end
end

function CumulationPool:Subtract(reference: any, amount: number)
	assert(reference ~= nil, "Reference must not be nil")

	local index = self._keyToIndex[reference]
	if index then
		self._values[index] = self._values[index] - amount
	else
		local newIndex = self._size + 1
		self._size = newIndex

		self._keys[newIndex] = reference
		self._values[newIndex] = -amount
		self._keyToIndex[reference] = newIndex
	end
end

function CumulationPool:Multiply(reference: any, amount: number)
	assert(reference ~= nil, "Reference must not be nil")

	local index = self._keyToIndex[reference]
	if index then
		self._values[index] = self._values[index] * amount
	else
		local newIndex = self._size + 1
		self._size = newIndex

		self._keys[newIndex] = reference
		self._values[newIndex] = 0
		self._keyToIndex[reference] = newIndex
	end
end

return CumulationPool
