local logic_account_protect_setting = {}
local needSlap = false
local needShowPopError = {
  [100150074] = 1,
  [100150075] = 1,
  [100150076] = 1,
  [100150077] = 1
}
function logic_account_protect_setting:DefineAndResetData()
  self.notice_info = {}
  self.is_gray = 0
  self.jumpToWebUrl = nil
  self.isJumpToAntiaddctionH5 = false
end
function logic_account_protect_setting:_ReportAccountFreezeAppeal()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAccountFreezeAppeal) or {}
  log_tree(bWriteLog and "logic_account_protect_setting:_ReportAccountFreezeAppeal saveData", saveData)
  if not next(saveData) then
    return
  end
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  for time, openid in pairs(saveData) do
    BasicDataTLogReport:ReportImmediate(TLogEventDefine.ClickAccountFreeze_Appeal, time, openid)
  end
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.eAccountFreezeAppeal)
end
function logic_account_protect_setting:OnInitialize()
end
function logic_account_protect_setting:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_UNBINDJUMPTO_H5, self.JumpToUnBindH5, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ACCOUNT_RISK_SLAP, self.ShowRiskSlap, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_PAKISTAN_ANTIADDCTION_H5, self.BackFromAntiaddctionH5, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_WEB_TO_GAME_LOGIN, self.OnWebToGameLogin, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LAUNCH_WEB_LOGIN, self.OnLaunchWebLogin, self)
  self:AddCommonEvent(EVENTTYPE_WEBVIEWACTION, EVENTID_WEBVIEWACTION, self.OnWebViewAction, self)
end
function logic_account_protect_setting:OnLogin(bReLogin)
end
function logic_account_protect_setting:OnLogOut()
end
function logic_account_protect_setting:OnPreSwitchGameStatus(preState, nextState)
end
function logic_account_protect_setting:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Lobby then
    self:_ReportAccountFreezeAppeal()
  end
end
function logic_account_protect_setting:OnWebToGameLogin(_, _, params)
  log_tree(bWriteLog and "logic_account_protect_setting:OnWebToGameLogin params", params)
  if not params then
    log(bWriteLog and "logic_account_protect_setting:OnWebToGameLogin - params is nil")
    return
  end
  log(bWriteLog and string.format("logic_account_protect_setting:OnWebToGameLogin state:%s", params.state))
  log(bWriteLog and string.format("logic_account_protect_setting:OnWebToGameLogin codeChallenge:%s", params.code_challenge))
  local base64 = require("client.slua.logic.lobby_watermark.base64")
  local state = base64.DecodeBase64(params.state)
  local codeChallenge = params.code_challenge
  if not state or not codeChallenge then
    log(bWriteLog and string.format("logic_account_protect_setting:OnWebToGameLogin - missing params, state=%s, code_challenge=%s", tostring(state), tostring(codeChallenge)))
    return
  end
  log(bWriteLog and string.format("logic_account_protect_setting:OnWebToGameLogin state:%s", state))
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  if not IMSDKHelperInstance then
    log(bWriteLog and "logic_account_protect_setting:OnWebToGameLogin - IMSDKHelper instance is nil")
    return
  end
  local loginParams = IMSDKHelperInstance:GetIMSDKWebLoginParamsLaunchFromWeb(state, codeChallenge)
  log(bWriteLog and string.format("logic_account_protect_setting:OnWebToGameLogin - loginParams=%s", tostring(loginParams)))
  if not loginParams or loginParams == "" then
    log(bWriteLog and "logic_account_protect_setting:OnWebToGameLogin - loginParams is empty")
    return
  end
  local LoginHandler = require("client.network.Protocol.LoginHandler")
  LoginHandler.send_get_web_login_code_req(loginParams):Then(function(err_code, sRedirectUrl)
    log(bWriteLog and string.format("logic_account_protect_setting:OnWebToGameLogin - rsp err_code=%s, url=%s", tostring(err_code), tostring(sRedirectUrl)))
    if err_code ~= 0 then
      log(bWriteLog and "logic_account_protect_setting:OnWebToGameLogin - server returned error: " .. tostring(err_code))
      return
    end
    if not sRedirectUrl or sRedirectUrl == "" then
      log(bWriteLog and "logic_account_protect_setting:OnWebToGameLogin - sRedirectUrl is empty")
      return
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local content = LocUtil.LocalizeResFormat(75534, params.url)
    CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, nil, content, function()
      Client.LaunchUrl(sRedirectUrl)
    end, nil, LocUtil.GetLocalizeResStr(8139))
    local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
    BasicDataTLogReport:ReportImmediate(TLogEventDefine.AccountSafe_WebLogin, 2)
  end)
