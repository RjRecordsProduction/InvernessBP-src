local version1800 = true
local logic_guest_bind_1700 = {
  currentStage = 0,
  tryingToBindChanelID = nil,
  tryingToBindChanelName = nil,
  needShowPanel = false,
  needShowPanelForce = false,
  setPasswordBefore = false,
  loginCounter = 0,
  CONST = {
    PasswordLen = 8,
    UI_Config = {
      [1] = UIManager.UI_Config.guest_bind_main,
      [2] = UIManager.UI_Config.guest_bind_main,
      [3] = UIManager.UI_Config.guest_bind_main,
      [8] = UIManager.UI_Config.guest_bind_main,
      [9] = UIManager.UI_Config.guest_bind_main,
      [10] = UIManager.UI_Config.guest_bind_main,
      [4] = UIManager.UI_Config.guest_bind_password_set,
      [5] = UIManager.UI_Config.guest_bind_password_set,
      [6] = UIManager.UI_Config.guest_bind_password_set,
      [7] = UIManager.UI_Config.guest_bind_password_set_success
    }
  },
  Enum_Stage = {
    WeekBindMain = 1,
    WeekBindMainSecond = 2,
    StrongBindMain = 3,
    StrongBindMainSecond = 8,
    WeekBindMain1800 = 9,
    StrongBindMain1800 = 10,
    WeekGuestPasswordSet = 4,
    StrongGuestPasswordSet = 5,
    GuestPasswordChange = 6,
    GuestPasswordSetSuccess = 7
  },
  Enum_Error = {
    SetPasswordCancel = 1,
    BindFail = 2,
    HideBottomBtn = 4
  }
}
local _closePage = function()
  log(bWriteLog and "[cw] [cw][guestBind] _closePage() ")
  UIManager.CloseUI(UIManager.UI_Config.LobbyAndroidGuestBind)
end
local _GoToStage = function(nextStage, errorCode, extraInfo)
  logic_guest_bind_1700.currentStage = tonumber(nextStage)
  EventSystem:postEvent(EVENTTYPE_LOGIN_ROLEDATA, EVENTID_GUEST_GUIDE_SETTING_REFRESH, nextStage, errorCode, extraInfo)
end
local _ShowGoBackToLoginInMsgBox = function()
  log(bWriteLog and "_ShowGoBackToLoginInMsgBox")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(5077), LocUtil.GetLocalizeResStr(301168), function()
    local ban_login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
    ban_login_module:sendLogoutWithoutLogoutAccount()
  end)
end
function logic_guest_bind_1700.TryToShowMainPage()
  log(bWriteLog and "[cw][guestBind] TryToShowMainPage() ")
  local common_config = require("client.slua.common.common_config")
  if common_config:IsBlockingPopupTip() then
    log(bWriteLog and "[cw][guestBind] TryToShowMainPage() return IsBlockingPopupTip ")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local activeInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGuestBindActive) or {}
  if activeInfo.BlockProcess then
    log(bWriteLog and "[cw][guestBind] GM blocked")
    return
  end
  log(bWriteLog and "[cw][guestBind] GameStatus.IsInLobbyOrMainCity():" .. tostring(GameStatus.IsInLobbyOrMainCity()))
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "[cw][guestBind] not in lobby")
    return
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.Android then
    log(bWriteLog and "[cw][guestBind] DevicePlatform is Android")
    return
  end
  if logic_guest_bind_1700.needShowPanel and logic_guest_bind_1700.loginCounter > 0 then
    local es = logic_guest_bind_1700.Enum_Stage
    if logic_guest_bind_1700.needShowPanelForce then
      logic_guest_bind_1700.currentStage = version1800 and es.StrongBindMain1800 or es.StrongBindMain
    else
      logic_guest_bind_1700.currentStage = version1800 and es.WeekBindMain1800 or es.WeekBindMain
    end
    local errorCode = logic_guest_bind_1700.Enum_Error.HideBottomBtn
    local logic_account_sensitive_aciton = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_sensitive_aciton)
    if not logic_account_sensitive_aciton:IsGrayNew() then
      UIManager.ShowUI(UIManager.UI_Config.LobbyAndroidGuestBind, logic_guest_bind_1700.currentStage, errorCode)
      log(bWriteLog and "[cw][guestBind] UIManager.ShowUI(UIManager.UI_Config.LobbyAndroidGuestBind, logic_guest_bind_1700.currentStage, errorCode) ")
    else
      local setting_macro = require("client.slua.logic.setting.setting_macro")
      logic_account_sensitive_aciton:ShowCommonPopupUI(setting_macro.AccountNewOperationType.GuestGuide)
    end
    logic_guest_bind_1700.needShowPanel = false
    log(bWriteLog and "[cw][guestBind] logic_guest_bind_1700.loginCounter = 0 , 153")
    logic_guest_bind_1700.loginCounter = 0
  else
    log(bWriteLog and "[cw][guestBind] logic_guest_bind_1700.needShowPanel: " .. tostring(logic_guest_bind_1700.needShowPanel))
    log(bWriteLog and "[cw][guestBind] logic_guest_bind_1700.loginCounter: " .. tostring(logic_guest_bind_1700.loginCounter))
  end
