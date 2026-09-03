local Logic_Bonus_ReadFrontCfg = {}
function Logic_Bonus_ReadFrontCfg:DefineAndResetData()
  Logic_Bonus_ReadFrontCfg.__super.DefineAndResetData(self)
end
function Logic_Bonus_ReadFrontCfg:OnInitialize()
  Logic_Bonus_ReadFrontCfg.__super.OnInitialize(self)
end
function Logic_Bonus_ReadFrontCfg:RegistEvents()
  Logic_Bonus_ReadFrontCfg.__super.RegistEvents(self)
end
function Logic_Bonus_ReadFrontCfg:OnLogin(bReLogin)
  Logic_Bonus_ReadFrontCfg.__super.OnLogin(self, bReLogin)
end
function Logic_Bonus_ReadFrontCfg:OnPostSwitchGameStatus(nPreStatus, _)
end
function Logic_Bonus_ReadFrontCfg:GetBPSeasonControlCfg()
  local sPath = self:GetSeasonControlCfgPath()
  local tBPSeasonCfg = CDataTable.GetTableDataByFilter(sPath, "seasonID", UnknowPassSystem.Season)
  if not tBPSeasonCfg then
    return
  end
  return tBPSeasonCfg
end
function Logic_Bonus_ReadFrontCfg:GetBPLevelAwardCfg()
  local sPath = self:GetLevelAwardCfgPath()
  local tLevelCfg = CDataTable.GetTableByFilter(sPath, "seasonID", UnknowPassSystem.Season)
  if not tLevelCfg then
    return
  end
  local tBPAwardCfg = {}
  for _, v in pairs(tLevelCfg) do
    tBPAwardCfg[v.awardLevel] = {
      awardLevel = v.awardLevel,
      specialShow = v.specialShow,
      awardItemID1 = v.awardItemID1,
      awardItemCount1 = v.awardItemCount1,
      awardItemValidHours1 = v.awardItemValidHours1,
      awardItemID2 = v.awardItemID2,
      awardItemCount2 = v.awardItemCount2,
      awardItemValidHours2 = v.awardItemValidHours2,
      twoItemSelect = v.twoItemSelect
    }
  end
  return tBPAwardCfg
end
function Logic_Bonus_ReadFrontCfg:GetBPFullLevelExtraRewardCfg()
  local sCfgPath = "FullLevelExtraReward"
  if GlobalData.IsJapanOrKorea() then
    sCfgPath = "FullLevelExtraRewardJK"
  elseif GlobalData.IsBLUEHOLE() then
    sCfgPath = "FullLevelExtraRewardIN"
  end
  local tFullLevelAwardCfg = CDataTable.GetTableData(sCfgPath, UnknowPassSystem.Season)
  if not tFullLevelAwardCfg then
    return
  end
  return tFullLevelAwardCfg
end
function Logic_Bonus_ReadFrontCfg:GetBPDailyTaskCfg()
  local tDailyTaskCfg = CDataTable.GetTableByFilter("RPBranchDailyTask", "SeasonID", UnknowPassSystem.Season)
  if not tDailyTaskCfg then
    return
  end
  local tBPDailyTaskCfg = {}
  for _, v in pairs(tDailyTaskCfg) do
    tBPDailyTaskCfg[#tBPDailyTaskCfg + 1] = {
      index = v.Index,
      seasonID = v.SeasonID,
      days = v.Days,
      taskGroupID = v.TaskGroupID
    }
  end
  return tBPDailyTaskCfg
end
function Logic_Bonus_ReadFrontCfg:GetBPWeekTaskCfg()
  local tWeekTaskCfg = CDataTable.GetTableByFilter("RPBranchWeekTask", "SeasonID", UnknowPassSystem.Season)
  if not tWeekTaskCfg then
    return
  end
  local tBPWeekTaskCfg = {}
  for _, v in pairs(tWeekTaskCfg) do
    tBPWeekTaskCfg[#tBPWeekTaskCfg + 1] = {
      index = v.Index,
      seasonID = v.SeasonID,
      weeks = v.Weeks,
      taskGroupID = v.TaskGroupID
    }
  end
  return tBPWeekTaskCfg
end
function Logic_Bonus_ReadFrontCfg:GetBPTaskCfgByIndexAndGroupID(taskGroupId)
  local tBPTaskCfg = {}
  local tTempCfg = CDataTable.GetTableByFilter("RPBranchTaskGroup", "TaskGroupID", taskGroupId)
  for _, v in pairs(tTempCfg) do
    tBPTaskCfg[#tBPTaskCfg + 1] = {
      index = v.Index,
      taskGroupID = v.TaskGroupID,
      taskID = v.TaskID,
      showSortOrder = v.ShowSortOrder,
      awardScores = v.AwardScores,
      taskType = v.TaskType
    }
  end
  local tFinalTaskCfg = {}
  for _, v in pairs(tBPTaskCfg) do
    table.insert(tFinalTaskCfg, v)
  end
  table.sort(tFinalTaskCfg, function(a, b)
    return a.showSortOrder < b.showSortOrder
  end)
  return tFinalTaskCfg
end
function Logic_Bonus_ReadFrontCfg:GetBPTaskCfgByTaskIdandGroupID(taskId, taskGroupId)
  local tBPTaskCfg = {}
  local tTempCfg = CDataTable.GetTableByFilter("RPBranchTaskGroup", "TaskID", taskId, "TaskGroupID", taskGroupId)
  for _, v in pairs(tTempCfg) do
    tBPTaskCfg[#tBPTaskCfg + 1] = {
      index = v.Index,
      taskGroupID = v.TaskGroupID,
      taskID = v.TaskID,
      showSortOrder = v.ShowSortOrder,
      awardScores = v.AwardScores,
      taskType = v.TaskType
    }
  end
  local tFinalTaskCfg = {}
  for _, v in pairs(tBPTaskCfg) do
    table.insert(tFinalTaskCfg, v)
  end
  table.sort(tFinalTaskCfg, function(a, b)
    return a.showSortOrder < b.showSortOrder
  end)
  return tFinalTaskCfg
end
function Logic_Bonus_ReadFrontCfg:GetBPCoreRewardCfg()
  local tBPCoreRewardCfg = {}
  local tRewardCfg = CDataTable.GetTableByFilter("BranchCoreAward", "seasonID", UnknowPassSystem.Season)
  for _, v in pairs(tRewardCfg) do
    tBPCoreRewardCfg[#tBPCoreRewardCfg + 1] = v
  end
  return tBPCoreRewardCfg
end
function Logic_Bonus_ReadFrontCfg:GetSeasonControlCfgPath()
  local sPath = "BranchSeasonControl"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bIsBLUEHOLE = PublishRegionMacros.IsBLUEHOLE()
  if bIsBLUEHOLE then
    sPath = "BranchSeasonControlIN"
  end
  return sPath
end
function Logic_Bonus_ReadFrontCfg:GetLevelAwardCfgPath()
  local sPath = "BranchLevelAward"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bIsJapanOrKorea = PublishRegionMacros.IsJapanOrKorea()
  local bIsBLUEHOLE = PublishRegionMacros.IsBLUEHOLE()
  if bIsJapanOrKorea then
    sPath = "BranchLevelAwardKJ"
  elseif bIsBLUEHOLE then
    sPath = "BranchLevelAwardIN"
  end
  return sPath
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_Bonus_ReadFrontCfg = class(CModuleBase, nil, Logic_Bonus_ReadFrontCfg)
return CLogic_Bonus_ReadFrontCfg