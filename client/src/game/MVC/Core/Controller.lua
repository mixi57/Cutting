--Author: mixi
--Date: 2016-05-27 22:53:34
--Abstract: Controller
local Controller = class("Controller")
local index = 1
function Controller:ctor(moduleConfig)
	self.__view__ = false
	-- self._moduleConfig = moduleConfig
	self:oncreate()
	-- print("new Controller", moduleConfig.name, index)
	index = index + 1
end

function Controller:oncreate()
end

function Controller:initServer()
	error("Controller:Need override initServer function")
end
function Controller:initView()
	error("Controller:need override initView function")
end

function Controller:onViewDestroy()
	error("Controller:Need override onViewDestroy function")
end

-- 一个controller 对应一个view
function Controller:getView()
	if not self.__view__ then
		-- 在initView之前先增加模块内部使用的事件监听 mixi 2015.08.11
		self:addModuleListener()
		-- 取ModuleView	
		self.__view__ = self:initView(self._moduleConfig)
		-- 调用ModuleView的initView()
		self.__view__:initView()
		if not self.__view__ then
			error("Controller:initView() return a nil value!")
		end
	end
	return self.__view__
end

function Controller:isBindView()
	return (self.__view__ and self:getView():getParent()) and true
end

function Controller:createAndBindView(targetScene)
	-- local view = self:getView()
	-- view:retain()
	-- view:removeFromParent()

	targetScene:addChild(self:getView())
	-- view:release()	
end

function Controller:removeAndCancelBindView()
	if self.__view__ then
		if self.__viewType__ == ModuleViewType.POP then
			AlertManager.hideWin(self.__view__)
		-- elseif self.__viewType__==ModuleViewType.FULL_POP then
		-- 	AlertManager.hideWin(self.__view__, true)
		else
			self.__view__:removeModuleFromScene()
		end
		self.__view__ = false
	end
	self:onViewDestroy()
	self:removeModuleListener()
end

--主模块事件
function Controller:addModuleListener()
end

function Controller:removeModuleListener()
end

return Controller

-- 思考 
--[[
1. 需要预加载资源功能不？
2. 需要子模块支持不
]]