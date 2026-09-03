local NetManager = require("client.network.comm.NetManager")
local SettingHandler = {}
function SettingHandler.send_query_custom_setting(slotType)
  NetManager.SendPkg(992897153, slotType)
end
function SettingHandler.on_sync_custom_setting(setting_info, slotType, setting_ver_info)
  local SettingSystem = require("client.logic.setting.logic_setting")
  SettingSystem.sync_custom_setting(setting_info, slotType, setting_ver_info)
end
function SettingHandler.send_switch_krjp_match_cross(switch)
  NetManager.SendPkg(295732190, switch)
end
function SettingHandler.on_switch_krjp_match_cross_rsp(res, switch)
  if res == 0 then
    DataMgr.JPKRMatchServerOn = switch
    log(bWriteLog and "SettingHandler.on_switch_krjp_match_cross_rsp switch:" .. tostring(switch))
    if switch then
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eJPKRMatchServer)
      saveData = saveData or {}
      saveData.last_match_time = 0
      PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eJPKRMatchServer)
    end
  else
    log(bWriteLog and "SettingHandler.on_switch_krjp_match_cross_rsp res:" .. tostring(res))
  end
end
function SettingHandler.send_on_krjp_match_across_zone_req()
  NetManager.SendPkg(567095570)
end
function SettingHandler.send_save_player_custom_data_to_battle_req(table)
  NetManager.SendPkg(2080782622, table)
end
function SettingHandler.send_save_custom_setting(setting_info, operType, slotType)
  NetManager.SendPkg(1939980124, setting_info, operType, slotType)
end
function SettingHandler.on_save_custom_setting_rsp(result, operType, slotType)
  local logic_setting = require("client.logic.setting.logic_setting")
  logic_setting.save_custom_setting_rsp(result, operType, slotType)
end
function SettingHandler.send_dirty_name_check_req(newName, reason)
  NetManager.SendPkg(1712925799, newName, reason)
end
function SettingHandler.on_dirty_name_check_rsp(result)
  local logic_setting = require("client.logic.setting.logic_setting")
  logic_setting.dirty_name_check_rsp(result)
end
function SettingHandler.send_get_guide_pic_cfg()
  NetManager.SendPkg(1057492478)
end
function SettingHandler.on_get_guide_pic_cfg_rsp(cfg)
  local logic_setting = require("client.logic.setting.logic_setting")
  logic_setting.get_guide_pic_cfg_rsp(cfg)
end
function SettingHandler.send_query_custom_sensitive()
  NetManager.SendPkg(1043127241)
end
function SettingHandler.on_sync_custom_sensitive(sen_info)
  local LogicGlobalSensitivity = require("client.logic.setting.logic_setting_global_sensitivity")
  sen_info = LogicGlobalSensitivity.PreprocessCloudSetting(sen_info)
  local SettingCloudHelper = require("client.logic.setting.SettingCloudHelper")
  SettingCloudHelper.OnReceiveCloudData(sen_info)
end
function SettingHandler.send_save_custom_sensitive(sen_info)
  NetManager.SendPkg(160921204, sen_info)
end
function SettingHandler.on_save_custom_sensitive_rsp(error_code)
  local LogicGlobalSensitivity = require("client.logic.setting.logic_setting_global_sensitivity")
  LogicGlobalSensitivity.OnUploadCloud(error_code)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_UPLOAD_SUCCESS)
end
function SettingHandler.send_gen_sensitive_share_req()
  NetManager.SendPkg(2062949111)
end
function SettingHandler.on_gen_sensitive_share_rsp(result, share_code)
  local SettingCloudSensitivityShare = require("client.slua.logic.setting.logic_cloud_sensitivity_share")
  SettingCloudSensitivityShare.GenerateShareCodeRsp(result, share_code)
end
function SettingHandler.send_confirm_sensitive_share_req(share_code, finger, device, setting_info)
  NetManager.SendPkg(1558596799, share_code, finger, device, setting_info)
end
function SettingHandler.on_confirm_sensitive_share_rsp(result)
  local logic_setting = require("client.logic.setting.logic_setting")
  logic_setting.confirm_sensitive_share_rsp(result)
