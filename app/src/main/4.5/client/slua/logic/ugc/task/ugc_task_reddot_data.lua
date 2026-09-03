local reddot_id = {common_task = 1, week_active = 2}
local UGCTaskRedPointData = {reddot_id = reddot_id}
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
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    desc = reddot_macro.SystemName.UGCTask,
    SubDatas = {newCount = 0}
  }
  return data
end
local ClearListeners = function()
  if delegateContainer then
    delegateContainer:Dispose()
    delegateContainer = nil
  end
end
function UGCTaskRedPointData.InitData()
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
  for _, reddotid in pairs(reddot_id) do
    local reddotData = GenDefaultSubData(reddotid, reddot_macro.Category.Receive)
    data.SubDatas[reddotid] = reddotData
  end
  if superRedPoint == nil then
    superRedPoint = super_data.CreateSuperData(data)
  else
    for k, v in pairs(data) do
      superRedPoint[k] = v
    end
  end
  reddot_manager:Regist(superRedPoint)
end
function UGCTaskRedPointData.OnLogin()
  log(bWriteLog and "UGCTaskRedPointData.OnLogin")
  UGCTaskRedPointData.InitData()
end
function UGCTaskRedPointData.OnLogout()
  UGCTaskRedPointData.DestroyData()
end
function UGCTaskRedPointData.GetData()
  return superRedPoint
end
function UGCTaskRedPointData.HasRedDot()
  if not superRedPoint then
    return false
  end
  for _, reddotid in pairs(reddot_id) do
    local reddotData = superRedPoint.SubDatas[reddotid]
    if reddotData and reddotData.newCount and reddotData.newCount > 0 then
      return true
    end
  end
  return false
end
function UGCTaskRedPointData.SetNewCount(_reddot_id, newCount)
  if superRedPoint then
    superRedPoint.groupShow = true
    local data = superRedPoint.SubDatas[_reddot_id]
    if data then
      data.    end
  end
end
function UGCTaskRedPointData.UpdateRedDot()
  local LogicUGCTask = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_task)
  local hasCommonReward = false
  for _, task in ipairs(LogicUGCTask.DailyTasks) do
    if task.status == 1 then
      hasCommonReward = true
    end
  end
  UGCTaskRedPointData.SetNewCount(reddot_id.common_task, hasCommonReward and 1 or 0)
  local hasActiveAward = false
  for _, receive in ipairs(LogicUGCTask.WeeklyActive.received) do
    if receive.status == 1 then
      hasActiveAward = true
    end
  end
  UGCTaskRedPointData.SetNewCount(reddot_id.week_active, hasActiveAward and 1 or 0)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_TASK_REDDOT_UPDATE)
end
function UGCTaskRedPointData.DestroyData()
  superRedPoint = nil
  isInited = false
end
return UGCTaskRedPointData