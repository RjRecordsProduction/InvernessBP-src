local DamageableComponent = {}
function DamageableComponent:ctor(selfType)
  self.owner = nil
  self.ownerRole = nil
  self.hasAuthority = nil
end
function DamageableComponent:ReceiveBeginPlay()
  self.Super:ReceiveBeginPlay()
  local Owner = self:GetOwnerActor()
  if Owner then
    self.ownerRole = Owner.Role
    self.hasAuthority = Owner:HasAuthority()
  end
  self:AddControlEvent(self, "OnHealthChangedNotify", self.LuaOnHealthChangedNotify, self)
end
function DamageableComponent:LuaOnHealthChangedNotify(CurrentHealth)
  local Owner = self:GetOwnerActor()
  if Owner and slua.isValid(Owner) then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    print(bWriteLog and "DamageableComponent:LuaOnHealthChangedNotify, CurrentHealth = " .. tostring(CurrentHealth) .. ", Name = " .. tostring(UKismetSystemLibrary.GetObjectName(Owner)))
    if Owner.OnHealthChange then
      Owner:OnHealthChange(CurrentHealth)
    end
  end
end
function DamageableComponent:BPTakeDamage(ActualDamage, DamageEvent, EventInstigator, DamageCauser, HitInfo, LuaDamageInfo)
  local Owner = self:GetOwnerActor()
  if slua.isValid(Owner) and Owner.BPTakeDamage then
    return Owner:BPTakeDamage(ActualDamage, DamageEvent, EventInstigator, DamageCauser, HitInfo, LuaDamageInfo)
  end
  return ActualDamage
end
function DamageableComponent:OnDie(uCauser)
  print(bWriteLog and "DamageableComponent:OnDie")
  local Owner = self:GetOwnerActor()
  if Owner and slua.isValid(Owner) then
    if Owner.OnDie then
      Owner:OnDie(uCauser)
    else
      Owner:K2_DestroyActor()
    end
  end
end
function DamageableComponent:GetOwnerActor()
  if self.owner and slua.isValid(self.owner) then
    return self.owner
  end
  self.owner = nil
  local Owner = self:GetOwner()
  if Owner and slua.isValid(Owner) then
    self.owner = Owner
  else
    print(bWriteLog and "DamageableComponent:GetOwnerActor, Owner = " .. tostring(Owner))
  end
  return self.owner
end
function DamageableComponent:ReceiveEndPlay(endPlayReason)
  self:Dispose()
  self.Super:ReceiveEndPlay(endPlayReason)
end
local Class = require("class")
local CDelegateContainer = require("common.delegate_container")
local DamageableComponentClass = Class(CDelegateContainer, nil, DamageableComponent)
return DamageableComponentClass