end
function SettingHandler.send_query_other_sensitive_req(share_code, is_cross_req)
  NetManager.SendPkg(955037187, share_code, is_cross_req)
end
function SettingHandler.on_query_other_sensitive_rsp(result, sensitivity_setting)
  local logic_setting = require("client.logic.setting.logic_setting")
  logic_setting.query_other_sensitive_rsp(result, sensitivity_setting)
end
function SettingHandler.send_set_lang_req(language)
  NetManager.SendPkg(899346076, language)
end
function SettingHandler.send_gen_csetting_share_req(slotType)
  NetManager.SendPkg(1422830343, slotType)
end
function SettingHandler.on_gen_csetting_share_rsp(result, code)
  local logic_setting = require("client.logic.setting.logic_setting")
  logic_setting.gen_csetting_share_rsp(result, code)
end
function SettingHandler.send_confirm_csetting_share_req(share_code, firemode, finger, slotType, setting_info)
  NetManager.SendPkg(229597639, share_code, firemode, finger, slotType, setting_info)
end
function SettingHandler.on_confirm_csetting_share_rsp(result, setting_info)
  local logic_setting = require("client.logic.setting.logic_setting")
  logic_setting.confirm_csetting_share_rsp(result, setting_info)
end
function SettingHandler.send_query_other_csetting_req(firemode, share_code, is_cross_req)
  NetManager.SendPkg(442742375, firemode, share_code, is_cross_req)
end
function SettingHandler.on_query_other_csetting_rsp(result, setting_info)
  local logic_setting = require("client.logic.setting.logic_setting")
  logic_setting.query_other_csetting_rsp(result, setting_info)
end
function SettingHandler.send_log_sensitivity_settings(sens_type, sens_info)
  NetManager.SendPkg(734116072, sens_type, sens_info)
end
function SettingHandler.on_on_krjp_match_across_zone_res(res)
end
function SettingHandler.send_set_avatar_privacy_policy(flag)
  NetManager.SendPkg(552127012, flag)
end
function SettingHandler.on_set_avatar_privacy_policy_rsp(err_code)
  log(bWriteLog and "[v_wllwu] SettingHandler.on_set_avatar_privacy_policy_rsp = " .. tostring(err_code))
end
function SettingHandler.send_save_weapon_settings_req(sensitivity_setting, type, sub_type)
  NetManager.SendPkg(734985703, sensitivity_setting, type, sub_type)
end
function SettingHandler.on_save_weapon_settings_rsp(err_code)
  print(bWriteLog and "SettingHandler.on_save_weapon_settings_rsp " .. tostring(err_code))
  if err_code == 0 then
    if BP_Setting_UploadType == 1 then
      local LogicCustomSensitivity = require("client.logic.setting.logic_setting_custom_sensitivity")
      LogicCustomSensitivity.OnUploadCloud()
    elseif BP_Setting_UploadType == 2 then
      local LogicCustomAccessories = require("client.logic.setting.logic_setting_custom_accessiores")
      LogicCustomAccessories.OnUploadCloud()
    end
  else
    ShowNotice(9645)
  end
end
function SettingHandler.send_query_weapon_settings_req(type)
  NetManager.SendPkg(99414999, type)
end
function SettingHandler.on_query_weapon_settings_rsp(type, data)
  local SettingCloudHelper = require("client.logic.setting.SettingCloudHelper")
  data = SettingCloudHelper.PreprocessGunData(data)
  SettingCloudHelper.OnReceiveCloudData(data)
end
function SettingHandler.send_gun_accessories_setting(count_info)
  NetManager.SendPkg(1040410178, count_info)
end
function SettingHandler.send_gun_sensitivity_setting(type, count_info)
  NetManager.SendPkg(496271699, type, count_info)
end
function SettingHandler.send_gen_weapon_sens_share_req()
  NetManager.SendPkg(1006464495)
end
function SettingHandler.on_gen_weapon_sens_share_rsp(error_code, share_code)
  local SettingCloudSensitivityShare = require("client.slua.logic.setting.logic_cloud_sensitivity_share")
  SettingCloudSensitivityShare.GenerateShareCodeRsp(error_code, share_code)
