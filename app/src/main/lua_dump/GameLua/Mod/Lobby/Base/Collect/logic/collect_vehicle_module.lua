local C_Upgrade_Vehicle_Tab_ID = 46631001
local C_Sports_Car_Tab_ID = 46631000
local collect_vehicle_module = {}
function collect_vehicle_module:DefineAndResetData()
  self.car2SubCar = {}
  self.VehiclesCfg = {}
end
function collect_vehicle_module:GetListOfAvailableRewards()
  local result, seriesID = {}
  local configs = self:GetVehiclesCfg()
  local collect_encryption_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_encryption_module)
  local collect_library_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_library_module)
  for serID, data in pairs(configs) do
    if not self:CheckEncryptionSeries(serID) then
      local score = self:GetCollectVehicleScoreByBrandID(serID)
      for level, cfg in pairs(configs[serID] or {}) do
        for i = 1, 2 do
          if cfg["Drop" .. i] ~= 0 and cfg["CostNum" .. i] == 0 and not collect_encryption_module:IsEncryption(cfg["Drop" .. i]) then
            local status = collect_library_module:GetSeriesAwardStatus(serID, level, i, score, cfg.MinScore, 5)
            if status == ActivityProgressStatus.Done then
              seriesID = seriesID or serID
              table.insert(result, {
                itemId = cfg["Drop" .. i],
                num = cfg["Num" .. i],
                time = cfg["Time" .. i],
                idx = cfg.Level,
                subIdx = i
              })
            end
          end
        end
      end
    end
  end
  return result, seriesID
end
function collect_vehicle_module:HasRed()
  local configs = self:GetVehiclesCfg()
  for serID, data in pairs(configs) do
    if self:CheckOneVehicleAwarded(serID) then
      return true
    end
  end
  return false
end
function collect_vehicle_module:CheckEncryptionSeries(serID)
  local collect_encryption_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_encryption_module)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if serID == C_Upgrade_Vehicle_Tab_ID or serID == C_Sports_Car_Tab_ID then
    return false
  end
  local config = collect_module:GetSplitTableData("CollectVehicleSubTheme", collect_module.E_ColCfgMode.JK, serID)
  if config and not collect_encryption_module:IsEncryptionSeries(config.Version, config.Time) then
    return false
  end
  return true
end
function collect_vehicle_module:CheckOneVehicleAwarded(serID)
  local configs = self:GetVehiclesCfg()
  local collect_encryption_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_encryption_module)
  local collect_library_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_library_module)
  if not self:CheckEncryptionSeries(serID) then
    local score = self:GetCollectVehicleScoreByBrandID(serID)
    for level, cfg in pairs(configs[serID] or {}) do
      for i = 1, 2 do
        if cfg["Drop" .. i] ~= 0 and cfg["CostNum" .. i] == 0 and not collect_encryption_module:IsEncryption(cfg["Drop" .. i]) then
          local status = collect_library_module:GetSeriesAwardStatus(serID, level, i, score, cfg.MinScore, 5)
          if status == ActivityProgressStatus.Done then
            return true
          end
        end
      end
    end
  end
  return false
end
function collect_vehicle_module:GetAllCarBoxData()
  local car2SubCar = self.car2SubCar
  local subTb = {}
  for id, subType in pairs(car2SubCar) do
    local cars = subTb[subType]
    if not cars then
      cars = prealloctable(2, 0)
      subTb[subType] = cars
    end
    cars[#cars + 1] = id
  end
  local CategoryTb = {}
  local defaultWingmanSkinResID = DataMgr.defaultWingmanSkinResID
  local allCar = {}
  for _, v in pairs(CDataTable.GetTable("WardrobeVehiclesTaxonomy")) do
    local VehicleDefualtSkinID = v.VehicleDefualtSkinID
    if VehicleDefualtSkinID ~= defaultWingmanSkinResID then
      local subType = v.ItemSubType
      local carList = {}
      local _subList = subTb[subType]
      if _subList and next(_subList) then
        local oneCar = {
          subList = _subList,
          subId = subType,
          default = VehicleDefualtSkinID
        }
        local CategoryID = v.CategoryID
        if not CategoryTb[CategoryID] then
          CategoryTb[CategoryID] = 1
          carList[#carList + 1] = oneCar
          allCar[#allCar + 1] = {
            id = CategoryID,
            List = carList,
            text = LocUtil.GetLocalizeResStr(v.VehicleCategory)
          }
        else
          for _, carT in ipairs(allCar) do
            if carT.id == CategoryID then
              carT.List[#carT.List + 1] = oneCar
            end
          end
        end
      end
    end
  end
  return allCar
end
function collect_vehicle_module:SetCarSubType(itemTb)
  local VehicleType = ENUM_ITEM_TYPE.Vehicle
  self.car2SubCar = {}
  local car2SubCar = self.car2SubCar
  for itemId, _ in pairs(itemTb) do
    local itemData = CDataTable.GetTableData("Item", itemId)
    if itemData and itemData.ItemType == VehicleType then
      car2SubCar[itemId] = itemData.ItemSubType
    end
  end
end
function collect_vehicle_module:GetCarSubType()
  return self.car2SubCar or {}
end
function collect_vehicle_module:GetVehiclesCfg()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not next(self.VehiclesCfg) then
    for id, cfg in pairs(collect_module:GetSplitTable("CollectVehicleSeriesAward", collect_module.E_ColCfgMode.JK)) do
      local level = cfg.Level
      if 0 <= level then
        local serID = cfg.SeriesID
        if not self.VehiclesCfg[serID] then
          self.VehiclesCfg[serID] = {}
        end
        self.VehiclesCfg[serID][level] = cfg
      end
    end
  end
  return self.VehiclesCfg
end
function collect_vehicle_module:GetCollectVehicleScoreByBrandID(brandID)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if brandID and collect_module.collect_data then
    local scoreMap = collect_module.collect_data.vehicle_sys_score or {}
    return scoreMap[brandID] or 0
  end
  return 0
end
function collect_vehicle_module:GetCollectVehicleScore()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if collect_module.collect_data then
    return collect_module.collect_data.vehicle_score or 0
  end
  return 0
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_vehicle_module)
return CModuleTemplate