end
function logic_account_protect_setting:GenerateVerifier()
  local seed = string.format("%s_%s_%s_%s", tostring(os.time()), tostring(math.random(100000000, 999999999)), tostring(DataMgr.roleData and DataMgr.roleData.uid or 0), tostring(math.random(100000000, 999999999)))
  return Client.SHA256(seed)
end
function logic_account_protect_setting:OnLaunchWebLogin(_, _, params)
  log_tree(bWriteLog and "logic_account_protect_setting:OnLaunchWebLogin params", params)
  if not params then
    log(bWriteLog and "logic_account_protect_setting:OnLaunchWebLogin - params is nil")
    return
  end
  self:LaunchWebLogin(params.url, params.appId)
end
function logic_account_protect_setting:LaunchWebLogin(url, appId)
  if not url or url == "" then
    log(bWriteLog and "logic_account_protect_setting:LaunchWebLogin - url is empty")
    return
  end
  if not appId or appId == "" then
    log(bWriteLog and "logic_account_protect_setting:LaunchWebLogin - appId is empty")
    return
  end
  local verifier = self:GenerateVerifier()
  self.webLoginVerifier = verifier
  log(bWriteLog and string.format("logic_account_protect_setting:LaunchWebLogin - verifier=%s", tostring(verifier)))
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  if not IMSDKHelperInstance then
    log(bWriteLog and "logic_account_protect_setting:LaunchWebLogin - IMSDKHelper instance is nil")
    return
  end
  local sParams = IMSDKHelperInstance:GetIMSDKWebLoginParams(url, appId, verifier)
  log(bWriteLog and string.format("logic_account_protect_setting:LaunchWebLogin - sParams=%s", tostring(sParams)))
  if not sParams or sParams == "" then
    log(bWriteLog and "logic_account_protect_setting:LaunchWebLogin - sParams is empty")
    return
  end
  local LoginHandler = require("client.network.Protocol.LoginHandler")
  LoginHandler.send_get_web_login_code_req(sParams):Then(function(err_code, sRedirectUrl)
    log(bWriteLog and string.format("logic_account_protect_setting:LaunchWebLogin - rsp err_code=%s, url=%s", tostring(err_code), tostring(sRedirectUrl)))
    if err_code ~= 0 then
      log(bWriteLog and "logic_account_protect_setting:LaunchWebLogin - server returned error: " .. tostring(err_code))
      return
    end
    self:OnWebLoginRedirectUrl(sRedirectUrl, url)
  end)
end
function logic_account_protect_setting:OnWebLoginRedirectUrl(sRedirectUrl, url)
  if not sRedirectUrl or sRedirectUrl == "" then
    log(bWriteLog and "logic_account_protect_setting:OnWebLoginRedirectUrl - sRedirectUrl is empty")
    return
  end
  if not self.webLoginVerifier or self.webLoginVerifier == "" then
    log(bWriteLog and "logic_account_protect_setting:OnWebLoginRedirectUrl - webLoginVerifier is empty")
    return
  end
  local separator = string.find(sRedirectUrl, "?") and "&" or "?"
  local finalUrl = sRedirectUrl .. separator .. "code_verifier=" .. self.webLoginVerifier
  log(bWriteLog and string.format("logic_account_protect_setting:OnWebLoginRedirectUrl - finalUrl=%s", finalUrl))
  self.webLoginVerifier = nil
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local content = LocUtil.LocalizeResFormat(75534, url)
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, nil, content, function()
    Client.LaunchUrl(finalUrl)
  end, nil, LocUtil.GetLocalizeResStr(8139))
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportImmediate(TLogEventDefine.AccountSafe_WebLogin, 1)
end
function logic_account_protect_setting:BackFromAntiaddctionH5(_, _, params)
  log_tree(bWriteLog and "logic_account_protect_setting:BackFromAntiaddctionH5 params", params)
  local minors_info = {
    guardian_name = "",
    guardian_email = params and tostring(params.address) or "",
    guardian_confirm = params and tonumber(params.status) or 0
  }
  local AntiaddctionHandler = require("client.network.Protocol.AntiaddctionHandler")
  AntiaddctionHandler.send_report_pakistan_minors_info_req(1, minors_info)
  local AntiaddctionSystem = require("client.logic.antiaddction.logic_antiaddction")
  AntiaddctionSystem.OpenNoticePanel()
