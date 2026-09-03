local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local SmallPaymentHandler = require("client.network.Protocol.SmallPaymentHandler")
local Const_SmallPayment = require("client.slua.logic.SmallPayment.Const_SmallPayment")
local Logic_SmallPayment = {}
local _nActivityId, _nExchangeActivityId, _tAllTaskData, _tAllTaskHash, _nExchangeUpdateTime
local _tTaskRewardCache = {}
local _tLocalCache, _tCallbackHandle, _bIsTipsJump, _nShowTimerId
function Logic_SmallPayment.Init()
  Logic_SmallPayment.InitLocalCache()
end
function Logic_SmallPayment.OnJumpByUrl()
  local exAtcId = Logic_SmallPayment.GetExchangeActId()
  if exAtcId == 0 then
    ShowNotice(4002)
    Logic_SmallPayment.RequestActivityData()
    return
  end
  local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  LuckybackActivitySystem.OpenExchangeStoreExternal(true, exAtcId, nil, nil, 33)
end
function Logic_SmallPayment.OnLogin(bReLogin)
  log(bWriteLog and " Logic_SmallPayment.OnLogin bReLogin >>>>" .. tostring(bReLogin))
  if bReLogin then
    SmallPaymentHandler.send_get_noble_coupon_activity_req()
  end
end
function Logic_SmallPayment.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby or GameStatus.IsInLobbyOrMainCity() then
    Logic_SmallPayment.Init()
    Logic_SmallPayment.RequestActivityData()
  else
    Logic_SmallPayment.Release()
  end
end
function Logic_SmallPayment.InitLocalCache()
  if _tLocalCache then
    return
  end
  local version_util = require("client.common.version_util")
  local sVersion = version_util.GetClientFormat(Client.GetAppVersion())
  local tValue = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSmallPaymentCache)
  if not (type(tValue) == "table" and tValue.sVersion) or tValue.sVersion ~= sVersion then
    _tLocalCache = {
      sVersion = sVersion,
      tShowedGroup = {},
      tGroupGetCount = {},
      tFinishedTaskId = {}
    }
  else
    _tLocalCache = tValue
  end
end
function Logic_SmallPayment.ShowLobbyRewardTip(tReward)
  log_tree("Logic_SmallPayment.ShowLobbyRewardTip tReward:", tReward)
  if not _tCallbackHandle then
    _tCallbackHandle = {
      checkJump = function()
        return not UIManager.IsUIShow(UIManager.UI_Config.SmallPayment_Exchange_New_UIBP)
      end,
      callback = function()
        local exAtcId = Logic_SmallPayment.GetExchangeActId()
        if exAtcId == 0 then
          ShowNotice(4002)
          Logic_SmallPayment.RequestActivityData()
          return
        end
        _bIsTipsJump = true
        local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
        LuckybackActivitySystem.OpenExchangeStoreExternal(true, exAtcId, nil, nil, 33)
      end
    }
  end
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local sTitle = LocUtil.GetLocalizeResStr(125056)
  local sContent = LocUtil.LocalizeResFormat(125057, tReward.count or 0)
  local UIUtil = require("client.common.ui_util")
  local path = UIUtil.GetItemBigIcon(tReward.resid)
  local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
  local ConfigTab = ui_show_queue_config.GetParamTable(nil, "SmallPayment")
  RightPopSystem.CommonPopup(ConfigTab, sTitle, sContent, path, _tCallbackHandle, 5)
end
function Logic_SmallPayment.Release()
  _nActivityId = nil
  _nExchangeActivityId = nil
  _tLocalCache = nil
  _tAllTaskData = nil
  _tAllTaskHash = nil
  Logic_SmallPayment.ReleaseTimer()
end
function Logic_SmallPayment.GetActivityId()
  return _nActivityId or 0
end
function Logic_SmallPayment.GetExchangeActId()
  return _nExchangeActivityId or 0
end
function Logic_SmallPayment.IsShowAdd()
  return Logic_SmallPayment.GetActivityId() > 0
end
function Logic_SmallPayment.GetRefreshTime()
  return _nExchangeUpdateTime or 0
end
function Logic_SmallPayment.GetIsTipsJump()
  return _bIsTipsJump
end
function Logic_SmallPayment.ResetJumpStatus()
  _bIsTipsJump = false
