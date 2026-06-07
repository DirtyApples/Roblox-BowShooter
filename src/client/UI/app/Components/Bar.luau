local React = require(game.ReplicatedStorage.Packages.React)
local e = React.createElement

type BarProps = {
	Value: string?,
	Color: Color3?,
	Position: UDim2?,
	Size: UDim2?,
	AnchorPoint: Vector2?,
}

local function Bar(props: BarProps)
	local value = props.Value or 0.75 -- 0 to 1
	local color = props.Color or Color3.fromRGB(80, 200, 120)
	local size = props.Size or UDim2.fromScale(0.5, 0.025)
	local position = props.Position or UDim2.fromScale(0.5, 0.95)
	local anchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5)

	value = math.clamp(value, 0, 1)

	return e("Frame", {
		Size = size,
		Position = position,
		AnchorPoint = anchorPoint,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderSizePixel = 0,
	}, {
		Corner = e("UICorner", { CornerRadius = UDim.new(0, 6) }),

		Fill = e("Frame", {
			Size = UDim2.new(value, 0, 1, 0),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}, {
			FillCorner = e("UICorner", { CornerRadius = UDim.new(0, 6) }),
		}),
	})
end

return Bar
