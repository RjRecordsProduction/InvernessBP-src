local ESkillActionRole = import("ESkillActionRole")
local SkillActorInst = {
  __parent = "/Game/Arts_PlayerBluePrints/Skill/Skill_Punch_Fist_bp.Skill_Punch_Fist_bp_C",
  Inst = {
    SkillData = {
      BaseData = {bEnableCombo = false}
    },
    [2] = {
      PhaseData = {PhaseDuration = 1.3},
      PlayMontage_Pose01 = {
        PoseMontageData = {
          AnimMontage_Stand = "/Game/Library/Res/AI/CarryMinatiBoss/Ani/AM_CarryMeleeAttack1.AM_CarryMeleeAttack1",
          AnimMontage_Crouch = "/Game/Library/Res/AI/CarryMinatiBoss/Ani/AM_CarryMeleeAttack1.AM_CarryMeleeAttack1"
        }
      }
    },
    [3] = {
      PhaseData = {PhaseDuration = 1.3},
      PlayMontage_Pose01 = {
        PoseMontageData = {
          AnimMontage_Stand = "/Game/Library/Res/AI/CarryMinatiBoss/Ani/AM_CarryMeleeAttack1.AM_CarryMeleeAttack1",
          AnimMontage_Crouch = "/Game/Library/Res/AI/CarryMinatiBoss/Ani/AM_CarryMeleeAttack1.AM_CarryMeleeAttack1"
        }
      }
    },
    [4] = {
      PhaseData = {PhaseDuration = 1.3},
      PlayMontage_Pose01 = {
        PoseMontageData = {
          AnimMontage_Stand = "/Game/Library/Res/AI/CarryMinatiBoss/Ani/AM_CarryMeleeAttack1.AM_CarryMeleeAttack1",
          AnimMontage_Crouch = "/Game/Library/Res/AI/CarryMinatiBoss/Ani/AM_CarryMeleeAttack1.AM_CarryMeleeAttack1"
        }
      }
    }
  }
}
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst