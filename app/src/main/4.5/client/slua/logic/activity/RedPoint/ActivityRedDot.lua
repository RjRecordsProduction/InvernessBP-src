local ActivityRedDot = {
  IsInit = nil,
  RedDotData = nil,
  NewRedDotRecord = nil,
  EndRedDotRecord = nil,
  BuildAllRedDotMark = nil,
  ReportIdMap = nil
}
local activityConfig = require("client.slua.logic.activity.activity_config")
local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
local ReddotConfig = require("client.slua.logic.reddot.reddot_config")
local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local TimeUtil = require("client.common.time_util")
local local local local local local local local local local local local local BatchKey_RewardRedDot = "BatchKey_RewardRedDot"
local GenerateRootData = function(systemName)
  return {
    newCount = 0,
    desc = systemName,
    pages = {
      newCount = 0,
      category = reddot_macro.Category.NewArrivals,
      isDynamic = true
    }
  }
end
local GenerateTabData = function(subName)
  return {
    newCount = 0,
    desc = subName,
    isDynamic = true,
    SubTabs = {newCount = 0, isDynamic = true}
  }
end
local GenerateActData = function(actId, subID)
  return {
    newCount = 0,
    category = reddot_macro.Category.NewArrivals,
    subID = subID,
    instanceId = actId,
    isDynamicCategory = true,
    redDotType = ActivityMacros.RedDotType.None
  }
end
local RecomputeAncestorOnWeightChange = function(leaf)
  leaf.realWeight = leaf.weight or 0
  local parentData = leaf:GetParent()
  while parentData do
    local maxWeight = -1
    local category = ReddotConfig.INVALID_CATEGORY
    local subID = ReddotConfig.INVALID_SUBID
    for _, v in pairs(parentData) do
      if type(v) == "table" and v.realWeight and maxWeight < v.realWeight then
        maxWeight = v.realWeight
        category = v.category or category
        subID = v.subID or subID
      end
    end
    if parentData.weight and maxWeight < parentData.weight then
      maxWeight = parentData.weight
    end
    parentData.realWeight = maxWeight
    parentData.    parentData.    parentData = parentData:GetParent()
  end
end
local NoRedShowTypeTb = {
  [ActivityShowType.None] = 1,
  [ActivityShowType.Bg] = 1,
  [ActivityShowType.TopBg] = 1,
  [ActivityShowType.BottomImage] = 1
}
function ActivityRedDot.OnLogin()
  ActivityRedDot._InitData()
end
function ActivityRedDot.OnLogout()
  ActivityRedDot.IsInit = nil
  ActivityRedDot.RedDotData = nil
  ActivityRedDot.NewRedDotRecord = nil
  ActivityRedDot.EndRedDotRecord = nil
  ActivityRedDot.BuildAllRedDotMark = nil
  ActivityRedDot.ReportIdMap = nil
  local BatchHelper = require("client.logic.Batch.BatchHelper")
  BatchHelper.Remove(BatchKey_RewardRedDot)
end
function ActivityRedDot.GetRedDotData(systemName, tabType, actId)
  local redDotData = ActivityRedDot.RedDotData and ActivityRedDot.RedDotData[systemName]
  if not tabType or tabType <= 0 then
    return redDotData
  end
  if not actId or actId <= 0 then
    return redDotData and redDotData.pages and redDotData.pages[tabType]
  end
  local redData = redDotData and redDotData.pages and redDotData.pages[tabType] and redDotData.pages[tabType].SubTabs and redDotData.pages[tabType].SubTabs[actId]
  if redData then
    log(bWriteLog and "ActivityRedDot.GetRedDotData" .. " ID=" .. tostring(tabType) .. " subID=" .. tostring(actId) .. " newCount=" .. tostring(redData.newCount))
  end
  return redData
end
function ActivityRedDot.BuildAllEntrances()
  for _, displayScene in pairs(ActivityDisplayScene) do
    ActivityRedDot.BuildEntrance(displayScene)
  end
end
function ActivityRedDot.BuildEntrance(displayScene)
  log(bWriteLog and "ActivityRedDot.BuildEntrance. Start! displayScene=" .. tostring(displayScene))
  if not ActivityRedDot._CanProcessRedDot() then
    log(bWriteLog and "ActivityRedDot.BuildEntrance. Can't Process RedDot")
    return
  end
  if ActivityRedDot.SystemHasRed(displayScene) then
    log(bWriteLog and "ActivityRedDot.BuildEntrance. In Loading and Has RedPoint, don't build red dot!")
    return
  end
  local systemName = ActivityRedDot.DisplayScene2SystemName(displayScene)
  if ActivityRedDot.HasBuildFully(systemName) then
    log(bWriteLog and "ActivityRedDot.BuildEntrance. not red and has build fully!")
    return
  end
  ActivityRedDot._InitData()
  ActivityRedDot._UpdateEntranceRedDot(displayScene)
end
function ActivityRedDot.ReBuildAllEntrances()
  for _, displayScene in pairs(ActivityDisplayScene) do
    ActivityRedDot.RebuildEntrance(displayScene)
  end
