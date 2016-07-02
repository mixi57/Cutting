
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

-- 系统配置
-- 顺序很重要
require "config"
require "cocos.init"
require "init"

if CC_DISABLE_GLOBAL then
    cc.disable_global()
end

local function init()
	if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(true)
    end
end
local function main()
	-- print(os.time())
    -- require("app.MyApp"):create():run()
    init()
    GameManager.startUp()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    -- printError(msg)
    print(msg)
end
