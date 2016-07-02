--Author: mixi
--Date: 2016-06-17 09:00:42
--Abstract: StringUtil

--[[分割字符串 返回数组
str 	字符串
delim	分隔符
delimLen 间隔长度
]]
function string.splitStr(str, delim, delimLen)
	if not str or str == "" then
		print("inval str")
		return {}
	end
	local delim = delim or ","
	local delimLen = delimLen or string.len(delim)
	local arr = {}
	local start = 1
	print("string.splitstring.splitstring.split")
	while true do
		local pos = string.find(str, delim, start)
		print("string.split", pos)
		table.insert(arr, string.sub(str, start, pos and pos - 1))
		if not pos then
			break
		end
		start = pos + delimLen
	end
	return arr
end