end
function logic_account_protect_setting:SetIsJumpToAntiaddctionH5(isJump)
  self.isJumpToAntiaddctionH5 = isJump
end
function logic_account_protect_setting:ReturnFromITopAccountH5(result)
  log_tree(bWriteLog and "logic_account_protect_setting:ReturnFromITopAccountH5 result", result)
  if result.operateType and result.operateType == 0 then
    if result.url and result.url ~= "" then
      GlobalData.JumpGameUrl(result.url)
    end
  elseif result.operateList and next(result.operateList) and result.operateType and result.operateType == 7 then
    local isOperateSocialAccount, isOperateMailOrPhone = self:CheckOperateAccountType(result.operateList)
    if isOperateSocialAccount or isOperateMailOrPhone then
      local title = LocUtil.GetLocalizeResStr(7390)
      local content = LocUtil.GetLocalizeResStr(38925)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, title, content)
      local IMSDKHelper = import("IMSDKHelper")
      local IMSDKHelperInstance = IMSDKHelper.GetInstance()
      if IMSDKHelperInstance then
        IMSDKHelperInstance:GetBindInfo()
      end
      EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_FAST_UNBIND_SUCCESS)
      Client.LogoutAllDevices(NetInterface)
      self:AddTimerOnce(0.1, function()
        local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
        login_module:sendLogout()
      end)
    elseif result.url and result.url ~= "" then
      GlobalData.JumpGameUrl(result.url)
    end
  end
end
function logic_account_protect_setting:CheckOperateAccountType(operateList)
  local isOperateSocialAccount = false
  local isOperateMailOrPhone = false
  for _, str in ipairs(operateList) do
    if str ~= "" then
      if str:find("*") then
        isOperateMailOrPhone = true
      else
        isOperateSocialAccount = true
      end
    end
  end
  return isOperateSocialAccount, isOperateMailOrPhone
end
function logic_account_protect_setting:OnWebViewAction(_, _, str)
  if str == "2" then
    if self.jumpToWebUrl then
      GlobalData.JumpWebUrl(self.jumpToWebUrl)
      self.jumpToWebUrl = nil
    end
    if self.isJumpToAntiaddctionH5 then
      self:BackFromAntiaddctionH5()
      self.isJumpToAntiaddctionH5 = false
    end
  end
end
function logic_account_protect_setting:GetIsGray()
  return self.is_gray == 1
end
function logic_account_protect_setting:GetNoticeInfo()
  return self.notice_info
end
function logic_account_protect_setting:GetIsClickGo()
  return self.isClickGo
end
function logic_account_protect_setting:SetIsClickGo(isClick, from)
  if self.isClickGo then
    return
  end
  local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
  local noticeInfo = logic_account_protect_setting:GetNoticeInfo()
  if noticeInfo then
    local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
    LoginVerifyHandler.send_report_notice_readed_req()
  end
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportImmediate(TLogEventDefine.AccountSafe_Risk_Readed, from)
  self.isClickGo = isClick
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_RISK_READED)
end
function logic_account_protect_setting:JumpToITopH5()
  local BusinessHelper = import("BusinessHelper")
  local iEnv = BusinessHelper.GetIMSDKEnv()
  local url = FuncUtil.GetDomainByID(3366185)
  if iEnv == 1 then
    url = FuncUtil.GetDomainByID(3366186)
  end
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  local deviceId_enc, data_enc
  if not IsEditor then
    deviceId_enc = webModule:GetEncryptedDeviceInfoUrlValue(3, "{device_id}")
    data_enc = webModule:GetEncryptedDeviceInfoUrlValue(3, "&device={device_name}&deviceId={device_id}&infoTime={info_time}&scene=5")
  end
  local ticket = Client.GetWebViewTicket(NetInterface)
  local iGameid = Client.GetITopGameId(NetInterface)
  local langType = webModule:GetCurrentLanguage()
  local deviceId = deviceId_enc
  local roleName = webModule:URLEncode(tostring(DataMgr.roleData.nickName))
  local deviceName = webModule:URLEncode(Client.GetDeivceNickName())
  local deviceHardware = webModule:URLEncode(Client.GetPhoneType())
  local os = string.lower(Client.GetDevicePlatformName())
  local itopDid = self:GetITopDid()
  local version_util = require("client.common.version_util")
  local version = version_util.GetMainFormat(Client.GetAppVersion())
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local platId = 1
  if os == DevicePlatformNameMacros.IOS then
    platId = 0
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local gameArea = ZoneSystem.GetChooseZone()
  local PandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  local areaId = PandoraSystem.GetAreaId()
  local TimeUtil = require("client.common.time_util")
  local timeZone = TimeUtil.GetTimeZone()
  local osVersion = Client.GetOSVersion()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local country = login_module.sIpRegion
  if webModule:GetDefaultEncryptMetod() ~= 1 then
    local params = "?sTicket=%s&game_id=%s&language=%s&roleName=%s&iTopDid=%s&device_name=%s&device_hardware=%s&os=%s&data_enc=%s&version=%s&plat_id=%s&game_area=%s&area_id=%s&time_zone=%s&os_version=%s&country=%s&never_adjust=1"
    params = string.format(params, ticket, iGameid, langType, roleName, itopDid, deviceName, deviceHardware, os, data_enc, version, platId, gameArea, areaId, timeZone, osVersion, country)
    url = url .. params
  else
    local params = "?sTicket=%s&game_id=%s&language=%s&sDid=%s&roleName=%s&iTopDid=%s&device_name=%s&device_hardware=%s&os=%s&version=%s&plat_id=%s&game_area=%s&area_id=%s&time_zone=%s&os_version=%s&country=%s&never_adjust=1"
    params = string.format(params, ticket, iGameid, langType, deviceId, roleName, itopDid, deviceName, deviceHardware, os, version, platId, gameArea, areaId, timeZone, osVersion, country)
    url = url .. params
  end
  log(bWriteLog and string.format("logic_account_protect_setting:JumpToITopH5, url:%s", url))
  GlobalData.JumpWebUrl(url)
end
function logic_account_protect_setting:GetITopDid()
  local IMSDKHelper = import("IMSDKHelper")
  local ret = IMSDKHelper.GetInstance():GetIMSDKClientApiParams()
  local base64 = require("client.slua.logic.lobby_watermark.base64")
  local clientBase64Str = string.gsub(ret, "-", "+")
  clientBase64Str = string.gsub(clientBase64Str, "_", "/")
  local afterDecode = base64.DecodeBase64(clientBase64Str)
  local imsdkRetMsgTable = json.decode(afterDecode)
  log(bWriteLog and string.format("logic_account_protect_setting:GetITopDid, afterDecode:%s", afterDecode))
  local itopDid = imsdkRetMsgTable and imsdkRetMsgTable.client_params and imsdkRetMsgTable.client_params.did
  if itopDid then
    local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
    local itopDid_enc = webModule:GetEncryptedDeviceInfoUrlValue(3, itopDid)
    return itopDid_enc
  end
  return nil
end
function logic_account_protect_setting:JumpToUnBindH5()
  local BusinessHelper = import("BusinessHelper")
  local iEnv = BusinessHelper.GetIMSDKEnv()
  local url = FuncUtil.GetDomainByID(3366188)
  if iEnv == 1 then
    url = FuncUtil.GetDomainByID(3366189)
  end
  local CSJumpModule = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.CSJumpModule)
  local args_json, h5_param = CSJumpModule:get_open_args_json()
  log_tree(bWriteLog and "logic_account_protect_setting:JumpToUnBindH5 h5_param", h5_param)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local country = login_module:GetIpRegion()
  local params = "?game_area=%s&region=%s&area_id=%s&game_id=%s&version=%s&language=%s&time_zone=%s&platform=%s&os_version=%s&country=%s&data_enc=%s&never_adjust=%s&sTicket=%s&sign=%s9&openid=%s&uid=%s&channel_id=%s&channel=10003"
  params = string.format(params, h5_param.z, h5_param.sRegion, h5_param.area_id, h5_param.appid, h5_param.version, h5_param.lang_type, h5_param.time_zone, h5_param.platform, h5_param.os_version, country, h5_param.data_enc, 1, h5_param.sTicket, "", h5_param.openid, tostring(DataMgr.roleData.uid or ""), h5_param.channel_id)
  url = url .. params
  log(bWriteLog and string.format("logic_account_protect_setting:JumpToUnBindH5, url:%s", url))
  self.jumpToWebUrl = url
