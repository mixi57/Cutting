--Author: mixi
--Date: 2016-06-23 11:07:32
--Abstract: FSM FiniteStateMachine
local FSM = class("FSM")

function FSM:ctor(owner)
	self._prevState = false -- 上一个状态
	self._curState = false	-- 当前状态
	self._owner	= owner or false		-- 拥有者

	self._curStateName = false
	self._prevStateName = false

	self._stateMap = {} -- 状态表
	--[[
	_stateMap = {
		[stateName1] = info,
	}
	]]

	self._linkMap = {} -- 链接表 
	--[[
	_linkMap = {
		[stateName] = nextStateName -- 一种方法
		[stateName] = {
			checkFunc(), -- function 返回结果
			[结果1] ＝ nextStateName,
			[结果2] ＝ nextStateName,
		}
	}
	]]
	self._uniqueUtil = false

	self._timer = false
	self._excuteState = false

	self._dirty = false -- 当执行一个动作时候插入一个新动作 的标志
	self._stateLevel = 0
	self._tag = false

	self._nextStateName = false
end

function FSM:setTag(tag)
	self._tag = tag
end

function FSM:changeState(stateName, level)
	if self._tag == 25 then
		print("FSM:changeState ", stateName, self._tag, self._owner)
	end
	local state = self._stateMap[stateName]
	if not state then
		print("该状态不存在 ", stateName)
		-- printAll(self._stateMap)
		return
	end
	local level = level or 0
	
	-- 当正在执行其他动作 
	if self._excuteState then
		if level > self._stateLevel then
			self._stateLevel = level
			self._dirty = true
			self._nextStateName = stateName
		else
			print("已有更高级的命令，低级命令不响应")
			return
		end
		print("正在执行其他动作")
		return
	end

	self._stateLevel = level

	-- 退出之前的状态
	if self._curStateName then
		self._curState:onExit(self._owner)
		self._prevStateName = self._curStateName
	end
	self._curState = state
	self._curStateName = stateName
	self._curState:onEnter(self._owner)

	self:startUpdate()
end

-- 检查并进入下一个状态
function FSM:checkState()

	self._excuteState = false
	-- self._dirty = false
	if self._dirty then
		self:changeState(self._nextStateName)
		self._dirty = false
		return
	end
	local nextStateInfo = self._linkMap[self._curStateName]
	local nextStateName
	if nextStateInfo then
		if type(nextStateInfo) == "table" then
			local checkFunc = nextStateInfo.checkFunc
			local var = checkFunc()
			nextStateName = nextStateInfo[var]
		else
			nextStateName = nextStateInfo
		end
	end
	if nextStateName then
		self:changeState(nextStateName)
	end
end

function FSM:startUpdate()
	if not self._timer then
		self._timer = FrameTimer:create()
		self._timer:addEventListener({
			{
				timerType = TimerType.ENTER,
				handler = self.update,
				target = self,
			}
		})
	end
	self._timer:start()
end

function FSM:endUpdate()
end

function FSM:stopUpdate()
end

function FSM:update()
	-- print("updateupdateupdate")
	if not self._curState then
		return
	end
	if self._excuteState then
		return
	end
	-- print("FSM update", self._owner)
	self._excuteState = true
	self._curState:excute(self._owner)
end
-----------------------------------
------------ 关于 State ------------
function FSM:newStateID()
	if not self._uniqueUtil then
		self._uniqueUtil = UniqueID:create(1000)
	end
	return self._uniqueUtil:newID()
end

--[[ 如果重复 会覆盖
{
	name,	-- 状态名字 唯一 stateName 
	state,	-- 状态对象 FSMStates
	linkInfo -- nextState 
			 -- or nextStateInfo
}
]]
function FSM:addState(stateInfo)
	local stateName = stateInfo.name
	if not stateName then
		print("没有状态名 先无效处理好了")
		print("FSM addState no name in stateInfo")
		return
	end
	local state = stateInfo.state
	if state then
		if self._stateMap[stateName] then
			print("重复的状态")
		else
			self._stateMap[stateName] = {}
			-- 把状态与状态机联系起来
			local id = self:newStateID()
			state:setMachine(self)
			state:setStateID(id)
		end
		self._stateMap[stateName] = state
		-- print("FSM addState", stateName)
		-- 如果有链接信息
		if stateInfo.linkInfo then
			self:linkStateInfo(stateName, stateInfo.linkInfo)
		end	
	else
		print("FSM addState no state in stateInfo")
	end
	return stateName
end

-- 链接状态与状态之间的信息
function FSM:linkStateInfo(stateName, linkInfo)
	if self._linkMap[stateName] then
		print("存在旧的链接信息 将会覆盖", stateName)
	end
	self._linkMap[stateName] = linkInfo
end

-----------------------------------
return FSM