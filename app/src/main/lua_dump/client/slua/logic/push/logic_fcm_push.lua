local FCMPushSystem = {
  isOpen = 0,
  info_list = {},
  need_set_list = {},
  callBackTimer = nil
}
function FCMPushSystem.OnLogin()
  local platName = Client.GetDevicePlatformName()
  log(bWriteLog and "FCMPushSystem.OnLogin platName:" .. platName)
  local time_ticker = require("common.time_ticker")
  local ConstPush = require("client.slua.logic.push.ConstPush")
  time_ticker.AddTimerOnce(ConstPush.START_FCM_PUSH_LATER_SECONDS, function()
    local FCMPushHandler = require("client.network.Protocol.FCMPushHandler")
    FCMPushHandler.send_get_fcm_info_req()
  end)
  FCMPushSystem.ReportGoogleServiceVersionCode()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if not login_module.ClientBasicCfg then
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(1, function()
      FCMPushSystem.ReportRemoteNotificationSwitchStatus()
    end)
  else
    FCMPushSystem.ReportRemoteNotificationSwitchStatus()
  end
  time_ticker.AddTimerOnce(3, function()
    local logic_setting_notify = require("client.logic.setting.logic_setting_notify")
    logic_setting_notify.ProcessOnlinePush()
  end)
end
function FCMPushSystem.on_get_fcm_info_rsp(isOpen, info_list)
  FCMPushSystem.  FCMPushSystem.  if not FCMPushSystem.isOpen then
    return
  end
  FCMPushSystem.UpdateSetInfo()
end
function FCMPushSystem.UpdateSetInfo()
  log(bWriteLog and "FCMPushSystem.UpdateSetInfo")
  FCMPushSystem.GetNeedSetList()
  for _, v in pairs(FCMPushSystem.need_set_list) do
    if v.key < 50000 then
      Client.SetUserProperty(v.fcm_key, tostring(v.value))
      v.callback = 1
    else
      v.callback = 1
      if v.value == 1 then
        Client.SubscribeToTopic(v.fcm_key)
      else
        Client.UnsubscribeFromTopic(v.fcm_key)
      end
    end
  end
  local time_ticker = require("common.time_ticker")
  FCMPushSystem.callBackTimer = time_ticker.AddTimerOnce(1, function()
    FCMPushSystem.SendSetInfoReq(true)
  end)
