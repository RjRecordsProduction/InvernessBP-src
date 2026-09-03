local VehiclePlateLicenseUtil = {
  ENUM_VehicleFeatureType = {
    VOICE = 1,
    CONTAINER = 2,
    DIEDBOX = 3,
    HIGHSHOW = 4,
    LICENSEPALTE = 5,
    COMBINATION = 6,
    ALIAS = 7,
    TIRE = 8,
    Garage = 9
  },
  ENUM_Vehicle_UITYPE = {COLLECT = 1, REFIT = 2},
  UpgradeVehicleEffectMap = nil,
  VehicleChassisLightItemMap = nil,
  SwitchEffectCSVList = {
    "/Game/CSV/SportsCarMatMappingCfg.SportsCarMatMappingCfg",
    "/Game/CSV/SportsCarBaseMatCfg.SportsCarBaseMatCfg"
  },
  SpecialGlassMatBaseName = "Master_Glass_HQ_Car",
  ShadingModeToGlassDissolveCfg = {
    [1] = "/Game/Arts/Common/MasterMaterials/Vehicle/CarDissolve/Master_Glass_HQ_Car_CarDissolve_DefaultLit.Master_Glass_HQ_Car_CarDissolve_DefaultLit"
  }
}
function VehiclePlateLicenseUtil.GetPlateStaticMeshPath(ItemID)
  local SportsCarCollectConfig = CDataTable.GetTableData("CollectCarPlateCfg", ItemID)
  if not SportsCarCollectConfig then
    return
  end
  return SportsCarCollectConfig.LicensePlatePath
end
function VehiclePlateLicenseUtil.GetPlateLocation(ItemID)
  local SportsCarCollectConfig = CDataTable.GetTableData("CollectCarPlateCfg", ItemID)
  if not SportsCarCollectConfig then
    print(bWriteLog and "VehiclePlateLicenseUtil.GetPlateOffset not SportsCarCollectConfig" .. tostring(ItemID))
    return FVector(0, 0, 0)
  end
  local Location = SportsCarCollectConfig.Location_af
  if not Location or Location:Num() ~= 3 then
    print(bWriteLog and "VehiclePlateLicenseUtil.GetPlateLocation Location is Error" .. tostring(ItemID))
    return FVector(0, 0, 0)
  end
  local X = Location:Get(0)
  local Y = Location:Get(1)
  local Z = Location:Get(2)
  return FVector(X, Y, Z)
end
function VehiclePlateLicenseUtil.GetPlateRotation(ItemID)
  local SportsCarCollectConfig = CDataTable.GetTableData("CollectCarPlateCfg", ItemID)
  if not SportsCarCollectConfig then
    print(bWriteLog and "VehiclePlateLicenseUtil.GetPlateOffset not SportsCarCollectConfig" .. tostring(ItemID))
    return FRotator(0, 0, 0)
  end
  local Rotation = SportsCarCollectConfig.Rotation_af
  if not Rotation or Rotation:Num() ~= 3 then
    print(bWriteLog and "VehiclePlateLicenseUtil.GetPlateRotation Rotation is Error" .. tostring(ItemID))
    return FRotator(0, 0, 0)
  end
  local Roll = Rotation:Get(0)
  local Pitch = Rotation:Get(1)
  local Yaw = Rotation:Get(2)
  return FRotator(Pitch, Yaw, Roll)
end
function VehiclePlateLicenseUtil.GetPlateScale(ItemID)
  local SportsCarCollectConfig = CDataTable.GetTableData("CollectCarPlateCfg", ItemID)
  if not SportsCarCollectConfig then
    print(bWriteLog and "VehiclePlateLicenseUtil.GetPlateScale not SportsCarCollectConfig" .. tostring(ItemID))
    return FVector(1, 1, 1)
  end
  local Scale = SportsCarCollectConfig.Scale_af
  if not Scale or Scale:Num() ~= 3 then
    print(bWriteLog and "VehiclePlateLicenseUtil.GetPlateScale Scale is Error" .. tostring(ItemID))
    return FVector(1, 1, 1)
  end
  local X = Scale:Get(0)
  local Y = Scale:Get(1)
  local Z = Scale:Get(2)
  return FVector(X, Y, Z)
end
function VehiclePlateLicenseUtil.CanChangeLicenseMesh(ItemID)
  local SportsCarCollectConfig = CDataTable.GetTableData("CollectCarPlateCfg", ItemID)
  if not SportsCarCollectConfig then
    return false
  end
  return true
