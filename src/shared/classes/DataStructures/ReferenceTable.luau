--[[
	ReferenceTable
	A data structure optimized for both fast access (O(1) lookup by key)
	and fast iteration (dense contiguous array, no holes).

	Uses the swap-and-pop strategy: on removal, the last element is swapped
	into the removed slot so the array stays dense. Iteration order is not
	preserved.

	Usage:
		local ReferenceTable = require(path.to.ReferenceTable)
		local rt = ReferenceTable.new()

		rt:Insert("enemy1", { Health = 100, Position = Vector3.new() })
		rt:Insert("enemy2", { Health = 80, Position = Vector3.new(5, 0, 0) })

		-- O(1) lookup
		local data = rt:Get("enemy1")

		-- Fast, dense iteration
		for i, key, value in rt:Iterate() do
			print(key, value.Health)
		end

		-- O(1) removal (swap-and-pop)
		rt:Remove("enemy1")
]]

local ReferenceTable = {}
ReferenceTable.__index = ReferenceTable

export type ReferenceTable<K, V> = typeof(setmetatable(
	{} :: {
		_keys: { K },
		_values: { V },
		_keyToIndex: { [K]: number },
		_size: number,
	},
	ReferenceTable
))

function ReferenceTable.new(size: number)
	local self = setmetatable({}, ReferenceTable)

	self._keys = {} -- dense array of keys:   [index] = key
	self._values = {} -- dense array of values:  [index] = value
	self._keyToIndex = {} -- hash map:               [key]   = index
	self._size = size or 0

	return self
end

function ReferenceTable:getSize()
	return self._size
end

--- Insert a key-value pair. Errors if the key already exists.
function ReferenceTable:Insert(key, value)
	assert(key ~= nil, "Key must not be nil")
	assert(self._keyToIndex[key] == nil, "Key already exists: " .. tostring(key))

	local index = self._size + 1
	self._size = index

	self._keys[index] = key
	self._values[index] = value
	self._keyToIndex[key] = index
end

--- Set a key's value, inserting if it doesn't exist or updating if it does.
function ReferenceTable:Set(key, value)
	assert(key ~= nil, "Key must not be nil")

	local index = self._keyToIndex[key]
	if index then
		self._values[index] = value
	else
		local newIndex = self._size + 1
		self._size = newIndex

		self._keys[newIndex] = key
		self._values[newIndex] = value
		self._keyToIndex[key] = newIndex
	end
end

--- Remove a key. Uses swap-and-pop to keep the array dense. Returns the
--- removed value, or nil if the key was not found.
function ReferenceTable:Remove(key)
	local index = self._keyToIndex[key]
	if not index then
		return nil
	end

	local size = self._size
	local removedValue = self._values[index]

	if index == size then
		-- Removing the last element, no swap needed
		self._keys[size] = nil
		self._values[size] = nil
	else
		-- Swap the last element into the removed slot
		local lastKey = self._keys[size]

		self._keys[index] = lastKey
		self._values[index] = self._values[size]
		self._keyToIndex[lastKey] = index

		-- Clear the last slot
		self._keys[size] = nil
		self._values[size] = nil
	end

	self._keyToIndex[key] = nil
	self._size = size - 1

	return removedValue
end

--- O(1) lookup by key. Returns the value or nil.
function ReferenceTable:Get(key)
	local index = self._keyToIndex[key]
	if index then
		return self._values[index]
	end
	return nil
end

--- Returns true if the key exists in the table.
function ReferenceTable:Has(key)
	return self._keyToIndex[key] ~= nil
end

--- Returns the number of entries.
function ReferenceTable:Size()
	return self._size
end

--- Returns whether the table is empty.
function ReferenceTable:IsEmpty()
	return self._size == 0
end

--- Stateless iterator for use in generic for loops.
---   for i, key, value in rt:Iterate() do ... end
function ReferenceTable:Iterate()
	local keys = self._keys
	local values = self._values
	local size = self._size
	local i = 0

	return function()
		i = i + 1
		if i > size then
			return nil
		end
		return i, keys[i], values[i]
	end
end

function ReferenceTable:IterateReverse()
	local keys = self._keys
	local values = self._values
	local i = self._size + 1

	return function()
		i = i - 1
		if i < 1 then
			return nil
		end
		return i, keys[i], values[i]
	end
end

--- Returns the raw dense arrays (read-only use recommended).
--- Useful when you need maximum iteration speed and want to avoid
--- the overhead of a closure-based iterator.
function ReferenceTable:GetArrays()
	return self._keys, self._values, self._size
end

--- Remove all entries.
function ReferenceTable:Clear()
	table.clear(self._keys)
	table.clear(self._values)
	table.clear(self._keyToIndex)
	self._size = 0
end

return ReferenceTable
