local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
local TableUtil = require("common.table_util")
local E_ActSwitchType = ActivitySwitchType
local E_local E_ActType = ActivityType
local E_local local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
local E_SubActType = ActivityMacros.SubActType
local C_SwitchIcon = ActivityMacros.ActTabIcon
local C_SwitchIcon_Selected = ActivityMacros.ActTabSelIcon
local ActivityCenterSystem = {
  activityData = {},
  centerAllData = {},
  extraActivityData = {},
  tabLists = {},
  noticeData = {},
  switchList = {},
  enterData = {},
  mergeActivityList = {},
  selectExchangeList = {},
  otherImageActRedDot = {},
  hasActAllDone = false,
  skipRedCheck = {},
  webRedPointData = {}
}
local C_ShowTab = {}
local C_ActInfo
local NoRedShowTypeTb = {
  [E_ActivityShowType.None] = 1,
  [E_ActivityShowType.Bg] = 1,
  [E_ActivityShowType.TopBg] = 1,
  [E_ActivityShowType.BottomImage] = 1
}
local StringUtil = require("common.string_util")
local strFind = StringUtil.StrFind
local HOSTED_ACT_ALL_DONE_ORDER_OFFSET = 10000
local _hostedActAllDoneCache
local _LoadHostedActAllDoneData = function()
  if _hostedActAllDoneCache then
    return _hostedActAllDoneCache
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  _hostedActAllDoneCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHostedActAllDone) or {}
  return _hostedActAllDoneCache
end
function ActivityCenterSystem.InitCenterData(displayScene)
  displayScene = displayScene or ActivityDisplayScene.Default
  local utility = require("common.utility")
  xpcall(ActivityCenterSystem.SetActivityCenterData, utility.ErrorMessageHandler, displayScene)
  xpcall(ActivityCenterSystem.SetNoticeActivityData, utility.ErrorMessageHandler, displayScene)
  xpcall(ActivityCenterSystem.SetExtraActivityData, utility.ErrorMessageHandler, displayScene)
end
local _SortCenterDataImpl = function()
  for i, v in pairs(ActivityCenterSystem.centerAllData) do
    table.sort(v, function(a, b)
      if a.nOrder == b.nOrder then
        return a.nActID > b.nActID
      else
        return a.nOrder < b.nOrder
      end
    end)
    if i == E_ActSwitchType.Activity and ActivityCenterSystem.extraActivityData[ActivityFixedID.ENTRY_SET] and v[1].nActID ~= ActivityFixedID.ENTRY_SET then
      for index = 1, #v do
        if v[index].nActID == ActivityFixedID.ENTRY_SET and v[index] then
          local data = v[index]
          table.remove(v, index)
          table.insert(v, 1, data)
          data = nil
          break
        end
      end
    end
  end
end
function ActivityCenterSystem.SortCenterData()
  local utility = require("common.utility")
  xpcall(_SortCenterDataImpl, utility.ErrorMessageHandler)
end
local CheckCanShowAct = function(activity, displayScene)
  if not activity.DisplayScene and displayScene ~= ActivityDisplayScene.Default then
    return false
  elseif activity.DisplayScene and not activity.DisplayScene[displayScene] then
    return false
  end
  if not ActivityCenterSystem.CanShowAct(activity) then
    return false
  end
  return true
end
function ActivityCenterSystem.SetActivityCenterData(displayScene)
  if not C_ActInfo then
    C_ActInfo = {}
    for _, actTabCfg in pairs(ActivityMacros.ActTabConfig) do
      C_ActInfo[#C_ActInfo + 1] = actTabCfg
    end
    table.sort(C_ActInfo, function(a, b)
      return a.nSort < b.nSort
    end)
  end
  C_ShowTab = {}
  local data = ActivityNewSystem.GetActivity()
  ActivityCenterSystem.centerAllData = {}
  for _, activity in ipairs(data) do
    if CheckCanShowAct(activity, displayScene) then
      local TabType = activity.TabType
      if not ActivityCenterSystem.centerAllData[TabType] then
        ActivityCenterSystem.centerAllData[TabType] = {}
      end
      if not C_ShowTab[TabType] and ActivityCenterSystem.CanShowSwitchType(activity) then
        C_ShowTab[TabType] = true
      end
      local actInfo = ActivityCenterSystem.UpdateOneActivity(activity)
      table.insert(ActivityCenterSystem.centerAllData[TabType], actInfo)
    end
  end
end
function ActivityCenterSystem.CanShowAct(actData)
  log(bWriteLog and string.format("ActivityCenterSystem.CanShowAct. ID=%s", tostring(actData.ID)))
  if not actData.Type then
    log(bWriteLog and "ActivityCenterSystem.CanShowAct. actData.Type is nil")
    return false
  end
  if ActivityNewSystem.IsSignInType(actData) then
    log(bWriteLog and "ActivityCenterSystem.CanShowAct. actData is sign in type")
    return false
  end
  if not ActivityCenterSystem.IsCurActSwitchTypeInCenter(actData) then
    log(bWriteLog and "ActivityCenterSystem.CanShowAct. actData not in current switch type")
    return false
  end
  if not ActivityCenterSystem.CheckActIsInProgress(actData) then
    log(bWriteLog and "ActivityCenterSystem.CanShowAct. actData not in progress")
    return false
  end
  local pageType = ActivityCenterSystem.GetActPageType(actData)
  if NoRedShowTypeTb[pageType] then
    log(bWriteLog and "ActivityCenterSystem.CanShowAct. pageType in NoRedShowTypeTb")
    return false
  end
  if ActivityNewSystem.IsEmbeddingGameletAct(actData) then
    log(bWriteLog and "ActivityCenterSystem.CanShowAct. actData is gamelet act")
    return ActivityNewSystem.IsGameletActCanShow(actData)
  end
  return true
end
function ActivityCenterSystem.CanShowSwitchType(actData)
  local tabType = actData.TabType
  if tabType == E_ActSwitchType.Activity and ActivityCenterSystem.IsActivityCompleted(actData) then
    return false
  end
  return true
end
local completedMark = {
  [ActivityProgressStatus.Get] = true,
  [ActivityProgressStatus.Expired] = true
}
function ActivityCenterSystem.IsActivityCompleted(activityData)
  if #activityData.List == 0 then
    return false
  end
  for _, taskData in ipairs(activityData.List) do
    if not next(taskData.Drop) or not completedMark[taskData.Status] then
      return false
    end
  end
  return true
end
function ActivityCenterSystem.CheckActIsInProgress(activityData)
  if not activityData then
    log(bWriteLog and "[v_wllwu] ActivityCenterSystem.CheckActIsInProgress, activityData is nil")
    return
  end
  if activityData.Type == E_ActType.PreventLose_LoginReward then
    local TimeUtil = require("client.common.time_util")
    local nowTime = TimeUtil.GetServerTimeInSec()
    if nowTime >= activityData.StartTime and nowTime < activityData.EndTime then
      return true
    end
    log(bWriteLog and "[v_wllwu] ActivityCenterSystem.CheckActIsInProgress return false, nowTime is " .. tostring(nowTime) .. " StartTime = " .. tostring(activityData.StartTime) .. " EndTime = " .. tostring(activityData.EndTime))
    return false
  end
  return true
end
function ActivityCenterSystem.SetNoticeActivityData(displayScene)
  if displayScene ~= ActivityDisplayScene.Default then
    return
  end
  local NoticesUtil = require("client.logic.Notice.NoticesUtil")
  local NoticesConst = require("client.logic.Notice.NoticesConst")
  local activityNotices = NoticesUtil.GetActivityNoticeArray()
  local switchType = E_ActSwitchType.Notice
  ActivityCenterSystem.noticeData = {}
  if not ActivityCenterSystem.centerAllData[switchType] then
    ActivityCenterSystem.centerAllData[switchType] = {}
  end
  for _, v in pairs(activityNotices) do
    if tonumber(v.MsgContentType) == NoticesConst.NoticeContentType.Text and v.MsgContent ~= "" or tonumber(v.MsgContentType) == NoticesConst.NoticeContentType.ImageOrBlueprint and v.EventCenter ~= "" then
      if not C_ShowTab[switchType] then
        C_ShowTab[switchType] = true
      end
      local tabInfo = {}
      tabInfo.nActID = tonumber(v.MsgId)
      tabInfo.nRedDotNum = 0
      if E_ActivityShowType.Notice == ActivityCenterSystem.GetNoticePageType(v) then
        tabInfo.sName = v.MsgTitle or ""
      else
        tabInfo.sName = v.PicTitle or ""
      end
      tabInfo.nType = 0
      tabInfo.sTypeName = ""
      tabInfo.bRedDot = false
      tabInfo.nStartTime = v.StartTime or 0
      tabInfo.nOrder = v.Sort or 1000
      table.insert(ActivityCenterSystem.centerAllData[switchType], tabInfo)
      ActivityCenterSystem.noticeData[tabInfo.nActID] = v
    end
  end
end
function ActivityCenterSystem.SetExtraActivityData(displayScene)
  local C_ExtraActPageTypeBegin = E_ActivityShowType.End
  ActivityCenterSystem.extraActivityData = {}
  local _InitExtraData = function(cfg, data)
    local tabInfo = data
    local switchType = data.nSwitchType or cfg.switchType
    if not data.DisplayScene and displayScene ~= ActivityDisplayScene.Default then
      return
    elseif data.DisplayScene and not data.DisplayScene[displayScene] then
      return
    end
    if data.Order then
      tabInfo.nOrder = data.Order or 0
    else
      tabInfo.nOrder = cfg.sort or 0
    end
    tabInfo.nType = data.nType or 0
    tabInfo.sTypeName = ""
    if type(data.nRedDotNum) ~= "function" and type(data.bRedDot) ~= "function" then
      tabInfo.nRedDotNum = 0
      tabInfo.bRedDot = false
    end
    if not ActivityCenterSystem.centerAllData[switchType] then
      ActivityCenterSystem.centerAllData[switchType] = {}
    end
    table.insert(ActivityCenterSystem.centerAllData[switchType], tabInfo)
    ActivityCenterSystem.SetShowTab(switchType, true)
    if cfg.showType == -1 or cfg.showType > E_ActivityShowType.End then
      C_ExtraActPageTypeBegin = C_ExtraActPageTypeBegin + 1
      cfg.showType = C_ExtraActPageTypeBegin
      ActivityMacros.ActPageUI[C_ExtraActPageTypeBegin] = cfg.uiConfig
    end
    ActivityCenterSystem.extraActivityData[data.nActID] = {cfg = cfg, data = data}
    if cfg.updateEventType and cfg.updateEventID then
      local ActModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Activity)
      ActModule:InsertCommonEvent(cfg, data)
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
function ActivityCenterSystem.SetTabList(nSelectType, bShowHasDoneAct)
  local tTabList = ActivityCenterSystem.centerAllData[nSelectType]
  if not tTabList then
    return
  end
  if not bShowHasDoneAct and nSelectType ~= E_ActSwitchType.Activity then
    bShowHasDoneAct = true
  end
  log_warning(bWriteLog and "  ActivityCenterSystem.SetTabList. bShowHasDoneAct " .. tostring(bShowHasDoneAct))
  local logic_activity_recharge_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_activity_recharge_mgr)
  local remakeList = {}
  ActivityCenterSystem.hasActAllDone = false
  for _, v in ipairs(tTabList) do
    local isAdd = true
    if not bShowHasDoneAct and isAdd and v.nHasDoneRate == 1 then
      ActivityCenterSystem.hasActAllDone = true
      isAdd = false
    end
    if isAdd then
      for _, vv in pairs(ActivityCenterSystem.mergeActivityList) do
        if v.nActID == tonumber(vv) then
          isAdd = false
          break
        end
      end
    end
    if v.nHasDoneRate == 1 then
      v.nOrder = 2000
    end
    if ActivityCenterSystem.IsHostedActAllDone(v.nActID) then
      v.nOrder = v.nOrder + HOSTED_ACT_ALL_DONE_ORDER_OFFSET
    end
    if isAdd then
      table.insert(remakeList, v)
    end
  end
  table.sort(remakeList, function(a, b)
    if a.nOrder == b.nOrder then
      return a.nActID > b.nActID
    else
      return a.nOrder < b.nOrder
    end
  end)
  ActivityCenterSystem.tabLists = remakeList
end
function ActivityCenterSystem.GetBrotherId(actId)
  for brother, vv in pairs(ActivityCenterSystem.mergeActivityList) do
    if actId == tonumber(vv) then
      return brother
    end
  end
  return nil
end
function ActivityCenterSystem.SetSwitchData()
  ActivityCenterSystem.switchList = {}
  local ActivityCenterTabModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterTabModule)
  local TableUtil = require("common.table_util")
  for _, value in ipairs(C_ActInfo) do
    if C_ShowTab[value.nType] then
      local SwitchInfo = TableUtil.CopyTable(value)
      local nType = SwitchInfo.nType
      local NormalPath = C_SwitchIcon[nType] and C_SwitchIcon[nType] or ""
      local SelectedPath = C_SwitchIcon_Selected[nType] and C_SwitchIcon_Selected[nType] or ""
      if ActivityCenterTabModule:ExistTabConfig(nType) then
        NormalPath = ActivityCenterTabModule:GetActCenterTabNormalPath(nType)
        SelectedPath = ActivityCenterTabModule:GetActCenterTabSelectedPath(nType)
      end
      SwitchInfo.inactivePath = NormalPath
      SwitchInfo.activePath = SelectedPath
      table.insert(ActivityCenterSystem.switchList, SwitchInfo)
    end
  end
end
local mergeTypeTb = {
  [E_ActType.ITEM_EXCHANGE] = 1,
  [E_ActivityShowType.Progress] = 1
}
local _UpdateMergeActivity = function(activity)
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
        ActivityCenterSystem.mergeActivityList[tonumber(brotherData.ID)] = activity.ID
        log_warning(bWriteLog and "  _UpdateMergeActivity. brotherData.ID " .. tostring(brotherData.ID))
        log_warning(bWriteLog and "  _UpdateMergeActivity. activity.ID " .. tostring(activity.ID))
      end
    elseif ActivityCenterSystem.mergeActivityList and next(ActivityCenterSystem.mergeActivityList) then
      for k, v in pairs(ActivityCenterSystem.mergeActivityList) do
        if k == tonumber(activity.BrotherID) or v == tonumber(activity.BrotherID) then
          ActivityCenterSystem.mergeActivityList[k] = nil
          break
        end
      end
    end
  elseif activity.SelectExchange then
    ActivityCenterSystem.selectExchangeList[activity.ID] = 1
  end
  return brotherData
end
local local SignTypeTb = {
  [ActivityType.LOGIN] = 1,
  [ActivityType.TOTAL_LOGIN] = 1,
  [ActivityType.LoginPunchIn] = 1
}
function ActivityCenterSystem.SortTask(List, Type)
  if not List then
    log_warning(bWriteLog and "ActivityCenterSystem.SortTask. List is nil, skip sorting")
    return
  end
  log_warning(bWriteLog and string.format("ActivityCenterSystem.SortTask. List=%s, Type=%s", tostring(List), tostring(Type)))
  if Type and SignTypeTb[Type] then
    ActivityCenterSystem.SortSign(List)
    return
  end
  local RuleTb = {
    Status = {
      [1] = 1,
      [0] = 2,
      [2] = 3
    },
    Type = {
      [10] = 0
    }
  }
  local sort_util = require("common.sort_util")
  sort_util.SortByRule(List, RuleTb, "Type", "Status", "Total", "ID", "Key")
end
function ActivityCenterSystem.SortSign(List)
  local RuleTb = {
    Status = {
      [1] = 1,
      [0] = 1,
      [2] = 3
    },
    Type = {
      [10] = 0
    }
  }
  local sort_util = require("common.sort_util")
  sort_util.SortByRule(List, RuleTb, "Type", "Status", "Index", "ID", "Key")
end
function ActivityCenterSystem.SortAndSetCurActSubData(activity)
  if not activity then
    return
  end
  for _, subActivity in ipairs(activity.List) do
    subActivity.IsShowExPage = false
    subActivity.CanGetTimes = 0
    for _, v in pairs(subActivity.CostList) do
      v.have_count = ActivityCenterSystem.GetItemNum(v.itemId)
    end
    if activity.Type == E_ActType.ITEM_EXCHANGE then
      subActivity = ActivityCenterSystem.ResetExchangeParams(subActivity)
    end
    if activity.SelectExchange then
      subActivity.IsSelectExchange = true
    end
  end
  return activity
end
function ActivityCenterSystem.ResetExchangeParams(subActivity)
  local can_exchange_num = 0
  for _, v in pairs(subActivity.CostList) do
    v.have_count = ActivityCenterSystem.GetItemNum(v.itemId)
    if 0 < v.have_count and 0 < v.count then
      local temp_exchange_num = math.floor(v.have_count / v.count)
      if can_exchange_num == 0 then
        can_exchange_num = temp_exchange_num
      elseif temp_exchange_num < can_exchange_num then
        can_exchange_num = temp_exchange_num
      end
    end
  end
  local left_times = subActivity.Total - subActivity.Progress
  if 1 <= left_times and 1 <= can_exchange_num then
    subActivity.IsShowExPage = true
    subActivity.CanGetTimes = left_times
    if can_exchange_num < subActivity.CanGetTimes then
      subActivity.CanGetTimes = can_exchange_num
    end
  else
    subActivity.IsShowExPage = false
    subActivity.CanGetTimes = 0
  end
  return subActivity
end
function ActivityCenterSystem.IsGroupAwardType(subData)
  if subData and subData.Type == E_ActType.GROUP and subData.Drop and #subData.Drop > 0 then
    return true
  end
  return false
