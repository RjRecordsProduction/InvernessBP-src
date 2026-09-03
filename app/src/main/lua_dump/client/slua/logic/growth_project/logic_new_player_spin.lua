local logic_new_player_spin = {}
logic_new_player_spin.EnumStatus = {
  NoFinish = 0,
  GetReward = 1,
  FinishGet = 2
}
function logic_new_player_spin.ResetData()
  logic_new_player_spin.ServerData = {}
  logic_new_player_spin.bOpenSpin = false
  logic_new_player_spin.ScoreID = 1321
  logic_new_player_spin.TicketID = 1320
  logic_new_player_spin.TaskList = {}
  logic_new_player_spin.ScoreReward = {}
  logic_new_player_spin.TenDrawList = {}
  logic_new_player_spin.SpinTwelveList = {}
  logic_new_player_spin.NewBieItem = nil
  logic_new_player_spin.bFstOpenUI = true
  logic_new_player_spin.bGetData = false
  logic_new_player_spin.bGetSwitch = false
  logic_new_player_spin.BannerUrl = ""
end
function logic_new_player_spin.GetNewbieSpinInfo()
  if not logic_new_player_spin.bGetData or not logic_new_player_spin.bOpenSpin then
    return
  end
  return {
    nActID = ActivityFixedID.Newbie_Spin,
    sName = LocUtil.GetLocalizeResStr(13696),
    bRedDot = logic_new_player_spin.UpdateRedTip,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = 0
  }
end
function logic_new_player_spin.Init()
  logic_new_player_spin.ResetData()
  EventSystem:unregistEvent(EVENTTYPE_LOBBY, EVENTID_ON_FETCH_SWITCH, logic_new_player_spin.UpdateSwitch)
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_ON_FETCH_SWITCH, logic_new_player_spin.UpdateSwitch)
end
function logic_new_player_spin.UpdateSwitch()
  logic_new_player_spin.bGetSwitch = true
  if logic_new_player_spin.bGetData then
    logic_new_player_spin:OnRecvData(logic_new_player_spin.ServerData)
  end
end
function logic_new_player_spin.Tlog(ClientShow)
  local time_ticker = require("common.time_ticker")
  if logic_new_player_spin.TlogTimer then
    time_ticker.RemoveTimer(logic_new_player_spin.TlogTimer)
    logic_new_player_spin.TlogTimer = nil
  end
  local registertime = DataMgr.registertime
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if 1209600 < now - registertime then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSpinTlog)
  if saveData then
    return
  end
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.eSpinTlog)
  local DiffVal
  if logic_new_player_spin.ServerData and logic_new_player_spin.ServerData.end_time then
    DiffVal = logic_new_player_spin.ServerData.end_time - now
  end
  local str = string.format("%s_%s_%s_%s", tostring(logic_new_player_spin.bGetData), tostring(logic_new_player_spin.ServerData.day), tostring(DiffVal), tostring(ClientShow))
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SpinDebugTest, nil, str)
end
function logic_new_player_spin.OnRecvData(celebration_info)
  logic_new_player_spin.bGetData = true
  if not logic_new_player_spin.bGetSwitch then
    return
  end
  logic_new_player_spin.ServerData = celebration_info
  local leftDay = celebration_info.day
  if leftDay and leftDay <= 0 then
    logic_new_player_spin.bOpenSpin = false
    log(bWriteLog and "[qintong] logic_new_player_spin self.bOpenSpin: leftDay  " .. tostring(leftDay))
    return
  end
  local endTime = celebration_info.end_time
  if not endTime then
    logic_new_player_spin.bOpenSpin = false
    log(bWriteLog and "[qintong] logic_new_player_spin self.bOpenSpin: endTime")
    return
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if endTime and endTime <= now then
    logic_new_player_spin.bOpenSpin = false
    log(bWriteLog and "[qintong] logic_new_player_spin self.bOpenSpin: now greater than endTime")
    return
  end
  local SwitchbOpen = LobbySystem.CheckOpen(20224)
  log(bWriteLog and "[qintong] logic_new_player_spin.OnRecvData " .. tostring(SwitchbOpen))
  if not SwitchbOpen then
    logic_new_player_spin.bOpenSpin = false
  else
    logic_new_player_spin.bOpenSpin = true
  end
  if not logic_new_player_spin.bOpenSpin then
    return
  end
  logic_new_player_spin.bOpenSpin = true
  logic_new_player_spin.SpinTwelveList = celebration_info.newbie_drop
  logic_new_player_spin.BannerUrl = celebration_info.newbie_drop_link
  logic_new_player_spin.AssembleTask(celebration_info.newbie_drop_mission)
  logic_new_player_spin.AssembleScoreReward(celebration_info.newbie_drop_points)
  logic_new_player_spin.UpdateRedTip()
  logic_new_player_spin.StartBannerRefreshTimer(endTime)
