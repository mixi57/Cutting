--Author: mixi
--Date: 2016-06-04 19:29:11
--Abstract: AlertManager 弹窗 还没加上管理部分

local DEFAULT_BUTTON_STYLE = Style.DEFALUT_BTN_STYLE
local ACTION_TIME = ViewUtil.actionTime
local WinSize = ViewUtil.winSize
local AlertManager = {
	winCache = {},
	offset = 0,
}
--[[建立窗口 增加一些包装处理
@params win 
@params params
		isShowMask 显示遮罩 默认显示
]]
local function createAlertItem(win, params)
	local params = params or {}

	local alertItem = UI.newLayout({
		size = WinSize,
		touchEnabled = true,
	})

	if params.isShowMask == nil or params.isShowMask == true then
		alertItem:setBackGroundColor(Style.ColorStyle.BLACK)
		alertItem:setOpacity(params.opacity or 165)
	end

	-- 吃掉触摸点 不再向下分发
	win:setTouchEnabled(true)

	local winSize = win:getContentSize()
	
	--需要判断是cc还是ccui 两种的位置不一样，ui的内部有调整过一次？哎
	local posX, posY = (WinSize.width - winSize.width) / 2, (WinSize.height - winSize.height) / 2
	if win.getVirtualRenderer then
		local anchorPoint = win:getAnchorPoint()
		posX = posX + anchorPoint.x * winSize.width
		posY = posY + anchorPoint.y * winSize.height
	end
	win:setPosition(posX, posY)
	
	-- print("anchorPoint ", anchorPoint.x, anchorPoint.y, winSize.width, winSize.height, win:getPosition())
	alertItem:addChild(win)
	alertItem:setTouchEnabled(true)
	alertItem:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AlertManager.hideWin(win, params)
		end
	end)

	return alertItem
end

local function getAlertItem(win)
	return win:getParent()
end

--[[
@params win 窗口对象
@params params
		noAction 需要打开动画 默认需要
		--  嗯 要加多点区分打开关闭的参数

]]
function AlertManager.popWin(win, params)
	local alertItem = createAlertItem(win)
	local params = params or {}

	local function openComplete()
		print("完成弹窗")
	end

	if params.noAction then
		openComplete()
	else
		win:setScale(0.5)
		win:runAction(
			cc.Sequence:create(
				cc.ScaleTo:create(ACTION_TIME, 1),
				cc.CallFunc:create(openComplete)
			)
		)
	end

	local currentScene = SceneManager.getCurScene()
	if currentScene then
		alertItem:setLocalZOrder(ViewUtil.popWinZOrder + AlertManager.offset)
		currentScene:addChild(alertItem)
		AlertManager.offset = AlertManager.offset + 1
	end

	return win
end

function AlertManager.hideWin(win, params)
	local params = params or {}
	local target = getAlertItem(win)

	local function closeComplete()
		target:removeFromParent()
	end

	if params.noAction then
		closeComplete()
	else
		win:setScale(0.5)
		win:runAction(
			cc.Sequence:create(
				cc.ScaleTo:create(ACTION_TIME, 0.2),
				cc.CallFunc:create(closeComplete)
			)
		)
	end
end

return AlertManager