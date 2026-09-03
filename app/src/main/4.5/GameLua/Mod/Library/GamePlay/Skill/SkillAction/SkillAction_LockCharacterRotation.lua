local SkillAction_LockCharacterRotation = {}
function SkillAction_LockCharacterRotation:LuaRealDoAction()
  local OwnerSkill = self:GetOwnerSkill()
  local Character = self:GetOwnerPawn()
  if self.CharacterBlackboardKey then
    Character = self:GetValueAsWeakObject(self.CharacterBlackboardKey)
  end
  if not slua.isValid(OwnerSkill) or not slua.isValid(Character) then
    return false
  end
  local ASTExtraPlayerCharacter = import("STExtraPlayerCharacter")
  if not Game:IsClassOf(Character, ASTExtraPlayerCharacter) then
    return false
  end
  if not Character:GetIsFPP() then
    Character.bUseControllerRotationYaw = false
  end
  Character.bSkillLockChangePersonPerspective = true
  return true
end
function SkillAction_LockCharacterRotation:LuaUndoAction()
  local OwnerSkill = self:GetOwnerSkill()
  local Character = self:GetOwnerPawn()
  if self.CharacterBlackboardKey then
    Character = self:GetValueAsWeakObject(self.CharacterBlackboardKey)
  end
  if not slua.isValid(OwnerSkill) or not slua.isValid(Character) then
    return
  end
  local ASTExtraPlayerCharacter = import("STExtraPlayerCharacter")
  if not Game:IsClassOf(Character, ASTExtraPlayerCharacter) then
    return
  end
  if not Character:GetIsFPP() then
    Character.bUseControllerRotationYaw = true
  end
  Character.bSkillLockChangePersonPerspective = false
end
local class = require("class")
local CObjectBase = require("GameLua.Mod.BaseMod.Common.Core.ObjectBase")
return class(CObjectBase, nil, SkillAction_LockCharacterRotation)