local Logic_UGC_Match = {
  matchInfo = nil,
  editMatchInfo = nil,
  nModID = 0,
  bUseDirectEdit = true,
  bLockGetLastGame = false,
  nLastMatchTime = 0,
  nLastRoomMatchTime = 0,
  StandAloneTemplateID = 0,
  StandAloneMetaData = nil
}
local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
local modulemacro = require("client.module_framework.ModuleMacro")
local _SubModeMap = {
  [UGCMacros.EDIT_SUB_MODE] = 0,
  [600080] = 0,
  [880001] = 0,
  [880002] = 0,
  [880003] = 0,
  [880004] = 0,
  [880005] = 0,
  [880006] = 0,
  [880007] = 0,
  [880008] = 0,
  [880000] = 0
}
for i = 1, #UGCMacros.UGC_SUB_GAME_MODE_ID_LIST do
  _SubModeMap[UGCMacros.UGC_SUB_GAME_MODE_ID_LIST[i]] = 0
end
Logic_UGC_Match.
function Logic_UGC_Match:DefineAndResetData()
  self.bUGCWaitingEnterGame = false
end
function Logic_UGC_Match:SetUGCWaitingEnterGame(bUGCWaitingEnterGame)
  log(bWriteLog and "Logic_UGC_Match:SetUGCWaitingEnterGame bUGCWaitingEnterGame = " .. tostring(bUGCWaitingEnterGame) .. " self.bUGCWaitingEnterGame = " .. tostring(self.bUGCWaitingEnterGame))
  self.end
function Logic_UGC_Match:IsInUGCWaitingEnterGame()
  return self.bUGCWaitingEnterGame
end
function Logic_UGC_Match:OnLogOut()
  self:ClearData()
  self.bLockGetLastGame = nil
end
function Logic_UGC_Match:RegistEvents()
  if EVENTTYPE_MATCH ~= nil then
    self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS_MATCHING_OR_NOT, self.OnMatchUpdateStatusMatchingOrNot, self)
  end
end
function Logic_UGC_Match:UnRegist()
  Logic_UGC_Match.__super.Dispose(self)
end
function Logic_UGC_Match:OnPostSwitchGameStatus(preState, nextState)
  self.bLockGetLastGame = nil
  if nextState == GameStatus.Login then
    self:ClearData()
  end
end
function Logic_UGC_Match:ClearData()
  self.matchInfo = nil
  self.editMatchInfo = nil
  self.nModID = 0
  self.bIsCreativeWoW = false
  self.PendingMatchChoose = false
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CHANGE_MOD_NOTIFY, true)
end
function Logic_UGC_Match:GetEnterGameModInfo()
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModInfo
  local LogicLobbyWatching = require("client.logic.watching.logic_lobby_watching")
  if LogicLobbyWatching.watchFriend_ModInfo then
    ModInfo = LogicLobbyWatching.watchFriend_ModInfo.pub_mod_meta
    LogicLobbyWatching.watchFriend_ModInfo = nil
  end
  if not ModInfo then
    local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
    local ModId = LogicUGCMulti:GetMatchMod()
    if ModId then
      local ModData = LogicUGC:GetModByAllCache(ModId)
      if ModData then
        ModInfo = ModData.pub_mod_meta
      end
    end
  end
  if not ModInfo then
    local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
    local ModId = UGCPlayHallRoom:GetStartMatchModID()
    local ModData = ModId and LogicUGC:GetModByAllCache(ModId)
    if ModData then
      ModInfo = ModData.pub_mod_meta
    end
  end
  ModInfo = ModInfo or self:GetUgcMatchModInfo()
  return ModInfo
end
function Logic_UGC_Match:MarkPendingBackToWoWPlayhall()
  print(bWriteLog and "Logic_UGC_Match:MarkPendingBackToWoWPlayhall")
  self.bPendingExitToLobby = true
end
function Logic_UGC_Match:OnMatchUpdateStatusMatchingOrNot(_, __, status)
  print(bWriteLog and "Logic_UGC_Match:OnMatchUpdateStatusMatchingOrNot")
  local E_MatchStatus = ENUM_MatchStatus
  if self.bPendingExitToLobby and status == E_MatchStatus.Not then
    GlobalData.JumpUrl("game://?module=1008403&menuList=900")
    self.bPendingExitToLobby = nil
  end
