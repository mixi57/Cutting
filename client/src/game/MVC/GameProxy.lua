--Author: mixi
--Date: 2016-05-29 17:49:59
--Abstract: GameProxy
local GameProxy = {
	proxyMap = {},
	init = false,
}

local function createProxy(path)
	return require(path).new()
end

-- 初始化网络
local function initPoxy(proxyName, path, needDelay, mapParent, map)
	if needDelay then
		map[proxyName] = path
	else
		mapParent[proxyName] = createProxy(path)
	end
end

local function setAutoInitProxy(mapParent, map)
	setmetatable(mapParent, {
		__index = function(t, k)
			if map[k] ~= nil then
				local v = createProxy(map[k])
				t.rawset(t, k, v)
				map[k] = nil
				return v
			end
		end
	})
end

function GameProxy.init()
	local proxyInfo = {
		{"player", "game.module.player.PlayerProxy", false}
	}

	for _, info in ipairs(proxyInfo) do
		print(unpack(info))
		initPoxy(unpack(info), GameProxy, GameProxy.proxyMap)
	end

	setAutoInitProxy(GameProxy, GameProxy.proxyMap)
end