end
local RebuildNewRedDotsFromProxy = function(systemName, proxy, onlyRewardRedDot, stopOnFirstReward)
  local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
  local groups = proxy:GetAllGroups()
  local remainSwitchCount = 0
  for _, __ in pairs(groups) do
    remainSwitchCount = remainSwitchCount + 1
  end
  local bHitRewardRedDot = false
  local bInterrupted = false
  for switchType, tabList in pairs(groups) do
    if switchType and 0 < switchType then
      local bBreakInner = false
      for index, tabInfo in ipairs(tabList) do
        local actId = tabInfo.nActID
        if actId and 0 < actId then
          local bShowRedHot, redDotType = ActivityRedDot._ResolveRedDotByTabInfo(tabInfo)
          redDotType = redDotType or ActivityMacros.RedDotType.None
          local bIsRewardRedDot = bShowRedHot and redDotType ~= ActivityMacros.RedDotType.None
          if bShowRedHot ~= nil and (not onlyRewardRedDot or bIsRewardRedDot) then
            local tabName = ActivityUtil.GetTabName(switchType)
            ActivityRedDot.AddRedDotNode(systemName, switchType, tabName, actId, bShowRedHot, redDotType)
          end
          if bIsRewardRedDot then
            bHitRewardRedDot = true
            if stopOnFirstReward then
              if index < #tabList then
                bInterrupted = true
              end
              bBreakInner = true
              break
            end
          end
        end
      end
      remainSwitchCount = remainSwitchCount - 1
      if bBreakInner then
        if 0 < remainSwitchCount then
          bInterrupted = true
        end
        break
      end
    end
  end
  return not bInterrupted, bHitRewardRedDot
end
local RebuildOldRedDotsFromTree = function(systemName, proxy)
  local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
  local redDot = ActivityRedDot.GetRedDotData(systemName)
  if not redDot or not redDot.pages then
    log_warning(bWriteLog and "ActivityRedDot.RebuildOldRedDotsFromTree. redDot is nil, systemName=" .. tostring(systemName))
    return
  end
  for switchType, pageData in pairs(redDot.pages) do
    if type(pageData) == "table" then
      for actId, node in pairs(pageData.SubTabs) do
        if type(node) == "table" then
          local tabInfo = proxy:GetActTabInfo(actId)
          local bShowRedHot, redDotType
          if not tabInfo then
            bShowRedHot, redDotType = false, ActivityMacros.RedDotType.None
          else
            bShowRedHot, redDotType = ActivityRedDot._ResolveRedDotByTabInfo(tabInfo)
          end
          local tabName = ActivityUtil.GetTabName(switchType)
          ActivityRedDot.AddRedDotNode(systemName, switchType, tabName, actId, bShowRedHot, redDotType)
        end
      end
    end
  end
end
function ActivityRedDot.RebuildEntrance(displayScene)
  log(bWriteLog and "ActivityRedDot.RebuildEntrance. Start! displayScene=" .. tostring(displayScene))
  if not ActivityRedDot._CanProcessRedDot() then
    log(bWriteLog and "ActivityRedDot.RebuildEntrance. Can't Process RedDot")
    return
  end
  ActivityRedDot._InitData()
  local proxy = ActivityRedDot._GetDataProxy(displayScene)
  if not proxy then
    log_warning(bWriteLog and "ActivityRedDot.RebuildEntrance. proxy is nil, displayScene=" .. tostring(displayScene))
    return
  end
  local systemName = ActivityRedDot.DisplayScene2SystemName(displayScene)
  local bFullyBuilt = RebuildNewRedDotsFromProxy(systemName, proxy, true, true)
  if bFullyBuilt then
    ActivityRedDot.BuildAllRedDotMark[systemName] = true
  end
  RebuildOldRedDotsFromTree(systemName, proxy)
end
function ActivityRedDot.BuildScenesFull()
  for _, displayScene in pairs(ActivityDisplayScene) do
    ActivityRedDot.BuildSceneFull(displayScene)
  end
end
function ActivityRedDot.BuildSceneFull(displayScene)
  log(bWriteLog and "ActivityRedDot.BuildSceneFull. Start! displayScene=" .. tostring(displayScene))
  if not ActivityRedDot._CanProcessRedDot() then
    log(bWriteLog and "ActivityRedDot.BuildSceneFull. Can't Process RedDot")
    return
  end
  local systemName = ActivityRedDot.DisplayScene2SystemName(displayScene)
  if ActivityRedDot.HasBuildFully(systemName) then
    log(bWriteLog and "ActivityRedDot.BuildSceneFull. Has Build Fully")
    return
  end
  ActivityRedDot._InitData()
  ActivityRedDot._UpdateRedDot(displayScene)
end
function ActivityRedDot.RebuildScenesFull()
  for _, displayScene in pairs(ActivityDisplayScene) do
    ActivityRedDot.RebuildSceneFull(displayScene)
  end
end
function ActivityRedDot.RebuildSceneFull(displayScene)
  log(bWriteLog and "ActivityRedDot.RebuildSceneFull. Start! displayScene=" .. tostring(displayScene))
  if not ActivityRedDot._CanProcessRedDot() then
    log(bWriteLog and "ActivityRedDot.RebuildSceneFull. Can't Process RedDot")
    return
  end
  ActivityRedDot._InitData()
  local proxy = ActivityRedDot._GetDataProxy(displayScene)
  if not proxy then
    log_warning(bWriteLog and "ActivityRedDot.RebuildSceneFull. proxy is nil, displayScene=" .. tostring(displayScene))
    return
  end
  local systemName = ActivityRedDot.DisplayScene2SystemName(displayScene)
  RebuildNewRedDotsFromProxy(systemName, proxy, false, false)
  ActivityRedDot.BuildAllRedDotMark[systemName] = true
  RebuildOldRedDotsFromTree(systemName, proxy)
