local logic_moment_proto = {
  err_moment_param_invalid = 104000001,
  err_moment_day_post_reach_limit = 104000002,
  err_moment_total_post_reach_limit = 104000003,
  err_moment_post_save_failed = 104000004,
  err_moment_not_exist = 104000005,
  err_moment_del_failed = 104000006,
  err_moment_get_data_failed = 104000007,
  err_moment_not_allow_view = 104000008,
  err_moment_ban_post = 104000009,
  err_moment_ban_opt_other = 104000010,
  err_moment_no_data = 104000011,
  err_moment_auth_not_open = 104000012,
  err_moment_no_fri = 104000013,
  err_moment_get_hot_moment_failed = 104000014,
  err_moment_reach_like_limit = 104000015,
  err_moment_is_liked = 104000016,
  err_moment_not_liked = 104000017,
  err_moment_internal_error = 104000018,
  err_moment_reach_max_reply = 104000019,
  err_moment_reply_uid_not_match = 104000020,
  err_moment_ban_all = 104000021,
  err_moment_send_sensitive_words = 104000022,
  err_moment_reply_not_exist = 104000023,
  err_moment_ban_chat = 104000024,
  err_moment_message_load_failed = 104000025,
  err_moment_player_state = 104000026,
  err_moment_level_state = 104000027,
  err_moment_segment_state = 104000028,
  err_moment_not_open = 104000029,
  err_moment_content_len_limit = 104000030,
  err_moment_sys_busy = 104000031,
  err_moment_reach_intimacy_limit = 104000032,
  err_moment_is_not_fri = 104000033,
  err_moment_no_more_data = 104000035
}
local filter_err_list = {
  logic_moment_proto.err_moment_get_data_failed,
  logic_moment_proto.err_moment_not_allow_view,
  logic_moment_proto.err_moment_ban_post,
  logic_moment_proto.err_moment_ban_opt_other,
  logic_moment_proto.err_moment_no_data,
  logic_moment_proto.err_moment_reach_like_limit,
  logic_moment_proto.err_moment_is_liked,
  logic_moment_proto.err_moment_not_liked,
  logic_moment_proto.err_moment_reply_uid_not_match,
  logic_moment_proto.err_moment_player_state
}
function logic_moment_proto.send_get_self_moments_info_req()
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_get_self_moments_info_req()
end
function logic_moment_proto.on_get_self_moments_info_rsp(moment_info, exceed_the_limit)
  log_tree("on_get_self_moments_info_rsp", {moment_info = moment_info, exceed_the_limit = exceed_the_limit})
  local logic_moment = require("client.slua.logic.moment.logic_moment")
  logic_moment.  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local sort_moment_ids = {}
  for id, release_time in pairs(moment_info.moment_ids) do
    table.insert(sort_moment_ids, {moment_id = id, release_time = release_time})
  end
  local logic_moment_helper = require("client.slua.logic.moment.logic_moment_helper")
  logic_moment_helper.SortActiveMessage(sort_moment_ids)
  moment_info.  logic_moment_data.clear_my_del_moment_info()
  logic_moment_data.clear_my_skip_moment_info()
  logic_moment_data.set_my_moment_info(moment_info)
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_GET_MY_MESSAGES)
end
function logic_moment_proto.send_batch_get_moments_summary_req(moment_ids)
  log_tree("send_batch_get_moments_summary_req", moment_ids)
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  local logic_moment = require("client.slua.logic.moment.logic_moment")
  local sourceType = logic_moment.GetSourceType()
  MomentHandler.send_batch_get_moments_summary_req(moment_ids, sourceType)
