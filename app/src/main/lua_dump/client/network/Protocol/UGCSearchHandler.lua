local NetManager = require("client.network.comm.NetManager")
local UGCSearchHandler = {}
function UGCSearchHandler.send_ugc_get_all_meta_key_req()
  log(bWriteLog and "UGCSearchHandler.send_ugc_get_all_meta_key_req")
  NetManager.SendPkg(130235303)
end
function UGCSearchHandler.on_ugc_get_all_meta_key_rsp(err_code, all_meta_key, authorizedAssetList, authorizedParameterList)
  log(bWriteLog and "UGCSearchHandler.on_ugc_get_all_meta_key_rsp", authorizedParameterList)
  log_tree(bWriteLog and "[edward] UGCSearchHandler.on_ugc_get_all_meta_key_rsp", all_meta_key)
  log_tree(bWriteLog and "[edward] UGCSearchHandler.on_ugc_get_all_meta_key_rsp", authorizedParameterList)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:OnGetAllMetaKeyRsp(all_meta_key)
  local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
  LogicUGCAssetHub:OnGetAllMetaKeyRsp()
  if authorizedAssetList or authorizedParameterList then
    local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
    LogicUGCAuthor:UpdateAuthorizedAssetList(authorizedAssetList or {}, authorizedParameterList or {})
  end
end
function UGCSearchHandler.send_ugc_get_single_pub_mod_rank_req(mod_id)
  log(bWriteLog and "UGCSearchHandler.send_ugc_get_single_pub_mod_rank_req mod_id = " .. tostring(mod_id))
  NetManager.SendPkg(284867847, mod_id)
end
function UGCSearchHandler.on_ugc_get_single_pub_mod_rank_rsp(res, mod_id, rank_info)
  log(bWriteLog and "UGCSearchHandler.on_ugc_get_single_pub_mod_rank_rsp res = " .. tostring(res) .. ", mod_id = " .. tostring(mod_id))
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  log_tree("UGCSearchHandler.on_ugc_get_single_pub_mod_rank_rsp, rank_info = ", rank_info)
  local LogicUGCModRank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCModRank)
  LogicUGCModRank:ProcModRankListRsp(mod_id, rank_info)
end
function UGCSearchHandler.send_ugc_get_single_pub_mod_play_info_req(mod_id)
  if mod_id == nil then
    return
  end
  log(bWriteLog and "UGCSearchHandler.send_ugc_get_single_pub_mod_play_info_req mod_id = " .. tostring(mod_id))
  NetManager.SendPkg(1620217575, mod_id)
end
function UGCSearchHandler.on_ugc_get_single_pub_mod_play_info_rsp(res, mod_id, player_rank_info)
  log(bWriteLog and "UGCSearchHandler.on_ugc_get_single_pub_mod_play_info_rsp res = " .. tostring(res) .. ", mod_id = " .. tostring(mod_id))
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  log_tree("UGCSearchHandler.on_ugc_get_single_pub_mod_play_info_rsp, player_rank_info = ", player_rank_info)
  local LogicUGCModRank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCModRank)
  LogicUGCModRank:ProcPlayerRankInfoRsp(mod_id, player_rank_info)
end
function UGCSearchHandler.send_ugc_gallery_hot_theme_req()
  NetManager.SendPkg(2007292491)
end
function UGCSearchHandler.on_ugc_gallery_hot_theme_rsp(err_code, hot_theme)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_hall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
  logic_ugc_hall:on_ugc_gallery_hot_theme_rsp(err_code, hot_theme)
  local logic_ugc_hot_page = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_page)
  logic_ugc_hot_page:on_ugc_gallery_hot_theme_rsp(err_code, hot_theme)
end
function UGCSearchHandler.send_ugc_mixed_banner_req()
  log(bWriteLog and "UGCSearchHandler.send_ugc_mixed_banner_req start")
  NetManager.SendPkg(1798347367)