end
function ActivityRedDot.AddRedDotNode(systemName, tabType, tabName, actId, isShow, redDotType)
  if not systemName or systemName == "" then
    return
  end
  if not (tabType and tonumber(tabType)) or tonumber(tabType) <= 0 then
    return
  end
  if not (actId and tonumber(actId)) or tonumber(actId) <= 0 then
    return
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if LogicNewbie.IsNewbie() or not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local SubAct201 = ActivityNewSystem.GetSubAct201()
  if actId and SubAct201[actId] then
    log_warning(bWriteLog and "ActivityRedDot.AddRedDotNode. " .. tostring(actId))
    actId = SubAct201[actId]
  end
  local SubAct46 = ActivityNewSystem.GetSubAct46()
  if actId and SubAct46[actId] then
    log_warning(bWriteLog and "ActivityRedDot.AddRedDotNode. " .. tostring(actId))
    actId = SubAct46[actId]
  end
  tabType = tonumber(tabType)
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  local isH5RedPointShow = ActivityCenterModule:CheckHasH5CenterRedPoint(actId)
  if not ActivityRedDot.RedDotData or not ActivityRedDot.RedDotData[systemName] then
    log_error(bWriteLog and "ActivityRedDot.AddRedDotNode. has not root red point data")
    return
  end
  local redPoint = ActivityRedDot.RedDotData[systemName]
  local newCount = 0
  if isShow or isH5RedPointShow then
    newCount = 1
  end
  if not redDotType then
    if 0 < newCount then
      redDotType = ActivityMacros.RedDotType.Normal
    else
      redDotType = ActivityMacros.RedDotType.None
    end
  end
  local subId = ActivityMacros.RedDotType2SubID[redDotType]
  if not redPoint or not redPoint.pages then
    log_error("ActivityRedDot.AddRedDotNode. has not root red point data")
    return
  end
  if not redPoint.pages[tabType] then
    redPoint.pages[tabType] = GenerateTabData(tabName)
  end
  actId = tonumber(actId)
  local category = ActivityRedDot._GetCategory(actId)
  if not redPoint.pages[tabType].SubTabs[actId] then
    redPoint.pages[tabType].SubTabs[actId] = GenerateActData(actId, subId)
  end
  local leaf = redPoint.pages[tabType].SubTabs[actId]
  leaf.subID = subId
  leaf.  leaf.  if leaf.category ~= category then
    leaf.  end
  local oldWeight = leaf.weight or 0
  local newWeight = ReddotConfig:GetWeight(systemName, leaf)
  leaf.weight = newWeight
  if 0 < newCount and newWeight ~= oldWeight then
    RecomputeAncestorOnWeightChange(leaf)
  end
  ActivityRedDot.CheckSmartAssistantReport(tabType, actId, redDotType)
  log_format("ActivityRedDot.AddRedDotNode. Pages(%s)NewCount=%s", tostring(tabType), tostring(redPoint.pages[tabType].newCount))
  log_warning(bWriteLog and string.format("ActivityRedDot.AddRedDotNode. tabType=%s, tabName=%s, actId=%s, isShow=%s, redDotType=%s", tostring(tabType), tostring(tabName), tostring(actId), tostring(isShow), tostring(redDotType)))
end
function ActivityRedDot.SystemHasRed(displayScene)
  if not displayScene then
    return false
  end
  local systemName = ActivityRedDot.DisplayScene2SystemName(displayScene)
  if ActivityRedDot.RedDotData then
    local redDotData = ActivityRedDot.RedDotData[systemName]
    if redDotData then
      return redDotData.newCount > 0
    end
  end
  return false
end
local getExtraData = function(actId)
  if not actId then
    return nil
  end
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  return ActivityCenterModule:GetExtraSourceData(actId)
end
function ActivityRedDot.ActHasRed(actId)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  if not ActivityRedDot.CheckRedDotSwitcher(actId) then
    return false, ActivityMacros.RedDotType.None
  end
  local extraData = getExtraData(actId)
  if extraData then
    local utility = require("common.utility")
    local func = extraData.data.bRedDot
    if type(func) == "function" then
      local bSuccess, HasRed, redDotType = xpcall(func, utility.ErrorMessageHandler, actId)
      return bSuccess and HasRed or false, redDotType or ActivityMacros.RedDotType.None
    else
      return func
    end
  end
  local activity = ActivityNewSystem.GetActivityByID(actId)
  if not activity then
    return false, ActivityMacros.RedDotType.None
  end
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  if ActivityCenterModule:GetActPageType(activity) == ActivitySwitchType.None or ActivityNewSystem.IsSignInType(activity) then
    return false, ActivityMacros.RedDotType.None
  end
  if activity.TabType == ActivitySwitchType.DragonSpearSpin then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    log(bWriteLog and "ActivityRedDot.ActHasRed.bEnterXMissionReq = " .. tostring(LogicTxMissionMain.bEnterXMissionReq))
    if LogicTxMissionMain.bEnterXMissionReq and ActivityRedDot.CheckNewRedDot(activity.ID, activity.TabType) then
      return true, ActivityMacros.RedDotType.New
    end
    return false, ActivityMacros.RedDotType.None
  end
  local SubAct201 = ActivityNewSystem.GetSubAct201()
  if SubAct201[actId] then
    local FatherID = SubAct201[actId]
    local FatherActData = ActivityNewSystem.GetActivityByID(FatherID)
    local AreaGroupSystem = require("client.slua.logic.activity.commom_activity_center.logic_area_group")
    return AreaGroupSystem.MainActHasRedDot(FatherActData)
  end
  if activity.Type == ActivityType.IMAGES_GROUP then
    if ActivityRedDot.CheckNewRedDot(activity.ID, activity.TabType) then
      return true, ActivityMacros.RedDotType.New
    end
    local LogicMultiBannerActRed = require("client.slua.logic.activity.LogicMultiBannerActRed")
    return LogicMultiBannerActRed.HasAllSubBannerRed(activity, activity.ID)
  end
  local act_red_cfg = require("client.slua.logic.activity.RedPoint.act_red_cfg")
  local redFunc = act_red_cfg[activity.ID]
  if redFunc then
    return redFunc()
  end
  local config = CDataTable.GetTableData("ActivityCenterConfig", activity.Type)
  if not (config and config.ShowType) or NoRedShowTypeTb[config.ShowType] then
    return false, ActivityMacros.RedDotType.None
  end
  local Red, RedDotType = ActivityNewSystem.HasActivityRedDotByID(activity.ID)
  if Red then
    return true, RedDotType
  end
  local brotherId = tonumber(activity.BrotherID)
  if brotherId and ActivityNewSystem.HasActivityRedDotByID(brotherId, true) then
    return true, ActivityMacros.RedDotType.Reward
  end
  if ActivityRedDot.CheckNewRedDot(activity.ID, activity.TabType) then
    return true, ActivityMacros.RedDotType.New
  end
  if ActivityRedDot.CheckEndRedDot(activity.ID, activity) then
    return true, ActivityMacros.RedDotType.End
  end
  return false, ActivityMacros.RedDotType.None
end
function ActivityRedDot.MarkEnterRedDot(actId, actData)
  if not actId then
    return false
  end
  local needUpdateNew = ActivityRedDot.MarkNewRedDot(actId)
  local needUpdateNear = ActivityRedDot.MarkEndRedDot(actId, actData)
  local needUpdateSwitch = needUpdateNew or needUpdateNear
  if needUpdateSwitch then
    local LogicNewbie = require("client.logic.newbie.logic_newbie")
    if not LogicNewbie.IsNewbie() then
      ActivityRedDot.RefreshOneActRedDot(actId)
    end
  end
end
function ActivityRedDot.MarkNewRedDot(actId)
  local needUpdateSwitch = false
  local redPointKey = tostring(actId)
  local bOpenNewRedPoint = ActivityRedDot.CheckNewRedDotSwitcher(actId)
  if not bOpenNewRedPoint then
    return false
  end
  local mergeRedKey = ""
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  local mergeMainId = ActivityCenterModule:GetMergeMainId(actId)
  if mergeMainId then
    mergeRedKey = tostring(mergeMainId)
    if not ActivityRedDot.NewRedDotRecord[mergeRedKey] then
      ActivityRedDot.NewRedDotRecord[mergeRedKey] = true
      PlayerPrefsSystem.SaveTableToFile_N(ActivityRedDot.NewRedDotRecord, PlayerPrefsSystem.ePlayerPrefsType.eActivityCenterRedPoint)
      needUpdateSwitch = true
    end
  end
  if not ActivityRedDot.NewRedDotRecord[redPointKey] then
    ActivityRedDot.NewRedDotRecord[redPointKey] = true
    PlayerPrefsSystem.SaveTableToFile_N(ActivityRedDot.NewRedDotRecord, PlayerPrefsSystem.ePlayerPrefsType.eActivityCenterRedPoint)
    needUpdateSwitch = true
  end
  return needUpdateSwitch
end
function ActivityRedDot.MarkEndRedDot(actId, actData)
  if not actId or actId == 0 then
    return false
  end
  if not actData then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    actData = ActivityNewSystem.GetActivityByID(actId)
    if not actData then
      return false
    end
  end
  local EndTime = actData.EndTime
  local EndingTime = EndTime - 259200
  if TimeUtil.UnixTimeBetween(EndingTime, EndTime) ~= 0 then
    return false
  end
  local needUpdateSwitch = false
  local redPointKey = tostring(actId)
  local mergeRedKey = ""
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  local mergeMainId = ActivityCenterModule:GetMergeMainId(actId)
  if mergeMainId then
    mergeRedKey = tostring(mergeMainId)
    if ActivityRedDot.CheckEndRedDot(mergeRedKey) then
      ActivityRedDot.EndRedDotRecord[mergeRedKey] = true
      PlayerPrefsSystem.SaveTableToFile_N(ActivityRedDot.EndRedDotRecord, PlayerPrefsSystem.ePlayerPrefsType.eActivityCenterEndingRedPoint)
      needUpdateSwitch = true
    end
  end
  if ActivityRedDot.CheckEndRedDot(redPointKey) then
    ActivityRedDot.EndRedDotRecord[redPointKey] = true
    PlayerPrefsSystem.SaveTableToFile_N(ActivityRedDot.EndRedDotRecord, PlayerPrefsSystem.ePlayerPrefsType.eActivityCenterEndingRedPoint)
    needUpdateSwitch = true
  end
  return needUpdateSwitch
