local NetManager = require("client.network.comm.NetManager")
local TeamupHandler = {}
function TeamupHandler.ShowErrorTips(res)
  if res ~= 0 then
    local errorID = tonumber(res)
    if errorID ~= nil and 0 < errorID then
      local noticeStr = LocUtil.GetLocalizeResStr(res)
      if noticeStr ~= "" then
        ShowNotice(noticeStr)
      else
        ShowNotice(9990004)
      end
    end
  end
end
function TeamupHandler.IsInNormalBattle()
  return GameStatus.IsInFightingNotSocialNotMainCityNotHome()
end
function TeamupHandler.send_get_horse_lamp()
  NetManager.SendPkg(488320684)
end
function TeamupHandler.on_get_horse_lamp_rsp(msg, info)
end
function TeamupHandler.send_get_label_status()
  NetManager.SendPkg(1806151948)
end
function TeamupHandler.on_get_label_status_rsp(res, tb)
end
function TeamupHandler.send_on_select_zone_req(match_zone)
  NetManager.SendPkg(377808392, match_zone)
end
function TeamupHandler.on_on_select_zone_res(ret, match_zone, next_select_time, shadow_region)
  if TeamupHandler.IsInNormalBattle() then
    return
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  ZoneSystem.on_select_zone_res(ret, match_zone, next_select_time, shadow_region)
end
function TeamupHandler.send_query_match_zone_list()
  NetManager.SendPkg(920340237)
end
function TeamupHandler.on_sync_match_zone_list(tpingsvr_tab, shadow_pingsvr_list, shadow_pingsvr_param, shadow_ping_wartermark_map, should_recheck_allzone, thread_epoll_module_params)
  if TeamupHandler.IsInNormalBattle() then
    return
  end
  log_tree("[DeanJYT] TeamupHandler.on_sync_match_zone_list tpingsvr_tab = ", tpingsvr_tab)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  ZoneSystem.sync_match_zone_list_rsp(tpingsvr_tab)
  local ShadowZoneSystem = require("client.slua.logic.teamup.logic_shadow_zone")
  ShadowZoneSystem.SyncShadowServer(shadow_pingsvr_list, shadow_pingsvr_param, shadow_ping_wartermark_map, should_recheck_allzone, thread_epoll_module_params)
  local logic_ai_take_over = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ai_take_over)
  logic_ai_take_over:ReportTLog(0)
end
function TeamupHandler.send_team_info_request()
  NetManager.SendPkg(1584545158)
end
function TeamupHandler.on_team_info_sync(teamid, teaminfo)
  log(bWriteLog and "TeamupHandler.on_team_info_sync teamid = " .. tostring(teamid))
  if not Client.IsShipping() and teaminfo and teaminfo.members and teaminfo.members[tonumber(DataMgr.roleData.uid)] then
    local logic_team_up_test = require("client.slua.logic.teamup.logic_team_up_test")
    local bGMCall = logic_team_up_test.bGMCall
    logic_team_up_test.SetTemplateMemberInfo(teaminfo.members[tonumber(DataMgr.roleData.uid)])
    if bGMCall then
      return
    end
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_team_info_sync(teamid, teaminfo)
  if teamid ~= 0 then
    local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
    XMissionSystem.EnterXMissionByInvite(teaminfo)
  end
end
function TeamupHandler.send_team_report_voice_info(voiceuid, voiceOpen, speakerOpen)
  NetManager.SendPkg(613117908, voiceuid, voiceOpen, speakerOpen)
end
function TeamupHandler.send_update_client_map_info(param)
  NetManager.SendPkg(690542060, param)
end
function TeamupHandler.on_update_client_map_info_rsp(res)
  log(bWriteLog and "[edward][TeamupHandler] TeamupHandler.on_update_client_map_info_rsp, res = " .. tostring(res))
  if res == NetErrorCode_NONE then
  else
  end
end
function TeamupHandler.send_one_more_battle_apply_req(battle_id)
  NetManager.SendPkg(1416320443, battle_id)
end
function TeamupHandler.on_one_more_battle_apply_rsp(res, battle_id)
  log(bWriteLog and "TeamupHandler.on_one_more_battle_apply_rsp res = " .. tostring(res))
  if res == 0 then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    TeamUpNewSystem.one_more_battle_apply_rsp()
  else
    TeamupHandler.ShowErrorTips(res)
  end
end
function TeamupHandler.send_one_more_battle_reply_req(team_id, opt, team_leader_id)
  NetManager.SendPkg(1152783123, team_id, opt, team_leader_id)
end
function TeamupHandler.on_one_more_battle_reply_rsp(res)
  log(bWriteLog and "TeamupHandler.on_one_more_battle_reply_rsp res = " .. tostring(res))
  TeamupHandler.ShowErrorTips(res)
end
function TeamupHandler.on_one_more_battle_info_notify(team_id, msg_type, msg)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.one_more_battle_info_notify(team_id, msg_type, msg)
end
function TeamupHandler.send_end_one_more_battle_req(team_id)
  NetManager.SendPkg(1529784815, team_id)
end
function TeamupHandler.on_end_one_more_battle_rsp(res, team_id)
  log(bWriteLog and "TeamupHandler.on_end_one_more_battle_rsp res = " .. tostring(res))
  if res == 0 then
    UIManager.CloseUI(UIManager.UI_Config.one_more_team_tip)
  else
    TeamupHandler.ShowErrorTips(res)
  end
end
function TeamupHandler.send_team_change_type_request(matchID, viewIDs)
  NetManager.SendPkg(1204342161, matchID, viewIDs)
end
function TeamupHandler.on_team_change_type_respond(res)
  if TeamupHandler.IsInNormalBattle() then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_change_type_rsp(res)
end
function TeamupHandler.send_team_invite_request(uid, inviteInfo)
  log(bWriteLog and "TeamupHandler.send_team_invite_request uid = " .. uid)
  log_tree("inviteInfo = ", inviteInfo)
  NetManager.SendPkg(576799152, uid, inviteInfo)
end
function TeamupHandler.on_team_invite_respond(state, invitee, verCompareResult, fcmLimit, op_name, text_id)
  log(bWriteLog and "TeamupHandler.on_team_invite_respond state = " .. state .. ", invitee = " .. invitee .. ", verCompareResult = " .. tostring(verCompareResult) .. ", fcmLimit = " .. tostring(fcmLimit) .. ", op_name = " .. tostring(op_name) .. ", text_id = " .. tostring(text_id))
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  local ShootingTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
  if TeamupHandler.IsInNormalBattle() and not PlanPH_GamePlay_Tools.IsPHomeMode() and not ShootingTrainTool.IsSelfInTraining() then
    local logic_creative_wow_friend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_creative_wow_friend)
    if not logic_creative_wow_friend or not logic_creative_wow_friend:IsIn() then
      log(bWriteLog and "TeamupHandler.on_team_invite_respond in fight")
      return
    end
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_team_invite_respond(state, invitee, verCompareResult, fcmLimit, op_name, text_id)
end
function TeamupHandler.send_team_invite_reply(ispermit, userid, teamid, src, from_type, version, tournament_id, text_id, extendinfo)
  if ispermit == NetErrorCode_NONE and GameStatus.IsInMainCity() then
    extendinfo = extendinfo or {}
    extendinfo.sceneType = "MainCity"
  end
  NetManager.SendPkg(433317190, ispermit, userid, teamid, src, from_type, version, tournament_id, text_id, extendinfo)
end
function TeamupHandler.send_team_apply_reply(ispermit, userid, teamid, src, from_type, join_signatur, applyer_name, text_id)
  NetManager.SendPkg(755986875, ispermit, userid, teamid, src, from_type, join_signatur, applyer_name, text_id)
end
function TeamupHandler.send_room_invite_reply(ispermit, room_id, inviter, src, extend_info)
  NetManager.SendPkg(1957946560, ispermit, room_id, inviter, src, extend_info)
end
function TeamupHandler.send_team_apply_request(uid, applyInfo)
  NetManager.SendPkg(1863046274, uid, applyInfo)
end
function TeamupHandler.send_team_quit_request(teamid, reason)
  NetManager.SendPkg(889351184, teamid, reason)
end
function TeamupHandler.on_team_quit_respond(state, zone_id, reason)
  if TeamupHandler.IsInNormalBattle() then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_team_quit_respond(state, zone_id, reason)
end
function TeamupHandler.send_team_kick_request(uid, from)
  NetManager.SendPkg(1931582242, uid, from)
end
function TeamupHandler.on_team_kick_respond(res, targetUID, from)
  if TeamupHandler.IsInNormalBattle() then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_team_kick_respond(res, targetUID)
end
function TeamupHandler.send_team_change_fill_request(fill)
  NetManager.SendPkg(1313535034, fill)
end
function TeamupHandler.send_team_change_leader_request(new_leader)
  NetManager.SendPkg(679522670, new_leader)
end
function TeamupHandler.on_team_change_leader_respond(new_leader, res)
  if TeamupHandler.IsInNormalBattle() then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_change_leader_rsp(res)
end
function TeamupHandler.send_team_change_member_status_request(reqStatus, device_info)
  NetManager.SendPkg(972847490, reqStatus, device_info)
end
function TeamupHandler.on_team_change_member_status_rsp(err_code, tournament_id)
  LobbySystem.change_status_rsp(err_code, tournament_id)
end
function TeamupHandler.send_team_recruit_for_plat_req()
  NetManager.SendPkg(115132066)
end
function TeamupHandler.on_team_recruit_for_plat_res(res, team_id, battle_id)
  if TeamupHandler.IsInNormalBattle() then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_plat_get_teamid_rsp(res, team_id, battle_id)
end
function TeamupHandler.send_team_player_action(action_id, sound_id, op_type, extraParam)
  log(bWriteLog and "TeamupHandler.send_team_player_action action_id = " .. action_id)
  NetManager.SendPkg(1121261184, action_id, sound_id, op_type, extraParam)
