local reddot_id = {friend = 1, jkWeekTask = 3}
local AssemblyRedPointData = {
  countFieldName = "newCount",
  desc = "assembly",
  }
AssemblyRedPointData.local superRedPoint
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
  local assembly_macro = require("client.slua.logic.come_back.assembly_macro")
  local data = {
    newCount = 0,
    desc = AssemblyRedPointData.desc,
    pages = {
      newCount = 0,
      [assembly_macro.ENUM_REDDOT.TASK_NEW] = {
        newCount = 0,
        subID = 2,
        category = reddot_macro.Category.NewArrivals
      }
    },
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
function AssemblyRedPointData.InitData()
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
function AssemblyRedPointData.OnLogin()
  log(bWriteLog and "AssemblyRedPointData.OnLogin")
  AssemblyRedPointData.InitData()
end
function AssemblyRedPointData.OnLogout()
  AssemblyRedPointData.DestroyData()
end
function AssemblyRedPointData.GetData()
  return superRedPoint
end
function AssemblyRedPointData.GetSubData(_reddot_id)
  if superRedPoint and superRedPoint.SubDatas then
    return superRedPoint.SubDatas[_reddot_id]
  end
  return nil
end
function AssemblyRedPointData.SetNewCount(_reddot_id, newCount)
  if superRedPoint then
    superRedPoint.groupShow = true
    local data = superRedPoint.SubDatas[_reddot_id]
    if data then
      data.    end
  end
end
function AssemblyRedPointData.UpdateRedDot()
  AssemblyRedPointData.AddAllRedPointData()
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  local hasCommonReward = false
  if not AssemblyActivitySystem.AssemblyData or not AssemblyActivitySystem.AssemblyData.recall_award then
    hasCommonReward = false
  else
    for _, v in pairs(AssemblyActivitySystem.AssemblyData.recall_award or {}) do
      if v == 1 then
        hasCommonReward = true
      end
    end
  end
  log(bWriteLog and string.format("AssemblyRedPointData.UpdateRedDot, hasCommonReward:%s", hasCommonReward))
  local hasReceive = false
  if not AssemblyActivitySystem.AssemblyData or not AssemblyActivitySystem.AssemblyData.task then
    hasReceive = false
  else
    for _, v in pairs(AssemblyActivitySystem.AssemblyData.task or {}) do
      if v.status == 1 then
        hasReceive = true
      end
    end
  end
  log(bWriteLog and string.format("AssemblyRedPointData.UpdateRedDot, hasReceive:%s", hasReceive))
  AssemblyRedPointData.SetNewCount(reddot_id.friend, (hasCommonReward or hasReceive) and 1 or 0)
  AssemblyRedPointData.UpdateJKWeekTaskRedDot()
end
function AssemblyRedPointData.UpdateJKWeekTaskRedDot()
  if GlobalData.IsJapanOrKorea() and LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_ZHU) then
    local WeekTaskSystem = require("client.slua.logic.task.logic_week_task")
    local HasRedDot = WeekTaskSystem.GetWeekTaskRedDot()
    log(bWriteLog and "AssemblyRedPointData.UpdateJKWeekTaskRedDot HasRedDot:" .. tostring(HasRedDot))
    AssemblyRedPointData.SetNewCount(reddot_id.jkWeekTask, HasRedDot and 1 or 0)
    local TableUtil = require("common.table_util")
    if HasRedDot then
      WeekTaskSystem.RefreshWeekTaskInfo()
      local dropIds = {}
      for _, v in pairs(WeekTaskSystem.WeekTaskInfos) do
        for _, t in ipairs(v.WeekTaskStatus) do
          if t.status == 1 then
            TableUtil.UniqueInsert(dropIds, t.dropId)
          end
        end
      end
      local BasicDataDropTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataDropTable)
      BasicDataDropTable:BatchGetOrReqData(dropIds)
    end
  end
end
function AssemblyRedPointData.AddAllRedPointData()
  local assembly_macro = require("client.slua.logic.come_back.assembly_macro")
  local logic_assembly_activity_utils = require("client.slua.logic.come_back.logic_assembly_activity_utils")
  if logic_assembly_activity_utils.IsNewActivity() then
    AssemblyRedPointData.AddRedPointData(assembly_macro.ENUM_REDDOT.TASK_NEW)
  else
    AssemblyRedPointData.RemoveRedPointData(assembly_macro.ENUM_REDDOT.TASK_NEW)
  end
end
function AssemblyRedPointData.AddRedPointData(type)
  log(bWriteLog and "AssemblyRedPointData.AddRedPointData " .. type)
  if superRedPoint then
    superRedPoint.pages[type].newCount = 1
  end
end
function AssemblyRedPointData.RemoveRedPointData(type)
  log(bWriteLog and "AssemblyRedPointData.RemoveRedPointData " .. type)
  if superRedPoint then
    superRedPoint.pages[type].newCount = 0
  end
end
function AssemblyRedPointData.DestroyData()
  superRedPoint = nil
  isInited = false
end
return AssemblyRedPointData