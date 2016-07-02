--Author: mixi
--Date: 2016-06-07 20:13:35
--Abstract: BaseConfig 让所有读表都是只读
local C = class("BaseConfig")
local index = 0
local function readOnly(t)
    local newT = {}
    local mt = {
        __index = t,
        __newindex = function(tt, k, v)
            print(string.format("别改我 我是只读的, 这里想让key %s 赋值 %s", k, v))
        end
    }
    setmetatable(newT, mt)
    return newT
end

function C:ctor(name)
	self._dict = false
	self._configName = name
	self._index = {index}
	print("BaseConfig ", index)
	index = index + 1
end
--[[
function C:getDict()
	if not self._dict then
		local config = ConfigManager.getRequireConfig(self:getConfigName())
		self._dict = config--readOnly(config)
	end
	return self._dict
end

function C:getConfigName()
	return self._configName
end

function C:getInfoByCode(code)
	return self:getDict()[code]
end

function C:getAttributeByCode(code, attributeName)
	print("getAttributeByCode", code, attributeName, self)
	-- printAll(self)
	-- printAll(C)
	local info = self:getInfoByCode(code)
	if info then
		return info[attributeName]
	end
end]]
function C:getDict()
	-- print("C.getConfigName", C.getConfigName(), C._index)
	if not self._dict then
		print("create Dict", self:getConfigName())
		local config = ConfigManager.getRequireConfig(self:getConfigName())
		self._dict = config --readOnly(config)
	end
	return self._dict
end

function C:getConfigName()
	return self._configName
end

function C:getInfoByCode(code)
	return self:getDict()[code]
end

function C:getAttributeByCode(code, attributeName)
	-- print("getAttributeByCode", self, code, attributeName)
	local info = self:getInfoByCode(code)
	if info then
		return info[attributeName]
	end
end
return C