--Author: mixi
--Date: 2016-05-27 17:12:19
--Abstract: GameManager
local GameManager = {}

local DefaultModule = ModuleConfig.MAIN --BALCONY--LOGIN--
local DefaultSceneName = "defaultScene"

local function init()
	GameManager.lastSceneName = false
	-- GameManager.lastScene = false
end

local function createNewModule(controller, moduleConfig, onCompleteHandler)
	local viewType = moduleConfig.viewType
	local curScene = SceneManager.getCurScene() -- target.lastScene
	if viewType == ModuleViewType.SCENE then
		-- 切换场景
		print("切换场景")
		local sceneName = moduleConfig.scene
		curScene = SceneManager.getSceneByName(sceneName)
		controller:createAndBindView(curScene)
		SceneManager.replaceScene(curScene, sceneName)
		-- target.lastScene = curScene
	elseif viewType == ModuleViewType.PANEL then
		if not curScene then
			local sceneName = DefaultSceneName
			curScene = SceneManager.getSceneByName(DefaultSceneName)
			SceneManager.replaceScene(curScene, sceneName)
			-- target.lastScene = curScene
		end
		-- if not controller:isBindView() then
			controller:createAndBindView(curScene)
		-- end
	elseif viewType == ModuleViewType.POP then
		-- AlertManager.popWindow(controller:getView())
	end

	if onCompleteHandler then
		onCompleteHandler()
	end
end

function GameManager.startUp()
	-- GameProxy.init()
	GameController.init()
	GameManager.openModule(DefaultModule)
	-- GameManager.openModule(ModuleConfig.TEST)
end

--打开一个模块
--@param #string moduleConfig 模块配置
--@param #function onCompleteHandler 打开模块结束执行的函数
function GameManager.openModule(moduleConfig, onCompleteHandler)
	local beginT = TimeUtil.getCurTime()

	local controller = GameController.getController(moduleConfig)
	if not controller then
		error(string.format("%s no exist controller", moduleConfig.name))
	end

	local viewType = moduleConfig.viewType
	if not viewType then
		error(string.format("please set viewType in module %s", moduleConfig.name))
	end

	-- 打开已打开的场景 无效
	local isScene = viewType == ModuleViewType.SCENE
	local lastSceneName = GameManager.lastSceneName
	if isScene and lastSceneName and lastSceneName == moduleConfig.scene then
		printError("while open the exist module", moduleConfig.scene)
		return
	end
	createNewModule(controller, moduleConfig, onCompleteHandler)

	printInfo(string.format("打开模块 %s 花费时间 %d ~~~~~~~~~~^_^~~~~~~~~~~", moduleConfig.name, TimeUtil.getCurTime() - beginT))
end

return GameManager