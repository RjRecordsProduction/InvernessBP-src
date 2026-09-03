local InformationSystem = {
  IsShowUI = false,
  NeedShow = false,
  MobileCode = "",
  EmailCode = ""
}
local SystemChildOpen = false
local NationCode = ""
local CanMobile = false
local CanEmail = false
local OpenUrl = ""
function InformationSystem.GetOpenUrl()
  return OpenUrl or ""
end
function InformationSystem.SetOpenUrl(url)
  OpenUrl = url or ""
end
function InformationSystem.SetCanEmail(is_can)
  CanEmail = is_can or ""
end
function InformationSystem.IsCanEmail()
  return CanEmail or false
end
function InformationSystem.SetCanMobile(is_can)
  CanMobile = is_can
end
function InformationSystem.IsCanMobile()
  return CanMobile or false
end
function InformationSystem.SetNationCode(code)
  NationCode = code or ""
end
function InformationSystem.GetNationCode()
  return NationCode or ""
end
function InformationSystem.GetEmailCode()
  return InformationSystem.EmailCode or ""
end
function InformationSystem.GetMobileCode()
  return InformationSystem.MobileCode or ""
end
function InformationSystem.IsNeedShow()
  return InformationSystem.NeedShow or false
end
function InformationSystem.SetSystemOpen(is_open)
  SystemChildOpen = is_open
end
function InformationSystem.IsChildSystemOpen()
  if SystemChildOpen then
    return true
  end
  return LobbySystem.CheckLobbyMenuOpen(BP_ENUM_NEW_SETTING_BIND_PANEL)
end
function InformationSystem.OpenInformationBindUI()
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  LobbyHandler.send_get_account_bind_req()
  InformationSystem.IsShowUI = true
  UIManager.ShowUI(UIManager.UI_Config.setting_information_bind)
end
function InformationSystem.HideInformationBindUI()
  InformationSystem.IsShowUI = false
  UIManager.CloseUI(UIManager.UI_Config.setting_information_bind)
end
function InformationSystem.get_account_bind_rsp(is_need_show, nation_code, mobile, email, noschat_id, facebook_id, is_need_show_parent, parent_nation_code, parent_mobile, button_type, change_parent_mobile_url, next_change_time)
  log(bWriteLog and "InformationSystem.get_account_bind_rsp " .. " is_need_show " .. tostring(is_need_show))
  log(bWriteLog and "is_need_show_parent " .. tostring(is_need_show_parent))
  log(bWriteLog and "parent_nation_code " .. tostring(parent_nation_code))
  log(bWriteLog and "button_type " .. tostring(button_type))
  log(bWriteLog and "parent_mobile " .. tostring(parent_mobile))
  log(bWriteLog and "next_change_time " .. tostring(next_change_time))
  InformationSystem.NeedShow = is_need_show
  local AntiaddctionSystem = require("client.logic.antiaddction.logic_antiaddction")
  AntiaddctionSystem.is_need_show_parent = is_need_show_parent or false
  AntiaddctionSystem.parent_nation_code = parent_nation_code or nil
  AntiaddctionSystem.parent_mobile = parent_mobile or nil
  AntiaddctionSystem.button_type = button_type or nil
  AntiaddctionSystem.change_parent_mobile_url = change_parent_mobile_url or nil
  AntiaddctionSystem.next_change_time = next_change_time or AntiaddctionSystem.next_change_time
  if parent_mobile then
    UIManager.CloseUI(UIManager.UI_Config.antiaddction_kick)
  end
  if mobile ~= nil then
    InformationSystem.MobileCode = mobile
    if nation_code ~= nil and nation_code ~= 0 then
      InformationSystem.MobileCode = "(+" .. tostring(nation_code) .. ")" .. mobile
    end
  else
    InformationSystem.MobileCode = ""
  end
  if email ~= nil then
    InformationSystem.EmailCode = email
  else
    InformationSystem.EmailCode = ""
  end
  if is_need_show == false and InformationSystem.IsShowUI == false and mobile == nil and email == nil then
    log(bWriteLog and "information_bind_ui\239\188\154not show")
    return
  end
  EventSystem:postEvent(EVENTTYPE_SETTING_INFORMATION_BIND, EVENTTYPE_SETTING_INFORMATION_BIND_RSP)
end
function InformationSystem.URLEncode(str)
  log(bWriteLog and "[bgp] InformationSystem.URLEncode, before str = " .. tostring(str))
  if str ~= nil then
    str = string.gsub(str, "([^%w%.%- ])", function(c)
      return string.format("%%%02x", string.byte(c))
    end)
    str = string.gsub(str, " ", "+")
  end
  log(bWriteLog and "[bgp] InformationSystem.URLEncode, after str = " .. tostring(str))
  return str
end
function InformationSystem.UpdateOpenUrl(binding_url)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local language = Client.GetCurrentLanguage()
  local nation = login_module.sIpRegion
  local nickName = DataMgr.roleData.nickName
  local newNickName = InformationSystem.URLEncode(InformationSystem.URLEncode(nickName))
  local openUrl = binding_url .. "?language=" .. language .. "&region=" .. nation .. "&nickname=" .. newNickName
  InformationSystem.SetOpenUrl(openUrl)
  log(bWriteLog and "[bgp] SetNewUrlByOnClick:openUrl" .. openUrl)
  local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
  WebviewSDK:OpenURL(openUrl, true)
end
function InformationSystem.BindInfoByOnClick()
  local bindingUrl = FuncUtil.GetDomainByID(3366036) .. "/act/a20181022h5bind/index.html"
  InformationSystem.UpdateOpenUrl(bindingUrl)
end
function InformationSystem.BindMobileCodeByOnClick()
  local bindingUrl = FuncUtil.GetDomainByID(3366036) .. "/act/a20181022h5bindsea/mobile.html"
  InformationSystem.UpdateOpenUrl(bindingUrl)
end
function InformationSystem.ChangeMobileCodeByOnClick()
  local bindingUrl = FuncUtil.GetDomainByID(3366036) .. "/act/a20181022h5bindsea/change_mobile.html"
  InformationSystem.UpdateOpenUrl(bindingUrl)
end
function InformationSystem.DeleteMobileCodeByOnClick()
  local title = LocUtil.GetLocalizeResStr(6354)
  local tip = LocUtil.GetLocalizeResStr(6355)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, tip, function()
    local MailHandler = require("client.network.Protocol.MailHandler")
    MailHandler.send_delete_account_bind_req(1)
    return true
  end)
end
function InformationSystem.BindEmailCodeByOnClick()
  local bindingUrl = FuncUtil.GetDomainByID(3366036) .. "/act/a20181022h5bindsea/mail.html"
  InformationSystem.UpdateOpenUrl(bindingUrl)
end
function InformationSystem.ChangeEmailCodeByOnClick()
  local bindingUrl = FuncUtil.GetDomainByID(3366036) .. "/act/a20181022h5bindsea/change_mai.html"
  InformationSystem.UpdateOpenUrl(bindingUrl)
end
function InformationSystem.DeleteEmailCodeByOnClick()
  local title = LocUtil.GetLocalizeResStr(6356)
  local tip = LocUtil.GetLocalizeResStr(6357)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, tip, function()
    local MailHandler = require("client.network.Protocol.MailHandler")
    MailHandler.send_delete_account_bind_req(2)
    return true
  end)
end
return InformationSystem