local NetManager = require("client.network.comm.NetManager")
local PopularityGiftHandler = {}
function PopularityGiftHandler.send_get_popularity_simple_req(uid)
  log(bWriteLog and "PopularityGiftHandler.send_get_popularity_simple_req uid = " .. uid)
  NetManager.SendPkg(1513337671, uid)
end
function PopularityGiftHandler.on_get_popularity_simple_rsp(res, uid, total_devote, is_show_detail)
  log(bWriteLog and "PopularityGiftHandler.on_get_popularity_simple_rsp uid = " .. uid .. " >>>> total_devote = " .. tostring(total_devote))
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.get_popularity_simple_rsp(res, uid, total_devote, is_show_detail)
end
function PopularityGiftHandler.send_get_pop_activity_rank_req(area_id)
  NetManager.SendPkg(1964062423, area_id)
end
function PopularityGiftHandler.on_get_pop_activity_rank_rsp(res, area_id, rank_list)
  if res == 0 then
    local RankPopularitySystem = require("client.slua.logic.activity.logic_rank_popularity")
    RankPopularitySystem.GetRankListRsp(area_id, rank_list)
  else
    ShowNotice(res)
  end
end
function PopularityGiftHandler.send_get_personal_pop_activity_rank_req(area_id)
  NetManager.SendPkg(418622087, area_id)
end
function PopularityGiftHandler.on_get_personal_pop_activity_rank_rsp(res, area_id, rank, score, other)
  if res == 0 then
    local RankPopularitySystem = require("client.slua.logic.activity.logic_rank_popularity")
    RankPopularitySystem.GetSelfRankRsp(rank, score, other)
  else
    ShowNotice(res)
  end
end
function PopularityGiftHandler.send_get_popularity_req(uid, eScene)
  NetManager.SendPkg(1933117319, uid, eScene)
end
function PopularityGiftHandler.on_get_popularity_rsp(ok, uid, total_devote, gift_record, is_show_detail, is_show_reddot, devote_rank, last_trend, reply_list, gift_record_summary, last_enter_pspace_time, last_week_devote, msg_trend, last_high_value, is_show_msg_reddot, pround_info, guardian_info, visitor_info, devote_level, guardian_rank, pspace_collect, summary_render_info, is_show_guardian_reddot, is_having_gift_record, ret_creative_rank)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.get_popularity_rsp(ok, uid, total_devote, gift_record, is_show_detail, is_show_reddot, devote_rank, last_trend, reply_list, gift_record_summary, last_enter_pspace_time, last_week_devote, msg_trend, last_high_value, is_show_msg_reddot, pround_info, guardian_info, visitor_info, devote_level, guardian_rank, pspace_collect, summary_render_info, is_show_guardian_reddot, is_having_gift_record, ret_creative_rank)
end
function PopularityGiftHandler.on_send_gift_notify_rsp(sender, receiver, gift_type, gift_count, sender_name, receiver_total_devote, gift_source, is_pay_uc, battle_id)
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  logic_send_gift.send_gift_notify_rsp(sender, receiver, gift_type, gift_count, sender_name, receiver_total_devote, gift_source, is_pay_uc, battle_id)
end
function PopularityGiftHandler.send_pspace_send_gift_req(uid, gift_type, gift_count, msg, name, gift_source, corps_seq_info, club_params, battle_id, manor_party_params, extendinfo)
  NetManager.SendPkg(255784167, uid, gift_type, gift_count, msg, name, gift_source, corps_seq_info, club_params, battle_id, manor_party_params, extendinfo)
end
function PopularityGiftHandler.on_pspace_send_gift_rsp(ok, total_devote, add_devote, gift_record, devote_rank, last_trend, gift_type, gift_count, uid, last_week_devote, msg_trend, last_high_value, gift_source, pround_info, battle_id, psmatch_team_gift)
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  logic_send_gift.pspace_send_gift_rsp(ok, total_devote, add_devote, gift_record, devote_rank, last_trend, gift_type, gift_count, uid, last_week_devote, msg_trend, last_high_value, gift_source, pround_info, battle_id, psmatch_team_gift)
end
function PopularityGiftHandler.send_show_popularity_detail_req(is_show)
  NetManager.SendPkg(2014485863, is_show)
end
function PopularityGiftHandler.on_show_popularity_detail_rsp(ok, is_show)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.show_popularity_detail_rsp(ok, is_show)
end
function PopularityGiftHandler.send_close_popularity_reddot_req(is_msg_reddot, is_guardian)
  NetManager.SendPkg(48329775, is_msg_reddot, is_guardian)
end
function PopularityGiftHandler.on_close_popularity_reddot_rsp(ok, is_msg_reddot, is_guardian)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.close_popularity_reddot_rsp(ok, is_msg_reddot, is_guardian)
end
function PopularityGiftHandler.send_set_last_trend_top_req(index, id, set_top)
  NetManager.SendPkg(317784615, index, id, set_top)
end
function PopularityGiftHandler.on_set_last_trend_top_rsp(ok, msg_trend)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.set_last_trend_top_rsp(ok, msg_trend)
end
function PopularityGiftHandler.send_delete_gift_record_req(index, id, scene)
  log(bWriteLog and "PopularityGiftHandler.send_delete_gift_record_req index = " .. tostring(index) .. ", id = " .. tostring(id) .. ", scene = " .. tostring(scene))
  NetManager.SendPkg(302760263, index, id, scene)
end
function PopularityGiftHandler.on_delete_gift_record_rsp(ok, msg_trend, scene)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.delete_gift_record_rsp(ok, msg_trend, scene)
end
function PopularityGiftHandler.send_reply_gift_msg_req(index, id, reply)
  NetManager.SendPkg(1589085351, index, id, reply)
end
function PopularityGiftHandler.on_reply_gift_msg_rsp(ok, msg_trend)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.reply_gift_msg_rsp(ok, msg_trend)
end
function PopularityGiftHandler.send_delete_gift_reply_req(index, id, recipient_uid)
  NetManager.SendPkg(913837199, index, id, recipient_uid)
end
function PopularityGiftHandler.on_delete_gift_reply_rsp(ok, msg_trend)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.delete_gift_reply_rsp(ok, msg_trend)
end
function PopularityGiftHandler.send_pspace_gift_config_req()
  NetManager.SendPkg(343229063)
end
function PopularityGiftHandler.on_pspace_gift_config_rsp(res, gift_config, gift_region_config)
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  logic_send_gift.pspace_gift_config_rsp(res, gift_config, gift_region_config)
end
function PopularityGiftHandler.on_show_msg_reddot(ok, is_show_msg_reddot, is_pay_uc)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.show_msg_reddot(ok, is_show_msg_reddot, is_pay_uc)
end
function PopularityGiftHandler.on_pspace_send_gift_ban_rsp(res, end_time)
  log(bWriteLog and "on_pspace_send_gift_ban_rsp:" .. tostring(res) .. ",end_time:" .. tostring(end_time))
  if res ~= 0 then
    local TimeUtil = require("client.common.time_util")
    ShowNotice(LocUtil.LocalizeResFormat(res, TimeUtil.FormatTime_YMDHMS(end_time, true)))
  end
end
function PopularityGiftHandler.send_set_popularity_pround_visable_req(is_show)
  NetManager.SendPkg(510272427, is_show)
end
function PopularityGiftHandler.on_set_popularity_pround_visable_rsp(errcode, is_show)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.set_popularity_pround_visable_rsp(errcode, is_show)
end
function PopularityGiftHandler.send_get_pspace_colletc_rank_req(target_uid, gift_id)
  NetManager.SendPkg(1731456327, target_uid, gift_id)
end
function PopularityGiftHandler.on_get_pspace_colletc_rank_rsp(res, target_uid, gift_id, pspace_colletc_rank)
  log(bWriteLog and "PopularityGiftHandler.on_get_pspace_colletc_rank_rsp res = " .. tostring(res))
  if res ~= 0 then
    return
  end
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.on_get_pspace_colletc_rank_rsp(target_uid, gift_id, pspace_colletc_rank)
end
function PopularityGiftHandler.send_get_gift_activity_rank_req(area_id, score_type)
  NetManager.SendPkg(250503175, area_id, score_type)
