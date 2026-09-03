local ActivityCenterModule = {}
local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
local TableUtil = require("common.table_util")
local StringUtil = require("common.string_util")
local E_ActSwitchType = ActivitySwitchType
local E_local E_ActType = ActivityType
local E_local local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
local E_SubActType = ActivityMacros.SubActType
local C_SwitchIcon = ActivityMacros.ActTabIcon
local C_SwitchIcon_Selected = ActivityMacros.ActTabSelIcon
local E_TabInfoSource = ActivityMacros.ActTabInfoSource
local DEFAULT_DISPLAY_SCENE = {
  [ActivityDisplayScene.Default] = ActivityDisplayScene.Default
}
local HOSTED_ACT_ALL_DONE_ORDER_OFFSET = 10000
function ActivityCenterModule:DefineAndResetData()
  self.IsInit = false
  self.IsActDataReady = false
  self.ActivityData = {}
  self.ExtraData = {}
  self.NoticeData = {}
  self.TabInfoMap = {}
  self.DataProxyMap = {}
  self.WebRedPointList = {}
  self.ExternalImageRedDotMap = {}
  self.MergeActivityList = {}
  self.ExchangeIdSet = {}
  self.HostedActAllDoneCache = nil
end
function ActivityCenterModule:OnInitialize()
end
function ActivityCenterModule:RegistEvents()
  ActivityCenterModule.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ACTIVITY_REMOVED, self.OnActivityRemoved, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, self.OnActDataChanged, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO, self.OnActDataReady, self)
end
function ActivityCenterModule:OnPostSwitchGameStatus(preState, nextState)
  log_warning(bWriteLog and string.format("logic_act_module:OnPostSwitchGameStatus. pre=%s, nextState=%s", tostring(preState), tostring(nextState)))
  if GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting(preState, nextState) then
    ActivityRedDot.ResetBuildFully()
    ActivityRedDot.BuildScenesFull()
  end
end
function ActivityCenterModule:OnLogOut()
  self.HostedActAllDoneCache = nil
end
function ActivityCenterModule:OnActivityRemoved(_, __, actData)
  if not self.IsActDataReady then
    return
  end
  if not actData or not actData.ID then
    return
  end
  local ID = actData.ID
  if not self.ActivityData[ID] and not self.ExtraData[ID] then
    return
  end
  self:InvalidateAndBroadcast()
end
function ActivityCenterModule:OnExtraDataUpdated(nActId, cfg)
  if not self.IsActDataReady then
    return
  end
  local displaySceneMap = cfg and cfg.DisplayScene or DEFAULT_DISPLAY_SCENE
  for displayScene in pairs(displaySceneMap) do
    local proxy = self:GetDataProxy(displayScene)
    if proxy and not proxy:GetActTabInfo(nActId) then
      log_format("ActivityCenterModule:OnExtraDataUpdated - nActId=%s missing in proxy(displayScene=%s), invalidate and broadcast", tostring(nActId), tostring(displayScene))
      self:InvalidateAndBroadcast()
      return
    end
  end
  log_format("ActivityCenterModule:OnExtraDataUpdated - nActId=%s exists in all relevant proxies, skip (field-only update)", tostring(nActId))
end
local ProcessRedDot = function()
  if ActivityRedDot.CheckShouldBuildFully() then
    ActivityRedDot.BuildScenesFull()
  else
    ActivityRedDot.BuildAllEntrances()
  end
end
function ActivityCenterModule:OnActDataChanged(_, _, changes)
  if not changes or not self.IsActDataReady then
    return
  end
  local RefreshAllNum = 10
  local idTb = changes.idList
  if idTb and RefreshAllNum > TableUtil.CountTable(idTb) then
    for id, _ in pairs(idTb) do
      if id == -1 then
        log_warning(bWriteLog and "ActivityCenterModule:OnActDataChanged. id error -1, trigger full refresh")
        ProcessRedDot()
        return
      end
      if not ActivityRedDot.RefreshOneActRedDot(id) then
        log_warning(bWriteLog and string.format("ActivityCenterModule:OnActDataChanged. actId=%s not in any proxy, fallback to full refresh", tostring(id)))
        ProcessRedDot()
        return
      end
      self:RefreshOneActivityOrder(id)
    end
    self:_RefreshNeedActs()
  else
    log_warning(bWriteLog and "ActivityCenterModule:OnActDataChanged. too many changes, trigger full refresh")
    ProcessRedDot()
  end
end
function ActivityCenterModule:_RefreshNeedActs()
  local act_red_cfg = require("client.slua.logic.activity.RedPoint.act_red_cfg")
  for _, v in ipairs(act_red_cfg.NeedRefreshActs) do
    local module = require(v.moduleName)
    local data = module[v.funcName]()
    if data and data.nActID then
      ActivityRedDot.RefreshOneActRedDot(data.nActID)
    end
  end
end
function ActivityCenterModule:OnActDataReady()
  self:InvalidateAndBroadcast()
  self.IsActDataReady = true
end
function ActivityCenterModule:BuildDisplaySceneData(displayScene)
  log_format("ActivityCenterModule:BuildDisplaySceneData - enter. displayScene=%s, IsInit=%s", tostring(displayScene), tostring(self.IsInit))
  self:_InitActivityCenterData()
  if not displayScene then
    log(bWriteLog and "ActivityCenterModule:BuildDisplaySceneData - displayScene is nil, abort")
    return false
  end
  local dataProxy = self:GetDataProxy(displayScene)
  if not dataProxy then
    log_format("ActivityCenterModule:BuildDisplaySceneData - failed to get/create proxy for displayScene=%s", tostring(displayScene))
    return false
  end
  return true
end
function ActivityCenterModule:GetDataProxy(displayScene)
  if not displayScene then
    return nil
  end
  if self.DataProxyMap[displayScene] then
    return self.DataProxyMap[displayScene]
  end
  local class = require("client.slua.logic.activity.ActivityCenterDataProxy")
  local proxy = class()
  self.DataProxyMap[displayScene] = proxy
  self:_FilterAndInitProxy(displayScene, proxy)
  return proxy
end
function ActivityCenterModule:InvalidateAndBroadcast()
  log(bWriteLog and "ActivityCenterModule:InvalidateAndBroadcast - begin. clear source data and rebuild")
  self.IsInit = false
  self:_InitActivityCenterData()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_CENTER_DATA_DIRTY)
end
function ActivityCenterModule:RefreshOneActivityOrder(actId)
  if not actId then
    return
  end
  local tabInfo = self.TabInfoMap[actId]
  if not tabInfo or tabInfo.eSource ~= E_TabInfoSource.Activity then
    return
  end
  local activity = self.ActivityData[actId]
  if not activity then
    log_warning(bWriteLog and string.format("ActivityCenterModule:RefreshOneActivityOrder - actId=%s has tabInfo but no ActivityData, skip", tostring(actId)))
    return
  end
  local brotherData
  if activity.BrotherID and activity.BrotherID ~= "" then
    for _, v in pairs(StringUtil.Split(activity.BrotherID, "|")) do
      local data = ActivityNewSystem.GetActivityByID(tonumber(v))
      if data and next(data) then
        brotherData = data
        break
      end
    end
  end
  local newOrder = self:_CalcActivityOrder(activity, brotherData)
  local oldOrder = tabInfo.nOrder
  if oldOrder == newOrder then
    return
  end
  tabInfo.nOrder = newOrder
  log_format("ActivityCenterModule:RefreshOneActivityOrder - actId=%s nOrder %s -> %s, invalidate proxies", tostring(actId), tostring(oldOrder), tostring(newOrder))
  for displayScene, proxy in pairs(self.DataProxyMap) do
    if proxy and proxy.Invalidate then
      proxy:Invalidate()
      self:_FilterAndInitProxy(displayScene, proxy)
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_CENTER_DATA_DIRTY)
end
function ActivityCenterModule:GetActivitySourceData(actId)
  return self.ActivityData[actId]
end
function ActivityCenterModule:GetExtraSourceData(actId)
  return self.ExtraData[actId]
end
function ActivityCenterModule:GetNoticeSourceData(actId)
  return self.NoticeData[actId]
end
function ActivityCenterModule:InsertCommonEvent(cfg, data)
  if not self:IsCommonEventExists(cfg.updateEventType, cfg.updateEventID) then
    self:AddCommonEvent(cfg.updateEventType, cfg.updateEventID, self.OnExtraDataUpdated, self, data.nActID, cfg)
    log(bWriteLog and "ActivityCenterModule:InsertCommonEvent. insert commont event! type" .. tostring(cfg.updateEventType) .. "id" .. tostring(cfg.updateEventID))
  end
end
function ActivityCenterModule:SetWebRedPointByCfg(cfg)
  local list = {}
  if cfg and next(cfg) then
    for i, v in pairs(cfg) do
      if tonumber(i) and next(v) and 2 < i and i ~= 5 then
        for k, j in pairs(v) do
          if j and type(j) == "table" then
            table.insert(list, {
              startTime = j.start_time,
              endTime = j.end_time,
              actID = tostring(k),
              isFirst = true
            })
          end
        end
      end
    end
  end
  self.WebRedPointList = list
  log_format("ActivityCenterModule:SetWebRedPointByCfg - built H5 red dot list, size=%s", tostring(#list))
end
function ActivityCenterModule:CheckHasH5CenterRedPoint(subID)
  if not self.WebRedPointList or not next(self.WebRedPointList) then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(self.WebRedPointList) do
    if tonumber(v.actID) == tonumber(subID) and v.isFirst and tonumber(v.startTime) < tonumber(serverTime) and tonumber(v.endTime) > tonumber(serverTime) then
      return true
    end
  end
  return false
end
function ActivityCenterModule:TryRemoveH5CenterRedPoint(actID)
  log(bWriteLog and "ActivityCenterModule:TryRemoveH5CenterRedPoint. " .. tostring(actID))
  if not self.WebRedPointList then
    return
  end
  for _, v in pairs(self.WebRedPointList) do
    if tonumber(actID) == tonumber(v.actID) then
      v.isFirst = false
    end
  end
end
function ActivityCenterModule:UpdateRedPointInJumpWebUrl(actID)
  self:TryRemoveH5CenterRedPoint(actID)
  ActivityRedDot.RefreshOneActRedDot(actID)
end
function ActivityCenterModule:_FindModuleIDByLink(sImageLink)
  if not sImageLink or sImageLink == "" then
    return 0
  end
  local idx = string.find(sImageLink, "module=")
  local nModuleID = 0
  if idx and tonumber(idx) and 0 < tonumber(idx) then
    local beginIdx = idx + string.len("module=")
    local endIdx = string.find(sImageLink, "&")
    if endIdx and tonumber(endIdx) and 0 < tonumber(endIdx) then
      nModuleID = tonumber(string.sub(sImageLink, beginIdx, endIdx - 1)) or 0
    else
      nModuleID = tonumber(string.sub(sImageLink, beginIdx, string.len(sImageLink))) or 0
    end
  end
  return nModuleID
end
function ActivityCenterModule:SetExternalImageRedDot(nKey, isModuleID, bShow, redDotType)
  if not nKey then
    return
  end
  local nActID
  local tCurAct = {}
  if isModuleID then
    local tActData = ActivityNewSystem.GetActivity()
    for _, v in pairs(tActData) do
      if v.ImgLink and v.ImgLink ~= "" then
        local nModuleID = self:_FindModuleIDByLink(v.ImgLink)
        if nModuleID == nKey then
          nActID = v.ID
          tCurAct = v
          break
        end
      end
    end
  else
    nActID = nKey
    tCurAct = ActivityNewSystem.GetActivityByID(nActID) or {}
  end
  if not nActID then
    return
  end
  if bShow then
    if not redDotType then
      redDotType = ActivityMacros.RedDotType.Normal
    end
  else
    redDotType = ActivityMacros.RedDotType.None
  end
  self.ExternalImageRedDotMap[nActID] = redDotType
  local tabName = ActivityUtil.GetTabName(tCurAct.TabType)
  if tCurAct.DisplayScene and next(tCurAct.DisplayScene) then
    for displayScene, _ in pairs(tCurAct.DisplayScene) do
      local systemName = ActivityRedDot.DisplayScene2SystemName(displayScene)
      ActivityRedDot.AddRedDotNode(systemName, tCurAct.TabType, tabName, tonumber(nActID), bShow, redDotType)
    end
  else
    local systemName = ActivityRedDot.GetActFirstRedDotSystemName(nActID)
    ActivityRedDot.AddRedDotNode(systemName, tCurAct.TabType, tabName, tonumber(nActID), bShow, redDotType)
  end
end
function ActivityCenterModule:GetExternalImageRedDot(actId)
  if not actId then
    return nil
  end
  return self.ExternalImageRedDotMap[actId]
end
function ActivityCenterModule:IsActivityMerged(nActivityID)
  if not nActivityID then
    return false
  end
  for k, v in pairs(self.MergeActivityList) do
    if k == nActivityID or v == nActivityID then
      return true
    end
  end
  return false
end
function ActivityCenterModule:GetActivityMergeID(nActivityID)
  if not nActivityID then
    return nil
  end
  if self.MergeActivityList[nActivityID] then
    return self.MergeActivityList[nActivityID]
  end
  for k, v in pairs(self.MergeActivityList) do
    if v == nActivityID then
      return k
    end
  end
  return nil
end
function ActivityCenterModule:GetMergeBrotherId(actId)
  if not actId then
    return nil
  end
  for k, v in pairs(self.MergeActivityList) do
    if actId == tonumber(v) then
      return k
    end
  end
  return nil
end
function ActivityCenterModule:GetMergeMainId(actId)
  if not actId then
    return nil
  end
  return self.MergeActivityList[actId]
end
function ActivityCenterModule:AddMergeActivity(brotherId, mainId)
  if not brotherId or not mainId then
    return
  end
  self.MergeActivityList[tonumber(brotherId)] = mainId
end
function ActivityCenterModule:RemoveMergeActivityByBrotherID(brotherID)
  if not brotherID or not next(self.MergeActivityList) then
    return
  end
  for k, v in pairs(self.MergeActivityList) do
    if k == brotherID or v == brotherID then
      self.MergeActivityList[k] = nil
      break
    end
  end
end
function ActivityCenterModule:IsExchangeIdRecorded(actId)
  if not actId then
    return false
  end
  return self.ExchangeIdSet[actId] ~= nil
end
function ActivityCenterModule:RecordExchangeId(actId)
  if not actId then
    return
  end
  self.ExchangeIdSet[actId] = 1
end
local mergeTypeTb = {
  [E_ActType.ITEM_EXCHANGE] = 1,
  [E_ActivityShowType.Progress] = 1
}
function ActivityCenterModule:_UpdateMergeActivity(activity)
  local brotherData
  if activity.BrotherID and activity.BrotherID ~= "" then
    local type
    local config = CDataTable.GetTableData("ActivityCenterConfig", activity.Type)
    if config then
      type = config.ShowType
    end
    for _, v in pairs(StringUtil.Split(activity.BrotherID, "|")) do
      local data = ActivityNewSystem.GetActivityByID(tonumber(v))
      if data and next(data) then
        brotherData = data
        break
      end
    end
    if brotherData then
      local subType = TableUtil.GetTableValue(activity.List, 1, "Type")
      if subType and mergeTypeTb[subType] or mergeTypeTb[type] then
        self:AddMergeActivity(tonumber(brotherData.ID), activity.ID)
        log_warning(bWriteLog and "  ActivityCenterModule:_UpdateMergeActivity. brotherData.ID " .. tostring(brotherData.ID))
        log_warning(bWriteLog and "  ActivityCenterModule:_UpdateMergeActivity. activity.ID " .. tostring(activity.ID))
      end
    else
      self:RemoveMergeActivityByBrotherID(tonumber(activity.BrotherID))
    end
  elseif activity.SelectExchange then
    self:RecordExchangeId(activity.ID)
  end
  return brotherData
end
function ActivityCenterModule:_LoadHostedActAllDoneData()
  if self.HostedActAllDoneCache then
    return self.HostedActAllDoneCache
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.HostedActAllDoneCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHostedActAllDone) or {}
  return self.HostedActAllDoneCache
end
function ActivityCenterModule:IsHostedActAllDone(actId)
  if not actId then
    return false
  end
  local allDoneData = self:_LoadHostedActAllDoneData()
  return allDoneData[tonumber(actId)] == 1
end
function ActivityCenterModule:MarkHostedActAllDone(actId, appType)
  if not actId or actId == 0 then
    log(bWriteLog and "ActivityCenterModule:MarkHostedActAllDone. actId is invalid, skip")
    return
  end
  local numericActId = tonumber(actId)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local savedData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHostedActAllDone) or {}
  if savedData[numericActId] then
    log(bWriteLog and string.format("ActivityCenterModule:MarkHostedActAllDone. already recorded, actId=%s appType=%s", tostring(actId), tostring(appType)))
    self:_OnHostedActivityAllDone(actId, appType)
    return
  end
  savedData[numericActId] = 1
  PlayerPrefsSystem.SaveTableToFile_N(savedData, PlayerPrefsSystem.ePlayerPrefsType.eHostedActAllDone)
  log(bWriteLog and string.format("ActivityCenterModule:MarkHostedActAllDone. saved to PlayerPrefs, actId=%s appType=%s", tostring(actId), tostring(appType)))
  self:_OnHostedActivityAllDone(actId, appType)
