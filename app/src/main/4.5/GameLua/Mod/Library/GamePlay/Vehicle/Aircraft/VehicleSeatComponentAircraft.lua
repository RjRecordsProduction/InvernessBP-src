local VehicleSeatComponentAircraft = {}
local STExtraGameplayStatics = import("STExtraGameplayStatics")
local ECollisionChannel = import("ECollisionChannel")
function VehicleSeatComponentAircraft:ctor(SelfType)
  self.MaxHeightToLeave = 15
  self.FailTips_OverMaxHeight = 30169
  self.CanEject = false
  self.HeightToEject = 15
  self.CanOpenParachuteHeight = 100
  self.ForceOpenParachuteHeight = 50
  self.CloseParachuteHeight = 10
end
function VehicleSeatComponentAircraft:_PostConstruct()
  VehicleSeatComponentAircraft.__super._PostConstruct(self)
  self:AddControlEvent(self, "EndExitVehicleEvent", self.OnEndExitVehicle, self)
  local OwnerVehicle = self:GetOwner()
  if slua.isValid(OwnerVehicle) then
    self:AddControlEvent(OwnerVehicle, "OnVehicleHealthStateChanged", self.OnVehicleHealthStateChange, self)
  end
end
function VehicleSeatComponentAircraft:CanExitVehicleEx(InCharacter)
  local Aircraft = self:GetOwner()
  if not slua.isValid(InCharacter) or not slua.isValid(Aircraft) then
    return false
  end
  if self.MaxHeightToLeave > 0 then
    local IgnoredActors = Aircraft:GetQueryIgnoreActors()
    local StartPos = Aircraft:GetPhysicsBoundsCenter(true)
    local EndPos = StartPos - FVector(0, 0, self.MaxHeightToLeave * 100)
    if not STExtraGameplayStatics.LineTraceTestByProfile(Aircraft, StartPos, EndPos, "Vehicle", IgnoredActors) and not self:NeedEject() then
      local Controller = InCharacter:GetPlayerControllerSafety()
      if slua.isValid(Controller) then
        Controller:DisplayGameTipWithMsgID(self.FailTips_OverMaxHeight)
      end
      return false
    end
  end
  return true
end
function VehicleSeatComponentAircraft:OnVehicleHealthStateChange()
  if not slua.isValid(self.Object) then
    return
  end
  local OwnerVehicle = self:GetOwner()
  if not slua.isValid(OwnerVehicle) then
    return
  end
  if OwnerVehicle:IsDestroyed() then
    self.MaxHeightToLeave = 0
    self.CanEject = true
  end
end
function VehicleSeatComponentAircraft:OnEndExitVehicle(Character, SeatType)
  if slua.isValid(self.Object) and slua.isValid(Character) and not self:HasCharacter(Character) and self:NeedEject() then
    print(bWriteLog and "VehicleSeatComponentAircraft:OnEndExitVehicle, character start parachute", self:GetOwner(), Character)
    local Controller = Character:GetPlayerControllerSafety()
    if slua.isValid(Controller) then
      Controller.PlaneFlyHeightFromGameMode = Character:K2_GetActorLocation().Z
      Controller.CanOpenParachuteHeight = self.CanOpenParachuteHeight * 100
      Controller.ForceOpenParachuteHeight = self.ForceOpenParachuteHeight * 100
      Controller.CloseParachuteHeight = self.CloseParachuteHeight * 100
      local EStateType = import("EStateType")
      Controller:ReInitParachuteItem()
      Controller:ServerChangeStatePC(EStateType.State_ParachuteJump)
    end
  end
end
function VehicleSeatComponentAircraft:NeedEject()
  if not self.CanEject then
    return false
  end
  local MyOwner = self:GetOwner()
  if not slua.isValid(MyOwner) then
    return false
  end
  if self.HeightToEject and self.HeightToEject > 0 then
    local IgnoredActors = MyOwner:GetQueryIgnoreActors()
    local StartPos = MyOwner:GetPhysicsBoundsCenter(true)
    local EndPos = StartPos - FVector(0, 0, self.HeightToEject * 100)
    return not STExtraGameplayStatics.LineTraceTestByProfile(MyOwner, StartPos, EndPos, "Vehicle", IgnoredActors)
  end
  return false
end
local class = require("class")
local CVehicleSeatComponent = require("GameLua.GameCore.Module.Vehicle.Component.VehicleSeatComponent")
return class(CVehicleSeatComponent, nil, VehicleSeatComponentAircraft)