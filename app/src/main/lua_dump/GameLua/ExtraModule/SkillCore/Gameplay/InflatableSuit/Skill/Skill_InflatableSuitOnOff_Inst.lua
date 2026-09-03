local Skill_InflatableSuitOnOff_Inst = {
  Inst = {
    SkillData = {bAutoShowRegisteredSkillUI = true}
  }
}
local ESpecialMovementType = import("ESpecialMovementType")
local UKismetMathLibrary = import("KismetMathLibrary")
local ECollisionChannel = import("ECollisionChannel")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local SkillUtils = require("GameLua.GameCore.Module.Skill.SkillUtils")
function Skill_InflatableSuitOnOff_Inst:PrepareData()
  print(bWriteLog and "Skill_InflatableSuitOnOff_Inst:PrepareData")
  if not slua.isValid(self.SpecificSkillCompRef) then
    return
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return
  end
end
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkill_InflatableSuitOnOff_Inst = class(CSkillActorBase, nil, Skill_InflatableSuitOnOff_Inst)
return CSkill_InflatableSuitOnOff_Inst