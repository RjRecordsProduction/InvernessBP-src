local Logic_Warm_Up_Group = {}
function Logic_Warm_Up_Group:InitCfg(tActParamCfg, tRewardCfg)
  self.actConfig = {
    jumpActivityID = tActParamCfg.jumpActivityID,
    begin_time = tActParamCfg.start_time,
    end_time = tActParamCfg.end_time,
    stages = tRewardCfg
  }
  log(bWriteLog and "Logic_Warm_Up_Group:InitCfg Success" .. tostring(tActParamCfg.jumpActivityID))
end
function Logic_Warm_Up_Group:TryGetCfg()
  log(bWriteLog and "Logic_Warm_Up_Group:TryGetCfg")
  local Promise = require("common.Promise")
  local tNewPromise = Promise.new()
  if self.actConfig then
    tNewPromise:Resolve()
    log(bWriteLog and "Logic_Warm_Up_Group:TryGetCfg cfg exits")
    return tNewPromise
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local tableList = {
    data_config_marco.pre_team_act_params_config,
    data_config_marco.pre_team_act_reward_config
  }
  BasicDataServerTable:BatchGetOrReqData(tableList, function(table_map)
    log_tree("Logic_Warm_Up_Group:TryGetCfg", table_map)
    local tActParamCfg = BasicDataServerTable:GetCacheData(data_config_marco.pre_team_act_params_config)
    local tRewardCfg = BasicDataServerTable:GetCacheData(data_config_marco.pre_team_act_reward_config)
    if not tActParamCfg then
      log_error("Logic_Warm_Up_Group:TryGetCfg tActParamCfg = nil")
      return
    end
    if not tRewardCfg then
      log_error("Logic_Warm_Up_Group:TryGetCfg tRewardCfg = nil")
      return
    end
    self:InitCfg(tActParamCfg, tRewardCfg)
    tNewPromise:Resolve()
  end)
  return tNewPromise
end
function Logic_Warm_Up_Group:GetMaxMemberCount()
  local tCfg = self:GetSeverCfg()
  if not tCfg then
    return 0
  end
  local tRewardCfgs = tCfg.stages
  local nMaxCount = 0
  for nMemberCount, _ in pairs(tRewardCfgs) do
    if nMemberCount > nMaxCount then
      nMaxCount = nMemberCount
    end
  end
  return nMaxCount
end
function Logic_Warm_Up_Group:GetJumpActivityID()
  local tActCfg = self:GetSeverCfg()
  return tonumber(tActCfg.jumpActivityID)
end
function Logic_Warm_Up_Group:GetEndTime()
  local time = 0
  local cfg = self:GetSeverCfg()
  if cfg then
    time = cfg.end_time
  end
  return time
end
function Logic_Warm_Up_Group:GetCurActivityTime()
  local beginTime = 0
  local endTime = 0
  local cfg = self:GetSeverCfg()
  if cfg and cfg.begin_time and cfg.end_time then
    beginTime = cfg.begin_time
    endTime = cfg.end_time
  end
  return beginTime, endTime
end
function Logic_Warm_Up_Group:GetSeverCfg()
  return self.actConfig
end
local Trait = require("common.trait")
local CLogic_Warm_Up_Group = Trait(Trait.TraitPrototype, nil, Logic_Warm_Up_Group)
return CLogic_Warm_Up_Group