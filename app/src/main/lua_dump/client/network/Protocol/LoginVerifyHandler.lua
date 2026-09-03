local LogicLoginVerify = require("client.slua.logic.login.logic_login_verify")
local NetManager = require("client.network.comm.NetManager")
local LoginVerifyHandler = {}
function LoginVerifyHandler.send_get_account_security_req()
  NetManager.SendPkg(1818380232)
end
function LoginVerifyHandler.on_get_account_security_res(err, info)
  LogicLoginVerify.GetAllDataRsp(err, info)
end
function LoginVerifyHandler.on_notify_account_security_change(type, info, ext_info)
  LogicLoginVerify.OnNotifyDataChange(type, info, ext_info)
end
function LoginVerifyHandler.send_report_account_bind_log(op_type, param_list)
  local bSwitch = LobbySystem.CheckOpen(BP_ENUM_ACCOUNT_BIND_BY_SERVER_SWITCH_ID)
  if bSwitch then
    log(bWriteLog and string.format("LoginVerifyHandler.send_report_account_bind_log, bSwitch:%s", bSwitch))
    return
  end
  NetManager.SendPkg(1900615237, op_type, param_list)
end
function LoginVerifyHandler.send_send_imobile_verify_code_req(account_type, lang_type, func_type, captcha, send_type)
  send_type = Client.IsInstallWhatsapp(NetInterface) and 1 or 0
  log(bWriteLog and string.format("LoginVerifyHandler.send_send_imobile_verify_code_req, send_type:%s", send_type))
  NetManager.SendPkg(872233800, account_type, lang_type, func_type, captcha, send_type)
end
function LoginVerifyHandler.on_send_imobile_verify_code_res(err, itop_err_code, send_type)
  log(bWriteLog and string.format("LoginVerifyHandler.on_send_imobile_verify_code_res, err:%s", err))
  log(bWriteLog and string.format("LoginVerifyHandler.on_send_imobile_verify_code_res, itop_err_code:%s", itop_err_code))
  log(bWriteLog and string.format("LoginVerifyHandler.on_send_imobile_verify_code_res, send_type:%s", send_type))
  LogicLoginVerify.SendVerifyCodeRsp(err, itop_err_code, send_type)
end
function LoginVerifyHandler.send_account_security_open_req(verify_code)
  NetManager.SendPkg(1642126064, verify_code)
end
function LoginVerifyHandler.on_account_security_open_res(err)
  log(bWriteLog and string.format("LoginVerifyHandler.on_account_security_open_res, err:%s", err))
  LogicLoginVerify.OnOpenLoginVerifyRsp(err)
end
function LoginVerifyHandler.send_account_security_close_req()
  NetManager.SendPkg(1966995016)
end
function LoginVerifyHandler.on_account_security_close_res(err)
  log(bWriteLog and string.format("LoginVerifyHandler.on_account_security_close_res, err:%s", err))
  LogicLoginVerify.OnCloseLoginVerifyRsp(err)
end
local switch_change_last_switch_type = 0
local switch_change_last_is_open = 0
function LoginVerifyHandler.send_verify_code_switch_change_req(switch_type, is_open, channel)
  if not channel then
    local IMSDKHelper = import("IMSDKHelper")
    local IMSDKHelperInstance = IMSDKHelper.GetInstance()
    channel = IMSDKHelperInstance:GetLastIMSDKChannelID()
  end
  switch_change_last_  switch_change_last_  NetManager.SendPkg(1143172248, switch_type, is_open, channel)
end
function LoginVerifyHandler.on_verify_code_switch_change_res(err)
  log(bWriteLog and string.format("LoginVerifyHandler.on_verify_code_switch_change_res, err:%s", err))
  if err ~= 0 then
    local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
    if logic_account_protect_setting:IsNeedShowLimitErrorPopup(err) then
      local setting_macro = require("client.slua.logic.setting.setting_macro")
      logic_account_protect_setting:ShowLimitErrorPopup(setting_macro.AccountOperationType.LoginVerify, err)
      return
    elseif err == 100150049 then
      local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
      QRcodeRestrictManager:ShowRestrictTips()
      return
    end
  end
  if switch_change_last_switch_type == 2 then
    if switch_change_last_is_open then
      LogicLoginVerify.OnOpenLoginVerifyMailRsp(err)
    else
      LogicLoginVerify.OnCloseLoginVerifyMailRsp(err)
    end
  end
  if switch_change_last_switch_type == 3 then
    if switch_change_last_is_open then
      LogicLoginVerify.OnOpenLoginVerifyCodeRsp(err)
    else
      LogicLoginVerify.OnCloseLoginVerifyCodeRsp(err)
    end
  end
