local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = require(ReplicatedStorage.Shared.Network.Events)

local RobloxPlayer = Players.LocalPlayer

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = RobloxPlayer.PlayerGui

-- Create Button
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 150, 0, 50)
button.Position = UDim2.new(0, 20, 1, -70) -- bottom left
button.Text = "Respawn"
button.Parent = screenGui

-- Fire server on click
button.Activated:Connect(function()
	Events.Player.RespawnRequest:Client():Fire(RobloxPlayer)
end)