end
function logic_account_protect_setting:JumpToRetrieveH5()
  local BusinessHelper = import("BusinessHelper")
  local iEnv = BusinessHelper.GetIMSDKEnv()
  local url = FuncUtil.GetDomainByID(3366202)
  if iEnv == 1 then
    url = FuncUtil.GetDomainByID(3366203)
  end
  local CSJumpModule = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.CSJumpModule)
  local args_json, h5_param = CSJumpModule:get_open_args_json()
  log_tree(bWriteLog and "logic_account_protect_setting:JumpToRetrieveH5 h5_param", h5_param)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local country = login_module:GetIpRegion()
  local params = "?game_area=%s&region=%s&area_id=%s&game_id=%s&version=%s&language=%s&time_zone=%s&platform=%s&os_version=%s&country=%s&data_enc=%s&never_adjust=%s&sTicket=%s&sign=%s9&openid=%s&uid=%s&channel_id=%s&channel=10004"
  params = string.format(params, h5_param.z, h5_param.sRegion, h5_param.area_id, h5_param.appid, h5_param.version, h5_param.lang_type, h5_param.time_zone, h5_param.platform, h5_param.os_version, country, h5_param.data_enc, 1, h5_param.sTicket, "", h5_param.openid, tostring(DataMgr.roleData.uid or ""), h5_param.channel_id)
  url = url .. params
  GlobalData.JumpWebUrl(url)
  log(bWriteLog and string.format("logic_account_protect_setting:JumpToRetrieveH5, url:%s", url))
end
function logic_account_protect_setting:GetOperationTypeByCodeType(code_type)
  local setting_macro = require("client.slua.logic.setting.setting_macro")
  if code_type == setting_macro.AccountVerifyCodeType.Register then
    return setting_macro.AccountOperationType.Bind
  elseif code_type == setting_macro.AccountVerifyCodeType.NewSelfAccount then
    return setting_macro.AccountOperationType.Modify
  elseif code_type == setting_macro.AccountVerifyCodeType.CurAccountCheck then
    return setting_macro.AccountOperationType.Replace
  elseif code_type == setting_macro.AccountVerifyCodeType.UpdateSelfAccount then
    return setting_macro.AccountOperationType.Replace
  end
end
function logic_account_protect_setting:IsNeedShowLimitErrorPopup(error)
  return needShowPopError[error] ~= nil
end
function logic_account_protect_setting:ShowLimitErrorPopup(type, error)
  UIManager.ShowUI(UIManager.UI_Config.Setting_Account_Prompt_Popup_UIBP, type, error)
end
function logic_account_protect_setting.IsCanShowRiskSlap()
  return needSlap
end
function logic_account_protect_setting:ShowRiskSlap()
  local common_config = require("client.slua.common.common_config")
  if not common_config:IsBlockingPopupTip() and needSlap then
    UIManager.ShowUI(UIManager.UI_Config.Setting_AccountSecurityTips_Popup_UIBP)
    needSlap = false
  end
