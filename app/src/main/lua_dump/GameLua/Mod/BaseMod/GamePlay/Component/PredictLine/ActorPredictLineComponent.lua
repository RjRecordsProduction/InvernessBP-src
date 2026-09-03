local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local EPawnState = import("EPawnState")
local ActorPredictLineComponent = {
  PredictEndPointFXMap = {
    [0] = "/Game/Arts_Effect/ParticleSystems/Share/P_MissileTarget.P_MissileTarget",
    [1] = "/Game/Arts_Effect/ParticleSystems/Share/P_MissileTarget_Red.P_MissileTarget_Red",
    [2] = "/Game/Arts_Effect/ParticleSystems/Share/P_MissileTarget_Green.P_MissileTarget_Green",
    [3] = "/Game/Arts_Effect/ParticleSystems/Share/P_MissileTarget_Blue.P_MissileTarget_Blue"
  }
}
function ActorPredictLineComponent:ctor(selfType)
end
function ActorPredictLineComponent:ReceiveBeginPlay()
  ActorPredictLineComponent.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "ActorPredictLineComponent:ReceiveBeginPlay()")
  self:Deactivate()
  self:SetComponentTickEnabled(false)
  self:SetCollisionEnabled(0)
  if Client then
    self:InitPredictDefaultRes()
    self:InitPredictProjectilePathParams()
    self:InitPredictLineColor()
  end
end
function ActorPredictLineComponent:ReceiveEndPlay(nEndPlayReason)
  print(bWriteLog and "ActorPredictLineComponent:ReceiveEndPlay()")
  ActorPredictLineComponent.__super.ReceiveEndPlay(self, nEndPlayReason)
end
function ActorPredictLineComponent:GetOwnerPawn()
  local uOwnerActor = self:GetOwner()
  if slua.isValid(uOwnerActor) then
    return uOwnerActor.Owner
  end
  return nil
end
function ActorPredictLineComponent:ActivePredictLine(bActive, bReset)
  if not Client then
    return
  end
  local uCharacter = self:GetOwnerPawn()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uCharacter) and slua.isValid(uPlayerController) and (uCharacter == uPlayerController:GetCurPawn() or uCharacter:HasState(EPawnState.ControlUnmannedVehicle)) then
    if bActive then
      if not self:IsActive() then
        self:SetActive(true, bReset)
      end
    elseif self:IsActive() then
      self:SetActive(false, bReset)
    end
  end
end
function ActorPredictLineComponent:InitPredictProjectilePathParams()
end
function ActorPredictLineComponent:InitPredictLineColor()
  local UIUtil = require("client.common.ui_util")
  local uGameFrontendHUD = UIUtil.GetGameFrontendHUD()
  local uColorBlindnessMgr = uGameFrontendHUD:GetColorBlindnessMgr()
  if slua.isValid(uColorBlindnessMgr) then
    self.PredictLineColor = uColorBlindnessMgr:GetColorByType(7)
  else
    self.PredictLineColor = FLinearColor(0.83, 0, 0, 1)
  end
  if self:IsWinOBCN() then
    self.PredictLineColor = FLinearColor(1, 1, 1, 1)
  end
end
function ActorPredictLineComponent:ResetPredictLineColor()
  print(bWriteLog and string.format("ActorPredictLineComponent:ResetPredictLineColor"))
  self:InitPredictLineColor()
end
function ActorPredictLineComponent:GetPredictLineIgnoreActors(bInclueVehicle)
  local uLocalIgnoreActors = slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
  local uOwnerActor = self:GetOwner()
  if slua.isValid(uOwnerActor) then
    uLocalIgnoreActors:Add(uOwnerActor)
    local uCharacter = uOwnerActor.Owner
    print(bWriteLog and string.format("ActorPredictLineComponent:GetPredictLineIgnoreActors %s, %s", uOwnerActor, uCharacter))
    if slua.isValid(uCharacter) then
      uLocalIgnoreActors:Add(uCharacter)
      if uCharacter:HasState(EPawnState.ControlUnmannedVehicle) then
        local uPlayerController = GameplayData.GetPlayerController()
        if slua.isValid(uPlayerController) and uPlayerController.GetVehicleUserComp then
          local uVehicleUserComp = uPlayerController:GetVehicleUserComp()
          if slua.isValid(uVehicleUserComp) and slua.isValid(uVehicleUserComp.UnmannedVehicle) then
            uLocalIgnoreActors:Add(uVehicleUserComp.UnmannedVehicle)
          end
        end
      end
      if bInclueVehicle == true and uCharacter.GetCurrentVehicle then
        local uVehicle = uCharacter:GetCurrentVehicle()
        if slua.isValid(uVehicle) then
          uLocalIgnoreActors:Add(uVehicle)
          if uVehicle.GetSeatComponent then
            local uVehicleSeatComp = uVehicle:GetSeatComponent()
            if slua.isValid(uVehicleSeatComp) then
              for _, uSeatCharacter in uVehicleSeatComp.SeatOccupiers:Pairs() do
                if slua.isValid(uSeatCharacter) then
                  uLocalIgnoreActors:Add(uVehicle)
                end
              end
            end
          end
        end
      end
      if uCharacter.PlayerAttachToFeature and uCharacter.PlayerAttachToFeature.GetParentAttachActor then
        local uParentAttachActor = uCharacter.PlayerAttachToFeature:GetParentAttachActor()
        if slua.isValid(uParentAttachActor) then
          uLocalIgnoreActors:Add(uParentAttachActor)
        end
      end
    else
      print(bWriteLog and string.format("ActorPredictLineComponent:GetPredictLineIgnoreActors GetCharacter Fail %s", uOwnerActor.Owner))
    end
  else
    print(bWriteLog and string.format("ActorPredictLineComponent:GetPredictLineIgnoreActors GetOwner Fail %s", tostring(uOwnerActor)))
  end
  return uLocalIgnoreActors
end
function ActorPredictLineComponent:GetPredictLineStartPoint()
  return FVector(0)
end
function ActorPredictLineComponent:GetPredictLineVelocity()
  return FVector(0)
end
function ActorPredictLineComponent:GetPredictLineAcceleration()
  return FVector(0)
end
function ActorPredictLineComponent:InitPredictDefaultRes()
  local nColorBlindnessType = 0
  local uSettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if slua.isValid(uSettingConfig) then
    nColorBlindnessType = uSettingConfig.ColorBlindnessType or 0
  end
  self:EventColorBlindnessTypeSwitch(nColorBlindnessType)
  self:LoadPredictDefaultRes()
end
function ActorPredictLineComponent:EventColorBlindnessTypeSwitch(nColorBlindnessType)
  self:InitPredictEndPointFX(nColorBlindnessType)
end
function ActorPredictLineComponent:IsWinOBCN()
  local playerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(playerController) and playerController.IsObserver then
    local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
    return Client.GetCurrentLanguage() == LanguageMacros.ZH and playerController:IsObserver()
  end
  return false
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CActorPredictLineComponent = class(CActorComponentBase, nil, ActorPredictLineComponent)
return CActorPredictLineComponent