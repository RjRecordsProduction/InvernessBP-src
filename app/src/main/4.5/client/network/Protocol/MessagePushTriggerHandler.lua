local NetManager = require("client.network.comm.NetManager")
local MessagePushTriggerHandler = {}
function MessagePushTriggerHandler.send_set_push_msg_pop_up_confirm_req(trigger_cond, trigger_state)
  NetManager.SendPkg(1144819747, trigger_cond, trigger_state)
end
function MessagePushTriggerHandler.on_set_push_msg_pop_up_confirm_rsp(errcode)
  log(bWriteLog and "MessagePushTriggerHandler.on_set_push_msg_pop_up_confirm_rsp errcode = " .. tostring(errcode))
end
function MessagePushTriggerHandler.send_get_push_msg_pop_up_confirm_req()
  NetManager.SendPkg(1543727827)
end
function MessagePushTriggerHandler.on_get_push_msg_pop_up_confirm_rsp(errcode, recordData)
  EventSystem:postEvent(EVENTTYPE_MESSAGE_PUSH_TRIGGER, EVENTID_MESSAGE_PUSH_TRIGGER_RECEIVE_RECORD_DATA, errcode, recordData)
end
return MessagePushTriggerHandler