--Author: mixi
--Date: 2016-06-09 17:21:34
--Abstract: 类似ListView的存在 为什么重写？为了满足更多的需求。例如，跳到第几项目，滚动加载，异步加载等功能
--[[
这是一个自由的list
list上可以加各种格式的Pack包裹
每一项包裹上有它自己的规则 来列出Item
List直接排列Pack
Pack直接排列Item
]]
local C = class("List", UIComponent)
--[[
@params viewParams		界面或公用参数
	viewSize			界面大小
	enabledBounce		是否回弹
	dir					方向	 只支持横 或者 竖
	scrollBarStyle		小滚动条的样式
	showScrollBar		如果不需要的话 可以去掉
	margin				Pack的各自间隔
	borderMargin 		外环的间隔
	samePackSize		是否每个包一样大

@params	packParams 		公用pack参数
	margin			
	borderMargin
	divNum				每行或列的个数
	packSize			统一的包大小
	sameItemSize
	itemSize
	template			创建模版
	data

]]
function C:ctor(params)
	self._dataSource = {}
	self._scrollViewInnerContainerSize = false
	self._scrollViewInnerContainer = false

	self._packCache = {}
	self._hidePackCache = {}

	local viewParams = self:createViewParams(params.viewParams)

	self:parseViewParams(viewParams)
	self:parsePack(params.packParams)
	self:updateDataSource(dataSource)
end

function C:createViewParams(params)
	local mustParams = {"viewSize"}
	local newParams = {}
	if ViewUtil.checkMustParams(params, mustParams) then
		newParams = {
			viewSize 		=	params.viewSize,
			enabledBounce	=	(params.enabledBounce and {params.enabledBounce} or {true})[1],
			dir				=	params.dir or ccui.LayoutType.VERTICAL,
			scrollBarStyle	=	params.scrollBarStyle or Style.DEFALUT_SCROLL_BAR_STYLE,
			showScrollBar	=	(params.showScrollBar and {params.showScrollBar} or {true})[1],
			margin			=	params.margin or UI.newMargin(),
			borderMargin 	=	params.borderMargin or UI.newMargin(),
			bg 				= 	params.bg or false,
			bgSize			= 	params.bg and params.bgSize or params.viewSize,
			innerContainerSize=	params.innerContainerSize or false,
			anchorPoint		= 	params.anchorPoint or cc.p(0, 0),
			barBgSize		=   params.barBgSize or cc.size(Style.DEFALUT_SCROLL_BAR_WIDTH, params.viewSize.height),
			barInterval		=	params.barInterval or 0,
		}
	else
		printError("List createViewParams error")
	end
	return newParams
end

function C:createPackParams()
end

-- list表上的单位 每项的参数设置
function C:createItemParams(params)
	return {
	}
end

function C:parseViewParams(viewParams)
	self._viewParams = self:createViewParams(viewParams)

	if viewParams.bg then
		self._bg = UI.newImageView({
			url 		= viewParams.bg,
			parent		= self,
			anchorPoint = viewParams.anchorPoint,
			size 		= params.bgSize,
		})
	end

	self._scrollView = ccui.ScrollView:create()
	self:addChild(self._scrollView)
	self._scrollView:setContentSize(viewParams.viewSize)
	self._scrollViewInnerContainer = self._scrollView:getInnerContainer()
	self._scrollView:setBounceEnabled(viewParams.enabledBounce)
	self._scrollView:setDirection(viewParams.dir)
	-- self._scrollView:setScrollBarEnabled(false)

	self._scrollView:setBackGroundColorType(1)
	self._scrollView:setBackGroundColor(Style.ColorStyle.GRAY)

	if viewParams.innerContainerSize then
		self._scrollViewInnerContainerSize = viewParams.innerContainerSize
		self._scrollViewInnerContainer:setContentSize(viewParams.innerContainerSize)
	else
		self._scrollViewInnerContainerSize = viewParams.viewSize
	end

	if viewParams.showScrollBar then
		self:updateScrollBar()--viewParams.scrollBarStyle)
	end
end

function C:parsePack(packParams)
	local packPos, targetAnchorPoint, updatePackSize
	local allPackSize = cc.size(0, 0)
	local isVertical = false
	if self._viewParams.dir == ccui.LayoutType.VERTICAL then
		isVertical = true
		packPos = cc.p(0, self._scrollViewInnerContainerSize.height)
		targetAnchorPoint = Style.PosStyle.LEFT_TOP
		updatePackSize = function(size)
			allPackSize.width = math.max(allPackSize.width, size.width)
			allPackSize.height = allPackSize.height + size.height
		end
	elseif self._viewParams.dir == ccui.LayoutType.HORIZONTAL then
		isVertical = false
		packPos = cc.p(0, 0)
		targetAnchorPoint = Style.PosStyle.LEFT_BOTTOM
		updatePackSize = function(size)
			allPackSize.width = allPackSize.width + size.width
			allPackSize.height = math.max(allPackSize.height, size.height)
		end
	end

	for index, pack in ipairs (packParams) do
		if pack.data then
			local objT = self:createPackObj(pack, index)
			local gatherSize = self:listData(objT, pack, packPos, targetAnchorPoint)
			print("gatherSizegatherSize ", gatherSize.width, gatherSize.height)
			if gatherSize then
				updatePackSize(gatherSize)
			end
			if isVertical then
				packPos = cc.p(packPos.x, packPos.y - gatherSize.height)
			else
				packPos = cc.p(packPos.x + gatherSize.width, packPos.y)
			end
			self._packCache[index] = {objT = objT, gatherSize = gatherSize}
		elseif pack.packSize then
		end
	end
	print("allPackSize", allPackSize.width, allPackSize.height)
	self:updateInnerSize(allPackSize)
