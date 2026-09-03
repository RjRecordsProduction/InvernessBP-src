local BlackFridayMainModule = {}
local UIUtil = require("client.common.ui_util")
local BlackFridayMacros = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayMacros")
local ActType = BlackFridayMacros.ActivityType
local ActivityTypeMap = {
  [ActType.Gun] = ActivityType.BlackFriday_Gun,
  [ActType.Vow] = ActivityType.BLACK5_VOW,
  [ActType.GroupBuy] = ActivityType.BlackFriday_GroupBuy,
  [ActType.Upgrade] = ActivityType.BlackFriday_Upgrade,
  [ActType.Pass] = ActivityType.BlackFriday_Pass,
  [ActType.Subscribe] = ActivityType.BlackFriday_Subscribe,
  [ActType.RPGroup] = ActivityType.BlackFriday_RPGroup
}
local _tActCheckShow = {
  [ActType.Subscribe] = function()
    local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
    local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
    if subscribeModuleObj:GetIsPrimeOpen() then
      return subscribeModuleObj:IsGetSubscribeData()
    else
      return false
    end
  end
}
function BlackFridayMainModule:DefineAndResetData()
  self.bActivityReady = nil
  self.ActivityConfigs = nil
  self.ActivityConfigMap = nil
  self.MainActStartTime = nil
  self.MainActEndTime = nil
  self.RePullTimer = nil
end
function BlackFridayMainModule:OnInitialize()
  self:OnActivityDataInit()
end
function BlackFridayMainModule:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO, self.OnActivityDataInit, self)
end
function BlackFridayMainModule:OnPreSwitchGameStatus(preState, nextState)
  if GameStatus.IsPreSwitchEnterFightingFromLobbyOrMainCity(preState, nextState) and self.RePullTimer then
    self:RemoveTimer(self.RePullTimer)
    self.RePullTimer = nil
  end
end
function BlackFridayMainModule:OnPostSwitchGameStatus(preState, nextState)
  if GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting(preState, nextState) then
    self:StartRePullTimer()
  end
end
function BlackFridayMainModule:OnActivityDataInit()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByType(ActivityType.BlackFriday_Main)
  if not actData then
    log(bWriteLog and "BlackFridayMainModule:OnActivityDataInit. There is no main activity.!")
    return
  end
  local TimeUtil = require("client.common.time_util")
  if TimeUtil.UnixTimeBetween(actData.StartTime, actData.EndTime) ~= 0 then
    log(bWriteLog and "BlackFridayMainModule:OnActivityDataInit. The time is out of the main activity time!")
    return
  end
  self.bActivityReady = true
  self:HandleRegisterEvent()
  self:ReqMainData()
end
function BlackFridayMainModule:ReqMainData()
  if self.ActivityConfigs and next(self.ActivityConfigs) then
    log(bWriteLog and "BlackFridayMainModule:ReqMainData. ActivityDataList existed")
    return
  end
  if not self.bActivityReady then
    self:OnActivityDataInit()
    log(bWriteLog and "BlackFridayMainModule:ReqMainData. BlackFriday Activity isn't bActivityReady!")
    return
  end
  local BlackFridayHandler = require("client.network.Protocol.BlackFridayHandler")
  BlackFridayHandler.send_get_black_friday_activity_list_req()
end
function BlackFridayMainModule:HasInit()
  return self.bActivityReady
