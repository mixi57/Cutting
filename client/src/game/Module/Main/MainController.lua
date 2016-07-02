--Author: mixi
--Date: 2016-05-28 22:24:15
--Abstract: BalconyController
local C = class("BalconyController", Controller)

function C:ctor(...)
	self.super:ctor(...)
	self._moduleConfig = ...
	self.module = false
	-- self.proxy = false
end

function C:initView(moduleConfig)
	if not self.module then
		self.module = require (moduleConfig.path):new()
	end
	return self.module
end

--游戏初始化侦听
--注册全局事件侦听，游戏一运行后，就无法移除
function C:initServer()
end

--模块打开时系统自动调用
--在此注册模块需要侦听的事件
function C:addModuleListener()
end

--模块关闭时系统自动调用
--在此注销模块已侦听的事件
function C:removeModuleListener()
end

function C:onViewDestroy()
end

return C