local BindFaceBookSystem = {
  activityId = 0,
  subActId1 = 0,
  subActIndex1 = 0,
  itemID1 = 0,
  itemID2_1 = 0,
  itemID2_2 = 0,
  status1 = 0,
  status2 = 0,
  off_rate = 0,
  price = 0,
  origin_price = 0,
  actBeginTime = 0,
  leftTime = 0,
  IsNoData = false,
  IsTimeUp = false,
  isCheckRed = false
}
local BindPlatfrom = ""
local RewardNum = ""
function BindFaceBookSystem.SetBindPlatfrom(plat)
  BindPlatfrom = plat or ""
end
function BindFaceBookSystem.GetBindPlatfrom()
  return BindPlatfrom
end
function BindFaceBookSystem.SetBindRewardNum()
  RewardNum = CDataTable.GetTableData("SystemConfig", "AccountBindingAward").ConfigValue
end
function BindFaceBookSystem.GetBindRewardNum()
  return BindPlatfrom
end
function BindFaceBookSystem.RegistEventByActChange()
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, BindFaceBookSystem.OnActivityDataChanged)
end
function BindFaceBookSystem.UnRegistEventActChange()
  EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, BindFaceBookSystem.OnActivityDataChanged)
end
function BindFaceBookSystem.OnActivityDataChanged(eventType, eventID, act_change_list)
  if act_change_list and act_change_list.typeList then
    for actType, _ in pairs(act_change_list.typeList) do
      if actType ~= ActivityType.BIND_SEND_GIFT then
        return
      end
    end
  end
  local isShow = BindFaceBookSystem.CheckRedPoint()
  local Logic_Activity_Center = require("client.slua.logic.activity.logic_activity_center")
  local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
  local RedDotType = isShow and ActivityMacros.RedDotType.Reward or ActivityMacros.RedDotType.None
  Logic_Activity_Center.AddCenterRedDotForImage(BP_ENUM_MODULE_BIND_FACEBOOK, true, isShow, RedDotType)
end
function BindFaceBookSystem.SetLeftTime(time)
  BindFaceBookSystem.leftTime = time
end
function BindFaceBookSystem.GetLeftTime()
  return BindFaceBookSystem.leftTime or 0
end
function BindFaceBookSystem.OpenUIByJump()
  BindFaceBookSystem.SetBindRewardNum()
  BindFaceBookSystem.ShowUI()
  BindFaceBookSystem.isCheckRed = false
end
function BindFaceBookSystem.ShowUI()
  UIManager.ShowUI(UIManager.UI_Config.activity_bind_facebook)
end
function BindFaceBookSystem.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby then
    local timeIndex = 0
    local time_ticker = require("common.time_ticker")
    timeIndex = time_ticker.AddTimerOnce(2.5, function()
      if BindFaceBookSystem.IsExistAct() then
        log(bWriteLog and "[bgp] BindFaceBookSystem:OnModePostSwitch")
        BindFaceBookSystem.RefreshBindData()
        BindFaceBookSystem.StructCentauriDataByActData()
        BindFaceBookSystem.SetActShowStatus()
        BindFaceBookSystem.RegistEventByActChange()
        BindFaceBookSystem.isCheckRed = true
        return
      end
    end)
  elseif nextState == GameStatus.Login then
    BindFaceBookSystem.UnRegistEventActChange()
    BindFaceBookSystem.ClearBindFacebookData()
  elseif GameStatus.IsInFightingNotMainCity() then
    BindFaceBookSystem.UnRegistEventActChange()
    BindFaceBookSystem.ClearBindFacebookData()
  end
end
function BindFaceBookSystem.RefreshBindData()
  local bindType = ActivityType.BIND_SEND_GIFT
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityListByType(bindType)
  for _, activity in ipairs(activityData) do
    BindFaceBookSystem.activityId = activity.ID
    BindFaceBookSystem.actBeginTime = activity.StartTime
    for k, v in ipairs(activity.List) do
      if v.Index == 1 then
        BindFaceBookSystem.status1 = v.Status
        BindFaceBookSystem.subActId1 = v.ID
        BindFaceBookSystem.subActIndex        if v.Drop and v.Drop[1].itemId then
          BindFaceBookSystem.itemID1 = v.Drop[1].itemId
        end
      end
      if v.Index == 2 then
        BindFaceBookSystem.status2 = v.Status
      end
    end
    if activity.other == nil then
      BindFaceBookSystem.SetLeftTime(-1)
      break
    end
    if activity.other.bind_activity_expire_time == nil then
      BindFaceBookSystem.SetLeftTime(-1)
      break
    end
    do
      local TimeUtil = require("client.common.time_util")
      local time = activity.other.bind_activity_expire_time - TimeUtil.GetServerTimeInSec()
      BindFaceBookSystem.SetLeftTime(time)
    end
    break
  end
