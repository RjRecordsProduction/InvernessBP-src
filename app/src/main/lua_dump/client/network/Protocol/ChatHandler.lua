local NetManager = require("client.network.comm.NetManager")
local ChatHandler = {}
function ChatHandler.send_get_all_offmsg_req(type)
  NetManager.SendPkg(1133008551, type)
end
function ChatHandler.on_get_all_offmsg_rsp(offmsg_list)
  local ESportSquadSystem = require("client.slua.logic.esport.logic_esport_squad")
  ESportSquadSystem.OnGetAllOffmsgRsp(offmsg_list)
end
function ChatHandler.send_get_offline_chat_msg_count_req()
  NetManager.SendPkg(2117014375)
end
function ChatHandler.on_get_offline_chat_msg_count_rsp(msg, count)
  local channelFriend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  channelFriend.on_get_offline_chat_msg_count(msg, count)
end
function ChatHandler.send_topic_fetch_lang_list_req(source)
  log(bWriteLog and "ChatHandler.send_topic_fetch_lang_list_req source:" .. tostring(source))
  NetManager.SendPkg(114745291, source)
end
function ChatHandler.on_topic_fetch_lang_list_rsp(list, timeSpan, source)
  local tb = {
    list = list,
    timeSpan = timeSpan,
      }
  log_tree(bWriteLog and "ChatHandler.on_topic_fetch_lang_list_rsp tb:", tb)
  local channelWorld = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  channelWorld.topic_fetch_lang_list_rsp(list, timeSpan, source)
end
function ChatHandler.send_open_chat_ui(isopen)
  NetManager.SendPkg(889104076, isopen)
end
function ChatHandler.on_open_chat_ui_rsp(chatCfgTable)
  if not chatCfgTable or type(chatCfgTable) ~= "table" or not next(chatCfgTable) then
    return
  end
  log(bWriteLog and "on_open_chat_ui_rsp chatCfgTable:", chatCfgTable)
  local channelMain = require("client.slua.logic.lobby_chat.logic_chat_main")
  channelMain.SetMaxChatContentLen(chatCfgTable.max_chat_content_len)
  channelMain.SetVoiceMsgOpenLv(chatCfgTable.voice_msg_open_level)
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  logic_chat_channel_world.SetChannelOpenLv(chatCfgTable.world_chat_open_level)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  logic_chat_channel_chat_room.SetChatRoomCfg(chatCfgTable.create_channel_level, chatCfgTable.max_create_channel_cnt, chatCfgTable.max_user_cnt_per_channel)
end
function ChatHandler.send_topic_flat_list_req(languageList)
  NetManager.SendPkg(878657371, languageList)
end
function ChatHandler.on_topic_flat_list_rsp(msg, list)
  local tb = {msg = msg, list = list}
  log_tree(bWriteLog and "ChatHandler.on_topic_flat_list_rsp tb:", tb)
  local channelWorld = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  channelWorld.topic_flat_list_rsp(msg, list)
end
function ChatHandler.on_chat_notify(chat_type, sender_name, msg_id, chat_content, sender_uid, nation)
  printf("ChatHandler.on_chat_notify chat_type=%s, sender_name=%s, msg_id=%s, chat_content=%s, sender_uid=%s, nation=%s", chat_type, sender_name, msg_id, chat_content, sender_uid, nation)
  local logic_profile_security = require("client.slua.logic.profile.logic_profile_security")
  sender_name = logic_profile_security.ProcChat(sender_uid, sender_name, chat_content)
  local logic_chat_cache = require("client.slua.logic.lobby_chat.logic_chat_cache")
  logic_chat_cache.cache_chat_notify(chat_type, sender_name, msg_id, chat_content, sender_uid, nation)
  local channelMain = require("client.slua.logic.lobby_chat.logic_chat_main")
  channelMain.chat_notify(chat_type, sender_name, msg_id, chat_content, sender_uid, nation)
end
function ChatHandler.on_chat_merge_notify(merge_world_chat, is_history)
  printf("ChatHandler.on_chat_merge_notify merge_world_chat=%s, is_history=%s", merge_world_chat, is_history)
  local logic_chat_cache = require("client.slua.logic.lobby_chat.logic_chat_cache")
  logic_chat_cache.cache_chat_merge_notify(merge_world_chat, is_history)
  local channelMain = require("client.slua.logic.lobby_chat.logic_chat_main")
  channelMain.chat_merge_notify(merge_world_chat, is_history)
end
function ChatHandler.send_chat_req(uid, channelType, msgId, tabContent)
  local xmissionUI = UIManager.GetUI(UIManager.UI_Config.xmission_main)
  tabContent.bInTlobby = xmissionUI ~= nil
  log(bWriteLog and "ChatHandler.send_chat_req bInTlobby = " .. tostring(tabContent.bInTlobby))
  local NicknameColorManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NicknameColorManager)
  local NicknameColor = NicknameColorManager:GetUserData(DataMgr.roleData.uid)
  if NicknameColor ~= NicknameColorManager.DEFAULT_PLAN_ID then
    log(bWriteLog and "ChatHandler.send_chat_req  NicknameColor = " .. tostring(NicknameColor))
    tabContent.  end
  if GameStatus.IsInMainCity() then
    tabContent.sceneType = "MainCity"
  end
  printf("ChatHandler.send_chat_req uid=%s,channelType=%s,msgId=%s,bInTlobby=%s,", uid, channelType, msgId, tabContent.bInTlobby)
  NetManager.SendPkg(1735709991, uid, channelType, msgId, tabContent)
end
function ChatHandler.on_chat_rsp(res, msg_id, chat_type, surplus, receiver_gid, chat_content, ext_info)
  printf("ChatHandler.on_chat_rsp res=%s,msg_id=%s,chat_type=%s,surplus=%s,receiver_gid=%s,chat_content=%s,ext_info=%s", res, msg_id, chat_type, surplus, receiver_gid, chat_content, ext_info)
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local tabContent = logic_chat_main.msgContentCacheMap[msg_id]
  local logic_chat_cache = require("client.slua.logic.lobby_chat.logic_chat_cache")
  logic_chat_cache.cache_chat_rsp(res, msg_id, chat_type, surplus, receiver_gid, chat_content, ext_info, tabContent)
  local channelMain = require("client.slua.logic.lobby_chat.logic_chat_main")
  channelMain.on_chat_rsp(res, msg_id, chat_type, surplus, receiver_gid, chat_content, ext_info)
end
function ChatHandler.send_get_offline_chat_msg_req()
  log(bWriteLog and "ChatHandler.send_get_offline_chat_msg_req")
  NetManager.SendPkg(1271970727)
end
function ChatHandler.on_get_offline_chat_msg_rsp(msg)
  log(bWriteLog and "ChatHandler.on_get_offline_chat_msg_rsp")
  local channelFriend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  channelFriend.on_get_offline_chat_msg(msg)
end
function ChatHandler.send_topic_unsubscribe_req()
  NetManager.SendPkg(1946301623)
end
function ChatHandler.on_topic_unsubscribe_rsp(tid, msg)
  local channelWorld = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  channelWorld.topic_unsubscribe_rsp(tid, msg)
end
function ChatHandler.send_topic_subscribe_req(tid)
  log(bWriteLog and "ChatHandler.send_topic_subscribe_req tid " .. tostring(tid))
  NetManager.SendPkg(861164787, tid)
end
function ChatHandler.on_topic_subscribe_rsp(tid, msg)
  log(bWriteLog and "ChatHandler.on_topic_subscribe_rsp tid = " .. tostring(tid))
  log(bWriteLog and "ChatHandler.on_topic_subscribe_rsp msg = " .. tostring(msg))
  local channelWorld = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  channelWorld.topic_subscribe_rsp(tid, msg)
