local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RootUI = require(script.Parent.RootUI)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

return function(parent)
	local root = ReactRoblox.createRoot(parent)
	local app = e(RootUI)
	root:render(app)
	return function()
		root:unmount()
	end
end
