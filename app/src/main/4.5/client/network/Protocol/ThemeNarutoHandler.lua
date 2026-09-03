local NetManager = require("client.network.comm.NetManager")
local ThemeNarutoHandler = {}
function ThemeNarutoHandler.send_get_ninja_level_data_req()
  log(bWriteLog and "[NinjaTraining] ThemeNarutoHandler.send_get_ninja_level_data_req")
  NetManager.SendPkg(714424359)
end
function ThemeNarutoHandler.on_get_ninja_level_data_rsp(err_code, rsp_data)
  log_tree(bWriteLog and string.format("[NinjaTraining] ThemeNarutoHandler.on_get_ninja_level_data_rsp err_code=%s rsp_data", tostring(err_code)), rsp_data)
  if err_code ~= 0 then
    log_warning(string.format("ThemeNarutoHandler.on_get_ninja_level_data_rsp err = %s", err_code))
    return
  end
  if not rsp_data then
    return
  end
  local logic_ninja_training = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ninja_training)
  logic_ninja_training:on_get_ninja_level_data_rsp(rsp_data)
end
function ThemeNarutoHandler.on_notify_ninja_level_reward(push_data)
  log_tree(bWriteLog and "[NinjaTraining] ThemeNarutoHandler.on_notify_ninja_level_reward push_data", push_data)
  if not push_data then
    return
  end
  local logic_ninja_training = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ninja_training)
  logic_ninja_training:on_notify_ninja_level_reward(push_data)
end
return ThemeNarutoHandler