end
function ChatHandler.on_chat_clear_msg(gid)
  local channelMain = require("client.slua.logic.lobby_chat.logic_chat_main")
  channelMain.ClearSomeonesMsg(gid)
end
function ChatHandler.send_filter_text_req(text, context)
  NetManager.SendPkg(410222403, text, context)
end
function ChatHandler.on_filter_text_rsp(filter_text, context)
  IngameChat:on_filter_finish(filter_text, context)
end
function ChatHandler.on_topic_send_at_notify(send_uid, chat_content)
end
function ChatHandler.send_open_world_and_team_recruit_req(switch)
  NetManager.SendPkg(262889379, switch)
end
function ChatHandler.on_open_world_and_team_recruit_rsp(res, switch)
  log(bWriteLog and "god test on_open_world_and_team_recruit_rsp " .. tostring(res) .. " switch " .. tostring(switch))
end
function ChatHandler.send_report_info(securityLog)
  NetManager.SendPkg(523590044, securityLog)
end
function ChatHandler.on_report_info(res)
  local ChatMenuSystem = require("client.slua.logic.lobby_chat.logic_chat_menu")
  ChatMenuSystem.on_report_rsp(res)
end
function ChatHandler.send_report_player_voice_status_in_team(lastTLogTime, openVoiceDt, openMicDt, isVoiceOpen, isMicOpen)
  NetManager.SendPkg(1753800026, lastTLogTime, openVoiceDt, openMicDt, isVoiceOpen, isMicOpen)
end
function ChatHandler.send_chat_translate_req(to, key, msg_id)
  log(bWriteLog and "ChatHandler.send_chat_translate_req to:" .. tostring(to) .. ", key:" .. tostring(key) .. ", msg_id:" .. tostring(msg_id))
  NetManager.SendPkg(1004987879, to, key, msg_id)
end
function ChatHandler.on_chat_translate_rsp(ret_code, msg_id, from, to, trans_key, trans_value)
  log(bWriteLog and "ChatHandler.on_chat_translate_rsp ret_code:" .. tostring(ret_code) .. ", msg_id:" .. tostring(msg_id) .. ", from:" .. tostring(from) .. ", to:" .. tostring(to) .. ", trans_key:" .. tostring(trans_key) .. ", trans_value: " .. tostring(trans_value))
  local TranslateMgr = require("client.slua.logic.translator.translate_mgr")
  TranslateMgr.OnGetTranslateViaServer(ret_code, msg_id, from, to, trans_key, trans_value)
end
function ChatHandler.send_chat_tog_report_req(uid, reciever_id, chat_content)
  NetManager.SendPkg(398701877, uid, reciever_id, chat_content)
end
function ChatHandler.send_report_translate_ping(ping, from, to, method)
  NetManager.SendPkg(1477285570, ping, from, to, method)
end
function ChatHandler.send_report_info_mic(securityLog)
  log(bWriteLog and "send_report_info_mic")
  if slua.isValid(CGameState) and CGameState.IsCreativeMode and CGameState:IsCreativeMode() then
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    if LogicUGCMatch then
      local tUGCMatchInfo = LogicUGCMatch:GetCurrentMatchInfoForFight()
      if tUGCMatchInfo then
        securityLog.nUGCModID = tUGCMatchInfo.mod_id or 0
        log(bWriteLog and "nUGCModID = " .. tostring(securityLog.nUGCModID))
      else
        log(bWriteLog and "tUGCMatchInfo nil")
      end
    else
      log(bWriteLog and "LogicUGCMatch nil")
    end
  else
    log(bWriteLog and "not creative mode")
  end
  NetManager.SendPkg(622042252, securityLog)
end
function ChatHandler.on_report_info_mic(res)
end
function ChatHandler.send_arabic_switch_channel_report(chat_type, chat_content, is_switch_channel)
  NetManager.SendPkg(1499415138, chat_type, chat_content, is_switch_channel)
end
function ChatHandler.send_ReportHawkeyeBanFlow(nReportedPlayerUID, nReportReason)
  NetManager.SendPkg(1345216445, nReportedPlayerUID, nReportReason)
