local TournamentsManager = {
  Score = 0,
  UnstableScore = 0,
  tournaments = {},
  popUpTimer = nil,
  popUpTimerStart = nil,
  matchCheckTimer = nil,
  matchState = true,
  tournamentHas = false,
  LockEnter = true,
  isNeedRedPoint = false,
  curMatchTourId = 1,
  curMatchIdSwap = 1,
  isInMatch = false,
  h5MarketUrl = "",
  activityCenterUrl = "game://?module=1001300&id=621010101",
  h5ImageUrl = "",
  h5IconUrl = "",
  indiaTicketConfig = nil,
  settlement_table = {},
  tournamentTeamInfo = {},
  bonusCfg = {
    isBonusOpen = false,
    redPointBonus = false,
    typeconfig = "",
    typeswitch = "",
    otherswitch = "",
    quiz_newer = "",
    weekly_reward = "",
    optionswitch = "",
    addTimes = 0
  },
  filter = {
    map_name = -1,
    cost = -1,
    team_size = -1
  },
  matchList = {},
  protocolFrom = -1,
  inviteApplyData = nil,
  creatRoomData = nil,
  joinRoomData = nil,
  matchData = nil
}
local E_TournamentProtocolType = {
  Team_Invite_Replay = 1,
  Team_Create = 2,
  Free_Room_Create = 3,
  Free_Room_Join = 4,
  Enter_Tournament_Room = 5,
  Tournament_Match = 6
}
TournamentsManager.TournamentsManager.h5MarketUrl = FuncUtil.GetDomainByID(3366036) .. "/act/a20190107point/index.html"
local super_data = require("common.super_data")
local TournamentsData = super_data.CreateSuperData(TournamentsManager)
function TournamentsManager.GetTournamentsData()
  return TournamentsData
end
Newbie_Guide_India_Championship_Introduce = 1
Newbie_Guide_India_Championship_Tournament_New = 2
Newbie_Guide_India_Championship_Mall = 3
function TournamentsManager.Init()
  TournamentsManager.matchState = true
  TournamentsManager.LockEnter = false
  TournamentsManager.bonusCfg.addTimes = 0
  TournamentsManager.bonusCfg.isBonusOpen = false
  TournamentsManager.bonusCfg.redPointBonus = false
end
function TournamentsManager.ClearAllAuthCheckData()
  TournamentsManager.protocolFrom = -1
  TournamentsManager.inviteApplyData = nil
  TournamentsManager.creatRoomData = nil
  TournamentsManager.joinRoomData = nil
  TournamentsManager.matchData = nil
end
function TournamentsManager.ClearInviteData()
  TournamentsManager.protocolFrom = -1
  TournamentsManager.inviteApplyData = nil
end
function TournamentsManager.ClearCreateRoomData()
  TournamentsManager.protocolFrom = -1
  TournamentsManager.creatRoomData = nil
end
function TournamentsManager.ClearJoinRoomData()
  TournamentsManager.protocolFrom = -1
  TournamentsManager.joinRoomData = nil
end
function TournamentsManager.ClearMatchRoomData()
  TournamentsManager.protocolFrom = -1
  TournamentsManager.matchData = nil
end
function TournamentsManager.InitOnlyOne()
  EventSystem:registEvent(EVENTTYPE_ALLIANCE, EVENTID_TOURNAMENT_AUTHENTICATION_CHECK_SUCCESS, TournamentsManager.OnEnterMatchOrRoomByAuth)
end
function TournamentsManager.GetEntryInfo()
  if not LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_INDIA_CHAMPIONSHIP_SYSTEM) then
    return nil
  end
  local info = {
    nNameID = 12588,
    nDescID = 12588,
    sIcon_close = "/Game/UMG/Texture/Lobby_NoAtlas/ESport/Esport_Game_bg_04.Esport_Game_bg_04",
    sIcon_open = "/Game/UMG/Texture/Lobby_NoAtlas/ESport/Esport_Game_bg_03.Esport_Game_bg_03",
    logo_close = "/Game/UMG/Texture/Lobby_NoAtlas/ESport/Esport_Game_logo_hui_02.Esport_Game_logo_hui_02",
    logo_open = "/Game/UMG/Texture/Lobby_NoAtlas/ESport/Esport_Game_logo_02.Esport_Game_logo_02",
    color_open = FLinearColor(0.346704, 0.617207, 0.686686, 1),
    color_close = FLinearColor(0.814847, 0.814847, 0.814847, 1),
    stateFunc = TournamentsManager.GetState,
    clickFunc = TournamentsManager.ShowUI
  }
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    info.sIcon_open = "/Game/MultiRegion/Content/IN/UMG/Texture/Lobby_NoAtlas/ESport/Esport_Game_bg_04.Esport_Game_bg_04"
    info.sIcon_close = "/Game/MultiRegion/Content/IN/UMG/Texture/Lobby_NoAtlas/ESport/Esport_Game_bg_05.Esport_Game_bg_05"
    info.logo_close = "/Game/MultiRegion/Content/IN/UMG/Texture/Lobby_NoAtlas/ESport/Esport_Game_logo_hui_06.Esport_Game_logo_hui_06"
    info.logo_open = "/Game/MultiRegion/Content/IN/UMG/Texture/Lobby_NoAtlas/ESport/Esport_Game_logo_06.Esport_Game_logo_06"
  end
  return info
end
function TournamentsManager.GetState()
  if not TournamentsManager.LockEnter and next(TournamentsManager.tournaments) then
    return ENUM_GameProgress.On
  else
    return ENUM_GameProgress.Off
  end
end
function TournamentsManager.ShowUI()
  if TournamentsManager.GetState() == ENUM_GameProgress.Off then
    ShowNotice(7132)
    return false
  end
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  if PufferMapManager:CheckClassicMapNotDownload() then
    return
  end
  local logic_tournament_main = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_tournament_main)
  logic_tournament_main:ShowMainUI()
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyTournament)
  return true
end
function TournamentsManager.ShowSafetyCheckUI(tournament_id)
  UIManager.ShowUI(UIManager.UI_Config.crew_safety_detection_tournament, tournament_id)
end
function TournamentsManager.OnEnterMatchOrRoomByAuth()
  log(bWriteLog and "[YY]OnEnterMatchOrRoomByAuth===" .. tostring(TournamentsManager.protocolFrom))
  if TournamentsManager.protocolFrom == E_TournamentProtocolType.Team_Invite_Replay then
    local applyData = TournamentsManager.inviteApplyData
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    log_tree("OnEnterMatchOrRoomByAuth===applyData===", applyData)
    TeamUpNewSystem.team_invite_reply(NetErrorCode_NONE, applyData.playerId, applyData.inviterTeamID, applyData.src, applyData.from, nil, applyData.tournament_id)
  elseif TournamentsManager.protocolFrom == E_TournamentProtocolType.Team_Create then
    local tournamentCreateTeamHandler = require("client.network.Protocol.TournamentCreateTeamHandler")
    log(bWriteLog and "[YY]OnEnterMatchOrRoomByAuth==curMatchTourId==" .. tostring(TournamentsManager.curMatchTourId))
    tournamentCreateTeamHandler.send_tournament_create_team_req(TournamentsManager.curMatchTourId)
  elseif TournamentsManager.protocolFrom == E_TournamentProtocolType.Free_Room_Create then
    log_tree(bWriteLog and "[YY]OnEnterMatchOrRoomByAuth==Free_Room_Create==", TournamentsManager.creatRoomData)
    local TournamentHandler = require("client.network.Protocol.TournamentHandler")
    local params = TournamentsManager.creatRoomData
    if params then
      TournamentHandler.send_tournament_free_room_create_req(params.tournament_id, params.name, params.map_id, params.password, params.group_type, params.cost_id, params.cost_rate)
    end
  elseif TournamentsManager.protocolFrom == E_TournamentProtocolType.Free_Room_Join then
    log_tree(bWriteLog and "[YY]OnEnterMatchOrRoomByAuth==Free_Room_Join==", TournamentsManager.joinRoomData)
    local tournamentCreateTeamHandler = require("client.network.Protocol.TournamentCreateTeamHandler")
    local params = TournamentsManager.joinRoomData
    if params then
      tournamentCreateTeamHandler.tournament_free_room_join_req(params.room_id, params.tournament_id, params.password, params.join_type)
    end
  elseif TournamentsManager.protocolFrom == E_TournamentProtocolType.Enter_Tournament_Room then
    TournamentsManager.enter_tournament_room_req()
  elseif TournamentsManager.protocolFrom == E_TournamentProtocolType.Tournament_Match then
    local params = TournamentsManager.matchData
    local TournamentMatchHandler = require("client.network.Protocol.TournamentMatchHandler")
    if params then
      TournamentMatchHandler.send_tournament_match_req(params.tournament_id, params.cost_id)
    end
  end
  TournamentsManager.ClearAllAuthCheckData()
end
function TournamentsManager.tournament_enroll_req(tournament_id, price_type)
  log(bWriteLog and "tournament_req,id:" .. tournament_id .. ", price_type:" .. price_type)
  local TournamentHandler = require("client.network.Protocol.TournamentHandler")
  TournamentHandler.send_tournament_enroll_req(tournament_id, price_type)
end
function TournamentsManager.tournament_match_single_req(tournament_id, price_type)
  log(bWriteLog and "tournament_match_single_req,id:" .. tournament_id .. ", price_type:" .. price_type)
  if TournamentsManager.isInMatch then
    ShowNotice(520016)
    return
  end
  local title = LocUtil.LocalizeResFormat("101001")
  local tip = LocUtil.LocalizeResFormat("7146")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, tip, TournamentsManager.RealSendEnroll)
  TournamentsManager.curMatchIdSwap = tournament_id
  TournamentsManager.end
