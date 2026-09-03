local logic_ninja_training = {}
local CREDIT_ITEM_ID = 23562
local LEVEL_TASK_SORT_WEIGHT = {
  Claimable = 1,
  InProgress = 2,
  Locked = 3,
  Claimed = 4
}
function logic_ninja_training:DefineAndResetData()
  self.levelData = nil
  self.levelRewardsClaimed = {}
  self._levelDataReady = false
  self._requestingLevelData = false
  self.lastSelectTab = nil
end
function logic_ninja_training:OnInitialize()
  log(bWriteLog and "[NinjaTraining] logic_ninja_training:OnInitialize")
  self:_LoadPendingLevelUp()
end
function logic_ninja_training:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_TASK_REWARD_RSP, self.OnThemeTaskRewardRsp, self)
end
function logic_ninja_training:OnPreSwitchGameStatus(preState, nextState)
  self:DefineAndResetData()
end
function logic_ninja_training:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Lobby then
    self:_TryLoadLevelData()
  end
end
function logic_ninja_training:GetCurrentLevel()
  self:_TryLoadLevelData()
  return self.levelData and self.levelData.current_level or 1
end
function logic_ninja_training:GetTotalCredit()
  self:_TryLoadLevelData()
  return self.levelData and self.levelData.credit or 0
end
function logic_ninja_training:GetCurrentLevelName()
  local NinjaTrainingConfig = require("client.slua.logic.theme_system.naruto.ninja_training_config")
  return NinjaTrainingConfig.GetLevelName(self:GetCurrentLevel())
end
function logic_ninja_training:GetCurrentLevelIcon()
  self:_TryLoadLevelData()
  if not self:HasLevelData() then
    return ""
  end
  local NinjaTrainingConfig = require("client.slua.logic.theme_system.naruto.ninja_training_config")
  local cfg = NinjaTrainingConfig.GetLevelConfig()[self:GetCurrentLevel()]
  return cfg and cfg.icon or ""
end
function logic_ninja_training:GetLevelRequiredCredit(level)
  self:_TryLoadLevelData()
  if not self.levelData or not self.levelData.level_thresholds then
    return 0
  end
  for _, v in ipairs(self.levelData.level_thresholds) do
    if v.level == level then
      return v.required_credit or 0
    end
  end
  return 0
end
function logic_ninja_training:GetLevelRewards(level)
  self:_TryLoadLevelData()
  if not self.levelData or not self.levelData.level_thresholds then
    return {}
  end
  for _, v in ipairs(self.levelData.level_thresholds) do
    if v.level == level then
      return v.awards or {}
    end
  end
  return {}
end
function logic_ninja_training:GetLevelRewardsForUI(level)
  local awards = self:GetLevelRewards(level)
  local list = {}
  for _, a in ipairs(awards) do
    if a.id and a.id > 0 then
      table.insert(list, {
        itemId = a.id,
        count = a.count or 1
      })
    end
  end
  return list
end
function logic_ninja_training:GetChakraCap()
  self:_TryLoadLevelData()
  return self.levelData and self.levelData.chakra_cap or 0
end
function logic_ninja_training:GetUpgradeTask()
  self:_TryLoadLevelData()
  return self.levelData and self.levelData.upgrade_tasks or nil
end
function logic_ninja_training:GetLevelTaskRuntime(taskId)
  self:_TryLoadLevelData()
  if not taskId then
    return nil
  end
  local levelTasks = self.levelData and self.levelData.level_tasks or {}
  return levelTasks[taskId]
end
function logic_ninja_training:HasClaimableLevelTask()
  self:_TryLoadLevelData()
  local levelTasks = self.levelData and self.levelData.level_tasks or {}
  for _, t in pairs(levelTasks) do
    if t.status == 1 then
      return true
    end
  end
  return false