end
function TeamupHandler.on_sync_player_action(player_uid, action_id, randSoundId, follow_id, op_type, extraParam)
  log(bWriteLog and string.format("TeamupHandler.on_sync_player_action player_uid:%s, action_id:%s, randSoundId:%s, follow_id:%s, op_type:%s", player_uid, tostring(action_id), tostring(randSoundId), tostring(follow_id), tostring(op_type)))
  if TeamupHandler.IsInNormalBattle() then
    return
  end
  if op_type and op_type == 1 then
    local LobbyThemeInteractiveManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeInteractiveManager)
    LobbyThemeInteractiveManager:StartInteractive()
    return
  end
  follow_id = follow_id and tostring(follow_id)
  local playActionFunc = function()
    log(bWriteLog and "TeamupHandler.on_sync_player_action playActionFunc")
    local bDelay = false
    local timer_tick = require("common.time_ticker")
    local main_city_performance_config = require("GameLua.Mod.MainCity.Client.logic.Performance.main_city_performance_config")
    local logic_lobby_performance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_performance)
    if logic_lobby_performance.switchData:GetSwitchVal() == false then
      logic_lobby_performance:SetLobbyModelTick(main_city_performance_config.SwitchDataType.SyncPlayerAction, true)
      timer_tick.AddTimer(10, function()
        logic_lobby_performance:SetLobbyModelTick(main_city_performance_config.SwitchDataType.SyncPlayerAction, false)
      end)
      bDelay = true
    end
    local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
    if XMissionSystem.IsInXMission() then
      local XMissionTeamUpSystem = require("client.slua.logic.TxMission.logic_xmission_team")
      XMissionTeamUpSystem.sync_player_action(player_uid, action_id, randSoundId, follow_id, extraParam)
    elseif bDelay then
      timer_tick.AddTimer(1, function()
        local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
        TeamUpNewSystem.sync_player_action(player_uid, action_id, randSoundId, follow_id, extraParam)
      end)
    else
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      TeamUpNewSystem.sync_player_action(player_uid, action_id, randSoundId, follow_id, extraParam)
    end
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {action_id})
  end
  local ShowBrandConst = require("client.slua.logic.showbrand.ShowBrandConst")
  if action_id == ShowBrandConst.EditEmoteId or action_id == ShowBrandConst.GeneralEmoteId then
    local ShowBrandUtils = require("client.slua.logic.showbrand.ShowBrandUtils")
    ShowBrandUtils.PrepareEmoteData(tonumber(player_uid), function()
      log(bWriteLog and "ShowBrandUtils.PrepareEmoteData callback")
      playActionFunc()
    end, nil, true)
    return
  end
  playActionFunc()
end
function TeamupHandler.send_team_recruit(list, msgid)
  NetManager.SendPkg(745491788, list, msgid)
end
function TeamupHandler.on_team_recruit_rsp(ret, time_left, team_id, msg_id, res_channel)
  if TeamupHandler.IsInNormalBattle() then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.team_recruit_rsp(ret, time_left, team_id, msg_id, res_channel)
end
function TeamupHandler.send_team_kick_no_map_req()
  NetManager.SendPkg(812635815)
end
function TeamupHandler.on_team_kick_no_map_rsp(res)
  LobbySystem.team_kick_no_map_rsp(res)
end
function TeamupHandler.on_team_invite_notify(inviter, teamId, team_type, inviteInfo, sub_mode_view_ids)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_team_invite_notify(inviter, teamId, team_type, inviteInfo, sub_mode_view_ids)
end
function TeamupHandler.on_team_join_respond(res, teamid, teamInfo, verCompareResult)
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if TeamupHandler.IsInNormalBattle() and not PlanPH_GamePlay_Tools.IsPHomeMode() then
    log(bWriteLog and "TeamupHandler.on_team_join_respond in fight")
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_team_join_rsp(res, teamid, teamInfo, verCompareResult)
end
function TeamupHandler.on_team_apply_respond(state, verCompareResult, op_name, text_id)
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if TeamupHandler.IsInNormalBattle() and not PlanPH_GamePlay_Tools.IsPHomeMode() then
    log(bWriteLog and "TeamupHandler.on_team_apply_respond in fight")
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_team_apply_respond(state, verCompareResult, op_name, text_id)
end
function TeamupHandler.on_team_info_notify(teamid, operate_type, param, param1, param2)
  log(bWriteLog and "TeamupHandler.on_team_info_notify teamid = " .. teamid .. ", operate_type = " .. tostring(operate_type))
  log_tree("param = ", param)
  log_tree("param1 = ", param1)
  log_tree("param2 = ", param2)
  if TeamupHandler.IsInNormalBattle() then
    SingleTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
    if not SingleTrainTool.IsSelfInTraining() then
      log(bWriteLog and "TeamupHandler.on_team_info_notify return normal battle")
      return
    else
      log(bWriteLog and "TeamupHandler.on_team_info_notify in single training")
    end
  end
  if operate_type and 110 <= operate_type and operate_type <= 116 then
    local XMissionTeamUpSystem = require("client.slua.logic.TxMission.logic_xmission_team")
    XMissionTeamUpSystem.OnTeamInfoChangeNotify(teamid, operate_type, param, param1, param2)
  else
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    TeamUpNewSystem.on_team_info_change_notify(teamid, operate_type, param, param1, param2)
  end
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_NOTIFY)
end
function TeamupHandler.on_team_apply_notify(applyerID, applyerName, teamid, applyInfo)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_team_apply_notify(applyerID, applyerName, teamid, applyInfo)
end
function TeamupHandler.on_team_change_wear(memberUid, isPushOn, mResId, mAvatarPos, wearInfo, gold_dress_set_info, gold_dress_set_info_all)
  if TeamupHandler.IsInNormalBattle() then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_team_change_wear(memberUid, isPushOn, mResId, mAvatarPos, wearInfo, gold_dress_set_info, gold_dress_set_info_all)
