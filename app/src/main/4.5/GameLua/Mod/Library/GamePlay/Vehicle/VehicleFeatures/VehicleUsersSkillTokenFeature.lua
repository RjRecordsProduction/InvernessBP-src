local VehicleUsersSkillTokenFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local ENetRole = import("ENetRole")
local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
function VehicleUsersSkillTokenFeature:ctor()
  self.sMyOwnerName = "BioVehicle"
end
function VehicleUsersSkillTokenFeature:_PostConstruct()
  VehicleUsersSkillTokenFeature.__super._PostConstruct(self)
  if not self.Owner then
    return
  end
  local VehicleSeat = self.Owner:GetVehicleSeats()
  if Game:IsValid(VehicleSeat) then
    self:AddControlEvent(VehicleSeat, "OnSeatAttached", self.HandleSeatAttached, self)
    self:AddControlEvent(VehicleSeat, "OnSeatDetached", self.HandleSeatDetached, self)
  end
end
function VehicleUsersSkillTokenFeature:ReceiveBeginPlay()
  VehicleUsersSkillTokenFeature.__super.ReceiveBeginPlay(self)
  self.sMyOwnerName = Game:GetObjName(self.Owner)
  if not Client then
    self:InitSkillList()
  end
end
function VehicleUsersSkillTokenFeature:InitSkillList()
  if not self.Owner then
    return
  end
  local uCurVehicle = self.Owner.Object
  if not Game:IsValid(uCurVehicle) then
    return
  end
  local tCustomConfigs = uCurVehicle.VehicleCustomConfigs
  if not tCustomConfigs then
    print(bWriteLog and string.format("VehicleUsersSkillTokenFeature:InitSkillList %s err VehicleCustomConfigs nil", self.sMyOwnerName))
    return
  end
  local tVehicleUsersSkillConfig = tCustomConfigs.VehicleUsersSkillConfig
  if not tVehicleUsersSkillConfig then
    print(bWriteLog and string.format("VehicleUsersSkillTokenFeature:InitSkillList %s err tVehicleUsersSkillConfig nil", self.sMyOwnerName))
    return
  end
  self.tVehicleUsersSkill = tVehicleUsersSkillConfig
  print(bWriteLog and string.format("VehicleUsersSkillTokenFeature:InitSkillList %s", self.sMyOwnerName))
  log_tree("VehicleUsersSkillTokenFeature:InitSkillList:", tVehicleUsersSkillConfig)
end
function VehicleUsersSkillTokenFeature:HandleSeatAttached(InCharacter, InSeatType, InSeatIndex)
  print(bWriteLog and string.format("VehicleUsersSkillTokenFeature:HandleSeatAttached() %s uCharacter:%s nSeatIdx:%s", self.sMyOwnerName, Game:GetObjName(InCharacter), tostring(InSeatIndex)))
  if not Game:IsValid(InCharacter) then
    return
  end
  if not self.tVehicleUsersSkill then
    return
  end
  local sCharacterName = Game:GetObjName(InCharacter)
  if InSeatType == ESTExtraVehicleSeatType.ESeatType_DriversSeat then
    if self.tVehicleUsersSkill[InSeatIndex + 1] then
      for _, SkillID in pairs(self.tVehicleUsersSkill[InSeatIndex + 1]) do
        print(bWriteLog and string.format("VehicleUsersSkillTokenFeature:HandleSeatDetached() Add Skill Token(%s) for %s", tostring(SkillID), sCharacterName))
        InCharacter:AddSkillToken(SkillID)
      end
    end
  elseif InSeatType == ESTExtraVehicleSeatType.ESeatType_PassengersSeat and self.tVehicleUsersSkill[InSeatIndex + 1] then
    for _, SkillID in pairs(self.tVehicleUsersSkill[InSeatIndex + 1]) do
      print(bWriteLog and string.format("VehicleUsersSkillTokenFeature:HandleSeatDetached() Add Skill Token(%s) for %s", tostring(SkillID), sCharacterName))
      InCharacter:AddSkillToken(SkillID)
    end
  end
end
function VehicleUsersSkillTokenFeature:HandleSeatDetached(uCharacter, nSeatType, nSeatIdx)
  print(bWriteLog and string.format("VehicleUsersSkillTokenFeature:HandleSeatDetached() %s uCharacter:%s nSeatIdx:%s", self.sMyOwnerName, Game:GetObjName(uCharacter), tostring(nSeatIdx)))
  if not Game:IsValid(uCharacter) then
    return
  end
  if not self.tVehicleUsersSkill then
    return
  end
  local sCharacterName = Game:GetObjName(uCharacter)
  if self.tVehicleUsersSkill[nSeatIdx + 1] then
    for _, SkillID in pairs(self.tVehicleUsersSkill[nSeatIdx + 1]) do
      print(bWriteLog and string.format("VehicleUsersSkillTokenFeature:HandleSeatDetached() Clear Skill Token(%s) for %s", tostring(SkillID), sCharacterName))
      uCharacter:ClearSkillToken(SkillID)
    end
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, VehicleUsersSkillTokenFeature)