end
function VehiclePlateLicenseUtil.GetVehicleType(ItemID)
  local CollectCarInfo = CDataTable.GetTableData("CollectCarInfo", ItemID)
  if not CollectCarInfo then
    return -1
  end
  return CollectCarInfo.Type
end
function VehiclePlateLicenseUtil.GetPlateMaterialPath(ItemID)
  local SportsCarCollectConfig = CDataTable.GetTableData("CollectCarPlateCfg", ItemID)
  if not SportsCarCollectConfig then
    return
  end
  return SportsCarCollectConfig.MaterialPath
end
function VehiclePlateLicenseUtil.GetPlateTable(String)
  String = String or ""
  local PlateTable = {}
  local ZeroByte = string.byte("0", 1)
  local NineByte = string.byte("9", 1)
  local AByte = string.byte("A", 1)
  local ZByte = string.byte("Z", 1)
  local Length = string.len(String)
  for i = 1, 6 do
    local num = 0
    if i <= Length then
      local byte = string.byte(String, i)
      if NineByte >= byte and ZeroByte <= byte then
        num = byte - ZeroByte
      elseif ZByte >= byte and AByte <= byte then
        num = byte - AByte + 10
      end
    else
      num = -1
    end
    table.insert(PlateTable, num)
  end
  log_tree("VehiclePlateLicenseUtil GetPlateTable", PlateTable)
  return PlateTable
end
function VehiclePlateLicenseUtil.GetDiedBoxID(PlayerUID, ItemID)
  local CollectCarKillBoxCfg = CDataTable.GetTableData("CollectCarKillBox", ItemID)
  if not CollectCarKillBoxCfg then
    return -1
  end
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local FeatureType = VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.DIEDBOX
  local VehicleType = VehiclePlateLicenseUtil.GetVehicleType(ItemID)
  local VehicleCollectTable = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(PlayerUID), ExtendAttribute.VehicleCollect)
  if not VehicleCollectTable or not VehicleCollectTable[VehicleType] then
    return -1
  end
  local unlock_data = VehicleCollectTable[VehicleType].unlock_data
  if unlock_data and unlock_data[FeatureType] and unlock_data[FeatureType][ItemID] then
    return CollectCarKillBoxCfg.DiedBoxBattleID
  end
  if not VehiclePlateLicenseUtil.CheckHasUnLockFeature(VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.DIEDBOX, PlayerUID, ItemID) then
    return -1
  end
  if not VehiclePlateLicenseUtil.OwnVehicleAvatar(PlayerUID, ItemID) then
    return -1
  end
  return CollectCarKillBoxCfg.DiedBoxBattleID
end
function VehiclePlateLicenseUtil.OwnVehicleAvatar(PlayerUID, VehicleID)
  print(bWriteLog and "VehiclePlateLicenseUtil OwnVehicleAvatar PlayerUID:" .. tostring(PlayerUID) .. " VehicleID:" .. tostring(VehicleID))
  local VehicleType = VehiclePlateLicenseUtil.GetVehicleType(VehicleID)
  if VehicleType < 1 then
    return false
  end
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local VehicleCollectTable = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(PlayerUID), ExtendAttribute.VehicleCollect)
  if not VehicleCollectTable or not VehicleCollectTable[VehicleType] then
    return false
  end
  log_tree("VehiclePlateLicenseUtil VehicleCollectTable", VehicleCollectTable)
  local collect_list = VehicleCollectTable[VehicleType].collect_list
  if not collect_list then
    return false
  end
  for _, _VehicleID in pairs(collect_list) do
    if tonumber(_VehicleID) == tonumber(VehicleID) then
      return true
    end
  end
  return false
end
function VehiclePlateLicenseUtil.IsVehicleDiedBox(DiedBoxID)
  local CollectCarKillBoxCfg = CDataTable.GetTable("CollectCarKillBox")
  for _, value in pairs(CollectCarKillBoxCfg) do
    if value.DiedBoxBattleID == DiedBoxID then
      return true
    end
  end
  return false
end
function VehiclePlateLicenseUtil.GetVehicleDiedBoxHandlePath(DiedBoxID)
  local model_util = require("client.common.model_util")
  local BPID = model_util.GetBPID(DiedBoxID)
  if not BPID then
    print(bWriteLog and "VehiclePlateLicenseUtil.GetVehicleDiedBoxHandlePath DiedBoxID" .. tostring(DiedBoxID))
    return ""
  end
  local UAELoadedClassManager = import("UAELoadedClassManager").Get()
  local HandlePath = UAELoadedClassManager:GetPath("Avatar", BPID, false, false)
  return HandlePath
