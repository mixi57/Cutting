--Author: mixi
--Date: 2016-06-16 10:50:35
--Abstract: algorithmUtil 算法
local AlgorithmUtil = {}

-- 假设是顺序数组 需要折半搜索与value相等的数据, nearBy为true的时候，如果找不到也会返回合适的位置
function AlgorithmUtil.halfSearch(array, value, nearBy, getValueFunc, startPos, endPos)
	local startPos, endPos = startPos or 1, endPos or #array
	local getValueFunc = getValueFunc or function(index)
		return array[index]
	end
	local num = endPos - startPos
	if num < 0 then
		if nearBy then
			return 1
		end
		return false
	else
		local startValue, endValue = getValueFunc(startPos), getValueFunc(endPos)
		if not startValue or not endValue then
			return false
		end
		if startValue >= value then
			if startValue == value then
				return startPos
			end
			if nearBy then
				local prevPos = startPos - 1
				if prevPos > 1 then
					local prevValue = getValueFunc(startPos - 1)
					if prevValue and prevValue < value then
						return startPos
					end
				else
					return startPos
				end
			end
			return false
		elseif endValue <= value then
			if endValue == value then
				return endPos
			end
			if nearBy then
				return endPos + 1
			end
			return false
		else
			local lastEndPos = math.floor((endPos + startPos) / 2)
			-- 注意顺序
			local var = AlgorithmUtil.halfSearch(array, value, nearBy, getValueFunc, lastEndPos + 1, endPos)
				or AlgorithmUtil.halfSearch(array, value, nearBy, getValueFunc, startPos, lastEndPos) 

			if not var and nearBy then
				return startPos + 1
			end
			return var
		end 
	end
end

return AlgorithmUtil