local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")

local UiConstants = require(StarterPlayer.StarterPlayerScripts.Client.UI.app.UiConstants)
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

local _debug = true

type MenuProps = {
	Size: UDim2,
	Position: UDim2,
	AnchorPoint: Vector2,

	Color: Color3?,
	StrokeColor: Color3?,
}

local function MenuFrame(props: MenuProps)
	return e("Frame", {
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		Size = props.Size or UDim2.fromScale(0.5, 0.5),

		BackgroundColor3 = props.Color or UiConstants.BACKGROUND_COLOR,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),
		Stroke = e("UIStroke", {
			Thickness = 4,
			Color = props.StrokeColor or UiConstants.TRIM_COLOR,
		}),
	})
end

return MenuFrame
