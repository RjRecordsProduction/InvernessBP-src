local NetManager = require("client.network.comm.NetManager")
local PhoneMailLoginHandler = {}
function PhoneMailLoginHandler.request_self_build_account()
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local channel = IMSDKHelperInstance:GetLastIMSDKChannelID()
  local platform = 2
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    platform = 1
  end
  local gameid = Client.GetITopGameId()
  PhoneMailLoginHandler.send_get_self_build_account_req(gameid, channel, platform)
end
function PhoneMailLoginHandler.send_get_self_build_account_req(gameid, channel, platform)
  NetManager.SendPkg(1848641607, gameid, channel, platform)
end
function PhoneMailLoginHandler.on_get_self_build_account_rsp(errcode, result)
  log_tree("xcc PhoneMailLoginHandler.on_get_self_build_account_rsp", result)
  if errcode ~= 0 then
    return
  end
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  SettingAccount.OnGetBuildAccountRsp(result)
end
function PhoneMailLoginHandler.request_get_self_build_account_award(bindType)
  local channel = Client.GetInstallChannelID(NetInterface)
  local platform = 2
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    platform = 1
  end
  local gameid = Client.GetITopGameId()
  log(bWriteLog and "  : bindType" .. tostring(bindType))
  PhoneMailLoginHandler.send_get_self_build_account_award_req(gameid, channel, platform, bindType)
end
function PhoneMailLoginHandler.send_get_self_build_account_award_req(gameid, channel, platform, type)
  NetManager.SendPkg(1552916647, gameid, channel, platform, type)
end
function PhoneMailLoginHandler.on_get_self_build_account_award_rsp(ret, award_list, got_time, bind_type, taketime_list)
  if ret ~= 0 then
    log(bWriteLog and " PhoneMailLoginHandler.on_get_self_build_account_award_rsp error code = " .. tostring(ret))
    log(bWriteLog and "got_time" .. tostring(got_time))
    PhoneMailLoginHandler.ShowNoticeByErrorCode(ret)
  else
    log_tree("  : award_list", award_list)
    if award_list and 0 < #award_list then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(award_list)
    end
    local SettingAccount = require("client.logic.setting.logic_setting_account")
    SettingAccount.OnGetAward(bind_type, taketime_list)
    local logic_singlebind = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_singlebind)
    logic_singlebind:TakePhoneOrMailBindAwardRsp()
    EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_PHONE_MAIL_REFRESH)
  end
end
function PhoneMailLoginHandler.send_send_account_verify_code_req(account_type, account, code_type, lang_type, region_code, is_imm, captcha, send_type)
  NetManager.SendPkg(1712374083, account_type, account, code_type, lang_type, region_code, is_imm, captcha)
end
function PhoneMailLoginHandler.on_get_self_build_account_verify_code_rsp(errcode, _, itop_err_code, code_type, send_type)
  log(bWriteLog and string.format("PhoneMailLoginHandler.on_get_self_build_account_verify_code_rsp, errcode:%s", errcode))
  log(bWriteLog and string.format("PhoneMailLoginHandler.on_get_self_build_account_verify_code_rsp, itop_err_code:%s", itop_err_code))
  log(bWriteLog and string.format("PhoneMailLoginHandler.on_get_self_build_account_verify_code_rsp, send_type:%s", send_type))
  if errcode ~= 0 then
    local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
    if logic_account_protect_setting:IsNeedShowLimitErrorPopup(errcode) and code_type then
      local operationType = logic_account_protect_setting:GetOperationTypeByCodeType(code_type)
      logic_account_protect_setting:ShowLimitErrorPopup(operationType, errcode)
    elseif errcode == 100150049 then
      local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
      QRcodeRestrictManager:ShowRestrictTips()
    else
      PhoneMailLoginHandler.ShowNoticeByErrorCode(errcode, itop_err_code)
    end
  else
    ShowNotice(9768)
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_GET_CODE_RSP, send_type)
  end
