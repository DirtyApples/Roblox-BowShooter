local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	DEBUG_PROJECTILES = false,
	DEBUG_PROJECTILE_MODEL = ReplicatedStorage.Models.DebugArrow,

	PROJECTILE_MODEL = ReplicatedStorage.Models.Arrow,

	SPACIAL_STORAGE_CELL_SIZE = 20,
	SPACIAL_STORAGE_WIDTH = 100,
}
