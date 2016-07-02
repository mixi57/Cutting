--Author: mixi
--Date: 2016-05-29 23:14:56
--Abstract: 
local UI = {}

-------------------------------------以下为通用参数，特殊参数在特定方法前面-----------------------------
--[[
@param #number		x				x坐标
@param #number 		y				y坐标
@param #PositionType positionType 	坐标模式
@param #number		width			宽度
@param #number		height			高度
@param #size 		size 			大小
@param #Widget 		parent			父组件
@param #number		tag				组件的标签
@param #string		name			组件的名字
@param #number		opacity			设置透明度0-255
@param #boolean		enabled 		是否启用
@param #boolean 	visible 		是否显示
@param #boolean 	touchEnabled	是否接收touch事件
@param #number		zOrder 			深度排序值
@param #CCPoint		anchorPoint		锚点坐标
@param #number		scaleX			X方向缩放比例
@param #number		scaleY			Y方向缩放比例
@param #number		scale			整体缩放比例
@param #number		rotationX		X方向旋转角度
@param #number		rotationY		Y方向旋转角度
@param #number		rotation		整体旋转角度
@param #color 		color 			颜色
]]
-------------------------------------以上为通用参数，特殊参数在方法前面------------------------------
function fillWidgetParams(widget, params)
	if params == nil then
		return
	end
	if tolua.cast(widget,"ccui.Widget") == nil or type(params) ~= "table" then	
		error((Language.getString(9000)))
		--[[error("Parameter type do not match")--]]
	end
	local p = params
	local x,y = p.x or 0,p.y or 0
	widget:setPosition(x, y)				--设置坐标
	
	if p.position ~= nil then
		widget:setPosition(p.position)
	end

	if p.positionType ~= nil then
		widget:setPositionType(p.positionType)
		if p.positionType == ccui.PositionType.percent then
			widget:setPositionPercent(cc.p(x, y))
		end
	end
	
	local widgetSize
	if p.width ~= nil and p.height ~= nil then		--设置大小
		widgetSize = cc.size(p.width, p.height)
	end
	if p.size ~= nil then
		widgetSize = p.size
	end
	if widgetSize then
		widget:ignoreContentAdaptWithSize(false)
		widget:setContentSize(widgetSize)
	end
	
	if p.parent ~= nil then							--设置父组件
		p.parent:addChild(widget)
	end
	
	if p.tag ~= nil then
		widget:setTag(p.tag)						--设置标签
	end
	
	if p.name ~= nil then							--设置组件名字
		widget:setName(p.name)
	end
	
	if p.opacity ~= nil then						--设置透明度
		widget:setOpacity(p.opacity)
	end
	
	if p.enabled ~= nil then						--设置是否启用
		widget:setEnabled(p.enabled)
	end
	
	if p.visible ~= nil then						--设置是否显示
		widget:setVisible(p.visible)
	end
	
	if p.touchEnabled ~= nil then					--设置是否接收touch事件
		widget:setTouchEnabled(p.touchEnabled)
	end
	
	if p.zOrder ~= nil then							--深度排序值
		widget:setLocalZOrder(p.zOrder)
	end
	
	if p.anchorPoint ~= nil then					--设置锚点坐标
		widget:setAnchorPoint(p.anchorPoint)
	end
	
	if p.scaleX ~= nil then							--设置X方向缩放比例
		widget:setScaleX(p.scaleX)
	end
	
	if p.scaleY ~= nil then							--设置Y方向缩放比例
		widget:setScaleY(p.scaleY)
	end
	
	if p.scale ~= nil then							--设置整体缩放比例
		widget:setScale(p.scale)
	end
	
	if p.rotationX ~= nil then						--设置X方向旋转角度
		widget:setRotationX(p.rotationX)
	end
	
	if p.rotationY ~= nil then						--设置Y方向旋转角度
		widget:setRotationY(p.rotationY)
	end
	
	if p.rotation ~= nil then						--整体旋转角度
		widget:setRotation(p.rotation)
	end
	
	if p.align and widget:getParent() then
		UI.applyAlign(widget:getParent(), widget, p.align)
	end
end

function fillButtonStyle(styleTable)
	if type(styleTable) ~= "table" or not styleTable.normal then 
		print("fillButtonStyle value error")
		return
	end
	if not styleTable.pressed then
		styleTable.pressed = styleTable.normal
	end
	if not styleTable.disabled then
		styleTable.disabled = styleTable.normal
	end
	return styleTable
