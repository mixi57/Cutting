--Author: mixi
--Date: 2016-05-27 17:48:40
--Abstract: ModuleConfig
--[[
模块名字 ＝ { 
	name 		= 名字，用作输出标志,
	scene 		= 场景名字 默认为当前场景 对比当前场景 不同的话会切换场景
	viewType	= 模块类型
}
]]
local ModuleConfig = {
	MAIN = {
		name = "main",
		scene = "mainScene",
		viewType = ModuleViewType.SCENE,
		cacheInfo = {"mainCache", "game.Module.Main.MainCache"},
		controllerInfo = {"game.Module.Main.MainController", false},
		path = "game.Module.Main.MainModule",
	},
	-- PLAYER = {
	-- 	name = "player",
	-- 	-- scene = "mainScene",
	-- 	viewType = ModuleViewType.PANEL,
	-- 	cacheInfo = {"playerCache", "game.Module.Player.PlayerCache"},
	-- 	controllerInfo = {"game.Module.Player.PlayerController", false},
	-- 	path = "game.Module.Player.PlayerModule",
	-- },
	-- LOGIN = {
	-- 	name = "login",
	-- 	scene = "loginScene",
	-- 	viewType = ModuleViewType.SCENE,
	-- 	controllerInfo = {"game.Module.Login.LoginController", false},
	-- 	path = "game.Module.Login.LoginModule",
	-- },

	TEST = {
		name = "test",
		viewType = ModuleViewType.PANEL,
		cacheInfo = {"roomCache", "game.Module.Test.TestCache"},
		controllerInfo = {"game.Module.Test.TestController", false},
		path = "game.Module.Test.TestModule",
	},

}

return ModuleConfig