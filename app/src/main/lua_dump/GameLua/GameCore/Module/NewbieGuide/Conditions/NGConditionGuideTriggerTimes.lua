local NGConditionGuideTriggerTimes = {}
function NGConditionGuideTriggerTimes:ctor(selfType, Params)
  self.CheckGuideID = Params.GuideID or ""
  self.CheckDataKey = Params.DataKey or ""
  self.CheckTimesList = Params.LegalTimes or {}
end
function NGConditionGuideTriggerTimes:CheckConditionOK(...)
  local bSuperOk = NGConditionGuideTriggerTimes.__super.CheckConditionOK(self, ...)
  if not bSuperOk then
    return false
  end
  local NewbieGuideMgr = require("GameLua.GameCore.Module.NewbieGuide.NewbieGuideMgr")
  if not NewbieGuideMgr or not NewbieGuideMgr.ServerData then
    return false
  end
  local CheckGuideData = NewbieGuideMgr.ServerData[self.CheckGuideID]
  if not CheckGuideData then
    log(bWriteLog and "Debug NewbieGuide: NGConditionGuideTriggerTimes CheckConditionOK GuideSeverData not find. Guide" .. tostring(self.CheckGuideID))
    return false
  end
  local TriggerTimes = CheckGuideData.SingleRoundTriggerNumber
  log(bWriteLog and "Debug NewbieGuide: NGConditionGuideTriggerTimes CheckConditionOK Guide:" .. tostring(self.CheckGuideID) .. "TriggerTimes:" .. tostring(TriggerTimes))
  local TableUtil = require("common.table_util")
  local FindRes = TableUtil.Find(self.CheckTimesList, TriggerTimes)
  return FindRes ~= -1
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionGuideTriggerTimes = class(CObject, nil, NGConditionGuideTriggerTimes)
return CNGConditionGuideTriggerTimes