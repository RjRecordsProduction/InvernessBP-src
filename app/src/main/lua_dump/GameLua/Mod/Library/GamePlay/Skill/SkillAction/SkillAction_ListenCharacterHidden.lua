local SkillAction_ListenCharacterHidden = {
  sObjectName = "SkillAction_ListenCharacterHidden"
}
function SkillAction_ListenCharacterHidden:ctor(selfType)
  print(bWriteLog and "SkillAction_ListenCharacterHidden:ctor")
end
local EActorHiddenMask = import("EActorHiddenMask")
function SkillAction_ListenCharacterHidden:LuaRealDoAction()
  local uOwnerPawn = self:GetOwnerPawn()
  if not slua.isValid(uOwnerPawn) then
    print(bWriteLog and "SkillAction_ListenCharacterHidden:LuaRealDoAction - Owner is invalid")
    return false
  end
  if not Client then
    return true
  end
  self:AddControlEvent(uOwnerPawn, "OnCharacterHiddenStateChange", self.OnCharacterHiddenStateChange, self)
  print(bWriteLog and "SkillAction_ListenCharacterHidden:LuaRealDoAction - Listening OnCharacterHiddenStateChange")
  return true
end
function SkillAction_ListenCharacterHidden:OnCharacterHiddenStateChange(bNewHidden)
  local uOwnerPawn = self:GetOwnerPawn()
  if not slua.isValid(uOwnerPawn) then
    return
  end
  local bIsMaskHidden = uOwnerPawn:IsMaskHidden(EActorHiddenMask.ActorHiddenMask7)
  if bNewHidden ~= bIsMaskHidden then
    print(bWriteLog and "SkillAction_ListenCharacterHidden:OnCharacterHiddenStateChange - Correcting hidden state, re-hide by mask")
    uOwnerPawn:SetActorHiddenInGameMask(bIsMaskHidden, EActorHiddenMask.ActorHiddenMask7)
  end
end
function SkillAction_ListenCharacterHidden:LuaUndoAction()
  print(bWriteLog and "SkillAction_ListenCharacterHidden:LuaUndoAction")
  local uOwnerPawn = self:GetOwnerPawn()
  if slua.isValid(uOwnerPawn) then
    self:RemoveControlEvent(uOwnerPawn, "OnCharacterHiddenStateChange")
  end
  SkillAction_ListenCharacterHidden.__super.LuaUndoAction(self)
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CSkillNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_ListenCharacterHidden = class(CSkillNodeBase, nil, SkillAction_ListenCharacterHidden)
return CSkillAction_ListenCharacterHidden