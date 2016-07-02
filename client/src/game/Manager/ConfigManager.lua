--Author: mixi
--Date: 2016-05-30 22:19:56
--Abstract: ConfigManager 配置表读取管理，为了方便多语言的切换
local ConfigManager = {
	configMap = {}
}
local MIDDLE_NAME = "game.Resource.config"
local CONFIG_PRE_PATH = string.format("%s.config", MIDDLE_NAME)
function ConfigManager.getRequireDesc(configName)
    return ConfigManager.getRequire(configName, MIDDLE_NAME)
end

function ConfigManager.getRequireConfig(configName)
	return ConfigManager.getRequire(configName, CONFIG_PRE_PATH)
end

function ConfigManager.getRequire(configName, middleName)	
	local path = string.format("%s.%s", middleName, configName)
	local res
	local function getRequireResult()
		res = require(path)
	end

	-- 搜索不到时的处理
	xpcall(
		getRequireResult, 
		function(msg)
			res = {}
		end
	)
	return res
end

local ConfigPathMap = {
	{"ConstInfo", "t_const"},
}

local function createConfig(configName)
	return BaseConfig.new(configName)
end

local function createPath(path)
	return require(path)
end

--[[
#params	configName
#params name
#params path
]]

local function delayInitConfig(name, configName, path)
	local obj = {cn = configName, p = path, n = name}
	setmetatable(obj, {
		__index = function(t, k)
			local configName, path, name = rawget(t, "cn"), rawget(t, "p"), rawget(t, "n")
			local config
			print("delayInitConfig ", configName)
			if configName then
				config = createConfig(configName)
				t.cn = nil
			elseif path then
				config = createPath(path)
				t.p = nil
			end
			t.n = nil
			setmetatable(t, nil)
			rawset(_G, name, config)
			return _G[name][k]--config -- 
		end,
	})
	rawset(_G, name, obj)
end

local function init()
	for _, info in ipairs(ConfigPathMap) do
		delayInitConfig(info[1], info[2])
		-- rawset(_G, info[1], createConfig(info[2]))
	end
	for _, info in ipairs(ConfigPathMap) do
		print("init", _G[info[1]]._index[1])		-- rawset(_G, info[1], createConfig(info[2]))
	end
end

init()

return ConfigManager