end
function LoginVerifyHandler.send_delete_trusted_device_req(index, device_id)
  NetManager.SendPkg(101927898, index, device_id)
end
function LoginVerifyHandler.on_delete_trusted_device_res(err, index, info)
  LogicLoginVerify.OnDelDevRsp(err, info)
end
function LoginVerifyHandler.send_gen_new_spare_code_req()
  NetManager.SendPkg(697910472)
end
function LoginVerifyHandler.on_gen_new_spare_code_res(err, spare_code_list)
  LogicLoginVerify.GenNewSpareCodeRsp(err, spare_code_list)
end
function LoginVerifyHandler.on_verify_code_check_notify(info, phone, area_code, mail)
  LogicLoginVerify.OnLoginVerifyNotify(info, phone, area_code, mail)
end
function LoginVerifyHandler.send_verify_code_check_login_req(verify_type, verify_code)
  NetManager.SendPkg(246157490, verify_type, verify_code)
end
function LoginVerifyHandler.on_verify_code_check_login_res(err)
  LogicLoginVerify.DoLoginVerifyRsp(err)
end
function LoginVerifyHandler.send_get_security_op_list_req()
  NetManager.SendPkg(1932904031)
end
function LoginVerifyHandler.send_verify_code_send_check_req()
  local logic_account_sensitive_aciton = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_sensitive_aciton)
  if logic_account_sensitive_aciton:IsGrayNew() then
    log(bWriteLog and "ShowVSBanTip return of IsGrayNew")
    return
  end
  NetManager.SendPkg(319686823)
end
function LoginVerifyHandler.on_verify_code_send_check_rsp(res)
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  SettingAccount.canBindCode = res
  log(bWriteLog and "  : SettingAccount.canBindCode" .. tostring(SettingAccount.canBindCode))
  if SettingAccount.myPromise then
    SettingAccount.myPromise:Resolve()
  end
end
function LoginVerifyHandler.on_busi_security_info_notify(deviceid, sysHardware, busi_security_data)
  print(bWriteLog and "LoginVerifyHandler.on_busi_security_info_notify")
  LogicLoginVerify.OnBusiSecurityInfoNotify(deviceid, sysHardware, busi_security_data)
end
function LoginVerifyHandler.send_account_modify_sacc_req(sparams, account, account_type, verify_code, area_code)
  local bSwitch = LobbySystem.CheckOpen(BP_ENUM_ACCOUNT_BIND_BY_SERVER_SWITCH_ID)
  if not bSwitch then
    log(bWriteLog and string.format("LoginVerifyHandler.send_account_modify_sacc_req, not bSwitch:%s", bSwitch))
    return
  end
  log_tree(bWriteLog and "LoginVerifyHandler.send_account_modify_sacc_req sparams", sparams)
  log(bWriteLog and string.format("LoginVerifyHandler.send_account_modify_sacc_req, account:%s", account))
  log(bWriteLog and string.format("LoginVerifyHandler.send_account_modify_sacc_req, account_type:%s", account_type))
  log(bWriteLog and string.format("LoginVerifyHandler.send_account_modify_sacc_req, verify_code:%s", verify_code))
  log(bWriteLog and string.format("LoginVerifyHandler.send_account_modify_sacc_req, area_code:%s", area_code))
  NetManager.SendPkg(408918815, sparams, account, account_type, verify_code, area_code)
