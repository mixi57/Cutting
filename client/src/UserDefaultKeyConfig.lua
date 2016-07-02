--Author: mixi
--Date: 2016-06-16 18:16:39
--Abstract: UserDefaultKeyConfig
-- 用来管理玩家本地存储数据 分为区分玩家与不区分的两种
-- local UserDefaultKeyType = {
-- 	PRIVATE = 1,
-- 	PUBLIC = 2,
-- }
local function createKeyName(key, moduleConfig)
	if moduleConfig then
		return string.format("%s_%s", moduleConfig.name, key)
	end
	return key
end
local UserDefaultKeyConfig = {
	PLANT_INFO = {
		isPublic = false,
		key = createKeyName("PLANT_INFO", ModuleConfig.BALCONY),
	},
}
return UserDefaultKeyConfig, UserDefaultKeyType