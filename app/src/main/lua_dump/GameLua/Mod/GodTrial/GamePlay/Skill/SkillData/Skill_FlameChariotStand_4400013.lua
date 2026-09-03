local SkillActorInst = {
  __parent = "/Game/Mod/GodTrial/BluePrints/Skill/Skill_FlameChariotStand.Skill_FlameChariotStand_C",
  Inst = {
    [4] = {
      PlayMontageWithSection01 = {AnimMontage = ""}
    }
  }
}
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst