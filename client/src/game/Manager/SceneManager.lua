--Author: mixi
--Date: 2016-05-28 00:11:51
--Abstract: SceneManager
local SceneManager = {
	scenesMap = {},
	curScene = false,
}

function SceneManager.getSceneByName(sceneName)
	local scene = SceneManager.scenesMap[sceneName]
	if not scene then
		scene = display.newScene(sceneName)
		SceneManager.scenesMap[sceneName] = scene
	end
	return scene
end

function SceneManager.replaceScene(scene, sceneName)
	if SceneManager.curScene then
		display.runScene(scene)
		SceneManager.scenesMap[sceneName] = scene
	else
		display.runScene(scene)
		SceneManager.scenesMap[sceneName] = nil
		SceneManager.curScene = scene
	end
end

function SceneManager.getCurScene()
	return SceneManager.curScene
end

return SceneManager
