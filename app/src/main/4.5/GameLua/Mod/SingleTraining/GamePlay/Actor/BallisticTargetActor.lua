local BallisticTargetActor = {
  ServerRPC = {},
  ClientRPC = {}
}
local EImpactMask = import("EImpactMask")
local KismetMathLibrary = import("KismetMathLibrary")
local SingleTrainingConfig = require("GameLua.Mod.SingleTraining.Gameplay.Config.SingleTrainingConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function BallisticTargetActor:ctor()
  self.XOffset = 1.6
  self.YOffset = -1
  self.HitBodyType = 0
  self.ImpactPoint = FVector(0, 0, 0)
  self.ImpactTime = 0
  self.TotalDamage = 0
end
function BallisticTargetActor:ReceiveBeginPlay()
  print(bWriteLog and "BallisticTargetActor:ReceiveBeginPlay")
  BallisticTargetActor.__super.ReceiveBeginPlay(self)
  if Client then
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_LOCAL_HANDLE_SHOOT_DAMAGE, self.OnLocalShootDamage, self)
  end
end
function BallisticTargetActor:OnLocalShootDamage(_, _, Weapon, TargetActor, Damage, HitBodyType, ImpactPoint)
  if slua.isValid(Weapon) and TargetActor == self.Object then
    local OwnerPawn = Weapon:GetOwnerPawn()
    if slua.isValid(OwnerPawn) then
      local uPlayerPawn = GameplayData.GetPlayerCharacter()
      if Game:GetPlayerKey(OwnerPawn) == Game:GetPlayerKey(uPlayerPawn) then
        local CompToWorldTrans = self.Target:K2_GetComponentToWorld()
        local LocalImpactLocation = KismetMathLibrary.InverseTransformLocation(CompToWorldTrans, ImpactPoint)
        LocalImpactLocation.Y = 0
        local InnerHitBodyType = self:GetHitBodyTypeCustom(LocalImpactLocation)
        local HitPartCoff = Weapon:GetHitPartCoff(nil, Weapon:IsOwnerInGunADS())
        if HitPartCoff and 0 < InnerHitBodyType then
          local factor = 1
          if InnerHitBodyType == 1 then
            Damage = Damage * HitPartCoff.Head / HitPartCoff.Body
          end
          local TableUtil = require("common.table_util")
          local DefineID = Weapon:GetItemDefineID()
          if DefineID and TableUtil.IsInTable(SingleTrainingConfig.ScatterGunIDs, DefineID.TypeSpecificID) then
            self.TotalDamage = self.TotalDamage + Damage
            if self.ImpactTime <= 0.0 then
              self.ImpactTime = slua.getMiliseconds()
              self:AddGameTimer(0.2, false, function()
                UIManager.ShowUI(UIManager.UI_Config_InGame.BallisticTargetDamageMainUI, math.floor(self.TotalDamage), ImpactPoint.X, ImpactPoint.Y, ImpactPoint.Z)
                self.TotalDamage = 0
                self.ImpactTime = 0
              end)
            end
          else
            UIManager.ShowUI(UIManager.UI_Config_InGame.BallisticTargetDamageMainUI, math.floor(Damage), ImpactPoint.X, ImpactPoint.Y, ImpactPoint.Z)
          end
        end
      end
    end
  end
end
function BallisticTargetActor:GetImpactType(DamageCauser, HitResult)
  if not Client then
    return
  end
  if not UIManager.IsUIShow(UIManager.UI_Config_InGame.BallisticTargetUI) then
    UIManager.ShowUI(UIManager.UI_Config_InGame.BallisticTargetUI)
  end
  self.ImpactPoint = HitResult.ImpactPoint
  local nDistance = 0
  local uPlayerPawn = GameplayData.GetPlayerCharacter()
  if slua.isValid(uPlayerPawn) and self.ImpactPoint then
    local uPlayerLoc = uPlayerPawn:K2_GetActorLocation()
    local uImpactPoint2D = FVector2D(self.ImpactPoint.X, self.ImpactPoint.Y)
    local uPlayerLoc2D = FVector2D(uPlayerLoc.X, uPlayerLoc.Y)
    local uDistanceVec = uImpactPoint2D - uPlayerLoc2D
    nDistance = uDistanceVec:Size() / 100
    nDistance = math.floor(nDistance + 0.5)
  end
  local CompToWorldTrans = HitResult.Component:K2_GetComponentToWorld()
  local LocalImpactLocation = KismetMathLibrary.InverseTransformLocation(CompToWorldTrans, HitResult.ImpactPoint)
  local BallisticTargetUI = UIManager.GetUI(UIManager.UI_Config_InGame.BallisticTargetUI)
  if BallisticTargetUI and BallisticTargetUI.AddTargetMark then
    local X = 0
    if 0 <= LocalImpactLocation.X then
      if LocalImpactLocation.X > 22 then
        X = SingleTrainingConfig.TargetUIWidth + LocalImpactLocation.X * 2 + self.XOffset
      else
        X = SingleTrainingConfig.TargetUIWidth + LocalImpactLocation.X * 2 - 1.2
      end
    elseif 0 > LocalImpactLocation.X then
      if LocalImpactLocation.X < -22 then
        X = SingleTrainingConfig.TargetUIWidth + LocalImpactLocation.X * 2 - 5.2
      else
        X = SingleTrainingConfig.TargetUIWidth + LocalImpactLocation.X * 2 - 2.6
      end
    end
    local Y = 0
    if 0 <= LocalImpactLocation.Z then
      Y = SingleTrainingConfig.TargetUIHeight - LocalImpactLocation.Z * 2 - 9
    elseif 0 > LocalImpactLocation.Z then
      Y = SingleTrainingConfig.TargetUIHeight + -LocalImpactLocation.Z * 2 + self.YOffset
    end
    LocalImpactLocation.Y = 0
    local HitBodyType = self:GetHitBodyTypeCustom(LocalImpactLocation)
    BallisticTargetUI:AddTargetMark(FVector2D(X, Y), self.TargetActorID, HitBodyType)
    BallisticTargetUI:UpdateDistance(nDistance)
  end
  return EImpactMask.EImpactEffect
end
function BallisticTargetActor:GetHitBodyTypeCustom(LocalImpactLocation)
  local HitBodyType = 0
  local bHitBody = KismetMathLibrary.IsPointInBox(LocalImpactLocation, SingleTrainingConfig.TargetActorBodyOrigin, SingleTrainingConfig.TargetActorBodyBoxExtent)
  if bHitBody then
    HitBodyType = 3
  elseif KismetMathLibrary.IsPointInBox(LocalImpactLocation, SingleTrainingConfig.TargetActorHeadOrigin, SingleTrainingConfig.TargetActorHeadBoxExtent) then
    HitBodyType = 1
  end
  return HitBodyType
end
local class = require("class")
local base = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CBallisticTargetActor = class(base, nil, BallisticTargetActor)
return CBallisticTargetActor