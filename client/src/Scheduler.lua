--Author: mixi
--Date: 2016-06-08 20:57:45
--Abstract: Scheduler 定时器
local Scheduler = {}
local SchedulerMap = {
	global = {},
	normal = {},
	dirScheduler = false
}

local function getDirScheduler()
	if not Scheduler.dirScheduler then
		Scheduler.dirScheduler = cc.Director:getInstance():getScheduler()
	end
	return Scheduler.dirScheduler
end
--[[定时器
@params 
function 	callback 	定时回调的方法
number		interval	时间间隔
boolean		isPaused	是否暂停
number		repeatCount	回调次数 0位一直调
userdata	target		回调的调用目标 默认nil
number		delayT		延迟时间
]]
function Scheduler.schedule(callback, interval, isPaused, repeatCount, target, isGlobal, delayT)
	local interval, isPaused = interval or 1, isPaused or false
	local func, handle

	if repeatCount and repeatCount > 0 then
		func = function(...)
			if target then
				callback(target, ...)
			else
				callback(...)
			end
			repeatCount = repeatCount - 1
			if repeatCount == 0 then
				Scheduler.unschedule(handle)
			end
		end
	else
		if target then
			func = function(...)
				callback(target, ...)
			end
		else
			func = callback
		end
	end
	handle = getDirScheduler():scheduleScriptFunc(func, interval, isPaused)
	local map = SchedulerMap[isGlobal and "global" or "normal"]
	map[handle] = true
	return handle
end

--[[ 移除定时器

]]
function Scheduler.unschedule(handle)
	getDirScheduler():unscheduleScriptEntry(handle)
	if SchedulerMap.global[handle] then
		SchedulerMap.global[handle] = nil
	elseif SchedulerMap.normal[handle] then
		SchedulerMap.normal[handle] = nil
	end
end

--[[
]]
function Scheduler.unscheduleAll(includeGobal)
	for handle, _ in pairs(SchedulerMap.normal) do
		getDirScheduler():unscheduleScriptEntry(handle)
	end
	SchedulerMap.normal = {}

	if includeGobal then
		for handle, _ in pairs(SchedulerMap.global) do
			getDirScheduler():unscheduleScriptEntry(handle)
		end
		SchedulerMap.global = {}
	end
end

return Scheduler