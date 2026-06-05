-- ModuleScript: ModelDestroyer
-- Place inside the Model, or in ReplicatedStorage and require it from elsewhere

local ModelDestroyer = {}

--[[
    Destroys the given model after a delay.
    
    @param model    Model   - The model to destroy
    @param delay    number  - Seconds before destruction (default: 5)
    @param callback function - Optional function called just before destruction
]]
function ModelDestroyer.destroyAfter(model, delay, callback)
	assert(typeof(model) == "Instance" and model:IsA("Model"), "Expected a Model instance")

	delay = delay or 5

	task.delay(delay, function()
		if model and model.Parent then -- Check it hasn't already been destroyed
			if callback then
				callback(model)
			end
			model:Destroy()
		end
	end)
end

--[[
    Destroys the model the script is attached to after a delay.
    Convenience wrapper — call this when the ModuleScript lives inside the model.
    
    @param delay    number   - Seconds before destruction (default: 5)
    @param callback function - Optional function called just before destruction
]]
function ModelDestroyer.destroySelf(delay, callback)
	local model = script.Parent

	assert(model and model:IsA("Model"), "destroySelf must be called from inside a Model")

	ModelDestroyer.destroyAfter(model, delay, callback)
end

return ModelDestroyer
