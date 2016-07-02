--Author: mixi
--Date: 2016-05-28 23:32:33
--Abstract: cache 用到的时候再加载
local Cache = {
	cacheMap = {},
	init = false
}

local function initCache(cacheName, cachePath, map)
	map[cacheName] = cachePath
end

local function setAutoInitCache(mapParent, map)
	setmetatable(mapParent, {
		__index = function(t, k)
			if map[k] ~= nil then
				local v = require(map[k])
				rawset(t, k, v)
				map[k] = nil
				return v
			end
		end
	})
end

local function getCacheInfo()
	local cacheInfo = {}
	for _, info in pairs(ModuleConfig) do
		if info.cacheInfo then
			table.insert(cacheInfo, info.cacheInfo)
		end
	end
	return cacheInfo
end
function Cache.init()
	local cacheInfo = getCacheInfo()

	for _, info in ipairs(cacheInfo) do
		initCache(info[1], info[2], Cache.cacheMap)
	end
	setAutoInitCache(Cache, Cache.cacheMap)
end

Cache.init()

return Cache