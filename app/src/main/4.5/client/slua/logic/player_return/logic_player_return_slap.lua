local TimeUtil = require("client.common.time_util")
local TableUtil = require("common.table_util")
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
local common_config = require("client.slua.common.common_config")
local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
local C_OneDaySeconds = 86400
local C_DaysNewRebackSlap = 7
local C_DaysNewSlap = 3
local C_DayNewSign = 8
local logic_player_return_slap = {}
function logic_player_return_slap:DefineAndResetData()
  self.showRebackSlap = false
  self.back_battle_num = 0
  self.isShowMainFlag = false
  self.bIsShowReturnFlag = nil
end
function logic_player_return_slap:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_RETURN_REWARD_SLAP, self.ShowNewRewardSlap, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_RETURN_NEW, self.ShowNewReturnUI, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_RETURN_BANNER_SLAP, self.ShowNewBannerSlapUI, self)
end
local _IsReturnActivityRebackUser = function(self)
  local lastLoginTime = TableUtil.GetTableValue(DataMgr, "roleData", "old_last_login_time")
  if not lastLoginTime then
    return false
  end
  local intervalTime = C_DaysNewRebackSlap * C_OneDaySeconds
  local nowTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "[v_wllwu] logic_player_return_slap._IsReturnActivityRebackUser  nowTime = " .. tostring(nowTime) .. " lastLoginTime= " .. tostring(lastLoginTime))
  if intervalTime < nowTime - lastLoginTime then
    log(bWriteLog and "[v_wllwu] logic_player_return_slap._IsReturnActivityRebackUser true")
    self.showRebackSlap = true
    return true
  end
  return false
end
function logic_player_return_slap:CanGetGift()
  log(bWriteLog and "god test CanGetGift " .. tostring(LobbySystem.CheckOpen(BP_ENUM_PLAYER_RETURN_GIFT)))
  if not LobbySystem.CheckOpen(BP_ENUM_PLAYER_RETURN_GIFT) then
    return
  end
  local userData = DataMgr.roleData.back_user_data
  if not userData then
    return false
  end
  if userData.user_gift_dropid > 0 then
    return true
  end
  return false
end
function logic_player_return_slap:UpdateCurrentBattleNum()
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  if not logic_player_return.isPlayerReturnOpenNew() then
    self.back_battle_num = 1
    return
  end
  local userData = DataMgr.roleData.back_user_data
  self.back_battle_num = userData.battle_task_progress
  local newBattleNum = logic_player_return.GetCurrentBattleNum()
  if newBattleNum then
    self.back_battle_num = newBattleNum
  end
  log(bWriteLog and string.format("[v_wllwu] logic_player_return_slap.UpdateCurrentBattleNum back_battle_num:%s", tostring(self.back_battle_num)))
end
function logic_player_return_slap:CanShowNewReturnAward()
  if not logic_return_activity_utils.IsActInProgress() then
    return false
  end
  if self:CanGetGift() then
    self.bIsShowReturnFlag = true
    return true
  end
  log(bWriteLog and "[v_wllwu] logic_player_return_slap CanShowNewReturnAward can not showUI ")
  return false
end
function logic_player_return_slap:ShowNewRewardSlap()
  UIManager.ShowUI(UIManager.UI_Config.ReturnActivity_Slap_Main_UIBP)
end
function logic_player_return_slap:CanShowNewReturnUI()
  if not logic_return_activity_utils.IsActInProgress() then
    log(bWriteLog and "[v_wllwu] logic_player_return_slap.CanShowNewReturnUI false, act end")
    return false
  end
  if not self.bIsShowReturnFlag then
    log(bWriteLog and "logic_player_return_slap.CanShowNewReturnUI return of bIsShowReturnFlag")
    return false
  end
  local logic_return_activity_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_guide)
  local guideCfg = logic_return_activity_guide:GetGuideConifg()
  if guideCfg and guideCfg.main_page == 1 then
    return true
  end
  return false