end
function logic_account_protect_setting:IsCurSelectModeLimit()
  if not self.nModeLimitStatus or self.nModeLimitStatus == 0 then
    log(bWriteLog and "logic_account_protect_setting:IsCurSelectModeLimit, no restriction status")
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if not logic_mode_selection then
    log_error("logic_account_protect_setting:IsCurSelectModeLimit, logic_mode_selection is nil")
    return false
  end
  local matchMode, _, _ = logic_mode_selection:GetCurSelectInfo()
  if not matchMode then
    log(bWriteLog and "logic_account_protect_setting:IsCurSelectModeLimit, matchMode is nil")
    return false
  end
  local restrictedModes = {
    [101] = true,
    [102] = true,
    [103] = true,
    [401] = true,
    [402] = true,
    [403] = true,
    [11201] = true,
    [23101] = true,
    [23103] = true
  }
  local isRestricted = restrictedModes[matchMode] == true
  log_format("logic_account_protect_setting:IsCurSelectModeLimit, matchMode:%s, isRestricted:%s, status:%s", matchMode, tostring(isRestricted), tostring(self.nModeLimitStatus))
  return isRestricted
end
function logic_account_protect_setting:ShowModeLimitPopup(uid)
  local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
  local bIsInTeam = logic_team_up.GetTeamNum() > 1
  if bIsInTeam and logic_team_up.IsTeamLeader() and uid then
    local name = logic_team_up.GetMemberName(uid)
    ShowNotice(LocUtil.LocalizeResFormat(612401102, name))
    return
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local title = LocUtil.GetLocalizeResStr(101001)
  local content = LocUtil.LocalizeResFormat(612401101)
  local buttonText = LocUtil.GetLocalizeResStr(49265)
  local confirmCallback = function()
    local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
    local logic_gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    local enc_data
    if not IsEditor then
      enc_data = webModule:GetEncryptedDeviceInfoUrlValue(1, "&device={device_name}&deviceId={device_id}&xwid={xwid}&infoTime={info_time}", 3)
    end
    local sTicket = Client.GetWebViewTicket(NetInterface)
    local channel = Client.GetLoginChannel(NetInterface)
    local iGameid = Client.GetITopGameId(NetInterface)
    local language = webModule:GetCurrentLanguage()
    local country = login_module.sIpRegion
    local PandoraSystem = require("client.slua.logic.Pandora.pandora_system")
    local areaId = PandoraSystem.GetAreaId()
    local TimeUtil = require("client.common.time_util")
    local timeZone = TimeUtil.GetTimeZone()
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    local platId = 1
    if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
      platId = 0
    end
    local nickName = webModule:URLEncode(tostring(DataMgr.roleData.nickName)) or ""
    local status = self.nModeLimitStatus or 0
    if not self.sModeLimitUrl or self.sModeLimitUrl == "" then
      log_error("logic_account_protect_setting:ShowModeLimitPopup, ModeLimitUrl is empty")
      return
    end
    local baseUrl = self.sModeLimitUrl
    local anchor = ""
    local anchorPos = string.find(baseUrl, "#")
    if anchorPos then
      anchor = string.sub(baseUrl, anchorPos)
      baseUrl = string.sub(baseUrl, 1, anchorPos - 1)
    end
    local separator = string.find(baseUrl, "?") and "&" or "?"
    local params = string.format("enc_data=%s&sTicket=%s&channel=%s&gameid=%s&language=%s&country=%s&areaId=%s&timeZone=%s&plat_id=%s&role_name=%s&status=%s", enc_data, sTicket, channel, iGameid, language, country, areaId, timeZone, platId, nickName, status)
    local finalUrl = baseUrl .. separator .. params .. anchor
    log(bWriteLog and string.format("logic_account_protect_setting:ShowModeLimitPopup, url:%s", finalUrl))
    log_format("logic_account_protect_setting:ShowModeLimitPopup, jump to url, status:%s", status)
    GlobalData.JumpWebUrl(finalUrl)
  end
  CommonMsgBoxMgr.Show(2, title, content, nil, confirmCallback, nil, buttonText)
end
function logic_account_protect_setting:on_account_group_info_notify(notice_info, is_gray)
  self.  self.  if notice_info.iNoticeType == 1 then
    needSlap = true
    local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
    NewFaceSlapSystem:ShowFaceSlapByID(BP_ENUM_MODULE_ACCOUNT_RISK_SLAP)
  end
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_RISK_RSP)
end
function logic_account_protect_setting:on_notify_account_status(status, url)
  self.nModeLimitStatus = status
  self.sModeLimitUrl = url
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_account_protect_setting = class(CModuleBase, nil, logic_account_protect_setting)
return Clogic_account_protect_setting