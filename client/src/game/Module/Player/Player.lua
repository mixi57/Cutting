--Author: mixi
--Date: 2016-06-25 00:40:35
--Abstract: Player
local Player = class("Player", ccui.Widget)
local PlayerActionTag = 1000
local ShowActionZOrder = 10
local HideActionZOrder = 0
function Player:ctor(gameScene)
	self._target = UI.newImageView({
		parent = self,
		anchorPoint = cc.p(0.5, 0),
		url = self:getPath(),
	})

	-- self._fsm = FSM:create(self._node)
	-- self._stepLenght = stepLenght

	self._moveTime = ConstInfo:getDict().PLAYER_MOVE_TIME
	self._gameScene = gameScene

	-- print("Player:ctor(state, pos, stepLenght, linePos)", state, pos, stepLenght, linePos)
	self._state = Enum.PLAYER_STATE.NORMAL
	self._prevRole = false
	self._nextRole = false
	self._offset = 0
	self._stepLenght = Cache.mainCache.playerInterval

	self._waitTime = ConstInfo:getDict().WAIT_TIME
	self._actionTable = {}
	-- self:updateSleepSchedule()
	
	local size = self:getContentSize()
	local touchSize = cc.size(self._stepLenght - 20, size.height)
	local layout = UI.newLayout({
		parent = self,
		-- color = Style.ColorStyle.GRAY,
		zOrder = 100,
		size = touchSize,
		touchEnabled = true,
		-- opacity = 100,
		-- x = - size.width / 2,
	})
	layout:addTouchEventListener(function(handle, eventType)
        if eventType == ccui.TouchEventType.ended then
        	-- print("State ", self._state, self._offset)
        	-- printAll({self, TimeUtil.getCurTime()})
        	local var = self:checkState()
        	self._gameScene:touchOffsetPlayer(self._offset, var, self)
        	if var then
        		self:changeState(Enum.PLAYER_STATE.END)
        	end
        	-- layout:setBackGroundColor(Style.ColorStyle.RED)
        	-- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        end
    end)

	self:cachePlayerAction()
	self:stopLastState()
end

function Player:cachePlayerAction()
	local actionInfoTable = {
		{
			name = "_normalAction",
			plistPath = ResConfig.plist.daiji,
			pngPath = ResConfig.png.daiji,
			frameTime = 1,
			frameNameInfo = {
				min = 0,
				max = 3,
				strFormat = "daiji1_%d.png"
			}
		},
		{
			name = "_sleepAction",
			plistPath = ResConfig.plist.shuijiao,
			pngPath = ResConfig.png.shuijiao,
			frameTime = 0.1,
			frameNameInfo = {
				min = 0,
				max = 3,
				strFormat = "shuijiao_%d.png"
			}
		},
		{
			name = "_endAction",
			plistPath = ResConfig.plist.angry,
			pngPath = ResConfig.png.angry,
			frameTime = 0.1,
			frameNameInfo = {
				min = 0,
				max = 3,
				strFormat = "angry_%d.png"
			}
		}
	}

	for i, v in ipairs(actionInfoTable) do
		local plistPath, pngPath, frameTime = v.plistPath, v.pngPath, v.frameTime
	    local frameNameTable = {}
	    local frameNameInfo = v.frameNameInfo
	    for i = frameNameInfo.min, frameNameInfo.max do
	        table.insert(frameNameTable, string.format(frameNameInfo.strFormat, i))
	    end 
	    self[v.name] = UI.newEffect({
	        parent = self,
	        plistPath = plistPath,
	        pngPath = pngPath,
	        frameNameTable = frameNameTable,
	        frameTime = frameTime,
	        y = self:getActionOffsetY()
	    })
	    table.insert(self._actionTable, self[v.name])
	end
end

function Player:changePosState()
	if self._prevRole then
		self._prevRole:setCheckSelfPos(true)
	end
end

function Player:getPath()
	return ResConfig.png.peopleNormal
end

function Player:getContentSize()
	return self._target:getContentSize()
end

function Player:changeState(state, offset, callback, targetPosX, time)
	self._target:setVisible(false)
	self:stopLastState()
	
	if state == Enum.PLAYER_STATE.NORMAL then
		self:normal()
	elseif state == Enum.PLAYER_STATE.RUNNING then
		self:running(offset, time, callback)
	elseif state == Enum.PLAYER_STATE.SLEEP then
		self:sleep()
	elseif state == Enum.PLAYER_STATE.INSERT then
		self:insert(offset, callback, targetPosX)
	elseif	state == Enum.PLAYER_STATE.END then
		self:endAction(offset)
	end
	self._state = state
end

function Player:getActionOffsetY()
	return 88
end

function Player:stopLastState()
	for i, v in ipairs(self._actionTable) do
		v:setVisible(false)
		v:setLocalZOrder(HideActionZOrder)
	end
	self:stopAllActionsByTag(PlayerActionTag)
end

function Player:showAction(action)
	for i, v in ipairs(self._actionTable) do
		v:setVisible(false)
		v:setLocalZOrder(HideActionZOrder)
		v:setPositionY(- ViewUtil.winSize.height)
	end
	action:setVisible(true)
	action:setLocalZOrder(ShowActionZOrder)
	action:setPositionY(self:getActionOffsetY())
end

