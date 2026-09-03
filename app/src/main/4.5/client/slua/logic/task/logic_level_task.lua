local LevelTaskSystem = {
  isIOSCheck = false,
  isTourist = false,
  currentLevel = 0,
  reddot = false,
  LevelTasks = {},
  SpecialDropList = {},
  LevelDrop = {},
  TaskState = {
    PROGRESS = 0,
    DONE = 1,
    AWARDED = 2
  },
  TaskLevelDoneCount = 0,
  CurrentOperateLevelTask = {level = 0, id = 0},
  LevelTaskId = {
    [0] = "level_status",
    [1] = "task1_status",
    [2] = "task2_status"
  }
}
function LevelTaskSystem.GetLevelTaskRedDot()
  local done = LevelTaskSystem.TaskState.DONE
  for Level, levelTaskInfo in pairs(DataMgr.levelTask.list) do
    if levelTaskInfo.level_status == done or levelTaskInfo.task1_status == done or levelTaskInfo.task2_status == done then
      return true, Level
    end
  end
  return false
end
function LevelTaskSystem.GetLevelTaskStatus(level)
  local status = LevelTaskSystem.LevelTasks[level]
  if status then
    return status
  end
  return {
    level = 0,
    level_status = 0,
    progress1 = 1,
    task1_status = 0,
    progress2 = 1,
    task2_status = 0
  }
end
function LevelTaskSystem.RefreshLevelTaskInfo()
  LevelTaskSystem.currentLevel = DataMgr.roleData.level
  LevelTaskSystem.LevelTasks = {}
  LevelTaskSystem.isIOSCheck = GlobalData.IsIOSCheck()
  LevelTaskSystem.isTourist = Client.GetLoginChannel(NetInterface) == BP_ENUM_PLAYFORM_TOURIST
  if DataMgr.levelTask then
    for level, info in pairs(DataMgr.levelTask.list) do
      LevelTaskSystem.LevelTasks[level] = info
      info.    end
  end
  if LevelTaskSystem.isTourist == true or LevelTaskSystem.isIOSCheck == true then
    for j, tmpinfo in pairs(LevelTaskSystem.LevelTasks) do
      local tableInfo = LevelTaskSystem.GetLevelTaskData(j)
      if tableInfo ~= nil then
        if (tableInfo.IOSSwitch1 == 0 or tableInfo.TouristSwitch1 == 0) and tableInfo.Task1Cond ~= 0 and (tableInfo.TouristSwitch1 == 0 and LevelTaskSystem.LevelTaskInfos.isTourist == true or tableInfo.IOSSwitch1 == 0 and LevelTaskSystem.LevelTaskInfos.isIOSCheck == true) then
          tmpinfo.task1_status = 2
        end
        if (tableInfo.IOSSwitch2 == 0 or tableInfo.TouristSwitch2 == 0) and tableInfo.Task2Cond ~= 0 and (tableInfo.TouristSwitch2 == 0 and LevelTaskSystem.LevelTaskInfos.isTourist == true or tableInfo.IOSSwitch2 == 0 and LevelTaskSystem.LevelTaskInfos.isIOSCheck == true) then
          tmpinfo.task2_status = 2
        end
      end
    end
  end
  local drop_id_list = {}
  for i = 1, 10 do
    local levelTaskInfo = LevelTaskSystem.GetLevelTaskData(i * 10)
    if levelTaskInfo and levelTaskInfo.Task1Award and 0 < levelTaskInfo.Task1Award then
      table.insert(drop_id_list, levelTaskInfo.Task1Award)
    end
  end
  LevelTaskSystem.reddot = LevelTaskSystem.GetLevelTaskRedDot()
  LevelTaskSystem.UpdateLevelDoneCount()
  local onGetDropListRsp = function(drop_list)
    LevelTaskSystem.UpdateSpecialDropListInfo()
  end
  local BasicDataDropTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataDropTable)
  BasicDataDropTable:BatchGetOrReqData(drop_id_list, onGetDropListRsp)
  local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
  TaskMgrSystem.RefreshLobbyTaskRedDot()
end
function LevelTaskSystem.UpdateLevelDoneCount()
  local levelDoneCount = 0
  local done = LevelTaskSystem.TaskState.DONE
  for j, tmpinfo in pairs(LevelTaskSystem.LevelTasks) do
    if tmpinfo.level_status == done then
      levelDoneCount = levelDoneCount + 1
    end
    if tmpinfo.task1_status == done then
      levelDoneCount = levelDoneCount + 1
    end
    if tmpinfo.task2_status == done then
      levelDoneCount = levelDoneCount + 1
    end
  end
  LevelTaskSystem.TaskLevelDoneCount = levelDoneCount