end
function SettingHandler.send_confirm_weapon_sens_share_req(share_code, finger, device, settings)
  NetManager.SendPkg(229685959, share_code, finger, device, settings)
end
function SettingHandler.on_confirm_weapon_sens_share_rsp(error_code)
  local logic_setting = require("client.logic.setting.logic_setting")
  logic_setting.confirm_sensitive_share_rsp(error_code)
end
function SettingHandler.send_query_other_weapon_sens_req(share_code, is_cross_req)
  NetManager.SendPkg(1956204651, share_code, is_cross_req)
end
function SettingHandler.on_query_other_weapon_sens_rsp(error_code, sensitivity_setting)
  local logic_setting = require("client.logic.setting.logic_setting")
  logic_setting.query_other_sensitive_rsp(error_code, sensitivity_setting)
end
function SettingHandler.send_gen_weapon_part_share_req()
  NetManager.SendPkg(325582127)
end
function SettingHandler.on_gen_weapon_part_share_rsp(error_code, share_code)
  local SettingCloudSensitivityShare = require("client.slua.logic.setting.logic_cloud_sensitivity_share")
  SettingCloudSensitivityShare.GenerateShareCodeRsp(error_code, share_code)
end
function SettingHandler.send_confirm_weapon_part_share_req(share_code, settings)
  NetManager.SendPkg(604717447, share_code, settings)
end
function SettingHandler.on_confirm_weapon_part_share_rsp(error_code)
  local logic_setting = require("client.logic.setting.logic_setting")
  logic_setting.confirm_sensitive_share_rsp(error_code)
end
function SettingHandler.send_query_other_weapon_part_req(share_code, is_cross_req)
  NetManager.SendPkg(746488363, share_code, is_cross_req)
end
function SettingHandler.on_query_other_weapon_part_rsp(error_code, sensitivity_setting)
  local logic_setting = require("client.logic.setting.logic_setting")
  logic_setting.query_other_sensitive_rsp(error_code, sensitivity_setting)
end
function SettingHandler.send_notify_click_gun_setting(type)
  NetManager.SendPkg(1844297994, type)
end
function SettingHandler.send_get_setting_label_req()
  NetManager.SendPkg(1445492083)
end
function SettingHandler.on_get_setting_label_rsp(res, label_data)
  local settingRedManager = require("client.slua.logic.setting.setting_redpoint_manager")
  settingRedManager.OnGetRedPointCfg(label_data)
end
function SettingHandler.send_update_setting_label_req(tab_id, label_id)
  NetManager.SendPkg(1745228327, tab_id, label_id)
end
function SettingHandler.on_update_setting_label_rsp(res)
end
function SettingHandler.send_log_status_flow(name, status)
  NetManager.SendPkg(57864280, name, status)
end
function SettingHandler.send_log_keys_setting_flow(info, report_type)
  NetManager.SendPkg(527056391, info, report_type)
end
function SettingHandler.send_common_setting_status_flow(tab_id, status)
  NetManager.SendPkg(2143938000, tab_id, status)
end
function SettingHandler.send_get_birthday_privacy_req()
  log(bWriteLog and "SettingHandler.send_get_birthday_privacy_req")
  NetManager.SendPkg(1647835495)
end
function SettingHandler.on_get_birthday_privacy_rsp(switch)
  log(bWriteLog and "SettingHandler.on_get_birthday_privacy_rsp switch = " .. tostring(switch))
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.ShowBirthdaySwitch = switch
end
function SettingHandler.send_set_birthday_privacy_req(switch)
  log(bWriteLog and "SettingHandler.send_get_birthday_privacy_req switch = " .. tostring(switch))
  SettingHandler.reqBirthdayPrivacySwitch = switch
  NetManager.SendPkg(37174119, switch)
end
function SettingHandler.on_set_birthday_privacy_rsp(errorCode)
  log(bWriteLog and "SettingHandler.on_set_birthday_privacy_rsp errorCode = " .. errorCode)
  if errorCode ~= 0 then
    ShowNotice(33710)
    return
  end
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.ShowBirthdaySwitch = SettingHandler.reqBirthdayPrivacySwitch
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_BIRTHDAY)
end
function SettingHandler.send_set_recommend_open_req(type, is_open)
  NetManager.SendPkg(108749319, type, is_open)
