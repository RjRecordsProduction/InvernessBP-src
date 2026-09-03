local TableUtil = require("common.table_util")
local EMovementMode = import("EMovementMode")
local UKismetMathLibrary = import("KismetMathLibrary")
local UGameplayStatics = import("GameplayStatics")
local FlyingWingConfig = require("GameLua.ExtraModule.SkillCore.Gameplay.FlyingWing.FlyingWingConfig")
local Skill_FlyingWing_Jump_Inst = {
  Inst = {}
}
function Skill_FlyingWing_Jump_Inst:CheckCanUse()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return false
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return false
  end
  print(bWriteLog and "Skill_FlyingWing_Jump_Inst:CheckCanUse")
  return true
end
function Skill_FlyingWing_Jump_Inst:ShowWing()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return false
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return false
  end
  if not uOwner:HasAuthority() then
    return
  end
  print(bWriteLog and "Skill_FlyingWing_Jump_Inst:ShowWing")
  local uWingActor = uOwner.uWingActor
  if not slua.isValid(uWingActor) then
    print(bWriteLog and "Skill_FlyingWing_Jump_Inst:ShowWing uWingActor is nil")
    return
  end
  uWingActor:Equip()
end
function Skill_FlyingWing_Jump_Inst:HideWing()
  if not slua.isValid(self.SpecificSkillCompRef) then
    return false
  end
  local uOwner = self.SpecificSkillCompRef:GetOwner()
  if not slua.isValid(uOwner) then
    return false
  end
  if not uOwner:HasAuthority() then
    return
  end
  print(bWriteLog and "Skill_FlyingWing_Jump_Inst:HideWing")
  local uWingActor = uOwner.uWingActor
  if not slua.isValid(uWingActor) then
    print(bWriteLog and "Skill_FlyingWing_Jump_Inst:ShowWing uWingActor is nil")
    return
  end
  uWingActor:Unequip()
end
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkill_FlyingWing_Jump_Inst = class(CSkillActorBase, nil, Skill_FlyingWing_Jump_Inst)
return CSkill_FlyingWing_Jump_Inst