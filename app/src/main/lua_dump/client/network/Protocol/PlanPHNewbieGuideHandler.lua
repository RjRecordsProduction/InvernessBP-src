local NetManager = require("client.network.comm.NetManager")
local PHomeHandler = require("client.network.Protocol.PHomeHandler")
local PlanPHNewbieGuideHandler = {}
function PlanPHNewbieGuideHandler.send_get_manor_newbie_guide_req()
  PHomeHandler.send_manor_on_client_call_req("get_manor_newbie_guide_req")
end
function PlanPHNewbieGuideHandler.on_get_manor_newbie_guide_rsp(err_code, status)
  log(bWriteLog and "PlanPHNewbieGuideHandler.on_get_manor_newbie_guide_rsp err_code = " .. tostring(err_code))
  log_tree("PlanPHNewbieGuideHandler.on_get_manor_newbie_guide_rsp status = ", status)
  if err_code ~= 0 then
    return
  end
  local logic_home_newbieguide = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_newbieguide)
  logic_home_newbieguide:OnGetHomeNewbieGuideTaskStatus(status)
end
function PlanPHNewbieGuideHandler.send_finish_manor_newbie_guide_req(taskIds)
  log(bWriteLog and "PlanPHNewbieGuideHandler.send_finish_manor_newbie_guide_req")
  log_tree("send_finish_manor_newbie_guide_req taskIds = ", taskIds)
  PHomeHandler.send_manor_on_client_call_req("finish_manor_newbie_guide_req", taskIds)
end
function PlanPHNewbieGuideHandler.on_finish_manor_newbie_guide_rsp(err_code, taskIds)
  log(bWriteLog and "PlanPHNewbieGuideHandler.on_finish_manor_newbie_guide_rsp err_code = " .. tostring(err_code))
  log_tree("on_finish_manor_newbie_guide_rsp taskIds = ", taskIds)
  if err_code ~= 0 then
    return
  end
  local logic_home_newbieguide = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_newbieguide)
  logic_home_newbieguide:OnFinishHomeNewbieGuideTask(taskIds, false)
end
function PlanPHNewbieGuideHandler.send_manor_guide_progress_report_req(report_info)
  log_tree("[wzp]PlanPHNewbieGuideHandler.send_manor_guide_progress_report_req report_info = ", report_info)
  local report_info = slua.LuaArchiverEncode(LuaStateWrapper, report_info)
  PHomeHandler.send_manor_on_client_call_req("manor_guide_progress_report_req", report_info)
end
function PlanPHNewbieGuideHandler.on_manor_guide_progress_report_rsp(err_code)
  log(bWriteLog and "[wzp]PlanPHNewbieGuideHandler.on_manor_guide_progress_report_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
end
function PlanPHNewbieGuideHandler.send_manor_get_guide_progress_req()
  log(bWriteLog and "[wzp]PlanPHNewbieGuideHandler.send_manor_get_guide_progress_req")
  PHomeHandler.send_manor_on_client_call_req("manor_get_guide_progress_req")
end
function PlanPHNewbieGuideHandler.on_manor_get_guide_progress_rsp(err_code, progress_info)
  log(bWriteLog and "[wzp]PlanPHNewbieGuideHandler.on_manor_get_guide_progress_rsp err_code = " .. tostring(err_code))
  if err_code ~= 0 then
    return
  end
  local info = slua.LuaArchiverDecode(LuaStateWrapper, progress_info)
  log_tree("[wzp]PlanPHNewbieGuideHandler.on_manor_get_guide_progress_rsp report_info = ", info)
  local PlanPH_Guide_SubSystem = SubsystemMgr:Get("PlanPH_Guide_SubSystem")
  if PlanPH_Guide_SubSystem then
    PlanPH_Guide_SubSystem:GetGuideProgressRsp(info or {})
  end
end
return PlanPHNewbieGuideHandler