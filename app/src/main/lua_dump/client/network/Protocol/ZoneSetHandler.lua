local NetManager = require("client.network.comm.NetManager")
local ZoneSetHandler = {}
function ZoneSetHandler.send_get_most_used_shadow_req()
  NetManager.SendPkg(1887847412)
end
function ZoneSetHandler.on_sync_most_used_shadow(most_used_shadow, shadow_default, only_use_shadow_ping)
  log_tree("[PXY]on_sync_most_used_shadow, shadow_default:", shadow_default)
  log(bWriteLog and "[PXY]on_sync_most_used_shadow, most_used_shadow: " .. tostring(most_used_shadow))
  log(bWriteLog and "[DeanJYT] ZoneSetHandler.on_sync_most_used_shadow, only_use_shadow_ping = " .. tostring(only_use_shadow_ping))
  local logic_setzone_control = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setzone_control)
  logic_setzone_control:SetDelayArea(most_used_shadow, shadow_default, only_use_shadow_ping)
end
return ZoneSetHandler