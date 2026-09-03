local SmartAssistantActivityModule = {}
local SmartAssistantActivityConfig = require("client.slua.logic.activity.SmartAssistant.SmartAssistantActivityConfig")
local CONST = SmartAssistantActivityConfig.CONST
function SmartAssistantActivityModule:DefineAndResetData()
  self.OperationActivityMap = {}
  self.MetroActivityMap = {}
end
function SmartAssistantActivityModule:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayZeroCome, self)
end
function SmartAssistantActivityModule:OnDestroy()
  local BatchHelper = require("client.logic.Batch.BatchHelper")
  BatchHelper.Remove(CONST.OPERATION_ACTIVITY_KEY)
  BatchHelper.Remove(CONST.METRO_WEEK_TASK_KEY)
  self.OperationActivityMap = {}
  self.MetroActivityMap = {}
end
function SmartAssistantActivityModule:OnNextDayZeroCome()
  local BatchHelper = require("client.logic.Batch.BatchHelper")
  BatchHelper.Remove(CONST.OPERATION_ACTIVITY_KEY)
  BatchHelper.Remove(CONST.METRO_WEEK_TASK_KEY)
  self.OperationActivityMap = {}
  self.MetroActivityMap = {}
end
function SmartAssistantActivityModule:Report(key)
  local SmartAssistantHandler = require("client.network.Protocol.SmartAssistantHandler")
  SmartAssistantHandler.send_robot_assistant_notice_module_change_req(key)
end
function SmartAssistantActivityModule:SaveOperationActivity(actId, ChangeType)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByID(actId)
  if not actData or actData.RedPointSwitcher ~= ActivityRedPointStatus.AllowGiftNormalNewCountdownReport then
    return
  end
  self:_SaveData(actId, ChangeType, self.OperationActivityMap, actData.Order, CONST.OPERATION_ACTIVITY_KEY)
end
function SmartAssistantActivityModule:SaveMetroWeekTask(actId, changeType)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivityByID(actId)
  if not actData or actData.Type ~= ActivityType.ACTIVITY_TYPE_AREA_GROUP or actData.TabType ~= ActivitySwitchType.Xmission then
    return
  end
  self:_SaveData(actId, changeType, self.MetroActivityMap, actData.Order, CONST.METRO_WEEK_TASK_KEY)
end
function SmartAssistantActivityModule:GetRecommendOperationActivityID()
  if not self.OperationActivityMap or not next(self.OperationActivityMap) then
    return nil
  end
  local list = {}
  for k, v in pairs(self.OperationActivityMap) do
    table.insert(list, v)
  end
  table.sort(list, function(a, b)
    if a.ChangeType ~= b.ChangeType then
      return a.ChangeType > b.ChangeType
    end
    if a.Weight ~= b.Weight then
      return a.Weight > b.Weight
    end
    return a.ActID > b.ActID
  end)
  return list[1].ActID
end
function SmartAssistantActivityModule:GetRecommendMetroWeekTaskActivityID()
  if not self.MetroActivityMap or not next(self.MetroActivityMap) then
    return nil
  end
  local list = {}
  for k, v in pairs(self.MetroActivityMap) do
    table.insert(list, v)
  end
  table.sort(list, function(a, b)
    if a.ChangeType ~= b.ChangeType then
      return a.ChangeType > b.ChangeType
    end
    if a.Weight ~= b.Weight then
      return a.Weight > b.Weight
    end
    return a.ActID > b.ActID
  end)
  return list[1].ActID
end
function SmartAssistantActivityModule:_SaveData(ActId, ChangeType, map, weight, reportKey)
  if ChangeType == CONST.ActChangeType.None then
    map[ActId] = nil
  elseif not map[ActId] then
    map[ActId] = {
      ActID = ActId,
      ChangeType = ChangeType,
      Weight = weight
    }
  elseif ChangeType > map[ActId].ChangeType then
    map[ActId].  end
  if ChangeType ~= CONST.ActChangeType.None then
    local BatchHelper = require("client.logic.Batch.BatchHelper")
    BatchHelper.DoOnce(reportKey, 5, self.Report, self, reportKey)
  else
    local HasOtherAct = next(map) ~= nil
    if not HasOtherAct then
      local BatchHelper = require("client.logic.Batch.BatchHelper")
      BatchHelper.Cancel(reportKey)
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CSmartAssistantActivityModule = class(CModuleBase, nil, SmartAssistantActivityModule)
return CSmartAssistantActivityModule