end
function ActivityCenterModule:_OnHostedActivityAllDone(actId, appType)
  log(bWriteLog and string.format("ActivityCenterModule:_OnHostedActivityAllDone. actId=%s appType=%s", tostring(actId), tostring(appType)))
  self.HostedActAllDoneCache = nil
  local changeList = {
    idList = {
      [actId] = true
    },
    typeList = {}
  }
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changeList)
end
function ActivityCenterModule:_IsActivityAllDone(activity, brotherData)
  if not activity or not activity.List then
    return false
  end
  local doneCount = 0
  for _, v in ipairs(activity.List) do
    if v and v.Status == E_ActivityProgressStatus.Get then
      doneCount = doneCount + 1
    end
  end
  local brotherNum = 0
  if brotherData and brotherData.List then
    brotherNum = #brotherData.List
    for _, v in ipairs(brotherData.List) do
      if v and v.Status == E_ActivityProgressStatus.Get then
        doneCount = doneCount + 1
      end
    end
  end
  local nAllNum = #activity.List + brotherNum
  if nAllNum == 0 then
    return false
  end
  return doneCount >= nAllNum
end
function ActivityCenterModule:_CalcActivityOrder(activity, brotherData)
  local nOrder = activity and activity.Order or 0
  if self:_IsActivityAllDone(activity, brotherData) then
    nOrder = 2000
  end
  if activity and self:IsHostedActAllDone(activity.ID) then
    nOrder = nOrder + HOSTED_ACT_ALL_DONE_ORDER_OFFSET
  end
  return nOrder
end
function ActivityCenterModule:UpdateOneActivity(activity, justRed)
  local brotherData = self:_UpdateMergeActivity(activity)
  local tabInfo = {}
  local curData = ActivityUtil.SortAndSetCurActSubData(activity)
  if justRed then
    if self.ActivityData[activity.ID] then
      self.ActivityData[activity.ID] = curData
    end
  else
    self.ActivityData[activity.ID] = curData
  end
  if activity.Type == E_ActType.ACTIVITY_TYPE_REBATE then
    local ActivityRebate = require("client.logic.activity.logic_activity_rebate")
    local info = ActivityRebate.GetRebateInfo()
    local rebateRateStr = LocUtil.LocalizeResFormat(7543, info.rebateRate .. "%%")
    tabInfo.sName = rebateRateStr
  else
    tabInfo.sName = activity.Title
  end
  if activity.Type == E_ActType.ACTIVITY_TYPE_LINK or activity.Type == E_ActType.SmallPaymentBanner then
    local sExParam = activity.ExParam
    if sExParam and sExParam ~= "" then
      local tAllParam = StringUtil.Split(sExParam, "|")
      tabInfo.tShowCoin = tAllParam
    end
  end
  tabInfo.nActID = activity.ID
  tabInfo.nType = activity.LabelType
  tabInfo.sTypeName = activity.LabelDesc
  tabInfo.nStartTime = activity.StartTime
  tabInfo.nOrder = self:_CalcActivityOrder(activity, brotherData)
  tabInfo.sImageLink = activity.ImgLink
  tabInfo.sTabImageUrl = activity.TabImgUrl
  return tabInfo
