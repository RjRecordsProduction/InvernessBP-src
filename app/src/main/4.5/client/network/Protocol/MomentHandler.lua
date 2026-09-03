local NetManager = require("client.network.comm.NetManager")
local MomentHandler = {}
function MomentHandler.send_moment_reply_req(moment_id, content, reply_idex, mention_uid, owner_uid, req_source, at_uids)
  NetManager.SendPkg(595803687, moment_id, content, reply_idex, mention_uid, owner_uid, req_source, at_uids)
end
function MomentHandler.on_moment_reply_rsp(res, moment_id, reply_idex, reply_sub_id, reply_ts, mention_uid, content)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_moment_reply_rsp(moment_id, reply_idex, reply_sub_id, reply_ts, mention_uid, content)
end
function MomentHandler.send_del_moment_reply_req(moment_id, reply_idex, reply_sub_id, owner_uid, req_source)
  log(bWriteLog and "MomentHandler.send_del_moment_reply_req mid" .. tostring(moment_id) .. " rid" .. tostring(reply_idex) .. " " .. tostring(reply_sub_id) .. " oid" .. tostring(owner_uid))
  NetManager.SendPkg(324593511, moment_id, reply_idex, reply_sub_id, owner_uid, req_source)
end
function MomentHandler.on_del_moment_reply_rsp(res, moment_id, reply_idex, reply_sub_id)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_del_moment_reply_rsp(moment_id, reply_idex, reply_sub_id)
end
function MomentHandler.send_get_moment_reply_req(moment_id, start_reply_idx, start_sub_reply_idx, source, direct)
  NetManager.SendPkg(253321703, moment_id, start_reply_idx, start_sub_reply_idx, source, direct)
end
function MomentHandler.on_get_moment_reply_rsp(res, moment_id, reply_info, start_reply_idx, start_sub_reply_idx, source, direct)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.on_get_moment_reply_err(res)
    return
  end
  logic_moment_proto.on_get_moment_reply_rsp(moment_id, reply_info, start_reply_idx, start_sub_reply_idx, source, direct)
end
function MomentHandler.send_set_moment_switch_req(set_info)
  NetManager.SendPkg(810253339, set_info)
end
function MomentHandler.on_set_moment_switch_rsp(res, set_info)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_set_moment_switch_rsp(set_info)
end
function MomentHandler.send_post_moment_req(moment_info)
  log(bWriteLog and "MomentHandler.send_post_moment_req")
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  NetManager.SendPkg(2118378671, moment_info)
end
function MomentHandler.on_post_moment_rsp(res, moment_id, exceed_the_limit)
  log(bWriteLog and "on_post_moment_rsp:" .. tostring(moment_id) .. ",exceed_the_limit:" .. tostring(exceed_the_limit))
  local logic_moment = require("client.slua.logic.moment.logic_moment")
  logic_moment.  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  local ShareMgr = require("client.logic.share.share_logic")
  if ShareMgr.HasSponsorAward() then
    local ShareHandler = require("client.network.Protocol.ShareHandler")
    ShareHandler.send_client_sponsor_award_req(1)
  end
  logic_moment_proto.on_post_moment_rsp()
end
function MomentHandler.send_get_moment_background_data_req()
  log(bWriteLog and "MomentHandler.send_get_moment_background_data_req")
  NetManager.SendPkg(1345605415)
end
function MomentHandler.on_get_moment_background_data_rsp(res, background_cfg, moment_background, last_moment_background_id)
  log(bWriteLog and "MomentHandler.on_get_moment_background_data_rsp res = " .. res)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  log_tree("background_cfg = ", background_cfg)
  log_tree("moment_background = ", moment_background)
  log_tree("last_moment_background_id = ", last_moment_background_id)
  local logic_moment_background = require("client.slua.logic.moment.logic_moment_background")
  logic_moment_background.proc_get_moment_background_data_rsp(background_cfg, moment_background, last_moment_background_id)
end
function MomentHandler.send_set_moment_background_flag_req(background_id)
  log(bWriteLog and "MomentHandler.send_set_moment_background_flag_req background_id = " .. background_id)
  NetManager.SendPkg(1493246055, background_id)