end
function TeamupHandler.on_team_update_wear(op_uid, wear_res, wear_ext_res, knapsack_ext_inf, gold_dress_set_info, gold_dress_set_info_all)
  if TeamupHandler.IsInNormalBattle() then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_team_update_wear(op_uid, wear_res, wear_ext_res, knapsack_ext_inf, gold_dress_set_info, gold_dress_set_info_all)
end
function TeamupHandler.on_team_change_avatar(op_uid, newAvatar)
  if TeamupHandler.IsInNormalBattle() then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_team_change_avatar(op_uid, newAvatar)
end
function TeamupHandler.send_user_finish_download_map(param)
  NetManager.SendPkg(1348199884, param)
end
function TeamupHandler.on_user_finish_download_map_rsp(res)
  log(bWriteLog and "[edward][TeamupHandler] TeamupHandler.on_user_finish_download_map_rsp, res = " .. tostring(res))
  if res == NetErrorCode_NONE then
  else
  end
end
function TeamupHandler.on_team_match_zone_notify(match_zone)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_team_match_zone_notify(match_zone)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  ZoneSystem.on_team_match_zone_notify(match_zone)
end
function TeamupHandler.on_room_invite_notify(inviter, room_id, mode, zone_id, room_type, map_id, mod_id)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_room_invite_notify(inviter, room_id, mode, zone_id, nil, nil, room_type, map_id, mod_id)
end
function TeamupHandler.send_team_code_create_req()
  NetManager.SendPkg(1105679368)
end
function TeamupHandler.on_team_code_create_res(state, code)
  local FaceTeamSystem = require("client.slua.logic.faceteam.logic_faceteam")
  FaceTeamSystem.team_code_create_res(state, code)
end
function TeamupHandler.send_team_code_join_req(code)
  NetManager.SendPkg(514902248, code)
end
function TeamupHandler.on_team_code_join_res(state)
  local FaceTeamSystem = require("client.slua.logic.faceteam.logic_faceteam")
  FaceTeamSystem.team_code_join_res(state)
end
function TeamupHandler.send_team_code_delete_req(code)
  NetManager.SendPkg(1823664264, code)
end
function TeamupHandler.on_team_code_delete_res(state, code)
  local FaceTeamSystem = require("client.slua.logic.faceteam.logic_faceteam")
  FaceTeamSystem.team_code_delete_res(state, code)
end
function TeamupHandler.on_team_code_notify(code)
  local FaceTeamSystem = require("client.slua.logic.faceteam.logic_faceteam")
  FaceTeamSystem.team_code_notify(code)
end
function TeamupHandler.on_notify_invite_reply_accept(err, UID)
  if err == 0 then
    log(bWriteLog and "[TeamUpHandler] invite accepted " .. tostring(UID))
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENT_ONE_TEAM_INVITE_ACCEPTED, UID)
  end
end
function TeamupHandler.on_sync_ping_factors(ping_factor_a, ping_factor_k0, ping_factor_k, shadow_ping_switch, extra_ping_info, range_info)
  log(bWriteLog and "[DeanJYT]  on_sync_ping_factors: a = " .. tostring(ping_factor_a) .. ", k0 = " .. tostring(ping_factor_k0) .. ", k = " .. tostring(ping_factor_k) .. ", switch = " .. tostring(shadow_ping_switch))
  local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
  logic_zone_delay.InitPingAdjustParam(ping_factor_a, ping_factor_k0, ping_factor_k, shadow_ping_switch, range_info)
  log_tree("extra_ping_info", extra_ping_info)
  local zoneSystem = require("client.slua.logic.teamup.logic_zone")
  zoneSystem.InitExtraPingInfo(extra_ping_info)
end
function TeamupHandler.send_join_anchor_team_req(anchor_uid, apply_info)
  NetManager.SendPkg(1076286664, anchor_uid, apply_info)
end
function TeamupHandler.on_join_anchor_team_res(err, ver_ret)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_join_anchor_team_res(err, ver_ret)
end
function TeamupHandler.send_modify_anchor_subscription_req(value)
  NetManager.SendPkg(1959957416, value)
end
function TeamupHandler.on_modify_anchor_subscription_res(value)
end
function TeamupHandler.send_get_pre_team_limit_req(is_squard)
  NetManager.SendPkg(728437255, is_squard)
end
function TeamupHandler.on_get_pre_team_limit_rsp(min_seg_id, max_seg_id)
  log(bWriteLog and "on_get_pre_team_limi_rsp: min_seg_id = " .. tostring(min_seg_id) .. ", max_seg_id = " .. tostring(max_seg_id))
  local LogicTeamUpLimit = require("client.slua.logic.teamup.logic_team_up_limit")
  LogicTeamUpLimit.on_get_pre_team_limit_rsp(min_seg_id, max_seg_id)
end
function TeamupHandler.send_get_all_pre_team_limit_req()
  NetManager.SendPkg(1457760519)
end
function TeamupHandler.on_get_all_pre_team_limit_rsp(segment_tabs)
  log_tree(bWriteLog and "on_get_all_pre_team_limit_rsp:", segment_tabs)
  local LogicTeamUpLimit = require("client.slua.logic.teamup.logic_team_up_limit")
  LogicTeamUpLimit.on_get_all_pre_team_limit_rsp(segment_tabs)