end
function SettingHandler.on_set_recommend_open_rsp(err, type, is_open)
  if err == 0 then
    local logic_setting_recommended = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setting_recommended)
    logic_setting_recommended:UpdateSwitchWithType(type, is_open)
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_SHOW_RECOMMENDED_UPDATE)
  else
    ShowNotice(33710)
  end
end
function SettingHandler.send_get_recommend_open_req()
  NetManager.SendPkg(1505454215)
end
function SettingHandler.on_get_recommend_open_rsp(switchList)
  local logic_setting_recommended = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setting_recommended)
  logic_setting_recommended:UpdateSwitchList(switchList)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_SHOW_RECOMMENDED_UPDATE)
end
function SettingHandler.send_save_custom_settings_new_req(page_name, settings)
  NetManager.SendPkg(1185075431, page_name, settings)
end
function SettingHandler.on_save_custom_settings_new_rsp(err_code, page_name, settings)
  log(bWriteLog and string.format("SettingHandler:on_save_custom_settings_new_rsp err_code[%s] page_name[%s] setting[%s]", tostring(err_code), tostring(page_name), tostring(settings)))
  local SettingSystem = require("client.logic.setting.logic_setting")
  if page_name == "Setting_Basic" then
    local TimeUtil = require("client.common.time_util")
    SettingSystem.last_save_setting_basic_tm = TimeUtil.GetTodayStartTimestamp()
    if err_code == 0 then
      ShowNotice(9644)
    else
      ShowNotice(9645)
    end
  end
  if err_code == 0 then
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_ON_SAVE_CUSTOM_SETTING_NEW_RSP, page_name, settings)
  end
end
function SettingHandler.send_get_custom_settings_new_req(page_name)
  log(bWriteLog and "SettingHandler.send_get_custom_settings_new_req page_name = " .. page_name)
  NetManager.SendPkg(139830783, page_name)
end
function SettingHandler.on_get_custom_settings_new_rsp(err_code, page_name, settings)
  log(bWriteLog and "SettingHandler.on_get_custom_settings_new_rsp err_code = " .. err_code .. ", page_name = " .. tostring(page_name))
  if err_code == 0 then
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_ON_GET_CUSTOM_SETTING_NEW_RSP, page_name, settings)
    local SettingCloudHelper = require("client.logic.setting.SettingCloudHelper")
    SettingCloudHelper.OnReceiveCloudData(settings)
  end
end
function SettingHandler.send_get_lbs_privacy_req()
  log(bWriteLog and "SettingHandler.send_get_lbs_privacy_req")
  NetManager.SendPkg(1453125911)
end
function SettingHandler.on_get_lbs_privacy_rsp(switch)
  log(bWriteLog and "SettingHandler.on_get_lbs_privacy_rsp switch = " .. tostring(switch))
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.bLBSPlace = switch
end
function SettingHandler.send_set_lbs_privacy_req(switch)
  log(bWriteLog and "SettingHandler.send_set_lbs_privacy_req switch = " .. tostring(switch))
  SettingHandler.reqLBSPrivacySwitch = switch
  NetManager.SendPkg(1182963687, switch)
end
function SettingHandler.on_set_lbs_privacy_rsp(errorCode)
  log(bWriteLog and "SettingHandler.on_set_lbs_privacy_rsp errorCode = " .. errorCode)
  if errorCode ~= 0 then
    ShowNotice(33710)
    return
  end
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.bLBSPlace = SettingHandler.reqLBSPrivacySwitch
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_BLBSPLACE)
end
function SettingHandler.send_get_pspace_hidden_visitor_track()
  NetManager.SendPkg(737477748)
end
function SettingHandler.on_get_pspace_hidden_visitor_track(err_code, switch)
  if err_code ~= 0 then
    log(bWriteLog and "SettingHandler.on_get_pspace_hidden_visitor_track err_code = " .. tostring(err_code))
  end
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.on_get_pspace_hidden_visitor_track(switch)
end
function SettingHandler.send_set_pspace_hidden_visitor_track(switch)
  NetManager.SendPkg(2089198524, switch)
end
function SettingHandler.on_set_pspace_hidden_visitor_track(err_code, switch)
  if err_code ~= 0 then
    log(bWriteLog and "SettingHandler.on_set_pspace_hidden_visitor_track err_code = " .. tostring(err_code))
  end
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.on_set_pspace_hidden_visitor_track(switch)
end
function SettingHandler.send_reset_all_custom_settings_req()
  NetManager.SendPkg(212481527)
end
function SettingHandler.on_reset_all_custom_settings_rsp()
  print(bWriteLog and "SettingHandler.on_reset_all_custom_settings_rsp")
end
function SettingHandler.send_set_social_private_switch_req(switch, value)
  log(bWriteLog and "SettingHandler.send_set_social_private_switch_req switch = " .. switch .. ", value = " .. value)
  NetManager.SendPkg(1480651175, switch, value)
end
function SettingHandler.on_set_social_private_switch_rsp(errcode, switch, value)
  log(bWriteLog and "SettingHandler.on_set_social_private_switch_rsp errcode = " .. errcode .. ", switch = " .. switch .. ", value = " .. value)
  if errcode ~= 0 then
    ShowNotice(errcode)
    return
  end
  LobbySystem.roleData.social_private_data = LobbySystem.roleData.social_private_data or {}
  LobbySystem.roleData.social_private_data[switch] = value
  local Refresh = require("client.logic.setting.refresh.setting_refresh")
  Refresh.RefreshProfileShow("ProfileShow")
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_PROFILE_SHOW)
end
function SettingHandler.send_set_psmatch_view_pk_switch(switch)
  log(bWriteLog and "SettingHandler.send_set_psmatch_view_pk_switch switch = " .. switch)
  NetManager.SendPkg(323623372, switch)
end
function SettingHandler.on_set_psmatch_view_pk_switch_rsp(err_code, switch)
  log(bWriteLog and "SettingHandler.on_set_psmatch_view_pk_switch_rsp err_code = " .. err_code .. ", switch = " .. switch)
  if err_code ~= 0 then
    return
  end
  local logic_popular_gift_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_gift_pk)
  logic_popular_gift_pk:proc_view_pk_switch(switch)
end
function SettingHandler.send_get_peakgame_anchor_setting_req()
  log(bWriteLog and "SettingHandler.send_get_peakgame_anchor_setting_req ")
  NetManager.SendPkg(1154350895)
end
function SettingHandler.on_get_peakgame_anchor_setting_rsp(peakgame_anchor_setting)
  log(bWriteLog and "SettingHandler.on_get_peakgame_anchor_setting_rsp")
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  if peakgame_anchor_setting == nil then
    LogicPeakGame.isShowPeakGameHideNameSelection = false
  else
    log_tree("peakgame_anchor_setting = ", peakgame_anchor_setting)
    LogicPeakGame.isShowPeakGameHideNameSelection = true
    if next(peakgame_anchor_setting) == nil then
      LogicPeakGame.peakgameHideName = 0
    end
    if peakgame_anchor_setting and peakgame_anchor_setting.hide_name_switch then
      LogicPeakGame.peakgameHideName = peakgame_anchor_setting.hide_name_switch
    end
  end
end
function SettingHandler.send_set_peakgame_anchor_setting_req(hide_name_switch)
  log(bWriteLog and "SettingHandler.send_set_peakgame_anchor_setting_req hide_name_switch = " .. tostring(hide_name_switch))
  NetManager.SendPkg(997078655, hide_name_switch)
end
function SettingHandler.on_set_peakgame_anchor_setting_rsp(error_info, peakgame_anchor_setting)
  log(bWriteLog and "SettingHandler.on_set_peakgame_anchor_setting_rsp error_info = " .. tostring(error_info))
  if error_info ~= "ok" then
    ShowNotice(error_info)
  else
    local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
    if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
      return
    end
    ShowNotice(LocUtil.LocalizeResFormat(410004))
    LogicPeakGame.peakgameHideName = peakgame_anchor_setting.hide_name_switch
    if LogicPeakGame.peakgameHideName == 1 then
      LogicPeakGame:RequestNewAnchorName()
    end
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_PEAKGAME_HIDE_NAME)
  end
