local LevelTaskRedPointData = {
  countFieldName = "newCount",
  desc = "leveltask",
  reddot_id = 1
}
local superRedPoint
local isInited = false
local delegateContainer
local GenDefaultSubData = function(subID, category)
  local data = {
    newCount = 0,
    category = category,
      }
  return data
end
local GenerateData = function()
  local data = {
    newCount = 0,
    SubDatas = {newCount = 0}
  }
  data.desc = LevelTaskRedPointData.desc
  return data
end
local ClearListeners = function()
  if delegateContainer then
    delegateContainer:Dispose()
    delegateContainer = nil
  end
end
function LevelTaskRedPointData.InitData()
  if isInited then
    return
  end
  isInited = true
  ClearListeners()
  local delegate_container = require("common.delegate_container")
  delegateContainer = delegate_container()
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  local super_data = require("common.super_data")
  local data = GenerateData()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local reddotData = GenDefaultSubData(LevelTaskRedPointData.reddot_id, reddot_macro.Category.Receive)
  data.SubDatas[LevelTaskRedPointData.reddot_id] = reddotData
  if superRedPoint == nil then
    superRedPoint = super_data.CreateSuperData(data)
  else
    for k, v in pairs(data) do
      superRedPoint[k] = v
    end
  end
  reddot_manager:Regist(superRedPoint)
end
function LevelTaskRedPointData.OnLogin()
  LevelTaskRedPointData.InitData()
end
function LevelTaskRedPointData.OnLogout()
  LevelTaskRedPointData.DestroyData()
end
function LevelTaskRedPointData.GetData()
  return superRedPoint
end
function LevelTaskRedPointData.SetNewCount(newCount)
  if superRedPoint then
    local data = superRedPoint.SubDatas[LevelTaskRedPointData.reddot_id]
    if data then
      data.    end
  end
end
function LevelTaskRedPointData.UpdateRedDot()
  LevelTaskRedPointData.InitData()
  local LevelTaskSystem = require("client.slua.logic.task.logic_level_task")
  local done = LevelTaskSystem.TaskState.DONE
  if DataMgr.levelTask then
    local levelDoneCount = 0
    local drop_id_list = {}
    for level, info in pairs(DataMgr.levelTask.list) do
      local isHave = false
      if info.level_status == done then
        levelDoneCount = levelDoneCount + 1
        isHave = true
      end
      if info.task1_status == done then
        levelDoneCount = levelDoneCount + 1
        isHave = true
      end
      if info.task2_status == done then
        levelDoneCount = levelDoneCount + 1
        isHave = true
      end
      if isHave then
        local levelTaskInfo = LevelTaskSystem.GetLevelTaskData(level)
        if levelTaskInfo and levelTaskInfo.Award and 0 < levelTaskInfo.Award then
          table.insert(drop_id_list, levelTaskInfo.Award)
        end
        if levelTaskInfo and levelTaskInfo.Task1Award and 0 < levelTaskInfo.Task1Award then
          table.insert(drop_id_list, levelTaskInfo.Task1Award)
        end
        if levelTaskInfo and levelTaskInfo.Task2Award and 0 < levelTaskInfo.Task2Award then
          table.insert(drop_id_list, levelTaskInfo.Task2Award)
        end
      end
    end
    local BasicDataDropTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataDropTable)
    BasicDataDropTable:BatchGetOrReqData(drop_id_list)
    log(bWriteLog and "LevelTaskRedPointData.HasRedDot:" .. tostring(levelDoneCount))
    LevelTaskRedPointData.SetNewCount(1 <= levelDoneCount and 1 or 0)
  end
end
function LevelTaskRedPointData.DestroyData()
  superRedPoint = nil
  isInited = false
end
return LevelTaskRedPointData