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
    local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
    local isCenterRedPoint = ActivityCenterSystem.CheckHasH5CenterRedPoint(actId)
    if isCenterRedPoint then
      redData.newCount = 1
      redData.redDotType = ActivityMacros.RedDotType.Normal
    end
    log(bWriteLog and "ActivityRedDot.GetRedDotData" .. " ID=" .. tostring(tabType) .. " subID=" .. tostring(actId) .. " newCount=" .. tostring(redData.newCount))
  end
  return redData
end
function ActivityRedDot.UpdateAllRedDotAdaptively()
  local uiDisplayScene
  if UIManager.IsUIShow(UIManager.UI_Config.new_activity_center) then
    local Activity_UIBP = UIManager.GetUI(UIManager.UI_Config.new_activity_center)
    uiDisplayScene = Activity_UIBP and Activity_UIBP:GetDisplayScene()
  end
  for key, value in pairs(ActivityDisplayScene) do
    if value ~= uiDisplayScene then
      ActivityRedDot.UpdateRedDotAdaptively(value)
    end
  end
  if uiDisplayScene then
    ActivityRedDot.UpdateRedDotAdaptively(uiDisplayScene)
  end
end
function ActivityRedDot.BuildAllSystemAllRedDotOnce()
  for key, value in pairs(ActivityDisplayScene) do
    local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
    ActivityCenterSystem.InitCenterData(value)
    ActivityCenterSystem.SortCenterData()
    ActivityRedDot.BuildAllRedDotOnce(value)
  end
end
function ActivityRedDot.UpdateRedDotAdaptively(displayScene)
  log(bWriteLog and "ActivityRedDot.UpdateRedDotAdaptively. Start! displayScene=" .. tostring(displayScene))
  if not ActivityRedDot._CanProcessRedDot() then
    log(bWriteLog and "ActivityRedDot.UpdateRedDotAdaptively. Can't Process RedDot")
    return
  end
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  local IsLoading = LoadingSystem.IsShowing()
  if IsLoading and ActivityRedDot.SystemHasRed(displayScene) then
    log(bWriteLog and "ActivityRedDot.UpdateRedDotAdaptively. In Loading and Has RedPoint, don't build red dot!")
    return false
  end
  local isUIShow = UIManager.IsUIShow(UIManager.UI_Config.new_activity_center)
  local uiDisplayScene
  if isUIShow then
    local Activity_UIBP = UIManager.GetUI(UIManager.UI_Config.new_activity_center)
    uiDisplayScene = Activity_UIBP and Activity_UIBP:GetDisplayScene()
  end
  local needRestoreUIData = isUIShow and uiDisplayScene and uiDisplayScene ~= displayScene
  local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
  ActivityCenterSystem.InitCenterData(displayScene)
  if isUIShow then
    ActivityCenterSystem.SortCenterData()
  end
  ActivityRedDot._InitData()
  if IsLoading then
    ActivityRedDot._UpdateRedDotInLoading(displayScene)
  else
    ActivityRedDot._UpdateRedDot(displayScene)
  end
  if needRestoreUIData then
    log(bWriteLog and "ActivityRedDot.UpdateRedDotAdaptively. Restore UI scene data, uiDisplayScene=" .. tostring(uiDisplayScene))
    ActivityCenterSystem.InitCenterData(uiDisplayScene)
    ActivityCenterSystem.SortCenterData()
  end
end
function ActivityRedDot.BuildAllRedDotOnce(displayScene)
  log(bWriteLog and "ActivityRedDot.BuildAllRedDotOnce. Start!")
  if not ActivityRedDot._CanProcessRedDot() then
    log(bWriteLog and "ActivityRedDot.BuildAllRedDotOnce. Can't Process RedDot")
    return
  end
  ActivityRedDot._InitData()
  local systemName = ActivityRedDot.DisplayScene2SystemName(displayScene)
  if ActivityRedDot.HasForceUpdateAllDone(systemName) then
    log(bWriteLog and "ActivityRedDot.BuildAllRedDotOnce. Has Force Update All Done")
    return
  end
  ActivityRedDot._UpdateRedDot(displayScene)
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
  local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
  local isH5RedPointShow = ActivityCenterSystem.CheckHasH5CenterRedPoint(actId)
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
    redPoint.pages[tabType].SubTabs[actId] = GenerateActData(tabType, subId)
  end
  redPoint.pages[tabType].SubTabs[actId].subID = subId
  redPoint.pages[tabType].SubTabs[actId].  redPoint.pages[tabType].SubTabs[actId].  if redPoint.pages[tabType].SubTabs[actId].category ~= category then
    redPoint.pages[tabType].SubTabs[actId].  end
  ActivityRedDot.CheckSmartAssistantReport(tabType, actId, redDotType)
  log_format("ActivityRedDot.AddRedDotNode. Pages(%s)NewCount=%s", tostring(tabType), tostring(redPoint.pages[tabType].newCount))
  log_warning(bWriteLog and string.format("ActivityRedDot.AddRedDotNode. tabType=%s, tabName=%s, actId=%s, isShow=%s, redDotType=%s", tostring(tabType), tostring(tabName), tostring(actId), tostring(isShow), tostring(redDotType)))
end
function ActivityRedDot.RemoveRedDotNode(systemName, tabType, actId, bData)
  local redPointData = ActivityRedDot.GetRedDotData(systemName, tabType, actId)
  local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
  local isH5RedPointShow = ActivityCenterSystem.CheckHasH5CenterRedPoint(actId)
  if redPointData and not isH5RedPointShow then
    redPointData.newCount = 0
    redPointData.redDotType = ActivityMacros.RedDotType.None
  end
  if bData then
    ActivityRedDot.NewRedDotRecord[tostring(tabType)] = true
  end
end
function ActivityRedDot.ClearAllRedDot()
  log(bWriteLog and "ActivityRedDot.ClearAllRedDot. Start!")
  if not ActivityRedDot.RedDotData or not next(ActivityRedDot.RedDotData) then
    log(bWriteLog and "ActivityRedDot.ClearAllRedDot. RedDotData is nil")
    return
  end
  ActivityRedDot.BuildAllRedDotMark = {}
  for systemName, redData in pairs(ActivityRedDot.RedDotData) do
    local pages = redData.pages
    if pages then
      for _, v in pairs(pages) do
        if type(v) == "table" and v.SubTabs then
          for _, oneAct in pairs(v.SubTabs) do
            if type(oneAct) == "table" then
              oneAct.newCount = 0
              oneAct.redDotType = ActivityMacros.RedDotType.None
            end
          end
        end
      end
    end
  end
  log(bWriteLog and "ActivityRedDot.ClearAllRedDot. Done!")
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
  local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
  return ActivityCenterSystem.extraActivityData and ActivityCenterSystem.extraActivityData[actId]
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
  local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
  if ActivityCenterSystem.GetActPageType(activity) == ActivitySwitchType.None or ActivityNewSystem.IsSignInType(activity) then
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
      local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
      ActivityCenterSystem.RefreshActRedById(actId)
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
  local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
  if ActivityCenterSystem.mergeActivityList[actId] then
    mergeRedKey = tostring(ActivityCenterSystem.mergeActivityList[actId])
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
  local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
  if ActivityCenterSystem.mergeActivityList[actId] then
    mergeRedKey = tostring(ActivityCenterSystem.mergeActivityList[actId])
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
  if Type == ActivitySwitchType.Activity and act and ActivityNewSystem.IsAllDone(act, Type) then
    return false
  end
  return true
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
    if TabType == ActivitySwitchType.Activity then
      local act = ActivityNewSystem.GetActivityByID(actId)
      if ActivityNewSystem.IsAllDone(act, TabType) then
        return false
      end
    end
    local EndTime = actData.EndTime
    local EndingTime = EndTime - 259200
    if TimeUtil.UnixTimeBetween(EndingTime, EndTime) == 0 then
      return true
    end
  end
  return false
end
function ActivityRedDot.HasForceUpdateAllDone(systemName)
  return ActivityRedDot.BuildAllRedDotMark and ActivityRedDot.BuildAllRedDotMark[systemName] and ActivityRedDot.BuildAllRedDotMark[systemName] == true
