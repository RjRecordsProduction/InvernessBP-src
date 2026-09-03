local NetManager = require("client.network.comm.NetManager")
local ThemeSystemHandler = {}
function ThemeSystemHandler.send_unpack_offline_chest_req(inst_id)
  log(bWriteLog and string.format("ThemeSystemHandler.send_unpack_offline_chest_req inst_id = %s", inst_id))
  NetManager.SendPkg(961152999, inst_id)
end
function ThemeSystemHandler.on_unpack_offline_chest_rsp(res, offline_chest_desc)
  log(bWriteLog and string.format("ThemeSystemHandler.on_unpack_offline_chest_rsp res = %s", res))
  if res == 0 then
    local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
    logic_theme_system:ReceiveUnpackOfflineChest(offline_chest_desc)
  else
    ShowNotice(res)
  end
end
function ThemeSystemHandler.send_query_offline_chest_req()
  NetManager.SendPkg(18972067)
end
function ThemeSystemHandler.on_query_offline_chest_rsp(res, offline_chest)
  log(bWriteLog and string.format("ThemeSystemHandler.on_query_offline_chest_rsp res = %s", res))
  if res == 0 then
    local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
    logic_theme_system:ReceiveOfflineChestInfo(offline_chest)
  else
    ShowNotice(res)
  end
end
function ThemeSystemHandler.send_open_offline_chest_req(inst_id)
  log(bWriteLog and string.format("ThemeSystemHandler.send_open_offline_chest_req inst_id = %s", inst_id))
  NetManager.SendPkg(1880653703, inst_id)
end
function ThemeSystemHandler.on_open_offline_chest_rsp(res, award_list)
  log(bWriteLog and string.format("ThemeSystemHandler.on_open_offline_chest_rsp res = %s", res))
  if res == 0 then
    local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
    logic_theme_system:ReceiveAward(award_list)
  elseif res == 100251011 then
    ThemeSystemHandler.send_query_offline_chest_req()
    EventSystem:postEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_OFFLINE_CHEST)
  else
    ShowNotice(res)
  end
end
function ThemeSystemHandler.send_get_global_magic_tree_percent_req()
  NetManager.SendPkg(1806285623)
end
function ThemeSystemHandler.on_get_global_magic_tree_percent_rsp(err_code, ret_tbl)
  log(bWriteLog and "ThemeSystemHandler.on_get_global_magic_tree_percent_rsp err_code " .. tostring(err_code))
  log_tree("ThemeSystemHandler.on_get_global_magic_tree_percent_rsp ret_tbl", ret_tbl)
  local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
  logic_theme_system:on_get_global_magic_tree_percent_rsp(err_code, ret_tbl)
end
function ThemeSystemHandler.send_get_magic_tree_stat_req()
  NetManager.SendPkg(539116635)
end
function ThemeSystemHandler.on_get_magic_tree_stat_rsp(data, watering_info)
  log_tree(bWriteLog and "ThemeSystemHandler.on_get_magic_tree_stat_rsp plant_info = ", data)
  log_tree(bWriteLog and "ThemeSystemHandler.on_get_magic_tree_stat_rsp watering_info = ", watering_info)
  local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
  logic_theme_system:on_get_magic_tree_stat_rsp(data, watering_info)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_PLANTINFO)
end
function ThemeSystemHandler.send_watering_tree_req(group_id)
  NetManager.SendPkg(1573390235, group_id)
end
function ThemeSystemHandler.on_watering_tree_rsp(err_num, magic_plant, watering_info)
  log(bWriteLog and "ThemeSystemHandler.on_watering_tree_rsp err_num is " .. tostring(err_num))
  log_tree(bWriteLog and "ThemeSystemHandler.on_watering_tree_rsp magic_plant = ", magic_plant)
  log_tree(bWriteLog and "ThemeSystemHandler.on_watering_tree_rsp watering_info = ", watering_info)
end
function ThemeSystemHandler.send_get_offline_chest_v2_req()
  log(bWriteLog and "ThemeSystemHandler.send_get_offline_chest_v2_req")
  NetManager.SendPkg(35104807)
end
function ThemeSystemHandler.on_get_offline_chest_v2_rsp(err_code, offline_chest_v2)
  log(bWriteLog and string.format("ThemeSystemHandler.on_get_offline_chest_v2_rsp err_code = %s", err_code))
  log_tree(bWriteLog and "ThemeSystemHandler.on_get_offline_chest_v2_rsp offline_chest_v2", offline_chest_v2)
  if err_code == 0 then
    local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
    logic_theme_system:ReceiveOfflineChestV2Info(offline_chest_v2)
    EventSystem:postEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_OFFLINE_CHEST)
  else
    ShowNotice(err_code)
  end
end
function ThemeSystemHandler.send_open_offline_chest_v2_req()
  log(bWriteLog and "ThemeSystemHandler.send_open_offline_chest_v2_req")
  NetManager.SendPkg(819094383)
end
function ThemeSystemHandler.on_open_offline_chest_v2_rsp(err_code, award_list, offline_chest_v2)
  log(bWriteLog and string.format("ThemeSystemHandler.on_open_offline_chest_v2_rsp err_code = %s", err_code))
  log_tree(bWriteLog and "ThemeSystemHandler.on_open_offline_chest_v2_rsp award_list", award_list)
  log_tree(bWriteLog and "ThemeSystemHandler.on_open_offline_chest_v2_rsp offline_chest_v2", offline_chest_v2)
  if err_code == 0 then
    local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
    logic_theme_system:ReceiveOfflineChestV2Award(award_list, offline_chest_v2)
    EventSystem:postEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_OFFLINE_CHEST)
  elseif err_code == 100251011 then
    ThemeSystemHandler.send_get_offline_chest_v2_req()
    EventSystem:postEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_OFFLINE_CHEST)
  else
    ShowNotice(err_code)
  end
end
local reqRsp = {
  send_get_global_magic_tree_percent_req = "on_get_global_magic_tree_percent_rsp",
  send_get_magic_tree_stat_req = "on_get_magic_tree_stat_rsp",
  send_watering_tree_req = "on_watering_tree_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, ThemeSystemHandler)
return ThemeSystemHandler