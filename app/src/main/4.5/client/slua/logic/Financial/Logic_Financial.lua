local Const_Financial = require("client.slua.logic.Financial.Const_Financial")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local Logic_Financial = {}
local AWARD_FIRST = 1
local TASK_SCORE_ITEM = 4200001
local MONEY_NO_UC_ERR = 100800009
local E_TaskState = Const_Financial.E_TaskState
local E_BoxState = Const_Financial.E_BoxState
local E_BoxRewardState = Const_Financial.E_BoxRewardState
local _bIsShowUI = false
local _ActivityId
local _nActivityStartTime = 0
local _nActivityEndTime = 0
local _nCurScore = 0
local _tScoreList = {}
local _bIsBuyGift = false
local _bIsFirstLogin = false
local _bIsFirstShow = true
local _bIsFirstAct = false
local _tAllTaskData = {}
local _tAllBoxData = {}
local _tBoxStateDict = {}
function Logic_Financial.Init()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bIsJapanOrKorea = PublishRegionMacros.IsJapanOrKorea()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  if bIsJapanOrKorea and ActivityNewSystem.IsActivityOpenByBanner(BP_ENUM_MODULE_FINANCIAL_P) then
    return
  end
  Logic_Financial.RequestActivityData()
end
function Logic_Financial.ShowUIHandle()
  _bIsShowUI = true
  Logic_Financial.RequestActivityData()
end
function Logic_Financial.ShowUI()
  if not _ActivityId then
    log(bWriteLog and " Logic_Financial.ShowUI not _ActivityId >>> ")
    return
  end
  local state = PufferManager.GetStateByModuleIDActivityID(nil, _ActivityId)
  if state == PufferConst.ENUM_DownloadState.Done then
    local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
    special_offer_module:OpenFinancialActivity()
  end
end
function Logic_Financial.GetIsFirstShow()
  return _bIsFirstShow
end
function Logic_Financial.SetIsFirstShow(bIsFirst)
  _bIsFirstShow = bIsFirst
end
function Logic_Financial.GetIsFirstAct()
  return _bIsFirstAct and _bIsFirstShow
end
function Logic_Financial.SetIsFirstAct(bIsFirst)
  _bIsFirstAct = bIsFirst
end
function Logic_Financial.HasAvailableTask()
  for _, info in ipairs(_tAllTaskData) do
    if info.state == E_TaskState.Available then
      return true
    end
  end
  return false
end
function Logic_Financial.HasAvailableBox()
  local result = false
  for _, info in ipairs(_tAllBoxData) do
    if info.status == E_BoxState.Bought then
      result = false
      break
    end
    if info.status == E_BoxState.CanBuy then
      result = true
    end
  end
  return result
end
function Logic_Financial.IsShowRed()
  if _bIsFirstShow then
    return true
  end
  if Logic_Financial.HasAvailableTask() then
    return true
  end
  return false
end
function Logic_Financial.RefreshRedDot()
  local result = false
  if not _bIsBuyGift then
    result = Logic_Financial.IsShowRed()
  end
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_FINANCIAL_P, result)
end
function Logic_Financial.ExtHandle(tExtInfo)
  _nCurScore = tExtInfo.cur_score or 0
  _tScoreList = tExtInfo.score_list or {}
  _bIsFirstLogin = tExtInfo.is_first_login
  _bIsBuyGift = tExtInfo.has_buy_gift
  if not _bIsFirstAct then
    _bIsFirstAct = tExtInfo.is_first_act
  end
  Logic_Financial.UpdateBoxState()
end
function Logic_Financial.ExtNtfHandle(nCurScore)
  _nCurScore = nCurScore or 0
  Logic_Financial.UpdateBoxState()
end
function Logic_Financial.UpdateBoxState()
  for id, score in pairs(_tScoreList) do
    if score and score <= _nCurScore then
      _tBoxStateDict[id] = true
    else
      _tBoxStateDict[id] = false
    end
  end
end
function Logic_Financial.GetCurScore()
  return _nCurScore or 0
end
function Logic_Financial.GetAllBoxData()
  return _tAllBoxData or {}
end
function Logic_Financial.BoxHandle(tBoxList)
  _tAllBoxData = {}
  if not tBoxList or type(tBoxList) ~= "table" then
    return
  end
  local len = #tBoxList
  for i, data in ipairs(tBoxList) do
    local bIsFirst = i == AWARD_FIRST
    local bIsLast = i == len
    local nId = data.reward_id or 0
    local status = Logic_Financial.GetBoxStatus(nId, data.reward_status or 0)
    Logic_Financial.SetBoxData(bIsFirst, bIsLast, data.item or {}, data.cost_uc or 0, data.cost_score or 0, nId, data.same_uc_value or 0, status)
  end
  Logic_Financial.BoxProgressHandle()
end
function Logic_Financial.BuyBoxHandle(nRewardId)
  _bIsBuyGift = true
  for _, data in ipairs(_tAllBoxData) do
    if data.id == nRewardId then
      data.status = E_BoxState.Bought
    else
      data.status = E_BoxState.DontBuy
    end
  end
  local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, special_offer_cfg.Financial)
  Logic_Financial.BoxProgressHandle()
end
function Logic_Financial.BoxRefreshHandle()
  for _, info in ipairs(_tAllBoxData) do
    if info and _tBoxStateDict[info.id] and info.status == E_BoxState.DontBuy then
      info.status = E_BoxState.CanBuy
    end
  end
  Logic_Financial.BoxProgressHandle()
end
function Logic_Financial.BoxProgressHandle()
  local before
  for _, info in ipairs(_tAllBoxData) do
    if info then
      info.progressL = Logic_Financial.GetProgress(info.id)
      if before then
        before.progressR = Logic_Financial.GetProgress(info.id)
      end
    end
    before = info
  end
end
function Logic_Financial.SetBoxData(bIsFirst, bIsLast, tItem, nUc, nScore, nId, nPrice, nStatus)
  local temp = {
    id = nId,
    atLast = bIsLast,
    atFirst = bIsFirst,
    price = nPrice,
    UC = 0,
    status = nStatus,
    award = tItem,
    boxUC = nUc,
    boxScore = nScore
  }
  table.insert(_tAllBoxData, temp)
end
function Logic_Financial.GetBoxStatus(nId, nStatus)
  local temp = E_BoxState.DontBuy
  if nStatus == E_BoxRewardState.NotReceived then
    if _tBoxStateDict[nId] then
      temp = E_BoxState.CanBuy
    else
      temp = E_BoxState.DontBuy
    end
  else
    temp = E_BoxState.Bought
  end
  return temp
end
function Logic_Financial.GetProgress(nId)
  local len = 0
  if _tBoxStateDict[nId] then
    len = 1
  end
  return len
end
function Logic_Financial.GetIsBuyGift()
  return _bIsBuyGift
end
function Logic_Financial.GetCurBuyMaxBox()
  local index = 0
  for _, info in ipairs(_tAllBoxData) do
    if info.status == E_BoxState.CanBuy or info.status == E_BoxState.Bought then
      index = index + 1
    end
  end
  return index
end
function Logic_Financial.GetAllTaskData()
  return _tAllTaskData or {}
end
function Logic_Financial.TaskHandle(taskList)
  if not taskList or type(taskList) ~= "table" then
    return
  end
  _tAllTaskData = {}
  for _, data in ipairs(taskList) do
    Logic_Financial.SetTaskData(data.task_id, data.task_status, data.condition, data.progress, data.score, data.precondition)
  end
  table.sort(_tAllTaskData, Logic_Financial.SortTask)
end
function Logic_Financial.TaskNtfHandle(tTaskList)
  for _, task in ipairs(tTaskList) do
    Logic_Financial.RefreshTask(task)
  end
  table.sort(_tAllTaskData, Logic_Financial.SortTask)
end
function Logic_Financial.SetTaskData(task_id, task_status, condition, progress, score, precondition)
  local tableTaskInfo
  if FuncUtil.IsPlayerJPKR() then
    tableTaskInfo = CDataTable.GetTableData("FinancialTaskOfJK", task_id)
  else
    tableTaskInfo = CDataTable.GetTableData("FinancialTask", task_id)
  end
  if not tableTaskInfo then
    return
  end
  local sContent = tableTaskInfo.TaskDescription or ""
  precondition = precondition or 0
  sContent = LocUtil.LocalizeResFormatByStr(sContent, precondition == 0 and condition or precondition)
  local temp = {
    id = task_id,
    score = tonumber(score) or 0,
    content = sContent,
    state = task_status,
    weight = Logic_Financial.GetWeight(task_status, progress),
    jump = tableTaskInfo.TaskJump or "",
    progress = progress,
      }
  table.insert(_tAllTaskData, temp)
end
function Logic_Financial.GetWeight(nStatus, nProgress)
  local weight = 1
  if nStatus == E_TaskState.Received then
    weight = 1
  elseif nStatus == E_TaskState.Processing then
    if tonumber(nProgress) <= 0 then
      weight = 2
    else
      weight = 3
    end
  elseif nStatus == E_TaskState.Available then
    weight = 4
  end
  return weight
end
function Logic_Financial.RefreshTask(tTask)
  local index = 0
  for i, info in ipairs(_tAllTaskData) do
    if info.id == tTask.task_id then
      index = i
    end
  end
  if index ~= 0 then
    table.remove(_tAllTaskData, index)
    Logic_Financial.SetTaskData(tTask.task_id, tTask.task_status, tTask.condition, tTask.progress, tTask.score, tTask.precondition)
  end
end
function Logic_Financial.SortTask(a, b)
  if a.weight == b.weight then
    return tonumber(a.id) > tonumber(b.id)
  end
  return a.weight > b.weight
end
function Logic_Financial.ShowRecharge()
  local RechargeSystem = require("client.logic.recharge.logic_recharge")
  RechargeSystem.OpenRechargeUI()