end
function logic_new_player_spin.GetAwardIndex()
  local nIdx, lastGetIdx
  for i, scoreInfo in ipairs(logic_new_player_spin.ScoreReward) do
    if scoreInfo.status == logic_new_player_spin.EnumStatus.GetReward then
      nIdx = i
      break
    end
  end
  for i, scoreInfo in ipairs(logic_new_player_spin.ScoreReward) do
    if scoreInfo.status == logic_new_player_spin.EnumStatus.FinishGet then
      lastGetIdx = i
    end
  end
  return nIdx, lastGetIdx
end
function logic_new_player_spin.GetBannerUrl()
  return logic_new_player_spin.BannerUrl
end
function logic_new_player_spin.StartBannerRefreshTimer(endTime)
  local time_ticker = require("common.time_ticker")
  if logic_new_player_spin.Timer then
    time_ticker.RemoveTimer(logic_new_player_spin.Timer)
    logic_new_player_spin.Timer = nil
  end
  logic_new_player_spin.Timer = time_ticker.AddTimerLoop(0, function()
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    if now >= endTime then
      logic_new_player_spin.UpdateTimer()
      LobbySystem.refresh_activity_display_byCentauri()
      time_ticker.RemoveTimer(logic_new_player_spin.Timer)
      logic_new_player_spin.Timer = nil
      EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_BANNER_CHANGE)
      return
    end
  end, TIMER_INFINITE, 1)
end
function logic_new_player_spin.IsOpen()
  log(bWriteLog and "[qintong] logic_new_player_spin.IsOpen" .. tostring(logic_new_player_spin.bGetData) .. tostring(logic_new_player_spin.bGetSwitch) .. tostring(logic_new_player_spin.bOpenSpin))
  if logic_new_player_spin.bGetData then
    return logic_new_player_spin.bOpenSpin
  else
    return false
  end
end
function logic_new_player_spin.UpdateTimer(bTest)
  if bTest then
    logic_new_player_spin.bOpenSpin = false
  elseif logic_new_player_spin.bGetData then
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    local endTime = logic_new_player_spin.ServerData.end_time
    if endTime and now >= endTime then
      logic_new_player_spin.bOpenSpin = false
    else
      logic_new_player_spin.bOpenSpin = true
    end
  else
    logic_new_player_spin.bOpenSpin = false
  end
  return logic_new_player_spin.bOpenSpin
end
function logic_new_player_spin.AssembleScoreReward(newbie_drop_points)
  local scoreList = {}
  for index, info in pairs(newbie_drop_points.cfg) do
    local ScoreBox = {
      cfg = info,
      status = newbie_drop_points.status[index],
      points_id = index
    }
    scoreList[index] = ScoreBox
  end
  logic_new_player_spin.ScoreReward = scoreList
  log_tree("[qintong] logic_new_player_spin.AssembleScoreReward", logic_new_player_spin.ScoreReward)
end
function logic_new_player_spin.AssembleTask(newbie_drop_mission)
  local tasklist = {}
  for _type, typeList in pairs(newbie_drop_mission.cfg) do
    if not tasklist[_type] then
      tasklist[_type] = {}
    end
    local task = {}
    for index, atomTask in pairs(typeList.task) do
      task[index] = {task = atomTask, index = index}
      if typeList.award[index] then
        task[index].award = typeList.award[index]
      end
      local mission_id = task[index].task.mission_id
      if newbie_drop_mission.status[mission_id] then
        task[index].status = newbie_drop_mission.status[mission_id]
      end
    end
    table.sort(task, function(a, b)
      return a.task.sort < b.task.sort
    end)
    tasklist[_type] = task
  end
  logic_new_player_spin.TaskList = tasklist
  log_tree("[qintong] logic_new_player_spin.AssembleTask", logic_new_player_spin.TaskList)