end
function logic_moment_proto.on_batch_get_moments_summary_rsp(moments_info, failed_moments_id_list)
  log_tree("on_batch_get_moments_summary_rsp", {moments_info = moments_info, failed_moments_id_list = failed_moments_id_list})
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  logic_moment_data.update_all_moments_info(moments_info)
  logic_moment_data.update_failed_moments_id(failed_moments_id_list)
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_GET_SUMMARY)
end
function logic_moment_proto.send_post_moment_req(moment_info)
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_post_moment_req(moment_info)
end
function logic_moment_proto.on_post_moment_rsp()
  ShowNotice(18461)
  local proto = require("client.slua.logic.moment.logic_moment_proto")
  proto.send_get_self_moments_info_req()
end
function logic_moment_proto.send_get_fri_hot_moments_req()
  log(bWriteLog and "logic_moment_proto.send_get_fri_hot_moments_req")
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_get_fri_hot_moments_req()
end
function logic_moment_proto.send_get_wow_hot_moments_req()
  log(bWriteLog and "logic_moment_proto.send_get_wow_hot_moments_req")
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_get_wow_hot_moments_req()
end
function logic_moment_proto.on_get_fri_hot_moments_rsp(hot_moments_info, last_view_timestamp)
  log(bWriteLog and "logic_moment_proto.on_get_fri_hot_moments_rsp")
  log_tree("hot_moment_info", hot_moments_info)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  logic_moment_data.set_hot_moment_info(hot_moments_info)
  local logic_moment_bubble_tips = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_moment_bubble_tips)
  logic_moment_bubble_tips:OnGetLastTimeEnterHotTab(last_view_timestamp)
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_GET_HOT_MESSAGES)
end
function logic_moment_proto.on_get_wow_hot_moments_rsp(hot_wowmoments_info, last_view_timestamp)
  log(bWriteLog and "logic_moment_proto.on_get_wow_hot_moments_rsp")
  log_tree("hot_moment_info", hot_wowmoments_info)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  logic_moment_data.set_wows_hot_moment_info(hot_wowmoments_info)
  local logic_moment_bubble_tips = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_moment_bubble_tips)
  logic_moment_bubble_tips:OnGetLastTimeEnterHotTab(last_view_timestamp)
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_GET_WOW_HOT_MESSAGES)
end
function logic_moment_proto.on_wow_notify_publish_moment(uid, modid)
  print(bWriteLog and "on_wow_notify_publish_moment uid:" .. tostring(uid) .. " modid:" .. tostring(modid))
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:SetAutoSendMomentModID(modid)
end
function logic_moment_proto.send_set_moments_remind_info_read_req(remind_info_idx)
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_set_moments_remind_info_read_req(remind_info_idx)
end
function logic_moment_proto.on_set_moments_remind_info_read_rsp(remind_info_idx)
end
function logic_moment_proto.send_set_all_moments_remind_info_read_req()
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_set_all_moments_remind_info_read_req()
end
function logic_moment_proto.on_set_all_moments_remind_info_read_rsp()
end
function logic_moment_proto.send_do_moment_like_req(moment_id, owner_uid, req_source)
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_do_moment_like_req(moment_id, owner_uid, req_source)
end
function logic_moment_proto.on_do_moment_like_rsp(moment_id, is_first)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local moment_info = logic_moment_data.get_single_moment_info(moment_id)
  if moment_info then
    moment_info.is_like = true
    moment_info.like_num = moment_info.like_num + 1
    local logic_moment_helper = require("client.slua.logic.moment.logic_moment_helper")
    moment_info.like_detail = logic_moment_helper.updateLikeDetailData(moment_info.like_detail, true)
  end
  if is_first then
    local ui_moment_main = UIManager.GetUI(UIManager.UI_Config.MomentMain)
    if ui_moment_main and ui_moment_main:IsShow() then
      UIManager.ShowUI(UIManager.UI_Config.MomentTip, LocUtil.GetLocalizeResStr(18938))
    end
  end
  local MomentDetailSystem = require("client.slua.logic.moment.logic_moment_detail")
  MomentDetailSystem.OnGiveLikeRsp(moment_id, is_first)
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_LIKE_STATUS_CHANGE, moment_id, true)
end
function logic_moment_proto.send_do_moment_unlike_req(moment_id, owner_uid, req_source)
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_do_moment_unlike_req(moment_id, owner_uid, req_source)
end
function logic_moment_proto.on_do_moment_unlike_rsp(moment_id)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local moment_info = logic_moment_data.get_single_moment_info(moment_id)
  if not moment_info then
    return
  end
  moment_info.is_like = false
  moment_info.like_num = moment_info.like_num - 1
  local logic_moment_helper = require("client.slua.logic.moment.logic_moment_helper")
  moment_info.like_detail = logic_moment_helper.updateLikeDetailData(moment_info.like_detail, false)
  local MomentDetailSystem = require("client.slua.logic.moment.logic_moment_detail")
  MomentDetailSystem.OnCancelGiveLike(moment_id)
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_LIKE_STATUS_CHANGE, moment_id, false)
end
function logic_moment_proto.send_do_moment_emoji_like_req(moment_id, owner_uid, emoji_id, req_source)
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_do_moment_emoji_like_req(moment_id, owner_uid, emoji_id, req_source)
end
function logic_moment_proto.on_do_moment_emoji_like_rsp(moment_id, emoji_id)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local moment_info = logic_moment_data.get_single_moment_info(moment_id)
  if not moment_info then
    return
  end
  if emoji_id then
    moment_info.self_    local totalCount = 0
    if not moment_info.emoji_like_cnt then
      moment_info.emoji_like_cnt = {}
    else
      totalCount = moment_info.emoji_like_cnt[emoji_id] or 0
    end
    moment_info.emoji_like_cnt[emoji_id] = totalCount + 1
    log(bWriteLog and "[v_wllwu] logic_moment_proto.on_do_moment_emoji_like_rsp, moment_id is:" .. tostring(moment_id) .. " owner_uid = " .. tostring(moment_info.owner_uid))
    EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_EMOJILIKE_STATUS_CHANGE, moment_id, moment_info.owner_uid)
  end
