--Author: mixi
--Date: 2016-05-28 22:24:15
--Abstract: BalconyModule
local M = class("BalconyModule", View)
local DEBUG = true
local Player = require "game.Module.Player.Player"
local GamePlayer = require "game.Module.Player.GamePlayer"
local printVV = print
local print = function() end
local printAll = function() end

local printV = print
local printT = printAll

local SoundManager = cc.SimpleAudioEngine:getInstance()
M.RESOURCE_INFO = {
    {  
        "Scene.csb", 
        {
        }
    }
}
local function addReleaseEvent(event, callback, params)
    if event.name == "ended" then
        callback(params)
    end
end

local OverTextResOnePre = {
    "你的女朋友对你失去信心，愤然离去",
    "你家的狗对你感到失望，去寻找新主人了",
    "你的喵主人决定抛弃你这个铲屎官",
}

local OverTextResTwoPre = {
    "居然被发现了",
    "下次要再注意点",
    "会被打么",
}

function M:initView()
    -- 预加载
    local mp3PathT = ResConfig.mp3
    for i, path in ipairs(mp3PathT) do
        ccexp.AudioEngine:preload(path)
    end
    local path = ResConfig.mp3.bgMusic
    ccexp.AudioEngine:play2d(path, true)
    
    self:show()

    -- 适配
    local winSize = ViewUtil.winSize
    local configHeight = CC_DESIGN_RESOLUTION.height
    local offsetHeight = winSize.height - configHeight
    -- self._targetNode:setPositionY(self._targetNode:getPositionY() + offsetHeight)


    -- print("winSize", winSize.width, winSize.height)
    -- 背景层
    self._bg = self._targetNode:getChildByName("Panel_1")

    self._bg:setContentSize(ViewUtil.winSize)

    -- 虚拟道路
    self._road = self._bg:getChildByName("Panel_2")
    self._rolesParent = ccui.Widget:create()
    self._road:addChild(self._rolesParent)
    
    -- 触摸判断层
    self._touchPanel = self._targetNode:getChildByName("Panel_3")
    self._touchPanel:setVisible(false)
    -- self._touchPanel:setTouchEnabled(true)
    

    -- 需要滚动的背景层
    self._bgImg = UI.newImageView({
        url = ResConfig.png.bg,
        parent = self._rolesParent,
        zOrder = -1,
        anchorPoint = cc.p(0, 0),
        y = -self._road:getPositionY() + offsetHeight,
        -- Color = Style.ColorStyle.RED
    })
    if offsetHeight > 0 then
        local bottomImg = self._bgImg:clone()
        bottomImg:setPositionY(- offsetHeight)
        self._bgImg:addChild(bottomImg)
    end
    self._bgImgSize = self._bgImg:getContentSize()
    self._nextBgImg = self._bgImg:clone()
    self._bgImg:getParent():addChild(self._nextBgImg)
    -- self._bgImg:setColor(Style.ColorStyle.RED)
    -- self._nextBgImg:setColor(Style.ColorStyle.GREEN)
    self._nextBgImg:setPositionX(self._bgImg:getPositionX() + self._bgImgSize.width)

    -- 占位
    self._textTarget = self._road:getChildByName("Text_1")
    self._startPos = cc.p(self._textTarget:getPosition())

    -- 玩家与玩家之间的间隔
    self._playerInterval = false
    
    self._textTarget:removeFromParent()

    -- 主角
    self._player = false
    self._playerPos = false
    self._playerScore = 0
    self._cutLineTimes = 0

    -- 角色向量
    self._roleVec = {}
    self._maxRoleIndex = false
    self._roleCache = {} -- 加个缓存 就不用频繁生成

    -- 用来算被删去的段落
    self._offsetNum = 0 
    
    -- 玩家初始化位置
    self._firstPlayerIndex = 3
    -- 玩家所在位置与屏幕左边的偏移量
    self._firstOffset = false

    self:openLoginAction()
    -- self:gameInit()
    self._hasStart = false
    self._lastOffset = 0
    -- self:gameStart()

    -- self:moveRoad()
    self._scoreText = UI.newText({
        parent = self._bg,
        x = 200,
        y = ViewUtil.winSize.height - 50,
    })
    self._cuttingText = UI.newText({
        parent = self._bg,
        x = ViewUtil.winSize.width - 200,
        y = ViewUtil.winSize.height - 50,
    })

end