end
function Logic_SmallPayment.GetTaskCfgById(nTaskId)
  local sCfgName = "CouponTaskTable"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bIsJapanOrKorea = PublishRegionMacros.IsJapanOrKorea()
  local bIsBLUEHOLE = PublishRegionMacros.IsBLUEHOLE()
  if bIsJapanOrKorea then
    sCfgName = "CouponTaskTable_JK"
  elseif bIsBLUEHOLE then
    sCfgName = "CouponTaskTable_IN"
  end
  local tTaskCfg = CDataTable.GetTableData(sCfgName, nTaskId)
  return tTaskCfg
end
function Logic_SmallPayment.GetTaskGroupCfgById(nGroupId)
  local sCfgName = "CouponTaskGroup"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bIsJapanOrKorea = PublishRegionMacros.IsJapanOrKorea()
  local bIsBLUEHOLE = PublishRegionMacros.IsBLUEHOLE()
  if bIsJapanOrKorea then
    sCfgName = "CouponTaskGroup_JK"
  elseif bIsBLUEHOLE then
    sCfgName = "CouponTaskGroup_IN"
  end
  local tTaskGroupCfg = CDataTable.GetTableData(sCfgName, nGroupId)
  return tTaskGroupCfg
end
function Logic_SmallPayment.SetAllTaskData(tAllData)
  _tAllTaskData = tAllData
end
function Logic_SmallPayment.UpdateTaskData(tTaskData)
  local tAllTaskData = _tAllTaskData or {}
  for _, v in pairs(tTaskData) do
    local tGroupData = tAllTaskData[v.task_group_id]
    if tGroupData then
      for _, tData in pairs(tGroupData.single_task_info) do
        if tData.task_id == v.task_id then
          tData.task_status = v.task_status
          tData.progress = v.progress
          tData.completed_times = v.completed_times
          tData.show_type = v.show_type
          break
        end
      end
    end
  end
end
local _AddShowData = function(tAllData, tAddData, nShowGroupId, bIsTimeLimit)
  local Enum_RFType = Const_SmallPayment.Enum_RFType
  local Enum_TakeState = Const_SmallPayment.Enum_TakeState
  local bIsPreviewTip = false
  local TimeUtil = require("client.common.time_util")
  local nNowTime = TimeUtil.GetServerTimeInSec()
  local nCount = #tAllData
  local nShowIndex = 0
  for i = 1, #tAddData do
    local nTotalRewardCount = 0
    local nReceivedCount = 0
    local bIsDone = true
    for _, v in pairs(tAddData[i].single_task_info) do
      if v.task_status == Enum_TakeState.Incomplete then
        bIsDone = false
      end
      nReceivedCount = nReceivedCount + v.coupon_num * v.completed_times
      nTotalRewardCount = nTotalRewardCount + v.coupon_num * v.task_times
      v.nShowType = Enum_RFType.TaskItem
    end
    tAddData[i].nShowType = bIsTimeLimit and Enum_RFType.TimeBoundTaskGroup or Enum_RFType.ResidentTaskGroup
    tAddData[i].    tAddData[i].    tAddData[i].    tAddData[i].bIsNewTip = Logic_SmallPayment.GetGroupTaskIsShowed(tAddData[i].nGroupId)
    local nOldGetCount = Logic_SmallPayment.GetGroupTaskRewardGotCount(tAddData[i].nGroupId)
    tAddData[i].nNewGetCount = nReceivedCount - nOldGetCount
  end
  for _, v in pairs(tAddData) do
    if nNowTime >= v.begin_time then
      v.index = 1
    else
      v.index = 2
    end
  end
  table.sort(tAddData, function(a, b)
    if a.index == b.index and a.index == 1 then
      return a.begin_time > b.begin_time
    elseif a.index < b.index then
      return true
    elseif a.index == b.index and a.index == 2 then
      return a.begin_time < b.begin_time
    end
    return
  end)
  for i = 1, #tAddData do
    local tGroupData = tAddData[i]
    if nNowTime < tGroupData.begin_time then
      local ENUM_TitleType = Const_SmallPayment.ENUM_TitleType
      table.insert(tAllData, {
        nShowType = Enum_RFType.Title,
        title = ENUM_TitleType.Preview
      })
      table.insert(tAllData, tGroupData)
      if tAddData[i + 1] then
        bIsPreviewTip = true
      end
      break
    elseif nNowTime < tGroupData.end_time then
      table.insert(tAllData, tGroupData)
      nCount = nCount + 1
      if nShowGroupId and tGroupData.nGroupId == nShowGroupId then
        nShowIndex = nCount
      end
      if nShowIndex == 0 then
        nShowIndex = nCount
      end
    end
    if tGroupData.bIsOpenList then
      if not tGroupData.bIsSorted then
        tGroupData.bIsSorted = true
        table.sort(tGroupData.single_task_info, function(a, b)
          return a.task_id < b.task_id
        end)
      end
      local tUnFinishTask = {}
      local tFinishTask = {}
      for _, v in pairs(tGroupData.single_task_info) do
        if v.task_status == 0 then
          table.insert(tUnFinishTask, v)
        elseif v.task_status == 1 then
          table.insert(tFinishTask, v)
        end
      end
      tGroupData.single_task_info = tUnFinishTask
      for _, v in pairs(tFinishTask) do
        table.insert(tGroupData.single_task_info, v)
      end
      for _, tTaskData in ipairs(tGroupData.single_task_info) do
        tTaskData.nShowType = Enum_RFType.TaskItem
        table.insert(tAllData, tTaskData)
        nCount = nCount + 1
      end
    end
  end
  return tAllData, bIsPreviewTip, nShowIndex