end
function LoginVerifyHandler.on_account_modify_sacc_rsp(err, json_data, itop_err, sacc_err)
  log(bWriteLog and string.format("LoginVerifyHandler.on_account_modify_sacc_rsp, err:%s", err))
  log(bWriteLog and string.format("LoginVerifyHandler.on_account_modify_sacc_rsp, json_data:%s", json_data))
  log(bWriteLog and string.format("LoginVerifyHandler.on_account_modify_sacc_rsp, itop_err:%s", itop_err))
  log(bWriteLog and string.format("LoginVerifyHandler.on_account_modify_sacc_rsp, sacc_err:%s", sacc_err))
  if err ~= 0 then
    local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
    if logic_account_protect_setting:IsNeedShowLimitErrorPopup(err) then
      local setting_macro = require("client.slua.logic.setting.setting_macro")
      logic_account_protect_setting:ShowLimitErrorPopup(setting_macro.AccountOperationType.Modify, err)
    elseif err == 18010100 then
      local text = LocUtil.GetLocalizeResStr(18010100)
      ShowNotice(LocUtil.FormatStringIndexOne(text, itop_err))
    else
      ShowNotice(err)
    end
  else
    local PhoneMailLoginHandler = require("client.network.Protocol.PhoneMailLoginHandler")
    PhoneMailLoginHandler.request_self_build_account()
    EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_BIND_SUCCESS)
  end
end
function LoginVerifyHandler.send_account_social_bind_req(bind_channel, sparams)
  local bSwitch = LobbySystem.CheckOpen(BP_ENUM_ACCOUNT_BIND_BY_SERVER_SWITCH_ID)
  if not bSwitch then
    log(bWriteLog and string.format("LoginVerifyHandler.send_account_modify_sacc_req, not bSwitch:%s", bSwitch))
    return
  end
  log(bWriteLog and string.format("LoginVerifyHandler.send_account_social_bind_req, bind_channel:%s", bind_channel))
  log_tree(bWriteLog and "LoginVerifyHandler.send_account_social_bind_req sparams", sparams)
  NetManager.SendPkg(252851343, bind_channel, sparams)
end
function LoginVerifyHandler.on_account_social_bind_rsp(err, bind_channel, json_data, itop_err)
  log(bWriteLog and string.format("LoginVerifyHandler.on_account_social_bind_rsp, err:%s", err))
  log(bWriteLog and string.format("LoginVerifyHandler.on_account_social_bind_rsp, bind_channel:%s", bind_channel))
  log(bWriteLog and string.format("LoginVerifyHandler.on_account_social_bind_rsp, json_data:%s", json_data))
  log(bWriteLog and string.format("LoginVerifyHandler.on_account_social_bind_rsp, itop_err:%s", itop_err))
  if err ~= 0 then
    local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
    if logic_account_protect_setting:IsNeedShowLimitErrorPopup(err) then
      local setting_macro = require("client.slua.logic.setting.setting_macro")
      logic_account_protect_setting:ShowLimitErrorPopup(setting_macro.AccountOperationType.Bind, err)
    elseif err == 18010100 then
      local text = LocUtil.GetLocalizeResStr(18010100)
      ShowNotice(LocUtil.FormatStringIndexOne(text, itop_err))
    else
      ShowNotice(err)
    end
  elseif json_data then
    local IMSDKHelper = import("IMSDKHelper")
    local IMSDKHelperInstance = IMSDKHelper.GetInstance()
    IMSDKHelperInstance:UpdateIMSDKBindResult(json_data)
  end
end
function LoginVerifyHandler.send_account_bind_sacc_req(sparams, account, account_type, verify_code, area_code)
  local bSwitch = LobbySystem.CheckOpen(BP_ENUM_ACCOUNT_BIND_BY_SERVER_SWITCH_ID)
  if not bSwitch then
    log(bWriteLog and string.format("LoginVerifyHandler.send_account_modify_sacc_req, not bSwitch:%s", bSwitch))
    return
  end
  log_tree(bWriteLog and "LoginVerifyHandler.send_account_bind_sacc_req sparams", sparams)
  log(bWriteLog and string.format("LoginVerifyHandler.send_account_bind_sacc_req, account:%s", account))
  log(bWriteLog and string.format("LoginVerifyHandler.send_account_bind_sacc_req, account_type:%s", account_type))
  log(bWriteLog and string.format("LoginVerifyHandler.send_account_bind_sacc_req, verify_code:%s", verify_code))
  log(bWriteLog and string.format("LoginVerifyHandler.send_account_bind_sacc_req, area_code:%s", area_code))
  NetManager.SendPkg(1823044419, sparams, account, account_type, verify_code, area_code)