end
function logic_player_return_slap:ShowNewReturnUI(ignoreQueue)
  self:UpdateSlapReturnMainSaveData()
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  logic_return_activity:EnterMainUI(nil, nil, ignoreQueue)
  local reason = 1
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.ReturnActivityEnter, reason)
end
function logic_player_return_slap:CanShowNewBannerUI()
  if not logic_return_activity_utils.IsActInProgress() then
    return false
  end
  if self.showRebackSlap then
    log(bWriteLog and "[v_wllwu] logic_player_return_slap has show SelectAwardSlap ")
    return false
  end
  local now = TimeUtil.GetServerTimeInSec()
  local startTime = tonumber(DataMgr.roleData.back_user_data.rejoin_start_time)
  if TimeUtil.IsSameDay(startTime, now) then
    log(bWriteLog and "logic_return_activity:CanShowNewBannerUI return startTime, now is same day")
    return false
  end
  local days = math.ceil((TimeUtil.GetServerTimeInSec() - startTime) / C_OneDaySeconds)
  if 7 < days then
    log(bWriteLog and "logic_return_activity:CanShowNewBannerUI return days > 7")
    return false
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  if logic_player_return.login_reward_info.got_indexs and #logic_player_return.login_reward_info.got_indexs >= C_DayNewSign then
    return false
  end
  local logic_return_activity_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_guide)
  local guideCfg = logic_return_activity_guide:GetGuideConifg()
  if guideCfg and guideCfg.pop_back_award == 0 then
    log(bWriteLog and "logic_player_return_slap.CanShowNewBannerUI return of guideCfg.pop_back_award == 0")
    return false
  end
  local savedData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnActivityFaceSlapTime)
  if savedData and savedData.time and TimeUtil.IsSameDay(now, savedData.time) then
    return false
  end
  local saveData = {
    time = TimeUtil.GetServerTimeInSec()
  }
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eReturnActivityFaceSlapTime)
  return true
end
function logic_player_return_slap:ShowNewBannerSlapUI(ignoreQueue)
  if common_config:IsBlockingPopupTip() then
    log(bWriteLog and "logic_player_return_slap.ShowNewBannerSlapUI UI responsiveness testing")
  else
    local ParamTable
    if ignoreQueue then
      local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
      ParamTable = ui_show_queue_config.GetParamTable(nil, "IsSlapUI")
    end
    UIManager.ShowUI(UIManager.UI_Config.ReturnActivity_Task_Popup_UIBP, ParamTable)
  end
end
function logic_player_return_slap:SetShowReturnFlag(flagValue)
  self.isShowMainFlag = flagValue
end
function logic_player_return_slap:UpdateSlapReturnMainSaveData()
  local nowTime = TimeUtil.GetServerTimeInSec()
  local cfg = {LastShowTime = nowTime}
  log(bWriteLog and "[v_wllwu] logic_player_return_slap.UpdateSlapReturnMainSaveData value : " .. tostring(nowTime))
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eReturnActivitySlapRecord)
end
function logic_player_return_slap:CanShowFBUI()
  local userData = DataMgr.roleData and DataMgr.roleData.back_user_data
  if not userData then
    log(bWriteLog and "logic_player_return_slap.CanShowFBUI - userData is nil, return false")
    return false
  end
  log_tree("logic_player_return_slap.CanShowFBUI - daily_battle_data", userData.daily_battle_data)
  if LobbySystem.CheckOpen(32020) and userData.daily_battle_data and userData.daily_battle_data.status then
    if userData.daily_battle_data.status == 1 and next(userData.daily_battle_data.reward_cfg) then
      log(bWriteLog and "logic_player_return_slap.CanShowFBUI - daily_battle_data check passed, return true")
      return true
    else
      log(bWriteLog and "logic_player_return_slap.CanShowFBUI - daily_battle_data check failed, return false")
    end
  end
  log(bWriteLog and "logic_player_return_slap.CanShowFBUI - No available rewards, return false")
  return false
end
function logic_player_return_slap:CanShowFBGuideUI()
  log(bWriteLog and "logic_player_return_slap:CanShowFBGuideUI")
  if self:CanShowModeSelectUI() then
    log(bWriteLog and "logic_player_return_slap.CanShowFBGuideUI return of CanShowModeSelectUI")
    return false
  end
  if self.bIsShowReturnFlag then
    log(bWriteLog and "logic_player_return_slap.CanShowFBGuideUI return of bIsShowReturnFlag")
    return false
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "logic_player_return_slap:CanShowFBGuideUI - IsInXMission, return false")
    return false
  end
  local now = TimeUtil.GetServerTimeInSec()
  local savedData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnActivityFBGuideTime)
  if savedData and savedData.time and TimeUtil.IsSameDay(now, savedData.time) then
    log(bWriteLog and "logic_player_return_slap:CanShowFBGuideUI - already shown today, return false")
    return false
  end
  local userData = DataMgr.roleData and DataMgr.roleData.back_user_data
  if not userData then
    log(bWriteLog and "logic_player_return_slap:CanShowFBGuideUI - userData is nil, return false")
    return false
  end
  local logic_return_activity_first_battle = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_first_battle)
  local hasUncompleted = logic_return_activity_first_battle:HasUncompletedMode()
  log(bWriteLog and string.format("logic_player_return_slap:CanShowFBGuideUI - hasUncompleted:%s", tostring(hasUncompleted)))
  if hasUncompleted then
    local saveData = {
      time = TimeUtil.GetServerTimeInSec()
    }
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eReturnActivityFBGuideTime)
  end
  return hasUncompleted