end
function Logic_SmallPayment.GetGroupTaskShowData(nShowGroupId)
  local Enum_RFType = Const_SmallPayment.Enum_RFType
  local tAllData = {}
  local tPermanentGroup = {}
  local nShowIndex = 0
  local TableUtil = require("common.table_util")
  local tAllTaskData = _tAllTaskData and TableUtil.CopyTable(_tAllTaskData) or {}
  for nGroupId, tGroupTask in pairs(tAllTaskData) do
    local tGroupConfig = Logic_SmallPayment.GetTaskGroupCfgById(nGroupId)
    if not tGroupConfig then
      break
    end
    tGroupTask.    tGroupTask.bIsOpenList = tGroupTask.bIsOpenList or false
    tGroupTask.ActivityName = tGroupConfig.ActivityName
    tGroupTask.ActivityLocalId = tGroupConfig.ActivityLocalId
    table.insert(tPermanentGroup, tGroupTask)
  end
  local bIsPreviewTip = false
  local ENUM_TitleType = Const_SmallPayment.ENUM_TitleType
  table.insert(tAllData, {
    nShowType = Enum_RFType.Title,
    title = ENUM_TitleType.Underway
  })
  tAllData, bIsPreviewTip, nShowIndex = _AddShowData(tAllData, tPermanentGroup, nShowGroupId, true)
  return tAllData, nShowIndex
end
function Logic_SmallPayment.GetGroupTaskIsShowed(nGroupId)
  local tLocalCache = _tLocalCache
  if tLocalCache and tLocalCache.tShowedGroup and tLocalCache.tShowedGroup[nGroupId] then
    return true
  end
  return false
end
function Logic_SmallPayment.GetGroupTaskRewardGotCount(nGroupId)
  local tLocalCache = _tLocalCache
  if tLocalCache and tLocalCache.tGroupGetCount and tLocalCache.tGroupGetCount[nGroupId] then
    return tLocalCache.tGroupGetCount[nGroupId]
  end
  return 0
end
function Logic_SmallPayment.UpdateGroupTaskData(nGroupId, bIsOpen)
  if not nGroupId then
    return
  end
  local tAllTaskData = _tAllTaskData or {}
  tAllTaskData[nGroupId].bIsOpenList = bIsOpen
end
function Logic_SmallPayment.InitAllTaskHash()
  local tAllTaskData = _tAllTaskData or {}
  local Enum_NowTaskSort = Const_SmallPayment.Enum_NowTaskSort
  local tAllTaskHash = {}
  local TimeUtil = require("client.common.time_util")
  local nNowTime = TimeUtil.GetServerTimeInSec()
  for nGroupId, tGroupTask in pairs(tAllTaskData) do
    for _, tTask in pairs(tGroupTask.single_task_info) do
      tTask.begin_time = tGroupTask.begin_time
      tTask.end_time = tGroupTask.end_time
      tTask.nRemainingTime = tTask.end_time - nNowTime
      tTask.nSortValue = Enum_NowTaskSort.Normal
      if tTask.nRemainingTime <= 0 then
        tTask.nRemainingTime = 0
      end
      if tTask.recomm_type then
        tTask.nSortValue = Enum_NowTaskSort.Recomm
      end
      tTask.      tAllTaskHash[tTask.task_id] = tTask
    end
  end
  _end
function Logic_SmallPayment.GetTaskDataById(nTaskId)
  if not _tAllTaskHash then
    Logic_SmallPayment.InitAllTaskHash()
  end
  return _tAllTaskHash[nTaskId]