end
function logic_moment_proto.send_do_moment_emoji_unlike_req(moment_id, owner_uid, req_source)
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_do_moment_emoji_unlike_req(moment_id, owner_uid, req_source)
end
function logic_moment_proto.on_do_moment_emoji_unlike_rsp(moment_id, emoji_id)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local moment_info = logic_moment_data.get_single_moment_info(moment_id)
  if not moment_info then
    log(bWriteLog and "[v_wllwu] on_do_moment_emoji_unlike_rsp moment_info is nil, moment_id is:" .. tostring(moment_id))
    return
  end
  if emoji_id then
    local totalCount = moment_info.emoji_like_cnt and moment_info.emoji_like_cnt[emoji_id]
    if totalCount and 0 < totalCount then
      moment_info.emoji_like_cnt[emoji_id] = totalCount - 1
    end
  end
  moment_info.self_emoji_id = 0
  log(bWriteLog and "[v_wllwu] logic_moment_proto.on_do_moment_emoji_unlike_rsp, moment_id is:" .. tostring(moment_id) .. " owner_uid = " .. tostring(moment_info.owner_uid))
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_EMOJILIKE_STATUS_CHANGE, moment_id, moment_info.owner_uid)
end
function logic_moment_proto.send_moment_reply_req(moment_id, content, reply_idex, mention_uid, owner_uid, req_source, at_uids)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_moment_reply_req(moment_id, content, reply_idex, mention_uid, owner_uid, req_source, at_uids)
end
function logic_moment_proto.on_moment_reply_rsp(moment_id, reply_idex, reply_sub_id, reply_ts, mention_uid, content)
  local MomentDetailSystem = require("client.slua.logic.moment.logic_moment_detail")
  MomentDetailSystem.SendReplyRsp(moment_id, reply_idex, reply_sub_id, reply_ts, mention_uid, content)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local moment_info = logic_moment_data.get_single_moment_info(moment_id)
  if not moment_info then
    return
  end
  logic_moment_data.update_single_moment_info(moment_id, {
    reply_num = moment_info.reply_num + 1
  })
  if reply_sub_id == 1 then
    local logic_moment_helper = require("client.slua.logic.moment.logic_moment_helper")
    local paras = {
      content = content,
      mention_uid = mention_uid,
      reply_ts = reply_ts,
      reply_uid = DataMgr.roleData.uid,
      type = 1
    }
    moment_info.reply_detail = logic_moment_helper.updateCommentDetailData(moment_info.reply_detail, true, paras)
  end
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_COMMENTS_ONECHANGE, moment_id, true)
end
function logic_moment_proto.send_del_moment_reply_req(moment_id, reply_idex, reply_sub_id, owner_uid, req_source)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_del_moment_reply_req(moment_id, reply_idex, reply_sub_id, owner_uid, req_source)
end
function logic_moment_proto.on_del_moment_reply_rsp(moment_id, reply_idex, reply_sub_id)
  log(bWriteLog and "logic_moment_proto.on_del_moment_reply_rsp reply id" .. tostring(reply_idex))
  local MomentDetailSystem = require("client.slua.logic.moment.logic_moment_detail")
  local logic_moment_helper = require("client.slua.logic.moment.logic_moment_helper")
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local moment_info = logic_moment_data.get_single_moment_info(moment_id)
  logic_moment_data.update_single_moment_info(moment_id, {
    reply_num = moment_info.reply_num - 1
  })
  if reply_sub_id == 1 then
    local reply_detail = moment_info.reply_detail
    local mm = MomentDetailSystem.FindMoment(moment_id)
    local del_idx, replace_idx
    if not mm.comments then
      return
    end
    for index, value in pairs(mm.comments) do
      if value.reply_index_id and value.reply_index_id == reply_idex then
        del_idx = index
      else
        replace_idx = index
      end
      if del_idx and replace_idx then
        break
      end
    end
    if del_idx and mm.comments[del_idx] then
      log(bWriteLog and "logic_moment_proto.on_del_moment_reply_rsp del_id" .. tostring(del_idx) .. " replace_idx" .. tostring(replace_idx))
      local bNeedUpdateDetail = false
      if reply_detail and reply_detail[1] then
        bNeedUpdateDetail = mm.comments[del_idx].reply_ts == reply_detail[1].reply_ts and mm.comments[del_idx].content == reply_detail[1].content
      else
        bNeedUpdateDetail = true
      end
      if bNeedUpdateDetail then
        local newValid = replace_idx and mm.comments[replace_idx]
        local paras = newValid and {
          content = mm.comments[replace_idx].content,
          mention_uid = mm.comments[replace_idx].mention_uid,
          reply_ts = mm.comments[replace_idx].reply_ts,
          reply_uid = mm.comments[replace_idx].reply_uid,
          type = 1
        } or nil
        moment_info.reply_detail = logic_moment_helper.updateCommentDetailData(moment_info.reply_detail, false, paras)
      end
    else
      log(bWriteLog and "logic_moment_proto.on_del_moment_reply_rsp failed to find deleted commont idx" .. tostring(reply_idex))
    end
  end
  MomentDetailSystem.DeleteReplyRsp(moment_id, reply_idex, reply_sub_id)
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_COMMENTS_ONECHANGE, moment_id, false)
end
function logic_moment_proto.send_get_moment_reply_req(moment_id, start_reply_idx, start_sub_reply_idx, source, direct)
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_get_moment_reply_req(moment_id, start_reply_idx, start_sub_reply_idx, source, direct)
end
function logic_moment_proto.on_get_moment_reply_rsp(moment_id, reply_info, start_reply_idx, start_sub_reply_idx, source, direct)
  local MomentDetailSystem = require("client.slua.logic.moment.logic_moment_detail")
  MomentDetailSystem.GetHistoryReplysRsp(moment_id, reply_info, start_reply_idx, start_sub_reply_idx, source, direct)
end
function logic_moment_proto.on_get_moment_reply_err(res)
  logic_moment_proto.ShowErrorCodeTips(res)
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_REFRESH_MOMENT_COMMENTS, res)
end
function logic_moment_proto.send_del_moment_req(moment_id)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_del_moment_req(moment_id)
end
function logic_moment_proto.on_del_one_moment_rsp(moment_id)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  logic_moment_data.del_single_moment_info(moment_id)
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_DELETE_ONE_MOMENT, moment_id)
end
function logic_moment_proto.send_get_fri_recent_moments_req()
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_get_fri_recent_moments_req()
end
function logic_moment_proto.on_get_fri_recent_moments_rsp(recent_moments_info, last_view_timestamp)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  table.sort(recent_moments_info, function(a, b)
    return a.post_ts > b.post_ts
  end)
  local moment_info_list = {}
  for _, v in pairs(recent_moments_info) do
    local logic_friend = require("client.slua.logic.friend.logic_new_friend")
    local isFriend = logic_friend.IsMyFriend(v.uid)
    if isFriend then
      table.insert(moment_info_list, v)
    else
      log(bWriteLog and "logic_moment_proto.on_get_fri_recent_moments_rsp not friend uid:" .. tostring(v.uid))
    end
  end
  logic_moment_data.set_fri_recent_moment_info(moment_info_list)
  local logic_moment_bubble_tips = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_moment_bubble_tips)
  logic_moment_bubble_tips:OnGetLastTimeEnterFriendTab(last_view_timestamp)
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_FRIEND_MESSAGES)
end
function logic_moment_proto.send_get_moment_detail_req(moment_id)
  log(bWriteLog and "[v_yibxu] MomentHandler.send_get_moment_detail_req")
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_get_moment_detail_req(moment_id)
end
function logic_moment_proto.on_get_moment_detail_rsp(moment_id, one_moment_info)
  log(bWriteLog and "[v_yibxu] MomentHandler.on_get_moment_detail_rsp")
  local MomentDetailSystem = require("client.slua.logic.moment.logic_moment_detail")
  MomentDetailSystem.GetMomentDetailInfoRsp(moment_id, one_moment_info)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local momentInfo = logic_moment_data.get_moment_info(moment_id)
  if momentInfo ~= nil then
    logic_moment_data.update_single_moment_info(moment_id, {
      like_num = momentInfo.like_num,
      reply_num = momentInfo.reply_num,
      self_emoji_id = momentInfo.self_emoji_id,
      emoji_like_cnt = momentInfo.emoji_like_cnt
    })
  end
