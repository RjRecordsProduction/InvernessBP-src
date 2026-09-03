local LogicNewbieAchievement = {}
local StatusDef = {
  NoFinish = 0,
  GetReward = 1,
  FinishGet = 2
}
local SortRewardItem = function(a, b)
  if a.finishStatus == b.finishStatus then
    return a.task.sort < b.task.sort
  elseif a.finishStatus == StatusDef.GetReward then
    return true
  elseif b.finishStatus == StatusDef.GetReward then
    return false
  else
    return a.finishStatus < b.finishStatus
  end
end
function LogicNewbieAchievement.OnRecvData(info)
  if info then
    local drop_mission = info.newbie_drop_mission
    if drop_mission then
      LogicNewbieAchievement.status = drop_mission.status
      LogicNewbieAchievement.taskConfig = drop_mission.cfg
      local taskList = {}
      local allTaskData = {}
      for k, v in pairs(LogicNewbieAchievement.taskConfig) do
        taskList[#taskList + 1] = k
        local taskDataList = {}
        for i = 1, #v.task do
          local task = v.task[i]
          local taskData = {
            task = task,
            award = v.award[i],
            finishStatus = drop_mission.status[task.mission_id].finish_status,
            value = drop_mission.status[task.mission_id].value,
            index = i
          }
          taskDataList[#taskDataList + 1] = taskData
        end
        table.sort(taskDataList, SortRewardItem)
        allTaskData[k] = taskDataList
      end
      LogicNewbieAchievement.      LogicNewbieAchievement.      EventSystem:postEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_DATA)
      EventSystem:postEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_CELEBRATION_INIT)
    end
  end
end
function LogicNewbieAchievement.UpdateTaskStatus(missionID, value, finishStatus)
  if not LogicNewbieAchievement.status then
    return
  end
  local missionStatus = LogicNewbieAchievement.status[missionID]
  if missionStatus then
    missionStatus.    missionStatus.finish_status = finishStatus
  end
  if LogicNewbieAchievement.allTaskData then
    for key, taskDataList in pairs(LogicNewbieAchievement.allTaskData) do
      local finded = false
      for i = 1, #taskDataList do
        local taskData = taskDataList[i]
        if taskData.task.mission_id == missionID then
          taskData.          taskData.          finded = true
          break
        end
      end
      if finded then
        break
      end
    end
  end
end
function LogicNewbieAchievement.UpdateTasks(taskDataList, missionIndex)
  local finded = false
  for i = 1, #taskDataList do
    local taskData = taskDataList[i]
    if taskData.index == missionIndex then
      taskData.finishStatus = StatusDef.FinishGet
      finded = true
      break
    end
  end
  if finded then
    table.sort(taskDataList, SortRewardItem)
  end
  return finded
end
function LogicNewbieAchievement.UpdateTaskReward(missionType, missionIndex)
  if LogicNewbieAchievement.allTaskData then
    for key, value in pairs(LogicNewbieAchievement.allTaskData) do
      if key == missionType and LogicNewbieAchievement.UpdateTasks(value, missionIndex) then
        break
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_AHCIEVEMENT_UPDATE)
  EventSystem:postEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_DATA)
end
function LogicNewbieAchievement.OnGetBatchNewbieMissonAward(misson_state)
  log(bWriteLog and "LogicNewbieAchievement.OnGetBatchNewbieMissonAward")
  local logic_new_player_spin = require("client.slua.logic.growth_project.logic_new_player_spin")
  local taskList = logic_new_player_spin.TaskList
  local award_info_map = {}
  for mission_type, finish_task_list in pairs(misson_state) do
    for key, mission_index in pairs(finish_task_list) do
      if taskList then
        for i, taskInfo in pairs(taskList[mission_type] or {}) do
          if mission_type == taskInfo.task.mission_type and mission_index == taskInfo.index then
            taskInfo.status.finish_status = logic_new_player_spin.EnumStatus.FinishGet
            for _, itemCfg in pairs(taskInfo.award) do
              local award_info = award_info_map[itemCfg.itemid]
              local bAdded = false
              if award_info then
                local valid_hours = award_info.valid_hours
                if valid_hours == nil or valid_hours == 0 then
                  bAdded = true
                  award_info.count = award_info.count + 1
                end
              end
              if not bAdded then
                local item = {
                  res_id = itemCfg.itemid,
                  valid_hours = itemCfg.valid_hours,
                  count = itemCfg.cnt
                }
                award_info_map[itemCfg.itemid] = item
              end
            end
            break
          end
        end
      end
      for key, value in pairs(LogicNewbieAchievement.allTaskData or {}) do
        if key == mission_type and LogicNewbieAchievement.UpdateTasks(value, mission_index) then
          break
        end
      end
    end
  end
  local award_list = {}
  for key, award_info in pairs(award_info_map) do
    table.insert(award_list, award_info)
  end
  log_tree(bWriteLog and "LogicNewbieAchievement.OnGetBatchNewbieMissonAward award_list = ", award_list)
  if award_list and next(award_list) then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(award_list)
  end
  logic_new_player_spin.UpdateRedTip()
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_TASK_CHANGE)
  EventSystem:postEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_AHCIEVEMENT_UPDATE)
  EventSystem:postEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_DATA)
end
function LogicNewbieAchievement.GetTaskList()
  return LogicNewbieAchievement.taskList
end
function LogicNewbieAchievement.GetMissionType(taskType)
  local cfg = LogicNewbieAchievement.taskConfig[taskType]
  if cfg and cfg.task and cfg.task[1] then
    return cfg.task[1].mission_type
  end
end
function LogicNewbieAchievement.GetSubTaskList(taskType)
  return LogicNewbieAchievement.allTaskData[taskType]
end
function LogicNewbieAchievement.UpdateRedDotCount(superData)
  if not superData or not superData.pages then
    log_warning(bWriteLog and "LogicNewbieAchievement.UpdateRedDotCount superData or superData.pages is nil")
    return
  end
  local pages = superData.pages
  local status = LogicNewbieAchievement.status
  if status then
    for i = 1, #LogicNewbieAchievement.taskList do
      local taskType = LogicNewbieAchievement.taskList[i]
      local subSuperData = pages[i]
      local tasks = LogicNewbieAchievement.taskConfig[taskType].task
      local count = 0
      for i = 1, #tasks do
        local missionID = tasks[i].mission_id
        if status[missionID].finish_status == StatusDef.GetReward then
          count = count + 1
        end
      end
      subSuperData.newCount = count
    end
  end
  log(bWriteLog and "==============> newbie activity LogicNewbieAchievement UpdateRedDotCount: " .. superData.newCount)
end
function LogicNewbieAchievement.HasRedDot()
  local status = LogicNewbieAchievement.status
  if status then
    for i = 1, #status do
      if status[i].finish_status == StatusDef.GetReward then
        return true
      end
    end
  end
  return false
end
function LogicNewbieAchievement.GetActivitySubData()
  if not LogicNewbieAchievement.taskConfig then
    return
  end
  return {
    nActID = ActivityFixedID.Newbie_Achievement,
    sName = LocUtil.GetLocalizeResStr(29941),
    bRedDot = LogicNewbieAchievement.HasRedDot,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = 0
  }
end
return LogicNewbieAchievement