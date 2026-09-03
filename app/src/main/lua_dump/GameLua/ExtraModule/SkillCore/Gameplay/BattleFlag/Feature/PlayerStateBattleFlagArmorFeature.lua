local PlayerStateBattleFlagArmorFeature = {}
local BattleFlagConfig = require("GameLua.ExtraModule.SkillCore.Gameplay.BattleFlag.BattleFlagConfig")
function PlayerStateBattleFlagArmorFeature:ctor()
  self.BattleFlagArmor = 0
  self.CachedCharacter = nil
end
function PlayerStateBattleFlagArmorFeature:_PostConstruct()
  PlayerStateBattleFlagArmorFeature.__super._PostConstruct(self)
end
function PlayerStateBattleFlagArmorFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "BattleFlagArmor",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Float
    }
  }
end
function PlayerStateBattleFlagArmorFeature:ReceiveBeginPlay()
  PlayerStateBattleFlagArmorFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "PlayerStateBattleFlagArmorFeature:ReceiveBeginPlay")
  if self:HasAuthority() then
    local uCharacter = self.Owner:GetPlayerCharacter()
    if slua.isValid(uCharacter) then
      self:BindCharacterAttrEvent(uCharacter)
    end
    print(bWriteLog and "PlayerStateBattleFlagArmorFeature:ReceiveBeginPlay - Character invalid, wait for OnCharacterOwnerUpdate")
    self:AddControlEvent(self.Owner.Object, "OnCharacterOwnerUpdate", self.OnCharacterOwnerUpdate, self)
  end
end
function PlayerStateBattleFlagArmorFeature:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and "PlayerStateBattleFlagArmorFeature:ReceiveEndPlay")
  if self:HasAuthority() then
    if slua.isValid(self.CachedCharacter) then
      self:RemoveControlEvent(self.CachedCharacter, "OnPlayerAttrChangeDelegate")
    end
    self.CachedCharacter = nil
    self:RemoveControlEvent(self.Owner.Object, "OnCharacterOwnerUpdate")
  end
  PlayerStateBattleFlagArmorFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function PlayerStateBattleFlagArmorFeature:OnCharacterOwnerUpdate()
  print(bWriteLog and "PlayerStateBattleFlagArmorFeature:OnCharacterOwnerUpdate")
  local uCharacter = self.Owner:GetPlayerCharacter()
  if slua.isValid(uCharacter) then
    self:BindCharacterAttrEvent(uCharacter)
  end
end
function PlayerStateBattleFlagArmorFeature:BindCharacterAttrEvent(uCharacter)
  if self.CachedCharacter == uCharacter then
    return
  end
  if slua.isValid(self.CachedCharacter) then
    self:RemoveControlEvent(self.CachedCharacter, "OnPlayerAttrChangeDelegate")
  end
  self.CachedCharacter = uCharacter
  self:AddControlEventWithCondition(uCharacter, "OnPlayerAttrChangeDelegate", {
    AttrName = "BattleFlagArmor"
  }, self.HandlePlayerAttrChange, self)
  local AttrModifyComp = uCharacter.AttrModifyComp
  if slua.isValid(AttrModifyComp) then
    local CurArmor = AttrModifyComp:GetAttributeValue("BattleFlagArmor")
    if CurArmor and CurArmor ~= self.BattleFlagArmor then
      self.BattleFlagArmor = CurArmor
      self:ForceNetUpdate()
      print(bWriteLog and string.format("PlayerStateBattleFlagArmorFeature:BindCharacterAttrEvent - Initial armor value: %s", tostring(CurArmor)))
    end
  end
end
function PlayerStateBattleFlagArmorFeature:HandlePlayerAttrChange(AttrName, OldAttrValue, NewAttrValue, Reason)
  if AttrName ~= "BattleFlagArmor" then
    return
  end
  print(bWriteLog and string.format("PlayerStateBattleFlagArmorFeature:HandlePlayerAttrChange - BattleFlagArmor changed from %s to %s", tostring(OldAttrValue), tostring(NewAttrValue)))
  self.BattleFlagArmor = NewAttrValue
  self:ForceNetUpdate()
end
function PlayerStateBattleFlagArmorFeature:OnRep_BattleFlagArmor()
  print(bWriteLog and string.format("PlayerStateBattleFlagArmorFeature:OnRep_BattleFlagArmor - Value: %s, PlayerKey: %s", tostring(self.BattleFlagArmor), tostring(self.Owner.PlayerKey)))
  EventSystem:postEvent(EVENTTYPE_SKILLCORE_NORMAL, EVENTID_BATTLEFLAG_ARMOR_CHANGED, self.Owner.PlayerKey, self.BattleFlagArmor)
end
function PlayerStateBattleFlagArmorFeature:GetBattleFlagArmor()
  return self.BattleFlagArmor or 0
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, PlayerStateBattleFlagArmorFeature)