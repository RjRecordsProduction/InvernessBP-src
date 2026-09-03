local logic_multi_select_match = {}
local SwitchStatus = {
  noSwitch = 1,
  Switching = 2,
  Switched = 3
}
function logic_multi_select_match:DefineAndResetData()
  self.MSMatchTriggerCfg = nil
  self.curSwitchStatus = SwitchStatus.noSwitch
  self.weekDays = 7
  self.guideTimesOneDay = 2
end
function logic_multi_select_match:SetMSMatchTriggerCfg(multi_select_match_trigger_cfg)
  log_tree(bWriteLog and "logic_multi_select_match:SetMSMatchTriggerCfg:", multi_select_match_trigger_cfg)
  self:DefineAndResetData()
  self.MSMatchTriggerCfg = multi_select_match_trigger_cfg
  self:StartGuideTimer()
end
function logic_multi_select_match:CheckGuideWhenCancelMatch()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    log(bWriteLog and "logic_multi_select_match:CheckGuideWhenCancelMatch IsJapanOrKorea")
    return false
  end
  if not self:PreCheckShowGuide() then
    log(bWriteLog and "logic_multi_select_match:CheckGuideWhenCancelMatch not PreCheckShowGuide")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local canGuideToday = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eMSMatchWhenCancelMatch, true, self.weekDays)
  if not canGuideToday then
    log(bWriteLog and "logic_multi_select_match:CheckGuideWhenCancelMatch cannot guide today")
    return false
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if MatchSystem.nMatchingTime < self.MSMatchTriggerCfg.min_time_for_cancel then
    log(bWriteLog and "logic_multi_select_match:CheckGuideWhenCancelMatch less than min time")
    return false
  end
  if not self:CheckGuideTimes(PlayerPrefsSystem.ePlayerPrefsType.eMSMatchTimesWhenCancelMatch) then
    log(bWriteLog and "logic_multi_select_match:CheckGuideWhenCancelMatch more times")
    return false
  end
  local long_time_match_macro_data = self:GetSpecialPopData()
  if long_time_match_macro_data.needShowWindow then
    return long_time_match_macro_data.needShowWindow()
  end
  log(bWriteLog and "logic_multi_select_match:CheckGuideWhenCancelMatch can")
  return true
end
function logic_multi_select_match:ShowGuideWhenCancelMatch()
  log(bWriteLog and "logic_multi_select_match:ShowGuideWhenCancelMatch")
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local long_time_match_macro_data = self:GetSpecialPopData()
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.MSMatch_ShowGuide_WhenCancelMatch)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self:SaveGuideTimes(PlayerPrefsSystem.ePlayerPrefsType.eMSMatchTimesWhenCancelMatch)
  local clickOkCallback = function(isCheck)
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.MSMatch_Switch_WhenCancelMatch, MatchModeMgrSystem.nSelectMatchID)
    self:SetCurSwitchStatus(SwitchStatus.Switching)
    self:CancelMatch()
    if isCheck then
      PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eMSMatchWhenCancelMatch, false, self.weekDays)
    end
  end
  local clickCancelCallback = function(isCheck)
    self:CancelMatch()
    if isCheck then
      PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eMSMatchWhenCancelMatch, false, self.weekDays)
    end
  end
  local title = LocUtil.GetLocalizeResStr(long_time_match_macro_data.title or 101001)
  local msg = LocUtil.GetLocalizeResStr(long_time_match_macro_data.msg or 64247)
  local btnOK = LocUtil.GetLocalizeResStr(long_time_match_macro_data.btnOK or 64246)
  local btnCancel = LocUtil.GetLocalizeResStr(long_time_match_macro_data.btnCancel or 64245)
  local extraData = {
    isShowCheckBox = true,
    checkBoxText = LocUtil.GetLocalizeResStr(42731),
    closeOnSwitch = true
  }
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_FOUR, title, msg, clickOkCallback, clickCancelCallback, btnOK, btnCancel, extraData)
end
function logic_multi_select_match:StartGuideTimer()
  if not self.MSMatchTriggerCfg then
    log(bWriteLog and "logic_multi_select_match:StartGuideTimer no MSMatchTriggerCfg")
    return
  end
  self:RemoveGuideTimer()
  self.guideTimer = self:AddTimerLoop(0, function()
    if self:CheckAutoGuide() then
      self:ShowAutoGuide()
    end
  end, TIMER_INFINITE, 1)
