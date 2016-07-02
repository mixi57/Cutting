--Author: mixi
--Date: 2016-06-06 15:00:10
--Abstract: 
local Scheduler = ViewUtil.director:getScheduler()
local print = print
local DEBUG = false
if not DEBUG then
	print = function() end 
end
local FrameTimerManager = {
	addTimer = false,
	removeTimer = false,
	removeAllTimer = false,
}

--定时器数量
local timerCount = 0
--所有定时器
local timerMap = {}
local scheduleId = false

local function handler()
	for _, timer in pairs(timerMap) do
		if timer then
			-- 如果触发器有效 处理改做的事情
			if timer:isRunning() then
				timer:handle()
			end
		end
	end
end
local function createSchedule()
	if not FrameTimerManager.scheduleId then
		FrameTimerManager.scheduleId = Scheduler:scheduleScriptFunc(handler, 0, false)
	end
end
local function removeSchedule()
	if FrameTimerManager.scheduleId then
		Scheduler:unscheduleScriptEntry(FrameTimerManager.scheduleId)
	end
end
--[[
@params timer 定时器
]]
function FrameTimerManager.addTimer(timer)
	local id = timer:getId()
	print("addTimer", id)
	if timer and not timerMap[id] then
		if timerCount == 0 then
			createSchedule()
		end
		timerMap[id] = timer
		timerCount = timerCount + 1
	end 
end

function FrameTimerManager.removeTimer(timer)
	local id = timer and timer:getId()
	if timerMap[id] then
		timer:dispose()
		timerMap[id] = nil
		timerCount = timerCount - 1

		-- 不需要的时候移除
		if timerCount == 0 then
			removeSchedule()
		end
	end
end

function FrameTimerManager.removeAllTimer()
	for _, v in pairs(timerMap) do
		v:dispose()
		v = nil
	end
	timerMap = {}
	timerCount = 0
	removeSchedule()
end

return FrameTimerManager