local logic_home_anniversary_activity = {}
local TimeUtil = require("client.common.time_util")
local home_anniversary_macros = require("client.slua.logic.home.Activity.Anniversary.home_anniversary_macros")
function logic_home_anniversary_activity:DefineAndResetData()
  self.cachedJointSplitReturnItemCfg = nil
  self.bShowLevelRewardReddot = nil
  self.nextExtraID = nil
  self.extra_reward = nil
end
function logic_home_anniversary_activity:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_HOME_ANNIVERSARY_MAIN, self.OnJumpMainUI, self)
end
function logic_home_anniversary_activity:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_home_anniversary_activity:OnPreSwitchGameStatus pre = " .. tostring(preState) .. ", nextState = " .. tostring(nextState))
  if nextState == GameStatus.Lobby then
    self.bNeedPopupNormalUpgrade = false
  end
end
function logic_home_anniversary_activity:IsActivityOpen()
  local PlanPH_AnniversaryActivity = CDataTable.GetTableData("PlanPH_AnniversaryActivity", 2)
  if not PlanPH_AnniversaryActivity then
    log(bWriteLog and "logic_home_anniversary_activity:IsActivityOpen not PlanPH_AnniversaryActivity")
    return false
  end
  local StringUtil = require("common.string_util")
  local appIDList = StringUtil.Split(PlanPH_AnniversaryActivity.APPIDs, "|")
  local gameId = Client.GetITopGameId()
  local bAppMatch = false
  for _, appID in ipairs(appIDList) do
    if gameId == appID then
      bAppMatch = true
      break
    end
  end
  if not bAppMatch then
    log(bWriteLog and "logic_home_anniversary_activity:IsActivityOpen not bAppMatch")
    return false
  end
  local curTime = TimeUtil.GetServerTimeInSec()
  local actStartTime = TimeUtil.TimeStringToUnixstamp(PlanPH_AnniversaryActivity.StartTime)
  local actEndTime = TimeUtil.TimeStringToUnixstamp(PlanPH_AnniversaryActivity.EndTime)
  if curTime >= actStartTime and curTime < actEndTime then
    return true
  end
  log(bWriteLog and "logic_home_anniversary_activity:IsActivityOpen not in time curTime = " .. tostring(curTime) .. ", actStartTime = " .. tostring(actStartTime) .. ", actEndTime = " .. tostring(actEndTime))
  return false
end
function logic_home_anniversary_activity:NeedShowTips()
  log(bWriteLog and "logic_home_anniversary_activity:NeedShowTips")
  if not self:IsActivityOpen() then
    log(bWriteLog and "logic_home_anniversary_activity:NeedShowTips not in time")
    return false
  end
  if self:CheckShowEntryTips() then
    log(bWriteLog and "logic_home_anniversary_activity:NeedShowTips show entry tips")
    return true
  end
  return false
end
function logic_home_anniversary_activity:NeedShowReddot()
  log(bWriteLog and "logic_home_anniversary_activity:NeedShowReddot")
  if not self:IsActivityOpen() then
    log(bWriteLog and "logic_home_anniversary_activity:NeedShowReddot not in time")
    return false
  end
  if self:CheckShowFirstReddot() then
    log(bWriteLog and "logic_home_anniversary_activity:NeedShowReddot show first reddot")
    return true
  end
  if self:CheckShowEntenReward() then
    log(bWriteLog and "logic_home_anniversary_activity:NeedShowReddot show enter reddot")
    return true
  end
  if self.bShowLevelRewardReddot then
    log(bWriteLog and "logic_home_anniversary_activity:NeedShowReddot show level reddot")
    return true
  end
  if self:CheckShowUpgradeReddot() then
    log(bWriteLog and "logic_home_anniversary_activity:NeedShowReddot show upgrade reddot")
    return true
  end
  if self:CheckShowSignReddot() then
    log(bWriteLog and "logic_home_anniversary_activity:NeedShowReddot show login reddot")
    return true
  end
  log(bWriteLog and "logic_home_anniversary_activity:NeedShowReddot return false")
  return false