end
function ActivityRedDot.CheckNewRedDot(actId, Type)
  if not actId then
    return false
  end
  local bOpenNewRedPoint = ActivityRedDot.CheckNewRedDotSwitcher(actId)
  if not bOpenNewRedPoint then
    return false
  end
  Type = Type or ActivitySwitchType.None
  if Type == ActivitySwitchType.Return then
    return false
  end
  if ActivityRedDot.NewRedDotRecord[tostring(actId)] then
    return false
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local act = ActivityNewSystem.GetActivityByID(actId)
  if act then
    local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
    if not ActivityUtil.IsInActivityRealTime(act) then
      return false
    end
  end
  return true
end
function ActivityRedDot.CheckShouldBuildFully()
  local IsUIShow = UIManager.IsUIShow(UIManager.UI_Config.ActivityCenter_Main_UIBP)
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  local IsLoading = LoadingSystem.IsShowing()
  return IsUIShow and not IsLoading
end
function ActivityRedDot.CheckNewRedDotITopNotice(noticeData)
  if not noticeData then
    return false
  end
  if (noticeData.ActivityRedPointStatus == ActivityRedPointStatus.AllowGiftNormalNew or noticeData.ActivityRedPointStatus == ActivityRedPointStatus.AllowGiftNormalNewCountdown or noticeData.ActivityRedPointStatus == ActivityRedPointStatus.AllowGiftNormalNewCountdownReport) and not ActivityRedDot.NewRedDotRecord[tostring(noticeData.MsgId)] then
    return true
  end
  return false
end
function ActivityRedDot.CheckEndRedDot(actId, actData)
  if not actId then
    return false
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  actId = tonumber(actId)
  if not actData then
    actData = ActivityNewSystem.GetActivityByID(actId)
    if not actData then
      return false
    end
  end
  local bOpenCountDownRedPoint = ActivityRedDot.CheckCountDownRedDotSwitcher(actId)
  if not bOpenCountDownRedPoint then
    return false
  end
  if actData.Type == ActivityType.NOTICE_INFO then
    return false
  end
  local TabType = actData.TabType
  if not ActivityRedDot.EndRedDotRecord[tostring(actId)] then
    local EndTime = actData.EndTime
    local EndingTime = EndTime - 259200
    if TimeUtil.UnixTimeBetween(EndingTime, EndTime) == 0 then
      return true
    end
  end
  return false
end
function ActivityRedDot.HasBuildFully(systemName)
  return ActivityRedDot.BuildAllRedDotMark and ActivityRedDot.BuildAllRedDotMark[systemName] and ActivityRedDot.BuildAllRedDotMark[systemName] == true
end
function ActivityRedDot.ResetBuildFully()
  if not ActivityRedDot.BuildAllRedDotMark then
    return
  end
  for key, systemName in pairs(ActivityMacros.DisplayScene2SystemName) do
    ActivityRedDot.BuildAllRedDotMark[systemName] = false
  end
end
function ActivityRedDot.GetActFirstRedDotSystemName(actId, actData)
  if not actId or actId == 0 then
    return ""
  end
  local displayScene
  if not actData then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    actData = ActivityNewSystem.GetActivityByID(actId)
    if actData then
      displayScene = next(actData.DisplayScene)
    else
      actData = getExtraData(actId)
      if actData then
        if actData.data and actData.data.DisplayScene then
          displayScene = next(actData.data.DisplayScene)
        else
          displayScene = ActivityDisplayScene.Default
        end
      else
        local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
        local noticeData = ActivityCenterModule:GetNoticeSourceData(actId)
        if noticeData then
          displayScene = ActivityDisplayScene.Default
        end
      end
    end
  end
  local systemName = ActivityRedDot.DisplayScene2SystemName(displayScene)
  return systemName
end
function ActivityRedDot.DisplayScene2SystemName(displayScene)
  if not displayScene then
    return ""
  end
  return ActivityMacros.DisplayScene2SystemName[displayScene]
end
function ActivityRedDot._InitData()
  if ActivityRedDot.IsInit then
    return
  end
  ActivityRedDot.IsInit = true
  ActivityRedDot.NewRedDotRecord = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eActivityCenterRedPoint) or {}
  ActivityRedDot.EndRedDotRecord = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eActivityCenterEndingRedPoint) or {}
  ActivityRedDot.RedDotData = {}
  ActivityRedDot.BuildAllRedDotMark = {}
  local super_data = require("common.super_data")
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  for _, systemName in ipairs(ActivityMacros.SubActivitySystemName) do
    local data = GenerateRootData(systemName)
    local redPoint = super_data.CreateSuperData(data)
    local registData = redPoint
    if ActivityMacros.NeedWrapperSystemName[systemName] then
      local wrapperData = GenerateRootData(systemName)
      redPoint[systemName] = wrapperData
      registData = redPoint[systemName]
    end
    if not reddot_manager:IsRegist(systemName) then
      reddot_manager:Regist(redPoint)
    end
    ActivityRedDot.RedDotData[systemName] = registData
  end
end
function ActivityRedDot._CanProcessRedDot()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if LogicNewbie.IsNewbie() then
    log(bWriteLog and "ActivityRedDot._CanProcessRedDot. IsNewbie")
    return false
  end
  return true
