local logic_AIChat_Adult = {}
function logic_AIChat_Adult:OnInitialize()
  self.AgegateSDKAdult = nil
  self._GM_SET_CHECK = false
end
function logic_AIChat_Adult:RegistEvents()
end
function logic_AIChat_Adult:NeedCheckAdult()
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  return region == PublishRegionMacros.GLOBAL or region == PublishRegionMacros.FIT or region == PublishRegionMacros.CE or region == PublishRegionMacros.FITCE
end
function logic_AIChat_Adult:CallAgegateSDK()
  if type(self.AgegateSDKAdult) ~= "nil" then
    return
  end
  local logic_compliance = require("client.slua.logic.gdpr.logic_compliance")
  logic_compliance.SDKSetUserProfile("")
  logic_compliance.SDKQueryUserStatus(function(jsonData)
    log(bWriteLog and "logic_housekeeper_AI:CallAgegateSDK SDKQueryUserStatus cb")
    if jsonData and jsonData.adultStatus == 1 then
      self.AgegateSDKAdult = true
    else
      self.AgegateSDKAdult = false
    end
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_LOBBY_ENTRY_ITEM_UPDATE)
    EventSystem:postEvent(EVENTTYPE_UGC_COPILOT, EVENTID_UGC_COPILOT_ENTRY_UPDATE)
    EventSystem:postEvent(EVENTTYPE_MINI_TV, EVENTID_MINI_AGEGATE_UPDATE)
  end)
end
function logic_AIChat_Adult:CallAgegateSDKPromise()
  local Promise = require("common.Promise")
  local promise = Promise.new()
  if Client and string.lower(Client.GetDevicePlatformName()) == "windows" then
    promise:Resolve(true)
    return promise
  end
  if type(self.AgegateSDKAdult) ~= "nil" then
    promise:Resolve(self.AgegateSDKAdult == true)
    return promise
  end
  local logic_compliance = require("client.slua.logic.gdpr.logic_compliance")
  logic_compliance.SDKSetUserProfile("")
  logic_compliance.SDKQueryUserStatus(function(jsonData)
    log(bWriteLog and "logic_AIChat_Adult:CallAgegateSDKPromise SDKQueryUserStatus callback")
    if jsonData and jsonData.adultStatus == 1 then
      self.AgegateSDKAdult = true
    else
      self.AgegateSDKAdult = false
    end
    promise:Resolve(self.AgegateSDKAdult == true)
  end)
  return promise
end
function logic_AIChat_Adult:_CheckAgeGate(forbidenTip, passWhenAgegateFinished)
  if not self:NeedCheckAdult() then
    log(bWriteLog and "logic_housekeeper_AI:CheckAgeGate not self:NeedCheckAdult true")
    return true
  end
  if self._GM_SET_CHECK or _G.IsEditor then
    log(bWriteLog and "logic_housekeeper_AI:CheckAgeGate _GM_SET_CHECK true")
    return true
  end
  local agegate_state = DataMgr.minor_cert_status
  local logic_compliance = require("client.slua.logic.gdpr.logic_compliance")
  local agegate_switch = logic_compliance.CanUseAgeGate()
  local logic_gdpr = require("client.slua.logic.gdpr.logic_gdpr")
  local gdpr_user_type = 1
  if DataMgr.roleData.eugdpr then
    gdpr_user_type = DataMgr.roleData.eugdpr.user_type
  else
    log(bWriteLog and "logic_housekeeper_AI:CheckAgeGate eugdpr is nil")
  end
  log(bWriteLog and string.format("logic_housekeeper_AI:CheckAgeGate check_switch = %s, agegate_switch = %s, agegate_state = %s, gdpr_user_type = %s", tostring(check_switch), tostring(agegate_switch), tostring(agegate_state), tostring(gdpr_user_type)))
  if agegate_state == logic_compliance.Enum_Minor_Cert_Status.Finish and (passWhenAgegateFinished or self.AgegateSDKAdult) then
    log(bWriteLog and "logic_housekeeper_AI:CheckAgeGate (agegate_state Finish) passed")
    return true
  end
  local gdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  if gdpr_user_type ~= 0 and logic_gdpr.IsEUGDPRUser(gdpr_user_type) and gdprSystem.GetEUGDPR_IsAdult() and logic_gdpr.CanAccessClub(gdpr_user_type) then
    log(bWriteLog and "logic_housekeeper_AI:CheckAgeGate (agegate_state Finish) logic_gdpr is true")
    return true
  end
  if not forbidenTip and agegate_switch and agegate_state ~= logic_compliance.Enum_Minor_Cert_Status.Finish then
    log(bWriteLog and "logic_housekeeper_AI:CheckAgeGate (agegate_state not Finish) gdprSystem.ShowAgeGatePage()")
    logic_compliance.bForceCert = false
    gdprSystem.ShowAgeGatePage()
  end
  log(bWriteLog and "logic_housekeeper_AI:CheckAgeGate (agegate_state)=" .. tostring(agegate_state))
  log(bWriteLog and "logic_housekeeper_AI:CheckAgeGate (AgegateSDKAdult)=" .. tostring(self.AgegateSDKAdult))
  return false
end
function logic_AIChat_Adult:CheckAgeGate(forbidenTip)
  return self:_CheckAgeGate(forbidenTip, false)
end
function logic_AIChat_Adult:CheckAgeGateForUGCAssistant(forbidenTip)
  return self:_CheckAgeGate(forbidenTip, true)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_AIChat_Adult)