--Author: mixi
--Date: 2016-06-03 00:51:44
--Abstract: DebugUtil
local print = print
local table = table
local string = string
local type = type
local pairs = pairs

local printAll = function(target, params)
	local targetType = type(target)
	if targetType == "table" then
		local tip = params and params.tip or "Table detail:>>>>>>>>>>>>>>>>>>>>>>>"
		local cache = {[target] = "."}
		local isHead = false

		local function dump(t, space, level)
			local temp = {}
			if not isHead then
				temp = {tip}
				isHead = true
			end
			for k, v in pairs(t) do
				local key = tostring(k)
				if type(v) == "table" then
					table.insert(temp, string.format("%s+[%s]\n%s", string.rep(" ", level), key, dump(v, space, level + 1)))
				else
					table.insert(temp, string.format("%s+[%s]%s", string.rep(" ", level), key, tostring(v)))
				end
			end
			return table.concat(temp, string.format("\n%s", space))
		end
		print(dump(target, "", 0))
		print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
	elseif targetType == "userdata" then
		return printAll(debug.getuservalue(target), {tip = "Userdata's uservalue detail:"})
	else
		print("[printAll error]: not support type")
	end
end
return printAll
