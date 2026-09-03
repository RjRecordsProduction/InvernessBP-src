local UGCHandler = {
  isGMTest = false,
  Enum_UGC_MatchListReqTarget = {SeasonTemplate = 1, ThemePlayActivityTemplate = 2},
  _UGCMatchListReqQueue = {},
  _bThemePlayActivityTemplatePanelActive = false,
  Enum_UGC_MatchListReqTarget = {SeasonTemplate = 1, ThemePlayActivityTemplate = 2},
  _UGCMatchListReqQueue = {},
  _bThemePlayActivityTemplatePanelActive = false
}
local NetManager = require("client.network.comm.NetManager")
local _BuildSortedIdCsv = function(DataTable, PreferValueId)
  if not DataTable then
    return ""
  end
  local IdMap = {}
  local IdList = {}
  local _AddId = function(RawId)
    if RawId == nil then
      return
    end
    local IdStr = tostring(RawId)
    if IdStr == "" then
      return
    end
    if not IdMap[IdStr] then
      IdMap[IdStr] = true
      table.insert(IdList, IdStr)
    end
  end
  for Key, Value in pairs(DataTable) do
    if PreferValueId then
      if type(Value) == "table" and Value.pub_prefab_id ~= nil then
        _AddId(Value.pub_prefab_id)
      else
        _AddId(Value)
      end
    elseif type(Value) == "table" and Value.pub_prefab_id ~= nil then
      _AddId(Value.pub_prefab_id)
    elseif type(Key) == "number" and type(Value) ~= "table" then
      _AddId(Value)
    else
      _AddId(Key)
    end
  end
  table.sort(IdList)
  return table.concat(IdList, ",")
end
local COPILOT_META_REQ_TYPE = 16
local _LogCopilotMetaTraceback = function(Stage, Src, IdCsv)
  if not bWriteLog or Src ~= COPILOT_META_REQ_TYPE then
    return
  end
  local Trace = string.format("UGCHandler.%s src=%s ids=[%s] traceback_unavailable", tostring(Stage), tostring(Src), tostring(IdCsv))
  if debug and debug.traceback then
    Trace = debug.traceback(string.format("UGCHandler.%s src=%s ids=[%s]", tostring(Stage), tostring(Src), tostring(IdCsv)), 3)
  end
  log(bWriteLog and Trace)
end
local _ShowErrorTips = function(errorCode)
  if not errorCode then
    return false
  end
  if errorCode == 0 then
    return false
  else
    log(bWriteLog and "[edward] UGCHandler._ShowErrorTips, errorCode = " .. errorCode)
    ShowNotice(errorCode)
  end
  return true
end
function UGCHandler.send_ugc_get_is_open_req()
  log(bWriteLog and "UGCHandler.send_ugc_get_is_open_req")
  NetManager.SendPkg(809462259)
end
function UGCHandler.on_ugc_get_is_open_rsp(is_open)
  log(bWriteLog and "UGCHandler.on_ugc_get_is_open_rsp " .. tostring(is_open))
  if not DataMgr then
    log(bWriteLog and "UGCHandler.on_ugc_get_is_open_rsp DataMgr is nil")
    return
  end
  DataMgr.is_open_ugc = is_open
  if not is_open then
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  logic_mode_selection:RequireUGCData()
end
function UGCHandler.send_ugc_lobby_text_filter_req(text)
  NetManager.SendPkg(823928423, text)
end
function UGCHandler.on_ugc_lobby_text_filter_rsp(err_code)
end
function UGCHandler.send_ugc_translate_req(to, key, msg_id)
  log(bWriteLog and "UGCHandler.send_ugc_translate_req " .. tostring(key))
  NetManager.SendPkg(1980359179, to, key, msg_id)
end
function UGCHandler.on_ugc_translate_rsp(ret_code, msg_id, from, to, trans_key, trans_value)
  log(bWriteLog and "UGCHandler.on_ugc_translate_rsp " .. tostring(trans_key) .. " value:" .. tostring(trans_value))
  local TranslateMgr = require("client.slua.logic.translator.translate_mgr")
  TranslateMgr.OnGetTranslateViaServer(ret_code, msg_id, from, to, trans_key, trans_value)
end
function UGCHandler.send_ugc_get_template_list_req()
  NetManager.SendPkg(2122233299)
end
function UGCHandler.on_ugc_get_template_list_rsp(err_code, mod_template_cfg, mod_template_cfg_gray)
  if err_code ~= 0 or type(mod_template_cfg) ~= "table" then
    return
  end
  local LogicUGCTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
  mod_template_cfg_gray = mod_template_cfg_gray or {}
  for k, v in pairs(mod_template_cfg_gray) do
    mod_template_cfg[k] = v
  end
  LogicUGCTemplate:SetTemplate(mod_template_cfg)
  log_tree("UGCHandler.on_ugc_get_template_list_rsp", mod_template_cfg)
end
function UGCHandler.send_ugc_get_random_rec_req(page)
  NetManager.SendPkg(1570371687, page)
end
function UGCHandler.on_ugc_get_random_rec_rsp(err_code, page, random_reg_info)
  log_tree("UGCHandler.on_ugc_get_random_rec_rsp", page)
  if err_code ~= 0 or type(page) ~= "table" then
    ShowNotice(err_code)
  end
  local logic_ugc_random_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_random_recommend)
  logic_ugc_random_recommend:OnRandomRsp(page)
  local LogicUGCRandom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCRandom)
  LogicUGCRandom:OnRandomRsp(page, random_reg_info)
end
function UGCHandler.send_ugc_report_rec_mod_view_req(version, report_info_list)
  NetManager.SendPkg(914772027, version, report_info_list)
end
function UGCHandler.on_ugc_report_rec_mod_view_rsp(err_code, version)
end
function UGCHandler.send_ugc_debug_id_cfg_req()
  log(bWriteLog and "UGCHandler.send_ugc_debug_id_cfg_req")
  NetManager.SendPkg(1451955623)
end
function UGCHandler.on_ugc_debug_id_cfg_rsp(ugc_debug_id_table)
  log(bWriteLog and "UGCHandler.on_ugc_debug_id_cfg_rsp")
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:SetUGCDebugID(ugc_debug_id_table)
end
function UGCHandler.send_ugc_translate_batch_req(to, keys, msg_id)
  NetManager.SendPkg(849734095, to, keys, msg_id)
end
function UGCHandler.on_ugc_translate_batch_rsp(ret_code, msg_id, from, to, trans_keys, trans_values)
  if _ShowErrorTips(ret_code) then
    return
  end
  local LogicUGCTrans = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTrans)
  LogicUGCTrans:on_ugc_translate_batch_rsp(msg_id, from, to, trans_keys, trans_values)
end
function UGCHandler.send_ugc_report_map_comment_video_req(params)
  log_tree(bWriteLog and "UGCHandler.send_ugc_report_map_comment_video_req params = ", params)
  NetManager.SendPkg(1016077927, params)
end
function UGCHandler.on_ugc_report_map_comment_video_rsp(err_code)
  log(bWriteLog and "UGCHandler.on_ugc_report_map_comment_video_rsp err_code = " .. err_code)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
end
function UGCHandler.send_ugc_query_map_comment_video_report_status_req(mod_id, feed_id)
  NetManager.SendPkg(2038486335, mod_id, feed_id)
end
function UGCHandler.on_ugc_query_map_comment_video_report_status_rsp(err_code)
  local logic_ugc_recommend_video = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_recommend_video)
  logic_ugc_recommend_video:OnRecommendVideoComplaintStatusRsp(err_code)
end
function UGCHandler.send_ugc_promotion_record_req()
  NetManager.SendPkg(1257838439)
end
function UGCHandler.on_ugc_promotion_record_rsp(err_code, record)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
end
function UGCHandler.send_ugc_promotion_use_item_req(instids, mod_id)
  NetManager.SendPkg(1547639207, instids, mod_id)
end
function UGCHandler.send_ugc_report_promotion_view_req(report_info_list, report_type, trans_info)
  print(bWriteLog and "UGCHandler.send_ugc_report_promotion_view_req report_type:" .. tostring(report_type))
  log_tree("report_info_list:", report_info_list)
  log_tree("UGCHandler.send_ugc_report_promotion_view_req trans_info:", trans_info)
  NetManager.SendPkg(921688835, report_info_list, report_type, trans_info)
end
function UGCHandler.on_ugc_promotion_use_item_rsp(err_code, record)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
end
function UGCHandler.on_ugc_report_promotion_view_rsp(err_code, record)
  print(bWriteLog and "UGCHandler.on_ugc_report_promotion_view_rsp err_code:" .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
end
function UGCHandler.send_ugc_set_privacy_req(privacy)
  log(bWriteLog and "[v_yibxu] UGCHandler send_ugc_set_privacy_req")
  NetManager.SendPkg(912227943, privacy)
end
function UGCHandler.on_ugc_set_privacy_rsp(err_code, privacy)
  log(bWriteLog and "[v_yibxu] UGCHandler on_ugc_set_privacy_rsp")
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
  LogicSettingBasic.RspUGCSetPrivacy(privacy)
end
function UGCHandler.send_mark_recommend_ugc_req(mod_id, tag)
  print(bWriteLog and "UGCHandler.send_mark_recommend_ugc_req " .. tostring(mod_id) .. " " .. tostring(tag))
  NetManager.SendPkg(1091417287, mod_id, tag)
end
function UGCHandler.on_mark_recommend_ugc_rsp(err_code, mod_id, tag)
  print(bWriteLog and "UGCHandler.on_mark_recommend_ugc_rsp err_code = " .. tostring(err_code))
  print(bWriteLog and "UGCHandler.on_mark_recommend_ugc_rsp mod_id = " .. tostring(mod_id))
  print(bWriteLog and "UGCHandler.on_mark_recommend_ugc_rsp tag = " .. tostring(tag))
  if err_code == 0 then
    ShowNotice(69490)
  end
end
function UGCHandler.send_ugc_share_pub_mod_req(share_type, mod_id, author_uid, mod_collection_id)
  log(bWriteLog and "[v_yibxu] UGCHandler.send_ugc_share_pub_mod_req mod_id = " .. tostring(mod_id) .. " author_uid = " .. tostring(author_uid) .. " mod_collection_id = " .. tostring(mod_collection_id))
  NetManager.SendPkg(678266499, share_type, mod_id, author_uid, mod_collection_id)
end
function UGCHandler.on_ugc_share_pub_mod_rsp(err_code, mod_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_UGC_Share = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_share)
  Logic_UGC_Share:OnUGCSharePubRsp(mod_id)
end
function UGCHandler.send_ugc_take_season_award_req()
  NetManager.SendPkg(228817335)
end
function UGCHandler.on_ugc_take_season_award_rsp(err_code, awards, invoke_type)
  log(bWriteLog and "SeasonHandler.on_task_season_segment_prize_all_rsp " .. err_code)
  log(bWriteLog and "SeasonHandler.on_task_season_segment_prize_all_rsp invoke_type" .. tostring(invoke_type))
  log_tree("SeasonHandler.on_task_season_segment_prize_all_rsp ", awards)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
end
function UGCHandler.send_ugc_get_season_award_list_req()
  NetManager.SendPkg(1423455159)
end
function UGCHandler.on_ugc_get_season_award_list_rsp(ok, season, cur_season_id, is_idle_time, pre_best_segment)
end
function UGCHandler.send_load_pub_prefab_id_list_req(params, tab_type)
  log_tree("UGCHandler load_pub_prefab_id_list_req params:", params)
  NetManager.SendPkg(9064699, params, tab_type)
end
function UGCHandler.on_load_pub_prefab_id_list_rsp(err_code, tab_type, pub_prefab_ids)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  if pub_prefab_ids then
    log(bWriteLog and "UGCHandler.load_pub_prefab_id_list_rsp #pub_prefab_ids = " .. #pub_prefab_ids)
    local LogicUGCCodePrefab = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_codeprefab)
    LogicUGCCodePrefab:RspPrefabIdList(tab_type, pub_prefab_ids)
  end
end
function UGCHandler.send_batch_load_pub_prefab_meta_data_req(pub_prefab_ids, src, client_data)
  local IdCsv = _BuildSortedIdCsv(pub_prefab_ids, true)
  log(bWriteLog and string.format("UGCHandler.send_batch_load_pub_prefab_meta_data_req count=%s src=%s ids=[%s] client_data={is_silent=%s,is_lobby=%s}", tostring(#pub_prefab_ids), tostring(src), tostring(IdCsv), tostring(client_data and client_data.is_silent), tostring(client_data and client_data.is_lobby)))
  _LogCopilotMetaTraceback("send_batch_load_pub_prefab_meta_data_req", src, IdCsv)
  NetManager.SendPkg(182263927, pub_prefab_ids, src, client_data)
end
function UGCHandler.on_batch_load_pub_prefab_meta_data_rsp(err_code, uid, prefab_meta_datas, invalid_prefab_ids, src, client_data)
  local MetaCount = 0
  local InvalidCount = 0
  local MetaIdCsv = ""
  local InvalidIdCsv = ""
  local TableUtil
  if prefab_meta_datas then
    TableUtil = require("common.table_util")
    MetaCount = TableUtil.CountTable(prefab_meta_datas)
    MetaIdCsv = _BuildSortedIdCsv(prefab_meta_datas, false)
  end
  if invalid_prefab_ids then
    TableUtil = TableUtil or require("common.table_util")
    InvalidCount = TableUtil.CountTable(invalid_prefab_ids)
    InvalidIdCsv = _BuildSortedIdCsv(invalid_prefab_ids, true)
  end
  log(bWriteLog and string.format("UGCHandler.batch_load_pub_prefab_meta_data_rsp err=%s uid=%s src=%s meta_count=%s invalid_count=%s meta_ids=[%s] invalid_ids=[%s] client_data={is_silent=%s,is_lobby=%s}", tostring(err_code), tostring(uid), tostring(src), tostring(MetaCount), tostring(InvalidCount), tostring(MetaIdCsv), tostring(InvalidIdCsv), tostring(client_data and client_data.is_silent), tostring(client_data and client_data.is_lobby)))
  _LogCopilotMetaTraceback("on_batch_load_pub_prefab_meta_data_rsp", src, MetaIdCsv)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  if prefab_meta_datas then
    log(bWriteLog and "UGCHandler.batch_load_pub_prefab_meta_data_rsp #meta_datas = " .. TableUtil.CountTable(prefab_meta_datas))
    local LogicUGCPrefabMall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
    if src == LogicUGCPrefabMall.ENUM_META_REQ_TYPE.CODE_PREFAB then
      log(bWriteLog and "UGCHandler.batch_load_pub_prefab_meta_data_rsp dispatch=CODE_PREFAB")
      local LogicUGCCodePrefab = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_codeprefab)
      LogicUGCCodePrefab:RspPrefabMetaList(prefab_meta_datas, src, client_data)
    elseif src == LogicUGCPrefabMall.ENUM_META_REQ_TYPE.AIDESC then
      log(bWriteLog and "UGCHandler.batch_load_pub_prefab_meta_data_rsp dispatch=AIDESC")
      EventSystem:postEvent(EVENTTYPE_CREATIVE, EVENTID_UGC_PREFAB_MALL_META_DESC_UPDATES, prefab_meta_datas, invalid_prefab_ids)
    else
      log(bWriteLog and "UGCHandler.batch_load_pub_prefab_meta_data_rsp dispatch=PREFAB_MALL")
      LogicUGCPrefabMall:RspPrefabMetaList(prefab_meta_datas, src, client_data, invalid_prefab_ids)
      log_tree("UGCHandler.on_batch_load_pub_prefab_meta_data_rsp prefab_meta_datas", prefab_meta_datas)
    end
  end
end
function UGCHandler.send_load_pub_prefab_bin_data_req(pub_prefab_id, off_set, src)
  log(bWriteLog and "UGCHandler.load_pub_prefab_bin_data_offset_req")
  NetManager.SendPkg(565092775, pub_prefab_id, off_set, src)
end
function UGCHandler.on_load_pub_prefab_bin_data_rsp(err_code, pub_prefab_id, off_set, fragment_data, src)
  log(bWriteLog and "UGCHandler.load_pub_prefab_bin_data_rsp")
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  if fragment_data then
    log(bWriteLog and "UGCHandler.batch_load_pub_prefab_meta_data_rsp #bin_data = " .. string.len(fragment_data))
    local LogicUGCPrefabMall = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_prefab_mall)
    if src == LogicUGCPrefabMall.ENUM_META_REQ_TYPE.CODE_PREFAB then
      local LogicUGCCodePrefab = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_codeprefab)
      LogicUGCCodePrefab:RspPrefabBinOffset(pub_prefab_id, off_set, fragment_data)
    else
      LogicUGCPrefabMall:RspPrefabBinOffset(pub_prefab_id, off_set, fragment_data)
    end
  end
end
function UGCHandler.send_ugc_author_line_chart_req()
  log(bWriteLog and "UGCHandler.send_ugc_author_line_chart_req")
  NetManager.SendPkg(926609383)
end
function UGCHandler.on_ugc_author_line_chart_rsp(error_code, line_chart_data, offline_stat_data, base_stat)
  log(bWriteLog and "UGCHandler.on_ugc_author_line_chart_rsp")
  if error_code ~= 0 then
    ShowNotice(error_code)
    return
  end
  log_tree("UGCHandler.on_ugc_author_line_chart_rsp = ", line_chart_data)
  local Logic_UGC_DataCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_datacenter)
  Logic_UGC_DataCenter:RspLineChartData(offline_stat_data.line_chart_data)
  Logic_UGC_DataCenter:RspRadarChartData(offline_stat_data.radar, base_stat)
  Logic_UGC_DataCenter:RspRingChartData(offline_stat_data.fan_source)
end
function UGCHandler.on_ugc_get_single_mod_season_rank_rsp(err_code, mod_id, rank_info, personal_info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    log(bWriteLog and "UGCHandler.on_ugc_get_radar_meta_rsp err")
  end
  local LogicUGCModRank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCModRank)
  LogicUGCModRank:ProcModRankListRsp(mod_id, rank_info, nil, true)
end
function UGCHandler.send_ugc_set_auto_translate_switch_req(ugc_auto_translate_switch)
  NetManager.SendPkg(736049579, ugc_auto_translate_switch)
end
function UGCHandler.on_ugc_set_auto_translate_switch_rsp(err)
  if err ~= 0 then
  end
end
function UGCHandler.send_ugc_get_auto_translate_switch_req()
  NetManager.SendPkg(128588251)
end
function UGCHandler.on_ugc_get_auto_translate_switch_rsp(ugc_auto_translate_switch)
  local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  Logic_UGC:ONGetAllAutoTransRsp(ugc_auto_translate_switch)
end
function UGCHandler.send_get_ugc_comm_cfg_req(set_type)
  log(bWriteLog and "UGCHandler.send_get_ugc_comm_cfg_req set_type = " .. tostring(set_type))
  NetManager.SendPkg(601019623, set_type)
end
function UGCHandler.on_get_ugc_comm_cfg_rsp(err, set_type, cfgs)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  log(bWriteLog and "UGCHandler.on_get_ugc_comm_cfg_rsp set_type = " .. tostring(set_type))
  log_tree("UGCHandler.on_get_ugc_comm_cfg_rsp cfgs:", cfgs)
  local Logic_UGC_SeasonTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season_template)
  Logic_UGC_SeasonTemplate:RspSeasonActivityData(set_type, cfgs)
  Logic_UGC_SeasonTemplate:RspMatchHubActivityData(set_type, cfgs)
  if UGCHandler._bThemePlayActivityTemplatePanelActive then
    local Logic_UGC_ThemePlay_ActivityTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_theme_play_activity_template)
    Logic_UGC_ThemePlay_ActivityTemplate:RspSeasonActivityData(set_type, cfgs)
    Logic_UGC_ThemePlay_ActivityTemplate:RspMatchHubActivityData(set_type, cfgs)
  end
end
function UGCHandler.send_ugc_general_report_req(report_type, data)
  log(bWriteLog and "UGCHandler.send_ugc_general_report_req report_type = " .. tostring(report_type))
  log_tree(bWriteLog and "UGCHandler.send_ugc_general_report_req data = ", data)
  NetManager.SendPkg(986636327, report_type, data)
end
function UGCHandler.on_ugc_general_report_rsp(err_code)
  log(bWriteLog and "UGCHandler.on_ugc_general_report_rsp err = " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  ShowNotice(8173)
end
function UGCHandler.send_ugc_share_task_get_progress_req()
  log(bWriteLog and "UGCHandler.send_ugc_share_task_get_progress_req")
  NetManager.SendPkg(1178576819)
end
function UGCHandler.on_ugc_share_task_get_progress_rsp(err_code, task_progress)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "UGCHandler.on_ugc_share_task_get_progress_rsp task_list = ", task_progress)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SHARE_TASK_GET_PROGRESS, task_progress)
end
function UGCHandler.send_ugc_share_task_receive_award_req(mod_id)
  log(bWriteLog and "UGCHandler.send_ugc_share_task_receive_award_req mod_id = " .. tostring(mod_id))
  NetManager.SendPkg(893843047, mod_id)
end
function UGCHandler.on_ugc_share_task_receive_award_rsp(err_code, award_list, ugc_share_task_data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "UGCHandler.on_ugc_share_task_receive_award_rsp award_list = ", award_list)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SHARE_GET_AWARD, award_list, ugc_share_task_data)
end
function UGCHandler.send_ugc_aws_presigned_url_batch_req(bucket, object_key_s, method, param_extra)
  NetManager.SendPkg(1670355315, bucket, object_key_s, method, param_extra)
end
function UGCHandler.on_ugc_aws_presigned_url_batch_rsp(err_code, bucket, object_key_s, method, param_extra, presigned_url_s)
  local ModuleManager = require("client.module_framework.ModuleManager")
  local logic_resbucket = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_resbucket)
  if logic_resbucket then
    logic_resbucket:OnFetchUrl(err_code, bucket, object_key_s, method, param_extra, presigned_url_s)
  end
end
function UGCHandler.send_wow_get_my_private_prefab_meta_list_req()
  log_format("UGCHandler.send_wow_get_my_private_prefab_meta_list_req")
  NetManager.SendPkg(868466455)
end
function UGCHandler.on_wow_get_my_private_prefab_meta_list_rsp(err_code, meta_data_list)
  local TableUtil = require("common.table_util")
  log_format("UGCHandler.on_wow_get_my_private_prefab_meta_list_rsp err_code:%s #meta_data_list:%s", err_code, TableUtil.CountTable(meta_data_list))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_prefab_mall_private_net = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private_net")
  logic_ugc_prefab_mall_private_net:RspPrefabMetaList(meta_data_list)
end
function UGCHandler.send_wow_get_my_private_prefab_bin_req(slot)
  log_format("UGCHandler.send_wow_get_my_private_prefab_bin_req slot:%s", slot)
  NetManager.SendPkg(287063563, slot)
end
function UGCHandler.on_wow_get_my_private_prefab_bin_rsp(err_code, slot, cur_fragment_index, cur_fragment_data, total_fragment_count)
  log_format("UGCHandler.on_wow_get_my_private_prefab_bin_rsp err_code:%s slot:%s cur_fragment_index:%s total_fragment_count:%s fragment_data_size:%s", err_code, slot, cur_fragment_index, total_fragment_count, cur_fragment_data and string.len(cur_fragment_data) or 0)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_prefab_mall_private_net = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private_net")
  logic_ugc_prefab_mall_private_net:RspSinglePrefabBin(slot, cur_fragment_index, total_fragment_count, cur_fragment_data)
end
function UGCHandler.send_wow_upload_private_prefab_req(trans_data)
  log_format("UGCHandler.send_wow_upload_private_prefab_req trans_data:%s", trans_data)
  NetManager.SendPkg(935380667, trans_data)
end
function UGCHandler.on_wow_upload_private_prefab_rsp(err_code, slot, new_edit_meta)
  log_format("UGCHandler.on_wow_upload_private_prefab_rsp err_code:%s slot:%s new_edit_meta:%s", err_code, slot, new_edit_meta)
  if err_code ~= 0 then
    if err_code == 511836 then
      ShowNotice(99010045)
    elseif err_code == 511837 then
      ShowNotice(18710135)
    elseif err_code == 511838 then
      ShowNotice(18710136)
    end
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PREFAB_MALL_PRIVATE_SAVE_UPDATE_FAIL, slot)
    return
  end
  local logic_ugc_prefab_mall_private_net = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private_net")
  logic_ugc_prefab_mall_private_net:RspSaveToMyPrivate(slot, new_edit_meta)
end
function UGCHandler.send_wow_delete_private_prefab_req(slot)
  log_format("UGCHandler.send_wow_delete_private_prefab_req slot:%s", slot)
  NetManager.SendPkg(865743795, slot)
end
function UGCHandler.on_wow_delete_private_prefab_rsp(err_code, slot)
  log_format("UGCHandler.on_wow_delete_private_prefab_rsp err_code:%s slot:%s", err_code, slot)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_prefab_mall_private_net = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private_net")
  logic_ugc_prefab_mall_private_net:RsqDelFromMyPrivate(slot)
end
function UGCHandler.send_wow_modify_private_prefab_meta_req(slot, modify_data)
  log_format("UGCHandler.send_wow_modify_private_prefab_meta_req slot:%s modify_data:%s", slot, modify_data)
  NetManager.SendPkg(1091503271, slot, modify_data)
end
function UGCHandler.on_wow_modify_private_prefab_meta_rsp(err_code, slot, new_edit_meta)
  log_format("UGCHandler.on_wow_modify_private_prefab_meta_rsp err_code:%s slot:%s new_edit_meta%s", err_code, slot, new_edit_meta)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_prefab_mall_private_net = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private_net")
  logic_ugc_prefab_mall_private_net:RsqModifyMetaInfo(err_code == 0, slot, new_edit_meta)
end
function UGCHandler.send_ugc_get_match_offline_data_req()
  NetManager.SendPkg(1786144039)
end
function UGCHandler.on_ugc_get_match_offline_data_rsp(err_code, offline_data_list)
  if err_code ~= 0 then
    return
  end
  local Logic_UGC_SeasonTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season_template)
  Logic_UGC_SeasonTemplate:SetMatchOfflineData(offline_data_list)
end
function UGCHandler.send_update_old_private_prefab_meta_req(slot, params, prefab_type, version)
  log_format("UGCHandler.send_wow_modify_private_prefab_meta_req slot:%s params:%s prefab_type:%s version:%s", slot, params, prefab_type, version)
  NetManager.SendPkg(1056367879, slot, params, prefab_type, version)
end
function UGCHandler.on_update_old_private_prefab_meta_rsp(err_code, slot, new_edit_meta)
  log_format("UGCHandler.on_update_old_private_prefab_meta_rsp err_code:%s slot:%s new_edit_meta%s", err_code, slot, new_edit_meta)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_prefab_mall_private_net = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private_net")
  logic_ugc_prefab_mall_private_net:RspModifyOldMeta(slot, new_edit_meta)
end
function UGCHandler.send_ugc_buy_mod_item_req(mod_id, market_id, item_id, buy_count, ext_info)
  log_format("UGCHandler.send_ugc_buy_mod_item_req mod_id:%s market_id:%s item_id:%s buy_count:%s", mod_id, market_id, item_id, buy_count)
  NetManager.SendPkg(47036071, mod_id, market_id, item_id, buy_count, ext_info)
end
function UGCHandler.on_ugc_buy_mod_item_rsp(err, the_depot_data, cb_param)
  log_format("UGCHandler.on_ugc_buy_mod_item_rsp err:%s", err)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local LogicUGCPropShop = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_propshop)
  LogicUGCPropShop:RspBuyModProp(the_depot_data, cb_param)
end
function UGCHandler.send_ugc_use_mod_item_req(mod_id, item_id, use_count, ext_info)
  log_format("UGCHandler.send_ugc_use_mod_item_req mod_id:%s item_id:%s use_count:%s", mod_id, item_id, use_count)
  NetManager.SendPkg(1449236263, mod_id, item_id, use_count, ext_info)
end
function UGCHandler.on_ugc_use_mod_item_rsp(err, the_depot_data)
  log_format("UGCHandler.on_ugc_use_mod_item_rsp err:%s", err)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local LogicUGCPropShop = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_propshop)
  LogicUGCPropShop:RspUseModProp(the_depot_data)
end
function UGCHandler.send_ugc_get_mod_item_req(mod_id, ext_info)
  log_format("UGCHandler.send_ugc_get_mod_item_req mod_id:%s", mod_id)
  NetManager.SendPkg(179695783, mod_id, ext_info)
end
function UGCHandler.on_ugc_get_mod_item_rsp(err, the_depot_data, cb_param)
  log_format("UGCHandler.on_ugc_get_mod_item_rsp err:%s", err)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local LogicUGCPropShop = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_propshop)
  LogicUGCPropShop:RspGetModProp(the_depot_data, cb_param)
end
function UGCHandler.SetThemePlayActivityTemplatePanelActive(bActive)
  UGCHandler._bThemePlayActivityTemplatePanelActive = bActive and true or false
end
function UGCHandler.send_ugc_get_my_match_list_req(match_hub_id, reqTarget)
  reqTarget = reqTarget or UGCHandler.Enum_UGC_MatchListReqTarget.SeasonTemplate
  table.insert(UGCHandler._UGCMatchListReqQueue, reqTarget)
  log(bWriteLog and "UGCHandler.send_ugc_get_my_match_list_req match_hub_id = " .. tostring(match_hub_id) .. " reqTarget = " .. tostring(reqTarget))
  NetManager.SendPkg(1420766819, match_hub_id)
end
function UGCHandler.on_ugc_get_my_match_list_rsp(err_code, match_ids)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "UGCHandler.on_ugc_get_my_match_list_rsp match_ids = ", match_ids)
  local reqTarget = table.remove(UGCHandler._UGCMatchListReqQueue, 1) or UGCHandler.Enum_UGC_MatchListReqTarget.SeasonTemplate
  if reqTarget == UGCHandler.Enum_UGC_MatchListReqTarget.ThemePlayActivityTemplate then
    if UGCHandler._bThemePlayActivityTemplatePanelActive then
      local Logic_UGC_ThemePlay_ActivityTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_theme_play_activity_template)
      Logic_UGC_ThemePlay_ActivityTemplate:SetMyMatchList(match_ids)
    end
    return
  end
  local Logic_UGC_SeasonTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season_template)
  Logic_UGC_SeasonTemplate:SetMyMatchList(match_ids)
end
function UGCHandler.send_ugc_exchange_advanced_crystal_by_uc_req(exchange_count, ext_info)
  log_format("UGCHandler.send_ugc_exchange_advanced_crystal_by_uc_req exchange_count:%s", exchange_count)
  NetManager.SendPkg(1827106347, exchange_count, ext_info)
end
function UGCHandler.on_ugc_exchange_advanced_crystal_by_uc_rsp(err, exchange_count)
  log_format("UGCHandler.on_ugc_exchange_advanced_crystal_by_uc_rsp err:%s exchange_count:%s", err, exchange_count)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local LogicUGCPropShop = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_propshop)
  LogicUGCPropShop:RspExchangeAdvancedCrystalByUC(exchange_count)
end
function UGCHandler.send_ugc_play_hall_filter_req(condition)
  NetManager.SendPkg(974559207, condition)
end
function UGCHandler.on_ugc_play_hall_filter_rsp(err, ret_info)
  log_tree(bWriteLog and "UGCHandler.on_ugc_play_hall_quick_join_rsp room_info = ", room_info)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAYHALL_FILTER_RESPONSE, ret_info)
end
function UGCHandler.send_ugc_play_hall_quick_join_req(condition)
  NetManager.SendPkg(1206305895, condition)
end
function UGCHandler.on_ugc_play_hall_quick_join_rsp(err, room_info)
  log_tree(bWriteLog and "UGCHandler.on_ugc_play_hall_quick_join_rsp room_info = ", room_info)
  local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
  UGCPlayHallRoom.BackToLobbyIfSuccess = true
  if err == 0 then
    UGCPlayHallRoom:JoinPlayHallRoomRsp(err, room_info)
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAYHALL_QUICK_JOIN_RESPONSE, room_info)
  else
    ShowNotice(err)
  end
end
function UGCHandler.send_batch_get_play_hall_info_req(ph_room_svr_id, ph_room_id_list)
  NetManager.SendPkg(1411922151, ph_room_svr_id, ph_room_id_list)
end
function UGCHandler.on_batch_get_play_hall_info_rsp(err, ret_info)
  log_tree(bWriteLog and "UGCHandler.on_batch_get_play_hall_info_rsp ret_info = ", ret_info)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAYHALL_MEMBER_RESPONSE, ret_info)
end
function UGCHandler.send_ugc_llm_chat_save_report_req(report_info)
  NetManager.SendPkg(2034706663, report_info)
end
function UGCHandler.on_ugc_llm_chat_save_report_rsp(err_code)
  log_tree(bWriteLog and "UGCHandler.on_ugc_llm_chat_save_report_rsp err_code = ", err_code)
end
function UGCHandler.send_ugc_get_review_panel_info_req()
  log(bWriteLog and "UGCHandler.send_ugc_get_review_panel_info_req")
  NetManager.SendPkg(477134279)
end
function UGCHandler.on_ugc_get_review_panel_info_rsp(err_code, info)
  log(bWriteLog and "UGCHandler.on_ugc_get_review_panel_info_rsp err_code = ", err_code)
  if err_code == 511919 then
    return
  elseif err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_APPRECIATIONGROUP_INFO, info)
end
function UGCHandler.send_ugc_join_review_panel_req()
  NetManager.SendPkg(59409627)
end
function UGCHandler.on_ugc_join_review_panel_rsp(err_code)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_JOIN_APPRECIATIONGROUP_SUCCESS)
end
function UGCHandler.send_ugc_take_review_panel_award_req(award_type, task_id)
  log_format("UGCHandler.send_ugc_take_review_panel_award_req award_type:%s task_id:%s", award_type, task_id)
  NetManager.SendPkg(119965647, award_type, task_id or 0)
end
function UGCHandler.on_ugc_take_review_panel_award_rsp(err_code, award_type, task_id, award_list, award_info)
  log_format("UGCHandler.on_ugc_take_review_panel_award_rsp err_code:%s award_type:%s task_id:%s", err_code, award_type, task_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_APPRECIATION_TAKE_AWARD_RSP, err_code, award_type, task_id, award_list, award_info)
end
function UGCHandler.send_wow_batch_delete_private_prefab_req(slot_list)
  NetManager.SendPkg(569326183, slot_list)
end
function UGCHandler.on_wow_batch_delete_private_prefab_rsp(err, slot_res)
  log_format("UGCHandler.on_wow_batch_delete_private_prefab_rsp err:%s", err)
  if err ~= 0 then
    return
  end
  local logic_ugc_prefab_mall_private_net = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private_net")
  logic_ugc_prefab_mall_private_net:RspBatchDelFromMyPrivate(slot_res)
end
function UGCHandler.send_wow_upload_local_file_req(params)
  log_format("UGCHandler.send_wow_upload_local_file_req params:%s", params)
  NetManager.SendPkg(2112830347, params)
end
function UGCHandler.on_wow_upload_local_file_rsp(err_code, slot, new_edit_meta, ban_time, min_level)
  log_format("UGCHandler.on_wow_upload_local_file_rsp err_code:%s slot:%s new_edit_meta:%s ban_time:%s min_level:%s", err_code, slot, new_edit_meta, ban_time, min_level)
  if err_code ~= 0 then
    if err_code == 8880146 then
      ShowNotice(99010065)
    else
      ShowNotice(err_code)
    end
    return
  end
  local logic_ugc_prefab_mall_private_net = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private_net")
  logic_ugc_prefab_mall_private_net:RspUploadToMyPrivate(slot, new_edit_meta)
end
function UGCHandler.on_notify_update_private_prefab_status(slot, edit_prefab_meta)
  local logic_ugc_prefab_mall_private_net = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private_net")
  logic_ugc_prefab_mall_private_net:RspNotifyUpdate(slot, edit_prefab_meta)
end
function UGCHandler.send_ugc_get_review_panel_comment_info_req(mod_id)
  NetManager.SendPkg(552070151, mod_id)
end
function UGCHandler.on_ugc_get_review_panel_comment_info_rsp(err_code, mod_id, comment_list)
  local logic_ugc_work_detail_featured_comment = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_work_detail_featured_comment)
  logic_ugc_work_detail_featured_comment:on_ugc_get_review_panel_comment_info_rsp(mod_id, comment_list)
end
function UGCHandler.send_wow_good_mod_of_template_req()
  log("UGCHandler.send_wow_good_mod_of_template_req")
  NetManager.SendPkg(326027047)
end
function UGCHandler.on_wow_good_mod_of_template_rsp(err_code, ret_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicUGCTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
  log_tree(bWriteLog and "UGCHandler.on_wow_good_mod_of_template_rsp", ret_list)
  LogicUGCTemplate:RspGoodModOfTemplate(ret_list)
end
function UGCHandler.send_ugc_review_panel_comment_req(mod_id, comment_data)
  NetManager.SendPkg(933714919, mod_id, comment_data)
end
function UGCHandler.on_ugc_review_panel_comment_rsp(err_code, mod_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_APPRECIATIONGROUP_EVALUATE_SUCCESS, mod_id)
end
function UGCHandler.send_wow_is_upload_local_file_open_req(asset_type)
  NetManager.SendPkg(501174483, asset_type)
end
function UGCHandler.on_wow_is_upload_local_file_open_rsp(err_code, ban_time, min_openlevel)
  local CreativeModePrefabMallUploadUtils = require("client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallUploadUtils")
  CreativeModePrefabMallUploadUtils.OnCheckUploadAuthority(err_code, ban_time, min_openlevel)
end
function UGCHandler.send_wow_get_upload_file_limits_req(custom_asset_types)
  NetManager.SendPkg(196574535, custom_asset_types)
end
function UGCHandler.on_wow_get_upload_file_limits_rsp(err, wow_upload_file_limit, limit_configs)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_ugc_prefab_mall_private = require("client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_private")
  logic_ugc_prefab_mall_private:SetUploadFileLimitsInfo(wow_upload_file_limit, limit_configs)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_CUSTOM_ASSET_UPLOAD_FILE_LIMITS_INFO_UPDATE)
end
function UGCHandler.send_ugc_review_panel_del_comment_req(mod_id)
  NetManager.SendPkg(80555559, mod_id)
end
function UGCHandler.on_ugc_review_panel_del_comment_rsp(err_code, mod_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_work_detail_featured_comment = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_work_detail_featured_comment)
  logic_ugc_work_detail_featured_comment:on_ugc_review_panel_del_comment_rsp(mod_id)
end
function UGCHandler.send_ugc_review_panel_top_comment_req(mod_id, comment_uid, opt_type)
  log("UGCHandler.send_ugc_review_panel_top_comment_req")
  NetManager.SendPkg(1800651559, mod_id, comment_uid, opt_type)
end
function UGCHandler.on_ugc_review_panel_top_comment_rsp(err_code, mod_id, comment_uid, opt_type, old_comment_uid)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_work_detail_featured_comment = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_work_detail_featured_comment)
  logic_ugc_work_detail_featured_comment:on_ugc_review_panel_top_comment_rsp(mod_id, comment_uid, opt_type, old_comment_uid)
end
function UGCHandler.send_ugc_review_panel_reply_comment_req(mod_id, comment_uid, reply_content)
  log("UGCHandler.send_ugc_review_panel_reply_comment_req")
  NetManager.SendPkg(378185479, mod_id, comment_uid, reply_content)
end
function UGCHandler.on_ugc_review_panel_reply_comment_rsp(err_code, mod_id, comment_uid, author_reply_content)
  if err_code ~= 0 then
    ShowNotice(tostring(err_code))
    return
  end
  local logic_ugc_work_detail_featured_comment = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_work_detail_featured_comment)
  logic_ugc_work_detail_featured_comment:on_ugc_review_panel_reply_comment_rsp(mod_id, comment_uid, author_reply_content)
end
function UGCHandler.send_ugc_review_panel_del_reply_comment_req(mod_id, comment_uid)
  log("UGCHandler.send_ugc_review_panel_del_reply_comment_req")
  NetManager.SendPkg(120914695, mod_id, comment_uid)
end
function UGCHandler.on_ugc_review_panel_del_reply_comment_rsp(err_code, mod_id, comment_uid)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_work_detail_featured_comment = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_work_detail_featured_comment)
  logic_ugc_work_detail_featured_comment:on_ugc_review_panel_del_reply_comment_rsp(mod_id, comment_uid)
end
function UGCHandler.send_ugc_review_panel_support_comment_req(mod_id, comment_uid, opt_type, opt_obj)
  log("UGCHandler.send_ugc_review_panel_support_comment_req")
  NetManager.SendPkg(776183079, mod_id, comment_uid, opt_type, opt_obj)
end
function UGCHandler.on_ugc_review_panel_support_comment_rsp(err_code, mod_id, comment_uid, opt_type, opt_obj, support_timestamp)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_work_detail_featured_comment = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_work_detail_featured_comment)
  logic_ugc_work_detail_featured_comment:on_ugc_review_panel_support_comment_rsp(mod_id, comment_uid, opt_type, opt_obj, support_timestamp)
end
function UGCHandler.send_ugc_report_item_req(report_info)
  NetManager.SendPkg(2090017651, report_info)
end
function UGCHandler.on_ugc_report_item_rsp(err_code)
  if err_code == 0 then
    ShowNotice(1050490)
  else
    ShowNotice(err_code)
  end
end
function UGCHandler.send_ugc_get_match_history_req(count, mod_id)
  NetManager.SendPkg(1285545127, count, mod_id)
end
function UGCHandler.on_ugc_get_match_history_rsp(ret, match_list, mod_id)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  local Logic_UGC_Mod_PlayHistory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mod_play_history)
  if Logic_UGC_Mod_PlayHistory then
    Logic_UGC_Mod_PlayHistory:OnWowPlayHistoryRsp(match_list)
  end
end
function UGCHandler.send_wow_query_newbie_guide_data_req()
  NetManager.SendPkg(1594233271)
end
function UGCHandler.on_wow_query_newbie_guide_data_rsp(err_code, newbie_mod_data, newbie_history_mod)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_ugc_new_process = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_process)
  logic_ugc_new_process:on_wow_query_newbie_guide_data_rsp(newbie_mod_data, newbie_history_mod)
end
function UGCHandler.send_ugc_exit_review_panel_req()
  NetManager.SendPkg(390085955)
end
function UGCHandler.on_ugc_exit_review_panel_rsp(err_code)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
end
function UGCHandler.send_free_inout_apply_req(respondent_uid, from_type)
  NetManager.SendPkg(1271528295, respondent_uid, from_type)
end
function UGCHandler.on_free_inout_apply_rsp(err, respondent_uid, from_type)
  if err == 0 then
  else
    ShowNotice(err)
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_FREE_INOUT_APPLY_RSP, err, respondent_uid, from_type)
end
function UGCHandler.send_free_inout_enter_req(mod_id, game_id, play_zone, from_type)
  NetManager.SendPkg(447813991, mod_id, game_id, play_zone, from_type)
end
function UGCHandler.on_free_inout_enter_rsp(err_code, mod_id, game_id, play_zone, from_type)
  if err_code ~= 0 then
    ShowNotice(err_code)
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_FREE_INOUT_ENTER_RSP, err_code, mod_id, game_id, play_zone, from_type)
end
function UGCHandler.send_free_inout_invite_req(invitee_uid)
  NetManager.SendPkg(798144107, invitee_uid)
end
function UGCHandler.on_free_inout_invite_rsp(res, uid, invitee_uid)
end
function UGCHandler.on_free_inout_invite_notify(inviter_uid, free_inout_info)
end
function UGCHandler.send_ugc_get_review_history_req()
  NetManager.SendPkg(1592357831)
end
function UGCHandler.on_ugc_get_review_history_rsp(err, history_list)
  if err ~= 0 then
    ShowNotice(err)
  end
  local logic_ugc_appreciation = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_ugc_appreciation_group)
  logic_ugc_appreciation:on_ugc_get_review_history_rsp(err, history_list)
end
function UGCHandler.send_batch_take_wow_play_activity_award_req(sub_activity_list)
  NetManager.SendPkg(1446367719, sub_activity_list)
end
function UGCHandler.on_batch_take_wow_play_activity_award_rsp(err, data_list)
  if err ~= 0 then
    ShowNotice(err)
  end
  local Logic_UGC_ThemePlay_ActivityTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_theme_play_activity_template)
  Logic_UGC_ThemePlay_ActivityTemplate:batch_take_wow_play_activity_award_rsp(data_list)
end
function UGCHandler.send_wow_upload_temp_prefab_req(object_key)
  log_format("send_wow_upload_temp_prefab_req: %s", object_key)
  NetManager.SendPkg(2047046567, object_key)
end
function UGCHandler.on_wow_upload_temp_prefab_rsp(err, object_key, custom_asset_key)
  log_format("on_wow_upload_temp_prefab_rsp: %s, %s, %s", err, object_key, custom_asset_key)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PREFAB_MALL_ANALYSIS_TEMP_ASSET_COMPLETE, object_key, custom_asset_key, err)
end
function UGCHandler.send_ugc_report_res_bitmap_req(bitmap_data, bitmap_bit_count)
  log(bWriteLog and "send_ugc_report_res_bitmap_req bitmap_data = " .. tostring(bitmap_data) .. " bitmap_bit_count = " .. tostring(bitmap_bit_count))
  NetManager.SendPkg(167082428, bitmap_data, bitmap_bit_count)
end
local reqRsp = {
  send_ugc_promotion_record_req = "on_ugc_promotion_record_rsp",
  send_ugc_promotion_use_item_req = "on_ugc_promotion_use_item_rsp",
  send_ugc_report_promotion_view_req = "on_ugc_report_promotion_view_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, UGCHandler)
return UGCHandler