local UKismetMathLibrary = import("KismetMathLibrary")
local LightningRushConfig = require("GameLua.ExtraModule.SkillCore.Gameplay.LightningRush.LightningRushConfig")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local UGameplayStatics = import("GameplayStatics")
local Skill_LightningRush_Inst = {
  Inst = {}
}
local USkillUtils = import("SkillUtils")
function Skill_LightningRush_Inst:CheckCanUse()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return false
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return false
  end
  print(bWriteLog and "Skill_LightningRush_Inst:CheckCanUse")
  return true
end
function Skill_LightningRush_Inst:PickTargetLocation()
  print(bWriteLog and "Skill_LightningRush_Inst:PickTargetLocation")
  if not slua.isValid(self.SpecificSkillCompRef) then
    return
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return
  end
  if not slua.isValid(uOwner.CapsuleComponent) then
    return
  end
  if not uOwner:HasAuthority() then
    return
  end
  local TraceDistance = 5000
  local ControlRotation = uOwner:GetControlRotation()
  local StartLoc = uOwner:GetSpringArmLocation()
  local EndLoc = StartLoc + ControlRotation:Vector() * TraceDistance
  local bHit = false
  local FHitResult = import("/Script/Engine.HitResult")
  local uHitResult = FHitResult()
  local ShapeZRate = 0
  local ShapeInflation = 2
  local HalfHeight = uOwner.CapsuleComponent:GetScaledCapsuleHalfHeight() + ShapeInflation
  local HalfRadius = uOwner.CapsuleComponent:GetScaledCapsuleRadius() + ShapeInflation
  bHit, uHitResult = USkillUtils.IsMoveActorLineBlock(uOwner, uOwner, StartLoc, EndLoc, ShapeZRate, uHitResult)
  if bHit then
    local HitPos = FVector(uHitResult.Location.X, uHitResult.Location.Y, uHitResult.Location.Z)
    local HitNormal = FVector(uHitResult.Normal.X, uHitResult.Normal.Y, uHitResult.Normal.Z)
    local HitOffset = FVector(HitNormal.X * HalfRadius, HitNormal.Y * HalfRadius, HitNormal.Z * HalfHeight)
    EndLoc = HitPos + HitOffset
    print(bWriteLog and string.format("Skill_LightningRush_Inst:PickTargetLocation bHit! Actor:%s Loc:%s HitNormal:%s", tostring(uHitResult.Actor), HitPos:ToString(), HitNormal:ToString()))
  end
  self.SpecificSkillCompRef:SetValueAsVector(self.SkillID, "OriginLoc", StartLoc)
  self.SpecificSkillCompRef:SetValueAsVector(self.SkillID, "TargetLocation", EndLoc)
  print(bWriteLog and string.format("Skill_LightningRush_Inst:PickTargetLocation TargetLocation:%s", EndLoc:ToString()))
end
function Skill_LightningRush_Inst:PrepareData()
  print(bWriteLog and "Skill_LightningRush_Inst:PrepareData")
  if not slua.isValid(self.SpecificSkillCompRef) then
    return
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return
  end
  print(bWriteLog and "Skill_LightningRush_Inst:PrepareData")
  local InputDir = uOwner:GetMoveInputState()
  InputDir.Z = 0
  if InputDir:IsNearlyZero(1.0E-4) then
    InputDir.X = 1
  end
  local DirToSprintType = {
    [0] = {
      [0] = 0,
      [1] = 1,
      [-1] = 5
    },
    [1] = {
      [0] = 3,
      [1] = 2,
      [-1] = 4
    },
    [-1] = {
      [0] = 7,
      [1] = 8,
      [-1] = 6
    }
  }
  local Local  local X = UKismetMathLibrary.FClamp(0 < LocalInputDir.X and math.floor(LocalInputDir.X + 0.5) or math.ceil(LocalInputDir.X - 0.5), -1, 1)
  local Y = UKismetMathLibrary.FClamp(0 < LocalInputDir.Y and math.floor(LocalInputDir.Y + 0.5) or math.ceil(LocalInputDir.Y - 0.5), -1, 1)
  local SprintType = DirToSprintType[Y][X]
  self.SpecificSkillCompRef:SetValueAsInt(self.SkillID, "SprintType", SprintType)
  local TargetLocation = self.SpecificSkillCompRef:GetValueAsVector(self.SkillID, "TargetLocation")
  local LocalMoveVector = InputDir:GetSafeNormal(0.001)
  local StartLoc = uOwner:GetSpringArmLocation()
  local ViewDir = TargetLocation - StartLoc
  local ViewRotation = ViewDir:Rotation()
  local ViewTransform = UKismetMathLibrary.MakeTransform(StartLoc, ViewRotation, FVector.OneVector)
  local MoveDirection = ViewTransform:TransformVector(LocalMoveVector)
  self.SpecificSkillCompRef:SetValueAsFloat(self.SkillID, "DirectionX", MoveDirection.X)
  self.SpecificSkillCompRef:SetValueAsFloat(self.SkillID, "DirectionY", MoveDirection.Y)
  self.SpecificSkillCompRef:SetValueAsFloat(self.SkillID, "DirectionZ", MoveDirection.Z)
  print(bWriteLog and string.format("Skill_LightningRush_Inst:PrepareData MoveDirection:%s", MoveDirection:ToString()))
end
function Skill_LightningRush_Inst:StartMove()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return
  end
  local uMovementComponent = uOwner.STCharacterMovement
  if not slua.isValid(uMovementComponent) then
    return
  end
  local OriginLoc = self.SpecificSkillCompRef:GetValueAsVector(self.SkillID, "OriginLoc")
  local OwnerLocation = uOwner:K2_GetActorLocation()
  local OwnerRotation = uOwner:K2_GetActorRotation()
  local LocDiff = OriginLoc - OwnerLocation
  uMovementComponent:K2_MoveUpdatedComponent(LocDiff, OwnerRotation, nil, true, false)
  print(bWriteLog and string.format("Skill_LightningRush_Inst:StartMove OriginLoc:%s", OriginLoc:ToString()))
end
function Skill_LightningRush_Inst:AdjustPosition()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return
  end
  if not slua.isValid(uOwner.CapsuleComponent) then
    return
  end
  local DirectionX = self.SpecificSkillCompRef:GetValueAsFloat(self.SkillID, "DirectionX")
  local DirectionY = self.SpecificSkillCompRef:GetValueAsFloat(self.SkillID, "DirectionY")
  local DirectionZ = self.SpecificSkillCompRef:GetValueAsFloat(self.SkillID, "DirectionZ")
  local MoveDirection = FVector(DirectionX, DirectionY, DirectionZ)
  local CurLoc = uOwner:K2_GetActorLocation()
  local NewLoc = CurLoc
  local ShapeInflation = 0
  local HalfHeight = uOwner.CapsuleComponent:GetScaledCapsuleHalfHeight() + ShapeInflation
  local HalfRadius = uOwner.CapsuleComponent:GetScaledCapsuleRadius() + ShapeInflation
  local bHit = false
  local FHitResult = import("/Script/Engine.HitResult")
  local uHitResult = FHitResult()
  local ShapeZRate = 0
  local TraceEndLoc = CurLoc - FVector(0, 0, HalfHeight)
  bHit, uHitResult = USkillUtils.IsMoveActorLineBlock(uOwner, uOwner, CurLoc, TraceEndLoc, ShapeZRate, uHitResult)
  if bHit then
    local HitPos = FVector(uHitResult.Location.X, uHitResult.Location.Y, uHitResult.Location.Z)
    NewLoc = HitPos + FVector(0, 0, 0 + HalfHeight)
    if not Client then
      local USTExtraGameplayStatics = import("STExtraGameplayStatics")
      local DrawDebugTime = 3
      USTExtraGameplayStatics.ClientDrawDebugCapsule(NewLoc, HalfHeight, HalfRadius, uOwner:K2_GetActorRotation(), FLinearColor.Blue, DrawDebugTime, 1)
      USTExtraGameplayStatics.ClientDrawDebugCapsule(CurLoc, HalfHeight, HalfRadius, uOwner:K2_GetActorRotation(), FLinearColor.Red, DrawDebugTime, 1)
      USTExtraGameplayStatics.ClientDrawDebugLine(HitPos, NewLoc, FLinearColor.Red, DrawDebugTime, 1)
    end
  end
  local FResolvePenetrationParams = import("/Script/ShadowTrackerExtra.ResolvePenetrationParams")
  local SafetyResolveParams = FResolvePenetrationParams()
  SafetyResolveParams.bLineTracePassWall = true
  SafetyResolveParams.BackDir = FVector(-MoveDirection.X, -MoveDirection.Y, -MoveDirection.Z)
  SafetyResolveParams.IterationBackDir = 10
  SafetyResolveParams.AdjustRadius = 100
  SafetyResolveParams.bRaiseUpAdjust = false
  SafetyResolveParams.IterationRounds = 0
  local bSucc = uOwner:SetActorLocationSafetyWithParams(NewLoc, SafetyResolveParams)
  print(bWriteLog and string.format("Skill_LightningRush_Inst:AdjustPosition NewLoc:%s CurLoc:%s bSucc:%s", NewLoc:ToString(), CurLoc:ToString(), tostring(bSucc)))
end
function Skill_LightningRush_Inst:StopAndTriggerCombo()
  print(bWriteLog and "Skill_LightningRush_Inst:StopAndTriggerCombo")
  if not slua.isValid(self.SpecificSkillCompRef) then
    return
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return
  end
  if not uOwner:HasAuthority() then
    return
  end
  local UTSkillStopReason = import("UTSkillStopReason")
  self.SpecificSkillCompRef:StopSkill(self.SkillID, UTSkillStopReason.SkillStopReason_Finished)
  Game:SetSkillBlackboardValue(uOwner, self.SkillID, UEnums.EBlackBoardKeyType.Bool, "bIsCombo", true)
  uOwner:TriggerEntrySkillWithParams(self.SkillID, {"bIsCombo"}, true)
  print(bWriteLog and string.format("Skill_LightningRush_Inst:StopAndTriggerCombo SkillID:%d", self.SkillID))
end
function Skill_LightningRush_Inst:ClientNotifySkillEnding()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return
  end
  uOwner.TrialFeature:ClientNotifySkillEnding()
end
function Skill_LightningRush_Inst:ShowSkillActor()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return false
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return false
  end
  if not Client then
    return
  end
  print(bWriteLog and "Skill_LightningRush_Inst:ShowSkillActor")
  local uSkillActor = GamePlayTools.GetAttachedActorByTag(uOwner, "LightningRushActor")
  if not slua.isValid(uSkillActor) then
    print(bWriteLog and "Skill_LightningRush_Inst:ShowSkillActor uSkillActor is nil")
    return
  end
  uSkillActor:Equip()
end
function Skill_LightningRush_Inst:HideSkillActor()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return false
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return false
  end
  if not Client then
    return
  end
  print(bWriteLog and "Skill_LightningRush_Inst:HideSkillActor")
  local uSkillActor = GamePlayTools.GetAttachedActorByTag(uOwner, "LightningRushActor")
  if not slua.isValid(uSkillActor) then
    print(bWriteLog and "Skill_LightningRush_Inst:ShowSkillActor uSkillActor is nil")
    return
  end
  uSkillActor:Unequip()
end
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkill_LightningRush_Inst = class(CSkillActorBase, nil, Skill_LightningRush_Inst)
return CSkill_LightningRush_Inst