function M:getGamePlayer()
    if not self._player then
        self._player = self:createPlayer(Enum.PLAYER_TYPE.MAIN_PLAYER)
        self._player:setLocalZOrder(100)
        self._playerInterval = self._player:getContentSize().width + ConstInfo:getDict().PLAYER_INTERVAL
        Cache.mainCache.playerInterval = self._playerInterval
        print("_playerInterval", self._playerInterval)
    end
    return self._player
end

function M:openLoginAction()
    local player = self:getGamePlayer()
    player:setPositionX(self._road:getContentSize().width / 2)
    
    self._tipPanel = cc.Node:create()
    self._bg:addChild(self._tipPanel)
    self._tipPanel:setLocalZOrder(100)
    local time = 0.5
    local stepLenght = 100
    local stateTable = {Enum.PLAYER_STATE.NORMAL, Enum.PLAYER_STATE.RUNNING, stepLenght, -2 * stepLenght, stepLenght}
    local index = 1
    local loginSchedule = Scheduler.schedule(
        function()
            if index < 3 then
                player:changeState(stateTable[index])
            else
                player:setScaleX(stateTable[index] > 0 and 1 or -1)
                player:runAction(cc.MoveBy:create(time, cc.p(stateTable[index], 0)))
            end
            index = index + 1
            if index > #stateTable then
                index = index % #stateTable
            end
        end,
        time, 
        false,
        0,
        self
    )

    local tipTouchFunc = function()
        Scheduler.unschedule(loginSchedule)
        self._player:setScaleX(1)
        self._tipPanel:removeFromParent()
        self:gameInit()
    end
    local tipTouchLayout = UI.newLayout({
        parent = self._tipPanel,
        -- color = Style.ColorStyle.GRAY,
        zOrder = 100,
        size = ViewUtil.winSize,
        touchEnabled = true,
    })
    tipTouchLayout:addTouchEventListener(function(handle, eventType)
        if eventType == ccui.TouchEventType.ended then
            tipTouchFunc()
        end
    end)

    local label = UI.newText({
        parent = self._tipPanel,
        x = ViewUtil.winSize.width / 2,
        y = ViewUtil.winSize.height - 150,
        zOrder = 1000,
        text = "我就是要插队",
        fontSize = 150,
        color = Style.ColorStyle.RED,
    })

    local tipText = UI.newText({
        parent = self._tipPanel,
        text = "任意点击准备开始",
        x = ViewUtil.winSize.width / 2,
        y = ViewUtil.winSize.height / 2,
        -- color = Style.ColorStyle.BLACK,
        zOrder = 1000,
    })
    ViewUtil.breathEnabled(true, tipText)
end

function M:changeTouchPosToRoadPos(touchPos)
    local roadPos = cc.pSub(
        touchPos,
        cc.p(self._road:getPosition())
    )
    local posInRolesParent = cc.pSub(roadPos, cc.p(self._rolesParent:getPosition()))
    
    local playerPosX = self._player:getPositionX() + self._playerInterval - self._player:getContentSize().width / 2
    local offset = math.ceil((posInRolesParent.x - playerPosX) / self._playerInterval)
    return posInRolesParent, offset
end

function M:touchOffsetPlayer(offset, var, target)
    if var then
        self:gameOver(offset)
        return
    else
        if self._playerRunning then
            printV("运动中 ")
            return
        end
    end
    
    if offset and offset > 0 then
        self._playerScore = self._playerScore + offset
        self._scoreText:setString(string.format("已插队前进%d步", self._playerScore))
        self._cutLineTimes = self._cutLineTimes + 1
        self._cuttingText:setString(string.format("已插队了%d次", self._cutLineTimes))
        printV("....... printAll(self._roleVec) offset", offset)
        
        self._playerRunning = true
        self._touchPanelTouchEnabled = false
        self._player:changeState(
            Enum.PLAYER_STATE.INSERT, 
            offset, 
            function()    
                printV("....... printAll(self._roleVec) 1", self._playerPos)
                -- printAll(self._roleVec)
               
                local newOffset = self._playerPos + offset
                -- 前面的不要睡啦
                for i = self._playerPos + 1, newOffset do
                    print("for i = self._playerPos + 1, newOffset do", i)
                    local role = self._roleVec[i]
                    role:changeState(Enum.PLAYER_STATE.NORMAL)
                end
                table.remove(self._roleVec, self._playerPos)
                table.insert(self._roleVec, newOffset, self._player)
                print("....... printAll(self._roleVec) 2")
                -- printAll(self._roleVec)

                self._playerPos = newOffset
                local lineTime = ConstInfo:getDict().LINE_TIME
                
                self:updateRolePrevAndNext()
                self:updateRolePos(lineTime)

                local time = ConstInfo:getDict().RETURN_TIME
                local posX = self._player:getPositionX() - self._player:getContentSize().width / 2 - self._startPos.x
                -- offsetNum * self._playerInterval
                -- print("touchOffsetPlayertouchOffsetPlayertouchOffsetPlayer", posX)
                local rolePosX = self._rolesParent:getPositionX()
                -- print("rolePos = self._rolesParent:getPositionX()", -posX - rolePos)
                local function moveEndFunc()
                    self._touchPanelTouchEnabled = true
                    self._playerRunning = false
                end
                if -posX - rolePosX < 0 then
                    self._rolesParent:runAction(
                        cc.Sequence:create(
                            cc.DelayTime:create(lineTime),
                            cc.MoveTo:create(
                                time, cc.p(-posX, 0)
                            ),
                            cc.CallFunc:create(moveEndFunc)
                        )
                    )
                else
                    moveEndFunc()
                end

            end,
            target:getPositionX()
        )
    end
