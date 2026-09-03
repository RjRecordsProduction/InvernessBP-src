local logic_ce = {}
function logic_ce:DefineAndResetData()
  self.getCDKeyInfo = nil
  self.nBan_code_lock_end_time = 0
  self.bindErrorCode = 0
  self.code = nil
end
function logic_ce:OnInitialize()
end
function logic_ce:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_WEBVIEWACTION, EVENTID_WEBVIEWACTION, self.OnHandleWebviewAction, self)
end
function logic_ce:OnLogin(bReLogin)
end
function logic_ce:OnLogOut()
end
function logic_ce:OnPreSwitchGameStatus(preState, nextState)
end
function logic_ce:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and string.format("logic_ce:OnPostSwitchGameStatus, preState:%s nextState:%s", preState, nextState))
  if preState == GameStatus.Login and nextState == GameStatus.Lobby then
    self:SetBindFlag()
    self:OpenVerifyCodeWindow(self.code)
    if self.bIsBindingCE and not UIManager.IsUIShow(UIManager.UI_Config.Setting_Common_Popup_Large_UIBP) then
      local logic_account_sensitive_aciton = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_sensitive_aciton)
      local setting_macro = require("client.slua.logic.setting.setting_macro")
      logic_account_sensitive_aciton:ShowCommonPopupUI(setting_macro.AccountNewOperationType.CEBindSocial)
    end
  end
end
function logic_ce:IsCEBindGlobalOpen()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsCEVersion() then
    return false
  end
  local bSwitch = LobbySystem.CheckOpen(BP_ENUM_CE_ACCOUNT_BIND_GLOBAL_SWITCH_ID)
  if not bSwitch then
    return false
  end
  return true
end
function logic_ce:GetLastBindTime()
  return self.nBan_code_lock_end_time
end
function logic_ce:GetLastGetCDKeyTime()
  if not self.getCDKeyInfo then
    return nil
  end
  return self.getCDKeyInfo.last_update_time
end
function logic_ce:GetSendCDKeyCount()
  if not self.getCDKeyInfo then
    return 0
  end
  return self.getCDKeyInfo.daily_cnt
end
function logic_ce:OpenVerifyCodeWindow(code)
  if not code then
    return
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.bIsRelogin == false then
    UIManager.ShowUI(UIManager.UI_Config.Setting_Bind_CE_UIBP, code)
    self.code = nil
  end
end
function logic_ce:SetBindErrorCode(err)
  self.bindErrorCode = err
end
function logic_ce:SetBindFlag()
  if LobbySystem.roleData.ce_need_bind_open_id then
    local logic_ce = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ce)
    logic_ce:SetBindErrorCode(-1)
  end
end
function logic_ce:OpenH5CEBind()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsCEVersion() then
    return
  end
  log_shipping_client("logic_ce:OpenH5CEBind ce_need_bind_open_id = " .. tostring(LobbySystem.roleData.ce_need_bind_open_id))
  if not LobbySystem.roleData.ce_need_bind_open_id then
    return
  end
  local url = ""
  local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
  local tssVersion = version_up_module:GetTssVersion()
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  if Client.IsReleaseVersion(NetInterface) then
    url = webModule:AddParameterByPersonalInfo(FuncUtil.GetDomainByID(3366036) .. "/act/cebindlogin/index.html?sTicket={itop_ticket}&version=" .. tssVersion)
  else
    url = webModule:AddParameterByPersonalInfo(FuncUtil.GetDomainByID(3366036) .. "/act/cebindlogin/index_test.html?sTicket={itop_ticket}&version=" .. tssVersion)
  end
  log_shipping_client("logic_ce:OpenH5CEBind url = " .. url)
  local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
  WebviewSDK:OpenURL(url)
end
function logic_ce:OnHandleWebviewAction(_, _, str)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsCEVersion() then
    return
  end
  log_shipping_client("logic_ce:OnHandleWebviewAction str = " .. str)
  log_shipping_client("logic_ce:OnHandleWebviewAction ce_need_bind_open_id = " .. tostring(LobbySystem.roleData.ce_need_bind_open_id))
  if str == "2" and LobbySystem.roleData.ce_need_bind_open_id and self.bindErrorCode ~= 0 then
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:backLogin()
  end
end
function logic_ce:OnBindSuccess(bindChannel)
  local clickOKCallback = function()
    Client.LogoutAllDevices(NetInterface)
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:sendLogout()
  end
  local msgTitle = LocUtil.GetLocalizeResStr(101001)
  local SettingSystem = require("client.logic.setting.logic_setting")
  local strBindName = SettingSystem.GetNameByImsdkChannel(tonumber(bindChannel))
  local msgContent = LocUtil.LocalizeResFormat(75474, strBindName)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, msgTitle, msgContent, clickOKCallback, nil, nil, nil, {clickCloseCallback = clickOKCallback})
end
function logic_ce:SetIsBinding(bFlag)
  log(bWriteLog and string.format("logic_ce:SetIsBinding, bFlag:%s", bFlag))
  self.bIsBindingCE = bFlag
end
function logic_ce:GetIsBinding()
  log(bWriteLog and string.format("logic_ce:GetIsBinding, bIsBindingCE:%s", self.bIsBindingCE))
  return self.bIsBindingCE
end
function logic_ce:send_gen_cdkey_req(global_uid, callback)
  local CEHandler = require("client.network.Protocol.CEHandler")
  CEHandler.send_gen_cdkey_req(global_uid):Then(callback)
end
function logic_ce:on_gen_cdkey_rsp(global_uid, gen_cdkey_info)
  self.getCDKeyInfo = gen_cdkey_info
end
function logic_ce:on_cdkey_verify(code, lock_end_time)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsCEVersion() then
    return
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local bGuest = IMSDKHelperInstance:IsEqualCurLoginPlatform(ShareSource.Guest)
  if bGuest then
    return
  end
  log(bWriteLog and "[v_wllwu]  OnGetSecurityVerify code = " .. tostring(code))
  if code and code == 1 or code == 2 or code == 5 or code == 6 then
    self.nBan_code_    self.  end
end
function logic_ce:send_active_by_cdkey_req(invite_code, callback)
  local CEHandler = require("client.network.Protocol.CEHandler")
  CEHandler.send_active_by_cdkey_req(invite_code):Then(callback)
end
function logic_ce:on_active_by_cdkey_rsp(result_str, lock_end_time)
  if lock_end_time then
    self.nBan_code_  end
end
function logic_ce:on_ce_bind_required_notify()
  self:SetIsBinding(true)
  if GameStatus.IsInLobbyOrMainCity() then
    local logic_account_sensitive_aciton = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_sensitive_aciton)
    local setting_macro = require("client.slua.logic.setting.setting_macro")
    logic_account_sensitive_aciton:ShowCommonPopupUI(setting_macro.AccountNewOperationType.CEBindSocial)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ce = class(CModuleBase, nil, logic_ce)
return Clogic_ce