end
function logic_player_return_slap:CanShowModeSelectUI()
  log(bWriteLog and "logic_player_return_slap:CanShowModeSelectUI")
  local logic_return_activity_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_guide)
  local guideType = logic_return_activity_guide:GetGuideType()
  if guideType ~= return_activity_macro.Enum_Guide_Type.ModeSelect then
    log(bWriteLog and "logic_player_return_slap.CanShowModeSelectUI return of guideType ~= ModeSelect")
    return false
  end
  if not logic_return_activity_guide:HasValidGuideUI() then
    log(bWriteLog and "logic_player_return_slap.CanShowModeSelectUI return of HasValidGuideUI is false")
    return false
  end
  if self.bIsShowReturnFlag then
    log(bWriteLog and "logic_player_return_slap.CanShowModeSelectUI return of bIsShowReturnFlag")
    return false
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "logic_player_return_slap:CanShowModeSelectUI - IsInXMission, return false")
    return false
  end
  local userData = DataMgr.roleData and DataMgr.roleData.back_user_data
  if not userData then
    log(bWriteLog and "logic_player_return_slap:CanShowModeSelectUI - userData is nil, return false")
    return false
  end
  if userData.daily_battle_data.status ~= 0 then
    log(bWriteLog and "logic_player_return_slap:CanShowModeSelectUI - daily_battle_data status is not 0, return false")
    return false
  end
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerMatchSuccess) or {}
  if saveData[DataMgr.roleData.back_user_data.rejoin_start_time] then
    log(bWriteLog and "logic_player_return_slap:CanShowModeSelectUI - matched successfully, return false")
    return false
  end
  return true
end
function logic_player_return_slap:CanShowSignRewardUI()
  log(bWriteLog and "logic_player_return_slap.CanShowSignRewardUI")
  if not logic_return_activity_utils.IsActInProgress() then
    log(bWriteLog and "logic_player_return_slap.CanShowSignRewardUI Activity is not open")
    return false
  end
  if not DataMgr.roleData.back_user_data.have_login_reward then
    log(bWriteLog and "logic_player_return_slap.CanShowSignRewardUI no have_login_reward")
    return
  end
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerEnterMainUI) or {}
  if not cfg[DataMgr.roleData.back_user_data.rejoin_start_time] then
    log(bWriteLog and "logic_player_return_slap.CanShowSignRewardUI not enter return activity")
    return false
  end
  if self.bIsShowReturnFlag then
    log(bWriteLog and "logic_player_return_slap.CanShowSignRewardUI return of bIsShowReturnFlag")
    return false
  end
  local startTime = tonumber(DataMgr.roleData.back_user_data.rejoin_start_time)
  local days = math.ceil((TimeUtil.GetServerTimeInSec() - startTime) / C_OneDaySeconds)
  if days > C_DayNewSign then
    log(bWriteLog and "logic_return_activity:CanShowSignRewardUI Return days > 8")
    return false
  end
  local logic_return_activity_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_guide)
  local guideCfg = logic_return_activity_guide:GetGuideConifg()
  if guideCfg and guideCfg.pop_sign_award == 0 then
    log(bWriteLog and "logic_player_return_slap.CanShowSignRewardUI return of guideCfg.pop_sign_award == 0")
    return false
  end
  return true
end
local _GetSelf = function()
  return ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_player_return_slap)
end
function logic_player_return_slap.CheckCanShowNewReturnAward()
  return _GetSelf():CanShowNewReturnAward()
end
function logic_player_return_slap.CheckCanShowNewReturnUI()
  return _GetSelf():CanShowNewReturnUI()
end
function logic_player_return_slap.CheckCanShowNewBannerUI()
  return _GetSelf():CanShowNewBannerUI()
end
function logic_player_return_slap.CheckCanShowFBUI()
  return _GetSelf():CanShowFBUI()
end
function logic_player_return_slap.CheckCanShowSignRewardUI()
  return _GetSelf():CanShowSignRewardUI()
end
function logic_player_return_slap.CheckCanShowFBGuideUI()
  return _GetSelf():CanShowFBGuideUI()
end
function logic_player_return_slap.CheckCanShowModeSelectUI()
  return _GetSelf():CanShowModeSelectUI()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_player_return_slap = class(CModuleBase, nil, logic_player_return_slap)
return Clogic_player_return_slap