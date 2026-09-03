local CareerSystemVehicle = {}
local CareerSystem = require("client.slua.logic.career.logic_career")
local ConstCareer = require("client.slua.logic.career.const_career")
local E_VehicleType = ConstCareer.E_VehicleType
local E_CareerModule = ConstCareer.E_CareerModule
local nModuleId = E_CareerModule.Vehicle
local vehicleCategoryData, _tVehicleShowList
function CareerSystemVehicle.GetVehicleShowList()
  if not _tVehicleShowList then
    local tTempData = CareerSystem.GetConfig(CareerSystem.C_ServerConfigs.Vehicle)
    if not tTempData then
      return
    end
    _tVehicleShowList = {}
    for k, v in pairs(tTempData) do
      if v.is_show == 1 then
        _tVehicleShowList[k] = 1
      end
    end
  end
  return _tVehicleShowList
end
function CareerSystemVehicle.GetVehicleProData(vehicleId)
  local vehicleData = CareerSystem.GetModuleData(E_CareerModule.Vehicle)
  if vehicleData[vehicleId] then
    return vehicleData[vehicleId].pro or 0
  end
  return 0
end
function CareerSystemVehicle.GetVehicleMedal(nVehicleId)
  local tAllWeaponData = CareerSystem.GetModuleData(E_CareerModule.Vehicle)
  if tAllWeaponData[nVehicleId] then
    return tAllWeaponData[nVehicleId].medal or 0
  end
  return 0
end
function CareerSystemVehicle.GetVehicleDistanceData(vehicleId, seasonOnly)
  local vehicleModuleHttpData = CareerSystem.GetModuleDetailedData(nModuleId, seasonOnly == 1)
  local vehicleHttpData = vehicleModuleHttpData and vehicleModuleHttpData[vehicleId] or {}
  return vehicleHttpData.distance or 0
end
function CareerSystemVehicle.GetVehicleShowData(vehicleTypeId)
  local nShowUserId = CareerSystem.GetShowUserId()
  if not nShowUserId then
    return
  end
  local bIsSeason = CareerSystem.GetIsSeason(E_CareerModule.Vehicle, vehicleTypeId)
  local tDetailedData = CareerSystem.GetModuleDetailedData(E_CareerModule.Vehicle, bIsSeason)
  if not tDetailedData then
    CareerSystem.ReqModuleInfo(E_CareerModule.Vehicle, vehicleTypeId, CareerSystem.GetShowUserId(), bIsSeason)
    return
  end
  local _, vehicleData = CareerSystem.GetModuleSubTypeAllItem(E_CareerModule.Vehicle, vehicleTypeId, bIsSeason)
  if vehicleData then
    return vehicleData
  end
  if not vehicleCategoryData then
    local vehicleAllData = {}
    vehicleCategoryData = {}
    local careerVehicleTbl = CareerSystemVehicle.GetVehicleShowList()
    if not careerVehicleTbl then
      return
    end
    local VehicleRawTable = CDataTable.GetTable("WardrobeVehiclesTaxonomy")
    local vehicleId, categoryId
    for _, v in pairs(VehicleRawTable) do
      vehicleId = v.VehicleDefualtSkinID
      categoryId = v.CategoryID
      if careerVehicleTbl[vehicleId] then
        table.insert(vehicleAllData, vehicleId)
        if not vehicleCategoryData[categoryId] then
          vehicleCategoryData[categoryId] = {}
        end
        table.insert(vehicleCategoryData[categoryId], vehicleId)
      end
    end
    vehicleCategoryData[E_VehicleType.All] = vehicleAllData
  end
  vehicleData = vehicleCategoryData[vehicleTypeId]
  local tModuleData = CareerSystem.GetModuleData(nModuleId)
  table.sort(vehicleData, function(lhs, rhs)
    local nLhsPro = tModuleData[lhs] and tModuleData[lhs].pro or 0
    local nRhsPro = tModuleData[rhs] and tModuleData[rhs].pro or 0
    return nLhsPro > nRhsPro
  end)
  CareerSystem.SetModuleSubTypeAllItem(nModuleId, vehicleTypeId, vehicleData, bIsSeason)
  return vehicleData
end
function CareerSystemVehicle.GetVehicleIcon(nVehicleId, nTabId)
  local sIcon = ""
  if nVehicleId then
    local UIUtil = require("client.common.ui_util")
    sIcon = UIUtil.GetItemBigIcon(nVehicleId)
  end
  if not CareerSystem.IsSelfCareer() then
    return sIcon
  end
  if nTabId then
    local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
    local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    local TabSurveillance = require("client.slua.logic.wardrobe.tab_surveillance")
    local equippedSkinInsID = TabSurveillance.GetEquipStates(nTabId)
    local skinItemList = {}
    local item = WardrobeDataManager:GetHallDepotItemDataByInsID(equippedSkinInsID)
    local depotItemList = WardrobeDataManager:GetArrayHallDepotItemInfo()
    if not item then
      return
    end
    local UIUtil = require("client.common.ui_util")
    for _, v in pairs(depotItemList) do
      local isUsing = item and item.insID == v.insID
      if v.insID == item.insID then
        local itemInfo = WardrobeLogicManager:ArrayHallDepotToCommonItem(v, #skinItemList, isUsing, false, false, false, false)
        sIcon = UIUtil.GetItemBigIcon(itemInfo.res_id)
      end
    end
  end
  return sIcon
end
return CareerSystemVehicle