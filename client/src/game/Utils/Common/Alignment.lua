--Author: mixi
--Date: 2016-06-06 08:33:55
--Abstract: ArrangeUtil 排位置 
--[[使用例子
	local labelT = {}
    for i = 1, 7 do 
        local label = UI.newText({
            text = "hah"..i,
            parent = layer,
            color = Style.ColorStyle.RED,
        })
        table.insert(labelT, label)
    end
    local postype = "CENTER"
    local params = {
        dataSource = labelT,
        interval = 10,
        isSameSize = true,
        targetPos = cc.p(500, 500),
        dir = ccui.LayoutType.HORIZONTAL, -- ccui.LayoutType.VERTICAL
        targetAnchorPoint = Style.PosStyle[postype],
    }
    Alignment.layout(params)

    local i = (1 + #params.dataSource) / 2
    local label = UI.newText({
        text = "hah"..i,
        parent = layer,
        color = Style.ColorStyle.BLACK,
        position = params.targetPos
    })
]]
local Alignment = {}
-- local list, move
local function list(params)
	local dataSource, dir, interval, isSameSize, itemSize = params.dataSource, params.dir, params.interval, params.isSameSize, params.itemSize
	local posT = {}
	local sizeT = {}
	local listItemSize
	local gatherSize = false
	local dataNum = #dataSource
	-- print("listlistlist isSameSize", isSameSize)
	if isSameSize then
		local itemSize = itemSize or dataSource[1]:getContentSize()
		local itemAnchorPoint = dataSource[1]:getAnchorPoint()
		local gatherSizeWidth, gatherSizeHeight
		local startPosX, startPosY, offsetX, offsetY
		if dir == ccui.LayoutType.HORIZONTAL then
			startPosX = itemAnchorPoint.x * itemSize.width
			startPosY = itemAnchorPoint.y * itemSize.height
			offsetX = itemSize.width + interval
			offsetY = 0
			gatherSizeWidth, gatherSizeHeight = itemSize.width * dataNum + interval * (dataNum - 1), itemSize.height
		elseif dir == ccui.LayoutType.VERTICAL then
			gatherSizeWidth, gatherSizeHeight = itemSize.width, itemSize.height * dataNum + interval * (dataNum - 1)
			startPosX = itemAnchorPoint.x * itemSize.width
			startPosY = gatherSizeHeight - itemSize.height * (1 - itemAnchorPoint.y)
			offsetX = 0
			offsetY = -(itemSize.height + interval)
		else
			print("TODO call mixi")
		end
		gatherSize = cc.size(gatherSizeWidth, gatherSizeHeight)
		for i, v in ipairs(dataSource) do
			table.insert(posT, 
				cc.p(
					startPosX + (i - 1) * offsetX,
					startPosY + (i - 1) * offsetY
				)
			)
		end
	else
		-- 不规则 TODO
		if dir == ccui.LayoutType.HORIZONTAL then
			print("TODO call mixi Alignment list")
		elseif dir == ccui.LayoutType.VERTICAL then
			print("not isSameSize dir == ccui.LayoutType.VERTICALdir == ccui.LayoutType.VERTICAL")
			local offsetX, offsetY, lastOffsetY = 0, 0, 0
			local gatherSizeWidth = 0
			for i, v in ipairs(dataSource) do
				local size = v:getContentSize() 
				local itemAnchorPoint = v:getAnchorPoint()
				offsetX = itemAnchorPoint.x * size.width
				offsetY = lastOffsetY - (1 - itemAnchorPoint.y) * size.height
				table.insert(posT, cc.p(offsetX, offsetY))
				lastOffsetY = lastOffsetY - size.height
				gatherSizeWidth = math.max(offsetX, gatherSizeWidth)
			end
			local gatherSizeHeight = -(lastOffsetY - dataSource[#dataSource]:getContentSize().height / 2)
			gatherSize = cc.size(gatherSizeWidth, gatherSizeHeight)
			for i, v in ipairs(posT) do
				v.y = v.y + gatherSizeHeight
			end
		end
	end
	return posT, gatherSize
end

local function move(params, posT, gatherSize)
	local dataSource, targetPos, targetAnchorPoint = params.dataSource, params.targetPos, params.targetAnchorPoint
	local offsetPos
	-- 如果有目标坐标 就移动 没有就按第一个排就好
	if targetPos then
		local anchorPoint = targetAnchorPoint
		local curPos = cc.p(
			gatherSize.width * anchorPoint.x,
			gatherSize.height * anchorPoint.y
		)
		offsetPos = cc.pSub(targetPos, curPos)
	else
		offsetPos = cc.pSub(dataSource[1]:getPosition(), posT[1])
	end
	for i, v in ipairs(dataSource) do
		v:setPosition(cc.pAdd(posT[i], offsetPos))
	end
end

local defaultParams = {
	-- dataSource = {},
	dir = ccui.LayoutType.HORIZONTAL,
	targetAnchorPoint = Style.PosStyle.CENTER,
	isSameSize = true,
	interval = 0,
}
local function fillParams(params)
	for name, value in pairs(defaultParams) do
		if params[name] == nil then
			params[name] = value
		end
	end
	return params
end
--[[
@params dataSource			必须是个表
@params dir 				排列类型  横 纵 都要
@params targetAnchorPoint 	目标点在整体的方位
@params targetPos			目标点
@params interval			间隔
@params isSameSize			相同大小
@params itemSize			大小
-- @params delay  			下一帧 todo
]]
-- 横的是从左到右 纵的是从上到下
function Alignment.layout(params)
	-- 先按间隔排列 在挪到适当地方
	local dataT = params.dataSource
	if not dataT or #dataT == 0 then
		print("Are you kidding me")
		return
	end
	local params = fillParams(params)
	local posT, gatherSize = list(params)
	move(params, posT, gatherSize)
	return gatherSize
end

return Alignment