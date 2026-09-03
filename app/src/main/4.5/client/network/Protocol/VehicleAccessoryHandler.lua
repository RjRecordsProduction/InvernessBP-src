local NetManager = require("client.network.comm.NetManager")
local VehicleAccessoryHandler = {}
function VehicleAccessoryHandler.send_car_unlock_accessory_req(car_id, acc_id)
  NetManager.SendPkg(587402471, car_id, acc_id)
end
function VehicleAccessoryHandler.on_car_unlock_accessory_rsp(err_code, car_id, acc_id)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicVehicleAccessory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleAccessory)
  LogicVehicleAccessory:on_car_unlock_accessory_rsp(car_id, acc_id)
end
function VehicleAccessoryHandler.send_car_accessory_op_req(car_id, acc_id, op_type)
  NetManager.SendPkg(570658407, car_id, acc_id, op_type)
end
function VehicleAccessoryHandler.on_car_accessory_op_rsp(err_code, car_id, acc_id, op_type)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicVehicleAccessory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleAccessory)
  LogicVehicleAccessory:on_car_accessory_op_rsp(car_id, acc_id, op_type)
end
function VehicleAccessoryHandler.on_car_accessory_notify(car_acc_list)
  local LogicVehicleAccessory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleAccessory)
  LogicVehicleAccessory:on_car_accessory_notify(car_acc_list)
end
function VehicleAccessoryHandler.send_get_sports_car_feature_req()
  NetManager.SendPkg(1551465863)
end
function VehicleAccessoryHandler.on_get_sports_car_feature_rsp(ret_list, install_list)
  log_tree("VehicleAccessoryHandler.on_get_sports_car_feature_rsp ret_list", ret_list)
  log_tree("VehicleAccessoryHandler.on_get_sports_car_feature_rsp install_list", install_list)
  local VehicleFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleFeature)
  VehicleFeature:OnVehicleFeatureResponse(ret_list, install_list)
end
function VehicleAccessoryHandler.on_notify_sports_car_feature_data(add_list)
  log_tree("VehicleAccessoryHandler.on_notify_sports_car_feature_data", add_list)
  local VehicleFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleFeature)
  VehicleFeature:AddVehicleFeatureResponse(add_list)
end
function VehicleAccessoryHandler.send_car_feature_op_req(feature_id, op_type)
  NetManager.SendPkg(1880421223, feature_id, op_type)
end
function VehicleAccessoryHandler.on_car_feature_op_rsp(err, feature_id, op_type)
  log(bWriteLog and string.format("VehicleAccessoryHandler.on_car_feature_op_rsp err = %s, feature_id = %s, op_type = %s", err, feature_id, op_type))
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local VehicleFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleFeature)
  VehicleFeature:InstallFeatureResponse(feature_id, op_type)
  EventSystem:postEvent(EVENTTYPE_VEHICLE_COLLECT, EVENTID_VEHICLE_INSTALL_STATUS_REF, feature_id, op_type)
end
function VehicleAccessoryHandler.send_get_car_feature_data_req()
  log(bWriteLog and "VehicleAccessoryHandler.send_get_car_feature_data_req")
  NetManager.SendPkg(255146855)
end
function VehicleAccessoryHandler.on_get_car_feature_data_rsp(err, feature_data, inherit_feature_data)
  log(bWriteLog and string.format("VehicleAccessoryHandler.on_get_car_feature_data_rsp err = %s", err))
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  log_tree("VehicleAccessoryHandler.on_get_car_feature_data_rsp", feature_data)
  log_tree("VehicleAccessoryHandler.on_get_car_feature_data_rsp inherit_feature_data", inherit_feature_data)
  local LogicVehicleExtendedFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleExtendedFeature)
  LogicVehicleExtendedFeature:on_get_car_feature_data_rsp(feature_data, inherit_feature_data)
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  VehicleCollectSystem:UpdateVechileVoiceSwitch(feature_data.car_voice_switch)
end
function VehicleAccessoryHandler.on_notify_car_feature_data(feature_data, inherit_feature_data)
  log_tree("VehicleAccessoryHandler.on_notify_car_feature_data", feature_data)
  log_tree("VehicleAccessoryHandler.on_notify_car_feature_data inherit_feature_data", inherit_feature_data)
  local LogicVehicleExtendedFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleExtendedFeature)
  LogicVehicleExtendedFeature:on_notify_car_feature_data(feature_data)
end
function VehicleAccessoryHandler.send_equip_car_feature_req(car_id, resid, op_type)
  log(bWriteLog and "VehicleAccessoryHandler.send_equip_car_feature_req car_id:" .. tostring(car_id) .. ", resid:" .. tostring(resid) .. ", op_type:" .. tostring(op_type))
  NetManager.SendPkg(2060432571, car_id, resid, op_type)
end
function VehicleAccessoryHandler.on_equip_car_feature_rsp(ret, car_id, resid, op_type, feature_data)
  log(bWriteLog and "VehicleAccessoryHandler.on_equip_car_feature_rsp ret:" .. tostring(ret) .. ", car_id:" .. tostring(car_id) .. ", resid:" .. tostring(resid) .. ", op_type:" .. tostring(op_type))
  log_tree("VehicleAccessoryHandler.on_equip_car_feature_rsp", feature_data)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  local LogicVehicleExtendedFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleExtendedFeature)
  LogicVehicleExtendedFeature:on_equip_car_feature_rsp(car_id, resid, op_type, feature_data)
end
function VehicleAccessoryHandler.send_clear_car_feature_red_point_req(resid)
  log(bWriteLog and "VehicleAccessoryHandler.send_clear_car_feature_red_point_req resid:" .. tostring(resid))
  NetManager.SendPkg(574450627, resid)
end
function VehicleAccessoryHandler.on_clear_car_feature_red_point_rsp(err, resid)
  log(bWriteLog and "VehicleAccessoryHandler.on_clear_car_feature_red_point_rsp err:" .. tostring(err) .. ", resid:" .. tostring(resid))
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local LogicVehicleExtendedFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleExtendedFeature)
  LogicVehicleExtendedFeature:on_clear_car_feature_red_point_rsp(resid)
end
return VehicleAccessoryHandler