end
function ActivityCenterSystem.UpdateOneActivity(activity, justRed)
  local brotherData = _UpdateMergeActivity(activity)
  local tabInfo = {}
  tabInfo.nRedDotNum = 0
  local nHasDoneRate = 0
  for _, v in ipairs(activity.List) do
    if v and v.Drop and next(v.Drop) and v.Drop[1].itemId ~= 0 then
      if v.Status == E_ActivityProgressStatus.Get then
        nHasDoneRate = nHasDoneRate + 1
      end
      if v.Status == E_ActivityProgressStatus.Done then
        if v.Type == ActivityType.LoginPunchIn then
          local punchIn = require("client.slua.logic.activity.logic_login_punchin")
          if punchIn.HasJump(v.Key) then
            tabInfo.nRedDotNum = 1
          end
        elseif v.Type ~= E_ActType.ITEM_EXCHANGE or v.IsCheckNotice ~= 0 then
          tabInfo.nRedDotNum = 1
        end
      end
    end
  end
  local curData = ActivityCenterSystem.SortAndSetCurActSubData(activity)
  if justRed then
    if ActivityCenterSystem.activityData[activity.ID] then
      ActivityCenterSystem.activityData[activity.ID] = curData
    end
  else
    ActivityCenterSystem.activityData[activity.ID] = curData
  end
  if activity.Type == E_ActType.ACTIVITY_TYPE_REBATE then
    local ActivityRebate = require("client.logic.activity.logic_activity_rebate")
    local info = ActivityRebate.GetRebateInfo()
    local rebateRateStr = LocUtil.LocalizeResFormat(7543, info.rebateRate .. "%%")
    tabInfo.sName = rebateRateStr
  else
    tabInfo.sName = activity.Title
  end
  if brotherData and next(brotherData) then
    for _, v in ipairs(brotherData.List) do
      if v.Status and v.Status == E_ActivityProgressStatus.Get then
        nHasDoneRate = nHasDoneRate + 1
      end
    end
  end
  local curAchieveNum = #activity.List or 0
  local otherAchieveNum = brotherData and #brotherData.List or 0
  local nAllNum = curAchieveNum + otherAchieveNum
  if nAllNum == 0 then
    tabInfo.nHasDoneRate = 0
  else
    tabInfo.nHasDoneRate = nHasDoneRate / nAllNum
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
  tabInfo.bRedDot = ActivityNewSystem.HasActivityRedDotByID(activity.ID)
  tabInfo.nStartTime = activity.StartTime
  tabInfo.nOrder = activity.Order
  tabInfo.sImageLink = activity.ImgLink
  tabInfo.sTabImageUrl = activity.TabImgUrl
  return tabInfo
end
function ActivityCenterSystem.GetItemNum(nItemID)
  if nItemID == 1000 then
    return DataMgr.gold
  elseif nItemID == 1003 then
    return DataMgr.roleData.roleExp
  elseif nItemID == 1103 then
    return DataMgr.battle_coin
  else
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetHallDepotItemDataByResID(nItemID)
    if itemData ~= nil then
      return itemData.count
    end
    local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
    local count = logic_xmission_warpre.GetItemNumByItemIdAndAffix(nItemID, true, false)
    return count
  end
end
function ActivityCenterSystem.GetNoticePageType(tNoticeData)
  local NoticesConst = require("client.logic.Notice.NoticesConst")
  if tNoticeData.MsgContentType == NoticesConst.NoticeContentType.Text then
    return E_ActivityShowType.Notice
  elseif tNoticeData.MsgContentType == NoticesConst.NoticeContentType.ImageOrBlueprint then
    return E_ActivityShowType.Image
  end
  return E_ActivityShowType.None
end
function ActivityCenterSystem.GetNoticesData(msgId)
  if ActivityCenterSystem.noticeData and ActivityCenterSystem.noticeData[msgId] then
    return ActivityCenterSystem.noticeData[msgId]
  end
end
function ActivityCenterSystem.JumpUrl(url, total, actID)
  ActivityNewSystem.JumpUrl(url, total, actID, true)
end
function ActivityCenterSystem.UpdateRedPointInJumpWebUrl(actID)
  ActivityCenterSystem.TryRemoveH5CenterRedPoint(actID)
  ActivityCenterSystem.RefreshActRedById(actID)
end
function ActivityCenterSystem.GetActSelectIndexByID(nActivityID, bShowHasDoneAct)
  local nSwitchIndex, nTabIndex, hasAllDoneChange
  for i, v in pairs(ActivityCenterSystem.mergeActivityList) do
    if v == nActivityID then
      nActivityID = i
      break
    end
  end
  for i, v in pairs(ActivityCenterSystem.centerAllData) do
    for _, vv in ipairs(v) do
      if vv.nActID == nActivityID then
        for iii, vvv in ipairs(ActivityCenterSystem.switchList) do
          if i == vvv.nType then
            nSwitchIndex = iii
            ActivityCenterSystem.SetTabList(vvv.nType, bShowHasDoneAct)
            break
          end
        end
      end
    end
  end
  for i, v in ipairs(ActivityCenterSystem.tabLists) do
    if v.nActID == nActivityID then
      if v.nHasDoneRate == 1 then
        if not bShowHasDoneAct then
          nTabIndex = 1
          break
        end
        nTabIndex = i
        hasAllDoneChange = true
        break
      end
      nTabIndex = i
      break
    end
  end
  return nSwitchIndex, nTabIndex, hasAllDoneChange
end
function ActivityCenterSystem.IsActivityMerged(nActivityID)
  for i, v in pairs(ActivityCenterSystem.mergeActivityList) do
    if v == nActivityID or i == nActivityID then
      return true
    end
  end
  return false
end
function ActivityCenterSystem.GetActivityMergeID(nActivityID)
  if ActivityCenterSystem.mergeActivityList[nActivityID] then
    return ActivityCenterSystem.mergeActivityList[nActivityID]
  else
    for i, v in pairs(ActivityCenterSystem.mergeActivityList) do
      if v == nActivityID then
        return i
      end
    end
  end
end
function ActivityCenterSystem.GetCurRebatePhaseInfo(data)
  local daysToSecFactor = 86400
  local conds = StringUtil.Split(data.Condition, ",")
  local condBegin = conds[2] * daysToSecFactor + data.StartTime
  local condEnd = conds[3] * daysToSecFactor + data.StartTime - 1
  local curTaskEnd = 0
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local curPhaseInfo = {
    activityPhase = -1,
    rebatePhase = -1,
    endTime = -1
  }
  local activityListMap = ActivityNewSystem.GetSubListMap()
  local rebateFirst = activityListMap[data.ID .. "_" .. tostring(2)]
  if not rebateFirst then
    return nil
  end
  local rebateFirstBegin = rebateFirst.Condition[1] * daysToSecFactor + data.StartTime - 1
  local ActivityRebate = require("client.logic.activity.logic_activity_rebate")
  if condBegin < now and condEnd >= now and data.List[1].Status == 0 then
    curPhaseInfo.activityPhase = ActivityRebate.activityPhase.discount
    curPhaseInfo.endTime = condEnd
  elseif condBegin < now and now <= rebateFirstBegin then
    curPhaseInfo.activityPhase = ActivityRebate.activityPhase.betweenDiscountAndRebate
    curPhaseInfo.endTime = rebateFirstBegin
  else
    curPhaseInfo.activityPhase = ActivityRebate.activityPhase.ending
    curPhaseInfo.endTime = -1
    for idx, _ in pairs(data.List) do
      local rebateInfo = activityListMap[data.ID .. "_" .. tostring(idx + 1)]
      curTaskEnd = rebateInfo.Condition[2] * daysToSecFactor + data.StartTime - 1
      if now < curTaskEnd then
        curPhaseInfo.activityPhase = ActivityRebate.activityPhase.rebate
        curPhaseInfo.rebatePhase = idx
        curPhaseInfo.endTime = curTaskEnd
        break
      end
    end
  end
  return curPhaseInfo
