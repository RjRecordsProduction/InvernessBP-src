local NetManager = require("client.network.comm.NetManager")
local PHomeHandler = require("client.network.Protocol.PHomeHandler")
local PHomeAuditHandler = {}
function PHomeAuditHandler.send_manor_scene_draft_state_req()
  log(bWriteLog and "PHomeAuditHandler.send_manor_scene_draft_state_req")
  PHomeHandler.send_manor_on_client_call_req("manor_scene_draft_state_req")
end
function PHomeAuditHandler.on_manor_scene_draft_state_rsp(err_code, state, state_expire_time)
  log(bWriteLog and "PHomeAuditHandler.on_manor_scene_draft_state_rsp err_code = " .. err_code .. ", state = " .. tostring(state) .. ", state_expire_time = " .. tostring(state_expire_time))
  if err_code ~= 0 then
    return
  end
  if not state then
    return
  end
  local logic_home_audit_state = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_audit_state)
  logic_home_audit_state:proc_manor_scene_draft_state_rsp(state, state_expire_time)
end
function PHomeAuditHandler.on_manor_scene_draft_state_notify(state, state_expire_time, op_type)
  log(bWriteLog and "PHomeAuditHandler.on_manor_scene_draft_state_notify state = " .. tostring(state) .. ", state_expire_time = " .. tostring(state_expire_time) .. ", op_type = " .. tostring(op_type))
  if not state then
    return
  end
  local logic_home_audit_state = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_audit_state)
  logic_home_audit_state:proc_manor_scene_draft_state_notify(state, state_expire_time, op_type)
end
return PHomeAuditHandler