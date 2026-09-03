local VehicleAccessoryDataUtil = {
  CachedVehicleAccessoryData = {}
}
function VehicleAccessoryDataUtil:GeneratePlayerVehicleAccessoryData(PlayerInfo, uPlayerController)
  if not uPlayerController then
    return
  end
  local UID = tonumber(uPlayerController.UID)
  if not UID then
    return
  end
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local VehicleAccessoryData = ServerPlayerDataMgr.GetPlayerProgressFromServer(UID, ExtendAttribute.VehicleAccessoryData)
  if not VehicleAccessoryData then
    return
  end
  local defaultAccessoryCfgList = CDataTable.GetTableByFilter("VehicleAccessoryUnlockConfig", "bDefaultAccessory", true)
  if not defaultAccessoryCfgList then
    self.CachedVehicleAccessoryData[uPlayerController.UID] = VehicleAccessoryData
    return
  end
  for _, accessoryCfg in pairs(defaultAccessoryCfgList) do
    if accessoryCfg then
      local vehicleId = accessoryCfg.VehicleId
      local accItemId = accessoryCfg.AccItemId
      local mutexAccessoryId = accessoryCfg.MutexAccessoryID
      if vehicleId ~= 0 and accItemId ~= 0 and mutexAccessoryId ~= 0 then
        if not VehicleAccessoryData[vehicleId] then
          VehicleAccessoryData[vehicleId] = {
            [accItemId] = 1
          }
        elseif not VehicleAccessoryData[vehicleId][mutexAccessoryId] then
          VehicleAccessoryData[vehicleId][accItemId] = 1
        end
      end
    end
  end
  self.CachedVehicleAccessoryData[uPlayerController.UID] = VehicleAccessoryData
end
function VehicleAccessoryDataUtil:GetPlayerVehicleAccessoryData(UID)
  if not UID then
    return nil
  end
  return self.CachedVehicleAccessoryData[UID]
end
return VehicleAccessoryDataUtil