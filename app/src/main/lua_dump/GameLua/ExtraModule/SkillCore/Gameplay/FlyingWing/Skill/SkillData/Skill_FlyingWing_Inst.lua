local SkillActorInst = {
  __parent = "/Game/Library/Res/Skills/FlyingWing/Arts_PlayerBluePrints/Skill/Skill_FlyingWing.Skill_FlyingWing_C",
  Inst = {}
}
local TableUtil = require("common.table_util")
local EMovementMode = import("EMovementMode")
local UKismetMathLibrary = import("KismetMathLibrary")
local UGameplayStatics = import("GameplayStatics")
local FlyingWingConfig = require("GameLua.ExtraModule.SkillCore.Gameplay.FlyingWing.FlyingWingConfig")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local USTExtraGameplayStatics = import("STExtraGameplayStatics")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local ECollisionChannel = import("ECollisionChannel")
local ECollisionEnabled = import("ECollisionEnabled")
local UseCheckConfig = {
  SpaceCheckOffset = FVector(0, 0, 120),
  SpaceCheckTraceDir = FVector(20, 0, 0),
  SpaceCheckTraceDir2 = FVector(-20, 0, 0),
  BoxHalfExtent = FVector(160, 160, 100),
  TipTextID = 69956,
  bDrawDebug = true
}
function SkillActorInst:CheckCanUse()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return false
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return false
  end
  print(bWriteLog and "SkillActorInst:CheckCanUse")
  if not uOwner:HasAuthority() then
    return true
  end
  local OwnerLocation = uOwner:K2_GetActorLocation()
  print(bWriteLog and "SkillActorInst:CheckCanUse Indoor: " .. tostring(uOwner.Indoor))
  if uOwner.Indoor then
    print(bWriteLog and "SkillActorInst:CheckCanUse Fail - Indoor detected (ceiling above)")
    local uPlayerController = uOwner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      IngameTipsTools.BattleNormalTipsByTextID(UseCheckConfig.TipTextID, "", "", nil, uPlayerController.PlayerKey, false)
    end
    return false
  end
  if uOwner:CheckOnMoveablePlatform() then
    print(bWriteLog and "SkillActorInst:CheckCanUse Fail - Player is on a moving platform")
    local uPlayerController = uOwner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      IngameTipsTools.BattleNormalTipsByTextID(UseCheckConfig.TipTextID, "", "", nil, uPlayerController.PlayerKey, false)
    end
    return false
  end
  if slua.isValid(uOwner.SwimComponet) and uOwner.SwimComponet:IsEnterWaterSuface() then
    print(bWriteLog and "SkillActorInst:CheckCanUse Fail - IsEnterWaterSuface")
    local uPlayerController = uOwner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      IngameTipsTools.BattleNormalTipsByTextID(UseCheckConfig.TipTextID, "", "", nil, uPlayerController.PlayerKey, false)
    end
    return false
  end
  local Actor_C = import("/Script/Engine.Actor")
  local ActorsToIgnore = slua.Array(UEnums.EPropertyClass.Object, Actor_C)
  ActorsToIgnore:Add(uOwner)
  local ActorTransform = uOwner:GetTransform()
  local BoxCenter = ActorTransform:TransformPosition(UseCheckConfig.SpaceCheckOffset)
  local TraceEnd = BoxCenter + ActorTransform:TransformVector(UseCheckConfig.SpaceCheckTraceDir)
  local uHitResult = import("/Script/Engine.HitResult")()
  local bHit = false
  bHit, uHitResult = USTExtraBlueprintFunctionLibrary.TraceSingleByChannel(uOwner, BoxCenter, TraceEnd, uOwner:K2_GetActorRotation(), UseCheckConfig.BoxHalfExtent, 1, ECollisionChannel.ECC_Pawn, true, ActorsToIgnore, nil, uHitResult)
  if not bHit then
    local TraceEnd2 = BoxCenter + ActorTransform:TransformVector(UseCheckConfig.SpaceCheckTraceDir2)
    uHitResult = import("/Script/Engine.HitResult")()
    bHit, uHitResult = USTExtraBlueprintFunctionLibrary.TraceSingleByChannel(uOwner, BoxCenter, TraceEnd2, uOwner:K2_GetActorRotation(), UseCheckConfig.BoxHalfExtent, 1, ECollisionChannel.ECC_Pawn, true, ActorsToIgnore, nil, uHitResult)
  end
  if UseCheckConfig.bDrawDebug then
    USTExtraGameplayStatics.ClientDrawDebugBox(BoxCenter, UseCheckConfig.BoxHalfExtent, bHit and FLinearColor.Red or FLinearColor.Green, uOwner:K2_GetActorRotation(), 3, 2)
  end
  print(bWriteLog and "SkillActorInst:CheckCanUse BoxTraceSingle bHit:" .. tostring(bHit) .. " HitComponent:" .. tostring(uHitResult.Component))
  if bHit then
    print(bWriteLog and "SkillActorInst:CheckCanUse Fail - Not enough space, BoxTraceSingle hit detected")
    local uPlayerController = uOwner:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) then
      IngameTipsTools.BattleNormalTipsByTextID(UseCheckConfig.TipTextID, "", "", nil, uPlayerController.PlayerKey, false)
    end
    return false
  end
  print(bWriteLog and "SkillActorInst:CheckCanUse Success")
  return true
end
function SkillActorInst:StartAim()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return
  end
  if uOwner:HasAuthority() then
    local OriginRotation = uOwner:K2_GetActorRotation()
    self.SpecificSkillCompRef:SetValueAsRotator(self.SkillID, "OriginRotation", OriginRotation)
    print(bWriteLog and "SkillActorInst:StartAim:" .. OriginRotation:ToString())
  end
  local uWingActor = GamePlayTools.GetAttachedActorByTag(uOwner, "FlyingWingActor")
  if slua.isValid(uWingActor) then
    uWingActor:StartAim()
  end
end
function SkillActorInst:EndAim()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return
  end
  local uWingActor = GamePlayTools.GetAttachedActorByTag(uOwner, "FlyingWingActor")
  if slua.isValid(uWingActor) then
    uWingActor:EndAim()
  end
end
function SkillActorInst:DoReset()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return false
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return false
  end
  if not uOwner:HasAuthority() then
    return
  end
  print(bWriteLog and "SkillActorInst:DoReset")
  local OriginRotation = self.SpecificSkillCompRef:GetValueAsRotator(self.SkillID, "OriginRotation")
  local uPlayerController = uOwner:GetPlayerControllerSafety()
  if slua.isValid(uPlayerController) then
    uPlayerController:SetControlRotation(OriginRotation, "FlyingWingReset")
    uPlayerController:ClientSetControlRotation(OriginRotation)
  end
end
function SkillActorInst:EnterParachuteJump()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return false
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return false
  end
  if not uOwner:HasAuthority() then
    return
  end
  print(bWriteLog and "SkillActorInst:EnterParachuteJump")
  local uPlayerController = uOwner:GetPlayerControllerSafety()
  if slua.isValid(uPlayerController) then
    uPlayerController:ReInitParachuteItem()
    local EStateType = import("EStateType")
    uPlayerController:ServerChangeStatePC(EStateType.State_ParachuteJump)
  end
end
function SkillActorInst:ShowWing()
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
  print(bWriteLog and "SkillActorInst:ShowWing")
  local uWingActor = GamePlayTools.GetAttachedActorByTag(uOwner, "FlyingWingActor")
  if not slua.isValid(uWingActor) then
    print(bWriteLog and "SkillActorInst:ShowWing uWingActor is nil")
    return
  end
  uWingActor:Equip()
end
function SkillActorInst:HideWing()
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
  print(bWriteLog and "SkillActorInst:HideWing")
  local uWingActor = GamePlayTools.GetAttachedActorByTag(uOwner, "FlyingWingActor")
  if not slua.isValid(uWingActor) then
    print(bWriteLog and "SkillActorInst:ShowWing uWingActor is nil")
    return
  end
  uWingActor:Unequip()
end
function SkillActorInst:DissolveShowWing()
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
  print(bWriteLog and "SkillActorInst:DissolveShowWing")
  local uWingActor = GamePlayTools.GetAttachedActorByTag(uOwner, "FlyingWingActor")
  if not slua.isValid(uWingActor) then
    print(bWriteLog and "SkillActorInst:DissolveShowWing uWingActor is nil")
    return
  end
  uWingActor:DissolveShow()
end
function SkillActorInst:DissolveHideWing()
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
  print(bWriteLog and "SkillActorInst:DissolveHideWing")
  local uWingActor = GamePlayTools.GetAttachedActorByTag(uOwner, "FlyingWingActor")
  if not slua.isValid(uWingActor) then
    print(bWriteLog and "SkillActorInst:DissolveHideWing uWingActor is nil")
    return
  end
  uWingActor:DissolveHide()
end
function SkillActorInst:DissolveDestroyWing()
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
  print(bWriteLog and "SkillActorInst:DissolveDestroyWing")
  local uWingActor = GamePlayTools.GetAttachedActorByTag(uOwner, "FlyingWingActor")
  if not slua.isValid(uWingActor) then
    print(bWriteLog and "SkillActorInst:DissolveDestroyWing uWingActor is nil")
    return
  end
  uWingActor:DissolveDestroy()
end
function SkillActorInst:SetSprintLaunchConfig()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return
  end
  local LightCrossMgr = SubsystemMgr:Get("MapMarkLightCrossMgr")
  if LightCrossMgr then
    LightCrossMgr:ReviveInit()
  end
  local ControlRotation = uOwner:GetControlRotation()
  local Pitch = ControlRotation.Pitch
  print(bWriteLog and "SkillActorInst:CheckSprintAngleType Pitch:" .. tostring(Pitch))
  local SprintAngleType = 45 < Pitch and 0 or 1
  self.SpecificSkillCompRef:SetValueAsInt(self.SkillID, "SprintAngleType", SprintAngleType)
  local UActorComponent = import("/Script/Engine.ActorComponent")
  local CompArray = uOwner:GetComponentsByTag(UActorComponent, "FlyingWingSlideComp")
  if not CompArray or 0 >= CompArray:Num() then
    print(bWriteLog and "SkillActorInst:SetSprintLaunchConfig - FlyingWingSlideComp not found")
    return
  end
  local SlideComp = CompArray:Get(0)
  if not slua.isValid(SlideComp) then
    return
  end
  local WorldDir = ControlRotation:Vector()
  local OwnerTransform = uOwner:GetTransform()
  local LocalDir = UKismetMathLibrary.InverseTransformDirection(OwnerTransform, WorldDir)
  SlideComp.CustomDestDir = LocalDir
  SlideComp.bLaunchControlRotateActor = true
  if SprintAngleType == 0 then
    SlideComp.Launch_PitchOffset = -90
  else
    SlideComp.Launch_PitchOffset = -45
  end
  local uWingActor = GamePlayTools.GetAttachedActorByTag(uOwner, "FlyingWingActor")
  if slua.isValid(uWingActor) then
    SlideComp:SetCustomMoveComponent(uWingActor.CustomMoveComponent)
    if slua.isValid(uWingActor.CustomMoveComponent) then
      uWingActor.CustomMoveComponent:SetCollisionEnabled(ECollisionEnabled.QueryOnly)
      uWingActor.CustomMoveComponent:IgnoreActorWhenMoving(uOwner, true)
      if slua.isValid(uOwner.RootComponent) then
        uOwner.RootComponent:IgnoreActorWhenMoving(uWingActor, true)
      end
    end
  end
  print(bWriteLog and "SkillActorInst:SetSprintLaunchConfig SprintAngleType:" .. tostring(SprintAngleType) .. " Launch_PitchOffset:" .. tostring(SlideComp.Launch_PitchOffset))
end
function SkillActorInst:ResetSprintLaunchConfig()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return
  end
  local LightCrossMgr = SubsystemMgr:Get("MapMarkLightCrossMgr")
  if LightCrossMgr then
    LightCrossMgr:EnableLightCrossBecauseInTheSky(false)
  end
  local uWingActor = GamePlayTools.GetAttachedActorByTag(uOwner, "FlyingWingActor")
  if slua.isValid(uWingActor) and slua.isValid(uWingActor.CustomMoveComponent) then
    uWingActor.CustomMoveComponent:IgnoreActorWhenMoving(uOwner, false)
    if slua.isValid(uOwner.RootComponent) then
      uOwner.RootComponent:IgnoreActorWhenMoving(uWingActor, false)
    end
    uWingActor.CustomMoveComponent:SetCollisionEnabled(ECollisionEnabled.NoCollision)
  end
  local UActorComponent = import("/Script/Engine.ActorComponent")
  local CompArray = uOwner:GetComponentsByTag(UActorComponent, "FlyingWingSlideComp")
  if not CompArray or CompArray:Num() <= 0 then
    print(bWriteLog and "SkillActorInst:ResetSprintLaunchConfig - FlyingWingSlideComp not found")
    return
  end
  local SlideComp = CompArray:Get(0)
  if not slua.isValid(SlideComp) then
    return
  end
  SlideComp:SetCustomMoveComponent(nil)
  print(bWriteLog and "SkillActorInst:ResetSprintLaunchConfig")
end
function SkillActorInst:CalcFlyDist()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return false
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return false
  end
  if not uOwner:HasAuthority() then
    return
  end
  print(bWriteLog and "SkillActorInst:CalcFlyDist")
  local OriginLocation = self.SpecificSkillCompRef:GetValueAsVector(self.SkillID, "OriginRotation")
  local OwnerLocation = uOwner:K2_GetActorLocation()
  local FlyDist = (OwnerLocation - OriginLocation):Size()
  local FlyDistInt = math.floor(FlyDist)
  self.SpecificSkillCompRef:SetValueAsInt(self.SkillID, "FlyDistInt", FlyDistInt)
  print(bWriteLog and "SkillActorInst:CalcFlyDist FlyDist:" .. tostring(FlyDist))
end
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst