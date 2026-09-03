local logic_community = require("client.slua.logic.community.logic_community_def")
function logic_community.SendSwitchShowLiveBtn(bShow)
  if not logic_community.IsUserAnchorSubscription() then
    return
  end
  log(bWriteLog and string.format("logic_community.SendSwitchShowLiveBtn bShow:%s", bShow))
  if not logic_community.tb_toggle_live_entry then
    logic_community.tb_toggle_live_entry = {
      action = "toggle_live_entry",
      status = false,
      authInfo = ""
    }
  end
  local send = function()
    local temp = logic_community.tb_toggle_live_entry
    temp.status = bShow
    temp.authInfo = "?" .. logic_community.GetRoleInfoUrlParam()
    local jsonStr = json.encode(temp)
    logic_community._SendToCommunity(jsonStr)
  end
  if DataMgr.RegionData.region == nil then
    log(bWriteLog and string.format("logic_community.SendSwitchShowLiveBtn region == nil"))
    local async = require("client.common.async")
    async.Run(function(co)
      async.AwaitEvent(co, nil, EVENTTYPE_SETTING, EVENTID_SET_REGION_OK)
      send()
    end)
  else
    send()
  end
end
function logic_community.SendOnGameBattleStartOrEnd(bStart)
  log(bWriteLog and string.format("logic_community.SendOnGameBattleStartOrEnd bStart:%s", bStart))
  if not logic_community.tb_game_start then
    logic_community.tb_game_start = {
      action = "game_start",
      status = false,
      authInfo = ""
    }
  end
  local temp = logic_community.tb_game_start
  temp.status = bStart
  temp.authInfo = "?" .. logic_community.GetRoleInfoUrlParam()
  local jsonStr = json.encode(temp)
  logic_community._SendToCommunity(jsonStr)
end
function logic_community.SendUserGameStateChange(EGameStateType, roomId, password)
  if not logic_community.IsUserAnchorSubscription() then
    return
  end
  log(bWriteLog and string.format("logic_community.SendUserGameStateChange EGameStateType:%s, roomId:%s, password:%s", EGameStateType, roomId, password))
  local url = logic_community.GetVersionUrl() .. "/live/streamer/sync_game_state"
  local BusinessHelper = import("BusinessHelper")
  local openid = BusinessHelper.GetOpenId()
  local ticket = Client.GetWebViewTicket(NetInterface)
  local region = FuncUtil.GetAccountRegionForBP()
  local lang = Client.GetCurrentLanguage()
  local uid = DataMgr.roleData.uid
  local header = {
    openid = openid,
    ticket = ticket,
    region = region,
    lang = lang,
    ["Content-Type"] = "application/json",
    ["Accept-Encoding"] = "gzip"
  }
  if not logic_community.tb_game_state_change then
    logic_community.tb_game_state_change = {
      openid = tostring(openid),
      uid = uid,
      event_time = 0,
      state = 0,
      roomId = 0,
      teamId = 0,
      password = "",
      team_player_num = 0
    }
  end
  local temp = logic_community.tb_game_state_change
  temp.event_time = slua.getMiliseconds()
  temp.state = EGameStateType
  temp.roomId = roomId or 0
  temp.teamId = 0
  temp.password = password or ""
  if EGameStateType == logic_community.EGameStateType.GAMESTATE_LOBBY_FREE then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    temp.teamId = TeamUpNewSystem.teamInfo.id or 0
    temp.team_player_num = TeamUpNewSystem.teamInfo.player_count or 1
    if TeamUpNewSystem.CanTeamUp() == false then
      log(bWriteLog and "logic_community TeamUpNewSystem.CanTeamUp() == false:")
      temp.state = logic_community.EGameStateType.GAMESTATE_UNKNOWN
    end
  end
  local jsonStr = json.encode(temp)
  log(bWriteLog and " sync_game_state json:" .. jsonStr)
  log(bWriteLog and " sync_game_state header:" .. json.encode(header))
  logic_community.lastPostState = temp.state
  local http_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
  http_manager:Post(url, header, jsonStr, nil, function(success, data)
    log(bWriteLog and string.format("logic_community.SendUserGameStateChange success:%s, data:%s", success, data))
  end)
end
function logic_community.SendQuitGame()
  log(bWriteLog and "logic_community.SendQuitGame")
  local tb = {
    action = "quit_game",
    authInfo = "?" .. logic_community.GetRoleInfoUrlParam()
  }
  local jsonStr = json.encode(tb)
  logic_community._SendToCommunity(jsonStr)
end
function logic_community.SendLogoutGame()
  log(bWriteLog and "logic_community.SendLogoutGame")
  local tb = {
    action = "logout",
    authInfo = "?" .. logic_community.GetRoleInfoUrlParam()
  }
  local jsonStr = json.encode(tb)
  logic_community._SendToCommunity(jsonStr)
end
function logic_community.OnJoinZhuboTeam(eventType, eventID, vars)
  log(bWriteLog and string.format("logic_community.OnJoinZhuboTeamvars:%s", vars))
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    ShowNotice(33631)
    return
  end
  if vars and vars.id then
    local uid = vars.id
    local UIUtil = require("client.common.ui_util")
    UIUtil.ShowLobbyUI(true)
    local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
    AdjustSystem:ClearAdjustDeepLink()
    log(bWriteLog and "[logic_community] OnJoinZhuboTeam userid = " .. uid)
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local applyInfo = {
      src = TeamUpNewSystem.GetPlayerRelation(uid),
      from = TeamUpNewSystem.E_InviteFromType.CommunityLive
    }
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    TeamupHandler.send_join_anchor_team_req(uid, applyInfo)
  end
end
function logic_community.SendOnRoomStateChange(bInRoom, roomid, password)
  if not logic_community.IsUserAnchorSubscription() then
    return
  end
  log(bWriteLog and "logic_community.SendOnRoomStateChange:")
  if bInRoom then
    logic_community.SendUserGameStateChange(logic_community.EGameStateType.GAMESTATE_ROOM_FREE, roomid, password)
  else
    logic_community.SendUserGameStateChange(logic_community.EGameStateType.GAMESTATE_LOBBY_FREE)
  end
end
function logic_community.OnEventidMatchUpdateStatus(eventType, eventID, state)
  if not logic_community.IsUserAnchorSubscription() then
    return
  end
  log(bWriteLog and string.format("logic_community.OnEventidMatchUpdateStatus: state:%s", state))
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if state == ENUM_MatchStatus.Matching then
    logic_community.SendUserGameStateChange(logic_community.EGameStateType.GAMESTATE_GAMING)
  else
    local room_info = RoomSystem.CurrentRoomInfo
    if room_info and next(room_info) then
      if MatchSystem.nMatchStatus == ENUM_MatchStatus.Not or MatchSystem.nMatchStatus == ENUM_MatchStatus.Ready then
        logic_community.SendUserGameStateChange(logic_community.EGameStateType.GAMESTATE_ROOM_FREE, room_info.id, room_info.password)
      end
    else
      logic_community.SendUserGameStateChange(logic_community.EGameStateType.GAMESTATE_LOBBY_FREE)
    end
  end
end
function logic_community.OnTeamupPlayerCountChange(eventType, eventID, arg1)
  if not logic_community.IsUserAnchorSubscription() then
    return
  end
  log(bWriteLog and "[logic_community] OnTeamupPlayerCountChange")
  logic_community.SendUserGameStateChange(logic_community.EGameStateType.GAMESTATE_LOBBY_FREE)
end
function logic_community.OnEventidLoadingBegin(eventType, eventID, toLobby)
  toLobby = toLobby or false
  log(bWriteLog and "logic_community.OnEventidLoadingBegin  toLobby:" .. tostring(toLobby))
  if toLobby == false then
    if logic_community.GetShowEntry() then
      logic_community.SendUserGameStateChange(logic_community.EGameStateType.GAMESTATE_GAMING)
    end
    logic_community.SendOnGameBattleStartOrEnd(true)
  end
end
function logic_community.OnLobbyMainShow()
  log(bWriteLog and "logic_community.OnLobbyMainShow")
  if logic_community.GetShowEntry() then
    logic_community.SendSwitchShowLiveBtn(true)
    logic_community.SendUserGameStateChange(logic_community.EGameStateType.GAMESTATE_LOBBY_FREE)
  end
  logic_community.SendOnGameBattleStartOrEnd(false)
end
function logic_community.OnBackLogin()
  if not logic_community.GetShowEntry() then
    return
  end
  log(bWriteLog and "logic_community.OnBackLogin")
  logic_community.SendSwitchShowLiveBtn(false)
end
function logic_community.OnInitRegionSetting()
  logic_community.SendAuthInfoChange()
end
function logic_community.OnSelectZoneRsp(eventType, eventID, arg1)
  log(bWriteLog and "[logic_community] OnSelectZoneRsp")
  logic_community.SendAuthInfoChange()
end