end
function ActivityRedDot._GetDataProxy(displayScene)
  if not displayScene then
    return nil
  end
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  ActivityCenterModule:BuildDisplaySceneData(displayScene)
  return ActivityCenterModule:GetDataProxy(displayScene)
end
function ActivityRedDot._UpdateEntranceRedDot(displayScene)
  local systemName = ActivityRedDot.DisplayScene2SystemName(displayScene)
  local bFullyBuilt, bHitRewardRedDot = ActivityRedDot._BuildRedDotFromProxy(systemName, displayScene, true)
  if bFullyBuilt then
    ActivityRedDot.BuildAllRedDotMark[systemName] = true
  end
end
function ActivityRedDot._UpdateRedDot(displayScene)
  local systemName = ActivityMacros.DisplayScene2SystemName[displayScene] or reddot_macro.SystemName.ActivityCenter
  local bFullyBuilt = ActivityRedDot._BuildRedDotFromProxy(systemName, displayScene, false)
  if bFullyBuilt then
    ActivityRedDot.BuildAllRedDotMark[systemName] = true
  end
end
function ActivityRedDot._ResolveRedDotByTabInfo(tabInfo)
  if not tabInfo then
    return nil, nil
  end
  local actId = tabInfo.nActID
  if not actId or actId <= 0 then
    return nil, nil
  end
  local E_TabInfoSource = ActivityMacros.ActTabInfoSource
  if tabInfo.eSource == E_TabInfoSource.Extra then
    return ActivityRedDot._ResolveExtraRedDot(tabInfo)
  elseif tabInfo.eSource == E_TabInfoSource.Notice then
    return ActivityRedDot._ResolveNoticeRedDot(tabInfo)
  else
    local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
    if ActivityCenterModule:GetMergeBrotherId(actId) then
      return nil, nil
    end
    return ActivityRedDot.ActHasRed(actId)
  end
end
function ActivityRedDot.RefreshOneActRedDot(actId)
  if not actId or actId <= 0 then
    return false
  end
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  local brotherId = ActivityCenterModule:GetMergeBrotherId(actId)
  if brotherId then
    log_warning(bWriteLog and string.format("ActivityRedDot.RefreshOneActRedDot. brother redirect actId=%s -> %s", tostring(actId), tostring(brotherId)))
    actId = brotherId
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local SubAct201 = ActivityNewSystem.GetSubAct201()
  if SubAct201[actId] then
    actId = SubAct201[actId]
  end
  local bRefreshed = false
  for _, displayScene in pairs(ActivityDisplayScene) do
    local proxy = ActivityRedDot._GetDataProxy(displayScene)
    if proxy then
      local tabInfo = proxy:GetActTabInfo(actId)
      if tabInfo then
        local bShowRedHot, redDotType = ActivityRedDot._ResolveRedDotByTabInfo(tabInfo)
        if bShowRedHot ~= nil then
          redDotType = redDotType or ActivityMacros.RedDotType.None
          local switchType = tabInfo.nSwitchType
          if switchType and 0 < switchType then
            local systemName = ActivityRedDot.DisplayScene2SystemName(displayScene)
            local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
            local tabName = ActivityUtil.GetTabName(switchType)
            ActivityRedDot.AddRedDotNode(systemName, switchType, tabName, actId, bShowRedHot, redDotType)
            bRefreshed = true
          end
        end
      end
    end
  end
  log_warning(bWriteLog and string.format("ActivityRedDot.RefreshOneActRedDot. actId=%s, bRefreshed=%s", tostring(actId), tostring(bRefreshed)))
  return bRefreshed
end
function ActivityRedDot._BuildRedDotFromProxy(systemName, displayScene, HasRedDotReturnImme)
  local proxy = ActivityRedDot._GetDataProxy(displayScene)
  if not proxy then
    log_warning(bWriteLog and "ActivityRedDot._BuildRedDotFromProxy. proxy is nil, displayScene=" .. tostring(displayScene))
    return false, false
  end
  local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
  local groups = proxy:GetAllGroups()
  local remainSwitchCount = 0
  for _, __ in pairs(groups) do
    remainSwitchCount = remainSwitchCount + 1
  end
  local bHitRewardRedDot = false
  local bInterrupted = false
  for switchType, tabList in pairs(groups) do
    if switchType and 0 < switchType then
      local bBreakInner = false
      for index, tabInfo in ipairs(tabList) do
        local actId = tabInfo.nActID
        if actId and 0 < actId then
          local bShowRedHot, redDotType = ActivityRedDot._ResolveRedDotByTabInfo(tabInfo)
          if bShowRedHot ~= nil then
            redDotType = redDotType or ActivityMacros.RedDotType.None
            local tabName = ActivityUtil.GetTabName(switchType)
            ActivityRedDot.AddRedDotNode(systemName, switchType, tabName, actId, bShowRedHot, redDotType)
            if bShowRedHot and redDotType == ActivityMacros.RedDotType.Reward then
              bHitRewardRedDot = true
              if HasRedDotReturnImme then
                if index < #tabList then
                  bInterrupted = true
                end
                bBreakInner = true
                break
              end
            end
          end
        end
      end
      remainSwitchCount = remainSwitchCount - 1
      if bBreakInner then
        if 0 < remainSwitchCount then
          bInterrupted = true
        end
        break
      end
    end
  end
  local bFullyBuilt = not bInterrupted
  return bFullyBuilt, bHitRewardRedDot