end
function logic_multi_select_match:CheckAutoGuide()
  if not self:PreCheckShowGuide() then
    log(bWriteLog and "logic_multi_select_match:CheckAutoGuide not PreCheckShowGuide")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local canGuideToday = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eMSMatchAuto, true, self.weekDays)
  if not canGuideToday then
    log(bWriteLog and "logic_multi_select_match:CheckAutoGuide cannot guide today")
    return false
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if MatchSystem.nMatchingTime < self.MSMatchTriggerCfg.min_time_for_auto then
    log(bWriteLog and "logic_multi_select_match:CheckAutoGuide less than min time")
    return false
  end
  if not self:CheckGuideTimes(PlayerPrefsSystem.ePlayerPrefsType.eMSMatchAutoTimes) then
    log(bWriteLog and "logic_multi_select_match:CheckAutoGuide more times")
    return false
  end
  local long_time_match_macro_data = self:GetSpecialPopData()
  if long_time_match_macro_data.needShowWindow then
    return long_time_match_macro_data.needShowWindow()
  end
  log(bWriteLog and "logic_multi_select_match:CheckAutoGuide can")
  return true
end
function logic_multi_select_match:ShowAutoGuide()
  self:RemoveGuideTimer()
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local long_time_match_macro_data = self:GetSpecialPopData()
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.MSMatch_ShowGuide_Auto)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self:SaveGuideTimes(PlayerPrefsSystem.ePlayerPrefsType.eMSMatchAutoTimes)
  local clickOkCallback = function(isCheck)
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.MSMatch_Switch_Auto, MatchModeMgrSystem.nSelectMatchID)
    self:SetCurSwitchStatus(SwitchStatus.Switching)
    self:CancelMatch()
    if isCheck then
      PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eMSMatchAuto, false, self.weekDays)
    end
  end
  local clickCancelCallback = function(isCheck)
    if isCheck then
      PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eMSMatchAuto, false, self.weekDays)
    end
  end
  local title = LocUtil.GetLocalizeResStr(long_time_match_macro_data.title or 101001)
  local msg = LocUtil.GetLocalizeResStr(long_time_match_macro_data.msg or 64247)
  local btnOK = LocUtil.GetLocalizeResStr(long_time_match_macro_data.btnOK or 64246)
  local btnCancel = LocUtil.GetLocalizeResStr(long_time_match_macro_data.btnCancel or 64249)
  local extraData = {
    isShowCheckBox = true,
    checkBoxText = LocUtil.GetLocalizeResStr(42731),
    closeOnSwitch = true
  }
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_FOUR, title, msg, clickOkCallback, clickCancelCallback, btnOK, btnCancel, extraData)
end
function logic_multi_select_match:RemoveGuideTimer()
  if self.guideTimer then
    self:RemoveTimer(self.guideTimer)
    self.guideTimer = nil
  end
end
function logic_multi_select_match:CancelMatch()
  log(bWriteLog and "logic_multi_select_match:CancelMatch")
  LobbySystem.on_match_cancel_req()
end
function logic_multi_select_match:TrySwitchMSMatch()
  if not self.MSMatchTriggerCfg then
    log(bWriteLog and "logic_multi_select_match:TrySwitchMSMatch no MSMatchTriggerCfg")
    return
  end
  if not self:IsSwitchingMSMatch() then
    log(bWriteLog and "logic_multi_select_match:TrySwitchMSMatch no switching")
    self:DefineAndResetData()
    return
  end
  log(bWriteLog and "logic_multi_select_match:TrySwitchMSMatch")
  local long_time_match_macro_data = self:GetSpecialPopData()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local filter_info = logic_mode_selection:GetFilterInfo()
  if long_time_match_macro_data.switchCallBack then
    long_time_match_macro_data.switchCallBack(self.MSMatchTriggerCfg.view_id_list, filter_info)
  end
  logic_mode_selection:SetSelectView(self.MSMatchTriggerCfg.view_id_list, filter_info)
end
function logic_multi_select_match:IsSwitchingMSMatch()
  log(bWriteLog and "logic_multi_select_match:IsSwitchingMSMatch:" .. tostring(self.curSwitchStatus))
  return self.curSwitchStatus == SwitchStatus.Switching
end
function logic_multi_select_match:SwitchMSMatchSuccess()
  log(bWriteLog and "logic_multi_select_match:SwitchMSMatchSuccess")
  self:SetCurSwitchStatus(SwitchStatus.Switched)
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_LT_SWITCHMODE)
  local noticeSystem = require("client.slua.logic.common.logic_notice_mgr")
  noticeSystem.RemoveAllNotice()
  local long_time_match_macro_data = self:GetSpecialPopData()
  ShowNotice(long_time_match_macro_data.tips or 64248)
end
function logic_multi_select_match:OnMatchSuccess()
  log(bWriteLog and "logic_multi_select_match:OnMatchSuccess")
  self:DefineAndResetData()