end
function BindFaceBookSystem.IsExistAct()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityByType(ActivityType.BIND_SEND_GIFT)
  if activityData then
    return true
  end
  return false
end
function BindFaceBookSystem.StructCentauriDataByActData()
  if BindFaceBookSystem.itemID1 ~= 0 and BindFaceBookSystem.activityId and BindFaceBookSystem.activityId ~= 0 then
    local AccountHandler = require("client.network.Protocol.AccountHandler")
    AccountHandler.send_get_account_link_info_req(BindFaceBookSystem.activityId)
  end
end
function BindFaceBookSystem.SetActShowStatus()
  if BindFaceBookSystem.itemID1 == 0 or BindFaceBookSystem.activityId == 0 then
    BindFaceBookSystem.IsTimeUp = true
    BindFaceBookSystem.IsNoData = true
  else
    BindFaceBookSystem.IsTimeUp = false
    BindFaceBookSystem.IsNoData = false
  end
end
function BindFaceBookSystem.get_account_link_info_rsp(data)
  log_tree(bWriteLog and "[bgp] get_account_link_info_rsp:", data)
  if not data or not next(data) then
    return
  end
  BindFaceBookSystem.itemID2_1 = data.rewards.items[1]
  BindFaceBookSystem.itemID2_2 = data.rewards.items[2]
  BindFaceBookSystem.off_rate = data.rewards.off_rate
  BindFaceBookSystem.price = data.rewards.price
  BindFaceBookSystem.origin_price = data.rewards.origin_price
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_BIND_FACE)
  if BindFaceBookSystem.isCheckRed then
    local isShow = BindFaceBookSystem.CheckRedPoint()
    LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_BIND_FACEBOOK, isShow)
    local Logic_Activity_Center = require("client.slua.logic.activity.logic_activity_center")
    local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
    local RedDotType = isShow and ActivityMacros.RedDotType.Reward or ActivityMacros.RedDotType.None
    Logic_Activity_Center.AddCenterRedDotForImage(BP_ENUM_MODULE_BIND_FACEBOOK, true, isShow, RedDotType)
  end
  if BindFaceBookSystem.status1 == 2 and BindFaceBookSystem.status2 == 2 then
    LobbySystem.refresh_activity_display_byCentauri()
  end
end
local Platform2Channel = {
  [ShareSource.Facebook] = BP_ENUM_IMSDK_CHANNEL_FACEBOOK,
  [ShareSource.GameCenter] = BP_ENUM_IMSDK_CHANNEL_GAMECENTER,
  [ShareSource.GooglePlay] = BP_ENUM_IMSDK_CHANNEL_GOOGLEPLAY,
  [ShareSource.Noschat] = BP_ENUM_IMSDK_CHANNEL_NOSCHAT,
  [ShareSource.VK] = BP_ENUM_IMSDK_CHANNEL_VK,
  [ShareSource.Twitter] = BP_ENUM_IMSDK_CHANNEL_TWITTER,
  [ShareSource.Line] = BP_ENUM_IMSDK_CHANNEL_LINE,
  [ShareSource.BgBg] = BP_ENUM_IMSDK_CHANNEL_BGBG,
  [ShareSource.Apple] = BP_ENUM_IMSDK_CHANNEL_APPLE,
  [ShareSource.Discord] = BP_ENUM_IMSDK_CHANNEL_DISCORD,
  [ShareSource.Whatsapp] = BP_ENUM_IMSDK_CHANNEL_WHATS,
  [ShareSource.TikTok] = BP_ENUM_IMSDK_CHANNEL_TIKTOK
}
function BindFaceBookSystem.SetBindChannelData()
  local SettingSystem = require("client.logic.setting.logic_setting")
  SettingSystem.NBindChannel = Platform2Channel[BindPlatfrom]
end
function BindFaceBookSystem.IsLinked()
  return Client.GetLoginChannel(NetInterface) == BP_ENUM_PLAYFORM_TOURIST
end
function BindFaceBookSystem.IsShowDisplayActivity()
  if BindFaceBookSystem.status1 == 2 and BindFaceBookSystem.status2 == 2 or BindFaceBookSystem.IsTimeUp or BindFaceBookSystem.IsNoData == true then
    return false
  else
    return true
  end
