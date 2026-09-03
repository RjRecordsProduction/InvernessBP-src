local NetManager = require("client.network.comm.NetManager")
local SocialLobbyHandler = {bHasStateData = false}
function SocialLobbyHandler.send_get_social_card()
  log(bWriteLog and "SocialLobbyHandler.send_get_social_card")
  NetManager.SendPkg(2019377638)
end
function SocialLobbyHandler.on_get_social_card_rsp(ok, social_card)
  log(bWriteLog and "SocialLobbyHandler.on_get_social_card_rsp ok = " .. ok)
  log_tree("social_card = ", social_card)
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  SocialCardSystem.get_social_card_rsp(ok, social_card)
end
function SocialLobbyHandler.send_modify_social_card(social_card, signature)
  log(bWriteLog and "SocialLobbyHandler.send_modify_social_card")
  log_tree("social_card = ", social_card)
  log_tree("signature = ", signature)
  NetManager.SendPkg(582500332, social_card, signature)
end
function SocialLobbyHandler.on_modify_social_card_rsp(ok, social_card, signature)
  log(bWriteLog and "SocialLobbyHandler.on_modify_social_card_rsp ok = " .. ok)
  log_tree("social_card = ", social_card)
  log_tree("signature = ", signature)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.modify_social_card_rsp(ok, social_card, signature)
end
function SocialLobbyHandler.send_get_role_battle_info(uid, client_data, optype, zone_id)
  NetManager.SendPkg(1549217228, uid, client_data, optype, zone_id)
end
function SocialLobbyHandler.on_get_role_battle_info_rsp(res, client_data, optype, role_combat_info, zoneid, curseasonid, allseasonlist, battle_info_no_rank, battle_info_career, peakgame_info)
  log(bWriteLog and "SocialLobbyHandler.on_get_role_battle_info_rsp zoneid = " .. tostring(zoneid))
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  if "Compare" == client_data then
    log(bWriteLog and "[ZH] Compare with Player")
    if res ~= 0 then
      ShowNotice(res)
      return
    end
    RoleInfoSystem.SetMyRadarData(role_combat_info, battle_info_no_rank)
    local logic_peakgame_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_combat)
    logic_peakgame_combat:OnGetMyPeakGameInfo(peakgame_info)
    return
  end
  RoleInfoSystem.SetBrokenLineData(role_combat_info)
  RoleInfoSystem.get_role_combat_info_rsp(res, client_data, optype, role_combat_info, zoneid, curseasonid, allseasonlist, battle_info_no_rank, battle_info_career, peakgame_info)
  local logic_mentor = require("client.slua.logic.mentor.logic_mentor")
  logic_mentor.get_role_combat_info_rsp(res, client_data, optype, role_combat_info, zoneid, curseasonid, allseasonlist)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  LobbySocialSystem.get_role_combat_info_rsp(res, client_data, optype, role_combat_info, zoneid, curseasonid, allseasonlist, battle_info_career, peakgame_info)
end
function SocialLobbyHandler.send_modify_role_signature(sign)
  log(bWriteLog and "SocialLobbyHandler.send_modify_role_signature sign = " .. tostring(sign))
  NetManager.SendPkg(300057964, sign)
end
function SocialLobbyHandler.on_modify_role_signature_respond(res, unlock_time)
  log(bWriteLog and "SocialLobbyHandler.on_modify_role_signature_respond res = " .. res .. ", unlock_time = " .. tostring(unlock_time))
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.modify_role_signature_respond(res, unlock_time)
end
function SocialLobbyHandler.send_modify_role_name(strName, itemid, instid)
  log(bWriteLog and "SocialLobbyHandler.send_modify_role_name strName = " .. strName .. ", itemid = " .. itemid .. ", instid = " .. instid)
  NetManager.SendPkg(1303985484, strName, itemid, instid)
end
function SocialLobbyHandler.on_modify_role_name_rsp(ok, unlock_time, new_name)
  log(bWriteLog and "SocialLobbyHandler.on_modify_role_name_rsp ok = " .. ok .. ", unlock_time = " .. tostring(unlock_time) .. ", new_name = " .. tostring(new_name))
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.modify_role_name_rsp(ok, unlock_time, new_name)
end
function SocialLobbyHandler.send_publish_intimacy_conscribe_req()
  log(bWriteLog and "SocialLobbyHandler.send_publish_intimacy_conscribe_req")
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local nSendSts = NetManager.SendPkg(333060327)
  local NetMacros = pcall(require, "client.network.comm.NetMacros")
  if NetMacros and type(NetMacros) == "table" and nSendSts == NetMacros.ERROR_INCD then
    ShowNotice(7108)
    return
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Lobby_Intimacy_Click_Update)
end
function SocialLobbyHandler.on_publish_intimacy_conscribe_rsp(err_code)
  log(bWriteLog and "SocialLobbyHandler.on_publish_intimacy_conscribe_rsp err_code = " .. err_code)
  SocialLobbyHandler.intimacy_conscribe_state = 1
  SocialLobbyHandler.bHasStateData = true
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_PUBLISH_INTIMACY_CONSCRIBE_RSP)
  ShowNotice(43401)
end
function SocialLobbyHandler.send_get_intimacy_conscribe_state_req()
  log(bWriteLog and "SocialLobbyHandler.send_get_intimacy_conscribe_state_req")
  NetManager.SendPkg(872016551)
end
function SocialLobbyHandler.on_get_intimacy_conscribe_state_rsp(err_code, state)
  log(bWriteLog and "SocialLobbyHandler.on_get_intimacy_conscribe_state_rsp err_code = " .. err_code .. ", state = " .. tostring(state))
  if err_code ~= 0 then
    return
  end
  SocialLobbyHandler.intimacy_conscribe_  SocialLobbyHandler.bHasStateData = true
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_GET_INTIMACY_CONSCRIBE_STATE)
end
function SocialLobbyHandler.send_get_role_privacy()
  log(bWriteLog and "SocialLobbyHandler.send_get_role_privacy")
  NetManager.SendPkg(89089484)
end
function SocialLobbyHandler.on_get_role_privacy_rsp(privacy, privacy_season_info)
  log(bWriteLog and "SocialLobbyHandler.on_get_role_privacy_rsp privacy = " .. tostring(privacy) .. ", privacy_season_info = " .. tostring(privacy_season_info))
  local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
  LogicSettingBasic.get_role_privacy_rsp(privacy)
  local CharacterHandler = require("client.network.Protocol.CharacterHandler")
  CharacterHandler.bShowPlayDays = privacy_season_info
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_SHOW_PLAY_DAYS_UPDATE)
end
function SocialLobbyHandler.send_get_role_history_season_battle(uid, season_id, zone_id)
  NetManager.SendPkg(527447724, uid, season_id, zone_id)
end
function SocialLobbyHandler.on_get_role_history_season_battle_rsp(res, battle_info)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.get_role_history_season_battle_rsp(res, battle_info)
  log_tree("[ZH] battle_info", battle_info)
end
function SocialLobbyHandler.send_get_last_battle_type_req()
  NetManager.SendPkg(441552679)
end
function SocialLobbyHandler.on_get_last_battle_type_rsp(ret, last_battle)
end
function SocialLobbyHandler.send_get_role_lbs_battle_info(uid, callback)
  NetManager.SendPkg(1822290252, uid, callback)
end
function SocialLobbyHandler.on_get_role_lbs_battle_info_rsp(ok, callback, battle_info, curr_season_index)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.get_role_lbs_battle_info_rsp(ok, callback, battle_info, curr_season_index)
end
function SocialLobbyHandler.send_client_in_depot()
  NetManager.SendPkg(1778875044)
end
function SocialLobbyHandler.send_get_role_history_season_battle_no_rank(uid, season_id, zone_id)
  NetManager.SendPkg(1187026892, uid, season_id, zone_id)
end
function SocialLobbyHandler.on_get_role_history_season_battle_no_rank_rsp(res, battle_info)
  local RoleInfoMatchSystem = require("client.logic.roleinfo.logic_roleinfo_match")
  RoleInfoMatchSystem.get_match_history_season_info_rsp(res, battle_info)
end
function SocialLobbyHandler.send_set_battleinfo_show_options_req(option_list)
  NetManager.SendPkg(1969842170, option_list)
end
function SocialLobbyHandler.on_set_battleinfo_show_options_res(err_code, option_list)
  local logic_social_battle_info = require("client.slua.logic.lobby.Left.logic_social_battle_info")
  logic_social_battle_info.on_set_battleinfo_show_options_rsp(err_code, option_list)
end
function SocialLobbyHandler.send_get_role_history_season_peakgame_req(uid, season_id, zone_id)
  NetManager.SendPkg(1700159783, uid, season_id, zone_id)
end
function SocialLobbyHandler.on_get_role_history_season_peakgame_rsp(err_code, season_id, zone_id, peakgame_info)
  log(bWriteLog and "SocialLobbyHandler.on_get_role_history_season_peakgame_rsp err_code = " .. tostring(err_code) .. " season_id = " .. tostring(season_id) .. "zone_id = " .. tostring(zone_id))
  log_tree("SocialLobbyHandler.on_get_role_history_season_peakgame_rsp peakgame_info = ", peakgame_info)
  local logic_peakgame_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_combat)
  logic_peakgame_combat:OnGetHistorySeasonPeakGameInfoRsp(err_code, season_id, zone_id, peakgame_info)
end
function SocialLobbyHandler.on_notify_collect_hall_data_to_client(notify_data)
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  Logic_SocialLobbyModule:CheckNoticeDataChangeSlot(notify_data)
end
return SocialLobbyHandler