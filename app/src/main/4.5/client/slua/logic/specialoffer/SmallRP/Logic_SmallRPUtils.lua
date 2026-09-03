local Logic_SmallRPUtils = {}
function Logic_SmallRPUtils.GetSceneName()
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  local nRoundId = Logic_SmallRP:GetActRoundId()
  if not nRoundId then
    return
  end
  local uObj_actCfg = CDataTable.GetTableData("AssembleActShowCfg", nRoundId) or {}
  if not uObj_actCfg.SceneName or uObj_actCfg.SceneName == "" then
    return
  end
  return uObj_actCfg.SceneName
end
function Logic_SmallRPUtils.GetIPLineMaxProgressScore()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  local nIPLineActId = Logic_SmallRP:GetIPLineActId()
  if not nIPLineActId then
    return
  end
  local tActData = ActivityNewSystem.GetActivityByID(nIPLineActId)
  if not tActData then
    local ActivityHandler = require("client.network.Protocol.ActivityHandler")
    ActivityHandler.send_get_activity_one_req(nIPLineActId)
    return
  end
  local   local nProgressRewardType = ActivityType.PROGRESS_REWARD_ACT
  local tAllProRewardData = {}
  for _, v in pairs(tActData.List) do
    if v.Type == nProgressRewardType then
      table.insert(tAllProRewardData, v)
    end
  end
  table.sort(tAllProRewardData, function(a, b)
    return a.Order > b.Order
  end)
  local tMaxProRewardData = tAllProRewardData[#tAllProRewardData] or {}
  local nMaxScore = tMaxProRewardData.Condition and tMaxProRewardData.Condition[1]
  return nMaxScore
end
return Logic_SmallRPUtils