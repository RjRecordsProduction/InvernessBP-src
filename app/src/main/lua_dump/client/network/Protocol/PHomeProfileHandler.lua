local PHomeProfileHandler = {}
function PHomeProfileHandler.send_manor_summarys_req(uids, cb_data)
  local logic_home_proto_queue = require("client.slua.logic.home.Profile.logic_home_proto_queue")
  local PHomeHandler = require("client.network.Protocol.PHomeHandler")
  logic_home_proto_queue.sendRequest(PHomeHandler.send_manor_on_client_call_req, "manor_summarys_req", 2, uids, cb_data)
end
function PHomeProfileHandler.on_manor_summarys_rsp(err_code, summarys, cb_data)
  log(bWriteLog and "PHomeProfileHandler.on_manor_summarys_rsp err_code = " .. tostring(err_code))
  local logic_home_proto_queue = require("client.slua.logic.home.Profile.logic_home_proto_queue")
  logic_home_proto_queue.onResponseReceived("manor_summarys_req")
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  logic_home_profile:proc_manor_summarys_rsp(summarys, cb_data)
end
function PHomeProfileHandler.send_manor_summary_by_manor_id_req(manor_id)
  local PHomeHandler = require("client.network.Protocol.PHomeHandler")
  PHomeHandler.send_manor_on_client_call_req("manor_summary_by_manor_id_req", manor_id)
end
function PHomeProfileHandler.on_manor_summary_by_manor_id_rsp(err, summary)
  log(bWriteLog and "PHomeProfileHandler.on_manor_summary_by_manor_id_rsp")
  if err ~= 0 then
    if err ~= 19810001 then
      ShowNotice(err)
    end
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_HOME_SEARCH_END, summary)
    return
  end
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  logic_home_profile:proc_manor_summary_by_manor_id_rsp(summary)
end
return PHomeProfileHandler