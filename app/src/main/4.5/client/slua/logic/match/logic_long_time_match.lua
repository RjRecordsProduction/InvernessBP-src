local logic_long_time_match = {}
function logic_long_time_match:DefineAndResetData()
  self.LTMatchTriggerConfig = nil
  self.LTReqCount = 0
  self.C_LTReqCountLimit = 1
  self.LTLastReqTime = 0
  self.C_LTReqCD = 5
  self.LTMatchGuideInfo = nil
  self.DisplayLTMatch = false
  self.LTMatchSelectType = 0
  self.LTMatchSelectTime = 0
  self.LTMatchCancelTipsCount = 0
end
function logic_long_time_match:SetLTMatchTriggerConfig(match_trigger_cfg)
  log_tree("logic_long_time_match:SetLTMatchTriggerConfig match_trigger_cfg", match_trigger_cfg)
  self.LTMatchTriggerConfig = match_trigger_cfg
end
function logic_long_time_match:IsNeedReqLTMatch()
  local Lobby_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not Lobby_Main_UIBP then
    log(bWriteLog and "logic_long_time_match:IsNeedReqLTMatch not Lobby_Main_UIBP")
    return false
  end
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  local page = Lobby_Main_Control.curPage
  if page ~= ENUM_LobbyPageType.Mid then
    log(bWriteLog and "logic_long_time_match:IsNeedReqLTMatch not Mid")
    return false
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() then
    log(bWriteLog and "logic_long_time_match:IsNeedReqLTMatch not leader")
    return false
  end
  if self:GetIsShowLTMatch() then
    log(bWriteLog and "logic_long_time_match:IsNeedReqLTMatch triggered")
    return false
  end
  local LTMatchTimeThreshold = self:GetLTMatchTimeThreshold()
  if not LTMatchTimeThreshold then
    log(bWriteLog and "logic_long_time_match:IsNeedReqLTMatch no threshold")
    return false
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if LTMatchTimeThreshold > MatchSystem.nMatchingTime then
    log(bWriteLog and "logic_long_time_match:IsNeedReqLTMatch not reach threshold")
    return false
  end
  if self.LTReqCount >= self.C_LTReqCountLimit then
    log(bWriteLog and "logic_long_time_match:IsNeedReqLTMatch LTReqCount >= C_LTReqCountLimit")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local cur = TimeUtil.GetServerTimeInSecWithFraction()
  if cur < self.LTLastReqTime + self.C_LTReqCD then
    log(bWriteLog and "logic_long_time_match:IsNeedReqLTMatch CD")
    return false
  end
  log(bWriteLog and "logic_long_time_match:IsNeedReqLTMatch can req")
  return true
end
function logic_long_time_match:GetLTMatchTimeThreshold()
  if not self.LTMatchTriggerConfig or not self.LTMatchTriggerConfig.match_guide_conf then
    log(bWriteLog and "logic_long_time_match:GetLTMatchTimeThreshold no config")
    return nil
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local estimateTime = MatchSystem.nEstimateTime
  local configs = self.LTMatchTriggerConfig.match_guide_conf
  local coefficient = tonumber(configs.coefficient) or 1.2
  local guide_time = tonumber(configs.guide_time) or 60
  if estimateTime == 0 or estimateTime == -1 then
    return guide_time
  end
  if coefficient == 0 then
    return guide_time
  end
  local LTMatchTimeThreshold = math.min(estimateTime * coefficient, guide_time)
  return LTMatchTimeThreshold
end
function logic_long_time_match:get_long_time_match_mode()
  local TimeUtil = require("client.common.time_util")
  self.LTLastReqTime = TimeUtil.GetServerTimeInSecWithFraction()
  self.LTReqCount = self.LTReqCount + 1
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local modeId, viewId = logic_mode_selection:GetCurSelectInfo()
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_get_long_time_match_mode(modeId, viewId)
end
function logic_long_time_match:on_get_long_time_match_mode_rsp(res, match_guide_cfg)
  if res ~= NetErrorCode_NONE then
    ShowNotice(res)
    return
  end
  if not next(match_guide_cfg) then
    return
  end
  self:SetIsShowLTMatch(true)
  self:ReportLTWindowInfo()
  self.LTMatchGuideInfo = match_guide_cfg
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_LT_GET_DATA)
end
function logic_long_time_match:ReportLTWindowInfo()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local modeId, viewId = logic_mode_selection:GetCurSelectInfo()
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local reportInfo = {
    Mode = modeId,
    ViewId = viewId,
    AlreadyMatchTime = MatchSystem.nLastTimeMatchingTime or 0,
    PredictTime = MatchSystem.nEstimateTime
  }
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_report_match_guide_window_info(reportInfo)
end
function logic_long_time_match:SetIsShowLTMatch(isShow)
  self.DisplayLTMatch = isShow
end
function logic_long_time_match:GetIsShowLTMatch()
  return self.DisplayLTMatch
end
function logic_long_time_match:GetLTMatchGuideInfo(recType)
  for _, info in ipairs(self.LTMatchGuideInfo or {}) do
    if recType == info.rec_type then
      return info
    end
  end
  return nil
end
function logic_long_time_match:GetRecommendTypeList()
  local recTypeList = {}
  if not (self.LTMatchTriggerConfig and self.LTMatchTriggerConfig.match_guide_conf) or not self.LTMatchTriggerConfig.match_guide_conf.type_level then
    return recTypeList
  end
  local StringUtil = require("common.string_util")
  local str = StringUtil.Split(self.LTMatchTriggerConfig.match_guide_conf.type_level, "|")
  for i = 1, #str do
    recTypeList[i] = tonumber(str[i])
  end
  return recTypeList
end
function logic_long_time_match:SetLTMatchSelectType(type)
  self.LTMatchSelectType = type
  local TimeUtil = require("client.common.time_util")
  self.LTMatchSelectTime = TimeUtil.GetServerTimeInSec()
end
function logic_long_time_match:IsSwitchLTMatchMode()
  return self.LTMatchSelectType ~= 0
end
function logic_long_time_match:TrySwitchLTMatchMode()
  self.LTMatchCancelTipsCount = 0
  self.LTReqCount = 0
  self:SetIsShowLTMatch(false)
  if not self.LTMatchGuideInfo then
    if self.LastTimeLTMatchInfo then
      self:ReportLTOperationInfo(true, false)
      self.LastTimeLTMatchInfo = nil
    end
    return
  end
  if not self:IsSwitchLTMatchMode() then
    self:ReportLTOperationInfo(false, false)
    self:ClearLTMatchInfo()
    return
  end
  local info = self:GetLTMatchGuideInfo(self.LTMatchSelectType)
  if not info then
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  logic_mode_selection:SetSelectView(info.view_id, info.map_info)
end
function logic_long_time_match:SwitchLTMatchModeSuccess(teamNum, perspective)
  log(bWriteLog and "logic_long_time_match:SwitchLTMatchModeSuccess")
  self:ClearLTMatchInfo(true)
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_LT_SWITCHMODE)
  local playerContentText = {
    [1] = 993048,
    [2] = 993049,
    [4] = 993050,
    [8] = 993098
  }
  local playerNumText = LocUtil.LocalizeResFormat(playerContentText[teamNum])
  local perspectText = LocUtil.LocalizeResFormat(perspective)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local _, viewId = logic_mode_selection:GetCurSelectInfo()
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local mapName = logic_mode_utils.GetMapNameByViewID(viewId, true) or ""
  local content = LocUtil.LocalizeResFormat(39039, mapName, perspectText, playerNumText)
  local noticeSystem = require("client.slua.logic.common.logic_notice_mgr")
  noticeSystem.RemoveAllNotice()
  ShowNotice(content)
end
function logic_long_time_match:IsShowLTMatchCancelTips()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local isShowCheckBox = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eMatchLTTipsCheckTime, true, 7)
  if not isShowCheckBox then
    log(bWriteLog and string.format("logic_long_time_match:IsShowLTMatchCancelTips isShowCheckBox:%s", tostring(isShowCheckBox)))
    return false
  end
  local almost_match_time_cfg = CDataTable.GetTableData("CancelMatchParams", "almost_match_time")
  local almost_match_time = almost_match_time_cfg and almost_match_time_cfg.Value or 5
  local cancel_match_remind_time_cfg = CDataTable.GetTableData("CancelMatchParams", "cancel_match_remind_time")
  local cancel_match_remind_time = cancel_match_remind_time_cfg and cancel_match_remind_time_cfg.Value or 60
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local matchingTime = MatchSystem.nMatchingTime
  local estimateTime = MatchSystem.nEstimateTime
  log(bWriteLog and string.format("logic_long_time_match:IsShowLTMatchCancelTips matchingTime:%s estimateTime:%s", matchingTime, estimateTime))
  if estimateTime < 0 then
    return false
  else
    if 0 < matchingTime - (estimateTime - almost_match_time) and cancel_match_remind_time >= matchingTime - (estimateTime - almost_match_time) then
      self.LTMatchCancelTipsCount = self.LTMatchCancelTipsCount + 1
      log(bWriteLog and string.format("logic_long_time_match:IsShowLTMatchCancelTips in time"))
      return true
    end
    if cancel_match_remind_time < matchingTime - (estimateTime - almost_match_time) then
      log(bWriteLog and string.format("logic_long_time_match:IsShowLTMatchCancelTips over time"))
      return false
    end
  end
  if not self.LTMatchTriggerConfig or not self.LTMatchTriggerConfig.match_cancel_guide_cfg then
    log(bWriteLog and string.format("logic_long_time_match:IsShowLTMatchCancelTips no info"))
    return false
  end
  local maxTime = self.LTMatchTriggerConfig.match_cancel_guide_cfg.max_time_threshold or 70
  local minTime = self.LTMatchTriggerConfig.match_cancel_guide_cfg.min_time_threshold or 20
  if matchingTime < minTime or matchingTime > maxTime then
    log(bWriteLog and string.format("logic_long_time_match:IsShowLTMatchCancelTips minTime:%s maxTime:%s", minTime, maxTime))
    return false
  end
  if self.LTMatchCancelTipsCount >= 2 then
    log(bWriteLog and string.format("logic_long_time_match:IsShowLTMatchCancelTips LTMatchCancelTipsCount:%s", tostring(self.LTMatchCancelTipsCount)))
    return false
  end
  self.LTMatchCancelTipsCount = self.LTMatchCancelTipsCount + 1
  return true
end
function logic_long_time_match:ReportLTMatchInfo()
  if not self.LTMatchGuideInfo and not self.LastTimeLTMatchInfo then
    return
  end
  if not self.LastTimeLTMatchInfo then
    self:ReportLTOperationInfo(false, true)
    self:ClearLTMatchInfo()
    return
  end
  self:ReportLTOperationInfo(true, true)
  self:ClearLTMatchInfo()
  self.LastTimeLTMatchInfo = nil
end
function logic_long_time_match:ReportLTOperationInfo(hasSwitch, isSuccess)
  local IsSwitch = 2
  local GapTime = 0
  local IsMatchSuccess = 2
  local WaitTime = 0
  if hasSwitch then
    IsSwitch = 1
    GapTime = math.ceil(self.LastTimeLTMatchInfo.LTMatchSelectTime - self.LTLastReqTime)
    local MatchSystem = require("client.slua.logic.match.logic_match")
    WaitTime = MatchSystem.nLastTimeMatchingTime or 0
  end
  if isSuccess then
    IsMatchSuccess = 1
  end
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_report_match_guide_operation_info(IsSwitch, GapTime, IsMatchSuccess, WaitTime)
end
function logic_long_time_match:ClearLTMatchInfo(isSave)
  if isSave then
    self.LastTimeLTMatchInfo = {
      LTMatchSelectType = self.LTMatchSelectType,
      LTMatchGuideInfo = self.LTMatchGuideInfo,
      LTMatchTriggerConfig = self.LTMatchTriggerConfig,
      LTMatchSelectTime = self.LTMatchSelectTime
    }
  end
  self.LTMatchSelectType = 0
  self.LTMatchGuideInfo = nil
  self.LTMatchTriggerConfig = nil
  self.LTMatchSelectTime = 0
