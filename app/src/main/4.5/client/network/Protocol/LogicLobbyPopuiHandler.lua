local NetManager = require("client.network.comm.NetManager")
local LogicLobbyPopuiHandler = {}
function LogicLobbyPopuiHandler.send_get_popui_show_count_req()
  NetManager.SendPkg(960434343)
end
function LogicLobbyPopuiHandler.on_get_popui_show_count_rsp(show_info)
  local LuaTab = slua.LuaArchiverDecode(LuaStateWrapper, show_info)
  log_tree("on_get_popui_show_count_rsp", LuaTab)
  local ui_show_queue_server_data = require("client.common.uibase.ui_show_queue_server_data")
  ui_show_queue_server_data.SetServerData(LuaTab)
end
function LogicLobbyPopuiHandler.send_report_popui_show_info_req(show_info)
  show_info = slua.LuaArchiverEncode(LuaStateWrapper, show_info)
  if type(show_info) ~= "string" then
    log_tree("LogicLobbyPopuiHandler.send_report_popui_show_info_req type(data) ~=string", show_info)
    return
  end
  NetManager.SendPkg(518110759, show_info)
end
function LogicLobbyPopuiHandler.on_report_popui_show_info_rsp(err_code)
  log(bWriteLog and "Currenerr_code" .. err_code)
end
return LogicLobbyPopuiHandler