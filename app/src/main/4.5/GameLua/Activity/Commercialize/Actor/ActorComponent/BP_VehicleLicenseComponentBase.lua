local BP_VehicleLicenseComponentBase = {}
local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local dotMatIndex = 1
local LightPlanePath = "/Engine/BasicShapes/Plane.Plane"
function BP_VehicleLicenseComponentBase:ctor()
  self.isParachuteState = false
  self.bIsLobbyLicense = false
  self.bEditingLicense = false
  self.curVehicleAvatarId = nil
  self.curVehicleHandle = nil
  self.HideOnScopeAccessorySet = nil
  self.ChassisLightMesh = nil
  self.ChassisLightTimer = nil
  self.lastSpeed = 0.0
end
function BP_VehicleLicenseComponentBase:ReceiveBeginPlay()
  BP_VehicleLicenseComponentBase.__super.ReceiveBeginPlay(self)
end
function BP_VehicleLicenseComponentBase:InitPlateMeshComp()
  local RuntimeMeshComponent = import("RuntimeMeshComponent")
  self.PlateMesh = Game:AddComponent(RuntimeMeshComponent, self:GetOwner(), "PlateMesh")
  if slua.isValid(self.PlateMesh) then
    local ECollisionEnabled = import("ECollisionEnabled")
    self.PlateMesh:SetCollisionEnabled(ECollisionEnabled.NoCollision)
  end
end
function BP_VehicleLicenseComponentBase:RefreshPlateMeshComponentTrans()
  print(bWriteLog and "BP_VehicleLicenseComponentBase RefreshPlateMeshComponentTrans ItemID" .. tostring(self.LicensePlate.ItemID))
  local EAttachmentRule = import("EAttachmentRule")
  self.PlateMesh:K2_AttachToComponent(self:GetAttachComponent(), self:GetAttachName(self.LicensePlate.ItemID), EAttachmentRule.SnapToTarget, EAttachmentRule.SnapToTarget, EAttachmentRule.SnapToTarget, true)
  local Location = VehiclePlateLicenseUtil.GetPlateLocation(self.LicensePlate.ItemID)
  local Rotation = VehiclePlateLicenseUtil.GetPlateRotation(self.LicensePlate.ItemID)
  local Scale = VehiclePlateLicenseUtil.GetPlateScale(self.LicensePlate.ItemID)
  self.PlateMesh:K2_SetRelativeLocation(Location, false, nil, true)
  self.PlateMesh:K2_SetRelativeRotation(Rotation, false, nil, true)
  self.PlateMesh:SetRelativeScale3D(Scale)
end
function BP_VehicleLicenseComponentBase:InitPlateMesh()
  local model_util = require("client.common.model_util")
  local PlateMeshPath = self:GetStaticMeshPath()
  local LoadObj = model_util.GetAssetObjByPath(PlateMeshPath)
  if not LoadObj then
    log_error("[LicensePlate] PlateStatic Mesh Is Null Path:" .. tostring(PlateMeshPath))
    return
  end
  local URuntimeMeshLibrary = import("RuntimeMeshLibrary")
  URuntimeMeshLibrary.CopyRuntimeMeshFromStaticMesh(LoadObj, 0, self.PlateMesh, false)
end
function BP_VehicleLicenseComponentBase:GetAttachComponent()
  return self:GetOwner().Mesh
end
function BP_VehicleLicenseComponentBase:GetAttachName(ItemID)
  return "None"
end
function BP_VehicleLicenseComponentBase:GetStaticMeshPath()
  local PlateMeshPath = VehiclePlateLicenseUtil.GetPlateStaticMeshPath(self.LicensePlate.ItemID)
  return PlateMeshPath
end
function BP_VehicleLicenseComponentBase:CheckHasVehicleDownloaded(ItemID)
  if not ItemID then
    log(bWriteLog and "BP_Battle_VehicleLicenseComponent:CheckHasVehicleDownloaded ItemID is nil")
    return true
  end
  local model_util = require("client.common.model_util")
  local BPID = model_util.GetBPID(ItemID)
  if not BPID or BPID == -1 then
    log(bWriteLog and "BP_Battle_VehicleLicenseComponent:CheckHasVehicleDownloaded BPID is nil")
    return true
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local dowloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {ItemID})
  return dowloadState == PufferConst.ENUM_DownloadState.Done
end
function BP_VehicleLicenseComponentBase:OnRep_LicensePlate()
  print(bWriteLog and "[LicensePlate] [VehicleEffect] OnRep_LicensePlate ItemID" .. tostring(self.LicensePlate.ItemID))
  self:DestroyAllAccessoryItem()
  local VehicleActor = self:GetOwner()
  if slua.isValid(VehicleActor) and VehicleActor.DeactiveEffect then
    VehicleActor:DeactiveEffect("Exhaust")
  end
  if not self:CheckHasVehicleDownloaded(self.LicensePlate.ItemID) then
    log(bWriteLog and "[LicensePlate] OnRep_LicensePlate Vehicle Is Not Download ItemID:" .. tostring(self.LicensePlate.ItemID))
    self:DestroyPlateMesh()
    self:DestoryChassisLight()
    return
  end
  self:PreChangePlate()
  self:PreChangeAccessory()
  self:PreChangeEffect()
  self:PreChangeChassisLight()
  if slua.isValid(VehicleActor) and VehicleActor.ReActivateExhaustParticle then
    VehicleActor:ReActivateExhaustParticle()
  end
  self:RefreshAccessoryHiddenStateByCurrentScope()
