local BP_Lobby_VehicleLicenseComponent = {}
local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
function BP_Lobby_VehicleLicenseComponent:ctor()
  self.PreviewAccessoryItemId = nil
  self.bIsLobbyLicense = true
  self.TextChassisLightActor = nil
end
function BP_Lobby_VehicleLicenseComponent:ReceiveEndPlay(EndReason, bClearTable)
  if self.TextChassisLightActor then
    self.TextChassisLightActor:K2_DestroyActor()
    self.TextChassisLightActor = nil
  end
  BP_Lobby_VehicleLicenseComponent.__super.ReceiveEndPlay(self, EndReason, bClearTable)
end
function BP_Lobby_VehicleLicenseComponent:CreatPlate(ItemID, PlateString, LicenseBgId, bEditingLicense)
  log(bWriteLog and "[LicensePlate] CreatPlate ItemID" .. tostring(ItemID) .. " PlateString:" .. tostring(PlateString))
  if not VehiclePlateLicenseUtil.CanChangeLicenseMesh(ItemID) then
    log(bWriteLog and "[LicensePlate] BP_Lobby_VehicleLicenseComponent not CanChangeLicenseMesh ItemID" .. tostring(ItemID))
    self:DestroyPlateMesh()
    return
  end
  self:ChangeNetData_ItemID(ItemID)
  local PlateTable = VehiclePlateLicenseUtil.GetPlateTable(PlateString)
  for LuaIndex, Num in pairs(PlateTable) do
    self:ChangeLicenseNum(LuaIndex - 1, Num)
  end
  local LogicVehicleExtendedFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleExtendedFeature)
  local DefaultPlateBgId = LogicVehicleExtendedFeature:GetDefaultPlateBgId()
  if DefaultPlateBgId == LicenseBgId then
    LicenseBgId = nil
  end
  self.LicensePlate.LicenseBackgroundId = LicenseBgId or 0
  self.bEditingLicense = bEditingLicense or false
  self:OnRep_LicensePlate()
  self.bEditingLicense = false
end
function BP_Lobby_VehicleLicenseComponent:CheckHasVehicleDownloaded(ItemID)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local dowloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {ItemID})
  return dowloadState == PufferConst.ENUM_DownloadState.Done
end
function BP_Lobby_VehicleLicenseComponent:SetAccessoryItemList(vehicleId, accItemList)
  if not vehicleId then
    log(bWriteLog and "BP_Lobby_VehicleLicenseComponent:SetPreviewAccessoryItem invalid vehicleId")
    self:DestroyAllAccessoryItem()
    return
  end
  accItemList = accItemList or {}
  local accItemIds = {}
  for accItem, _ in pairs(accItemList) do
    table.insert(accItemIds, accItem)
  end
  log_tree("BP_Lobby_VehicleLicenseComponent:SetAccessoryItemList accItemIds", accItemIds)
  self.PreviewAccessoryItemId = nil
  self:ChangeNetData_ItemID(vehicleId)
  self:ChangeAccessoryItemListWrapper(accItemIds)
  self:OnRep_LicensePlate()
end
function BP_Lobby_VehicleLicenseComponent:SetPreviewAccessoryItem(vehicleId, accItemId)
  if not vehicleId then
    log(bWriteLog and "BP_Lobby_VehicleLicenseComponent:SetPreviewAccessoryItem invalid vehicleId")
    self:DestroyAllAccessoryItem()
    return
  end
  self.curVehicleAvatarId = vehicleId
  local LogicVehicleAccessory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleAccessory)
  local equipList = LogicVehicleAccessory:GetEquipedAccessoryList(vehicleId) or {}
  local equipArray = {}
  for accId, _ in pairs(equipList) do
    table.insert(equipArray, accId)
  end
  if accItemId then
    table.insert(equipArray, accItemId)
  end
  self.PreviewAccessoryItemId = accItemId
  self:ChangeNetData_ItemID(vehicleId)
  self:ChangeAccessoryItemListWrapper(equipArray)
  self:OnRep_LicensePlate()
end
function BP_Lobby_VehicleLicenseComponent:SetChassisLightData(vehicleId, chassisLightId)
  vehicleId = vehicleId or -1
  self:DestoryChassisLight()
  if not self.LicensePlate.ChassisLightId then
    return
  end
  self.LicensePlate.ChassisLightId = 0
  if type(chassisLightId) == "number" then
    self.LicensePlate.ChassisLightId = chassisLightId
  end
  if self:CheckAndShowGMChassisLight(vehicleId) then
    log(bWriteLog and "BP_Lobby_VehicleLicenseComponent:SetChassisLightData CheckAndShowGMChassisLight true")
    return
  end
  if not self:CheckHasVehicleDownloaded(vehicleId) then
    log(bWriteLog and "BP_Lobby_VehicleLicenseComponent:SetChassisLightData CheckHasVehicleDownloaded false")
    return
  end
  self:ChangeNetData_ItemID(vehicleId)
  self:PreChangeChassisLight()
