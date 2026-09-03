local SmallPaymentHandler = {}
local NetManager = require("client.network.comm.NetManager")
function SmallPaymentHandler.send_get_noble_coupon_activity_req()
  NetManager.SendPkg(1413099699)
end
function SmallPaymentHandler.on_get_noble_coupon_activity_rsp(err_code, total_task_info, ext_info)
  local Logic_SmallPayment = require("client.slua.logic.SmallPayment.Logic_SmallPayment")
  if err_code ~= 0 then
    Logic_SmallPayment.HandleErrorCode(err_code)
    log(bWriteLog and " Error >>>>>>> get_noble_coupon_activity_req err_code : " .. tostring(err_code))
    return
  end
  Logic_SmallPayment.HandlerActivityData(total_task_info, ext_info)
end
function SmallPaymentHandler.on_sync_noble_coupon_activity_task_ntf(task_info)
  local Logic_SmallPayment = require("client.slua.logic.SmallPayment.Logic_SmallPayment")
  Logic_SmallPayment.CacheServerAllTaskData(task_info)
  Logic_SmallPayment.UpdateTaskData(task_info)
  EventSystem:postEvent(EVENTTYPE_SMALL_PAYMENT, EVENTID_SMALL_PAYMENT_TASK_UPDATE)
end
function SmallPaymentHandler.on_sync_noble_coupon_lucky_info(luck_player_info)
  EventSystem:postEvent(EVENTTYPE_SMALL_PAYMENT, EVENTID_SMALL_PAYMENT_SHOW_BARRAGE, luck_player_info)
end
return SmallPaymentHandler