end
function LoginVerifyHandler.on_account_bind_sacc_rsp(err, json_data, itop_err, sacc_err)
  log(bWriteLog and string.format("LoginVerifyHandler.on_account_bind_sacc_rsp, err:%s", err))
  log(bWriteLog and string.format("LoginVerifyHandler.on_account_bind_sacc_rsp, json_data:%s", json_data))
  log(bWriteLog and string.format("LoginVerifyHandler.on_account_bind_sacc_rsp, itop_err:%s", itop_err))
  log(bWriteLog and string.format("LoginVerifyHandler.on_account_bind_sacc_rsp, sacc_err:%s", sacc_err))
  if err ~= 0 then
    local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
    if logic_account_protect_setting:IsNeedShowLimitErrorPopup(err) then
      local setting_macro = require("client.slua.logic.setting.setting_macro")
      logic_account_protect_setting:ShowLimitErrorPopup(setting_macro.AccountOperationType.Bind, err)
    elseif err == 18010100 then
      local text = LocUtil.GetLocalizeResStr(18010100)
      ShowNotice(LocUtil.FormatStringIndexOne(text, itop_err))
    else
      ShowNotice(err)
    end
  elseif json_data then
    local IMSDKHelper = import("IMSDKHelper")
    local IMSDKHelperInstance = IMSDKHelper.GetInstance()
    IMSDKHelperInstance:UpdateIMSDKBindResult(json_data)
  end
end
function LoginVerifyHandler.on_account_group_info_notify(notice_info, is_gray)
  local bSwitch = LobbySystem.CheckOpen(BP_ENUM_ITOP_SAFETY_ACCESS_SWITCH_ID)
  if not bSwitch then
    log(bWriteLog and string.format("LoginVerifyHandler.on_account_group_info_notify, not bSwitch:%s", bSwitch))
    return
  end
  log_tree(bWriteLog and "LoginVerifyHandler.on_account_group_info_notify notice_info", notice_info)
  log(bWriteLog and string.format("LoginVerifyHandler.on_account_group_info_notify, is_gray:%s", is_gray))
  local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
  logic_account_protect_setting:on_account_group_info_notify(notice_info, is_gray)
end
function LoginVerifyHandler.send_report_notice_readed_req()
  log(bWriteLog and "LoginVerifyHandler.send_report_notice_readed_req")
  NetManager.SendPkg(1821687207)
end
function LoginVerifyHandler.on_report_notice_readed_rsp(err)
  log(bWriteLog and string.format("LoginVerifyHandler.on_report_notice_readed_rsp, err:%s", err))
  if err ~= 0 then
    ShowNotice(err)
  end
end
function LoginVerifyHandler.send_batch_get_user_names_req(openids)
  local len = #openids
  if len <= 0 or 12 < len then
    log_error(bWriteLog and "  LoginVerifyHandler.send_batch_get_user_names_req.  len error")
    local utility = require("common.utility")
    local IMSDKHelper = import("IMSDKHelper")
    local ret = IMSDKHelper.GetInstance():GetAllQRCodeLoginResults()
    local info = string.format("batch_get_user_names_req len error: %s", ret)
    utility.ErrorMessageHandler(info)
    return
  end
  NetManager.SendPkg(325987943, openids)
end
function LoginVerifyHandler.on_batch_get_user_names_rsp(res, names)
  if res ~= 0 then
    ShowNotice(res)
    return true
  end
end
function LoginVerifyHandler.send_report_account_group_log(sence_id, reason_str, op_type, channel, serial_no, stage_id)
  log(bWriteLog and string.format("LoginVerifyHandler.send_report_account_group_log, sence_id:%s", sence_id))
  log(bWriteLog and string.format("LoginVerifyHandler.send_report_account_group_log, reason_str:%s", reason_str))
  log(bWriteLog and string.format("LoginVerifyHandler.send_report_account_group_log, op_type:%s", op_type))
  log(bWriteLog and string.format("LoginVerifyHandler.send_report_account_group_log, channel:%s", channel))
  log(bWriteLog and string.format("LoginVerifyHandler.send_report_account_group_log, serial_no:%s", serial_no))
  log(bWriteLog and string.format("LoginVerifyHandler.send_report_account_group_log, stage_id:%s", stage_id))
  NetManager.SendPkg(2127406935, sence_id, reason_str, op_type, channel, serial_no, stage_id)
end
local reqRsp = {
  send_batch_get_user_names_req = "on_batch_get_user_names_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, LoginVerifyHandler)
return LoginVerifyHandler