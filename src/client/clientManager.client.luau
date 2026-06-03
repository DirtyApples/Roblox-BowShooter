local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local UserInputService = game:GetService("UserInputService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local ClientProjectileManager = require(StarterPlayer.StarterPlayerScripts.Client.Services.ClientProjectileManager)
local Events = require(ReplicatedStorage.Shared.Network.Events)
local PlayerEntity = require(ReplicatedStorage.Shared.classes.Entity.PlayerEntity)

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

-- Incomming --

-- EVENTS --

-- Respawn
button.Activated:Connect(function()
	Events.Player.RespawnRequest:Client():Fire(RobloxPlayer)
end)

-- Fire
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		RunService.RenderStepped:Wait() -- sync to render boundary
		local cameraCFrame = Workspace.CurrentCamera.CFrame
		local timestamp = Workspace:GetServerTimeNow()

		ClientProjectileManager.CreateProjectile(RobloxPlayer, cameraCFrame, PlayerEntity.DEFAULT_GUN_STATS)
		Events.Player.Shoot:Client():Fire(cameraCFrame, timestamp)
	end
end)

local function onUpdate(dt)
	--ServerEntityManager.Update(dt)
	ClientProjectileManager.Update(dt)
end

RunService.Heartbeat:Connect(onUpdate)