end
function PhoneMailLoginHandler.on_can_use_self_build_account(mail_state, phone_state, login_check_state, phone_change_state, mail_unbind_state, op_log_state, mail_change_state)
  log(bWriteLog and "PhoneMailLoginHandler.on_can_use_self_build_account mail_state : " .. tostring(mail_state) .. " || phone_state = " .. tostring(phone_state))
  log(bWriteLog and "PhoneMailLoginHandler.on_can_use_self_build_account" .. tostring(phone_change_state))
  local show_login = false
  if mail_state or phone_state then
    show_login = true
  end
  local save_data = {show_login_btn = show_login}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(save_data, PlayerPrefsSystem.ePlayerPrefsType.eMailPhoneLogin)
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  SettingAccount.ShowMail(mail_state)
  SettingAccount.ShowPhone(phone_state)
  SettingAccount.SetMailChangeState(mail_change_state)
  SettingAccount.SetPhoneChangeState(phone_change_state)
  SettingAccount.InitData()
  local LogicLoginVerify = require("client.slua.logic.login.logic_login_verify")
  LogicLoginVerify.SetFunctionOpen(login_check_state)
  LogicLoginVerify.SetOpLogOpen(op_log_state)
end
function PhoneMailLoginHandler.ShowNoticeByErrorCode(code, itop_err_code)
  local LogicLoginVerify = require("client.slua.logic.login.logic_login_verify")
  code = code or -999
  local resId = LogicLoginVerify.err_code_map[code]
  local tipContent = LocUtil.GetLocalizeResStr(tonumber(code))
  if resId then
    ShowNotice(LocUtil.LocalizeResFormat(resId, itop_err_code))
  elseif tipContent ~= "" then
    ShowNotice(LocUtil.LocalizeResFormat(code, itop_err_code))
  else
    local error = LocUtil.LocalizeResFormat(18010001) .. tostring(itop_err_code)
    ShowNotice(error)
  end
end
function PhoneMailLoginHandler.send_modify_self_build_account_req(account_type, account, verify_code, area_code)
  NetManager.SendPkg(2135566435, account_type, account, verify_code, area_code)
end
function PhoneMailLoginHandler.on_update_self_build_account_res(err, account_type)
  log(bWriteLog and string.format("PhoneMailLoginHandler.on_update_self_build_account_res, err:%s", err))
  log(bWriteLog and string.format("PhoneMailLoginHandler.on_update_self_build_account_res, account_type:%s", account_type))
  if err ~= 0 then
    local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
    if logic_account_protect_setting:IsNeedShowLimitErrorPopup(err) then
      local setting_macro = require("client.slua.logic.setting.setting_macro")
      logic_account_protect_setting:ShowLimitErrorPopup(setting_macro.AccountOperationType.Replace, err)
      return
    elseif err == 100150049 then
      local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
      QRcodeRestrictManager:ShowRestrictTips()
      return
    end
  else
    PhoneMailLoginHandler.request_self_build_account()
  end
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  SettingAccount.OnUpdateAccountRes(err, account_type)
end
function PhoneMailLoginHandler.send_get_update_mail_info_req()
  NetManager.SendPkg(45978471)
end
function PhoneMailLoginHandler.on_get_update_mail_info_rsp(err, fast_update_info)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_UPD_PHONE_MAIL_FAST, err, fast_update_info)
end
function PhoneMailLoginHandler.on_account_steal_popup_notify()
  log(bWriteLog and "[Shine] account_steal_popup_notify.")
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  SettingAccount.SetStealModelFlag()
end
function PhoneMailLoginHandler.send_verify_check_cur_bind_account_req(account_type, verify_code)
  NetManager.SendPkg(1803350663, account_type, verify_code)
end
function PhoneMailLoginHandler.on_verify_check_cur_bind_account_rsp(ret_code, account_type, expires_in)
  log(bWriteLog and string.format("PhoneMailLoginHandler.on_verify_check_cur_bind_account_rsp. ret_code=%s, account_type=%s, expires_in=%s", tostring(ret_code), tostring(account_type), tostring(expires_in)))
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_UPD_PHONE_MAIL_VERIFY, ret_code, account_type, expires_in)
end
function PhoneMailLoginHandler.on_push_social_bind_notify(text_id, popup_cd_days, end_time)
  local logic_account_sensitive_aciton = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_sensitive_aciton)
  logic_account_sensitive_aciton:CheckShowBindRemind(text_id, popup_cd_days, end_time)
end
function PhoneMailLoginHandler.send_query_social_email_req()
  NetManager.SendPkg(751360871)
end
function PhoneMailLoginHandler.on_query_social_email_rsp(err, emails)
  if err ~= 0 then
    ShowDevNotice("###just dev " .. tostring(err))
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    log(bWriteLog and "AccountBindHandler.on_query_social_email_rsp return of IsJapanOrKorea")
    return
  end
  local logic_account_sensitive_aciton = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_sensitive_aciton)
  logic_account_sensitive_aciton:on_only_social_bind_notify(nil, emails)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_MAIL)
end
return PhoneMailLoginHandler