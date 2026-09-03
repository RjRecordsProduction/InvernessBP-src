local WeaponBase = {}
function WeaponBase:ctor(selfType)
end
function WeaponBase:ReceiveBeginPlay()
  print(bWriteLog and "WeaponBase ReceiveBeginPlay() ", self)
  self.Super:ReceiveBeginPlay()
  WeaponBase.__super.ReceiveBeginPlay(self)
  self.bEquipmentModifierOnlyRepOwner = false
  self:ModifyUnMatchStateSyncCheckInterval()
end
function WeaponBase:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "WeaponBase ReceiveEndPlay()", self)
  self.Super:ReceiveEndPlay(EndPlayReason)
  WeaponBase.__super.ReceiveEndPlay(self)
end
function WeaponBase:InitWeaponBP()
  print(bWriteLog and "WeaponBase InitWeaponBP", self)
  self.Super:InitWeaponBP()
  self:InitWeaponPartsEquippedEvent()
  self:InitWeapon()
end
function WeaponBase:InitWeaponPartsEquippedEvent()
end
function WeaponBase:GetWeaponAvatarComponent()
  return self.WeaponAvatarComponent
end
function WeaponBase:InitWeapon()
  EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_WEAPON, EVENTID_PLAYEREVENT_WEAPON_LUA_INIT, self)
end
function WeaponBase:ModifyUnMatchStateSyncCheckInterval()
  if Client and slua.isValid(self.Object) then
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    if STExtraBlueprintFunctionLibrary.IsPlayingAnyReplay(self.Object) then
      self.UnMatchStateSyncCheckInterval = 30.0
    end
  end
end
function WeaponBase:IsHoldingInHand()
  local OwnerPawn = self:GetOwnerPawn()
  if Game:IsValid(OwnerPawn) and OwnerPawn.GetCurrentWeapon then
    local CurrentWeapon = OwnerPawn:GetCurrentWeapon()
    return CurrentWeapon == self.Object
  end
  return false
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CWeaponBase = class(CActorBase, nil, WeaponBase)
return CWeaponBase