local NetManager = require("client.network.comm.NetManager")
local PeakGameHandler = {}
function PeakGameHandler.send_get_peakgame_season_info_req()
  log(bWriteLog and "PeakGameHandler.send_get_peakgame_season_info_req")
  NetManager.SendPkg(1814853479)
end
function PeakGameHandler.on_get_peakgame_season_info_rsp(err_code, season_info)
  log(bWriteLog and "PeakGameHandler.on_get_peakgame_season_info_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  log_tree("PeakGameHandler.on_get_peakgame_season_info_rsp, season_info = ", season_info)
  local LogicPeakGameReward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameReward)
  LogicPeakGameReward:OnGetPeakGameSeasonInfo(season_info)
end
function PeakGameHandler.send_get_peakgame_info_req()
  log(bWriteLog and "PeakGameHandler.send_get_peakgame_info_req")
  NetManager.SendPkg(1738124615)
end
function PeakGameHandler.on_get_peakgame_info_rsp(err_code, peakgame_info)
  log(bWriteLog and "PeakGameHandler.on_get_peakgame_info_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  log_tree("PeakGameHandler.on_get_peakgame_info_rsp, peakgame_info = ", peakgame_info)
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  LogicPeakGame:OnGetPeakGameInfo(peakgame_info)
end
function PeakGameHandler.on_peakgame_info_notify(peakgame_info)
  log_tree("PeakGameHandler.on_peakgame_info_notify, peakgame_info = ", peakgame_info)
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  LogicPeakGame:OnGetPeakGameInfo(peakgame_info)
end
function PeakGameHandler.send_get_peakgame_all_rating_info_req()
  log(bWriteLog and "PeakGameHandler.send_get_peakgame_all_rating_info_req")
  NetManager.SendPkg(496494887)
end
function PeakGameHandler.on_get_peakgame_all_rating_info_rsp(err_code, all_rating_info)
  log(bWriteLog and "PeakGameHandler.on_get_peakgame_all_rating_info_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  log_tree("PeakGameHandler.on_get_peakgame_all_rating_info_rsp, all_rating_info = ", all_rating_info)
  if not all_rating_info then
    return
  end
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  LogicPeakGame:OnGetPeakGameRatingInfo(all_rating_info.rating_info)
end
function PeakGameHandler.send_get_peakgame_rating_info_req()
  log(bWriteLog and "PeakGameHandler.send_get_peakgame_rating_info_req")
  NetManager.SendPkg(1768532135)
end
function PeakGameHandler.on_get_peakgame_rating_info_rsp(err_code, rating_info)
  log(bWriteLog and "PeakGameHandler.on_get_peakgame_rating_info_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  log_tree("PeakGameHandler.on_get_peakgame_rating_info_rsp, rating_info = ", rating_info)
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  LogicPeakGame:OnGetPeakGameRatingInfo(rating_info)
end
function PeakGameHandler.on_peakgame_rating_info_notify(can_peakgame, rating_info)
  log(bWriteLog and "PeakGameHandler.on_peakgame_rating_info_notify can_peakgame = " .. tostring(can_peakgame))
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  LogicPeakGame:OnGetPeakGameRatingInfoNotify(can_peakgame, rating_info)
end
function PeakGameHandler.send_get_peakgame_time_req()
  log(bWriteLog and "PeakGameHandler.send_get_peakgame_time_req")
  NetManager.SendPkg(728559843)
end
function PeakGameHandler.on_get_peakgame_time_rsp(err_code, peakgame_time_info)
  log(bWriteLog and "PeakGameHandler.on_get_peakgame_time_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  log_tree("PeakGameHandler.on_get_peakgame_time_rsp, peakgame_time_info = ", peakgame_time_info)
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  LogicPeakGame:OnGetPeakGameTimeInfo(peakgame_time_info)
end
function PeakGameHandler.on_peakgame_time_notify(peakgame_time_info)
  log_tree("PeakGameHandler.on_peakgame_time_notify, peakgame_time_info = ", peakgame_time_info)
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  LogicPeakGame:OnGetPeakGameTimeInfo(peakgame_time_info)
end
function PeakGameHandler.send_take_peakgame_segment_prize_all_req()
  NetManager.SendPkg(1353852827)
end
function PeakGameHandler.on_take_peakgame_segment_prize_all_rsp(err_code, awards, invoke_type)
  log(bWriteLog and "PeakGameHandler.on_take_peakgame_segment_prize_all_rsp " .. err_code)
  log(bWriteLog and "PeakGameHandler.on_take_peakgame_segment_prize_all_rsp invoke_type" .. tostring(invoke_type))
  log_tree("PeakGameHandler.on_take_peakgame_segment_prize_all_rsp ", awards)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicPeakGameReward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameReward)
  LogicPeakGameReward:OnGetPeakGameSegmentAllPrice(awards, invoke_type)
end
function PeakGameHandler.send_take_peakgame_segment_prize_req(id)
  NetManager.SendPkg(1531535171, id)
end
function PeakGameHandler.on_take_peakgame_segment_prize_rsp(err_code, id)
  log(bWriteLog and "PeakGameHandler.on_take_peakgame_segment_prize_rsp err_code:" .. tostring(err_code) .. " id:" .. tostring(id))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicPeakGameReward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameReward)
  LogicPeakGameReward:OnGetPeakGameSegmentPrize(id)
end
function PeakGameHandler.send_get_friend_peakgame_rank(zone_id, uid_list)
  NetManager.SendPkg(748257420, zone_id, uid_list)
end
function PeakGameHandler.on_get_friend_peakgame_rank_rsp(err_code, zone_id, friend_rank_data)
  log(bWriteLog and "PeakGameHandler.on_get_friend_peakgame_rank_rsp err_code = " .. tostring(err_code) .. " zone_id:" .. tostring(zone_id))
  log_tree("PeakGameHandler.on_get_friend_peakgame_rank_rsp, friend_rank_data = ", friend_rank_data)
  local LogicPeakGameRank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameRank)
  LogicPeakGameRank:OnGetFriendRankListData(err_code, zone_id, friend_rank_data)
end
function PeakGameHandler.on_peakgame_season_info_notify(season_info)
  log(bWriteLog and "PeakGameHandler.on_peakgame_season_info_notify")
  log_tree("PeakGameHandler.on_peakgame_season_info_notify, season_info = ", season_info)
  local LogicPeakGameReward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameReward)
  LogicPeakGameReward:OnGetPeakGameSeasonInfo(season_info)
end
function PeakGameHandler.send_get_peak_week_rank_time_req()
  NetManager.SendPkg(402197843)
end
function PeakGameHandler.on_get_peak_week_rank_time_rsp(err_code, start_timestamp, end_timestamp)
  log(bWriteLog and "PeakGameHandler.on_get_peak_week_rank_time_rsp err_code" .. tostring(err_code) .. " start_timestamp:" .. tostring(start_timestamp) .. " end_timestamp:" .. tostring(end_timestamp))
  if err_code ~= 0 then
    return
  end
  local LogicPeakGameHall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameHall)
  LogicPeakGameHall:OnGetPeakGameWeeklyRankTime(start_timestamp, end_timestamp)
end
function PeakGameHandler.send_sync_peak_game_auth_check_result_req(client_check_result, auth_sdk_failed)
  NetManager.SendPkg(1221623552, client_check_result, auth_sdk_failed)
end
function PeakGameHandler.on_sync_peak_game_check_result_rsp(err, is_pass)
  local CrewAuthLogic = require("client.slua.logic.crew.logic_crew_authentication")
  CrewAuthLogic.SyncAuthCheckResult(is_pass and 0 or 1)
  if is_pass then
    LobbySystem.on_start_match_req()
  end
end
function PeakGameHandler.send_peakgame_result_reward_req(rank_requird_id)
  NetManager.SendPkg(1317990119, rank_requird_id)
end
function PeakGameHandler.on_peakgame_result_reward_rsp(err_code, rank_requird_id, flag, rank_data)
  log(bWriteLog and "PeakGameHandler.on_peakgame_result_reward_rsp err_code = " .. tostring(err_code) .. " rank_requird_id = " .. tostring(rank_requird_id) .. " flag = " .. tostring(flag))
  log_tree("PeakGameHandler.on_peakgame_result_reward_rsp rank_data = ", rank_data)
  local LogicPeakHallResultReward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakHallResultReward)
  LogicPeakHallResultReward:OnGetPeakGameResultReward(err_code, rank_requird_id, flag, rank_data)
end
function PeakGameHandler.send_get_peakgame_fame_rank_req(rank_type, zone_id, season_id, extra_data)
  NetManager.SendPkg(842791975, rank_type, zone_id, season_id, extra_data)
end
function PeakGameHandler.on_get_peakgame_fame_rank_rsp(err_code, rank_list, zone_id, season_id, extra_data)
  log(bWriteLog and "PeakGameHandler.on_get_peakgame_fame_rank_rsp err_code = " .. tostring(err_code) .. " zone_id = " .. tostring(zone_id) .. " season_id = " .. tostring(season_id))
  log_tree("PeakGameHandler.on_get_peakgame_fame_rank_rsp rank_list = ", rank_list)
  log_tree("PeakGameHandler.on_get_peakgame_fame_rank_rsp extra_data = ", extra_data)
  local LogicPeakGameHall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameHall)
  LogicPeakGameHall:OnGetTopnHofRankData(err_code, rank_list, zone_id, season_id, extra_data)
end
function PeakGameHandler.send_get_peakgame_prize_info_req(type, zone_id, battle_type)
  log(bWriteLog and "PeakGameHandler.send_get_peakgame_prize_info_req type" .. tostring(type) .. " zone_id = " .. tostring(zone_id) .. "battle_type" .. tostring(battle_type))
  NetManager.SendPkg(379448067, type, zone_id, battle_type)
end
function PeakGameHandler.on_get_peakgame_prize_info_rsp(err_code, item_list, type)
  log(bWriteLog and "PeakGameHandler.on_get_peakgame_prize_info_rsp " .. tostring(err_code) .. " type = " .. tostring(type))
  if err_code ~= 0 then
    return
  end
  log_tree("PeakGameHandler.on_get_peakgame_segment_prize_info_rsp  item_list= ", item_list)
  local LogicPeakGameReward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameReward)
  if type == 1 then
    LogicPeakGameReward:OnGetPeakTierRewardList(item_list)
  elseif type == 2 then
    LogicPeakGameReward:OnGetEndRewardList(item_list)
  end
end
function PeakGameHandler.send_set_segment_show_type_req(segment_show_type)
  NetManager.SendPkg(615546823, segment_show_type)
end
function PeakGameHandler.on_set_segment_show_type_rsp(err_code, segment_show_type)
  log(bWriteLog and "PeakGameHandler.on_set_segment_show_type_rsp err_code = " .. tostring(err_code) .. " segment_show_type = " .. tostring(segment_show_type))
  local LogicPeakGameSegmentType = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameSegmentType)
  LogicPeakGameSegmentType:OnGetSetSegmentShowTypeRsp(err_code, segment_show_type)
end
function PeakGameHandler.send_query_peak_game_change_day_req()
  NetManager.SendPkg(1968512487)
end
function PeakGameHandler.on_query_peak_game_change_day_rsp(err_code, peakgame_info)
  log(bWriteLog and "PeakGameHandler.on_query_peak_game_change_day_rsp err_code = " .. tostring(err_code))
  log_tree(bWriteLog and "PeakGameHandler.on_query_peak_game_change_day_rsp peakgame_info = ", peakgame_info)
  if err_code ~= 0 then
    return
  end
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  LogicPeakGame:OnGetPeakGameChangeRankRuleInfo(peakgame_info)
end
function PeakGameHandler.send_batch_peakgame_result_reward_req(rank_requird_id_list)
  NetManager.SendPkg(1975412135, rank_requird_id_list)
end
function PeakGameHandler.on_batch_peakgame_result_reward_rsp(err_code, rank_requird_id_list, flag_map, rank_data_map)
  log(bWriteLog and "PeakGameHandler.on_batch_peakgame_result_reward_rsp err_code = " .. tostring(err_code))
  log_tree("PeakGameHandler.on_batch_peakgame_result_reward_rsp rank_data = ", rank_requird_id_list)
  log_tree("PeakGameHandler.on_batch_peakgame_result_reward_rsp flag_map = ", flag_map)
  log_tree("PeakGameHandler.on_batch_peakgame_result_reward_rsp rank_data_map = ", rank_data_map)
  local LogicPeakHallResultReward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakHallResultReward)
  LogicPeakHallResultReward:OnGetBatchPeakGameResultReward(err_code, rank_requird_id_list, flag_map, rank_data_map)
end
function PeakGameHandler.send_get_peakgame_segment_all_req()
  log(bWriteLog and "PeakGameHandler.send_get_peakgame_segment_all_req uid = " .. tostring(uid))
  NetManager.SendPkg(1004860711)
end
function PeakGameHandler.on_get_peakgame_segment_all_rsp(err_code, segment_info)
  log(bWriteLog and "PeakGameHandler.on_get_peakgame_segment_all_rsp err_code = " .. tostring(err_code) .. " uid = " .. tostring(uid))
  log_tree(bWriteLog and "on_set_ace_show_type_rsp segment_info = ", segment_info)
  local logic_peakgame_ace = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_ace)
  logic_peakgame_ace:OnGetPeakGameSegmentAllRsp(err_code, segment_info)
end
function PeakGameHandler.on_peakgame_ace_reissue_notify(segment_info)
  log_tree(bWriteLog and "on_peakgame_ace_reissue_notify segment_info = ", segment_info)
  local logic_peakgame_ace = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_ace)
  logic_peakgame_ace:OnPeakGameAceReissueNotify(segment_info)
end
return PeakGameHandler