end
function UGCSearchHandler.on_ugc_mixed_banner_rsp(err_code, mixed_banner_list)
  log(bWriteLog and "UGCSearchHandler.on_ugc_mixed_banner_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  log_tree("UGCSearchHandler.on_ugc_mixed_banner_rsp mixed_banner_list = ", mixed_banner_list)
  local logic_ugc_hot_page = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_page)
  logic_ugc_hot_page:on_ugc_mixed_banner_rsp(err_code, mixed_banner_list)
  local logic_ugc_hall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
  logic_ugc_hall:on_ugc_mixed_banner_rsp(err_code, mixed_banner_list)
end
function UGCSearchHandler.send_ugc_mod_itemcf_req(mod_id, topn)
  log(bWriteLog and "UGCSearchHandler.send_ugc_mod_itemcf_req")
  NetManager.SendPkg(888765287, mod_id, topn)
end
function UGCSearchHandler.on_ugc_mod_itemcf_rsp(err_code, mod_id, topn, data)
  log(bWriteLog and "UGCSearchHandler.ugc_mod_itemcf_rsp")
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:OnGetResultRecommendRsp(topn, data)
end
function UGCSearchHandler.send_ugc_search_mod_collection_req(keyword)
  NetManager.SendPkg(1992170843, keyword)
end
function UGCSearchHandler.on_ugc_search_mod_collection_rsp(err_code, keyword, data_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
end
function UGCSearchHandler.send_ugc_search_collection_filter_req(rank_type, search_filter, page)
  NetManager.SendPkg(425552871, rank_type, search_filter, page)
end
function UGCSearchHandler.on_ugc_search_collection_filter_rsp(err_code, rank_type, search_filter, page, data_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
end
function UGCSearchHandler.send_ugc_combined_search_mod_req(keyword, rank_type, tag_list, is_ugc_season, feature_tag_list)
  log(bWriteLog and "UGCSearchHandler.send_ugc_combined_search_mod_req keyword = " .. tostring(keyword) .. " rank_type = " .. tostring(rank_type) .. " is_ugc_season = " .. tostring(is_ugc_season))
  NetManager.SendPkg(984965151, keyword, rank_type, tag_list, is_ugc_season, feature_tag_list)
end
function UGCSearchHandler.on_ugc_combined_search_mod_rsp(err_code, keyword, rank_type, tag_list, ret_info, is_ugc_season, feature_tag_list, extra_data)
  log(bWriteLog and "UGCSearchHandler.on_ugc_combined_search_mod_rsp err_code = " .. tostring(err_code))
  log(bWriteLog and "UGCSearchHandler.on_ugc_combined_search_mod_rsp keyword = " .. tostring(keyword) .. " rank_type = " .. tostring(rank_type) .. " is_ugc_season = " .. tostring(is_ugc_season))
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SEARCH_MOD, keyword, ret_info)
  local logic_ugc_search = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_search)
  logic_ugc_search:on_ugc_combined_search_mod_rsp(err_code, keyword, rank_type, tag_list, ret_info, is_ugc_season, feature_tag_list, extra_data)
end
function UGCSearchHandler.send_ugc_combined_search_collection_req(keyword, rank_type, tag_list, feature_tag_list)
  NetManager.SendPkg(60264871, keyword, rank_type, tag_list, feature_tag_list)
end
function UGCSearchHandler.on_ugc_combined_search_collection_rsp(err_code, keyword, rank_type, tag_list, ret_info, feature_tag_list)
  local logic_ugc_search = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_search)
  logic_ugc_search:on_ugc_combined_search_collection_rsp(keyword, rank_type, tag_list, ret_info, feature_tag_list)
end
function UGCSearchHandler.send_ugc_get_search_info_req(lang)
  NetManager.SendPkg(204105323, lang)
end
function UGCSearchHandler.on_ugc_get_search_info_rsp(err_code, lang, hot_search, icon_search)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_search = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_search)
  logic_ugc_search:OnUgcGetSearchInfoRsp(hot_search, icon_search)
