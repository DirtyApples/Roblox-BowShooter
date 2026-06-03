-- Shared/EventBus.lua
local EventBus = {}
local _listeners = {}

EventBus.Events = {
	projectileHits = "projectileHits",
}

function EventBus.Subscribe(event: string, fn: (...any) -> ())
	_listeners[event] = _listeners[event] or {}
	table.insert(_listeners[event], fn)
end

function EventBus.Publish(event: string, ...: any)
	if not _listeners[event] then
		return
	end
	for _, fn in ipairs(_listeners[event]) do
		fn(...)
	end
end

return EventBus