end
function logic_new_player_spin.GetScoreID()
  return logic_new_player_spin.ScoreID
end
function logic_new_player_spin.GetScore()
  local value = DataMgr.roleData.newbie_points
  log(bWriteLog and "[qintong] logic_new_player_spin.GetScore" .. tostring(value))
  return value or 0
end
function logic_new_player_spin.GetTicketID()
  return logic_new_player_spin.TicketID
end
function logic_new_player_spin.GetTicketCount()
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local value = WardrobeData:GetHallDepotItemCountByResID(logic_new_player_spin.TicketID)
  return value or 0
end
function logic_new_player_spin.GetActTime()
  local startTime = logic_new_player_spin.ServerData.open_time
  local endTime = logic_new_player_spin.ServerData.end_time
  return startTime, endTime
end
function logic_new_player_spin.OpenSpinUI()
  if logic_new_player_spin.bOpenSpin then
    local logicNewbieMain = require("client.slua.logic.activity.newbie.logic_newbie_activity_config")
    local activityDef = logicNewbieMain.activityDef
    UIManager.ShowUI(UIManager.UI_Config.Activity_Newbie_Main, activityDef.Spin)
  else
    ShowNotice(LocUtil.GetLocalizeResStr(4002))
  end
end
function logic_new_player_spin.GetTaskListByType(taskType)
  for _Type, taskInfo in pairs(logic_new_player_spin.TaskList) do
    if _Type == taskType then
      local TableUtil = require("common.table_util")
      local t = TableUtil.CopyTable(taskInfo)
      return t
    end
  end
  return {}
end
function logic_new_player_spin.GetScoreReward()
  return logic_new_player_spin.ScoreReward
end
function logic_new_player_spin.GetRewardScoreByIndex(idx)
  local lastScore = 0
  if logic_new_player_spin.ScoreReward[idx - 1] then
    lastScore = logic_new_player_spin.ScoreReward[idx - 1].cfg.collect_points
  end
  local nextScore = 9999999999
  if logic_new_player_spin.ScoreReward[idx + 1] then
    nextScore = logic_new_player_spin.ScoreReward[idx + 1].cfg.collect_points
  end
  if idx == #logic_new_player_spin.ScoreReward and lastScore ~= 0 then
    local current = logic_new_player_spin.ScoreReward[idx].cfg.collect_points
    nextScore = 2 * current - lastScore
  end
  return lastScore, nextScore
end
function logic_new_player_spin.GetTaskPreview()
  local list = {}
  for _, taskList in pairs(logic_new_player_spin.TaskList) do
    local enter = false
    for _, taskInfo in ipairs(taskList) do
      if taskInfo.status.finish_status == logic_new_player_spin.EnumStatus.NoFinish then
        enter = true
        table.insert(list, taskInfo)
        break
      end
      if taskInfo.status.finish_status == logic_new_player_spin.EnumStatus.GetReward then
        enter = true
        table.insert(list, taskInfo)
        break
      end
    end
    if not enter then
      table.insert(list, taskList[#taskList])
    end
  end
  return list
end
function logic_new_player_spin.GetSpinTwelveList()
  return logic_new_player_spin.SpinTwelveList
end
function logic_new_player_spin.UpdateTaskReward(mission_type, mission_index)
  local item_list = {}
  for i, taskInfo in pairs(logic_new_player_spin.TaskList[mission_type] or {}) do
    if mission_type == taskInfo.task.mission_type and mission_index == taskInfo.index then
      taskInfo.status.finish_status = logic_new_player_spin.EnumStatus.FinishGet
      for _, itemCfg in pairs(taskInfo.award) do
        local item = {
          res_id = itemCfg.itemid,
          valid_hours = itemCfg.valid_hours,
          count = itemCfg.cnt
        }
        table.insert(item_list, item)
      end
      break
    end
  end
  logic_new_player_spin.UpdateRedTip()
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(item_list)
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_TASK_CHANGE)
end
function logic_new_player_spin.UpdateTaskStatus(mission_id, value, finish_status)
  if not logic_new_player_spin.TaskList then
    printf("logic_new_player_spin.UpdateTaskStatus self.TaskList is nil")
    return
  end
  for _, tasklist in pairs(logic_new_player_spin.TaskList) do
    for _, taskData in pairs(tasklist) do
      if mission_id == taskData.task.mission_id then
        taskData.status.        taskData.status.        break
      end
    end
  end
  logic_new_player_spin.UpdateRedTip()
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_TASK_CHANGE)
end
function logic_new_player_spin.UpdateTaskRedTip()
  local TaskRedTip = false
  for _, tasklist in pairs(logic_new_player_spin.TaskList) do
    for _, taskData in pairs(tasklist) do
      if taskData.status.finish_status == logic_new_player_spin.EnumStatus.GetReward then
        TaskRedTip = true
        break
      end
    end
    if TaskRedTip then
      break
    end
  end
  return TaskRedTip