end
local Type2Label = {
  [E_ActType.ACTIVITY_TYPE_REBATE] = E_ActivityShowType.Sub,
  [E_ActType.REDEEM_CODE] = E_ActivityShowType.RedeemCode,
  [E_ActType.IMAGES_GROUP] = E_ActivityShowType.Banner
}
local LabelTypeTb = {}
function ActivityCenterModule:GetActPageType(tActData)
  if not tActData or not tActData.Type then
    log(bWriteLog and "[v_vyhhzhang] Act have not type")
    return E_ActivityShowType.None
  end
  if ActivityUtil.IsHideInActivityCenter(tActData) then
    return E_ActivityShowType.None
  end
  if tActData.Type == E_ActType.ACTIVITY_TYPE_AREA_GROUP then
    return E_ActivityShowType.None
  end
  local mergeMainId = self:GetMergeMainId(tActData.ID)
  if mergeMainId and tActData.Type ~= E_ActType.WEEKEND_MARKET then
    local subActData = ActivityNewSystem.GetActivityByID(mergeMainId)
    if subActData then
      local config = CDataTable.GetTableData("ActivityCenterConfig", subActData.Type)
      if config then
        if config.ShowType == E_ActivityShowType.Progress then
          return E_ActivityShowType.TaskProgress
        else
          return E_ActivityShowType.TaskExchange
        end
      else
        return E_ActivityShowType.None
      end
    end
  end
  if self:IsExchangeIdRecorded(tActData.ID) then
    return E_ActivityShowType.Sub
  end
  if tActData.Type == E_ActType.NOTICE_INFO then
    if tActData.ImgUrl == "" then
      return E_ActivityShowType.Notice
    elseif tActData.Detail == "" then
      return E_ActivityShowType.None
    else
      return E_ActivityShowType.Image
    end
  end
  if tActData.Type == E_ActType.IMAGES_GROUP and #tActData.List == 0 then
    return E_ActivityShowType.None
  end
  if tActData.Type == E_ActType.ACTIVITY_TYPE_LINK and tActData.back_int_value == ActivityBackUpIntType.Gamelet then
    local JumpUtils = require("client.logic.store.jump_utils")
    if JumpUtils.IsPanDoraJumpUrl(tActData.ImgLink) then
      return E_ActivityShowType.PandoraContainer
    else
      return E_ActivityShowType.GameletContainer
    end
  end
  if LabelTypeTb[tActData.LabelType] then
    return tActData.LabelType
  end
  if Type2Label[tActData.Type] then
    local changedLabel = Type2Label[tActData.Type]
    log_warning(bWriteLog and "  ActivityCenterModule:GetActPageType. changedLabel " .. tostring(changedLabel))
    return changedLabel
  end
  local tActConfig = CDataTable.GetTableData("ActivityCenterConfig", tActData.Type)
  if tActConfig then
    return tActConfig.ShowType
  end
  return E_ActivityShowType.Image
