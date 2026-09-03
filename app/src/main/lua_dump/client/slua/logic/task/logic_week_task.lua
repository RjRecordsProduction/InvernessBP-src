local WeekTaskSystem = {
  WeekTaskInfos = {},
  week_list = {}
}
local StringUtil = require("common.string_util")
function WeekTaskSystem.RefreshWeekTaskInfo()
  WeekTaskSystem.WeekTaskInfos = {}
  local tbTask = CDataTable.GetTable("WeekTask")
  local week_list = {}
  for _, info in pairs(tbTask) do
    local data = WeekTaskSystem.week_list[info.ID]
    week_list[info.ID] = {
      progress = data and data.progress or 0,
      totalStage = info.TotalStage,
      detail = {}
    }
    local cnds = StringUtil.Split(info.Cond, ";")
    local drops = StringUtil.Split(info.DropIDs, ";")
    for i = 1, #cnds do
      if cnds[i] and cnds[i] ~= "" and drops[i] and drops[i] ~= "" then
        local cnd = tonumber(cnds[i])
        week_list[info.ID].detail[i] = {
          status = data and data.status[i] or 0,
          dropId = tonumber(drops[i]),
          cndId = cnd
        }
      end
    end
  end
  for id, v in pairs(week_list) do
    local tb = {
      progress = v.progress,
      totalStage = v.totalStage,
      weekTaskId = id
    }
    tb.WeekTaskStatus = {}
    for index, detail in pairs(v.detail) do
      table.insert(tb.WeekTaskStatus, {
        cnd = detail.cndId,
        status = detail.status,
        dropId = detail.dropId,
              })
    end
    table.sort(tb.WeekTaskStatus, function(a, b)
      return a.cnd < b.cnd
    end)
    table.insert(WeekTaskSystem.WeekTaskInfos, tb)
  end
  local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
  TaskMgrSystem.RefreshLobbyTaskRedDot()
end
function WeekTaskSystem.UpdateWeekTaskData(week_list, isAll)
  log_tree("WeekTaskSystem.UpdateWeekTaskData", week_list)
  if isAll then
    WeekTaskSystem.week_list = {}
  end
  for i, v in pairs(week_list) do
    WeekTaskSystem.week_list[i] = v
  end
  local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
  TaskMgrSystem.RefreshLobbyTaskRedDot()
  local assembly_reddot_data = require("client.slua.logic.task.assembly_reddot_data")
  assembly_reddot_data.UpdateJKWeekTaskRedDot()
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_WEEK_TASK_CHANGE)
end
function WeekTaskSystem.GetWeekTaskRedDot()
  for _, v in pairs(WeekTaskSystem.week_list) do
    for _, status in pairs(v.status) do
      if status == 1 then
        return true
      end
    end
  end
  return false
end
function WeekTaskSystem.Req_WeekTaskGetAward(taskid, recvIndex)
  log(bWriteLog and "[yyc] Req_WeekTaskGetAward taskid " .. taskid .. " index" .. tostring(recvIndex))
  local TaskHandler = require("client.network.Protocol.TaskHandler")
  TaskHandler.send_task_get_weekly_award_req(taskid, recvIndex)
end
function WeekTaskSystem.Res_WeekTaskGetAward(res, taskid, stage_index, itemlist)
  log(bWriteLog and "[yyc] Res_WeekTaskGetAward taskid " .. tostring(taskid) .. " res " .. res)
  log_tree("[yyc] Res_WeekTaskGetAward itemlist", itemlist)
  log_tree("[yyc] Res_WeekTaskGetAward stage_index", tostring(stage_index))
  if res == 0 then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(itemlist)
    local taskData = WeekTaskSystem.week_list[taskid]
    if taskData then
      for stageIndex, _ in pairs(stage_index) do
        if not taskData.status then
          taskData.status = {}
        else
          log(bWriteLog and "[yyc] stage index is not valid " .. stageIndex)
        end
        taskData.status[stageIndex] = 2
      end
    else
      log(bWriteLog and "[yyc] taskid is not valid " .. tostring(taskid))
    end
    WeekTaskSystem.RefreshWeekTaskInfo()
    local assembly_reddot_data = require("client.slua.logic.task.assembly_reddot_data")
    assembly_reddot_data.UpdateJKWeekTaskRedDot()
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_WEEK_TASK_CHANGE)
  else
    log(bWriteLog and "[yyc] Res_WeekTaskGetAward failed res = " .. res)
  end
end
return WeekTaskSystem