end
function LevelTaskSystem.GetLevelTaskData(level)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local levelTaskInfo = CDataTable.GetTableData("NewLevelTask", level)
  if not levelTaskInfo then
    return
  end
  local LevelInfo = {}
  LevelInfo.Award = levelTaskInfo.Award
  LevelInfo.TouristSwitch2 = levelTaskInfo.TouristSwitch2
  LevelInfo.Level = levelTaskInfo.Level
  LevelInfo.Task2Detail = levelTaskInfo.Task2Detail
  LevelInfo.Unlock = levelTaskInfo.Unlock
  LevelInfo.Task2Award = levelTaskInfo.Task2Award
  LevelInfo.Task2Cond = levelTaskInfo.Task2Cond
  LevelInfo.JumpTo2 = levelTaskInfo.JumpTo2
  LevelInfo.IOSSwitch2 = levelTaskInfo.IOSSwitch2
  LevelInfo.TouristSwitch1 = levelTaskInfo.TouristSwitch1
  LevelInfo.IOSSwitch1 = levelTaskInfo.IOSSwitch1
  LevelInfo.JumpTo1 = levelTaskInfo.JumpTo1
  LevelInfo.Task1Detail = levelTaskInfo.Task1Detail
  LevelInfo.Task1Cond = levelTaskInfo.Task1Cond
  LevelInfo.Task1Award = levelTaskInfo.Task1Award
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local new_level_task_cover_table = BasicDataServerTable:GetCacheData(data_config_marco.new_level_task_cover_table)
  if new_level_task_cover_table and new_level_task_cover_table[tonumber(level)] then
    local cover_info = new_level_task_cover_table[tonumber(level)]
    LevelInfo.Award = cover_info.level_award
    LevelInfo.Task1Cond = cover_info.task1_progress
    LevelInfo.Task1Award = cover_info.task1_drop
    LevelInfo.Task2Cond = cover_info.task2_progress
    LevelInfo.Task2Award = cover_info.task2_drop
  end
  return LevelInfo
end
function LevelTaskSystem.UpdateSpecialDropListInfo()
  LevelTaskSystem.SpecialDropList = {}
  local BasicDataDropTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataDropTable)
  for i = 1, 10 do
    local level = i * 10
    local levelTaskInfo = LevelTaskSystem.GetLevelTaskData(level)
    if levelTaskInfo ~= nil then
      if LevelTaskSystem.LevelDrop[i] == nil then
        LevelTaskSystem.LevelDrop[i] = BasicDataDropTable:GetOrReqData(levelTaskInfo.Task1Award, nil, nil, true)
      end
      if LevelTaskSystem.LevelDrop[i] and #LevelTaskSystem.LevelDrop[i] > 0 then
        table.insert(LevelTaskSystem.SpecialDropList, LevelTaskSystem.LevelDrop[i][1])
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_LEVLE_TASK_SPECIAL_DROP)
end
function LevelTaskSystem.LevelTaskGoto()
  local levelTaskInfo = LevelTaskSystem.GetLevelTaskData(LevelTaskSystem.CurrentOperateLevelTask.level)
  if not levelTaskInfo then
    return
  end
  if LevelTaskSystem.CurrentOperateLevelTask.id == 0 then
    GlobalData.JumpUrl("game://?module=" .. BP_ENUM_MODULE_LOBBY)
  elseif LevelTaskSystem.CurrentOperateLevelTask.id == 1 then
    local UIUtil = require("client.common.ui_util")
    UIUtil.JumpToByPattern(levelTaskInfo.JumpTo1)
  elseif LevelTaskSystem.CurrentOperateLevelTask.id == 2 then
    local UIUtil = require("client.common.ui_util")
    UIUtil.JumpToByPattern(levelTaskInfo.JumpTo2)
  end
end
function LevelTaskSystem.LevelTaskGetAward()
  log(bWriteLog and "====================EventLevelTaskGetAward_Push " .. LevelTaskSystem.CurrentOperateLevelTask.level .. " " .. LevelTaskSystem.CurrentOperateLevelTask.id)
  local TaskHandler = require("client.network.Protocol.TaskHandler")
  TaskHandler.send_level_task_get_award_req(LevelTaskSystem.CurrentOperateLevelTask.level, LevelTaskSystem.CurrentOperateLevelTask.id)
