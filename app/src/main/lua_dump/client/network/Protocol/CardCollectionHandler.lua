local NetManager = require("client.network.comm.NetManager")
local CardCollectionHandler = {}
function CardCollectionHandler.send_get_card_collect_data_req(target_uid)
  log(bWriteLog and "CardCollectionHandler.send_get_card_collect_data_req target_uid = " .. tostring(target_uid))
  NetManager.SendPkg(1707887231, target_uid)
end
function CardCollectionHandler.on_get_card_collect_data_rsp(res, target_uid, card_collect_data)
  if res ~= "ok" then
    log_error("CardCollectionHandler.on_get_card_collect_data_rsp err = " .. res)
    return
  end
  log(bWriteLog and "CardCollectionHandler.on_get_card_collect_data_rsp target_uid = " .. tostring(target_uid))
  log_tree("CardCollectionHandler.on_get_card_collect_data_rsp card_collect_data = ", card_collect_data)
  local logic_card_collection = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_card_collection)
  logic_card_collection:on_get_card_collect_data_rsp(target_uid, card_collect_data)
end
function CardCollectionHandler.send_give_collect_card_req(card_id, accept_uid)
  log(bWriteLog and "CardCollectionHandler.send_give_collect_card_req card_id = " .. tostring(card_id))
  log(bWriteLog and "CardCollectionHandler.send_give_collect_card_req accept_uid = " .. tostring(accept_uid))
  NetManager.SendPkg(1899779055, card_id, accept_uid)
end
function CardCollectionHandler.on_give_collect_card_rsp(err_msg, card_id, gave_count)
  if err_msg ~= "ok" then
    if err_msg == "already_have" then
      ShowNotice(79188)
      return
    end
    log_error("CardCollectionHandler.on_give_collect_card_rsp err_msg = " .. err_msg)
    return
  end
  log(bWriteLog and "CardCollectionHandler.on_give_collect_card_rsp card_id = " .. tostring(card_id))
  log(bWriteLog and "CardCollectionHandler.on_give_collect_card_rsp gave_count = " .. tostring(gave_count))
  local logic_card_collection = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_card_collection)
  logic_card_collection:on_give_collect_card_rsp(card_id, gave_count)
end
function CardCollectionHandler.on_notify_card_collect_data(card_collect_data)
  log_tree("CardCollectionHandler.on_notify_card_collect_data card_collect_data = ", card_collect_data)
  local logic_card_collection = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_card_collection)
  logic_card_collection:on_notify_card_collect_data(card_collect_data)
end
function CardCollectionHandler.send_set_show_card_req(card_id)
  log(bWriteLog and "CardCollectionHandler.send_set_show_card_req card_id = " .. tostring(card_id))
  NetManager.SendPkg(2013076615, card_id)
end
function CardCollectionHandler.on_set_show_card_rsp(res)
  if res ~= "ok" then
    log_error("CardCollectionHandler.on_set_show_card_rsp err_msg = " .. res)
    return
  end
  log(bWriteLog and "CardCollectionHandler.on_set_show_card_rsp")
  local logic_card_collection = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_card_collection)
  logic_card_collection:on_set_show_card_rsp()
end
function CardCollectionHandler.send_clear_be_gave_new_req()
  log(bWriteLog and "CardCollectionHandler.send_clear_be_gave_new_req")
  NetManager.SendPkg(1433011777)
end
function CardCollectionHandler.send_clear_card_new_req(new_card_table)
  log_tree(bWriteLog and "CardCollectionHandler.send_clear_card_new_req new_card_table = ", new_card_table)
  NetManager.SendPkg(2107515751, new_card_table)
end
function CardCollectionHandler.on_clear_card_new_rsp(res)
  if res ~= "ok" then
    log_error("CardCollectionHandler.on_clear_card_new_rsp err_msg = " .. res)
    return
  end
  log(bWriteLog and "CardCollectionHandler.on_clear_card_new_rsp")
  local logic_card_collection = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_card_collection)
  logic_card_collection:on_clear_card_new_rsp()
end
function CardCollectionHandler.on_notify_new_card_accept(accept_uid, give_uid, card_id, be_gave_new_count)
  log(bWriteLog and "CardCollectionHandler.on_notify_new_card_accept accept_uid = " .. tostring(accept_uid))
  log(bWriteLog and "CardCollectionHandler.on_notify_new_card_accept give_uid = " .. tostring(give_uid))
  log(bWriteLog and "CardCollectionHandler.on_notify_new_card_accept card_id = " .. tostring(card_id))
  log(bWriteLog and "CardCollectionHandler.on_notify_new_card_accept be_gave_new_count = " .. tostring(be_gave_new_count))
  local logic_card_collection = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_card_collection)
  logic_card_collection:on_notify_new_card_accept(accept_uid, give_uid, card_id, be_gave_new_count)
end
function CardCollectionHandler.send_set_action_card_version_req(verison)
  log(bWriteLog and "CardCollectionHandler.send_set_action_card_version_req verison = " .. verison)
  NetManager.SendPkg(1328069623, verison)
end
function CardCollectionHandler.on_set_action_card_version_rsp(err_code)
  log(bWriteLog and "CardCollectionHandler.on_set_action_card_version_rsp err_code = " .. err_code)
  if err_code ~= "ok" then
    log_error("CardCollectionHandler.on_set_action_card_version_rsp err_code = " .. err_code)
    return
  end
  local logic_card_collection = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_card_collection)
  logic_card_collection:on_set_action_card_version_rsp()
end
return CardCollectionHandler