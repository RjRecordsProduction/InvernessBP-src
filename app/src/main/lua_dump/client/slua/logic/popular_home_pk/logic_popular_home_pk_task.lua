local logic_popular_home_pk_task = {}
function logic_popular_home_pk_task:DefineAndResetData()
  self.taskList = nil
  self.award_flag = nil
end
function logic_popular_home_pk_task:OnLogOut()
  self:DefineAndResetData()
end
function logic_popular_home_pk_task:GetTaskList()
  return self.taskList or {}
end
function logic_popular_home_pk_task:GetTaskEndTime()
  if not self.taskList then
    return nil
  end
  local maxEndTime = 0
  for _, task in ipairs(self.taskList) do
    if maxEndTime < task.end_time then
      maxEndTime = task.end_time
    end
  end
  return maxEndTime
end
function logic_popular_home_pk_task:GetTask(taskID)
  if not self.taskList then
    log(bWriteLog and "logic_popular_home_pk_task:GetTask not self.taskList")
    return nil
  end
  for _, task in ipairs(self.taskList) do
    if task.task_id == taskID then
      return task
    end
  end
  log(bWriteLog and "logic_popular_home_pk_task:GetTask no task, taskID = " .. tostring(taskID))
  return nil
end
function logic_popular_home_pk_task:GetAwardFlag()
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  if not logic_popular_home_pk:IsInVoteTaskTime() then
    log(bWriteLog and "logic_popular_home_pk_task:GetAwardFlag not in vote task time")
    return false
  end
  return self.award_flag == 1
end
function logic_popular_home_pk_task:SetAwardFlag(award_flag)
  log(bWriteLog and "logic_popular_home_pk_task:SetAwardFlag award_flag:" .. tostring(award_flag))
  self.  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_TASK_UPDATE_AWARD_FLAG)
end
function logic_popular_home_pk_task:ProcTaskListRsp(task_map, award_flag)
  if not task_map or not next(task_map) then
    log(bWriteLog and "logic_popular_home_pk_task:ProcTaskListRsp invalid task_map")
    return
  end
  local logic_home_collection_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_collection_task)
  self.taskList = {}
  for taskId, task in pairs(task_map) do
    local taskCfg = logic_home_collection_task:GetManorTaskCfg(taskId)
    if taskCfg then
      task.Priority = taskCfg.order_prior
      task.JumpUrl = taskCfg.task_jump
      task.TaskDesc = taskCfg.task_desc
      task.task_id = taskId
      table.insert(self.taskList, task)
    else
      log(bWriteLog and "logic_popular_home_pk_task:ProcTaskListRsp no taskCfg:" .. tostring(taskId))
    end
  end
  table.sort(self.taskList, function(a, b)
    if a.status ~= b.status then
      return a.status < b.status
    end
    return a.Priority > b.Priority
  end)
  log_tree("logic_popular_home_pk_task:on_get_manor_task_list_rsp taskList:", self.taskList)
  self:SetAwardFlag(award_flag)
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_GET_TASK_LIST)
end
function logic_popular_home_pk_task:ProcGetTaskAwardRsp(task_id, award_flag)
  local task = self:GetTask(task_id)
  if task then
    if task.award_item_list and next(task.award_item_list) then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(task.award_item_list)
    end
    local PopularHomePKMacros = require("client.slua.logic.popular_home_pk.popular_home_pk_macros")
    task.status = PopularHomePKMacros.ENUM_TASK_AWARD_STATUS.Award
    if self.taskList then
      table.sort(self.taskList, function(a, b)
        if a.status ~= b.status then
          return a.status < b.status
        end
        return a.Priority > b.Priority
      end)
    end
  end
  self:SetAwardFlag(award_flag)
  EventSystem:postEvent(EVENTTYPE_POPULAR_HOMEPK, EVENTID_POPULAR_HOME_PK_TAKE_TASK_AWARD, task_id)
end
function logic_popular_home_pk_task:ProcTaskUpdateNotify(update_task_info, award_flag)
  if not update_task_info or not next(update_task_info) then
    log(bWriteLog and "logic_popular_home_pk_task:on_manor_task_update_notify invalid update_task_info")
    return
  end
  for taskId, taskInfo in pairs(update_task_info) do
    local task = self:GetTask(taskId)
    if task then
      task.status = taskInfo.status
      task.cur_value = taskInfo.cur_value
    end
  end
  if self.taskList then
    table.sort(self.taskList, function(a, b)
      if a.status ~= b.status then
        return a.status < b.status
      end
      return a.Priority > b.Priority
    end)
  end
  self:SetAwardFlag(award_flag)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_popular_home_pk_task = class(CModuleBase, nil, logic_popular_home_pk_task)
return Clogic_popular_home_pk_task