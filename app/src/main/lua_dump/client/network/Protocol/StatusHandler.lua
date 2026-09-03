local NetManager = require("client.network.comm.NetManager")
local StatusHandler = {}
function StatusHandler.send_set_online_status_req(status)
  log(bWriteLog and "StatusHandler.send_set_online_status_req status = " .. tostring(status))
  NetManager.SendPkg(1530925416, status)
end
function StatusHandler.on_set_online_status_res(res, status, left_times)
  log(bWriteLog and "StatusHandler.on_set_online_status_res res = " .. res .. " status = " .. tostring(status) .. " left_times=" .. tostring(left_times))
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local PlayerStatusEnum = require("client.slua.logic.player_status.PlayerStatusEnum")
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  if res == 0 then
    LogicFriend.teamState = status
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_MY_ONLINE_STATE_CHANGE)
  elseif res == 101000001 then
    ShowNotice(101000001)
  elseif res == 101000002 then
    ShowNotice(101000002)
  elseif res == 101000003 then
    local times = logic_friend_list.res_set_status_data.total_daily_times
    local str = LocUtil.LocalizeResFormat(101000003, times)
    ShowNotice(str)
  elseif res == 101000004 then
    ShowNotice(101000004)
  elseif res == 101000005 then
    local times = logic_friend_list.res_set_status_data.total_week_times
    local str = LocUtil.LocalizeResFormat(101000005, times)
    ShowNotice(str)
  else
    ShowNotice(10802)
  end
  if status == PlayerStatusEnum.Enum_TeamState.Stealth and (res == 0 or res == 101000005) then
    local data = LogicFriend.set_status_data
    data.week_times = data.total_week_times - left_times
  end
end
function StatusHandler.send_batch_get_group_and_online_req(type, uidList)
  NetManager.SendPkg(1756432487, type, uidList)
end
function StatusHandler.on_batch_get_group_and_online_rsp(listType, res, infos)
  log(bWriteLog and "StatusHandler.on_batch_get_group_and_online_rsp listType = " .. tostring(listType))
  if res ~= NetErrorCode_NONE and res ~= "timeout" then
    if listType == ENUM_BATCH_GET_GROUP_AND_ONLINE.RecommendTeammate then
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_UPDATE_RECOMMEND_STATUS, {})
    elseif listType == ENUM_BATCH_GET_GROUP_AND_ONLINE.RecentTeammate then
      EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_UPDATE_RECENT_STATUS)
    end
    return
  end
  for k, v in pairs(infos) do
    v.maxTeamAmount = StatusHandler.GetMaxTeamAmount(v)
    if not v.mod_id or type(v.mod_id) ~= "number" then
      v.mod_id = 0
    end
    log(bWriteLog and "StatusHandler.on_batch_get_group_and_online_rsp maxTeamAmount = " .. v.maxTeamAmount)
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  PlayerStatusMgr:on_batch_get_group_and_online_rsp(listType, res, infos)
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  local mod_ids = {}
  for uid, info in pairs(infos) do
    if info.online ~= 0 then
      if PlayerStatusUtil.IsIdle(info) then
        StatusHandler.send_get_friend_play_hall_room_stat(uid)
      end
      if info.mod_id and info.mod_id > 0 then
        mod_ids[#mod_ids + 1] = info.mod_id
      end
    end
  end
  PlayerStatusMgr:RequestModInfoByIds(mod_ids)
end
function StatusHandler.on_notify_online_status_chg(uid, isOnline)
  log(bWriteLog and "StatusHandler.on_notify_online_status_chg uid = " .. tostring(uid) .. " isOnline = " .. tostring(isOnline))
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  if PlayerStatusMgr and PlayerStatusMgr.on_notify_online_status_chg then
    PlayerStatusMgr:on_notify_online_status_chg(uid, isOnline)
  end
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  CorpsMemberSystem.on_notify_online_status_chg(uid, isOnline)
  if isOnline == 1 then
    StatusHandler.UpdateOnlinePlayerWoWInfo(uid)
  end
end
function StatusHandler.on_notify_group_status_chg(uid, status)
  log(bWriteLog and "StatusHandler.on_notify_group_status_chg uid = " .. uid)
  log_tree("StatusHandler.on_notify_group_status_chg", status)
  status.maxTeamAmount = StatusHandler.GetMaxTeamAmount(status)
  if not status.mod_id or type(status.mod_id) ~= "number" then
    status.mod_id = 0
  end
  log(bWriteLog and "StatusHandler.on_notify_group_status_chg status.maxTeamAmount = " .. status.maxTeamAmount)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  PlayerStatusMgr:on_notify_group_status_chg(uid, status)
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  CorpsMemberSystem.on_notify_group_status_chg(uid, status)
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  logic_ugc_mode:on_notify_group_status_chg(uid, status)
  if status.mod_id and status.mod_id > 0 then
    PlayerStatusMgr:RequestModInfoByIdDelay(status.mod_id)
  end
end
function StatusHandler.GetMaxTeamAmount(status)
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if status and status.game_mode == 0 or status.game_mode == 321 or PlayerStatusUtil.IsMainCity(status) or PlayerStatusUtil.InWoW(status) then
    return status.maxTeamAmount
  else
    local cfg = CDataTable.GetTableData("MatchModeTable", status.game_mode)
    if not cfg then
      return 1
    end
    return cfg.MaxTeamPlayerNum
  end
end
function StatusHandler.on_notify_friend_play_hall_room_stat(from_uid, ph_room_svr_id, play_hall_rooms)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local roomInfo
  local roomId = play_hall_rooms and next(play_hall_rooms)
  if roomId then
    roomInfo = play_hall_rooms[roomId]
    roomInfo.hall_id = roomId
  end
  PlayerStatusMgr:on_notify_friend_play_hall_room_stat_chg(from_uid, ph_room_svr_id, roomInfo)
end
function StatusHandler.send_get_friend_play_hall_room_stat(friend_uid)
  NetManager.SendPkg(1915552044, friend_uid)
end
function StatusHandler.on_get_friend_play_hall_room_stat_rsp(err_code, friend_uid, ph_room_svr_id, play_hall_rooms)
  if err_code ~= 0 then
    return
  end
  StatusHandler.on_notify_friend_play_hall_room_stat(friend_uid, ph_room_svr_id, play_hall_rooms)
end
function StatusHandler.send_query_friend_room_id(friend_uid)
  NetManager.SendPkg(1694671820, friend_uid)
end
function StatusHandler.on_query_friend_room_id_rsp(err_code, friend_uid, room_id)
  if err_code == 0 then
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    PlayerStatusMgr:OnQueryFriendRoom(friend_uid, room_id)
  end
end
function StatusHandler.UpdateOnlinePlayerWoWInfo(uid)
  if UIManager.IsUIShow(UIManager.UI_Config.Lobby_InviteFriend_BP) then
    local uidList = {
      [1] = uid
    }
    StatusHandler.send_batch_get_group_and_online_req(ENUM_BATCH_GET_GROUP_AND_ONLINE.TeamUpStranger, uidList)
    return
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  PlayerStatusMgr.needUpdateWoWInfoPlayerIdList[#PlayerStatusMgr.needUpdateWoWInfoPlayerIdList + 1] = uid
end
return StatusHandler