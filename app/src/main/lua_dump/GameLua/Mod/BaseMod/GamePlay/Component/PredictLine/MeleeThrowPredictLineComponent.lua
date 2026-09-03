local MeleeThrowPredictLineComponent = {}
function MeleeThrowPredictLineComponent:ctor(selfType)
  self.bUseCharacterPredictLine = false
end
function MeleeThrowPredictLineComponent:ReceiveBeginPlay()
  MeleeThrowPredictLineComponent.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "MeleeThrowPredictLineComponent:ReceiveBeginPlay()")
  if Client then
    local uOwnerMeleeWeapon = self:GetOwner()
    if slua.isValid(uOwnerMeleeWeapon) then
      local uThrowComponent = uOwnerMeleeWeapon:GetComponentByClass(import("/Script/ShadowTrackerExtra.ThrowComponent"))
      if slua.isValid(uThrowComponent) then
        print(bWriteLog and "MeleeThrowPredictLineComponent:ReceiveBeginPlay ThrowStateChangedDelegate")
        self:AddControlEvent(uThrowComponent, "ThrowStateChangedDelegate", self.HandleThrowStateChangedDelegate, self)
      end
    end
  end
end
function MeleeThrowPredictLineComponent:ReceiveEndPlay(nEndPlayReason)
  print(bWriteLog and "MeleeThrowPredictLineComponent:ReceiveEndPlay()")
  MeleeThrowPredictLineComponent.__super.ReceiveEndPlay(self, nEndPlayReason)
end
function MeleeThrowPredictLineComponent:InitPredictLineColor()
  print(bWriteLog and "MeleeThrowPredictLineComponent:InitPredictLineColor()")
  self.PredictLineColor = FLinearColor(0.83, 0, 0, 1)
end
function MeleeThrowPredictLineComponent:InitPredictProjectilePathParams()
  local uPredictProjectilePathParams = self.PredictProjectilePathParams
  local ECollisionChannel = import("ECollisionChannel")
  uPredictProjectilePathParams.bTraceWithCollision = true
  uPredictProjectilePathParams.bTraceWithChannel = true
  uPredictProjectilePathParams.bTraceComplex = true
  uPredictProjectilePathParams.TraceChannel = ECollisionChannel.ECC_GameTraceChannel17
  uPredictProjectilePathParams.ActorsToIgnore = self:GetPredictLineIgnoreActors(false)
end
function MeleeThrowPredictLineComponent:HandleThrowStateChangedDelegate(nCurrentState, nPrevState)
  if not Client then
    return
  end
  local uOwnerMeleeWeapon = self:GetOwner()
  if slua.isValid(uOwnerMeleeWeapon) then
    local uThrowComponent = uOwnerMeleeWeapon:GetComponentByClass(import("/Script/ShadowTrackerExtra.ThrowComponent"))
    if slua.isValid(uThrowComponent) then
      if self.bUseCharacterPredictLine then
        local USTExtraGameplayStatics = import("STExtraGameplayStatics")
        if uThrowComponent:ShouldDrawTrajectory() then
          USTExtraGameplayStatics.ActiveCharacterPredictLine(self:GetOwner(), self:GetOwnerPawn(), true)
        else
          USTExtraGameplayStatics.DeativeCharacterPredictLine(self:GetOwner(), self:GetOwnerPawn(), true)
        end
      else
        local bActive = uThrowComponent:ShouldDrawTrajectory()
        print(bWriteLog and string.format("MeleeThrowPredictLineComponent:HandleThrowStateChangedDelegate bActive:%s", tostring(bActive)))
        self:ActivePredictLine(bActive, false)
      end
    end
  end
end
function MeleeThrowPredictLineComponent:GetPredictLineStartPoint()
  local uOwnerActor = self:GetOwner()
  if slua.isValid(uOwnerActor) then
    local GetPredictLineStartPointFun = uOwnerActor.GetPredictLineStartPoint
    if GetPredictLineStartPointFun then
      return GetPredictLineStartPointFun(uOwnerActor)
    end
  end
  return FVector(0)
end
function MeleeThrowPredictLineComponent:GetPredictLineVelocity()
  local uOwnerActor = self:GetOwner()
  if slua.isValid(uOwnerActor) then
    local GetPredictLineVelocityFun = uOwnerActor.GetPredictLineVelocity
    if GetPredictLineVelocityFun then
      return GetPredictLineVelocityFun(uOwnerActor)
    end
  end
  return FVector(0)
end
local class = require("class")
local CActorPredictLineComponent = require("GameLua.Mod.BaseMod.GamePlay.Component.PredictLine.ActorPredictLineComponent")
local CMeleeThrowPredictLineComponent = class(CActorPredictLineComponent, nil, MeleeThrowPredictLineComponent)
return CMeleeThrowPredictLineComponent