end
function BP_VehicleLicenseComponentBase:PreChangePlate()
  log(bWriteLog and "[LicensePlate] BP_VehicleLicenseComponentBase PreChangePlate")
  if not self.bEditingLicense and not self:CheckIsLicenseValid() then
    self:DestroyPlateMesh()
    return
  end
  if self:CheckIsVehicleExploded() then
    log(bWriteLog and "[LicensePlate] BP_VehicleLicenseComponentBase PreChangePlate CheckIsVehicleExploded true")
    self:DestroyPlateMesh()
    return
  end
  if not self.PlateMesh then
    self:InitPlateMeshComp()
  end
  self:RefreshPlateMeshComponentTrans()
  if not self.isParachuteState then
    local bMatch = self.LicensePlate.ItemID == self.curVehicleAvatarId
    print(bWriteLog and "BP_VehicleLicenseComponentBase PreChangePlate bMatch:" .. tostring(bMatch))
    self:SetPlateMeshVisible(bMatch)
  end
  if self.bIsLobbyLicense then
    log(bWriteLog and "[LicensePlate] BP_VehicleLicenseComponentBase PreChangePlate sync")
    self:OnResourceLoadFinish()
  else
    log(bWriteLog and "[LicensePlate] BP_VehicleLicenseComponentBase PreChangePlate async")
    local LicenseBackgroundId = self.LicensePlate.LicenseBackgroundId
    if LicenseBackgroundId and 0 < LicenseBackgroundId then
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      if PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {LicenseBackgroundId}) == PufferConst.ENUM_DownloadState.Done then
        self:AsyncLoadAccessoryItemHandle(LicenseBackgroundId, false)
      else
        self:AsyncLoadResource()
      end
    else
      self:AsyncLoadResource()
    end
  end
end
function BP_VehicleLicenseComponentBase:BPGetNeedLoadSoftPath()
  log(bWriteLog and "[LicensePlate] BPGetNeedLoadSoftPath")
  local SoftObjectPath = import("/Script/CoreUObject.SoftObjectPath")
  local SoftObjectPathArray = slua.Array(UEnums.EPropertyClass.Struct, SoftObjectPath)
  local PlateMeshPath = self:GetStaticMeshPath()
  if not PlateMeshPath then
    log(bWriteLog and "[LicensePlate] BPGetNeedLoadSoftPath PlateMeshPath is nil")
    return
  end
  local PlateMeshPathSoftObjPath = UKismetSystemLibrary.MakeSoftObjectPath(PlateMeshPath)
  SoftObjectPathArray:Add(PlateMeshPathSoftObjPath)
  local LicenseBackgroundId = self.LicensePlate and self.LicensePlate.LicenseBackgroundId
  if LicenseBackgroundId and 0 < LicenseBackgroundId then
    local LicenseBgHandle = self.AccessoryHandleCacheMap:Get(self.LicensePlate.LicenseBackgroundId)
    if slua.isValid(LicenseBgHandle) and LicenseBgHandle.ExtendedMatData and 0 < LicenseBgHandle.ExtendedMatData:Num() then
      local BgMatData = LicenseBgHandle.ExtendedMatData:Get(0)
      local bgMatsoftPath = BgMatData and BgMatData.MatInstance and BgMatData.MatInstance:ToSoftObjectPath()
      if bgMatsoftPath then
        SoftObjectPathArray:Add(bgMatsoftPath)
        log(bWriteLog and "[LicensePlate] BPGetNeedLoadSoftPath matdata 2")
      end
    end
  end
  return SoftObjectPathArray
end
function BP_VehicleLicenseComponentBase:OnResourceLoadFinish()
  log(bWriteLog and "[LicensePlate] OnResourceLoadFinish")
  if self:CheckIsVehicleExploded() then
    log(bWriteLog and "[LicensePlate] BP_VehicleLicenseComponentBase OnResourceLoadFinish CheckIsVehicleExploded true")
    self:DestroyPlateMesh()
    return
  end
  self:InitPlateMesh()
  self:ChangePlate()
  self:ChangePlateBg()
end
function BP_VehicleLicenseComponentBase:ChangePlate()
  log(bWriteLog and "[LicensePlate] ChangePlate")
  if not self.PlateMesh then
    log(bWriteLog and "[LicensePlate] ChangePlate not self.PlateMesh")
    return
  end
  local UVMaps = VehiclePlateLicenseUtil.ConvertPlateNumToUVMap(self.LicensePlate.LicenseNumArray)
  if VehiclePlateLicenseUtil.IsInInspectionMode() then
    log(bWriteLog and "[LicensePlate] ChangePlate InspectionMode hide license number")
    UVMaps = VehiclePlateLicenseUtil.ConstructDefaultUVMap()
  end
  local result = self.PlateMesh:ChangeRuntimeMeshSectionUVs(0, 0, UVMaps)
  if not result then
    log(bWriteLog and "[LicensePlate] ChangeRuntimeMeshSectionUVs return false")
  end
