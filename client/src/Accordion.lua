--Author: mixi
--Date: 2016-06-09 17:23:25
--Abstract: Accordion 折叠标签 本质上是个List
local C = class("Accordion", UIComponent)
local DefaultSize = cc.size(40, 100)
function C:ctor(params)
	-- 数据源
	self.dataSource = params.dataSource 
	-- 界面大小 没有的话不合理吧
	self.size = params.size or (params.width and params.height and cc.size(params.width, params.height))
	self.dynamicCreate = params

	local packParams = {
		signName = "",
		signStyle = Style.DEFAULT_ACCORDION_STYLE,
		data = {},
		template = function() return end,
	}
end

function C:createSign(name, style, params)
	local bg = UI.newImageView({
		url = style.bg,
		width = params.width,
		height = style.height,
	})
	local btn = UI.newButton({
		style = {normal = style.signBg}, 
		parent = bg,
		-- x = 
	})
	btn:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
		end
	end)
	return bg
end

return C