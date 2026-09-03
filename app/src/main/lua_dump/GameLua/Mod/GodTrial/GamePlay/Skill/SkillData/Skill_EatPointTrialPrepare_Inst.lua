local Skill_EatPointTrialPrepare_Inst = {
  Inst = {}
}
function Skill_EatPointTrialPrepare_Inst:ClearGravity()
  local uMovementComponent = self:GetMovementComponent()
  if not slua.isValid(uMovementComponent) then
    return
  end
  uMovementComponent:SetGravityScale(0, true)
  uMovementComponent.Velocity = FVector.ZeroVector
  print(bWriteLog and string.format("Skill_EatPointTrialPrepare_Inst:ClearGravity"))
end
function Skill_EatPointTrialPrepare_Inst:ResetGravity()
  local uMovementComponent = self:GetMovementComponent()
  if not slua.isValid(uMovementComponent) then
    return
  end
  uMovementComponent:SetGravityScale(1, false)
  print(bWriteLog and string.format("Skill_EatPointTrialPrepare_Inst:ResetGravity"))
end
function Skill_EatPointTrialPrepare_Inst:GetMovementComponent()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return
  end
  local uMovementComponent = uOwner.STCharacterMovement
  return uMovementComponent
end
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkill_EatPointTrialPrepare_Inst = class(CSkillActorBase, nil, Skill_EatPointTrialPrepare_Inst)
return CSkill_EatPointTrialPrepare_Inst