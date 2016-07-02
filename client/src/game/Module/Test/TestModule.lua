--Author: mixi
--Date: 2016-05-28 22:24:15
--Abstract: BalconyModule
local M = class("TestModule", View)

M.RESOURCE_INFO = {
    --[[{  
        "MainScene.csb", 
        {
            ["roomBtn"] = {
                ["varname"] = "_roomBtn",
                ["events"] = {
                    ["event"] = "touch",
                    ["method"] = "openModuleByName",
                    ["params"] = "ROOM"
                },
            },
        }
    }]]
}
local function addReleaseEvent(event, callback, params)
    if event.name == "ended" then
        callback(params)
    end
end

function M:openModuleByName(params, event)
    addReleaseEvent(
        event,
        function(moduleName)
            GameManager.openModule(ModuleConfig[moduleName])
        end,
        params
    )
end

function M:ctor()
    self._showTestList = false
    self._btnParent = false
end

function M:initView()
    self:show()
    -- self:setPlantTest()

    -- local ChangePanel = require "game.Module.Test.ChangePanel"
    -- local view = ChangePanel.new(self)
    -- self:addChild(view)
    

    if not self._btnParent then
        self._btnParent = cc.Node:create()
        self:addChild(self._btnParent)
    end

    local testBtn = UI.newButton({
        parent = self._btnParent,
        x = 200,
        y = 600,
        text = "Test",
        -- btnStyle = {normal = ResConfig.png.botany01},
    })
    local btnPos = {x =0, y = 0}
    btnPos.x, btnPos.y = testBtn:getPosition()
    testBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.moved then
            local pos = sender:getTouchMovePosition()
            local offset = cc.pSub(pos, btnPos)
            self._btnParent:setPosition(offset)
            -- sender:stopAllActions()
            -- sender:runAction(cc.MoveTo:create(0.02, pos))
            sender:setPressedActionEnabled(false)
        elseif eventType == ccui.TouchEventType.ended then
            print("end")
            sender:setPressedActionEnabled(true)
            self:addDefaultTestList()
        end
    end)
    self._testBtn = testBtn
    print(btnPos)
    self._curentListPos = cc.pAdd(btnPos, cc.p(200, 0))

    -- local Bar = require "ScrollBar"
    -- Bar = Bar.new({
    --     dir = ccui.LayoutType.VERTICAL,
    --     style = Style.DEFALUT_SCROLL_BAR_STYLE,
    --     bgSize = cc.size(Style.DEFALUT_SCROLL_BAR_WIDTH, 100)
    -- })
    -- Bar:setPosition(400, 700)
    -- self:addChild(Bar)
    -- Bar:updateRate(0.3)

    -- local List = require "List"
    -- List = List.new({
    --     viewParams = {
    --         viewSize = cc.size(500, 500),
    --         dir = ccui.LayoutType.VERTICAL,
    --         innerContainerSize = cc.size(500, 1000),
    --     },
    --     packParams = {
    --         {
    --             data = {1, 2, 3, 4, 5},
    --             template = function(v) 
    --                 print("number ", v)
    --                 local label = UI.newText({text = v})
    --                 return label
    --             end,
    --             dir = ccui.LayoutType.VERTICAL
    --         }
    --     }
    -- })
    -- self:addChild(List)
    -- List:setPosition(400, 200)
end

function M:addDefaultTestList()
    if self._showTestList then
        return
    end
    local testDesList = {
        {
            btnTest = "多肉特效调整", 
            releaseCallBack = function() 
                self:actionTest() 
            end
        },
        {
            btnTest = "多肉植物摆放", 
            releaseCallBack = function() 
                self:setPlantTest() 
            end
        },
        {
            btnTest = "组件测试", 
            releaseCallBack = function() 
                -- self:setPlantTest() 
            end
        },
        {
            btnTest = "FSM测试",
            releaseCallBack = function()
                -- print("")
                self:testFSM()
            end
        },
    }
    for i, v in ipairs(testDesList) do
        self:addButton(v)
    end
    self:testFSM()
    self._showTestList = true
end