end

function M:addTouchPanelEvent()
    print("addTouchPanelEvent")
    local touchPanel = UI.newLayout({
        parent = self._touchPanel:getParent(),
        position = cc.p(self._touchPanel:getPosition()),
        size = self._touchPanel:getContentSize(),
        zOrder = 100,
        -- color = Style.ColorStyle.RED,
        anchorPoint = cc.p(0, 0),
        touchEnabled = false,
        opacity = 100,
        tag = 10000,
    })
    self._touchPanel:removeFromParent()
    self._touchPanel = touchPanel
    self._touchPanelTouchEnabled = false -- true
    self._touchPanel:addTouchEventListener(function(handle, eventType)
        print("eventType", eventType)
        if not self._touchPanelTouchEnabled then
            print("点击无效化")
            return
        end
        local pos, newPos, offset
        if eventType == ccui.TouchEventType.ended then
            pos = self._touchPanel:getTouchEndPosition()
            newPos, offset = self:changeTouchPosToRoadPos(pos)
            print("touch ended", pos.x, pos.y, newPos.x, newPos.y, offset)
        end
        self:touchOffsetPlayer(offset)
    end)
end

function M:updateRolePos(lineTime)
    print("updateRolePosupdateRolePos", lineTime)
    for i = 1, #self._roleVec do
        local role = self._roleVec[i]
        local offset = i - self._playerPos
        print("offset", offset)
        role:runAction(
            cc.MoveTo:create(
                lineTime, 
                cc.p(
                    self._player:getPositionX() + offset * self._playerInterval, 
                    self._startPos.y --+ offset * 10
                )
            )
        )
    end
    -- 加了个弹开功能 但效果不太喜欢
    -- self._player:tellTheNearByChangeTheirPos(Enum.NEAR_TYPE.FRONT, lineTime)
    -- self._player:tellTheNearByChangeTheirPos(Enum.NEAR_TYPE.BACK, lineTime)
    -- self:gameOver(1)
end

function M:createPlayer(playerType)
    local player, fromCache
    if playerType == Enum.PLAYER_TYPE.MAIN_PLAYER then
        player = GamePlayer:create(self)
    elseif playerType == Enum.PLAYER_TYPE.NORMAL_PLAYER then
        player = table.remove(self._roleCache, 1) 
        if player then
            fromCache = true
        else
            player = Player:create(self)
        end
    end
    player:changeState(Enum.PLAYER_STATE.NORMAL)
    if player and not fromCache then
        self._rolesParent:addChild(player)
    end
    return player
end

