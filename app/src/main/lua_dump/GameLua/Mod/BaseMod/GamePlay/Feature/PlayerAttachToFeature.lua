local EAttachmentRule = import("EAttachmentRule")
local EDetachmentRule = import("EDetachmentRule")
local EPutDownDetachMethod = import("EPutDownDetachMethod")
local KismetSystemLibrary = import("KismetSystemLibrary")
local UKismetMathLibrary = import("KismetMathLibrary")
local ENetRole = import("ENetRole")
local EPawnState = import("EPawnState")
local PlayerAttachToFeature = {
  ServerRPC = {
    ServerRPC_AttachToTarget = {
      Params = {
        UEnums.EPropertyClass.Object
      },
      Reliable = true
    },
    ServerRPC_DetachFromParent = {
      Params = {
        import("EPutDownDetachMethod")
      },
      Reliable = true
    }
  },
  ClientRPC = {},
  MulticastRPC = {}
}
function PlayerAttachToFeature:ctor()
  self.uParentAttachActor = nil
  self.ParentAttachableFeatrue = nil
end
function PlayerAttachToFeature:_PostConstruct()
  PlayerAttachToFeature.__super._PostConstruct(self)
end
function PlayerAttachToFeature:OnDestroy()
  PlayerAttachToFeature.__super.OnDestroy(self)
end
function PlayerAttachToFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {}
end
function PlayerAttachToFeature:GetParentAttachActor(bEvenIfDetaching)
  if self.ParentAttachableFeatrue and slua.isValid(self.uParentAttachActor) and (bEvenIfDetaching or not self.ParentAttachableFeatrue.bIsDetaching) then
    return self.uParentAttachActor
  end
  return nil
end
function PlayerAttachToFeature:GetParentAttachableFeature()
  return self.ParentAttachableFeatrue
end
function PlayerAttachToFeature:ServerRPC_AttachToTarget(TargetPlayerCharacter)
  self:DoAttachToTarget(TargetPlayerCharacter)
end
function PlayerAttachToFeature:DoAttachToTarget(TargetPlayerCharacter)
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    return
  end
  if slua.isValid(TargetPlayerCharacter) and TargetPlayerCharacter.PlayerAttachableFeature then
    TargetPlayerCharacter.PlayerAttachableFeature:AttachPlayerCharacterToOwner(self.Owner.Object)
  end
end
function PlayerAttachToFeature:ServerRPC_DetachFromParent(DetachMethod)
  self:DoDetachFromParent(DetachMethod)
end
function PlayerAttachToFeature:DoDetachFromParent(DetachMethod)
  if not self.Owner or not slua.isValid(self.Owner.Object) then
    return
  end
  DetachMethod = DetachMethod or EPutDownDetachMethod.Skill_Back
  if slua.isValid(self.uParentAttachActor) and self.uParentAttachActor.PlayerAttachableFeature then
    self.uParentAttachActor.PlayerAttachableFeature:MulticastRPC_NotifyAttachmentUpdate(self.Owner.Object, false, DetachMethod)
    self.uParentAttachActor.PlayerAttachableFeature:DetachPlayerCharacterFromOwner(DetachMethod)
  end
end
function PlayerAttachToFeature:OnPrePlayerAttachTo(uParentAttachActor, PlayerAttachableFeature)
  self.  self.ParentAttachableFeatrue = PlayerAttachableFeature
end
function PlayerAttachToFeature:OnPostPlayerAttachTo(uParentAttachActor, PlayerAttachableFeature)
end
function PlayerAttachToFeature:OnPrePlayerDetachFrom(uParentAttachActor, PlayerAttachableFeature)
end
function PlayerAttachToFeature:OnPostPlayerDetachFrom(uParentAttachActor, PlayerAttachableFeature)
  self.uParentAttachActor = nil
  self.ParentAttachableFeatrue = nil
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CPlayerAttachToFeature = class(CFeatureBase, nil, PlayerAttachToFeature)
return require("combine_class").SetFeatureDynamic(CPlayerAttachToFeature)