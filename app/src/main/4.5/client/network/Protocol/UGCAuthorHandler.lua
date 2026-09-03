local NetManager = require("client.network.comm.NetManager")
local UGCAuthorHandler = {}
function UGCAuthorHandler.send_ugc_get_other_user_pub_mod_req(other_uid)
  log(bWriteLog and "UGCAuthorHandler.send_ugc_get_other_user_pub_mod_req")
  NetManager.SendPkg(154125639, other_uid)
end
function UGCAuthorHandler.on_ugc_get_other_user_pub_mod_rsp(err_code, all_meta_key, other_uid)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_get_other_user_pub_mod_rsp other_uid:" .. tostring(other_uid))
  log_tree("UGCAuthorHandler.on_ugc_get_other_user_pub_mod_rsp all_meta_key", all_meta_key)
  local LogicUGCAuthorGuest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthorGuest)
  LogicUGCAuthorGuest:on_ugc_get_other_user_pub_mod_rsp(all_meta_key, other_uid)
end
function UGCAuthorHandler.send_ugc_get_author_req(author_uid)
  log(bWriteLog and "UGCAuthorHandler.send_ugc_get_author_req")
  NetManager.SendPkg(1406584519, author_uid)
end
function UGCAuthorHandler.on_ugc_get_author_rsp(err_code, author_uid, author, tb, ugc_author_info_ext)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_get_author_rsp err_code = " .. tostring(err_code) .. ", author_uid = " .. tostring(author_uid))
  log_tree("UGCAuthorHandler.on_ugc_get_author_rsp tb = ", tb)
  if err_code ~= 0 and err_code == 511201 then
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CUSTOM_PRESENTATION_EMPTY_WOW_AUTHOR)
  end
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  LogicUGCAuthor:SetAuthorInfo(author_uid, author, tb, ugc_author_info_ext)
end
function UGCAuthorHandler.send_ugc_author_summary_req(author_uid)
  if not author_uid or not tonumber(author_uid) then
    log(bWriteLog and "UGCAuthorHandler.send_ugc_author_summary_req no author_uid")
    return
  end
  author_uid = tonumber(author_uid)
  log(bWriteLog and "UGCAuthorHandler.send_ugc_author_summary_req author_uid = " .. tostring(author_uid))
  NetManager.SendPkg(687533127, author_uid)
end
function UGCAuthorHandler.on_ugc_author_summary_rsp(err_code, author_uid, result, tb, ugc_privacy_setting)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_author_summary_rsp err_code = " .. tostring(err_code) .. ", author_uid = " .. tostring(author_uid))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("UGCAuthorHandler.on_ugc_author_summary_rsp, result = ", result)
  log_tree("UGCAuthorHandler.on_ugc_author_summary_rsp, tb = ", tb)
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  local LogicUGCAuthorGuest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthorGuest)
  if tb and tb.follow_status then
    LogicUGCAuthor:SetAuthorFollowStatus(author_uid, tb.follow_status)
  end
  if author_uid then
    if author_uid == tonumber(DataMgr.roleData.uid) then
      LogicUGCAuthor:SetMyAuthorSummaryData(result)
    else
      LogicUGCAuthorGuest:SetAuthorSummaryData(result, author_uid)
    end
  end
  LogicUGCAuthorGuest:ProcAuthorModInfoSummary(author_uid, result.mod_info_summary)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_AUTHOR_SUMMARY_RSP, author_uid, result, ugc_privacy_setting)
end
function UGCAuthorHandler.send_ugc_player_update_follow_list_req(operate_type, author_uid, modid)
  log(bWriteLog and "UGCAuthorHandler.send_ugc_player_update_follow_list_req  operate_type = " .. tostring(operate_type) .. ", author_uid = " .. tostring(author_uid))
  NetManager.SendPkg(162264635, operate_type, author_uid, modid)
end
function UGCAuthorHandler.on_ugc_player_update_follow_list_rsp(err_code, operate_type, author_uid)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_player_update_follow_list_rsp err_code = " .. tostring(err_code) .. ", operate_type = " .. tostring(operate_type) .. ", author_uid = " .. tostring(author_uid))
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  if err_code == 513003 then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_EXCEED_FOLLOW_LIMIT, author_uid)
    return
  elseif err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  LogicUGCAuthor:ProcPlayerUpdateFollowListRsp(operate_type, author_uid)
end
function UGCAuthorHandler.send_ugc_get_player_follow_author_list_req()
  NetManager.SendPkg(1436180919)
end
function UGCAuthorHandler.on_ugc_get_player_follow_author_list_rsp(err_code, max_follow_num, follow_list)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_get_player_follow_author_list_rsp err_code = " .. tostring(err_code) .. ", max_follow_num = " .. tostring(max_follow_num))
  log_tree("UGCAuthorHandler.on_ugc_get_player_follow_author_list_rsp, follow_list = ", follow_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  LogicUGCAuthor:ProcGetFollowListRsp(max_follow_num, follow_list)
end
function UGCAuthorHandler.send_ugc_get_follow_author_meta_key_req()
  NetManager.SendPkg(1723471623)
end
function UGCAuthorHandler.on_ugc_get_follow_author_meta_key_rsp(err_code, follow_key_list, ugc_history_play_list)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_get_follow_author_meta_key_rsp err_code = " .. tostring(err_code))
  log_tree("UGCAuthorHandler.on_ugc_get_follow_author_meta_key_rsp follow_key_list = ", follow_key_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  local logic_ugc_mine = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mine)
  logic_ugc_mine:SetFollowData(follow_key_list)
end
function UGCAuthorHandler.send_ugc_get_friend_author_meta_key_req(friend_author_uids)
  log_tree("UGCAuthorHandler.send_ugc_get_friend_author_meta_key_req = ", friend_author_uids)
  NetManager.SendPkg(766079527, friend_author_uids)
end
function UGCAuthorHandler.on_ugc_get_friend_author_meta_key_rsp(err_code, friend_key_list, ugc_history_play_list)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_get_friend_author_meta_key_rsp err_code = " .. tostring(err_code))
  log_tree("UGCAuthorHandler.on_ugc_get_follow_author_meta_key_rsp friend_key_list = ", friend_key_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  local logic_ugc_mine = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mine)
  logic_ugc_mine:SetFriendData(friend_key_list)
end
function UGCAuthorHandler.send_ugc_display_friend_req()
  log(bWriteLog and "UGCAuthorHandler.send_ugc_display_friend_req.")
  NetManager.SendPkg(2011588967)
end
function UGCAuthorHandler.on_ugc_display_friend_rsp(err_code, display_friend)
  log(bWriteLog and string.format("UGCAuthorHandler.on_ugc_display_friend_rsp. err_code=%s", tostring(err_code)))
  log_tree("UGCAuthorHandler.on_ugc_display_friend_rsp display_friend = ", display_friend)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  logic_ugc_mode:proc_ugc_display_friend_rsp(display_friend)
end
function UGCAuthorHandler.send_ugc_get_other_all_meta_key_req(other_uid)
  log(bWriteLog and "UGCAuthorHandler.send_ugc_get_other_all_meta_key_req")
  NetManager.SendPkg(372711143, other_uid)
end
function UGCAuthorHandler.on_ugc_get_other_all_meta_key_rsp(retcode, other_uid, playData, privacyData)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_get_other_all_meta_key_rsp retcode = " .. tostring(retcode))
  if retcode ~= 0 then
    return
  end
  if other_uid == tonumber(DataMgr.roleData.uid) then
    local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
    LogicSettingBasic.RspUGCSetPrivacy(privacyData)
  end
  if playData and playData.mod_collection_data and next(playData.mod_collection_data) then
    local LogicUGCCollectionList = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCollectionList)
    LogicUGCCollectionList:CacheCollectionDataList(playData.mod_collection_data)
  end
  local logic_ugc_playlevel = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_playlevel)
  logic_ugc_playlevel:RspGetPrivacy(other_uid, playData, privacyData)
end
function UGCAuthorHandler.send_ugc_get_other_follow_author_list_req(other_follow_uids)
  log_tree("UGCAuthorHandler.send_ugc_get_other_follow_author_list_req other_follow_uids = ", other_follow_uids)
  NetManager.SendPkg(1200406823, other_follow_uids)
end
function UGCAuthorHandler.on_ugc_get_other_follow_author_list_rsp(err_code, dataList)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_get_other_follow_author_list_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("UGCAuthorHandler.on_ugc_get_other_follow_author_list_rsp dataList = ", dataList)
  local logic_ugc_follow_author = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_follow_author)
  logic_ugc_follow_author:on_ugc_get_other_follow_author_list_rsp(dataList)
end
function UGCAuthorHandler.send_ugc_author_level_get_award_info_req()
  NetManager.SendPkg(392041067)
end
function UGCAuthorHandler.on_ugc_author_level_get_award_info_rsp(err_code, award_config, state, condition)
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  LogicUGCAuthor:RspAuthorAwardInfo(award_config, state, condition)
end
function UGCAuthorHandler.send_ugc_author_level_award_req()
  NetManager.SendPkg(1192823047)
end
function UGCAuthorHandler.on_ugc_author_level_award_rsp(err_code, level, award, state)
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  LogicUGCAuthor:RspGetAuthorAward(level, state, award)
end
function UGCAuthorHandler.send_ugc_author_level_get_ex_award_info_req()
  NetManager.SendPkg(1311515271)
end
function UGCAuthorHandler.on_ugc_author_level_get_ex_award_info_rsp(err_code, award_config, state, condition)
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  LogicUGCAuthor:RspAuthorExAwardInfo(award_config, state, condition)
end
function UGCAuthorHandler.send_ugc_author_level_ex_award_req()
  NetManager.SendPkg(1160579843)
end
function UGCAuthorHandler.on_ugc_author_level_ex_award_rsp(err_code, level, award, state)
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  LogicUGCAuthor:RspGetExAuthorAward(level, state, award)
end
function UGCAuthorHandler.send_ugc_play_level_get_award_info_req()
  log(bWriteLog and "[v_yibxu] RoleInfoHandler.send_ugc_play_level_get_award_info_req")
  NetManager.SendPkg(565403367)
end
function UGCAuthorHandler.on_ugc_play_level_get_award_info_rsp(err_code, level, exp, award)
  log(bWriteLog and "RoleInfoHandler.on_ugc_play_level_get_award_info_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_playlevel = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_playlevel)
  logic_ugc_playlevel:RspGetPlayLevelAwardInfo(level, exp, award)
end
function UGCAuthorHandler.send_ugc_play_level_award_req(level)
  NetManager.SendPkg(977707047, level)
end
function UGCAuthorHandler.on_ugc_play_level_award_rsp(err_code, level, exp, items, award)
  log(bWriteLog and "RoleInfoHandler.on_ugc_play_level_award_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    if err_code == 100000005 then
      UGCAuthorHandler.send_ugc_play_level_get_award_info_req()
      ShowNotice(730006)
    else
      ShowNotice(err_code)
    end
    return
  end
  local logic_ugc_playlevel = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_playlevel)
  logic_ugc_playlevel:RspGetPlayLevelAward(level, exp, items, award)
end
function UGCAuthorHandler.on_ugc_play_level_ntf(level, exp, award)
  local logic_ugc_playlevel = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_playlevel)
  logic_ugc_playlevel:PlayLevelNtf(level, exp, award)
