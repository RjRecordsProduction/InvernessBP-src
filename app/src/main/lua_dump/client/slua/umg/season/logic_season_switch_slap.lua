local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local logic_season_switch_slap = {}
function logic_season_switch_slap:DefineAndResetData()
  self._isServerAlreadyShow = nil
  self._saveData = nil
end
function logic_season_switch_slap:OnInitialize()
  self:LoadSeasonSwitchLocalData()
end
function logic_season_switch_slap:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SEASON_SWITCH, self.ShowSeasonSwitchSlap, self)
end
function logic_season_switch_slap:OnLogin(bReLogin)
end
function logic_season_switch_slap:OnLogOut()
end
function logic_season_switch_slap:OnPreSwitchGameStatus(pre, next)
end
function logic_season_switch_slap:OnPostSwitchGameStatus(pre, next)
end
function logic_season_switch_slap:CheckShouldSlapOnEnterLobby()
  if DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.quick_battle_switch then
    log_warning(bWriteLog and "logic_season_switch_slap:ShouldSlapOnEnterLobby. is return player")
    return false
  end
  return self:CheckShouldSlap()
end
function logic_season_switch_slap:CheckShouldSlap()
  log(bWriteLog and "logic_season_switch_slap:CheckShouldSlap")
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  if logic_player_return.blockTip then
    log_warning(bWriteLog and "logic_season_switch_slap:CheckShouldSlap. is return player blockTip")
    return
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.season) then
    log_warning(bWriteLog and "logic_season_switch_slap:CheckShouldSlap. not level_unlock_manager:IsFeatureUnlocked")
    return
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if LogicNewbie.IsNewbie() and LogicNewbie.NeedShowNewbieGuide(10007) then
    log_warning(bWriteLog and "logic_season_switch_slap:CheckShouldSlap. newbie stage")
    return false
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.IsFinishAllNewGuide() then
    log_warning(bWriteLog and "logic_season_switch_slap:CheckShouldSlap. not finish newbie guide")
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsCEVersion() then
    log_warning(bWriteLog and "logic_season_switch_slap:CheckShouldSlap. is ce version")
    return false
  end
  log_tree(bWriteLog and "logic_season_switch_slap:CheckShouldSlap. saveData", self._saveData)
  if not self._saveData or not next(self._saveData) then
    log_warning(bWriteLog and "logic_season_switch_slap:CheckShouldSlap. no data")
    return false
  end
  local mark = DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_SEASON_SWITCH_SLAP, DataMgr.season_id)
  log_format("logic_season_switch_slap:CheckShouldSlap. mark = [%s]", mark)
  if mark ~= nil then
    if mark == 1 then
      log_warning(bWriteLog and "logic_season_switch_slap:CheckShouldSlap. is return is already show in server")
      return
    end
  else
    if self._saveData.uid ~= DataMgr.roleData.uid then
      log_warning_format("logic_season_switch_slap:CheckShouldSlap. uid not match. uid = [%s], saveData.uid = [%s]", DataMgr.roleData.uid, self._saveData.uid)
      return false
    end
    if self._saveData.hasShow then
      log_warning(bWriteLog and "logic_season_switch_slap:CheckShouldSlap. is already show")
      return false
    end
  end
  if DataMgr.season_id and tonumber(DataMgr.season_id) ~= self._saveData.new_season_index then
    log_warning(bWriteLog and "logic_season_switch_slap:CheckShouldSlap. season_id not match")
    return false
  end
  local SeasonVerCfg = CDataTable.GetTableData("SeasonVersion", self._saveData.new_season_index)
  if not SeasonVerCfg then
    log_warning(bWriteLog and "logic_season_switch_slap:CheckShouldSlap. not season version config")
    return false
  end
  local version_util = require("client.common.version_util")
  local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  if not (version_util.CompareVersionStandard(ClientVersion, SeasonVerCfg.MinVersion) >= 0) or not (0 > version_util.CompareVersionStandard(ClientVersion, SeasonVerCfg.MaxVersion)) then
    log_warning(bWriteLog and "logic_season_switch_slap:CheckShouldSlap. client version not match")
    return false
  end
  return true
