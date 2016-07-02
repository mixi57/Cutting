--Author: mixi
--Date: 2016-05-27 17:36:47
--Abstract: time
local TimeUtil = {}

function TimeUtil.getCurTime()
	local time = os.time()
	return time
end

return TimeUtil