end
function UGCAuthorHandler.on_notify_author_data_change(ugc_author_info)
  log(bWriteLog and "UGCAuthorHandler.on_notify_author_data_change")
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  LogicUGCAuthor:NotifyAuthorInfoChange(ugc_author_info)
end
function UGCAuthorHandler.send_wow_get_author_homepage_req(author_uid)
  log(bWriteLog and "UGCAuthorHandler.send_wow_get_author_homepage_req author_uid = " .. tostring(author_uid))
  NetManager.SendPkg(816980223, author_uid)
end
function UGCAuthorHandler.on_wow_get_author_homepage_rsp(err, author_uid, new_homepage_data)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  log(bWriteLog and "UGCAuthorHandler.on_wow_get_author_homepage_rsp author_uid = " .. tostring(author_uid))
  log_tree("UGCAuthorHandler.on_wow_get_author_homepage_rsp new_homepage_data = ", new_homepage_data)
  local Logic_UGC_AuthorHome = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_authorhome)
  Logic_UGC_AuthorHome:RspAuthorHomePageData(author_uid, new_homepage_data)
end
function UGCAuthorHandler.send_wow_get_author_homepage_support_info_req(author_uid)
  log(bWriteLog and "UGCAuthorHandler.send_wow_get_author_homepage_support_info_req author_uid = " .. tostring(author_uid))
  NetManager.SendPkg(1688205415, author_uid)
end
function UGCAuthorHandler.on_wow_get_author_homepage_support_info_rsp(err, author_uid, wow_author_homepage_support_info)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  log(bWriteLog and "UGCAuthorHandler.on_wow_get_author_homepage_support_info_rsp author_uid = " .. tostring(author_uid))
  log_tree("UGCAuthorHandler.on_wow_get_author_homepage_support_info_rsp wow_author_homepage_support_info = ", wow_author_homepage_support_info)
  local Logic_UGC_AuthorHome = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_authorhome)
  Logic_UGC_AuthorHome:RspAuthorHomePageSupportInfo(author_uid, wow_author_homepage_support_info)
end
function UGCAuthorHandler.send_wow_modify_author_homepage_req(modify_data)
  log_tree("UGCAuthorHandler.send_wow_modify_author_homepage_req modify_data = ", modify_data)
  NetManager.SendPkg(1245918695, modify_data)
end
function UGCAuthorHandler.on_wow_modify_author_homepage_rsp(err, new_homepage_data)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  log_tree("UGCAuthorHandler.on_wow_modify_author_homepage_rsp new_homepage_data = ", new_homepage_data)
  local Logic_UGC_AuthorHome = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_authorhome)
  Logic_UGC_AuthorHome:RspModifyData(new_homepage_data)
end
function UGCAuthorHandler.send_wow_support_author_homepage_req(author_uid)
  log(bWriteLog and "UGCAuthorHandler.send_wow_support_author_homepage_req author_uid = " .. tostring(author_uid))
  NetManager.SendPkg(185937331, author_uid)
end
function UGCAuthorHandler.on_wow_support_author_homepage_rsp(err)
  log(bWriteLog and "UGCAuthorHandler.on_wow_support_author_homepage_rsp")
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_AUTHORHOME_SUPPORTINFO_BACK, err)
end
function UGCAuthorHandler.send_wow_get_author_homepage_support_count_req(author_uid)
  log(bWriteLog and "UGCAuthorHandler.send_wow_get_author_homepage_support_count_req author_uid = " .. tostring(author_uid))
  NetManager.SendPkg(338224767, author_uid)
end
function UGCAuthorHandler.on_wow_get_author_homepage_support_count_rsp(err, author_uid, support_count)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  log(bWriteLog and "UGCAuthorHandler.on_wow_get_author_homepage_support_count_rsp author_uid = " .. tostring(author_uid) .. " support_count = " .. tostring(support_count))
  local Logic_UGC_AuthorHome = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_authorhome)
  Logic_UGC_AuthorHome:RspAuthorSupportInfo(author_uid, support_count)
end
function UGCAuthorHandler.send_ugc_get_general_button_switch_req()
  NetManager.SendPkg(1241712967)
  log(bWriteLog and "UGCAuthorHandler.send_ugc_get_general_button_switch_req ")
end
function UGCAuthorHandler.on_ugc_get_general_button_switch_rsp(err_code, button_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("UGCAuthorHandler.on_ugc_get_general_button_switch_rsp || button_data = ", button_data)
  local LogicUGCCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
  LogicUGCCenter:OnCreatorForumStateRsp(button_data)
end
function UGCAuthorHandler.send_ugc_get_author_progress_req()
  log(bWriteLog and "UGCAuthorHandler.send_ugc_get_author_progress_req ")
  NetManager.SendPkg(1815520379)
end
function UGCAuthorHandler.on_ugc_get_author_progress_rsp(notify_list)
  log_tree("UGCAuthorHandler.on_ugc_get_author_progress_rsp notify_list = ", notify_list)
  if notify_list and next(notify_list) then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    LogicUGC.author_progress = notify_list
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GETAUTHORPROGRESS_RSP)
end
function UGCAuthorHandler.send_ugc_clear_author_progress_notify_req(id)
  NetManager.SendPkg(1032014503, id)
end
function UGCAuthorHandler.on_ugc_clear_author_progress_notify_rsp(err_code)
end
function UGCAuthorHandler.send_ugc_friend_v2_realtime_req()
  NetManager.SendPkg(724056423)
end
function UGCAuthorHandler.on_ugc_friend_v2_realtime_rsp(friend_uid_list)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_friend_v2_realtime_rsp  friend_uid_list = ")
  log_tree("UGCAuthorHandler.on_ugc_friend_v2_realtime_rsp friend_uid_list", friend_uid_list)
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  logic_ugc_mode:FriendPlayingRsp(friend_uid_list)
  local logic_ugc_mine = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mine)
  logic_ugc_mine:SetFriendPlayData(friend_uid_list)
end
function UGCAuthorHandler.send_wow_author_push_audit_req(mod_id_verify, req_src)
  log(bWriteLog and "UGCAuthorHandler.send_wow_author_push_audit_req mod_id_verify = " .. tostring(mod_id_verify) .. " req_src = " .. req_src)
  NetManager.SendPkg(526629651, mod_id_verify, req_src)
end
function UGCAuthorHandler.on_wow_author_push_audit_rsp(err, author_info)
  log_tree("UGCAuthorHandler.on_wow_author_push_audit_rsp err = ", err)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  log_tree("UGCAuthorHandler.on_wow_author_push_audit_rsp author_info = ", author_info)
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  LogicUGCAuthor:UpdateMineAuthorInfo(author_info)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_AUTHOR, DataMgr.roleData.uid)
  ShowNotice(8801039)
end
function UGCAuthorHandler.on_ugc_frd_game_result_notify(from_uid, mod_id, outcome)
  if not (from_uid and mod_id) or not outcome then
    log(bWriteLog and "UGCAuthorHandler.on_ugc_frd_game_result_notify error !")
  end
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  logic_ugc_mode:FriendWinRsp(from_uid, mod_id, outcome)
end
function UGCAuthorHandler.send_ugc_apply_crystal_incentive_req()
  log(bWriteLog and "UGCAuthorHandler.send_ugc_apply_crystal_incentive_req")
  NetManager.SendPkg(1441983495)
end
function UGCAuthorHandler.on_ugc_apply_crystal_incentive_rsp(err_code)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CRYSTALINCENTIVE_APPLY)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_apply_crystal_incentive_rsp")
end
function UGCAuthorHandler.send_ugc_crystal_benefit_overview_req()
  log(bWriteLog and "UGCAuthorHandler.send_ugc_crystal_benefit_overview_req")
  NetManager.SendPkg(1311918951)
