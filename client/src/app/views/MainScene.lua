
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

MainScene.RESOURCE_FILENAME = "LoginScene.csb"
--[[
-- 获取UI控件
MainScene.RESOURCE_BINDING =
{
    ["cocos控件名"] = {
        ["varname"] = 引用变量名，
        ["events"] = {
            "event" = "touch" -- 触摸事件
            "method" = 调用接口名
        } 
    }
    ...
}
]]--
local MainSceneEvents={
    ["logInBtn"]={
        ["varname"]="_logInBtn",
        ["events"]={
            {
                ["event"]="touch",
                ["method"]="loginCallBack"
            },
        }
    },
    ["resignBtn"]={
        ["varname"]="_regisnBtn",
        ["events"]={
            {
                ["event"]="touch",
                ["method"]="resignCallBack"
            },
        }
    },
}
MainScene.RESOURCE_BINDING = MainSceneEvents

local function addReleaseEvent(event, callback, params)
    if event.name == "ended" then
        callback(params)
    end
end
function MainScene:loginCallBack(event)
    local callback = function()
        print("点击登陆按钮")
    end
    addReleaseEvent(event, callback)
end
function MainScene:resignCallBack(event)
    addReleaseEvent(
        event, 
        function()
            print("点击注册按钮")
        end
    )
end

function MainScene:onCreate()
    printf("resource node = %s", tostring(self:getResourceNode()))
    
    -- local sprite = display.newSprite("HelloWorld.png")
    --     -- :move(display.center)
    --     :addTo(self)

    -- local size = cc.size(1280, 720)
    -- local spriteSize = sprite:getContentSize()
    -- sprite:setAnchorPoint(0, 0)
    -- sprite:setScaleX(size.width / spriteSize.width)
    -- sprite:setScaleY(size.height / spriteSize.height)

    local menuRequest = cc.Menu:create()
    menuRequest:setPosition(cc.p(0, 0))
    self:addChild(menuRequest)

    local sendTextStatus
    local wsSendText

    local function onMenuSendTextClicked()
        -- if nil ~= wsSendText then
        --     if cc.WEBSOCKET_STATE_OPEN == wsSendText:getReadyState() then
        --        sendTextStatus:setString("Send Text WS is waiting...")
        --        wsSendText:sendString("Hello WebSocket中文, I'm a text message.")
        --     else
        --         local warningStr = "send text websocket instance wasn't ready..."
        --         print(warningStr)
        --         sendTextStatus:setString(warningStr)
        --     end
        -- end
        local sz_T2S 
        --把集合(table)转换为服务器方便处理的 JSON 格式字符串
        sz_T2S = function(_t)
            local szRet = "{"
            local function doT2S(_i, _v)
                    szRet = szRet .. '"' .. _i .. '":'
                    if "number" == type(_v) then
                        szRet = szRet .. _v .. ","
                    elseif "string" == type(_v) then
                        szRet = szRet .. '"' .. _v .. '"' .. ","
                    elseif "table" == type(_v) then
                        szRet = szRet .. sz_T2S(_v) .. ","
                    else
                        szRet = szRet .. "nil,"
                    end
            end
            table.foreach(_t, doT2S)
            szRet = string.sub(szRet,1,-2) --末尾会多一个逗号,减去
            szRet = szRet .. "}"
            return szRet
        end

        --把服务器传来的字符串(已经转换为 loadstring 能够直接处理的格式,而非 JSON 格式)转换为集合
        local function unsz_S2T(str)
            str = "return " .. str
            local fun = loadstring(str)
            return fun()
        end

        -- wsSendText = WebSocket:create("ws://182.254.212.143:8000/lua.js") 
--·¢ËÍÊý¾Ý ws://182.254.212.143:8000/lua.js
        local test = {}
        test.msg = "test"
        test.num = 123.45678
        local ss = sz_T2S(test)
        print("ssssss", ss)
        wsSendText:sendString(ss)
        print("sendString 182.254.212.143:8000/")
    end
    -- local winSize = cc.Director:getInstance():getWinSize()
    local winSize = cc.Director:getInstance():getWinSize()
    local MARGIN = 40
    local SPACE  = 35

    local labelSendText = cc.Label:createWithTTF("Send Text", "Marker Felt.ttf", 22)
    labelSendText:setAnchorPoint(0.5, 0.5)
    local itemSendText  = cc.MenuItemLabel:create(labelSendText)
    itemSendText:registerScriptTapHandler(onMenuSendTextClicked)
    itemSendText:setPosition(cc.p(winSize.width / 2, winSize.height - MARGIN - SPACE))
    menuRequest:addChild(itemSendText)

    sendTextStatus = cc.Label:createWithTTF("Send Text WS is waiting...", "Marker Felt.ttf", 14,cc.size(160, 100),cc.VERTICAL_TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    sendTextStatus:setAnchorPoint(cc.p(0, 0))
    sendTextStatus:setPosition(cc.p(0, 25))
    self:addChild(sendTextStatus)

    -- wsSendText   = cc.WebSocket:create("ws://echo.websocket.org")
    wsSendText = cc.WebSocket:create("ws://182.254.212.143:8000/lua.js")
    local function wsSendTextOpen(strData)
        sendTextStatus:setString("Send Text WS was opened.")
    end

    local receiveTextTimes = 1
    local function wsSendTextMessage(strData)
        receiveTextTimes= receiveTextTimes + 1
        local strInfo= "response text msg: "..strData..", "..receiveTextTimes    
        sendTextStatus:setString(strInfo)
    end

    local function wsSendTextClose(strData)
        print("_wsiSendText websocket instance closed.")
        sendTextStatus = nil
        wsSendText = nil
    end

    local function wsSendTextError(strData)
        print("sendText Error was fired")
    end
    if nil ~= wsSendText then
        wsSendText:registerScriptHandler(wsSendTextOpen,cc.WEBSOCKET_OPEN)
        wsSendText:registerScriptHandler(wsSendTextMessage,cc.WEBSOCKET_MESSAGE)
        wsSendText:registerScriptHandler(wsSendTextClose,cc.WEBSOCKET_CLOSE)
        wsSendText:registerScriptHandler(wsSendTextError,cc.WEBSOCKET_ERROR)
    end

    -- sprite:setScale(2)
    -- sprite:ignoreContentAdaptWithSize()

    --[[ you can create scene with following comment code instead of using csb file.
    -- add background image
    display.newSprite("HelloWorld.png")
        :move(display.center)
        :addTo(self)

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)
    ]]
end

return MainScene
