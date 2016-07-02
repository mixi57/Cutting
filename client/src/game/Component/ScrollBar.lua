--Author: mixi
--Date: 2016-06-10 09:20:08
--Abstract: ScrollBar 滚动层旁边的小进度条
-- 对比已有的ScrollViewBar，后者是C＋＋上的组件，功能不齐全，为了扩展性考虑，还是在Lua上实现一个
local C = class("ScrollBar", UIComponent)
function C:ctor(...)

	self._defaultLength = 10-- false
	self._rate = -1
	self._barMovelength = 0
	self._barDefaultSide = 0
	self._barPercent = 0
	self._barTouchPos = false

	-- self._dirType = {}
	-- for typeName, value in pairs(ccui.LayoutType) do
	-- 	self._dirType[value] = false
	-- end
	-- self._barDirType = {}
	-- for typeName, value in pairs(ccui.LayoutType) do
	-- 	self._barDirType[value] = false
	-- end

	self:init(...)
end

--[[
@params 	dir			方向
@params		style		格式
			bar 		滚动条图案
			bg			背景图案
			width		宽 指的是那个不动的边的大小 看方向决定
			interval	与边界的距离 间隔 还是要看方向的
			bgDir		背景图的方向
@params 	canDrag		可以拖动
@params		bgSize
]]
function C:init(params)
	self._dir = params.dir
	self._style	= params.style
	self._canDrag = params.canDrag or true
	self._bgSize = params.bgSize

	-- 思考 这样子会减少判断么
	-- self._dirType[self.dir] = true
	-- self._barDirType[self._style.dir] = true
	
	self:createScrollBar()
end

function C:createScrollBar()
	local width, height
	local rotation = 0
	-- 方向不同的要旋转 bar 与 bg 方向相同
	if self._dir == ccui.LayoutType.HORIZONTAL then
		if self._style.dir == ccui.LayoutType.VERTICAL then
			rotation = -90
			self._bgSize = cc.size(self._bgSize.height, self._bgSize.width)
			width = self._bgSize.width - self._style.interval * 2
			height = self._bgSize.height
			self._barDefaultSide = width / 2
		elseif self._style.dir == ccui.LayoutType.HORIZONTAL then
			height = self._bgSize.height - self._style.interval * 2
			width = self._bgSize.width
			self._barDefaultSide = height / 2
		end
	elseif self._dir == ccui.LayoutType.VERTICAL then
		if self._style.dir == ccui.LayoutType.HORIZONTAL then
			rotation = 90
			self._bgSize = cc.size(self._bgSize.height, self._bgSize.width)
			height = self._bgSize.height - self._style.interval * 2
			width = self._bgSize.width
			self._barDefaultSide = height / 2
		elseif self._style.dir == ccui.LayoutType.VERTICAL then
			width = self._bgSize.width - self._style.interval * 2
			height = self._bgSize.height
			self._barDefaultSide = width / 2
		end
	end

	self._bg = UI.newImageView({
		scale9 = true,
		url = self._style.bg,
		size = self._bgSize,
		rotation = rotation,
		parent = self, 
	})

	---------------------
	--				--1--
	--				-- --
	--				-- --
	--				-- --
	--				-- --
	---------------------

	--------------------
	--			      --
	--				  --
	--				  --
	--				  --
	--1-- -- -- -- -- --
	--------------------


	self._bar = UI.newImageView({
		scale9 = true,
		url = self._style.bar,
		width = width,
		height = height,
		parent = self._bg,
	})
	self:updateRate(1)

	self:setTouchEnabled(self._canDrag, true)
end

--  滚动bar与背景的比例 默认 1 scrollView的界面／实际 的比例
function C:updateRate(rate)
	if _rate ~= rate then
		local barSize = self._bar:getContentSize()
		local curSize = barSize
		if self._style.dir == ccui.LayoutType.VERTICAL then
			curSize = cc.size(barSize.width, barSize.height * rate)
			self._drapStart = self._bgSize.height - curSize.height / 2
			self._drapLength = self._bgSize.height - curSize.height
		elseif self._style.dir == ccui.LayoutType.HORIZONTAL then
			curSize = cc.size(barSize.width * rate, barSize.height)
			self._drapStart = curSize.width / 2
			self._drapLength = self._bgSize.width - curSize.width
		end
		self._rate = rate
		self._bar:setContentSize(curSize)
		self:setPercent(self._barPercent, true)
	end
end

function C:setPercent(percent, noCheck)
	print("setPercent ", percent)
	local percent = ViewUtil.checkValue(percent, 100, 0)
	if not noCheck and self._barPercent == percent then
		return
	end
	local isDirVertical = self._dir == ccui.LayoutType.VERTICAL
	local rate = isDirVertical and -1 or 1
	local posX = self._drapStart + self._drapLength * percent / 100 * rate
	local pos
	if isDirVertical then
		pos = cc.p(self._barDefaultSide, posX)
	else
		pos = cc.p(posX, self._barDefaultSide)
	end
	print("setPercent2 ", isDirVertical, pos.x, pos.y)
	self._bar:setPosition(pos)
	self._barPercent = percent
end

function C:setTouchEnabled(var, noCheck)
	if noCheck or self._canDrag ~= var then
		self._bar:setTouchEnabled(var)
		local function touchBeganFunc()
			self._barTouchPos = self._bar:getTouchBeganPosition()
		end
		local touchMovedFunc
		if self._style.dir == ccui.LayoutType.VERTICAL then
			touchMovedFunc = function()
				local touchPos = self._bar:getTouchMovePosition()
				local offset = touchPos.y - self._barTouchPos.y
				local newPosY = self._bar:getPositionY() + offset
				newPosY = ViewUtil.checkValue(newPosY, self._drapStart, self._drapStart - self._drapLength)
				self._bar:setPositionY(newPosY)
				self._barTouchPos = touchPos
			end
		elseif self._style.dir == ccui.LayoutType.HORIZONTAL then
			touchMovedFunc = function()
				local touchPos = self._bar:getTouchMovePosition()
				local offset = touchPos.x - self._barTouchPos.x
				local newPosX = self._bar:getPositionX() + offset
				newPosX = ViewUtil.checkValue(newPosX, self._drapLength, self._drapStart)
				self._bar:setPositionX(newPosX)
				self._barTouchPos = touchPos
			end
		end
		local function touchEndedFunc()
			-- self._barTouchPos = self._bar:getTouchBeganPosition()
		end
		local eventTypeT = {
			[ccui.TouchEventType.began] = touchBeganFunc,
			[ccui.TouchEventType.moved] = touchMovedFunc,
			-- [ccui.TouchEventType.ended] = touchEndedFunc,
			-- [ccui.TouchEventType.canceled] = touchEndedFunc,
		}
		self._bar:addTouchEventListener(function(sender, eventType)
			local func = eventTypeT[eventType]
			if func then
				func()
			end
		end)
		self._canDrag = var
	end
end

return C