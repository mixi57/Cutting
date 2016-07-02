--Author: mixi
--Date: 2016-06-06 15:25:34
--Abstract: UniqueID
local UniqueID = class("UniqueID")
function UniqueID:ctor(startNum)
	self._id = startNum or 100000000000
end

function UniqueID:newID()
	local id = self._id
	self._id = self._id + 1
	return id
end
return UniqueID