function M:gameInit()
    print("gameInit")
    self:getGamePlayer()
    self:addTouchPanelEvent()
    self._player:retain()
    self._player:removeFromParent(false)
    local playerPos = cc.pAdd(cc.p(self._player:getPosition()), cc.p(self._road:getPosition()))
    self._bg:addChild(self._player)
    self._player:setPosition(playerPos)
    self._player:release()
    local time = 0.5
    local size = self._bgImgSize --self._bgImg:getContentSize()
    local loadingTime = 1
    self._rolesParent:runAction(cc.MoveBy:create(loadingTime, cc.p(-size.width, 0)))
    local startPos = cc.pAdd(cc.p(self._road:getPosition()), self._startPos)
    
    print("startPos", startPos.x, startPos.y )
    self._player:changeState(Enum.PLAYER_STATE.RUNNING)

    local function enterGame()
        self._rolesParent:setPositionX(self._rolesParent:getPositionX() + size.width)

        self._player:retain()
        self._player:removeFromParent(false)
        local playerPos = cc.pSub(cc.p(self._player:getPosition()), cc.p(self._road:getPosition()))
        self._rolesParent:addChild(self._player)
        self._player:setPosition(playerPos)
        self._player:release()
        self:gameStart()
    end

    self._player:runAction(
        cc.Sequence:create(
            cc.MoveTo:create(loadingTime, startPos),
            cc.CallFunc:create(enterGame)
        )
    )
end

-- 按照视觉的顺序 map表是由左到右 实际传递顺序是从右到左
function M:updateRolePrevAndNext(oldRoleNum, num)
    local oldRoleNum = oldRoleNum or 0
    local num = num or #self._roleVec - oldRoleNum
    print("updateRolePrevAndNext", oldRoleNum, num)
    -- printAll(self._roleVec)
    for i = 1, num do
        local role = self._roleVec[oldRoleNum + i]
        local prevRole = self._roleVec[oldRoleNum + i - 1]
        local nextRole = self._roleVec[oldRoleNum + i + 1]
        -- if prevRole then
            role._prevRole = prevRole
        -- end
        -- if nextRole then
            role._nextRole = nextRole
        -- end
        role._stepLenght = Cache.mainCache.playerInterval
        role:setOffset(oldRoleNum + i - self._playerPos)
    end
end
-- pos 为与player的距离
function M:createAndInsertPlayerMap(pos, num, noUpdate)
    printV("createAndInsertPlayerMap", pos, num)
    local oldRoleNum = #self._roleVec
    for i = 1, num do
        local offset = pos + i - 1
        local role = self:createPlayer(Enum.PLAYER_TYPE.NORMAL_PLAYER, offset)
        role:setPosition(
            cc.p(
                self._player:getPositionX() + offset * self._playerInterval, 
                self._startPos.y
            )
        )
        table.insert(self._roleVec, role)
        -- print("createAndInsertPlayerMap ", role:getPositionX())
    end
    if not noUpdate then
        self:updateRolePrevAndNext(oldRoleNum, num)
    end
end

function M:gameStart()
    if self._hasStart then
        return
    end
    printV("gameStart")
     self._hasStart = true
    local player = self:getGamePlayer()
    player:changeState(Enum.PLAYER_STATE.NORMAL)
    local num = math.ceil(ViewUtil.winSize.width / self._playerInterval)
    self._maxNum = num

    if self._firstPlayerIndex - 1 > 0 then
        self:createAndInsertPlayerMap(-(self._firstPlayerIndex - 1), self._firstPlayerIndex - 1, true)
    end
    
    table.insert(self._roleVec, self._player)
    self._playerPos = #self._roleVec
    self:createAndInsertPlayerMap(1, num - self._firstPlayerIndex, true)

    self:updateRolePrevAndNext()

    self:moveRoad()
end

