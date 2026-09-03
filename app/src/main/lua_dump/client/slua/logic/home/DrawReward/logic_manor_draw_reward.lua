local logic_manor_draw_reward = {}
function logic_manor_draw_reward:DefineAndResetData()
  self.isRun = false
  self.rewardRate = 0
  self.rewardConfigList = {}
  self.rewardRecord = {}
  self.rewardResult = nil
  self.dailyDrawInfo = nil
end
function logic_manor_draw_reward:OnPreSwitchGameStatus(preState, nextState)
  self:ClearRewardResult()
end
function logic_manor_draw_reward:SetIsRun(run)
  log(bWriteLog and "logic_manor_draw_reward:SetIsRun run:" .. tostring(run))
  self.isRun = run
end
function logic_manor_draw_reward:GetIsRun()
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestirctManor() then
    return false
  end
  return self.isRun
end
function logic_manor_draw_reward:GetRewardRate()
  local showRate = self.rewardRate * 50
  if 100 <= showRate then
    showRate = 99
  end
  return string.format("%.1f", showRate)
end
function logic_manor_draw_reward:GetRewardRecord()
  return self.rewardRecord
end
function logic_manor_draw_reward:GetRewardResult()
  return self.rewardResult
end
function logic_manor_draw_reward:GetDailyDrawInfo()
  return self.dailyDrawInfo
end
function logic_manor_draw_reward:GetRewardTypeList()
  local typeMap = {}
  for _, rewardTbl in ipairs(self.rewardConfigList) do
    if not typeMap[rewardTbl.is_senior] then
      typeMap[rewardTbl.is_senior] = true
    end
  end
  local typeList = {}
  for type, _ in pairs(typeMap) do
    table.insert(typeList, type)
  end
  table.sort(typeList, function(a, b)
    return b < a
  end)
  return typeList
end
function logic_manor_draw_reward:GetRewardConfigList(rewardType)
  local rewardList = {}
  for _, rewardTbl in ipairs(self.rewardConfigList) do
    if rewardTbl.is_senior == rewardType then
      table.insert(rewardList, rewardTbl)
    end
  end
  return rewardList
end
function logic_manor_draw_reward:send_manor_draw_reward_info_req()
  local PHomeDrawRewardHandler = require("client.network.Protocol.PHomeDrawRewardHandler")
  PHomeDrawRewardHandler.send_manor_draw_reward_info_req()
end
function logic_manor_draw_reward:on_manor_draw_reward_info_rsp(probability, reward_info, daily_draw_info)
  self:SetRewardRate(probability)
  self:SetRewardConfigList(reward_info)
  self:SetDailyDrawInfo(daily_draw_info)
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_MANOR_DRAW_REWARD_CONFIG)
end
function logic_manor_draw_reward:send_manor_draw_reward_record_req()
  local PHomeDrawRewardHandler = require("client.network.Protocol.PHomeDrawRewardHandler")
  PHomeDrawRewardHandler.send_manor_draw_reward_record_req()
end
function logic_manor_draw_reward:on_manor_draw_reward_record_rsp(records)
  self:SetRewardRecord(records)
end
function logic_manor_draw_reward:on_manor_draw_reward_notify(probability, reward_result, daily_draw_info)
  self:SetRewardRate(probability)
  self:SetRewardResult(reward_result)
  self:SetDailyDrawInfo(daily_draw_info)
end
function logic_manor_draw_reward:SetRewardRate(rate)
  log(bWriteLog and "logic_manor_draw_reward:SetRewardRate rate:" .. tostring(rate))
  self.rewardRate = rate
end
function logic_manor_draw_reward:SetRewardConfigList(reward_info)
  log_tree(bWriteLog and "logic_manor_draw_reward:SetRewardConfigList reward_info:", reward_info)
  self.rewardConfigList = reward_info
end
function logic_manor_draw_reward:SetDailyDrawInfo(daily_draw_info)
  log_tree(bWriteLog and "logic_manor_draw_reward:SetDailyDrawInfo daily_draw_info:", daily_draw_info)
  self.dailyDrawInfo = daily_draw_info
end
function logic_manor_draw_reward:SetRewardRecord(record)
  log_tree(bWriteLog and "logic_manor_draw_reward:SetRewardRecord record:", record)
  self.rewardRecord = record
  table.sort(self.rewardRecord, function(a, b)
    return a.get_time > b.get_time
  end)
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_MANOR_DRAW_REWARD_RECORD)
end
function logic_manor_draw_reward:SetRewardResult(result)
  log_tree(bWriteLog and "logic_manor_draw_reward:SetRewardResult result:", result)
  self.rewardResult = result
  if not next(result) then
    log(bWriteLog and "logic_manor_draw_reward:SetRewardResult no reward")
    return
  end
  if not SubsystemMgr then
    log(bWriteLog and "logic_manor_draw_reward:SetRewardResult no SubsystemMgr")
    return
  end
  local BattleResultRewardSubsystem = SubsystemMgr:Get("BattleResultRewardSubsystem")
  if not BattleResultRewardSubsystem then
    log(bWriteLog and "logic_manor_draw_reward:SetRewardResult no BattleResultRewardSubsystem")
    return
  end
  local drawReward = {
    res_id = result.reward_res_id,
    count = result.reward_cnt,
    valid_hours = 0
  }
  BattleResultRewardSubsystem:AddOneRewardData(UEnums.EResultRewardSourceType.HomeReward, drawReward)
end
function logic_manor_draw_reward:ClearRewardResult()
  log(bWriteLog and "logic_manor_draw_reward:ClearRewardResult")
  if self.rewardResult then
    self.rewardResult = nil
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_manor_draw_reward)