end
function VehiclePlateLicenseUtil.GetContainerAvatarID(PlayerUID, ItemID)
  local FeatureID = -1
  if VehiclePlateLicenseUtil.CheckHasUnLockFeature(VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.HIGHSHOW, PlayerUID, ItemID) then
    FeatureID = VehiclePlateLicenseUtil.GetFeatureID(VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.HIGHSHOW, ItemID)
  elseif VehiclePlateLicenseUtil.CheckHasUnLockFeature(VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.CONTAINER, PlayerUID, ItemID) then
    FeatureID = VehiclePlateLicenseUtil.GetFeatureID(VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.CONTAINER, ItemID)
  end
  if FeatureID < 0 then
    return -1
  end
  local CollectCarFeatureCfg = CDataTable.GetTableData("CollectCarFeatureCfg", FeatureID)
  if not CollectCarFeatureCfg then
    return -1
  end
  return CollectCarFeatureCfg.ContainerAvatarID
end
function VehiclePlateLicenseUtil.ContainerCanInteractive(ContainerAvatarID)
  local CollectCarFeatureTable = CDataTable.GetTable("CollectCarFeatureCfg")
  for key, value in pairs(CollectCarFeatureTable) do
    if value.ContainerAvatarID == ContainerAvatarID then
      return value.FeatureType == VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.HIGHSHOW
    end
  end
  return false
end
function VehiclePlateLicenseUtil.ContainerCanShowName(ContainerAvatarID)
  local CollectCarFeatureTable = CDataTable.GetTable("CollectCarFeatureCfg")
  for key, value in pairs(CollectCarFeatureTable) do
    if value.ContainerAvatarID == ContainerAvatarID then
      return value.FeatureType == VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.HIGHSHOW
    end
  end
  return false
end
function VehiclePlateLicenseUtil.CheckHasUnLockFeature(FeatureType, PlayerUID, ItemID)
  local VehicleNum = VehiclePlateLicenseUtil.GetOwnVehicleNum(PlayerUID, ItemID)
  if VehicleNum < 1 then
    return false
  end
  local VehicleType = VehiclePlateLicenseUtil.GetVehicleType(ItemID)
  local UnlockNum = VehiclePlateLicenseUtil.GetUnlockNum(VehicleType, FeatureType)
  if VehicleNum >= UnlockNum then
    return true
  end
  return false
end
function VehiclePlateLicenseUtil.GetOwnVehicleNum(PlayerUID, VehicleID)
  print(bWriteLog and "VehiclePlateLicenseUtil GetOwnVehicleNum PlayerUID:" .. tostring(PlayerUID) .. " VehicleID:" .. tostring(VehicleID))
  local VehicleType = VehiclePlateLicenseUtil.GetVehicleType(VehicleID)
  if VehicleType < 1 then
    return -1
  end
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local VehicleCollectTable = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(PlayerUID), ExtendAttribute.VehicleCollect)
  if not VehicleCollectTable or not VehicleCollectTable[VehicleType] then
    return -1
  end
  log_tree("VehiclePlateLicenseUtil VehicleCollectTable", VehicleCollectTable)
  local VehicleNum = VehicleCollectTable[VehicleType].collect_num
  return VehicleNum
end
function VehiclePlateLicenseUtil.GetUnlockNum(VehicleType, FeatureType)
  local CollectCarCfg = VehiclePlateLicenseUtil.GetCollectCarCfgByType(VehicleType)
  for key, Cfg in pairs(CollectCarCfg) do
    if Cfg.FeatureType == FeatureType then
      return Cfg.UnlockNum
    elseif Cfg.FeatureType == VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.COMBINATION then
      local SubFeatureTypes = VehiclePlateLicenseUtil.GetSubFeatureTypes(Cfg.FeatureID)
      for _, SubFeatureType in pairs(SubFeatureTypes) do
        if SubFeatureType == FeatureType then
          return Cfg.UnlockNum
        end
      end
    end
  end
  return 999
end
function VehiclePlateLicenseUtil.GetFeatureUnlockNum(FeatureID)
  local CollectCarCfg = CDataTable.GetTable("CollectCarCfg")
  for _, value in pairs(CollectCarCfg) do
    if value.FeatureID == FeatureID then
      return value.UnlockNum
    end
    if value.FeatureType == VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.COMBINATION then
      local SubFeatureIDs = VehiclePlateLicenseUtil.GetSubFeatureIDs(value.FeatureID)
      for _, SubFeatureID in pairs(SubFeatureIDs) do
        if SubFeatureID == FeatureID then
          return value.UnlockNum
        end
      end
    end
  end
  return 999