end
function Logic_Financial.GetActivityBannerData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activityData = ActivityNewSystem.GetActivityByType(ActivityType.MAKE_MONEY_PLAY)
  if not activityData then
    log(bWriteLog and " FinancialSystem.GetActivityData Activity data doesn't exist!")
    return nil
  end
  return activityData
end
function Logic_Financial.GetActivityTime()
  local data = Logic_Financial.GetActivityBannerData()
  if data then
    _ActivityId = data.ID
    _nActivityStartTime = tonumber(data.StartTime)
    _nActivityEndTime = tonumber(data.EndTime)
  end
  return _nActivityStartTime, _nActivityEndTime
end
function Logic_Financial.RequestActivityData()
  Logic_Financial.GetActivityTime()
  if not (_nActivityStartTime and _nActivityEndTime) or _nActivityStartTime == 0 then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nNowTime = TimeUtil.GetServerTimeInSec()
  if _nActivityEndTime == 0 or nNowTime < _nActivityEndTime and nNowTime >= _nActivityStartTime then
    local FinancialHandler = require("client.network.Protocol.FinancialHandler")
    FinancialHandler.send_get_make_money_plan_req(_ActivityId)
  end
end
function Logic_Financial.ActivityDataRspHandle(err_code, task_info, reward_info, ext_info)
  if err_code == 0 then
    Logic_Financial.ExtHandle(ext_info)
    Logic_Financial.TaskHandle(task_info)
    Logic_Financial.BoxHandle(reward_info)
    Logic_Financial.RefreshRedDot()
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_FINANCIAL, EVENTID_ACTIVITY_FINANCIAL_DATA)
    EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_OFFER_REFRESH_PAGE)
    if _bIsShowUI then
      Logic_Financial.ShowUI()
    end
  elseif _bIsShowUI then
    Logic_Financial.ShowErrorTips(err_code)
  end
  _bIsShowUI = false
end
function Logic_Financial.SyncMakeTaskNtf(task_info, ext_info)
  if task_info and type(task_info) == "table" then
    Logic_Financial.TaskNtfHandle(task_info)
  end
  if ext_info and type(ext_info) == "table" then
    Logic_Financial.ExtNtfHandle(ext_info.cur_score)
    Logic_Financial.BoxRefreshHandle()
  end
  Logic_Financial.RefreshRedDot()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_FINANCIAL, EVENTID_ACTIVITY_FINANCIAL_TASK)
end
function Logic_Financial.GetTaskReward(task_id)
  local FinancialHandler = require("client.network.Protocol.FinancialHandler")
  FinancialHandler.send_get_make_money_plan_task_reward_req(task_id, _ActivityId)
end
function Logic_Financial.ResTaskReward(err_code, task_id)
  if err_code == 0 then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    for _, info in ipairs(_tAllTaskData) do
      if info.id == task_id then
        Logic_CommonItemGet.ShowPanel_DefaultStyle({
          {
            res_id = TASK_SCORE_ITEM,
            count = info.score or 0,
            0
          }
        })
      end
    end
  else
    Logic_Financial.ShowErrorTips(err_code)
  end
end
function Logic_Financial.GetAllTaskReward()
  local FinancialHandler = require("client.network.Protocol.FinancialHandler")
  FinancialHandler.send_get_make_money_plan_multiple_task_reward_req(_ActivityId)
end
function Logic_Financial.ResByAllTask(err, ids)
  if err ~= 0 then
    if err == 100800001 then
      ShowNotice(LocUtil.GetLocalizeResStr(89005))
    else
      ShowNotice(LocUtil.GetLocalizeResStr(8177))
    end
  else
    local totalNum = 0
    for _, info in ipairs(_tAllTaskData) do
      for _, v in pairs(ids) do
        if info.id == v then
          totalNum = totalNum + info.score
        end
      end
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle({
      {
        res_id = TASK_SCORE_ITEM,
        count = totalNum or 0,
        0
      }
    })
  end
end
function Logic_Financial.BuyBox(reward_id)
  local FinancialHandler = require("client.network.Protocol.FinancialHandler")
  FinancialHandler.send_buy_make_money_plan_gift_req(reward_id, _ActivityId)
end
function Logic_Financial.ResBuyBox(err_code, reward_id, item_list, cur_score)
  if err_code == 0 then
    Logic_Financial.ExtNtfHandle(cur_score)
    Logic_Financial.BuyBoxHandle(reward_id)
    if item_list and next(item_list) then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(item_list)
    end
    Logic_Financial.RefreshRedDot()
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_FINANCIAL, EVENTID_ACTIVITY_FINANCIAL_BOX)
  else
    if err_code == MONEY_NO_UC_ERR then
      Logic_Financial.ShowRecharge()
    end
    Logic_Financial.ShowErrorTips(err_code)
  end
end
function Logic_Financial.ShowErrorTips(err_code)
  local TextData = LocUtil.GetLocalizeResStr(err_code)
  if TextData ~= "" then
    ShowNotice(TextData)
  else
    ShowNotice(err_code)
  end
end
return Logic_Financial