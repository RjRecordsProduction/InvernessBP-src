local NGConditionMsgBox = {}
function NGConditionMsgBox:ctor(selfType, Params)
end
function NGConditionMsgBox:CheckConditionOK(...)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  if CommonMsgBoxMgr:IsShowDataListEmpty() then
    return true
  end
  return false
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
return class(CObject, nil, NGConditionMsgBox)