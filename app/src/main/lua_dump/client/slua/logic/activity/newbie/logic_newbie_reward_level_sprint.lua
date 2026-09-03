local logic_newbie_reward_level_sprint = {
  LevelAmount = 20,
  MaxRewardCount = 9,
  TimeStep = 604799
}
function logic_newbie_reward_level_sprint.IsOpen()
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  if not logic_newbie_new_abtest:CheckUseNewNewbieLogic() then
    log(bWriteLog and "logic_newbie_reward_level_sprint.IsOpen return not in ABTest new Group")
    return false
  end
  if DataMgr.roleData.level >= logic_newbie_reward_level_sprint.LevelAmount then
    local upgradeConfig = logic_newbie_reward_level_sprint.GetUpgradeConfig()
    local currentLevel = DataMgr.roleData.level
    local upgradeData = logic_newbie_new_abtest:GetNewbieNewDataUpgradeData()
    for _, config in pairs(upgradeConfig) do
      if currentLevel >= config.Level and not upgradeData[config.Level] then
        return true
      end
    end
    log(bWriteLog and "logic_newbie_reward_level_sprint.IsOpen return not in time end")
    return false
  end
  return true
end
function logic_newbie_reward_level_sprint.LoadConfig(group_id)
  log(bWriteLog and "logic_newbie_reward_level_sprint.LoadConfig group_id is " .. tostring(group_id))
  local NewbieUpgradeConfig = CDataTable.GetTable("NewbieLevelLockConfig")
  logic_newbie_reward_level_sprint.NewbieUpgradeConfig = {}
  for _, data in pairs(NewbieUpgradeConfig) do
    if data.GroupId == group_id and data.BannerUrl ~= "" and data.Reward1 ~= 0 then
      local config = {}
      config.Level = data.Level
      config.Reward1 = data.Reward1
      config.Reward1Number = data.Reward1Number
      config.Reward1Time = data.Reward1Time
      config.Reward2 = data.Reward2
      config.Reward2Number = data.Reward2Number
      config.Reward2Time = data.Reward2Time
      config.BannerUrl = data.BannerUrl
      table.insert(logic_newbie_reward_level_sprint.NewbieUpgradeConfig, config)
    end
  end
end
function logic_newbie_reward_level_sprint.GetUpgradeConfig()
  return logic_newbie_reward_level_sprint.NewbieUpgradeConfig or {}
end
function logic_newbie_reward_level_sprint.UpdateRedDotCount(superData)
  if not superData then
    return
  end
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  if not logic_newbie_reward_level_sprint.IsOpen() then
    superData.newCount = 0
    return
  end
  local count = 0
  local upgradeConfig = logic_newbie_reward_level_sprint.GetUpgradeConfig()
  local currentLevel = DataMgr.roleData.level
  local upgradeData = logic_newbie_new_abtest:GetNewbieNewDataUpgradeData()
  for _, config in pairs(upgradeConfig) do
    if currentLevel >= config.Level and not upgradeData[config.Level] then
      count = count + 1
    end
  end
  superData.newCount = count
  log(bWriteLog and "==============> newbie activity logic_newbie_reward_level_sprint UpdateRedDotCount: " .. count)
end
function logic_newbie_reward_level_sprint.HasRedDot()
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  if not logic_newbie_reward_level_sprint.IsOpen() then
    return false
  end
  local upgradeConfig = logic_newbie_reward_level_sprint.GetUpgradeConfig()
  local currentLevel = DataMgr.roleData.level
  local upgradeData = logic_newbie_new_abtest:GetNewbieNewDataUpgradeData()
  for _, config in pairs(upgradeConfig) do
    if currentLevel >= config.Level and not upgradeData[config.Level] then
      return true
    end
  end
  return false
end
function logic_newbie_reward_level_sprint.GetActivitySubData()
  if not logic_newbie_reward_level_sprint.IsOpen() then
    return
  end
  return {
    nActID = ActivityFixedID.Newbie_LevelSprint,
    sName = LocUtil.GetLocalizeResStr(29942),
    bRedDot = logic_newbie_reward_level_sprint.HasRedDot,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = 0
  }
end
function logic_newbie_reward_level_sprint.GetNewbieBannerEndTime()
  local nRegisterTime = DataMgr.registertime or 0
  local TimeUtil = require("client.common.time_util")
  if nRegisterTime == 0 or nRegisterTime > TimeUtil.GetServerTimeInSec() then
    return 0
  end
  log_format(bWriteLog and "logic_newbie_reward_level_sprint.GetNewbieEndTime nRegisterTime = %s ", nRegisterTime)
  local totalTime = logic_newbie_reward_level_sprint.TimeStep
  local tDateTable = TimeUtil.GetDateByUnixTime(nRegisterTime)
  if next(tDateTable) then
    nRegisterTime = nRegisterTime - tDateTable.hour * 3600 - tDateTable.min * 60 - tDateTable.sec
  end
  return totalTime + nRegisterTime
end
function logic_newbie_reward_level_sprint.HasNewbieBanner()
  if not logic_newbie_reward_level_sprint.IsOpen() then
    return false
  end
  if DataMgr.roleData.level < logic_newbie_reward_level_sprint.LevelAmount then
    return true
  end
  local nRegisterTime = DataMgr.registertime or 0
  local TimeUtil = require("client.common.time_util")
  if nRegisterTime > TimeUtil.GetServerTimeInSec() then
    log(bWriteLog and "logic_newbie_reward_level_sprint.HasNewbieBanner false , nRegisterTime is " .. tostring(nRegisterTime))
    return false
  end
  local endTime = logic_newbie_reward_level_sprint.GetNewbieBannerEndTime()
  if 0 > endTime - TimeUtil.GetServerTimeInSec() then
    log(bWriteLog and "logic_newbie_reward_level_sprint.HasNewbieBanner false , endTime is " .. tostring(endTime))
    return false
  end
  return true
end
function logic_newbie_reward_level_sprint.GetNextBannerLink(currentLevel)
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local link = ""
  local level = 1
  local upgradeConfig = logic_newbie_reward_level_sprint.NewbieUpgradeConfig or {}
  if not upgradeConfig or not next(upgradeConfig) then
    return link, level
  end
  local upgradeData = logic_newbie_new_abtest:GetNewbieNewDataUpgradeData()
  for i = 1, #upgradeConfig do
    local config = upgradeConfig[i]
    if not upgradeData[config.Level] then
      link = config.BannerUrl
      level = config.Level
      break
    end
  end
  log(bWriteLog and "logic_newbie_reward_level_sprint.GetNextBannerLink link is " .. tostring(link) .. " level is " .. tostring(level))
  return link, level
end
return logic_newbie_reward_level_sprint