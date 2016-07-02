--Author: mixi
--Date: 2016-06-15 13:05:02
--Abstract: FileUtil
FileUtil = {
	
}

local function getCurrDir()  
  os.execute("cd > cd.tmp")  
	os.execute("pwd")
  local f = io.open("cd.tmp", "r")  
  local cwd = f:read("*a")  
  f:close()  
  os.remove("cd.tmp")  
  return cwd  
end

function FileUtil.saveFile(fileName, data, fileUrl)
	
	local fileName = string.format("%s.lua", fileName)
	print("FileUtil saveFile ", fileName, data)
	local file = io.open(fileName, "w+")
	file:write(data)
	file:close()

	local fileUrl = fileUrl or ""
	-- 暂时写死
	os.execute(string.format("mv %s /Users/mixi/mixiGitLab/Succulent_Wizard/client/src%s", fileName, fileUrl))

	-- file:close()
end

local function transTableToString(tt, name)
	local str = ""
	local function analyFunc(t, space, level)
		local temp = {}
		local valueType = type(t)
		local rep = string.rep("  ", level)
		-- local repEnd = string.rep(" ", level - 1)
		if valueType == "table" then
			table.insert(temp, "{\n")
			for key, v in pairs(t) do
				local isNumber = tonumber(key)
				local pre
				if isNumber then
					pre = string.format("[%s]", isNumber)
				else
					pre = key
				end
				table.insert(temp, string.format("%s%s = %s,\n", rep, pre, analyFunc(v, space, level + 1)))
			end
			table.insert(temp, "}")--string.format("%s}", repEnd))
		else
			table.insert(temp, string.format("%s", t))
		end
		return table.concat(temp, string.format("%s", rep))
	end
	str = analyFunc(tt, "", 0)
	if name then
		str = string.format("local %s = %s\nreturn %s", name, str, name)
	else
		str = string.format("return %s", str)
	end
	return str
end

function FileUtil.saveConfigFile(configName, configTable)
	local data = transTableToString(configTable, configName)
	local fileUrl = "/game/Resource/config/config"
	print("FileUtil.saveConfigFile", fileUrl)
	FileUtil.saveFile(configName, data, fileUrl)
end


function FileUtil.tableToString(tt, name)
	local str = ""
	local function analyFunc(t, space, level)
		local temp = {}
		local valueType = type(t)
		local rep = string.rep("  ", level)
		-- local repEnd = string.rep(" ", level - 1)
		if valueType == "table" then
			table.insert(temp, "{\n")
			for key, v in pairs(t) do
				local isNumber = tonumber(key)
				local pre
				if isNumber then
					pre = string.format("[%s]", isNumber)
				else
					pre = key
				end
				table.insert(temp, string.format("%s%s = %s,\n", rep, pre, analyFunc(v, space, level + 1)))
			end
			table.insert(temp, "}")--string.format("%s}", repEnd))
		else
			table.insert(temp, string.format("%s", t))
		end
		return table.concat(temp, string.format("%s", rep))
	end
	str = analyFunc(tt, "", 0)
	if name then
		str = string.format("local %s = %s\nreturn %s", name, str, name)
	else
		str = string.format("return %s", str)
	end
	return str
end

return FileUtil
