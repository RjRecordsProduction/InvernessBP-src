local SkillAction_ChangeShootVertifyHitBoxScale = {
  sObjectName = "SkillAction_ChangeShootVertifyHitBoxScale"
}
function SkillAction_ChangeShootVertifyHitBoxScale:ctor(selfType)
  print(bWriteLog and "SkillAction_ChangeShootVertifyHitBoxScale:ctor")
end
function SkillAction_ChangeShootVertifyHitBoxScale:LuaRealDoAction()
  local uCharacter = self:GetOwnerPawn()
  if not slua.isValid(uCharacter) then
    print(bWriteLog and "SkillAction_ChangeShootVertifyHitBoxScale LuaRealDoAction uCharacter is nil")
    return false
  end
  if not uCharacter:HasAuthority() then
    return false
  end
  print(bWriteLog and "SkillAction_ChangeShootVertifyHitBoxScale LuaRealDoAction")
  self:AddControlEvent(uCharacter, "OnShootVerifyScaleDelegate", self.HandleOnOnShootVerifyScaleDelegate, self)
  return true
end
function SkillAction_ChangeShootVertifyHitBoxScale:LuaResetAction()
  print(bWriteLog and "SkillAction_ChangeShootVertifyHitBoxScale:LuaResetAction")
  local uCharacter = self:GetOwnerPawn()
  if not slua.isValid(uCharacter) then
    print(bWriteLog and "SkillAction_ChangeShootVertifyHitBoxScale LuaResetAction uCharacter is nil")
    return
  end
  if not uCharacter:HasAuthority() then
    return
  end
  if self.bReverseOnUndo then
    return
  end
  self.bHasReset = true
  print(bWriteLog and "SkillAction_ChangeShootVertifyHitBoxScale LuaResetAction")
  self:RemoveControlEvent(uCharacter, "OnShootVerifyScaleDelegate")
end
function SkillAction_ChangeShootVertifyHitBoxScale:LuaUndoAction()
  print(bWriteLog and "SkillAction_ChangeShootVertifyHitBoxScale:LuaUndoAction")
  local uCharacter = self:GetOwnerPawn()
  if not slua.isValid(uCharacter) then
    print(bWriteLog and "SkillAction_ChangeShootVertifyHitBoxScale LuaUndoAction uCharacter is nil")
    return
  end
  if not uCharacter:HasAuthority() then
    return
  end
  if self.bHasReset then
    self.bHasReset = nil
    return
  end
  print(bWriteLog and "SkillAction_ChangeShootVertifyHitBoxScale LuaUndoAction")
  self:RemoveControlEvent(uCharacter, "OnShootVerifyScaleDelegate")
end
function SkillAction_ChangeShootVertifyHitBoxScale:HandleOnOnShootVerifyScaleDelegate()
  local uCharacter = self:GetOwnerPawn()
  if not slua.isValid(uCharacter) then
    print(bWriteLog and "SkillAction_ChangeShootVertifyHitBoxScale HandleOnOnShootVerifyScaleDelegate uCharacter is nil")
    return
  end
  print(bWriteLog and "SkillAction_ChangeShootVertifyHitBoxScale:HandleOnOnShootVerifyScaleDelegate:" .. self.HitBoxScale:ToString())
  uCharacter.FeatureDynamicVertifyHitBoxScale = self.HitBoxScale
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CSkillNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_ChangeShootVertifyHitBoxScale = class(CSkillNodeBase, nil, SkillAction_ChangeShootVertifyHitBoxScale)
return CSkillAction_ChangeShootVertifyHitBoxScale