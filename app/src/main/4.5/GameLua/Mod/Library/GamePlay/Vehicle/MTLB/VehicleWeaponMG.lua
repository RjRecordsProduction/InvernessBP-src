local VehicleWeaponMG = {}
local GameplayStatics = import("GameplayStatics")
local UAkGameplayStatics = import("AkGameplayStatics")
local ECollisionEnabled = import("ECollisionEnabled")
local EnquipTime = 0.7
function VehicleWeaponMG:ctor(SelfType)
  self.bEquipActionState = false
  self.bIsDoUnEquipAction = false
end
function VehicleWeaponMG:ReceiveBeginPlay()
  VehicleWeaponMG.__super.ReceiveBeginPlay(self)
  if Client then
    self:AddControlEvent(self, "OnWeaponShootDelegate", self.OnWeaponShootDelegate_Handle, self)
  end
  self.SkeletalMesh.BoundsScale = 5
  self.VehicleWeaponItemType = 1
end
function VehicleWeaponMG:OnWeaponShootDelegate_Handle()
  local uWeaponOverHeating = self.WeaponOverHeating
  if not slua.isValid(uWeaponOverHeating) then
    return
  end
  if uWeaponOverHeating.MaxTemperature == 0 then
    return
  end
  local rtpc_value = uWeaponOverHeating.CurrentTemperature / uWeaponOverHeating.MaxTemperature
  print(bWriteLog and "VehicleWeaponMG:SetRTPCValue ", rtpc_value)
  UAkGameplayStatics.SetRTPCValue("Vehicle_Tank_MG3_Velocity", rtpc_value, 0, nil)
end
function VehicleWeaponMG:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "bEquipActionState",
      ELifetimeCondition.COND_SimulatedOnly,
      UEnums.EPropertyClass.Bool
    }
  }
end
function VehicleWeaponMG:DoUsedOrNotBP(uCharacter, bUsed)
  print(bWriteLog and "VehicleWeaponMG:DoUsedOrNotBP")
  local ENetRole = import("ENetRole")
  self.bIsDoUnEquipAction = false
  if not slua.isValid(uCharacter) then
    return
  end
  local uVehicle = self:GetOwnerVehicle()
  if not slua.isValid(uVehicle) then
    return
  end
  if self.Role == ENetRole.ROLE_Authority then
    self.bEquipActionState = bUsed
    local uCharacterAvatarComp = uCharacter:getAvatarComponent2()
    if slua.isValid(uCharacterAvatarComp) then
      local EAvatarSlotType = import("EAvatarSlotType")
      if bUsed then
        if uVehicle.ShowOnTank then
          uVehicle:ShowOnTank(uCharacter)
        end
      else
        if uVehicle.HideOnTank then
          uVehicle:HideOnTank(uCharacter)
        end
        local EForceHideState = import("EForceHideState")
        local EForceHideStateReason = import("EForceHideStateReason")
        uCharacterAvatarComp:SetForceHideState(8, EForceHideState.None, EForceHideStateReason.Server_InTank)
      end
    end
  else
    if self.SkeletalMesh then
      self.SkeletalMesh.bNoSkeletonUpdate = false
    end
    if bUsed then
      local uAnimInstances = uCharacter.Mesh:GetSubAnimInstances()
      for i = 1, uAnimInstances:Num() do
        local uAnimInst = uAnimInstances:Get(i - 1)
        if uAnimInst.PlayWeaponUnEquipMontage then
          uAnimInst:PlayWeaponEquipMontage()
        end
      end
      local uLocalControl = uCharacter:GetPlayerControllerSafety()
      if slua.isValid(uLocalControl) and self.BoxCollison then
        self.BoxCollison:SetCollisionEnabled(ECollisionEnabled.NoCollision)
      end
    else
      local uLocalControl = uCharacter:GetPlayerControllerSafety()
      if slua.isValid(uLocalControl) and self.BoxCollison then
        self.BoxCollison:SetCollisionEnabled(ECollisionEnabled.QueryAndPhysics)
      end
    end
  end
end
function VehicleWeaponMG:DoVehicleWeaponEquipActionBP(bEquip)
  self.bEquipActionState = bEquip
  self:ForceNetUpdate()
end
function VehicleWeaponMG:OnRep_bEquipActionState()
  print(bWriteLog and "OnRep_bEquipActionState")
  local uCharacter = self:GetOwnerActor()
  if not self.bEquipActionState then
    self:UnEquipAction()
  end
end
function VehicleWeaponMG:UnEquipAction()
  local uCharacter = self:GetOwnerActor()
  if slua.isValid(uCharacter) and not self.bEquipActionState then
    local uAnimInstances = uCharacter.Mesh:GetSubAnimInstances()
    for i = 1, uAnimInstances:Num() do
      local uAnimInst = uAnimInstances:Get(i - 1)
      if uAnimInst.PlayWeaponUnEquipMontage then
        self.bIsDoUnEquipAction = true
        uAnimInst:PlayWeaponUnEquipMontage()
      end
    end
  end
end
function VehicleWeaponMG:StartFireFilter()
  local uVehicle = self:GetOwnerVehicle()
  if self.LastUseTimeStamp and GameplayStatics.GetTimeSeconds(CGameWorld) - self.LastUseTimeStamp > EnquipTime and not self.bIsDoUnEquipAction then
    return self.Super:StartFireFilter()
  else
    return false
  end
end
function VehicleWeaponMG:StartScopeFilter()
  if self.LastUseTimeStamp and GameplayStatics.GetTimeSeconds(CGameWorld) - self.LastUseTimeStamp > EnquipTime and not self.bIsDoUnEquipAction then
    return self.Super:StartScopeFilter()
  else
    return false
  end
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
return class(CActorBase, nil, VehicleWeaponMG)