end
function VehiclePlateLicenseUtil.GetCollectCarCfgByType(VehicleType)
  local CollectList = {}
  local CollectCarCfg = CDataTable.GetTable("CollectCarCfg")
  for _, value in pairs(CollectCarCfg) do
    if value.VehicleType == VehicleType then
      table.insert(CollectList, value)
    end
  end
  return CollectList
end
function VehiclePlateLicenseUtil.GetSubFeatureTypes(FeatureID)
  local CollectCarFeatureCfg = CDataTable.GetTableData("CollectCarFeatureCfg", FeatureID)
  if not CollectCarFeatureCfg then
    return {}
  end
  local FeatureTypes = {}
  for _, FeatureID in pairs(CollectCarFeatureCfg.FeatureIDArray_a) do
    local FeatureType = VehiclePlateLicenseUtil.GetFeatureType(FeatureID)
    table.insert(FeatureTypes, FeatureType)
  end
  return FeatureTypes
end
function VehiclePlateLicenseUtil.GetSubFeatureIDs(FeatureID)
  local CollectCarFeatureCfg = CDataTable.GetTableData("CollectCarFeatureCfg", FeatureID)
  if not CollectCarFeatureCfg then
    return {}
  end
  local SubFeatureIDs = {}
  for _, FeatureID in pairs(CollectCarFeatureCfg.FeatureIDArray_a) do
    table.insert(SubFeatureIDs, FeatureID)
  end
  return SubFeatureIDs
end
function VehiclePlateLicenseUtil.GetFeatureType(FeatureID)
  local CollectCarFeatureCfg = CDataTable.GetTableData("CollectCarFeatureCfg", FeatureID)
  if not CollectCarFeatureCfg then
    log(bWriteLog and "VehicleCollectSystem:GetFeatureType not CollectCarFeatureCfg FeatureID" .. tostring(FeatureID))
    return -1
  end
  return CollectCarFeatureCfg.FeatureType
end
function VehiclePlateLicenseUtil.GetFeatureID(FeatureType, VehicleID)
  local VehicleType = VehiclePlateLicenseUtil.GetVehicleType(VehicleID)
  if not VehicleType then
    return -1
  end
  local CollectCarCfg = CDataTable.GetTableByFilter("CollectCarCfg", "VehicleType", VehicleType)
  for _, value in pairs(CollectCarCfg) do
    if value.FeatureType == FeatureType then
      return value.FeatureID
    elseif value.FeatureType == VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.COMBINATION then
      local SubFeatureIDs = VehiclePlateLicenseUtil.GetSubFeatureIDs(value.FeatureID)
      for _, SubFeatureID in pairs(SubFeatureIDs) do
        local SubFeatureType = VehiclePlateLicenseUtil.GetFeatureType(SubFeatureID)
        if SubFeatureType and SubFeatureType == FeatureType then
          return SubFeatureID
        end
      end
    end
  end
  return -1
end
function VehiclePlateLicenseUtil.GetCollectCarFeatureCfg(VehicleID)
  local FeatureID = VehiclePlateLicenseUtil.GetFeatureID(VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.VOICE, VehicleID)
  if FeatureID < 0 then
    return
  end
  local CollectCarFeatureCfg = CDataTable.GetTableData("CollectCarFeatureCfg", FeatureID)
  if not CollectCarFeatureCfg then
    return
  end
  return CollectCarFeatureCfg
end
function VehiclePlateLicenseUtil.GetItemName(ItemID)
  local ItemCofnig = CDataTable.GetTableData("Item", ItemID)
  if ItemCofnig then
    return ItemCofnig.ItemName
  end
  return ""
end
function VehiclePlateLicenseUtil.ConvertPlateNumToUVMap(LicenseNumArray)
  local Row = 6
  local Yaw = 6
  local NormalRowUV = 1 / Row
  local NormalYawUV = 1 / Yaw
  local   local UVMaps = {}
  for i = 0, 5 do
    local Num = LicenseNumArray:Get(i)
    if 0 <= Num then
      local RowIndex = Num % Row
      local YawIndex = math.floor(Num / Yaw)
      UVMaps[i * 4 + 2] = FVector2D(RowIndex * NormalRowUV, YawIndex * NormalYawUV)
      UVMaps[i * 4 + 0] = FVector2D(RowIndex * NormalRowUV, (YawIndex + 1) * NormalYawUV)
      UVMaps[i * 4 + 1] = FVector2D((RowIndex + 1) * NormalRowUV, YawIndex * NormalYawUV)
      UVMaps[i * 4 + 3] = FVector2D((RowIndex + 1) * NormalRowUV, (YawIndex + 1) * NormalYawUV)
    else
      UVMaps[i * 4 + 0] = FVector2D(0, 0)
      UVMaps[i * 4 + 1] = FVector2D(0, 0)
      UVMaps[i * 4 + 2] = FVector2D(0, 0)
      UVMaps[i * 4 + 3] = FVector2D(0, 0)
    end
  end
  return UVMaps