end
function ActivityCenterSystem.GetSubActPageType(tSubData)
  if not tSubData then
    return E_SubActType.Award
  end
  if tSubData.IsSelectExchange then
    return E_SubActType.SelectExchange
  end
  if tSubData.Type == E_ActType.ITEM_EXCHANGE then
    return E_SubActType.Exchange
  elseif tSubData.Type == E_ActType.ACTIVITY_TYPE_REBATE then
    return E_SubActType.AwardTimeLimit
  elseif tSubData.Type == E_ActType.TaskPropsCollect then
    return E_SubActType.TaskPropsCollect
  else
    return E_SubActType.Award
  end
end
function ActivityCenterSystem.GetDefaultBg(tActdata, nSwitchType)
  if not tActdata then
    return
  end
  local type = ActivityCenterSystem.GetActPageType(tActdata)
  local NoticesConst = require("client.logic.Notice.NoticesConst")
  if tActdata.MsgContentType and tActdata.MsgContentType == NoticesConst.NoticeContentType.Text then
    return "/Game/UMG/Texture/Lobby_NoAtlas/NewActivty/NewActivty_Affiche_BG.NewActivty_Affiche_BG"
  end
  if type == E_ActivityShowType.Notice then
    return "/Game/UMG/Texture/Lobby_NoAtlas/NewActivty/NewActivty_Affiche_BG.NewActivty_Affiche_BG"
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission(false) or nSwitchType == E_ActSwitchType.Xmission then
    return "/Game/UMG/Texture/Lobby_NoAtlas/NewActivty/NewActivty_SubwaySurvive_BG_07.NewActivty_SubwaySurvive_BG_07"
  else
    return "/Game/UMG/Texture/Lobby_NoAtlas/NewActivty/NewActivty_Default_BG1.NewActivty_Default_BG1"
  end
end
local _InitRemakeProgressData = function(remakeList, data)
  if not data then
    return
  end
  local itemData = {}
  itemData.ID = data.ID
  itemData.Rewards = data.Drop and data.Drop[1]
  itemData.RequireScore = data.Condition and data.Condition[1]
  itemData.Index = data.Index
  itemData.Status = data.Status
  itemData.ExpireTime = data.Drop and data.Drop[1] and data.Drop[1].expireTime
  itemData.CostID = data.CostList and data.CostList[1] and data.CostList[1].itemId or nil
  remakeList[data.Index] = itemData
end
function ActivityCenterSystem.GetProgressDataByType(tActData)
  local tRemakeList = {}
  local nGetIndex = 1
  local maxScore = 0
  local curScore = 0
  local curPersonProgress, curPersonMaxProgress
  if tActData.Type == E_ActType.AVALON_PROGRESS or tActData.Type == E_ActType.GIFT_INTIMACY_DOUBLE then
    for k, v in ipairs(tActData.List) do
      _InitRemakeProgressData(tRemakeList, v)
      if v.Status == E_ActivityProgressStatus.Done then
        nGetIndex = k
      end
      maxScore = v.Total or 0
      curScore = tActData.other.progress and tActData.other.progress[k] or 0
    end
  end
  if tActData.Type == E_ActType.PROGRESS then
    curScore = tActData.other.max_score or 0
    for k, v in ipairs(tActData.List) do
      _InitRemakeProgressData(tRemakeList, v)
      if v.Status == E_ActivityProgressStatus.Done then
        nGetIndex = k
      end
      if v.Index == 1 then
        maxScore = 0 < v.Condition[2] and v.Condition[2] or 200
      end
      maxScore = v.Total or 0
    end
  end
  if tActData.Type == E_ActType.ACTIVITY_CENTER_KR_PROGRESS then
    curScore = tActData.other.progress or 0
    curPersonProgress = tActData.other.personal_progress
    for k, v in ipairs(tActData.List) do
      _InitRemakeProgressData(tRemakeList, v)
      if v.Status == E_ActivityProgressStatus.Done then
        nGetIndex = k
      end
      maxScore = v.Condition[1] + maxScore
      if v.Index == 1 then
        curPersonMaxProgress = v.Condition[3]
      end
    end
  end
  return tRemakeList, maxScore, curScore, nGetIndex, curPersonProgress, curPersonMaxProgress
end
local Type2Label = {
  [E_ActType.ACTIVITY_TYPE_REBATE] = E_ActivityShowType.Sub,
  [E_ActType.REDEEM_CODE] = E_ActivityShowType.RedeemCode,
  [E_ActType.IMAGES_GROUP] = E_ActivityShowType.Banner
}
local LabelTypeTb = {}
function ActivityCenterSystem.GetActPageType(tActData)
  if not tActData or not tActData.Type then
    log(bWriteLog and "[v_vyhhzhang] Act have not type")
    return E_ActivityShowType.None
  end
  if ActivityCenterSystem.IsHideInActivityCenter(tActData) then
    return E_ActivityShowType.None
  end
  if tActData.Type == E_ActType.ACTIVITY_TYPE_AREA_GROUP then
    return E_ActivityShowType.None
  end
  if ActivityCenterSystem.mergeActivityList[tActData.ID] and tActData.Type ~= E_ActType.WEEKEND_MARKET then
    local subActData = ActivityNewSystem.GetActivityByID(ActivityCenterSystem.mergeActivityList[tActData.ID])
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
  if ActivityCenterSystem.selectExchangeList[tActData.ID] then
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
    log_warning(bWriteLog and "  ActivityCenterSystem.GetActPageType. changedLabel " .. tostring(changedLabel))
    return changedLabel
  end
  local tActConfig = CDataTable.GetTableData("ActivityCenterConfig", tActData.Type)
  if tActConfig then
    return tActConfig.ShowType
  end
  return E_ActivityShowType.Image
