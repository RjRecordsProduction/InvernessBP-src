local logicRightPopupModule = {}
local rightType = 102
function logicRightPopupModule:OnPostSwitchGameStatus(_, next)
  log(bWriteLog and "  : logicRightPopupModule:OnPostSwitchGameStatus" .. tostring(next))
  if next == GameStatus.Lobby then
    self:ShowPopup()
  end
end
local sortFunc = function(a, b)
  if not a.StartTime or not b.StartTime then
    return false
  end
  if a.Order == b.Order then
    if a.StartTime == b.StartTime then
      return a.ID < b.ID
    else
      return a.StartTime < b.StartTime
    end
  else
    return a.Order < b.Order
  end
end
function logicRightPopupModule:ShowPopup()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local TimeUtil = require("client.common.time_util")
  local TableUtil = require("common.table_util")
  local now = TimeUtil.GetServerTimeInSec()
  local acts = {}
  for _, activity in ipairs(ActivityNewSystem.data) do
    if activity.TabType == rightType and now > activity.StartTime and now < activity.EndTime then
      local status = TableUtil.GetTableValue(activity, "List", 1, "Status")
      if status == ActivityProgressStatus.Done then
        table.insert(acts, activity)
      end
    end
  end
  table.sort(acts, sortFunc)
  log(bWriteLog and "  : logicRightPopupModule #acts" .. tostring(#acts))
  for i, oneAct in ipairs(acts) do
    local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
    local jumpButton = {}
    function jumpButton.callback()
      GlobalData.JumpUrl(oneAct.ImgLink)
    end
    log(bWriteLog and "  :ShowPopup showUI " .. tostring(i))
    log_tree("oneAct", oneAct)
    local LobbyQueuePopUIKeyDefine = require("client.slua.config.LobbyQueuePopUIKeyDefine")
    local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
    local queueParam = ui_show_queue_config.GetParamTable(LobbyQueuePopUIKeyDefine.UIKey_Common_RightBottom_NoPic_UIBP_ActivityComplete)
    RightPopSystem.Common_RightBottom_NoPic_UIBP(oneAct.Title, oneAct.Desc, jumpButton, 10, nil, queueParam)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CBlack5Module = class(CModuleBase, nil, logicRightPopupModule)
return CBlack5Module