end
function VehiclePlateLicenseUtil.ConstructDefaultUVMap()
  local UVMaps = {}
  for i = 0, 5 do
    UVMaps[i * 4 + 0] = FVector2D(0, 0)
    UVMaps[i * 4 + 1] = FVector2D(0, 0)
    UVMaps[i * 4 + 2] = FVector2D(0, 0)
    UVMaps[i * 4 + 3] = FVector2D(0, 0)
  end
  return UVMaps
end
function VehiclePlateLicenseUtil.IsInInspectionMode()
  if not Client then
    return false
  end
  if not slua_GameFrontendHUD or not slua_GameFrontendHUD.GetPlayerController then
    return false
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) or not uPlayerController.HasAnySpectatorReplayFlag then
    return false
  end
  local ESpectatorReplayFlag = import("ESpectatorReplayFlag")
  return uPlayerController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_HawkEye | ESpectatorReplayFlag.ESpectatorReplayFlag_CompletePlayback)
end
function VehiclePlateLicenseUtil.NeedOpenHighTire(PlayerUID, VehicleID)
  print(bWriteLog and "VehiclePlateLicenseUtil.NeedOpenHighTire PlayerUID:" .. tostring(PlayerUID) .. " VehicleID:" .. tostring(VehicleID))
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local FeatureType = VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.TIRE
  local VehicleType = VehiclePlateLicenseUtil.GetVehicleType(VehicleID)
  local VehicleCollectTable = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(PlayerUID), ExtendAttribute.VehicleCollect)
  if not VehicleCollectTable or not VehicleCollectTable[VehicleType] then
    return false
  end
  local tire_switch = VehicleCollectTable[VehicleType].tire_switch
  if tire_switch and tire_switch == 1 then
    print(bWriteLog and "VehiclePlateLicenseUtil.NeedOpenHighTire tire_switch == 1")
    return false
  end
  local unlock_data = VehicleCollectTable[VehicleType].unlock_data
  if unlock_data and unlock_data[FeatureType] and unlock_data[FeatureType][VehicleID] then
    return true
  end
  if not VehiclePlateLicenseUtil.CheckHasUnLockFeature(VehiclePlateLicenseUtil.ENUM_VehicleFeatureType.TIRE, PlayerUID, VehicleID) then
    print(bWriteLog and "VehiclePlateLicenseUtil.NeedOpenHighTire LockFeature")
    return false
  end
  if not VehiclePlateLicenseUtil.OwnVehicleAvatar(PlayerUID, VehicleID) then
    print(bWriteLog and "VehiclePlateLicenseUtil.NeedOpenHighTire tire_switch not OwnVehicleAvatar")
    return false
  end
  return true
end
function VehiclePlateLicenseUtil.GetUpgradeVehicleMusicFeatureId()
  return 6701001
end
function VehiclePlateLicenseUtil.IsRefitOrUpgradeVehicle(car_id)
  if not car_id then
    return false
  end
  local cfgCar = CDataTable.GetTableData("VehicleRefitInfo", car_id)
  return cfgCar ~= nil
end
function VehiclePlateLicenseUtil.CheckUseUpgradeCarMusicList(uPlayerController, carId)
  if not carId then
    print(bWriteLog and "VehiclePlateLicenseUtil.CheckUseUpgradeCarMusicList carId is nil")
    return false
  end
  if not slua.isValid(uPlayerController) or not uPlayerController.CommerFeature then
    print(bWriteLog and "VehiclePlateLicenseUtil.CheckUseUpgradeCarMusicList uPlayerController is invalid")
    return false
  end
  if not uPlayerController.CommerFeature.bUpgradeCarUseMusicList then
    print(bWriteLog and "VehiclePlateLicenseUtil.CheckUseUpgradeCarMusicList bUpgradeCarUseMusicList is false")
    return false
  end
  local bUpgradeCar = VehiclePlateLicenseUtil.IsRefitOrUpgradeVehicle(carId)
  print(bWriteLog and "VehiclePlateLicenseUtil.CheckUseUpgradeCarMusicList bUpgradeCar:" .. tostring(bUpgradeCar))
  return bUpgradeCar