end
function logic_moment_proto.on_get_moment_detail_err(res)
  logic_moment_proto.ShowErrorCodeTips(res)
  if res == logic_moment_proto.err_moment_not_exist then
    EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_NO_EXIST_MESSAGES)
  end
  UIManager.CloseUI(UIManager.UI_Config.MomentDetail)
end
function logic_moment_proto.send_get_user_moments_id_req(target_uid)
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_get_user_moments_id_req(target_uid)
end
function logic_moment_proto.on_get_user_moments_id_rsp(target_uid, moment_ids, is_banned)
  log(bWriteLog and "v_ywuyuan on_get_user_moments_id_rsp:" .. tostring(target_uid) .. " " .. tostring(is_banned))
  log_tree("on_get_user_moments_id_rsp", moment_ids)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  logic_moment_data.set_other_people_moment_info(target_uid, moment_ids, is_banned)
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_GET_OTHER_PERSON_MESSAGES)
end
function logic_moment_proto.on_get_user_moments_id_err(res, target_uid)
  if res ~= 0 then
    log(bWriteLog and "v_ywuyuan on_get_user_moments_id_rsp " .. tostring(res))
  end
  if res == logic_moment_proto.err_moment_ban_all then
    logic_moment_proto.on_get_user_moments_id_rsp(target_uid, {}, true)
  elseif res == logic_moment_proto.err_moment_auth_not_open then
    EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_NO_PRIVILEGE)
  else
    logic_moment_proto.ShowErrorCodeTips(res)
  end
end
function logic_moment_proto.on_notify_moments_message(message_num, message_info, deleted_index)
  log(bWriteLog and "v_ywuyuan" .. tostring(message_num) .. "deleted_index:" .. tostring(deleted_index))
  log_tree("v_ywuyuan on_notify_moments_message message_info", message_info)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local message_info_list = logic_moment_data.get_moment_remind_info()
  if message_info_list == nil then
    return
  end
  if deleted_index then
    message_info_list[deleted_index] = nil
  end
  message_info_list[message_num] = message_info
  logic_moment_data.set_moment_remind_info(message_info_list)
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_MESSAGES_REFRESH_UI, 1)
end
function logic_moment_proto.send_update_moments_messages_req(type, num)
  log(bWriteLog and "[v_ywuyuan] send_update_moments_messages_req type:" .. tostring(type) .. " num:" .. tostring(num))
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_update_moments_messages_req(type, num)
end
function logic_moment_proto.on_update_moments_messages_rsp(type, num)
  log(bWriteLog and "[v_ywuyuan] on_update_moments_messages_rsp type:" .. tostring(type) .. " num:" .. tostring(num))
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local message_info = logic_moment_data.get_moment_remind_info()
  if message_info == nil then
    return
  end
  if num == -1 then
    for k, v in pairs(message_info) do
      v.status = 0
    end
  else
    local info = message_info[tostring(num)]
    if info then
      info.status = 0
    end
  end
  logic_moment_data.set_moment_remind_info(message_info)
  local logic_moment_helper = require("client.slua.logic.moment.logic_moment_helper")
  logic_moment_helper.MergeMomentRemindInfo()
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_MESSAGES_REFRESH_UI, 1)
end
function logic_moment_proto.send_delete_moments_messages_req()
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_delete_moments_messages_req()
end
function logic_moment_proto.on_delete_moments_messages_rsp(deleted_index)
  log_tree("deleted_index", deleted_index)
  local logic_moment = require("client.slua.logic.moment.logic_moment")
  logic_moment.DeleteReadRemindInfo(deleted_index)
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_MESSAGES_REFRESH_UI, 1)
end
function logic_moment_proto.send_get_moments_red_point_req()
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_get_moments_red_point_req()
end
function logic_moment_proto.on_get_moments_red_point_rsp(has_new_fri_moments, has_new_fri_msgs)
  local moment_reddot_data = require("client.slua.logic.moment.moment_reddot_data")
  moment_reddot_data.UpdateMomentRedPointData(has_new_fri_moments, has_new_fri_msgs)
end
function logic_moment_proto.send_set_moments_red_point_req(type)
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_set_moments_red_point_req(type)
end
function logic_moment_proto.on_set_moments_red_point_rsp(type)
  local moment_reddot_data = require("client.slua.logic.moment.moment_reddot_data")
  moment_reddot_data.ClearRedPointDataByType(type)
end
function logic_moment_proto.send_get_all_moments_messages_req()
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_get_all_moments_messages_req()
end
function logic_moment_proto.on_get_all_moments_messages_rsp(like_messages, reply_messages, emoji_like_messages, been_at_messages)
  like_messages = like_messages or {}
  reply_messages = reply_messages or {}
  log_tree(bWriteLog and "[v_ywuyuan] on_get_all_moments_messages_rsp like_messages", like_messages)
  log_tree(bWriteLog and "[v_ywuyuan] on_get_all_moments_messages_rsp reply_messages", reply_messages)
  log_tree(bWriteLog and "[v_wllwu] on_get_all_moments_messages_rsp, emoji_like_messages:", emoji_like_messages)
  log_tree(bWriteLog and "[dongkaizha] on_get_all_moments_messages_rsp, emoji_like_messages:", been_at_messages)
  local logic_moment_helper = require("client.slua.logic.moment.logic_moment_helper")
  local message_info = logic_moment_helper.WrapRemindInfoFromMessages(like_messages, reply_messages, emoji_like_messages, been_at_messages)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  logic_moment_data.set_moment_remind_info(message_info)
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_MESSAGES_REFRESH_UI, 1)
end
function logic_moment_proto.send_set_moment_switch_req(set_info)
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_set_moment_switch_req(set_info)
end
function logic_moment_proto.on_set_moment_switch_rsp(set_info)
  local moment_cfg = require("client.slua.logic.moment.moment_cfg")
  moment_cfg.UpdatePlayerMomentSettings(set_info)
