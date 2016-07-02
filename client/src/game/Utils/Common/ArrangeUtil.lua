--Author: mixi
--Date: 2016-06-04 23:13:08
--Abstract: ArrangeUtil
local ArrangeUtil = {
	shiftX = false,
	shiftY = false,
	dataSource = false,
	isVertical = false,
	interval = false,
	arrangeType = false,
}
local WinSize = ViewUtil.winSize
local WinX, WinY = WinSize.width/2, WinSize.height/2
local anchorPos = {
	cc.p(0.5,0.5),
	cc.p(0,0.5),
	cc.p(1,0.5),
	cc.p(0.5,1),
	cc.p(0.5,0),
}

local clientEnum = {}
local function createEnum(name, enumTb, origin)
	local enumMap = {}
	local index = origin or 1
	for i,v in ipairs(enumTb) do
		enumMap[v] = index
		index = index + 1
	end
	
	clientEnum[name] = enumMap
end

createEnum("ARRANGE_TYPE",{
	"CENTER",
	"LEFT",
	"RIGHT",
	"TOP",
	"BOTTOM",
})


function ArrangeUtil.list(params)
	local _params = {
		dataSource = params.dataSource, 			-- 传入的节点对象表
		interval = params.interval or 0,			-- 对象之间的间隔
		isVertical = params.isVertical or false,	-- 是否为竖直方向
		shiftX = params.targetPos.x or 0,			-- X坐标偏移量
		shiftY = params.targetPos.y or 0,			-- Y坐标偏移量
		arrangeType = 	clientEnum.ARRANGE_TYPE[params.arrangeType] or clientEnum.ARRANGE_TYPE["CENTER"], -- 传入对齐的类型,相对于参考点的位置
	}
	ArrangeUtil.shiftX, ArrangeUtil.shiftY = _params.shiftX,_params.shiftY
	ArrangeUtil.dataSource = _params.dataSource
	ArrangeUtil.isVertical = _params.isVertical
	ArrangeUtil.interval = _params.interval
	ArrangeUtil.arrangeType = _params.arrangeType
	ArrangeUtil.createBox()
	ArrangeUtil.shiftBox()
end

function ArrangeUtil.getTotalSize() 		-- 获得整个组件的大小
	local width,height,intervalX,intervalY = 0,0,0,0
	if ArrangeUtil.isVertical then
		intervalY = ArrangeUtil.interval
	else
		intervalX = ArrangeUtil.interval
	end
	for k,v in pairs(ArrangeUtil.dataSource) do
		width = width + v:getContentSize().width + intervalX
	end
	for k,v in pairs(ArrangeUtil.dataSource) do
		height = height + v:getContentSize().height + intervalY
	end
	return cc.size(width,height)
end

function ArrangeUtil.getPos(idx) 		-- 获得每个对象在组件中的位置
	local ContentSizeTbl = {}
	for k,v in pairs(ArrangeUtil.dataSource) do
		ContentSizeTbl[k] = v:getContentSize()
	end
	ArrangeUtil.ContentSizeTbl = ContentSizeTbl
	if idx == 1 then
		return 0
	end
	if ArrangeUtil.isVertical then
		if ArrangeUtil.arrangeType==4 then
			return ContentSizeTbl[idx].height + ArrangeUtil.interval
		elseif ArrangeUtil.arrangeType==5 then
			return ContentSizeTbl[idx-1].height + ArrangeUtil.interval
		else
			return ContentSizeTbl[idx].height/2 + ContentSizeTbl[idx-1].height/2 + ArrangeUtil.interval
		end
	else
		if ArrangeUtil.arrangeType==2 then
			return ContentSizeTbl[idx-1].width + ArrangeUtil.interval
		elseif ArrangeUtil.arrangeType==3 then
			return ContentSizeTbl[idx].width + ArrangeUtil.interval
		else
			return ContentSizeTbl[idx].width/2 + ContentSizeTbl[idx-1].width/2 + ArrangeUtil.interval
		end
	end
end

function ArrangeUtil.createBox() 		-- 设定组件对象位置
	local lastPos = 0
	local anchorTar = anchorPos[ArrangeUtil.arrangeType]
	local anchorCur = cc.p(0,0)
	local x,y
	for i,v in ipairs(ArrangeUtil.dataSource) do
		anchorCur = v:getAnchorPoint()
		x = (anchorCur.x - anchorTar.x)*v:getContentSize().width
		y = (anchorCur.y - anchorTar.y)*v:getContentSize().height
		if not ArrangeUtil.isVertical then
			v:setPosition(cc.p(ArrangeUtil.getPos(i)+ArrangeUtil.shiftX+lastPos+x,ArrangeUtil.shiftY+y))
		else
			v:setPosition(cc.p(ArrangeUtil.shiftX+x,ArrangeUtil.getPos(i)+ArrangeUtil.shiftY+lastPos+y))
		end
		lastPos = ArrangeUtil.getPos(i) + lastPos
	end
end

function ArrangeUtil.shiftBox() 			-- 实现对齐等效果
	local shiftX,shiftY = 0,0
	local ContentSizeTbl = ArrangeUtil.ContentSizeTbl
	if ArrangeUtil.isVertical then
		if ArrangeUtil.arrangeType==4 then
			shiftY = ContentSizeTbl[1].height - ArrangeUtil.getTotalSize().height
		elseif ArrangeUtil.arrangeType~=5 then
			shiftY = ContentSizeTbl[1].height/2 - ArrangeUtil.getTotalSize().height/2
		end
	else
		if ArrangeUtil.arrangeType==3 then
			shiftX = ArrangeUtil.getTotalSize().width - ContentSizeTbl[1].width
		elseif ArrangeUtil.arrangeType~=2 then
			shiftX = ContentSizeTbl[1].width/2 - ArrangeUtil.getTotalSize().width/2
		end
	end
	local x,y
	for i,v in ipairs(ArrangeUtil.dataSource) do
		x = v:getPositionX()
		y = v:getPositionY()
		v:setPosition(cc.p(x+shiftX,y+shiftY))
	end
end

return ArrangeUtil