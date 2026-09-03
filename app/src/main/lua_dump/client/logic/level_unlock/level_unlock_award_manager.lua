local level_unlock_config = require("client.logic.level_unlock.config.level_unlock_config")
local EAwardStatus = level_unlock_config.EAwardStatus
local level_unlock_award_manager = {}
function level_unlock_award_manager:DefineAndResetData()
  self._levelToAward = {}
  self._levelAwardList = {}
  self._awardStatus = {}
  self._bannerLinks = {}
end
function level_unlock_award_manager:OnInitialize()
end
function level_unlock_award_manager:RegistEvents()
end
function level_unlock_award_manager:OnLogin(bReLogin)
end
function level_unlock_award_manager:OnLogOut()
end
function level_unlock_award_manager:OnPreSwitchGameStatus(preState, nextState)
end
function level_unlock_award_manager:OnPostSwitchGameStatus(preState, nextState)
end
function level_unlock_award_manager:InitByData(unlockData)
  if not unlockData then
    return
  end
  self._levelToAward = {}
  self._levelAwardList = {}
  self._bannerLinks = {}
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local isNewbieABTest = logic_newbie_new_abtest:CheckUseNewNewbieLogic()
  if isNewbieABTest then
    self:_InitByNewConfig()
    return
  end
  self:_InitByOldConfig(unlockData)
end
function level_unlock_award_manager:InitByNewConfig(groupID)
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local isNewbieABTest = logic_newbie_new_abtest:CheckUseNewNewbieLogic()
  if not isNewbieABTest then
    log_warning(bWriteLog and "level_unlock_award_manager:InitByNewConfig. not in newbie ABTest")
    return
  end
  self:_InitByNewConfig(groupID)
end
function level_unlock_award_manager:GetLevelAwardList()
  local showData = {}
  for i, v in ipairs(self._levelAwardList) do
    showData[i] = self._levelToAward[v]
  end
  return showData
end
function level_unlock_award_manager:GetUnlockReward(level)
  local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
  if not logic_newbie_assist.CheckIsNewBie() then
    log_warning(bWriteLog and "level_unlock_manager:GetLevelToAward is not newbie")
    return nil
  end
  return self._levelToAward[level]
end
function level_unlock_award_manager:GetUnlockRewardList(level, oldLevel)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  oldLevel = oldLevel or level_unlock_manager:GetRecordedLevel()
  if not oldLevel then
    return {
      self._levelToAward[level]
    }
  end
  local startLevel = math.min(oldLevel + 1, level)
  local rewardList = {}
  for i = startLevel, level do
    if self._levelToAward[i] then
      table.insert(rewardList, self._levelToAward[i])
    end
  end
  return rewardList
end
function level_unlock_award_manager:GetNextBannerLink(currentLevel)
  for _, v in ipairs(self._bannerLinks) do
    local level = v.level
    local status = self._awardStatus[level]
    if status and status ~= EAwardStatus.AlreadyGet then
      return v.link, v.level
    end
  end
end
function level_unlock_award_manager:CheckHasActiveBanner(currentLevel)
  local link, _ = self:GetNextBannerLink(currentLevel)
  if link then
    return true
  end
  return false
end
function level_unlock_award_manager:GetAwardStatus()
  return self._awardStatus
end
function level_unlock_award_manager:_InitByOldConfig(unlockData)
  local unlockConfig = unlockData.cfg
  if not unlockConfig then
    log_warning(bWriteLog and "level_unlock_manager:InitByOldConfig unlockData.cfg is nil")
    return
  end
  for level, v in pairs(unlockConfig) do
    if v.itemid1 and v.itemid1 > 0 then
      local awardData = {
        id = v.itemid1,
        count = v.cnt1,
        validHour = v.valid_hours1,
              }
      self:_InitAwardConfig(level, awardData)
    end
    if not self._awardStatus[level] then
      self._awardStatus[level] = EAwardStatus.CantGet
    end
    local bannerLink = v.banner_link
    if bannerLink ~= "" then
      table.insert(self._bannerLinks, {level = level, link = bannerLink})
    end
  end
  table.sort(self._bannerLinks, function(a, b)
    return a.level < b.level
  end)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:SetHasInitLevelUnLockAward(true)
end
function level_unlock_award_manager:_InitByNewConfig(groupID)
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  groupID = groupID or logic_newbie_new_abtest:GetGroupID()
  log_format("level_unlock_award_manager:InitByNewConfig. groupID = [%s]", groupID)
  if not groupID then
    log_warning(bWriteLog and "level_unlock_award_manager:InitByNewConfig. newbie_new_info_notify not reach")
    return
  end
  local NewbieUpgradeConfig = CDataTable.GetTableByFilter("NewbieLevelLockConfig", "GroupId", groupID)
  for k, v in pairs(NewbieUpgradeConfig) do
    local level = v.Level
    if v.Reward1 and v.Reward1 > 0 then
      local awardData = {
        id = v.Reward1,
        count = v.Reward1Number,
        validHour = v.Reward1Time,
              }
      self:_InitAwardConfig(level, awardData)
    end
    if not self._awardStatus[level] then
      self._awardStatus[level] = EAwardStatus.CantGet
    end
    local bannerLink = v.BannerUrl
    if bannerLink ~= "" then
      table.insert(self._bannerLinks, {level = level, link = bannerLink})
    end
  end
  table.sort(self._bannerLinks, function(a, b)
    return a.level < b.level
  end)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:SetHasInitLevelUnLockAward(true)