function TournamentsManager.RealSendEnroll()
  local TournamentMatchHandler = require("client.network.Protocol.TournamentMatchHandler")
  TournamentsManager.matchData = {
    tournament_id = TournamentsManager.curMatchIdSwap,
    cost_id = TournamentsManager.price_type
  }
  TournamentMatchHandler.send_tournament_match_req(TournamentsManager.curMatchIdSwap, TournamentsManager.price_type)
end
function TournamentsManager.MatchRspSuccess(tournament_id)
  TournamentsManager.isInMatch = true
  if tournament_id then
    TournamentsManager.curMatchTourId = tournament_id
    TournamentsManager.settlement_table[TournamentsManager.curMatchTourId] = {true}
    local logic_tournament_main = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_tournament_main)
    logic_tournament_main:SetTournamentData(TournamentsManager.tournaments)
  end
end
function TournamentsManager.CancelMatch()
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  LobbyHandler.send_on_match_cancel_req()
  TournamentsManager.isInMatch = false
  local logic_tournament_main = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_tournament_main)
  logic_tournament_main:SetTournamentData(TournamentsManager.tournaments)
end
function TournamentsManager.SetCancelState()
  TournamentsManager.isInMatch = false
  local logic_tournament_main = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_tournament_main)
  logic_tournament_main:SetTournamentData(TournamentsManager.tournaments)
end
function TournamentsManager.tournament_enroll_rsp(res, tournament_id)
  log(bWriteLog and "tournament_enroll_rsp res:" .. tostring(res) .. ", id:" .. tostring(tournament_id))
  if res == 0 then
    local TournamentHandler = require("client.network.Protocol.TournamentHandler")
    TournamentHandler.send_get_tournaments_req()
    EventSystem:postEvent(EVENTTYPE_INDIA_COMPETITION, EVENTID_INDIA_CHAMPIONSHIP_CREDIT_AND_TICKET_UPDATE)
    ShowNotice(6045)
  elseif res == 520004 then
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    CommonPayBoxMgr.ShowUcRechargeMsg()
    ShowNotice(res)
  elseif res == 100211001 then
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.ShowBanTip(MatchSystem.GetSelectModeBanTip())
  elseif res == 12020001 then
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.ShowBanTip(LocUtil.GetLocalizeResStr(29114))
  elseif res == 520029 then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local title = LocUtil.GetLocalizeResStr(101001)
    local content = LocUtil.GetLocalizeResStr(520029)
    CommonMsgBoxMgr.Show(1, title, content)
  else
    ShowNotice(res)
  end
end
function TournamentsManager.enter_tournament_room_req()
  local TournamentHandler = require("client.network.Protocol.TournamentHandler")
  TournamentHandler.send_enter_tournament_room_req()
end
function TournamentsManager.enter_tournament_room_rsp(res, room, members, tournament_id)
  log(bWriteLog and "enter_tournament_room_rsp res:" .. tostring(res) .. ", room:" .. tostring(room))
  if res ~= 0 then
    log(bWriteLog and "join_room_respond failed = " .. res)
    if res == 110091 then
      DataMgr.ShowMessageBoxByID(res)
    elseif res == 100211001 then
      local MatchSystem = require("client.slua.logic.match.logic_match")
      MatchSystem.ShowBanTip(MatchSystem.GetSelectModeBanTip())
    elseif res == 12020001 then
      local MatchSystem = require("client.slua.logic.match.logic_match")
      MatchSystem.ShowBanTip(LocUtil.GetLocalizeResStr(29114))
    elseif res == 505046 then
      TournamentsManager.protocolFrom = E_TournamentProtocolType.Enter_Tournament_Room
      log(bWriteLog and "[YY]enter_tournament_room_rsp==tournament_id" .. tostring(tournament_id))
      TournamentsManager.ShowSafetyCheckUI(tournament_id)
    elseif res == 520029 then
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      local title = LocUtil.GetLocalizeResStr(101001)
      local content = LocUtil.GetLocalizeResStr(520029)
      CommonMsgBoxMgr.Show(1, title, content)
    else
      ShowNotice(res)
    end
    return
  end
  TournamentsManager.protocolFrom = -1
  BattleResult.IgnoreDSError = false
  RoomSystem.SetCurrentRoomInfo(room)
  RoomSystem.CurrentRoomInfo.owner_id = tostring(RoomSystem.CurrentRoomInfo.owner_id)
  RoomSystem.CurrentRoomInfo.MemberInfoList = {}
  for k, v in pairs(members) do
    local tmp = v
    tmp.openid = tostring(k)
    tmp.isRoomMaster = RoomSystem.CurrentRoomInfo.owner_id == tmp.openid
    tmp.head_url = ""
    tmp.gender = ""
    tmp.frame_level = ""
    table.insert(RoomSystem.CurrentRoomInfo.MemberInfoList, tmp)
  end
  local time_ticker = require("common.time_ticker")
  if TournamentsManager.popUpTimer then
    time_ticker.RemoveTimer(TournamentsManager.popUpTimer)
    TournamentsManager.popUpTimer = nil
  end
  if TournamentsManager.popUpTimerStart then
    time_ticker.RemoveTimer(TournamentsManager.popUpTimerStart)
    TournamentsManager.popUpTimerStart = nil
  end
  if TournamentsManager.matchCheckTimer then
    time_ticker.RemoveTimer(TournamentsManager.matchCheckTimer)
    TournamentsManager.matchCheckTimer = nil
  end
  UIManager.ShowUI(UIManager.UI_Config.ui_room_waiting)
  RoomSystem.req_profile_join_room()
end
function TournamentsManager.get_tournaments_rsp(tournaments, appendInfo)
  log_tree("TournamentsManager.1111====send_get_tournaments_req tournaments = ", tournaments)
  if appendInfo then
    TournamentsManager.isInMatch = appendInfo.matching_tournament ~= nil
    TournamentsManager.curMatchTourId = appendInfo.matching_tournament or 0
    TournamentsManager.h5MarketUrl = appendInfo.market_h5_url or FuncUtil.GetDomainByID(3366036) .. "/act/a20190107point/index.html"
    TournamentsManager.h5ImageUrl = appendInfo.picture_url or ""
    TournamentsManager.h5IconUrl = appendInfo.texture_url or ""
    TournamentsManager.settlement_table = appendInfo.settlement_table or {}
  else
    TournamentsManager.isInMatch = false
  end
  if tournaments then
    TournamentsManager.    local time_ticker = require("common.time_ticker")
    if TournamentsManager.popUpTimer then
      time_ticker.RemoveTimer(TournamentsManager.popUpTimer)
      TournamentsManager.popUpTimer = nil
    end
    if TournamentsManager.popUpTimerStart then
      time_ticker.RemoveTimer(TournamentsManager.popUpTimerStart)
      TournamentsManager.popUpTimerStart = nil
    end
    if TournamentsManager.matchCheckTimer then
      time_ticker.RemoveTimer(TournamentsManager.matchCheckTimer)
      TournamentsManager.matchCheckTimer = nil
    end
    local is_enroll = false
    for k, v in pairs(tournaments) do
      if v.user_data.enroll_state == 1 then
        is_enroll = true
        local TimeUtil = require("client.common.time_util")
        local serverTime = TimeUtil.GetServerTimeInSec()
        if 0 < v.type_data.enter_time - serverTime then
          TournamentsManager.popUpTimer = time_ticker.AddTimerOnce(v.type_data.enter_time - serverTime, TournamentsManager.EnterRoomTimerFunc)
        end
        if 0 < v.type_data.start_time - 120 - serverTime then
          TournamentsManager.popUpTimerStart = time_ticker.AddTimerOnce(v.type_data.start_time - 120 - serverTime, TournamentsManager.StartGameTimerFunc)
        end
        local offset = math.random(0, 10)
        local matchCheckSendTime = v.type_data.match_time - serverTime
        if 0 < matchCheckSendTime then
          is_enroll = false
          TournamentsManager.matchCheckTimer = time_ticker.AddTimerOnce(matchCheckSendTime + offset, TournamentsManager.MatchTimerFunc)
          break
        end
        TournamentsManager.MatchTimerFunc()
        break
      end
    end
    TournamentsManager.matchState = not is_enroll or TournamentsManager.matchState
    local logic_tournament_main = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_tournament_main)
    logic_tournament_main:SetTournamentData(TournamentsManager.tournaments)
    EventSystem:postEvent(EVENTTYPE_INDIA_COMPETITION, EVENTID_INDIA_CHAMPIONSHIP_TOURNAMENT_INFO)
    TournamentsManager.UpdateBonusReddot()
  end
end
function TournamentsManager.EnterRoomTimerFunc()
  if not RoomSystem.IsShowWaiting() then
    UIManager.ShowUI(UIManager.UI_Config.Championship_India_QuickTips_UIBP)
  end
  if TournamentsManager.popUpTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(TournamentsManager.popUpTimer)
  end
end
function TournamentsManager.StartGameTimerFunc()
  if not RoomSystem.IsShowWaiting() then
    UIManager.ShowUI(UIManager.UI_Config.Championship_India_FloatTips_UIBP)
  end
  if TournamentsManager.popUpTimerStart then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(TournamentsManager.popUpTimerStart)
  end
end
function TournamentsManager.MatchTimerFunc()
  TournamentsManager.tournament_room_id_req()
end
function TournamentsManager.tournament_info_req()
  local TournamentHandler = require("client.network.Protocol.TournamentHandler")
  TournamentHandler.send_tournament_info_req()
end
function TournamentsManager.tournament_info_rsp(tournamentsInfo)
  log_tree("tournament_info_rsp list = ", tournamentsInfo)
  local TournamentHistoryRecordSystem = require("client.slua.logic.tournament.logic_tournament_history_record")
  TournamentHistoryRecordSystem.tournament_info_rsp(tournamentsInfo)
end
function TournamentsManager.get_tournament_score_req()
  local TournamentHandler = require("client.network.Protocol.TournamentHandler")
  TournamentHandler.send_get_tournament_score_req()
end
function TournamentsManager.get_tournament_score_rsp(score, unstableScore)
  log(bWriteLog and "get_tournament_score_rsp score:" .. tostring(score) .. ", unstableScore:" .. tostring(unstableScore))
  TournamentsManager.Score = score
  TournamentsManager.UnstableScore = unstableScore
  EventSystem:postEvent(EVENTTYPE_INDIA_COMPETITION, EVENTID_INDIA_CHAMPIONSHIP_CREDIT_AND_TICKET_UPDATE)
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_BATTLE_COIN_CHANGE, score)
end
function TournamentsManager.notify_tournament_score_change(score, unstableScore)
  log(bWriteLog and "notify_tournament_score_change score:" .. tostring(score) .. ", unstableScore:" .. tostring(unstableScore))
  DataMgr.battle_coin = score
  TournamentsManager.Score = score
  TournamentsManager.UnstableScore = unstableScore
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_BATTLE_COIN_CHANGE, score)
end
function TournamentsManager.get_tournament_newbie_award_req()
  local TournamentHandler = require("client.network.Protocol.TournamentHandler")
  TournamentHandler.send_get_tournament_newbie_award_req()
end
function TournamentsManager.get_tournament_newbie_award_rsp(res, items)
  log(bWriteLog and "get_tournament_newbie_award_rsp res:" .. tostring(res))
  log_tree("items", items)
  local TournamentIntroduceSystem = require("client.slua.logic.tournament.logic_tournament_introduce")
  if res == 0 or res == NetErrorCode_NONE then
    TournamentIntroduceSystem.OnGetNewbieAwards(items)
  else
    TournamentIntroduceSystem.CloseUI()
  end
end
function TournamentsManager.OpenUrl()
  local baseUrl = TournamentsManager.h5MarketUrl
  local strOpenid = DataMgr.roleData.openID
  local strUid = DataMgr.roleData.uid
  local myLanguage = Client.GetCurrentLanguage()
  local current_version = Client.GetAppVersion() or FuncUtil.GetDomainByID(3366015)
  local webTicket = Client.GetWebViewTicket(NetInterface)
  local StringUtil = require("common.string_util")
  local strUserName = StringUtil.EncodeURI(DataMgr.roleData.nickName)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local finalUrl = string.format("%s?nickname=%s&openid=%d&uid=%d&totalScore=%d&unstableScore=%d&region=%s&version=%s&language=%s&game_area=%s&sTicket=%s", baseUrl, strUserName, strOpenid, strUid, TournamentsManager.Score, TournamentsManager.UnstableScore, login_module.sIpRegion, current_version, myLanguage, ZoneSystem.GetChooseZone(), webTicket)
  local IndiaPrivateKey = "XEPPTNsQV5BAkGDA"
  local sign = ""
  local signUrl = string.format("openid=%d&uid=%d&totalScore=%d&unstableScore=%d&region=%s&language=%s&game_area=%s&version=%s", strOpenid, strUid, TournamentsManager.Score, TournamentsManager.UnstableScore, login_module.sIpRegion, myLanguage, ZoneSystem.GetChooseZone(), current_version)
  local encryptionStr = IndiaPrivateKey .. signUrl .. IndiaPrivateKey
  sign = Client.MD5HashAnsiString(encryptionStr)
  finalUrl = finalUrl .. "&sign=" .. sign
  log(bWriteLog and "finalUrl url = " .. finalUrl)
  local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
  WebviewSDK:OpenURL(finalUrl)
end
function TournamentsManager.GetEnrollName()
  for k, v in pairs(TournamentsManager.tournaments) do
    if v.user_data.enroll_state == 1 then
      return v.title
    end
  end
  local QuilifyHandler = require("client.network.Protocol.QuilifyHandler")
  if QuilifyHandler then
    return QuilifyHandler.getRoomName()
  else
    return ""
  end
end
function TournamentsManager.GetEnrollStartTime()
  for k, v in pairs(TournamentsManager.tournaments) do
    if v.user_data.enroll_state == 1 then
      return v.type_data.start_time
    end
  end
  local QuilifyHandler = require("client.network.Protocol.QuilifyHandler")
  if QuilifyHandler then
    return QuilifyHandler.getStartTime()
  else
    return 0
  end
end
function TournamentsManager.LobbyMatchCheck()
  if not TournamentsManager.tournaments or not next(TournamentsManager.tournaments) then
    return false
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchModeMgrSystem.nSelectMatchID == 0 then
    return false
  end
  for k, v in pairs(TournamentsManager.tournaments) do
    if v.user_data and v.user_data.enroll_state == 1 then
      if MatchModeMgrSystem.nSelectMatchID == 0 then
        return false
      end
      local gameTime = 2700
      if MatchModeMgrSystem.nSelectMatchID > 200 then
        gameTime = 1200
      end
      local indiaTourmentTime = v.type_data.start_time
      local TimeUtil = require("client.common.time_util")
      local serverTime = TimeUtil.GetServerTimeInSec()
      if indiaTourmentTime > serverTime and indiaTourmentTime < serverTime + gameTime then
        UIManager.ShowUI(UIManager.UI_Config.Championship_India_Popup01_UIBP, indiaTourmentTime - serverTime)
        return true
      end
      break
    end
  end
  return false
end
function TournamentsManager.tournament_room_id_req()
  local TournamentHandler = require("client.network.Protocol.TournamentHandler")
  TournamentHandler.send_tournament_room_id_req()
end
function TournamentsManager.tournament_room_id_rsp(res, roomId)
  log(bWriteLog and "tournament_room_id_rsp res = " .. tostring(res))
  local time_ticker = require("common.time_ticker")
  if TournamentsManager.matchCheckTimer then
    time_ticker.RemoveTimer(TournamentsManager.matchCheckTimer)
    TournamentsManager.matchCheckTimer = nil
  end
  if res == 0 then
    TournamentsManager.matchState = true
  elseif res == 520017 then
    TournamentsManager.matchState = false
    if TournamentsManager.popUpTimerStart then
      time_ticker.RemoveTimer(TournamentsManager.popUpTimerStart)
      TournamentsManager.popUpTimerStart = nil
    end
    if TournamentsManager.popUpTimer then
      time_ticker.RemoveTimer(TournamentsManager.popUpTimer)
      TournamentsManager.popUpTimer = nil
    end
    EventSystem:postEvent(EVENTTYPE_INDIA_COMPETITION, EVENTID_INDIA_CHAMPIONSHIP_MATCH_FAIL, TournamentsManager.tournaments)
  else
    TournamentsManager.matchCheckTimer = time_ticker.AddTimerOnce(15, TournamentsManager.MatchTimerFunc)
    for k, v in pairs(TournamentsManager.tournaments) do
      if v.user_data.enroll_state == 1 then
        local TimeUtil = require("client.common.time_util")
        local serverTime = TimeUtil.GetServerTimeInSec()
        if 0 >= v.type_data.enter_time - serverTime then
          TournamentsManager.matchState = false
          if TournamentsManager.matchCheckTimer then
            time_ticker.RemoveTimer(TournamentsManager.matchCheckTimer)
            TournamentsManager.matchCheckTimer = nil
          end
          EventSystem:postEvent(EVENTTYPE_INDIA_COMPETITION, EVENTID_INDIA_CHAMPIONSHIP_MATCH_FAIL, TournamentsManager.tournaments)
        end
        break
      end
    end
  end
  local logic_tournament_main = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_tournament_main)
  logic_tournament_main:SetTournamentData(TournamentsManager.tournaments)
end
function TournamentsManager.notify_tournament_new()
  log_tree("TournamentsManager.3333========notify_tournament_new===", TournamentsManager.tournaments)
  TournamentsManager.LockEnter = false
  local timeData = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP, Newbie_Guide_India_Championship_Tournament_New)
  if timeData then
    local TimeUtil = require("client.common.time_util")
    local nowData = math.floor(TimeUtil.GetServerTimeInSec() / 86400)
    if 0 < nowData - timeData then
      TournamentsManager.UpdateBonusReddot()
    end
  end
end
function TournamentsManager.notify_tournament_has()
  log_tree("TournamentsManager.22222===notify_tournament_has", TournamentsManager.tournaments)
  TournamentsManager.LockEnter = false
  TournamentsManager.tournamentHas = true
  local timeData = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP, Newbie_Guide_India_Championship_Tournament_New)
  if timeData then
    local TimeUtil = require("client.common.time_util")
    local nowData = math.floor(TimeUtil.GetServerTimeInSec() / 86400)
    log(bWriteLog and "esport_reddot_data.UpdateBonusCount==nowData" .. nowData .. "  timeData===" .. timeData .. "  now==" .. TimeUtil.GetServerTimeInSec())
    if 0 < nowData - timeData then
      TournamentsManager.UpdateBonusReddot()
    end
  end
end
function TournamentsManager.UpdateBonusReddot()
  local logic_tournament_main = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_tournament_main)
  local entranceList = logic_tournament_main:GetEntranceList()
  if not entranceList or not next(entranceList) then
    return
  end
  local esport_reddot_data = require("client.slua.logic.esport.esport_reddot_data")
  for _, v in pairs(entranceList) do
    if v.state == 2 and v.user_state == 0 and v.type == 1001 then
      esport_reddot_data.UpdateBonusCount(1)
      break
    end
  end
end
function TournamentsManager.ClearBonusReddot()
  local esport_reddot_data = require("client.slua.logic.esport.esport_reddot_data")
  esport_reddot_data.UpdateBonusCount(0)
end
local E_TOURNAMENT_TYPE = {ROOM = 1000, MATCH = 1001}
local E_TOURNAMENT_TEAM_TYPE = {SOLO = 1, SQUARD = 4}
function TournamentsManager.EnterOneGame(id)
  local info = TournamentsManager.tournaments[id]
  if not info then
    log_error("TournamentsManager.EnterOneGame can find tournament for id " .. tostring(id))
    return
  end
  if id == TournamentsManager.curMatchTourId and TournamentsManager.isInMatch then
    local title = LocUtil.LocalizeResFormat("101001")
    local tip = LocUtil.LocalizeResFormat("7147")
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, tip, function()
      TournamentsManager.CancelMatch()
      return true
    end)
    return
  end
  if info.user_data.enroll_state == 1 then
    TournamentsManager.enter_tournament_room_req()
  elseif TournamentsManager.settlement_table[id] and info.type_data.team_size == 1 then
    TournamentsManager.curMatchIdSwap = id
    TournamentsManager.RealSendEnroll()
  else
    UIManager.ShowUI(UIManager.UI_Config.Championship_India_Popup_UIBP, info, id)
  end
end
function TournamentsManager.GetTourmentInfoById(id)
  if not TournamentsManager.tournaments then
    return nil
  else
    return TournamentsManager.tournaments[id]
  end
end
function TournamentsManager.RegistTournametWithCostType(id, costID)
  local info = TournamentsManager.tournaments[id]
  if not info then
    log_error("TournamentsManager.RegistTournametWithCostType get nil info by id:" .. tostring(id))
    return
  end
  if info.type == E_TOURNAMENT_TYPE.ROOM then
    TournamentsManager.tournament_enroll_req(id, costID)
  elseif info.type == E_TOURNAMENT_TYPE.MATCH and info.type_data.team_size == E_TOURNAMENT_TEAM_TYPE.SOLO then
    TournamentsManager.tournament_match_single_req(id, costID)
  elseif info.type == E_TOURNAMENT_TYPE.MATCH and info.type_data.team_size == E_TOURNAMENT_TEAM_TYPE.SQUARD then
    if DataMgr.IsEmulator() then
      ShowNotice(LocUtil.LocalizeResFormat("7126"))
      return
    end
    if TournamentsManager.isInMatch then
      ShowNotice(520016)
      return
    end
    local tournamentCreateTeamHandler = require("client.network.Protocol.TournamentCreateTeamHandler")
    TournamentsManager.curMatchTourId = id
    tournamentCreateTeamHandler.send_tournament_create_team_req(id)
  end
end
function TournamentsManager.CheckMoneyIsEnough(itemId, needNum, id)
  log(bWriteLog and "TournamentsManager:CheckMoneyIsEnough itemId = " .. itemId .. ",needNum = " .. needNum)
  if id and TournamentsManager.settlement_table[id] then
    return true
  end
  if itemId == 1006 then
    if needNum > DataMgr.ticket then
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg(needNum)
      return false
    end
  elseif itemId == 1702018 then
    log(bWriteLog and "TournamentsManager:CheckMoneyIsEnou 1")
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetHallDepotItemDataByResID(1702018)
    local hasIndiaTicket = itemData and itemData.count or 0
    if needNum > hasIndiaTicket then
      local title = LocUtil.LocalizeResFormat("101001")
      local needBuyIndiaTicket = needNum - hasIndiaTicket
      local needTicket = needBuyIndiaTicket * 10
      local tip = LocUtil.LocalizeResFormat(7109, tostring(needTicket), tostring(needBuyIndiaTicket))
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, title, tip, function()
        if TournamentsManager.CheckMoneyIsEnough(1006, needTicket) then
          local item_list = {
            [1702018] = needBuyIndiaTicket
          }
          local params = {}
          params.          local BuyTournamentTicketHandler = require("client.network.Protocol.BuyTournamentTicketHandler")
          BuyTournamentTicketHandler.send_buy_tournament_ticket_req(params)
        end
      end)
      return false
    end
  else
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetHallDepotItemDataByResID(itemId)
    local hasIndiaTicket = itemData and itemData.count or 0
    if needNum > hasIndiaTicket then
      ShowNotice(4716)
      return false
    end
  end
  return true
end
function TournamentsManager.IsInSingleMatch()
  if not TournamentsManager.isInMatch then
    return false
  end
  if TournamentsManager.curMatchTourId then
    local itemData = TournamentsManager.tournaments[TournamentsManager.curMatchTourId]
    if itemData and itemData.type_data.team_size and itemData.type_data.team_size == 1 then
      return true
    end
  end
  return false
end
function TournamentsManager.UpdateTournamentInfo(tournamentInfo)
  for k, v in pairs(tournamentInfo) do
    TournamentsManager.tournaments[k] = v
  end
end
function TournamentsManager.IsTournamentClosed(id)
  if TournamentsManager.tournaments[id] == nil then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local closeTime = TournamentsManager.tournaments[id].type_data.close_time
  log(bWriteLog and "TournamentsManager.IsTournamentClosed curTime: " .. tostring(curTime))
  log(bWriteLog and "TournamentsManager.IsTournamentClosed closeTime: " .. tostring(closeTime))
  return curTime >= closeTime
end
function TournamentsManager.IsTournamentTeam(id)
  local _config = TournamentsManager.tournaments[id]
  if _config and _config.type_data.team_size and _config.type_data.team_size == 4 then
    return true
  else
    return false
  end
end
function TournamentsManager.EnterTournamentTeamup(tournament_id)
  log(bWriteLog and "TournamentsManager.EnterTournamentTeamup tournament_id:" .. tostring(tournament_id))
  TournamentsManager.ClearInviteData()
  if 0 < tournament_id then
    local isTeamConfig = TournamentsManager.IsTournamentTeam(tournament_id)
    if not isTeamConfig then
      log(bWriteLog and "TournamentsManager.EnterTournamentTeamup notTeamConfig")
      return
    end
    if TournamentsManager.IsTournamentClosed(tournament_id) then
      if TournamentsManager.tournamentTeamInfo.team_id ~= nil and 0 < TournamentsManager.tournamentTeamInfo.team_id then
        local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
        TeamUpNewSystem.team_quit_request(TournamentsManager.tournamentTeamInfo.team_id)
      end
    elseif GameStatus.IsInLobbyOrMainCity() and not UIManager.IsUIShow(UIManager.UI_Config.tournament_teamup) then
      UIManager.ShowUI(UIManager.UI_Config.tournament_teamup, tournament_id)
    end
  end
end
function TournamentsManager.send_get_tournaments_req()
  local TournamentHandler = require("client.network.Protocol.TournamentHandler")
  TournamentHandler.send_get_tournaments_req()
end
function TournamentsManager.SetTournamentTeamInfo(tournament_id, team_id)
  log(bWriteLog and "TournamentsManager.SetTournamentTeamInfo")
  TournamentsManager.tournamentTeamInfo.  TournamentsManager.tournamentTeamInfo.end
function TournamentsManager.ClearTournamentTeamInfo()
  log(bWriteLog and "TournamentsManager.ClearTournamentTeamInfo")
  TournamentsManager.tournamentTeamInfo = {}
end
function TournamentsManager.TryQuitTournamentTeam()
  log_tree("TournamentsManager.TryQuitTournamentTeam tournamentTeamInfo:", TournamentsManager.tournamentTeamInfo)
  if TournamentsManager.tournamentTeamInfo.tournament_id ~= nil and TournamentsManager.tournamentTeamInfo.tournament_id > 0 and TournamentsManager.tournamentTeamInfo.team_id ~= nil and 0 < TournamentsManager.tournamentTeamInfo.team_id then
    log(bWriteLog and "TournamentsManager.TryQuitTournamentTeam team_quit_request")
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    TeamUpNewSystem.team_quit_request(TournamentsManager.tournamentTeamInfo.team_id)
  end
end
function TournamentsManager.ShowScoreDetailByIndex(index)
  if not TournamentsManager.score_config then
    log_error("TournamentsManager.score_config is nil!!")
    return
  end
  if index and TournamentsManager.tournaments[index] then
    local tournament_info = TournamentsManager.tournaments[index]
    local cost = tournament_info.type_data.cost[1702018] * 10
    local team_size = tournament_info.type_data.team_size
    local scores = {}
    if tournament_info.type_data.mode_group == 13703 then
      scores = TournamentsManager.score_config.vs[cost]
    elseif team_size == 1 then
      scores = TournamentsManager.score_config.single[cost]
    elseif team_size == 4 then
      scores = TournamentsManager.score_config.team[cost]
    end
    if scores[1] and scores[3] then
      UIManager.ShowUI(UIManager.UI_Config.Championship_Rule2_UIBP, TournamentsManager.tournaments[index], scores)
    elseif scores[1] then
      UIManager.ShowUI(UIManager.UI_Config.Championship_Rule_UIBP, TournamentsManager.tournaments[index], scores)
    else
      log_error("TournamentsManager.ShowScoreDetailByIndex get nil scores")
    end
  else
    log_error("TournamentsManager.ShowScoreDetailByIndex get nil by id = " .. tostring(index))
  end
end
function TournamentsManager.SetResultType(battle_result)
  if DataMgr and battle_result and type(battle_result) == "table" then
    DataMgr.sub_mode = battle_result.sub_mode
    DataMgr.allstar_id = battle_result.allstar_id
    DataMgr.tournament_id = battle_result.tournament_id
    DataMgr.is_pug_result = battle_result.is_pug_result
  end
end
return TournamentsManager