end
function logic_multi_select_match:PreCheckShowGuide()
  if GameStatus.IsInFightingNotMainCity() then
    log(bWriteLog and "logic_multi_select_match:PreCheckShowGuide Fighting")
    return false
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() then
    log(bWriteLog and "logic_multi_select_match:PreCheckShowGuide not leader")
    return false
  end
  if not self.MSMatchTriggerCfg then
    log(bWriteLog and "logic_multi_select_match:PreCheckShowGuide no MSMatchTriggerCfg")
    return false
  end
  if self.curSwitchStatus ~= SwitchStatus.noSwitch then
    log(bWriteLog and "logic_multi_select_match:PreCheckShowGuide switch")
    return false
  end
  local readyViewIDs = self:GetDownloadedMaps()
  if #readyViewIDs == 0 then
    log(bWriteLog and "logic_multi_select_match:PreCheckShowGuide no downloaded map")
    return false
  end
  log(bWriteLog and "logic_multi_select_match:PreCheckShowGuide can")
  return true
end
function logic_multi_select_match:GetDownloadedMaps()
  local readyViewIDs = {}
  if not (self.MSMatchTriggerCfg and self.MSMatchTriggerCfg.view_id_list) or not next(self.MSMatchTriggerCfg.view_id_list) then
    log(bWriteLog and "logic_multi_select_match:GetDownloadedMaps no view_id_list")
    return readyViewIDs
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local logic_mode_map_download = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_map_download)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local view_id_list = self.MSMatchTriggerCfg.view_id_list
  for i = 1, #view_id_list do
    local viewID = view_id_list[i]
    local downloadViewData = logic_mode_selection:GetSubviewInfoBySubviewID(viewID)
    local mapKeyList, _ = logic_mode_map_download:GetMapKeyListByViewData(downloadViewData)
    local state = logic_mode_map_download:GetMapListState(mapKeyList)
    if state == PufferConst.ENUM_DownloadState.Done then
      table.insert(readyViewIDs, viewID)
    end
  end
  log_tree(bWriteLog and "logic_multi_select_match:GetDownloadedMaps:", readyViewIDs)
  return readyViewIDs
end
function logic_multi_select_match:CheckGuideTimes(playerPrefsType)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local guideData = PlayerPrefsSystem.LoadFileToTable_N(playerPrefsType)
  if not guideData then
    log(bWriteLog and "logic_multi_select_match:CheckGuideTimes no guideData")
    return true
  end
  local TimeUtil = require("client.common.time_util")
  if not TimeUtil.IsSameDay(TimeUtil.GetServerTimeInSec(), guideData.date) then
    log(bWriteLog and "logic_multi_select_match:CheckGuideTimes not same day")
    return true
  end
  log(bWriteLog and "logic_multi_select_match:CheckGuideTimes times:" .. tostring(guideData.times))
  return guideData.times < self.guideTimesOneDay
end
function logic_multi_select_match:SaveGuideTimes(playerPrefsType)
  local TimeUtil = require("client.common.time_util")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local guideData = PlayerPrefsSystem.LoadFileToTable_N(playerPrefsType)
  if not guideData then
    log(bWriteLog and "logic_multi_select_match:SaveGuideTimes no guideData")
    guideData = {
      date = TimeUtil.GetServerTimeInSec(),
      times = 1
    }
    PlayerPrefsSystem.SaveTableToFile_N(guideData, playerPrefsType)
    return
  end
  if not TimeUtil.IsSameDay(TimeUtil.GetServerTimeInSec(), guideData.date) then
    log(bWriteLog and "logic_multi_select_match:SaveGuideTimes not same day")
    guideData = {
      date = TimeUtil.GetServerTimeInSec(),
      times = 1
    }
    PlayerPrefsSystem.SaveTableToFile_N(guideData, playerPrefsType)
    return
  end
  log(bWriteLog and "logic_multi_select_match:SaveGuideTimes same day")
  guideData.times = guideData.times + 1
  PlayerPrefsSystem.SaveTableToFile_N(guideData, playerPrefsType)
end
function logic_multi_select_match:SetCurSwitchStatus(status)
  log(bWriteLog and "logic_multi_select_match:SetCurSwitchStatus:" .. tostring(status))
  self.curSwitchStatus = status
end
function logic_multi_select_match:GetSpecialPopData()
  local logic_long_time_match_macro = require("client.slua.logic.match.logic_long_time_match_macro")
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  log(bWriteLog and "logic_multi_select_match:GetSpecialPopData selectMatchID:" .. tostring(MatchModeMgrSystem.nSelectMatchID))
  return logic_long_time_match_macro[MatchModeMgrSystem.nSelectMatchID] or {}
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_multi_select_match = class(CModuleBase, nil, logic_multi_select_match)
return Clogic_multi_select_match