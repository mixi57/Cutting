--Author: mixi
--Date: 2016-05-29 18:47:31
--Abstract: GateSession
local GateSession = {}

function GateSession:send(request)
	
	local sessionName = request.sessionName
	local response = request.response

	if sessionName == "GetPlayerInfo" then
		local info = {
			playerId = 0,
			name = "mixi",
			level = 1,
			currency = 0,
			starValue = 0,
		}
		response(info)
	end
end

return GateSession