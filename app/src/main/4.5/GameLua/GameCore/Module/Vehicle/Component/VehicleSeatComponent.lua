local VehicleSeatComponent = {
  LuaEventContainer = {
    "OnEnterVehicle",
    "OnExitVehicle",
    "OnChangeSeat"
  }
}
local ECollisionChannel = import("ECollisionChannel")
local ECollisionResponse = import("ECollisionResponse")
local KismetSystemLibrary = import("KismetSystemLibrary")
local KismetMathLibrary = import("KismetMathLibrary")
local STExtraGameplayStatics = import("STExtraGameplayStatics")
local ESTExtraVehicleType = import("ESTExtraVehicleType")
function VehicleSeatComponent:IsLeavePositionValid(Character, EnterPos, LeavePos, ForceUseLineTrace, IgnoreVehicle)
  if not slua.isValid(self.Object) then
    return false
  end
  local MyOwner = self:GetOwner()
  if not (slua.isValid(MyOwner) and slua.isValid(Character)) or not slua.isValid(Character.CapsuleComponent) then
    return false
  end
  if MyOwner.VehicleType == ESTExtraVehicleType.VT_UH60 or MyOwner.VehicleType == ESTExtraVehicleType.VT_Motorglider or MyOwner.VehicleType == ESTExtraVehicleType.VT_Fighter then
    local TraceStart = LeavePos
    local TraceEnd = LeavePos + FVector(0, 0, 1000)
    local TraceHitInfo = import("/Script/Engine.HitResult")()
    local CapsuleRadius = Character.CapsuleComponent:GetScaledCapsuleRadius() * 2
    local CapsuleHalfHeight = Character.CapsuleComponent:GetScaledCapsuleHalfHeight()
    local BlockingHit, HitResult = KismetSystemLibrary.CapsuleTraceSingleForObjects(Character, TraceStart, TraceEnd, CapsuleRadius, CapsuleHalfHeight, {
      Game:ConvertToObjectType(ECollisionChannel.ECC_Vehicle)
    }, true, nil, 0, TraceHitInfo, true, FLinearColor.Red, FLinearColor.Green, 5.0)
    print(bWriteLog and string.format("VehicleSeatComponent:IsLeavePositionValid 1 bHit:%s Hit:%s", tostring(BlockingHit), Game:GetObjName(HitResult.Actor)))
    if BlockingHit and slua.isValid(HitResult.Actor) and Game:IsVehicle(HitResult.Actor) and HitResult.Actor == MyOwner then
      return false
    end
  end
  return true
end
function VehicleSeatComponent:OnEnterVehicleExt(InCharacter, InSeatType, InSeatIndex)
  if not slua.isValid(self.Object) or not slua.isValid(InCharacter) then
    return
  end
  self:LuaBroadcast("OnEnterVehicle", InCharacter, InSeatType, InSeatIndex)
end
function VehicleSeatComponent:OnExitVehicleExt(InCharacter, InSeatType, InSeatIndex)
  if not slua.isValid(self.Object) or not slua.isValid(InCharacter) then
    return
  end
  self:LuaBroadcast("OnExitVehicle", InCharacter, InSeatType, InSeatIndex)
end
function VehicleSeatComponent:OnChangeSeatExt(InCharacter, InSeatType, InSeatIndex)
  if not slua.isValid(self.Object) or not slua.isValid(InCharacter) then
    return
  end
  self:LuaBroadcast("OnChangeSeat", InCharacter, InSeatType, InSeatIndex)
end
function VehicleSeatComponent:BPIsSeatAllowWeapon(TestType, SeatIdx)
  return true
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
return class(CDelegateContainer, nil, VehicleSeatComponent)