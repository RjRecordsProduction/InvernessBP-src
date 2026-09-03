local SkillAction_DisableOtherSkill = {
  sObjectName = "SkillAction_DisableOtherSkill"
}
local EPawnState = import("EPawnState")
function SkillAction_DisableOtherSkill:ctor(selfType)
  print(bWriteLog and "SkillAction_DisableOtherSkill:ctor")
end
function SkillAction_DisableOtherSkill:LuaRealDoAction()
  local uCharacter = self:GetOwnerPawn()
  print(bWriteLog and "SkillAction_DisableOtherSkill:LuaRealDoAction")
  if slua.isValid(uCharacter) and slua.isValid(uCharacter.SkillManager) then
    print(bWriteLog and "SkillAction_DisableOtherSkill:LuaRealDoAction SetSkillTagsDisable:" .. tostring(uCharacter))
    local DisableTag = self:GetDisableTag()
    uCharacter.SkillManager:SetSkillTagsDisable({DisableTag}, true, "DisableAllOtherSKill")
  end
  return true
end
function SkillAction_DisableOtherSkill:LuaUndoAction()
  local uCharacter = self:GetOwnerPawn()
  print(bWriteLog and "SkillAction_DisableOtherSkill:LuaUndoAction")
  if slua.isValid(uCharacter) and slua.isValid(uCharacter.SkillManager) then
    print(bWriteLog and "SkillAction_DisableOtherSkill:LuaUndoAction SetSkillTagsDisable reset:" .. tostring(uCharacter))
    local DisableTag = self:GetDisableTag()
    uCharacter.SkillManager:SetSkillTagsDisable({DisableTag}, false, "DisableAllOtherSKill")
  end
  SkillAction_DisableOtherSkill.__super.LuaUndoAction(self)
end
function SkillAction_DisableOtherSkill:GetDisableTag()
  if self.DisableTag and self.DisableTag > 0 then
    return self.DisableTag
  end
  return 0
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CSkillNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_DisableOtherSkill = class(CSkillNodeBase, nil, SkillAction_DisableOtherSkill)
return CSkillAction_DisableOtherSkill