end
function logic_new_player_spin.UpdateAllScoreReawrdStatus(statusinfo)
  for index, status in pairs(statusinfo) do
    if logic_new_player_spin.ScoreReward[index] then
      logic_new_player_spin.ScoreReward[index].    end
  end
  logic_new_player_spin.UpdateRedTip()
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_POINT_CHANGE)
end
function logic_new_player_spin.UpdateSingleScoreRewardStatus(points_id)
  for i, info in pairs(logic_new_player_spin.ScoreReward) do
    if points_id == info.points_id then
      info.status = logic_new_player_spin.EnumStatus.FinishGet
      break
    end
  end
  logic_new_player_spin.UpdateRedTip()
  logic_new_player_spin.ReleaseNewBieGetScoreItem(points_id)
  log_tree("[qintong] logic_new_player_spin.UpdateScoreRewardStatus " .. points_id, logic_new_player_spin.ScoreReward)
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_POINT_CHANGE)
end
function logic_new_player_spin.ReleaseNewBieGetScoreItem(points_id)
  if logic_new_player_spin.NewBieItem and points_id == logic_new_player_spin.NewBieItem.points_id then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle({
      logic_new_player_spin.NewBieItem
    })
    logic_new_player_spin.NewBieItem = nil
  end
end
function logic_new_player_spin.SaveNewBieGetScoreItem(item)
  logic_new_player_spin.NewBieItem = item
end
function logic_new_player_spin.UpdateScoreRedTip()
  local has = false
  for i, info in pairs(logic_new_player_spin.ScoreReward) do
    if info.status == logic_new_player_spin.EnumStatus.GetReward then
      has = true
      break
    end
  end
  return has
end
function logic_new_player_spin.UpdateRedTip()
  local bOpen = logic_new_player_spin.IsOpen()
  if not bOpen then
    LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_OPEN_GROWPROGET_SIPN_UI, false)
    return
  end
  local hasTaskRed = false
  local hasScoreRed = logic_new_player_spin.UpdateScoreRedTip()
  local cnt = logic_new_player_spin.GetTicketCount()
  local bLottey = 0 < cnt
  log(bWriteLog and "[qintong] logic_new_player_spin.UpdateRedTip" .. tostring(hasTaskRed) .. tostring(hasScoreRed) .. tostring(bLottey))
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_OPEN_GROWPROGET_SIPN_UI, hasTaskRed or hasScoreRed or bLottey)
  return hasTaskRed or hasScoreRed or bLottey
end
function logic_new_player_spin.UpdateRedDotCount(superData)
  local count = 0
  local bOpen = logic_new_player_spin.IsOpen()
  if not bOpen then
    LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_OPEN_GROWPROGET_SIPN_UI, false)
    return count
  end
  for i, info in pairs(logic_new_player_spin.ScoreReward) do
    if info.status == logic_new_player_spin.EnumStatus.GetReward then
      count = count + 1
    end
  end
  local cnt = logic_new_player_spin.GetTicketCount()
  if 0 < cnt then
    count = count + 1
  end
  superData.newCount = count
end
return logic_new_player_spin