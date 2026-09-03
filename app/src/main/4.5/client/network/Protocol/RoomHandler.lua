local NetManager = require("client.network.comm.NetManager")
local RoomHandler = {}
local HandleErrorCode = function(res, isnot_show_tip)
  if res ~= 0 then
    if isnot_show_tip then
      return true
    end
    if res == 210013 then
      ShowNotice(505089)
    elseif res == 210014 then
      ShowNotice(505090)
    elseif res == 210015 or res == 210023 then
      ShowNotice(505091)
    elseif res == 210016 then
      ShowNotice(505092)
    elseif res == 210017 then
      ShowNotice(505093)
    elseif res == 210018 then
      ShowNotice(505094)
    elseif res == 210019 then
      ShowNotice(505095)
    elseif res == 210020 then
      ShowNotice(505096)
    elseif res == 210021 then
      ShowNotice(505097)
    elseif res == 210022 then
      ShowNotice(505098)
    elseif res == 210002 then
      ShowNotice(505099)
    elseif res == 110068 then
      ShowNotice(18351)
    elseif res == 110148 or res == 110149 or res == 210006 then
      ShowNotice(505089)
    else
      ShowNotice(res)
    end
    return true
  end
  return false
end
local _ShowErrorTips = function(errorCode)
  if not errorCode then
    return false
  end
  if errorCode == 0 then
    return false
  elseif errorCode == 100150049 then
    ShowNotice(200000108)
  elseif errorCode == 49480 then
    return false
  else
    log(bWriteLog and " RoomHandler._ShowErrorTips, errorCode = " .. errorCode)
    ShowNotice(errorCode)
  end
  return true
end
function RoomHandler.send_room_info_request()
  NetManager.SendPkg(1868323700)
end
function RoomHandler.on_sync_room_info(room, members)
  RoomSystem.on_sync_room_info(room, members)
end
function RoomHandler.on_room_info_notify(room_id, opt, param)
  RoomSystem.on_room_info_notify(room_id, opt, param)
end
function RoomHandler.send_set_room_passwd_req(password)
  NetManager.SendPkg(1057587295, password)
end
function RoomHandler.on_set_room_passwd_rsp(res, password)
  if res ~= 0 then
    HandleErrorCode(res)
    return
  end
  RoomSystem.CurrentRoomInfo.  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_CHANGE_PASSWORD)
end
function RoomHandler.send_query_rooms_req(view_type, zone_id, map_id, page, template_type, mod_id)
  NetManager.SendPkg(1180663463, view_type, zone_id, map_id, page, template_type, mod_id)
end
function RoomHandler.on_query_rooms_rsp(view_type, zone_id, map_id, page, view_room, template_type)
  local LogicUGCRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCRoom)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if view_type == Config_UGC.RoomListType or view_type == Config_UGC.DetailRoomListType then
    LogicUGCRoom:OnSyncRoomList(view_room, page, #view_room, template_type)
    return
  end
  local curCount = #RoomSystem.RoomInfoList
  if page == 1 then
    curCount = 0
  end
  local RoomListSystem = require("client.slua.logic.room.logic_room_list")
  RoomListSystem.OnSyncRoomList(view_room, curCount + 1, #view_room)
end
function RoomHandler.send_query_room_password_state_req(room_id)
  NetManager.SendPkg(481125475, room_id)
end
function RoomHandler.on_query_room_password_state_rsp(err, room_id, room_type, have_password, tournament_data)
  log(bWriteLog and "on_query_room_password_state_rsp have_password=" .. tostring(have_password))
  log_tree("on_query_room_password_state_rsp", tournament_data)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if err ~= 0 then
    log(bWriteLog and "on_query_room_respond, res:" .. err)
    HandleErrorCode(err)
    local RoomListSystem = require("client.slua.logic.room.logic_room_list")
    RoomListSystem.ReqRoomListWhenError()
    TeamUpNewSystem.nInviterRoomID = 0
    return
  end
  if not Client.IsWindowOB() and UIManager.IsUIShow(UIManager.UI_Config.room_list) then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if room_type and room_type ~= "tmode" and LogicTxMissionMain.IsInXMission() then
      HandleErrorCode(67831)
      return
    elseif room_type and room_type == "tmode" and not LogicTxMissionMain.IsInXMission() then
      HandleErrorCode(67830)
      return
    end
  end
  if room_type and room_type == "bouns" then
    local tournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
    local title = LocUtil.LocalizeResFormat("101001")
    local cost_u = 0
    local cost_t = 0
    tournamentsManager.query_    tournamentsManager.query_tournament_id = tournament_data.tournament_id
    if tournament_data.cost_info[1006] then
      cost_u = tournament_data.cost_info[1006]
      cost_t = math.ceil(cost_u / 10)
    else
      cost_t = tournament_data.cost_info[1702018]
      cost_u = cost_t * 10
    end
    local txtData = LocUtil.GetLocalizeResStr(7674)
    local content_txt = txtData
    local cfg = CDataTable.GetTableData("Item", 1702018)
    local item_name = ""
    if cfg then
      item_name = cfg.ItemName
    end
    local content = LocUtil.LocalizeResFormatByStr(content_txt, cost_u, "UC", cost_t, item_name)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, content, function()
      if TeamUpNewSystem.nInviterRoomID and TeamUpNewSystem.nInviterRoomID == room_id then
        local TournamentHandler = require("client.network.Protocol.TournamentHandler")
        tournamentsManager.joinRoomData = {
          room_id = room_id,
          tournament_id = tournament_data.tournament_id,
          password = "",
          join_type = "invite"
        }
        TournamentHandler.send_tournament_free_room_join_req(room_id, tournament_data.tournament_id, "", "invite")
      elseif have_password then
        UIManager.ShowUI(UIManager.UI_Config.room_list_password_popup, room_id)
      else
        local RoomListSystem = require("client.slua.logic.room.logic_room_list")
        RoomListSystem.EnterRoom(room_id, "")
      end
      TeamUpNewSystem.nInviterRoomID = 0
    end)
  elseif room_type == "allstar" then
    if DataMgr.anchor == 1 then
      local AllStarHandler = require("client.network.Protocol.AllStarHandler")
      AllStarHandler.send_enter_allstar_room_ob_req(room_id, room_type)
    end
  elseif room_type and room_type == "asian_games" then
    if have_password then
      UIManager.ShowUI(UIManager.UI_Config.room_list_password_popup, room_id, room_type)
    else
      local RoomListSystem = require("client.slua.logic.room.logic_room_list")
      RoomListSystem.EnterRoom(room_id, "", room_type)
    end
  else
    if TeamUpNewSystem.nInviterRoomID and TeamUpNewSystem.nInviterRoomID == room_id then
      TeamUpNewSystem.room_invite_reply(NetErrorCode_NONE, TeamUpNewSystem.nInviterRoomID, TeamUpNewSystem.nInviter)
    elseif have_password then
      UIManager.ShowUI(UIManager.UI_Config.room_list_password_popup, room_id)
    else
      local RoomListSystem = require("client.slua.logic.room.logic_room_list")
      RoomListSystem.EnterRoom(room_id, "")
    end
    TeamUpNewSystem.nInviterRoomID = 0
  end
end
function RoomHandler.send_change_room_adv_param_req(battle_custom_cfg)
  NetManager.SendPkg(1916922963, battle_custom_cfg)
end
function RoomHandler.on_change_room_adv_param_rsp(err, battle_custom_cfg)
  if err ~= 0 then
    log(bWriteLog and "on_change_room_adv_param_rsp, res:" .. err)
    HandleErrorCode(err)
    return
  end
  if RoomSystem and RoomSystem.CurrentRoomInfo then
    RoomSystem.CurrentRoomInfo.  end
  UIManager.CloseUI(UIManager.UI_Config.room_option)
end
function RoomHandler.send_query_room_list(num1, num2, zoom_zone_id, view_str)
  NetManager.SendPkg(1160666701, num1, num2, zoom_zone_id, view_str)
end
function RoomHandler.on_sync_room_list(view, pos, total)
  local LogicUGCRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCRoom)
  if LogicUGCRoom:IsQueryRoomList() then
    LogicUGCRoom:OnSyncRoomList(view, pos, total)
    return
  end
  local RoomListSystem = require("client.slua.logic.room.logic_room_list")
  RoomListSystem.OnSyncRoomList(view, pos, total)
end
function RoomHandler.send_join_room_request(_roomID, _passWd, join_type, third_party_info)
  RoomSystem.RecordJoinRoomParams = {
    _roomID = _roomID,
    _passWd = _passWd,
    join_type = join_type,
      }
  NetManager.SendPkg(652119782, _roomID, _passWd, join_type, third_party_info)
end
function RoomHandler.on_join_room_respond(res, param1, param2)
  RoomSystem.on_join_room_respond(res, param1, param2)
end
function RoomHandler.on_sync_room_member(id, info, carteamInfo, zone_id, reason)
  RoomSystem.on_sync_room_member(id, info, carteamInfo, zone_id, reason)
end
function RoomHandler.on_sync_room_state(state)
  RoomSystem.on_sync_room_state(state)