end
function Logic_UGC_Match:HasUGCMatchInfo()
  if self:GetEditMatchInfo() or self:GetMatchInfo() then
    return true
  end
  return false
end
function Logic_UGC_Match:GetMatchInfo()
  return self.matchInfo
end
function Logic_UGC_Match:GetMatchModID()
  return self.matchInfo and self.matchInfo.mod_id or self.nModID
end
function Logic_UGC_Match:GetUgcMatchModInfo()
  log(bWriteLog and "Logic_UGC_Match:GetUgcMatchModInfo")
  local matchInfo = self:GetMatchInfo()
  if not matchInfo then
    log(bWriteLog and "Logic_UGC_Match:GetUgcMatchModInfo no matchinfo")
    return nil
  end
  local modId = matchInfo.mod_id
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local cacheMod = LogicUGC:GetModByAllCache(modId)
  if not cacheMod then
    log(bWriteLog and "Logic_UGC_Match:GetUgcMatchModInfo no cacheinfo")
    return nil
  end
  return cacheMod.pub_mod_meta
end
function Logic_UGC_Match:SetIsCreativeWoW(bIsCreativeWoW)
  self.end
function Logic_UGC_Match:IsCreativeWoW()
  return self.bIsCreativeWoW
end
function Logic_UGC_Match:SetModID(modID)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  logic_mode_selection:HasSelectMetroTxMission(0)
  self.nModID = modID
  self:ReqGetLastGame()
end
function Logic_UGC_Match:GetEditMatchInfo()
  return self.editMatchInfo
end
function Logic_UGC_Match:CleanEditMatchInfo(bIsTeamLeader)
  self.editMatchInfo = nil
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CHANGE_MOD_NOTIFY, true)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_EDITMATCH_SELECTCHANGE, bIsTeamLeader)
end
function Logic_UGC_Match:SetEditMatchInfoByModInfo(modInfo)
  if not modInfo then
    return
  end
  self.editMatchInfo = {
    slot = modInfo.base.slot,
    name = modInfo.setting.name,
    template_id = modInfo.base.template_id,
    thumb_info = modInfo.setting.album[modInfo.setting.thumb_index] or {}
  }
  self:HandleEnterUGC()
end
function Logic_UGC_Match:IsUGCSingleMatchMode(MatchMode)
  MatchMode = tonumber(MatchMode)
  if not MatchMode then
    return false
  end
  if 1001 <= MatchMode and MatchMode <= 1008 then
    return true
  end
  return false
end
function Logic_UGC_Match:IsUGCMode(submode)
  if not submode then
    return false
  end
  return _SubModeMap[submode] == 0
end
function Logic_UGC_Match:IsUGCEditMode(submode)
  if not submode then
    return false
  end
  return submode == UGCMacros.EDIT_SUB_MODE
end
function Logic_UGC_Match:IsCanWatchUGCMode(submode)
  if not submode then
    return false
  end
  if not self:IsUGCMode(submode) then
    return false
  end
  if submode == UGCMacros.EDIT_SUB_MODE or submode == UGCMacros.UGC_WOW_SUB_MODE then
    return false
  end
  for _, modeID in ipairs(UGCMacros.UGC_SUB_GAME_MODE_ID_LIST) do
    if submode == modeID then
      return false
    end
  end
  return true
end
function Logic_UGC_Match:UpdateLastMatchTime()
  local TimeUtil = require("client.common.time_util")
  self.nLastMatchTime = TimeUtil.GetServerTimeInSec()
  self.StandAloneTemplateID = 0
end
function Logic_UGC_Match:UpdateLastRoomMatchTime()
  local TimeUtil = require("client.common.time_util")
  self.nLastRoomMatchTime = TimeUtil.GetServerTimeInSec()
  self.StandAloneTemplateID = 0
end
function Logic_UGC_Match:GetCurrentMatchInfoForFight()
  if self.nLastRoomMatchTime > self.nLastMatchTime then
    return RoomSystem.CurrentRoomInfo and RoomSystem.CurrentRoomInfo.ugc_room_param or nil
  else
    return self:GetMatchInfo()
  end