end
function logic_ninja_training:GetLevelTaskListForUI(level)
  local NinjaTrainingConfig = require("client.slua.logic.theme_system.naruto.ninja_training_config")
  local currentLevel = self:GetCurrentLevel()
  local isLocked = level > currentLevel
  local taskIds = NinjaTrainingConfig.GetLevelTaskList(level)
  local list = {}
  for _, tid in ipairs(taskIds or {}) do
    local weight
    if isLocked then
      weight = LEVEL_TASK_SORT_WEIGHT.Locked
    else
      local runtime = self:GetLevelTaskRuntime(tid)
      local status = runtime and runtime.status or 0
      if status == 1 then
        weight = LEVEL_TASK_SORT_WEIGHT.Claimable
      elseif status == 2 then
        weight = LEVEL_TASK_SORT_WEIGHT.Claimed
      else
        weight = LEVEL_TASK_SORT_WEIGHT.InProgress
      end
    end
    table.insert(list, {
      task_id = tid,
      isLocked = isLocked,
      _    })
  end
  table.sort(list, function(a, b)
    return a._weight < b._weight
  end)
  return list
end
function logic_ninja_training:OnThemeTaskRewardRsp(_, _, task_id, item_id, item_count)
  log(bWriteLog and string.format("[NinjaTraining] logic_ninja_training:OnThemeTaskRewardRsp task_id=%s, item_id=%s, item_count=%s", tostring(task_id), tostring(item_id), tostring(item_count)))
  if not self.levelData then
    log(bWriteLog and "[NinjaTraining] logic_ninja_training:OnThemeTaskRewardRsp levelData is nil, skip")
    return
  end
  if task_id and self.levelData.level_tasks and self.levelData.level_tasks[task_id] then
    self.levelData.level_tasks[task_id].status = 2
    EventSystem:postEvent(EVENTTYPE_NINJA_TRAINING, EVENTID_NINJA_TRAINING_LEVEL_DATA_RSP)
  end
  if item_id == CREDIT_ITEM_ID and item_count and 0 < item_count then
    self.levelData.credit = (self.levelData.credit or 0) + item_count
    EventSystem:postEvent(EVENTTYPE_NINJA_TRAINING, EVENTID_NINJA_TRAINING_CREDIT_UPDATE)
  end
end
function logic_ninja_training:GetCreditThresholds()
  local curLevel = self:GetCurrentLevel()
  local curThreshold = self:GetLevelRequiredCredit(curLevel)
  local nextThreshold = self:GetLevelRequiredCredit(curLevel + 1)
  if curThreshold >= nextThreshold then
    return curThreshold, curThreshold
  end
  return curThreshold, nextThreshold
end
function logic_ninja_training:GetCreditProgress()
  local curThreshold, nextThreshold = self:GetCreditThresholds()
  if nextThreshold <= curThreshold then
    return 1
  end
  local totalCredit = self:GetTotalCredit()
  local progress = totalCredit / nextThreshold
  return math.max(0, math.min(1, progress))
end
function logic_ninja_training:GetCreditProgressText()
  local _, nextThreshold = self:GetCreditThresholds()
  local totalCredit = self:GetTotalCredit()
  if self:IsMaxLevel() then
    return tostring(totalCredit)
  end
  return LocUtil.LocalizeResFormat(6830, totalCredit, nextThreshold)
end
function logic_ninja_training:IsMaxLevel()
  local NinjaTrainingConfig = require("client.slua.logic.theme_system.naruto.ninja_training_config")
  return self:GetCurrentLevel() >= NinjaTrainingConfig.GetMaxLevel()
end
function logic_ninja_training:IsLevelRewardClaimed(level)
  for _, claimedLevel in ipairs(self.levelRewardsClaimed or {}) do
    if claimedLevel == level then
      return true
    end
  end
  return false
end
function logic_ninja_training:CanClaimLevelReward(level)
  local requiredCredit = self:GetLevelRequiredCredit(level)
  return requiredCredit <= self:GetTotalCredit() and not self:IsLevelRewardClaimed(level)