end
function PopularityGiftHandler.on_get_gift_activity_rank_rsp(res, area_id, score_type, rank_list)
  log(bWriteLog and "PopularityGiftHandler.on_get_gift_activity_rank_rsp res = " .. tostring(res))
  if res ~= 0 then
    return
  end
  local logic_rank_popularity = require("client.slua.logic.activity.logic_rank_popularity")
  logic_rank_popularity.GetRankListRsp(area_id, score_type, rank_list)
  local logic_rank_pround = require("client.slua.logic.activity.logic_rank_pround")
  logic_rank_pround.GetRankListRsp(area_id, score_type, rank_list)
  local logic_rank_guard = require("client.slua.logic.activity.logic_rank_guard")
  logic_rank_guard.GetRankListRsp(area_id, score_type, rank_list)
end
function PopularityGiftHandler.send_get_personal_gift_activity_rank_req(area_id, score_type)
  NetManager.SendPkg(1641772519, area_id, score_type)
end
function PopularityGiftHandler.on_get_personal_gift_activity_rank_rsp(res, area_id, score_type, rank_data)
  log(bWriteLog and "PopularityGiftHandler.on_get_personal_gift_activity_rank_rsp res = " .. tostring(res))
  if res ~= 0 then
    return
  end
  local logic_rank_popularity = require("client.slua.logic.activity.logic_rank_popularity")
  logic_rank_popularity.GetSelfRankRsp(area_id, score_type, rank_data)
  local logic_rank_pround = require("client.slua.logic.activity.logic_rank_pround")
  logic_rank_pround.GetSelfRankRsp(area_id, score_type, rank_data)
  local logic_rank_guard = require("client.slua.logic.activity.logic_rank_guard")
  logic_rank_guard.GetSelfRankRsp(area_id, score_type, rank_data)
end
function PopularityGiftHandler.send_get_pop_gift_record_req(target_uid)
  NetManager.SendPkg(1222288335, target_uid)
end
function PopularityGiftHandler.on_get_pop_gift_record_rsp(err_code, gift_record, uid, gift_record_summary, pspace_collect)
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  logic_send_gift.get_pop_gift_record_rsp(err_code, gift_record, uid, gift_record_summary, pspace_collect)
end
function PopularityGiftHandler.send_delete_last_trend_record_req(index, id)
  log(bWriteLog and "PopularityGiftHandler.send_delete_last_trend_record_req index = " .. tostring(index) .. ", id = " .. tostring(id))
  NetManager.SendPkg(1818599335, index, id)
