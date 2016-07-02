--Author: mixi
--Date: 2016-06-10 19:00:34
--Abstract: TableUtil

function table.clone(t, needDeepClone)
	local newT = {}
	for i, v in pairs(t) do
		-- if needDeepClone then
		-- 	local typeName = type(t)
		-- end
		newT[i] = v
	end
end

function table.size(t)
	local num = 0
	for i, v in pairs(t) do
		num = num + 1
	end
	return num
end