end
function UGCSearchHandler.send_ugc_get_single_mod_share_rank_req(mod_id)
  log(bWriteLog and "UGCSearchHandler.send_ugc_get_single_mod_share_rank_req = " .. tostring(mod_id))
  NetManager.SendPkg(560570175, mod_id)
end
function UGCSearchHandler.on_ugc_get_single_mod_share_rank_rsp(res, mod_id, rank_info, the_ugc_mod_share_count)
  log(bWriteLog and "UGCSearchHandler.on_ugc_get_single_mod_share_rank_rsp res = " .. tostring(res) .. ", mod_id = " .. tostring(mod_id))
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  log_tree("UGCSearchHandler.on_ugc_get_single_mod_share_rank_rsp, rank_info = ", rank_info)
  log(bWriteLog and "UGCSearchHandler.on_ugc_get_single_mod_share_rank_rsp the_ugc_mod_share_count = " .. tostring(the_ugc_mod_share_count))
  local LogicUGCModRank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCModRank)
  LogicUGCModRank:ProcModRankListRsp(mod_id, rank_info, the_ugc_mod_share_count)
end
function UGCSearchHandler.send_ugc_promotion_game_result_req(req_type)
  log(bWriteLog and "UGCSearchHandler.send_ugc_promotion_game_result_req req_type = " .. tostring(req_type))
  NetManager.SendPkg(527316499, req_type)
end
function UGCSearchHandler.on_ugc_promotion_game_result_rsp(err_code, promo_list, extra_info)
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:OnGetPromotionRecommendRsp(promo_list, extra_info)
end
function UGCSearchHandler.send_get_recommend_setting_req()
  log(bWriteLog and "[v_yibxu] UGCSearchHandler.send_get_recommend_setting_req")
  NetManager.SendPkg(272748107)
end
function UGCSearchHandler.on_get_recommend_setting_rsp(err_code, cur_save_count, max_save_count, my_favor_mods, interest_list, interest_list_setting, favor_tags, favor_mod_setting)
  log(bWriteLog and "[v_yibxu] UGCSearchHandler.on_get_recommend_setting_rsp")
  log_tree(bWriteLog and "[v_yibxu] UGCSearchHandler.on_get_recommend_setting_rsp cur_save_count = ", cur_save_count)
  log_tree(bWriteLog and "[v_yibxu] UGCSearchHandler.on_get_recommend_setting_rsp max_save_count = ", max_save_count)
  log_tree(bWriteLog and "[v_yibxu] UGCSearchHandler.on_get_recommend_setting_rsp my_favor_mods = ", my_favor_mods)
  log_tree(bWriteLog and "[v_yibxu] UGCSearchHandler.on_get_recommend_setting_rsp interest_list = ", interest_list)
  log_tree(bWriteLog and "[v_yibxu] UGCSearchHandler.on_get_recommend_setting_rsp interest_list_setting = ", interest_list_setting)
  log_tree(bWriteLog and "[v_yibxu] UGCSearchHandler.on_get_recommend_setting_rsp favor_tags = ", favor_tags)
  log_tree(bWriteLog and "[v_yibxu] UGCSearchHandler.on_get_recommend_setting_rsp favor_mod_setting = ", favor_mod_setting)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_UGC_Personalization = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_personalization)
  Logic_UGC_Personalization:RsqRecommendSettingData(cur_save_count, max_save_count, my_favor_mods, interest_list, interest_list_setting, favor_tags, favor_mod_setting)
