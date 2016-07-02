--Author: mixi
--Date: 2016-05-29 16:58:18
--Abstract: Proxy
local Proxy = class("Proxy")

function Proxy:ctor()
end

function Proxy:getProxy()
end

local function defaultResponse()
	print("Proxy defaultResponse")
end

local function defaultException(res)
	-- MsgManager.tipsException(res.err)
end

local function defaultTimeout()
	-- MsgManager.tipsException()
end

function Proxy:getCallBackObj(response, exception, timeout)
	return response or defaultResponse, exception or defaultException, timeout or defaultTimeout
end

-- 打包
local function decorateReq(...)
	local target, msg, sessionName, response, exception, timeout = ...
	local request = {
		target = target, 
		msg = msg, 
		sessionName = sessionName, 
		response = response, 
		exception = exception, 
		timeout = timeout
	}
	return request
end

function Proxy:sendReq(...)
	GateSession:send(decorateReq(self, ...))
end
return Proxy