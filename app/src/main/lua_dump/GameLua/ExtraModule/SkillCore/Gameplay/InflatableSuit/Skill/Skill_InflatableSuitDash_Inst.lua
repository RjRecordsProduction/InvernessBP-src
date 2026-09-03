local Skill_InflatableSuitDash_Inst = {
  Inst = {
    SkillData = {bAutoShowRegisteredSkillUI = true}
  }
}
local ESpecialMovementType = import("ESpecialMovementType")
local UKismetMathLibrary = import("KismetMathLibrary")
local ECollisionChannel = import("ECollisionChannel")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local SkillUtils = require("GameLua.GameCore.Module.Skill.SkillUtils")
function Skill_InflatableSuitDash_Inst:PrepareData()
  print(bWriteLog and "Skill_InflatableSuitDash_Inst:PrepareData")
  if not slua.isValid(self.SpecificSkillCompRef) then
    return
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return
  end
  if not uOwner:HasAuthority() then
    return
  end
  local Weights = {
    [1] = 0,
    [2] = 0,
    [3] = 100
  }
  local SkillConfig = SkillUtils.GetSkillConfig(self.SkillID)
  if SkillConfig and SkillConfig.SkillRandomType then
    Weights = SkillConfig.SkillRandomType
  end
  local RandomPhaseIndex = Game:RandomByWeight(Weights, 1)[1]
  if uOwner.SuitSkillIndex and 0 < uOwner.SuitSkillIndex and uOwner.SuitSkillIndex < 4 then
    RandomPhaseIndex = uOwner.SuitSkillIndex
  end
  self.SpecificSkillCompRef:SetValueAsInt(self.SkillID, "RandomPhaseIndex", RandomPhaseIndex)
  print(bWriteLog and string.format("Skill_InflatableSuitDash_Inst:PrepareData RandomPhaseIndex: %s", tostring(RandomPhaseIndex)))
end
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkill_InflatableSuitDash_Inst = class(CSkillActorBase, nil, Skill_InflatableSuitDash_Inst)
return CSkill_InflatableSuitDash_Inst