end
function UGCSearchHandler.send_set_recommend_setting_req(my_favor_mods, interest_list, interest_list_setting, favor_tags, favor_mod_setting)
  log_tree(bWriteLog and "[v_yibxu] UGCSearchHandler.send_set_recommend_setting_req my_favor_mods = ", my_favor_mods)
  log_tree(bWriteLog and "[v_yibxu] UGCSearchHandler.send_set_recommend_setting_req interest_list = ", interest_list)
  log_tree(bWriteLog and "[v_yibxu] UGCSearchHandler.send_set_recommend_setting_req interest_list_setting = ", interest_list_setting)
  log_tree(bWriteLog and "[v_yibxu] UGCSearchHandler.send_set_recommend_setting_req favor_tags = ", favor_tags)
  log_tree(bWriteLog and "[v_yibxu] UGCSearchHandler.send_set_recommend_setting_req favor_mod_setting = ", favor_mod_setting)
  NetManager.SendPkg(1501206043, my_favor_mods, interest_list, interest_list_setting, favor_tags, favor_mod_setting)
end
function UGCSearchHandler.on_set_recommend_setting_rsp(err_code, cur_save_count, max_save_count, my_favor_mods, interest_list, interest_list_setting, favor_tags, favor_mod_setting)
  log(bWriteLog and "[v_yibxu] UGCSearchHandler.on_set_recommend_setting_rsp")
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  ShowNotice(9826)
  local Logic_UGC_Personalization = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_personalization)
  Logic_UGC_Personalization:RefreshLocalData(cur_save_count, max_save_count, my_favor_mods, interest_list, interest_list_setting, favor_tags, favor_mod_setting)
end
function UGCSearchHandler.send_ugc_personal_recommond_req()
  NetManager.SendPkg(1585810599)
end
function UGCSearchHandler.on_ugc_personal_recommond_rsp(err_code, info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_search = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_search)
  logic_ugc_search:on_ugc_personal_recommond_rsp(info)
end
function UGCSearchHandler.send_ugc_get_guess_search_text_req()
  NetManager.SendPkg(827762527)
end
function UGCSearchHandler.on_ugc_get_guess_search_text_rsp(err_code, rat_info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_search = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_search)
  logic_ugc_search:ugc_get_guess_search_text_rsp(rat_info)
end
function UGCSearchHandler.send_ugc_hot_theme_ext_req()
  NetManager.SendPkg(1291385415)
end
function UGCSearchHandler.on_ugc_hot_theme_ext_rsp(err_code, mod_list)
  local logic_ugc_hot_page = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_page)
  logic_ugc_hot_page:on_ugc_hot_theme_ext_rsp(err_code, mod_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCRank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCRank)
  LogicUGCRank:OnGetHotRankListRsp(mod_list)
end
function UGCSearchHandler.send_ugc_match_tab_req()
  log(bWriteLog and "UGCSearchHandler.send_ugc_match_tab_req")
  NetManager.SendPkg(1565205255)
end
function UGCSearchHandler.on_ugc_match_tab_rsp(err_code, match_tab_list)
  log(bWriteLog and "UGCSearchHandler.on_ugc_match_tab_rsp")
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("UGCSearchHandler.on_ugc_match_tab_rsp match_tab_list = ", match_tab_list)
  local logic_ugc_match_tab = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_match_tab)
  logic_ugc_match_tab:on_ugc_mixed_match_rsp(match_tab_list)
end
function UGCSearchHandler.send_ugc_search_word_comp_req(input)
  NetManager.SendPkg(1585714279, input)
end
function UGCSearchHandler.on_ugc_search_word_comp_rsp(err_code, input, ret_info)
  if err_code ~= 0 then
    log(bWriteLog and "UGCSearchHandler.on_ugc_search_word_comp_rsp err")
    return
  end
  local logic_ugc_search = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_search)
  logic_ugc_search:SearchWordCompRsp(input, ret_info)
end
function UGCSearchHandler.send_get_ugc_top_author_list_req(author_list_key)
  log(bWriteLog and "UGCSearchHandler.send_get_ugc_top_author_list_req")
  NetManager.SendPkg(663742639, author_list_key)
end
function UGCSearchHandler.on_get_ugc_top_author_list_rsp(err_code, random_top_author, author_list_key)
  if err_code ~= 0 then
    log(bWriteLog and "UGCSearchHandler.on_get_ugc_top_author_list_rsp err")
  end
  log_tree(bWriteLog and "UGCSearchHandler.on_get_ugc_top_author_list_rsp author_list_key =  ", author_list_key)
  log_tree(bWriteLog and "UGCSearchHandler.on_get_ugc_top_author_list_rsp random_top_author =  ", random_top_author)
  if author_list_key == "recent_publish_author" then
    local LogicUGCRandom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCRandom)
    LogicUGCRandom:OnGetUGCTopAuthorListRsp(random_top_author)
  else
    local logic_ugc_hot_author = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hot_author)
    logic_ugc_hot_author:HotAuthorListRsp(random_top_author)
  end
end
function UGCSearchHandler.send_ugc_new_mod_tab_req()
  NetManager.SendPkg(665665599)
end
function UGCSearchHandler.on_ugc_new_mod_tab_rsp(err_code, new_mod_tab_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    log(bWriteLog and "UGCSearchHandler.on_ugc_new_mod_tab_rsp err")
    return
  end
  log_tree("UGCSearchHandler.on_ugc_new_mod_tab_rsp new_mod_tab_list = ", new_mod_tab_list)
  local LogicUGCRandom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCRandom)
  LogicUGCRandom:GetManagementGualityAuthor(new_mod_tab_list)
end
function UGCSearchHandler.send_ugc_gallery_new_mod_incubation_req()
  NetManager.SendPkg(1489709863)
end
function UGCSearchHandler.on_ugc_gallery_new_mod_incubation_rsp(err_code, mod_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("UGCSearchHandler.on_ugc_gallery_new_mod_incubation_rsp mod_list:", mod_list)
  local logic_ugc_new_map = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_map)
  logic_ugc_new_map:on_ugc_gallery_new_mod_incubation_rsp(mod_list)
end
function UGCSearchHandler.send_ugc_gallery_new_mod_validation_req()
  NetManager.SendPkg(1246208519)
end
function UGCSearchHandler.on_ugc_gallery_new_mod_validation_rsp(err_code, mod_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("UGCSearchHandler.on_ugc_gallery_new_mod_validation_rsp mod_list:", mod_list)
  local logic_ugc_new_map = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_map)
  logic_ugc_new_map:on_ugc_gallery_new_mod_validation_rsp(mod_list)
end
function UGCSearchHandler.send_ugc_gallery_explore_mix_req()
  NetManager.SendPkg(1280978655)
end
function UGCSearchHandler.on_ugc_gallery_explore_mix_rsp(err_code, info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_search = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_search)
  logic_ugc_search:on_ugc_gallery_explore_mix_rsp(info)
end
function UGCSearchHandler.send_ugc_get_events_mod_list_req(activity_id, get_type, rank_type, keyword)
  log(bWriteLog and "UGCSearchHandler.send_ugc_get_events_mod_list_req activity_id = " .. activity_id .. " get_type = " .. get_type .. " rank_type = " .. tostring(rank_type) .. " keyword = " .. tostring(keyword))
  NetManager.SendPkg(1134166203, activity_id, get_type, rank_type, keyword)
end
function UGCSearchHandler.on_ugc_get_events_mod_list_rsp(err, activity_id, get_type, rank_type, mods, keyword)
  log(bWriteLog and "UGCSearchHandler.on_ugc_get_events_mod_list_rsp activity_id = " .. tostring(activity_id) .. " get_type = " .. tostring(get_type) .. " rank_type = " .. tostring(rank_type) .. " keyword = " .. tostring(keyword))
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local Logic_UUGC_SeasonTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season_template)
  Logic_UUGC_SeasonTemplate:RspContestMods(activity_id, get_type, rank_type, mods, keyword)
end
function UGCSearchHandler.send_ugc_get_all_spec_theme_list_req()
  NetManager.SendPkg(421139775)