function M:gameOver(offset)
    local overText = UI.newText({
        text = "Game Over",
        parent = self,
        zOrder = 100,
        fontSize = 150,
        color = Style.ColorStyle.RED,
        x = ViewUtil.winSize.width / 2,
        y = ViewUtil.winSize.height - 150,
    })
    local stepNum = self._playerScore
    local roadNumText = UI.newText({
        text = string.format("你已经插了%s步 插队%d次", stepNum, self._cutLineTimes),
        parent = overText,
        color = Style.ColorStyle.RED,
        x = overText:getContentSize().width / 2,
        fontSize = 40,
    })

    local tipTabel = offset and OverTextResTwoPre or OverTextResOnePre 
    local otherText = UI.newText({
        text = tipTabel[math.random(1, #tipTabel)],
        x = overText:getContentSize().width / 2,
        y = -40,
        color = Style.ColorStyle.RED,
        parent = overText,
    })

    self._scoreText:setString("")
    self._cuttingText:setString("")
    self._touchPanel:setTouchEnabled(true)

    if self._moveRoadSchedule then
        Scheduler.unschedule(self._moveRoadSchedule)
    end
    if self._sleepSchedule then
        Scheduler.unschedule(self._sleepSchedule)
    end
    self._touchPanelTouchEnabled = false
    self._player:changeState(Enum.PLAYER_STATE.END, offset)
    local path = ResConfig.mp3.fail2
    ccexp.AudioEngine:play2d(path, false)

    local scale = 0.6
    local btn = UI.newButton({
        btnStyle = {normal = ResConfig.png.kaishi},
        parent = self,
        x = ViewUtil.winSize.width / 2,
        y = ViewUtil.winSize.height / 4,
        -- color = Style.ColorStyle.BLACK,
        scale = scale,
        zOrder = 1000,
    })
    btn:setPositionY(btn:getContentSize().height / 2 * scale + 50)
    btn:addTouchEventListener(function()
        self:removeAllChildren()
        ccexp.AudioEngine:stopAll()
        self:initView()
    end)
end

function M:moveRoad()
    local time = 0
    local bgSize = self._bgImgSize
    local nextImgBroadPosX = self._nextBgImg:getPositionX() + bgSize.width
    self._moveRoadSchedule = Scheduler.schedule(
        function()
            -- print("_moveRoadSchedule_moveRoadSchedule")
            local nextPosX = self._rolesParent:getPositionX() - 2
            self._rolesParent:setPositionX(nextPosX)
            local playerHalfSize = self._player:getContentSize().width / 2
            -- print("moveRoad moveRoad ", nextPosX, self._player:getPositionX())
            if self._player:getPositionX() + playerHalfSize < -nextPosX  then
                self:gameOver()
            end
            local offset = ViewUtil.winSize.width - (self._roleVec[#self._roleVec]:getPositionX() + playerHalfSize + nextPosX)
            if offset > 0 then --if self._roleVec[#self._roleVec]:getPositionX() + playerHalfSize + nextPosX < ViewUtil.winSize.width then
                local num = math.ceil(offset / self._playerInterval)
                self:createAndInsertPlayerMap(#self._roleVec - self._playerPos + 1, num)
            end

            if nextImgBroadPosX <= -nextPosX + ViewUtil.winSize.width then
                self._bgImg:setPositionX(nextImgBroadPosX)
                local temp = self._bgImg
                self._bgImg = self._nextBgImg
                self._nextBgImg = temp
                nextImgBroadPosX = self._nextBgImg:getPositionX() + bgSize.width
            end

            local firstRole = self._roleVec[1]
            if firstRole:getOffset() < 0 and self._roleVec[1]:getPositionX() + self._playerInterval < -nextPosX then
                if firstRole._nextRole then
                    firstRole._nextRole._prevRole = false
                end
                -- 改成缓存起来 循环利用 06.28 20:10 或者直接加在后边？
                firstRole:refresh()
                table.insert(self._roleCache, firstRole)
                -- firstRole:removeFromParent() 
                table.remove(self._roleVec, 1)
                self._playerPos = self._playerPos - 1
                print("清掉")
            end
        end,
        time,
        false,
        0,
        self
    )
    local maxSleepPlayerNum = 2
    self._sleepSchedule = Scheduler.schedule(
        function()
            -- print("_sleepSchedule_sleepSchedule")
            local sleepIndexMap = {}
            local addIndexT = {}
            for i = self._playerPos + 1, #self._roleVec do
                local road = self._roleVec[i]
                -- 如果在睡觉
                if not road:checkState() then
                    sleepIndexMap[i] = true
                end
            end
            local size = table.size(sleepIndexMap)

            local function getIndex(min, max)
                if min > max then
                    return false
                end
                if min == max then
                    return min
                end
                local index = math.random(min, max)
                local randomTime = 0
                local num = max - min + 1
                while sleepIndexMap[index] do
                    index = index + 1
                    if index > max then
                        index = min
                    end
                    randomTime = randomTime + 1
                    if randomTime >= num then
                        return false
                    end
                end 
                return index
            end
            if size < maxSleepPlayerNum then
                local num = maxSleepPlayerNum - size
                for i = 1, num do
                    local index = getIndex(self._playerPos + 1, #self._roleVec)
                    if index then
                        sleepIndexMap[index] = true
                        table.insert(addIndexT, index)
                    else
                        break
                    end
                end
                for i, v in ipairs(addIndexT) do
                    local role = self._roleVec[v]
                    role:changeState(Enum.PLAYER_STATE.SLEEP)
                end
            end
        end,
        1,
        false,
        0,
        self
    )
end

return M
