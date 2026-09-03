local SkillAction_UpdateExecuteState = {
  sObjectName = "SkillAction_UpdateExecuteState",
  TargetBlackboardKey = "ExecuteTarget"
}
function SkillAction_UpdateExecuteState:ctor(selfType)
end
function SkillAction_UpdateExecuteState:LuaRealDoAction()
  local uOwnerPawn = self:GetOwnerPawn()
  if uOwnerPawn and uOwnerPawn.SetIsExecutingOther then
    uOwnerPawn:SetIsExecutingOther(true)
  end
  local uCurSkill = self:GetOwnerSkill()
  local uSkillManager = self:GetOwnerSkillManager()
  local uTarget
  if slua.isValid(uSkillManager) and slua.isValid(uCurSkill) then
    uTarget = uSkillManager:GetValueAsWeakObject(uCurSkill.SkillID, self.TargetBlackboardKey)
    if uTarget then
      if uTarget.SetIsBeingExecuted then
        uTarget:SetIsBeingExecuted(true)
      end
      if uTarget.bCanBeRescued then
        uTarget.bCanBeRescued = uTarget.bCanBeRescued - 1
      end
    end
  end
  return true
end
function SkillAction_UpdateExecuteState:LuaUndoAction()
  local uOwnerPawn = self:GetOwnerPawn()
  if uOwnerPawn and uOwnerPawn.SetIsExecutingOther then
    uOwnerPawn:SetIsExecutingOther(false)
  end
  local uCurSkill = self:GetOwnerSkill()
  local uSkillManager = self:GetOwnerSkillManager()
  local uTarget
  if slua.isValid(uSkillManager) and slua.isValid(uCurSkill) then
    uTarget = uSkillManager:GetValueAsWeakObject(uCurSkill.SkillID, self.TargetBlackboardKey)
    if uTarget then
      if uTarget.SetIsBeingExecuted then
        uTarget:SetIsBeingExecuted(false)
      end
      if uTarget.bCanBeRescued then
        uTarget.bCanBeRescued = uTarget.bCanBeRescued + 1
      end
    end
  end
  SkillAction_UpdateExecuteState.__super.LuaUndoAction(self)
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CSkillNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
return class(CSkillNodeBase, nil, SkillAction_UpdateExecuteState)