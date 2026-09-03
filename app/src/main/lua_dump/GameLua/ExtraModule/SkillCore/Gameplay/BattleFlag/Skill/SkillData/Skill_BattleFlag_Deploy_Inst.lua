local BattleFlagConfig = require("GameLua.ExtraModule.SkillCore.Gameplay.BattleFlag.BattleFlagConfig")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local USTExtraGameplayStatics = import("STExtraGameplayStatics")
local ECollisionChannel = import("ECollisionChannel")
local EDrawDebugTrace = import("EDrawDebugTrace")
local UKismetMathLibrary = import("KismetMathLibrary")
local Skill_BattleFlag_Deploy_Inst = {
  Inst = {}
}
local DeployCheckConfig = {
  ForwardOffset = FVector(44.965, 42.994999, 28.654999),
  MaxHeightDiff = 50,
  GroundTraceDepth = 1000,
  BoxOverlapUpOffset = 120,
  BoxHalfExtent = FVector(50, 50, 80),
  BoxTraceDir = FVector(1, 0, 0),
  MinDeployDist = 1000,
  SpawnUpOffset = 118.80881,
  TipTextID = 69956,
  bDrawDebug = true
}
function Skill_BattleFlag_Deploy_Inst:CheckCanUse()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return false
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return false
  end
  print(bWriteLog and "Skill_BattleFlag_Deploy_Inst:CheckCanUse")
  if not uOwner:HasAuthority() then
    return true
  end
  local OwnerLocation = uOwner:K2_GetActorLocation()
  local Offset = DeployCheckConfig.ForwardOffset
  local ActorTransform = uOwner:GetTransform()
  local TargetLocation = ActorTransform:TransformPosition(Offset)
  local Actor_C = import("/Script/Engine.Actor")
  local ActorsToIgnore = slua.Array(UEnums.EPropertyClass.Object, Actor_C)
  ActorsToIgnore:Add(uOwner)
  local TraceType = Game:ConvertToTraceType(ECollisionChannel.ECC_Visibility)
  local uHitResult = import("/Script/Engine.HitResult")()
  local bForwardHit, uForwardHitResult = UKismetSystemLibrary.LineTraceSingle(uOwner, OwnerLocation, TargetLocation, TraceType, true, ActorsToIgnore, 0, uHitResult, true, FLinearColor.Red, FLinearColor.Green, 0.0)
  if DeployCheckConfig.bDrawDebug then
    USTExtraGameplayStatics.ClientDrawDebugLine(OwnerLocation, TargetLocation, bForwardHit and FLinearColor.Red or FLinearColor.Green, 3, 2)
  end
  if bForwardHit then
    if DeployCheckConfig.bDrawDebug then
      USTExtraGameplayStatics.ClientDrawDebugPoint(FVector(uForwardHitResult.ImpactPoint.X, uForwardHitResult.ImpactPoint.Y, uForwardHitResult.ImpactPoint.Z), 20, FLinearColor.Red, 3)
    end
    print(bWriteLog and "Skill_BattleFlag_Deploy_Inst:CheckCanUse Fail - Forward trace blocked")
    local uPlayerController = uOwner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      IngameTipsTools.BattleNormalTipsByTextID(DeployCheckConfig.TipTextID, "", "", nil, uPlayerController.PlayerKey, false)
    end
    return false
  end
  local GroundTraceStart = TargetLocation
  local GroundTraceEnd = TargetLocation - FVector(0, 0, DeployCheckConfig.GroundTraceDepth)
  local uGroundHitResult = import("/Script/Engine.HitResult")()
  local bGroundHit, uGroundHitResult = UKismetSystemLibrary.LineTraceSingle(uOwner, GroundTraceStart, GroundTraceEnd, TraceType, true, ActorsToIgnore, 0, uGroundHitResult, true, FLinearColor.Red, FLinearColor.Green, 0.0)
  if DeployCheckConfig.bDrawDebug then
    USTExtraGameplayStatics.ClientDrawDebugLine(GroundTraceStart, GroundTraceEnd, bGroundHit and FLinearColor.Green or FLinearColor.Red, 3, 2)
  end
  if not bGroundHit then
    print(bWriteLog and "Skill_BattleFlag_Deploy_Inst:CheckCanUse Fail - No ground detected")
    local uPlayerController = uOwner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      IngameTipsTools.BattleNormalTipsByTextID(DeployCheckConfig.TipTextID, "", "", nil, uPlayerController.PlayerKey, false)
    end
    return false
  end
  local uGroundHitActor = uGroundHitResult.Actor
  if slua.isValid(uGroundHitActor) then
    local ASTExtraVehicleBase = import("STExtraVehicleBase")
    if Game:IsClassOf(uGroundHitActor, ASTExtraVehicleBase) then
      print(bWriteLog and "Skill_BattleFlag_Deploy_Inst:CheckCanUse Fail - Ground hit actor is a vehicle")
      local uPlayerController = uOwner:GetPlayerControllerSafety()
      if slua.isValid(uPlayerController) then
        IngameTipsTools.BattleNormalTipsByTextID(DeployCheckConfig.TipTextID, "", "", nil, uPlayerController.PlayerKey, false)
      end
      return false
    end
  end
  local HitLocation = FVector(uGroundHitResult.ImpactPoint.X, uGroundHitResult.ImpactPoint.Y, uGroundHitResult.ImpactPoint.Z)
  local WaterHeight = 0.0
  local bIsInWater, WaterHeight = USTExtraGameplayStatics.IsLocationInWater(uOwner, HitLocation, WaterHeight)
  if bIsInWater then
    print(bWriteLog and string.format("Skill_BattleFlag_Deploy_Inst:CheckCanUse Fail - Hit location is in water, WaterHeight:%.1f", WaterHeight))
    local uPlayerController = uOwner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      IngameTipsTools.BattleNormalTipsByTextID(DeployCheckConfig.TipTextID, "", "", nil, uPlayerController.PlayerKey, false)
    end
    return false
  end
  if DeployCheckConfig.bDrawDebug then
    USTExtraGameplayStatics.ClientDrawDebugPoint(HitLocation, 20, FLinearColor.Green, 3)
  end
  local HeightDiff = UKismetMathLibrary.Abs(OwnerLocation.Z - 88 - HitLocation.Z)
  if HeightDiff > DeployCheckConfig.MaxHeightDiff then
    print(bWriteLog and string.format("Skill_BattleFlag_Deploy_Inst:CheckCanUse Fail - Height diff too large: %.1f", HeightDiff))
    local uPlayerController = uOwner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      IngameTipsTools.BattleNormalTipsByTextID(DeployCheckConfig.TipTextID, "", "", nil, uPlayerController.PlayerKey, false)
    end
    return false
  end
  local uHitComp = uGroundHitResult.Component
  if slua.isValid(uHitComp) and uHitComp:ComponentHasTag("MoveablePlatform") then
    print(bWriteLog and "Skill_BattleFlag_Deploy_Inst:CheckCanUse Fail - Hit component is a moveable platform")
    local uPlayerController = uOwner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      IngameTipsTools.BattleNormalTipsByTextID(DeployCheckConfig.TipTextID, "", "", nil, uPlayerController.PlayerKey, false)
    end
    return false
  end
  local uAllFlags = ActorTools.GetAllActors(uOwner, BattleFlagConfig.BattleFlagActorBPPath)
  if uAllFlags then
    local MinDistSqr = DeployCheckConfig.MinDeployDist * DeployCheckConfig.MinDeployDist
    local NearestDistSqr = math.huge
    for _, uFlag in pairs(uAllFlags) do
      if slua.isValid(uFlag) then
        local FlagLocation = uFlag:K2_GetActorLocation()
        local DiffX = HitLocation.X - FlagLocation.X
        local DiffY = HitLocation.Y - FlagLocation.Y
        local DiffZ = HitLocation.Z - FlagLocation.Z
        local DistSqr = DiffX * DiffX + DiffY * DiffY + DiffZ * DiffZ
        if NearestDistSqr > DistSqr then
          Nearest        end
      end
    end
    if MinDistSqr > NearestDistSqr then
      print(bWriteLog and string.format("Skill_BattleFlag_Deploy_Inst:CheckCanUse Fail - Too close to existing battle flag, dist:%.1f minDist:%d", math.sqrt(NearestDistSqr), DeployCheckConfig.MinDeployDist))
      local uPlayerController = uOwner:GetPlayerControllerSafety()
      if slua.isValid(uPlayerController) then
        IngameTipsTools.BattleNormalTipsByTextID(DeployCheckConfig.TipTextID, "", "", nil, uPlayerController.PlayerKey, false)
      end
      return false
    end
  end
  local BoxCenter = HitLocation + FVector(0, 0, DeployCheckConfig.BoxOverlapUpOffset)
  local ActorTransform = uOwner:GetTransform()
  local TraceEnd = BoxCenter + ActorTransform:TransformVector(DeployCheckConfig.BoxTraceDir)
  local uBoxHitResult = import("/Script/Engine.HitResult")()
  local bBoxHit, uBoxHitResult = UKismetSystemLibrary.BoxTraceSingle(uOwner, BoxCenter, TraceEnd, DeployCheckConfig.BoxHalfExtent, FRotator(0, 0, 0), TraceType, true, ActorsToIgnore, EDrawDebugTrace.None, uBoxHitResult, true, FLinearColor.Red, FLinearColor.Green, 0)
  if DeployCheckConfig.bDrawDebug then
    USTExtraGameplayStatics.ClientDrawDebugBox(BoxCenter, DeployCheckConfig.BoxHalfExtent, bBoxHit and FLinearColor.Red or FLinearColor.Green, FRotator(0, 0, 0), 3, 2)
  end
  print(bWriteLog and "Skill_BattleFlag_Deploy_Inst:CheckCanUse BoxTraceSingle bHit:" .. tostring(bBoxHit) .. " HitComponent:" .. tostring(uBoxHitResult.Component))
  if bBoxHit then
    print(bWriteLog and "Skill_BattleFlag_Deploy_Inst:CheckCanUse Fail - BoxTraceSingle hit detected")
    local uPlayerController = uOwner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      IngameTipsTools.BattleNormalTipsByTextID(DeployCheckConfig.TipTextID, "", "", nil, uPlayerController.PlayerKey, false)
    end
    return false
  end
  local SpawnLocation = HitLocation + FVector(0, 0, DeployCheckConfig.SpawnUpOffset)
  self.SpecificSkillCompRef:SetValueAsVector(self.SkillID, "SpawnLocation", SpawnLocation)
  print(bWriteLog and string.format("Skill_BattleFlag_Deploy_Inst:CheckCanUse Success - TargetLocation:%s SpawnLocation:%s", TargetLocation:ToString(), SpawnLocation:ToString()))
  return true
end
function Skill_BattleFlag_Deploy_Inst:DoDeloy()
  print(bWriteLog and "Skill_BattleFlag_Deploy_Inst:DoDeloy")
  if not slua.isValid(self.SpecificSkillCompRef) then
    return
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return
  end
  local uCurWeapon = uOwner:GetCurrentWeapon()
  if not slua.isValid(uCurWeapon) then
    return
  end
  if not uCurWeapon.DoDeloy then
    return
  end
  uCurWeapon:DoDeloy()
end
function Skill_BattleFlag_Deploy_Inst:CalcDeloyOffset()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return
  end
  local uCurWeapon = uOwner:GetCurrentWeapon()
  if not slua.isValid(uCurWeapon) then
    return
  end
  local ActorTransform = uOwner:GetTransform()
  local CurOffset = ActorTransform:InverseTransformPosition(uCurWeapon:K2_GetActorLocation())
  print(bWriteLog and "Skill_BattleFlag_Deploy_Inst:CalcDeloyOffset:" .. CurOffset:ToString())
end
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkill_BattleFlag_Deploy_Inst = class(CSkillActorBase, nil, Skill_BattleFlag_Deploy_Inst)
return CSkill_BattleFlag_Deploy_Inst