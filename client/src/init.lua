--Author: mixi
--Date: 2016-05-28 02:06:37
--Abstract: init

-- 各种关于游戏框架的初始化

--[[
定个规矩
枚举，表类的文件名 都用大驼峰

常量 大写 不同单词用_连接

Config 结尾 是读配置的文件 可以直接包含配置在内

]]

-- 常量
require "game.Enum"
require "game.configuration"

-- 配置与读配置工具 是读配置的文件 可以直接包含配置在内 存配置放config里面
ModuleConfig 	= require "game.Resource.ModuleConfig"
FontConfig 		= require "game.Resource.FontConfig"
Language		= require "game.Resource.Language"
Resources		= require "game.Resource.Resources"
ResConfig		= require "game.Resource.ResConfig"
Style			= require "game.Resource.Style"
UserDefaultKeyConfig= require "UserDefaultKeyConfig"

-- 工具 是一些辅助接口 把一些常用功能封装
TimeUtil 		= require "game.Utils.Common.TimeUtil"
ViewUtil 		= require "game.Utils.Common.ViewUtil"
printAll		= require "game.Utils.Common.DebugUtil"
-- ArrangeUtil 	= require "game.Utils.Common.ArrangeUtil"
Alignment		= require "game.Utils.Common.Alignment"
FileUtil		= require "FileUtil"
AlgorithmUtil	= require "AlgorithmUtil"

Scheduler		= require "Scheduler"
require "TableUtil"
require "StringUtil"

-- 组件
UIComponent 	= require "game.Component.UIComponent"
UI 				= require "game.Component.UI"
AlertManager	= require "game.Component.AlertManager"
UniqueID		= require "game.Component.UniqueID"
FrameTimer		= require "game.Component.FrameTimer"
BaseConfig		= require "game.Component.BaseConfig"
ScrollBar 		= require "game.Component.ScrollBar"
List			= require "game.Component.List"

	
-- 管理 全局唯一的控制者
GameManager		= require "game.Manager.GameManager"
SceneManager	= require "game.Manager.SceneManager"
ConfigManager	= require "game.Manager.ConfigManager"
FrameTimerManager=require "game.Manager.FrameTimerManager"
UserCacheManager= require "UserCacheManager"

-- MVC
Controller 		= require "game.MVC.Core.Controller"
GameController 	= require "game.MVC.GameController"
View 			= require "game.MVC.Core.View"
Cache 			= require "game.MVC.Core.Cache"
Dispatcher		= require "game.MVC.Core.Dispatcher"


EventType 		= require "game.Resource.EventType"


-- test FSM
FSM 			= require "FSM"
FSMState		= require "FSMState"