end
function ActivityRedDot.SetForceAllUpdateAllDone(value)
  for key, systemName in pairs(ActivityMacros.DisplayScene2SystemName) do
    ActivityRedDot.SetForceUpdateAllDone(systemName, value)
  end
end
function ActivityRedDot.SetForceUpdateAllDone(systemName, value)
  if ActivityRedDot.BuildAllRedDotMark then
    ActivityRedDot.BuildAllRedDotMark[systemName] = value
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
        local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
        local noticeData = ActivityCenterSystem.GetNoticesData(actId)
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
function ActivityRedDot._UpdateRedDotInLoading(displayScene)
  local systemName = ActivityRedDot.DisplayScene2SystemName(displayScene)
  local HasRedDot = false
  HasRedDot = HasRedDot or ActivityRedDot._RefreshActRedData(systemName, displayScene, true)
  if HasRedDot then
    log(bWriteLog and "ActivityRedDot._UpdateRedDotInLoading. Act Red Data has red point!")
    ActivityRedDot.HasRedPointInLoading = true
    return
  end
  HasRedDot = HasRedDot or ActivityRedDot._RefreshExtraActRedData(systemName, displayScene, true)
  if HasRedDot then
    log(bWriteLog and "ActivityRedDot._UpdateRedDotInLoading. Extra Act Red Data has red point!")
    ActivityRedDot.HasRedPointInLoading = true
    return
  end
  HasRedDot = HasRedDot or ActivityRedDot._RefreshNoticeRedData(systemName, displayScene, true)
  ActivityRedDot.BuildAllRedDotMark[systemName] = true
  if HasRedDot then
    log(bWriteLog and "ActivityRedDot._UpdateRedDotInLoading. Notice Act Red Data has red point!")
    ActivityRedDot.HasRedPointInLoading = true
    return
  end
end
function ActivityRedDot._UpdateRedDot(displayScene)
  local systemName = ActivityMacros.DisplayScene2SystemName[displayScene] or reddot_macro.SystemName.ActivityCenter
  ActivityRedDot._RefreshActRedData(systemName, displayScene)
  ActivityRedDot._RefreshExtraActRedData(systemName, displayScene)
  ActivityRedDot._RefreshNoticeRedData(systemName, displayScene)
  ActivityRedDot.BuildAllRedDotMark[systemName] = true
end
function ActivityRedDot._RefreshActRedData(systemName, displayScene, HasRedDotReturnImme)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
  local activityData = ActivityNewSystem.GetActivity()
  local bShowRedHot = false
  local TabName = ""
  for _, activity in ipairs(activityData) do
    local TabType = ActivityRedDot._GetTabType(activity)
    if 0 < TabType and not ActivityCenterSystem.GetBrotherId(activity.ID) and activity.DisplayScene[displayScene] then
      local RedDotType = ActivityMacros.RedDotType.None
      bShowRedHot, RedDotType = ActivityRedDot.ActHasRed(activity.ID)
      TabName = ActivityCenterSystem.GetTabName(TabType)
      ActivityRedDot.AddRedDotNode(systemName, TabType, TabName, activity.ID, bShowRedHot, RedDotType)
      if bShowRedHot and HasRedDotReturnImme and RedDotType == ActivityMacros.RedDotType.Reward then
        return bShowRedHot
      end
    end
  end
  return bShowRedHot