end
function ChatHandler.send_chat_translate_with_filter_req(to, trans_key, msg_id, filter_context)
  NetManager.SendPkg(1802516967, to, trans_key, msg_id, filter_context)
end
function ChatHandler.on_chat_translate_with_filter_rsp(ret_code, msg_id, from, to, trans_key, trans_value, filter_context)
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_RECEIVE_TRANSLATE_MSG, ret_code, msg_id, from, to, trans_key, trans_value, filter_context)
end
function ChatHandler.on_metro_chat_shield_expired_ntfy(expired_time, label, percent)
  local channelMain = require("client.slua.logic.lobby_chat.logic_chat_main")
  channelMain.on_metro_chat_shield_expired_ntfy(expired_time, label, percent)
end
function ChatHandler.send_subscribe_world_cup_req(game_seq)
  log(bWriteLog and "send_subscribe_world_cup_req game_seq = " .. tostring(game_seq))
  NetManager.SendPkg(1534226459, game_seq)
end
function ChatHandler.on_subscribe_world_cup_rsp(err_code, game_seq, topic_id)
  log(bWriteLog and "on_subscribe_world_cup_rsp err_code = " .. err_code .. ", game_seq" .. game_seq .. ", topic_id" .. topic_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_world_cup_chat = require("client.slua.logic.lobby_chat.world_cup.logic_world_cup_chat")
  logic_world_cup_chat.on_subscribe_world_cup_rsp(game_seq, topic_id)
end
function ChatHandler.send_leave_world_cup_act_page()
  log(bWriteLog and "send_leave_world_cup_act_page")
  NetManager.SendPkg(1915097504)
end
function ChatHandler.send_set_player_recruit_langs_req(langs)
  log_tree(bWriteLog and "[v_wllwu] ChatHandler.send_set_player_recruit_langs_req, langs is:", langs)
  NetManager.SendPkg(1344172647, langs)
end
function ChatHandler.on_set_player_recruit_langs_rsp(err_code, langs)
  log_tree(bWriteLog and "[v_wllwu] ChatHandler.on_set_player_recruit_langs_rsp, langs is:", langs)
  local logic_chat_filter_language = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_filter_language)
  logic_chat_filter_language:OnSetRecruitLangsRsp(err_code, langs)
end
function ChatHandler.send_search_team_recruit_req(condition, search_reason)
  log_tree(bWriteLog and "[v_wllwu] ChatHandler.send_search_team_recruit_req, condition is:", condition)
  NetManager.SendPkg(1128809271, condition, search_reason)
end
function ChatHandler.on_search_team_recruit_rsp(err_code, msg_list)
  local logic_chat_recruit_msg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_recruit_msg)
  logic_chat_recruit_msg:OnSearchTeamRecruitDataRsp(err_code, msg_list)
end
function ChatHandler.send_social_voice_audit_callback(jwt_token)
  NetManager.SendPkg(1201228654, jwt_token)
end
function ChatHandler.send_get_chat_manor_list_req()
  log(bWriteLog and "ChatHandler.send_get_chat_manor_list_req")
  NetManager.SendPkg(1746708531)
end
function ChatHandler.on_get_chat_manor_list_rsp(err, response)
  local tb = {err = err, response = response}
  log_tree(bWriteLog and "ChatHandler.on_get_chat_manor_list_rsp:", tb)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_chat_manor_topic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_manor_topic)
  logic_chat_manor_topic:on_get_chat_manor_list_rsp(response)
end
function ChatHandler.on_metro_chat_shield_expired_list_ntfy(labelTb, shieldPercentTb)
  log_tree(bWriteLog and "ChatHandler.on_metro_chat_shield_expired_list_ntfy labelTb:", labelTb)
  local channelMain = require("client.slua.logic.lobby_chat.logic_chat_main")
  channelMain.on_metro_chat_shield_expired_list_ntfy(labelTb, shieldPercentTb)