end
function FCMPushSystem.SendSetInfoReq(foreAllSend)
  log(bWriteLog and "FCMPushSystem.UpdateSetInfo")
  local send_list = {}
  local iNum = 0
  if FCMPushSystem.need_set_list then
    for _, v in pairs(FCMPushSystem.need_set_list) do
      if v.callback == 1 then
        v.key = tonumber(v.key)
        send_list[v.key] = tonumber(v.value)
        iNum = iNum + 1
      end
    end
  end
  if 0 < iNum and (iNum == #FCMPushSystem.need_set_list or foreAllSend) then
    local FCMPushHandler = require("client.network.Protocol.FCMPushHandler")
    FCMPushHandler.send_set_fcm_info_req(send_list)
  end
end
function FCMPushSystem.GetFCMInfoByKey(key)
  if FCMPushSystem.info_list then
    for i, v in pairs(FCMPushSystem.info_list) do
      if i == key then
        return {key = i, value = v}
      end
    end
  end
  return nil
end
function FCMPushSystem.GetNeedSetList()
  FCMPushSystem.need_set_list = {}
  local ConstPush = require("client.slua.logic.push.ConstPush")
  for _, v in pairs(ConstPush.FCM_KEY_DEFINE) do
    local fcmInfo = FCMPushSystem.GetFCMInfoByKey(v.key)
    local value = FCMPushSystem.GetValueByFCMKey(v.fcm_key)
    if value ~= nil and (fcmInfo == nil or fcmInfo ~= nil and fcmInfo.value ~= value) then
      table.insert(FCMPushSystem.need_set_list, {
        key = v.key,
        fcm_key = v.fcm_key,
        value = value,
        callback = 0
      })
    end
  end
end
function FCMPushSystem.GetValueByFCMKey(fcm_key)
  if fcm_key == "user_level" then
    return DataMgr.roleData.level
  elseif fcm_key == "pass_level" then
    return UnknowPassSystem.Level
  elseif fcm_key == "jk_push_switch" or fcm_key == "jk_push_night_switch" then
    local strRegion = Client.GetPublishRegion()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsJapanOrKorea() or strRegion == PublishRegionMacros.CE or strRegion == PublishRegionMacros.FITCE then
      local IntlHelper = import("IntlHelper")
      local bSysOpen = IntlHelper.IsRemoteNotificationsEnabled()
      if fcm_key == "jk_push_switch" then
        if bSysOpen then
          return 1
        else
          return 0
        end
      elseif fcm_key == "jk_push_night_switch" then
        local strNightTag = IntlHelper.GetSavedXGPushNightTag()
        if bSysOpen then
          if strNightTag == "night_on" then
            return 1
          else
            return 0
          end
        else
          if strNightTag == "night_on" then
            IntlHelper.UpdateXGPushNightTag(false)
          end
          return 0
        end
      end
    end
  elseif fcm_key == "client_version" then
    return FCMPushSystem.GetAppMaxVersion()
  end
  return nil
end
function FCMPushSystem.OnSubscribeToTopicSuccess(topic, _)
  if FCMPushSystem.need_set_list then
    for _, v in pairs(FCMPushSystem.need_set_list) do
      if v.fcm_key == topic then
        v.callback = 1
        break
      end
    end
    FCMPushSystem.SendSetInfoReq()
  end
end
function FCMPushSystem.ReportRemoteNotificationSwitchStatus()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if not login_module then
    log(bWriteLog and "FCMPushSystem.ReportRemoteNotificationSwitchStatus skip to report for config is nil")
    return
  end
  local isReportEnable = login_module.ClientBasicCfg and login_module.ClientBasicCfg.ReportRemoteNotificationSwitchStatus or false
  if not isReportEnable then
    log(bWriteLog and "FCMPushSystem.ReportRemoteNotificationSwitchStatus switch is close skip to report")
    return
  end
  local hasRecordToday = FCMPushSystem.HasRecordTodayForKey("ReportRemoteNotificationSwitchStatus")
  if hasRecordToday then
    log(bWriteLog and "FCMPushSystem.ReportRemoteNotificationSwitchStatus has record and skip to report")
    return
  end
  FCMPushSystem.SetupRecordTodayForKey("ReportRemoteNotificationSwitchStatus")
  log(bWriteLog and "FCMPushSystem.ReportRemoteNotificationSwitchStatus do report")
  local eventParam = {}
  local IntlHelper = import("IntlHelper")
  local isRemoteNotificationsEnabled = IntlHelper.IsRemoteNotificationsEnabled()
  if isRemoteNotificationsEnabled then
    table.insert(eventParam, "1")
  else
    table.insert(eventParam, "0")
  end
  Client.GEMReportSubEvent(GameFrontendHUD, "FCMNotification", "isRemoteNotificationsEnabled", eventParam)
  log(bWriteLog and "FCMPushSystem.ReportRemoteNotificationSwitchStatus Done")
end
function FCMPushSystem.ReportGoogleServiceVersionCode()
  local platName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if platName == DevicePlatformNameMacros.Android then
    local hasRecordToday = FCMPushSystem.HasRecordTodayForKey("ReportGoogleServiceVersionCode")
    if hasRecordToday then
      log(bWriteLog and "FCMPushSystem.ReportGoogleServiceVersionCode has record skip to report")
      return
    end
    FCMPushSystem.SetupRecordTodayForKey("ReportGoogleServiceVersionCode")
    local eventParam = {}
    local googleServiceVersionCode = Client.GetGoogleServiceVersionCode()
    if nil == googleServiceVersionCode or "" == googleServiceVersionCode then
      googleServiceVersionCode = 0
    end
    table.insert(eventParam, tostring(googleServiceVersionCode))
    Client.GEMReportSubEvent(GameFrontendHUD, "FCMNotification", "googleServiceVersionCode", eventParam)
  end
  log(bWriteLog and "FCMPushSystem.ReportGoogleServiceVersionCode Done")
end
function FCMPushSystem.HasRecordTodayForKey(key)
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  local localStoreDic = LogicPlayerPrefs.LoadFileToData_N(PlayerPrefsConfig.eDefault)
  local lastReportTime
  if localStoreDic and localStoreDic[key] then
    lastReportTime = localStoreDic[key]
    log(bWriteLog and "FCMPushSystem.HasRecordTodayForKey" .. tostring(lastReportTime))
  end
  local TimeUtil = require("client.common.time_util")
  local tNow = TimeUtil.OSDate("*t", TimeUtil.GetServerTimeInSec())
  local strToday = string.format("%02d%02d%02d", tNow.year, tNow.month, tNow.day)
  if lastReportTime ~= nil and lastReportTime ~= "" and lastReportTime == strToday then
    return true
  else
    return false
  end
end
function FCMPushSystem.SetupRecordTodayForKey(key)
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  local TimeUtil = require("client.common.time_util")
  local tNow = TimeUtil.OSDate("*t", TimeUtil.GetServerTimeInSec())
  local strToday = string.format("%02d%02d%02d", tNow.year, tNow.month, tNow.day)
  local localStoreDic = LogicPlayerPrefs.LoadFileToData_N(PlayerPrefsConfig.eDefault)
  if localStoreDic == nil then
    localStoreDic = {}
  end
  localStoreDic[key] = strToday
  LogicPlayerPrefs.SaveDataToFile_N(localStoreDic, PlayerPrefsConfig.eDefault)
end
function FCMPushSystem.GetRecordOfTodayByKey(key)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local localStoreDic = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eOnlineNotify)
  log_tree("FCMPushSystem.GetRecordOfTodayByKey ", localStoreDic)
  if not localStoreDic then
    log(bWriteLog and " FCMPushSystem.GetRecordOfTodayByKey no localStoreDic")
    return false
  end
  local saved = localStoreDic[key]
  if not saved then
    log(bWriteLog and " FCMPushSystem.GetRecordOfTodayByKey no saved. key:" .. key)
    return false
  end
  local lastReportTime = saved.lastReportTime
  if not lastReportTime then
    log(bWriteLog and " FCMPushSystem.GetRecordOfTodayByKey no lastReportTime")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local tNow = TimeUtil.OSDate("*t", TimeUtil.GetServerTimeInSec())
  local strToday = string.format("%02d%02d%02d", tNow.year, tNow.month, tNow.day)
  printf(" FCMPushSystem.GetRecordOfTodayByKey lastReportTime:%s, strToday:%s, todayCount:%s", lastReportTime, strToday, saved.todayCount)
  if lastReportTime ~= nil and lastReportTime ~= "" and lastReportTime == strToday then
    return true, saved.todayCount
  else
    return false
  end
end
function FCMPushSystem.SetRecordOfTodayByKey(key)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local hasToday, todayCount = FCMPushSystem.GetRecordOfTodayByKey(key)
  if hasToday then
    local localStoreDic = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eOnlineNotify)
    local saved = localStoreDic[key]
    saved.todayCount = todayCount + 1
    PlayerPrefsSystem.SaveTableToFile_N(localStoreDic, PlayerPrefsSystem.ePlayerPrefsType.eOnlineNotify)
    log(bWriteLog and string.format(" FCMPushSystem.SetRecordOfTodayByKey hasToday true key:%s, todayCount:%s", key, todayCount + 1))
  else
    local TimeUtil = require("client.common.time_util")
    local tNow = TimeUtil.OSDate("*t", TimeUtil.GetServerTimeInSec())
    local strToday = string.format("%02d%02d%02d", tNow.year, tNow.month, tNow.day)
    local localStoreDic = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eOnlineNotify) or {}
    localStoreDic[key] = {lastReportTime = strToday, todayCount = 1}
    PlayerPrefsSystem.SaveTableToFile_N(localStoreDic, PlayerPrefsSystem.ePlayerPrefsType.eOnlineNotify)
    log(bWriteLog and string.format(" FCMPushSystem.SetRecordOfTodayByKey hasToday false key:%s", key))
  end
end
function FCMPushSystem.OnApplicationEnterBackground()
end
function FCMPushSystem.OnApplicationEnterForeground()
  log(bWriteLog and "FCMPushSystem.OnApplicationEnterForeground")
  if FCMPushSystem.isOpen then
    local strRegion = Client.GetPublishRegion()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if (PublishRegionMacros.IsJapanOrKorea() or strRegion == PublishRegionMacros.CE or strRegion == PublishRegionMacros.FITCE) and UIManager.IsUIShow(UIManager.UI_Config.setting_main) then
      local SettingSystem = require("client.logic.setting.logic_setting")
      FCMPushSystem.UpdateSetInfo()
      SettingSystem.RefreshFCMSwitchState()
    end
  end
end
function FCMPushSystem.GetAppMaxVersion()
  local strPreVersion = Client.GetApplicationVersion()
  local StringUtil = require("common.string_util")
  local arrVersion = StringUtil.Split(strPreVersion, ".")
  local strVersion = ""
  for i = 1, #arrVersion - 1 do
    if i == #arrVersion - 1 then
      strVersion = strVersion .. arrVersion[i]
    else
      strVersion = strVersion .. arrVersion[i] .. "."
    end
  end
  return strVersion
end
return FCMPushSystem