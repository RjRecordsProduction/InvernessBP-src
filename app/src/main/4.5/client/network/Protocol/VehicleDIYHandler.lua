local NetManager = require("client.network.comm.NetManager")
local VehicleDIYHandler = {}
function VehicleDIYHandler.send_save_car_applique_data_req(car_id, applique_list, version)
  NetManager.SendPkg(688806759, car_id, applique_list, version)
end
function VehicleDIYHandler.on_save_car_applique_data_rsp(err, car_id, applique_list, version, cur_car_applique_data)
  local LogicVehicleDIY = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicVehicleDIY)
  if err ~= 0 then
    log(bWriteLog and "on_save_car_applique_data_rsp err = " .. tostring(err))
    ShowNotice(err)
    if err == 9920337 then
      cur_car_applique_data = cur_car_applique_data or {}
      LogicVehicleDIY:UpdateAppliqueData(car_id, cur_car_applique_data.version, cur_car_applique_data.appliques)
    end
    return
  end
  LogicVehicleDIY:on_save_car_applique_data_rsp(car_id, cur_car_applique_data.version, cur_car_applique_data.appliques)
end
function VehicleDIYHandler.send_get_car_applique_data_req()
  NetManager.SendPkg(1939760123)
end
function VehicleDIYHandler.on_get_car_applique_data_rsp(err, applique_data)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local LogicVehicleDIY = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicVehicleDIY)
  LogicVehicleDIY:UpdateAllAppliqueData(applique_data)
end
function VehicleDIYHandler.send_get_car_applique_data_by_car_req(car_id)
  NetManager.SendPkg(169344295, car_id)
end
function VehicleDIYHandler.on_get_car_applique_data_by_car_rsp(err, car_id, one_car_applique_data)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local LogicVehicleDIY = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicVehicleDIY)
  if not one_car_applique_data then
    log(bWriteLog and "VehicleDIYHandler.on_get_car_applique_data_by_car_rsp not data")
    LogicVehicleDIY:UpdateAppliqueData(car_id, nil, nil)
  else
    LogicVehicleDIY:UpdateAppliqueData(one_car_applique_data.version, one_car_applique_data.appliques)
  end
end
function VehicleDIYHandler.send_depot_exchange_req(pattern_id, pattern_count, cost_list)
  NetManager.SendPkg(477476231, pattern_id, pattern_count, cost_list)
end
function VehicleDIYHandler.on_depot_exchange_rsp(err_code, pattern_id, pattern_count)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicVehicleDecalExchange = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleDecalExchange)
  LogicVehicleDecalExchange:OnDepotExchangeRsp(pattern_id, pattern_count)
end
return VehicleDIYHandler