end
function MomentHandler.on_set_moment_background_flag_rsp(res, background_id)
  log(bWriteLog and "MomentHandler.on_set_moment_background_flag_rsp res = " .. res .. ", background_id = " .. background_id)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local logic_moment_background = require("client.slua.logic.moment.logic_moment_background")
  logic_moment_background.proc_set_moment_background_flag_rsp(background_id)
end
function MomentHandler.on_notify_new_moment_background_red_point()
  log(bWriteLog and "MomentHandler.on_notify_new_moment_background_red_point")
  local logic_moment_background = require("client.slua.logic.moment.logic_moment_background")
  logic_moment_background.proc_notify_new_moment_background_red_point()
  MomentHandler.send_get_moment_background_data_req()
end
function MomentHandler.send_del_moment_req(moment_id)
  NetManager.SendPkg(169440098, moment_id)
end
function MomentHandler.on_del_one_moment_rsp(res, moment_id)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_del_one_moment_rsp(moment_id)
end
function MomentHandler.send_batch_get_moments_summary_req(moment_ids, source)
  NetManager.SendPkg(337536723, moment_ids, source)
end
function MomentHandler.on_batch_get_moments_summary_rsp(res, moments_info, failed_moments_id_list)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_batch_get_moments_summary_rsp(moments_info, failed_moments_id_list)
end
function MomentHandler.send_get_moment_detail_req(moment_id)
  NetManager.SendPkg(1530791151, moment_id)
end
function MomentHandler.on_get_moment_detail_rsp(res, moment_id, one_moment_info)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.on_get_moment_detail_err(res)
    return
  end
  logic_moment_proto.on_get_moment_detail_rsp(moment_id, one_moment_info)
end
function MomentHandler.send_do_moment_like_req(moment_id, owner_uid, req_source)
  NetManager.SendPkg(1136689991, moment_id, owner_uid, req_source)
end
function MomentHandler.on_do_moment_like_rsp(res, moment_id, is_first)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    if res ~= logic_moment_proto.err_moment_reach_intimacy_limit then
      return
    end
  end
  logic_moment_proto.on_do_moment_like_rsp(moment_id, is_first)
end
function MomentHandler.send_get_fri_recent_moments_req()
  log(bWriteLog and "MomentHandler.send_get_fri_recent_moments_req")
  NetManager.SendPkg(1859983943)
end
function MomentHandler.on_get_fri_recent_moments_rsp(res, recent_moments_info, last_view_timestamp)
  log(bWriteLog and "MomentHandler.on_get_fri_recent_moments_rsp res = " .. res .. ", last_view_timestamp = " .. tostring(last_view_timestamp))
  log_tree("recent_moments_info = ", recent_moments_info)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_get_fri_recent_moments_rsp(recent_moments_info, last_view_timestamp)
end
function MomentHandler.send_get_fri_hot_moments_req()
  NetManager.SendPkg(1140030315)
end
function MomentHandler.on_get_fri_hot_moments_rsp(res, hot_moments_info, last_view_timestemp)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_get_fri_hot_moments_rsp(hot_moments_info, last_view_timestemp)
end
function MomentHandler.send_do_moment_unlike_req(moment_id, owner_uid, req_source)
  NetManager.SendPkg(811291431, moment_id, owner_uid, req_source)
end
function MomentHandler.on_do_moment_unlike_rsp(res, moment_id)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_do_moment_unlike_rsp(moment_id)
end
function MomentHandler.send_set_moments_remind_info_read_req(remind_info_idx)
  NetManager.SendPkg(1455058919, remind_info_idx)
end
function MomentHandler.on_set_moments_remind_info_read_rsp(res, remind_info_idx)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_set_moments_remind_info_read_rsp(remind_info_idx)
end
function MomentHandler.send_set_all_moments_remind_info_read_req()
  NetManager.SendPkg(723225063)
end
function MomentHandler.on_set_all_moments_remind_info_read_rsp(res)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_set_all_moments_remind_info_read_rsp()
end
function MomentHandler.send_get_self_moments_info_req()
  NetManager.SendPkg(1657947051)