end
function ActivityCenterModule:GetTabRed(tTabData, nCurSwitchType)
  local SystemName = ActivityRedDot.GetActFirstRedDotSystemName(tTabData.nActID)
  if self:IsActivityMerged(tTabData.nActID) then
    local redActOne = ActivityRedDot.GetRedDotData(SystemName, nCurSwitchType, tTabData.nActID)
    if redActOne and redActOne.newCount >= 1 then
      return redActOne
    end
    local actTwoID = self:GetActivityMergeID(tTabData.nActID)
    SystemName = ActivityRedDot.GetActFirstRedDotSystemName(actTwoID)
    local redActTwo = ActivityRedDot.GetRedDotData(SystemName, nCurSwitchType, actTwoID)
    if redActTwo and redActTwo.newCount >= 1 then
      return redActTwo
    end
  end
  return ActivityRedDot.GetRedDotData(SystemName, nCurSwitchType, tTabData.nActID)
end
function ActivityCenterModule:_InitActivityCenterData(shouldBroadcast)
  if self.IsInit then
    return
  end
  self.IsInit = true
  self.ActivityData = {}
  self.ExtraData = {}
  self.NoticeData = {}
  self.TabInfoMap = {}
  self.MergeActivityList = {}
  self.ExchangeIdSet = {}
  local utility = require("common.utility")
  xpcall(self._ConstructActivityData, utility.ErrorMessageHandler, self)
  xpcall(self._ConstructExtraData, utility.ErrorMessageHandler, self)
  xpcall(self._ConstructNoticeData, utility.ErrorMessageHandler, self)
  local proxyCount = 0
  for displayScene, proxy in pairs(self.DataProxyMap) do
    if proxy and proxy.Invalidate then
      proxy:Invalidate()
      self:_FilterAndInitProxy(displayScene, proxy)
      proxyCount = proxyCount + 1
    end
  end
  if bWriteLog then
    local tabInfoCount = 0
    for _ in pairs(self.TabInfoMap) do
      tabInfoCount = tabInfoCount + 1
    end
    log_format("ActivityCenterModule:_InitActivityCenterData - finished. TabInfoMap=%s, proxyRebuilt=%s, broadcast=%s", tostring(tabInfoCount), tostring(proxyCount), tostring(shouldBroadcast))
  end
  if shouldBroadcast then
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_CENTER_DATA_DIRTY)
  end
end
function ActivityCenterModule:_ConstructActivityData()
  local data = ActivityNewSystem.GetActivity()
  self.ActivityData = {}
  for _, activity in ipairs(data) do
    if ActivityUtil.CanShowAct(activity) then
      local tabInfo = self:UpdateOneActivity(activity)
      if tabInfo then
        tabInfo.eSource = E_TabInfoSource.Activity
        tabInfo.nSwitchType = activity.TabType
        tabInfo.nShowType = activity.LabelType
        tabInfo.tDisplayScene = activity.DisplayScene or DEFAULT_DISPLAY_SCENE
        tabInfo.tRawRef = activity
        self.TabInfoMap[activity.ID] = tabInfo
      end
    end
  end
