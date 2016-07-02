--Author: mixi
--Date: 2016-06-03 10:36:48
--Abstract: Style
-- 要不定个规矩 常量 大驼峰
-- 补充display 里面的内容
local Style = {
	
	DEFALUT_BTN_STYLE = {
		normal 	= ResConfig.png.commonBtnHong,
		pressed = ResConfig.png.commonBtnHong,
		disabled= ResConfig.png.commonBtnHong,
	},

	ColorStyle = {
		RED 	= display.COLOR_RED,
		BLACK 	= display.COLOR_BLACK,
		GRAY 	= cc.c3b(128, 128, 128),
		WHITE	= display.COLOR_WHITE,
		GREEN	= display.COLOR_GREEN,
		BLUE	= display.COLOR_BLUE,	
	},

	PosStyle = {
		CENTER 	= display.CENTER,
		LEFT	= display.LEFT_CENTER,
		RIGHT	= display.RIGHT_CENTER,
		TOP		= display.CENTER_TOP,
		BOTTOM	= display.CENTER_BOTTOM,

		LEFT_TOP = display.LEFT_TOP,
		LEFT_BOTTOM = display.LEFT_BOTTOM,
		RIGHT_TOP = display.RIGHT_TOP,
		RIGHT_BOTTOM = display.RIGHT_BOTTOM,
	},

	DEFALUT_SCROLL_BAR_WIDTH = 12,
	DEFALUT_SCROLL_BAR_STYLE = {
		bar = ResConfig.png.commonBgGundontiao03,	-- 滚动条图
		bg = ResConfig.png.commonBgGundontiao04,	-- 背景图
		interval = 0,								-- 滚动条与背景之间的间隙 好像没啥用
		dir = ccui.LayoutType.VERTICAL, 			-- 两者一般是一套的 所以方向一致 默认是竖立的
	},
	DEFALUT_SIZE = cc.size(0, 0),
	DEFAULT_ACCORDION_STYLE = {
		bg = ResConfig.png.commonTitleLachu,
		signBg = ResConfig.png.commonBgJiantouXia,
		height = 40,
	},
	-- DEFALUT_MARGIN	=	UI.new


}
return Style