local NetManager = require("client.network.comm.NetManager")
local FCMPushHandler = {pendingSet = nil}
function FCMPushHandler.send_get_fcm_info_req()
  log(bWriteLog and "send_get_fcm_info_req ")
  NetManager.SendPkg(535043239)
end
function FCMPushHandler.on_get_fcm_info_rsp(isOpen, info_list)
  log(bWriteLog and "on_get_fcm_info_rsp isOpen:" .. tostring(isOpen))
  local FCMPushSystem = require("client.slua.logic.push.logic_fcm_push")
  FCMPushSystem.on_get_fcm_info_rsp(isOpen, info_list)
end
function FCMPushHandler.send_set_fcm_info_req(info_list)
  NetManager.SendPkg(713922727, info_list)
end
function FCMPushHandler.on_set_fcm_info_rsp(error_code)
  log(bWriteLog and "on_set_fcm_info_rsp error_code:" .. error_code)
end
function FCMPushHandler.send_get_msg_push_cfg_req()
  NetManager.SendPkg(1949481639)
end
function FCMPushHandler.on_get_msg_push_cfg_rsp(cfg, data)
  local LocalPushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LocalPushSystem)
  LocalPushSystem:on_get_msg_push_cfg_rsp(cfg, data)
end
function FCMPushHandler.send_set_fcm_switch_req(func_id, is_open)
  log(bWriteLog and string.format(" FCMPushHandler.send_set_fcm_switch_req func_id:%s, is_open:%s", func_id, is_open))
  NetManager.SendPkg(836538664, func_id, is_open)
end
function FCMPushHandler.on_set_fcm_switch_res(errcode)
  log(bWriteLog and string.format(" FCMPushHandler.on_set_fcm_switch_res errcode:%s", errcode))
  if errcode == 0 and FCMPushHandler.pendingSet then
    FCMPushHandler.pendingSet()
  end
  FCMPushHandler.pendingSet = nil
end
function FCMPushHandler.send_trigger_fcm_msg_req(func_id, frd_uids)
  log(bWriteLog and string.format(" FCMPushHandler.send_trigger_fcm_msg_req func_id:%s, frd_uids:%s", func_id, table.concat(frd_uids, ",")))
  NetManager.SendPkg(1344653352, func_id, frd_uids)
end
function FCMPushHandler.on_trigger_fcm_msg_res(err)
  log(bWriteLog and string.format(" FCMPushHandler.on_trigger_fcm_msg_res err:%s", err))
end
function FCMPushHandler.send_get_fcm_switch_info_req()
  log(bWriteLog and " FCMPushHandler.send_get_fcm_switch_info_req")
  NetManager.SendPkg(1850918064)
end
function FCMPushHandler.on_get_fcm_switch_info_res(switch_cfg, can_not_set_ids)
  log_tree(" FCMPushHandler.on_get_fcm_switch_info_res switch_cfg", switch_cfg)
  log_tree(" FCMPushHandler.on_get_fcm_switch_info_res can_not_set_ids", can_not_set_ids)
  local logic_setting_notify = require("client.logic.setting.logic_setting_notify")
  logic_setting_notify.InitFcmSwitchInfo(switch_cfg, can_not_set_ids)
end
return FCMPushHandler