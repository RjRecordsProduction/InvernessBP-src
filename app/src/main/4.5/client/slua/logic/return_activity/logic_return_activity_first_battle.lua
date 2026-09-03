local logic_return_activity_first_battle = {}
local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
local CommonItem_Const = require("client.slua.component.item.ItemUtils.CommonItem_Const")
function logic_return_activity_first_battle:DefineAndResetData()
  self.modeOrder = {
    return_activity_macro.Enum_FB_Mode_Type.Classic,
    return_activity_macro.Enum_FB_Mode_Type.TeamCompetition,
    return_activity_macro.Enum_FB_Mode_Type.WOW,
    return_activity_macro.Enum_FB_Mode_Type.Xmission
  }
  self.modeConfig = {
    [return_activity_macro.Enum_FB_Mode_Type.Classic] = {
      title = "",
      jumpFunc = function()
        GlobalData.JumpUrl("game://?module=1008403&menuList=100")
      end
    },
    [return_activity_macro.Enum_FB_Mode_Type.TeamCompetition] = {
      title = "",
      jumpFunc = function()
        GlobalData.JumpUrl("game://?module=1008403&menuList=220|200")
      end
    },
    [return_activity_macro.Enum_FB_Mode_Type.WOW] = {
      title = "",
      jumpFunc = function()
        GlobalData.JumpUrl("game://?module=1008403&menuList=900")
      end
    },
    [return_activity_macro.Enum_FB_Mode_Type.Xmission] = {
      title = "",
      jumpFunc = function()
        GlobalData.JumpUrl("game://?module=1009912")
      end
    }
  }
  self.gmModID = nil
end
function logic_return_activity_first_battle:GMSetModID(modID)
  self.gmModID = modID
  log(bWriteLog and string.format("logic_return_activity_first_battle:GMSetModID, modID=%s", tostring(modID)))
end
function logic_return_activity_first_battle:GMGetModID()
  return self.gmModID
end
function logic_return_activity_first_battle:_GetConfig()
  local userData = DataMgr.roleData and DataMgr.roleData.back_user_data
  if userData then
    return userData.mode_first_battle_cfg
  end
  return nil
end
function logic_return_activity_first_battle:_GetModeRewardStatus()
  local userData = DataMgr.roleData and DataMgr.roleData.back_user_data
  if userData then
    return userData.mode_first_battle_info or {}
  end
  return {}
end
function logic_return_activity_first_battle:_OnMatchSuccess()
  local userData = DataMgr.roleData and DataMgr.roleData.back_user_data
  if not userData then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerMatchSuccess) or {}
  if not saveData[DataMgr.roleData.back_user_data.rejoin_start_time] then
    saveData[DataMgr.roleData.back_user_data.rejoin_start_time] = true
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerMatchSuccess)
  end
