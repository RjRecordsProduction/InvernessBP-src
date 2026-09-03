RoomModeCreateState = {
  CanCreate = 1,
  HaveCard = 2,
  NoCard = 3,
  Closed = 4,
  NoVersionMatched = 5
}
RoomSystem = RoomSystem or {
  RoomInfoList = {},
  CurrentRoomInfo = {},
  QRCodeRoomInfo = {},
  RoomZoneId = 0,
  RoomNewMemberInfoList = {},
  BeKickedPlayerList = {},
  IsQRCodeEnterRoom = false,
  PendingEnterInfo = {},
  IsPendingEnter = false,
  quickJoinTimer = nil,
  idc_flag = -1,
  SaveLocalRoomData = nil,
  isRegisterEvent = false
}
RoomDisbandReason = ""
Switch_InnerTest = false
local ENUM_ROOM_TYPE = {
  NORMAL = 1,
  ALLSTAR = 2,
  TOURNAMENT = 3
}
local HandleErrorCode = function(res)
  if res == 0 then
    return
  end
  local err_code_hash = {
    [210013] = 505089,
    [210014] = 505090,
    [210015] = 505091,
    [210023] = 505091,
    [210016] = 505092,
    [210017] = 505093,
    [210018] = 505094,
    [210019] = 505095,
    [210020] = 505096,
    [210021] = 505097,
    [210022] = 505098,
    [210002] = 505099,
    [110148] = 505089,
    [110149] = 505089,
    [210006] = 505089,
    [100040015] = 505091,
    [110000] = 49281,
    [100040016] = 49425,
    [100150049] = 200000108
  }
  ShowNotice(err_code_hash[res] or res)
end
local RoomDisbandReasonMsgLocalKey = {
  ["owner-exit"] = 110069,
  ["owner-offline"] = 110073,
  ["over-time"] = 117073
}
local JoinRoomRespondShowMsgCode = {
  [110068] = 110068,
  [110069] = 110069,
  [110073] = 110073
}
function RoomSystem.SetIdcFlag(idc_flag)
  RoomSystem.idc_flag = idc_flag or 0
end
function RoomSystem.GetIdcFlag()
  return RoomSystem.idc_flag or 0
end
function RoomSystem.IsNeedPingShadow()
  if not LobbySystem.CheckOpen(BP_ENUM_ROOM_SHADOW_DELAY_SWITCH) then
    return false
  end
  if RoomSystem.idc_flag == 0 or RoomSystem.idc_flag == -1 then
    return false
  end
  return true
end
function RoomSystem.isRoomOwner()
  if RoomSystem.CurrentRoomInfo == nil then
    return false
  end
  if tonumber(RoomSystem.CurrentRoomInfo.owner_id) == tonumber(DataMgr.roleData.uid) then
    return true
  else
    return false
  end
end
function RoomSystem.IsTModeRoom()
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  local C_RoomTypeMap = CreateRoomConfig.C_RoomTypeMap
  local tRoomInfo = RoomSystem.CurrentRoomInfo
  if tRoomInfo and (tRoomInfo.room_type == C_RoomTypeMap.TMode or tRoomInfo.room_type == C_RoomTypeMap.TMatch) then
    return true
  end
  return false
end
function RoomSystem.OnModePostSwitch(preState, nextState)
  if GameStatus.IsInLobbyOrMainCity() then
    local time_ticker = require("common.time_ticker")
    if RoomSystem.quickJoinTimer then
      time_ticker.RemoveTimer(RoomSystem.quickJoinTimer)
      RoomSystem.quickJoinTimer = nil
    end
    RoomSystem.quickJoinTimer = time_ticker.AddTimerOnce(2, RoomSystem.OnQuickJoinRoom)
    RoomSystem.ResumeRoom()
  elseif nextState == GameStatus.Login then
    RoomSystem.Enter()
  elseif nextState == GameStatus.Fighting and not GameStatus.IsInLobbyOrMainCity() then
    FuncUtil.AddCrashContextMainFlow("80")
  end
end
function RoomSystem.Enter()
  log(bWriteLog and "RoomSystem Enter")
  RoomSystem.SetCurrentRoomInfo({})
  RoomSystem.RoomNewMemberInfoList = {}
  RoomSystem.CurrentCarteamInfo = {}
  RoomSystem.BeKickedPlayerList = {}
  RoomSystem.MyUID = DataMgr.roleData.uid
  RoomSystem.idc_flag = -1
  if not RoomSystem.isRegisterEvent then
    RoomSystem.isRegisterEvent = true
    EventSystem:registEvent(EVENTTYPE_NETWORK, EVENTID_LOBBY_SERVER_CONNECT_SUCCESS, RoomSystem.OnConnectedToLobbyServer)
  end
end
function RoomSystem.Release()
  log(bWriteLog and "RoomSystem Release")
  RoomSystem.SetCurrentRoomInfo({})
  RoomSystem.RoomNewMemberInfoList = {}
  RoomSystem.CurrentCarteamInfo = {}
  RoomSystem.BeKickedPlayerList = {}
  RoomSystem.idc_flag = -1
  if RoomSystem.isRegisterEvent then
    RoomSystem.isRegisterEvent = false
    EventSystem:unregistEvent(EVENTTYPE_NETWORK, EVENTID_LOBBY_SERVER_CONNECT_SUCCESS, RoomSystem.OnConnectedToLobbyServer)
  end
end
function RoomSystem.BeKicked(zone_id, reason)
  log_format("RoomSystem BeKicked zone_id = %s, reason = %s", zone_id, reason)
  RoomSystem.SetCurrentRoomInfo({})
  RoomSystem.BeKickedPlayerList = {}
  RoomSystem.idc_flag = -1
  local logic_community = require("client.slua.logic.community.logic_community")
  logic_community.SendOnRoomStateChange(false)
  if GameStatus.IsInLobbyOrMainCity() and not RoomSystem.SelfLeave then
    log(bWriteLog and "RoomSystem BeKicked in lobby or main city be kicked")
    local title_data = LocUtil.GetLocalizeResStr(101001)
    local title = tostring(title_data)
    local msg = ""
    if reason then
      if tonumber(reason) == 100040009 then
        reason = 45454
      elseif tonumber(reason) == 100040019 then
        reason = 468890055
      end
      msg = LocUtil.GetLocalizeResStr(reason)
    else
      local msg_data = LocUtil.GetLocalizeResStr(110085)
      msg = tostring(msg_data)
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, msg)
  else
    RoomSystem.SelfLeave = nil
  end
  UIManager.CloseUI(UIManager.UI_Config.ui_room_waiting)
  UIManager.CloseUI(UIManager.UI_Config.ui_room_waiting_test)
  UIManager.CloseUI(UIManager.UI_Config.ui_room_waiting_allstar)
  UIManager.CloseUI(UIManager.UI_Config.UGCRoomWaitingPanel)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Room_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Room_Owner_Setting_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Room_Owner_Waiting_Tips_UIBP)
  local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
  CreateRoomSystem.IsFromDeepLink = false
  if zone_id and 0 < zone_id and zone_id ~= RoomSystem.RoomZoneId then
    log_format("RoomSystem.BeKicked zone_id is not match. zone_id = %s, RoomSystem.RoomZoneId = %s", zone_id, RoomSystem.RoomZoneId)
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    ZoneSystem.ShowReturnZoneTip(zone_id)
    ZoneSystem.on_select_zone_res(NetErrorCode_NONE, zone_id)
  end
  local logic_room_match_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_room_match_voice)
  logic_room_match_voice:OnQuitMatchRoom()
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_BE_KICKED)
end
function RoomSystem.OnLoadStartGameFailed()
  log(bWriteLog and "RoomSystem OnLoadStartGameFailed")
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.RefreshLoadPercent(1)
  Client.ReturnToLobby(GameFrontendHUD)
end
function RoomSystem.RefreshMyProfileInRoom()
  if not RoomSystem.CurrentRoomInfo or not RoomSystem.CurrentRoomInfo.MemberInfoList then
    return
  end
  for _, v in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
    if tonumber(DataMgr.roleData.uid) == tonumber(v.openid) then
      v.head_url = DataMgr.roleData.headIconUrl
      v.gender = DataMgr.roleData.gender
      v.frame_level = DataMgr.roleData.cur_avatar_box_id
      break
    end
  end
end
function RoomSystem.GetProfileAfterJoinRoom(listinfo)
  log(bWriteLog and "RoomSystem GetProfileAfterJoinRoom")
  if not listinfo or not next(listinfo) then
    return
  end
  if not RoomSystem.CurrentRoomInfo.MemberInfoList then
    return
  end
  for k, v in pairs(listinfo) do
    for kk, vv in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
      if tonumber(v.uid) == tonumber(vv.openid) then
        if tonumber(v.uid) == tonumber(DataMgr.roleData.uid) then
          vv.head_url = DataMgr.roleData.headIconUrl
          vv.gender = DataMgr.roleData.gender
          vv.frame_level = DataMgr.roleData.cur_avatar_box_id
          break
        end
        vv.head_url = v.picUrl
        vv.gender = v.sex
        vv.frame_level = v.cur_avatar_box_id
        break
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_MEMBER)
end
function RoomSystem.GetProfileAfterSync(listinfo)
  log(bWriteLog and "RoomSystem GetProfileAfterSync")
  if listinfo == nil or next(listinfo) == nil then
    return
  end
  if not RoomSystem.CurrentRoomInfo.MemberInfoList then
    return
  end
  for k, v in pairs(listinfo) do
    for kk, vv in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
      if tonumber(v.uid) == tonumber(vv.openid) then
        if tonumber(v.uid) == tonumber(DataMgr.roleData.uid) then
          vv.head_url = DataMgr.roleData.headIconUrl
          vv.gender = DataMgr.roleData.gender
          vv.frame_level = DataMgr.roleData.cur_avatar_box_id
          break
        end
        vv.head_url = v.picUrl
        vv.gender = v.sex
        vv.frame_level = v.cur_avatar_box_id
        break
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_MEMBER)
end
function RoomSystem.GetProfileAfterOffline(listinfo)
  RoomSystem.GetProfileAfterJoinRoom(listinfo)
  RoomSystem.get_room_battle_watch_info_req()
end
function RoomSystem.get_room_battle_watch_info_req()
  log(bWriteLog and "RoomSystem get_room_battle_watch_info_req")
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_get_room_battle_watch_info_req()
end
function RoomSystem.get_room_battle_watch_info_rsp(room_ob_info)
  log(bWriteLog and "RoomSystem get_room_battle_watch_info_rsp")
  log_tree("room_ob_info", room_ob_info)
  if room_ob_info ~= nil and room_ob_info.room_id ~= 0 then
    local strTile = DataMgr.GetMsgByID(102012)
    local strMsg = DataMgr.GetMsgByID(501151)
    local clickOkCallback = function()
      BattleResult.enter_room_battle_watch()
    end
    local clickCancelCallback = function()
      RoomSystem.leave_room_battle_watch()
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, strTile, strMsg, clickOkCallback, clickCancelCallback)
  end
end
function RoomSystem.leave_room_battle_watch()
  log(bWriteLog and "RoomSystem leave_room_battle_watch")
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_leave_room_battle_watch()
end
function RoomSystem.req_join_room(_roomID, _passWd, third_party_info, room_type)
  if _roomID == nil then
    if RoomSystem.IsQRCodeEnterRoom == true then
      RoomSystem.IsQRCodeEnterRoom = false
    end
    return
  end
  log(bWriteLog and "_roomID = " .. _roomID)
  local room_info = RoomSystem.CurrentRoomInfo
  if RoomSystem.IsShowWaiting() then
    if room_info and room_info.room_type and room_info.room_type == "compete_plat" and room_info.id and tonumber(room_info.id) == tonumber(_roomID) then
      DataMgr.ShowMessageBoxByID(117070)
    else
      DataMgr.ShowMessageBoxByID(110132)
    end
    if RoomSystem.IsQRCodeEnterRoom == true then
      RoomSystem.IsQRCodeEnterRoom = false
    end
    return
  end
  if room_type and room_type == "asian_games" then
    local CreateRoomHandler = require("client.network.Protocol.CreateRoomHandler")
    if _passWd == "" then
      CreateRoomHandler.send_join_asian_games_room_req(_roomID, nil, nil)
    else
      CreateRoomHandler.send_join_asian_games_room_req(_roomID, _passWd, nil)
    end
    return
  end
  if _passWd == "" then
    local RoomHandler = require("client.network.Protocol.RoomHandler")
    RoomHandler.send_join_room_request(_roomID, nil, room_type, third_party_info)
  else
    local RoomHandler = require("client.network.Protocol.RoomHandler")
    RoomHandler.send_join_room_request(_roomID, _passWd, room_type, third_party_info)
  end
