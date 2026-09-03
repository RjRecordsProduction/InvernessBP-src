local NetManager = require("client.network.comm.NetManager")
local PatrollerHandler = {}
function PatrollerHandler.send_query_patroller_privilege_level_req()
  NetManager.SendPkg(224639039)
end
function PatrollerHandler.on_query_patroller_privilege_level_rsp(err_code, privilege_level, last_query_time)
  log(bWriteLog and "PatrollerHandler.on_query_patroller_privilege_level_rsp err_code:" .. tostring(err_code) .. " privilege_level:" .. tostring(privilege_level) .. " last_query_time:" .. tostring(last_query_time))
  if err_code == 0 then
    local PatrollerModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PatrollerModule)
    PatrollerModule:on_query_patroller_privilege_level_rsp(privilege_level, last_query_time)
  else
    ShowNotice(err_code)
  end
end
function PatrollerHandler.send_query_patroller_stat_info_req(ticket)
  NetManager.SendPkg(816081779, ticket)
end
function PatrollerHandler.on_query_patroller_stat_info_rsp(err_code, stat_info)
  log(bWriteLog and "PatrollerHandler.on_query_patroller_stat_info_rsp:" .. tostring(err_code))
  local PatrollerModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PatrollerModule)
  PatrollerModule:on_query_patroller_stat_info_rsp(stat_info)
end
return PatrollerHandler