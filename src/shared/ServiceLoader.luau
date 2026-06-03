local runService = game:GetService("RunService")

local ServiceLoader = {}

export type ServiceConfig = {
	serviceParent: string,
	serviceChild: string,
}

local _configs = {
	server = {
		serviceParent = "ServerScriptService",
		serviceChild = "Services",
		type = "server",
	},
	client = {
		serviceParent = "StarterPlayer",
		serviceChild = "Services",
		type = "client",
	},
	shared = {
		serviceParent = "ReplicatedStorage",
		serviceChild = "Services",
		type = "shared",
	},
}

local _services = {}

local function _loadService(config)
	if config.type ~= "server" and runService:IsServer() then
		return {}
	end

	local serviceParent = game:GetService(config.serviceParent)
	local serviceChild = serviceParent.WaitForChild(config.serviceChild)

	local services = {}
	for i, serviceModule in pairs(serviceChild:GetChildren()) do
		local serviceName = serviceModule.Name
		local serviceData = require(serviceModule)
		services[serviceName] = serviceData
	end

	return services
end

local function _InitServices()
	for name, service in pairs(_services) do
		if service["Init"] then
			task.spawn(function()
				local initResult = service:Init()

				if initResult then
					print('[MODULE LOADER]: Successfully initiated "' .. name .. '" service')
				else
					warn('[MODULE LOADER]: Error while initiating "' .. name .. '" service')
				end
			end)
		end
	end
end

----------
-- API ---
----------

function ServiceLoader.Get(name: string)
	local service = _services[name]
	if service == nil then
		warn("Failed To Get Service %s from Service Loader", name)
	end
	return service
end

function ServiceLoader.LoadServices()
	for name, config in pairs(_configs) do
		local services = _loadService(config)
		for serviceName, service in pairs(services) do
			_services[serviceName] = service
		end
	end

	_InitServices()
end

return ServiceLoader
