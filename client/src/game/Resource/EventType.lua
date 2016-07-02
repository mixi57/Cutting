--Author: mixi
--Date: 2016-06-07 17:06:39
--Abstract: EventType 事件名
-----------------------------
-- 控制唯一id
local UniqueUtil = false
local IdCache = false
local function addIdToIdCache(id)
	if not IdCache then
		IdCache = {}
	end
	table.insert(IdCache, id)
end
local function pushIdFromIdCache()
	local id = table.remove(IdCache, 1)
	if #IdCache == 0 then
		IdCache = false
	end
	return id
end
local function getId()
	-- 需要的时候获取
	if not UniqueUtil then
		UniqueUtil = UniqueID:create()
	end
	if IdCache then
		return pushIdFromIdCache()
	end
	return UniqueUtil:newID()
end
-----------------------------
local EventType = {}
local EventNameGather = {
	"BALCONY_PLANT",
}

local pairsTable
pairsTable = function(t)
	for _, name in ipairs(t) do
		local nameType = type(name)
		if nameType == "string" then
			EventType[name] = getId()
		elseif nameType == "table" then
			pairsTable(name)
		else
			assert(false, string.format("Invail type", nameType))
		end
	end
end

pairsTable(EventNameGather)
print(string.format("There are %d event in our game", #EventType))

-- 临时增加
function EventType.addEventType(name)
	if not EventType[name] then
		EventType[name] = getId()
	end
end
function EventType.removeEventType(name)
	if EventType[name] then
		addIdToIdCache(EventType[name])
		EventType[name] = nil
	end
end

return EventType