end
function SettingHandler.send_get_anchor_random_name(uid)
  log(bWriteLog and "SettingHandler.send_get_anchor_random_name uid = " .. uid)
  NetManager.SendPkg(782548364, uid)
end
function SettingHandler.on_get_anchor_random_name_rsp(uid, name)
  print(bWriteLog and "SettingHandler.on_get_anchor_random_name_rsp " .. "uid =" .. uid .. " name =" .. (name or "nil"))
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ANCHOR_NAME_RSP, uid, name)
end
function SettingHandler.send_gen_new_anchor_random_name(uid)
  NetManager.SendPkg(1910573356, uid)
end
function SettingHandler.on_gen_new_anchor_random_name_rsp(uid, err_code, name)
  print(bWriteLog and string.format("on_gen_new_anchor_random_name_rsp %d, %d, %s", uid, err_code, name))
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  if err_code and err_code == 0 then
    LogicPeakGame.peakgameHideName = 1
    LogicPeakGame.peakgame_anchorName = name
  elseif err_code and err_code == -1 then
    LogicPeakGame.peakgameHideName = 0
    LogicPeakGame.peakgame_anchorName = ""
  elseif err_code and err_code == -2 then
    LogicPeakGame.peakgameHideName = 0
    LogicPeakGame.peakgame_anchorName = ""
    LogicPeakGame.isShowPeakGameHideNameSelection = false
  end
end
function SettingHandler.send_set_screen_resolution_req(device_model, width, height, scale)
  NetManager.SendPkg(1555227899, device_model, width, height, scale)
end
function SettingHandler.on_set_screen_resolution_rsp(err_code)
end
function SettingHandler.send_get_all_screen_resolutions_req()
  NetManager.SendPkg(824944743)
end
function SettingHandler.on_get_all_screen_resolutions_rsp(err_code, screen_resolution)
  print(bWriteLog and "SettingHandler.on_get_all_screen_resolutions_rsp")
  local math_abs = math.abs
  local FoundData = false
  local UIUtil = require("client.common.ui_util")
  local UIViewportSize = UIUtil.GetViewportSize()
  local CurrentWidth = UIViewportSize.X
  local CurrentHeight = UIViewportSize.Y
  local CurrentScale = UIUtil.GetViewportScale()
  if Client.GetDeviceModel() == "" then
    print(bWriteLog and "SettingHandler.on_get_all_screen_resolutions_rsp device is not iOS or Android, Skip")
    return
  end
  if screen_resolution and type(screen_resolution) == "table" then
    for DeviceModel, Data in pairs(screen_resolution) do
      if DeviceModel == Client.GetDeviceModel() then
        Found        break
      end
    end
  end
  if FoundData then
    print(bWriteLog and "SettingHandler.on_get_all_screen_resolutions_rsp same model found " .. Client.GetDeviceModel())
    if math_abs(FoundData.width - CurrentWidth) > 0.1 or 0.1 < math_abs(FoundData.height - CurrentHeight) or math_abs(FoundData.scale - CurrentScale) > 1.0E-4 then
      print(bWriteLog and string.format("SettingHandler.on_get_all_screen_resolutions_rsp former: %f %f %.4f current: %f %f %.4f", FoundData.width, FoundData.height, FoundData.scale, CurrentWidth, CurrentHeight, CurrentScale))
      SettingHandler.send_set_screen_resolution_req(Client.GetDeviceModel(), CurrentWidth, CurrentHeight, tonumber(string.format("%.4f", CurrentScale)))
      local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
      WidgetLayoutLibrary.SetOriginalViewPortSizeXY(math.floor(FoundData.width), math.floor(FoundData.height))
    else
      local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
      WidgetLayoutLibrary.SetOriginalViewPortSizeXY(math.floor(FoundData.width), math.floor(FoundData.height))
      return
    end
  else
    print(bWriteLog and "SettingHandler.on_get_all_screen_resolutions_rsp new model added")
    SettingHandler.send_set_screen_resolution_req(Client.GetDeviceModel(), CurrentWidth, CurrentHeight, tonumber(string.format("%.4f", CurrentScale)))
  end