end
function logic_long_time_match:CheckShowMatchUpdateTips(bCheckMatchTime)
  local version_util = require("client.common.version_util")
  local appVersion = version_util.GetCurVersionNumber()
  log(bWriteLog and "[v_vvjiali] logic_long_time_match:CheckShowMatchUpdateTips appVersion = " .. tostring(appVersion) .. " bCheckMatchTime = " .. tostring(bCheckMatchTime))
  local updateMatchCfg = CDataTable.GetTableData("UpdateMatchConfig", appVersion)
  if not updateMatchCfg then
    return false
  end
  local wait_time = updateMatchCfg.WaitTime
  local min_version = updateMatchCfg.MinVersion
  local max_version = updateMatchCfg.MaxVersion
  local start_time_str = updateMatchCfg.StartTime
  local end_time_str = updateMatchCfg.EndTime
  local appids = updateMatchCfg.AppIds
  log(bWriteLog and "[v_vvjiali] logic_long_time_match:CheckShowMatchUpdateTips" .. " wait_time " .. wait_time .. " min_version " .. min_version .. " max_version " .. max_version .. " start_time " .. start_time_str .. " end_time " .. end_time_str .. " appids " .. appids)
  if bCheckMatchTime then
    local MatchSystem = require("client.slua.logic.match.logic_match")
    if wait_time > MatchSystem.nMatchingTime then
      log(bWriteLog and "[v_vvjiali] logic_long_time_match:CheckShowMatchUpdateTips MatchSystem.nMatchingTime: " .. MatchSystem.nMatchingTime)
      return false
    else
      local TimeUtil = require("client.common.time_util")
      local diff_time = math.floor(TimeUtil.GetTimeZone() * 3600)
      local start_time = TimeUtil.TimeStringToUnixstamp(start_time_str, true)
      local end_time = TimeUtil.TimeStringToUnixstamp(end_time_str, true)
      local nowTime = TimeUtil.GetServerTimeInSec() - diff_time
      if start_time > nowTime or end_time < nowTime then
        log(bWriteLog and "[v_vvjiali] logic_long_time_match:CheckShowMatchUpdateTips nowTime: " .. nowTime .. " start_time " .. start_time .. " end_time " .. end_time)
        return false
      else
        return true
      end
    end
  else
    local version_util = require("client.common.version_util")
    local current_version = Client.GetAppVersion()
    if version_util.LowerVersion(current_version, min_version) or version_util.HigherVersion(current_version, max_version) then
      log(bWriteLog and "[v_vvjiali] logic_long_time_match:CheckShowMatchUpdateTips current_version: " .. current_version)
      return false
    end
    local gameId = Client.GetITopGameId()
    local StringUtil = require("common.string_util")
    local appIDs = StringUtil.Split(appids, "|")
    local bAppValid = false
    for _, id in ipairs(appIDs) do
      if id == gameId then
        bAppValid = true
        break
      end
    end
    if not bAppValid then
      log(bWriteLog and "[v_vvjiali] logic_long_time_match:CheckShowMatchUpdateTips gameId: " .. gameId)
      return false
    end
    return true
  end
end
function logic_long_time_match:ShowMatchUpdateTips()
  local extraData = {
    showUIKey = "Lobby_UpdateGuide_Popup_UIBP"
  }
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_ONE, nil, LocUtil.GetLocalizeResStr(655661), nil, nil, nil, nil, extraData)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_long_time_match = class(CModuleBase, nil, logic_long_time_match)
return Clogic_long_time_match