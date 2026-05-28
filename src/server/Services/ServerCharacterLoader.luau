local Players = game:GetService("Players")
local ServerCharacterLoader = {}

function ServerCharacterLoader.ApplyDescription(humanoid: Humanoid, robloxPlayer: Player)
	local success, err = pcall(function()
		local description = Players:GetHumanoidDescriptionFromUserIdAsync(robloxPlayer.UserId)
		humanoid:ApplyDescriptionAsync(description)
	end)
	if not success then
		warn("Failed to apply description for", robloxPlayer.Name, err)
	end
end

return ServerCharacterLoader