end
function level_unlock_award_manager:_InitAwardConfig(level, awardConfig)
  self._levelToAward[tonumber(level)] = awardConfig
  self._levelAwardList[#self._levelAwardList + 1] = level
end
function level_unlock_award_manager:SendGetLevelUnLockAward(level)
  local levelReward = self:GetUnlockReward(level)
  if not levelReward then
    log(bWriteLog and "level_unlock_award_manager:SendGetLevelUnLockAward levelReward is nil. level = " .. tostring(level))
    return
  end
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local isNewbieABTest = logic_newbie_new_abtest:CheckUseNewNewbieLogic()
  if isNewbieABTest then
    local NewbieNewLogicHandle = require("client.network.Protocol.NewbieNewLogicHandle")
    NewbieNewLogicHandle.send_newbie_upgrade_reward_req(DataMgr.roleData.level)
    return
  end
  local newbieGuideHandler = require("client.network.Protocol.NewbieGuideHandler")
  newbieGuideHandler.send_newbie_level_unlock_get_reward_req(DataMgr.roleData.level)
end
function level_unlock_award_manager:on_newbie_activity_init(newbie_level_unlock)
  log_tree("level_unlock_award_manager:on_newbie_activity_init. newbie_level_unlock = ", newbie_level_unlock)
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local isNewbieABTest = logic_newbie_new_abtest:CheckUseNewNewbieLogic()
  if isNewbieABTest then
    log_warning(bWriteLog and "level_unlock_award_manager:on_newbie_activity_init. isNewbieABTest")
    return
  end
  if newbie_level_unlock then
    self._awardStatus = newbie_level_unlock.status
    EventSystem:postEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_DATA)
  end
end
function level_unlock_award_manager:on_newbie_level_unlock_get_reward_rsp(reward_level)
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local isNewbieABTest = logic_newbie_new_abtest:CheckUseNewNewbieLogic()
  if isNewbieABTest then
    log_warning(bWriteLog and "level_unlock_award_manager:on_newbie_level_unlock_get_reward_rsp. isNewbieABTest")
    return
  end
  local award = self._levelToAward[reward_level]
  if self._awardStatus then
    self._awardStatus[reward_level] = EAwardStatus.AlreadyGet
  end
  local newbie_guide_util = require("client.slua.logic.growth_project.newbie_guide_util")
  if newbie_guide_util.IsInNewbieForceRankABTest() then
    local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
    local unlockLevel = level_unlock_manager:GetUnlockLevel(level_unlock_manager.featureDef.matchMode)
    if DataMgr.roleData.level == unlockLevel then
      log(bWriteLog and "level_unlock_award_manager:on_newbie_level_unlock_get_reward_rsp is in newbie force rank abtest and current level is match mode unlock level. not show")
      return
    end
  end
  if award then
    local items = {}
    local item = {
      res_id = award.id,
      count = award.count,
      valid_hours = award.validHour
    }
    table.insert(items, item)
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(items)
  end
end
function level_unlock_award_manager:on_newbie_activity_sync_status(level_unlock_status)
  log(bWriteLog and "level_unlock_award_manager:on_newbie_activity_sync_status")
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local isNewbieABTest = logic_newbie_new_abtest:CheckUseNewNewbieLogic()
  if isNewbieABTest then
    log_warning(bWriteLog and "level_unlock_award_manager:on_newbie_activity_sync_status. isNewbieABTest")
    return
  end
  if level_unlock_status and self._awardStatus then
    for key, value in pairs(level_unlock_status) do
      self._awardStatus[key] = value
    end
  end
  EventSystem:postEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_DATA)
end
function level_unlock_award_manager:on_newbie_new_info_notify(upgrade_awards)
  log_tree("level_unlock_award_manager:on_newbie_new_info_notify. upgrade_awards = ", upgrade_awards)
  if not upgrade_awards then
    return
  end
  for level, isGet in pairs(upgrade_awards) do
    self._awardStatus[level] = isGet and EAwardStatus.AlreadyGet or EAwardStatus.CantGet
  end
  EventSystem:postEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_DATA)
end
function level_unlock_award_manager:on_newbie_upgrade_reward_rsp(level)
  if self._awardStatus then
    self._awardStatus[level] = EAwardStatus.AlreadyGet
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clevel_unlock_award_manager = class(CModuleBase, nil, level_unlock_award_manager)
return Clevel_unlock_award_manager