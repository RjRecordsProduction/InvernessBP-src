local Notices_SubUI_UIBP = {}
function Notices_SubUI_UIBP:PushSeq()
  local ParentUI = self:GetParentUI()
  if not ParentUI then
    return
  end
  ParentUI:PushSeq()
end
function Notices_SubUI_UIBP:JumpUrl(noticeData)
  local ParentUI = self:GetParentUI()
  if not ParentUI then
    return
  end
  ParentUI:JumpUrl(noticeData)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
local CNotices_SubUI_UIBP = class(UIBase, nil, Notices_SubUI_UIBP)
return CNotices_SubUI_UIBP