end
function UGCSearchHandler.on_ugc_get_all_spec_theme_list_rsp(err_code, spec_theme_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_album_theme = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_album_theme)
  logic_ugc_album_theme:on_ugc_get_all_spec_theme_list_rsp(spec_theme_list)
end
function UGCSearchHandler.send_spec_theme_task_get_progress_req()
  NetManager.SendPkg(1331806887)
end
function UGCSearchHandler.on_spec_theme_task_get_progress_rsp(err_code, task_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_album_theme = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_album_theme)
  logic_ugc_album_theme:on_spec_theme_task_get_progress_rsp(task_data)
end
function UGCSearchHandler.send_spec_theme_task_receive_reward_req(task_id)
  NetManager.SendPkg(609738599, task_id)
end
function UGCSearchHandler.on_spec_theme_task_receive_reward_rsp(err_code, reward_list, task_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_album_theme = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_album_theme)
  logic_ugc_album_theme:on_spec_theme_task_receive_reward_rsp(reward_list, task_data)
end
function UGCSearchHandler.send_spec_theme_task_receive_all_reward_req()
  NetManager.SendPkg(915374567)
end
function UGCSearchHandler.on_spec_theme_task_receive_all_reward_rsp(err_code, reward_list, task_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_album_theme = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_album_theme)
  logic_ugc_album_theme:on_spec_theme_task_receive_all_reward_rsp(reward_list, task_data)
end
function UGCSearchHandler.send_ugc_get_single_mod_purchase_rank_req(mod_id)
  NetManager.SendPkg(1893451303, mod_id)
end
function UGCSearchHandler.on_ugc_get_single_mod_purchase_rank_rsp(err, mod_id, rank_info)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local LogicUGCModRank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCModRank)
  LogicUGCModRank:ProcModPurchaseRankInfoRsp(mod_id, rank_info)
end
function UGCSearchHandler.send_ugc_is_recommend_fresh_req()
  NetManager.SendPkg(2070631815)
end
function UGCSearchHandler.on_ugc_is_recommend_fresh_rsp(err_code, is_new, is_back)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_intention = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_intention)
  logic_ugc_intention:on_ugc_is_recommend_fresh_rsp(is_new, is_back)
end
function UGCSearchHandler.send_ugc_admin_recommend_mods_req()
  NetManager.SendPkg(302555879)
end
function UGCSearchHandler.on_ugc_admin_recommend_mods_rsp(err_code, mods)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_intention = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_intention)
  logic_ugc_intention:on_ugc_admin_recommend_mods_rsp(mods)
end
function UGCSearchHandler.send_ugc_mark_recommend_mods_req(id_arr, is_chosen)
  NetManager.SendPkg(2065114675, id_arr, is_chosen)
end
function UGCSearchHandler.on_ugc_mark_recommend_mods_rsp(err_code, id_arr)
  local logic_ugc_intention = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_intention)
  logic_ugc_intention:on_ugc_mark_recommend_mods_rsp(err_code, id_arr)
end
function UGCSearchHandler.send_ugc_gallery_feeds_req(tag_list)
  NetManager.SendPkg(129806955, tag_list)
  log_tree(bWriteLog and "UGCSearchHandler.send_ugc_gallery_feeds_req tag_list = ", tag_list)
end
function UGCSearchHandler.on_ugc_gallery_feeds_rsp(err_code, table_info)
  log_tree(bWriteLog and "UGCSearchHandler.on_ugc_gallery_feeds_rsp tag_list = ", table_info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_search = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_search)
  logic_ugc_search:on_ugc_gallery_feeds_rsp(table_info)
end
local reqRsp = {
  send_ugc_search_mod_collection_req = "on_ugc_search_mod_collection_rsp",
  send_ugc_search_collection_filter_req = "on_ugc_search_collection_filter_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, UGCSearchHandler)
return UGCSearchHandler