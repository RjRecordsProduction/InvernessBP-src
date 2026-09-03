local EUGDPRSystem = {}
function EUGDPRSystem.OnLogin()
  local roleData = LobbySystem.roleData
  if roleData.eugdpr then
    Client.SetGDPRUserType(GameFrontendHUD, roleData.eugdpr.user_type)
    if roleData.eugdpr.user_type ~= 2 and roleData.eugdpr.user_type ~= 4 or roleData.eugdpr.policy_state ~= 1 then
      NeedCheckDeviceLimit = false
    end
  end
end
function EUGDPRSystem.GetIsGDPRUser()
  local gdpr_config = require("client.slua.logic.gdpr.gdpr_config")
  if LobbySystem.roleData.eugdpr then
    local userType = LobbySystem.roleData.eugdpr.user_type
    if userType == gdpr_config.GDPRState.EUGDPR_DefaultState or userType == gdpr_config.GDPRState.EUGDPR_NotEUState then
      return false
    else
      return true
    end
  end
  return false
end
function EUGDPRSystem.ReportBtnClick(isNew, btnID)
  log(bWriteLog and "EUGDPRSystem.ReportBtnClick, isnew = " .. tostring(isNew) .. ", btnID = " .. btnID)
  local param = {}
  param.is_new_user = isNew
  param.tlog_reason = btnID
  param.tlog_sub_reason = 0
  local EUGDPRHandler = require("client.network.Protocol.EUGDPRHandler")
  EUGDPRHandler.send_eugdpr_report_tlog_req(param)
end
local bDeleteAsync = false
local bShouldLogoutAfterDelete = false
function EUGDPRSystem.DeleteAccountReq(async, shouldLogout)
  log(bWriteLog and "EUGDPRSystem.DeleteAccountReq " .. tostring(async) .. "  " .. tostring(shouldLogout))
  bShouldLogoutAfterDelete = shouldLogout
  if DataMgr.roleData.eugdpr == nil then
    log(bWriteLog and "EUGDPRSystem.DeleteAccountReq, gdpr is nil")
    return
  end
  if DataMgr.roleData.eugdpr.is_deleting then
    local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
    GdprSystem.CloseAllGDPRUI()
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:sendLogout()
    return
  end
  local EUGDPRHandler = require("client.network.Protocol.EUGDPRHandler")
  EUGDPRHandler.send_eugdpr_del_account_req()
  if async then
    logic_connection_waiting:Show(1)
    bDeleteAsync = true
  end
end
function EUGDPRSystem.DeleteKoreaAccountReq(async, shouldLogout)
  log(bWriteLog and "EUGDPRSystem.DeleteKoreaAccountReq " .. tostring(async) .. "  " .. tostring(shouldLogout))
  bShouldLogoutAfterDelete = shouldLogout
  if DataMgr.krjp_del_account_left_time > 0 then
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:sendLogout()
    return
  end
  local EUGDPRHandler = require("client.network.Protocol.EUGDPRHandler")
  EUGDPRHandler.send_krjp_del_account_req()
  if async then
    logic_connection_waiting:Show(1)
    bDeleteAsync = true
  end
end
function EUGDPRSystem.DeleteAccountImmediatelyReq()
  log(bWriteLog and "EUGDPRSystem.DeleteAccountImmediatelyReq")
  local EUGDPRHandler = require("client.network.Protocol.EUGDPRHandler")
  EUGDPRHandler.send_eugdpr_direct_del_account_req()
end
function EUGDPRSystem.CancelDeleteAccountReq()
  log(bWriteLog and "EUGDPRSystem.CancelDeleteAccountReq")
  local EUGDPRHandler = require("client.network.Protocol.EUGDPRHandler")
  EUGDPRHandler.send_eugdpr_cancel_del_account_req()
end
function EUGDPRSystem.SendStateToServer(state)
  log(bWriteLog and "EUGDPRSystem.SendStateToServer, state = " .. state)
  local EUGDPRHandler = require("client.network.Protocol.EUGDPRHandler")
  EUGDPRHandler.send_eugdpr_update_type_req(state)
  if DataMgr.roleData.eugdpr ~= nil then
    DataMgr.roleData.eugdpr.user_type = state
    Client.SetGDPRUserType(GameFrontendHUD, DataMgr.roleData.eugdpr.user_type)
  end
