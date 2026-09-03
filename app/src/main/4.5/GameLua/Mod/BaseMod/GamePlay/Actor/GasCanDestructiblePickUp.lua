local GasCanDestructiblePickUp = {}
local UGameplayStatics = import("GameplayStatics")
function GasCanDestructiblePickUp:_PostConstruct()
  GasCanDestructiblePickUp.__super._PostConstruct(self)
  self.ExplosionFXPath = "/Game/Arts_Effect/ParticleSystems/Share/P_Explo_Oil.P_Explo_Oil"
  self.Health = self.MaxHealth
  self.bDestructed = false
end
function GasCanDestructiblePickUp:GetLifetimeReplicatedProps()
  local BaseRepTable = {}
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "bDestructed",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    }
  }
  table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  return RepTable
end
function GasCanDestructiblePickUp:ReceiveBeginPlay()
  GasCanDestructiblePickUp.__super.ReceiveBeginPlay(self)
  self:SetActorEnableCollision(true)
  if not Client then
    self.bCanBeDamaged = true
    self:AddControlEvent(self, "OnTakeAnyDamage", self.HandleTakeDamage, self)
  end
end
function GasCanDestructiblePickUp:SpawnEffect()
  if Client then
    local Loc = self:K2_GetActorLocation()
    self:AsyncLoadAsset(self.ExplosionFXPath, function(uPartcileSystem)
      UGameplayStatics.SpawnEmitterAtLocation(self.Object, uPartcileSystem, Loc, FRotator(0, 0, 0), FVector(1, 1, 1), true)
    end)
  end
end
function GasCanDestructiblePickUp:HandleTakeDamage(DamagedActor, Damage, DamageType, InstigatedBy, DamageCauser)
  if Client or DamagedActor ~= self.Object or Damage == 0 or 0 >= self.Health or self:_LastHitInfoHasValidInfo() then
    return
  end
  self.Health = self.Health - Damage
  if 0 >= self.Health then
    if slua.isValid(InstigatedBy) then
      self.LastHitInfo.LastHitBy = InstigatedBy
    end
    if slua.isValid(DamageCauser) then
      self.LastHitInfo.LastHitCauser = DamageCauser
    end
    self:Destruct()
    self:ForceNetUpdate()
  end
end
function GasCanDestructiblePickUp:Destruct()
  if self.bDestructed then
    return
  end
  if not Client then
    self.bDestructed = true
    self:OnDestructed()
    self:ReceiveDestructed()
  end
end
function GasCanDestructiblePickUp:ResetDestructedStateLua()
  self.bDestructed = false
  if not Client then
    self.Health = self.MaxHealth
    self:_LastHitInfoReset()
    self:ForceNetUpdate()
  end
end
function GasCanDestructiblePickUp:OnRep_bDestructed()
  if Client and self.bDestructed then
    self:OnDestructed()
    self:ReceiveDestructed()
  end
end
function GasCanDestructiblePickUp:_LastHitInfoHasValidInfo()
  return self.LastHitInfo.LastHitBy ~= nil and self.LastHitInfo.LastHitCauser ~= nil
end
function GasCanDestructiblePickUp:_LastHitInfoReset()
  self.LastHitInfo.LastHitBy = nil
  self.LastHitInfo.LastHitCauser = nil
end
local Class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CGasCanDestructiblePickUp = Class(CActorBase, nil, GasCanDestructiblePickUp)
return CGasCanDestructiblePickUp