--[[
@params btnTest 按钮上文字
releaseCallBack 回调
]]--
function M:addButton(params)
    local btn = UI.newButton({
        text = params.btnTest,
        x = self._curentListPos.x,
        y = self._curentListPos.y,
        parent = self._btnParent,
    })
    if btn then
        self._curentListPos.y = self._curentListPos.y - 100

        if params.releaseCallBack then
            btn:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    params.releaseCallBack()
                end
            end)
        end
    end
end

local function createLayer()
    local winSize = ViewUtil.winSize
    local layer = cc.LayerColor:create(display.COLOR_WHITE, winSize.width, winSize.height)

    local closeBtn = UI.newButton({
        x = 1100,
        y = 700,
        parent = layer,
        text = "关闭"
    })
    closeBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AlertManager.hideWin(layer)
        end
    end)
    AlertManager.popWin(layer)
    return layer
end
function M:actionTest()
    local layer = createLayer()
    -- self:addChild(layer)
    -- AlertManager.popWin(layer)

    local botany02 = UI.newImageView({
        url = ResConfig.png.EElegan005,
        parent = layer,
        x = 400,
        y = 300,
    })
    local time = 0.5
    local xValue = 1.3
    local yValue = 0.8
    
    local xx = 700
    local invail = 150
    local x, y = xx, 400
    local inputSign = UI.newText({
        text = "宽变形比例",
        parent = layer,
        x = x,
        y = y,
        color = display.COLOR_BLACK,
    })
    local inputValue = UI.newTextField({
        parent = layer,
        placeHolder = "占位"..xValue,
        x = x + invail,
        y = y,
        color = display.COLOR_BLACK,
    })

    local x, y = xx, 300
    local inputSign = UI.newText({
        text = "高变形比例",
        parent = layer,
        x = x,
        y = y,
        color = display.COLOR_BLACK,
    })
    local inputValue2 = UI.newTextField({
        parent = layer,
        placeHolder = "占位"..yValue,
        x = x + invail,
        y = y,
        color = display.COLOR_BLACK,
    })

    local x, y = xx, 200
    local inputSign = UI.newText({
        text = "时间",
        parent = layer,
        x = x,
        y = y,
        color = display.COLOR_BLACK,
    })
    local inputValue3 = UI.newTextField({
        parent = layer,
        placeHolder = "占位"..time,
        x = x + invail,
        y = y,
        color = display.COLOR_BLACK,
    })
    
    local btn = UI.newButton({
        text = "调整",
        x = 800,
        y = 600,
        parent = layer,
        -- btnStyle = {normal = ResConfig.png.commonIconWq06}
    })

    local labelT = {}
    for i = 1, 3 do
        local text = UI.newText({
            x = 200 + i * 200,
            y = 700,
            parent = layer,
            color = display.COLOR_RED,
        })
        table.insert(labelT, text)
    end

    local function changeAction()
        botany02:stopAllActions()
        botany02:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.ScaleTo:create(time, xValue, yValue),
                    cc.ScaleTo:create(time, 1)
                )
            )
        )
        local v = {xValue, yValue, time}
        for i = 1, 3 do
            labelT[i]:setString(v[i])
        end
    end

    changeAction()
    -- addReleaseEvent()
    btn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            print("Touch Up")
            xValue = tonumber(inputValue:getString()) or xValue
            yValue = tonumber(inputValue2:getString()) or yValue
            time = tonumber(inputValue3:getString()) or time
            changeAction()
        end
    end)
end

local ChangePanel = require "game.Module.Test.ChangePanel"

function M:setPlantTest()
    local defaultScale = 0.5
    local layer = createLayer()
    local imgGather = {}
    local listView
    local lastChooseObj, changePanel = false, false

    local sizeLayout = UI.newLayout({
        size = cc.size(5, 5),
        color = Style.ColorStyle.BLACK,
        parent = layer,
        x = 0.5, 
        y = 0.5,
        positionType = ccui.PositionType.percent,
    })

    -- sizeLayout:setLocalZOrder(0)
    -- sizeLayout:setContentSize(cc.size(100, 100))
    -- sizeLayout:runAction(cc.Follow:create(layout))
    
    sizeLayout:setTag(10010)

    local layout = sizeLayout:clone()
    layer:addChild(layout)

    local outLayout = layout:clone()
    outLayout:setLocalZOrder(10)
    layer:addChild(outLayout)

    -- outLayout:runAction(cc.Follow:create(layout))
    
    

    local function updateSizeLayout()
        local rect = ViewUtil.getRect(layout, true)
        printAll(rect, {tip = "updateSizeLayout"})
        sizeLayout:setContentSize(cc.size(rect.width, rect.height))
        sizeLayout:setPosition(rect.x, rect.y)--(cc.pAdd(cc.p(rect.x, rect.y), cc.p(layout:getPosition())))
        print("sizeLayoutsizeLayout", 
            sizeLayout:getContentSize().width, 
            sizeLayout:getContentSize().height, 
            sizeLayout:getPositionX(), 
            sizeLayout:getPositionY())
    end

    local moveImgT = {}
    --增加ZOrder自动增加
    local moveImgZOrder = 0
    local function createMovedImg(url)
        local img = UI.newImageView({
            url = url,
            -- parent = layer
            zOrder = moveImgZOrder,
        })
        moveImgZOrder = moveImgZOrder + 1
        img:setTouchEnabled(true)
        img:setName(url)
        local imgPos, startPos = {x = 0, y = 0}, {x = 0, y =0}
        local isMove = false
        local function removeChangePanel()
            if changePanel then
                changePanel:removeFromParent()
                changePanel = false
            end
        end
        img:addTouchEventListener(function(sender, eventType)
            -- print("img eventType", eventType)
            if eventType == ccui.TouchEventType.began then
                if lastChooseObj then
                    ViewUtil.breathEnabled(false, lastChooseObj)
                end
                lastChooseObj = img
                imgPos.x, imgPos.y = img:getPosition()
                startPos = img:getTouchBeganPosition()
                removeChangePanel()
                isMove = false
            elseif eventType == ccui.TouchEventType.moved then
                isMove = true
                local pos = sender:getTouchMovePosition()
                img:setPosition(cc.pAdd(imgPos, cc.pSub(pos, startPos)))
            elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
                if not isMove then
                    changePanel = ChangePanel.new(img, removeChangePanel)
                    changePanel:setPosition(img:getContentSize().width, 0)
                    img:addChild(changePanel)
                    ViewUtil.breathEnabled(true, img)
                else
                    updateSizeLayout()
                end
            end
        end)
        table.insert(moveImgT, img)
        return img
    end

    --[[local function createImg(startPos, nameT)
        for i, v in  ipairs(nameT) do
            for imgIndex = 1, v[2] do
                local name = ResConfig.png[string.format("%s%d", v[1], imgIndex)]
                if name then
                    local img = createMovedImg(name)
                    img:setPosition(startPos.x, startPos.y - (imgIndex - 1) * img:getContentSize().height * defaultScale)
                    table.insert(imgGather, img)
                end
            end
        end
    end]]

    local defaultConfigNameT = {"Pot", "Soil", "Succulent"}
    local configInput = UI.newTextField({
        parent = layer,
        placeHolder = "导入配置",
        x = 1100,
        y = 650,
        text = "",
        color = display.COLOR_BLACK,
    })
    local addConfigInfoBtn = UI.newButton({
        text = "导入配置",
        x = 1100,
        y = 580,
        parent = layer,
    })

    local function createListItem(params)
        -- print("createListItemcreateListItem")
        local img = UI.newImageView({url = params.url})
        img:setTouchEnabled(true)
        local cloneImg = false
        local lastMovePos = false


        img:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.moved then
                -- local layoutPos = cc.p(layout:getPosition())

                if not lastMovePos then
                    lastMovePos = img:getTouchMovePosition()
                else 
                    local curMovePos = img:getTouchMovePosition()
                    local offset = cc.pSub(curMovePos, lastMovePos)
                    -- print("offsetX", offset.x, offset.y)
                    if offset.x > 30 and offset.y < 30 then
                        if not cloneImg then
                            cloneImg = createMovedImg(params.url)
                            layer:addChild(cloneImg)
                            -- layout:addChild(cloneImg)
                            cloneImg.code = params.code
                            cloneImg.configName = params.configName
                            -- print("layoutPoslayoutPos", layoutPos.x, layoutPos.y, img:getTouchMovePosition().x, img:getTouchMovePosition().y)
                            cloneImg:setPosition(img:getTouchMovePosition())
                            -- (cc.pSub(img:getTouchMovePosition(), layoutPos)) 
                        end 
                    end
                end
                if cloneImg then
                    cloneImg:setPosition(img:getTouchMovePosition())
                    -- cloneImg:setPosition(cc.pSub(img:getTouchMovePosition(), layoutPos)) 

                end
            elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
                if cloneImg then
                    -- 切换父节点
                    cloneImg:retain()
                    cloneImg:removeFromParent()
                    local layoutPos = cc.p(layout:getPosition())
                    layout:addChild(cloneImg)
                    -- print("")
                    print("layoutPoslayoutPos", layoutPos.x, layoutPos.y, cloneImg:getPosition())
                          
                    cloneImg:setPosition(cc.pSub(cc.p(cloneImg:getPosition()), layoutPos))
                    updateSizeLayout()
                    cloneImg = false 
                end             
                lastMovePos = false
            end
        end)
        return img
    end

    local packT = {}
    local function getData(name)
        local configName = string.format("%sConfig", name)
        local config = _G[configName]
        -- print("addInfoToList ", info)
        if not config then
            return {}
        end
        -- print("getDatagetDatagetData ", name)
        local info = config:getDict()
        local data = {}
        for i, v in pairs(info) do
            if v.img then
                -- print("create img ", v.img)
                local url = ResConfig.png[v.img]
                table.insert(data, {url = url, code = i, configName = configName})
            end
        end
        return data
    end
    local function createSign(params)
        print("createSigncreateSign")
        local name, style, width = params.name, params.style, params.width
        local bg = UI.newImageView({
            url = style.bg,
            width = width,
            height = style.height,
        })
        local name = UI.newText({
            text = name,
            parent = bg,
            x = 0.5,
            y = 0.5,
            positionType = ccui.PositionType.percent,
        })
        local btn = UI.newButton({
            btnStyle = {normal = style.signBg}, 
            parent = bg,
            x = 30,
            y = 15,
        })
        local packEnabled  = true
        local function setPackEnabled(var)
            if packEnabled ~= var then
                local rotation = -90
                local time = 0.2
                if var then
                    rotation = 0
                end
                listView:setPackEnabled(bg:getTag() + 1, var)
                btn:runAction(cc.RotateTo:create(time, rotation))
                packEnabled = var
            end
        end
        btn:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                print("旋转")
                setPackEnabled(not packEnabled)
            end
        end)
        return bg
    end
    for i, v in ipairs(defaultConfigNameT) do
        local sign = {{name = v, style = Style.DEFAULT_ACCORDION_STYLE, width = 300}}
        table.insert(
            packT, 
            {
                data = sign,
                template = createSign,
                dir = ccui.LayoutType.VERTICAL,
                sameItemSize = false,
            }
        )
        local data = getData(v)
        print("datadatadatadata", data, table.size(data))
        printAll(data)
        table.insert(
            packT, 
            {
                data = data,
                template = createListItem,
                dir = ccui.LayoutType.VERTICAL,
                sameItemSize = false,
            }
        )
    end

    listView = List.new({
        viewParams = {
            viewSize = cc.size(300, 700),
            dir = ccui.LayoutType.VERTICAL,
            -- innerContainerSize = cc.size(500, 1000),
        },
        packParams = packT,
        --[[{
            {
                data = urlGather,
                template = createListItem,
                dir = ccui.LayoutType.VERTICAL,
                sameItemSize = false,
            }
        }]]
    })
    layer:addChild(listView)
    listView:setPosition(0, 50)


    local function updateConfigName()
        local ss = table.concat(defaultConfigNameT, "")
        configInput:setString(ss)
    end
    addConfigInfoBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local value = configInput:getString()
            if value ~= "" then
                table.insert(defaultConfigNameT, value)
                addInfoToList(value)
            end
        end
    end)

    local input = UI.newTextField({
        parent = layer,
        placeHolder = "缩放比例",
        x = 1100,
        y = 500,
        color = display.COLOR_BLACK,
    })
    local comBtn = UI.newButton({
        text = "改变大小",
        x = 1100,
        y = 400,
        parent = layer,
    })
    local configFileNameInput = UI.newTextField({
        parent = layer,
        placeHolder = "配置文件名称",
        x = 1100,
        y = 300,
        color = display.COLOR_BLACK,
    })
    local configNameInput = UI.newTextField({
        parent = layer,
        placeHolder = "配置项目名称",
        x = 1100,
        y = 200,
        color = display.COLOR_BLACK,
    })

    local saveBtn = UI.newButton({
        text = "保存这个组合",
        x = 1100,
        y = 100,
        parent = layer,
    })
    local function changeScale(scale)
        if scale then
            for i, v in ipairs(imgGather) do
                v:setScale(scale)
            end
            input:setString("缩放比例"..scale)
        end
    end
    comBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local scale = tonumber(input:getString())
            changeScale(scale)
        end
    end)
    changeScale(defaultScale)

    local function getObjInfoT(obj)
        local objT = {
            posX = obj:getPositionX(),
            posY = obj:getPositionY(),
            zOrder = obj:getLocalZOrder(),
        }
        return objT
    end
    local targetInfo = {
        child = {}
    }
    saveBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local insertChildrenInfo
            insertChildrenInfo = function(children, t, name)
                for _, child in ipairs(children) do
                    local info = getObjInfoT(child)
                    if not t[name] then
                        t[name] = {}
                    end
                    if child.code then
                        if child.sameSizeCode then
                            local configName = child.configName
                            print("configNameconfigName", configName)
                            local config = _G[configName]:getDict()
                            for code, _ in pairs(config) do
                                t[name][code] = info
                            end
                        else
                            t[name][child.code] = info
                        end
                        local ch = child:getChildren()
                        if #ch > 0 then 
                            insertChildrenInfo(ch, info, name)
                        end
                    end
                end
            end
            insertChildrenInfo(layout:getChildren(), targetInfo, "child")
            printAll(targetInfo)
            FileUtil.saveConfigFile("TestFIleSave", targetInfo)
        end
    end)

