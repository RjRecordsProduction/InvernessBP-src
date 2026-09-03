local NetManager = require("client.network.comm.NetManager")
local VehicleCollectHandler = {}
function VehicleCollectHandler.send_get_car_collection_award_status_req(car_type)
  log(bWriteLog and string.format("VehicleCollectHandler.send_get_car_collection_award_status_req car_type = %s", car_type))
  NetManager.SendPkg(2074655559, car_type)
end
function VehicleCollectHandler.on_get_car_collection_award_status_rsp(err_code, car_type, award_status)
  log_tree("on_get_car_collection_award_status_rsp", {
    err_code,
    car_type,
    award_status
  })
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local vehicle_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.vehicle_collect_manager)
  vehicle_collect_manager:ResponseCollectAwardStatus(car_type, award_status)
end
function VehicleCollectHandler.send_take_car_collection_award_req(car_type, award_index)
  NetManager.SendPkg(285208991, car_type, award_index)
end
function VehicleCollectHandler.on_take_car_collection_award_rsp(err_code, car_type, award_index)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("VehicleCollectHandler.on_take_car_collection_award_rsp", {car_type, award_index})
end
function VehicleCollectHandler.send_get_car_collection_data_req()
  NetManager.SendPkg(38829951)
end
function VehicleCollectHandler.on_get_car_collection_data_rsp(err_code, award, plate_number)
end
function VehicleCollectHandler.send_edit_car_plate_number_req(car_type, plate_number)
  NetManager.SendPkg(1052074523, car_type, plate_number)
end
function VehicleCollectHandler.on_edit_car_plate_number_rsp(err_code, car_type, plate_number)
  if err_code ~= 0 then
    ShowNotice(err_code)
    EventSystem:postEvent(EVENTTYPE_VEHICLE_COLLECT, EVENTID_VEHICLE_COLLECT_LICENSE_CHANGE)
    return
  end
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  VehicleCollectSystem:on_edit_car_plate_number_rsp(car_type, plate_number)
end
function VehicleCollectHandler.send_get_car_collection_info_req()
  NetManager.SendPkg(635979223)
end
function VehicleCollectHandler.on_get_car_collection_info_rsp(err_code, car_collection, car_colleciton_unlock_table, car_cost_uc_table, inherit_car_collection)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree("on_get_car_collection_info_rsp car_collection = ", car_collection)
  log_tree("on_get_car_collection_info_rsp car_colleciton_unlock_table = ", car_colleciton_unlock_table)
  log_tree("on_get_car_collection_info_rsp  car_cost_uc_table:", car_cost_uc_table)
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  VehicleCollectSystem:on_get_car_collection_info_rsp(car_collection, car_colleciton_unlock_table, car_cost_uc_table, inherit_car_collection)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  HallThemeUtils.ShowThemeVehicle()
  VehicleCollectSystem:IsShowVehicleReddot()
  EventSystem:postEvent(EVENTTYPE_VEHICLE_COLLECT, EVENTID_VEHICLE_UNLOCK_FEATURE_EFFECT_RSP_REFRESH)
end
function VehicleCollectHandler.send_set_car_feature_switch_req(cart_type, value)
  NetManager.SendPkg(1844967463, cart_type, value)
end
function VehicleCollectHandler.on_set_car_feature_switch_rsp(err_code, car_type, value)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  VehicleCollectSystem:SetTireSwitch(car_type, value)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  HallThemeUtils.ShowThemeVehicle()
end
function VehicleCollectHandler.send_unlock_specific_sports_car_feature_req(car_id, feature_id)
  NetManager.SendPkg(2123152103, car_id, feature_id)
end
function VehicleCollectHandler.on_unlock_specific_sports_car_feature_rsp(retcode, car_id, feature_id)
  if retcode ~= 0 then
    ShowNotice(retcode)
    return
  end
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  VehicleCollectSystem:HandleUnlockFeatureEffectRsp()
end
function VehicleCollectHandler.send_take_unlock_refund_req(car_type, feature_id)
  NetManager.SendPkg(481007911, car_type, feature_id)
end
function VehicleCollectHandler.on_take_unlock_refund_rsp(retcode, car_type, feature_id, res_list)
  if retcode ~= 0 then
    ShowNotice(retcode)
    return
  end
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  VehicleCollectSystem:HandleGetRewardRsp(car_type, feature_id, res_list)
end
function VehicleCollectHandler.send_set_car_voice_switch_req(switch_value)
  NetManager.SendPkg(1707900135, switch_value)
end
function VehicleCollectHandler.on_set_car_voice_switch_rsp(err_code, switch_value)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  VehicleCollectSystem:UpdateVechileVoiceSwitch(switch_value)
end
return VehicleCollectHandler