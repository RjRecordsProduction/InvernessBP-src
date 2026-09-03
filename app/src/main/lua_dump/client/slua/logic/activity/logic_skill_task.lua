local LogicTaskSkill = {}
function LogicTaskSkill.GetRedDotNum()
  local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
  local RedDotType = ActivityMacros.RedDotType.None
  local skill_task_system = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.skill_task_system)
  local ActivityData = skill_task_system:GetActivityData()
  if not ActivityData then
    return 0, RedDotType
  end
  local Num = 0
  local DisplayActivityTaskData = LogicTaskSkill.GetDisplayActivityTaskData()
  if not DisplayActivityTaskData then
    return 0, RedDotType
  end
  for Index, TaskDisplayData in pairs(DisplayActivityTaskData) do
    if TaskDisplayData.Status == 1 then
      Num = Num + 1
      RedDotType = ActivityMacros.RedDotType.Reward
    end
  end
  return Num, RedDotType
end
function LogicTaskSkill.GetDisplayActivityTaskData()
  local skill_task_system = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.skill_task_system)
  local ActivityData = skill_task_system:GetActivityData()
  if not ActivityData then
    return
  end
  local TaskData = skill_task_system:GetTaskData()
  if not TaskData then
    return
  end
  local DisplayActivityTaskData = {}
  for TaskID, OneTaskData in pairs(TaskData) do
    local Temp = {
      ID = ActivityData.ID,
      Type = ActivityData.Type,
      TaskID = TaskID,
      StartTime = ActivityData.StartTime,
      Status = OneTaskData.ServerStatus.status,
      ShowImgLink = "",
      ImgLink = "game://?module=1008403",
      Drop = {
        [1] = {
          count = OneTaskData.LocalConfig.count,
          itemId = OneTaskData.ServerStatus.award_id,
          reviseId = 0,
          expireTime = 0
        }
      },
      Desc = LocUtil.LocalizeResFormat(OneTaskData.LocalConfig.task_text_key, OneTaskData.LocalConfig.total),
      Title = LocUtil.LocalizeResFormat(OneTaskData.LocalConfig.task_text_key, OneTaskData.LocalConfig.total),
      bNeedLight = true,
      Progress = OneTaskData.ServerStatus.progress,
      Total = OneTaskData.LocalConfig.total
    }
    if OneTaskData.LocalConfig.pre_task ~= 0 then
      local PreTask = TaskData[OneTaskData.LocalConfig.pre_task]
      if PreTask and PreTask.ServerStatus.status ~= 0 then
        Temp.Index = #DisplayActivityTaskData + 1
        table.insert(DisplayActivityTaskData, Temp)
      end
    else
      Temp.Index = #DisplayActivityTaskData + 1
      table.insert(DisplayActivityTaskData, Temp)
    end
    table.sort(DisplayActivityTaskData, function(a, b)
      if a.Status == b.Status then
        return a.Index < b.Index
      end
      if a.Status == ActivityProgressStatus.Done then
        return true
      end
      if b.Status == ActivityProgressStatus.Done then
        return false
      end
      if a.Status == ActivityProgressStatus.Get then
        return false
      end
      if b.Status == ActivityProgressStatus.Get then
        return true
      end
      return a.Index < b.Index
    end)
  end
  return DisplayActivityTaskData
end
function LogicTaskSkill.GetActivitySubData()
  local skill_task_system = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.skill_task_system)
  local ActivityData = skill_task_system:GetActivityData()
  if not ActivityData then
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  local CurTime = TimeUtil.GetServerTimeInSec()
  if CurTime > ActivityData.EndTime or CurTime < ActivityData.StartTime then
    return nil
  end
  local tActdata = {
    nActID = ActivityData.ID,
    nRedDotNum = LogicTaskSkill.GetRedDotNum,
    Title = ActivityData.Title or "\230\138\128\232\131\189\228\187\187\229\138\161",
    sName = ActivityData.Title or "\230\138\128\232\131\189\228\187\187\229\138\161",
    Desc = ActivityData.Desc or "\230\138\128\232\131\189\228\187\187\229\138\161",
    ImgUrl = ActivityData.ImgUrl or "",
    ImgLink = ActivityData.ImgLink or "",
    List = LogicTaskSkill.GetDisplayActivityTaskData() or {},
    StartTime = ActivityData.StartTime,
    EndTime = ActivityData.EndTime,
    DisplayScene = ActivityData.DisplayScene
  }
  return tActdata
end
return LogicTaskSkill