end
local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
local goldenId = special_offer_cfg.id2ActId[special_offer_cfg.golden]
local hideIdTb = {
  [goldenId] = 1
}
function ActivityCenterSystem.IsHideInActivityCenter(activity)
  if not activity then
    return true
  end
  if hideIdTb[activity.ID] then
    return true
  end
  local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  if activity.ImgLink and not pandoraSystem.CheckActIsShowByUrl(activity.ImgLink) then
    return true
  end
  if activity.TabType and not ActivityMacros.ActTabConfig[activity.TabType] then
    return true
  end
  if activity.ShowSceneID and activity.ShowSceneID > 1 then
    if activity.Type == ActivityType.ACTIVITY_TYPE_LINK then
      return false
    end
    return true
  end
  if activity.Type == E_ActType.ITEM_EXCHANGE then
    local exParam = activity.ExParam
    if exParam ~= "" then
      local params = StringUtil.Split(exParam, ",")
      local isShowInLobby = tonumber(params[1]) == 1
      return isShowInLobby
    end
  end
  if activity.Type == E_ActType.NOTICE_INFO and activity.ImgUrl ~= "" and activity.Detail == "" then
    return true
  end
  if activity.BackupParam1 and tonumber(activity.BackupParam1) == ActivityBackUpOneType.UGCSeason then
    if activity.Type == ActivityType.ACTIVITY_TYPE_LINK then
      return true
    end
    return false
  end
  return false
end
function ActivityCenterSystem.SetShowTab(TabType, bShow)
  C_ShowTab[TabType] = bShow
end
function ActivityCenterSystem.GetTabName(TabType)
  local result = ""
  if TabType and ActivityMacros.ActTabConfig[TabType] then
    local TabConfig = ActivityMacros.ActTabConfig[TabType]
    result = LocUtil.GetLocalizeResStr(TabConfig.sLocalizeID)
  end
  return result
end
function ActivityCenterSystem.RefreshActRedById(id)
  log_warning(bWriteLog and string.format("ActivityCenterSystem.RefreshActRedById. id=%s", tostring(id)))
  if not id or id < 1 then
    return
  end
  local brother = ActivityCenterSystem.GetBrotherId(id)
  if brother then
    id = brother
    log_warning(bWriteLog and string.format("ActivityCenterSystem.RefreshActRedById.brother id=%s", tostring(id)))
  end
  local Sub201 = ActivityNewSystem.GetSubAct201()
  if Sub201[id] then
    log_warning(bWriteLog and "  ActivityCenterSystem.RefreshActRedById.  change 201" .. tostring(id))
    id = Sub201[id]
  end
  local Sub46 = ActivityNewSystem.GetSubAct46()
  if Sub46[id] then
    id = Sub46[id]
  end
  for _, v in ipairs(ActivityCenterSystem.switchList) do
    local curSwitchActData = ActivityCenterSystem.centerAllData[v.nType]
    if curSwitchActData then
      for _, tab in ipairs(curSwitchActData) do
        if tab.nActID == id then
          local act = ActivityNewSystem.GetActivityByID(id)
          if act then
            tab = ActivityCenterSystem.UpdateOneActivity(act, true)
          end
          local bRed, RedDotType = ActivityRedDot.ActHasRed(id)
          log_warning(bWriteLog and "  ActivityCenterSystem.RefreshActRedById. bRed " .. tostring(bRed))
          local tabName = ActivityCenterSystem.GetTabName(v.nType)
          if act and act.DisplayScene and next(act.DisplayScene) then
            for displayScene, _ in pairs(act.DisplayScene) do
              local systemName = ActivityRedDot.DisplayScene2SystemName(displayScene)
              ActivityRedDot.AddRedDotNode(systemName, v.nType, tabName, tab.nActID, bRed, RedDotType)
            end
          else
            local systemName = ActivityRedDot.GetActFirstRedDotSystemName(id)
            ActivityRedDot.AddRedDotNode(systemName, v.nType, tabName, tab.nActID, bRed, RedDotType)
          end
          return true
        end
      end
    end
  end
end
local _FindMoudleIDByLink = function(sImageLink)
  local idx = strFind(sImageLink, "module=")
  local nModuleID = 0
  if idx and 0 < tonumber(idx) then
    local beginIdx = idx + string.len("module=")
    local endIdx = strFind(sImageLink, "&")
    if endIdx and 0 < tonumber(endIdx) then
      nModuleID = tonumber(string.sub(sImageLink, beginIdx, endIdx - 1))
    else
      nModuleID = tonumber(string.sub(sImageLink, beginIdx, string.len(sImageLink)))
    end
  end
  return nModuleID
end
function ActivityCenterSystem.AddCenterRedDotForImage(nKey, isModuleID, bShow, redDotType)
  if not nKey then
    return
  end
  local nActID
  local tCurAct = {}
  if isModuleID then
    local tActData = ActivityNewSystem.GetActivity()
    for _, v in pairs(tActData) do
      if v.ImgLink and v.ImgLink ~= "" then
        local nModuleID = _FindMoudleIDByLink(v.ImgLink)
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
  if nActID then
    if not ActivityCenterSystem.otherImageActRedDot[nActID] then
      ActivityCenterSystem.otherImageActRedDot[nActID] = {}
    end
    if bShow then
      if not redDotType then
        redDotType = ActivityMacros.RedDotType.Normal
      end
    else
      redDotType = ActivityMacros.RedDotType.None
    end
    ActivityCenterSystem.otherImageActRedDot[nActID] = redDotType
    local tabName = ActivityCenterSystem.GetTabName(tCurAct.TabType)
    if tCurAct.DisplayScene and next(tCurAct.DisplayScene) then
      for displayScene, _ in pairs(tCurAct.DisplayScene) do
        local systemName = ActivityRedDot.DisplayScene2SystemName(displayScene)
        ActivityRedDot.AddRedDotNode(systemName, tCurAct.TabType, tabName, tonumber(nActID), bShow, redDotType)
      end
    else
      local SystemName = ActivityRedDot.GetActFirstRedDotSystemName(nActID)
      ActivityRedDot.AddRedDotNode(SystemName, tCurAct.TabType, tabName, tonumber(nActID), bShow, redDotType)
    end
  end
end
function ActivityCenterSystem.GetSwitchList(switchType)
  if not switchType or switchType == 0 then
    return {}
  end
  return ActivityCenterSystem.centerAllData[switchType] or {}
end
function ActivityCenterSystem.IsShowInCenter(nActID, nCurSwitchType)
  local tCurTypeData = ActivityCenterSystem.centerAllData[nCurSwitchType]
  if tCurTypeData then
    for _, v in ipairs(tCurTypeData) do
      if v.nActID == nActID then
        return true
      end
    end
  end
  return false
end
function ActivityCenterSystem.IsCurActSwitchTypeInCenter(tActData)
  local bIsInCenter = true
  if not tActData.ImgLink then
    tActData.ImgLink = ""
  end
  if strFind(tActData.ImgLink, "module=" .. BP_ENUM_MODULE_BIND_FACEBOOK) then
    local logic_bind_facebook = require("client.slua.logic.activity.logic_bind_facebook")
    local bindType = E_ActType.BIND_SEND_GIFT
    if not ActivityNewSystem.IsModuleOnline(logic_bind_facebook.activityId, bindType) then
      bIsInCenter = false
    end
  elseif strFind(tActData.ImgLink, "module=" .. BP_ENUM_MODULE_BUY_UPASS_ACT) then
    local UnknowPassBuyActSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_buy_act")
    bIsInCenter = UnknowPassBuyActSystem.GetNeedShowEntrance()
  end
  if ActivityMacros.ActTabConfig[tActData.TabType] then
    return bIsInCenter
  end
  log(bWriteLog and "v_vyhhzhang__IsCurActSwitchTypeInCenterID:" .. tostring(tActData.Title))
  return false
end
function ActivityCenterSystem.IsCenterActOpenByMoudle(nMoudleID)
  local tActData = ActivityNewSystem.GetActivity()
  local tCurActData
  for _, v in pairs(tActData) do
    if v.ImgLink and v.ImgLink ~= "" then
      local nActModuleID = _FindMoudleIDByLink(v.ImgLink)
      if nActModuleID == nMoudleID then
        tCurActData = v
        break
      end
    end
  end
  if tCurActData then
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    if now > tCurActData.StartTime and now < tCurActData.EndTime then
      return true
    end
  end
  return false
end
function ActivityCenterSystem.FindActSwitchTypeByID(ID)
  if not ActivityCenterSystem.centerAllData or not next(ActivityCenterSystem.centerAllData) then
    ActivityCenterSystem.SetActivityCenterData(ActivityDisplayScene.Default)
  end
  for k, v in pairs(ActivityCenterSystem.centerAllData) do
    for _, vv in ipairs(v) do
      if vv.nActID == ID then
        return k
      end
    end
  end
  return 0
