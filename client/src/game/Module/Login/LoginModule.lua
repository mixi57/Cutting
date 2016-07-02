--Author: mixi
--Date: 2016-05-28 01:03:48
--Abstract: LoginModule
local LoginModule = class("LoginModule", View)--cc.load("mvc").ViewBase)

-- 主csb文件
LoginModule.RESOURCE_FILENAME = "LoginScene.csb"
-- 处理点击事件
local MainSceneEvents = {
    ["logInBtn"] = {
        ["varname"] = "_logInBtn",
        ["events"] = {
            {
                ["event"] = "touch",
                ["method"] = "loginCallBack"
            },
        }
    },
    ["resignBtn"] = {
        ["varname"] = "_regisnBtn",
        ["events"] = {
            {
                ["event"] = "touch",
                ["method"] = "resignCallBack"
            },
        }
    },
}
LoginModule.RESOURCE_BINDING = MainSceneEvents

-- LoginModule.RESOURCE_INFO = {
--     -- "LoginScene.csb" = {}--MainSceneEvents
--     {LoginModule.RESOURCE_FILENAME, LoginModule.RESOURCE_BINDING}
-- }

local function addReleaseEvent(event, callback, params)
    if event.name == "ended" then
        callback(params)
    end
end
function LoginModule:loginCallBack(params, event)
    local callback = function()
        print("点击登陆按钮")
        GameManager.openModule(ModuleConfig.ROOM)
        print("点击注册按钮 2")
    end
    addReleaseEvent(event, callback, params)
end
function LoginModule:resignCallBack(params, event)
    addReleaseEvent(
        event, 
        function()
            print("点击注册按钮")
        end,
        params
    )
end

function LoginModule:initView()
    -- self:show()
    local btn = UI.newButton({
        text = "",
        x = 500,
        y = 500,
        parent = self,
    })
    btn:addTouchEventListener(function()
        GameManager.openModule(ModuleConfig.MAIN)
    end)
    
end

return LoginModule
