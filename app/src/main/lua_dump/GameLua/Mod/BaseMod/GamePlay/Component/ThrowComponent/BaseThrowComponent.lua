local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local BaseThrowComponent = {
  sComponentName = "BaseThrowComponent"
}
function BaseThrowComponent:ctor(selfType)
end
function BaseThrowComponent:ReceiveBeginPlay()
  BaseThrowComponent.__super.ReceiveBeginPlay(self)
  print(bWriteLog and string.format("%s:ReceiveBeginPlay()", self.sComponentName))
  self.CurWeaponID = nil
  local uThrowWeapon = self:GetOwner()
  if slua.isValid(uThrowWeapon) then
    self.CurWeaponID = uThrowWeapon:GetItemDefineID()
  else
    self.CurWeaponID = FItemDefineIDDefault()
  end
end
function BaseThrowComponent:ReceiveEndPlay(nEndPlayReason)
  print(bWriteLog and string.format("%s:ReceiveEndPlay()", self.sComponentName))
  BaseThrowComponent.__super.ReceiveEndPlay(self, nEndPlayReason)
end
function BaseThrowComponent:SetPawnStateDisabled(uPawn)
  if slua.isValid(uPawn) then
    for index = 0, self.ThrowDisableStates:Num() - 1 do
      uPawn:ResetPawnStateDisabled(self.ThrowDisableStates:Get(index))
    end
  end
end
function BaseThrowComponent:ReceiveThrowStateChanged(NewState, PrevState)
  print(bWriteLog and string.format("%s:ReceiveThrowStateChanged NewState=%d, PrevState=%d", self.sComponentName, NewState, PrevState))
  local uPawn = self:GetOwnerPawn()
  if slua.isValid(uPawn) and uPawn:HasAuthority() then
    self:SetPawnStateDisabled(uPawn)
  end
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CBaseThrowComponent = class(CActorComponentBase, nil, BaseThrowComponent)
return CBaseThrowComponent