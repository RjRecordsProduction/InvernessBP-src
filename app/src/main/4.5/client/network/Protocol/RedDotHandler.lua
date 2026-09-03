local NetManager = require("client.network.comm.NetManager")
local RedDotHandler = {}
function RedDotHandler.send_reddot_list_req()
  NetManager.SendPkg(1697297047)
end
function RedDotHandler.on_reddot_list_rsp(list)
  local RedDotSystem = require("client.slua.logic.common.logic_reddot")
  RedDotSystem.OnRedDotListRsp(list)
  local logic_lobby_system_entrance_reddot = require("client.slua.logic.lobby.logic_lobby_system_entrance_reddot")
  logic_lobby_system_entrance_reddot.proc_reddot_list_rsp(list)
end
function RedDotHandler.send_dismiss_reddot_ntf(id)
  NetManager.SendPkg(949081610, id)
end
function RedDotHandler.on_display_reddot_ntf(id, notify_time)
  local RedDotSystem = require("client.slua.logic.common.logic_reddot")
  RedDotSystem.OnDisplayRedDotNtf(id, notify_time)
end
function RedDotHandler.on_sync_reddots_label_rsp(user_label)
end
function RedDotHandler.on_sync_reddots_info(overall_data, label, reddot_args, dynamicWeightParamsTable)
  log(bWriteLog and "[DeanJYT] RedDotHandler.on_sync_reddots_info label = " .. tostring(label))
  EventSystem:postEvent(EVENTTYPE_REDDOT, EVENTID_REDDOT_SYSTEM_OVER_ALL, overall_data, label, reddot_args, dynamicWeightParamsTable)
end
return RedDotHandler