end
function logic_home_anniversary_activity:CheckShowLevelTabReddot()
  log(bWriteLog and "logic_home_anniversary_activity:CheckShowLevelTabReddot")
  if self.bShowLevelRewardReddot then
    log(bWriteLog and "logic_home_anniversary_activity:CheckShowLevelTabReddot show level reddot")
    return true
  end
  if self:CheckShowUpgradeReddot() then
    log(bWriteLog and "logic_home_anniversary_activity:CheckShowLevelTabReddot show upgrade reddot")
    return true
  end
  return false
end
function logic_home_anniversary_activity:CheckNeedShowNormalPopup()
  if not self:IsActivityOpen() then
    log(bWriteLog and "logic_home_anniversary_activity:CheckNeedShowNormalPopup not in time")
    return false
  end
  log(bWriteLog and "logic_home_anniversary_activity:CheckNeedShowNormalPopup self.bNeedPopupNormalUpgrade = " .. tostring(self.bNeedPopupNormalUpgrade))
  return self.bNeedPopupNormalUpgrade
end
function logic_home_anniversary_activity:CheckShowEntryTips()
  log(bWriteLog and "logic_home_anniversary_activity:CheckShowEntryTips")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeAnniversaryTips) or {}
  if cfg.bHasShowEntryTips then
    log(bWriteLog and "logic_home_anniversary_activity:CheckShowEntryTips has showed tips")
    return false
  end
  log(bWriteLog and "logic_home_anniversary_activity:CheckShowEntryTips return true")
  return true
end
function logic_home_anniversary_activity:CheckShowFirstReddot()
  log(bWriteLog and "logic_home_anniversary_activity:CheckShowFirstReddot")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeSecondAnniversaryReddot) or {}
  if cfg.bHasOpenActivity then
    log(bWriteLog and "logic_home_anniversary_activity:CheckShowFirstReddot has open")
    return false
  end
  log(bWriteLog and "logic_home_anniversary_activity:CheckShowFirstReddot return true")
  return true
end
function logic_home_anniversary_activity:CheckShowSignReddot()
  log(bWriteLog and "logic_home_anniversary_activity:CheckShowSignReddot")
  if not self.act_data or not self.act_data.login_days then
    log(bWriteLog and "logic_home_anniversary_activity:CheckShowSignReddot not act_data")
    return false
  end
  local take_records = self.act_data.take_records or {}
  for i = 1, self.act_data.login_days do
    if not take_records[i] then
      log(bWriteLog and "logic_home_anniversary_activity:CheckShowSignReddot show reddot for day " .. tostring(i))
      return true
    end
  end
  return false
end
function logic_home_anniversary_activity:CheckShowEntenReward()
  return false
end
function logic_home_anniversary_activity:IsVersionRewardFinished()
  log(bWriteLog and "logic_home_anniversary_activity:IsVersionRewardFinished")
  local manor_visit_info = LobbySystem.roleData.manor_visit_info
  if manor_visit_info and manor_visit_info.award_time then
    log(bWriteLog and "logic_home_anniversary_activity:IsVersionRewardFinished return true")
    return true
  end
  log(bWriteLog and "logic_home_anniversary_activity:IsVersionRewardFinished return false")
  return false
end
function logic_home_anniversary_activity:IsHomeNewbieFinished()
  local logic_home_newbieguide = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_newbieguide)
  local bFinishedNewbie = logic_home_newbieguide:IsFinishNewbieGuideTask()
  log(bWriteLog and "logic_home_anniversary_activity:IsHomeNewbieFinished bFinishedNewbie = " .. tostring(bFinishedNewbie))
  return bFinishedNewbie
end
function logic_home_anniversary_activity:CheckShowUpgradeReddot()
  log(bWriteLog and "logic_home_anniversary_activity:CheckShowUpgradeReddot")
  local logic_home_newbieguide = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_newbieguide)
  local bFinishedNewbie = logic_home_newbieguide:IsFinishNewbieGuideTask()
  if not bFinishedNewbie then
    log(bWriteLog and "logic_home_anniversary_activity:CheckShowUpgradeReddot not bFinishedNewbie")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeSecondAnniversaryReddot) or {}
  if cfg.bHasOpenActivity and cfg.bExistUpgrade then
    log(bWriteLog and "logic_home_anniversary_activity:CheckShowUpgradeReddot has showed")
    return false
  end
  if self:CheckCanSmartUpgrade() then
    return true
  else
    return self:CheckCanNormalUpgrade()
  end
