local VehicleDamageComponent = {
  LuaEventContainer = {
    "OnCharacterTakeDamageByVehicleHitOthersDelegate"
  }
}
local KismetSystemLibrary = import("KismetSystemLibrary")
function VehicleDamageComponent:ctor(SelfType)
  self.PassengerProtect = {}
end
function VehicleDamageComponent:_PostConstruct()
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) then
    return
  end
  if not Client then
    local VehicleSeat = Owner:GetVehicleSeats()
    if slua.isValid(VehicleSeat) then
      self:AddControlEvent(VehicleSeat, "OnSeatAttached", self.HandleSeatAttached, self)
      self:AddControlEvent(VehicleSeat, "OnSeatDetached", self.HandleSeatDetached, self)
    end
  end
end
function VehicleDamageComponent:ReceiveEndPlay(EndPlayReason)
  self:Dispose()
  self.Super:ReceiveEndPlay(EndPlayReason)
  VehicleDamageComponent.__super.ReceiveEndPlay(self, EndPlayReason)
end
function VehicleDamageComponent:Protect(InCharacter)
  if slua.isValid(InCharacter) and not self.PassengerProtect[InCharacter.PlayerKey] then
    local Handle = self:AddTimer(5, function()
      if slua.isValid(InCharacter) then
        self.PassengerProtect[InCharacter.PlayerKey] = nil
        print(bWriteLog and "VehicleDamageComponent:Protect, delay cancel protect")
      end
    end)
    self.PassengerProtect[InCharacter.PlayerKey] = Handle
    print(bWriteLog and "VehicleDamageComponent:Protect, ", self.PassengerProtect[InCharacter.PlayerKey], InCharacter.PlayerKey)
  end
end
function VehicleDamageComponent:CancelProtect(InCharacter)
  if slua.isValid(InCharacter) and self.PassengerProtect[InCharacter.PlayerKey] then
    print(bWriteLog and "VehicleDamageComponent:CancelProtect, ", InCharacter.PlayerKey)
    local Handle = self.PassengerProtect[InCharacter.PlayerKey]
    self:RemoveTimer(Handle)
    self.PassengerProtect[InCharacter.PlayerKey] = nil
  end
end
function VehicleDamageComponent:HandleSeatAttached(InCharacter, SeatType, SeatIndex)
  if slua.isValid(InCharacter) then
    self:CancelProtect(InCharacter)
  end
end
function VehicleDamageComponent:ShouldCauseDamageExt(HitDamage, InPrimComp, InCharacter)
  if not slua.isValid(InPrimComp) or not slua.isValid(InCharacter) then
    return false
  end
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) then
    return
  end
  if slua.isValid(InCharacter) and self.PassengerProtect[InCharacter.PlayerKey] ~= nil then
    print(bWriteLog and "VehicleDamageComponent:ShouldCauseDamageEx, character still been protected", Owner)
    return false
  end
  local StartPos = Owner:GetPhysicsBoundsCenter(true)
  local EndPos = InCharacter:K2_GetActorLocation()
  local ActorsToIgnore = Owner:GetQueryIgnoreActors()
  ActorsToIgnore:Add(InCharacter)
  local bBlockingHit, HitResult = KismetSystemLibrary.LineTraceSingleByProfile(self, StartPos, EndPos, "Vehicle", true, ActorsToIgnore, 0, import("/Script/Engine.HitResult")(), true, FLinearColor.Red, FLinearColor.Green, 5)
  if bBlockingHit and not Game:IsClassOf(HitResult.Actor, import("STExtraSimulatedSlidingVehicle")) then
    print(bWriteLog and "VehicleDamageComponent:ShouldCauseDamageEx, may damage character through obstacles", Owner, HitResult.Actor)
    return false
  end
  return true
end
function VehicleDamageComponent:HandleSeatDetached(InCharacter, SeatType, SeatIndex)
  if slua.isValid(InCharacter) then
    self:Protect(InCharacter)
  end
end
function VehicleDamageComponent:CharacterTakeDamageByVehicleHitOthersExt(InDamage, InOtherActor, InImpulse)
  print(bWriteLog and "VehicleDamageComponent:CharacterTakeDamageByVehicleHitOthersExt", InDamage, InOtherActor, InImpulse)
  self:LuaBroadcast("OnCharacterTakeDamageByVehicleHitOthersDelegate", InDamage, InOtherActor, InImpulse)
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CVehicleDamageComponent = class(CDelegateContainer, nil, VehicleDamageComponent)
return CVehicleDamageComponent