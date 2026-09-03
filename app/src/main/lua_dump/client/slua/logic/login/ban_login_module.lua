local ban_login_module = {}
local TimeUtil = require("client.common.time_util")
local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local strRegion = Client.GetPublishRegion()
function ban_login_module:DefineAndResetData()
  self.hasKickOut = nil
  self.kickoutCountdown = 0
  self.forceRepair = nil
end
function ban_login_module:ResethasKickOut()
  self.hasKickOut = nil
end
local banLoginAppeal = function()
  local ban = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
  ban:banLoginAppeal()
end
local banLoginDetail = function()
  local ban = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
  ban:banLoginDetail()
end
local banLoginUserTerms = function()
  local ban = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
  ban:banLoginUserTerms()
end
local backLogin = function(reason)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:backLogin(reason)
end
local kickoutCountdownTimerCallback = function()
  local ban = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
  ban:kickoutCountdownTimerCallback()
end
local sendLogout = function()
  local ban = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
  ban:sendLogout()
end
function ban_login_module:banLoginUserTerms()
  log_warning(bWriteLog and "  : banLoginUserTerms")
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  sendLogout()
  gem_report_utils.ReportEventDelay(gem_report_utils.EventName_Network, "disconnect", "ban")
  local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
  if strRegion == PublishRegionMacros.JAPAN then
    WebviewSDK:OpenURL(FuncUtil.GetDomainByID(3366039) .. "/terms.html")
  elseif strRegion == PublishRegionMacros.KOREA then
    WebviewSDK:OpenURL(FuncUtil.GetDomainByID(3366040) .. "/battlegroundsmobile/6804")
  elseif strRegion == PublishRegionMacros.BLUEHOLE then
    WebviewSDK:OpenURL(FuncUtil.GetDomainByID(3366047) .. "/terms")
  else
    WebviewSDK:OpenURL(FuncUtil.GetDomainByID(3366036) .. "/terms.html")
  end
  NetUtil.Disconnect()
end
function ban_login_module:banLoginAppeal()
  log_warning(bWriteLog and "  :login_module banLoginAppeal")
  ClientSendBAReport(TLogEventDefine.LobbySafetyAppeal, 0, nil, true)
  self:AddTimerOnce(0.1, function()
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:DelaybanLoginCancelCallback()
  end)
  self:AddTimerOnce(1, function()
    backLogin()
  end)
end
function ban_login_module:banLoginDetail()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  log(bWriteLog and "LoginSystem.banLoginDetail LoginSystem.link_type = " .. tostring(login_module.nLink_type))
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  if login_module.nLink_type == 2 then
    ClientSendBAReport(TLogEventDefine.IDIPJIANMIANCHUFA, 0, nil, true)
    local url = FuncUtil.GetDomainByID(3366177) .. "/user_guide/index.html?" .. FuncUtil.GetKeywordByID(3377009)
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, "Id", webModule.h5Parameter.gameid, true)
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, webModule.h5Parameter.language)
    local country = login_module.sBancountry or self:GetIpRegion()
    url = webModule:AddPersonalInfoPropertyAndValue(url, webModule.h5Parameter.country, country)
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, webModule.h5Parameter.loginType, webModule.h5Parameter.loginType)
    local nickName = login_module.sBanNickname or DataMgr.roleData.nickName
    nickName = webModule:URLEncode(tostring(nickName))
    url = webModule:AddPersonalInfoPropertyAndValue(url, "roleName", nickName)
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, webModule.h5Parameter.timeZone, webModule.h5Parameter.timeZone)
    url = webModule:AddParameterByPersonalInfo(url, false, true)
    log(bWriteLog and "banLoginDetail url = (new) " .. tostring(url))
    local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
    WebviewSDK:OpenURL(url, true)
    self:AddTimerOnce(1, function()
      backLogin()
    end)
    return
  end
  if login_module.nLink_type and login_module.nLink_type == 3 then
    ClientSendBAReport(TLogEventDefine.IDIPJIECHUDONGJIE, 0, nil, true)
    local enc_data = webModule:GetEncryptedDeviceInfoUrlValue(2, "device_id={device_id}&xwid={xwid}&scene=3")
    local url = FuncUtil.GetDomainByID(3366177) .. "/safemode/index.html?"
    local country = login_module.sBancountry or login_module.sIpRegion or self:GetIpRegion()
    local roleName = login_module.sBanNickname or DataMgr.roleData.nickName
    roleName = webModule:URLEncode(tostring(roleName))
    url = webModule:AddPersonalInfoPropertyAndValue(url, "enc", enc_data, true)
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, "game_id", webModule.h5Parameter.gameid)
    url = webModule:AddPersonalInfoPropertyAndValue(url, webModule.h5Parameter.country, country)
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, webModule.h5Parameter.language)
    url = webModule:AddPersonalInfoPropertyAndValue(url, "role_name", roleName)
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, "timezone", webModule.h5Parameter.timeZone)
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, "iticket", webModule.h5Parameter.itop_ticket)
    url = webModule:AddParameterByPersonalInfo(url, false, true)
    GlobalData.JumpUrl(url)
    return
  end
  ClientSendBAReport(TLogEventDefine.LobbySafetyDetail, 0)
  local url = ""
  if strRegion == PublishRegionMacros.BLUEHOLE then
    url = FuncUtil.GetDomainByID(3366047) .. "/"
  else
    local BusinessHelper = import("BusinessHelper")
    local openid = BusinessHelper.GetOpenId()
    url = FuncUtil.GetDomainByID(3366036) .. "/act/a20190812aqxz/closeInfo.shtml?"
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, webModule.h5Parameter.sTicket, webModule.h5Parameter.itop_ticket, true)
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, webModule.h5Parameter.gameid)
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, webModule.h5Parameter.language)
    url = webModule:AddPersonalInfoPropertyAndValue(url, "openid", openid)
    url = webModule:AddPersonalInfoPropertyAndValue(url, "v", 1)
    url = webModule:AddParameterByPersonalInfo(url, false, true)
  end
  local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
  WebviewSDK:OpenURL(url, true)
  webModule:SetneedLogoutOnCloseWeb(true)
  if not GameStatus.IsInLobbyOrMainCity() then
    backLogin()
  end
