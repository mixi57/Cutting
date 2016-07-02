--Author: mixi
--Date: 2016-06-06 14:54:22
--Abstract: FrameTimer 定时帧 FrameTimerManager 是隐藏的管理
--[[使用例子
	local timer = FrameTimer.create()
    local index = 0
    local function haha()
        print("index ", index)
        index = index + 1
    end
    timer:addEventListener({
        {
            timerType = TimerType.ENTER, 
            handler = haha,
        }
    })
    timer:start()
]]
local FrameTimer = class("FrameTimer")
local TimerType = TimerType
local UniqueUtil
local function getUniqueId()
	-- 需要的时候获取
	if not UniqueUtil then
		UniqueUtil = UniqueID:create()
	end
	return UniqueUtil:newID()
end
function FrameTimer:ctor(params)
	self._id = getUniqueId()	-- 唯一id
	self._running = false		-- 运行否
	self._lastTime = false		-- 记录时间
	self._frameInterval = 1		-- 默认一帧执行一次
	self._repeatTimes = 0		-- 设置为运行次数，0为一直循环
	self._handlerMap = {}		-- 句柄表
	self._handleTimes = 0		-- 整个过程的执行句柄次数
	self._passInterval = 0		-- 每个循环已经执行的帧数目

	local timerTypeT = TimerType
	for i, v in pairs(timerTypeT) do
		self._handlerMap[v] = {handler = false, target = false}
	end
end

function FrameTimer:getId()
	return self._id
end

-- 是否运行状态
function FrameTimer:isRunning()
	return self._running
end
-- 暂停
function FrameTimer:pause()
	self._running = false
end
-- 恢复暂停
function FrameTimer:resume()
	self._running = true
end
-- 开始
function FrameTimer:start()
	self:resume()
	self._lastTime = TimeUtil.getCurTime()
	FrameTimerManager.addTimer(self)
end
-- 结束
function FrameTimer:endSelf()
	FrameTimerManager.removeTimer(self)
	self:dispose()
end

-- 帧间隔 多少帧执行一次 
function FrameTimer:setFrameInterval(interval)
	self._frameInterval = interval
end
function FrameTimer:getFrameInterval()
	return self._frameInterval
end

-- 执行次数 到了自动关闭移除 0 则一直
function FrameTimer:setRepeatTimes(times)
	self._repeatTimes = times
end
function FrameTimer:getRepeatTimes()
	return self._repeatTimes
end

--[[重点 帧定时器用来干什么 设置监听事件
@params	infoT
	timerType	监听事件类型
	handler 	监听函数
	target 		监听函数执行对象
]]
function FrameTimer:addEventListener(infoT)
	for i, v in ipairs(infoT) do
		local t = self._handlerMap[v.timerType]
		if t then
			t.handler = v.handler
			t.target = v.target
		end
	end
end
function FrameTimer:removeEventListerner(infoT)
	for i, v in ipairs(infoT) do
		local t = self._handlerMap[v.timerType]
		if t then
			t.handler = false
			t.target = false
		end
	end
end
function FrameTimer:handle()

	if not self._running then
		return
	end
	self._passInterval = self._passInterval + 1
	-- 到预定的触发时间
	if self._passInterval == self._frameInterval then
		local curT = TimeUtil.getCurTime()
		local passTime = curT - self._lastTime
		self._lastTime = curT
		self._passInterval = 0

		self:handleByTimerType(TimerType.ENTER)
	end
	self._handleTimes = self._handleTimes + 1
	if self._repeatTimes ~= 0 and self._handleTimes == self._repeatTimes then
		self:handleByTimerType(TimerType.EXIT)
		self:stop()
	end
end

function FrameTimer:handleByTimerType(timerType)
	local handler = self._handlerMap[timerType]
	if handler.handler then
		if handler.target then
			handler.handler(handler.target, self)
		else
			handler.handler(self)
		end
	end
end

function FrameTimer:dispose()
	self._running = false
	self._lastTime = false
end

return FrameTimer