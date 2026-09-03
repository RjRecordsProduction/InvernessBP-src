local tLogFlag
local NeedOpenRegion = false
local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
local GM_Data = {
  function_open = true,
  op_log_open = true,
  is_open = true,
  phone_open = true,
  mail_open = true,
  code_open = false,
  code_list = {
    {code = "11111355", is_used = false},
    {code = "22225612", is_used = false},
    {code = "33334651", is_used = true},
    {code = "44441231", is_used = false},
    {code = "55555435", is_used = true},
    {code = "66667654", is_used = false},
    {code = "77772356", is_used = true},
    {code = "88880986", is_used = false},
    {code = "99994567", is_used = false}
  },
  dev_list = {
    {
      is_cur = true,
      sysHardware = "TestPhone 1"
    },
    {
      is_cur = false,
      sysHardware = "TestPhone 2"
    },
    {
      is_cur = false,
      sysHardware = "TestPhone 3"
    },
    {
      is_cur = false,
      sysHardware = "TestPhone 4"
    }
  },
  op_list = {
    {
      op_time = 1,
      op_type = 1,
      sysHardware = "TestPhone 1"
    },
    {
      op_time = 1,
      op_type = 6,
      sysHardware = "TestPhone 2"
    },
    {
      op_time = 1,
      op_type = 7,
      sysHardware = "TestPhone 3"
    },
    {
      op_time = 1,
      op_type = 9,
      sysHardware = "TestPhone 4"
    },
    {
      op_time = 1,
      op_type = 10,
      sysHardware = "TestPhone 5"
    },
    {
      op_time = 1,
      op_type = 11,
      sysHardware = "TestPhone 6"
    },
    {
      op_time = 1,
      op_type = 12,
      sysHardware = "TestPhone 7"
    },
    {
      op_time = 1,
      op_type = 13,
      sysHardware = "TestPhone 8"
    }
  }
}
local ENUM_LoginVerifyType = {
  Phone = 1,
  Email = 2,
  Code = 3
}
local ENUM_AccountType = {Email = 1, Phone = 2}
local ENUM_VerifyType = {Login = 0, OpenVerify = 1}
local Enum_BindOperateType = {PhoneError = 2, MailError = 3}
local logic_login_verify = {
  function_open = false,
  op_log_open = false,
  is_open = false,
  phone_open = false,
  mail_open = false,
  code_open = false,
  code_list = {},
  dev_list = {},
  op_list = {},
  next_can_send_time = 0,
  ENUM_LoginVerifyType = ENUM_LoginVerifyType,
  ENUM_AccountType = ENUM_AccountType,
  ENUM_VerifyType = ENUM_VerifyType,
  use_gm_data = false,
  gm_data = GM_Data,
  has_popup_security = false,
  security_data = nil,
  sendType = SDKMacros.IMSDKVerifyCodeSendType.SMS
}
logic_login_verify.err_code_map = {
  [100150000] = 540001,
  [100150001] = 108104,
  [100150002] = 540001,
  [100150003] = 540001,
  [100150004] = 501128,
  [100150005] = 120178,
  [100150007] = 9927,
  [100150008] = 9930,
  [100150009] = 33255,
  [100150010] = 33254,
  [100150024] = 100150024,
  [100150038] = 100150038,
  [100150039] = 100150039,
  [881020] = 881020,
  [881021] = 881021
}
function logic_login_verify.IsLoginVerifyOpen()
  if logic_login_verify.use_gm_data then
    return logic_login_verify.gm_data.is_open
  end
  return logic_login_verify.is_open
end
function logic_login_verify.IsLoginVerifyPhoneOpen()
  if logic_login_verify.use_gm_data then
    return logic_login_verify.gm_data.phone_open
  end
  return logic_login_verify.phone_open
end
function logic_login_verify.IsLoginVerifyMailOpen()
  if logic_login_verify.use_gm_data then
    return logic_login_verify.gm_data.mail_open
  end
  return logic_login_verify.mail_open
end
function logic_login_verify.IsLoginVerifyCodeOpen()
  if logic_login_verify.use_gm_data then
    return logic_login_verify.gm_data.code_open
  end
  return logic_login_verify.code_open
end
function logic_login_verify.GetVerifyCodeList()
  if logic_login_verify.use_gm_data then
    return logic_login_verify.gm_data.code_list
  end
  return logic_login_verify.code_list
end
function logic_login_verify.GetDevList()
  if logic_login_verify.use_gm_data then
    return logic_login_verify.gm_data.dev_list
  end
  return logic_login_verify.dev_list
end
function logic_login_verify.GetOpList()
  if logic_login_verify.use_gm_data then
    return logic_login_verify.gm_data.op_list
  end
  log(bWriteLog and string.format("logic_login_verify::GetOpList len = %s", logic_login_verify.op_list and #logic_login_verify.op_list or "nil"))
  return logic_login_verify.op_list
end
function logic_login_verify.IsFunctionOpen()
  if logic_login_verify.use_gm_data then
    return logic_login_verify.gm_data.function_open
  end
  return logic_login_verify.function_open
end
function logic_login_verify.SetFunctionOpen(is_open)
  if is_open then
    logic_login_verify.function_open = true
  else
    logic_login_verify.function_open = false
  end
end
function logic_login_verify.IsOpLogOpen()
  if IsEditor then
    return true
  end
  if logic_login_verify.use_gm_data then
    return logic_login_verify.gm_data.op_log_open
  end
  return logic_login_verify.op_log_open
end
function logic_login_verify.SetOpLogOpen(is_open)
  log(bWriteLog and string.format("logic_login_verify::SetOpLogOpen is_open = %s", is_open))
  if is_open then
    logic_login_verify.op_log_open = true
  else
    logic_login_verify.op_log_open = false
  end
end
function logic_login_verify.IsBindPhoneOpen()
  if logic_login_verify.use_gm_data then
    return true
  end
  local logic = require("client.logic.setting.logic_setting_account")
  local data = logic.GetSettingAccountData()
  return data.show_phone
end
function logic_login_verify.IsBindMailOpen()
  local logic = require("client.logic.setting.logic_setting_account")
  local data = logic.GetSettingAccountData()
  return data.show_mail
end
function logic_login_verify.GetBindPhoneNumber(make_private, with_area_code)
  if logic_login_verify.use_gm_data then
    return "GM Phone Number"
  end
  local logic = require("client.logic.setting.logic_setting_account")
  local data = logic.GetSettingAccountData()
  local result = data.bind_phone
  if not result then
    return result
  end
  if make_private then
    result = logic_login_verify.MakeStrPrivate(result, 2, 2)
  end
  if with_area_code and data.area_code then
    result = string.format("+%s  %s", data.area_code, result)
  end
  return result
end
function logic_login_verify.GetBindMailAddr(make_private)
  local logic = require("client.logic.setting.logic_setting_account")
  local data = logic.GetSettingAccountData()
  local result = data.bind_mail
  if not result then
    return result
  end
  if make_private then
    result = logic_login_verify.MakeStrPrivate(result, 2, 6)
  end
  return result
end
function logic_login_verify.MakeStrPrivate(str, head, tail)
  if not head or head < 0 then
    head = 1
  end
  if not tail or tail < 0 then
    tail = 1
  end
  local strLen = #str
  if strLen <= head + tail then
    return str
  end
  return string.format("%s%s%s", head == 0 and "" or string.sub(str, 1, head), string.rep("*", strLen - head - tail), tail == 0 and "" or string.sub(str, -tail))
end
function logic_login_verify.GetVerifyCodeNextCanSendTime()
  return logic_login_verify.next_can_send_time or 0
end
function logic_login_verify.GetAllDataReq()
  local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
  LoginVerifyHandler.send_get_account_security_req()
end
function logic_login_verify.GetAllDataRsp(err, info)
  if err ~= 0 then
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_LOGINVERIFY_LOAD_RSP, err)
    return
  end
  log_tree("  :GetAllDataRsp info", info)
  logic_login_verify.is_open = info.main_switch
  logic_login_verify.phone_open = info.phone_code_switch
  logic_login_verify.mail_open = info.mail_code_switch
  logic_login_verify.code_open = info.spare_code_switch
  logic_login_verify.code_list = info.spare_code_list or {}
  logic_login_verify.dev_list = info.trusted_device_list or {}
  logic_login_verify.CalcDevListCurDev()
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_LOGINVERIFY_LOAD_RSP, 0)
end
function logic_login_verify.CalcDevListCurDev()
  if not logic_login_verify.dev_list then
    return
  end
  local my_deviceid = Client.GetPhoneDeviceID()
  for _, data in ipairs(logic_login_verify.dev_list) do
    data.is_cur = data.deviceid == my_deviceid
  end
end
function logic_login_verify.GetAllOpListReq()
  if not logic_login_verify.IsOpLogOpen() then
    return
  end
  local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
  LoginVerifyHandler.send_get_security_op_list_req()
end
function logic_login_verify.OnBusiSecurityInfoNotify(deviceid, sysHardware, busi_security_data)
  if not logic_login_verify.IsOpLogOpen() then
    return
  end
  if logic_login_verify.has_popup_security then
    return
  end
  logic_login_verify.security_data = {
    deviceid = deviceid,
    sysHardware = sysHardware,
      }
end
function logic_login_verify.ProcessSecurityPopup()
  if not logic_login_verify.IsOpLogOpen() then
    return
  end
  if logic_login_verify.has_popup_security then
    return
  end
  if not logic_login_verify.security_data then
    return
  end
  logic_login_verify.has_popup_security = true
  logic_login_verify.security_data.showTimer = true
  UIManager.ShowUI(UIManager.UI_Config.Inform_Popup_Abnormal_UIBP, logic_login_verify.security_data)
  logic_login_verify.security_data = nil
end
function logic_login_verify.OnNotifyDataChange(type, info, ext_info)
  log(bWriteLog and string.format("logic_login_verify::OnNotifyDataChange type = %s", type))
  info = info or {}
  if type == 0 then
    logic_login_verify.is_open = info.main_switch
    logic_login_verify.phone_open = info.phone_code_switch
    logic_login_verify.mail_open = info.mail_code_switch
    logic_login_verify.code_open = info.spare_code_switch
    logic_login_verify.code_list = info.spare_code_list or {}
    logic_login_verify.dev_list = info.trusted_device_list or {}
    logic_login_verify.RebuildOpList(info.op_log_list, ext_info)
  elseif type == 1 then
    logic_login_verify.phone_open = info[1]
    logic_login_verify.mail_open = info[2]
    logic_login_verify.code_open = info[3]
  elseif type == 2 then
    logic_login_verify.code_list = info or {}
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_LOGINVERIFY_GEN_CODE_LIST_RSP, 0)
  elseif type == 3 then
    logic_login_verify.dev_list = info or {}
  elseif type == 4 then
    logic_login_verify.RebuildOpList(info, ext_info)
  else
    return
  end
  logic_login_verify.CalcDevListCurDev()
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_LOGINVERIFY_LOAD_RSP, 0)
end
function logic_login_verify.RebuildOpList(info, ext_info)
  log_tree(bWriteLog and "RebuildOpList info", info)
  log_tree(bWriteLog and "RebuildOpList ext_info", ext_info)
  local result = {}
  if info and next(info) then
    table.move(info, 1, #info, 1, result)
  end
  if ext_info and next(ext_info) then
    table.move(ext_info, 1, #ext_info, #result + 1, result)
  end
  table.sort(result, function(a, b)
    return a.op_time > b.op_time
  end)
  if 10 < #result then
    logic_login_verify.op_list = {}
    table.move(result, 1, 10, 1, logic_login_verify.op_list)
  else
    logic_login_verify.op_list = result
  end
end
function logic_login_verify.SendVerifyCodeReq(accountType, verifyType, resendCD, is_secondverify)
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.OSTime()
  if logic_login_verify.next_can_send_time and now < logic_login_verify.next_can_send_time then
    log(bWriteLog and "SendVerifyCodeReq next_can_send_time is fail")
    return
  end
  local langCode = FuncUtil.TransLanguageToImsdkLanguage()
  if is_secondverify then
    log(bWriteLog and "LogicLoginVerify.SendVerifyCodeReq is_secondverify start")
    local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
    LoginVerifyHandler.send_send_imobile_verify_code_req(accountType, langCode, verifyType)
    resendCD = tonumber(resendCD) or 60
    logic_login_verify.next_can_send_time = now + resendCD
    return
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  IMSDKHelperInstance.WebviewVerifyCallbackDelegate:Clear()
  IMSDKHelperInstance.WebviewVerifyCallbackDelegate:Add(function(ret, extra)
    local dataTable = json.decode(ret)
    local extraTable = json.decode(extra)
    local sdkReturnSucc = false
    local strPlatform = Client.GetDevicePlatformName()
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    if strPlatform == DevicePlatformNameMacros.IOS and dataTable.retCode == 1 or dataTable.imsdkRetCode == 1 then
      sdkReturnSucc = true
    else
      log(bWriteLog and "SendVerifyCodeReq is fail")
      ShowNotice(119600036)
    end
    if sdkReturnSucc == true and dataTable.captcha then
      local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
      resendCD = tonumber(resendCD) or 60
      logic_login_verify.next_can_send_time = now + resendCD
      log_tree("SendVerifyCodeReq.extraTable ", extraTable)
      log_tree("SendVerifyCodeReq.dataTable.captcha ", dataTable.captcha)
      LoginVerifyHandler.send_send_imobile_verify_code_req(extraTable.accountType, extraTable.langCode, extraTable.verifyType, dataTable.captcha)
    end
  end)
  local extraTable = {
    accountType = accountType,
    langCode = langCode,
      }
  local VerifyAppId = IMSDKHelperInstance:GetVerifyAppId4SendCode()
  IMSDKHelperInstance:StartWebVerify(json.encode(extraTable), VerifyAppId, "")
end
function logic_login_verify.SendVerifyCodeRsp(err, itop_err_code, send_type)
  if err ~= 0 then
    local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
    if logic_account_protect_setting:IsNeedShowLimitErrorPopup(err) then
      local setting_macro = require("client.slua.logic.setting.setting_macro")
      logic_account_protect_setting:ShowLimitErrorPopup(setting_macro.AccountOperationType.LoginVerify, err)
    elseif err == 100150049 then
      local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
      QRcodeRestrictManager:ShowRestrictTips()
    else
      ShowNotice(logic_login_verify.GetSpecialErrCodeNotice(err, itop_err_code))
    end
  else
    ShowNotice(9768)
    logic_login_verify.sendType = send_type
    EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_UPDATE_COUNT_DOWN)
  end
end
function logic_login_verify.OpenLoginVerifyReq(verifyCode)
  local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
  LoginVerifyHandler.send_account_security_open_req(verifyCode)
end
function logic_login_verify.OnOpenLoginVerifyRsp(err)
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
  else
    logic_login_verify.next_can_send_time = 0
    ShowNotice(27473)
  end
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_LOGINVERIFY_OPEN_RSP, err)
end
function logic_login_verify.CloseLoginVerifyReq()
  local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
  LoginVerifyHandler.send_account_security_close_req()
end
function logic_login_verify.OnCloseLoginVerifyRsp(err)
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
  else
    ShowNotice(27717)
  end
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_LOGINVERIFY_OPEN_RSP, err)
end
function logic_login_verify.OpenLoginVerifyMailReq()
  if logic_login_verify.use_gm_data then
    logic_login_verify.gm_data.mail_open = true
    logic_login_verify.OnOpenLoginVerifyMailRsp(0)
    return
  end
  local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
  LoginVerifyHandler.send_verify_code_switch_change_req(2, true)
end
function logic_login_verify.OnOpenLoginVerifyMailRsp(err)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_LOGINVERIFY_MAIL_OPEN_RSP, err)
end
function logic_login_verify.CloseLoginVerifyMailReq()
  local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
  LoginVerifyHandler.send_verify_code_switch_change_req(2, false)
end
function logic_login_verify.OnCloseLoginVerifyMailRsp(err)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_LOGINVERIFY_MAIL_CLOSE_RSP, err)
end
function logic_login_verify.OpenLoginVerifyCodeReq()
  if logic_login_verify.use_gm_data then
    logic_login_verify.gm_data.code_open = true
    logic_login_verify.OnOpenLoginVerifyCodeRsp(0)
    return
  end
  local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
  LoginVerifyHandler.send_verify_code_switch_change_req(3, true)
end
function logic_login_verify.OnOpenLoginVerifyCodeRsp(err)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_LOGINVERIFY_CODE_OPEN_RSP, err)
end
function logic_login_verify.CloseLoginVerifyCodeReq()
  local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
  LoginVerifyHandler.send_verify_code_switch_change_req(3, false)
end
function logic_login_verify.OnCloseLoginVerifyCodeRsp(err)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_LOGINVERIFY_CODE_CLOSE_RSP, err)
end
function logic_login_verify.DelDevReq(index)
  local data = logic_login_verify.dev_list[index]
  if not data then
    return
  end
  local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
  LoginVerifyHandler.send_delete_trusted_device_req(index, data.deviceid)
end
function logic_login_verify.OnDelDevRsp(err, info)
  if err == 100150049 then
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  if err == 0 then
    logic_login_verify.dev_list = info
  end
  logic_login_verify.CalcDevListCurDev()
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_LOGINVERIFY_DEL_DEV_RSP, err)
end
function logic_login_verify.GenNewSpareCodeReq()
  local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
  LoginVerifyHandler.send_gen_new_spare_code_req()
end
function logic_login_verify.GenNewSpareCodeRsp(err, spare_code_list)
  if err ~= 0 then
    if err == 100150026 then
      ShowNotice(27505)
    else
      ShowNotice(err)
    end
  end
end
function logic_login_verify.OnLoginVerifyNotify(info, phone, area_code, mail)
  if UIManager.IsUIShow(UIManager.UI_Config.login_verify_confirm) or UIManager.IsUIShow(UIManager.UI_Config.login_verify_code_box) then
    log(bWriteLog and "LogicLoginVerify.OnLoginVerifyNotify IsUIShow return")
    return
  end
  local msgData = {
    phoneNumber = phone,
    mailAddr = mail,
    canUseMailVerify = false,
    canUseCodeVerify = false
  }
  for _, v in pairs(info) do
    if v == 2 then
      msgData.canUseMailVerify = true
    end
    if v == 3 then
      msgData.canUseCodeVerify = true
    end
  end
  logic_login_verify.login_verify_msg_data = msgData
  logic_login_verify.OpenLoginVerifyCodeBoxPanel(ENUM_LoginVerifyType.Phone)
end
function logic_login_verify.GetLoginVerifyMsgData()
  return logic_login_verify.login_verify_msg_data or {
    phoneNumber = "",
    mailAddr = "",
    canUseMailVerify = false,
    canUseCodeVerify = false
  }
end
function logic_login_verify.OpenLoginVerifyConfirm()
  local msgData = logic_login_verify.GetLoginVerifyMsgData()
  UIManager.ShowUI(UIManager.UI_Config.login_verify_confirm, msgData)
end
function logic_login_verify.OpenLoginVerifyCodeBoxPanel(verifyType)
  local loginVerifyData = logic_login_verify.GetLoginVerifyMsgData()
  local msgData = {}
  msgData.title = LocUtil.GetLocalizeResStr(27460)
  msgData.btnOK = LocUtil.GetLocalizeResStr(27479)
  msgData.styleType = 3
  msgData.canResendTimeGetter = logic_login_verify.GetVerifyCodeNextCanSendTime
  function msgData.changeTypeCallback()
    logic_login_verify.OpenLoginVerifyConfirm()
    return true
  end
  function msgData.cancelCallback()
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:sendLogout()
  end
  if verifyType == ENUM_LoginVerifyType.Phone then
    msgData.msg = LocUtil.LocalizeResFormat(31014, loginVerifyData.phoneNumber)
    msgData.codeMinLen = 5
    msgData.autoSend = false
    function msgData.resendCallback()
      logic_login_verify.SendVerifyCodeReq(ENUM_AccountType.Phone, ENUM_VerifyType.Login, 60, true)
    end
    function msgData.verifyCallback(verifyCode)
      logic_login_verify.DoLoginVerifyReq(ENUM_LoginVerifyType.Phone, verifyCode)
      return false
    end
  end
  if verifyType == ENUM_LoginVerifyType.Email then
    msgData.msg = LocUtil.LocalizeResFormat(31014, loginVerifyData.mailAddr)
    msgData.codeMinLen = 5
    function msgData.resendCallback()
      logic_login_verify.SendVerifyCodeReq(ENUM_AccountType.Email, ENUM_VerifyType.Login, 60, true)
    end
    function msgData.verifyCallback(verifyCode)
      logic_login_verify.DoLoginVerifyReq(ENUM_LoginVerifyType.Email, verifyCode)
      return false
    end
  end
  if verifyType == ENUM_LoginVerifyType.Code then
    msgData.msg = LocUtil.GetLocalizeResStr(31015)
    msgData.codeMinLen = 8
    msgData.needResendButton = false
    function msgData.verifyCallback(verifyCode)
      logic_login_verify.DoLoginVerifyReq(ENUM_LoginVerifyType.Code, verifyCode)
      return false
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.login_verify_code_box, msgData)
end
function logic_login_verify.DoLoginVerifyReq(loginVerifyType, verifyCode)
  local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
  LoginVerifyHandler.send_verify_code_check_login_req(loginVerifyType, verifyCode)