end
function logic_moment_proto.send_square_moment_list_req(page_no)
  log(bWriteLog and "[v_ywuyuan] page_no " .. tostring(page_no))
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_square_moment_list_req(page_no)
end
function logic_moment_proto.on_square_moment_list_rsp(square_moment_list, page_no)
  log(bWriteLog and "[v_ywuyuan] on_square_moment_list_rsp" .. tostring(page_no))
  log_tree("square_moment_list", square_moment_list)
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  if page_no == 1 then
    logic_moment_data.set_square_moment_info({})
  end
  local temp_moment_list = logic_moment_data.get_square_moment_info() or {}
  local add_moment_list = {}
  for i, v1 in ipairs(square_moment_list) do
    local bRepeat = false
    for _, v2 in ipairs(temp_moment_list) do
      if tonumber(v1.moment_id) == tonumber(v2.moment_id) and tonumber(v1.uid) == tonumber(v1.uid) then
        bRepeat = true
        break
      end
    end
    if bRepeat == false then
      add_moment_list[#add_moment_list + 1] = v1
    end
  end
  for i, v in ipairs(add_moment_list) do
    temp_moment_list[#temp_moment_list + 1] = v
  end
  local logic_square_moment = require("client.slua.logic.moment.logic_square_moment")
  logic_square_moment.set_cur_page_no(page_no)
  logic_moment_data.set_square_moment_info(temp_moment_list)
  local uiEventType
  if page_no == 1 then
    uiEventType = 1
  else
    uiEventType = 2
  end
  local logic_moment_bubble_tips = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_moment_bubble_tips)
  logic_moment_bubble_tips:UpdateIsGetSquareList()
  EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_GET_SQUARE_MESSAGES, uiEventType)
end
function logic_moment_proto.on_square_moment_list_rsp_err(err, page_no)
  log(bWriteLog and "[v_ywuyuan] err, page_no" .. tostring(err) .. " " .. tostring(page_no))
  if err == logic_moment_proto.err_moment_no_more_data then
    local logic_square_moment = require("client.slua.logic.moment.logic_square_moment")
    logic_square_moment.set_max_page(page_no)
    EventSystem:postEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_GET_SQUARE_MESSAGES, 3)
  else
    logic_moment_proto.ShowErrorCodeTips(err)
  end
end
function logic_moment_proto.IsFilterErrCode(err_code)
  for i, v in ipairs(filter_err_list) do
    if v == err_code then
      return true
    end
  end
  return false
end
function logic_moment_proto.ShowErrorCodeTips(res)
  if res ~= 0 then
    log(bWriteLog and "[v_ywuyuan] res: " .. tostring(res))
    if res == logic_moment_proto.err_moment_level_state or res == logic_moment_proto.err_moment_segment_state then
      local moment_cfg = require("client.slua.logic.moment.moment_cfg")
      moment_cfg.ShowLevelTips(res)
      return
    elseif res == logic_moment_proto.err_moment_reply_not_exist then
      ShowNotice(18944)
      return
    elseif logic_moment_proto.IsFilterErrCode(res) then
      return
    end
    ShowNotice(res)
  end
end
return logic_moment_proto