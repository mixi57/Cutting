--Author: mixi
--Date: 2016-05-30 21:56:15
--Abstract: Language
local Language = {
	desRes = false,
}

local function getDescription()
	if not Language.desRes then
		Language.desRes = ConfigManager.getRequireDesc("Description")
	end
	return Language.desRes
end

local function changeString(str, ...)
	if not str or type(str) ~= "string" then return "" end
	-- 判断... 长度
	if select("#", ...) > 0 then
		str = string.format(str, ...)
	end
	return str
end

--[[
根据id获取字符串
@param id 文字id
@param ... 填充数据
]]
function Language.getString(id, ...)
	if not id or not tonumber(id) then return "" end
	local str = getDescription()[id] or ""
	return changeString(str, ...)
end

return Language