end
function Logic_UGC_Match:ReqStartGame(From)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if not Config_UGC.IsUGCReleased() then
    return
  end
  if self.PendingMatchChoose then
    return
  end
  if LobbySystem.isInMatch then
    ShowNotice(6244)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() then
    ShowNotice(70010)
    return
  end
  local MatchInfo = self:GetMatchInfo()
  if MatchInfo then
    local TeamNum = TeamUpNewSystem.GetTeamNum()
    local Util_UGC = require("client.slua.logic.ugc.util_ugc")
    local ModTeamSize = Util_UGC.GetModTeamSize(MatchInfo)
    if TeamNum > ModTeamSize then
      ShowNotice(8600142)
      return
    end
  end
  local ModInfo = self:GetUgcMatchModInfo()
  if ModInfo then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
    local State = LogicUGCResManager:GetResState(LogicUGCResManager.DownloaderType.ModCopy, ModInfo)
    if State ~= PufferConst.ENUM_DownloadState.Done then
      local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
      logic_ugc_mode:ShowCurSelectUGCModDownloadNotice()
      return
    end
    local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
    local bPrivate = LogicUGCCRUD:CheckPubModIsPrivate(ModInfo)
    if bPrivate and tonumber(ModInfo.base.uid) ~= tonumber(DataMgr.roleData.uid) then
      ShowNotice(LocUtil.GetLocalizeResStr(10120054))
      return
    end
  end
  log(bWriteLog and "Logic_UGC_Match:ReqStartGame modID = " .. self.nModID .. " FromType = " .. tostring(From))
  local Logic_UGC_Share = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_share)
  local share_info = Logic_UGC_Share:GetShareData()
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
  if UGCPlayHallRoom:IsSystemOpen() then
    local Util_UGC = require("client.slua.logic.ugc.util_ugc")
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local ModInfo = LogicUGC:GetModByAllCache(self.nModID)
    if slua.isValid(CGameState) and CGameState.IsCreativeMode and CGameState:IsCreativeMode() and CGameState.bIsCreativeWoW or Util_UGC.IsSubModeGameMod(ModInfo and ModInfo.pub_mod_meta) then
      local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
      Logic_UGC_TLog:SendInteractionTLog(UGCMacros.ENU_UGC_TLOG_REACH_TYPE.START_MATCH, self.nModID)
      UGCModHandler.send_ugc_multi_match_req({
        self.nModID
      }, false, nil, nil, nil, share_info)
      log(bWriteLog and "Logic_UGC_Match:ReqStartGame ClearShareData")
      Logic_UGC_Share:ClearShareData()
    else
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      local TLogStr = string.format("{ModID:%d From:%s}", self.nModID or 0, From)
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.UGC_PlayHall_Room_Click_StartEntry_Lobby, 0, TLogStr)
      local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
      Logic_UGC_TLog:SendInteractionTLog(UGCMacros.ENU_UGC_TLOG_REACH_TYPE.START_MATCH, self.nModID)
      UGCPlayHallRoom:StartUGCMatch(function(HotStat, ModID)
        local StartType = HotStat.start_type
        local Logic_UGC_Share = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_share)
        local share_info1 = Logic_UGC_Share:GetShareData()
        local wow_newbie_guide_match
        local logic_ugc_new_process = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_process)
        if logic_ugc_new_process:CheckIsOpen() and logic_ugc_new_process:GetNewProcessSelectId() then
          wow_newbie_guide_match = 1
        end
        if StartType and StartType == Config_UGC.E_UGCGameStartType.Smart then
          if HotStat.heat_level == Config_UGC.E_UGCSmartStartHeatLevelState.QuickStart then
            UGCPlayHallRoom:SendJoinPlayHallRoomReq(self.nModID, Config_UGC.E_UGCJoinPlayHallType.HallFirst, {share_ext = share_info1, wow_newbie_guide_match = wow_newbie_guide_match})
            log(bWriteLog and "Logic_UGC_Match:ReqStartGame ClearShareData")
            Logic_UGC_Share:ClearShareData()
          else
            if self.nModID > 0 then
              local ExtraParam = {try_match_before_playhall = true, wow_newbie_guide_match = wow_newbie_guide_match}
              UGCModHandler.send_ugc_multi_match_req({
                self.nModID
              }, false, nil, nil, nil, share_info, ExtraParam)
              UGCPlayHallRoom:SetPendingMatchParamRecord(self.nModID, {share_ext = share_info1})
            end
            log(bWriteLog and "Logic_UGC_Match:ReqStartGame ClearShareData")
            Logic_UGC_Share:ClearShareData()
            print(bWriteLog and "Logic_UGC_Match:ReqStartGame QuickGameJoinPendingWaiting")
          end
        else
          if self.nModID > 0 then
            UGCModHandler.send_ugc_multi_match_req({
              self.nModID
            }, false, nil, nil, nil, share_info, {wow_newbie_guide_match = wow_newbie_guide_match})
          end
          log(bWriteLog and "Logic_UGC_Match:ReqStartGame ClearShareData")
          Logic_UGC_Share:ClearShareData()
        end
      end)
    end
  else
    local wow_newbie_guide_match
    local logic_ugc_new_process = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_process)
    if logic_ugc_new_process:CheckIsOpen() and logic_ugc_new_process:GetNewProcessSelectId() then
      wow_newbie_guide_match = 1
    end
    if self.nModID > 0 then
      UGCModHandler.send_ugc_multi_match_req({
        self.nModID
      }, false, nil, nil, nil, share_info, {wow_newbie_guide_match = wow_newbie_guide_match})
    end
    log(bWriteLog and "Logic_UGC_Match:ReqStartGame ClearShareData")
    Logic_UGC_Share:ClearShareData()
    local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
    Logic_UGC_TLog:SendInteractionTLog(UGCMacros.ENU_UGC_TLOG_REACH_TYPE.START_MATCH, self:GetMatchModID())
  end
  local LogicUGCExposure = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCExposure)
  LogicUGCExposure:UserStartMatch(self.nModID)
end
function Logic_UGC_Match:ReqGetLastGame()
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if not Config_UGC.IsUGCReleased() then
    return
  end
  if self.bLockGetLastGame then
    return
  end
  self.bLockGetLastGame = true
  self:AddTimerOnce(0.5, function()
    self.bLockGetLastGame = false
  end)
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_get_last_game_req()
end
function Logic_UGC_Match:ReqChooseModForMatch(modID)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if not Config_UGC.IsUGCReleased() then
    return false
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 and TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
    for UID, MemberInfo in pairs(TeamUpNewSystem.teamInfo.members) do
      if tonumber(UID) ~= TeamUpNewSystem.GetSelfUID() then
        local Level = MemberInfo.level
        if not Config_UGC.IsUGCUnlock(Level) then
          ShowNotice(LocUtil.LocalizeResFormat(7925, MemberInfo.name))
          return false
        end
      end
    end
  end
  local Logic_UGC_TLog = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_TLog)
  local Source_Info = Logic_UGC_TLog:GetUGCMatchSourceInfo(modID)
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_choose_mod_for_match_req(modID, Source_Info)
  local LogicUGCExposure = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCExposure)
  LogicUGCExposure:ClearMayState()
  self.PendingMatchChoose = true
  return true
end
function Logic_UGC_Match:ReqEditModMatch(slot)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if not Config_UGC.IsUGCReleased() then
    return
  end
  if LobbySystem.isInMatch then
    ShowNotice(6244)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() then
    ShowNotice(70010)
    return
  end
end
function Logic_UGC_Match:OnMatchRsp(modID, ugcMatchInfo)
  log(bWriteLog and "[edward] Logic_UGC_Match:OnMatchRsp mod_id = " .. tostring(modID))
  log_tree(bWriteLog and "[edward] Logic_UGC_Match:OnMatchRsp", ugcMatchInfo)
  self.matchInfo = ugcMatchInfo
  self.nModID = self.matchInfo and self.matchInfo.mod_id or 0
  self:HandleEnterUGC()
end
function Logic_UGC_Match:OnMatchRes(msg, waitTime)
end
function Logic_UGC_Match:OnGetLastGameRsp(ugcMatchInfo)
  log_tree(bWriteLog and "[edward] Logic_UGC_Match:OnGetLastGameRsp", ugcMatchInfo)
  local isInfoChange = false
  if not self.matchInfo and not ugcMatchInfo then
    isInfoChange = false
  elseif self.matchInfo and ugcMatchInfo then
    if self.matchInfo.mod_id == ugcMatchInfo.mod_id then
      isInfoChange = false
    else
      isInfoChange = true
    end
  else
    isInfoChange = true
  end
  self.matchInfo = ugcMatchInfo
  log_warning(bWriteLog and "Logic_UGC_Match:OnGetLastGameRsp.mod_id=" .. tostring(self.matchInfo and self.matchInfo.mod_id))
  self.nModID = self.matchInfo and self.matchInfo.mod_id or 0
  if self.nModID > 0 then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local TempCache = LogicUGC:GetCacheByType(UGCMacros.ENUM_MODE_TYPE.UgcMatch) or {}
    local TempReqCache = LogicUGC:GetMatchModIsReq(UGCMacros.ENUM_MODE_TYPE.UgcMatch) or {}
    LogicUGC:ClearModCacheByType(UGCMacros.ENUM_MODE_TYPE.UgcMatch, true)
    if TempCache[self.nModID] then
      LogicUGC:SetMatchCache(self.nModID, TempCache[self.nModID])
    end
    if TempReqCache[self.nModID] then
      LogicUGC:SetMatchReqCache(self.nModID)
    end
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ShowExtraTeamUI()
  self:HandleEnterUGC()
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CHANGE_MOD_NOTIFY, isInfoChange)
end
function Logic_UGC_Match:OnChooseModForMatchRsp()
  self.PendingMatchChoose = false
end
function Logic_UGC_Match:GetTeamMode(MatchMode)
  if self:IsUGCSingleMatchMode(MatchMode) then
    self:ReqGetLastGame()
  end
end
function Logic_UGC_Match:HandleEnterUGC()
  if not self:HasUGCMatchInfo() then
    return
  end
  log(bWriteLog and "[v_wllwu] Logic_UGC_Match:HandleEnterUGC ")
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "[v_wllwu] Logic_UGC_Match:HandleEnterUGC return, because IsInXMission ")
    return
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MATCH_ENTER_MOD, self:GetMatchModID() or 0)
end
function Logic_UGC_Match:EnterBattleStandAlone(TemplateID, EnterGameType, CreativeWoWMissionID)
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.ShowLoading(false)
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0, function()
    if LobbySystem.isInMatch then
      LobbySystem.on_match_cancel_req()
    end
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if TeamUpNewSystem.IsInTeam() then
      print(bWriteLog and "[edward] Logic_UGC_Match:EnterBattleStandAlone, is in team. quit team first")
      if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.id then
        TeamUpNewSystem.team_quit_request(TeamUpNewSystem.teamInfo.id)
      else
        TeamUpNewSystem.on_team_quit_respond(NetErrorCode_NONE)
      end
    end
    local TemplateConfig = CDataTable.GetTableData("UGCTemplateConfig", TemplateID)
    if not TemplateConfig then
      TemplateID = 3
      TemplateConfig = CDataTable.GetTableData("UGCTemplateConfig", TemplateID)
    end
    local MapID = TemplateConfig.MapID
    self.StandAlone    local LogicUGCCreativeWoW = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_creativewow)
    if LogicUGCCreativeWoW then
      LogicUGCCreativeWoW:SetCreativeWoWMissionID(CreativeWoWMissionID)
    end
    local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
    local AdditionalURLSuffixes = ""
    local ECreativeModeGameType = import("ECreativeModeGameType")
    if EnterGameType == ECreativeModeGameType.CreativeModeGameType_Editor then
      AdditionalURLSuffixes = AdditionalURLSuffixes .. "StandAloneGameType=1"
    else
      AdditionalURLSuffixes = AdditionalURLSuffixes .. "StandAloneGameType=2"
    end
    local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
    logic_enter_game:EnterBattleStandAlone(UGCMacros.EDIT_SUB_MODE, MapID, AdditionalURLSuffixes)
  end)
end
function Logic_UGC_Match:GetStandAloneData()
  return self.StandAloneTemplateID, self.StandAloneMetaData
end
function Logic_UGC_Match:IsFreeInOutMatch()
  if not self:HasUGCMatchInfo() then
    return false
  end
  local modInfo = self:GetUgcMatchModInfo()
  if not modInfo or not modInfo.setting then
    return false
  end
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  return PlayerStatusUtil.IsFreeInOut(modInfo.setting.free_inout)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGCMatch = class(CModuleBase, nil, Logic_UGC_Match)
return CLogicUGCMatch