function Player:sleep()
	-- printAll({self, "sleep", TimeUtil.getCurTime()})
	self:showAction(self._sleepAction)
	local time = math.random(1, 4)
	local action = cc.Sequence:create(
		cc.DelayTime:create(time),
		cc.CallFunc:create(function()
			self:changeState(Enum.PLAYER_STATE.NORMAL)
		end)
	)

	action:setTag(PlayerActionTag)
	self:runAction(action)
end

function Player:endAction()
	local action = cc.Sequence:create(
		cc.DelayTime:create(ConstInfo:getDict().GAME_OVER_ACTION_TIME),
		cc.CallFunc:create(function()
			self:showAction(self._endAction)
		end)
	)
	action:setTag(PlayerActionTag)
	self:runAction(action)
end

function Player:insert()
	print("normal has no insert")
end

function Player:running(offset, time, callback)
	print("Player running", offset)
	local time = time or self._moveTime * offset / self._stepLenght
	local action = cc.MoveBy:create(time, cc.p(offset, 0))	
	local sequenceAction = cc.Sequence:create(
		action, 
		cc.CallFunc:create(function()
			self:changeState(Enum.PLAYER_STATE.NORMAL)
			if callback then
				callback()
			end
		end)
	)			
	sequenceAction:setTag(PlayerActionTag)
	self:runAction(sequenceAction)
end

function Player:normal()
	self:showAction(self._normalAction)
	
	-- local time = math.random(1, 4)
	-- local sleepEnabled = self._offset >  0
	-- if sleepEnabled then
		-- self:runAction(cc.Sequence:create(
		-- 		cc.DelayTime:create(time),
		-- 		cc.CallFunc:create(function()
		-- 			self:changeState(Enum.PLAYER_STATE.SLEEP)
		-- 		end)
		-- 	)
		-- )
	-- end
end

function Player:updateSleepSchedule()
	local time = math.random(3, 100)
	time = time / 10
	Scheduler.schedule(
		function()
			-- self:sleep()
			self:changeState(Enum.PLAYER_STATE.SLEEP)
		end,
		time,
		false,
		1,
		self
	)
end

function Player:setOffset(offset)
	self._offset = offset
end
function Player:getOffset()
	return self._offset
end

-- 检查人物的状态
function Player:checkState()--false--true--
	return self._state ~= Enum.PLAYER_STATE.SLEEP -- true--false
end

function Player:setCheckSelfPos(var)
	self:runAction(
		cc.DelayTime:create(self._waitTime),
		cc.CallFunc:create(function()
			if self._nextRole then
				if self._nextRole:getPositionX() - self:getPositionX() > self._stepLenght then
					self:changeState(Enum.PLAYER_STATE.RUNNING)
				end
			end
		end)
	)
end

-- 某个方向的人提醒我要调位置
function Player:checkSelfPos(nearType, time)
	local targetposX
	local target
	local oppositeNearType
	-- printAll({"checkSelfPoscheckSelfPoscheckSelfPoscheckSelfPos", self._prevRole, self, self._nextRole, nearType})
	-- 前面的人提醒我挪后面
	if nearType == Enum.NEAR_TYPE.FRONT then
		if self._prevRole then
			local posX = self._prevRole:getPositionX()
			targetposX = posX + self._stepLenght
			target = self._nextRole
			oppositeNearType = Enum.NEAR_TYPE.BACK
		end
	-- 后面的人提醒我挪前面	
	elseif nearType == Enum.NEAR_TYPE.BACK then
		if self._nextRole then
			local posX = self._nextRole:getPositionX()
			targetposX = posX - self._stepLenght
			target = self._prevRole
			oppositeNearType = Enum.NEAR_TYPE.FRONT
		end
	end

	if targetposX then
		local offset = targetposX - self:getPositionX()
		 -- nearType, time)
		-- printAll({"checkSelfPoscheckSelfPos", self, offset, time, nearType, targetposX})
		if math.abs(offset) > 3 then
			local callback = function()
				self:tellTheNearByChangeTheirPos(oppositeNearType, time)
			end

			self:runAction(
				cc.Sequence:create(
					cc.DelayTime:create(ConstInfo:getDict().DELAY_TIME),
					cc.CallFunc:create(function()
						self:changeState(Enum.PLAYER_STATE.RUNNING, offset, callback, false, time)
					end)
				)
			)
		end
	end
end

--告诉邻近的人调整位置
function Player:tellTheNearByChangeTheirPos(nearType, time)
	local targetposX
	local target
	local oppositeNearType
	-- printAll({"tellTheNearByChangeTheirPos", self._prevRole, self, self._nextRole})
	if nearType == Enum.NEAR_TYPE.FRONT then
		if self._prevRole then
			local posX = self._prevRole:getPositionX()
			targetposX = posX + self._stepLenght
			target = self._prevRole
			oppositeNearType = Enum.NEAR_TYPE.BACK
		end
	elseif nearType == Enum.NEAR_TYPE.BACK then
		if self._nextRole then
			local posX = self._nextRole:getPositionX()
			targetposX = posX - self._stepLenght
			target = self._nextRole
			oppositeNearType = Enum.NEAR_TYPE.FRONT
		end
	end
	if target then
		target:checkSelfPos(oppositeNearType, time)
	end
end

function Player:refresh()
	self._prevRole = false
	self._nextRole = false
	self:stopLastState()
end
return Player