end
function ban_login_module:ShowIDIPBanTips(banInfo, banTime, uid)
  log(bWriteLog and "LoginSystem.ShowIDIPBanTips:" .. tostring(uid))
  local date = TimeUtil.FormatTime_YMDHMS(banTime, true)
  local textLift = LocUtil.GetLocalizeResStr(49428)
  local textEmail = ""
  local title = LocUtil.GetLocalizeResStr(101001)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if PublishRegionMacros.IsGlobalVersion() then
  elseif PublishRegionMacros.IsJapanOrKorea() then
    textEmail = LocUtil.GetLocalizeResStr(7400)
  elseif Client.GetPublishRegion() == PublishRegionMacros.CE or Client.GetPublishRegion() == PublishRegionMacros.FITCE then
    textEmail = LocUtil.GetLocalizeResStr(79609)
  elseif Client.GetPublishRegion() == PublishRegionMacros.VNG then
    textEmail = LocUtil.GetLocalizeResStr(16020)
  elseif Client.GetPublishRegion() == PublishRegionMacros.TW then
  elseif Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
  elseif Client.GetPublishRegion() == PublishRegionMacros.FIT then
  end
  if login_module.nLink_type == 3 then
    textLift = LocUtil.GetLocalizeResStr(49428)
    textEmail = LocUtil.GetLocalizeResStr(49429)
  end
  local msg = ""
  if uid and uid ~= 0 then
    msg = LocUtil.LocalizeResFormat(44575, tostring(uid)) .. "\n"
  end
  msg = string.format(textLift, msg, date)
  msg = msg .. "\n" .. banInfo
  if textEmail ~= "" then
    msg = msg .. "\n" .. textEmail
  end
  if login_module.nLink_type == 3 then
    local btnLeft = LocUtil.GetLocalizeResStr(49265)
    CommonMsgBoxMgr.Show(2, title, msg, nil, banLoginDetail, nil, btnLeft)
  elseif PublishRegionMacros.IsJapanOrKorea() then
    local btnOK = LocUtil.GetLocalizeResStr(4003)
    local btnCancel = LocUtil.GetLocalizeResStr(4004)
    CommonMsgBoxMgr.Show(2, title, msg, banLoginAppeal, banLoginUserTerms, btnCancel, btnOK, {
      is5s = true,
      autoCloseTime = 150,
      autoCloseWithoutCallback = true,
      hideAutoCloseRemainTime = true
    })
  else
    local btnOK = ""
    local okCallback = banLoginDetail
    if login_module.nLink_type == 2 then
      btnOK = LocUtil.GetLocalizeResStr(8500233)
    elseif login_module.nAppeal_switch and login_module.nAppeal_switch == 1 then
      btnOK = LocUtil.GetLocalizeResStr(110036)
      function okCallback()
        login_module:backLogin()
      end
    else
      btnOK = LocUtil.GetLocalizeResStr(7943)
    end
    local btnCancel = LocUtil.GetLocalizeResStr(4004)
    local urlText = LocUtil.GetLocalizeResStr(7942)
    local extraData = {
      showUIKey = "com_msg_box_5s",
      urlTips = urlText,
      urlHandle = banLoginUserTerms,
      autoCloseTime = 150,
      autoCloseWithoutCallback = true,
      hideAutoCloseRemainTime = true,
      onTimerInvoke = kickoutCountdownTimerCallback
    }
    CommonMsgBoxMgr.Show(2, title, msg, okCallback, banLoginAppeal, btnOK, btnCancel, extraData)
  end
end
local maxKickout = 9
function ban_login_module:kickoutCountdownTimerCallback()
  log(bWriteLog and "login_module.kickoutCountdownTimerCallback" .. self.kickoutCountdown)
  self.kickoutCountdown = self.kickoutCountdown + 1
  if self.kickoutCountdown > maxKickout then
    self.kickoutCountdown = 0
    CommonMsgBoxMgr.HideAllPanel()
    local login = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login:backLogin()
  end
end
function ban_login_module:on_kickout(msg, banInfo, banTime, localizeResID, op_type, sDeviceName, ext_info, login_channel, info)
  log(bWriteLog and "on_kickout " .. msg .. "banTime = " .. tostring(banTime) .. " localizeResID = " .. tostring(localizeResID) .. " op_type = " .. tostring(op_type) .. " sDeviceName = " .. tostring(sDeviceName) .. " login_channel " .. tostring(login_channel))
  log_tree("on_kickout ext_info", ext_info)
  log_tree("  ban_login_module:on_kickout. info ", info)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  self.hasKickOut = true
  if ext_info and type(ext_info) == "table" then
    login_module.nLink_type = ext_info.link_type
  end
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  NetUtil.Disconnect()
  local hasLogoutMSDKLoginData = false
  if Client.GetLoginChannel(NetInterface) == BP_ENUM_PLAYFORM_UnifiedAccountByiTOP then
    local SettingAccount = require("client.logic.setting.logic_setting_account")
    SettingAccount.ClientLogout()
    hasLogoutMSDKLoginData = true
  end
  gem_report_utils.ReportEventDelay(gem_report_utils.EventName_Network, "disconnect", "kickout")
  login_module:RemoveLoginTimer()
  Client.ClearChannelID(NetInterface)
  local extraData = {
    showUIKey = "com_msg_box_5s"
  }
  local title = LocUtil.GetLocalizeResStr(101001)
  local sLocalHM = TimeUtil.FormatTime_HM(TimeUtil.GetServerTimeInSec(), true)
  local bShowDeviceName = sDeviceName and sDeviceName ~= "" and sDeviceName ~= "unknown_device"
  local text = LocUtil.LocalizeResFormat(27708, sLocalHM, bShowDeviceName and sDeviceName:gsub("^%l", string.upper) or "")
  if op_type and op_type == "weeding_ban" then
    self.forceRepair = true
    backLogin()
  elseif msg == "not-in-open-time" then
    text = LocUtil.GetLocalizeResStr(101702)
    extraData = {
      showUIKey = "com_msg_box_5s",
      onTimerInvoke = kickoutCountdownTimerCallback
    }
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData)
  elseif msg == "ban-login" or msg == "parents_ban" then
    banInfo = LocUtil.LocalizeResFormatByStr(banInfo)
    if banTime == -1 then
      CommonMsgBoxMgr.Show(1, title, banInfo, backLogin, nil, nil, nil, extraData)
    else
      local date = TimeUtil.FormatTime_YMDHMS(banTime, true)
      local textLift = LocUtil.GetLocalizeResStr(49428)
      text = string.format(textLift, LocUtil.LocalizeResFormat(44575, DataMgr.roleData.uid) .. "\n", date .. "\n" .. banInfo)
      local textEmail = ""
      if PublishRegionMacros.IsGlobalVersion() then
      elseif PublishRegionMacros.IsJapanOrKorea() then
        textEmail = LocUtil.GetLocalizeResStr(7400)
      elseif Client.GetPublishRegion() == PublishRegionMacros.CE or Client.GetPublishRegion() == PublishRegionMacros.FITCE then
        textEmail = LocUtil.GetLocalizeResStr(79609)
      elseif Client.GetPublishRegion() == PublishRegionMacros.VNG then
        textEmail = LocUtil.GetLocalizeResStr(16020)
      elseif Client.GetPublishRegion() == PublishRegionMacros.TW then
      elseif Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
      elseif Client.GetPublishRegion() == PublishRegionMacros.FIT then
      end
      if textEmail ~= "" then
        text = text .. "\n" .. textEmail
      end
      extraData = {
        showUIKey = "com_msg_box_5s",
        onTimerInvoke = kickoutCountdownTimerCallback
      }
      CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData)
    end
  elseif msg == "idip-kick-out" then
    text = LocUtil.GetLocalizeResStr(115006)
    extraData = {
      showUIKey = "com_msg_box_5s",
      onTimerInvoke = kickoutCountdownTimerCallback
    }
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData)
  elseif msg == "aas_once_force_rest" then
    local a = banInfo.reachTime / 3600
    local b = math.floor(banInfo.restTime / 60)
    local notice = LocUtil.GetLocalizeResStr(115004)
    text = string.format(notice, a, b)
    extraData = {
      showUIKey = "com_msg_box_5s",
      onTimerInvoke = kickoutCountdownTimerCallback
    }
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData)
  elseif msg == "aas_acc_force_rest" then
    local a = banInfo.reachTime / 3600
    local b = math.floor(banInfo.restTime / 60)
    local notice = LocUtil.GetLocalizeResStr(115004)
    text = string.format(notice, a, b)
    extraData = {
      showUIKey = "com_msg_box_5s",
      onTimerInvoke = kickoutCountdownTimerCallback
    }
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData)
  elseif msg == "aas_acc_ban" then
    local date = TimeUtil.FormatTime_YMDHMS(banTime.endTime, true)
    local textvalue = LocUtil.GetLocalizeResStr(115011)
    text = string.format(textvalue, date)
    extraData = {
      showUIKey = "com_msg_box_5s",
      onTimerInvoke = kickoutCountdownTimerCallback
    }
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData)
  elseif msg == "aas_acc_curfew" then
    text = LocUtil.GetLocalizeResStr(115010)
    extraData = {is5s = true, onTimerInvoke = kickoutCountdownTimerCallback}
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData)
  elseif msg == "login-in-other-device" then
    local showComMsgPopups = function(isPreciseChannel)
      local SettingSystem = require("client.logic.setting.logic_setting")
      local channelName
      if isPreciseChannel then
        channelName = SettingSystem.GetNameByImsdkChannel(tonumber(login_channel), SettingSystem.NBindExtType)
      else
        channelName = LocUtil.GetLocalizeResStr(27924)
      end
      info = info or {}
      local account_type = info.account_type
      if account_type then
        local channelStr = login_module:GetChannelName(account_type)
        if channelStr then
          channelName = channelStr
        end
      end
      local name = info.device_name or ""
      local defineName = info.define_name or ""
      if not tonumber(defineName) and 0 < #defineName then
        name = name .. "/" .. defineName
      end
      if info.is_qrcode_login then
        channelName = LocUtil.GetLocalizeResStr(200000062)
      end
      text = LocUtil.LocalizeResFormat(200000463, sLocalHM, channelName, name, info.region)
      log(bWriteLog and "  ban_login_module:on_kickout. text: " .. tostring(text))
      local okCallback = function()
        if not hasLogoutMSDKLoginData then
          local IMSDKQRCodeSystem = require("client.logic.login.logic_imsdk_qrcode")
          if not IMSDKQRCodeSystem:IsQRCodeLogined() then
            local SettingAccount = require("client.logic.setting.logic_setting_account")
            SettingAccount.ClientLogout()
          else
            log(bWriteLog and "Not clear login data kickout by other device with QRCode login")
          end
        end
        backLogin()
      end
      UIManager.ShowUI(UIManager.UI_Config.Setting_TopMark_Popup, text, okCallback)
    end
    if Client.GetLoginChannel(NetInterface) == BP_ENUM_PLAYFORM_UnifiedAccountByiTOP then
      local time_ticker = require("common.time_ticker")
      self.DelayPopups = time_ticker.AddTimerLoop(1, function()
        local curStatus = GameStatus.GetGameStatus()
        if curStatus == GameStatus.Login then
          showComMsgPopups(login_channel ~= BP_ENUM_IMSDK_CHANNEL_UNIFIEDACCOUNT)
          time_ticker.RemoveTimer(self.DelayPopups)
        end
      end, 10, 0.5)
    else
      showComMsgPopups(true)
    end
  elseif msg == "gdpr_deleting" or msg == "ios_deleting" or msg == "aos_deleting" or msg == "krjp_deleting" then
    text = LocUtil.GetLocalizeResStr(4367)
    extraData = {is5s = true, onTimerInvoke = kickoutCountdownTimerCallback}
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData)
  elseif msg == "metro_kick_out" or banInfo == "metro_kick_out" then
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_ON_ENTERTPLAN_NOTIFY, false)
    text = LocUtil.GetLocalizeResStr(localizeResID or 11975)
    extraData = {is5s = true, onTimerInvoke = kickoutCountdownTimerCallback}
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData)
  elseif msg == "ds_kickout_player" and localizeResID and 0 < localizeResID then
    Client.ReturnToLobby(GameFrontendHUD)
    self:AddTimer(1, function()
      backLogin()
      coroutine.yield(1)
      local content = LocUtil.GetLocalizeResStr(localizeResID)
      local logic_region_block = require("client.logic.logic_region_block.logic_region_block")
      local ipRegion = login_module.sIpRegion or "ALL"
      extraData = {
        urlHandle = logic_region_block.MakeUrlCallBack(ipRegion)
      }
      local okCallback = function()
      end
      UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 1, LocUtil.GetLocalizeResStr(5077), content, nil, LocUtil.GetLocalizeResStr(8139), nil, okCallback, nil, extraData)
    end)
  elseif msg == "delay-kick-out" then
    text = LocUtil.GetLocalizeResStr(24228)
    extraData = {is5s = true, onTimerInvoke = kickoutCountdownTimerCallback}
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData)
  elseif msg == "minor_reach_daily_limit" then
    text = LocUtil.GetLocalizeResStr(44549)
    extraData = {is5s = true, onTimerInvoke = kickoutCountdownTimerCallback}
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData)
  elseif msg == "qrcode_grant_ok" then
    title = LocUtil.GetLocalizeResStr(200000068)
    text = LocUtil.LocalizeFormatConcatenation(200000121, tostring(sDeviceName:gsub("^%l", string.upper)), TimeUtil.FormatTime_YMDHMS(ext_info, false, true))
    login_module:addLogoutCallback(function()
      log(bWriteLog and "qrcode_grant_ok logout pop")
      UIManager.ShowUI(UIManager.UI_Config.Login_QRCode_Success_Popup_UIBP, title, text, LocUtil.LocalizeFormatConcatenation(200000122))
    end)
    backLogin()
  elseif msg == "qrcode_login_kickout" then
    login_module:addLogoutCallback(function()
      log(bWriteLog and "qrcode_login_kickout logout pop")
      title = LocUtil.GetLocalizeResStr(200000100)
      text = LocUtil.GetLocalizeResStr(200000107)
      extraData = {is5s = true}
      CommonMsgBoxMgr.Show(1, title, text, nil, nil, nil, nil, extraData)
    end)
    backLogin()
  elseif msg == "delete_all_token" then
    login_module:addLogoutCallback(function()
      log(bWriteLog and "delete_all_token logout pop")
      if not hasLogoutMSDKLoginData then
        local SettingAccount = require("client.logic.setting.logic_setting_account")
        SettingAccount.ClientLogout()
      end
      title = LocUtil.GetLocalizeResStr(200000100)
      text = LocUtil.GetLocalizeResStr(200000476)
      extraData = {is5s = true, onTimerInvoke = kickoutCountdownTimerCallback}
      CommonMsgBoxMgr.Show(1, title, text, nil, nil, nil, nil, extraData)
    end)
    backLogin()
  else
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData)
  end