end
function BlackFridayMainModule:HandleMainData(res, activityIdList, presetData, extraData)
  log(bWriteLog and string.format("BlackFridayMainModule:HandleActivityData. res=%s", tostring(res)))
  log_tree("BlackFridayMainModule:HandleActivityData. activityIdList = ", activityIdList)
  log_tree("BlackFridayMainModule:HandleActivityData. presetData = ", presetData)
  log_tree("BlackFridayMainModule:HandleActivityData. extraData = ", extraData)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  self.ActivityConfigs = activityIdList
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local BlackFridayActivityInfo = ActivityNewSystem.GetActivityByID(presetData.main_activity_id)
  if BlackFridayActivityInfo then
    self.MainActStartTime = BlackFridayActivityInfo.StartTime
    self.MainActEndTime = BlackFridayActivityInfo.EndTime
  end
  self:HandleTabImage()
  local BlackFridayGroupBuyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayGroupBuyModule)
  BlackFridayGroupBuyModule:HandleExtraData(extraData)
  local BlackFridayUpgradeModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayUpgradeModule)
  BlackFridayUpgradeModule:HandlePresetData(presetData)
  local BlackFridayPassModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayPassModule)
  BlackFridayPassModule:HandlePresetData(presetData)
  local BlackFridayGunModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayGunModule)
  BlackFridayGunModule:HandlePresetData(presetData)
  local BlackFridayVowModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayVowModule)
  BlackFridayVowModule:HandlePresetData(presetData)
  local BlackFridayWeekSignModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayWeekSignModule)
  BlackFridayWeekSignModule:HandleExtraData(extraData)
  local BlackFridayEntranceModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayEntranceModule)
  BlackFridayEntranceModule:HandleExtraData(extraData)
  local Logic_BFSubscribeModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BFSubscribeModule)
  Logic_BFSubscribeModule:send_black_friday_prime_promotion_info_req()
  local BlackFridayRedDotModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayRedDotModule)
  BlackFridayRedDotModule:ConstructRedDot()
  BlackFridayRedDotModule:UpdateAllRedDot()
  self:StartRePullTimer()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_ACT_CONFIG_UPDATE)
end
function BlackFridayMainModule:Black5Preview(widget, itemId, validHours, type, config, other)
  log(bWriteLog and string.format("BlackFridayMainModule:Black5Preview itemId=%s, validHours=%s, type=%s, config=%s, other=%s", tostring(itemId), tostring(validHours), tostring(type), tostring(config), tostring(other)))
  local ItemPreviewSystem = require("client.slua.logic.item_preview.logic_itemPreview")
  if ItemPreviewSystem.IsNeedShow(itemId, other) or LobbySystem.CheckShowPackagePreview(itemId) then
    LobbySystem.PlayItemPreviewAnimation(itemId, false, type, config, validHours, other)
  else
    UIUtil.ShowItemTips(itemId, widget, FVector2D(0, 0), validHours, 0, true)
  end
end
function BlackFridayMainModule:GetMainActTime()
  return self.MainActStartTime, self.MainActEndTime
end
function BlackFridayMainModule:HasActivityConfig()
  if not self.ActivityConfigs or not next(self.ActivityConfigs) then
    return false
  end
  return true
end
function BlackFridayMainModule:GetActivityConfig(selActType)
  local result = {}
  local index = 1
  if not self.ActivityConfigs then
    return result, index
  end
  local TimeUtil = require("client.common.time_util")
  for _, v in pairs(self.ActivityConfigs) do
    local nActType = tonumber(v.type)
    if TimeUtil.UnixTimeBetween(v.start_time, v.end_time) <= 0 and (not _tActCheckShow[nActType] or _tActCheckShow[nActType]()) then
      table.insert(result, v)
      if nActType == selActType then
        index = #result
      end
    end
  end
  return result, index
end
function BlackFridayMainModule:GetActivityConfigByType(type)
  if not self.ActivityConfigMap then
    return nil
  end
  return self.ActivityConfigMap[tostring(type)]
end
function BlackFridayMainModule:HandleTabImage()
  local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
  local OnSuccess = function(texture, url)
    log(bWriteLog and string.format("BlackFridayMainModule:HandleTabImage OnSuccess, url=%s", tostring(url)))
  end
  local OnFailed = function(url)
    log(bWriteLog and string.format("BlackFridayMainModule:HandleTabImage OnFailed, url=%s", tostring(url)))
  end
  local image_download_config = require("client.slua.logic.image_download.image_download_config")
  self.ActivityConfigMap = {}
  for _, config in pairs(self.ActivityConfigs) do
    log(bWriteLog and string.format("BlackFridayMainModule:HandleTabImage. Path:%s", config.imageLink))
    if config.imageLink and config.imageLink ~= "" then
      image_download_mgr:DownloadImageByHttpWrapper(config.imageLink, OnSuccess, OnFailed, {
        diskCacheType = image_download_config.EnumDiskCacheType.VersionUpdate
      })
    end
    self.ActivityConfigMap[tostring(config.type)] = config
  end
end
function BlackFridayMainModule:TakeAward(activityId, isSpecialAward, awardIndex)
  log(bWriteLog and string.format("BlackFridayMainModule:TakeAward. activityId=%s, isSpecialAward=%s, awardIndex=%s", tostring(activityId), tostring(isSpecialAward), tostring(awardIndex)))
  if isSpecialAward then
  else
    local ActivityHandler = require("client.network.Protocol.ActivityHandler")
    ActivityHandler.send_take_activity_award_req(activityId, awardIndex)
  end
  local TLogReasonTable = {activity_id = activityId}
  if awardIndex then
    TLogReasonTable.index = awardIndex
  end
  local TLogReasonStr = json.encode(TLogReasonTable)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.BlackFriday_Task_TakeAward, 0, TLogReasonStr)
  log(bWriteLog and string.format("BlackFridayMainModule:TakeAward. TLogReport reason str : %s", tostring(TLogReasonStr)))
end
function BlackFridayMainModule:EnoughUCBuy(nNeedCount, bHideJump, fCloseCallBack)
  if nNeedCount > DataMgr.ticket then
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    local BlackFridayPopupUtil = require("GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayPopupUtil")
    BlackFridayPopupUtil.Push({
      Func = CommonPayBoxMgr.ShowUcRechargeMsg,
      Params = {
        nNeedCount,
        bHideJump,
        fCloseCallBack
      }
    }, true)
    return false
  end
  return true
end
function BlackFridayMainModule:HasActivityData(type)
  type = tonumber(type)
  if ActivityTypeMap[type] then
    local actType = ActivityTypeMap[type]
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    local actData = ActivityNewSystem.GetActivityByType(actType)
    return actData ~= nil
  end
  return false
end
function BlackFridayMainModule:HandleCostTLog(tLogReasonTable)
  if not tLogReasonTable then
    return
  end
  local TLogReasonStr = json.encode(tLogReasonTable)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.BlackFriday_Cost, 0, TLogReasonStr)
  log(bWriteLog and string.format("BlackFridayMainModule:HandleCostTLog. TLogReport reason str : %s", tostring(TLogReasonStr)))
end
function BlackFridayMainModule:HandleError(res)
  log(bWriteLog and string.format("BlackFridayMainModule.HandleError. res=%s", tostring(res)))
  if res == 0 then
    return false
  end
  if tostring(res) == "9940041" then
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    CommonPayBoxMgr.ShowUcRechargeMsg()
  elseif res == 9940049 then
    local sTitle = LocUtil.GetLocalizeResStr(5077)
    local sShowStr = LocUtil.GetLocalizeResStr(18140086)
    local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
    IngameTipsTools.ShowMsgBox(IngameTipsTools.MSGBOX_SHOW_TYPE_FOUR, sTitle, sShowStr, function()
      GlobalData.JumpUrl("game://?module=1006014&type=" .. ActType.Subscribe)
    end, nil, LocUtil.GetLocalizeResStr(27840))
  else
    ShowNotice(res)
  end
  return true
end
function BlackFridayMainModule:HandleRegisterEvent()
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVEMTID_DATAMGR_ACTIVITY_REWARDS_COMMON, self.OnRefreshRedDot, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_GET_AWARDS, self.OnRefreshRedDot, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_REFRESH, self.OnRefreshRedDot, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_TAKE_CUMULATIVE_AWARD, self.OnRefreshRedDot, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, self.OnRefreshRedDot, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_RPGROUP_UPDATE_REDDOT, self.OnRefreshRedDot, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, self.OnActChanged, self)
end
function BlackFridayMainModule:HandleUnregisterEvent()
  self:RemoveCommonEvent(EVENTTYPE_ACTIVITY, EVEMTID_DATAMGR_ACTIVITY_REWARDS_COMMON)
  self:RemoveCommonEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_GET_AWARDS)
  self:RemoveCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_REFRESH)
  self:RemoveCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_TAKE_CUMULATIVE_AWARD)
  self:RemoveCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE)
  self:RemoveCommonEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_RPGROUP_UPDATE_REDDOT)
  self:RemoveCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE)
end
function BlackFridayMainModule:OnRefreshRedDot()
  local BlackFridayRedDotModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayRedDotModule)
  BlackFridayRedDotModule:UpdateAllRedDot()
end
function BlackFridayMainModule:OnActChanged(_, __, changeList)
  if not changeList or not changeList.idList then
    return
  end
  local BlackFridayUpgradeModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayUpgradeModule)
  local BlackFridayPassModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayPassModule)
  local BlackFridayRedDotModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayRedDotModule)
  local BlackFridayGunModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayGunModule)
  local BlackFridayVowModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayVowModule)
  local idList = changeList.idList
  if idList then
    for id, _ in pairs(idList) do
      if BlackFridayUpgradeModule:IsUpgradeActId(id) then
        BlackFridayRedDotModule:UpdateDirectRedDot(ActType.Upgrade)
      elseif BlackFridayPassModule:IsPassActId(id) then
        BlackFridayRedDotModule:UpdateDirectRedDot(ActType.Pass)
      elseif BlackFridayGunModule:IsGunActId(id) then
        BlackFridayRedDotModule:UpdateDirectRedDot(ActType.Gun)
      elseif BlackFridayVowModule:IsVowActId(id) then
        BlackFridayRedDotModule:UpdateDirectRedDot(ActType.Vow)
      end
    end
  end
end
function BlackFridayMainModule:StartRePullTimer()
  local TimeUtil = require("client.common.time_util")
  local curTimestamp = TimeUtil.GetServerTimeInSec()
  local timestampList = {}
  local BlackFridayGroupBuyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayGroupBuyModule)
  local groupBuyTimestamp = BlackFridayGroupBuyModule:GetNextUpdateTime()
  if groupBuyTimestamp then
    table.insert(timestampList, groupBuyTimestamp)
  end
  local config = self:GetActivityConfigByType(BlackFridayMacros.ActivityType.Gun)
  if config and config.start_time then
    table.insert(timestampList, config.start_time)
  end
  local futureTimestamps = {}
  local diff, nextUpdateTimestamp
  for _, timestamp in ipairs(timestampList) do
    if timestamp > curTimestamp then
      if not diff then
        diff = timestamp - curTimestamp
        nextUpdateTimestamp = timestamp
      else
        local newDiff = timestamp - curTimestamp
        if diff > newDiff then
          diff = newDiff
          nextUpdateTimestamp = timestamp
        end
      end
    end
  end
  if self.RePullTimer then
    self:RemoveTimer(self.RePullTimer)
    self.RePullTimer = nil
  end
  if not nextUpdateTimestamp then
    log(bWriteLog and "BlackFridayMainModule:StartRePullTimer. No future timestamps found")
    return
  end
  self.RePullTimer = self:AddTimerOnce(nextUpdateTimestamp - curTimestamp, function()
    log(bWriteLog and "BlackFridayMainModule:StartRePullTimer. Timer triggered, re-pulling activity data")
    self.ActivityConfigs = nil
    self:ReqMainData()
    self.RePullTimer = nil
  end)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CBlackFridayMainModule = class(CModuleBase, nil, BlackFridayMainModule)
return CBlackFridayMainModule