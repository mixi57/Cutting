--Author: mixi
--Date: 2016-06-26 03:26:52
--Abstract: Enum 公用枚举值
ModuleViewType = {
	SCENE = "SCENE",		--场景，表示这个模块是独占一个场景
	PANEL = "PANEL",		--层，表示可以多个模块共在对应的scene上，层级自己控制
	POP = 	"POP",			--弹窗，跟层类似，但是层级不同，弹窗强制pop到最顶层
	-- FULL_POP = 	"FULL_POP",	--全屏的弹窗
}

LanguageType = {
	CN = 1,
	EN = 2,
}

TimerType = {
	ENTER	= 1,
	EXIT	= 2,
}

Enum = {
	-- 玩家种类
	PLAYER_TYPE = {
		MAIN_PLAYER = 1,
		NORMAL_PLAYER = 2,
	},

	PLAYER_STATE = {
		NORMAL = 1,
		RUNNING = 2,
		SLEEP = 3,
		INSERT = 4,
		END = 5,
	},
	
	NEAR_TYPE = {
		FRONT = 1,
		BACK = 2,
	},
}