end
function logic_return_activity_first_battle:OnInitialize()
end
function logic_return_activity_first_battle:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_SUCCESS, self._OnMatchSuccess, self)
end
function logic_return_activity_first_battle:OnLogin(bReLogin)
end
function logic_return_activity_first_battle:OnLogOut()
end
function logic_return_activity_first_battle:OnPreSwitchGameStatus(preState, nextState)
end
function logic_return_activity_first_battle:OnPostSwitchGameStatus(preState, nextState)
end
function logic_return_activity_first_battle:GetModeIntroductionList()
  local version_util = require("client.common.version_util")
  local appVersion = Client.GetAppVersion()
  if not appVersion then
    return nil
  end
  local CurrentMainVersion = version_util.GetMainFormat(appVersion)
  local backUserData = DataMgr.roleData and DataMgr.roleData.back_user_data
  if not backUserData then
    return nil
  end
  local lastLoginVersion = backUserData.last_cli_sub_ver or CurrentMainVersion
  local versionCfg = CDataTable.GetTable("ReturnVersionConfig")
  if not versionCfg then
    return nil
  end
  local configID = 1
  local serverABTestID = DataMgr.roleData.back_user_data.playcard_ugc_abtest_group or 0
  local currentABTestID = serverABTestID == 0 and 1001 or serverABTestID
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local BuildInfoCardDataList = function(cfgRow)
    local cardTypes = {
      cfgRow.InfoCard1Type,
      cfgRow.InfoCard2Type,
      cfgRow.InfoCard3Type
    }
    local cardIDs = {
      cfgRow.InfoCard1ID,
      cfgRow.InfoCard2ID,
      cfgRow.InfoCard3ID
    }
    local dataList = {}
    for i = 1, 3 do
      local cardType = cardTypes[i]
      if not cardType or cardType == 0 then
        cardType = i
      end
      local tableName = "ReturnVersionInfoCardConfig" .. cardType
      local cardData = CDataTable.GetTableData(tableName, cardIDs[i])
      if not cardData then
        log_error_format("logic_return_activity_first_battle:GetModeIntroductionList InfoCard config not found, index:%s, table:%s, ID:%s", tostring(i), tableName, tostring(cardIDs[i]))
      end
      dataList[i] = cardData
    end
    return dataList
  end
  local genericConfigID, genericConfigRow
  for k, v in pairs(versionCfg) do
    local timeMatch = true
    local hasStart = v.StartTime and v.StartTime ~= ""
    local hasEnd = v.EndTime and v.EndTime ~= ""
    if hasStart or hasEnd then
      local nStartTime = hasStart and TimeUtil.TimeStringToUnixstamp(v.StartTime) or 0
      local nEndTime = hasEnd and TimeUtil.TimeStringToUnixstamp(v.EndTime) or 0
      if hasStart and 0 < nStartTime and nowTime < nStartTime then
        timeMatch = false
      elseif hasEnd and 0 < nEndTime and nowTime > nEndTime then
        timeMatch = false
      end
      log(bWriteLog and string.format("logic_return_activity_first_battle:GetModeIntroductionList time check, k:%s, StartTime:%s, EndTime:%s, nStartTime:%s, nEndTime:%s, nowTime:%s, timeMatch:%s", tostring(k), tostring(v.StartTime), tostring(v.EndTime), tostring(nStartTime), tostring(nEndTime), tostring(nowTime), tostring(timeMatch)))
    end
    local versionMatch = timeMatch and 0 <= version_util.CompareVersionMain(v.CurrentVersion, CurrentMainVersion) and lastLoginVersion >= v.VersionMin and lastLoginVersion < v.VersionMax
    if versionMatch then
      local isGeneric = not v.ABTESTID or v.ABTESTID == 0
      local isExactMatch = v.ABTESTID and v.ABTESTID == currentABTestID
      if isExactMatch then
        configID = k
        log(bWriteLog and string.format("logic_return_activity_first_battle:GetModeIntroductionList, configID:%s (exact ABTest match)", tostring(configID)))
        local dataList = BuildInfoCardDataList(v)
        if self.gmModID and self.gmModID ~= 0 then
          for k, v in ipairs(dataList) do
            if v.MODID and v.MODID ~= 0 then
              v.MODID = self.gmModID
            end
          end
        end
        return dataList
      elseif isGeneric and not genericConfigID then
        genericConfigID = k
        genericConfigRow = v
      end
    end
  end
  if genericConfigID and genericConfigRow then
    configID = genericConfigID
    log(bWriteLog and string.format("logic_return_activity_first_battle:GetModeIntroductionList, configID:%s (generic config)", tostring(configID)))
    local dataList = BuildInfoCardDataList(genericConfigRow)
    return dataList
  end
  log(bWriteLog and "logic_return_activity_first_battle:GetModeIntroductionList no config matched (version/abtest/time window all missed)")
  return nil
end
function logic_return_activity_first_battle:GetRewardStatus()
  return self:_GetModeRewardStatus()
end
function logic_return_activity_first_battle:GetRewardConfig()
  return self:_GetConfig()
end
function logic_return_activity_first_battle:IsShowEntry()
  return self:_GetConfig() ~= nil
end
function logic_return_activity_first_battle:IsShowMatchTips()
  if not self:IsShowEntry() then
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local matchMode = logic_mode_selection:GetCurSelectInfo()
  if not matchMode then
    return false
  end
  local history_combat_util = require("client.logic.combat.history.history_combat_util")
  if not history_combat_util.IsClassicRankMode(matchMode) then
    return false
  end
  local modeRewardStatus = self:_GetModeRewardStatus()
  if modeRewardStatus[return_activity_macro.Enum_FB_Mode_Type.Classic] == CommonItem_Const.Enum_ItemStatus.Not then
    return true
  end
  return false