end
function Logic_SmallPayment.GetNowShowTask()
  local tData = {}
  local Enum_TaskShow = Const_SmallPayment.Enum_TaskShow
  local Enum_TakeState = Const_SmallPayment.Enum_TakeState
  local Enum_NowTaskSort = Const_SmallPayment.Enum_NowTaskSort
  if not _tAllTaskHash then
    Logic_SmallPayment.InitAllTaskHash()
  end
  if not _tLocalCache then
    Logic_SmallPayment.InitLocalCache()
  end
  local tNeedRemoveId = {}
  local TimeUtil = require("client.common.time_util")
  local nNowTime = TimeUtil.GetServerTimeInSec()
  local TableUtil = require("common.table_util")
  local tAllTaskHash = TableUtil.CopyTable(_tAllTaskHash)
  local tLocalCache = _tLocalCache
  for _, tTask in pairs(tAllTaskHash) do
    if tTask.show_type == Enum_TaskShow.Show or not Logic_SmallPayment.GetNowTaskFinished(tTask.task_id) and tTask.task_status == Enum_TakeState.Received then
      if tTask.task_status == Enum_TakeState.Received then
        if tTask.recomm_type == 1 then
          tTask.nSortValue = Enum_NowTaskSort.FinishRecomm
        else
          tTask.nSortValue = Enum_NowTaskSort.FinishNormal
        end
        local tTaskConfig = Logic_SmallPayment.GetTaskCfgById(tTask.task_id)
        local nPostTaskId = tTaskConfig.PostTaskId
        tTask.        if _tAllTaskHash[tTask.task_id] then
          _tAllTaskHash[tTask.task_id].        end
        tNeedRemoveId[nPostTaskId] = true
        table.insert(tData, tTask)
      elseif tTask.show_type == Enum_TaskShow.Show then
        if Logic_SmallPayment.GetNowTaskFinished(tTask.task_id) then
          tLocalCache.tFinishedTaskId[tTask.task_id] = nil
          PlayerPrefsSystem.SaveTableToFile_N(tLocalCache, PlayerPrefsSystem.ePlayerPrefsType.eSmallPaymentCache)
        end
        if tTask.recomm_type == 1 then
          tTask.nSortValue = Enum_NowTaskSort.Recomm
        else
          tTask.nSortValue = Enum_NowTaskSort.Normal
        end
        if nNowTime >= tTask.begin_time and nNowTime < tTask.end_time then
          table.insert(tData, tTask)
        end
      end
    end
  end
  for nTaskId, _ in pairs(tNeedRemoveId) do
    for nIndex, tTask in pairs(tData) do
      if nTaskId == tTask.task_id then
        table.remove(tData, nIndex)
        break
      end
    end
  end
  table.sort(tData, function(a, b)
    if a.nSortValue < b.nSortValue then
      return false
    elseif a.nSortValue == b.nSortValue then
      return a.nRemainingTime < b.nRemainingTime
    else
      return true
    end
  end)
  return tData
end
function Logic_SmallPayment.GetNowTaskFinished(nTaskId)
  local tLocalCache = _tLocalCache
  if tLocalCache and tLocalCache.tFinishedTaskId and tLocalCache.tFinishedTaskId[nTaskId] then
    return true
  end
  return false
end
function Logic_SmallPayment.TaskParamConvertData(sParamStr)
  local tParams = {}
  if sParamStr then
    local StringUtil = require("common.string_util")
    local tAllStr = StringUtil.Split(sParamStr, "|")
    for _, v in ipairs(tAllStr) do
      local tValue = StringUtil.Split(v, ";")
      local nNum = tonumber(tValue[1])
      if nNum == 1 then
        table.insert(tParams, tValue[2])
      elseif nNum == 2 then
        local tItemConfig = CDataTable.GetTableData("Item", tValue[2])
        local sContent = tItemConfig and tItemConfig.ItemName or ""
        table.insert(tParams, sContent)
      end
    end
  end
  return tParams
