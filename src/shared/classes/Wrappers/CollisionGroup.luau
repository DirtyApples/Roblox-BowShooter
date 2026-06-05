-- CollisionGroupManager.lua
local PhysicsService = game:GetService("PhysicsService")

local CollisionGroupManager = {}
CollisionGroupManager.__index = CollisionGroupManager

export type GroupConfig = {
	name: string,
	nonCollidableWith: { string }?,
}

-- Register a single group
function CollisionGroupManager.registerGroup(name: string)
	local success, err = pcall(function()
		PhysicsService:RegisterCollisionGroup(name)
	end)

	if not success then
		warn(`CollisionGroupManager: Failed to register group "{name}": {err}`)
	end
end

-- Register multiple groups at once
function CollisionGroupManager.registerGroups(groups: { GroupConfig })
	for _, group in ipairs(groups) do
		CollisionGroupManager.registerGroup(group.name)
	end

	-- Second pass to apply collidable rules (ensures all groups exist first)
	for _, group in ipairs(groups) do
		if group.nonCollidableWith then
			for _, otherGroup in ipairs(group.nonCollidableWith) do
				CollisionGroupManager.setCollidable(group.name, otherGroup, false)
			end
		end
	end
end

-- Set collidable between two groups
function CollisionGroupManager.setCollidable(groupA: string, groupB: string, collidable: boolean)
	local success, err = pcall(function()
		PhysicsService:CollisionGroupSetCollidable(groupA, groupB, collidable)
	end)

	if not success then
		warn(`CollisionGroupManager: Failed to set collidable "{groupA}" <-> "{groupB}": {err}`)
	end
end

-- Assign a part to a group
function CollisionGroupManager.assignPart(part: BasePart, groupName: string)
	part.CollisionGroup = groupName
end

-- Assign all BaseParts in a model to a group
function CollisionGroupManager.assignModel(model: Model, groupName: string)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = groupName
		end
	end
end

-- Build RaycastParams for a given group with optional exclusions
function CollisionGroupManager.buildRaycastParams(groupName: string, excluded: { Instance }?): RaycastParams
	local params = RaycastParams.new()
	params.CollisionGroup = groupName

	if excluded and #excluded > 0 then
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = excluded
	end

	return params
end

-- Check if two groups are collidable
function CollisionGroupManager.areCollidable(groupA: string, groupB: string): boolean
	return PhysicsService:CollisionGroupsAreCollidable(groupA, groupB)
end

return CollisionGroupManager