end
function VehiclePlateLicenseUtil.GetUpgradeEffectList(PlayerUID)
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local UpgradeVehicleData = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(PlayerUID), ExtendAttribute.UpgradeVehicleData)
  if not UpgradeVehicleData or not next(UpgradeVehicleData) then
    print(bWriteLog and "VehiclePlateLicenseUtil.GetUpgradeEffectList  not UpgradeVehicleData" .. tostring(PlayerUID))
    return
  end
  local EffectList = {}
  for _, ItemID in pairs(UpgradeVehicleData) do
    if VehiclePlateLicenseUtil.IsUpgradeVehicleEffect(ItemID) then
      table.insert(EffectList, ItemID)
    end
  end
  return EffectList
end
function VehiclePlateLicenseUtil.IsUpgradeVehicleEffect(ItemID)
  if VehiclePlateLicenseUtil.UpgradeVehicleEffectMap and VehiclePlateLicenseUtil.UpgradeVehicleEffectMap[ItemID] ~= nil then
    return VehiclePlateLicenseUtil.UpgradeVehicleEffectMap[ItemID]
  end
  VehiclePlateLicenseUtil.UpgradeVehicleEffectMap = VehiclePlateLicenseUtil.UpgradeVehicleEffectMap or {}
  local ItemCofnig = CDataTable.GetTableData("Item", ItemID)
  if ItemCofnig and ItemCofnig.ItemSubType == ENUM_ITEM_SUBTYPE.VehicleAirflow then
    VehiclePlateLicenseUtil.UpgradeVehicleEffectMap[ItemID] = true
    return true
  end
  VehiclePlateLicenseUtil.UpgradeVehicleEffectMap[ItemID] = false
  return false
end
function VehiclePlateLicenseUtil.IsChassisLightItem(ItemID)
  if not ItemID then
    print(bWriteLog and "VehiclePlateLicenseUtil.IsChassisLightItem ItemID is nil")
    return false
  end
  if VehiclePlateLicenseUtil.VehicleChassisLightItemMap and VehiclePlateLicenseUtil.VehicleChassisLightItemMap[ItemID] ~= nil then
    return VehiclePlateLicenseUtil.VehicleChassisLightItemMap[ItemID]
  end
  VehiclePlateLicenseUtil.VehicleChassisLightItemMap = VehiclePlateLicenseUtil.VehicleChassisLightItemMap or {}
  local ItemConfig = CDataTable.GetTableData("Item", ItemID)
  if ItemConfig and ItemConfig.ItemSubType == ENUM_ITEM_SUBTYPE.VehicleChassisLight then
    VehiclePlateLicenseUtil.VehicleChassisLightItemMap[ItemID] = true
    return true
  end
  VehiclePlateLicenseUtil.VehicleChassisLightItemMap[ItemID] = false
  return false
end
function VehiclePlateLicenseUtil.GetChassisLightLocAndScale(vehicleId, bIsLobbyVehicle)
  print(bWriteLog and "VehiclePlateLicenseUtil.GetChassisLightLocAndScale bIsLobbyVehicle:" .. tostring(bIsLobbyVehicle))
  if not vehicleId then
    print(bWriteLog and "VehiclePlateLicenseUtil.GetChassisLightLocAndScale vehicleId is nil")
    return nil, nil
  end
  local VehicleEffectCfg = CDataTable.GetTableData("BetterVehicleEffect", vehicleId)
  if not VehicleEffectCfg then
    print(bWriteLog and "VehiclePlateLicenseUtil.GetChassisLightLocAndScale VehicleEffectCfg is nil")
    return nil, nil
  end
  local LocX, LocY, LocZ = 0, -20, 10
  local ScaleX, ScaleY, ScaleZ = 6.5, 7, 1
  if not bIsLobbyVehicle and VehicleEffectCfg.ChassisLightLocInBattle_af and VehicleEffectCfg.ChassisLightLocInBattle_af:Num() >= 3 then
    LocX, LocY, LocZ = VehicleEffectCfg.ChassisLightLocInBattle_af:Get(0), VehicleEffectCfg.ChassisLightLocInBattle_af:Get(1), VehicleEffectCfg.ChassisLightLocInBattle_af:Get(2)
  elseif VehicleEffectCfg.ChassisLightLoc_af and 3 <= VehicleEffectCfg.ChassisLightLoc_af:Num() then
    LocX, LocY, LocZ = VehicleEffectCfg.ChassisLightLoc_af:Get(0), VehicleEffectCfg.ChassisLightLoc_af:Get(1), VehicleEffectCfg.ChassisLightLoc_af:Get(2)
  end
  if VehicleEffectCfg.ChassisLightScale_af and 3 <= VehicleEffectCfg.ChassisLightScale_af:Num() then
    ScaleX, ScaleY, ScaleZ = VehicleEffectCfg.ChassisLightScale_af:Get(0), VehicleEffectCfg.ChassisLightScale_af:Get(1), VehicleEffectCfg.ChassisLightScale_af:Get(2)
  end
  return FVector(LocX, LocY, LocZ), FVector(ScaleX, ScaleY, ScaleZ)
