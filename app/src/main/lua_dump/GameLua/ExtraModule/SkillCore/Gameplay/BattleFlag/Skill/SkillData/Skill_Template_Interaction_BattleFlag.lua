local SkillActorInst = {
  __parent = "/Game/Mod/EvoBase/Arts_PlayerBluePrints/Skill/Template/Skill_Template_Interaction.Skill_Template_Interaction_C",
  Inst = {
    [1] = {
      PhaseData = {PhaseDuration = 0.5},
      PlayMontage_Pose01 = {
        PoseMontageData = {
          AnimMontage_Stand = "/Game/Library/Res/Skills/BattleFlag/Arts_Player/Characters/Ani/Sparta_Flag_PlantFlag_end_Montage.Sparta_Flag_PlantFlag_end_Montage"
        },
        AnimStopAfterPhase = false,
        AnimStopAfterSkill = true
      }
    },
    [2] = {
      PhaseData = {PhaseDuration = 0.6},
      CheckActivityActor01 = {bTickCheckCondition = false}
    }
  }
}
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst