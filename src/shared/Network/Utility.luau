local Utility = {}

function Utility.Expect(value, name, expectedType)
	if typeof(value) ~= expectedType then
		error(
			string.format("[Net] Validation failed for '%s' — expected %s, got %s", name, expectedType, typeof(value)),
			2
		)
	end
end

return Utility