end
function ActivityRedDot._ResolveExtraRedDot(tabInfo)
  local RedDotType = ActivityMacros.RedDotType.None
  local actId = tabInfo.nActID
  if not ActivityRedDot.CheckRedDotSwitcher(actId) then
    return false, RedDotType
  end
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  local sourceData = ActivityCenterModule and ActivityCenterModule:GetExtraSourceData(actId) or nil
  local data = sourceData and sourceData.data or nil
  if not data then
    return false, RedDotType
  end
  local bShowRedHot = false
  if type(data.nRedDotNum) == "function" then
    local Num = 0
    Num, RedDotType = data.nRedDotNum(actId)
    if Num and 0 < Num then
      bShowRedHot = true
    end
  end
  if not bShowRedHot and type(data.bRedDot) == "function" then
    bShowRedHot, RedDotType = data.bRedDot(actId)
  end
  if not bShowRedHot and ActivityRedDot.CheckNewRedDotSwitcher(actId) then
    bShowRedHot = ActivityRedDot.CheckNewRedDot(actId, tabInfo.nSwitchType)
    if bShowRedHot then
      RedDotType = ActivityMacros.RedDotType.New
    end
  end
  return bShowRedHot or false, RedDotType or ActivityMacros.RedDotType.None
end
function ActivityRedDot._ResolveNoticeRedDot(tabInfo)
  local noticeData = tabInfo.tRawRef
  if not noticeData then
    return false, ActivityMacros.RedDotType.None
  end
  local bShowRedHot = ActivityRedDot.CheckNewRedDotITopNotice(noticeData)
  local redDotType = bShowRedHot and ActivityMacros.RedDotType.New or ActivityMacros.RedDotType.None
  return bShowRedHot, redDotType
end
function ActivityRedDot.CheckRedDotSwitcher(actId)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByID(actId)
  if actData then
    return actData.RedPointSwitcher ~= ActivityRedPointStatus.ForceCloseAll
  end
  local SubAct46 = ActivityNewSystem.GetSubAct46()
  if SubAct46[actId] then
    local fatherID = SubAct46[actId]
    local fatherActData = ActivityNewSystem.GetActivityByID(fatherID)
    if fatherActData and next(fatherActData.List) then
      for _, subActData in ipairs(fatherActData.List) do
        if subActData.ID == actId then
          return subActData.RedPointSwitcher ~= ActivityRedPointStatus.ForceCloseAll
        end
      end
    end
  end
  local extraData = getExtraData(actId)
  if extraData then
    local localCfg = CDataTable.GetTableData("LocalActConfig", actId)
    if localCfg then
      return localCfg.ActivityRedPointStatus ~= ActivityRedPointStatus.ForceCloseAll
    end
  end
  return false
end
function ActivityRedDot.CheckNewRedDotSwitcher(actId)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByID(actId)
  if actData then
    return actData.RedPointSwitcher == ActivityRedPointStatus.AllowGiftNormalNew or actData.RedPointSwitcher == ActivityRedPointStatus.AllowGiftNormalNewCountdown or actData.RedPointSwitcher == ActivityRedPointStatus.AllowGiftNormalNewCountdownReport
  end
  local SubAct46 = ActivityNewSystem.GetSubAct46()
  if SubAct46[actId] then
    local fatherID = SubAct46[actId]
    local fatherActData = ActivityNewSystem.GetActivityByID(fatherID)
    if fatherActData and next(fatherActData.List) then
      for _, subActData in ipairs(fatherActData.List) do
        if subActData.ID == actId then
          return subActData.RedPointSwitcher == ActivityRedPointStatus.AllowGiftNormalNew or subActData.RedPointSwitcher == ActivityRedPointStatus.AllowGiftNormalNewCountdown or subActData.RedPointSwitcher == ActivityRedPointStatus.AllowGiftNormalNewCountdownReport
        end
      end
    end
  end
  local extraData = getExtraData(actId)
  if extraData then
    local localCfg = CDataTable.GetTableData("LocalActConfig", actId)
    if localCfg then
      return localCfg.ActivityRedPointStatus == ActivityRedPointStatus.AllowGiftNormalNew or localCfg.ActivityRedPointStatus == ActivityRedPointStatus.AllowGiftNormalNewCountdown or localCfg.ActivityRedPointStatus == ActivityRedPointStatus.AllowGiftNormalNewCountdownReport
    end
  end
  return false
end
function ActivityRedDot.CheckCountDownRedDotSwitcher(actId)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByID(actId)
  if actData then
    return actData.RedPointSwitcher == ActivityRedPointStatus.AllowGiftNormalNewCountdown or actData.RedPointSwitcher == ActivityRedPointStatus.AllowGiftNormalNewCountdownReport
  end
  local SubAct46 = ActivityNewSystem.GetSubAct46()
  if SubAct46[actId] then
    local fatherID = SubAct46[actId]
    local fatherActData = ActivityNewSystem.GetActivityByID(fatherID)
    if fatherActData and next(fatherActData.List) then
      for _, subActData in ipairs(fatherActData.List) do
        if subActData.ID == actId then
          return subActData.RedPointSwitcher == ActivityRedPointStatus.AllowGiftNormalNewCountdown or subActData.RedPointSwitcher == ActivityRedPointStatus.AllowGiftNormalNewCountdownReport
        end
      end
    end
  end
  local extraData = getExtraData(actId)
  if extraData then
    local localCfg = CDataTable.GetTableData("LocalActConfig", actId)
    if localCfg then
      return localCfg.ActivityRedPointStatus == ActivityRedPointStatus.AllowGiftNormalNewCountdown or localCfg.ActivityRedPointStatus == ActivityRedPointStatus.AllowGiftNormalNewCountdownReport
    end
  end
  return false
