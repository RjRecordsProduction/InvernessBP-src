local skill_task_system = {}
function skill_task_system:OnInitialize()
  skill_task_system.__super.OnInitialize(self)
  self.ActivityID = nil
  self.ActivityData = nil
  self.HasActivityData = false
  self.TaskData = nil
  self.DisplayActivityTaskData = nil
  self.ServerTaskConfig = nil
end
function skill_task_system:RegistEvents()
  self:AddCommonEvent(EVENTID_UI, BP_ENUM_UI_SHOW, self.CheckActivityUIShow, self)
end
function skill_task_system:OnLogin(bReLogin)
end
function skill_task_system:OnLogOut()
end
function skill_task_system:OnPreSwitchGameStatus(preState, nextState)
end
function skill_task_system:OnPostSwitchGameStatus(preState, nextState)
end
function skill_task_system:CheckActivityUIShow(_, __, config)
  if config and config.keyName and config.keyName == "ActivityCenter_Main_UIBP" then
    self:SendGetTaskDataReq()
  end
end
function skill_task_system:GetActivityData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityList = ActivityNewSystem.GetActivityByType(ActivityType.ACTIVITY_SKILL_TASK)
  if ActivityList then
    log_tree("skill_task_system:GetActivityData", ActivityList)
    self.ActivityID = ActivityList.ID
    self.ActivityData = ActivityList
    self.HasActivityData = true
  end
  return self.ActivityData
end
function skill_task_system:GetTaskData()
  return self.TaskData
end
function skill_task_system:GetRelatedTaskData(SkillID)
  if not SkillID then
    return nil
  end
  if not self.TaskData then
    return nil
  end
  local RelatedTaskData
  for TaskID, TaskData in pairs(self.TaskData) do
    if TaskData.LocalConfig.skill_id == SkillID and TaskData.ServerStatus.status ~= ActivityProgressStatus.Get then
      Related    end
  end
  if not RelatedTaskData then
    return nil
  end
  return RelatedTaskData
end
function skill_task_system:_OnGetTaskConfigTable()
end
function skill_task_system:_SetTaskData(SkillTasks)
  if not SkillTasks or not next(SkillTasks) then
    return
  end
  self.TaskData = {}
  for TaskID, TaskServerStatus in pairs(SkillTasks) do
    local TaskConfig = CDataTable.GetTableData("SkillDailyTaskTable", TaskID)
    if TaskConfig then
      local TempTaskData = {
        ID = TaskID,
        ServerStatus = TaskServerStatus,
        LocalConfig = TaskConfig
      }
      self.TaskData[TaskID] = TempTaskData
    end
  end
end
function skill_task_system:SendGetTaskRewardReq(TaskID)
  local SkillSystemHandler = require("client.network.Protocol.SkillSystemHandler")
  SkillSystemHandler.send_receive_skill_trial_task_reward_req(self.ActivityID, TaskID)
end
function skill_task_system:OnGetTaskRewardRsp(RetCode, ActivityID, TaskID, RewardTable)
  if tonumber(RetCode) == 0 then
    self:SendGetTaskDataReq()
    local itemsGet = {}
    local TaskData = self.TaskData[TaskID]
    TaskData.ServerStatus.status = ActivityProgressStatus.Get
    local itemGetData = {
      res_id = TaskData.ServerStatus.award_id,
      count = TaskData.LocalConfig.count,
      valid_hours = 0,
      expire_time = 0
    }
    table.insert(itemsGet, itemGetData)
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(itemsGet)
  else
    ShowNotice(RetCode)
  end
end
function skill_task_system:SendGetTaskDataReq()
  self:GetActivityData()
  local SkillSystemHandler = require("client.network.Protocol.SkillSystemHandler")
  if self.ActivityID then
    SkillSystemHandler.send_get_skill_trial_task_req(self.ActivityID)
  else
    log(bWriteLog and "skill_task_system:SendGetTaskDataReq No ActivityID")
  end
end
function skill_task_system:PostTaskDataUpdated()
  EventSystem:postEvent(EVENTTYPE_SKILL_TASK, EVENTID_SKILL_SELECTION_TASK_DATA)
  local LogicSkillTaskActivity = require("client.slua.logic.activity.logic_skill_task")
  local Data = LogicSkillTaskActivity.GetActivitySubData()
  if Data then
    local changeList = {
      idList = {},
      typeList = {}
    }
    changeList.idList[self.ActivityID] = true
    changeList.typeList[ActivityType.ACTIVITY_SKILL_TASK] = true
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changeList)
  end
end
function skill_task_system:OnGetTaskDataRsp(ErrCode, SkillTasks)
  if tonumber(ErrCode) == 0 then
    log_tree("skill_task_system:OnGetTaskDataRsp", SkillTasks)
    self:_SetTaskData(SkillTasks)
    self:PostTaskDataUpdated()
  end
end
function skill_task_system:OnSyncTaskList(SyncTaskList)
  if not self.TaskData then
    self:_SetTaskData(SyncTaskList)
  end
  for TaskID, SyncTaskData in pairs(SyncTaskList) do
    if self.TaskData[TaskID] then
      self.TaskData[TaskID].ServerStatus.status = SyncTaskData.status
      self.TaskData[TaskID].ServerStatus.progress = SyncTaskData.progress
    end
  end
  self:PostTaskDataUpdated()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CSkillTaskSystem = class(CModuleBase, nil, skill_task_system)
return CSkillTaskSystem