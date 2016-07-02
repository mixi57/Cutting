--Author: mixi
--Date: 2016-05-29 14:12:44
--Abstract: ViewUtil
local ViewUtil = {
    winSize = cc.Director:getInstance():getWinSize(),
    actionTime = 0.2,
    popWinZOrder = 1000,
    longTouchTime = 0.15,
    director = cc.Director:getInstance(),
}

function ViewUtil.createResoueceNode(resourceFilename, parent)
    local resourceNode = cc.CSLoader:createNode(resourceFilename)
    if parent then
        parent:addChild(resourceNode)
    end
    return resourceNode
end

local function viewHandler(obj, method, params)
    return function(...)
        return method(obj, params, ...)
    end
end
function ViewUtil.createResoueceBinding(binding, parent, target)
    for nodeName, nodeBinding in pairs(binding) do
        local node = target:getChildByName(nodeName)
        if node then
            if nodeBinding.varname then
                parent[nodeBinding.varname] = node
            end
            for _, event in pairs(nodeBinding.events or {}) do
                if event.event == "touch" then
                    node:onTouch(viewHandler(parent, parent[event.method], event.params))
                end
            end
        end
    end
end

-- 呼吸灯效果
local function getTintAction(time, startColor, endColor)
    local time = time or 1
    local startColor = startColor or cc.c3b(255, 255, 255)
    local endColor = endColor or cc.c3b(250, 103, 136)
    local action = cc.RepeatForever:create(
        cc.Sequence:create(
            cc.TintTo:create(time, endColor.r, endColor.g, endColor.b),
            cc.TintTo:create(time, startColor.r, startColor.g, startColor.b)
        )
    )
    return action
end
function ViewUtil.breathEnabled(enable, obj, time, startColor, endColor)
    if not obj then
        return
    end
    if enable then
        local action = getTintAction(time, startColor, endColor)
        obj:runAction(action)
        obj.startColor = startColor
    else
        obj:stopAllActions()
        obj:setColor(obj.startColor or cc.c3b(255, 255, 255))
        obj.startColor = nil
    end
end

---------------------------
-- Touch
local MovingActionTag = 99101
function ViewUtil.addDrayEvent(obj, dir, addTouchBeganEvent, addTouchMovedEvent, addTouchEndedEvent, addTouchCaceledEvent)
    local moveChangeFunc
    if dir == ccui.LayoutType.VERTICAL then
        moveChangeFunc = function(offset)
            offset.x = 0
            return offset
        end
    elseif dir == ccui.LayoutType.HORIZONTAL then
        moveChangeFunc = function(offset)
            offset.y = 0
            return offset
        end
    else
        moveChangeFunc = function(offset)
            return offset
        end
    end
    obj:setTouchEnabled(true)
    local objPosX, objPosY, lastPos
    obj:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            objPosX, objPosY = obj:getPosition()
            lastPos = obj:getTouchBeganPosition()
            -- obj:stopActionByTag(MovingActionTag)
            if addTouchBeganEvent then
                addTouchBeganEvent(lastPos)
            end
        elseif eventType == ccui.TouchEventType.moved then
            local newPos = obj:getTouchMovePosition()
            local offset = moveChangeFunc(cc.pSub(newPos, lastPos))
            objPosX = objPosX + offset.x
            objPosY = objPosY + offset.y
            obj:setPosition(objPosX, objPosY)
            --[[local bezier = cc.MoveTo:create(0.2, cc.p(objPosX, objPosY))
            local action = cc.EaseExponentialOut:create(bezier)
            action:setTag(MovingActionTag)
            bezier:setTag(MovingActionTag)
            obj:runAction(bezier)]]
            lastPos = newPos
            
            if addTouchMovedEvent then
                addTouchMovedEvent(newPos)
            end
        elseif eventType == ccui.TouchEventType.ended then
            if addTouchEndedEvent then
                addTouchEndedEvent()
            end
        elseif eventType == ccui.TouchEventType.calceled then
            if addTouchCaceledEvent then
                addTouchCaceledEvent()
            end
        end
    end)
end

function ViewUtil.getRect(node, needRecursion)
    local rect = node:getBoundingBox()
    local children = node:getChildren()
    print("children num ", #children)
    printAll(rect, {tip = "children rect"})
    if #children > 0 then
        for _, child in ipairs(children) do
            if child:isVisible() then
                local childRect = ViewUtil.getRect(child)
                local pos = cc.p(childRect.x, childRect.y)
                local newPos = node:convertToWorldSpace(pos)
                print("convertPos ", pos.x, pos.y, newPos.x, newPos.y)
                childRect.x, childRect.y = newPos.x, newPos.y
                rect = cc.rectUnion(rect, childRect)
            end
        end
    end
    return rect
end

------------------------------------------------- 跟界面无关
-- 检查是否有必要的参数 没有的话报错
function ViewUtil.checkMustParams(params, mustParams, errMsg)
    local msg = errMsg or "It is not params %s"
    local res = true
    for _, name in ipairs(mustParams) do
        if not params[name] then
            printError(string.format(msg, name))
            res = false
        end
    end
    return res
end

function ViewUtil.checkValue(value, maxValue, minValue)
    local value, maxValue, minValue = value, maxValue, minValue or 0
    if value > maxValue then
        value = maxValue
    elseif value < minValue then
        value = minValue
    end
    return value
end

return ViewUtil