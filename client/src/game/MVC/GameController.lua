--Author: mixi
--Date: 2016-05-27 18:19:15
--Abstract: GameController
local GameController = {}

--初始化控制器
--@param #string path 控制器加载路径
--@param #string moduleConfig 控制器所属模块
--@param #boolean isDelayInit 是否延时初始化，true在需要的时候再初始化，false，系统一运行就初始化
local function initController(moduleConfig, needDelayInit)
	local controllerInfo = moduleConfig.controllerInfo
	local path, isDelayInit = controllerInfo[1]
	if needDelayInit ~= nil then
		isDelayInit = needDelayInit
	else
		isDelayInit = controllerInfo[2]
	end

	local moduleName = moduleConfig.name
	if isDelayInit then
		GameController.delayMap[moduleName] = path
	else
		local controller = require(path).new(moduleConfig)
		print("initController", path, controller)
		GameController.controllerMap[moduleName] = controller
	end
end

local function getControllerInfo()
	local controllerInfo = {}
	for moduleName, info in pairs(ModuleConfig) do
		table.insert(
			controllerInfo,
			{
				info.controllerInfo
			}
		)
	end
end

function GameController.init()
	GameController.delayMap = {}
	GameController.controllerMap = {}

	--以下是：在系统运行时就初始化，除业务特殊外，都采用延迟初始化（用到了再去初始化）
	for moduleName, info in pairs(ModuleConfig) do
		initController(info)
	end
end

function GameController.getController(moduleConfig)
	local moduleName = moduleConfig.name
	local controller = GameController.controllerMap[moduleName]
	if not controller and GameController.delayMap[moduleName] then
		controller = initController(moduleConfig, false)
	end
	if not controller then
		printError("not controller name %s", moduleName)
		return
	end
		
	return controller
end

return GameController
