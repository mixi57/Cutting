--Author: mixi
--Date: 2016-06-16 17:47:01
--Abstract: UserCacheManager
local UserCacheManager = {}

local UserDefault = cc.UserDefault:getInstance()
-- local UserCacheManager.setStringForKey(value)

local function getRoleName(noRoleName)
	if noRoleName then
		return ""
	end
	local roleId = Cache.playerCache.playerId
	if roleId then
		return string.format("_%s", roleId)
	end
	return ""
end

local function checkType(value, targetType)
	return value and type(value) == targetType
end

local function getKey(key, noRoleName)
	key = string.format("%s%s", key, getRoleName(noRoleName))
	return key
end

local AutoValueTypeAndFunc = false
function UserCacheManager.setValueForKey(key, value)
	if not AutoValueTypeAndFunc then
		AutoValueTypeAndFunc = {
			["string"] = UserCacheManager.setStringForKey,
			["bool"] = UserCacheManager.setBoolForKey,
			["number"] = UserCacheManager.setFloatForKey,
			["table"] = UserCacheManager.setTableForKey,
		}
	end
	local valueType = type(value)
	local func = AutoValueTypeAndFunc[valueType]
	if func then
		func(key, value, true)
	end
	
end

function UserCacheManager.setStringForKey(keyInfo, value, noCheck)
	if not noCheck then
		if not checkType(value, "string") then
			return false
		end
	end

	local key = getKey(keyInfo.key, keyInfo.isPublic)
	UserDefault:setStringForKey(key, value)
	UserDefault:flush()
end

function UserCacheManager.getStringForKey(keyInfo, defaultValue)
	local key = getKey(keyInfo.key, keyInfo.isPublic)
	return UserDefault:getStringForKey(key, defaultValue)
end

function UserCacheManager.setBoolForKey(keyInfo, value, noCheck)
	if not noCheck then
		if not checkType(value, "bool") then
			return false
		end
	end

	local key = getKey(keyInfo.key, keyInfo.isPublic)
	UserDefault:setBoolForKey(key, value)
	UserDefault:flush()
end

function UserCacheManager.getBoolForKey(keyInfo, defaultValue)
	local key = getKey(keyInfo.key, keyInfo.isPublic)
	return UserDefault:getBoolForKey(key, defaultValue)
end 

function UserCacheManager.setIntegerForKey(keyInfo, value, noCheck)
	if not noCheck then
		if not checkType(value, "number") then
			return false
		end
	end

	local key = getKey(keyInfo.key, keyInfo.isPublic)
	UserDefault:setIntegerForKey(key, value)
	UserDefault:flush()
end

function UserCacheManager.getIntegerForKey(keyInfo, defaultValue)
	local key = getKey(keyInfo.key, keyInfo.isPublic)
	return UserDefault:getIntegerForKey(key, defaultValue)
end

function UserCacheManager.setFloatForKey(keyInfo, value, noCheck)
	if not noCheck then
		if not checkType(value, "number") then
			return false
		end
	end

	local key = getKey(keyInfo.key, keyInfo.isPublic)
	UserDefault:setFloatForKey(key, value)
	UserDefault:flush()
end

function UserCacheManager.getFloatForKey(keyInfo, defaultValue)
	local key = getKey(keyInfo.key, keyInfo.isPublic)
	return UserDefault:getFloatForKey(key, defaultValue)
end 


local function tableToString(t, rep, tableRepL, tableRepR, level)
	local rep, tableRepL, tableRepR = rep or ",", tableRepL or "(", tableRepR or ")"
	local level = level or 0
	local levelRep = string.rep(" ", level)
	local valueType = type(t)
	if valueType == "table" then
		local temp = {}
		for i, v in pairs(t) do
			table.insert(temp, string.format("%s%s%s%s", i, tableRepL, tableToString(v, rep, tableRepL, tableRepR, level + 1), tableRepR))
		end
		return table.concat(temp, string.format("%s%s", rep, levelRep))
	else
		return tostring(t)
	end
end

local function stringToTable(str, level, rep, tableRepR, tableRepL)
	local rep, tableRepL, tableRepR = rep or ",", tableRepL or "(", tableRepR or ")"
	local level = level or 0
	
	local arr = {}
	local newRep = string.format("%s%s%%S", rep, string.rep(" ", level))
	local strArr = string.splitStr(
		str, 
		newRep,
		level + 1
	)
	level = level + 1
	local strRep = "%(.+%)"
	print("strstr", str, "__"..newRep.."__")
	printAll(strArr)
	for i, v in ipairs(strArr) do
		print("strArr v", v, strRep)
		local startP, endP = string.find(v, strRep)
		local newStr = string.sub(v, startP + 1, endP - 1)
		local name = string.sub(v, 1, startP - 1)
		local value
		if string.find(newStr, strRep) then
			value = stringToTable(newStr, level)
		else
			value = newStr
		end
		arr[name] = value
	end

	return arr
end

function UserCacheManager.setTableForKey(keyInfo, value, noCheck)
	if not noCheck then
		if not checkType(value, "table") then
			return false
		end
	end
	local str = tableToString(value)
	UserCacheManager.setStringForKey(keyInfo, str, true)
end

function UserCacheManager.getTableForKey(keyInfo, defaultValue)
	-- local key = getKey(keyInfo.key, keyInfo.isPublic)
	local str = UserCacheManager.getStringForKey(keyInfo)
	if not str then return defaultValue end
	return stringToTable(str)
end

return UserCacheManager