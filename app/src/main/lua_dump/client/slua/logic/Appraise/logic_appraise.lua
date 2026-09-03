local AppraiseSystem = {
  canShow = false,
  lastPopTime = 0,
  hasEvaluated = false,
  hasInit = false
}
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local TimeUtil = require("client.common.time_util")
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local APPRAISE_POP_INTERVAL_DAYS = 14
function AppraiseSystem.OnLogin()
  log(bWriteLog and "AppraiseSystem.OnLogin")
  AppraiseSystem.Init()
end
function AppraiseSystem.Init()
  log(bWriteLog and "AppraiseSystem.Init")
  if AppraiseSystem.hasInit then
    log(bWriteLog and "AppraiseSystem.Init hasInit")
    return
  end
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAppraiseData)
  if data and type(data) == "table" then
    AppraiseSystem.lastPopTime = data.lastPopTime or 0
    AppraiseSystem.hasEvaluated = data.hasEvaluated or false
    log(bWriteLog and "AppraiseSystem.Init lastPopTime:" .. tostring(AppraiseSystem.lastPopTime) .. " hasEvaluated:" .. tostring(AppraiseSystem.hasEvaluated))
  else
    log(bWriteLog and "AppraiseSystem.Init no saved data, using default values")
  end
  AppraiseSystem.waitPopSceneAppraise = nil
  AppraiseSystem.hasInit = true
end
function AppraiseSystem.SaveData()
  log(bWriteLog and "AppraiseSystem.SaveData")
  local data = {
    lastPopTime = AppraiseSystem.lastPopTime,
    hasEvaluated = AppraiseSystem.hasEvaluated
  }
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eAppraiseData)
  log(bWriteLog and "AppraiseSystem.SaveData lastPopTime:" .. tostring(AppraiseSystem.lastPopTime) .. " hasEvaluated:" .. tostring(AppraiseSystem.hasEvaluated))
end
function AppraiseSystem.HasPop()
  if not PublishRegionMacros.IsBLUEHOLE() then
    log(bWriteLog and "AppraiseSystem.HasPop not Bluehole version, return false")
    return false
  end
  local currentTime = TimeUtil.GetServerTimeInSec()
  local timeDiff = currentTime - AppraiseSystem.lastPopTime
  local daysDiff = timeDiff / 86400
  local hasPop = daysDiff < APPRAISE_POP_INTERVAL_DAYS
  log(bWriteLog and "AppraiseSystem.HasPop currentTime:" .. tostring(currentTime) .. " lastPopTime:" .. tostring(AppraiseSystem.lastPopTime) .. " daysDiff:" .. tostring(daysDiff) .. " hasPop:" .. tostring(hasPop))
  return hasPop
end
function AppraiseSystem.HasEvaluate()
  if not PublishRegionMacros.IsBLUEHOLE() then
    log(bWriteLog and "AppraiseSystem.HasEvaluate not Bluehole version, return false")
    return false
  end
  log(bWriteLog and "AppraiseSystem.HasEvaluate hasEvaluated:" .. tostring(AppraiseSystem.hasEvaluated))
  return AppraiseSystem.hasEvaluated
end
function AppraiseSystem.RecordPopTime()
  AppraiseSystem.lastPopTime = TimeUtil.GetServerTimeInSec()
  AppraiseSystem.SaveData()
  log(bWriteLog and "AppraiseSystem.RecordPopTime lastPopTime:" .. tostring(AppraiseSystem.lastPopTime))
end
function AppraiseSystem.RecordEvaluated()
  AppraiseSystem.hasEvaluated = true
  AppraiseSystem.SaveData()
  log(bWriteLog and "AppraiseSystem.RecordEvaluated hasEvaluated:" .. tostring(AppraiseSystem.hasEvaluated))
end
function AppraiseSystem.OnNotifyAppraise(scene_id, localization_id, finish_count, ext_info)
  log(bWriteLog and "AppraiseSystem.OnNotifyAppraise")
  AppraiseSystem.Init()
  if Client.GetPublishRegion() == PublishRegionMacros.JAPAN then
    log(bWriteLog and "AppraiseSystem.OnNotifyAppraise, Japan never popup the dialog.")
    return
  end
  if GlobalData.IsIOSCheck() == true then
    log(bWriteLog and "AppraiseSystem.OnNotifyAppraise, App Store Review State.")
    return
  end
  if AppraiseSystem.HasPop() then
    log(bWriteLog and "AppraiseSystem.OnNotifyAppraise, Has popped in 14 days.")
    return
  end
  if AppraiseSystem.HasEvaluate() then
    log(bWriteLog and "AppraiseSystem.OnNotifyAppraise, Has evaluated.")
    return
  end
  local status = GameStatus.GetGameStatus()
  log(bWriteLog and "AppraiseSystem.OnNotifyAppraise. status = " .. tostring(status))
  if status == GameStatus.Login then
    AppraiseSystem.SetCanShow(false)
  else
    AppraiseSystem.SetCanShow(true)
  end
  AppraiseSystem.appraiseInfo = {
    scene_id,
    localization_id,
    finish_count,
    ext_info
  }
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_POST_SWITCH_SHOW_APP_RAISE_POPUP)
end
function AppraiseSystem.OnModePostSwitch(preState, nextState)
end
function AppraiseSystem.SetCanShow(canShow)
  log(bWriteLog and "AppraiseSystem.SetCanShow canShow:" .. tostring(canShow))
  AppraiseSystem.end
function AppraiseSystem.TryShowAppRaiseUI()
  if not AppraiseSystem.canShow then
    log(bWriteLog and "AppraiseSystem.TryShowAppRaiseUI not canShow")
    return
  end
  local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
  local needUpdateRole = newbieGuideManager.NeedUpdateRole()
  if needUpdateRole then
    log(bWriteLog and "AppraiseSystem.TryShowAppRaiseUI role needUpdateRole")
    return
  end
  AppraiseSystem.ShowAppRaiseUI(AppraiseSystem.appraiseInfo[1], AppraiseSystem.appraiseInfo[2], AppraiseSystem.appraiseInfo[3], AppraiseSystem.appraiseInfo[4])
end
function AppraiseSystem.ShowAppRaiseUI(scene_id, localization_id, finish_count, ext_info)
  log(bWriteLog and "AppraiseSystem.ShowAppRaiseUI")
  AppraiseSystem.RecordPopTime()
  local text
  if localization_id and ext_info and ext_info.item_id then
    local itemData = CDataTable.GetTableData("Item", tonumber(ext_info.item_id))
    text = LocUtil.LocalizeResFormat(localization_id, itemData.ItemName)
  elseif localization_id then
    text = LocUtil.GetLocalizeResStr(localization_id)
  end
  UIManager.ShowUI(UIManager.UI_Config.Appstore_AppRaise, text, scene_id)
end
return AppraiseSystem