--Author: mixi
--Date: 2016-05-29 14:40:40
--Abstract: View
local View = class("View", cc.Node)
function View:ctor()
    self._targetNode = false
	self:enableNodeEvents()
end

function View:initView()
	error("View:Need override initView function")
end

function View:createResouece(res, binding)
    local targetNode
    print("createResouece", res)
    if res then
        targetNode = ViewUtil.createResoueceNode(res, self)
    end

    if res and binding then
        -- print("View:createResouece ", res, " ", binding)
        -- for i, v in pairs(binding) do
        --     if type(v) == "table" then
        --         for ii, vv in pairs(v) do
        --             print(ii, vv)
        --         end
        --     end
        -- end
        ViewUtil.createResoueceBinding(binding, self, targetNode)
    end
    self._targetNode = targetNode
end

function View:show()
	local resInfo = rawget(self.class, "RESOURCE_INFO")
    for _, info in pairs(resInfo) do
        self:createResouece(info[1], info[2])
    end
end

return View