end
function logic_home_anniversary_activity:CheckCanSmartUpgrade()
  log(bWriteLog and "logic_home_anniversary_activity:CheckCanSmartUpgrade")
  local info = self:GetSmartUpgradeInfo()
  if not next(info) then
    return false
  end
  return info.curLevel < info.targetLevel
end
function logic_home_anniversary_activity:GetSmartUpgradeInfo()
  log(bWriteLog and "logic_home_anniversary_activity:GetSmartUpgradeInfo")
  local logic_home_newbieguide = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_newbieguide)
  local bFinishedNewbie = logic_home_newbieguide:IsFinishNewbieGuideTask()
  if not bFinishedNewbie then
    log(bWriteLog and "logic_home_anniversary_activity:GetSmartUpgradeInfo not bFinishedNewbie")
    return {}
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  if logic_home_joint:HasJointHome() then
    log(bWriteLog and "logic_home_anniversary_activity:GetSmartUpgradeInfo is joint home")
    return {}
  end
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  local homeProfile = logic_home_profile:GetHomeProfileByUid(DataMgr.roleData.uid)
  if not homeProfile then
    log(bWriteLog and "logic_home_anniversary_activity:GetSmartUpgradeInfo not homeProfile")
    return {}
  end
  local growInfo = homeProfile.grow_info
  if not growInfo then
    log(bWriteLog and "logic_home_anniversary_activity:GetSmartUpgradeInfo not growInfo")
    return {}
  end
  local scene_prosperity = growInfo.scene_prosperity or 0
  local depot_prosperity = growInfo.depot_prosperity or 0
  local curLevel = growInfo.level or 0
  log(bWriteLog and "logic_home_anniversary_activity:GetSmartUpgradeInfo curLevel = " .. tostring(curLevel))
  local config_home_level = require("client.slua.logic.home.level.config.config_home_level")
  if curLevel >= config_home_level.C_MaxSmartUpgradeLevel then
    log(bWriteLog and "logic_home_anniversary_activity:GetSmartUpgradeInfo curLevel >= C_MaxSmartUpgradeLevel")
    return {}
  end
  local totalProsperity = scene_prosperity + depot_prosperity
  local canUpgradeTo = curLevel
  local prosperityOffset = 0
  for level = curLevel + 1, config_home_level.C_MaxSmartUpgradeLevel do
    local levelUpCfg = CDataTable.GetTableData("PlanPH_LevelUpCfg", level)
    if totalProsperity >= levelUpCfg.Condition1Value then
      canUpgradeTo = level
    else
      prosperityOffset = levelUpCfg.Condition1Value - totalProsperity
      break
    end
  end
  local info = {
    curLevel = curLevel,
    targetLevel = canUpgradeTo,
    prosperityOffset = prosperityOffset,
      }
  log_tree("logic_home_anniversary_activity:GetSmartUpgradeInfo info", info)
  return info
end
function logic_home_anniversary_activity:CheckCanNormalUpgrade()
  log(bWriteLog and "logic_home_anniversary_activity:CheckCanNormalUpgrade")
  local info = self:GetNormalUpgradeInfo()
  if not next(info) then
    return false
  end
  return info.curLevel < info.targetLevel
end
function logic_home_anniversary_activity:GetNormalUpgradeInfo()
  log(bWriteLog and "logic_home_anniversary_activity:GetNormalUpgradeInfo")
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  local homeProfile = logic_home_profile:GetHomeProfileByUid(DataMgr.roleData.uid)
  if not homeProfile then
    log(bWriteLog and "logic_home_anniversary_activity:GetNormalUpgradeInfo not homeProfile")
    return {}
  end
  local growInfo = homeProfile.grow_info
  if not growInfo then
    log(bWriteLog and "logic_home_anniversary_activity:GetNormalUpgradeInfo not growInfo")
    return {}
  end
  local scene_prosperity = growInfo.scene_prosperity or 0
  local curLevel = growInfo.level or 0
  local canUpgradeTo = curLevel
  local prosperityOffset
  local levelUpCfg = CDataTable.GetTableData("PlanPH_LevelUpCfg", curLevel + 1)
  if not levelUpCfg then
    prosperityOffset = -1
  elseif scene_prosperity >= levelUpCfg.Condition1Value then
    canUpgradeTo = curLevel + 1
    prosperityOffset = 0
  else
    prosperityOffset = levelUpCfg.Condition1Value - scene_prosperity
  end
  local info = {
    curLevel = curLevel,
    targetLevel = canUpgradeTo,
      }
  log_tree("logic_home_anniversary_activity:GetNormalUpgradeInfo info", info)
  return info