end
function logic_guest_bind_1700.OnModePostSwitch(_, __, status)
  log_tree(bWriteLog and "logic_guest_bind_1700.OnModePostSwitch status", status)
  if status.pre == GameStatus.Login and status.current == GameStatus.Lobby then
    local bSwitch = LobbySystem.CheckOpen(BP_ENUM_ACCOUNT_BIND_BY_SERVER_SWITCH_ID)
    local logic_ce = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ce)
    if logic_ce:IsCEBindGlobalOpen() then
      bSwitch = true
    end
    local IMSDKSystem = require("client.logic.login.logic_imsdk")
    IMSDKSystem.SetBindBySDK(not bSwitch)
  end
  EventSystem:registEvent(EVENTTYPE_BIND_INTL, EVENTID_INTL_BIND_NEED_SVR_PROCESSS, logic_guest_bind_1700.OnBindSvrProcesss)
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.Android then
    return
  end
  log(bWriteLog and "[cw][guestBind] status.current:" .. tostring(status.current))
  if status.current ~= GameStatus.Login then
    log(bWriteLog and "[cw][guestBind] CleanCache not in Login ")
    return
  end
  logic_guest_bind_1700.currentStage = 0
  logic_guest_bind_1700.tryingToBindChanelID = nil
  logic_guest_bind_1700.tryingToBindChanelName = nil
  logic_guest_bind_1700.needShowPanel = false
  logic_guest_bind_1700.needShowPanelForce = false
  logic_guest_bind_1700.setPasswordBefore = false
  logic_guest_bind_1700.loginCounter = 1
  log(bWriteLog and "[cw][guestBind] logic_guest_bind_1700.loginCounter = 1 , 176")
end
function logic_guest_bind_1700.OnBindSvrProcesss(_, _, loginRet)
  log_tree(bWriteLog and "logic_guest_bind_1700.OnBindSvrProcesss loginRet", loginRet)
  local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
  if loginRet.imsdkRetCode == SDKMacros.IMSDKErrorCode.BIND_CMD_NEED_PROCESS_BY_SVR then
    local ret = loginRet.imsdkRetMsg
    local base64 = require("client.slua.logic.lobby_watermark.base64")
    local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
    local clientBase64Str = string.gsub(ret, "-", "+")
    clientBase64Str = string.gsub(clientBase64Str, "_", "/")
    local afterDecode = base64.DecodeBase64(clientBase64Str)
    log_tree(bWriteLog and "logic_guest_bind_1700.OnBindSvrProcesss afterDecode", afterDecode)
    local imsdkRetMsgTable = json.decode(afterDecode)
    if imsdkRetMsgTable.bind_params ~= nil then
      local bind_channel = imsdkRetMsgTable.bind_params.iBindChannel
      log(bWriteLog and string.format("logic_guest_bind_1700.OnBindSvrProcesss, bind_channel:%s", bind_channel))
      if bind_channel then
        do
          local logic_ce = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ce)
          if logic_ce:IsCEBindGlobalOpen() then
            local CEHandler = require("client.network.Protocol.CEHandler")
            CEHandler.send_ce_new_channel_bind_req(ret):Then(function(ret, dst_openid)
              if ret ~= 0 then
                ShowNotice(ret)
                return
              end
              logic_ce:OnBindSuccess(bind_channel)
            end)
            return
          end
          local logic_account_sensitive_aciton = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_sensitive_aciton)
          if logic_account_sensitive_aciton:IsGrayNew() then
            logic_account_sensitive_aciton:BindSocialReq(tonumber(bind_channel), ret, imsdkRetMsgTable.bind_params)
          else
            LoginVerifyHandler.send_account_social_bind_req(tonumber(bind_channel), ret)
          end
        end
      end
    elseif imsdkRetMsgTable.sacc_params ~= nil then
      local logic_account_sensitive_aciton = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_sensitive_aciton)
      if logic_account_sensitive_aciton:IsGrayNew() then
        logic_account_sensitive_aciton:BindSelfBuildReq(ret, imsdkRetMsgTable.sacc_params)
      else
        LoginVerifyHandler.send_account_bind_sacc_req(ret, imsdkRetMsgTable.sacc_params.account, imsdkRetMsgTable.sacc_params.account_type, imsdkRetMsgTable.sacc_params.verify_code, imsdkRetMsgTable.sacc_params.area_code)
      end
    else
      log_tree(bWriteLog and "logic_guest_bind_1700.OnBindSvrProcesss Donothing with bind result json:%s", imsdkRetMsgTable)
    end
  end
end
function logic_guest_bind_1700.GoToGuestPasswordSetPage()
  local currentStage = logic_guest_bind_1700.currentStage
  local stage = logic_guest_bind_1700.Enum_Stage
  if currentStage == stage.WeekBindMain or currentStage == stage.WeekBindMainSecond then
    _GoToStage(stage.WeekGuestPasswordSet)
  elseif currentStage == stage.StrongBindMain or currentStage == stage.StrongBindMainSecond then
    _GoToStage(stage.StrongGuestPasswordSet)
  end
end
function logic_guest_bind_1700.CloseCurrentPage()
  log(bWriteLog and "[cw][guestBind] logic_guest_bind_1700.CloseCurrentPage()")
  local currentStage = logic_guest_bind_1700.currentStage
  log(bWriteLog and "[cw][guestBind] currentStage:" .. tostring(currentStage))
  local stage = logic_guest_bind_1700.Enum_Stage
  local error = logic_guest_bind_1700.Enum_Error
  if currentStage == stage.WeekBindMain then
    if logic_guest_bind_1700.setPasswordBefore then
      _closePage()
    else
      _GoToStage(stage.WeekGuestPasswordSet)
    end
  elseif currentStage == stage.WeekGuestPasswordSet then
    _GoToStage(stage.WeekBindMainSecond, error.SetPasswordCancel)
  elseif currentStage == stage.WeekBindMainSecond then
    _closePage()
  elseif currentStage == stage.StrongBindMain then
    if logic_guest_bind_1700.setPasswordBefore then
      _closePage()
    else
      _GoToStage(stage.StrongGuestPasswordSet)
    end
  elseif currentStage == stage.StrongBindMainSecond then
    _ShowGoBackToLoginInMsgBox()
  elseif currentStage == stage.StrongGuestPasswordSet then
    _GoToStage(stage.StrongBindMainSecond, error.SetPasswordCancel)
  elseif currentStage == stage.GuestPasswordChange then
    _closePage()
  elseif currentStage == stage.GuestPasswordSetSuccess then
    _closePage()
  elseif currentStage == stage.SocialAccountBindSuccess then
  elseif currentStage == stage.WeekBindMain1800 then
    _closePage()
  elseif currentStage == stage.StrongBindMain1800 then
    local bIsDev = Client.IsDevelopment()
    if bIsDev then
      _closePage()
    else
      _ShowGoBackToLoginInMsgBox()
    end
  else
    _closePage()
  end
end
function logic_guest_bind_1700.ChangeGuestAccountPassword()
  logic_guest_bind_1700.currentStage = logic_guest_bind_1700.Enum_Stage.GuestPasswordChange
  UIManager.ShowUI(UIManager.UI_Config.LobbyAndroidGuestBind, logic_guest_bind_1700.currentStage)
end
function logic_guest_bind_1700.HandlerResponseFromIMSDK()
  log(bWriteLog and "[cw][guestBind] logic_guest_bind_1700.HandlerResponseFromIMSDK()")
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local bindRetJson = IMSDKHelperInstance:GetBindRet()
  local bindRet = json.decode(bindRetJson)
  local imsdkRetCode = bindRet.imsdkRetCode
  local imsdkThirdRetCode = bindRet.thirdRetCode
  local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
  local msgContent
  if imsdkRetCode == SDKMacros.IMSDKErrorCode.SUCCESS then
    local msgTitle = LocUtil.GetLocalizeResStr(4045)
    local SettingSystem = require("client.logic.setting.logic_setting")
    local strBindName = SettingSystem.GetNameByImsdkChannel(SettingSystem.NBindChannel, SettingSystem.NBindExtType)
    msgContent = string.format(DataMgr.GetMultiLineMsgByID(4455), strBindName)
    log(bWriteLog and "[mxiliu]HandlerResponseFromIMSDK strBindName:" .. tostring(strBindName))
    IMSDKHelperInstance:SaveLastIMSDKChannelID(SettingSystem.NBindChannel)
    local clickOKCallback = function()
      local LogicLoginVerify = require("client.slua.logic.login.logic_login_verify")
      LogicLoginVerify.PostTLog(strBindName)
      EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_ACCOUNT_BINDSUCC)
      Client.LogoutAllDevices(NetInterface)
      local ban_login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
      ban_login_module:sendLogoutWithoutLogoutAccount()
      local SettingAccount = require("client.logic.setting.logic_setting_account")
      SettingAccount.ClientLogout()
      if SettingSystem.NBindChannel ~= nil and SettingSystem.NBindChannel ~= 0 then
        IMSDKHelperInstance:LogoutWith(SettingSystem.NBindChannel)
      end
    end
    local logic_account_sensitive_aciton = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_sensitive_aciton)
    if logic_account_sensitive_aciton:IsGrayNew() then
      function clickOKCallback()
        logic_account_sensitive_aciton:OnBindSuccess()
      end
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, msgTitle, msgContent, clickOKCallback)
    return
  elseif imsdkRetCode == SDKMacros.IMSDKErrorCode.BIND_CMD_NEED_PROCESS_BY_SVR then
    return
  end
  if imsdkRetCode == SDKMacros.IMSDKErrorCode.SERVER_ERROR and imsdkThirdRetCode == SDKMacros.IMSDKServerErrorCode.BIND_OPENID_ALREADY_EXIST then
    local SettingSystem = require("client.logic.setting.logic_setting")
    local strBindName = SettingSystem.GetNameByImsdkChannel(logic_guest_bind_1700.tryingToBindChanelID)
    msgContent = string.format(DataMgr.GetMultiLineMsgByID(4453), strBindName)
  else
    msgContent = LocUtil.GetLocalizeResStr(4048)
  end
  local cs = logic_guest_bind_1700.currentStage
  local s = logic_guest_bind_1700.Enum_Stage
  local error = logic_guest_bind_1700.Enum_Error
  log(bWriteLog and "[cw][guestBind] currentStage & msgContent: " .. tostring(cs) .. " & " .. tostring(msgContent))
  if cs == s.StrongBindMain1800 or cs == s.WeekBindMain1800 then
    log(bWriteLog and "[cw][guestBind] cs == s.StrongBindMain1800 or cs == s.WeekBindMain1800")
    _GoToStage(cs, error.BindFail + error.HideBottomBtn, msgContent)
  elseif cs == s.StrongBindMain then
    log(bWriteLog and "[cw][guestBind] cs == s.StrongBindMain")
    _GoToStage(s.StrongBindMain, error.SetPasswordCancel + error.BindFail + error.HideBottomBtn, msgContent)
  elseif cs == s.StrongBindMainSecond then
    log(bWriteLog and "[cw][guestBind] cs == s.StrongBindMainSecond")
    _GoToStage(s.StrongBindMainSecond, error.SetPasswordCancel + error.BindFail, msgContent)
  elseif cs == s.WeekBindMain or cs == s.WeekBindMainSecond then
    log(bWriteLog and "[cw][guestBind] cs == s.WeekBindMain or cs == s.WeekBindMainSecond")
    _GoToStage(s.WeekBindMainSecond, error.SetPasswordCancel + error.BindFail, msgContent)
  else
    log(bWriteLog and "[cw][guestBind] cs == otherSituation")
    _GoToStage(s.WeekBindMainSecond, error.SetPasswordCancel + error.BindFail, msgContent)
  end
end
function logic_guest_bind_1700.on_guest_account_bind_ntfy(bClash, bSetPasswordBefore)
  log(bWriteLog and "[cw][guestBind] logic_guest_bind_1700.on_guest_account_bind_ntfy(" .. tostring(bClash) .. ", " .. tostring(bSetPasswordBefore) .. ")")
  if not Client.IsCloudVersion or not Client.IsCloudVersion() then
    logic_guest_bind_1700.needShowPanel = true
    logic_guest_bind_1700.needShowPanelForce = bClash or false
    logic_guest_bind_1700.setPasswordBefore = bSetPasswordBefore or false
    logic_guest_bind_1700.TryToShowMainPage()
  end
end
function logic_guest_bind_1700.send_guest_account_pwd_set_req(password)
  log(bWriteLog and "[cw][guestBind] logic_guest_bind_1700.send_guest_account_pwd_set_req(" .. tostring(password) .. ")")
  local GuestBindHandler = require("client.network.Protocol.GuestBindHandler")
  local StringUtil = require("common.string_util")
  local encodedPassword = StringUtil.EncodeXOR(tostring(password), true)
  log(bWriteLog and "[cw] encodedPassword:" .. tostring(encodedPassword))
  GuestBindHandler.send_guest_account_pwd_set_req(encodedPassword)
end
function logic_guest_bind_1700.on_guest_account_pwd_set_rsp(errorCode, password)
  log(bWriteLog and "[cw][guestBind] logic_guest_bind_1700.on_guest_account_pwd_set_rsp(" .. tostring(errorCode) .. ", " .. tostring(password) .. ")")
  if errorCode == 0 then
    logic_guest_bind_1700.currentStage = logic_guest_bind_1700.Enum_Stage.GuestPasswordSetSuccess
    ShowNotice(29970)
    EventSystem:postEvent(EVENTTYPE_LOGIN_ROLEDATA, EVENTID_GUEST_GUIDE_SETTING_REFRESH, logic_guest_bind_1700.currentStage)
  else
    ShowNotice(errorCode)
  end
end
return logic_guest_bind_1700