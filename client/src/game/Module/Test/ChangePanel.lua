--Author: mixi
--Date: 2016-06-11 13:18:04
--Abstract: ChangePanel
local C = class("ChangePanel", View)
C.RESOURCE_INFO = {
	{
		"Layer.csb",
		{

		}
	}
}
function C:ctor(obj, removeCallBack)
	self._obj = obj
	self._removeCallBack = removeCallBack
	self:initView()
end

local function addTextFieldEvent(params)
	local textField = params.obj
	local panel = params.panel

	textField:addEventListener(function(sender, eventType)
		-- print("addTextFieldEvent, ", panel)
		-- if params.touchEvent then params.touchEvent(...)  return end
		-- if params.addTouchEvent then 
		-- 	params.addTouchEvent(...)
		-- end
		-- if delButton then textField.updateButtonStatus() end

		--print("**************************-- ",event.TextFieldEventType)
		if eventType == ccui.TextFiledEventType.attach_with_ime then 
		    -- if params.needBlueSign then textField.blue:setVisible(true) end
			print("弹出键盘")
			-- if params.inputEndEvent then
			-- 	params.inputEndEvent(panel)
			-- end
			--安卓上不做此处理
			if __OS__~=2 then
			     textField:setTouchEnabled(false)
	        end
        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
		   -- if params.needBlueSign then textField.blue:setVisible(false) end
		    print("收下键盘")
		    if params.inputEndEvent then
				params.inputEndEvent(panel)
			end
		    if __OS__~=2 then 
		        textField:setTouchEnabled(true)
		    end
		elseif eventType == ccui.TextFiledEventType.insert_text then
			print("插入数据")
			if params.onInputEvent then
				params.onInputEvent()--(event.self)
			end
		elseif eventType == ccui.TextFiledEventType.delete_backward then
			print("删除数据")
			if params.onDeleteEvent then
				params.onDeleteEvent()--(event.self)
			end
		end
		-- if  params.isInvalidBr==nil or  params.isInvalidBr==false then
		-- 	if event.TextFieldEventType==ccui.TextFiledEventType.insert_text or event.TextFieldEventType==ccui.TextFiledEventType.detach_with_ime then
		-- 		local ss=textField:getString()
		-- 		ss=string.gsub(ss,"\n","")
		-- 		textField:setString(ss)
		-- 	end
		-- end
		-- updateBlueStatus()
	end)

end

function C:initView()
	self:show()

	self._bg = self._targetNode:getChildByName("bg")
	ViewUtil.addDrayEvent(self._bg)

	local nameSufT = {"TL", "TR", "BL", "BR"}
	for _, nameSuf in ipairs(nameSufT) do
		local name = string.format("closeBtn%s", nameSuf)

		local closeBtn = self._bg:getChildByName(name)
		closeBtn:addTouchEventListener(function(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				self:removeCallBack()
			end
		end)
	end

	local scroll = self._bg:getChildByName("scrolll")


	local target = scroll:getInnerContainer()
	self._anchorPointX = target:getChildByName("anchorPointX")
	self._anchorPointY = target:getChildByName("anchorPointY")

	addTextFieldEvent({
		obj = self._anchorPointX, 
		inputEndEvent = self.updateAnchorPoint,
		panel = self,
	})
	addTextFieldEvent({
		obj = self._anchorPointY, 
		inputEndEvent = self.updateAnchorPoint,
		panel = self,
	})
	
	self._posX = target:getChildByName("posX")
	self._posY = target:getChildByName("posY")

	addTextFieldEvent({
		obj = self._posX, 
		inputEndEvent = self.updatePos,
		panel = self,
	})
	addTextFieldEvent({
		obj = self._posY, 
		inputEndEvent = self.updatePos,
		panel = self,
	})

	self._width = target:getChildByName("width")
	self._height = target:getChildByName("height")
	addTextFieldEvent({
		obj = self._width, 
		inputEndEvent = self.updateContentSize,
		panel = self,
	})
	addTextFieldEvent({
		obj = self._height, 
		inputEndEvent = self.updateContentSize,
		panel = self,
	})

	self._zOrder = target:getChildByName("level")
	addTextFieldEvent({
		obj = self._zOrder, 
		inputEndEvent = self.updateZOrder,
		panel = self,
	})

	self._scaleX = target:getChildByName("scaleX")
	self._scaleY = target:getChildByName("scaleY")

	addTextFieldEvent({
		obj = self._scaleX, 
		inputEndEvent = self.updateScale,
		panel = self,
	})
	addTextFieldEvent({
		obj = self._scaleY, 
		inputEndEvent = self.updateScale,
		panel = self,
	})

	self._sameSizeCodeCheckBox = target:getChildByName("checkBox")

	self._sameSizeCodeCheckBox:addEventListener(function(sender, eventType)
        local var = false
        if eventType == ccui.CheckBoxEventType.selected then
            var = true
        elseif eventType == ccui.CheckBoxEventType.unselected then

        end
        self:setCheckBoxEnabled(var)
    end)

    local hideBtn = target:getChildByName("hideBtn")
	hideBtn:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			-- self:removeCallBack()
			self._obj:setVisible(false)
			self._obj:setEnabled(false)
		end
	end)

	local removeBtn = target:getChildByName("removeBtn")
	removeBtn:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			self._obj:removeFromParent()
			self:removeCallBack()
		end
	end)



	-- self._anchorPointY = target:getChildByName("anchorPointY")
	-- addEventListenerTextField
	self:updateAnchorPoint(self._obj:getAnchorPoint())
	self:updatePos(cc.p(self._obj:getPositionX(), self._obj:getPositionY()))
	self:updateContentSize(self._obj:getContentSize())
	self:updateZOrder(self._obj:getLocalZOrder())
	self:updateScale(self._obj:getScaleX(), self._obj:getScaleY())
	self:setCheckBoxEnabled(self._obj.sameSizeCode)
