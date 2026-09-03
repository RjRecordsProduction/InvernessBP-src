local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local MeleeThrowComponent = {
  sComponentName = "MeleeThrowComponent"
}
function MeleeThrowComponent:ctor(selfType)
end
function MeleeThrowComponent:ReceiveBeginPlay()
  MeleeThrowComponent.__super.ReceiveBeginPlay(self)
end
function MeleeThrowComponent:ReceiveEndPlay(nEndPlayReason)
  MeleeThrowComponent.__super.ReceiveEndPlay(self, nEndPlayReason)
end
local EThrowState = import("EThrowState")
function MeleeThrowComponent:ReceiveThrowStateChanged(NewState, PrevState)
  MeleeThrowComponent.__super.ReceiveThrowStateChanged(self, NewState, PrevState)
  if Client then
    local OwnerPawn = self:GetOwnerPawn()
    local ENetRole = import("ENetRole")
    if not slua.isValid(OwnerPawn) or OwnerPawn.Role ~= ENetRole.ROLE_AutonomousProxy then
      return
    end
    if NewState == EThrowState.Idle then
      self:HideCancelButton()
    elseif NewState == EThrowState.Prepare then
      self:ShowCancelButton()
    elseif NewState == EThrowState.Aim then
      self:ShowCancelButton()
    elseif NewState == EThrowState.Release then
      self:HideCancelButton()
    elseif NewState == EThrowState.Drop then
      self:HideCancelButton()
    end
  elseif NewState == EThrowState.Idle and (PrevState == EThrowState.Prepare or PrevState == EThrowState.Aim) then
    print(bWriteLog and string.format("MeleeThrowComponent:ReceiveThrowStateChanged CancelThrow force PrevState:%d", PrevState))
    self:CancelThrow(true)
  end
end
function MeleeThrowComponent:ShowCancelButton()
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:BroadcastUIMessage("UIMsg_ShowCancelGrenadeThrow", 0, "", "")
  end
end
function MeleeThrowComponent:HideCancelButton()
  local ShootingUIPanel = InGameUITools.GetShootingUIPanelLuaClass()
  if ShootingUIPanel then
    ShootingUIPanel:HideCancelGrenadeBtn()
  end
end
function MeleeThrowComponent:CheckIsSafetyFly(InStartLocation, InStartVelocity)
  if Client then
    return true
  end
  local bIsSafetyFly = true
  local InOwner = self:GetOwner()
  if not slua.isValid(InOwner) then
    return true
  end
  if InOwner.GetPredictLineComp == nil then
    return true
  end
  local uPredictLineComp = InOwner:GetPredictLineComp()
  if slua.isValid(uPredictLineComp) then
    local uPredictProjectilePathParams = import("PredictProjectilePathParams")()
    local PredictParams = uPredictLineComp.PredictProjectilePathParams
    uPredictProjectilePathParams.OverrideGravityZ = PredictParams.OverrideGravityZ
    uPredictProjectilePathParams.GravityScale = PredictParams.GravityScale
    uPredictProjectilePathParams.IgnoreGravityDis = PredictParams.IgnoreGravityDis
    uPredictProjectilePathParams.MaxSimTime = PredictParams.MaxSimTime
    uPredictProjectilePathParams.bTraceWithChannel = PredictParams.bTraceWithChannel
    uPredictProjectilePathParams.ProjectileRadius = PredictParams.ProjectileRadius
    uPredictProjectilePathParams.bTraceComplex = PredictParams.bTraceComplex
    uPredictProjectilePathParams.ObjectTypes = PredictParams.ObjectTypes
    uPredictProjectilePathParams.ActorsToIgnore = PredictParams.ActorsToIgnore
    uPredictProjectilePathParams.LaunchAcceleration = PredictParams.LaunchAcceleration
    uPredictProjectilePathParams.bTraceWithCollision = PredictParams.bTraceWithCollision
    uPredictProjectilePathParams.ActorsToIgnore:AddUnique(InOwner)
    uPredictProjectilePathParams.SimFrequency = 100
    uPredictProjectilePathParams.StartLocation = InStartLocation
    uPredictProjectilePathParams.LaunchVelocity = InStartVelocity
    local USTExtraGameplayStatics = import("STExtraGameplayStatics")
    bIsSafetyFly = USTExtraGameplayStatics.CheckProjectileIsSafetyFly(self, uPredictProjectilePathParams)
  end
  print(bWriteLog and "MeleeThrowComponent:CheckIsSafetyFly bIsSafetyFly:", bIsSafetyFly)
  return bIsSafetyFly
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.GamePlay.Component.ThrowComponent.BaseThrowComponent")
local CMeleeThrowComponent = class(CActorComponentBase, nil, MeleeThrowComponent)
return CMeleeThrowComponent