end
function logic_login_verify.DoLoginVerifyRsp(err)
  if err == 0 then
    logic_login_verify.next_can_send_time = 0
  end
  EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_DO_VERIFY_RSP, err)
end
function logic_login_verify.GetSpecialErrCodeNotice(err_code, itop_err_code)
  local result
  result = logic_login_verify.err_code_map[err_code or 100150000] or err_code
  if result == 540001 then
    return LocUtil.LocalizeResFormat(result, itop_err_code)
  else
    return LocUtil.GetLocalizeResStr(result)
  end
end
function logic_login_verify.SetBindTLogFlag(isPhone)
  tLogFlag = "Mail"
  if isPhone then
    tLogFlag = "Phone"
  end
end
function logic_login_verify.OnModePostSwitch(_, _, status)
end
function logic_login_verify.PostTLog(strBindName)
  strBindName = strBindName or tLogFlag
  local SettingSystem = require("client.logic.setting.logic_setting")
  local bind
  local op_type = BP_ENUM_IMSDK_CHANNEL_DEFAULT
  local channel_type = SettingSystem.NBindChannel
  if strBindName == "Mail" then
    bind = 0
    op_type = BP_ENUM_IMSDK_CHANNEL_MAIL
  elseif strBindName == "Phone" then
    bind = 1
    op_type = BP_ENUM_IMSDK_CHANNEL_PHONE
  end
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  LobbyHandler.send_refresh_account_bind_req(op_type, channel_type)
  if bind then
    local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
    LoginVerifyHandler.send_report_account_bind_log(bind)
  end
  log(bWriteLog and string.format("logic_login_verify.PostTLog op_type : %s, channel_type : %s, bind : %s, strBindName : %s", tostring(op_type), tostring(channel_type), tostring(bind), tostring(strBindName)))
end
function logic_login_verify.ReportBindErrorLog(retCode, resultDic)
  if not retCode or not resultDic then
    return
  end
  log_tree(bWriteLog and "[v_wllwu] LoginSystem.ReportBindErrorLog, resultDic is:", resultDic)
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  local paramList = {
    retCode = retCode,
    thirdRetCode = resultDic.thirdRetCode,
    account = resultDic.account,
    area_code = resultDic.areaCode,
    verify_code = resultDic.verifyCode,
    current_login_channel = SettingAccount.nLoginChannel
  }
  local operateType = Enum_BindOperateType.PhoneError
  local accountType = tonumber(resultDic.accountType)
  if accountType == ENUM_AccountType.Email then
    operateType = Enum_BindOperateType.MailError
  end
  log(bWriteLog and "[v_wllwu] LoginSystem.ReportBindErrorLog, accountType is:" .. tostring(accountType))
  log_tree(bWriteLog and "[v_wllwu] LoginSystem.ReportBindErrorLog, paramList is:", paramList)
  local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
  LoginVerifyHandler.send_report_account_bind_log(operateType, paramList)
end
function logic_login_verify.IsNotPhoneOrMail()
  local isNotPhoneOrMail = true
  if BP_ENUM_PLAYFORM_UnifiedAccountByiTOP == Client.GetLoginChannel(NetInterface) then
    isNotPhoneOrMail = false
  end
  log(bWriteLog and "  : notPhoneOrMail" .. tostring(isNotPhoneOrMail))
  return isNotPhoneOrMail
end
function logic_login_verify.HandleOpenRegion()
  if NeedOpenRegion then
    UIManager.ShowUI(UIManager.UI_Config.setting_set_region)
    logic_login_verify.SetChangeRegionFlag(nil)
  end
end
function logic_login_verify.SetChangeRegionFlag(flag)
  log(bWriteLog and "  :SetChangeRegionFlag flag" .. tostring(flag))
  NeedOpenRegion = flag
end
return logic_login_verify