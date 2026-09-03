local NetManager = require("client.network.comm.NetManager")
local LegendWeaponHandler = {}
function LegendWeaponHandler.send_set_lgd_wpn(lgd_wpn_resid, scene_lobby, scene_battle)
  log(bWriteLog and string.format("LegendWeaponHandler.send_set_lgd_wpn, lgd_wpn_resid:%s", lgd_wpn_resid))
  log(bWriteLog and string.format("LegendWeaponHandler.send_set_lgd_wpn, scene_lobby:%s", scene_lobby))
  log(bWriteLog and string.format("LegendWeaponHandler.send_set_lgd_wpn, scene_battle:%s", scene_battle))
  NetManager.SendPkg(592944380, lgd_wpn_resid, scene_lobby, scene_battle)
end
function LegendWeaponHandler.on_set_lgd_wpn_rsp(err_code, lgd_wpn_info)
  log(bWriteLog and string.format("LegendWeaponHandler.on_set_lgd_wpn_rsp, err_code:%s", err_code))
  log_tree(bWriteLog and "LegendWeaponHandler.on_set_lgd_wpn_rsp lgd_wpn_info", lgd_wpn_info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
  logic_legend_weapon:on_set_lgd_wpn_rsp(lgd_wpn_info)
end
return LegendWeaponHandler