end
function ChatHandler.send_share_pre_filter_text_req(share_type, share_text)
  log(bWriteLog and "on_share_pre_filter_text_rsp share_type = " .. tostring(share_type))
  log_tree(bWriteLog and "ChatHandler.send_share_pre_filter_text_req:share_text = ", share_text)
  NetManager.SendPkg(1683847787, share_type, share_text)
end
function ChatHandler.on_share_pre_filter_text_rsp(err_code, share_type, share_text)
  log(bWriteLog and "on_share_pre_filter_text_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    if err_code == 116200001 then
      ShowNotice(20220914)
      EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_IS_SAFE_MESSAGE, false)
    end
    if err_code == 116200002 then
    end
    return
  end
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_IS_SAFE_MESSAGE, true)
end
function ChatHandler.send_poke_friend_req(fri_uid)
  NetManager.SendPkg(2067855355, fri_uid)
end
function ChatHandler.on_poke_friend_rsp(err, fri_uid, is_recent_frd)
  log(bWriteLog and "ChatHandler.on_poke_friend_rsp" .. tostring(err))
  log(bWriteLog and "ChatHandler.on_poke_friend_rsp fri_uid" .. tostring(fri_uid))
  log(bWriteLog and "ChatHandler.on_poke_friend_rsp is_recent_frd" .. tostring(is_recent_frd))
  local logic_poke = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_poke)
  logic_poke:on_poke_friend_rsp(err, fri_uid, is_recent_frd)
end
function ChatHandler.send_daily_poke_list_req()
  NetManager.SendPkg(394493459)
end
function ChatHandler.on_daily_poke_list_rsp(err, poke_frd_list, bepoke_frd_list)
  log(bWriteLog and "ChatHandler.on_daily_poke_list_rsp " .. tostring(err))
  if err ~= 0 then
    return
  end
  log_tree(bWriteLog and "[v_yunjxiang] ChatHandler.on_daily_poke_list_rsp, poke_frd_list:", poke_frd_list)
  log_tree(bWriteLog and "[v_yunjxiang] ChatHandler.on_daily_poke_list_rsp, bepoke_frd_list:", bepoke_frd_list)
  local logic_poke = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_poke)
  logic_poke:on_daily_poke_list_rsp(poke_frd_list, bepoke_frd_list)
end
function ChatHandler.send_no_fri_poke_list_req(fri_uid)
  NetManager.SendPkg(1367583975, fri_uid)
end
function ChatHandler.on_no_fri_poke_list_rsp(err, poke_frd_list, bepoke_frd_list)
  log(bWriteLog and "ChatHandler.on_no_fri_poke_list_rsp " .. tostring(err))
  if err ~= 0 then
    return
  end
  log_tree(bWriteLog and "[v_yunjxiang] ChatHandler.on_no_fri_poke_list_rsp, poke_frd_list:", poke_frd_list)
  log_tree(bWriteLog and "[v_yunjxiang] ChatHandler.on_no_fri_poke_list_rsp, bepoke_frd_list:", bepoke_frd_list)
  local logic_poke = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_poke)
  logic_poke:on_no_fri_poke_list_rsp(poke_no_frd_list, bepoke_no_frd_list)
end
function ChatHandler.on_frd_poke_notify(frd_uid, is_recent_frd)
  log(bWriteLog and "ChatHandler.on_frd_poke_notify frd_uid" .. tostring(frd_uid))
  log(bWriteLog and "ChatHandler.on_frd_poke_notify is_recent_frd" .. tostring(is_recent_frd))
  local logic_poke = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_poke)
  logic_poke:on_frd_poke_notify(frd_uid, is_recent_frd)
end
function ChatHandler.send_get_interact_info_req(frd_uid)
  log(bWriteLog and "ChatHandler.send_get_interact_info_req: frd_uid " .. tostring(frd_uid))
  NetManager.SendPkg(837066931, frd_uid)