end
function BP_VehicleLicenseComponentBase:ChangePlateBg(downloadBgId)
  log(bWriteLog and "[LicensePlate] ChangePlateBg downloadBgId:" .. tostring(downloadBgId))
  if not self.PlateMesh then
    log(bWriteLog and "[LicensePlate] ChangePlateBg not self.PlateMesh")
    return
  end
  if not self.LicensePlate.LicenseBackgroundId or self.LicensePlate.LicenseBackgroundId <= 0 then
    log(bWriteLog and "[LicensePlate] ChangePlateBg not LicenseBackgroundId is 0")
    return
  end
  local LicenseBackgroundId = self.LicensePlate.LicenseBackgroundId
  if downloadBgId and LicenseBackgroundId ~= downloadBgId then
    log(bWriteLog and "[LicensePlate] ChangePlateBg LicenseBackgroundId ~= downloadBgId")
    return
  end
  if self.bIsLobbyLicense then
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    if PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {LicenseBackgroundId}) ~= PufferConst.ENUM_DownloadState.Done then
      log(bWriteLog and "[LicensePlate] ChangePlateBg not download LicenseBackgroundId:" .. tostring(LicenseBackgroundId))
      if not downloadBgId then
        local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
        PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {LicenseBackgroundId}, PufferTlog.Enum_TLog_From.Auto, function()
          self:ChangePlateBg(LicenseBackgroundId)
        end)
      end
      return
    end
  end
  local LicenseBgHandle = self.AccessoryHandleCacheMap:Get(self.LicensePlate.LicenseBackgroundId)
  if not LicenseBgHandle then
    if not self.bIsLobbyLicense then
      log(bWriteLog and "[LicensePlate] ChangePlateBg LicenseBgHandle is invalid and  not self.bIsLobbyLicense")
      return
    end
    local ItemCfg = CDataTable.GetTableData("Item", LicenseBackgroundId)
    if not ItemCfg or not ItemCfg.BPID then
      log(bWriteLog and "[LicensePlate] ChangePlateBg ItemCfg is nil" .. tostring(LicenseBackgroundId))
      return
    end
    local model_util = require("client.common.model_util")
    local BPHandleClass = model_util.GetClass("Avatar", ItemCfg.BPID, false, false)
    if not BPHandleClass then
      log(bWriteLog and "[LicensePlate] ChangePlateBg BPID Handle is nil" .. tostring(LicenseBackgroundId))
      return
    end
    LicenseBgHandle = BPHandleClass()
  end
  if not (LicenseBgHandle and LicenseBgHandle.ExtendedMatData) or 0 >= LicenseBgHandle.ExtendedMatData:Num() then
    log(bWriteLog and "[LicensePlate] ChangePlateBg LicenseBgHandle is invalid")
    return
  end
  local matData = LicenseBgHandle.ExtendedMatData:Get(0)
  if not matData or not matData.MatInstance then
    log(bWriteLog and "[LicensePlate] ChangePlateBg ExtendedMatData is invalid")
    return
  end
  local asset_util = require("common.asset_util")
  local material = asset_util.GetAssetSync(matData.MatInstance:ToString())
  if not material then
    log(bWriteLog and "[LicensePlate] ChangePlateBg material is invalid")
    return
  end
  local matIns = self.PlateMesh:CreateDynamicMaterialInstance(2, material)
  if not matIns then
    log(bWriteLog and "[LicensePlate] ChangePlateBg matIns is invalid")
    return
  end
  local VehiclePlateBgCfg = CDataTable.GetTableData("VehiclePlateBgCfg", LicenseBackgroundId)
  if not (VehiclePlateBgCfg and VehiclePlateBgCfg.NumTint_af and not (VehiclePlateBgCfg.NumTint_af:Num() < 4) and VehiclePlateBgCfg.BaseCol_af) or 4 > VehiclePlateBgCfg.BaseCol_af:Num() then
    log(bWriteLog and "[LicensePlate] ChangePlateBg VehiclePlateBgCfg is invalid")
    return
  end
  local NumMatIns = self.PlateMesh:CreateDynamicMaterialInstance(0)
  if NumMatIns then
    NumMatIns:SetScalarParameterValue("NumIntensity", VehiclePlateBgCfg.NumIntensity or 1)
    if VehiclePlateBgCfg.NumTint_af and VehiclePlateBgCfg.NumTint_af:Num() >= 4 then
      NumMatIns:SetVectorParameterValue("NumTint", FLinearColor(VehiclePlateBgCfg.NumTint_af:Get(0), VehiclePlateBgCfg.NumTint_af:Get(1), VehiclePlateBgCfg.NumTint_af:Get(2), VehiclePlateBgCfg.NumTint_af:Get(3)))
    end
  end
  if VehiclePlateBgCfg.BaseCol_af and 4 <= VehiclePlateBgCfg.BaseCol_af:Num() then
    local DotMatIns = self.PlateMesh:CreateDynamicMaterialInstance(dotMatIndex)
    if DotMatIns then
      DotMatIns:SetVectorParameterValue("BaseCol", FLinearColor(VehiclePlateBgCfg.BaseCol_af:Get(0), VehiclePlateBgCfg.BaseCol_af:Get(1), VehiclePlateBgCfg.BaseCol_af:Get(2), VehiclePlateBgCfg.BaseCol_af:Get(3)))
    end
  end
end
function BP_VehicleLicenseComponentBase:DestroyPlateMesh()
  print(bWriteLog and "[LicensePlate] DestroyPlateMesh")
  if not self.PlateMesh then
    return
  end
  self.PlateMesh:K2_DestroyComponent(self.PlateMesh)
  self.PlateMesh = nil
end
function BP_VehicleLicenseComponentBase:SetPlateMeshVisible(bVisible)
  print(bWriteLog and "BP_VehicleLicenseComponentBase SetPlateMeshVisible " .. tostring(bVisible))
  if not self.PlateMesh then
    return
  end
  self.PlateMesh:SetVisibility(bVisible, false)
end
function BP_VehicleLicenseComponentBase:OnVehicleMeshAvatarEquiped(expectItemId)
  print(bWriteLog and "BP_VehicleLicenseComponentBase OnVehicleMeshAvatarEquiped " .. tostring(expectItemId))
  if self.isParachuteState then
    print(bWriteLog and "BP_VehicleLicenseComponentBase OnVehicleMeshAvatarEquiped isParachuteState true")
    return
  end
  if not expectItemId or not self.LicensePlate then
    print(bWriteLog and "BP_VehicleLicenseComponentBase OnVehicleMeshAvatarEquiped invalid param")
    return
  end
  self.curVehicleAvatarId = expectItemId
  local bMatch = self.LicensePlate.ItemID == expectItemId
  print(bWriteLog and "BP_VehicleLicenseComponentBase OnVehicleMeshAvatarEquiped bMatch:" .. tostring(bMatch))
  self:SetPlateMeshVisible(bMatch)
  self:SetAccessoriesVisibility(bMatch)
