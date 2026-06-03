local SwapTable = {}
SwapTable.__index = SwapTable

export type SwapTable<T> = typeof(setmetatable(
	{} :: {
		_data: { T },
		_indices: { [T]: number },
	},
	SwapTable
))

function SwapTable.new<T>(): SwapTable<T>
	return setmetatable({
		_data = {} :: { T },
		_indices = {} :: { [T]: number },
	}, SwapTable)
end

function SwapTable:Add<T>(element: T)
	if self._indices[element] then
		return
	end

	local index = #self._data + 1
	self._data[index] = element
	self._indices[element] = index
end

function SwapTable:Remove<T>(element: T)
	local index = self._indices[element]
	if not index then
		return
	end

	local lastIndex = #self._data
	local last = self._data[lastIndex]

	if index ~= lastIndex then
		self._data[index] = last
		self._indices[last] = index
	end

	self._data[lastIndex] = nil
	self._indices[element] = nil
end

function SwapTable:GetTable<T>(): { T }
	return self._data
end

return SwapTable