end
function logic_return_activity_first_battle:GetLobbyFirstBattleGuideShowForNewEntry()
  local userData = DataMgr.roleData.back_user_data
  if not userData then
    log(bWriteLog and "logic_return_activity_first_battle:GetLobbyFirstBattleGuideShowForNewEntry is not backuser")
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bLevelUnlockSwitchOpen = level_unlock_util:IsSwitchOpen()
  if bLevelUnlockSwitchOpen then
    local menuInfo = logic_mode_selection:GetMenuInfo() or {}
    if next(menuInfo) and DataMgr.roleData.level < menuInfo.sub_menus[1].level_limit then
      log(bWriteLog and "logic_return_activity_first_battle:GetLobbyFirstBattleGuideShowForNewEntry is lock")
      return false
    end
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local judgeStr = GameStatus.IsInMainCity() and PlayerPrefsSystem.ePlayerPrefsType.ReturnPlayerFirstBattleGuideMainCity or PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerFirstBattleGuide
  local bIsDifferentDate = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(judgeStr, true)
  if not bIsDifferentDate then
    log(bWriteLog and "logic_return_activity_first_battle:GetLobbyFirstBattleGuideShowForNewEntry already shown today")
    return false
  end
  log(bWriteLog and "logic_return_activity_first_battle:GetLobbyFirstBattleGuideShowForNewEntry show guide")
  return true
end
function logic_return_activity_first_battle:IsShowMatchGuide()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if self:IsShowEntry() then
    if not self:GetLobbyFirstBattleGuideShowForNewEntry() then
      return false
    end
    local matchMode = logic_mode_selection:GetCurSelectInfo()
    local modeType
    local history_combat_util = require("client.logic.combat.history.history_combat_util")
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if matchMode then
      if history_combat_util.IsClassicRankMode(matchMode) or history_combat_util.IsMatchMode(matchMode) then
        modeType = return_activity_macro.Enum_FB_Mode_Type.Classic
      elseif history_combat_util.IsTeamMode(matchMode) then
        modeType = return_activity_macro.Enum_FB_Mode_Type.TeamCompetition
      elseif history_combat_util.IsUGCMatchMode(matchMode) then
        modeType = return_activity_macro.Enum_FB_Mode_Type.WOW
      elseif logic_mode_selection.hasSelectTxMission and UIManager.GetUI(UIManager.UI_Config.xmission_main) then
        modeType = return_activity_macro.Enum_FB_Mode_Type.Xmission
      end
    end
    if not modeType then
      return false
    end
    local hasOldRewardNotFinish = false
    local userData = DataMgr.roleData and DataMgr.roleData.back_user_data
    if userData and userData.daily_battle_data and userData.daily_battle_data.status == CommonItem_Const.Enum_ItemStatus.Not then
      hasOldRewardNotFinish = true
    end
    local hasNewRewardNotFinish = false
    local modeRewardStatus = self:_GetModeRewardStatus()
    if modeRewardStatus[modeType] == CommonItem_Const.Enum_ItemStatus.Not then
      hasNewRewardNotFinish = true
    end
    return hasOldRewardNotFinish or hasNewRewardNotFinish
  end
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  if not logic_return_activity:GetLobbyFirstBattleGuideShow() or logic_mode_selection.hasSelectTxMission then
    return false
  end
  return true
end
function logic_return_activity_first_battle:GetDailyFirstWinBonusScore()
  log(bWriteLog and "logic_return_activity_first_battle:GetDailyFirstWinBonusScore")
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local privilegeInfo = logic_player_return.privilege_info
  if not (privilegeInfo and privilegeInfo.progress) or not privilegeInfo.base_cfg then
    log(bWriteLog and "logic_return_activity_first_battle:GetDailyFirstWinBonusScore - privilege_info is nil")
    return nil
  end
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  local privilegeEndTime = logic_return_activity_utils.GetTimeLimitedPrivilegeEndTime()
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if privilegeEndTime <= nowTime then
    log(bWriteLog and "logic_return_activity_first_battle:GetDailyFirstWinBonusScore - Privilege expired")
    return nil
  end
  local firstWinConfig = privilegeInfo.base_cfg[3]
  if not firstWinConfig or not firstWinConfig.effect_para then
    log(bWriteLog and "logic_return_activity_first_battle:GetDailyFirstWinBonusScore - firstWinConfig not found")
    return nil
  end
  local bonusScore = firstWinConfig.effect_para
  log(bWriteLog and string.format("logic_return_activity_first_battle:GetDailyFirstWinBonusScore - bonusScore:%s", tostring(bonusScore)))
  return bonusScore
end
function logic_return_activity_first_battle:GetDailyFirstWinUsageCount()
  log(bWriteLog and "logic_return_activity_first_battle:GetDailyFirstWinUsageCount")
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local privilegeInfo = logic_player_return.privilege_info
  if not (privilegeInfo and privilegeInfo.progress) or not privilegeInfo.base_cfg then
    log(bWriteLog and "logic_return_activity_first_battle:GetDailyFirstWinUsageCount - privilege_info is nil")
    return 0, 0
  end
  local firstWinConfig = privilegeInfo.base_cfg[3]
  if not firstWinConfig then
    log(bWriteLog and "logic_return_activity_first_battle:GetDailyFirstWinUsageCount - firstWinConfig not found")
    return 0, 0
  end
  local totalCount = firstWinConfig.effect_times or 0
  local usedCount = 0
  if DataMgr.roleData and DataMgr.roleData.back_user_data then
    usedCount = DataMgr.roleData.back_user_data.back_user_day_win_score_cnt or 0
  end
  log(bWriteLog and string.format("logic_return_activity_first_battle:GetDailyFirstWinUsageCount - usedCount:%s, totalCount:%s", tostring(usedCount), tostring(totalCount)))
  return usedCount, totalCount
end
function logic_return_activity_first_battle:GetRankProtectionCount()
  log(bWriteLog and "logic_return_activity_first_battle:GetRankProtectionCount")
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local privilegeInfo = logic_player_return.privilege_info
  if not (privilegeInfo and privilegeInfo.progress) or not privilegeInfo.base_cfg then
    log(bWriteLog and "logic_return_activity_first_battle:GetRankProtectionCount - privilege_info is nil")
    return 0, 0
  end
  local protectConfig = privilegeInfo.base_cfg[2]
  if not protectConfig then
    log(bWriteLog and "logic_return_activity_first_battle:GetRankProtectionCount - protectConfig not found")
    return 0, 0
  end
  local totalCount = protectConfig.effect_para or 0
  local usedCount = privilegeInfo.progress.seg_protect_times or 0
  log(bWriteLog and string.format("logic_return_activity_first_battle:GetRankProtectionCount - usedCount:%s, totalCount:%s", tostring(usedCount), tostring(totalCount)))
  return usedCount, totalCount
end
function logic_return_activity_first_battle:JumpToTargetMode(modeType)
  log(bWriteLog and string.format("logic_return_activity_first_battle:JumpToTargetMode - modeType:%s", tostring(modeType)))
  local modeInfo = self.modeConfig[modeType]
  if not modeInfo then
    log(bWriteLog and string.format("logic_return_activity_first_battle:JumpToTargetMode - Invalid modeType:%s", tostring(modeType)))
    return
  end
  if not modeInfo.jumpFunc then
    log(bWriteLog and string.format("logic_return_activity_first_battle:JumpToTargetMode - jumpFunc not found for modeType:%s", tostring(modeType)))
    return
  end
  modeInfo.jumpFunc()
end
function logic_return_activity_first_battle:GetCurModeRewards()
  log(bWriteLog and "logic_return_activity_first_battle:GetCurModeRewards")
  local config = self:_GetConfig()
  if not config then
    log(bWriteLog and "logic_return_activity_first_battle:GetCurModeRewards - config is nil")
    return nil
  end
  local modeRewardStatus = self:_GetModeRewardStatus()
  for _, modeType in ipairs(self.modeOrder) do
    local status = modeRewardStatus[modeType]
    if status == CommonItem_Const.Enum_ItemStatus.Done then
      log(bWriteLog and string.format("logic_return_activity_first_battle:GetCurModeRewards - Found Done modeType:%s", tostring(modeType)))
      local modeConfig = config[modeType]
      if modeConfig and modeConfig.item_list then
        return modeConfig.item_list, modeType
      end
    end
  end
  log(bWriteLog and "logic_return_activity_first_battle:GetCurModeRewards - No Done mode found")
  return nil