end
function VehiclePlateLicenseUtil.CheckIsBetterVehicle(vehicleId, bSupportDefaultCar)
  print(bWriteLog and "VehiclePlateLicenseUtil.CheckIsBetterVehicle vehicleId:" .. tostring(vehicleId))
  if not vehicleId then
    print(bWriteLog and "VehiclePlateLicenseUtil.CheckIsBetterVehicle vehicleId is nil")
    return false
  end
  local VehicleEffectCfg = CDataTable.GetTableData("BetterVehicleEffect", vehicleId)
  if not VehicleEffectCfg then
    print(bWriteLog and "VehiclePlateLicenseUtil.CheckIsBetterVehicle VehicleEffectCfg is nil")
    return false
  end
  if bSupportDefaultCar then
    print(bWriteLog and "VehiclePlateLicenseUtil.CheckIsBetterVehicle bSupportDefaultCar true")
    return true
  end
  local WardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local UIUtil = require("client.common.ui_util")
  local itemCfg = UIUtil.GetItemCfg(vehicleId)
  if not itemCfg or not itemCfg.ItemSubType then
    print(bWriteLog and "VehiclePlateLicenseUtil.CheckIsBetterVehicle itemCfg is nil")
    return false
  end
  if vehicleId ~= WardrobeMacro.DefaultVehiclesId[itemCfg.ItemSubType] then
    print(bWriteLog and "VehiclePlateLicenseUtil.CheckIsBetterVehicle true")
    return true
  end
  print(bWriteLog and "VehiclePlateLicenseUtil.CheckIsBetterVehicle false")
  return false
end
function VehiclePlateLicenseUtil.GetDefaultVehicleId(vehicleId)
  print(bWriteLog and "VehiclePlateLicenseUtil.GetDefaultVehicleId vehicleId:" .. tostring(vehicleId))
  if not vehicleId then
    print(bWriteLog and "VehiclePlateLicenseUtil.GetDefaultVehicleId vehicleId is nil")
    return false
  end
  local WardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  local UIUtil = require("client.common.ui_util")
  local itemCfg = UIUtil.GetItemCfg(vehicleId)
  if not itemCfg or not itemCfg.ItemSubType then
    print(bWriteLog and "VehiclePlateLicenseUtil.GetDefaultVehicleId itemCfg is nil")
    return false
  end
  return WardrobeMacro.DefaultVehiclesId[itemCfg.ItemSubType]
end
function VehiclePlateLicenseUtil.GetSportsCarBaseMatNameList(vehicleId)
  print(bWriteLog and "VehiclePlateLicenseUtil.GetSportsCarBaseMatNameList vehicleId:" .. tostring(vehicleId))
  if not vehicleId then
    print(bWriteLog and "VehiclePlateLicenseUtil.GetSportsCarBaseMatNameList vehicleId is nil")
    return nil
  end
  local SportsCarBaseMatCfg = CDataTable.GetTableData("SportsCarBaseMatCfg", vehicleId)
  if not SportsCarBaseMatCfg or not SportsCarBaseMatCfg.BaseMatNames_as then
    print(bWriteLog and "VehiclePlateLicenseUtil.GetSportsCarBaseMatNameList VehicleEffectCfg is nil")
    return nil
  end
  return SportsCarBaseMatCfg.BaseMatNames_as