end
function BP_VehicleLicenseComponentBase:DestroyAllAccessoryItem()
  log(bWriteLog and "[vehicleAccessory] DestroyAllAccessory ")
  self.curVehicleHandle = nil
  self.HideOnScopeAccessorySet = nil
  self:DestroyAllAccessory()
end
function BP_VehicleLicenseComponentBase:PreChangeAccessory()
  print(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase PreChangeAccessory ")
  if not (self.LicensePlate and self.LicensePlate.ItemID) or not self.LicensePlate.AccessoryIdList then
    print(bWriteLog and "[vehicleAccessory]PreChangeAccessory invalid param")
    return
  end
  if self.LicensePlate.AccessoryIdList:Num() <= 0 then
    print(bWriteLog and "[vehicleAccessory]PreChangeAccessory AccessoryIdList is empty")
    return
  end
  local vehicleId = self.LicensePlate.ItemID
  if vehicleId == -1 then
    print(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase PreChangeAccessory vehicleId == -1")
    return
  end
  self:RebuildHideOnScopeAccessorySet()
  local vehicleActor = self:GetOwner()
  if not slua.isValid(vehicleActor) or not vehicleActor.GetAvatarComponent then
    print(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase PreChangeAccessory invalid vehicleActor")
    return
  end
  local vehicleAvatarComponent = vehicleActor:GetAvatarComponent()
  if not slua.isValid(vehicleAvatarComponent) then
    print(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase PreChangeAccessory invalid vehicleAvatarComponent")
    return
  end
  local handlePath = vehicleAvatarComponent:GetItemAvatarHandlePath(vehicleId)
  if not handlePath or handlePath == "" then
    print(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase PreChangeAccessory invalid handlePath")
    return
  end
  self:AsyncLoadAsset(handlePath, function(handleAsset)
    if vehicleId and vehicleId == self.LicensePlate.ItemID and slua.isValid(handleAsset) then
      print(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase PreChangeAccessory AsyncLoadAccessoryHandle")
      self.curVehicleHandle = handleAsset
      self:AsyncLoadAccessoryHandle()
    else
      print(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase PreChangeAccessory handle not match")
    end
  end)
end
function BP_VehicleLicenseComponentBase:AsyncLoadAccessoryHandle()
  print(bWriteLog and "[vehicleAccessory]AsyncLoadAccessoryHandle ")
  if not (self.LicensePlate and self.LicensePlate.ItemID) or not self.LicensePlate.AccessoryIdList then
    print(bWriteLog and "[vehicleAccessory]AsyncLoadAccessoryHandle invalid param")
    return
  end
  if self.LicensePlate.AccessoryIdList:Num() <= 0 then
    print(bWriteLog and "[vehicleAccessory]AsyncLoadAccessoryHandle AccessoryIdList is empty")
    return
  end
  for i = 0, self.LicensePlate.AccessoryIdList:Num() - 1 do
    local accItemId = self.LicensePlate.AccessoryIdList:Get(i)
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local dowloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {accItemId})
    if dowloadState == PufferConst.ENUM_DownloadState.Done then
      self:_AsyncLoadHandle(accItemId)
    else
      log(bWriteLog and "[vehicleAccessory] AsyncLoadAccessoryHandle Vehicle Is Not Download ItemID:" .. tostring(accItemId))
      if self.bIsLobbyLicense then
        do
          local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
          PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {accItemId}, PufferTlog.Enum_TLog_From.Auto, function()
            self:OnDownloadResDone(accItemId)
          end)
        end
      end
    end
  end
end
function BP_VehicleLicenseComponentBase:_AsyncLoadHandle(ItemID)
  local UBackpackUtils = import("BackpackUtils")
  local handlePath = self:GetAccessoryAvatarHandlePath(ItemID)
  local itemCfg = CDataTable.GetTableData("Item", ItemID)
  if handlePath and UBackpackUtils.IsBattleItemHandlePathExist(handlePath) then
    local bpCfg = CDataTable.GetTableData("AvatarBPTable", itemCfg.BPID)
    if bpCfg and bpCfg.AvatarBPPath and bpCfg.AvatarBPPath ~= "" then
      self:AsyncLoadAsset(handlePath, self.OnAccHandleLoaded, self, ItemID, itemCfg.BPID)
    end
  end
end
function BP_VehicleLicenseComponentBase:OnDownloadResDone(accItemId)
  print(bWriteLog and "[vehicleAccessory]OnDownloadResDone accItemId:" .. tostring(accItemId))
  if not accItemId then
    print(bWriteLog and "[vehicleAccessory]OnDownloadResDone invalid param")
    return
  end
  if not slua.isValid(self:GetOwner()) then
    print(bWriteLog and "[vehicleAccessory]OnDownloadResDone invalid GetOwner")
    return
  end
  if not self:CheckIsValidItemId(accItemId) then
    print(bWriteLog and "[vehicleAccessory]OnDownloadResDone not bValidItem")
    return
  end
  if self.AccesssoryMeshs:Get(accItemId) or self.AccesssorySkeletalMeshs:Get(accItemId) then
    print(bWriteLog and "[vehicleAccessory]OnDownloadResDone has AccesssoryMeshs done")
    return
  end
  local handlePath = self:GetAccessoryAvatarHandlePath(accItemId)
  local itemCfg = CDataTable.GetTableData("Item", accItemId)
  local UBackpackUtils = import("BackpackUtils")
  if handlePath and UBackpackUtils.IsBattleItemHandlePathExist(handlePath) then
    local bpCfg = CDataTable.GetTableData("AvatarBPTable", itemCfg.BPID)
    if bpCfg and bpCfg.AvatarBPPath and bpCfg.AvatarBPPath ~= "" then
      self:AsyncLoadAsset(handlePath, self.OnAccHandleLoaded, self, accItemId, itemCfg.BPID)
    end
  end
end
function BP_VehicleLicenseComponentBase:GetAccessoryAvatarHandlePath(accItemId)
  print(bWriteLog and "[vehicleAccessory]GetAccessoryAvatarHandlePath ")
  if not accItemId then
    print(bWriteLog and "[vehicleAccessory]GetAccessoryAvatarHandlePath invalid param")
    return
  end
  local itemCfg = CDataTable.GetTableData("Item", accItemId)
  if not itemCfg or not itemCfg.BPID then
    print(bWriteLog and "[vehicleAccessory]GetAccessoryAvatarHandlePath invalid itemCfg.BPID ")
    return
  end
  local UAELoadedClassManager = import("UAELoadedClassManager").Get()
  local HandlePath = UAELoadedClassManager:GetPath("Avatar", itemCfg.BPID, false, false)
  return HandlePath
end
function BP_VehicleLicenseComponentBase:OnAccHandleLoaded(accItemId, accBPID, handleAsset)
  if not (slua.isValid(handleAsset) and accBPID) or not accItemId then
    log(bWriteLog and "[vehicleAccessory]OnAccHandleLoaded invalid param")
    return
  end
  log(bWriteLog and "[vehicleAccessory]OnAccHandleLoaded accItemId:" .. tostring(accItemId))
  local BusinessHelper = import("BusinessHelper")
  local ItemHandleBaseClass = import("ItemHandleBase")
  if not ItemHandleBaseClass then
    return
  end
  local model_util = require("client.common.model_util")
  local handleClass = model_util.GetClass("Avatar", accBPID, false, false)
  if not handleClass then
    log_error("[vehicleAccessory] OnAccHandleLoaded. handleClass is nil")
    return nil
  end
  local handle = handleClass()
  if not BusinessHelper.IsClassOf(handle, ItemHandleBaseClass) then
    log_error("[vehicleAccessory] OnAccHandleLoaded. Cast to BackpackVehicleAccessoryHandle failed.")
    return nil
  end
  self.AccessoryHandleCacheMap:Add(accItemId, handle)
  if self.LicensePlate.ChassisLightId == accItemId then
    log(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase:OnAccessoryResLoadFinish ChassisLightId true")
    self:AsyncLoadOneAccessoryRes(accItemId)
  elseif self.LicensePlate.LicenseBackgroundId == accItemId then
    self:AsyncLoadResource()
  elseif self:CheckIsCurVevhileAccessory(accItemId) then
    log(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase:OnAccessoryResLoadFinish CheckIsCurVevhileAccessory true")
    self:AsyncLoadOneAccessoryRes(accItemId)
  end
end
function BP_VehicleLicenseComponentBase:OnAccessoryResLoadFinish(accItemId)
  if not accItemId then
    log(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase:OnAccessoryResLoadFinish invalid accItemId")
    return
  end
  if VehiclePlateLicenseUtil.IsUpgradeVehicleEffect(accItemId) then
    self:OnEffectResLoadFinish(accItemId)
    return
  elseif accItemId == self.LicensePlate.ChassisLightId then
    self:OnChassisLightResLoadFinish(accItemId)
    return
  end
  if not self:CheckIsCurVevhileAccessory(accItemId) then
    log(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase:OnAccessoryResLoadFinish CheckIsCurVevhileAccessory false")
    return
  end
  local handle = self.AccessoryHandleCacheMap:Get(accItemId)
  if not (handle and handle.AccessorySlotName) or handle.AccessorySlotName == "" then
    log(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase:OnAccessoryResLoadFinish invalid handle or AccessorySlotName")
    return
  end
  log(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase:OnAccessoryResLoadFinish accItemId:" .. tostring(accItemId))
  log(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase:OnAccessoryResLoadFinish AccessorySlotName:" .. tostring(handle.AccessorySlotName))
  local vechileActor = self:GetOwner()
  if not vechileActor or not vechileActor.GetVehicleAccessorySlotConfig then
    log(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase:OnAccessoryResLoadFinish invalid vechileActor")
    return
  end
  if self:CheckIsVehicleExploded() then
    log(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase:OnAccessoryResLoadFinish vechileActor is exploded")
    self:ChangeOneAccessoryToBroken(accItemId)
    return
  end
  local vehicleSlotConfig = vechileActor:GetVehicleAccessorySlotConfig(self.LicensePlate.ItemID, handle.AccessorySlotName)
  if not vehicleSlotConfig then
    log(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase:OnAccessoryResLoadFinish vechileActor no slotconfig VehicleId:" .. tostring(self.LicensePlate.ItemID))
    return
  end
  self:CreateAccessoryMesh(accItemId, vehicleSlotConfig.AccessoryPos, vehicleSlotConfig.AccessoryRot, vehicleSlotConfig.AccessoryScale * handle.MeshScale, vehicleSlotConfig.AttachBoneName or "None")
  if not self.isParachuteState then
    local bMatch = self.LicensePlate.ItemID == self.curVehicleAvatarId
    print(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase:OnAccessoryResLoadFinish bMatch:" .. tostring(bMatch))
    self:SetAccessoriesVisibility(bMatch)
    self:RefreshAccessoryHiddenStateByCurrentScope()
  end
end
function BP_VehicleLicenseComponentBase:GetParticlePack(ItemId)
  local handle = self.AccessoryHandleCacheMap:Get(ItemId)
  if not handle then
    log(bWriteLog and "BP_VehicleLicenseComponentBase:OnEffectResLoadFinish invalid handle")
    return
  end
  local VehicleID = self:GetOwner():GetAvatarID()
  local ParticlePack = handle.ParticlePackMap:Get(VehicleID)
  if not ParticlePack then
    local WeaponModelMgrHelper = require("client.slua.logic.manager.WeaponModelSubLogic.WeaponModelMgrHelper")
    local ItemId = WeaponModelMgrHelper.GetRealResId(VehicleID, true)
    ParticlePack = handle.ParticlePackMap:Get(ItemId)
  end
  return ParticlePack
end
function BP_VehicleLicenseComponentBase:SetAccessoriesVisibility(bShow)
  bShow = bShow or false
  if self.AccesssorySkeletalMeshs then
    for _, skeletalMeshComp in pairs(self.AccesssorySkeletalMeshs) do
      if slua.isValid(skeletalMeshComp) then
        skeletalMeshComp:SetVisibility(bShow, false)
      end
    end
  end
  if self.AccesssoryMeshs then
    for _, staticMeshComp in pairs(self.AccesssoryMeshs) do
      if slua.isValid(staticMeshComp) then
        staticMeshComp:SetVisibility(bShow, false)
      end
    end
  end
end
function BP_VehicleLicenseComponentBase:GetOneAccessoryMeshComp(accItemId)
  if self.AccesssoryMeshs and slua.isValid(self.AccesssoryMeshs:Get(accItemId)) then
    return self.AccesssoryMeshs:Get(accItemId)
  end
  if self.AccesssorySkeletalMeshs and slua.isValid(self.AccesssorySkeletalMeshs:Get(accItemId)) then
    return self.AccesssorySkeletalMeshs:Get(accItemId)
  end
  return nil
end
function BP_VehicleLicenseComponentBase:DestroyOneAccessoryMeshComp(accItemId)
  if self.AccesssoryMeshs and slua.isValid(self.AccesssoryMeshs[accItemId]) then
    local meshComp = self.AccesssoryMeshs:Get(accItemId)
    if meshComp then
      meshComp:K2_DestroyComponent(meshComp)
      self.AccesssoryMeshs:Remove(accItemId)
      return
    end
  end
  if self.AccesssorySkeletalMeshs then
    local meshComp = self.AccesssorySkeletalMeshs:Get(accItemId)
    if meshComp then
      meshComp:K2_DestroyComponent(meshComp)
      self.AccesssorySkeletalMeshs:Remove(accItemId)
      return
    end
  end
end
function BP_VehicleLicenseComponentBase:CheckIsCurVevhileAccessory(accItemId)
  if not accItemId then
    return false
  end
  local accessoryListNum = self.LicensePlate.AccessoryIdList:Num()
  if accessoryListNum <= 0 then
    print(bWriteLog and "[vehicleAccessory]CheckIsCurVevhileAccessory AccessoryIdList is empty")
    return false
  end
  for i = 0, accessoryListNum - 1 do
    local accId = self.LicensePlate.AccessoryIdList:Get(i)
    if accId == accItemId then
      return true
    end
  end
  print(bWriteLog and "[vehicleAccessory]CheckIsCurVevhileAccessory not cur Accessory")
  return false
end
function BP_VehicleLicenseComponentBase:ChangeOneAccessoryToBroken(ItemId)
  log(bWriteLog and "[vehicleAccessory]ChangeOneAccessoryToBroken ItemId:" .. tostring(ItemId))
  if not ItemId then
    log(bWriteLog and "[vehicleAccessory]ChangeOneAccessoryToBroken ItemId is nil")
    return
  end
  local AccHandle = self.AccessoryHandleCacheMap:Get(ItemId)
  if not AccHandle then
    log(bWriteLog and "[vehicleAccessory]ChangeOneAccessoryToBroken AccHandle is nil")
    return
  end
  if AccHandle.ShouldHideOnBroken then
    print(bWriteLog and "[vehicleAccessory]ChangeOneAccessoryToBroken ShouldHideOnBroken true")
    self:DestroyOneAccessoryMeshComp(ItemId)
  elseif AccHandle.BrokenMatData and AccHandle.BrokenMatData:Num() > 0 then
    print(bWriteLog and "[vehicleAccessory]ChangeOneAccessoryToBroken AsyncLoadOneAccessoryBrokenRes")
    self:AsyncLoadOneAccessoryBrokenRes(ItemId)
  else
    print(bWriteLog and "[vehicleAccessory]ChangeOneAccessoryToBroken do nothing")
  end
end
function BP_VehicleLicenseComponentBase:RebuildHideOnScopeAccessorySet()
  self.HideOnScopeAccessorySet = {}
  if not self.LicensePlate or not self.LicensePlate.AccessoryIdList then
    return
  end
  local vehicleId = self.LicensePlate.ItemID
  if not vehicleId or vehicleId <= 0 then
    return
  end
  local accessoryIdList = self.LicensePlate.AccessoryIdList
  local accessoryNum = accessoryIdList:Num()
  if accessoryNum <= 0 then
    return
  end
  local hideSet = self.HideOnScopeAccessorySet
  for i = 0, accessoryNum - 1 do
    local accItemId = accessoryIdList:Get(i)
    local cfg = CDataTable.GetTableDataByFilter("VehicleAccessoryUnlockConfig", "VehicleId", vehicleId, "AccItemId", accItemId)
    if cfg and cfg.HideOnScope then
      hideSet[accItemId] = true
    end
  end
  log(bWriteLog and "[vehicleAccessory]RebuildHideOnScopeAccessorySet vehicleId:" .. tostring(vehicleId))
end
function BP_VehicleLicenseComponentBase:SetOneAccessoryMeshVisible(accItemId, bVisible)
  local meshComp = self:GetOneAccessoryMeshComp(accItemId)
  if slua.isValid(meshComp) then
    meshComp:SetVisibility(bVisible, false)
  end
end
function BP_VehicleLicenseComponentBase:SetAccessoriesHiddenOnScope(bInScope)
  log(bWriteLog and "[vehicleAccessory]SetAccessoriesHiddenOnScope bInScope:" .. tostring(bInScope))
  local hideSet = self.HideOnScopeAccessorySet
  if not hideSet or not next(hideSet) then
    return
  end
  if self:CheckIsVehicleExploded() then
    log(bWriteLog and "[vehicleAccessory]SetAccessoriesHiddenOnScope vehicle exploded, skip")
    return
  end
  local bVehicleAvatarMatch = self.LicensePlate and self.LicensePlate.ItemID == self.curVehicleAvatarId
  if not bInScope and not bVehicleAvatarMatch then
    log(bWriteLog and "[vehicleAccessory]SetAccessoriesHiddenOnScope avatar not match on scope out, skip")
    return
  end
  local bVisible = not bInScope
  for accItemId, _ in pairs(hideSet) do
    self:SetOneAccessoryMeshVisible(accItemId, bVisible)
  end
end
function BP_VehicleLicenseComponentBase:RefreshAccessoryHiddenStateByCurrentScope()
  local vehicleActor = self:GetOwner()
  if not slua.isValid(vehicleActor) then
    return
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local playerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(playerCharacter) or not playerCharacter.GetCurrentVehicle then
    return
  end
  if playerCharacter:GetCurrentVehicle() ~= vehicleActor then
    return
  end
  local bInScope = playerCharacter.IsLocalActuallyScopeIn and true or false
  log(bWriteLog and "[vehicleAccessory]RefreshAccessoryHiddenStateByCurrentScope bInScope:" .. tostring(bInScope))
  self:SetAccessoriesHiddenOnScope(bInScope)
end
function BP_VehicleLicenseComponentBase:SetInvalidLicenseNum()
  self:ChangeLicenseNum(0, -1)
end
function BP_VehicleLicenseComponentBase:CheckIsLicenseValid()
  if self.LicensePlate.ItemID < 0 or not self.LicensePlate.LicenseNumArray then
    return false
  end
  for i = 0, self.LicensePlate.LicenseNumArray:Num() - 1 do
    if self.LicensePlate.LicenseNumArray:Get(i) == -1 then
      return false
    end
  end
  return true
end
function BP_VehicleLicenseComponentBase:PreChangeEffect()
end
function BP_VehicleLicenseComponentBase:PreChangeChassisLight()
  print(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase PreChangeChassisLight ")
  if self.ChassisLightTimer then
    self:RemoveTimer(self.ChassisLightTimer)
    self.ChassisLightTimer = nil
  end
  if slua.isValid(self.ChassisLightMesh) then
    self.ChassisLightMesh:SetVisibility(false, false)
  end
  if not (self.LicensePlate and self.LicensePlate.ChassisLightId) or self.LicensePlate.ChassisLightId == 0 then
    print(bWriteLog and "[vehicleAccesssory]PreChangeChassisLight invalid ChassisLightId")
    self:DestoryChassisLight()
    return
  end
  local vehicleId = self.LicensePlate.ItemID
  if vehicleId == -1 then
    print(bWriteLog and "[vehicleAccessory]BP_VehicleLicenseComponentBase PreChangeAccessory vehicleId == -1")
    self:DestoryChassisLight()
    return
  end
  local chassisLightId = self.LicensePlate.ChassisLightId
  self:AsyncLoadAccessoryItemHandle(chassisLightId, true)
end
function BP_VehicleLicenseComponentBase:AsyncLoadAccessoryItemHandle(itemId, bCheckDownload)
  print(bWriteLog and "[vehicleAccessory]AsyncLoadAccessoryItemHandle ")
  if not itemId then
    print(bWriteLog and "[vehicleAccessory]AsyncLoadAccessoryItemHandle invalid param")
    return
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  if not bCheckDownload or PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {itemId}) == PufferConst.ENUM_DownloadState.Done then
    self:_AsyncLoadHandle(itemId)
  else
    log(bWriteLog and "[vehicleAccessory] AsyncLoadAccessoryItemHandle Vehicle Is Not Download ItemID:" .. tostring(itemId))
    if self.bIsLobbyLicense then
      local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {itemId}, PufferTlog.Enum_TLog_From.Auto, function()
        self:OnDownloadResDone(itemId)
      end)
    end
  end
end
function BP_VehicleLicenseComponentBase:CreateChassisLightMeshComp(matPath)
  if not matPath or matPath == "" then
    print(bWriteLog and "[vehicleAccessory]CreateChassisLightMeshComp matPath is nil")
    return
  end
  if self:CheckIsVehicleExploded() then
    print(bWriteLog and "[vehicleAccessory]CreateChassisLightMeshComp CheckIsVehicleExploded is true")
    return
  end
  if self:CheckIsWheelDestoryed() then
    print(bWriteLog and "[vehicleAccessory]CreateChassisLightMeshComp bHasWheelDestroy is true")
    return
  end
  local LocVec, ScaleVec = VehiclePlateLicenseUtil.GetChassisLightLocAndScale(self.LicensePlate.ItemID, self.bIsLobbyLicense)
  if not LocVec or not ScaleVec then
    return
  end
  local asset_util = require("common.asset_util")
  if self.LightAssetLoadingHandle then
    asset_util.CancelAssetAsync(self.LightAssetLoadingHandle)
    self.LightAssetLoadingHandle = nil
  end
  self.LightAssetLoadingHandle = asset_util.GetAssetAsync(LightPlanePath, function(uMesh)
    self.LightAssetLoadingHandle = nil
    local ECollisionEnabled = import("ECollisionEnabled")
    if not slua.isValid(self.ChassisLightMesh) then
      local StaticMeshComponentClass = import("StaticMeshComponent")
      if slua.isValid(self.Object) then
        local effectComp = Game:AddComponent(StaticMeshComponentClass, self:GetOwner(), "Effect")
        local EAttachmentRule = import("EAttachmentRule")
        effectComp:SetCollisionEnabled(ECollisionEnabled.NoCollision)
        effectComp:K2_AttachToComponent(self:GetAttachComponent(), self:GetAttachName(self.curVehicleAvatarId), EAttachmentRule.SnapToTarget, EAttachmentRule.SnapToTarget, EAttachmentRule.SnapToTarget, true)
        if slua.isValid(uMesh) then
          effectComp:SetStaticMesh(uMesh)
        end
        self.ChassisLightMesh = effectComp
      end
    end
    self.LightAssetLoadingHandle = asset_util.GetAssetAsync(matPath, function(uMaterial)
      self.LightAssetLoadingHandle = nil
      if slua.isValid(uMaterial) and slua.isValid(self.ChassisLightMesh) then
        self.ChassisLightMesh:CreateDynamicMaterialInstance(0, uMaterial)
        self.ChassisLightMesh.bGenerateOverlapEvents = false
        self.ChassisLightMesh:K2_SetRelativeLocation(LocVec, false, nil, true)
        self.ChassisLightMesh:K2_SetRelativeRotation(FRotator(0, 0, 0), false, nil, true)
        self.ChassisLightMesh:SetRelativeScale3D(ScaleVec)
      end
    end)
  end)
end
function BP_VehicleLicenseComponentBase:OnChassisLightResLoadFinish(accItemId)
  log(bWriteLog and "[vehicleAccessory]OnChassisLightResLoadFinish accItemId:" .. tostring(accItemId))
  if not accItemId then
    log(bWriteLog and "[vehicleAccessory]OnChassisLightResLoadFinish invalid accItemId")
    return
  end
  if not self.LicensePlate.ChassisLightId == accItemId then
    log(bWriteLog and "[vehicleAccessory]OnChassisLightResLoadFinish invalid accItemId")
    return
  end
  local handle = self.AccessoryHandleCacheMap:Get(accItemId)
  if not (handle and handle.ExtendedMatData) or handle.ExtendedMatData:Num() <= 0 then
    log(bWriteLog and "[vehicleAccessory]OnChassisLightResLoadFinish invalid handle or AccessorySlotName")
    return
  end
  local LightMatData = handle.ExtendedMatData:Get(0)
  if not LightMatData or not LightMatData.MatInstance then
    log(bWriteLog and "[vehicleAccessory]OnChassisLightResLoadFinish invalid LightMatPath")
    return
  end
  self:CreateChassisLightMeshComp(LightMatData.MatInstance:ToString())
  self:SetChassisLightCheckTimer()
end
function BP_VehicleLicenseComponentBase:CheckIsValidItemId(accItemId)
  log(bWriteLog and "[vehicleAccessory]CheckIsValidItemId accItemId:" .. tostring(accItemId))
  if not accItemId then
    log(bWriteLog and "[vehicleAccessory]CheckIsValidItemId accItemId is nil")
    return false
  end
  if self.LicensePlate.ChassisLightId == accItemId then
    return true
  end
  local bValidItem = false
  for i = 0, self.LicensePlate.AccessoryIdList:Num() - 1 do
    local accId = self.LicensePlate.AccessoryIdList:Get(i)
    if accId == accItemId then
      bValidItem = true
      break
    end
  end
  return bValidItem
end
function BP_VehicleLicenseComponentBase:SetChassisLightCheckTimer()
  log(bWriteLog and "[vehicleAccessory]SetChassisLightCheckTimer")
  if self.ChassisLightTimer then
    self:RemoveTimer(self.ChassisLightTimer)
    self.ChassisLightTimer = nil
  end
  if self.bIsLobbyLicense then
    self:SetChassisLightShow(true)
    return
  end
  self:UpdateChassisLightShow()
  self.ChassisLightTimer = self:AddTimerLoop(0, function()
    self:UpdateChassisLightShow()
  end, TIMER_INFINITE, 0.1)
end
function BP_VehicleLicenseComponentBase:UpdateChassisLightShow()
  local vehicleActor = self:GetOwner()
  if not vehicleActor or not vehicleActor.GetForwardSpeed then
    log(bWriteLog and "[vehicleAccessory]UpdateChassisLightShow GetOwner is nil")
    return
  end
  local curSpeed = vehicleActor:GetForwardSpeed()
  if curSpeed and math.abs(curSpeed) <= 5 and 5 >= self.lastSpeed then
    self:SetChassisLightShow(true)
  else
    self:SetChassisLightShow(false)
  end
  self.lastSpeed = math.abs(curSpeed)
end
function BP_VehicleLicenseComponentBase:SetChassisLightShow(bShow)
  if not slua.isValid(self.ChassisLightMesh) then
    log(bWriteLog and "[vehicleAccessory]SetChassisLightShow self.ChassisLightMesh is nil")
    return
  end
  if self.LicensePlate.ItemID ~= self.curVehicleAvatarId or self.LicensePlate.ChassisLightId == 0 then
    log(bWriteLog and "[vehicleAccessory]SetChassisLightShow self.ChassisLightMesh self.LicensePlate.ItemID ~= self.curVehicleAvatarId")
    self.ChassisLightMesh:SetVisibility(false, false)
    return
  end
  self.ChassisLightMesh:SetVisibility(bShow, false)
end
function BP_VehicleLicenseComponentBase:DestoryChassisLight()
  log(bWriteLog and "[vehicleAccessory]SetChassisLightCheckTimer")
  if self.ChassisLightTimer then
    self:RemoveTimer(self.ChassisLightTimer)
    self.ChassisLightTimer = nil
  end
  if self.ChassisLightMesh then
    self.ChassisLightMesh:K2_DestroyComponent(self.ChassisLightMesh)
    self.ChassisLightMesh = nil
  end
end
function BP_VehicleLicenseComponentBase:CheckIsWheelDestoryed()
  return false
end
function BP_VehicleLicenseComponentBase:CheckIsVehicleExploded()
  return false
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CBP_VehicleLicenseComponentBase = class(CActorComponentBase, nil, BP_VehicleLicenseComponentBase)
return CBP_VehicleLicenseComponentBase