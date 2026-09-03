local NetManager = require("client.network.comm.NetManager")
local LBSHandler = {}
function LBSHandler.send_lbs_set_privacy_req(id, privacy_type)
  NetManager.SendPkg(553156071, id, privacy_type)
end
function LBSHandler.on_lbs_set_privacy_rsp(err_code, id, privacy_type)
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  LbsMgr.UpdateJoin(id, privacy_type)
end
function LBSHandler.send_lbs_set_zone_req(select_zone_list)
  NetManager.SendPkg(1893135271, select_zone_list)
end
function LBSHandler.on_lbs_set_zone_rsp(err_code, select_zone_list, update_ts)
  local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
  logic_lbs_warzone:on_lbs_set_zone_by_gps_rsp(err_code, select_zone_list, update_ts)
end
function LBSHandler.on_lbs_sync_rsp(err_code, lbs)
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  LbsMgr.UpdateLBSSummary(lbs)
end
function LBSHandler.send_get_lbs_potential_title_req()
  log(bWriteLog and "LBSHandler.send_get_lbs_potential_title_req")
  NetManager.SendPkg(1187166795)
end
function LBSHandler.on_get_lbs_potential_title_rsp(ret, title_map)
  log(bWriteLog and "LBSHandler.on_get_lbs_potential_title_rsp ret = " .. ret)
  log_tree("title_map = ", title_map)
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  LbsMgr.proc_get_lbs_potential_title_rsp(ret, title_map)
end
function LBSHandler.lbs_nearly_player_req()
  NetManager.SendPkg(1230680703)
end
function LBSHandler.on_lbs_nearly_player_rsp(err_code, player_list)
  local LBSFriendMgr = require("client.slua.logic.lbs.logic_lbs_friend")
  LBSFriendMgr:UpdatePlayerList(player_list)
end
function LBSHandler.on_lbs_nearly_notify_online_status_chg(uid, isOnline)
  log(bWriteLog and "[qintong] on_lbs_nearly_notify_online_status_chg uid =" .. uid .. " isOnline =" .. tostring(isOnline))
  local LBSFriendMgr = require("client.slua.logic.lbs.logic_lbs_friend")
  LBSFriendMgr:UpdateFriendOnLineData(uid, isOnline)
  EventSystem:postEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_TEAM_BAR_STATUS, uid)
end
function LBSHandler.on_lbs_nearly_notify_group_status_chg(uid, newStatus)
  log_tree("[qintong] on_lbs_nearly_notify_group_status_chg uid =" .. uid, newStatus)
  local LBSFriendMgr = require("client.slua.logic.lbs.logic_lbs_friend")
  LBSFriendMgr:UpdateFriendGroupData(uid, newStatus)
  EventSystem:postEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_TEAM_BAR_STATUS, uid)
end
function LBSHandler.send_set_title_not_new(title_list)
  NetManager.SendPkg(646478972, title_list)
end
function LBSHandler.on_set_title_not_new_rsp(err)
  if err == 0 then
    local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
    LbsMgr.ClearTitleRedPoint()
  end
end
function LBSHandler.send_lbs_nearly_player_req()
  NetManager.SendPkg(1230680703)
end
function LBSHandler.send_lbs_get_gps_zone_req(latitude, longitude)
  NetManager.SendPkg(284810791, latitude, longitude)
end
function LBSHandler.on_lbs_get_gps_zone_rsp(err_code, zone_id_list, query_ts)
  log_format(bWriteLog and "LBSHandler.on_lbs_get_gps_zone_rsp err_code:%s query_ts:%s", err_code, query_ts)
  log_tree("LBSHandler.on_lbs_get_gps_zone_rsp zone_id_list", zone_id_list)
  local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
  logic_lbs_warzone:on_lbs_get_gps_zone_rsp(err_code, zone_id_list, query_ts)
end
function LBSHandler.send_lbs_set_zone_by_gps_req(zone_id_list)
  NetManager.SendPkg(209999267, zone_id_list)
end
function LBSHandler.on_lbs_set_zone_by_gps_rsp(err_code, zone_id_list, update_ts)
  local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
  logic_lbs_warzone:on_lbs_set_zone_by_gps_rsp(err_code, zone_id_list, update_ts)
end
return LBSHandler