end
function PopularityGiftHandler.on_delete_last_trend_record_rsp(err_code, last_trend)
  log(bWriteLog and "PopularityGiftHandler.on_delete_last_trend_record_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  else
    ShowNotice(46099)
  end
  log_tree("PopularityGiftHandler.on_delete_last_trend_record_rsp last_trend", last_trend)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.proc_delete_last_trend_record_rsp(last_trend)
end
function PopularityGiftHandler.send_delete_pspace_rank_record_req(rank_type, uid)
  log(bWriteLog and "PopularityGiftHandler.send_delete_pspace_rank_record_req rank_type = " .. tostring(rank_type) .. ", uid = " .. tostring(uid))
  NetManager.SendPkg(37292839, rank_type, uid)
end
function PopularityGiftHandler.on_delete_pspace_rank_record_rsp(err_code, rank_type, rank)
  log(bWriteLog and "PopularityGiftHandler.on_delete_pspace_rank_record_rsp err_code = " .. tostring(err_code) .. ", rank_type = " .. tostring(rank_type))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  else
    ShowNotice(46099)
  end
  log_tree("PopularityGiftHandler.on_delete_pspace_rank_record_rsp rank", rank)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.proc_delete_pspace_rank_record_rsp(rank_type, rank)
end
function PopularityGiftHandler.send_get_popularity_last_high_value_req(source)
  log(bWriteLog and "PopularityGiftHandler.send_get_popularity_last_high_value_req source = " .. tostring(source))
  NetManager.SendPkg(386081479, source)
end
function PopularityGiftHandler.on_get_popularity_last_high_value_rsp(last_high_value, source)
  log(bWriteLog and "PopularityGiftHandler.on_get_popularity_last_high_value_rsp source = " .. tostring(source))
  log_tree(bWriteLog and "PopularityGiftHandler.on_get_popularity_last_high_value_rsp last_high_valuers", last_high_value)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.get_popularity_last_high_value_rsp(last_high_value, source)
end
function PopularityGiftHandler.on_manor_gift_notify(tips_bin)
  local PlanPH_GiftEffectSystem_Client = SubsystemMgr:Get("PlanPH_GiftEffectSystem_Client")
  if not PlanPH_GiftEffectSystem_Client then
    log(bWriteLog and "PopularityGiftHandler.on_manor_gift_notify not PlanPH_GiftEffectSystem_Client")
    return
  end
  tips_bin = slua.LuaArchiverDecode(LuaStateWrapper, tips_bin)
  log_tree("PopularityGiftHandler.on_manor_gift_notify tips_bin", tips_bin)
  PlanPH_GiftEffectSystem_Client:OnOfflineGiftNotify(tips_bin)
end
function PopularityGiftHandler.on_pspace_send_gift_limit_rsp(err_code, gift_type, gift_count, tip_text_id, params)
  if not tip_text_id then
    log(bWriteLog and "PopularityGiftHandler.on_pspace_send_gift_limit_rsp not text id")
    return
  end
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  logic_send_gift.on_pspace_send_gift_limit_rsp(gift_type, gift_count, tip_text_id, params)
end
function PopularityGiftHandler.send_get_self_daily_pop_gift_req()
  NetManager.SendPkg(167986907)
end
function PopularityGiftHandler.on_get_self_daily_pop_gift_rsp(ret_tbl)
  log_tree("PopularityGiftHandler.on_get_self_daily_pop_gift_rsp ret_tbl = ", ret_tbl)
  local AccountAnchorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.AccountAnchorModule)
  AccountAnchorModule:on_get_self_daily_pop_gift_rsp(ret_tbl)
end
function PopularityGiftHandler.send_query_quick_gift_friends_req()
  NetManager.SendPkg(793110759)
end
function PopularityGiftHandler.on_query_quick_gift_friends_rsp(err_code, friend_list, gift_record_count, daily_max_count)
  log(bWriteLog and "PopularityGiftHandler.on_query_quick_gift_friends_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 and err_code ~= 500064 and err_code ~= 100150049 and err_code ~= 540009 and err_code ~= 500165 then
    return
  end
  log_tree(bWriteLog and "PopularityGiftHandler.on_query_quick_gift_friends_rsp friend_list", friend_list)
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  logic_send_gift:proc_query_quick_gift_friends_rsp(err_code, friend_list, gift_record_count, daily_max_count)
end
function PopularityGiftHandler.send_friends_quick_gift_req(send_list, gift_source)
  NetManager.SendPkg(179310343, send_list, gift_source)
end
function PopularityGiftHandler.on_friends_quick_gift_rsp(err_code, send_list, friends_list, gift_record_count, daily_max_count)
  log(bWriteLog and "PopularityGiftHandler.on_friends_quick_gift_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    if err_code == 540009 then
      ShowNotice(7933)
    end
    return
  end
  log_tree(bWriteLog and "PopularityGiftHandler.on_friends_quick_gift_rsp send_list", send_list)
  log_tree(bWriteLog and "PopularityGiftHandler.on_friends_quick_gift_rsp friends_list", friends_list)
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  logic_send_gift:proc_friends_quick_gift_rsp(err_code, send_list, friends_list, gift_record_count, daily_max_count)
end
function PopularityGiftHandler.on_send_upvote_notify_rsp(sender, reciver, gift_type, name, gift_source, battle_id, upvote_cnt)
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  logic_send_gift:on_send_upvote_notify_rsp(sender, reciver, gift_type, name, gift_source, battle_id, upvote_cnt)
end
function PopularityGiftHandler.send_set_guardian_visable_req(switch)
  NetManager.SendPkg(1132836839, switch)
end
function PopularityGiftHandler.on_set_guardian_visable_rsp(errcode, switch)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.set_guardian_visable_rsp(errcode, switch)
end
return PopularityGiftHandler