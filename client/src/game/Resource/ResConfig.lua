--Author: mixi
--Date: 2016-06-02 23:56:06
--Abstract: ResConfigba
local ResConfig = {}
setmetatable(ResConfig, {
	__index = Resources
})
return ResConfig