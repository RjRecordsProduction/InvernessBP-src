local draw_trun = {}
local Static = {lable_type = 10}
local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
function draw_trun.GetDrawTurntable()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local DrawTurntableData = ActivityNewSystem.GetActivityByTypeAndLabel(Static.lable_type, ActivitySwitchType.DrawTurn)
  if not DrawTurntableData then
    log(bWriteLog and "[jinqiang] not DrawTurntableData")
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  return {
    nActID = ActivityFixedID.Draw_Turntable,
    sName = DrawTurntableData.Title,
    bRedDot = draw_trun.GetRedDotData,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    DisplayScene = DrawTurntableData.DisplayScene,
    nStartTime = TimeUtil.GetServerTimeInSec()
  }
end
function draw_trun.GetRedDotData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local DrawTurntableData = ActivityNewSystem.GetActivityByTypeAndLabel(Static.lable_type, ActivitySwitchType.DrawTurn)
  if DrawTurntableData then
    for index = 1, #DrawTurntableData.List do
      if DrawTurntableData.List[index].Status == 1 then
        return true, ActivityMacros.RedDotType.Reward
      end
    end
  end
  local voucherId = 3901084
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemList = WardrobeData:GetHallDepotItemListByResIDValidExpireTime(voucherId)
  if ItemList and next(ItemList) then
    return true, ActivityMacros.RedDotType.Reward
  end
  return false, ActivityMacros.RedDotType.None
end
function draw_trun.UpdateRedPoint()
  local isUpdateRedPoint = draw_trun.GetRedDotData()
  local changes = {
    idList = {
      [ActivityFixedID.Draw_Turntable] = isUpdateRedPoint
    },
    typeList = {}
  }
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changes)
end
return draw_trun