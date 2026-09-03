local SkillActorInst = {
  __parent = "/Game/Mod/EvoBase/Arts_PlayerBluePrints/Skill/Template/Skill_Template_PlayMontage.Skill_Template_PlayMontage_C",
  Inst = {
    [0] = {
      PhaseData = {PhaseDuration = 6.9},
      PlayMontage01 = {
        AnimMontage = "/Game/Library/Res/AI/Centaur/Arts_Player/Animations/Centaur/Zombie170_int_idle01_Montage.Zombie170_int_idle01_Montage"
      }
    }
  }
}
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst