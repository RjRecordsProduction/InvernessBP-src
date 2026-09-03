local NetManager = require("client.network.comm.NetManager")
local kol_handler = {}
function kol_handler.send_get_kol_detail_req(team_id)
  NetManager.SendPkg(1114348967, team_id)
end
function kol_handler.on_get_kol_detail_rsp(ret, kol_detail)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  log_tree("xcc kol_handler.on_get_kol_detail_rsp", kol_detail)
  local kol_data_in = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.kol_data_in)
  kol_data_in:ShowBusinessCard(kol_detail)
  kol_data_in:UpdateTimeWhenGetServerDataSuccess(kol_detail.team_id)
end
function kol_handler.send_join_kol_team_req(team_id)
  NetManager.SendPkg(259039343, team_id)
end
function kol_handler.on_join_kol_team_rsp(ret)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  local kol_data_in = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.kol_data_in)
  kol_data_in:JoinTeamHandler()
end
function kol_handler.send_leave_kol_team_req(team_id)
  NetManager.SendPkg(1305632007, team_id)
end
function kol_handler.on_leave_kol_team_rsp(ret)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  local kol_data_in = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.kol_data_in)
  kol_data_in:ExitTeamHandler()
end
function kol_handler.send_get_kol_ranks_req(type)
  NetManager.SendPkg(1475154223, type)
end
function kol_handler.on_get_kol_ranks_rsp(ret, rank_list, user_rank)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  log_tree("xcc kol_handler.on_get_kol_ranks_rsp rank_list", rank_list)
  log_tree("xcc kol_handler.on_get_kol_ranks_rsp user_rank", user_rank)
  local kol_data_in = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.kol_data_in)
  kol_data_in:SetThisWeekOrSeasonKolData(rank_list, user_rank)
  EventSystem:postEvent(EVENTTYPE_KOL_IN, EVENTID_KOL_PAGE_REFRESH_IN)
end
function kol_handler.send_get_top_fans_req()
  NetManager.SendPkg(238674663)
end
function kol_handler.on_get_top_fans_rsp(ret, top_fans, user_rank)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  log_tree("xcc kol_handler.on_get_top_fans_rsp top_fans", top_fans)
  log_tree("xcc kol_handler.on_get_top_fans_rsp user_rank", user_rank)
  local kol_data_in = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.kol_data_in)
  kol_data_in:GetOtherPlayersProfiles(top_fans)
  kol_data_in:SetTopFansDatas(top_fans, user_rank)
  kol_data_in:UpdateTimeWhenGetServerDataSuccess(kol_const.page_id_top_fans)
  EventSystem:postEvent(EVENTTYPE_KOL_IN, EVENTID_KOL_PAGE_REFRESH_IN)
end
function kol_handler.send_get_history_season_rank_req(season_id)
  NetManager.SendPkg(1633738411, season_id)
  log(bWriteLog and "xcc kol_handler.send_get_history_season_rank_req season_id" .. tostring(season_id))
end
function kol_handler.on_get_history_season_rank_rsp(ret, history_season_rank, user_rank, season_id)
  log(bWriteLog and "xcc kol_handler.on_get_history_season_rank_rsp season_id" .. tostring(season_id))
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  if not season_id then
    log(bWriteLog and "xcc kol_handler.on_get_history_season_rank_rsp season_id season_id is nil")
    return
  end
  log_tree("xcc kol_handler.on_get_history_season_rank_rsp history_season_rank", history_season_rank)
  log_tree("xcc kol_handler.on_get_history_season_rank_rsp user_rank", user_rank)
  local kol_data_in = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.kol_data_in)
  kol_data_in:SetHistoryKolData(history_season_rank, user_rank, season_id)
  EventSystem:postEvent(EVENTTYPE_KOL_IN, EVENTID_KOL_PAGE_REFRESH_IN)
end
function kol_handler.send_get_user_homepage_req()
  NetManager.SendPkg(347904399)
end
function kol_handler.on_get_user_homepage_rsp(ret, homepage_info)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  log_tree("xcc kol_handler.on_get_user_homepage_rsp", homepage_info)
  local kol_data_in = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.kol_data_in)
  kol_data_in:SetMyKolData(homepage_info)
  EventSystem:postEvent(EVENTTYPE_KOL_IN, EVENTID_KOL_PAGE_REFRESH_IN)
end
function kol_handler.send_take_kol_leaderboard_reward_req(award_segment_id)
  NetManager.SendPkg(91411219, award_segment_id)
end
function kol_handler.on_take_kol_leaderboard_reward_rsp(ret, award_segment_id, award_list)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  log(bWriteLog and "xcc kol_handler.on_take_kol_leaderboard_reward_rsp  " .. tostring(award_segment_id))
  log_tree("xcc kol_handler.on_take_kol_leaderboard_reward_rsp award_list", award_list)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DecomposeStyle(award_list)
  EventSystem:postEvent(EVENTTYPE_KOL_IN, EVENTID_KOL_GET_AWARD_IN, award_segment_id)
end
function kol_handler.send_get_user_historical_records_req(from_index, count)
  NetManager.SendPkg(1600716659, from_index, count)
end
function kol_handler.on_get_user_historical_records_rsp(ret, historical_records)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  log_tree("xcc kol_handler.on_get_user_historical_records_rsp", historical_records)
  local kol_data_in = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.kol_data_in)
  kol_data_in:ShowUserHistorySeason(historical_records)
end
function kol_handler.send_get_kol_list_req(season_id)
  log(bWriteLog and "xcc kol_handler.send_get_kol_list_req season_id" .. tostring(season_id))
  NetManager.SendPkg(2097168103, season_id)
end
function kol_handler.on_get_kol_list_rsp(ret, kol_list)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  log_tree("xcc kol_handler.on_get_kol_list_rsp", kol_list)
  local kol_data_in = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.kol_data_in)
  kol_data_in:SetCurSeasonAllTeamCfg(kol_list)
  EventSystem:postEvent(EVENTTYPE_KOL_IN, EVENTID_KOL_PAGE_REFRESH_IN)
  EventSystem:postEvent(EVENTTYPE_KOL_IN, EVENTID_KOL_REGET_CURPAGE_DATA)
end
function kol_handler.send_get_kol_topfans5_req(team_id)
  log(bWriteLog and "xcc kol_handler.send_get_kol_topfans5_req team_id" .. tostring(team_id))
  NetManager.SendPkg(62847399, team_id)
end
function kol_handler.on_get_kol_topfans5_rsp(ret, kol_card)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  log_tree("xcc kol_handler.on_get_kol_topfans5_rsp", kol_card)
  local kol_data_in = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.kol_data_in)
  kol_data_in:SetTeamTop5FansList(kol_card.team_id, kol_card.top5_fans)
  kol_data_in:GetOtherPlayersProfiles(kol_card.top5_fans)
end
return kol_handler