end
function ActivityCenterModule:_ConstructExtraData()
  local C_ExtraActPageTypeBegin = E_ActivityShowType.End
  self.ExtraData = {}
  local _InitExtraData = function(cfg, data)
    local nSwitchType = data.nSwitchType or cfg.switchType or 0
    if nSwitchType <= 0 then
      log_warning(bWriteLog and string.format("ActivityCenterModule._ConstructExtraData. skip invalid extra: nActID=%s, nSwitchType=%s", tostring(data.nActID), tostring(nSwitchType)))
      return
    end
    local tabInfo = data
    if data.Order then
      tabInfo.nOrder = data.Order or 0
    else
      tabInfo.nOrder = cfg.sort or 0
    end
    tabInfo.nType = data.nType or 0
    tabInfo.sTypeName = ""
    if cfg.showType == -1 or cfg.showType > E_ActivityShowType.End then
      C_ExtraActPageTypeBegin = C_ExtraActPageTypeBegin + 1
      cfg.showType = C_ExtraActPageTypeBegin
      ActivityMacros.ActPageUI[C_ExtraActPageTypeBegin] = cfg.uiConfig
    end
    self.ExtraData[data.nActID] = {cfg = cfg, data = data}
    tabInfo.eSource = E_TabInfoSource.Extra
    tabInfo.    tabInfo.nShowType = cfg.showType
    tabInfo.tDisplayScene = data.DisplayScene or DEFAULT_DISPLAY_SCENE
    tabInfo.tRawRef = cfg
    self.TabInfoMap[data.nActID] = tabInfo
    if cfg.updateEventType and cfg.updateEventID then
      self:InsertCommonEvent(cfg, data)
    end
  end
  local activityConfig = require("client.slua.logic.activity.activity_config")
  activityConfig.StartCache()
  for i, cfg in ipairs(activityConfig) do
    local actData = activityConfig.DoAction(i, cfg)
    if actData then
      if 0 < #actData then
        for _, subData in ipairs(actData) do
          _InitExtraData(cfg, subData)
        end
      else
        _InitExtraData(cfg, actData)
      end
    end
  end
end
function ActivityCenterModule:_ConstructNoticeData()
  local NoticesUtil = require("client.logic.Notice.NoticesUtil")
  local NoticesConst = require("client.logic.Notice.NoticesConst")
  local activityNotices = NoticesUtil.GetActivityNoticeArray()
  local switchType = E_ActSwitchType.Notice
  self.NoticeData = {}
  for _, v in pairs(activityNotices) do
    if tonumber(v.MsgContentType) == NoticesConst.NoticeContentType.Text and v.MsgContent ~= "" or tonumber(v.MsgContentType) == NoticesConst.NoticeContentType.ImageOrBlueprint and v.EventCenter ~= "" then
      local nActID = tonumber(v.MsgId)
      if nActID then
        local tabInfo = {}
        tabInfo.        if ActivityUtil.GetNoticePageType(v) == E_ActivityShowType.Notice then
          tabInfo.sName = v.MsgTitle or ""
        else
          tabInfo.sName = v.PicTitle or ""
        end
        tabInfo.nType = switchType
        tabInfo.sTypeName = ""
        tabInfo.nStartTime = v.StartTime or 0
        tabInfo.nOrder = v.Sort or 1000
        self.NoticeData[nActID] = v
        tabInfo.eSource = E_TabInfoSource.Notice
        tabInfo.nSwitchType = switchType
        tabInfo.nShowType = E_ActivityShowType.Notice
        tabInfo.tDisplayScene = DEFAULT_DISPLAY_SCENE
        tabInfo.tRawRef = v
        self.TabInfoMap[nActID] = tabInfo
      end
    end
  end
end
function ActivityCenterModule:_FilterAndInitProxy(displayScene, dataProxy)
  if not displayScene or not dataProxy then
    return
  end
  local filtered = {}
  local filteredCount = 0
  for actId, tabInfo in pairs(self.TabInfoMap) do
    local displaySceneMap = tabInfo.tDisplayScene or DEFAULT_DISPLAY_SCENE
    if displaySceneMap[displayScene] then
      filtered[actId] = tabInfo
      filteredCount = filteredCount + 1
    end
  end
  log_format("ActivityCenterModule:_FilterAndInitProxy - displayScene=%s, filtered tab count=%s", tostring(displayScene), tostring(filteredCount))
  dataProxy.TabInfoMap = filtered
  dataProxy:Init()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CActivityCenterModule = class(CModuleBase, nil, ActivityCenterModule)
return CActivityCenterModule