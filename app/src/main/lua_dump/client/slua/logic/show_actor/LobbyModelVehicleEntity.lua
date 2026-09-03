local LobbyModelVehicleEntity = {}
function LobbyModelVehicleEntity:RegistAsyncEvent()
  self:AddControlEvent(self.ModelActor:GetVehicleAvatar(), "VehicleAvatarEqiuped", self.OnAsyncReady, self)
end
function LobbyModelVehicleEntity:OnShowModel()
  if not slua.isValid(self.ModelActor) then
    log(bWriteLog and "LobbyModelVehicleEntity:OnShowModel self.ModelActor is not Valid ItemID is " .. tostring(self.ItemID))
    return
  end
  self.ModelActor.Mesh:SetCastShadow(true)
  self.ModelActor.Mesh:SetSimulatePhysics(false)
  self.ModelActor:SetActorTickEnabled(false)
  self.ModelActor.VehicleResId = self.ItemID
  if self:ArrayFind("is_hall_vehicle") then
    self.ModelActor.IsHallVehicle = true
    self.ModelActor.VehicleAvatarComponent_BP.bIsLobbyAvatar = false
  else
    self.ModelActor.VehicleAvatarComponent_BP.bIsLobbyAvatar = true
    self.ModelActor.VehicleAvatarComponent_BP.MeshLODOptimize = false
  end
  if self:ArrayFind("force_lod") then
    self.ModelActor.VehicleAvatarComponent_BP.MeshLODOptimize = true
    self.ModelActor.VehicleAvatarComponent_BP.ForceLod = true
  end
  if self:ArrayFind("NotOpenDoor") then
    self.ModelActor.bIsProhibitOpenDoorAnim = true
  end
end
function LobbyModelVehicleEntity:ChangeAvatar()
  self.ModelActor:PreChangeVehicleAvatar(self.ItemID, 0)
end
function LobbyModelVehicleEntity:OnAsyncReady()
  LobbyModelVehicleEntity.__super.OnAsyncReady(self)
  local VehicleAvatar = self.ModelActor:GetVehicleAvatar()
  if not slua.isValid(VehicleAvatar) then
    return
  end
  local MeshComp = VehicleAvatar.ItemBodyMesh
  if slua.isValid(MeshComp) then
    self:RefreshTextureMipmapImmediately(MeshComp)
  end
end
function LobbyModelVehicleEntity:OnAsyncFinish()
  local VehicleLicense = self.OwnerActor:GetVehicleLicense()
  local VehicleLicenseBgId = self.OwnerActor:GetVehicleLicenseBgId()
  if VehicleLicense and VehicleLicense ~= "" then
    self.ModelActor:SetLicensePlate(VehicleLicense, VehicleLicenseBgId)
  end
  if self:ArrayFind("CastPhontonShadow") and slua.isValid(self.ModelActor) and slua.isValid(self.ModelActor.Mesh) then
    self.ModelActor.Mesh:SetCastPhotonShadow(true)
  end
  local EnableHighTire = self.OwnerActor:IsEnableHighTire()
  self.ModelActor.VehicleAvatarComponent_BP:EnableHighTireLight(EnableHighTire)
  local vehicleAccessoryList = self.OwnerActor:GetVehicleAccessory()
  if self.ModelActor.SetVehicleAccessoryList then
    self.ModelActor:SetVehicleAccessoryList(vehicleAccessoryList)
  end
  local vehicleChassisLightData = self.OwnerActor:GetVehicleChassisLight()
  if self.ModelActor.SetChassisLightShowData then
    self.ModelActor:SetChassisLightShowData(vehicleChassisLightData)
  end
  local appliqueData = self.OwnerActor:GetVehicleAppliqueList()
  if appliqueData and self.ModelActor.BP_VehicleDIYComp then
    local LogicVehicleDIY = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicVehicleDIY)
    local patternArray = LogicVehicleDIY:ConvertUserVehicleDIYDataList(appliqueData.appliques)
    self.ModelActor.BP_VehicleDIYComp.car_id = self.ItemID
    self.ModelActor.BP_VehicleDIYComp:AddDIYPattern(patternArray)
  end
end
function LobbyModelVehicleEntity:GetSpawnTransform()
  local UKismetMathLibrary = import("KismetMathLibrary")
  return UKismetMathLibrary.MakeTransform(FVector(0, 0, 0), FRotator(0, 0, 0), FVector(1, 1, 1))
end
function LobbyModelVehicleEntity:AttachToAttachPoint()
  log(bWriteLog and "LobbyModelVehicleEntity AttachToAttachPoint")
  self:_ResetAttachPointRotate()
  local AttachPoint = self.OwnerActor:GetAttachPoint()
  if slua.isValid(AttachPoint) then
    log(bWriteLog and "LobbyModelVehicleEntity AttachToAttachPoint AttachPoint")
    self.OwnerActor:K2_AttachToActor(AttachPoint, "None", 1, 1, 1, true)
    if slua.isValid(self.ModelActor) and slua.isValid(self.ModelActor.Mesh) then
      self.ModelActor.Mesh:SetCastPhotonShadow(true)
    end
  end
end
function LobbyModelVehicleEntity:RefreshExtraTableDataShow()
  log(bWriteLog and "LobbyModelVehicleEntity RefreshExtraTableDataShow")
  if not slua.isValid(self.ModelActor) then
    return
  end
  local vehicleAccessoryList = self.OwnerActor:GetVehicleAccessory()
  if self.ModelActor.SetVehicleAccessoryList then
    self.ModelActor:SetVehicleAccessoryList(vehicleAccessoryList)
  end
end
local class = require("class")
local BaseModel = require("client.slua.logic.show_actor.LobbyModelBaseEntity")
local CLobbyModelVehicleEntity = class(BaseModel, nil, LobbyModelVehicleEntity)
return CLobbyModelVehicleEntity