end
function ban_login_module:backLogin(reason)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:backLogin(reason)
end
function ban_login_module:sendLogout()
  log(bWriteLog and "login_module.sendLogout !!!!")
  self:HandleLogout()
  local PlayerStatusEnum = require("client.slua.logic.player_status.PlayerStatusEnum")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.teamState = PlayerStatusEnum.Enum_TeamState.Idle
  local logic_community = require("client.slua.logic.community.logic_community")
  logic_community.SendLogoutGame()
end
function ban_login_module:sendLogoutWithoutLogoutAccount()
  log(bWriteLog and "ban_login_module.sendLogoutWithoutLogoutAccount !!!!")
  self:HandleLogout()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local PlayerStatusEnum = require("client.slua.logic.player_status.PlayerStatusEnum")
  LogicFriend.teamState = PlayerStatusEnum.Enum_TeamState.Idle
  local logic_community = require("client.slua.logic.community.logic_community")
  logic_community.SendLogoutGame()
end
function ban_login_module:HandleLogout()
  log(bWriteLog and "ban_login_module:HandleLogout")
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  local bConnectDS = Lobby_Main_City_Enter.bConnectDS
  log(bWriteLog and "ban_login_module:HandleLogout bConnectDS = " .. tostring(bConnectDS))
  if bConnectDS then
    Lobby_Main_City_Enter.LeaveMainCity(true, false, false)
  end
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  local LoginHandler = require("client.network.Protocol.LoginHandler")
  LoginHandler.send_logout(DeviceOSInfo.InfoList)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Cban_login_module = class(CModuleBase, nil, ban_login_module)
return Cban_login_module