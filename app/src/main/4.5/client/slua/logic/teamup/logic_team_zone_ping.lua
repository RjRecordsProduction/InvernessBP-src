local logic_team_zone_ping = {}
local Enum_Net_Type = {Signal = 1, Wifi = 2}
logic_team_zone_ping.local Enum_Net_State = {
  No = 1,
  Connecting = 2,
  Good = 3,
  Average = 4,
  Poor = 5
}
logic_team_zone_ping.local TimeUtil = require("client.common.time_util")
function logic_team_zone_ping:DefineAndResetData()
  self.pings = {}
  self.limitsConfig = nil
  self.showTipsUIDList = {}
  self.lobbyGmData = nil
  self.inGameGmData = nil
  self.lastSycnTime = {}
  self.bIsUseLeaderStrategy = nil
  self.strategyTeamPingMap = {}
  self.strategyLeaderPingMap = {}
end
function logic_team_zone_ping:SetLobbyGMData(pingData)
  self.lobbyGmData = pingData
end
function logic_team_zone_ping:_GMSetLobbyCrossShow()
  self.GMlobbyCrossShow = not self.GMlobbyCrossShow
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CROSS_MATCH_NOTIFY)
end
function logic_team_zone_ping:GMGetLobbyCrossShow()
  return self.GMlobbyCrossShow
end
function logic_team_zone_ping:OnInitialize()
end
function logic_team_zone_ping:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_ADD_OTHER_PLAYER, self.OnAddOtherPlayer, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CREATE_TEAM, self.OnAddOtherPlayer, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_BE_KICKED_OUT, self.OnQuit, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_EXIT_OTHER_PLAYER, self.OnExitMember, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_LEADER_NOTIFY, self.OnTeamChangeLeader, self)
end
function logic_team_zone_ping:OnLogin(bReLogin)
end
function logic_team_zone_ping:OnLogOut()
end
function logic_team_zone_ping:OnPreSwitchGameStatus(preState, nextState)
end
function logic_team_zone_ping:OnPostSwitchGameStatus(preState, nextState)
end
function logic_team_zone_ping:OnTeamChangeLeader()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInTeam() and not TeamUpNewSystem.IsTeamLeader() then
    self.bIsUseLeaderStrategy = nil
  end
end
function logic_team_zone_ping:OnExitMember(_, _, uid)
  if tostring(uid) == DataMgr.roleData.uid then
    self:ClearChangeLeaderInfo()
    self.bIsUseLeaderStrategy = nil
  end
end
function logic_team_zone_ping:OnAddOtherPlayer()
  self.isAddMember = true
end
function logic_team_zone_ping:OnQuit()
  self.lastSycnTime = {}
  self.bIsUseLeaderStrategy = nil
end
function logic_team_zone_ping:GetTeamZonePing()
  return self.pings
end
function logic_team_zone_ping:GetMemberZonePing(uid)
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    return self:GetSelfPingData()
  end
  return self.pings[uid]
end
function logic_team_zone_ping:GetPingLevelLimits()
  if self.pingLevelLimits then
    return self.pingLevelLimits
  end
  local config = CDataTable.GetTableData("SystemConfig", "TeamupPingLevelLimit")
  local Limits = "200;500"
  if config then
    Limits = config.ConfigValue
  end
  local StringUtil = require("common.string_util")
  self.pingLevelLimits = StringUtil.SplitToNum(Limits, ";")
  return self.pingLevelLimits
end
function logic_team_zone_ping:GetPingSycnCD()
  local config = CDataTable.GetTableData("SystemConfig", "TeamupPingSycnCD")
  local CD = 60
  if config then
    CD = tonumber(config.ConfigValue)
  end
  return CD
end
function logic_team_zone_ping:GetCrossNextShowCD()
  local config = CDataTable.GetTableData("SystemConfig", "CrossNextShowCD")
  local CD = 90
  if config then
    CD = tonumber(config.ConfigValue)
  end
  return CD
end
function logic_team_zone_ping:UpdateTeamZonePing(pings)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local teamID = TeamUpNewSystem:GetTeamID()
  if not teamID then
    log(bWriteLog and "logic_team_zone_ping:UpdateTeamZonePing not teamID")
    return
  end
  for uid, _ in pairs(self.pings or {}) do
    if not TeamUpNewSystem.GetMemberInfo(uid) then
      self.pings[uid] = nil
    end
  end
  for uid, data in pairs(pings) do
    if TeamUpNewSystem.GetMemberInfo(uid) and data.ping ~= -1 then
      self.pings[uid] = data
    end
  end
  local TableUtil = require("common.table_util")
  if TableUtil.CountTable(self.pings) == TeamUpNewSystem.GetTeamNum() then
    self.lastSycnTime[teamID] = TimeUtil.GetServerTimeInSec()
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_MEMBER_PING_CHANGE, self.pings)
    if self.isAddMember then
      self.isAddMember = false
      self:EnterTeamOtherTips()
    end
  end