end
function EUGDPRSystem.SendPrivacyToServer(state)
  log(bWriteLog and "EUGDPRSystem.SendPrivacyToServer, state = " .. state)
  local EUGDPRHandler = require("client.network.Protocol.EUGDPRHandler")
  EUGDPRHandler.send_eugdpr_update_policy_req(state)
  if DataMgr.roleData.eugdpr ~= nil then
    DataMgr.roleData.eugdpr.policy_  end
end
function EUGDPRSystem.SendKoreaCancelDeleteAccount()
  log(bWriteLog and "EUGDPRSystem.SendKoreaCancelDeleteAccount")
  local EUGDPRHandler = require("client.network.Protocol.EUGDPRHandler")
  EUGDPRHandler.send_krjp_cancel_del_account_req()
  if DataMgr.roleData.eugdpr ~= nil then
    DataMgr.roleData.eugdpr.policy_state = nil
  end
end
function EUGDPRSystem.eugdpr_update_type_rsp(res, left_change_age_time)
  log(bWriteLog and "EUGDPRSystem.eugdpr_update_type_rsp, res = " .. res)
  if res == NetErrorCode_NONE or res == "not open" then
  elseif res == "bad param" then
  elseif res == "not need to update" then
  end
  if left_change_age_time and 0 < left_change_age_time and DataMgr.roleData.eugdpr and DataMgr.roleData.eugdpr.left_change_age_time then
    log(bWriteLog and "EUGDPRSystem.eugdpr_update_type_rsp update left_change_age_time")
    DataMgr.roleData.eugdpr.  end
end
function EUGDPRSystem.eugdpr_update_policy_rsp(res)
  log(bWriteLog and "EUGDPRSystem.eugdpr_update_policy_rsp, res = " .. res)
  if res == NetErrorCode_NONE or res == "not open" then
  elseif res == "bad param" then
  elseif res == "not need to update" then
  end
end
function EUGDPRSystem.eugdpr_del_account_rsp(res)
  log(bWriteLog and "EUGDPRSystem.eugdpr_del_account_rsp, res = " .. res)
  log(bWriteLog and "  : bDeleteAsync" .. tostring(bDeleteAsync))
  log(bWriteLog and "  : bShouldLogoutAfterDelete" .. tostring(bShouldLogoutAfterDelete))
  if bDeleteAsync then
    if res == "fail" then
      ShowNotice(4372)
    else
      local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
      GdprSystem.CloseAllGDPRUI()
      if bShouldLogoutAfterDelete == true then
        local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
        login_module:backLogin()
      end
    end
    logic_connection_waiting:Hide(1)
    bDeleteAsync = false
  end
end
function EUGDPRSystem.eugdpr_cancel_del_account_rsp(res)
  log(bWriteLog and "EUGDPRSystem.eugdpr_cancel_del_account_rsp, res = " .. res)
  if res ~= NetErrorCode_NONE then
    ShowNotice(4372)
  else
    DataMgr.roleData.eugdpr.is_deleting = false
  end
end
function EUGDPRSystem.krjp_del_account_rsp(res)
  log(bWriteLog and "EUGDPRSystem.krjp_del_account_rsp, res = " .. res)
  if bDeleteAsync then
    if res == "fail" then
      ShowNotice(4372)
    elseif bShouldLogoutAfterDelete == true then
      local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
      login_module:backLogin()
    end
    logic_connection_waiting:Hide(1)
    bDeleteAsync = false
  end
end
function EUGDPRSystem.krjp_cancel_del_account_rsp(res)
  log(bWriteLog and "EUGDPRSystem.krjp_cancel_del_account_rsp, res = " .. res)
  DataMgr.krjp_del_account_left_time = 0
  BP_krjp_del_account_time = 0
end
function EUGDPRSystem.eugdpr_direct_del_account_rsp(res)
  log(bWriteLog and "EUGDPRSystem.eugdpr_direct_del_account_rsp, res = " .. res)
  if res ~= NetErrorCode_NONE then
  end
end
function EUGDPRSystem.eugdpr_notify(res)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if res == "delete account relogin" then
    log(bWriteLog and "EUGDPRSystem.eugdpr_notify, res = delete account relogin, and ReConnect")
    login_module:ConnectToGate()
  elseif res == "delete account direct" then
    login_module.sendLogout()
  else
    log(bWriteLog and "EUGDPRSystem.eugdpr_notify, res = " .. res)
  end
end
function EUGDPRSystem.SetNoEUJuvenile(value)
  EUGDPRSystem.NoEUJuvenile = value
end
return EUGDPRSystem