end
--[[文字
@param #string text 需要显示的文本
@param #number fontSize	字体大小
@param #cc.c3b(0,0,0)	颜色值
]]
function UI.newText(params)
    local label = ccui.Text:create()
	local params = params or {}
	--填充参数
	fillWidgetParams(label, params)
	--增加个默认使用的字体类型
	label:setFontName(params.fontName or FontConfig.getDefaultFont())

	label:setFontSize(params.fontSize or 30)

	label:setTextAreaSize(cc.size(params.width or 0, params.height or 0))
	  
	if params.text ~= nil then			--设置按钮文字
		label:setString(params.text)
	end
	if params.color ~= nil then
   		label:setTextColor(params.color)
   	end
	if params.lineColor ~= nil then
		local lineWidth = params.lineWidth or 1
   		label:enableStroke(params.lineColor,lineWidth,true)	
   	end
	-- if params.labelStyle then
	-- 	UI.applyLabelStyle(label, params.labelStyle)
	-- end
    return label
end

--[[图片
@params #string url		资源路径
@params #bool 	isAysn	是否异步
@params #bool 	scale9	是否开启九宫格
@params #rect	拉伸尺寸 没填的
]]
function UI.newImageView(params)
	local img = ccui.ImageView:create()
	-- TODO mixi 2016-05-31 12:19:06
	if params.isAysn ~= nil then
	end
	-- 九宫格部分
	if params.enabledScale9 then
		img:setScale9Enabled(true)
		if params.rect then
			img:setCapInsets(rect)	
		end
	end
	if params.url ~= nil then
		img:loadTexture(params.url)
	end
	fillWidgetParams(img, params)
	
	return img
end

--[[输入框
@params #string ftext		显示文本
@params #string placeHolder	占有文本
@params #string fontName	字体资源路径
@param 	#number fontSize	字体大小
@param 	#		color		颜色值
]]
function UI.newTextField(params)
	local input = ccui.TextField:create()
	
	if params.placeHolder  then	
		input:setPlaceHolder(params.placeHolder)
	end

	if params.color then
		input:setTextColor(params.color)
		params.color = nil
	end
	if params.text then
		input:setString(params.text)
	end

    input:setFontName(params.fontName or FontConfig.getDefaultFont())
	input:setFontSize(params.fontSize or 30)

	fillWidgetParams(input, params)

	return input
end

-- function UI.

--[[按钮
@params #string text		显示文本
@params #string btnStyle	按钮样式
@params #string labelStyle	字体样式
@params #bool   touchEnabled是否点击
]]
function UI.newButton(params)
	local btn = ccui.Button:create()
	btn:setTouchEnabled(params.touchEnabled ~= nil and (params.touchEnabled) or true)
	
	btn:setTitleText(params.text)
	btn:setTitleFontName(params.fontName or FontConfig.getDefaultFont())
	btn:setTitleFontSize(params.fontSize or 30)

	local style = params.btnStyle and fillButtonStyle(params.btnStyle) or Style.DEFALUT_BTN_STYLE
	btn:loadTextures(style.normal, style.select, style.disabled)

	fillWidgetParams(btn, params)

	return btn
end

--[[输入框
@params 	color		颜色
@params 	bgColorType	按钮样式
]]
function UI.newLayout(params)
	local layout = ccui.Layout:create()

    layout:setBackGroundColorType(params.bgColorType or ccui.LayoutBackGroundColorType.none)--solid)

    if params.color then
    	layout:setBackGroundColor(params.color)
    	params.color = nil
    	layout:setBackGroundColorType(params.bgColorType or ccui.LayoutBackGroundColorType.solid)
    end

    fillWidgetParams(layout, params)
    return layout
end

function UI.newMargin(paramsOrLeft, top, right, bottom)
	local left, top, right, bottom = paramsOrLeft, top, right, bottom
	if paramsOrLeft and type(paramsOrLeft) == "table" then
		local params = left
		left, top, right, bottom = params.left, params.top, params.left, params.bottom
	end
	local margin = {
		left = left or 0,
		top	 = top or 0,
		right = right or 0,
		bottom = bottom or 0,
	}
	return margin
end
-- list

--[[
params 	plistPath
params 	pngPath
params 	target
params 	frameNameTable
params  delay
]]
function UI.newEffect(params)
	if not params.plistPath or not params.pngPath then
		print("invalid create")
		return
	end
	local target = params.target or cc.Sprite:create()
	local spriteFrameCache = cc.SpriteFrameCache:getInstance()

	spriteFrameCache:addSpriteFrames(params.plistPath, params.pngPath)

	local animation
	if params.frameNameTable then
		local frameTable = {}
		for i, name in ipairs(params.frameNameTable) do
			table.insert(frameTable, spriteFrameCache:getSpriteFrame(name))
		end
		local frameTime = params.frameTime or 0.5
		animation = cc.Animation:createWithSpriteFrames(frameTable, frameTime)
		if not params.noAction then
			local action = cc.RepeatForever:create(cc.Animate:create(animation))
			if params.actionTag then
				target:stopActionByTag(params.actionTag)
				action:setTag(params.actionTag)
			end
			target:runAction(action)            
		end
	end

	fillWidgetParams(target, params)

	return target, animation
end

return UI