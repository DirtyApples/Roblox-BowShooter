local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local react_charm = require(ReplicatedStorage.Packages["react-charm"])
local PlayerEntity = require(ReplicatedStorage.Shared.classes.Entity.PlayerEntity)
local Bar = require(StarterPlayer.StarterPlayerScripts.Client.UI.app.Components.Bar)
local MenuFrame = require(StarterPlayer.StarterPlayerScripts.Client.UI.app.Components.MenuFrame)
local UiConstants = require(StarterPlayer.StarterPlayerScripts.Client.UI.app.UiConstants)
local React = require(game.ReplicatedStorage.Packages.React)
local e = React.createElement

type HudProps = {
	Value: string?,
	Color: Color3?,
	Position: UDim2?,
	Size: UDim2?,
	AnchorPoint: Vector2?,
}

local playerAtom = PlayerEntity.GetAtom()

local function HUD(props: HudProps)
	local health = 0.5
	if not UiConstants.DEBUG then
		local playerId = Players.LocalPlayer.UserId
		local playerData = react_charm.useAtom(playerAtom)
		local playerEntry = playerData[tostring(playerId)]
		health = (playerEntry and playerEntry.health) or -1
	end

	local props = {
		Size = props.Size or UDim2.fromScale(0.5, 0.05),
		Position = props.Position or UDim2.fromScale(0.5, 0.95),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 1),

		Value = health,
	}

	local components = {}

	return e(Bar, props, components)
end

return HUD