end
function MomentHandler.on_get_self_moments_info_rsp(res, moment_info, exceed_the_limit)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_get_self_moments_info_rsp(moment_info, exceed_the_limit)
end
function MomentHandler.send_get_user_moments_id_req(target_uid)
  NetManager.SendPkg(312452467, target_uid)
end
function MomentHandler.on_get_user_moments_id_rsp(res, target_uid, moment_ids)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.on_get_user_moments_id_err(res, target_uid)
    return
  end
  logic_moment_proto.on_get_user_moments_id_rsp(target_uid, moment_ids, false)
end
function MomentHandler.on_notify_moments_message(res, message_num, message_info, deleted_index)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_notify_moments_message(message_num, message_info, deleted_index)
end
function MomentHandler.send_update_moments_messages_req(type, num)
  NetManager.SendPkg(458976083, type, num)
end
function MomentHandler.on_update_moments_messages_rsp(res, type, num)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_update_moments_messages_rsp(type, num)
end
function MomentHandler.send_delete_moments_messages_req()
  log(bWriteLog and "MomentHandler.send_delete_moments_messages_req")
  NetManager.SendPkg(2038382627)
end
function MomentHandler.on_delete_moments_messages_rsp(res, deleted_index)
  log(bWriteLog and "MomentHandler.on_delete_moments_messages_rsp res = " .. res)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_delete_moments_messages_rsp(deleted_index)
end
function MomentHandler.send_get_moments_red_point_req()
  log(bWriteLog and "MomentHandler.send_get_moments_red_point_req")
  NetManager.SendPkg(801817543)
end
function MomentHandler.on_get_moments_red_point_rsp(res, has_new_fri_moments, has_new_fri_msgs)
  log(bWriteLog and "MomentHandler.on_get_moments_red_point_rsp res = " .. res .. ", has_new_fri_moments = " .. tostring(has_new_fri_moments) .. ", has_new_fri_msgs = " .. tostring(has_new_fri_msgs))
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_get_moments_red_point_rsp(has_new_fri_moments, has_new_fri_msgs)
end
function MomentHandler.send_set_moments_red_point_req(type)
  log(bWriteLog and "MomentHandler.send_set_moments_red_point_req type = " .. tostring(type))
  NetManager.SendPkg(1381563799, type)
end
function MomentHandler.on_set_moments_red_point_rsp(res, type)
  log(bWriteLog and "MomentHandler.on_set_moments_red_point_rsp res = " .. res .. ", type = " .. tostring(type))
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_set_moments_red_point_rsp(type)
end
function MomentHandler.send_get_all_moments_messages_req()
  log(bWriteLog and "MomentHandler.send_get_all_moments_messages_req")
  NetManager.SendPkg(806579431)
end
function MomentHandler.on_get_all_moments_messages_rsp(res, like_messages, reply_messages, emoji_like_messages, been_at_messages)
  log(bWriteLog and "MomentHandler.on_get_all_moments_messages_rsp res = " .. res)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_get_all_moments_messages_rsp(like_messages, reply_messages, emoji_like_messages, been_at_messages)
end
function MomentHandler.send_square_moment_list_req(page_no)
  log(bWriteLog and "MomentHandler.send_square_moment_list_req page_no = " .. tostring(page_no))
  NetManager.SendPkg(1248752487, page_no)
end
function MomentHandler.on_square_moment_list_rsp(err, square_moment_list, page_no)
  log(bWriteLog and "MomentHandler.on_square_moment_list_rsp err = " .. tostring(err) .. ", page_no = " .. tostring(page_no))
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if err ~= 0 then
    logic_moment_proto.on_square_moment_list_rsp_err(err, page_no)
    return
  end
  logic_moment_proto.on_square_moment_list_rsp(square_moment_list, page_no)
end
function MomentHandler.send_report_view_moments_req(view_module_index_list)
  log(bWriteLog and "MomentHandler.send_report_view_moments_req view_module_index_list")
  NetManager.SendPkg(354649307, view_module_index_list)