end
local _ProcessExtraRedDot = function(systemName, displayScene, cfg, data, limitTabTypes)
  local bShowRedHot = false
  local RedDotType = ActivityMacros.RedDotType.None
  local TabType = data.nSwitchType or cfg.switchType
  if TabType <= 0 or limitTabTypes and not limitTabTypes[TabType] then
    return bShowRedHot, RedDotType
  end
  if not data.DisplayScene and displayScene ~= ActivityDisplayScene.Default then
    return bShowRedHot, RedDotType
  elseif data.DisplayScene and not data.DisplayScene[displayScene] then
    return bShowRedHot, RedDotType
  end
  local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
  local TabName = ActivityCenterSystem.GetTabName(TabType)
  if not ActivityRedDot.CheckRedDotSwitcher(data.nActID) then
    ActivityRedDot.AddRedDotNode(systemName, TabType, TabName, data.nActID, bShowRedHot, RedDotType)
    return bShowRedHot, RedDotType
  end
  if type(data.nRedDotNum) == "function" then
    local Num = 0
    Num, RedDotType = data.nRedDotNum(data.nActID)
    if 0 < Num then
      bShowRedHot = true
    end
  end
  if not bShowRedHot and type(data.bRedDot) == "function" then
    bShowRedHot, RedDotType = data.bRedDot(data.nActID)
  end
  if not bShowRedHot and ActivityRedDot.CheckNewRedDotSwitcher(data.nActID) then
    bShowRedHot = ActivityRedDot.CheckNewRedDot(data.nActID, cfg.switchType or data.nSwitchType)
    if bShowRedHot then
      RedDotType = ActivityMacros.RedDotType.New
    end
  end
  ActivityRedDot.AddRedDotNode(systemName, TabType, TabName, data.nActID, bShowRedHot, RedDotType)
  return bShowRedHot, RedDotType
end
function ActivityRedDot._RefreshExtraActRedData(SystemName, displayScene, HasRedDotReturnImme, TabTypes)
  local bShowRedHot = false
  local RedDotType
  for i, cfg in ipairs(activityConfig) do
    local data = activityConfig.DoAction(i, cfg)
    if data then
      if 0 < #data then
        for _, subData in ipairs(data) do
          bShowRedHot, RedDotType = _ProcessExtraRedDot(SystemName, displayScene, cfg, subData, TabTypes)
          if bShowRedHot and HasRedDotReturnImme and RedDotType == ActivityMacros.RedDotType.Reward then
            return bShowRedHot
          end
        end
      else
        bShowRedHot, RedDotType = _ProcessExtraRedDot(SystemName, displayScene, cfg, data, TabTypes)
        if bShowRedHot and HasRedDotReturnImme and RedDotType == ActivityMacros.RedDotType.Reward then
          return bShowRedHot
        end
      end
    end
  end
  return bShowRedHot
end
function ActivityRedDot._RefreshNoticeRedData(SystemName, displayScene, HasRedDotReturnImme)
  if displayScene ~= ActivityDisplayScene.Default then
    return
  end
  local bShowRedHot = false
  local subName = ""
  local NoticesUtil = require("client.logic.Notice.NoticesUtil")
  local NoticesConst = require("client.logic.Notice.NoticesConst")
  local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
  local activityNotices = NoticesUtil.GetActivityNoticeArray()
  if activityNotices then
    for _, v in pairs(activityNotices) do
      if tonumber(v.MsgContentType) == NoticesConst.NoticeContentType.Text and v.MsgContent ~= "" or tonumber(v.MsgContentType) == NoticesConst.NoticeContentType.ImageOrBlueprint and v.EventCenter ~= "" then
        bShowRedHot = ActivityRedDot.CheckNewRedDotITopNotice(v)
        subName = ActivityCenterSystem.GetTabName(ActivitySwitchType.Notice)
        local redDotType = bShowRedHot and ActivityMacros.RedDotType.New or ActivityMacros.RedDotType.None
        ActivityRedDot.AddRedDotNode(SystemName, ActivitySwitchType.Notice, subName, tonumber(v.MsgId), bShowRedHot, redDotType)
      end
      if bShowRedHot and HasRedDotReturnImme then
        return bShowRedHot
      end
    end
  end
  return bShowRedHot
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
  local ActivityCenterSystem = require("client.slua.logic.activity.logic_activity_center")
  local pageType = ActivityCenterSystem.GetActPageType(activity)
  if not NoRedShowTypeTb[pageType] and activity and activity.TabType and ActivityCenterSystem.IsCurActSwitchTypeInCenter(activity) then
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
  local StartTime = slua.getMicroseconds()
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
  local EndTime = slua.getMicroseconds()
  log(bWriteLog and string.format("ActivityRedDot.CheckSmartAssistantReport. CostTime:%.3f ms", (EndTime - StartTime) / 1000))
end
return ActivityRedDot