end
function RoomHandler.on_room_disband(room_id, reason, zone_id)
  RoomSystem.on_room_disband(room_id, reason, zone_id)
end
function RoomHandler.send_change_room_pos_request(room_id, new_pos)
  NetManager.SendPkg(1394003236, room_id, new_pos)
end
function RoomHandler.on_change_room_pos_respond(res, new_pos)
  if res ~= 0 then
    if res == 210060 then
      ShowNotice(468890057)
    end
    if res == 49479 then
      ShowNotice(468890059)
    end
    log(bWriteLog and "RoomHandler.on_change_room_pos_respond res is not zero ,res = " .. tostring(res))
    return
  end
  RoomSystem.on_change_room_pos_respond(res, new_pos)
end
function RoomHandler.send_room_kick_request(room_id, kick_id)
  NetManager.SendPkg(415675542, room_id, kick_id)
end
function RoomHandler.on_room_kick_respond(res, kick_id)
  RoomSystem.on_room_kick_respond(res, kick_id)
end
function RoomHandler.on_notify_enter_game(ip, port, key)
  log(bWriteLog and "notify_enter_game " .. ip .. ":" .. port .. ",key=" .. key)
end
function RoomHandler.send_start_game_request()
  NetManager.SendPkg(816763214)
end
function RoomHandler.on_start_game_respond(res)
  RoomSystem.on_start_game_respond(res)
end
function RoomHandler.on_enter_game(ip, port, key, packet_key, game_id, sub_mode_id, ad_conf, dynamic_disabled_levels, eigeninfo, land_id, waterType, socialland_info, svr_pub_key, svr_packet_key_md5, waterUserID, ext_info, mode_type, antsvoice_url, team_antsvoice_url, custom_room_id, manor_data, ext_params, grome_info, collect_hall_info)
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  logic_enter_game:on_enter_game(ip, port, key, packet_key, game_id, sub_mode_id, ad_conf, dynamic_disabled_levels, eigeninfo, land_id, waterType, socialland_info, svr_pub_key, svr_packet_key_md5, waterUserID, ext_info, mode_type, antsvoice_url, team_antsvoice_url, custom_room_id, manor_data, ext_params, grome_info, collect_hall_info)
end
function RoomHandler.on_change_room_name_respond(res, room_id, name)
  RoomSystem.on_change_room_name_request(res, room_id, name)
end
function RoomHandler.send_change_room_group_type_request(room_id, map_id)
  NetManager.SendPkg(368230222, room_id, map_id)
end
function RoomHandler.on_change_room_group_type_respond(res, room_id, group_type)
  RoomSystem.on_change_room_group_type_respond(res, room_id, group_type)
end
function RoomHandler.send_change_room_map_request(room_id, map_id)
  NetManager.SendPkg(72854980, room_id, map_id)
end
function RoomHandler.on_change_room_map_respond(res, room_id, map_id)
  RoomSystem.on_change_room_map_respond(res, room_id, map_id)
end
function RoomHandler.send_query_room_request(room_id)
  NetManager.SendPkg(589459310, room_id)
end
function RoomHandler.on_query_room_respond(res, room_id, room)
  if HandleErrorCode(res) then
    return
  end
  EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_GET_ROOMINFO, room_id, room)
end
function RoomHandler.on_room_start_game_notify(res, antsvoice_url)
  RoomSystem.on_room_start_game_notify(res, antsvoice_url)
end
function RoomHandler.send_lock_room_pos_request(lock_pos)
  NetManager.SendPkg(2088098978, lock_pos)
end
function RoomHandler.on_lock_room_pos_respond(res, lock_pos)
  RoomSystem.on_lock_room_pos_respond(res, lock_pos)
end
function RoomHandler.send_unlock_room_pos_request(unlock_pos)
  NetManager.SendPkg(2012026112, unlock_pos)
end
function RoomHandler.on_unlock_room_pos_respond(res, unlock_pos)
  RoomSystem.on_unlock_room_pos_respond(res, unlock_pos)
end
function RoomHandler.on_sync_room_lock(islock, pos)
  RoomSystem.on_sync_room_lock(islock, pos)
end
function RoomHandler.send_get_room_battle_watch_info_req()
  NetManager.SendPkg(1780292359)
end
function RoomHandler.on_get_room_battle_watch_info_rsp(room_ob_info)
  RoomSystem.get_room_battle_watch_info_rsp(room_ob_info)
end
function RoomHandler.send_enter_league_ob_req(room_id)
  NetManager.SendPkg(1034902063, room_id)
end
function RoomHandler.send_enter_league_room_req(zoneId, modeId)
  NetManager.SendPkg(772152587, zoneId, modeId)
end
function RoomHandler.on_enter_league_room_rsp(res, ss, room, members, carteamInfo)
end
function RoomHandler.send_room_invite_request(userid)
  NetManager.SendPkg(1659625980, userid)
end
function RoomHandler.on_room_invite_respond(res, invitee, extend_info)
  RoomSystem.on_room_invite_respond(res, invitee, extend_info)
end
function RoomHandler.on_room_invite_reply_notify(res, invitee, extend_info)
  RoomSystem.on_room_invite_reply_notify(res, invitee, extend_info)
end
function RoomHandler.send_change_room_request(name, map_id, password, group_type, allow_invite, battle_cfg, isfpp, use_pc_param)
  NetManager.SendPkg(446225790, name, map_id, password, group_type, allow_invite, battle_cfg, isfpp, use_pc_param)
end
function RoomHandler.on_change_room_respond(res)
  RoomSystem.on_change_room_respond(res)
end
function RoomHandler.on_sync_room_change(room_id, room)
  RoomSystem.on_sync_room_change(room_id, room)
end
function RoomHandler.send_exit_room(room_id)
  NetManager.SendPkg(2037010220, room_id)
end
function RoomHandler.on_exit_room_rsp()
  RoomSystem.on_exit_room_rsp()
end
function RoomHandler.send_kickout_simulator_user_req()
  NetManager.SendPkg(583810535)
end
function RoomHandler.on_kickout_simulator_user_rsp(res, kick_count)
  RoomSystem.on_kickout_simulator_user_rsp(res, kick_count)
end
function RoomHandler.on_kickout_simulator_user_notify(kickIds)
  RoomSystem.on_kickout_simulator_user_notify(kickIds)
end
function RoomHandler.on_room_next_match_ready_notify(roomId)
  RoomSystem.on_room_next_match_ready_notify(roomId)
end
function RoomHandler.send_leave_room_battle_watch()
  NetManager.SendPkg(1488575984)
end
function RoomHandler.send_enter_next_match(room_id)
  NetManager.SendPkg(1414309922, room_id)
end
function RoomHandler.send_room_recruit_req()
  NetManager.SendPkg(1269746343)
end
function RoomHandler.send_match_room_kick_req(uids)
  NetManager.SendPkg(318890035, uids)
end
function RoomHandler.on_match_room_kick_rsp(err)
  RoomSystem.on_match_room_kick_rsp(err)
end
function RoomHandler.on_team_match_shadow_notify(idc_flag)
  log(bWriteLog and "[YY]on_team_match_shadow_notify====" .. tostring(idc_flag))
  RoomSystem.SetIdcFlag(idc_flag)
end
function RoomHandler.send_set_room_prepared_req(tmode_use_owner_solution)
  NetManager.SendPkg(1891397099, tmode_use_owner_solution)
end
function RoomHandler.on_set_room_prepared_rsp(res, room_id, unprepared_num)
  _ShowErrorTips(res)
  if unprepared_num then
    RoomSystem.on_set_room_prepared_rsp(unprepared_num)
  end
end
function RoomHandler.send_cancel_room_prepared_req()
  NetManager.SendPkg(1642609127)
end
function RoomHandler.on_cancel_room_prepared_rsp(res, room_id)
  _ShowErrorTips(res)
end
function RoomHandler.send_set_member_prepared_req()
  NetManager.SendPkg(554906831)
end
function RoomHandler.on_set_member_prepared_rsp(err_code, uid, room_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  RoomSystem.on_set_member_prepared_rsp()
end
function RoomHandler.send_set_room_prepared_second_confirm_req(opt_type)
  NetManager.SendPkg(789852135, opt_type)
end
function RoomHandler.on_set_room_prepared_second_confirm_rsp(res, uid, room_id, opt_type)
  if res ~= 0 then
    ShowNotice(res)
    return true
  end
end
function RoomHandler.on_notify_room_member(owner_uid, room_id, notified_uid, notify_content)
  log(bWriteLog and "RoomHandler.on_notify_room_member")
  if notify_content == "remind_ready" and tonumber(DataMgr.roleData.uid) ~= owner_uid then
    ShowNotice(67798)
  end
end
function RoomHandler.on_get_game_info_rsp(game_info)
  log(bWriteLog and "RoomHandler.on_get_game_info_rsp")
  log_tree(bWriteLog and "RoomHandler.on_get_game_info_rsp game_info = ", game_info)
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  logic_enter_game:on_get_game_info_rsp(game_info)
end
function RoomHandler.on_notify_team_member_enter_hvh_room(room_id, room_info)
  log(bWriteLog and "RoomHandler.on_notify_team_member_enter_hvh_room: auto join room notify")
  log_tree("RoomHandler.on_notify_team_member_enter_hvh_room room_info", room_info)
  if room_info and type(room_info) == "table" then
    local roomId = room_id
    local password = room_info.password or ""
    local roomType = room_info.room_type
    if roomId then
      log_format("RoomHandler.on_notify_team_member_enter_hvh_room: auto join room - roomId:%s password:%s roomType:%s", tostring(roomId), tostring(password), tostring(roomType))
      if password == "" then
        RoomHandler.send_join_room_request(tonumber(roomId), nil, roomType, nil)
      else
        RoomHandler.send_join_room_request(tonumber(roomId), tostring(password), roomType, nil)
      end
      log_format("RoomHandler.on_notify_team_member_enter_hvh_room: sent join room request - roomId:%s", tostring(roomId))
    else
      log_error_format("RoomHandler.on_notify_team_member_enter_hvh_room: missing room_id in room_info")
    end
  else
    log_error_format("RoomHandler.on_notify_team_member_enter_hvh_room: invalid room_info type:%s", type(room_info))
  end
end
function RoomHandler.send_lock_team_request(team_id)
  NetManager.SendPkg(437761628, team_id)
end
function RoomHandler.on_lock_team_respond(res, team_list)
  if res ~= 0 then
    log(bWriteLog and "RoomHandler.on_lock_team_respond res is " .. tostring(res))
    return
  end
  RoomSystem.on_lock_team_respond(team_list)
end
function RoomHandler.send_unlock_team_request(team_id)
  NetManager.SendPkg(218606950, team_id)
end
function RoomHandler.on_unlock_team_respond(res, team_list)
  if res ~= 0 then
    log(bWriteLog and "RoomHandler.on_unlock_team_respond res is " .. tostring(res))
    return
  end
  RoomSystem.on_unlock_team_respond(team_list)
end
function RoomHandler.send_change_other_pos_request(room_id, new_pos, op_uid)
  NetManager.SendPkg(1092946030, room_id, new_pos, op_uid)
end
function RoomHandler.on_change_other_pos_respond(res, new_pos, op_uid)
  if res ~= 0 then
    log(bWriteLog and "RoomHandler.on_change_other_pos_respond res is " .. tostring(res))
    if res == 210060 then
      ShowNotice(468890057)
    end
    if res == 49479 then
      ShowNotice(468890059)
    end
    if res == 210018 then
      ShowNotice(468890061)
    end
    return
  end
  RoomSystem.on_change_other_pos_respond(new_pos, op_uid)
end
function RoomHandler.send_set_pos_arranging_request()
  NetManager.SendPkg(1216104536)
end
function RoomHandler.on_set_pos_arranging_respond(res)
  if res ~= 0 then
    log(bWriteLog and "RoomHandler.on_set_pos_arranging_respond res is " .. tostring(res))
    if res == 49479 then
      ShowNotice(468890059)
    end
    return
  end
  RoomSystem.on_set_pos_arranging_respond()
end
function RoomHandler.send_cancel_pos_arranging_request()
  NetManager.SendPkg(882583534)
end
function RoomHandler.on_cancel_pos_arranging_respond(res)
  if res ~= 0 then
    log(bWriteLog and "RoomHandler.on_cancel_pos_arranging_respond res is " .. tostring(res))
    return
  end
  RoomSystem.on_cancel_pos_arranging_respond()
end
function RoomHandler.send_ugc_room_member_reject_download(room_id)
  log(bWriteLog and "RoomHandler.send_ugc_room_member_reject_download room_id = " .. tostring(room_id))
  NetManager.SendPkg(455191030, room_id)
end
function RoomHandler.on_ugc_room_member_reject_download_rsp(err_code)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log(bWriteLog and "RoomHandler.on_ugc_room_member_reject_download_rsp")
end
function RoomHandler.on_ugc_room_member_reject_download_notify(member_uid, room_id)
  log(bWriteLog and "RoomHandler.on_ugc_room_member_reject_download_notify member_uid = " .. tostring(member_uid) .. " room_id = " .. tostring(room_id))
  RoomSystem.RoomMemberRejectDownloadNotify(member_uid, room_id)
end
local reqRsp = {
  send_set_member_prepared_req = "on_set_member_prepared_rsp",
  send_set_room_prepared_second_confirm_req = "on_set_room_prepared_second_confirm_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, RoomHandler)
return RoomHandler