end
function TeamupHandler.send_get_single_squad_pre_team_limit_req()
  NetManager.SendPkg(1228794275)
end
function TeamupHandler.on_get_single_squad_pre_team_limit_rsp(segment_tabs)
  log_tree(bWriteLog and "on_get_single_squad_pre_team_limit_rsp: ", segment_tabs)
  local LogicTeamUpLimit = require("client.slua.logic.teamup.logic_team_up_limit")
  LogicTeamUpLimit.on_get_single_squad_pre_team_limit_rsp(segment_tabs)
end
function TeamupHandler.on_team_change_type_notify(msg)
  log(bWriteLog and "on_team_change_type_notify msg = " .. tostring(msg))
  if msg == "pre_team_limit" then
    ShowNotice(27193)
  elseif msg == "peakgame_segment_limit" then
    ShowNotice(27193)
  end
end
function TeamupHandler.send_get_pre_team_limit_info_req()
  NetManager.SendPkg(964516143)
end
function TeamupHandler.on_get_pre_team_limit_info_rsp(team_segment_limit_info)
  log_tree(bWriteLog and "on_get_pre_team_limit_info_rsp: ", team_segment_limit_info)
  local LogicTeamUpLimit = require("client.slua.logic.teamup.logic_team_up_limit")
  LogicTeamUpLimit.on_get_pre_team_limit_info_rsp(team_segment_limit_info)
end
function TeamupHandler.send_set_receive_nonfriend_team_request(enable)
  NetManager.SendPkg(2038445622, enable)
end
function TeamupHandler.on_view_id_conflict_notify(err_code, fixed_match_id, fixed_view_ids, conflict_reason)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  logic_mode_selection:OnNotifyViewIdConflict(err_code, fixed_match_id, fixed_view_ids, conflict_reason)
end
function TeamupHandler.send_share_team_invite_link_req(player_uid)
  log(bWriteLog and "[DeanJYT] TeamupHandler.send_share_team_invite_link_req player_uid = " .. tostring(player_uid))
  NetManager.SendPkg(1617451143, player_uid)
end
function TeamupHandler.on_share_team_invite_link_rsp(err_code)
  log(bWriteLog and "[DeanJYT] TeamupHandler.on_share_team_invite_link_rsp err_code = " .. tostring(err_code))
  if err_code == 0 then
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_SHARE_TEAM_INVITE_LINK)
  elseif err_code == 100220028 then
    ShowNotice(33400)
  elseif err_code == 100220029 then
    ShowNotice(100500002)
  else
    ShowNotice(err_code)
  end
end
function TeamupHandler.on_team_apply_reply_res_notify(res, applyer_name)
  if bWriteLog then
    print(" >>>>> on_team_apply_reply_res_notify", res, applyer_name)
  end
  if not applyer_name or applyer_name == "" then
    return
  end
  if res == "already_has_team" then
    ShowNotice(LocUtil.LocalizeResFormat(39093, applyer_name))
  elseif res == "already_in_team" then
    ShowNotice(LocUtil.LocalizeResFormat(39093, applyer_name))
  elseif res == "already_in_match" then
    ShowNotice(LocUtil.LocalizeResFormat(39095, applyer_name))
  elseif res == "already_in_game" then
    ShowNotice(LocUtil.LocalizeResFormat(39095, applyer_name))
  elseif res == "already_in_room" then
    ShowNotice(LocUtil.LocalizeResFormat(39094, applyer_name))
  end
end
function TeamupHandler.on_team_invite_reply_res_notify(res, invitee_name)
  if bWriteLog then
    print(" >>>>> on_team_invite_reply_res_notify ", res, invitee_name)
  end
  if not invitee_name or invitee_name == "" then
    return
  end
  if res == "already_has_team" then
    ShowNotice(LocUtil.LocalizeResFormat(39093, invitee_name))
  elseif res == "already_in_team" then
    ShowNotice(LocUtil.LocalizeResFormat(39093, invitee_name))
  elseif res == "invitee_in_match" then
    ShowNotice(LocUtil.LocalizeResFormat(39095, invitee_name))
  end
end
function TeamupHandler.send_get_recommend_team_req(friend_uid_list, corps_uid_list)
  NetManager.SendPkg(324315751, friend_uid_list, corps_uid_list)
end
function TeamupHandler.on_get_recommend_team_rsp(team_uid, from, labels)
  local logic_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_recommend)
  logic_team_recommend:get_recommend_team_rsp(team_uid, from, labels)
end
function TeamupHandler.on_notify_recommend_team_info(last_recommend_team_time, day_cnt, week_cnt, last_recommend_nil_time)
  local logic_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_recommend)
  logic_team_recommend:on_notify_recommend_team_info(last_recommend_team_time, day_cnt, week_cnt, last_recommend_nil_time)
end
function TeamupHandler.on_sync_team_play_action_invite(action_id, invite_info)
  if IsWoWEditor then
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "TeamupHandler.on_sync_team_play_action_invite  not lobby")
    return
  end
  UIManager.CloseUI(UIManager.UI_Config.EmoteDanceInviteUI)
  UIManager.ShowUI(UIManager.UI_Config.EmoteDanceInviteUI, action_id, invite_info)
end
function TeamupHandler.send_together_dance_action_replay_req(answer, action_id, follow_uid)
  NetManager.SendPkg(946725927, answer, action_id, follow_uid)
end
function TeamupHandler.on_together_dance_action_replay_rsp(err_code)
end
function TeamupHandler.send_together_dance_action_req(action_id)
  NetManager.SendPkg(617885431, action_id)
end
function TeamupHandler.on_together_dance_action_rsp(err_code, action_id)
  log(bWriteLog and "TeamupHandler.on_together_dance_action_rsp " .. tostring(err_code))
end
function TeamupHandler.send_team_query_quick_msg_req()
  log(bWriteLog and "TeamupHandler.send_team_query_quick_msg_req")
  NetManager.SendPkg(797675047)
end
function TeamupHandler.on_team_query_quick_msg_rsp(id_list)
  log(bWriteLog and "TeamupHandler.on_team_query_quick_msg_rsp")
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_QUERY_QUICK_MSG_RSP, id_list)
end
function TeamupHandler.send_team_send_quick_msg_req(id)
  local ban_util = require("client.common.ban_util")
  local BanMacro = require("client.slua.config.ClientMacros.BanMacro")
  if ban_util.IsBanned(BanMacro.PLAYER_BAN_CHAT) then
    log(bWriteLog and "TeamupHandler.send_team_send_quick_msg_req is banned")
    return
  end
  NetManager.SendPkg(299146019, id)
end
function TeamupHandler:on_team_send_quick_msg_rsp(err_code, id)
  log(bWriteLog and string.format(" TeamupHandler:on_team_send_quick_msg_rsp err_code:%s, id:%s", err_code, id))
  if err_code == 17020001 then
    ShowNotice(err_code)
  elseif err_code == 17020002 then
    ShowNotice(err_code)
  end
end
function TeamupHandler.on_notify_pre_team_rating_gap_unreasonable(uid, gap_id)
  log(bWriteLog and "on_notify_pre_team_rating_gap_unreasonable")
  local logic_team_up_gap_unreasonable = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_up_gap_unreasonable)
  logic_team_up_gap_unreasonable:on_notify_pre_team_rating_gap_unreasonable(uid, gap_id)
end
function TeamupHandler.send_get_recommend_team_info()
  NetManager.SendPkg(1619087110)
end
function TeamupHandler.on_notify_teamup_sex_show(bShow)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.on_notify_teamup_sex_show(bShow)
end
function TeamupHandler.send_follow_leader_motion_setting_req(is_follow)
  NetManager.SendPkg(891211559, is_follow)
end
function TeamupHandler.on_follow_leader_motion_setting_rsp(err_code, is_follow)
  if err_code ~= 0 then
    log(bWriteLog and "on_follow_leader_motion_setting_rsp err_code" .. tostring(err_code))
    ShowNotice(err_code)
    return
  end
  log(bWriteLog and "on_follow_leader_motion_setting_rsp " .. tostring(is_follow))
  DataMgr.is_follow_leader = is_follow
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.UpdateEmoteFollowerState(tonumber(DataMgr.roleData.uid), is_follow)
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTIP_TEAMUP_FOLLOW_LEADER_EMOTE_UPDATE)
end
function TeamupHandler.on_sync_team_follow_leader_motion(member_uid, is_follow_leader)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.UpdateEmoteFollowerState(member_uid, is_follow_leader)
end
function TeamupHandler.on_update_match_zone_list(updated_shadow_pingsvr)
  log_tree("[DeanJYT] TeamupHandler.on_update_match_zone_list updated_shadow_pingsvr", updated_shadow_pingsvr)
  local ShadowZoneSystem = require("client.slua.logic.teamup.logic_shadow_zone")
  ShadowZoneSystem.UpdateShadowServer(updated_shadow_pingsvr)
end
function TeamupHandler.send_zone_select_ping_display_details_req(stat_infos, extraInfo)
  NetManager.SendPkg(102927911, stat_infos, extraInfo)
end
function TeamupHandler.on_zone_select_ping_display_details_rsp(res)
  log(bWriteLog and "[DeanJYT] TeamupHandler.on_zone_select_ping_display_details_rsp res = " .. tostring(res))
end
function TeamupHandler.on_ntf_teamate_motion_show_effect(uid, flag)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.UpdateEmoteShowEffect(uid, flag)
end
function TeamupHandler.on_ntf_teamate_motion_levelup(uid, action_id, level)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.UpdateEmoteLevel(uid, action_id, level)
end
function TeamupHandler.on_team_send_quick_msg_rsp(err_code, id)
end
function TeamupHandler.send_report_play_zone_ping(ping, net_type)
  log(bWriteLog and string.format("send_report_play_zone_ping, ping:%s", ping))
  log(bWriteLog and string.format("send_report_play_zone_ping, netType:%s", net_type))
  NetManager.SendPkg(1142732831, ping, net_type)
end
function TeamupHandler.send_record_net_anomaly_date_req(trigger_info)
  log_tree(bWriteLog and "TeamupHandler.send_record_net_anomaly_date_req trigger_info", trigger_info)
  NetManager.SendPkg(1526730587, trigger_info)
end
function TeamupHandler.on_record_net_anomaly_date_rsp(err_code)
  log(bWriteLog and string.format("TeamupHandler.on_record_net_anomaly_date_rsp, err_code:%s", err_code))
end
function TeamupHandler.send_get_car_main_page_data_req()
  NetManager.SendPkg(983471559)
end
function TeamupHandler.on_get_car_main_page_data_rsp(retcode, car_main_page_info)
  log_tree("TeamupHandler.on_get_car_main_page_data_rsp", {retcode, car_main_page_info})
  if retcode ~= 0 then
    return
  end
  local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
  GarageThemeSystem:OnReceiveGarageData(car_main_page_info)
end
function TeamupHandler.send_update_car_main_page_slot_req(slot_id, item_inst_id)
  NetManager.SendPkg(273709911, slot_id, item_inst_id)
end
function TeamupHandler.on_update_car_main_page_slot_rsp(ret_code, slot_id, item_inst_id)
  log_tree("TeamupHandler.on_update_car_main_page_slot_rsp", {
    ret_code,
    slot_id,
    item_inst_id
  })
  if ret_code ~= 0 then
    ShowNotice(ret_code)
    return
  end
  if not slot_id then
    return
  end
  local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
  GarageThemeSystem:OnEquipVehicle(slot_id, item_inst_id)
end
function TeamupHandler.send_batch_put_on_sportscar_req(instid_list)
  NetManager.SendPkg(975142279, instid_list)
end
function TeamupHandler.on_batch_put_on_sportscar_rsp(retcode, instid_list)
  log_tree("TeamupHandler.on_batch_put_on_sportscar_rsp", {retcode, instid_list})
  if retcode ~= 0 then
    return
  end
  local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
  GarageThemeSystem:OnBatchEquipVehicleRsp(instid_list)
end
function TeamupHandler.send_use_fun_prop_req(inst_id, count, target_uid_list)
  NetManager.SendPkg(1128956135, inst_id, count, target_uid_list)
end
function TeamupHandler.on_use_fun_prop_rsp(res, inst_id, count, target_uid_list)
  local logic_lobby_toy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_toy)
  logic_lobby_toy:on_use_fun_prop_rsp(res, inst_id, count, target_uid_list)
end
function TeamupHandler.on_notify_player_use_fun_prop(team_id, uid, res_id, target_uid_list)
  local logic_lobby_toy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_toy)
  logic_lobby_toy:on_notify_player_use_fun_prop(team_id, uid, res_id, target_uid_list)
end
function TeamupHandler.on_cross_zone_change_leader_notify(old_leader, new_leader, reduce_ping, predict_time, type)
  log(bWriteLog and string.format("TeamupHandler.on_cross_zone_change_leader_notify, old_leader:%s", old_leader))
  log(bWriteLog and string.format("TeamupHandler.on_cross_zone_change_leader_notify, new_leader:%s", new_leader))
  log(bWriteLog and string.format("TeamupHandler.on_cross_zone_change_leader_notify, reduce_ping:%s", reduce_ping))
  log(bWriteLog and string.format("TeamupHandler.on_cross_zone_change_leader_notify, predict_time:%s", predict_time))
  log(bWriteLog and string.format("TeamupHandler.on_cross_zone_change_leader_notify, type:%s", type))
  local logic_team_zone_ping = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_zone_ping)
  logic_team_zone_ping:on_cross_zone_change_leader_notify(old_leader, new_leader, reduce_ping, predict_time, type)
end
function TeamupHandler.send_cross_zone_allow_change_leader(old_leader, new_leader)
  log(bWriteLog and string.format("TeamupHandler.send_cross_zone_allow_change_leader, old_leader:%s", old_leader))
  log(bWriteLog and string.format("TeamupHandler.send_cross_zone_allow_change_leader, new_leader:%s", new_leader))
  NetManager.SendPkg(1649956144, old_leader, new_leader)
end
function TeamupHandler.on_tmode_room_team_info_notify(room_id, uid, change_key, change_value)
  log(bWriteLog and string.format("tmode_room_team_info_notify %s %s %s", room_id, uid, change_key))
  log_tree("tmode_room_team_info_notify change_value=", change_value)
  local logic_xmission_room_team = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_room_team)
  logic_xmission_room_team:on_tmode_room_team_info_notify(room_id, uid, change_key, change_value)
end
function TeamupHandler.on_only_leader_ping_notify(team_ping_map, leader_ping_map, is_open)
  log_tree(bWriteLog and "TeamupHandler.on_only_leader_ping_notify team_ping_map", team_ping_map)
  log_tree(bWriteLog and "TeamupHandler.on_only_leader_ping_notify leader_ping_map", leader_ping_map)
  local logic_team_zone_ping = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_zone_ping)
  logic_team_zone_ping:on_only_leader_ping_notify(team_ping_map, leader_ping_map, is_open)
end
function TeamupHandler.send_change_only_leader_ping_req(is_open)
  log(bWriteLog and string.format("TeamupHandler.send_change_only_leader_ping_req, is_open:%s", is_open))
  NetManager.SendPkg(1420305171, is_open)
end
function TeamupHandler.on_change_only_leader_ping_rsp(res, is_open)
  log(bWriteLog and string.format("TeamupHandler.on_change_only_leader_ping_rsp, res:%s", res))
  log(bWriteLog and string.format("TeamupHandler.on_change_only_leader_ping_rsp, is_open:%s", is_open))
  if res ~= NetErrorCode_NONE then
    ShowNotice(res)
    return true
  end
  local logic_team_zone_ping = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_zone_ping)
  logic_team_zone_ping:on_change_only_leader_ping_rsp(is_open)
end
function TeamupHandler.on_change_cross_shadow_notify(not_cross, add_ping, plan_type)
  log(bWriteLog and string.format("TeamupHandler.on_change_cross_shadow_notify, not_cross:%s", not_cross))
  log(bWriteLog and string.format("TeamupHandler.on_change_cross_shadow_notify, add_ping:%s", add_ping))
  log(bWriteLog and string.format("TeamupHandler.on_change_cross_shadow_notify, plan_type:%s", plan_type))
  local logic_team_zone_ping = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_zone_ping)
  logic_team_zone_ping:on_change_cross_shadow_notify(not_cross, add_ping, plan_type)
end
function TeamupHandler.send_change_cross_shadow_req(not_cross, save_change, next_show_time)
  NetManager.SendPkg(1695662147, not_cross, save_change, next_show_time)
end
function TeamupHandler.on_change_cross_shadow_rsp(res, not_cross, save_change)
  log(bWriteLog and string.format("TeamupHandler.on_change_cross_shadow_rsp, res:%s", res))
  log(bWriteLog and string.format("TeamupHandler.on_change_cross_shadow_rsp, not_cross:%s", not_cross))
  log(bWriteLog and string.format("TeamupHandler.on_change_cross_shadow_rsp, save_change:%s", save_change))
  if res ~= NetErrorCode_NONE then
    ShowNotice(res)
    return
  end
  local logic_team_zone_ping = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_zone_ping)
  logic_team_zone_ping:on_change_cross_shadow_rsp(not_cross, save_change)
end
function TeamupHandler.send_depot_cloth_feature_trigger_req(instid)
  NetManager.SendPkg(1167237447, instid)
end
function TeamupHandler.on_depot_cloth_feature_trigger_rsp(err, instid)
  log(bWriteLog and string.format("TeamupHandler.on_depot_cloth_feature_trigger_rsp, err:%s, instid:%s", err, instid))
  if err ~= 0 then
    return
  end
end
function TeamupHandler.send_main_city_change_3d_req(is_3d)
  printf("TeamupHandler.send_main_city_change_3d_req. is_3d=%s", tostring(is_3d))
  NetManager.SendPkg(1912817755, is_3d)
end
function TeamupHandler.on_select_zone_sync_krjp_asia(krjp_asia)
  log_tree(bWriteLog and "TeamupHandler.on_select_zone_sync_krjp_asia krjp_asia", krjp_asia)
  if not GlobalData.IsJapanOrKorea() then
    log(bWriteLog and "TeamupHandler.on_select_zone_sync_krjp_asia return of not IsJapanOrKorea")
    return
  end
  if krjp_asia and type(krjp_asia) == "table" then
    DataMgr.JPKRMatchServerOn = krjp_asia.switch_to_asia
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  MatchSystem.SetCrossMatchParamByJPKR(krjp_asia)
  MatchSystem.bIsSwitchServerShowed = not krjp_asia or not krjp_asia.cross_time_to_asia or krjp_asia.cross_time_to_asia <= 0
end
function TeamupHandler.send_depot_common_puton_sync_team_req(instid)
  NetManager.SendPkg(2124236967, instid)
end
function TeamupHandler.on_depot_common_puton_sync_team_rsp(err, instid)
end
function TeamupHandler.send_on_check_team_match_state(mode, sub_mode_groups, mod_id_list)
  log(bWriteLog and string.format("TeamupHandler.send_on_check_team_match_state mode=%s", tostring(mode)))
  log_tree(bWriteLog and "TeamupHandler.send_on_check_team_match_state sub_mode_groups", sub_mode_groups)
  log_tree(bWriteLog and "TeamupHandler.send_on_check_team_match_state mod_id_list", mod_id_list)
  NetManager.SendPkg(1817633027, mode, sub_mode_groups, mod_id_list)
end
function TeamupHandler.on_on_check_team_match_state_res(err_code, team_match_state)
  log(bWriteLog and "TeamupHandler.on_on_check_team_match_state_res err_code:" .. tostring(err_code))
  log_tree(bWriteLog and "TeamupHandler.on_on_check_team_match_state_res team_match_state", team_match_state)
  if TeamupHandler.IsInNormalBattle() then
    return
  end
  local logic_team_match_state = require("client.slua.logic.teamup.logic_team_match_state")
  logic_team_match_state:on_check_team_match_state_res(err_code, team_match_state)
end
function TeamupHandler.on_team_member_map_download_notify(leader_uid, map_list)
  log(bWriteLog and "TeamupHandler.on_team_member_map_download_notify leader_uid:" .. tostring(leader_uid))
  log_tree(bWriteLog and "TeamupHandler.on_team_member_map_download_notify map_list", map_list)
  if map_list and type(map_list) == "table" and 0 < #map_list then
    ShowNotice(817435)
  end
end
function TeamupHandler.send_notify_team_member_map_download_req(member_map_info)
  log_tree(bWriteLog and "TeamupHandler.send_notify_team_member_map_download_req member_map_info", member_map_info)
  NetManager.SendPkg(1015576047, member_map_info)
end
local reqRsp = {
  send_change_only_leader_ping_req = "on_change_only_leader_ping_rsp",
  send_change_cross_shadow_req = "on_change_cross_shadow_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, TeamupHandler)
return TeamupHandler