end
function ChatHandler.on_get_interact_info_rsp(err, frd_uid, frd_interact_info, record_list, interact_reward_limit_data, limit_num)
  log(bWriteLog and "ChatHandler.on_get_interact_info_rsp: code " .. tostring(err) .. " frd_uid " .. tostring(frd_uid))
  if err ~= 0 then
    return
  end
  log_tree(bWriteLog and "[v_yunjxiang] ChatHandler.on_get_interact_info_rsp, frd_interact_info", frd_interact_info)
  log_tree(bWriteLog and "[v_yunjxiang] ChatHandler.on_get_interact_info_rsp, record_list:", record_list)
  log_tree(bWriteLog and "[dongkaizha] ChatHandler.on_get_interact_info_rsp, reward_limit_data", interact_reward_limit_data)
  log(bWriteLog and "[dongkaizha] ChaChatHandler.on_get_interact_info_rsp, limit_num" .. tostring(limit_num))
  local logic_interaction = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_interaction)
  logic_interaction:on_get_interact_info_rsp(frd_uid, frd_interact_info, record_list, interact_reward_limit_data, limit_num)
end
function ChatHandler.send_get_interact_score_reward_req(reward_idx, frd_uid)
  log(bWriteLog and "ChatHandler.send_get_interact_score_reward_req:" .. tostring(frd_uid) .. " reward_idx " .. tostring(reward_idx))
  NetManager.SendPkg(456765867, reward_idx, frd_uid)
end
function ChatHandler.on_get_interact_score_reward_rsp(err_code, frd_uid, reward_idx, res_list)
  log(bWriteLog and "ChatHandler.on_get_interact_score_reward_rsp, errcode: " .. tostring(err_code) .. ", frd_uid: " .. tostring(frd_uid) .. ", reward_idx: " .. tostring(reward_idx))
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
  log_tree(res_list)
  local logic_interaction = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_interaction)
  logic_interaction:on_get_interact_score_reward_rsp(err_code, frd_uid, reward_idx, res_list)
end
function ChatHandler.on_interact_key_event_notify(frd_uid, change_type, value, para1, para2, weekSummaryInfo)
  log(bWriteLog and "ChatHandler.on_interact_key_event_notify frd_uid = " .. frd_uid .. ", change_type = " .. change_type .. ", value = " .. value .. ", para1 = " .. tostring(para1) .. ", para2 = " .. tostring(para2))
  log_tree("weekSummaryInfo = ", weekSummaryInfo)
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  logic_friend_list:proc_interact_key_event_notify(frd_uid, change_type, value, para1, para2, weekSummaryInfo)
  local logic_interaction = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_interaction)
  logic_interaction:on_interact_key_event_notify(frd_uid, change_type, value, para1, para2)
end
function ChatHandler.send_get_frd_interact_info_req(frd_uid, target_uid)
  NetManager.SendPkg(850674375, frd_uid, target_uid)
end
function ChatHandler.on_get_frd_interact_info_rsp(res, target_uid, frd_interact_info, user_data, interact_reward_limit_data, cfg_limit, frd_uid)
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  logic_person_relation:on_get_frd_interact_info_rsp(res, target_uid, frd_interact_info, user_data, interact_reward_limit_data, cfg_limit, frd_uid)
end
function ChatHandler.send_set_frd_chat_background_req(frd_uid, set_id, set_type)
  log(bWriteLog and "ChatHandler.send_set_frd_chat_background_req frd_uid" .. tostring(frd_uid) .. " set_id" .. tostring(set_id) .. " set_type" .. tostring(set_type))
  NetManager.SendPkg(709874647, frd_uid, set_id, set_type)
end
function ChatHandler.on_set_frd_chat_background_rsp(err, frd_uid, chat_background_id)
  log(bWriteLog and "ChatHandler.on_set_frd_chat_background_rsp err" .. tostring(err) .. " frd_uid" .. tostring(frd_uid) .. " chat_background_id" .. tostring(chat_background_id))
  if err == 0 then
    ShowNotice(410004)
  else
    ShowNotice(err)
  end
end
return ChatHandler