--Author: mixi
--Date: 2016-06-07 16:05:41
--Abstract: Dispatcher -- 事件监听
local Dispatcher = {}
local EventMap = {}

function Dispatcher:clear()
	EventMap = {}
end

local ParamsType = {
	["name"] = {
		["string"] = true,
		["number"] = true,
	},
	["listener"] = {
		["function"] = true
	}
}
local function checkParams(infoT)
	for _, info in ipairs(infoT) do
		local name, value = info.name, info.value
		local valueType = type(value)
		if ParamsType[name] and not ParamsType[name][valueType] then
			assert(false, string.format("Invalid params %s", name))
		end
	end
end
--[[
@name			事件名
@listener 		监听函数
@target	监听函数调用者
-- @priority		优先级 默认0 按照加入的先后顺序  TODO
]]
function Dispatcher.addEventListener(name, listener, target, priority)
	checkParams({
		{"name", name},
		{"listener", listener}
	})
	-- 如果已经存在 覆盖
	-- if EventMap[name] then
	-- end
	EventMap[name] = {
		listener = listener,
		target = target,
	}
end

function Dispatcher.removeEventListener(name, listener, target)
	checkParams({
		{"name", name},
		{"listener", listener}
	})
	if EventMap[name] then
		EventMap[name] = nil
	end
end

function Dispatcher.dispatchEvent(name, ...)
	checkParams({
		{"name", name}
	})
	local event = EventMap[name]
	if event then
		event.listener(event.target, ...)
	end
end

function Dispatcher.checkEventListener(name)
	checkParams({
		{"name", name}
	})
	return EventMap[name] ~= nil
end

return Dispatcher