end
function ActivityRedDot._GetTabType(activity)
  local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  local pageType = ActivityCenterModule:GetActPageType(activity)
  if not NoRedShowTypeTb[pageType] and activity and activity.TabType and ActivityUtil.IsCurActSwitchTypeInCenter(activity) then
    return activity.TabType
  end
  return 0
end
function ActivityRedDot._GetActivityCenterConfigData(actID)
  activityConfig.StartCache()
  for i, cfg in ipairs(activityConfig) do
    local data = activityConfig.DoAction(i, cfg)
    if data and data.nActID == actID then
      if 0 < #data then
        for _, subData in ipairs(data) do
          if subData.nActID == actID then
            return {data = subData, cfg = cfg}
          end
        end
      elseif data.nActID == actID then
        return {data = data, cfg = cfg}
      end
    end
  end
  return nil
end
function ActivityRedDot._GetActivityData(actID)
  local activityData
  activityData = ActivityRedDot._GetActivityCenterConfigData(actID)
  if activityData and activityData.data and activityData.data.sName then
    return activityData
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  activityData = ActivityNewSystem.GetActivityByID(actID)
  return activityData
end
function ActivityRedDot._GetAwardListByActivity(awardList, activityData)
  awardList = awardList or {}
  if activityData and activityData.List and #activityData.List > 0 then
    local reddotUtil = require("client.slua.logic.reddot.reddot_util")
    for _, v in pairs(activityData.List) do
      if v.Status == 1 then
        log_tree("  ActivityRedDot.GetAwardListByActivity. activityData.List ", activityData.List)
      end
      if v.Status == 1 and v.Drop and 0 < #v.Drop then
        for _, vv in pairs(v.Drop) do
          table.insert(awardList, reddotUtil.CreateItem(vv.itemId, vv.count, vv.expireTime))
        end
      end
    end
  end
  return awardList
end
function ActivityRedDot._GetCenterAwardList(instanceKey)
  local activityData = ActivityRedDot._GetActivityData(instanceKey)
  local awardList = {}
  if activityData and activityData.cfg and activityData.cfg.moduleName then
    local module = require(activityData.cfg.moduleName)
    if module and module.GetCanReceiveAwards and type(module.GetCanReceiveAwards) == "function" then
      awardList = module.GetCanReceiveAwards(instanceKey)
    end
  end
  log_warning(bWriteLog and "  ActivityRedDot.GetCenterAwardList. instanceKey: " .. tostring(instanceKey))
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  if activityData and activityData.Type == ActivityType.ACTIVITY_TYPE_AREA_GROUP then
    local string_util = require("common.string_util")
    if activityData.Condition then
      local conditions = string_util.SplitToNum(activityData.Condition, ",")
      for _, id in ipairs(conditions) do
        if id ~= 0 then
          local condAct = ActivityNewSystem.GetActivityByID(id)
          log_tree("  ActivityRedDot.GetCenterAwardList. condAct ", condAct)
          awardList = ActivityRedDot._GetAwardListByActivity(awardList, condAct)
          if 0 < #awardList then
            log_tree("  ActivityRedDot.GetCenterAwardList. awardList ", awardList)
          end
        end
      end
    end
  elseif not awardList or #awardList <= 0 then
    awardList = ActivityRedDot._GetAwardListByActivity(awardList, activityData)
  end
  return awardList
end
function ActivityRedDot._GetCategory(instanceKey)
  local awardList = ActivityRedDot._GetCenterAwardList(instanceKey)
  local category = reddot_macro.Category.NewArrivals
  if awardList and 0 < #awardList then
    category = reddot_macro.Category.Receive
  end
  return category
end
function ActivityRedDot.CheckSmartAssistantReport(tabType, actId, redDotType)
  local SmartAssistantActivityModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.SmartAssistantActivityModule)
  local SmartAssistantActivityConfig = require("client.slua.logic.activity.SmartAssistant.SmartAssistantActivityConfig")
  if redDotType == ActivityMacros.RedDotType.Reward then
    SmartAssistantActivityModule:SaveOperationActivity(actId, SmartAssistantActivityConfig.CONST.ActChangeType.RewardCollection)
    if tabType == ActivitySwitchType.Xmission then
      SmartAssistantActivityModule:SaveMetroWeekTask(actId, SmartAssistantActivityConfig.CONST.ActChangeType.RewardCollection)
    end
  elseif redDotType == ActivityMacros.RedDotType.Normal then
    SmartAssistantActivityModule:SaveOperationActivity(actId, SmartAssistantActivityConfig.CONST.ActChangeType.TaskReminder)
  elseif redDotType == ActivityMacros.RedDotType.None then
    SmartAssistantActivityModule:SaveOperationActivity(actId, SmartAssistantActivityConfig.CONST.ActChangeType.None)
    if tabType == ActivitySwitchType.Xmission then
      SmartAssistantActivityModule:SaveMetroWeekTask(actId, SmartAssistantActivityConfig.CONST.ActChangeType.None)
    end
  end
end
return ActivityRedDot