end

function C:updateAnchorPoint(pos)
	local pos = pos
	if not pos then
		local posX, posY = self._anchorPointX:getString(), self._anchorPointY:getString()
		if not tonumber(posX) or not tonumber(posY) then
			return
		end
	 	pos = cc.p(posX, posY)
	end
	self._obj:setAnchorPoint(pos)
	self._anchorPointX:setString(pos.x)
	self._anchorPointY:setString(pos.y)
end

local function getValidNum(value, num)
	local s = string.format(".%df", num)
	return string.format("%"..s, value)
end

function C:updatePos(pos)
	local pos = pos
	if not pos then
		local posX, posY = self._posX:getString(), self._posY:getString()
		if not tonumber(posX) or not tonumber(posY) then
			return
		end
	 	pos = cc.p(posX, posY)
	end
	self._obj:setPosition(pos)
	self._posX:setString(getValidNum(pos.x, 3))
	self._posY:setString(getValidNum(pos.y, 3))
	print("updatePosupdatePos", pos.x, pos.y)
end

function C:updateScale(scaleX, scaleY)
	local scaleX, scaleY = scaleX, scaleY
	if not scaleX or not scaleY then
		scaleX, scaleY = self._scaleX:getString(), self._scaleY:getString()
		if not tonumber(scaleX) or not tonumber(scaleY) then
			return
		end
	end
	self._obj:setScaleX(scaleX)
	self._obj:setScaleY(scaleY)
	self._scaleX:setString(scaleX)
	self._scaleY:setString(scaleY)
end

function C:updateContentSize(size)
	local size = size
	if not size then
		local width, height = self._width:getString(), self._height:getString()
		if not tonumber(width) or not tonumber(height) then
			return
		end
	 	size = cc.size(width, height)
	end
	self._obj:setContentSize(size)
	self._width:setString(size.width)
	self._height:setString(size.height)
end

function C:updateZOrder(zOrder)
	local zOrder = zOrder
	if not zOrder then
		zOrder = self._zOrder:getString()
		if not tonumber(zOrder) then
			return
		end
	end
	self._obj:setLocalZOrder(zOrder)
	self._zOrder:setString(zOrder)
end

function C:removeCallBack()
	if self._removeCallBack then
		self._removeCallBack()
	end
end

function C:setCheckBoxEnabled(var)
	self._obj.sameSizeCode = var
	self._sameSizeCodeCheckBox:setSelected(var or false)
end

return C