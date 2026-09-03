local logic_level_unlock_report = {}
function logic_level_unlock_report:DefineAndResetData()
  self.levelNeedToReport = {
    {Level = 5, AdjustId = 34},
    {Level = 10, AdjustId = 35},
    {Level = 15, AdjustId = 36},
    {Level = 20, AdjustId = 37},
    {Level = 25, AdjustId = 38},
    {Level = 30, AdjustId = 39},
    {Level = 35, AdjustId = 40},
    {Level = 40, AdjustId = 41}
  }
end
function logic_level_unlock_report:RegistEvents()
  log(bWriteLog and "logic_level_unlock_report:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE, self.OnLevelChange, self)
end
function logic_level_unlock_report:OnLevelChange(_, __, new_level)
  log(bWriteLog and "logic_level_unlock_report:OnLevelChange new_level " .. tostring(new_level))
  local LevelUpSystem = require("client.logic.levelup.logic_levelup")
  local old_level = LevelUpSystem.OldLevel
  for _, v in ipairs(self.levelNeedToReport) do
    if old_level < v.Level and new_level >= v.Level then
      local StatManager = import("StatManager")
      StatManager.GetInstance():ReportEventWithNoParam(v.AdjustId, true)
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_level_unlock_report = class(CModuleBase, nil, logic_level_unlock_report)
return Clogic_level_unlock_report