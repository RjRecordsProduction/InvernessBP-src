local AdvertisingWheelSubTab = {actId = nil}
local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
function AdvertisingWheelSubTab.ChackShow()
  local logic_advertisement_BlueHole = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_advertisement_BlueHole)
  return logic_advertisement_BlueHole:CheckCanGetAdvertisementData()
end
function AdvertisingWheelSubTab.GetSubTabTable()
  AdvertisingWheelSubTab.actId = nil
  if not AdvertisingWheelSubTab.ChackShow() then
    return nil
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actDataList = ActivityNewSystem.GetActivityByLabel(ActivitySwitchType.AdvertisingSpin)
  if not actDataList or not next(actDataList) then
    log(bWriteLog and "hhy not SubTabTable")
    return nil
  end
  local actData = actDataList[1]
  AdvertisingWheelSubTab.actId = actDataList[1].ID
  local TimeUtil = require("client.common.time_util")
  return {
    nActID = actData.ID,
    sName = actData.Title,
    bRedDot = AdvertisingWheelSubTab.GetRedDotData(),
    Order = actData.Order,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    DisplayScene = actData.DisplayScene,
    nStartTime = TimeUtil.GetServerTimeInSec()
  }
end
function AdvertisingWheelSubTab.GetRedDotData()
  local activityID = AdvertisingWheelSubTab.actId
  if not activityID then
    return false, ActivityMacros.RedDotType.None
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityData = ActivityNewSystem.GetServerDataByID(activityID)
  local actType = ActivityData.cfg.type
  local labelType = ActivityData.cfg.label_type
  local tableData = ActivityNewSystem.GetActivityByTypeAndLabel(actType, labelType)
  if tableData then
    for index = 1, #tableData.List do
      if tableData.List[index].Status == 1 then
        return true, ActivityMacros.RedDotType.Reward
      end
    end
  end
  local voucherId = 1703279
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemList = WardrobeData:GetHallDepotItemListByResIDValidExpireTime(voucherId)
  if ItemList and next(ItemList) then
    return true, ActivityMacros.RedDotType.Reward
  end
  local logic_advertisement_BlueHole = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_advertisement_BlueHole)
  local AD_macro = require("client.slua.logic.advertisement.AD_macro")
  local sceType = AD_macro.ENUM_SCENCE_TYPE.Wheel
  if logic_advertisement_BlueHole:CheckMaxWatchCountByScenceType(sceType) and logic_advertisement_BlueHole:CheckWatchTimeByScenceType(sceType) then
    return true, ActivityMacros.RedDotType.Normal
  end
  return false, ActivityMacros.RedDotType.None
end
function AdvertisingWheelSubTab.UpdateRedPoint()
  if not AdvertisingWheelSubTab.actId then
    return
  end
  local isUpdateRedPoint = AdvertisingWheelSubTab.GetRedDotData()
  log(bWriteLog and "hhy AdvertisingWheelSubTab.UpdateRedPoint isUpdateRedPoint = " .. tostring(isUpdateRedPoint))
  local changes = {
    idList = {
      [AdvertisingWheelSubTab.actId] = isUpdateRedPoint
    },
    typeList = {}
  }
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changes)
end
return AdvertisingWheelSubTab