local whatsApp_subscription_config = require("client.logic.countryarea.whatsApp_subscription_config")
local EStatus = whatsApp_subscription_config.EStatus
local logic_whatsApp_subscription = {}
function logic_whatsApp_subscription:DefineAndResetData()
  self._status = EStatus.None
  self._localStatus = EStatus.None
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  self._isBlueHole = PublishRegionMacros.IsBLUEHOLE()
end
function logic_whatsApp_subscription:OnInitialize()
  self:LoadLocalStatus()
  self:send_query_marketing_agreement()
end
function logic_whatsApp_subscription:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_WHATSAPP_SUBSCRIPTION_SLAP, self.ShowSlap, self)
end
function logic_whatsApp_subscription:OnLogin(bReLogin)
end
function logic_whatsApp_subscription:OnLogOut()
end
function logic_whatsApp_subscription:GetStatus()
  return self._status
end
function logic_whatsApp_subscription:CheckCanShowSlap()
  local loginChannel = Client.GetLoginChannel(NetInterface)
  local isWhatsApp = loginChannel == BP_ENUM_PLAYFORM_WHATSAPP
  if not isWhatsApp then
    log_warning(bWriteLog and "logic_whatsApp_subscription:CheckCanShowSlap. not in whatsApp")
    return false
  end
  if not self._isBlueHole then
    log_warning(bWriteLog and "logic_whatsApp_subscription:CheckCanShowSlap. not in india")
    return false
  end
  if self._status ~= EStatus.None then
    log_warning(bWriteLog and "logic_whatsApp_subscription:ShowPopUpAfterLogin. status is not none")
    return false
  end
  return true
end
function logic_whatsApp_subscription:ShowSlap()
  log(bWriteLog and "logic_whatsApp_subscription:ShowSlap")
  self:ShowPopUp(self._status)
end
function logic_whatsApp_subscription:ShowSettingPopup()
  log(bWriteLog and "logic_whatsApp_subscription:ShowSettingPopup")
  self:ShowPopUp(self._status)
end
function logic_whatsApp_subscription:ShowPopUp(status)
  log(bWriteLog and "logic_whatsApp_subscription:ShowPopUp. status = " .. tostring(status))
  local content = whatsApp_subscription_config.PopupContent[status]
  if not content then
    log_warning(bWriteLog and "logic_whatsApp_subscription:ShowPopUp. content is nil.")
    return
  end
  local confirmCallback, cancelCallback
  if content.confirmStatus then
    function confirmCallback()
      self:SetStatus(content.confirmStatus)
      self:send_report_marketing_agreement()
    end
  end
  if content.cancelStatus then
    function cancelCallback()
      self:SetStatus(content.cancelStatus)
      self:send_report_marketing_agreement()
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 2, content.title, content.desc, nil, content.confirmText, content.cancelText, confirmCallback, cancelCallback, {showCloseBtn = false})
end
function logic_whatsApp_subscription:SetStatus(status)
  log(bWriteLog and "logic_whatsApp_subscription:SetStatus. status = " .. tostring(status))
  self._status = status or EStatus.None
end
function logic_whatsApp_subscription:GetSettingButtonName()
  local name = LocUtil.GetLocalizeResStr(817285)
  if self._status == EStatus.Subscribe then
    name = LocUtil.GetLocalizeResStr(817286)
  end
  return name
end
function logic_whatsApp_subscription:OnHyperLinkClicked()
  local url
  if self._isBlueHole or IsEditor then
    url = "www.battlegroundsmobileindia.com/privacy"
  end
  if not url then
    return
  end
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  local h5Url = webModule:AddParameterByPersonalInfo(url, true, true)
  GlobalData.JumpUrl(h5Url)
end
function logic_whatsApp_subscription:send_query_marketing_agreement()
  if self._localStatus > 0 then
    log_warning(bWriteLog and "logic_whatsApp_subscription:send_query_marketing_agreement. has local status")
    return
  end
  if not self._isBlueHole then
    log_warning(bWriteLog and "logic_whatsApp_subscription:send_query_marketing_agreement. not in india")
    return
  end
  log(bWriteLog and "logic_whatsApp_subscription:send_query_marketing_agreement. send query")
  local MarketingAgreementHandler = require("client.network.Protocol.MarketingAgreementHandler")
  MarketingAgreementHandler.send_query_marketing_agreement()
end
function logic_whatsApp_subscription:on_query_marketing_agreement_rsp(data)
  log_tree("logic_whatsApp_subscription:on_query_marketing_agreement_rsp. data = ", data)
  if not data then
    return
  end
  if not self._isBlueHole then
    log_warning(bWriteLog and "logic_whatsApp_subscription:on_query_marketing_agreement_rsp. not in india")
    return
  end
  local isAgree = data.is_agree
  local status = EStatus.None
  if isAgree == true then
    status = EStatus.Subscribe
  elseif isAgree == false then
    status = EStatus.Refuse
  end
  self:SetStatus(status)
  self:SaveLocalStatus()
end
function logic_whatsApp_subscription:send_report_marketing_agreement()
  local isAgree
  if self._status == EStatus.Subscribe then
    isAgree = true
  elseif self._status == EStatus.Refuse then
    isAgree = false
  end
  log(bWriteLog and "logic_whatsApp_subscription:send_report_marketing_agreement. isAgree = " .. tostring(isAgree))
  if isAgree ~= nil then
    local MarketingAgreementHandler = require("client.network.Protocol.MarketingAgreementHandler")
    MarketingAgreementHandler.send_report_marketing_agreement(isAgree)
  end
end
function logic_whatsApp_subscription:on_report_marketing_agreement_rsp(errcode)
  log(bWriteLog and "logic_whatsApp_subscription:on_report_marketing_agreement_rsp. errcode = " .. tostring(errcode))
  if errcode and errcode ~= 0 then
    return
  end
  if not self._isBlueHole then
    log_warning(bWriteLog and "logic_whatsApp_subscription:on_report_marketing_agreement_rsp. not in india")
    return
  end
  local notice
  if self._localStatus == EStatus.Subscribe and self._status == EStatus.Refuse then
    notice = 817293
  elseif self._status == EStatus.Subscribe then
    notice = 817292
  end
  if notice then
    ShowNotice(LocUtil.GetLocalizeResStr(notice))
  end
  self:SaveLocalStatus()
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_UPDATE_BOTTOM, "WhatsAppSubscription")
end
function logic_whatsApp_subscription:SaveLocalStatus()
  log(bWriteLog and "logic_whatsApp_subscription:SaveLocalStatus")
  self._localStatus = self._status
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self._localStatus, PlayerPrefsSystem.ePlayerPrefsType.eWhatAppSubscription)
end
function logic_whatsApp_subscription:LoadLocalStatus()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self._localStatus = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWhatAppSubscription) or EStatus.None
  log(bWriteLog and "logic_whatsApp_subscription:LoadLocalStatus, localStatus:" .. tostring(self._localStatus))
  if self._localStatus > 0 then
    self:SetStatus(self._localStatus)
  end
end
function logic_whatsApp_subscription:ClearLocalStatus()
  log(bWriteLog and "logic_whatsApp_subscription:ClearLocalStatus")
  self._localStatus = EStatus.None
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self._localStatus, PlayerPrefsSystem.ePlayerPrefsType.eWhatAppSubscription)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_whatsApp_subscription = class(CModuleBase, nil, logic_whatsApp_subscription)
return Clogic_whatsApp_subscription