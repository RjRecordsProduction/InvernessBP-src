local LeaveBikeFeature = {}
local KismetSystemLibrary = import("KismetSystemLibrary")
local STExtraGameplayStatics = import("STExtraGameplayStatics")
local KismetMathLibrary = import("KismetMathLibrary")
function LeaveBikeFeature:ctor()
end
function LeaveBikeFeature:_PostConstruct()
  LeaveBikeFeature.__super._PostConstruct(self)
end
function LeaveBikeFeature:IsLeavePositionValid(Character, EnterPos, LeavePos, ForceUseLineTrace, IgnoreVehicle)
  if not (slua.isValid(self.Owner.Object) and slua.isValid(Character)) or not slua.isValid(Character.CapsuleComponent) then
    return false
  end
  local OwnerVehicle = self.Owner:GetOwner()
  if not slua.isValid(OwnerVehicle) then
    return false
  end
  if self.Owner.bCheckValidLeaveLocationBySweep and not ForceUseLineTrace then
    local ActorsToIgnore = slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
    ActorsToIgnore:Add(OwnerVehicle)
    ActorsToIgnore:Add(Character)
    local uPlayerController = Character:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      local uVehicleUser = uPlayerController:GetVehicleUserComp()
      if slua.isValid(uVehicleUser) and uVehicleUser.SvrLeaveVehicleSnapshot.bPenetrationPhysicsVehicleFlag then
        for _, uIgnoreActor in pairs(uVehicleUser.SvrLeaveVehicleSnapshot.CacheIgnoreActors) do
          if slua.isValid(uIgnoreActor) then
            ActorsToIgnore:Add(uIgnoreActor)
          end
        end
      end
    end
    local StartPos = OwnerVehicle:GetPhysicsBoundsCenter(true)
    if STExtraGameplayStatics.LineTraceTestByProfile(Character, StartPos, LeavePos, "Pawn", ActorsToIgnore) then
      print(bWriteLog and string.format("VehicleSeat LeaveBikeFeature:IsLeavePositionValid() 0 check LineTrace from StartPos to LeavePos failed."))
      return false
    end
    local CapsuleRadius = Character.CapsuleComponent:GetScaledCapsuleRadius()
    local CapsuleHalfHeight = Character.CapsuleComponent:GetScaledCapsuleHalfHeight()
    StartPos = FVector(EnterPos.X, EnterPos.Y, EnterPos.Z + CapsuleHalfHeight)
    local BlockingHit, HitResult = KismetSystemLibrary.CapsuleTraceSingleByProfile(Character, StartPos, LeavePos, CapsuleRadius, CapsuleHalfHeight, "Pawn", true, ActorsToIgnore, 0, import("/Script/Engine.HitResult")(), true, FLinearColor.Red, FLinearColor.Green, 5.0)
    if HitResult.bBlockingHit and not HitResult.bStartPenetrating then
      print(bWriteLog and string.format("VehicleSeat LeaveBikeFeature:IsLeavePositionValid() 1 check CapsuleTrace from StartPos to LeavePos failed."))
      return false
    elseif HitResult.bStartPenetrating then
      local Direction = LeavePos - StartPos
      Direction = FVector(Direction.X, Direction.Y, 0)
      if Direction:IsNearlyZero(0.01) then
        print(bWriteLog and string.format("VehicleSeat LeaveBikeFeature:IsLeavePositionValid() 1-1 failed."))
        return false
      end
      Direction:Normalize(0.01)
      StartPos = StartPos + Direction * CapsuleRadius
      local BoundsCenter = OwnerVehicle:GetPhysicsBoundsCenter(true)
      local BlockingHit2, _ = KismetSystemLibrary.LineTraceSingleByProfile(Character, BoundsCenter, StartPos, "Pawn", true, ActorsToIgnore, 0, import("/Script/Engine.HitResult")(), true, FLinearColor.Red, FLinearColor.Green, 5.0)
      if BlockingHit2 then
        print(bWriteLog and string.format("VehicleSeat LeaveBikeFeature:IsLeavePositionValid() 2 check LineTrace from BoundsCenter to StartPos failed."))
        return false
      end
      local BlockingHit3, HitResult3 = KismetSystemLibrary.CapsuleTraceSingleByProfile(Character, StartPos, LeavePos, CapsuleRadius, CapsuleHalfHeight, "Pawn", true, ActorsToIgnore, 0, import("/Script/Engine.HitResult")(), true, FLinearColor.Red, FLinearColor.Green, 5.0)
      if BlockingHit3 and not HitResult3.bStartPenetrating then
        print(bWriteLog and string.format("VehicleSeat LeaveBikeFeature:IsLeavePositionValid() 3 check CapsuleTrace from StartPos to LeavePos failed."))
        return false
      end
    end
  end
  local LeaveVehicleConfig = require("GameLua.GameCore.Module.Vehicle.Config.LeaveVehicleConfig")
  local SpecificConfig = LeaveVehicleConfig.GetConfig(OwnerVehicle.VehicleShapeType)
  if SpecificConfig and SpecificConfig.bCheckRollPassWall then
    local CurrentRotation = OwnerVehicle:K2_GetActorRotation()
    local Rotation = KismetMathLibrary.MakeRotFromXZ(OwnerVehicle:GetActorForwardVector(), FVector(0, 0, 1))
    local Location = OwnerVehicle:K2_GetActorLocation()
    local Center = OwnerVehicle:GetPhysicsBoundsCenter(true)
    local StandCenter = FVector(0, 0, 0)
    StandCenter, Rotation = OwnerVehicle:CalcPhysicsBounds(StandCenter, Rotation, FTransform(Rotation, Location, FVector(1, 1, 1)), true)
    local ActorsToIgnore = OwnerVehicle:GetQueryIgnoreActors()
    if STExtraGameplayStatics.LineTraceTestByProfile(Character, StandCenter, Center, "Pawn", ActorsToIgnore) then
      print(bWriteLog and string.format("VehicleSeat LeaveBikeFeature:IsLeavePositionValid() 4 failed."))
      return false
    end
  end
  return true
end
local class = require("class")
local CFeature = require("GameLua.Mod.BaseMod.Gameplay.Feature.Common.FeatureBase")
return class(CFeature, nil, LeaveBikeFeature)