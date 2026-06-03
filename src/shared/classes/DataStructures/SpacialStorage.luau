local floor = math.floor
local EMPTY = table.freeze({})

local SpatialStorage = {}
SpatialStorage.__index = SpatialStorage

function SpatialStorage.new(cellSize: number, cellsX: number, cellsZ: number)
	local self = setmetatable({}, SpatialStorage)
	self._cellSize = cellSize
	self._cellsX = cellsX
	self._cellsZ = cellsZ
	self._originX = -(cellsX * cellSize) / 2
	self._originZ = -(cellsZ * cellSize) / 2

	local total = cellsX * cellsZ
	local cells = table.create(total)
	for i = 1, total do
		cells[i] = {}
	end
	self._cells = cells

	return self
end

function SpatialStorage:_getIndex(x: number, z: number): number?
	local cx = floor((x - self._originX) / self._cellSize)
	local cz = floor((z - self._originZ) / self._cellSize)
	if cx < 0 or cx >= self._cellsX or cz < 0 or cz >= self._cellsZ then
		return nil
	end
	return cz * self._cellsX + cx + 1
end

-- Convert a flat index back to the world-space center of that cell
function SpatialStorage:_indexToWorldCenter(i: number): (number, number)
	local idx = i - 1
	local cx = idx % self._cellsX
	local cz = floor(idx / self._cellsX)
	local worldX = self._originX + (cx + 0.5) * self._cellSize
	local worldZ = self._originZ + (cz + 0.5) * self._cellSize
	return worldX, worldZ
end

function SpatialStorage:insert(entity, x: number, z: number)
	local i = self:_getIndex(x, z)
	if i then
		self._cells[i][entity] = true
	end
end

function SpatialStorage:remove(entity, x: number, z: number)
	local i = self:_getIndex(x, z)
	if i then
		self._cells[i][entity] = nil
	end
end

function SpatialStorage:update(entity, oldX: number, oldZ: number, newX: number, newZ: number)
	local oldI = self:_getIndex(oldX, oldZ)
	local newI = self:_getIndex(newX, newZ)
	if oldI ~= newI then
		if oldI then
			self._cells[oldI][entity] = nil
		end
		if newI then
			self._cells[newI][entity] = true
		end
	end
end

function SpatialStorage:getCell(x: number, z: number): { [any]: boolean }
	local i = self:_getIndex(x, z)
	if i then
		return self._cells[i]
	end
	return EMPTY
end

function SpatialStorage:getCellByIndex(i: number): { [any]: boolean }
	return self._cells[i]
end

function SpatialStorage:getTotalCells(): number
	return self._cellsX * self._cellsZ
end

function SpatialStorage:queryRadius(x: number, z: number, radius: number): { any }
	local size = self._cellSize
	local w = self._cellsX
	local h = self._cellsZ
	local ox = self._originX
	local oz = self._originZ
	local cells = self._cells

	local cellRadius = math.ceil(radius / size)
	local cx = floor((x - ox) / size)
	local cz = floor((z - oz) / size)

	local results = {}
	local n = 0

	for dz = -cellRadius, cellRadius do
		for dx = -cellRadius, cellRadius do
			local nx = cx + dx
			local nz = cz + dz
			if nx >= 0 and nx < w and nz >= 0 and nz < h then
				local cell = cells[nz * w + nx + 1]
				for entity in pairs(cell) do
					n += 1
					results[n] = entity
				end
			end
		end
	end

	return results
end

function SpatialStorage:findClosest(
	x: number,
	z: number,
	radius: number,
	amount: number,
	getPosition: (any) -> (number, number)
): ({ any }, { number })
	local size = self._cellSize
	local w = self._cellsX
	local h = self._cellsZ
	local ox = self._originX
	local oz = self._originZ
	local cells = self._cells
	local cellRadius = math.ceil(radius / size)
	local cx = floor((x - ox) / size)
	local cz = floor((z - oz) / size)
	local radiusSq = radius * radius

	-- Collect all candidates within radius
	local candidates = {}
	local n = 0

	for dz = -cellRadius, cellRadius do
		for dx = -cellRadius, cellRadius do
			local nx = cx + dx
			local nz = cz + dz
			if nx >= 0 and nx < w and nz >= 0 and nz < h then
				local cell = cells[nz * w + nx + 1]
				for entity in pairs(cell) do
					local ex, ez = getPosition(entity)
					local ddx = ex - x
					local ddz = ez - z
					local distSq = ddx * ddx + ddz * ddz
					if distSq < radiusSq then
						n += 1
						candidates[n] = { entity = entity, distSq = distSq }
					end
				end
			end
		end
	end

	-- Sort by distance and take the top N
	table.sort(candidates, function(a, b)
		return a.distSq < b.distSq
	end)

	local resultEntities = {}
	local resultDistances = {}
	local count = if n < amount then n else amount

	for i = 1, count do
		resultEntities[i] = candidates[i].entity
		resultDistances[i] = candidates[i].distSq ^ 0.5
	end

	return resultEntities, resultDistances
end

function SpatialStorage:getNeighborIndices(i: number): { number }
	local w = self._cellsX
	local total = w * self._cellsZ
	local results = {}
	local n = 0

	for dz = -1, 1 do
		for dx = -1, 1 do
			local ni = i + dz * w + dx
			if ni >= 1 and ni <= total then
				local ix = (i - 1) % w
				local nx = ix + dx
				if nx >= 0 and nx < w then
					n += 1
					results[n] = ni
				end
			end
		end
	end
	return results
end

function SpatialStorage:clear()
	local cells = self._cells
	for i = 1, #cells do
		table.clear(cells[i])
	end
end

-- Debug visualization

local DEBUG_FOLDER_PATH = "Workspace.Debug.Spatial"

local function getOrCreateFolder(): Folder
	local workspace = game:GetService("Workspace")
	local debug = workspace:FindFirstChild("Debug")
	if not debug then
		debug = Instance.new("Folder")
		debug.Name = "Debug"
		debug.Parent = workspace
	end
	local spatial = debug:FindFirstChild("Spatial")
	if not spatial then
		spatial = Instance.new("Folder")
		spatial.Name = "Spatial"
		spatial.Parent = debug
	end
	return spatial
end

function SpatialStorage:clearVisualization()
	local workspace = game:GetService("Workspace")
	local debug = workspace:FindFirstChild("Debug")
	if not debug then
		return
	end
	local spatial = debug:FindFirstChild("Spatial")
	if not spatial then
		return
	end
	spatial:ClearAllChildren()
end

function SpatialStorage:showVisualization(height: number?)
	self:clearVisualization()

	local folder = getOrCreateFolder()
	local size = self._cellSize
	local y = height or 0.1
	local total = self._cellsX * self._cellsZ
	local cells = self._cells
	local w = self._cellsX

	for i = 1, total do
		local worldX, worldZ = self:_indexToWorldCenter(i)
		local occupied = next(cells[i]) ~= nil

		local idx = i - 1
		local cx = idx % w
		local cz = floor(idx / w)
		local isLight = (cx + cz) % 2 == 0

		local tile = Instance.new("Part")
		tile.Name = "Cell_" .. i
		tile.Shape = Enum.PartType.Block
		tile.Size = Vector3.new(size, 0.2, size)
		tile.Position = Vector3.new(worldX, y, worldZ)
		tile.Anchored = true
		tile.CanCollide = false
		tile.Material = Enum.Material.SmoothPlastic

		if occupied then
			tile.Color = if isLight then Color3.fromRGB(255, 80, 80) else Color3.fromRGB(180, 40, 40)
			tile.Transparency = 0
		else
			tile.Color = if isLight then Color3.fromRGB(220, 220, 220) else Color3.fromRGB(140, 140, 140)
			tile.Transparency = 0.4
		end

		tile.Parent = folder
	end
end

function SpatialStorage:updateVisualizationCounts()
	local workspace = game:GetService("Workspace")
	local debug = workspace:FindFirstChild("Debug")
	if not debug then
		return
	end
	local spatial = debug:FindFirstChild("Spatial")
	if not spatial then
		return
	end

	local cells = self._cells
	local total = self._cellsX * self._cellsZ

	for i = 1, total do
		local tile = spatial:FindFirstChild("Cell_" .. i)
		if not tile then
			continue
		end

		local count = 0
		for _ in pairs(cells[i]) do
			count += 1
		end

		-- Update tile color
		local idx = i - 1
		local cx = idx % self._cellsX
		local cz = floor(idx / self._cellsX)
		local isLight = (cx + cz) % 2 == 0

		if count > 0 then
			tile.Color = if isLight then Color3.fromRGB(255, 80, 80) else Color3.fromRGB(180, 40, 40)
			tile.Transparency = 0
		else
			tile.Color = if isLight then Color3.fromRGB(220, 220, 220) else Color3.fromRGB(140, 140, 140)
			tile.Transparency = 0.4
		end

		-- Update or create/remove label
		local existing = tile:FindFirstChildWhichIsA("BillboardGui")

		if count > 0 then
			if not existing then
				local billboard = Instance.new("BillboardGui")
				billboard.Name = "Count_" .. i
				billboard.Size = UDim2.new(2, 0, 1, 0)
				billboard.StudsOffset = Vector3.new(0, 2, 0)
				billboard.AlwaysOnTop = true
				billboard.Adornee = tile
				billboard.Parent = tile

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.TextColor3 = Color3.fromRGB(255, 255, 255)
				label.TextStrokeTransparency = 0
				label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				label.TextScaled = true
				label.Font = Enum.Font.GothamBold
				label.Parent = billboard
				existing = billboard
			end

			local label = existing:FindFirstChildWhichIsA("TextLabel")
			if label then
				label.Text = tostring(count)
			end
		else
			if existing then
				existing:Destroy()
			end
		end
	end
end

return SpatialStorage