end
function BindFaceBookSystem.CheckRedPoint()
  local clickBindTime, cliclNotBindTime = BindFaceBookSystem.GetBindTimeAndNotBindTime()
  local isLinked = BindFaceBookSystem.IsLinked()
  local isShow = BindFaceBookSystem.HasRedPoint(clickBindTime, cliclNotBindTime, BindFaceBookSystem.actBeginTime, isLinked) or false
  log(bWriteLog and "bgp BindFaceBookSystem.CheckRedPoint = " .. tostring(isShow))
  return isShow
end
function BindFaceBookSystem.GetBindTimeAndNotBindTime()
  local clickTimeNotBind = 0
  local clickTimeBind = 0
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBindFaceBook)
  if saveData then
    clickTimeNotBind = saveData.timeNotBind
    clickTimeBind = saveData.timeBind
  end
  return clickTimeNotBind, clickTimeBind
end
function BindFaceBookSystem.HasRedPoint(time_not_bind, time_bind, act_begin_time, isLinked)
  if isLinked == false then
    if time_not_bind and act_begin_time and time_not_bind < act_begin_time then
      if BindFaceBookSystem.status1 ~= 1 then
        return false
      end
      local TimeUtil = require("client.common.time_util")
      local now = TimeUtil.GetServerTimeInSec()
      if now > act_begin_time + 259200 and BindFaceBookSystem.status1 ~= 1 then
        return false
      end
      return true
    else
      return false
    end
  elseif time_bind and time_bind < act_begin_time then
    if BindFaceBookSystem.status1 ~= 1 then
      return false
    end
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    if now > act_begin_time + 259200 and BindFaceBookSystem.status1 ~= 1 then
      return false
    end
    return true
  else
    if BindFaceBookSystem.status1 == 1 then
      return true
    end
    return false
  end
end
function BindFaceBookSystem.ClickActEnterance()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local actBeginTime = BindFaceBookSystem.actBeginTime
  local isLinked = BindFaceBookSystem.isLinked
  local timeNotBind = 0
  local timeBind = 0
  log(bWriteLog and "bgp actBeginTime = " .. actBeginTime .. ",timeNotBind = " .. timeNotBind .. ", timeBind = " .. timeBind .. ", curTime = " .. curTime)
  local hasChange = false
  if isLinked == false then
    timeNotBind = curTime
    hasChange = true
  else
    timeBind = curTime
    hasChange = true
  end
  if hasChange == true then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBindFaceBook) or {}
    saveData.    saveData.    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eBindFaceBook)
  end
  local isShow = BindFaceBookSystem.CheckRedPoint()
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_BIND_FACEBOOK, isShow)
  local Logic_Activity_Center = require("client.slua.logic.activity.logic_activity_center")
  local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
  local RedDotType = isShow and ActivityMacros.RedDotType.Reward or ActivityMacros.RedDotType.None
  Logic_Activity_Center.AddCenterRedDotForImage(BP_ENUM_MODULE_BIND_FACEBOOK, true, isShow, RedDotType)
end
function BindFaceBookSystem.GetAwardBySendReq()
  if BindFaceBookSystem.status1 ~= 1 then
    return
  end
  if BindFaceBookSystem.subActId1 == nil or BindFaceBookSystem.subActId1 == 0 then
    return
  end
  if BindFaceBookSystem.subActIndex1 == nil or BindFaceBookSystem.subActIndex1 == 0 then
    return
  end
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  ActivityHandler.send_take_activity_award_req(BindFaceBookSystem.subActId1, BindFaceBookSystem.subActIndex1, 1)
end
function BindFaceBookSystem.ClearBindFacebookData()
  BindFaceBookSystem.activityId = 0
  BindFaceBookSystem.subActId1 = 0
  BindFaceBookSystem.subActIndex1 = 0
  BindFaceBookSystem.itemID1 = 0
  BindFaceBookSystem.itemID2_1 = 0
  BindFaceBookSystem.itemID2_2 = 0
  BindFaceBookSystem.status1 = 0
  BindFaceBookSystem.status2 = 0
  BindFaceBookSystem.off_rate = 0
  BindFaceBookSystem.price = 0
  BindFaceBookSystem.origin_price = 0
  BindFaceBookSystem.actBeginTime = 0
  BindFaceBookSystem.leftTime = 0
  BindFaceBookSystem.isCheckRed = false
  BindFaceBookSystem.IsTimeUp = false
  BindFaceBookSystem.IsNoData = false
end
return BindFaceBookSystem