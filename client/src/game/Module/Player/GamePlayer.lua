--Author: mixi
--Date: 2016-06-25 15:03:52
--Abstract: GamePlayer
local GamePlayer = class("GamePlayer", require "game.Module.Player.Player")

-- function GamePlayer:ctor(...)
-- end
-- local print = function () end

function GamePlayer:getPath()
	return ResConfig.png.peoplePlayer
end
local StateTextInfo = {
	["normal"] = "站\n立\n",
	["running"] = "走\n动\n",
	["down"] = "绑\n鞋\n带\n",
}

local function getActionOffsetY()
	return 90
end

function GamePlayer:cachePlayerAction()
	local plistPath, pngPath, frameTime = ResConfig.plist.jianxiao, ResConfig.png.jianxiao, 0.1
    local frameNameTable = {}
    for i = 0, 1 do
        table.insert(frameNameTable, string.format("jianxiao_%d.png", i))
    end 
    self._normalAction = UI.newEffect({
        parent = self,
        plistPath = plistPath,
        pngPath = pngPath,
        frameNameTable = frameNameTable,
        frameTime = frameTime,
        y = getActionOffsetY()
    })
    self._target:setVisible(false)
    table.insert(self._actionTable, self._normalAction)

    local plistPath, pngPath, frameTime = ResConfig.plist.peopleAction, ResConfig.png.peopleAction, 0.15
    local frameNameTable = {}
    for i = 0, 1 do
        table.insert(frameNameTable, string.format("pwalk_%d.png", i))
    end 
    self._runningAction = UI.newEffect({
        parent = self,
        plistPath = plistPath,
        pngPath = pngPath,
        frameNameTable = frameNameTable,
        frameTime = frameTime,
        y = getActionOffsetY()
    })
    self._target:setVisible(false)
    table.insert(self._actionTable, self._runningAction)

	
	local plistPath, pngPath, frameTime = ResConfig.plist.han, ResConfig.png.han, 0.1
    local frameNameTable = {}
    for i = 0, 7 do
        table.insert(frameNameTable, string.format("han_%d.png", i))
    end 
    self._endAction = UI.newEffect({
        parent = self,
        plistPath = plistPath,
        pngPath = pngPath,
        frameNameTable = frameNameTable,
        frameTime = frameTime,
        y = getActionOffsetY()
    })
    table.insert(self._actionTable, self._endAction)

end
function GamePlayer:normal()
	self._normalAction:setVisible(true)
end

function GamePlayer:endAction(offset)
	print("GamePlayer:endAction(offset) ", offset)
	if not offset or offset <= 0 then
		return
	end
	local offsetLine = offset
	local time = ConstInfo:getDict().GAME_OVER_ACTION_TIME / 2
	local offsetX = 40
	local offsetY = 40
	-- print("self._stepLenght", self._stepLenght, self._stepLenght * offsetLine, offsetLine)

	local addPosX = -20--self._stepLenght / 2
	local path = ResConfig.mp3.cutLine
	ccexp.AudioEngine:play2d(path, false)

	local length = addPosX + self._stepLenght * offsetLine - 2 * offsetX
	self:runAction(
		cc.Sequence:create(
			cc.MoveBy:create(time, cc.p(offsetX, -offsetY)),
			cc.MoveBy:create(time, cc.p(length, 0)),
			-- cc.MoveBy:create(time, cc.p(offsetX, offsetY)),
			cc.CallFunc:create(function()
				self._endAction:setVisible(true)
				local path = ResConfig.mp3.fail1
			    ccexp.AudioEngine:play2d(path, false)
			end)
		)
	)
end

function GamePlayer:running()
	self._runningAction:setVisible(true)
end
-- local index = 0
function GamePlayer:insert(offset, callbackFunc, targetPosX)
	local path = ResConfig.mp3.cutLine
    ccexp.AudioEngine:play2d(path, false)

	-- print("GamePlayer:insert", offset)
	local offsetLine = offset
	local time = ConstInfo:getDict().INSERT_TIME
	local offsetX = 40
	local offsetY = 40
	local targetPosX = targetPosX or 0
	-- print("self._stepLenght", self._stepLenght, self._stepLenght * offsetLine, offsetLine)

	local addPosX = self._stepLenght / 2
	local forwardLength = targetPosX and math.ceil(targetPosX - self:getPositionX()) or self._stepLenght * offsetLine
	local length = addPosX + forwardLength - 2 * offsetX
	-- if targetPosX then print("targetPosX ", targetPosX) end
	-- print("前进距离 ", offset, length, addPosX, self._stepLenght * offsetLine, targetPosX, targetPosX - self:getPositionX())
	self:runAction(
		cc.Sequence:create(
			cc.MoveBy:create(time, cc.p(offsetX, -offsetY)),
			cc.MoveBy:create(time, cc.p(length, 0)),
			cc.MoveBy:create(time, cc.p(offsetX, offsetY)),
			cc.CallFunc:create(function()
				self:changeState(Enum.PLAYER_STATE.NORMAL)
			end),
			-- cc.DelayTime:create(1),
			cc.CallFunc:create(function()
				if callbackFunc then
					callbackFunc()
				end
			end)
		)
	)
	-- local text = UI.newText({
	-- 	parent = self:getParent(),
	-- 	x = self:getPositionX() + offsetX + length,
	-- 	y = self:getPositionY(),
	-- 	text = "Here"..index
	-- })
	-- local text = UI.newText({
	-- 	parent = self:getParent(),
	-- 	x = self:getPositionX(),
	-- 	y = self:getPositionY(),
	-- 	text = "Start"..index
	-- })
	-- index = index + 1
	
	self._runningAction:setVisible(true)
end

-- 这个是重写 不能删掉
function GamePlayer:sleep()
end
function GamePlayer:updateSleepSchedule()
end

return GamePlayer