end
function RoomSystem.req_exit_room()
  log(bWriteLog and "exit_room:" .. DataMgr.roleData.uid)
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_exit_room(tonumber(DataMgr.roleData.uid))
  UIManager.CloseUI(UIManager.UI_Config.ui_room_waiting)
  UIManager.CloseUI(UIManager.UI_Config.ui_room_waiting_test)
  UIManager.CloseUI(UIManager.UI_Config.ui_room_waiting_allstar)
  UIManager.CloseUI(UIManager.UI_Config.UGCRoomWaitingPanel)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Room_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Room_Owner_Setting_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Room_Owner_Waiting_Tips_UIBP)
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_BE_DISBAND)
  local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
  CreateRoomSystem.IsFromDeepLink = false
  RoomSystem.SelfLeave = true
  local logic_room_match_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_room_match_voice)
  logic_room_match_voice:OnQuitMatchRoom()
end
function RoomSystem.req_exit_allstar_room()
  log(bWriteLog and "[edward] RoomSystem.req_exit_allstar_room")
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_exit_room(tonumber(DataMgr.roleData.uid))
  UIManager.CloseUI(UIManager.UI_Config.ui_room_waiting_allstar)
  RoomSystem.SelfLeave = true
  local logic_room_match_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_room_match_voice)
  if logic_room_match_voice then
    logic_room_match_voice:OnQuitMatchRoom()
  end
end
function RoomSystem.req_start_game()
  log(bWriteLog and "RoomSystem.req_start_game, Send start_game_request")
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_start_game_request()
end
function RoomSystem.req_change_room_pos_request(room_id, new_pos)
  log(bWriteLog and "req_change_room_pos_request: room_id = " .. tostring(room_id) .. "new_pos == " .. tostring(new_pos))
  if RoomSystem.CurrentRoomInfo == nil then
    return
  end
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_change_room_pos_request(RoomSystem.CurrentRoomInfo.id, new_pos)
end
function RoomSystem.req_room_kick_request(room_id, kick_id)
  log(bWriteLog and "req_room_kick_request: room_id = " .. tostring(room_id) .. "kick_id == " .. tostring(kick_id))
  if not RoomSystem.isRoomOwner() then
    return
  end
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_room_kick_request(RoomSystem.CurrentRoomInfo.id, tonumber(kick_id))
end
function RoomSystem.send_match_room_kick_req(uids)
  log_tree("send_match_room_kick_req: uids = ", uids)
  if not next(uids) then
    return
  end
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_match_room_kick_req(uids)
end
function RoomSystem.on_match_room_kick_rsp(err_code)
  log(bWriteLog and "on_match_room_kick_rsp:" .. tostring(err_code))
end
function RoomSystem.req_change_room_group_type(room_id, group_type)
  log(bWriteLog and "req_change_room_group_type: room_id = " .. tostring(room_id) .. " group_type = " .. tostring(group_type))
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_change_room_group_type_request(room_id, group_type)
end
function RoomSystem.req_change_room_map(room_id, map_id)
  log(bWriteLog and "req_change_room_map: room_id = " .. tostring(room_id) .. " map_id = " .. tostring(map_id))
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_change_room_map_request(room_id, map_id)
end
function RoomSystem.req_query_one_room(room_id)
  log(bWriteLog and "[YY]req_query_one_room: room_id = " .. tostring(room_id))
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_query_room_password_state_req(room_id)
end
function RoomSystem.req_profile_join_room()
  log(bWriteLog and "RoomSystem req_profile_join_room")
  local listUid = {}
  for k, v in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
    table.insert(listUid, tonumber(v.openid))
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(listUid, RoomSystem.GetProfileAfterJoinRoom, Enum_PROFILE_REPORT_CFG.ROOM_JOIN)
end
function RoomSystem.req_profile_sync_room()
  log(bWriteLog and "RoomSystem req_profile_sync_room")
  local listUid = {}
  for k, v in pairs(RoomSystem.RoomNewMemberInfoList) do
    table.insert(listUid, tonumber(v.openid))
  end
  RoomSystem.RoomNewMemberInfoList = {}
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(listUid, RoomSystem.GetProfileAfterSync, Enum_PROFILE_REPORT_CFG.ROOM_SYNC)
end
function RoomSystem.req_profile_info_offline_room()
  log(bWriteLog and "RoomSystem req_profile_info_offline_room")
  local listUid = {}
  for k, v in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
    table.insert(listUid, tonumber(v.openid))
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(listUid, RoomSystem.GetProfileAfterOffline, Enum_PROFILE_REPORT_CFG.ROOM_OFFLINE)
end
function RoomSystem.req_lock_room_pos(lock_pos)
  log(bWriteLog and "RoomSystem req_lock_room_pos")
  log(bWriteLog and "lock_pos = " .. tostring(lock_pos))
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_lock_room_pos_request(lock_pos)
end
function RoomSystem.req_unlock_room_pos(unlock_pos)
  log(bWriteLog and "RoomSystem req_unlock_room_pos==unlock_pos = " .. tostring(unlock_pos))
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_unlock_room_pos_request(unlock_pos)
end
function RoomSystem.on_create_room_respond(res, room_info, is_asia, member)
  log(bWriteLog and "create_room_respond " .. res)
  log_tree("roominfo", room_info)
  if res ~= 0 then
    log(bWriteLog and "create_room_respond failed ")
    if res == 100211001 then
      local MatchSystem = require("client.slua.logic.match.logic_match")
      MatchSystem.ShowBanTip(MatchSystem.GetSelectModeBanTip())
    elseif res == 12020001 then
      local MatchSystem = require("client.slua.logic.match.logic_match")
      MatchSystem.ShowBanTip(LocUtil.GetLocalizeResStr(29114))
    elseif res == 100040001 then
      HandleErrorCode(res)
      local RoomHandler = require("client.network.Protocol.RoomHandler")
      RoomHandler.send_room_info_request()
    else
      HandleErrorCode(res)
    end
    return
  end
  if not room_info then
    return
  end
  RoomDisbandReason = ""
  local logic_community = require("client.slua.logic.community.logic_community")
  logic_community.OnPostRoomInfo(room_info.id, room_info.password)
  BattleResult.IgnoreDSError = false
  RoomSystem.SetCurrentRoomInfo(room_info)
  RoomSystem.CurrentRoomInfo.IsRoomOwner = true
  RoomSystem.CurrentRoomInfo.owner_id = tostring(RoomSystem.CurrentRoomInfo.owner_id)
  RoomSystem.CurrentRoomInfo.MemberInfoList = {}
  RoomSystem.CurrentRoomInfo.LockTeamInfoList = {}
  RoomSystem.BeKickedPlayerList = {}
  local isEmulator = DataMgr.roleData.isEmulator
  local country
  local selfPos = GetWindowOBState() and 101 or 1
  if member and next(member) then
    for uid, v in pairs(member) do
      country = v.country
      if tonumber(uid) == tonumber(DataMgr.roleData.uid) and v.pos then
        log(bWriteLog and "RoomSystem.on_create_room_respond override pos " .. tostring(selfPos) .. " " .. tostring(v.pos))
        selfPos = v.pos
      end
    end
  end
  table.insert(RoomSystem.CurrentRoomInfo.MemberInfoList, {
    openid = DataMgr.roleData.uid,
    name = DataMgr.roleData.nickName,
    level = DataMgr.roleData.level,
    svr = 0,
    isRoomMaster = true,
    pos = selfPos,
    state = "idle",
    head_url = DataMgr.roleData.headIconUrl,
    gender = DataMgr.roleData.gender,
    frame_level = DataMgr.roleData.cur_avatar_box_id,
    device_type = isEmulator == true and 1 or 0,
    country = is_asia and country
  })
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  if room_info.room_type == require("client.slua.logic.ugc.config_ugc").RoomType then
    local LogicUGCRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCRoom)
    LogicUGCRoom:ShowRoomWaitingUI()
  elseif room_info.room_type == CreateRoomConfig.C_RoomTypeMap.TMode or room_info.room_type == CreateRoomConfig.C_RoomTypeMap.TMatch then
    UIManager.CloseUI(UIManager.UI_Config.room_create)
    local Xmission_Room_UIBP = UIManager.GetUI(UIManager.UI_Config.Xmission_Room_UIBP)
    if Xmission_Room_UIBP then
      Xmission_Room_UIBP:Maximize()
    end
    UIManager.ShowUI(UIManager.UI_Config.Xmission_Room_UIBP)
  else
    UIManager.CloseUI(UIManager.UI_Config.room_create)
    RoomSystem.ShowRoomWaitingUI(is_asia)
  end
  local logic_room_match_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_room_match_voice)
  if logic_room_match_voice:IsVoiceRoom(room_info) then
    logic_room_match_voice:OnJoinMatchRoom(room_info.id, selfPos)
  end
end
function RoomSystem.ShowRoomWaitingUI(is_asia)
  log(bWriteLog and "ShowRoomWaitingUI is_asia = " .. tostring(is_asia))
  local timer_ticker = require("common.time_ticker")
  timer_ticker.AddTimerOnce(0.5, function()
    local IsInLobbyOrMainCity = GameStatus.IsInLobbyOrMainCity()
    log(bWriteLog and "RoomSystem.ShowRoomWaitingUI IsInLobbyOrMainCity = " .. tostring(IsInLobbyOrMainCity))
    if not IsInLobbyOrMainCity then
      return
    end
    local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
    local task = {
      module = RoomSystem,
      funcName = "_RealShowRoomWaitingUI",
      param = is_asia,
      debugInfo = "RoomSystem._RealShowRoomWaitingUI",
      protect = true
    }
    queue_task_module:Enqueue(queue_task_module.TaskEnum.Room, task)
  end)
end
function RoomSystem._RealShowRoomWaitingUI(is_asia)
  log(bWriteLog and "_RealShowRoomWaitingUI is_asia = " .. tostring(is_asia))
  log_tree(bWriteLog and "RoomSystem._RealShowRoomWaitingUI RoomSystem.CurrentRoomInfo = ", RoomSystem.CurrentRoomInfo)
  if RoomSystem.CurrentRoomInfo == nil or not next(RoomSystem.CurrentRoomInfo) then
    log(bWriteLog and "_RealShowRoomWaitingUI RoomSystem.CurrentRoomInfo is nil")
    return
  end
  if RoomSystem.CurrentRoomInfo.id == nil then
    log(bWriteLog and "_RealShowRoomWaitingUI RoomSystem.CurrentRoomInfo.id is nil")
    return
  end
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  local topNode = ui_jump_manager.GetTopNode()
  local ignoredModuleIds = {
    [BP_ENUM_MODULE_LOBBY] = true,
    [BP_ENUM_MODULE_LOBBY_TXMISSION] = true,
    [BP_ENUM_MODULE_ROOM_LIST] = true
  }
  if topNode and not ignoredModuleIds[topNode.moduleID] then
    log(bWriteLog and "RoomSystem._RealShowRoomWaitingUI AndroidBackToLobby. topNode.moduleID = " .. tostring(topNode.moduleID))
    UIManager.AndroidBackToLobby()
  end
  if Client.IsShipping() or not Switch_InnerTest then
    UIManager.ShowUI(UIManager.UI_Config.ui_room_waiting, is_asia)
  else
    UIManager.ShowUI(UIManager.UI_Config.ui_room_waiting_test)
  end
end
function RoomSystem.ShowRoomWaitingUI_AllStar()
  log(bWriteLog and "ShowRoomWaitingUI_AllStar")
  local timer_ticker = require("common.time_ticker")
  timer_ticker.AddTimerOnce(0.5, function()
    local IsInLobbyOrMainCity = GameStatus.IsInLobbyOrMainCity()
    log(bWriteLog and "RoomSystem.ShowRoomWaitingUI_AllStar IsInLobbyOrMainCity = " .. tostring(IsInLobbyOrMainCity))
    if not IsInLobbyOrMainCity then
      return
    end
    local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
    local task = {
      module = RoomSystem,
      funcName = "Real_ShowRoomWaitingUI_AllStar",
      param = RoomSystem,
      debugInfo = "RoomSystem.Real_ShowRoomWaitingUI_AllStar",
      protect = true
    }
    queue_task_module:Enqueue(queue_task_module.TaskEnum.Room, task)
  end)
end
function RoomSystem.Real_ShowRoomWaitingUI_AllStar()
  log(bWriteLog and "Real_ShowRoomWaitingUI_AllStar")
  log_tree(bWriteLog and "RoomSystem.Real_ShowRoomWaitingUI_AllStar RoomSystem.CurrentRoomInfo = ", RoomSystem.CurrentRoomInfo)
  if RoomSystem.CurrentRoomInfo == nil or not next(RoomSystem.CurrentRoomInfo) then
    log(bWriteLog and "RoomSystem.Real_ShowRoomWaitingUI_AllStar RoomSystem.CurrentRoomInfo is nil")
    return
  end
  if RoomSystem.CurrentRoomInfo.id == nil then
    log(bWriteLog and "_RealShowRoomWaitingUI RoomSystem.CurrentRoomInfo.id is nil")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.ui_room_waiting_allstar)
end
function RoomSystem.on_join_room_respond(res, param1, param2)
  log(bWriteLog and "join_room_respond " .. res)
  local RoomListSystem = require("client.slua.logic.room.logic_room_list")
  RoomSystem.QRCodeRoomInfo = nil
  if res ~= 0 then
    log(bWriteLog and "join_room_respond failed = " .. res)
    if res == 110091 then
      DataMgr.ShowMessageBoxByID(res)
      RoomListSystem.ReqRoomListWhenError()
      return
    end
    if RoomSystem.IsQRCodeEnterRoom == true then
      RoomSystem.IsQRCodeEnterRoom = false
      if res == 110103 or res == 110133 then
        ShowNotice(res)
        UIManager.CloseUI(UIManager.UI_Config.room_list)
        return
      end
    end
    if res == 210056 then
      ShowNotice(LocUtil.GetLocalizeResStr(6276))
      return
    end
    if res == 210001 then
      local left_time = param1
      log(bWriteLog and "on_join_room_respond, left time to enter room:" .. left_time)
      ShowNotice(string.format(DataMgr.GetMsgByID(210001), left_time))
      return
    end
    if res == 210022 then
      local modeSystem = require("client.slua.logic.match.logic_mode_mgr")
      if modeSystem.IsSocialIslandMode() then
        ShowNotice(9720)
      end
    end
    if res == 100211001 then
      local MatchSystem = require("client.slua.logic.match.logic_match")
      MatchSystem.ShowBanTip(MatchSystem.GetTeamUpBanTip())
      return
    elseif res == 12020001 then
      local MatchSystem = require("client.slua.logic.match.logic_match")
      MatchSystem.ShowBanTip(LocUtil.GetLocalizeResStr(29113))
      return
    elseif JoinRoomRespondShowMsgCode[res] then
      local titleStr = LocUtil.GetLocalizeResStr(101001)
      local msgStr = LocUtil.GetLocalizeResStr(JoinRoomRespondShowMsgCode[res])
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, titleStr, msgStr)
    end
    HandleErrorCode(res)
    RoomListSystem.ReqRoomListWhenError()
    return
  end
  local base_info = param1
  local members = param2
  local LogicLobbyWatching = require("client.logic.watching.logic_lobby_watching")
  LogicLobbyWatching.IsPCOB = false
  BattleResult.IgnoreDSError = false
  RoomSystem.SetCurrentRoomInfo(base_info)
  RoomDisbandReason = ""
  local zone_id = base_info.zone_id
  if not (zone_id and 0 < zone_id) or zone_id ~= RoomSystem.RoomZoneId then
  end
  RoomSystem.RoomZoneId = zone_id
  RoomSystem.CurrentRoomInfo.owner_id = tostring(RoomSystem.CurrentRoomInfo.owner_id)
  RoomSystem.CurrentRoomInfo.MemberInfoList = {}
  RoomSystem.BeKickedPlayerList = {}
  RoomSystem.CurrentRoomInfo.player_count = 0
  RoomSystem.CurrentRoomInfo.ob_count = 0
  local selfPos
  for k, v in pairs(members) do
    local tmp = v
    tmp.openid = tostring(k)
    tmp.isRoomMaster = RoomSystem.CurrentRoomInfo.owner_id == tmp.openid
    tmp.head_url = ""
    tmp.gender = 0
    tmp.frame_level = 0
    if tonumber(tmp.openid) == tonumber(DataMgr.roleData.uid) and v.pos then
      log(bWriteLog and "RoomSystem.on_join_room_respond selfpos " .. tostring(v.pos))
      selfPos = v.pos
    end
    table.insert(RoomSystem.CurrentRoomInfo.MemberInfoList, tmp)
    if v.pos > 100 then
      RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count + 1
    else
      RoomSystem.AddPlayerCount()
    end
  end
  local mapInfo = CDataTable.GetTableData("Map", RoomSystem.CurrentRoomInfo.map_id)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
    mapInfo.MapKey
  })
  local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
  local room_type = RoomSystem.CurrentRoomInfo.room_type
  local isUGCRoom = room_type == require("client.slua.logic.ugc.config_ugc").RoomType
  if not isUGCRoom and state ~= PufferConst.ENUM_DownloadState.Done then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local title = LocUtil.GetLocalizeResStr("101001")
    local promptTip = LocUtil.LocalizeResFormat(18355, mapInfo.MapName)
    if room_type == "asian_games" then
      local clickOkCallback = function()
        RoomSystem.req_exit_room()
        local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
        PufferManager.Download(PufferConst.ENUM_DownloadType.MAP, {"map_planag"}, PufferTlog.Enum_TLog_From.Click)
        local info = {isNotLobbyBtnClick = true}
        UIManager.ShowUI(UIManager.UI_Config.Download_Main_UIBP, info)
      end
      if CreateRoomSystem.IsAsiaGamesWhite() then
        promptTip = LocUtil.GetLocalizeResStr(18350)
        CommonMsgBoxMgr.Show(2, title, promptTip, clickOkCallback, nil)
      else
        ShowNotice(505091)
        RoomSystem.req_exit_room()
      end
      return
    end
    local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
    local spCfg = CreateRoomConfig.GetMapSpeicialConfig(RoomSystem.CurrentRoomInfo.map_id)
    if spCfg then
      local roomId = RoomSystem.CurrentRoomInfo.id
      local pswd = RoomSystem.CurrentRoomInfo.password
      local params = {
        locText = promptTip,
        callBack = function()
          print(bWriteLog and string.format("UIManager.UI_Config.Common_Room_Download_Popup_UIBP CB %s %s", roomId, pswd))
          RoomSystem.req_join_room(roomId, pswd)
        end,
        mapKey = mapInfo.MapKey
      }
      UIManager.ShowUI(UIManager.UI_Config.Common_Room_Download_Popup_UIBP, params)
      RoomSystem.req_exit_room()
    else
      CommonMsgBoxMgr.Show(1, title, promptTip, function()
        RoomSystem.req_exit_room()
      end, nil)
    end
    return
  end
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  if isUGCRoom then
    local LogicUGCRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCRoom)
    LogicUGCRoom:SetjoinRoomAnimation(true)
    LogicUGCRoom:ShowRoomWaitingUI()
  elseif room_type == "asian_games" then
    RoomSystem.ShowRoomWaitingUI(true)
  elseif room_type == CreateRoomConfig.C_RoomTypeMap.TMode or room_type == CreateRoomConfig.C_RoomTypeMap.TMatch then
    UIManager.ShowUI(UIManager.UI_Config.Xmission_Room_UIBP)
    local logic_xmission_room_team = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_room_team)
    logic_xmission_room_team:SyncRoomMember()
  else
    RoomSystem.ShowRoomWaitingUI()
  end
  RoomSystem.req_profile_join_room()
  if base_info.room_can_kick_player_in_game ~= nil then
    log(bWriteLog and "on_join_room_respond, room_can_kick_player_in_game = " .. tostring(base_info.room_can_kick_player_in_game))
    if base_info.room_can_kick_player_in_game then
      local title = LocUtil.GetLocalizeResStr(101001)
      local content = LocUtil.GetLocalizeResStr(6277)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, title, content)
    end
  end
  local logic_room_match_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_room_match_voice)
  if logic_room_match_voice:IsVoiceRoom() then
    logic_room_match_voice:OnJoinMatchRoom(base_info.id, selfPos)
  end
end
function RoomSystem.on_sync_room_state(state)
  RoomSystem.CurrentRoomInfo.end
function RoomSystem.on_room_disband(room_id, reason, zone_id)
  log(bWriteLog and string.format("on_room_disband room_id = %s, reason = %s, zone_id = %s", room_id, reason, zone_id))
  if GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "RoomSystem.on_room_disband")
    local msg
    if reason == "owner-exit" then
      if not RoomSystem.isRoomOwner() then
        RoomDisbandReason = "owner-exit"
        msg = RoomDisbandReasonMsgLocalKey[RoomDisbandReason]
      end
    elseif reason == "owner-offline" then
      RoomDisbandReason = "owner-offline"
      msg = RoomDisbandReasonMsgLocalKey[RoomDisbandReason]
    elseif reason == "version-not-same" then
    elseif reason == "over-time" then
      RoomDisbandReason = "over-time"
      msg = RoomDisbandReasonMsgLocalKey[RoomDisbandReason]
    elseif reason == "game-over" then
      RoomDisbandReason = "game-over"
    end
    if msg then
      local titleStr = LocUtil.GetLocalizeResStr(101001)
      local msgStr = LocUtil.GetLocalizeResStr(msg)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, titleStr, msgStr)
    end
    if zone_id and 0 < zone_id and zone_id ~= RoomSystem.RoomZoneId then
      log_format("RoomSystem.on_room_disband zone_id is not match. zone_id = %s, RoomSystem.RoomZoneId = %s", zone_id, RoomSystem.RoomZoneId)
      local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
      ZoneSystem.ShowReturnZoneTip(zone_id)
      ZoneSystem.on_select_zone_res(NetErrorCode_NONE, zone_id)
    end
  else
    log(bWriteLog and "RoomSystem.on_room_disband fighting")
    if reason == "owner-exit" then
      if not RoomSystem.isRoomOwner() then
        RoomDisbandReason = "owner-exit"
      end
    elseif reason == "owner-offline" then
      RoomDisbandReason = "owner-offline"
    elseif reason == "version-not-same" then
    elseif reason == "game-over" then
      RoomDisbandReason = "game-over"
    end
  end
  local logic_room_match_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_room_match_voice)
  if logic_room_match_voice then
    logic_room_match_voice:OnQuitMatchRoom()
  end
  RoomSystem.SetCurrentRoomInfo({})
  RoomSystem.RoomZoneId = 0
  RoomSystem.idc_flag = -1
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.RemoveModule(BP_ENUM_MODULE_ROOM_WAITING)
  ui_jump_manager.RemoveModule(BP_ENUM_MODULE_UGC_ROOM_WAITING)
  UIManager.CloseUI(UIManager.UI_Config.ui_room_waiting)
  UIManager.CloseUI(UIManager.UI_Config.ui_room_waiting_test)
  UIManager.CloseUI(UIManager.UI_Config.ui_room_waiting_allstar)
  UIManager.CloseUI(UIManager.UI_Config.UGCRoomWaitingPanel)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Room_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Room_Owner_Setting_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Room_Owner_Waiting_Tips_UIBP)
  local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
  CreateRoomSystem.IsFromDeepLink = false
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_BE_DISBAND)
end
function RoomSystem.on_set_asian_games_room_nickname_rsp(nickname)
  RoomSystem.on_room_member_nickname_ntfy(RoomSystem.CurrentRoomInfo.id, DataMgr.roleData.uid, nickname)
end
function RoomSystem.on_room_member_nickname_ntfy(room_id, member_id, nickname)
  if RoomSystem.CurrentRoomInfo == nil then
    log(bWriteLog and "RoomSystem.on_room_member_nickname_ntfy return CurrentRoomInfo is nil")
    return
  end
  if RoomSystem.CurrentRoomInfo.id ~= room_id then
    log(bWriteLog and "RoomSystem.on_room_member_nickname_ntfy return room_id is not match")
    return
  end
  if RoomSystem.CurrentRoomInfo.MemberInfoList == nil then
    RoomSystem.CurrentRoomInfo.MemberInfoList = {}
    log(bWriteLog and "RoomSystem.on_room_member_nickname_ntfy return MemberInfoList is nil")
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "RoomSystem.on_room_member_nickname_ntfy return not IsInLobbyOrMainCity")
    return
  end
  member_id = tostring(member_id)
  for _memberIndex = 1, #RoomSystem.CurrentRoomInfo.MemberInfoList do
    if RoomSystem.CurrentRoomInfo.MemberInfoList[_memberIndex].openid == member_id then
      RoomSystem.CurrentRoomInfo.MemberInfoList[_memberIndex].name = nickname
      break
    end
  end
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_MEMBER)
end
function RoomSystem.on_sync_room_member(id, info, carteamInfo, zone_id, reason)
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and string.format("RoomSystem.on_sync_room_memberShow nowTime = %s", TimeUtil.FormatTime_YMDHMS(nowTime)))
  log(bWriteLog and string.format("RoomSystem.on_sync_room_memberShow id = %s zone_id = %s reason = %s", id, zone_id, reason))
  log_tree("RoomSystem.on_sync_room_member info = ", info)
  log_tree("RoomSystem.on_sync_room_member carteamInfo = ", carteamInfo)
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "RoomSystem.on_sync_room_member return not IsInLobbyOrMainCity")
    return
  end
  if RoomSystem.CurrentRoomInfo == nil then
    log(bWriteLog and "RoomSystem.on_sync_room_member return CurrentRoomInfo is nil")
    return
  end
  id = tostring(id)
  local isLeaveRoomSync = false
  local isInRoomMemberInfoList = false
  if info == nil then
    isLeaveRoomSync = true
    local selfKicked = RoomSystem.MemberLeaveRoom(id, zone_id, reason)
    if selfKicked then
      log(bWriteLog and "RoomSystem.on_sync_room_member return selfKicked")
      return
    end
  else
    if not info.pos then
      log(bWriteLog and "RoomSystem.on_sync_room_member return info.pos is nil")
      return
    end
    local car_index = math.ceil(info.pos / 4)
    if RoomSystem.CurrentCarteamInfo then
      RoomSystem.CurrentCarteamInfo[car_index] = carteamInfo
      EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_ADD_CAR_TEAM, car_index)
    end
    local tempInfo = RoomSystem.CreateMemberInfo(id, info)
    isInRoomMemberInfoList = RoomSystem.UpdateRoomMember(id, tempInfo, reason)
    if not isInRoomMemberInfoList then
      if RoomSystem.BeKickedPlayerList[id] then
        log(bWriteLog and "RoomSystem.on_sync_room_member return bekicked player")
        return
      end
      RoomSystem.AddRoomMember(id, tempInfo)
    end
  end
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_ROOM_INFO)
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_MEMBER)
  log_format("RoomSystem.on_sync_room_member isLeaveRoomSync = %s, isInRoomMemberInfoList = %s", isLeaveRoomSync, isInRoomMemberInfoList)
  if not isLeaveRoomSync and not isInRoomMemberInfoList then
    RoomSystem.req_profile_sync_room()
  end
end
function RoomSystem.MemberLeaveRoom(id, zone_id, reason)
  log(bWriteLog and "sync_room_member, delete member id = " .. tostring(id))
  log(bWriteLog and "RoomSystem.PlayerLeaveRoom")
  if id == DataMgr.roleData.uid then
    local ui_room_waiting = UIManager.GetUI(UIManager.UI_Config.ui_room_waiting)
    if not ui_room_waiting then
      log(bWriteLog and "RoomSystem.on_sync_room_member ui_room_waiting is not showing")
      local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
      ui_jump_manager.RemoveModule(BP_ENUM_MODULE_ROOM_WAITING)
    end
    RoomSystem.BeKicked(zone_id, reason)
    return true
  end
  if reason and reason ~= 0 then
    log(bWriteLog and "RoomSystem.MemberLeaveRoom add beKickList id = " .. id)
    RoomSystem.BeKickedPlayerList[id] = true
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(3, function()
      if RoomSystem.BeKickedPlayerList[id] then
        RoomSystem.BeKickedPlayerList[id] = nil
      end
    end)
  end
  if RoomSystem.CurrentRoomInfo.MemberInfoList then
    log(bWriteLog and "RoomSystem.MemberLeaveRoom start delete player")
    RoomSystem.CurrentRoomInfo.player_count = RoomSystem.CurrentRoomInfo.player_count or 0
    RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count or 0
    local TableUtil = require("common.table_util")
    for _memberIndex = 1, #RoomSystem.CurrentRoomInfo.MemberInfoList do
      if RoomSystem.CurrentRoomInfo.MemberInfoList[_memberIndex].openid == id then
        log(bWriteLog and "RoomSystem.PlayerLeaveRoom find delete player")
        local tmp = TableUtil.CopyTable(RoomSystem.CurrentRoomInfo.MemberInfoList[_memberIndex])
        table.remove(RoomSystem.CurrentRoomInfo.MemberInfoList, _memberIndex)
        if tmp.pos <= 100 then
          RoomSystem.RemovePlayerCount()
        else
          RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count - 1
        end
        log(bWriteLog and "RoomSystem.MemberLeaveRoom after delete player count = " .. RoomSystem.CurrentRoomInfo.player_count)
        EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_MEMBER_UPDATE)
        break
      end
    end
  end
end
function RoomSystem.CreateMemberInfo(id, info)
  local TableUtil = require("common.table_util")
  local tempInfo = TableUtil.CopyTable(info)
  tempInfo.open  tempInfo.isRoomMaster = RoomSystem.CurrentRoomInfo.owner_id == id
  tempInfo.head_url = ""
  tempInfo.gender = 0
  tempInfo.frame_level = 0
  return tempInfo
end
function RoomSystem.UpdateRoomMember(id, tempInfo, reason)
  log(bWriteLog and "RoomSystem.UpdateRoomMember")
  local isInRoomMemberInfoList = false
  if RoomSystem.CurrentRoomInfo.MemberInfoList == nil then
    RoomSystem.CurrentRoomInfo.MemberInfoList = {}
  end
  RoomSystem.CurrentRoomInfo.player_count = RoomSystem.CurrentRoomInfo.player_count or 0
  RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count or 0
  local TableUtil = require("common.table_util")
  for _memberIndex = 1, #RoomSystem.CurrentRoomInfo.MemberInfoList do
    if RoomSystem.CurrentRoomInfo.MemberInfoList[_memberIndex].openid == id then
      log(bWriteLog and "sync change room pos")
      local tmp2 = TableUtil.CopyTable(RoomSystem.CurrentRoomInfo.MemberInfoList[_memberIndex])
      tempInfo.head_url = tmp2.head_url
      tempInfo.gender = tmp2.gender
      tempInfo.frame_level = tmp2.frame_level
      local _old_pos = tmp2.pos
      local _new_pos = tempInfo.pos
      if RoomSystem.CurrentRoomInfo.ugc_room_param then
        local mod_id = RoomSystem.CurrentRoomInfo.ugc_room_param.mod_id
        local PufferConst = require("client.slua.logic.download.puffer_const")
        if tempInfo.mod_info and tmp2.mod_info and tmp2.mod_info[mod_id] == PufferConst.ENUM_DownloadState.Done then
          tempInfo.mod_info[mod_id] = PufferConst.ENUM_DownloadState.Done
        end
      end
      tempInfo.      RoomSystem.CurrentRoomInfo.MemberInfoList[_memberIndex] = TableUtil.CopyTable(tempInfo)
      if _old_pos <= 100 and 100 < _new_pos then
        RoomSystem.RemovePlayerCount()
        RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count + 1
      elseif 100 < _old_pos and _new_pos <= 100 then
        RoomSystem.AddPlayerCount()
        RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count - 1
      end
      isInRoomMemberInfoList = true
      EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_MEMBER_UPDATE)
      break
    end
  end
  return isInRoomMemberInfoList
end
function RoomSystem.AddRoomMember(id, tempInfo)
  local TableUtil = require("common.table_util")
  log(bWriteLog and "RoomSystem.AddRoomMember new room member")
  local tmp2 = TableUtil.CopyTable(tempInfo)
  local tmp3 = TableUtil.CopyTable(tempInfo)
  table.insert(RoomSystem.CurrentRoomInfo.MemberInfoList, tmp2)
  table.insert(RoomSystem.RoomNewMemberInfoList, tmp3)
  if tempInfo.pos <= 100 then
    RoomSystem.AddPlayerCount()
  else
    RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count + 1
  end
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_MEMBER_UPDATE)
  local UGC_Inventory = require("client.slua.logic.ugc.ugc_Inventory")
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_ENTRY_UPDATE_TIPS, id, UGC_Inventory.UpInRoomTypeUIList.RoomTeam)
end
function RoomSystem.on_change_room_pos_respond(res, new_pos)
  log(bWriteLog and "on change room pos respond")
  log(bWriteLog and "[YY]on_change_room_pos_respond==new_pos" .. tostring(new_pos))
  if res ~= 0 then
    log(bWriteLog and "change room pos failed")
    log(bWriteLog and "res: " .. res)
    if res == "pos-not-free" then
      ShowNotice(505094)
    else
      HandleErrorCode(res)
    end
    return
  end
  if RoomSystem.CurrentRoomInfo == nil then
    return
  end
  local logic_room_match_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_room_match_voice)
  logic_room_match_voice:OnChangeRoomPos(RoomSystem.CurrentRoomInfo.id, new_pos)
end
function RoomSystem.on_room_kick_respond(res, kick_id)
  log(bWriteLog and "on room kick respond res = " .. res)
  if res ~= 0 then
    log(bWriteLog and "room kick failed")
    HandleErrorCode(res)
    return
  end
  log(bWriteLog and "memberID = " .. tostring(kick_id) .. " was kicked by room owner")
end
function RoomSystem.on_start_game_respond(res)
  log(bWriteLog and "RoomSystem.on_start_game_respond, res = " .. tostring(res))
  if res ~= 0 then
    if res == 210005 then
      ShowNotice(520028)
    else
      HandleErrorCode(res)
    end
  else
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    LogicUGCMatch:UpdateLastRoomMatchTime()
  end
end
g_game_id = 0
function RoomSystem.on_change_room_name_request(res, room_id, name)
  log(bWriteLog and "change_room_name_request")
  log(bWriteLog and "room_id = " .. tostring(room_id))
  log(bWriteLog and "name = " .. tostring(name))
  if res ~= 0 then
    HandleErrorCode(res)
    return
  end
  ShowNotice(110100)
end
function RoomSystem.on_change_room_group_type_respond(res, room_id, group_type)
  log(bWriteLog and "change_room_group_type_respond res = " .. res)
  log(bWriteLog and "room_id = " .. tostring(room_id))
  log(bWriteLog and "group_type = " .. tostring(group_type))
  if res ~= 0 then
    HandleErrorCode(res)
    return
  end
end
function RoomSystem.on_change_room_map_respond(res, room_id, map_id)
  log(bWriteLog and "RoomSystem.on_change_room_map_respond, res = " .. res)
  log(bWriteLog and "room_id = " .. tostring(room_id))
  log(bWriteLog and "map_id = " .. tostring(map_id))
  if res ~= 0 then
    if res == 210006 then
      local tips = LocUtil.GetLocalizeResStr(5010)
      ShowNotice(tips)
      return
    end
    HandleErrorCode(res)
    return
  end
  ShowNotice(110097)
end
function RoomSystem.on_room_info_notify(room_id, opt, param)
  log(bWriteLog and "room_info_notify")
  log(bWriteLog and "room_id = " .. tostring(room_id))
  log(bWriteLog and "opt = " .. tostring(opt))
  log(bWriteLog and "param = " .. tostring(param))
  log_tree("[ccl] on_room_info_notify", param)
  if opt == 1 then
    RoomSystem.CurrentRoomInfo.name = param
    EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_ROOM_INFO)
  elseif opt == 2 then
    RoomSystem.CurrentRoomInfo.map_id = param
    RoomSystem.MakeDefaultParams()
    log_tree("[edward][logic_room] RoomSystem.on_room_info_notify", RoomSystem.CurrentRoomInfo.battle_custom_cfg)
    EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_ROOM_INFO)
  elseif opt == 3 then
    RoomSystem.CurrentRoomInfo.group_type = param
    EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_RESET_ROOM_INFO)
  elseif opt == 4 then
    RoomSystem.CurrentRoomInfo.state = param
    EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_STATE)
  elseif opt == 5 then
    if RoomSystem.CurrentRoomInfo.max_room_player ~= param then
      RoomSystem.CurrentRoomInfo.max_room_player = param
      EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_RESET_ROOM_INFO)
    end
  elseif opt == 6 then
    RoomSystem.CurrentRoomInfo.MemberInfoList = {}
    RoomSystem.CurrentRoomInfo.player_count = 0
    RoomSystem.CurrentRoomInfo.ob_count = 0
    for k, v in pairs(param) do
      local tmp = v
      tmp.openid = tostring(k)
      tmp.isRoomMaster = RoomSystem.CurrentRoomInfo.owner_id == tmp.openid
      tmp.head_url = ""
      tmp.gender = 0
      tmp.frame_level = 0
      table.insert(RoomSystem.CurrentRoomInfo.MemberInfoList, tmp)
      if v.pos > 100 then
        RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count + 1
      else
        RoomSystem.AddPlayerCount()
      end
    end
    for i = 1, #RoomSystem.CurrentRoomInfo.MemberInfoList do
      RoomSystem.CurrentRoomInfo.MemberInfoList[i].offline_time = nil
    end
    RoomSystem.req_profile_info_offline_room()
    EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_ROOM_INFO)
    EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_MEMBER_UPDATE)
  elseif opt == 7 then
    RoomSystem.CurrentRoomInfo.disband_tm = param
  elseif opt == 8 then
    log_tree("RoomSystem.on_room_info_notify battle_cfg=", param)
    RoomSystem.CurrentRoomInfo.battle_custom_cfg = param
    if not param or not next(param) then
      RoomSystem.MakeDefaultParams()
    end
  elseif opt == 9 then
    log(bWriteLog and "[YY]\229\155\190\231\129\181\230\136\191\233\151\180\229\177\143\232\148\189\230\168\161\229\188\143" .. tostring(param))
    RoomSystem.CurrentRoomInfo.gm_turing = param
    ShowNotice(param and 8464 or 111022)
    EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_ROOM_INFO)
  elseif opt == 10 then
    RoomSystem.CurrentRoomInfo.start_time = param
    EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_TIME)
  elseif opt == 11 then
    RoomSystem.CurrentRoomInfo.pos_arranging = param
    EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_PosArranging)
  elseif opt == 12 then
    RoomSystem.CurrentRoomInfo.LockTeamInfoList = {}
    for _, team_id in pairs(param) do
      RoomSystem.CurrentRoomInfo.LockTeamInfoList[team_id] = true
    end
    EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_LockTeamList)
  else
    log(bWriteLog and "room_info_notify Error!")
  end
end
function RoomSystem.MakeDefaultParams()
  local roomType = RoomSystem.CurrentRoomInfo.room_type
  local mapID = RoomSystem.CurrentRoomInfo.map_id
  local MapConfig = CDataTable.GetTableData("Map", mapID)
  local roomID = MapConfig.RoomModeId
  if roomType == "asian_games" then
    return
  end
  local privilegeList = {}
  if RoomSystem.CurrentRoomInfo.privileges and next(RoomSystem.CurrentRoomInfo.privileges) then
    for k, v in pairs(RoomSystem.CurrentRoomInfo.privileges) do
      table.insert(privilegeList, k)
    end
  end
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  local advanceParamShowList = CreateRoomConfig.GetParamList(roomType, privilegeList, roomID)
  advanceParamShowList = advanceParamShowList or CreateRoomConfig.GetBasicParamList()
  if advanceParamShowList then
    local cfg = {}
    for i, v in ipairs(advanceParamShowList) do
      for ii, vv in ipairs(v) do
        if vv.ParamKey and vv.ParamKey ~= "" then
          if vv.ParamType == CreateRoomConfig.C_ParamWidgetType.Switch then
            cfg[vv.ParamKey] = vv.DefaultValue == "true"
          else
            cfg[vv.ParamKey] = tonumber(vv.DefaultValue)
          end
        end
      end
    end
    RoomSystem.CurrentRoomInfo.battle_custom_  end
end
function RoomSystem.on_sync_room_info_internal(room, members, bResume)
  bResume = bResume or false
  log_tree("RoomSystem.on_sync_room_info_internal room = ", room)
  log_tree("RoomSystem.on_sync_room_info_internal", members)
  log(bWriteLog and "RoomSystem.on_sync_room_info_internal resume = " .. tostring(bResume))
  log(bWriteLog and "RoomSystem.on_sync_room_info_internal RoomDisbandReason = " .. tostring(RoomDisbandReason))
  if RoomSystem.CheckIsEmptyOrDisband(room) then
    log(bWriteLog and "RoomSystem.on_sync_room_info_internal IsEmptyOrDisband")
    RoomSystem.OnRoomEmptyOrDisband(room)
    return
  end
  RoomSystem.ClearReconnectTimer()
  BattleResult.IgnoreDSError = false
  RoomSystem.SetCurrentRoomInfo(room)
  local zone_id = room.zone_id
  if not (zone_id and 0 < zone_id) or zone_id ~= RoomSystem.RoomZoneId then
  end
  RoomSystem.RoomZoneId = room.zone_id
  RoomSystem.CurrentRoomInfo.owner_id = tostring(RoomSystem.CurrentRoomInfo.owner_id)
  RoomSystem.CurrentRoomInfo.MemberInfoList = {}
  RoomSystem.BeKickedPlayerList = {}
  RoomSystem.CurrentRoomInfo.player_count = 0
  RoomSystem.CurrentRoomInfo.ob_count = 0
  RoomSystem.UpdateMemberInfoList(members, bResume)
  RoomSystem.req_profile_info_offline_room()
  RoomSystem.OnShowWaitingUI()
  local logic_room_match_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_room_match_voice)
  if logic_room_match_voice:IsVoiceRoom() then
    local selfPos
    for _, member in pairs(members) do
      if member.uid == DataMgr.roleData.uid then
        selfPos = member.pos
        break
      end
    end
    if selfPos then
      logic_room_match_voice:OnJoinMatchRoom(room.id, selfPos)
    else
      log("RoomSystem.on_sync_room_info_internal selfPos is nil")
    end
  end
end
function RoomSystem.CheckIsEmptyOrDisband(roomInfo)
  return roomInfo == nil or not next(roomInfo) or RoomDisbandReason ~= ""
end
function RoomSystem.OnRoomEmptyOrDisband(roomInfo)
  if not RoomSystem.CheckIsEmptyOrDisband(roomInfo) then
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "RoomSystem.OnRoomEmptyOrDisband not inLobbyOrMainCity")
    return
  end
  log(bWriteLog and "RoomSystem.OnRoomEmptyOrDisband RoomSystem.MyUID = " .. tostring(RoomSystem.MyUID) .. " " .. tostring(DataMgr.roleData.uid))
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_BE_KICKED)
  log_tree("RoomSystem.OnRoomEmptyOrDisband CurrentRoomInfo =", RoomSystem.CurrentRoomInfo)
  local preLocalData = RoomSystem.GetLocalRoomData()
  RoomSystem.SetCurrentRoomInfo({})
  RoomSystem.idc_flag = -1
  local logic_room_match_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_room_match_voice)
  if logic_room_match_voice then
    logic_room_match_voice:OnQuitMatchRoom()
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
  if LogicTxMissionMain.IsInXMission() and not LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide() then
    log(bWriteLog and "RoomSystem.OnRoomEmptyOrDisband have xmission guide return")
    RoomDisbandReason = ""
    return
  end
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local msg
  if logic_enter_game:IsEnterBattleByRoom() then
    log(bWriteLog and "RoomSystem.OnRoomEmptyOrDisband IsEnterBattleByRoom RoomDisbandReason = " .. tostring(RoomDisbandReason))
    msg = RoomDisbandReasonMsgLocalKey[RoomDisbandReason or ""]
  end
  local LogicUGCRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCRoom)
  if RoomSystem.IsShowWaiting() or LogicUGCRoom:IsShowWaiting() then
    log(bWriteLog and "RoomSystem.OnRoomEmptyOrDisband BP_Room_IsInRoom LeaveRoom")
    UIManager.CloseUI(UIManager.UI_Config.ui_room_waiting)
    UIManager.CloseUI(UIManager.UI_Config.ui_room_waiting_test)
    UIManager.CloseUI(UIManager.UI_Config.ui_room_waiting_allstar)
    UIManager.CloseUI(UIManager.UI_Config.UGCRoomWaitingPanel)
    UIManager.CloseUI(UIManager.UI_Config.Xmission_Room_UIBP)
    local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
    CreateRoomSystem.IsFromDeepLink = false
    if not logic_enter_game:IsEnterBattleByRoom() then
      log(bWriteLog and "RoomSystem.OnRoomEmptyOrDisband not IsEnterBattleByRoom")
      RoomSystem.TryReconnectRoomByLocalData(preLocalData)
    end
  end
  if msg then
    local titleStr = LocUtil.GetLocalizeResStr(101001)
    local msgStr = LocUtil.GetLocalizeResStr(msg)
    CommonMsgBoxMgr.Show(1, titleStr, msgStr)
  end
  RoomDisbandReason = ""
end
function RoomSystem.UpdateMemberInfoList(members, bResume)
  for k, v in pairs(members or {}) do
    local tmp = v
    if not bResume then
      log(bWriteLog and "RoomSystem.on_sync_room_info_internal not resume")
      tmp.openid = tostring(k)
      tmp.head_url = ""
      tmp.gender = 0
      tmp.frame_level = 0
    end
    tmp.isRoomMaster = RoomSystem.CurrentRoomInfo.owner_id == tmp.openid
    tmp.is_qrcode_limit = tmp.is_qrcode_limit or false
    table.insert(RoomSystem.CurrentRoomInfo.MemberInfoList, tmp)
    if v.pos > 100 then
      RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count + 1
    else
      RoomSystem.AddPlayerCount()
    end
  end
  log_tree(bWriteLog and "RoomSystem.UpdateMemberList memberList ", RoomSystem.CurrentRoomInfo.MemberInfoList)
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_MEMBER_UPDATE)
  for i, v in ipairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
    v.offline_time = nil
  end
end
function RoomSystem.CheckRoomCanReconnectByDisbandTime()
  local TimeUtil = require("client.common.time_util")
  local disbandTime = RoomSystem.CurrentRoomInfo and RoomSystem.CurrentRoomInfo.disband_tm and RoomSystem.CurrentRoomInfo.disband_tm
  local nowTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "RoomSystem.on_sync_room_info_internal disband_tm = " .. tostring(disbandTime) .. " nowTime = " .. tostring(nowTime))
  local isOverTime = disbandTime < TimeUtil.GetServerTimeInSec()
  if not isOverTime then
    return true
  end
  log_warning(bWriteLog and "RoomSystem.on_sync_room_info_internal disband_tm overtime")
  local titleStr = LocUtil.GetLocalizeResStr(101001)
  local msgStr = LocUtil.GetLocalizeResStr(501123)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, titleStr, msgStr)
  RoomSystem.req_exit_room()
  return false
end
function RoomSystem.OnShowWaitingUI()
  log(bWriteLog and "RoomSystem.OnShowWaitingUI")
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    log_warning(bWriteLog and "RoomSystem.on_sync_room_info_internal return IsInFightingNotSocialNotMainCityNotHome")
    return
  end
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  if RoomSystem.CurrentRoomInfo and RoomSystem.CurrentRoomInfo.room_type == "allstar" then
    log(bWriteLog and "RoomSystem.OnShowWaitingUI=\229\133\168\230\176\145\232\181\155\231\173\137\229\190\133\231\149\140\233\157\162==" .. tostring(11))
    RoomSystem.ShowRoomWaitingUI_AllStar()
  elseif RoomSystem.CurrentRoomInfo and RoomSystem.CurrentRoomInfo.room_type == "asian_games" then
    log(bWriteLog and "RoomSystem.OnShowWaitingUI==\228\186\154\232\191\144\230\136\191\233\151\180=" .. tostring(333))
    RoomSystem.ShowRoomWaitingUI(true)
  elseif RoomSystem.CurrentRoomInfo and RoomSystem.CurrentRoomInfo.room_type == require("client.slua.logic.ugc.config_ugc").RoomType then
    local LogicUGCRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCRoom)
    LogicUGCRoom:ShowRoomWaitingUI()
  elseif RoomSystem.CurrentRoomInfo and (RoomSystem.CurrentRoomInfo.room_type == CreateRoomConfig.C_RoomTypeMap.TMode or RoomSystem.CurrentRoomInfo.room_type == CreateRoomConfig.C_RoomTypeMap.TMatch) then
    UIManager.ShowUI(UIManager.UI_Config.Xmission_Room_UIBP)
  else
    log(bWriteLog and "RoomSystem.OnShowWaitingUI==\231\187\143\229\133\184\230\136\191\233\151\180=" .. tostring(222))
    RoomSystem.ShowRoomWaitingUI()
  end
end
function RoomSystem.on_sync_room_info(room, members)
  log(bWriteLog and "RoomSystem.on_sync_room_info")
  if GameStatus.GetGameStatus() == GameStatus.Login then
    if not RoomSystem.CheckIsEmptyOrDisband(room) then
      RoomSystem.bPendingRoomSync = true
      log(bWriteLog and "RoomSystem.on_sync_room_info. bPendingRoomSync = true")
    end
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimer(3, function()
      RoomSystem.bPendingRoomSync = false
      log(bWriteLog and "RoomSystem.on_sync_room_info. clear bPendingRoomSync")
      RoomSystem.on_sync_room_info_internal(room, members)
    end)
  elseif room and room.room_type == "tmode" then
    local time_ticker = require("common.time_ticker")
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if RoomSystem.xmissionRoomTimer then
      time_ticker.RemoveTimer(RoomSystem.xmissionRoomTimer)
      RoomSystem.xmissionRoomTimer = nil
    end
    RoomSystem.xmissionRoomTimer = time_ticker.AddTimerLoop(0, function()
      if LogicTxMissionMain.IsInXMission() and UIManager.IsUIShow(UIManager.UI_Config.xmission_main) then
        log(bWriteLog and "RoomSystem.on_sync_room_info tmode")
        RoomSystem.on_sync_room_info_internal(room, members)
        local logic_xmission_room_team = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_room_team)
        logic_xmission_room_team:SyncRoomMember()
        if RoomSystem.xmissionRoomTimer then
          time_ticker.RemoveTimer(RoomSystem.xmissionRoomTimer)
          RoomSystem.xmissionRoomTimer = nil
        end
      end
    end, TIMER_INFINITE, 1)
  else
    log(bWriteLog and "RoomSystem.on_sync_room_info default")
    RoomSystem.on_sync_room_info_internal(room, members)
  end
end
function RoomSystem.on_room_start_game_notify(res, antsvoice_url)
  log(bWriteLog and "RoomSystem.on_room_start_game_notify, received on_room_start_game_notify, res = " .. tostring(res))
  if res == "start" then
    RoomSystem.CurrentRoomInfo.state = "gaming"
    local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
    ui_jump_manager.Clear()
    local logic_room_match_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_room_match_voice)
    logic_room_match_voice:OnQuitMatchRoom()
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    LogicUGCMatch:UpdateLastRoomMatchTime()
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
    logic_enter_game:SetRoomID(1)
    logic_chat_voice:SetBattleAntsVoiceRoomParam(nil, nil, antsvoice_url)
    local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
    logic_chat_voice_doctor:AddJoinTeamRoomStep(900)
    local logic_loading = require("client.slua.logic.loading.logic_loading")
    logic_loading.SetInitPercent(50)
    logic_loading.ShowLoading(false)
  elseif res == "load-game-fail" then
    RoomSystem.CurrentRoomInfo.state = "idle"
    local title = LocUtil.GetLocalizeResStr(101001)
    local content = LocUtil.GetLocalizeResStr(9911109)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, content)
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    LoadingSystem.RefreshLoadPercent(1)
  elseif res == "version-not-support" then
    RoomSystem.CurrentRoomInfo.state = "idle"
    local title = LocUtil.GetLocalizeResStr(101001)
    local content = LocUtil.GetLocalizeResStr(9911112)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, content, RoomSystem.OnLoadStartGameFailed, nil)
  else
    RoomSystem.CurrentRoomInfo.state = "idle"
  end
end
function RoomSystem.team_match_zone_notify(match_zone)
  RoomSystem.RoomZoneId = match_zone
  log(bWriteLog and "team_match_zone_notify RoomSystem.RoomZoneId=" .. tostring(RoomSystem.RoomZoneId))
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_ROOM_INFO)
end
function RoomSystem.on_select_zone_rsp(ret, match_zone)
  log(bWriteLog and "RoomSystem.on_select_zone_rsp, ret = " .. tostring(ret) .. ", match_zone = " .. tostring(match_zone))
  if string.lower(ret) == NetErrorCode_NONE then
    if not RoomSystem.RoomZoneId or RoomSystem.RoomZoneId ~= match_zone then
      RoomSystem.RoomZoneId = match_zone
      log(bWriteLog and "RoomSystem.on_select_zone_rsp")
      EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_ROOM_INFO)
    end
  elseif string.lower(ret) == "on_room" or string.lower(ret) == "invalid zone" then
    textMsg = LocUtil.GetLocalizeResStr(4055)
    ShowNotice(textMsg)
  elseif string.lower(ret) == "not_owner" then
    textMsg = LocUtil.GetLocalizeResStr(4056)
    ShowNotice(textMsg)
  elseif string.lower(ret) == "in_game" then
    textMsg = LocUtil.GetLocalizeResStr(4057)
    ShowNotice(textMsg)
  elseif string.lower(ret) == "unknown_err" then
    textMsg = LocUtil.GetLocalizeResStr(4058)
    ShowNotice(textMsg)
  elseif tonumber(ret) and tonumber(ret) == 100150049 then
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
end
function RoomSystem.on_select_zone_req(zone_id)
  log(bWriteLog and "RoomSystem.on_select_zone_req,match_zone = " .. tostring(zone_id))
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_on_select_zone_req(zone_id)
  RoomSystem.on_select_zone_rsp(NetErrorCode_NONE, zone_id)
end
function RoomSystem.on_lock_room_pos_respond(res, lock_pos)
  log(bWriteLog and "on_lock_room_pos_respond lock_pos = " .. tostring(lock_pos))
  if res ~= 0 then
    log(bWriteLog and "failed")
    return
  end
  log(bWriteLog and "succeed")
end
function RoomSystem.on_unlock_room_pos_respond(res, unlock_pos)
  log(bWriteLog and "on_unlock_room_pos_respond, unlock_pos = " .. tostring(unlock_pos))
  if res ~= 0 then
    log(bWriteLog and "failed")
    return
  end
  log(bWriteLog and "succeed")
end
function RoomSystem.on_sync_room_lock(islock, pos)
  log(bWriteLog and "on_sync_room_lock")
  if islock == true then
    log(bWriteLog and "lock")
    RoomSystem.CurrentRoomInfo.lock_pos_list[pos] = true
  else
    log(bWriteLog and "unlock")
    RoomSystem.CurrentRoomInfo.lock_pos_list[pos] = nil
  end
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_MEMBER)
end
function RoomSystem.EnterRoomByAllStar(room, members, carteamInfo)
  RoomSystem.CurrentCarteamInfo = carteamInfo
  BattleResult.IgnoreDSError = false
  RoomSystem.SetCurrentRoomInfo(room)
  RoomSystem.CurrentRoomInfo.owner_id = tostring(RoomSystem.CurrentRoomInfo.owner_id)
  RoomSystem.CurrentRoomInfo.roomType = ENUM_ROOM_TYPE.ALLSTAR
  RoomSystem.CurrentRoomInfo.MemberInfoList = {}
  RoomSystem.BeKickedPlayerList = {}
  RoomSystem.CurrentRoomInfo.player_count = 0
  RoomSystem.CurrentRoomInfo.ob_count = 0
  for k, v in pairs(members) do
    local tmp = v
    tmp.openid = tostring(k)
    tmp.isRoomMaster = RoomSystem.CurrentRoomInfo.owner_id == tmp.openid
    tmp.head_url = ""
    tmp.gender = 0
    tmp.frame_level = 0
    table.insert(RoomSystem.CurrentRoomInfo.MemberInfoList, tmp)
    if v.pos > 100 then
      RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count + 1
    else
      RoomSystem.AddPlayerCount()
    end
  end
  RoomSystem.ShowRoomWaitingUI_AllStar()
  RoomSystem.req_profile_join_room()
end
function RoomSystem.on_set_room_prepared_rsp(unpreparedNum)
  local logic_xmission_room = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_room)
  logic_xmission_room:SetUnPreparedNum(unpreparedNum)
end
function RoomSystem.room_invite_request(userid)
  log(bWriteLog and "room_invite_request, invite: " .. tostring(userid))
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_room_invite_request(userid)
end
function RoomSystem.on_room_invite_respond(res, invitee, extend_info)
  log(bWriteLog and "on_room_invite_respond res = " .. res .. ", invitee = " .. tostring(invitee))
  if res == 0 then
    ShowNotice(110004)
  elseif res == "refuse" then
    if extend_info ~= nil and extend_info.reply_type ~= nil then
      if extend_info.reply_type == 1 and extend_info.refuseMsgInfo ~= nil then
        ShowNotice(tostring(extend_info.refuseMsgInfo))
      elseif extend_info.reply_type == 2 then
        ShowNotice(110011)
      end
    else
      ShowNotice(110011)
    end
  elseif res == 110116 then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(110116))
  elseif res == 100040015 then
    ShowNotice(18951)
  else
    HandleErrorCode(res)
  end
end
function RoomSystem.on_room_invite_reply_notify(res, invitee, extend_info)
  log(bWriteLog and "on_room_invite_respond res = " .. res .. ", invitee = " .. tostring(invitee))
  log_tree("[chub]on_room_invite_respond, extend_info = ", extend_info)
  if res == NetErrorCode_NONE then
    return
  end
  if res == "autoRefuseOnTeamChange" then
    ShowNotice(110056)
    return
  end
  if res == "refuse" then
    if extend_info and extend_info.reason_id then
      local reason = LocUtil.LocalizeResFormat(extend_info.reason_id)
      ShowNotice(LocUtil.LocalizeResFormat(43751, extend_info.nickName or "", reason))
      return
    end
    if extend_info ~= nil and extend_info.reply_type ~= nil then
      if extend_info.reply_type == 1 and extend_info.refuseMsgInfo ~= nil or extend_info.reply_type == 2 then
        ShowNotice(110011)
      end
    else
      ShowNotice(110011)
    end
  end
end
function RoomSystem.req_edit_room()
  local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
  local basicParam = CreateRoomSystem.basicParam
  local battleCfg = {}
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  local roomType = RoomSystem.CurrentRoomInfo.room_type
  if roomType == CreateRoomConfig.C_RoomTypeMap.Advance or roomType == CreateRoomConfig.C_RoomTypeMap.Match then
    battleCfg = CreateRoomSystem.advanceParam
  else
    battleCfg = CreateRoomSystem.advanceParam or CreateRoomSystem.GetOrdinaryBattleConfig()
  end
  RoomSystem.req_change_room(basicParam.sRoomName, basicParam.nMapID, basicParam.sPassword, basicParam.nPlayerNum, true, battleCfg)
end
function RoomSystem.req_change_room(name, map_id, password, group_type, allow_invite, battle_cfg, modeid)
  local local_map = CDataTable.GetTableData("Map", map_id)
  local isfpp = local_map.IsFpp and local_map.IsFpp == 1
  if password == "" then
    local RoomHandler = require("client.network.Protocol.RoomHandler")
    RoomHandler.send_change_room_request(name, map_id, nil, group_type, allow_invite, battle_cfg, isfpp, RoomSystem.CurrentRoomInfo.use_pc_param)
  else
    local RoomHandler = require("client.network.Protocol.RoomHandler")
    RoomHandler.send_change_room_request(name, map_id, password, group_type, allow_invite, battle_cfg, isfpp, RoomSystem.CurrentRoomInfo.use_pc_param)
  end
end
function RoomSystem.on_change_room_respond(res)
  log(bWriteLog and "on_change_room_respond res = " .. res)
  if res ~= 0 then
    HandleErrorCode(res)
    return
  end
  UIManager.CloseUI(UIManager.UI_Config.room_option)
  UIManager.CloseUI(UIManager.UI_Config.room_create)
end
function RoomSystem.on_sync_room_change(room_id, room)
  log(bWriteLog and "on_sync_room_change")
  log_tree("room = ", room)
  local tmp = RoomSystem.CurrentRoomInfo
  RoomSystem.SetCurrentRoomInfo(room)
  RoomSystem.CurrentRoomInfo.MemberInfoList = tmp.MemberInfoList
  if RoomSystem.CurrentRoomInfo.group_type ~= room.group_type then
    RoomSystem.CurrentRoomInfo.group_type = room.group_type
    bModifyMode = true
    EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_RESET_ROOM_INFO)
  else
    EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_ROOM_INFO)
  end
end
function RoomSystem.on_exit_room_rsp()
  local logic_room_match_voice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_room_match_voice)
  if logic_room_match_voice then
    logic_room_match_voice:OnQuitMatchRoom()
  end
  RoomSystem.SetCurrentRoomInfo({})
  RoomSystem.BeKickedPlayerList = {}
  RoomSystem.idc_flag = -1
  local logic_community = require("client.slua.logic.community.logic_community")
  logic_community.SendOnRoomStateChange(false)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
  if LogicTxMissionMain.IsInXMission() and UIManager.IsUIShow(UIManager.UI_Config.xmission_main) and not LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide() then
    LogicXMissionBeginnerGuide.ContinueBeginnerGuide()
  end
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_BE_DISBAND)
end
function RoomSystem.kickout_simulator_user_req()
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_kickout_simulator_user_req()
end
function RoomSystem.on_kickout_simulator_user_rsp(res, kick_count)
  if res ~= 0 then
    HandleErrorCode(res)
    return
  end
end
function RoomSystem.on_kickout_simulator_user_notify(kickIds)
  if RoomSystem.CurrentRoomInfo == nil then
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "Not lobby on_kickout_simulator_user_notify ")
    return
  end
  for _, id in ipairs(kickIds) do
    RoomSystem.on_sync_room_member(id)
  end
end
function RoomSystem.on_room_next_match_ready_notify(roomId)
  local curStatus = GameStatus.GetGameStatus()
  if GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local onClickCallBack = function()
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    LoadingSystem.ShowLoading(true)
    LobbySystem.ReturnToLobby()
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(6928), onClickCallBack, onClickCallBack, nil, nil, nil, nil, nil, 3)
end
function RoomSystem.SendPullBackFromResult()
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_enter_next_match(RoomSystem.CurrentRoomInfo.id)
end
function RoomSystem.IsShowWaiting()
  return UIManager.IsUIShow(UIManager.UI_Config.ui_room_waiting) or UIManager.IsUIShow(UIManager.UI_Config.ui_room_waiting_test) or UIManager.IsUIShow(UIManager.UI_Config.ui_room_waiting_allstar) or UIManager.IsUIShow(UIManager.UI_Config.UGCRoomWaitingPanel) or UIManager.IsUIShow(UIManager.UI_Config.Xmission_Room_UIBP)
end
function RoomSystem.GetMaxTeamPlayerNum()
  local maxTeamPlayerNum = 0
  if not RoomSystem.CurrentRoomInfo then
    return maxTeamPlayerNum
  end
  if RoomSystem.CurrentRoomInfo.group_type == 4 then
    local map_info = CDataTable.GetTableData("Map", RoomSystem.CurrentRoomInfo.map_id)
    if map_info then
      local bt_mode = CDataTable.GetTableData("MatchModeTable", map_info.IsTeamValid)
      if bt_mode then
        maxTeamPlayerNum = bt_mode.MaxTeamPlayerNum
      end
    else
      log(bWriteLog and "GetMaxTeamPlayerNum map not found mapid[" .. tostring(RoomSystem.CurrentRoomInfo.map_id) .. "]")
    end
  else
    maxTeamPlayerNum = RoomSystem.CurrentRoomInfo.group_type
  end
  return maxTeamPlayerNum
end
function RoomSystem.GetSelfPos()
  local currentRoomInfo = RoomSystem.CurrentRoomInfo
  if not currentRoomInfo or not currentRoomInfo.MemberInfoList then
    return nil
  end
  local selfUid = tostring(DataMgr.roleData.uid)
  for _, memberInfo in pairs(currentRoomInfo.MemberInfoList) do
    local memberOpenId = tostring(memberInfo.openid)
    local memberUid = tostring(memberInfo.uid)
    if memberOpenId == selfUid or memberUid == selfUid then
      return memberInfo.pos
    end
  end
  return nil
end
function RoomSystem.GetSelfTeamIds()
  local currentRoomInfo = RoomSystem.CurrentRoomInfo
  local TableUtil = require("common.table_util")
  local memberInfoList = TableUtil.GetTableValue(RoomSystem.CurrentRoomInfo, "MemberInfoList")
  if not currentRoomInfo or not memberInfoList then
    return {}
  end
  local selfInfo = {}
  for _, v in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
    if v.openid == DataMgr.roleData.uid then
      selfInfo = v
      break
    end
  end
  local team_size = currentRoomInfo.group_type
  if team_size == 4 then
    local map_info = CDataTable.GetTableData("Map", RoomSystem.CurrentRoomInfo.map_id)
    if map_info then
      local bt_mode = CDataTable.GetTableData("MatchModeTable", map_info.IsTeamValid)
      if bt_mode then
        team_size = bt_mode.MaxTeamPlayerNum
      end
    else
      log(bWriteLog and "GetSelfTeamIds map not found mapid[" .. tostring(RoomSystem.CurrentRoomInfo.map_id) .. "]")
    end
  end
  local uid_list = {}
  local selfPos = TableUtil.GetTableValue(selfInfo, "pos")
  if not selfPos then
    return uid_list
  end
  if 100 < selfPos or team_size == 1 then
    table.insert(uid_list, tonumber(selfInfo.openid))
    return uid_list
  end
  local members = {}
  if team_size == nil then
    team_size = 4
  end
  local myTeamNum = math.floor((selfPos - 1) / team_size)
  for _, v in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
    if math.floor((v.pos - 1) / team_size) == myTeamNum then
      table.insert(uid_list, tonumber(v.openid))
      table.insert(members, v)
    end
  end
  return uid_list, members
end
function RoomSystem.OnQuickJoinRoom(roominfo)
  roominfo = roominfo or RoomSystem.QRCodeRoomInfo
  if roominfo and type(roominfo) == "table" and next(roominfo) and roominfo.game_roomid ~= nil and roominfo.game_roompw ~= nil then
    log(bWriteLog and "[edward][logic_room] RoomSystem.OnQuickJoinRoom, rmid=" .. tostring(roominfo.game_roomid) .. " rmpw=" .. tostring(roominfo.game_roompw))
    local curStatus = GameStatus.GetGameStatus()
    if curStatus == GameStatus.Login then
      return
    end
    if not GameStatus.IsInLobbyOrMainCity() then
      RoomSystem.QRCodeRoomInfo = nil
      return
    end
    if curStatus == GameStatus.Createrole then
      return
    end
    if RoomSystem.IsShowWaiting() then
      ShowNotice(110132)
      RoomSystem.QRCodeRoomInfo = nil
      return
    end
    if LobbySystem.isInMatch then
      log(bWriteLog and "LobbySystem.isInMatch")
      ShowNotice(110133)
      RoomSystem.QRCodeRoomInfo = nil
      return
    end
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if TeamUpNewSystem.GetTeamNum() > 1 then
      ShowNotice(110103)
      RoomSystem.QRCodeRoomInfo = nil
      return
    end
    local RoomListSystem = require("client.slua.logic.room.logic_room_list")
    RoomListSystem.ShowUI()
    RoomSystem.IsQRCodeEnterRoom = true
    RoomSystem.req_join_room(tonumber(roominfo.game_roomid), roominfo.game_roompw)
  end
end
function RoomSystem.ResumeRoom()
  log(bWriteLog and "RoomSystem.ResumeRoom")
  if not RoomSystem.CurrentRoomInfo or not next(RoomSystem.CurrentRoomInfo) then
    log(bWriteLog and "RoomSystem.ResumeRoom RoomSystem.CurrentRoomInfo is nil")
    RoomSystem.TryReconnectRoomByLocalData()
    return
  end
  if RoomSystem.CurrentRoomInfo.room_type == "tmode" then
    local time_ticker = require("common.time_ticker")
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if RoomSystem.xmissionRoomTimer then
      time_ticker.RemoveTimer(RoomSystem.xmissionRoomTimer)
      RoomSystem.xmissionRoomTimer = nil
    end
    RoomSystem.xmissionRoomTimer = time_ticker.AddTimerLoop(0, function()
      if LogicTxMissionMain.IsInXMission() and UIManager.IsUIShow(UIManager.UI_Config.xmission_main) then
        log(bWriteLog and "RoomSystem.ResumeRoom tmode")
        if UIManager.IsUIShow(UIManager.UI_Config.Xmission_Room_UIBP) then
          log(bWriteLog and "RoomSystem.ResumeRoom tmode already exist")
          if RoomSystem.xmissionRoomTimer then
            time_ticker.RemoveTimer(RoomSystem.xmissionRoomTimer)
            RoomSystem.xmissionRoomTimer = nil
          end
          return
        end
        RoomSystem.on_sync_room_info_internal(RoomSystem.CurrentRoomInfo, RoomSystem.CurrentRoomInfo.MemberInfoList, true)
        if RoomSystem.xmissionRoomTimer then
          time_ticker.RemoveTimer(RoomSystem.xmissionRoomTimer)
          RoomSystem.xmissionRoomTimer = nil
        end
      end
    end, TIMER_INFINITE, 1)
  else
    RoomSystem.on_sync_room_info_internal(RoomSystem.CurrentRoomInfo, RoomSystem.CurrentRoomInfo.MemberInfoList, true)
  end
end
function RoomSystem.GetRoomMemberList()
  local roomMemberList = {}
  if not RoomSystem.CurrentRoomInfo or not RoomSystem.CurrentRoomInfo.MemberInfoList then
    log(bWriteLog and "RoomSystem.GetRoomMemberList no MemberInfo")
    return roomMemberList
  end
  for _, member in ipairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
    if not member.is_robot then
      table.insert(roomMemberList, member)
    end
  end
  table.sort(roomMemberList, function(a, b)
    return a.pos < b.pos
  end)
  log_tree(bWriteLog and "RoomSystem.GetRoomMemberList roomMemberList:", roomMemberList)
  return roomMemberList
end
function RoomSystem.CanShowTeamChat()
  if not RoomSystem.CurrentRoomInfo or not RoomSystem.CurrentRoomInfo.MemberInfoList then
    log(bWriteLog and "RoomSystem.CanShowTeamChat no MemberInfo")
    return false
  end
  for _, member in ipairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
    if tonumber(member.openid) == tonumber(DataMgr.roleData.uid) and member.pos > 100 then
      log(bWriteLog and "RoomSystem.CanShowTeamChat ob")
      return false
    end
  end
  if RoomSystem.CurrentRoomInfo.ugc_room_param then
    if RoomSystem.CurrentRoomInfo.ugc_room_param.team_size <= 1 then
      log(bWriteLog and "RoomSystem.CanShowTeamChat UGC team_size:" .. tostring(RoomSystem.CurrentRoomInfo.ugc_room_param.team_size))
      return false
    end
  elseif RoomSystem.CurrentRoomInfo.group_type == 1 then
    log(bWriteLog and "RoomSystem.CanShowTeamChat group_type == 1")
    return false
  end
  log(bWriteLog and "RoomSystem.CanShowTeamChat can show")
  return true
end
function RoomSystem.GetTeamMemberList()
  local teamMemberList = {}
  if not RoomSystem.CurrentRoomInfo or not RoomSystem.CurrentRoomInfo.MemberInfoList then
    log(bWriteLog and "RoomSystem.GetTeamMemberList no MemberInfo")
    return teamMemberList
  end
  local team_size
  if RoomSystem.CurrentRoomInfo.ugc_room_param then
    team_size = RoomSystem.CurrentRoomInfo.ugc_room_param.team_size
  else
    team_size = RoomSystem.CurrentRoomInfo.group_type
    if team_size == 4 and RoomSystem.CheckTeamModeIsMulti() then
      team_size = RoomSystem.GetMaxTeamPlayerNum()
    end
  end
  if not team_size or team_size == 0 then
    log(bWriteLog and "RoomSystem.GetTeamMemberList team_size error")
    return teamMemberList
  end
  local myTeamId
  for _, member in ipairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
    if tonumber(member.openid) == tonumber(DataMgr.roleData.uid) then
      myTeamId = math.floor((member.pos - 1) / team_size + 1)
      log(bWriteLog and "RoomSystem.GetTeamMemberList myTeamId:" .. tostring(myTeamId))
      break
    end
  end
  for _, member in ipairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
    if math.floor((member.pos - 1) / team_size + 1) == myTeamId and not member.is_robot then
      table.insert(teamMemberList, member)
    end
  end
  table.sort(teamMemberList, function(a, b)
    return a.pos < b.pos
  end)
  log_tree(bWriteLog and "RoomSystem.GetTeamMemberList teamMemberList:", teamMemberList)
  return teamMemberList
end
function RoomSystem.CheckTeamModeIsMulti()
  local map_id = RoomSystem.CurrentRoomInfo.map_id
  local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
  local team_size = CreateRoomSystem.GetTeamModeMaxPlayerNum(map_id)
  local ismulti = 4 < team_size
  log(bWriteLog and "RoomSystem.CheckTeamModeIsMulti ismulti:" .. tostring(ismulti))
  return ismulti
end
function RoomSystem.AddPlayerCount()
  local count = RoomSystem.CurrentRoomInfo.player_count or 0
  RoomSystem.CurrentRoomInfo.player_count = count + 1
  log(bWriteLog and "RoomSystem.AddPlayerCount = " .. RoomSystem.CurrentRoomInfo.player_count)
end
function RoomSystem.RemovePlayerCount()
  local count = RoomSystem.CurrentRoomInfo.player_count or 0
  RoomSystem.CurrentRoomInfo.player_count = math.max(count - 1, 0)
  log(bWriteLog and "RoomSystem.RemovePlayerCount = " .. RoomSystem.CurrentRoomInfo.player_count)
end
function RoomSystem.on_set_member_prepared_rsp()
  log(bWriteLog and "RoomSystem.RemovePlayerCount = " .. RoomSystem.CurrentRoomInfo.player_count)
  if not RoomSystem.CurrentRoomInfo.MemberInfoList or not next(RoomSystem.CurrentRoomInfo.MemberInfoList) then
    return
  end
  for k, v in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
    if v.openid == DataMgr.roleData.uid then
      v.state = "prepared"
    end
  end
end
function RoomSystem.GetRoomWeather()
  local id, level
  if not RoomSystem.CurrentRoomInfo or not RoomSystem.CurrentRoomInfo.weather_client then
    local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
    local defWeather = CreateRoomSystem.GetDefaultWeather()
    id = defWeather.id
    level = defWeather.level
  else
    for k, v in pairs(RoomSystem.CurrentRoomInfo.weather_client) do
      id = k
      level = v
      break
    end
  end
  return {id = id, level = level}
end
function RoomSystem.SetCurrentRoomInfo(info)
  if not RoomSystem.SaveLocalRoomData then
    RoomSystem._LoadLocalRoomData()
  end
  RoomSystem.CurrentRoomInfo = info
  log_tree("RoomSystem.CurrentRoomInfo = ", RoomSystem.SetCurrentRoomInfo)
  local CreateRoomSystem = require("client.slua.logic.room.logic_create_room")
  CreateRoomSystem.RefreshBasicParam()
  CreateRoomSystem.RefreshAdvanceParam()
  if RoomSystem.SaveLocalRoomData then
    local joinData = RoomSystem.RecordJoinRoomParams
    RoomSystem.SaveLocalRoomData[DataMgr.roleData.uid] = {
      id = info and info.id or 0,
          }
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N(RoomSystem.SaveLocalRoomData, PlayerPrefsSystem.ePlayerPrefsType.eRoomIDLocalSave)
  end
end
function RoomSystem._LoadLocalRoomData()
  local uid = DataMgr.roleData.uid
  if not uid or uid == "" then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  RoomSystem.SaveLocalRoomData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRoomIDLocalSave) or {}
  log_tree("RoomSystem._LoadLocalRoomData SaveLocalRoomData = ", RoomSystem.SaveLocalRoomData)
end
function RoomSystem.GetLocalRoomData()
  if not RoomSystem.SaveLocalRoomData then
    RoomSystem._LoadLocalRoomData()
  end
  return RoomSystem.SaveLocalRoomData[DataMgr.roleData.uid]
end
function RoomSystem.CheckNeedReconnect()
  local hasRoomData = RoomSystem.HasRoomData()
  local isOwner = RoomSystem.isRoomOwner()
  return hasRoomData and not isOwner
end
function RoomSystem.HasRoomData()
  return RoomSystem.CurrentRoomInfo and RoomSystem.CurrentRoomInfo.id and RoomSystem.CurrentRoomInfo.id > 0
end
function RoomSystem.TryReconnectRoomByLocalData(otherSaveLocalRoomData)
  log(bWriteLog and "RoomSystem.TryReconnectRoomByLocalData")
  if RoomSystem.HasRoomData() then
    return
  end
  RoomSystem._LoadLocalRoomData()
  local localData = otherSaveLocalRoomData or RoomSystem.SaveLocalRoomData and RoomSystem.SaveLocalRoomData[DataMgr.roleData.uid]
  local delayTimer = otherSaveLocalRoomData and 1 or 2
  log(bWriteLog and "RoomSystem.TryReconnectRoomByLocalData delayTimer:" .. tostring(delayTimer))
  local roomID = localData and localData.id or 0
  local joinData = localData and localData.joinData
  log(bWriteLog and "RoomSystem.TryReconnectRoomByLocalData roomID:" .. tostring(roomID))
  log_tree("RoomSystem.TryReconnectRoomByLocalData joinData =", joinData)
  if 0 < roomID and joinData then
    RoomSystem.ClearReconnectTimer()
    local callback = function()
      log_tree("RoomSystem.TryReconnectRoomByLocalData delay callback")
      RoomSystem.TryConnectTimer = nil
      local titleStr = LocUtil.GetLocalizeResStr(101001)
      local msgStr = LocUtil.GetLocalizeResStr(46880164)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, titleStr, msgStr, function()
        RoomSystem.req_join_room(joinData._roomID, joinData._passWd, joinData.join_type, joinData.third_party_info)
      end, function()
        RoomSystem.SetCurrentRoomInfo({})
      end)
    end
    local timer_ticker = require("common.time_ticker")
    RoomSystem.TryConnectTimer = timer_ticker.AddTimerOnce(delayTimer, callback)
  end
end
function RoomSystem.ClearReconnectTimer()
  log(bWriteLog and "RoomSystem.ClearReconnectTimer")
  if RoomSystem.TryConnectTimer then
    local timer_ticker = require("common.time_ticker")
    timer_ticker.RemoveTimer(RoomSystem.TryConnectTimer)
    RoomSystem.TryConnectTimer = nil
  end
end
function RoomSystem.SetAutoReconnectParam(param)
  log(bWriteLog and "RoomSystem.SetAutoReconnectParam")
  local heartbeat_timeout = 10
  local seat_timeout = 29
  param.times = heartbeat_timeout + seat_timeout
  function param.showFunc()
    log(bWriteLog and "RoomSystem.SetAutoReconnectParam showFunc")
    UIManager.ShowUI(UIManager.UI_Config.Room_OfflineStatus_UIBP)
  end
  function param.clearFunc()
    log(bWriteLog and "RoomSystem.SetAutoReconnectParam clearFunc")
    UIManager.CloseUI(UIManager.UI_Config.Room_OfflineStatus_UIBP)
  end
end
function RoomSystem.OnConnectedToLobbyServer()
  log(bWriteLog and "RoomSystem.OnConnectedToLobbyServer")
  local uid = DataMgr.roleData and DataMgr.roleData.uid
  if not uid or uid == "" then
    return
  end
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_room_info_request()
end
function RoomSystem.req_lock_team_request(team_id)
  log(bWriteLog and "req_lock_team_request: team_id = " .. tostring(team_id))
  if RoomSystem.CurrentRoomInfo == nil then
    return
  end
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_lock_team_request(team_id)
end
function RoomSystem.on_lock_team_respond(team_id)
  log(bWriteLog and "RoomSystem.on_lock_team_respond = ", team_id)
end
function RoomSystem.req_unlock_team_request(team_id)
  log(bWriteLog and "req_unlock_team_request: team_id = " .. tostring(team_id))
  if RoomSystem.CurrentRoomInfo == nil then
    return
  end
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_unlock_team_request(team_id)
end
function RoomSystem.on_unlock_team_respond(team_id)
  log(bWriteLog and "RoomSystem.on_unlock_team_respond = ", team_id)
end
function RoomSystem.req_set_pos_arranging_request()
  log(bWriteLog and "RoomSystem.req_set_pos_arranging_request")
  if RoomSystem.CurrentRoomInfo == nil then
    return
  end
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_set_pos_arranging_request()
end
function RoomSystem.on_set_pos_arranging_respond()
  log(bWriteLog and "RoomSystem.set_pos_arranging_respond")
end
function RoomSystem.req_cancel_pos_arranging_request()
  log(bWriteLog and "RoomSystem.req_cancel_pos_arranging_request")
  if RoomSystem.CurrentRoomInfo == nil then
    return
  end
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_cancel_pos_arranging_request()
end
function RoomSystem.on_cancel_pos_arranging_respond()
  log(bWriteLog and "RoomSystem.on_cancel_pos_arranging_respond")
end
function RoomSystem.on_change_other_pos_request(new_pos, op_uid)
  log(bWriteLog and "req_change_room_pos_request: new_pos = " .. tostring(new_pos) .. "op_uid == " .. tostring(op_uid))
  if RoomSystem.CurrentRoomInfo == nil then
    return
  end
  local RoomHandler = require("client.network.Protocol.RoomHandler")
  RoomHandler.send_change_other_pos_request(RoomSystem.CurrentRoomInfo.id, new_pos, tonumber(op_uid))
end
function RoomSystem.on_change_other_pos_respond(new_pos, op_uid)
  log(bWriteLog and "RoomSystem.on_change_other_pos_respond new_pos is " .. tostring(new_pos) .. " op_uid is " .. tostring(op_uid))
  if RoomSystem.CurrentRoomInfo.MemberInfoList == nil then
    log(bWriteLog and "RoomSystem.on_change_other_pos_respond RoomSystem.CurrentRoomInfo.MemberInfoList is nil")
    return
  end
  RoomSystem.CurrentRoomInfo.player_count = 0
  RoomSystem.CurrentRoomInfo.ob_count = 0
  RoomSystem.CurrentRoomInfo.change_other_pos_first_uid = 100 < new_pos and op_uid or nil
  for _, v in pairs(RoomSystem.CurrentRoomInfo.MemberInfoList) do
    if tonumber(op_uid) == tonumber(v.openid) then
      v.pos = new_pos
      log(bWriteLog and "RoomSystem.on_change_other_pos_respond RoomSystem.CurrentRoomInfo.MemberInfoList set new pos")
    end
    if 100 < v.pos then
      RoomSystem.CurrentRoomInfo.ob_count = RoomSystem.CurrentRoomInfo.ob_count + 1
    elseif 100 >= v.pos then
      RoomSystem.CurrentRoomInfo.player_count = RoomSystem.CurrentRoomInfo.player_count + 1
    end
  end
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_ROOM_INFO)
end
function RoomSystem.CheckNewPosCanChange(new_pos)
  local lockTeamList = RoomSystem.CurrentRoomInfo and RoomSystem.CurrentRoomInfo.LockTeamInfoList or {}
  local new_team_id = math.floor((new_pos - 1) / 4) + 1
  log(bWriteLog and "RoomSystem.CheckNewPosCanChange new pos is " .. tostring(new_pos) .. " new team id is " .. tostring(new_team_id))
  if lockTeamList[new_team_id] then
    ShowNotice(468890058)
    return false
  end
  return true
end
function RoomSystem.IsPlayerPos(pos)
  return pos and pos <= 100
end
function RoomSystem.IsObserverPos(pos)
  return pos and 100 < pos and pos ~= 999
end
function RoomSystem.RoomMemberRejectDownloadNotify(member_uid, room_id)
  if RoomSystem.CurrentRoomInfo == nil then
    log(bWriteLog and "RoomSystem.RoomMemberRejectDownloadNotify return CurrentRoomInfo is nil")
    return
  end
  if RoomSystem.CurrentRoomInfo.id ~= room_id then
    log(bWriteLog and "RoomSystem.RoomMemberRejectDownloadNotify return room_id is not match")
    return
  end
  if not RoomSystem.isRoomOwner() then
    log(bWriteLog and "RoomSystem.RoomMemberRejectDownloadNotify return is not room owner")
    return
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({member_uid}, function(profileList)
    for k, profile in pairs(profileList) do
      ShowNotice(LocUtil.LocalizeResFormat(10120064, profile.nickName))
    end
  end, Enum_PROFILE_REPORT_CFG.UGC)
end
return RoomSystem