end
function LevelTaskSystem.Res_LevelTaskGetAward(ret, level, id, itemList, isRewardClick)
  if ret == NetErrorCode_NONE then
    local taskInfo = DataMgr.levelTask.list[level]
    if taskInfo == nil then
      log_error("level task can not found on level : " .. (level or -1))
      return
    end
    local logic_user_ctrl = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_user_ctrl)
    if logic_user_ctrl:IsNewUser() and level == 1 then
      local StatManager = import("StatManager")
      local BusinessHelper = import("BusinessHelper")
      StatManager.GetInstance():ReportEventWithParam(76, {
        openId = BusinessHelper.GetOpenId(),
        nation = DataMgr.roleData.nation
      }, true)
    end
    taskInfo[LevelTaskSystem.LevelTaskId[id]] = 2
    LevelTaskSystem.LevelTaskGetAwardRsp(level, id, itemList, isRewardClick)
    if isRewardClick ~= 1 then
      local LevelTaskRedPointData = require("client.slua.logic.task.level_task_reddot_data")
      LevelTaskRedPointData.UpdateRedDot()
    end
  else
    ShowNotice(ret)
  end
end
function LevelTaskSystem.LevelTaskGetAwardRsp(level, id, itemList, isRewardClick)
  if isRewardClick ~= 1 then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(itemList)
  end
  LevelTaskSystem.RefreshLevelTaskInfo()
  LevelTaskSystem.CurrentOperateLevelTask = {level = level, id = id}
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_LEVLE_TASK_CHANGE)
end
function LevelTaskSystem.GetNewLevelTaskData(level)
  log(bWriteLog and "LuaGlobalWidget:GetNewLevelTaskData:" .. tostring(level))
  local info = LevelTaskSystem.GetLevelTaskData(level)
  local cls_NewLevelTask = import("/Game/StructFromLua/BP_STRUCT_NewLevelTask_type.BP_STRUCT_NewLevelTask_type")
  local obj_NewLevelTask = cls_NewLevelTask()
  if not info then
    return false, obj_NewLevelTask
  end
  local util = require("client.slua_ui_framework.util")
  util.TableToBPObject(info, obj_NewLevelTask)
  log_tree("info", info)
  return true, obj_NewLevelTask
end
function LevelTaskSystem.GenerateLevelTaskInfos()
  local cls_BP_STRUCT_LevelTaskInfo = import("/Game/StructFromLua/BP_STRUCT_LevelTaskInfo.BP_STRUCT_LevelTaskInfo")
  local LevelTaskInfos = slua.Array(UEnums.EPropertyClass.Struct, cls_BP_STRUCT_LevelTaskInfo)
  local util = require("client.slua_ui_framework.util")
  for i, v in ipairs(LevelTaskSystem.LevelTasks) do
    local obj_LevelTaskInfo = cls_BP_STRUCT_LevelTaskInfo()
    util.TableToBPObject(v, obj_LevelTaskInfo)
    LevelTaskInfos:Add(obj_LevelTaskInfo)
  end
  for i = LevelTaskInfos:Num() + 1, 100 do
    local obj_LevelTaskInfo = cls_BP_STRUCT_LevelTaskInfo()
    obj_LevelTaskInfo.level = i
    LevelTaskInfos:Add(obj_LevelTaskInfo)
  end
  return LevelTaskInfos
end
function LevelTaskSystem.GenerateLevelTaskInfo(Level)
  local cls_BP_STRUCT_LevelTaskInfo = import("/Game/StructFromLua/BP_STRUCT_LevelTaskInfo.BP_STRUCT_LevelTaskInfo")
  local obj_LevelTaskInfo = cls_BP_STRUCT_LevelTaskInfo()
  obj_LevelTaskInfo.level = Level
  local util = require("client.slua_ui_framework.util")
  if LevelTaskSystem.LevelTasks[Level] then
    util.TableToBPObject(LevelTaskSystem.LevelTasks[Level], obj_LevelTaskInfo)
  end
  return obj_LevelTaskInfo
end
function LevelTaskSystem.GenerateDropItems()
  local cls_BP_STRUCT_TaskDropItem = import("/Game/StructFromLua/BP_STRUCT_TaskDropItem.BP_STRUCT_TaskDropItem")
  local TaskDropItems = slua.Array(UEnums.EPropertyClass.Struct, cls_BP_STRUCT_TaskDropItem)
  local util = require("client.slua_ui_framework.util")
  for i, v in ipairs(LevelTaskSystem.SpecialDropList) do
    local obj_TaskDropItem = cls_BP_STRUCT_TaskDropItem()
    util.TableToBPObject(v, obj_TaskDropItem)
    TaskDropItems:Add(obj_TaskDropItem)
  end
  return TaskDropItems
end
return LevelTaskSystem