end
function logic_return_activity_first_battle:ReqFirstBattleConfig()
end
function logic_return_activity_first_battle:on_backuser_mode_first_battle_status_notify(mode_category)
  local userData = DataMgr.roleData and DataMgr.roleData.back_user_data
  if userData then
    userData.mode_first_battle_red_point = true
    if userData.mode_first_battle_info then
      userData.mode_first_battle_info[mode_category] = CommonItem_Const.Enum_ItemStatus.Done
    end
  end
end
function logic_return_activity_first_battle:ReqGetFirstBattleReward()
  local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
  PlayerReturnHandler.send_backuser_get_daily_reward_req():Then(function(res, status, item_list)
    if res ~= 0 then
      log(bWriteLog and string.format("logic_return_activity_first_battle:ReqGetFirstBattleReward - send_backuser_get_daily_reward_req failed, res:%s", tostring(res)))
      return
    end
    local userData = DataMgr.roleData and DataMgr.roleData.back_user_data
    if not userData then
      log(bWriteLog and "logic_return_activity_first_battle:ReqGetFirstBattleReward - back_user_data is nil")
      return
    end
    if userData.mode_first_battle_red_point then
      local hasClaimable = false
      local modeRewardStatus = self:_GetModeRewardStatus()
      for _, status in ipairs(modeRewardStatus) do
        if status == CommonItem_Const.Enum_ItemStatus.Done then
          hasClaimable = true
          break
        end
      end
      if not hasClaimable then
        log(bWriteLog and "logic_return_activity_first_battle:ReqGetFirstBattleReward - No claimable mode found")
        return
      end
      log(bWriteLog and "logic_return_activity_first_battle:ReqGetFirstBattleReward - Claim all claimable rewards")
      self:HandleNewVersionReward()
    else
      log(bWriteLog and "logic_return_activity_first_battle:ReqGetFirstBattleReward - Old version reward handled by Handler callback")
    end
  end)
end
function logic_return_activity_first_battle:HandleNewVersionReward()
  log(bWriteLog and "logic_return_activity_first_battle:HandleNewVersionReward - Claim all claimable rewards")
  local claimableModes = {}
  local modeRewardStatus = self:_GetModeRewardStatus()
  for _, modeType in ipairs(self.modeOrder) do
    local status = modeRewardStatus[modeType]
    if status == CommonItem_Const.Enum_ItemStatus.Done then
      table.insert(claimableModes, modeType)
    end
  end
  if #claimableModes == 0 then
    log(bWriteLog and "logic_return_activity_first_battle:HandleNewVersionReward - No claimable modes found")
    return
  end
  local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
  PlayerReturnHandler.send_backuser_claim_mode_first_battle_reward_req():Then(function(err_code, item_list)
    if err_code ~= 0 then
      log(bWriteLog and string.format("logic_return_activity_first_battle:HandleNewVersionReward - Claim failed, err_code:%s", tostring(err_code)))
      return
    end
    local rewardStatus = self:_GetModeRewardStatus()
    for _, modeType in ipairs(claimableModes) do
      rewardStatus[modeType] = CommonItem_Const.Enum_ItemStatus.Got
      log(bWriteLog and string.format("logic_return_activity_first_battle:HandleNewVersionReward - Status updated to Got for modeType:%s", tostring(modeType)))
    end
    EventSystem:postEvent(EVENTTYPE_COME_BACK, EVENTID_LOBBY_COME_BACK_FB_STATUS_RSP)
    if item_list and next(item_list) then
      local rewardItems = {}
      for _, data in ipairs(item_list) do
        table.insert(rewardItems, {
          res_id = data.resid or data.res_id,
          count = data.count or data.res_num,
          valid_hours = data.valid_hours
        })
      end
      self:ShowRewardPanel(rewardItems)
    else
      log(bWriteLog and "logic_return_activity_first_battle:HandleNewVersionReward - item_list is empty")
    end
  end)
end
function logic_return_activity_first_battle:HandleOldVersionReward()
  log(bWriteLog and "logic_return_activity_first_battle:HandleOldVersionReward")
  local rewardItems = self:CollectOldRewards()
  self:ShowRewardPanel(rewardItems)