end

function C:updateInnerSize(allPackSize)
	if self._viewParams.dir == ccui.LayoutType.VERTICAL then
		allPackSize.width = self._viewParams.viewSize.width
		if allPackSize.height < self._viewParams.viewSize.height then
			allPackSize.height = self._viewParams.viewSize.height
		end
	elseif self._viewParams.dir == ccui.LayoutType.HORIZONTAL then
		allPackSize.height = self._viewParams.viewSize.height
		if allPackSize.width < self._viewParams.viewSize.width then
			allPackSize.width = self._viewParams.viewSize.width
		end
	end

	if not self._scrollViewInnerContainerSize 
		or (self._scrollViewInnerContainerSize.width ~= allPackSize.width)
		or (self._scrollViewInnerContainerSize.height ~= allPackSize.height) then

		local offsetX, offsetY = 0, 0
		if self._viewParams.dir == ccui.LayoutType.VERTICAL then
			offsetY = allPackSize.height - self._scrollViewInnerContainerSize.height
		elseif self._viewParams.dir == ccui.LayoutType.HORIZONTAL then
			offsetX = allPackSize.width - self._scrollViewInnerContainerSize.width
		end
		self._scrollViewInnerContainer:setContentSize(allPackSize)
		local children = self._scrollViewInnerContainer:getChildren()
		for _, child in ipairs(children) do
			local oldPosX, oldPosY = child:getPosition()
			child:setPosition(oldPosX + offsetX, oldPosY + offsetY)
		end
		self._scrollViewInnerContainerSize = allPackSize
	end

	if self._viewParams.dir == ccui.LayoutType.VERTICAL then
		self._scrollView:jumpToTop()
	elseif self._viewParams.dir == ccui.LayoutType.HORIZONTAL then
		self._scrollView:jumpToLeft()
	end
end


function C:updateScrollBar()
	if not self._scrollBar then
		self._scrollBar = ScrollBar.new({
	        dir = self._viewParams.dir,
	        style = self._viewParams.scrollBarStyle,
	        bgSize = self._viewParams.barBgSize
	    })
	    self:addChild(self._scrollBar)
	    local barPosX, barPosY
	    if self._viewParams.dir == ccui.LayoutType.VERTICAL then
	    	barPosX, barPosY = self._viewParams.viewSize.width - self._viewParams.barInterval, self._viewParams.viewSize.height / 2
	    else
	    	barPosX, barPosY = self._viewParams.viewSize.width / 2, self._viewParams.barInterval
	    end
	    self._scrollBar:setPosition(barPosX, barPosY)
	end
	local rate
	if self._viewParams.dir == ccui.LayoutType.VERTICAL then
		rate = self._viewParams.viewSize.height / self._scrollViewInnerContainerSize.height
	elseif self._viewParams.dir == ccui.LayoutType.HORIZONTAL then
		rate = self._viewParams.viewSize.width / self._scrollViewInnerContainerSize.width
	end
	self._scrollBar:updateRate(rate)
end

function C:updateDataSource(dataSource)
	
	if dataSource then
		for i, info in ipairs(dataSource) do

		end
		-- self._dataSource = dataSource
	end
end

function C:createPackObj(pack, index)
	local objT = {}
	for i, v in ipairs(pack.data) do
		local obj = pack.template(v)
		if obj then
			self._scrollViewInnerContainer:addChild(obj)
			table.insert(objT, obj)
			obj:setTag(index)
		else
			print("createPackObj error", v)
		end
	end
	return objT
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

function C:listData(objT, packParams, targetPos, targetAnchorPoint)
	print(" packParams.sameItemSize packParams.sameItemSize ", packParams.sameItemSize)
	local params = {
		dataSource = objT,
		dir = packParams.dir,
		targetPos = targetPos,
		targetAnchorPoint = targetAnchorPoint, 
		interval = 10,
		isSameSize = packParams.sameItemSize,
	}
	return Alignment.layout(params)
end

function C:removePack(index)
end

function C:setPackEnabled(index, var)
	if not self._packCache[index] then
		return
	end
	local needMove = false
	local rate = 1
	if var then
		needMove = self._hidePackCache[index]
		rate = -1
	else
		needMove = not self._hidePackCache[index]
	end

	if needMove then
		local info = self._packCache[index]
		for i, obj in ipairs(info.objT) do
			obj:setEnabled(var)
			obj:setVisible(var)
		end
		local offset
		if self._viewParams.dir == ccui.LayoutType.VERTICAL then
			offset = cc.p(0, info.gatherSize.height * rate)
		elseif self._viewParams.dir == ccui.LayoutType.HORIZONTAL then
			offset = cc.p(-info.gatherSize.width * rate, 0)
		end
		local time = 0.2
		for i, info in pairs(self._packCache) do
			if i > index then
			-- printAll(self._packCache[i]) 
				for _, obj in ipairs(self._packCache[i].objT) do
					obj:runAction(cc.MoveBy:create(time, offset))
				end
			end
		end
		if var then
			self._hidePackCache[index] = nil
		else
			self._hidePackCache[index] = info
		end
	end
end

return C