end
function logic_ninja_training:EquipLevelRewards(level)
  log(bWriteLog and string.format("[NinjaTraining] logic_ninja_training:EquipLevelRewards level=%s", tostring(level)))
  local rewards = self:GetLevelRewards(level)
  if not rewards or #rewards == 0 then
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  for _, a in ipairs(rewards) do
    local resId = a.id
    if resId and 0 < resId then
      local itemData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(resId) or wardrobe_data:GetHallDepotItemDataByResID(resId)
      if itemData then
        WardrobeLogicManager:wardrobe_puton_data_req(itemData)
      end
    end
  end
end
function logic_ninja_training:IsNarutoActivityOpen()
  return true
end
function logic_ninja_training:HasLevelData()
  return self._levelDataReady == true
end
function logic_ninja_training:_TryLoadLevelData()
  if self._levelDataReady or self._requestingLevelData then
    return
  end
  log(bWriteLog and "[NinjaTraining] logic_ninja_training:_TryLoadLevelData sending get_ninja_level_data_req")
  self._requestingLevelData = true
  local ThemeNarutoHandler = require("client.network.Protocol.ThemeNarutoHandler")
  ThemeNarutoHandler.send_get_ninja_level_data_req()
end
function logic_ninja_training:SetLastSelectTab(tab)
  self.lastSelectTab = tab
end
function logic_ninja_training:GetLastSelectTab()
  return self.lastSelectTab
end
function logic_ninja_training:on_get_ninja_level_data_rsp(rsp_data)
  log_tree(bWriteLog and "[NinjaTraining] logic_ninja_training:on_get_ninja_level_data_rsp rsp_data", rsp_data)
  if not rsp_data then
    log_warning("logic_ninja_training:on_get_ninja_level_data_rsp rsp_data is nil")
    self._requestingLevelData = false
    return
  end
  self.levelData = rsp_data
  self._levelDataReady = true
  self._requestingLevelData = false
  EventSystem:postEvent(EVENTTYPE_NINJA_TRAINING, EVENTID_NINJA_TRAINING_LEVEL_DATA_RSP)
end
function logic_ninja_training:proc_claim_level_reward_rsp(err_code, level, award_list)
  log(bWriteLog and string.format("[NinjaTraining] logic_ninja_training:proc_claim_level_reward_rsp err_code=%s, level=%s", tostring(err_code), tostring(level)))
  log_tree("[NinjaTraining] logic_ninja_training:proc_claim_level_reward_rsp award_list", award_list)
  if err_code ~= 0 then
    log_warning(string.format("logic_ninja_training:proc_claim_level_reward_rsp err = %s", err_code))
    return
  end
  self.levelRewardsClaimed = self.levelRewardsClaimed or {}
  table.insert(self.levelRewardsClaimed, level)
  if award_list and 0 < #award_list then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(award_list)
  end
  EventSystem:postEvent(EVENTTYPE_NINJA_TRAINING, EVENTID_NINJA_TRAINING_LEVEL_REWARD_RSP)
end
function logic_ninja_training:on_notify_ninja_level_reward(push_data)
  log_tree(bWriteLog and "[NinjaTraining] logic_ninja_training:on_notify_ninja_level_reward push_data", push_data)
  if not push_data then
    log_warning("logic_ninja_training:on_notify_ninja_level_reward push_data is nil")
    return
  end
  if not self.levelData then
    self.levelData = {}
  end
  if push_data.total_credit ~= nil then
    self.levelData.credit = push_data.total_credit
  end
  if push_data.chakra_cap ~= nil then
    self.levelData.chakra_cap = push_data.chakra_cap
  end
  local new_level = push_data.new_level
  log(bWriteLog and string.format("[NinjaTraining] logic_ninja_training:on_notify_ninja_level_reward current_level=%s", tostring(self.levelData.current_level)))
  if new_level then
    local prevLevel = new_level - 1
    self.levelData.current_level = new_level
    self:_SavePendingLevelUp(prevLevel, new_level, push_data.award_list)
    EventSystem:postEvent(EVENTTYPE_NINJA_TRAINING, EVENTID_NINJA_TRAINING_LEVEL_UP_PENDING)
  end
  EventSystem:postEvent(EVENTTYPE_NINJA_TRAINING, EVENTID_NINJA_TRAINING_CREDIT_UPDATE)
