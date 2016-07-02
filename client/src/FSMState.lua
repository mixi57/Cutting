--Author: mixi
--Date: 2016-06-23 11:10:14
--Abstract: FSMState
local FSMState = class("FSMState")
local DEBUG = false
local print = print
if not DEBUG then
	print = function() end 
end
--[[
params	init 	初始化操作
params	onEnter	状态进入时执行的动作
params	onExit	状态退出时执行额动作
params  update  状态的更新操作
params  checkTransition 状态转移判断
]]
function FSMState:ctor(params)
	self._id = false
	self._machine = false

	-- 作为公有的 不带_
	-- self._init = params.init or self.defaultInit
	self.onEnter = params.onEnter or self.defaultEnter
	self.onExit = params.onExit or self.defaultExit
	-- self._update = params.update or self.defaultUpdate
	-- self._checkTransition = params.checkTransition or self.defaultCheckTransition
	self.excute = params.excute or self.defaultExcute
	-- self._excuteEnd = 

end

function FSMState:setMachine(machine)
	self._machine = machine
end

function FSMState:setStateID(id)
	self._id = id
end

function FSMState:defaultInit(target)
	print("FSMState init")
end

function FSMState:defaultEnter(target)
	print("FSMState onEnter")
end

function FSMState:defaultExit(target)
	print("FSMState onExit")
end

function FSMState:defaultExcute(target)
	print("FSMState excute")
	self:finishExcute()
end

function FSMState:finishExcute()
	if self._machine then
		self._machine:checkState()
	end
end

function FSMState:defaultCheckTransition(target)
	print("FSMState checkTransition")
	
end

return FSMState