end
function BP_Lobby_VehicleLicenseComponent:ChangeAccessoryItemListWrapper(accessoryItemIds)
  local vehicleId = self.LicensePlate.ItemID
  local bNeedProcessDefaultAccessory = false
  local defaultAccessoryCfg
  if vehicleId and 0 < vehicleId then
    defaultAccessoryCfg = CDataTable.GetTableDataByFilter("VehicleAccessoryUnlockConfig", "VehicleId", vehicleId, "bDefaultAccessory", true)
  end
  if not defaultAccessoryCfg then
    self:ChangeAccessoryItemList(accessoryItemIds)
    return
  end
  if defaultAccessoryCfg then
    local accItemId = defaultAccessoryCfg.AccItemId
    local mutexAccessoryId = defaultAccessoryCfg.MutexAccessoryID
    if accItemId ~= 0 and mutexAccessoryId ~= 0 then
      if not accessoryItemIds then
        accessoryItemIds = {accItemId}
      else
        local bFindMutexAccessory = false
        for _, itemId in pairs(accessoryItemIds) do
          if itemId == mutexAccessoryId then
            bFindMutexAccessory = true
            break
          end
        end
        if not bFindMutexAccessory then
          log(bWriteLog and "BP_Lobby_VehicleLicenseComponent:ChangeAccessoryItemListWrapper add default accessory itemId:" .. tostring(accItemId))
          table.insert(accessoryItemIds, accItemId)
        end
      end
    end
  end
  log_tree("BP_Lobby_VehicleLicenseComponent:ChangeAccessoryItemListWrapper accessoryItemIds", accessoryItemIds)
  self:ChangeAccessoryItemList(accessoryItemIds)
end
function BP_Lobby_VehicleLicenseComponent:CheckAndShowGMChassisLight(vehicleId)
  if not IsEditor then
    return false
  end
  local LogicVehicleExtendedFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleExtendedFeature)
  if not LogicVehicleExtendedFeature.IsInGMChassisLightMTest then
    return false
  end
  local BP_TestChassisLightClass = import("/Game/Delete/lizzhi/Test_ChassisLight_Actor.Test_ChassisLight_Actor_C")
  local world = slua_GameFrontendHUD:GetWorld()
  if not BP_TestChassisLightClass then
    return false
  end
  if not self.TextChassisLightActor then
    self.TextChassisLightActor = world:SpawnActor(BP_TestChassisLightClass, nil, nil, nil)
    self.TextChassisLightActor:K2_AttachToActor(self:GetOwner(), "None", 1, 1, 1, false)
  end
  local LocVec, ScaleVec = VehiclePlateLicenseUtil.GetChassisLightLocAndScale(vehicleId)
  self.TextChassisLightActor:K2_SetActorRelativeLocation(LocVec, false, nil, false)
  self.TextChassisLightActor:K2_SetActorRelativeRotation(FRotator(0, 0, 0), false, nil, false)
  self.TextChassisLightActor:SetActorRelativeScale3D(ScaleVec)
  self:DestoryChassisLight()
  return true
end
function BP_Lobby_VehicleLicenseComponent:GetAttachName(ItemID)
  local SkeletalMeshComponent = self:GetAttachComponent()
  if not slua.isValid(SkeletalMeshComponent) then
    print(bWriteLog and "[LicensePlate] BP_Lobby_VehicleLicenseComponent:GetAttachName SkeletalMeshComponent is nil rootJNT ItemID:" .. tostring(ItemID))
    return "rootJNT"
  end
  local RootSocketName = SkeletalMeshComponent:GetBoneName(0)
  print(bWriteLog and "[LicensePlate] BP_Lobby_VehicleLicenseComponent:GetAttachName RootSocketName:" .. tostring(RootSocketName) .. " ItemID:" .. tostring(ItemID))
  return RootSocketName
end
local class = require("class")
local BP_VehicleLicenseComponentBase = require("GameLua.Activity.Commercialize.Actor.ActorComponent.BP_VehicleLicenseComponentBase")
local CBP_Lobby_VehicleLicenseComponent = class(BP_VehicleLicenseComponentBase, nil, BP_Lobby_VehicleLicenseComponent)
return CBP_Lobby_VehicleLicenseComponent