end
function logic_ninja_training:_ShowLevelUpAnimation(prevLevel, nextLevel, awardList)
  log_tree(string.format("[NinjaTraining] logic_ninja_training:_ShowLevelUpAnimation prevLevel=%s, nextLevel=%s, awardList=", tostring(prevLevel), tostring(nextLevel)), awardList)
  UIManager.ShowUI(UIManager.UI_Config.Theme_Naruto_Transition_UIBP, {
    prevLevel = prevLevel,
    nextLevel = nextLevel,
      })
end
function logic_ninja_training:_LoadPendingLevelUp()
  log(bWriteLog and "[NinjaTraining] logic_ninja_training:_LoadPendingLevelUp")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self._pendingLevelUp = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNinjaTrainingLevelUp)
end
function logic_ninja_training:_SavePendingLevelUp(prevLevel, nextLevel, awardList)
  self._pendingLevelUp = {
    prevLevel = prevLevel,
    nextLevel = nextLevel,
    award_list = awardList or {}
  }
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self._pendingLevelUp, PlayerPrefsSystem.ePlayerPrefsType.eNinjaTrainingLevelUp)
  log_tree(string.format("[NinjaTraining] logic_ninja_training:_SavePendingLevelUp prevLevel=%s, nextLevel=%s, awardList=", prevLevel, nextLevel), awardList)
end
function logic_ninja_training:_ClearPendingLevelUp()
  log(bWriteLog and "[NinjaTraining] logic_ninja_training:_ClearPendingLevelUp")
  self._pendingLevelUp = nil
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.eNinjaTrainingLevelUp)
end
function logic_ninja_training:HasPendingLevelUp()
  if not self._pendingLevelUp then
    self:_LoadPendingLevelUp()
  end
  return self._pendingLevelUp and self._pendingLevelUp.nextLevel ~= nil
end
function logic_ninja_training:ConsumePendingLevelUp()
  if not self:HasPendingLevelUp() then
    return
  end
  local cache = self._pendingLevelUp
  log(bWriteLog and string.format("[NinjaTraining] logic_ninja_training:ConsumePendingLevelUp prevLevel=%s, nextLevel=%s", tostring(cache.prevLevel), tostring(cache.nextLevel)))
  self:_ShowLevelUpAnimation(cache.prevLevel, cache.nextLevel, cache.award_list)
  self:_ClearPendingLevelUp()
  EventSystem:postEvent(EVENTTYPE_NINJA_TRAINING, EVENTID_NINJA_TRAINING_LEVEL_UP_PENDING)
end
function logic_ninja_training:NeedShowTaskReddot()
  if self:HasClaimableLevelTask() then
    return true
  end
  local ut = self:GetUpgradeTask()
  if ut and ut.finish_value and ut.finish_value > 0 and (ut.value or 0) >= ut.finish_value then
    return true
  end
  local logic_ninja_training_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ninja_training_task)
  return logic_ninja_training_task:NeedShowTaskReddot()
end
function logic_ninja_training:NeedShowLevelUpReddot()
  local NinjaTrainingConfig = require("client.slua.logic.theme_system.naruto.ninja_training_config")
  local maxLevel = NinjaTrainingConfig.GetMaxLevel()
  for level = 1, maxLevel do
    if self:CanClaimLevelReward(level) then
      return true
    end
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ninja_training = class(CModuleBase, nil, logic_ninja_training)
return Clogic_ninja_training