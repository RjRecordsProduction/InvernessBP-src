local LogicNewbieLevelSprint = {}
function LogicNewbieLevelSprint.UpdateRedDotCount(superData)
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bLevelUnlockSwitchOpen = level_unlock_util:IsSwitchOpen()
  log(bWriteLog and "LogicNewbieLevelSprint.UpdateRedDotCount bLevelUnlockSwitchOpen = " .. tostring(bLevelUnlockSwitchOpen))
  if not bLevelUnlockSwitchOpen then
    return
  end
  local count = 0
  local level_unlock_award_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_award_manager)
  local levelAwardList = level_unlock_award_manager:GetLevelAwardList()
  local currentLevel = DataMgr.roleData.level
  local awardStatus = level_unlock_award_manager:GetAwardStatus()
  if not awardStatus then
    return
  end
  for i = 1, #levelAwardList do
    local award = levelAwardList[i]
    if award and currentLevel >= award.level and awardStatus[award.level] == 1 then
      count = count + 1
    end
  end
  superData.newCount = count
  log(bWriteLog and "==============> newbie activity LogicNewbieLevelSprint UpdateRedDotCount: " .. count)
end
function LogicNewbieLevelSprint.HasRedDot()
  local level_unlock_award_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_award_manager)
  local levelAwardList = level_unlock_award_manager:GetLevelAwardList()
  local currentLevel = DataMgr.roleData.level
  local awardStatus = level_unlock_award_manager:GetAwardStatus()
  for i = 1, #levelAwardList do
    local award = levelAwardList[i]
    if award and currentLevel >= award.level and awardStatus[award.level] == 1 then
      return true
    end
  end
  return false
end
function LogicNewbieLevelSprint.IsOpen()
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bLevelUnlockSwitchOpen = level_unlock_util:IsSwitchOpen()
  log(bWriteLog and "LogicNewbieLevelSprint.IsOpen bLevelUnlockSwitchOpen = " .. tostring(bLevelUnlockSwitchOpen))
  if not bLevelUnlockSwitchOpen then
    return false
  end
  local level_unlock_award_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_award_manager)
  local awardStatus = level_unlock_award_manager:GetAwardStatus()
  local levelAwardList = level_unlock_award_manager:GetLevelAwardList()
  if awardStatus and levelAwardList then
    for i = 1, #levelAwardList do
      local award = levelAwardList[i]
      if awardStatus[award.level] ~= 2 then
        return true
      end
    end
  else
    log(bWriteLog and "LogicNewbieLevelSprint award status is: " .. tostring(awardStatus) .. " award list is: " .. tostring(levelAwardList))
  end
  return false
end
function LogicNewbieLevelSprint.GetActivitySubData()
  return {
    nActID = ActivityFixedID.Newbie_LevelSprint,
    sName = LocUtil.GetLocalizeResStr(29942),
    bRedDot = LogicNewbieLevelSprint.HasRedDot,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = 0
  }
end
return LogicNewbieLevelSprint