end
function Logic_SmallPayment.CacheServerAllTaskData(tAllTaskData)
  log_tree("Logic_SmallPayment.TryTaskRewardShow tAllTaskData = ", tAllTaskData or {})
  for _, v in pairs(tAllTaskData) do
    if v.get_coupon_info and next(v.get_coupon_info) then
      table.insert(_tTaskRewardCache, v.get_coupon_info)
    end
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_POST_SWITCH_SMALL_PAYMENT_TASK_POPUP)
end
function Logic_SmallPayment.TaskRewardShow()
  log_tree("Logic_SmallPayment.TaskRewardShow tAllTaskData = ", _tTaskRewardCache)
  if not _tTaskRewardCache or #_tTaskRewardCache == 0 then
    log_warning(bWriteLog and "Logic_SmallPayment.TaskRewardShow _tTaskRewardCache is empty")
    return
  end
  if not Logic_SmallPayment.IsShowAdd() then
    log_warning(bWriteLog and "Logic_SmallPayment.TaskRewardShow not activity data")
    return
  end
  for _, v in pairs(_tTaskRewardCache) do
    Logic_SmallPayment.ShowLobbyRewardTip(v)
  end
  _tTaskRewardCache = {}
end
function Logic_SmallPayment.SaveCurOpenTaskGroupId(tAllTaskData)
  local tLocalCache = _tLocalCache
  if not (tLocalCache and tLocalCache.tShowedGroup) or not tLocalCache.tGroupGetCount then
    return
  end
  local bIsSave = false
  local TimeUtil = require("client.common.time_util")
  local nNowTime = TimeUtil.GetServerTimeInSec()
  tAllTaskData = tAllTaskData or {}
  for _, tGroupTask in pairs(tAllTaskData) do
    if tGroupTask.single_task_info then
      local nGroupId = tGroupTask.nGroupId
      if nNowTime >= tGroupTask.begin_time and nNowTime < tGroupTask.end_time then
        tLocalCache.tShowedGroup[nGroupId] = 1
        tLocalCache.tGroupGetCount[nGroupId] = tGroupTask.nReceivedCount or 0
        bIsSave = true
      end
    end
  end
  if bIsSave then
    PlayerPrefsSystem.SaveTableToFile_N(tLocalCache, PlayerPrefsSystem.ePlayerPrefsType.eSmallPaymentCache)
  end
end
function Logic_SmallPayment.SaveNowTaskFinished(nTaskId)
  local tLocalCache = _tLocalCache
  if not tLocalCache or not tLocalCache.tFinishedTaskId then
    return
  end
  tLocalCache.tFinishedTaskId[nTaskId] = 1
  PlayerPrefsSystem.SaveTableToFile_N(tLocalCache, PlayerPrefsSystem.ePlayerPrefsType.eSmallPaymentCache)
end
function Logic_SmallPayment.GetIsInActTime()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local tActivityData = ActivityNewSystem.GetActivityByType(ActivityType.SmallPayment)
  local TimeUtil = require("client.common.time_util")
  local nCurTime = TimeUtil.GetServerTimeInSec()
  if tActivityData and nCurTime >= tActivityData.StartTime and nCurTime <= tActivityData.EndTime then
    return true
  end
  return false
end
function Logic_SmallPayment.RequestActivityData()
  if _nActivityId then
    return
  end
  log(bWriteLog and "Logic_SmallPayment.RequestActivityData: ")
  SmallPaymentHandler.send_get_noble_coupon_activity_req()
end
function Logic_SmallPayment.HandlerActivityData(tAllTaskData, tBaseData)
  _tAllTaskHash = nil
  _nActivityId = tBaseData.activity_id
  _nExchangeActivityId = tBaseData.relate_exchange_activity_id
  _nExchangeUpdateTime = tBaseData.next_update_time
  _  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_POST_SWITCH_SMALL_PAYMENT_TASK_POPUP)
end
function Logic_SmallPayment.HandleErrorCode(nCode)
  if nCode == 112800001 then
    ShowNotice(125046)
  elseif nCode == 112800006 then
    ShowNotice(125048)
  elseif nCode == 112800007 then
    ShowNotice(125049)
  elseif nCode == 114800006 then
    ShowNotice(125049)
  end
end
function Logic_SmallPayment.TestFun()
  local version_util = require("client.common.version_util")
  local sVersion = version_util.GetClientFormat(Client.GetAppVersion())
  _tLocalCache = {
    sVersion = sVersion,
    tShowedGroup = {},
    tGroupGetCount = {},
    tFinishedTaskId = {}
  }
  PlayerPrefsSystem.SaveTableToFile_N(_tLocalCache, PlayerPrefsSystem.ePlayerPrefsType.eSmallPaymentCache)
end
function Logic_SmallPayment.ReleaseTimer()
  local time_ticker = require("common.time_ticker")
  if _nShowTimerId then
    time_ticker.RemoveTimer(_nShowTimerId)
    _nShowTimerId = nil
  end
end
return Logic_SmallPayment