end
function logic_team_zone_ping:GetPingState(ping)
  if not ping then
    return Enum_Net_State.No
  end
  local range = self:GetPingLevelLimits()
  local left = range[1]
  local right = range[2]
  local hasNetwork = ping < 10000 and ping ~= 0
  if hasNetwork then
    if ping <= left then
      return Enum_Net_State.Good
    elseif ping <= right then
      return Enum_Net_State.Average
    else
      return Enum_Net_State.Poor
    end
  else
    local isConnecting = ping == 0
    if isConnecting then
      return Enum_Net_State.Connecting
    else
      return Enum_Net_State.No
    end
  end
end
function logic_team_zone_ping:ShowPingTips(uid)
  local pingData = self:GetMemberZonePing(uid)
  if not pingData then
    log(bWriteLog and string.format("logic_team_zone_ping:ShowPingTips, not pingData:%s", pingData))
    return
  end
  local state = self:GetPingState(pingData.ping)
  if state < Enum_Net_State.Average then
    log(bWriteLog and string.format("logic_team_zone_ping:ShowPingTips, state < Enum_Net_State.Average:%s", state))
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local info = TeamUpNewSystem.GetMemberInfo(uid)
  local isWifi = pingData.net_type == Enum_Net_Type.Wifi
  if uid == tonumber(DataMgr.roleData.uid) then
    if info and info.play_zone == TeamUpNewSystem:GetTeamZoneID() then
      if state == Enum_Net_State.Average then
        if isWifi then
          ShowNotice(LocUtil.LocalizeResFormat(65360, pingData.ping))
        else
          ShowNotice(LocUtil.LocalizeResFormat(65362, pingData.ping))
        end
      elseif state == Enum_Net_State.Poor then
        if isWifi then
          ShowNotice(LocUtil.LocalizeResFormat(65361, pingData.ping))
        else
          ShowNotice(LocUtil.LocalizeResFormat(65363, pingData.ping))
        end
      end
    elseif state == Enum_Net_State.Average then
      if isWifi then
        ShowNotice(LocUtil.LocalizeResFormat(65352, pingData.ping))
      else
        ShowNotice(LocUtil.LocalizeResFormat(65354, pingData.ping))
      end
    elseif state == Enum_Net_State.Poor then
      if isWifi then
        ShowNotice(LocUtil.LocalizeResFormat(65353, pingData.ping))
      else
        ShowNotice(LocUtil.LocalizeResFormat(65355, pingData.ping))
      end
    end
  elseif info and info.play_zone == TeamUpNewSystem:GetTeamZoneID() then
    if state == Enum_Net_State.Average then
      if isWifi then
        ShowNotice(LocUtil.LocalizeResFormat(65356, info.name, pingData.ping))
      else
        ShowNotice(LocUtil.LocalizeResFormat(65358, info.name, pingData.ping))
      end
    elseif state == Enum_Net_State.Poor then
      if isWifi then
        ShowNotice(LocUtil.LocalizeResFormat(65357, info.name, pingData.ping))
      else
        ShowNotice(LocUtil.LocalizeResFormat(65359, info.name, pingData.ping))
      end
    end
  elseif info and info.name then
    if state == Enum_Net_State.Average then
      if isWifi then
        ShowNotice(LocUtil.LocalizeResFormat(65348, info.name, pingData.ping))
      else
        ShowNotice(LocUtil.LocalizeResFormat(65350, info.name, pingData.ping))
      end
    elseif state == Enum_Net_State.Poor then
      if isWifi then
        ShowNotice(LocUtil.LocalizeResFormat(65349, info.name, pingData.ping))
      else
        ShowNotice(LocUtil.LocalizeResFormat(65351, info.name, pingData.ping))
      end
    end
  end
end
function logic_team_zone_ping:EnterTeamOtherTips()
  local maxPing = 0
  local targetUID
  for uid, data in pairs(self.pings or {}) do
    if maxPing < data.ping then
      targetUID = uid
      maxPing = data.ping
    end
  end
  self:ShowPingTips(targetUID)
end
function logic_team_zone_ping:ReportSelfPing(isForce)
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "logic_team_zone_ping:ReportSelfPing not in lobby")
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not isForce then
    local teamID = TeamUpNewSystem:GetTeamID()
    if not teamID then
      log(bWriteLog and "logic_team_zone_ping:ReportSelfPing not teamID")
      return
    end
    local lastReqTime = self.lastSycnTime[teamID]
    if lastReqTime and TimeUtil.GetServerTimeInSec() - lastReqTime < self:GetPingSycnCD() then
      log(bWriteLog and "logic_team_zone_ping:ReportSelfPing in sycn cd")
      return
    end
  end
  if not isForce and TeamUpNewSystem.GetTeamNum() <= 1 then
    log(bWriteLog and string.format("logic_team_zone_ping:ReportSelfPing, TeamUpNewSystem.GetTeamNum() <= 1:%s", TeamUpNewSystem.GetTeamNum()))
    return
  end
  if self.lobbyGmData then
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    TeamupHandler.send_report_play_zone_ping(tonumber(self.lobbyGmData[1]), tonumber(self.lobbyGmData[2]))
    return
  end
  local pingData = self:GetSelfPingData()
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_report_play_zone_ping(pingData.ping, pingData.net_type)
end
function logic_team_zone_ping:GetSelfPingData()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local teamZoneID = TeamUpNewSystem.GetTeamZoneID()
  log(bWriteLog and string.format("logic_team_zone_ping:GetSelfPingData, teamZoneID:%s", teamZoneID))
  local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
  local ping = logic_zone_delay.GetZoneDelay(teamZoneID, 10000, 10000)
  log(bWriteLog and string.format("logic_team_zone_ping:GetSelfPingData, ping:%s", ping))
  local net_type = Client.HasActiveWifi() and Enum_Net_Type.Wifi or Enum_Net_Type.Signal
  return {ping = ping, net_type = net_type}
end
function logic_team_zone_ping:InGameDelayShow()
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  if logic_ugc_mode:IsSelectUgcMode() then
    log(bWriteLog and "logic_team_zone_ping:InGameDelayShow, is ugc mode")
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "logic_team_zone_ping:InGameDelayShow, is t mode")
    return
  end
  local BusinessHelper = import("BusinessHelper")
  local networkState = BusinessHelper.GetCurrentNetworkState()
  if self.lobbyGmData then
    networkState = tonumber(self.lobbyGmData[2])
  end
  if networkState == 0 then
    log(bWriteLog and string.format("logic_team_zone_ping:InGameDelayShow, networkState:%s", networkState))
    return false
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local teamZoneID = TeamUpNewSystem.GetTeamZoneID()
  local info = TeamUpNewSystem.GetMemberInfo(tonumber(DataMgr.roleData.uid))
  if not info then
    log_tree(bWriteLog and "logic_team_zone_ping:InGameDelayShow not info", info)
    return false
  end
  if teamZoneID == info.play_zone then
    log(bWriteLog and string.format("logic_team_zone_ping:InGameDelayShow, same play_zone %s", teamZoneID))
    return false
  end
  local playerPing = -1
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  if slua.isValid(uPlayerController) then
    playerPing = STExtraBlueprintFunctionLibrary.GetPlayerPing(uPlayerController)
  end
  if self.lobbyGmData then
    playerPing = tonumber(self.lobbyGmData[1])
  end
  if playerPing < 0 then
    log(bWriteLog and string.format("logic_team_zone_ping:InGameDelayShow, playerPing < 0 %s", playerPing))
    return false
  end
  local playerPingSignal = STExtraBlueprintFunctionLibrary.GetPlayerPingSignal(playerPing)
  if playerPingSignal == 0 then
    log(bWriteLog and string.format("logic_team_zone_ping:InGameDelayShow, playerPing good %s", playerPing))
    return false
  end
  log(bWriteLog and string.format("logic_team_zone_ping:InGameDelayShow, playerPing %s", playerPing))
  return true, playerPingSignal, networkState
end
function logic_team_zone_ping:ShowSwitchLeaderPopup()
  local changeLeaderInfo = self.ChangeLeaderInfo
  if not changeLeaderInfo then
    log(bWriteLog and "logic_team_zone_ping:ShowSwitchLeaderPopup not changeLeaderInfo")
    return
  end
  local strMsg = LocUtil.LocalizeResFormat(69277, changeLeaderInfo.reduce_ping, changeLeaderInfo.newLeaderName, changeLeaderInfo.serverName, changeLeaderInfo.predict_time, changeLeaderInfo.reduce_ping)
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportImmediate(TLogEventDefine.Reduce_Ping_Switch_Leader_Popup_Show)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_FOUR, nil, strMsg, function()
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    TeamupHandler.send_cross_zone_allow_change_leader(changeLeaderInfo.old_leader, changeLeaderInfo.new_leader)
    BasicDataTLogReport:ReportImmediate(TLogEventDefine.Reduce_Ping_Switch_Leader_Popup_Confirm)
  end)
end
function logic_team_zone_ping:GetChangeLeaderInfo()
  return self.ChangeLeaderInfo
end
function logic_team_zone_ping:ClearChangeLeaderInfo()
  self.ChangeLeaderInfo = nil
end
function logic_team_zone_ping:IsUseLeaderStrategy()
  return self.bIsUseLeaderStrategy
end
function logic_team_zone_ping:GetStrategyTeamPingMap()
  return self.strategyTeamPingMap
end
function logic_team_zone_ping:GetStrategyLeaderPingMap()
  return self.strategyLeaderPingMap
end
function logic_team_zone_ping:GetNotCrossMatch()
  return self.notCrossMatch
end
function logic_team_zone_ping:SetNotCrossMatch(ext_info)
  log_tree(bWriteLog and "logic_team_zone_ping:SetNotCrossMatch ext_info", ext_info)
  if ext_info and type(ext_info) == "table" then
    self.notCrossMatch = ext_info.not_cross_shadow
    return
  end
  self.notCrossMatch = nil
end
function logic_team_zone_ping:SetReOpenCrossTimer(data)
  if self.reOpenCrossTimer then
    self:RemoveTimer(self.reOpenCrossTimer)
    self.reOpenCrossTimer = nil
  end
  local nextShowTime = self:GetCrossNextShowCD()
  self.reOpenCrossTimer = self:AddTimerOnce(nextShowTime, function()
    local MatchSystem = require("client.slua.logic.match.logic_match")
    if MatchSystem.nMatchStatus ~= ENUM_MatchStatus.Matching then
      return
    end
    if not GameStatus.IsInLobbyOrMainCity() then
      return
    end
    if UIManager.GetUI(UIManager.UI_Config.Lobby_ExpandMatching_Popup_UIBP) then
      return
    end
    UIManager.ShowUI(UIManager.UI_Config.Lobby_ExpandMatching_Popup_UIBP, data)
    self.reOpenCrossTimer = nil
  end)
end
function logic_team_zone_ping:on_cross_zone_change_leader_notify(old_leader, new_leader, reduce_ping, predict_time, type)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local info = TeamUpNewSystem.GetMemberInfo(new_leader)
  local teamZoneID = info and info.play_zone
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  local serverName = logic_multiple_area:GetDisplayNameByZoneID(teamZoneID)
  local newLeaderInfo = TeamUpNewSystem.GetMemberInfo(new_leader)
  local newLeaderName = newLeaderInfo and newLeaderInfo.name or DataMgr.roleData.nickName
  if type == 1 then
    self.ChangeLeaderInfo = {
      old_leader = old_leader,
      new_leader = new_leader,
      reduce_ping = reduce_ping,
      newLeaderName = newLeaderName,
      serverName = serverName,
          }
    self:ShowSwitchLeaderPopup()
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_ZONE_CHANGE_LEADER_NOTIFY)
  end
  local myUId = tonumber(DataMgr.roleData.uid)
  if type == 2 then
    local oldLeaderInfo = TeamUpNewSystem.GetMemberInfo(old_leader)
    local oldLeaderName = oldLeaderInfo and oldLeaderInfo.name or DataMgr.roleData.nickName
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    if new_leader == myUId then
      local strMsg = LocUtil.LocalizeResFormat(69275, oldLeaderName, serverName, reduce_ping)
      CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_THREE, nil, strMsg)
    elseif old_leader == myUId then
      self:ClearChangeLeaderInfo()
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_ZONE_CHANGE_LEADER_NOTIFY)
      local strMsg = LocUtil.LocalizeResFormat(69274, newLeaderName, serverName, reduce_ping)
      CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_THREE, nil, strMsg)
    else
      local strMsg = LocUtil.LocalizeResFormat(69276, oldLeaderName, newLeaderName, serverName, reduce_ping)
      CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_THREE, nil, strMsg)
    end
  end
end
function logic_team_zone_ping:on_only_leader_ping_notify(team_ping_map, leader_ping_map, is_open)
  self.strategyTeamPingMap = team_ping_map
  self.strategyLeaderPingMap = leader_ping_map
  self.bIsUseLeaderStrategy = is_open
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_MATCH_STRATEGY_NOTIFY)
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportImmediate(TLogEventDefine.Reduce_Team_Ping_Strategy_Popup_Show)
end
function logic_team_zone_ping:on_change_only_leader_ping_rsp(is_open)
  self.bIsUseLeaderStrategy = is_open
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_MATCH_STRATEGY_NOTIFY)
end
function logic_team_zone_ping:on_change_cross_shadow_notify(not_cross, add_ping, plan_type)
  self.notCrossMatch = not_cross
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  local data = {
    not_cross = not_cross,
    add_ping = add_ping,
      }
  UIManager.ShowUI(UIManager.UI_Config.Lobby_ExpandMatching_Popup_UIBP, data)
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportImmediate(TLogEventDefine.Team_Cross_Match_Popup_Show)
end
function logic_team_zone_ping:on_change_cross_shadow_rsp(not_cross, save_change)
  self.notCrossMatch = not_cross
  if save_change then
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CROSS_MATCH_NOTIFY)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_team_zone_ping = class(CModuleBase, nil, logic_team_zone_ping)
return Clogic_team_zone_ping