local Collect_UI_Base = {}
function Collect_UI_Base:OnInitialize()
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyCamera(false)
end
function Collect_UI_Base:OnClose()
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyCamera(true)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCollect_Milestone_UIBP = class(ui_base, nil, Collect_UI_Base)
return CCollect_Milestone_UIBP