end
function MomentHandler.on_report_view_moments_rsp(res, record_time)
  log(bWriteLog and "MomentHandler.on_report_view_moments_rsp res = " .. res .. ", record_time = " .. tostring(record_time))
  local logic_moment_bubble_tips = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_moment_bubble_tips)
  logic_moment_bubble_tips:OnReportViewMomentsRsp(res, record_time)
end
function MomentHandler.send_get_new_square_moments_num_req()
  log(bWriteLog and "MomentHandler.send_get_new_square_moments_num_req")
  NetManager.SendPkg(1437711943)
end
function MomentHandler.on_get_new_square_moments_num_rsp(res, count)
  log(bWriteLog and "MomentHandler.on_get_new_square_moments_num_rsp res = " .. res .. ", count = " .. tostring(count))
  local logic_moment_bubble_tips = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_moment_bubble_tips)
  logic_moment_bubble_tips:OnGetNewSquareNumRsp(res, count)
end
function MomentHandler.send_set_moment_bubble_req(bubble_id)
  log(bWriteLog and "MomentHandler.send_set_moment_bubble_req bubble_id = " .. tostring(bubble_id))
  NetManager.SendPkg(573640699, bubble_id)
end
function MomentHandler.on_set_moment_bubble_rsp(res, bubble_id)
  log(bWriteLog and "MomentHandler.on_set_moment_bubble_rsp res = " .. res .. ", bubble_id = " .. tostring(bubble_id))
  local logic_moment_bubble_tips = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_moment_bubble_tips)
  logic_moment_bubble_tips:OnRemoveTipsTips(res, bubble_id)
end
function MomentHandler.send_do_moment_emoji_like_req(moment_id, owner_uid, emoji_id, req_source)
  log(bWriteLog and "[v_wllwu] MomentHandler.send_do_moment_emoji_like_req, moment_id:" .. tostring(moment_id) .. " emoji_id:" .. tostring(emoji_id) .. " req_source:" .. tostring(req_source))
  NetManager.SendPkg(854327975, moment_id, owner_uid, emoji_id, req_source)
end
function MomentHandler.on_do_moment_emoji_like_rsp(err_code, moment_id, emoji_id)
  log(bWriteLog and "[v_wllwu] MomentHandler.on_do_moment_emoji_like_rsp, err_code is:" .. tostring(err_code) .. " moment_id is:" .. tostring(moment_id) .. " emoji_id is:" .. tostring(emoji_id))
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if err_code ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(err_code)
    return
  end
  logic_moment_proto.on_do_moment_emoji_like_rsp(moment_id, emoji_id)
end
function MomentHandler.send_do_moment_emoji_unlike_req(moment_id, owner_uid, req_source)
  NetManager.SendPkg(430991495, moment_id, owner_uid, req_source)
end
function MomentHandler.on_do_moment_emoji_unlike_rsp(err_code, moment_id, emoji_id)
  log(bWriteLog and "[v_wllwu] MomentHandler.on_do_moment_emoji_unlike_rsp, err_code is:" .. tostring(err_code) .. " moment_id is:" .. tostring(moment_id) .. " emoji_id is:" .. tostring(emoji_id))
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if err_code ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(err_code)
    return
  end
  logic_moment_proto.on_do_moment_emoji_unlike_rsp(moment_id, emoji_id)
end
function MomentHandler.send_get_wow_hot_moments_req()
  NetManager.SendPkg(1845428499)
end
function MomentHandler.on_get_wow_hot_moments_rsp(res, hot_moments_info, last_view_timestemp)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  if res ~= 0 then
    logic_moment_proto.ShowErrorCodeTips(res)
    return
  end
  logic_moment_proto.on_get_wow_hot_moments_rsp(hot_moments_info, last_view_timestemp)
end
function MomentHandler.on_wow_notify_publish_moment(uid, mod_id)
  local logic_moment_proto = require("client.slua.logic.moment.logic_moment_proto")
  logic_moment_proto.on_wow_notify_publish_moment(uid, mod_id)
end
return MomentHandler