end
function logic_home_anniversary_activity:GetLevelUnlockList(fromLevel, toLevel)
  log(bWriteLog and "logic_home_anniversary_activity:GetLevelUnlockList fromLevel = " .. tostring(fromLevel) .. ", toLevel = " .. tostring(toLevel))
  if toLevel == fromLevel then
    toLevel = fromLevel + 1
  end
  local logic_home_smart_upgrade = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_smart_upgrade)
  local rightList = {}
  for level = fromLevel + 1, toLevel do
    local curRights = logic_home_smart_upgrade:GetAuthorityCfg(level)
    for _, v in ipairs(curRights) do
      rightList[#rightList + 1] = v
      v.    end
  end
  log_tree("logic_home_anniversary_activity:GetLevelUnlockList rightList = ", rightList)
  return rightList
end
function logic_home_anniversary_activity:GetSplitReturnItemCfg()
  if self.cachedJointSplitReturnItemCfg then
    return self.cachedJointSplitReturnItemCfg
  end
  local cfg = CDataTable.GetTableData("PlanPH_LevelUpParamsCfg", "SplitJointReturnItems")
  local StringUtil = require("common.string_util")
  self.cachedJointSplitReturnItemCfg = StringUtil.SplitToNum(cfg.Value, "|")
  return self.cachedJointSplitReturnItemCfg
end
function logic_home_anniversary_activity:GetRewardsCfg(level, historyLevel)
  log(bWriteLog and "logic_home_anniversary_activity:GetRewardsCfg level = " .. tostring(level) .. ", historyLevel = " .. tostring(historyLevel))
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local manorLevelTableData = BasicDataServerTable:GetCacheData(data_config_marco.manor_level_table_for_client)
  if not manorLevelTableData then
    log(bWriteLog and "logic_home_anniversary_activity:GetRewardsCfg not manorLevelTableData")
    return {}
  end
  local bSkipGotItem = false
  historyLevel = historyLevel or 0
  if level <= historyLevel then
    bSkipGotItem = true
  end
  local currLevelCfg = manorLevelTableData[level]
  log_tree("logic_home_anniversary_activity:GetRewardsCfg currLevelCfg = ", currLevelCfg)
  if currLevelCfg and currLevelCfg.award_array and next(currLevelCfg.award_array) then
    if bSkipGotItem then
      local splitReturnItemCfg = self:GetSplitReturnItemCfg()
      local result = {}
      local table_util = require("common.table_util")
      for _, v in pairs(currLevelCfg.award_array) do
        if table_util.IsInTable(splitReturnItemCfg, v.resid) then
          result[#result + 1] = v
        end
      end
      log_tree("logic_home_anniversary_activity:GetRewardsCfg should skip got item, result = ", result)
      return result
    else
      return currLevelCfg.award_array
    end
  end
  return {}
end
function logic_home_anniversary_activity:GetLevelRewardList(fromLevel, toLevel)
  if toLevel == fromLevel then
    toLevel = fromLevel + 1
  end
  local historyLevel = 0
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  local homeProfile = logic_home_profile:GetHomeProfileByUid(DataMgr.roleData.uid, false)
  if homeProfile and homeProfile.grow_info then
    historyLevel = homeProfile.grow_info.his_max_manor_level or 0
  end
  log(bWriteLog and "logic_home_anniversary_activity:GetLevelRewardList historyLevel = " .. tostring(historyLevel))
  local rewardList = {}
  for level = fromLevel + 1, toLevel do
    local curReward = self:GetRewardsCfg(level, historyLevel)
    for _, v in ipairs(curReward) do
      rewardList[#rewardList + 1] = v
      v.    end
  end
  log_tree("logic_home_anniversary_activity:GetLevelRewardList rewardList = ", rewardList)
  return rewardList
end
function logic_home_anniversary_activity:GetExtraRewardInfo()
  return self.extra_reward
end
function logic_home_anniversary_activity:GetCurrentActID()
  if not self.act_data or not self.act_data.act_id then
    log(bWriteLog and "logic_home_anniversary_activity:GetCurrentActID not act_data")
    return nil
  end
  return self.act_data.act_id
end
function logic_home_anniversary_activity:GetDailyRewardStatus(day)
  if not self.act_data or not self.act_data.login_days then
    return home_anniversary_macros.ENUM_ANNIVERSARY_REWARD_STUTAS.NoFinish
  end
  if day > self.act_data.login_days then
    return home_anniversary_macros.ENUM_ANNIVERSARY_REWARD_STUTAS.NoFinish
  end
  if self.act_data.take_records[day] then
    return home_anniversary_macros.ENUM_ANNIVERSARY_REWARD_STUTAS.HasGotReward
  end
  return home_anniversary_macros.ENUM_ANNIVERSARY_REWARD_STUTAS.CanTakeReward
end
function logic_home_anniversary_activity:GetDiscountShopList()
  if not self.discount_shop then
    log(bWriteLog and "logic_home_anniversary_activity:GetDiscountShopList not discount_shop")
    return {}
  end
  return self.discount_shop.shop_list or {}
end
function logic_home_anniversary_activity:GetNextRefreshTime()
  if not self.discount_shop then
    log(bWriteLog and "logic_home_anniversary_activity:GetNextRefreshTime not discount_shop")
    return 0
  end
  return self.discount_shop.next_refresh_time or 0
end
function logic_home_anniversary_activity:GetDiscountInfo(good_id)
  if not self.discount_shop or not self.discount_shop.shop_list then
    log(bWriteLog and "logic_home_anniversary_activity:GetDiscountInfo not shop_list")
    return 0, 0, 0
  end
  for _, v in pairs(self.discount_shop.shop_list) do
    if v.good_id == good_id then
      return v.discount or 0, v.is_lucky or 0, v.avail_cnt or 0
    end
  end
  log(bWriteLog and "logic_home_anniversary_activity:GetDiscountInfo not good_id = " .. tostring(good_id))
  return 0, 0, 0
end
function logic_home_anniversary_activity:GetDiscountNextRefreshTime()
  if not self.discount_shop then
    log(bWriteLog and "logic_home_anniversary_activity:GetDiscountNextRefreshTime not discount_shop")
    return 0
  end
  return self.discount_shop.next_refresh_time or 0
end
function logic_home_anniversary_activity:PopupEnterHome(bIsUpgrade)
  log(bWriteLog and "logic_home_anniversary_activity:PopupEnterHome bIsUpgrade = " .. tostring(bIsUpgrade))
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if logic_home_switch:CheckHomeLimit(true) then
    log(bWriteLog and "logic_home_anniversary_activity:PopupEnterHome limit")
    return
  end
  local titleStr = LocUtil.GetLocalizeResStr(102012)
  local contentStr
  if bIsUpgrade then
    contentStr = LocUtil.GetLocalizeResStr(75165)
  else
    contentStr = LocUtil.GetLocalizeResStr(75164)
  end
  local clickOkCallback = function()
    local gotoFunc = function()
      log(bWriteLog and "logic_home_anniversary_activity:PopupEnterHome gotoFunc")
      if bIsUpgrade and self:CheckCanSmartUpgrade() then
        log(bWriteLog and "logic_home_anniversary_activity:PopupEnterHome set shouldShowSmartUpgradeAfterEnterGame = true")
        local logic_home_smart_upgrade = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_smart_upgrade)
        logic_home_smart_upgrade.shouldShowSmartUpgradeAfterEnterGame = true
      elseif bIsUpgrade then
        self:MarkNormalUpgradePopup(true)
      end
      local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
      logic_home_entry:EntryVisitHome(DataMgr.roleData.uid)
    end
    local logic_home_download = require("client.slua.logic.home.Download.logic_home_download")
    logic_home_download.CheckHomeDownloadedDone(DataMgr.roleData.uid, gotoFunc)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, titleStr, contentStr, clickOkCallback)
end
function logic_home_anniversary_activity:MarkNormalUpgradePopup(bNeedPopup)
  self.bNeedPopupNormalUpgrade = bNeedPopup
end
function logic_home_anniversary_activity:OnJumpMainUI()
  log(bWriteLog and "logic_home_anniversary_activity:OnJumpMainUI")
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if logic_home_switch:CheckHomeLimit(true) or not logic_home_switch:CheckHomeSwitchOpen(true) then
    log(bWriteLog and "logic_home_anniversary_activity:OnJumpMainUI limit")
    return
  end
  if self:IsActivityOpen() then
    if not UIManager.IsUIShow(UIManager.UI_Config.Home_Collection_AnniversaryMain_UIBP) then
      UIManager.ShowUI(UIManager.UI_Config.Home_Collection_AnniversaryMain_UIBP)
    end
  else
    ShowNotice(108108)
  end
end
function logic_home_anniversary_activity:proc_notify_manor_level_extra_reward(extra_id)
  log(bWriteLog and "logic_home_anniversary_activity:proc_notify_manor_level_extra_reward extra_id = " .. tostring(extra_id))
  self.nextExtraID = extra_id
  self.bShowLevelRewardReddot = true
  EventSystem:postEvent(EVENTTYPE_PLANPH_ANNIVERSARY, EVENTID_PLANPH_ANNIVERSARY_REDDOT_UPDATE)
end
function logic_home_anniversary_activity:proc_take_manor_level_extra_reward_rsp(extra_id)
  log(bWriteLog and "logic_home_anniversary_activity:proc_take_manor_level_extra_reward_rsp extra_id = " .. tostring(extra_id))
  if not self.nextExtraID or extra_id >= self.nextExtraID then
    self.nextExtraID = nil
    self.bShowLevelRewardReddot = false
    EventSystem:postEvent(EVENTTYPE_PLANPH_ANNIVERSARY, EVENTID_PLANPH_ANNIVERSARY_REDDOT_UPDATE)
  end
end
function logic_home_anniversary_activity:proc_manor_extra_reward_notify(level_extra_reward)
  self.bShowLevelRewardReddot = level_extra_reward
  EventSystem:postEvent(EVENTTYPE_PLANPH_ANNIVERSARY, EVENTID_PLANPH_ANNIVERSARY_REDDOT_UPDATE)
end
function logic_home_anniversary_activity:proc_check_manor_extra_rewards_rsp(extra_reward)
  self.  EventSystem:postEvent(EVENTTYPE_PLANPH_ANNIVERSARY, EVENTID_PLANPH_ANNIVERSARY_REWARD_STATUS_RSP)
end
function logic_home_anniversary_activity:proc_anniversary_login_act_info_rsp(act_data)
  self.  EventSystem:postEvent(EVENTTYPE_PLANPH_ANNIVERSARY, EVENTID_PLANPH_ANNIVERSARY_LOGIN_ACT_INFO_RSP)
end
function logic_home_anniversary_activity:proc_anniversary_login_act_reward_notify(act_data)
  self.  EventSystem:postEvent(EVENTTYPE_PLANPH_ANNIVERSARY, EVENTID_PLANPH_ANNIVERSARY_REDDOT_UPDATE)
  EventSystem:postEvent(EVENTTYPE_PLANPH_ANNIVERSARY, EVENTID_PLANPH_ANNIVERSARY_LOGIN_REWARD_STATUS_UPDATE)
end
function logic_home_anniversary_activity:proc_anniversary_login_act_take_rsp(act_id, day, award_list)
  self.act_data = self.act_data or {}
  self.act_data.take_records = self.act_data.take_records or {}
  self.act_data.take_records[day] = true
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(award_list)
  EventSystem:postEvent(EVENTTYPE_PLANPH_ANNIVERSARY, EVENTID_PLANPH_ANNIVERSARY_REDDOT_UPDATE)
  EventSystem:postEvent(EVENTTYPE_PLANPH_ANNIVERSARY, EVENTID_PLANPH_ANNIVERSARY_LOGIN_REWARD_STATUS_UPDATE)
end
function logic_home_anniversary_activity:proc_manor_discount_shop_info_rsp(discount_shop)
  self.  EventSystem:postEvent(EVENTTYPE_PLANPH_ANNIVERSARY, EVENTID_PLANPH_ANNIVERSARY_DISCOUNT_SHOP_INFO_RSP)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_home_anniversary_activity = class(CModuleBase, nil, logic_home_anniversary_activity)
return Clogic_home_anniversary_activity