end
function logic_return_activity_first_battle:CollectOldRewards()
  local rewardItems = {}
  local userData = DataMgr.roleData and DataMgr.roleData.back_user_data
  if not (userData and userData.daily_battle_data) or not userData.daily_battle_data.reward_cfg then
    log(bWriteLog and "logic_return_activity_first_battle:CollectOldRewards - No old reward config")
    return rewardItems
  end
  local rewardCfg = userData.daily_battle_data.reward_cfg
  for _, reward in ipairs(rewardCfg) do
    if reward.res_id and reward.res_id > 0 then
      table.insert(rewardItems, {
        res_id = reward.res_id,
        count = reward.res_num,
        valid_hours = reward.valid_hours
      })
    end
  end
  log(bWriteLog and string.format("logic_return_activity_first_battle:CollectOldRewards - Collected %s old rewards", tostring(#rewardItems)))
  return rewardItems
end
function logic_return_activity_first_battle:CollectNewRewards(modeType)
  local config = self:_GetConfig()
  if not (config and config[modeType]) or not config[modeType].item_list then
    log(bWriteLog and string.format("logic_return_activity_first_battle:CollectNewRewards - No new reward config for modeType:%s", tostring(modeType)))
    return nil
  end
  local rewardItems = {}
  local itemList = config[modeType].item_list
  for _, data in ipairs(itemList) do
    table.insert(rewardItems, {
      res_id = data.resid,
      count = data.count,
      valid_hours = data.valid_hours
    })
  end
  log(bWriteLog and string.format("logic_return_activity_first_battle:CollectNewRewards - Collected %s new rewards for modeType:%s", tostring(#rewardItems), tostring(modeType)))
  return rewardItems
end
function logic_return_activity_first_battle:ShowRewardPanel(rewardItems)
  if not rewardItems or #rewardItems == 0 then
    log(bWriteLog and "logic_return_activity_first_battle:ShowRewardPanel - No rewards to show")
    return
  end
  log(bWriteLog and string.format("logic_return_activity_first_battle:ShowRewardPanel - Showing %s rewards", tostring(#rewardItems)))
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  if self:HasUncompletedMode() then
    log(bWriteLog and "logic_return_activity_first_battle:ShowRewardPanel - Has uncompleted modes, showing two-button style")
    Logic_CommonItemGet.ShowPanel_TwoBtnStyle(rewardItems, LocUtil.GetLocalizeResStr(76365), function()
      local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
      logic_return_activity:EnterMainUI(return_activity_macro.Enum_MenuID.FirstBattle)
    end)
  else
    log(bWriteLog and "logic_return_activity_first_battle:ShowRewardPanel - All modes completed, showing default style")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(rewardItems)
  end
end
function logic_return_activity_first_battle:HasUncompletedMode()
  local modeRewardStatus = self:_GetModeRewardStatus()
  for _, modeType in ipairs(self.modeOrder) do
    local status = modeRewardStatus[modeType]
    if status == CommonItem_Const.Enum_ItemStatus.Not then
      log(bWriteLog and string.format("logic_return_activity_first_battle:HasUncompletedMode - Found uncompleted modeType:%s, status:%s", tostring(modeType), tostring(status)))
      return true, modeType
    end
  end
  log(bWriteLog and "logic_return_activity_first_battle:HasUncompletedMode - All modes completed")
  return false, nil
end
function logic_return_activity_first_battle:GetModeTypeByMatchMode(matchMode)
  local history_combat_util = require("client.logic.combat.history.history_combat_util")
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if matchMode then
    if history_combat_util.IsClassicRankMode(matchMode) or history_combat_util.IsMatchMode(matchMode) then
      return return_activity_macro.Enum_FB_Mode_Type.Classic
    elseif history_combat_util.IsTeamMode(matchMode) then
      return return_activity_macro.Enum_FB_Mode_Type.TeamCompetition
    elseif history_combat_util.IsUGCMatchMode(matchMode) then
      return return_activity_macro.Enum_FB_Mode_Type.WOW
    elseif logic_mode_selection.hasSelectTxMission and UIManager.GetUI(UIManager.UI_Config.xmission_main) then
      return return_activity_macro.Enum_FB_Mode_Type.Xmission
    end
  end
  return nil
end
function logic_return_activity_first_battle:GetRewardConfigByModeType(modeType)
  if not modeType then
    return nil
  end
  local itemList = {}
  local userData = DataMgr.roleData and DataMgr.roleData.back_user_data
  if userData and userData.daily_battle_data and userData.daily_battle_data.status == CommonItem_Const.Enum_ItemStatus.Not then
    local oldRewards = self:CollectOldRewards()
    for _, reward in ipairs(oldRewards) do
      table.insert(itemList, {
        resid = reward.res_id,
        count = reward.count,
        valid_hours = reward.valid_hours
      })
    end
  end
  local config = self:_GetConfig()
  if config and config[modeType] and config[modeType].item_list then
    for _, v in ipairs(config[modeType].item_list) do
      table.insert(itemList, v)
    end
  end
  return 0 < #itemList and itemList or nil
end
function logic_return_activity_first_battle:GetCurSelModeRewardConfig()
  local userData = DataMgr.roleData and DataMgr.roleData.back_user_data
  if userData and userData.daily_battle_data and userData.daily_battle_data.status == CommonItem_Const.Enum_ItemStatus.Not then
    local oldRewards = self:CollectOldRewards()
    if oldRewards and 0 < #oldRewards then
      local itemList = {}
      for _, reward in ipairs(oldRewards) do
        table.insert(itemList, {
          resid = reward.res_id,
          count = reward.count,
          valid_hours = reward.valid_hours
        })
      end
      return itemList
    end
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local matchMode = logic_mode_selection:GetCurSelectInfo()
  local modeType = self:GetModeTypeByMatchMode(matchMode)
  local config = self:_GetConfig()
  if not (modeType and config and config[modeType]) or not config[modeType].item_list then
    return nil
  end
  local itemList = config[modeType].item_list
  if not itemList or #itemList == 0 then
    log(bWriteLog and string.format("logic_return_activity_first_battle:GetCurSelModeRewardConfig - No rewards found for modeType:%s", tostring(modeType)))
    return nil
  end
  return itemList
end
function logic_return_activity_first_battle:ShouldShowReturnModeSelect()
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  if not logic_return_activity_utils.IsActInProgress() then
    log(bWriteLog and "logic_return_activity_first_battle:ShouldShowReturnModeSelect - Not in return activity")
    return false
  end
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  local logic_return_activity_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_guide)
  local guideType = logic_return_activity_guide:GetGuideType()
  if guideType ~= return_activity_macro.Enum_Guide_Type.ModeSelect then
    log(bWriteLog and string.format("logic_return_activity_first_battle:ShouldShowReturnModeSelect - guideType=%s, not ModeSelect, skip", tostring(guideType)))
    return false
  end
  if not logic_return_activity_guide:HasValidGuideUI() then
    log(bWriteLog and "logic_return_activity_first_battle:ShouldShowReturnModeSelect - HasValidGuideUI is false")
    return false
  end
  local userData = DataMgr.roleData and DataMgr.roleData.back_user_data
  if not userData then
    return false
  end
  if userData.daily_battle_data.status ~= 0 then
    log(bWriteLog and "logic_return_activity_first_battle:ShouldShowReturnModeSelect - daily_battle_data status is not 0, return false")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerMatchSuccess) or {}
  if saveData[userData.rejoin_start_time] then
    log(bWriteLog and "logic_return_activity_first_battle:ShouldShowReturnModeSelect - matched successfully, return false")
    return false
  end
  local clickData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerModeSelectClick) or {}
  local lastClickTime = clickData[userData.rejoin_start_time]
  if lastClickTime then
    local TimeUtil = require("client.common.time_util")
    if TimeUtil.IsSameDay(TimeUtil.GetServerTimeInSec(), tonumber(lastClickTime)) then
      log(bWriteLog and "logic_return_activity_first_battle:ShouldShowReturnModeSelect - Already shown today")
      return false
    end
  end
  if not self:GetModeIntroductionList() then
    log(bWriteLog and "logic_return_activity_first_battle:ShouldShowReturnModeSelect - GetModeIntroductionList is nil, skip")
    return false
  end
  return true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_return_activity_first_battle = class(CModuleBase, nil, logic_return_activity_first_battle)
return Clogic_return_activity_first_battle