end
function UGCAuthorHandler.on_ugc_crystal_benefit_overview_rsp(err_code, trans_data, rsp_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCCrystalIncentive = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_crystal_incentive)
  LogicUGCCrystalIncentive:RspCrystalBenefitOverview(trans_data, rsp_data)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_crystal_benefit_overview_rsp")
end
function UGCAuthorHandler.send_ugc_crystal_benefit_details_req(api_name, page, size)
  log(bWriteLog and "UGCAuthorHandler.send_ugc_crystal_benefit_details_req api_name = " .. tostring(api_name) .. " page = " .. tostring(page) .. " size = " .. tostring(size))
  NetManager.SendPkg(236270663, api_name, page, size)
end
function UGCAuthorHandler.on_ugc_crystal_benefit_details_rsp(err_code, trans_data, rsp_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCCrystalIncentive = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_crystal_incentive)
  LogicUGCCrystalIncentive:RspCrystalBenefitDetails(trans_data, rsp_data)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_crystal_benefit_details_rsp")
end
function UGCAuthorHandler.send_ugc_mod_crystal_benefit_req(mod_id, page, size)
  log(bWriteLog and "UGCAuthorHandler.send_ugc_mod_crystal_benefit_req mod_id = " .. tostring(mod_id) .. " page = " .. tostring(page) .. " size = " .. tostring(size))
  NetManager.SendPkg(2098475287, mod_id, page, size)
end
function UGCAuthorHandler.on_ugc_mod_crystal_benefit_rsp(err_code, trans_data, rsp_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCCrystalIncentive = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_crystal_incentive)
  LogicUGCCrystalIncentive:RspModCrystalBenefit(trans_data, rsp_data)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_mod_crystal_benefit_rsp")
end
function UGCAuthorHandler.send_ugc_crystal_get_balance_req()
  log(bWriteLog and "UGCAuthorHandler.send_ugc_crystal_get_balance_req")
  NetManager.SendPkg(1101744411)
end
function UGCAuthorHandler.on_ugc_crystal_get_balance_rsp(err_code, trans_data, rsp_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCCrystalIncentive = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_crystal_incentive)
  LogicUGCCrystalIncentive:RspCrystalGetBalance(trans_data, rsp_data)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_crystal_get_balance_rsp")
end
function UGCAuthorHandler.send_ugc_crystal_exchange_req(exchange_type, amount)
  log(bWriteLog and "UGCAuthorHandler.send_ugc_crystal_exchange_req exchange_type = " .. tostring(exchange_type) .. " amount = " .. tostring(amount))
  NetManager.SendPkg(1593270567, exchange_type, amount)
end
function UGCAuthorHandler.on_ugc_crystal_exchange_rsp(err_code, trans_data, rsp_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCCrystalIncentive = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_crystal_incentive)
  LogicUGCCrystalIncentive:RspCrystalExchange(trans_data, rsp_data)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_crystal_exchange_rsp")
end
function UGCAuthorHandler.send_ugc_crystal_withdraw_req(amount)
  log(bWriteLog and "UGCAuthorHandler.send_ugc_crystal_withdraw_req amount = " .. tostring(amount))
  NetManager.SendPkg(74129639, amount)
end
function UGCAuthorHandler.on_ugc_crystal_withdraw_rsp(err_code, trans_data, rsp_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCCrystalIncentive = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_crystal_incentive)
  LogicUGCCrystalIncentive:RspCrystalWithdraw(trans_data, rsp_data)
  log(bWriteLog and "UGCAuthorHandler.on_ugc_crystal_withdraw_rsp")
end
local reqRsp = {
  send_ugc_get_follow_author_meta_key_req = "on_ugc_get_follow_author_meta_key_rsp",
  send_ugc_get_friend_author_meta_key_req = "on_ugc_get_friend_author_meta_key_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, UGCAuthorHandler)
return UGCAuthorHandler