end
function logic_season_switch_slap:ShowSeasonSwitchSlap()
  log_tree(bWriteLog and "logic_season_switch_slap:ShowSeasonSwitchSlap. saveData = ", self._saveData)
  if not self._saveData then
    return false
  end
  UIManager.ShowUI(UIManager.UI_Config.ui_season_switch_mgr, self._saveData)
end
function logic_season_switch_slap:TryShowSeasonSwitchSlapForReturner()
  if not DataMgr.roleData.back_user_data or not DataMgr.roleData.back_user_data.quick_battle_switch then
    log_warning(bWriteLog and "logic_season_switch_slap:TryShowSeasonSwitchSlapForReturner. not back user")
    return false
  end
  if not self:CheckShouldSlap() then
    log_warning(bWriteLog and "logic_season_switch_slap:TryShowSeasonSwitchSlapForReturner. not should slap")
    return false
  end
  local isFail = self:ShowSeasonSwitchSlap()
  if isFail ~= nil then
    log_warning(bWriteLog and "logic_season_switch_slap:TryShowSeasonSwitchSlapForReturner. show fail")
    return false
  end
  return true
end
function logic_season_switch_slap:on_season_switch_info_summary(new_segment_info)
  log_tree(bWriteLog and "logic_season_switch_slap:on_season_switch_info_summary. new_segment_info = ", new_segment_info)
  DataMgr.roleData.season_switch_display = new_segment_info
  self:SaveSeasonSwitchData(new_segment_info)
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  season_redpoint_data.RefreshClassicSwitchForReturnReddot()
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_SEASON_SWITCH)
end
function logic_season_switch_slap:SetServerMark()
  log(bWriteLog and "logic_season_switch_slap:SetServerMark")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  DataMgr.SetNewbieGuide(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_SEASON_SWITCH_SLAP, DataMgr.season_id)
end
function logic_season_switch_slap:LoadSeasonSwitchLocalData()
  self._saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSeasonSwitch)
  log_tree("logic_season_switch_slap:LoadSeasonSwitchLocalData. saveData = ", self._saveData)
end
function logic_season_switch_slap:SaveSeasonSwitchData(new_segment_info)
  log_tree(bWriteLog and "logic_season_switch_slap:SaveSeasonSwitchData. new_segment_info = ", new_segment_info)
  if not new_segment_info or not next(new_segment_info) then
    return
  end
  if self._saveData and self._saveData.last_season_index == new_segment_info.last_season_index and self._saveData.uid == DataMgr.roleData.uid then
    log_warning(bWriteLog and "logic_season_switch_slap:SaveSeasonSwitchData. already saved")
    return
  end
  self:RecordUserData(new_segment_info, false)
  self._saveData = new_segment_info
  PlayerPrefsSystem.SaveTableToFile_N(new_segment_info, PlayerPrefsSystem.ePlayerPrefsType.eSeasonSwitch)
end
function logic_season_switch_slap:ClearSeasonSwitchLocalData()
  log(bWriteLog and "logic_season_switch_slap:ClearSeasonSwitchLocalData")
  if not self._saveData then
    self._saveData = {}
  end
  self:RecordUserData(self._saveData, true)
  PlayerPrefsSystem.SaveTableToFile_N(self._saveData, PlayerPrefsSystem.ePlayerPrefsType.eSeasonSwitch)
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  season_redpoint_data.RefreshClassicSwitchForReturnReddot()
end
function logic_season_switch_slap:RecordUserData(saveData, hasShow)
  log(bWriteLog and "logic_season_switch_slap:RecordUserData. hasShow = " .. tostring(hasShow))
  saveData.  saveData.uid = DataMgr.roleData.uid
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_season_switch_slap = class(CModuleBase, nil, logic_season_switch_slap)
return Clogic_season_switch_slap