end
function ActivityCenterSystem.GetStringLen(inputstr)
  if not inputstr then
    return 0
  end
  local bytes = {
    inputstr:byte(1, #inputstr)
  }
  local lengh, begin = 0, false
  for _, byte in ipairs(bytes) do
    if byte < 128 or 192 <= byte then
      begin = false
      lengh = lengh + 1
    elseif not begin then
      begin = true
      lengh = lengh + 1
    end
  end
  return lengh
end
function ActivityCenterSystem.GetCurActTaskData(activity)
  local nAllTaskNum = 0
  local nCurDoneNum = 0
  nAllTaskNum = #activity.List
  for _, subActivity in ipairs(activity.List) do
    if subActivity.Type == E_ActType.ITEM_EXCHANGE then
      if subActivity.Status == E_ActivityProgressStatus.Get then
        nCurDoneNum = nCurDoneNum + 1
      end
    elseif subActivity.Status == E_ActivityProgressStatus.Get then
      nCurDoneNum = nCurDoneNum + 1
    end
  end
  return nCurDoneNum, nAllTaskNum
end
function ActivityCenterSystem.GetTabRed(tTabData, nCurSwitchType)
  local SystemName = ActivityRedDot.GetActFirstRedDotSystemName(tTabData.nActID)
  if ActivityCenterSystem.IsActivityMerged(tTabData.nActID) then
    local redActOne = ActivityRedDot.GetRedDotData(SystemName, nCurSwitchType, tTabData.nActID)
    if redActOne and redActOne.newCount >= 1 then
      return redActOne
    end
    local actTwoID = ActivityCenterSystem.GetActivityMergeID(tTabData.nActID)
    SystemName = ActivityRedDot.GetActFirstRedDotSystemName(actTwoID)
    local redActTwo = ActivityRedDot.GetRedDotData(SystemName, nCurSwitchType, actTwoID)
    if redActTwo and redActTwo.newCount >= 1 then
      return redActTwo
    end
  end
  return ActivityRedDot.GetRedDotData(SystemName, nCurSwitchType, tTabData.nActID)
end
function ActivityCenterSystem.ExistTabIndexByType(nType)
  return C_ShowTab[nType] or false
end
function ActivityCenterSystem.FindTabIndexByType(nType)
  if not C_ShowTab[nType] then
    return 1
  end
  local index = 1
  if ActivityCenterSystem.switchList then
    for i, v in ipairs(ActivityCenterSystem.switchList) do
      if v.nType == nType then
        index = i
        break
      end
    end
  end
  return index
end
function ActivityCenterSystem.GetImportentActData()
  local nActType = E_ActType.ACTIVITY_TYPE_LINK
  local E_ImportantActTab = 12
  local result = {
    bHasAct = false,
    sImageUrl = "",
    sJumpUrl = "",
    nEndTime = 0,
    nNotShowTime = 0,
    isGoExchange = 0
  }
  local data = ActivityNewSystem.GetActivityByTypeAndLabel(nActType, E_ImportantActTab)
  if data then
    log_tree("[ljw]isGoExchangePort v", data)
    local TimeUtil = require("client.common.time_util")
    local nowTime = TimeUtil.GetServerTimeInSec()
    local severData = ActivityNewSystem.GetServerDataByID(data.ID)
    if not severData then
      return result
    end
    result.bHasAct = severData.cfg and severData.cfg.priority_begin_time and severData.cfg.priority_end_time and nowTime >= severData.cfg.priority_begin_time and nowTime <= severData.cfg.priority_end_time
    result.sImageUrl = data.ImgUrl
    result.sJumpUrl = data.ImgLink
    result.nEndTime = data.StartTime
    result.nNotShowTime = data.EndTime
    result.isGoExchange = data.cond_2
  end
  return result
end
function ActivityCenterSystem.GetRechargeTipsData()
  local nActType = E_ActType.ACTIVITY_TYPE_LINK
  local nTabType = E_ActSwitchType.IOSOfUSRechargeTips
  local result = {
    bHasAct = false,
    sDescription = "",
    sJumpUrl = "",
    nEndTime = 0
  }
  local data = ActivityNewSystem.GetActivityByTypeAndLabel(nActType, nTabType)
  if data then
    local TimeUtil = require("client.common.time_util")
    local nowTime = TimeUtil.GetServerTimeInSec()
    local severData = ActivityNewSystem.GetActivityByID(data.ID)
    if not severData then
      return result
    end
    local begin_time = severData.StartTime
    local end_time = severData.EndTime
    if begin_time and end_time then
      result.bHasAct = nowTime >= begin_time and nowTime <= end_time
    end
    result.sDescription = data.Title or ""
    result.sJumpUrl = data.ImgLink or ""
  end
  log_tree("[recharge]RechargeTipsResult", result)
  return result
end
function ActivityCenterSystem.GetLobbyBottomEntranceData()
  local nTabType = E_ActSwitchType.LobbyMidBottomEntrance
  local tDatas = ActivityNewSystem.GetActivityByLabel(nTabType)
  if #tDatas <= 0 then
    return
  end
  local tData = tDatas[1]
  local TimeUtil = require("client.common.time_util")
  local nNowTime = TimeUtil.GetServerTimeInSec()
  local nStartTime = tData.StartTime or 0
  local nEndTime = tData.EndTime or 0
  if nNowTime < nStartTime or nNowTime > nEndTime then
    return
  end
  local result = {
    jump = tData.ImgLink,
    start_time = tData.StartTime,
    end_time = tData.EndTime,
    duration = 0,
    cdn = tData.ImageUrl,
    id = tData.ID,
    bNotBubble = true
  }
  log(bWriteLog and "ActivityCenterSystem.GetLobbyBottomEntranceData" .. tostring(nNowTime < nStartTime) .. ":" .. tostring(nNowTime > nEndTime))
  log_tree("ActivityCenterSystem.GetLobbyBottomEntranceData", result)
  return result
end
function ActivityCenterSystem.GetTimeStr(nTotalTime, nDay)
  if not nTotalTime or nTotalTime <= 0 then
    return ""
  end
  local days = math.floor(nTotalTime / 86400)
  local hours = math.fmod(math.floor(nTotalTime / 3600), 24)
  local mins = math.fmod(math.floor(nTotalTime / 60), 60)
  local seconds = math.fmod(math.floor(nTotalTime), 60)
  nDay = nDay or 2
  if days >= nDay then
    return LocUtil.LocalizeResFormat(4409, days + 1)
  else
    if 0 < days then
      hours = hours + days * 24
    end
    return string.format("%02d:%02d:%02d", hours, mins, seconds)
  end
end
function ActivityCenterSystem.SetCenterMessageRedPoint(cfg)
  local ActivityCenterRedPoint = {}
  if next(cfg) then
    for i, v in pairs(cfg) do
      if tonumber(i) and next(v) then
        local data = {}
        if 2 < i and i ~= 5 then
          for k, j in pairs(v) do
            if j and type(j) == "table" then
              data.startTime = j.start_time
              data.endTime = j.end_time
              data.actID = tostring(k)
              data.isFirst = true
              table.insert(ActivityCenterRedPoint, data)
            end
          end
        end
      end
    end
  end
  ActivityCenterSystem.webRedPointData = ActivityCenterRedPoint
end
function ActivityCenterSystem.CheckHasH5CenterRedPoint(subID)
  if not next(ActivityCenterSystem.webRedPointData) then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(ActivityCenterSystem.webRedPointData) do
    if tonumber(v.actID) == tonumber(subID) and v.isFirst and tonumber(v.startTime) < tonumber(serverTime) and tonumber(v.endTime) > tonumber(serverTime) then
      return true
    end
  end
  return false
end
function ActivityCenterSystem.TryRemoveH5CenterRedPoint(actID)
  log(bWriteLog and "TryRemoveH5CenterRedPoint")
  for _, v in pairs(ActivityCenterSystem.webRedPointData) do
    if tonumber(actID) == tonumber(v.actID) then
      v.isFirst = false
    end
  end
end
local cycle2ResId = {
  [0] = 512288,
  [1] = 512289,
  [7] = 512290
}
function ActivityCenterSystem.GetShareDescByAct(id)
  local data = ActivityNewSystem.GetServerDataByID(id)
  local resId = cycle2ResId[data.cfg.cycle_type or 0]
  local drop = TableUtil.GetTableValue(data, "cfg", "award", 1, "drop", 1)
  local itemId = drop and drop.item_id
  if not itemId then
    return ""
  end
  local itemData = CDataTable.GetTableData("Item", itemId)
  local itemName = FuncUtil.GetItemNameWithLimitTime(itemData.ItemName, drop.item_expire_time or 0)
  local num = drop and drop.item_num or 1
  return LocUtil.LocalizeResFormat(resId, itemName, num), itemId, num, drop.item_expire_time
end
function ActivityCenterSystem.IsHostedActAllDone(actId)
  if not actId then
    return false
  end
  local allDoneData = _LoadHostedActAllDoneData()
  return allDoneData[tonumber(actId)] == 1
end
function ActivityCenterSystem.OnHostedActivityAllDone(actId, appType)
  log(bWriteLog and "ActivityCenterSystem.OnHostedActivityAllDone actId:" .. tostring(actId) .. " appType:" .. tostring(appType))
  _hostedActAllDoneCache = nil
  local changeList = {
    idList = {
      [actId] = true
    },
    typeList = {}
  }
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changeList)
end
function ActivityCenterSystem.ShowBHAdOrNot()
  log(bWriteLog and "ActivityCenterSystem.ShowBHAd")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsBLUEHOLE() then
    return
  end
  local BShowBHAd = HDmpveRemote.HDmpveRemoteConfigGetBool("BShowBHAd", false)
  if not BShowBHAd then
    log(bWriteLog and "ActivityCenterSystem.LoadBHAd.  BShowBHAd is false")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local bIsDiffDate = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eBHAdToday, true)
  if not bIsDiffDate then
    log(bWriteLog and "ActivityCenterSystem.LoadBHAd.  today has shown ad")
    return
  end
  local AdvertiseSdk = require("client.logic.advertise.logic_advertise_sdk")
  AdvertiseSdk:LoadAdWithoutPrize()
  PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eBHAdToday)
end
return ActivityCenterSystem