local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local MenuFrame = require(StarterPlayer.StarterPlayerScripts.Client.UI.app.Components.MenuFrame)
local HUD = require(StarterPlayer.StarterPlayerScripts.Client.UI.app.Menus.HUD)

local UiConstants = require(script.Parent.UiConstants)
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

local function RootUI()
	local debugBackDrop = e(MenuFrame, {
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Color = Color3.fromRGB(173, 173, 173),
		StrokeColor = Color3.fromRGB(173, 173, 173),
	})
	local ui = {
		hud = e(HUD, {}),
	}

	if UiConstants.DEBUG then
		table.insert(ui, debugBackDrop)
	end
	return e(React.Fragment, {}, ui)
end

return RootUI