end
function SettingHandler.on_notify_ally_ai_takeover_zones(zone_id_list)
  if zone_id_list ~= nil then
    SettingHandler.ally_ai_takeover_zones = zone_id_list
    log_tree("SettingHandler.on_notify_ally_ai_takeover_zones", zone_id_list)
  end
end
function SettingHandler.send_delete_custom_setting(slot_type)
  print(bWriteLog and "SettingHandler.send_delete_custom_setting " .. tostring(slot_type))
  NetManager.SendPkg(734904350, slot_type)
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if SettingConfig then
    local VersionsMap
    if type(slot_type) == "number" then
      VersionsMap = SettingConfig.setting_ver_info
    elseif type(slot_type) == "string" then
      VersionsMap = SettingConfig.LayoutSlotVersions
    end
    if VersionsMap and VersionsMap:Get(slot_type) then
      VersionsMap:Remove(slot_type)
      slua_GameFrontendHUD:FinishModifyUserSettings()
    end
  end
end
function SettingHandler.send_set_grome_link_open_req(stat)
  NetManager.SendPkg(1621364577, stat)
end
function SettingHandler.on_sync_grome_link_open_stat(err_code, stat)
  if err_code ~= 0 then
    log(bWriteLog and "SettingHandler.on_sync_grome_link_open_stat err_code is " .. tostring(err_code))
    return
  end
  local SettingSystem = require("client.logic.setting.logic_setting")
  SettingSystem.on_sync_grome_link_open_stat(stat)
end
function SettingHandler.send_get_grome_link_open_req()
  NetManager.SendPkg(1893124447)
end
function SettingHandler.on_get_grome_link_open_rsp(err_code, stat)
  if err_code ~= 0 then
    log(bWriteLog and "SettingHandler.on_get_grome_link_open_rsp err_code is " .. tostring(err_code))
    return
  end
  local SettingSystem = require("client.logic.setting.logic_setting")
  SettingSystem.on_get_grome_link_open_rsp(stat)
end
function SettingHandler.send_set_collect_hall_visit_privacy_req(value)
  log(bWriteLog and string.format("[114514] SettingHandler.send_set_collect_hall_visit_privacy_req value: %s ", value))
  NetManager.SendPkg(597918855, value)
end
function SettingHandler.on_set_collect_hall_visit_privacy_rsp(err, value)
  log(bWriteLog and string.format("[114514] SettingHandler.on_visit_collect_hall_req err: %s; value: %s", err, value))
  if err ~= 0 then
    log(bWriteLog and string.format("[114514] SettingHandler.on_set_collect_hall_visit_privacy_rsp err == 0"))
  end
  local CollectionHallVisitPrivacyTool = require("client.slua.logic.CollectionHall.CollectionHallVisitPrivacyTool")
  CollectionHallVisitPrivacyTool.OnVisitPrivacyChange(value)
end
function SettingHandler.send_set_grome_link_fec_req(set_val)
  NetManager.SendPkg(1151408017, set_val)
end
function SettingHandler.on_sync_grome_link_fec_stat(err_code, set_val)
  if err_code ~= 0 then
    log(bWriteLog and "SettingHandler.on_sync_grome_link_fec_stat err_code is " .. tostring(err_code))
    return
  end
  local SettingSystem = require("client.logic.setting.logic_setting")
  SettingSystem.on_sync_grome_link_fec_stat(set_val)
end
function SettingHandler.send_get_grome_link_fec_req()
  NetManager.SendPkg(723609191)
end
function SettingHandler.on_get_grome_link_fec_rsp(err_code, set_val)
  if err_code ~= 0 then
    log(bWriteLog and "SettingHandler.on_get_grome_link_fec_rsp err_code is " .. tostring(err_code))
    return
  end
  local SettingSystem = require("client.logic.setting.logic_setting")
  SettingSystem.on_get_grome_link_fec_rsp(set_val)
end
return SettingHandler