end
-- 完善它
function M:componentExp()

end

function M:testFSM()
    local time = 1
    local img = UI.newImageView({
        url = ResConfig.png.EElegan001,
        parent = self,
        x = 400,
        y = 400,
        zOrder = 100,
    })

    local fsm = FSM:create(img)
    local moveStateName, moveState = "moveState"
    moveState = FSMState:create({
        excute = function(_, target)
            target:runAction(
                cc.Sequence:create(
                    cc.MoveBy:create(time, cc.p(0, 50)),
                    cc.CallFunc:create(function()
                        moveState:finishExcute()
                    end)
                )
            )
        end
    })

    local scaleStateName, scaleState = "scaleState"
    scaleState = FSMState:create({
        excute = function(_, target)
            target:runAction(
                cc.Sequence:create(
                    cc.ScaleBy:create(time, 1.5),
                    cc.CallFunc:create(function()
                        scaleState:finishExcute()
                    end)
                )
            )
        end
    })

    local normalStateName, normalState = "normalState"
    normalState = FSMState:create({
        excute = function(_, target)
            target:runAction(
                cc.Sequence:create(
                    cc.ScaleTo:create(time, 1),
                    cc.MoveBy:create(time, cc.p(0, -50)),
                    cc.CallFunc:create(function()
                        normalState:finishExcute()
                    end)
                )
            )
        end
    })

    local infoTable = {
        {
            name = moveStateName,
            state = moveState,
            linkInfo = scaleStateName,
        },
        {
            name = scaleStateName,
            state = scaleState,
            linkInfo = normalStateName,
        },
        {
            name = normalStateName,
            state = normalState,
            linkInfo = moveStateName,
        }
    }
    for i, info in ipairs(infoTable) do
        fsm:addState(info)
    end

    fsm:changeState(moveStateName)
end

return M