end
function VehiclePlateLicenseUtil.GetSportsCarDissolveMatPathList(vehicleId, oldVehicleId)
  print(bWriteLog and "VehiclePlateLicenseUtil.GetSportsCarDissolveMatPathList vehicleId:" .. tostring(vehicleId) .. ", oldVehicleId:" .. tostring(oldVehicleId))
  local matPathList = {}
  local matPathMap = {}
  local bHasSpecialGlassMat = false
  local vehicleBaseMatNames = VehiclePlateLicenseUtil.GetSportsCarBaseMatNameList(vehicleId)
  if vehicleBaseMatNames and vehicleBaseMatNames:Num() > 0 then
    for i = 0, vehicleBaseMatNames:Num() - 1 do
      local matName = vehicleBaseMatNames:Get(i) or ""
      local dissolveMatCfg = CDataTable.GetTableData("SportsCarMatMappingCfg", matName)
      local dissolveMatPath = dissolveMatCfg and dissolveMatCfg.DissolveMatPath
      if dissolveMatPath and dissolveMatPath ~= "" then
        matPathMap[dissolveMatPath] = true
      end
      if matName == VehiclePlateLicenseUtil.SpecialGlassMatBaseName then
        bHasSpecialGlassMat = true
      end
    end
  end
  local oldVehicleBaseMatNames = VehiclePlateLicenseUtil.GetSportsCarBaseMatNameList(oldVehicleId)
  if oldVehicleBaseMatNames and oldVehicleBaseMatNames:Num() > 0 then
    for i = 0, oldVehicleBaseMatNames:Num() - 1 do
      local matName = oldVehicleBaseMatNames:Get(i) or ""
      local dissolveMatCfg = CDataTable.GetTableData("SportsCarMatMappingCfg", matName)
      local dissolveMatPath = dissolveMatCfg and dissolveMatCfg.DissolveMatPath
      if dissolveMatPath and dissolveMatPath ~= "" then
        matPathMap[dissolveMatPath] = true
      end
      if matName == VehiclePlateLicenseUtil.SpecialGlassMatBaseName then
        bHasSpecialGlassMat = true
      end
    end
  end
  if bHasSpecialGlassMat then
    for _, specialGlassMatPath in pairs(VehiclePlateLicenseUtil.ShadingModeToGlassDissolveCfg) do
      matPathMap[specialGlassMatPath] = true
    end
  end
  for matPath, _ in pairs(matPathMap) do
    table.insert(matPathList, matPath)
  end
  table.insert(matPathList, VehiclePlateLicenseUtil.GetSwitchEffectActorPath())
  log_tree(bWriteLog and "VehiclePlateLicenseUtil.GetSportsCarDissolveMatPathList matPathList:", matPathList)
  return matPathList
end
function VehiclePlateLicenseUtil.GetSwitchEffectActorPath()
  return "/Game/Arts_PlayerBluePrints/Vehicle/VehcleAccessory/BP_VehicleSwitchEffect_Dissolve.BP_VehicleSwitchEffect_Dissolve_C"
end
function VehiclePlateLicenseUtil.GetSwitchEffectNoiseTexturePath()
  return "/Game/Arts/Common/Textures/Tex_SportsCar20_int_06_Emiss.Tex_SportsCar20_int_06_Emiss"
end
function VehiclePlateLicenseUtil.GetOneVehicleResPaths(pathList, vehicleId)
  pathList = pathList or {}
  if not vehicleId then
    log(bWriteLog and "VehiclePlateLicenseUtil.GetOneVehicleResPaths vehicleId is nil")
    return pathList
  end
  local model_util = require("client.common.model_util")
  local BPID = model_util.GetBPID(vehicleId)
  local BPHandleClass = model_util.GetClass("Vehicle", BPID, true, false)
  if not BPHandleClass then
    log(bWriteLog and " VehiclePlateLicenseUtil.GetOneVehicleResPaths BPHandleClass is nil BPID", BPID)
    return
  end
  local BPHandle = BPHandleClass()
  local meshPath = BPHandle.ItemSkletalMesh and BPHandle.ItemSkletalMesh:ToString()
  if meshPath and meshPath ~= "" then
    table.insert(pathList, meshPath)
  end
  if BPHandle.ItemAvatarMats and BPHandle.ItemAvatarMats:Num() > 0 then
    for i = 0, BPHandle.ItemAvatarMats:Num() - 1 do
      local matdata = BPHandle.ItemAvatarMats:Get(i)
      if matdata and matdata.MatInstance and matdata.MatInstance:ToString() ~= "" then
        table.insert(pathList, matdata.MatInstance:ToString())
      end
    end
  end
  log_tree(bWriteLog and "VehiclePlateLicenseUtil.GetOneVehicleResPaths pathList:", pathList)
  return pathList
end
function VehiclePlateLicenseUtil.GetVehicleEffectCSVPaths()
  return VehiclePlateLicenseUtil.SwitchEffectCSVList
end
function VehiclePlateLicenseUtil.CheckIsCabrioLetVehicle(itemID)
  if not itemID then
    return false
  end
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if itemCfg and ModelDisplayTypeHelper.IsCabrioletCar(itemCfg.ItemSubType) then
    return true
  end
  return false
end
return VehiclePlateLicenseUtil