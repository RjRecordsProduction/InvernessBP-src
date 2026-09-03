local NetManager = require("client.network.comm.NetManager")
local MarketingAgreementHandler = {}
function MarketingAgreementHandler.send_report_marketing_agreement(is_agree)
  log(bWriteLog and string.format("MarketingAgreementHandler.send_report_marketing_agreement is_agree: %s", tostring(is_agree)))
  NetManager.SendPkg(1456190924, is_agree)
end
function MarketingAgreementHandler.on_report_marketing_agreement_rsp(ret)
  log(bWriteLog and string.format("MarketingAgreementHandler.on_report_marketing_agreement_rsp ret: %s", tostring(ret)))
  local logic_marketing_agreement = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_marketing_agreement)
  logic_marketing_agreement:proc_report_marketing_agreement_rsp(ret)
  local logic_whatsApp_subscription = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_whatsApp_subscription)
  logic_whatsApp_subscription:on_report_marketing_agreement_rsp(ret)
end
function MarketingAgreementHandler.send_query_marketing_agreement()
  NetManager.SendPkg(2062167404)
end
function MarketingAgreementHandler.on_query_marketing_agreement_rsp(err_code, data)
  log(bWriteLog and "MarketingAgreementHandler.on_query_marketing_agreement_rsp err_code: " .. tostring(err_code))
  if err_code and err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_whatsApp_subscription = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_whatsApp_subscription)
  logic_whatsApp_subscription:on_query_marketing_agreement_rsp(data)
end
return MarketingAgreementHandler