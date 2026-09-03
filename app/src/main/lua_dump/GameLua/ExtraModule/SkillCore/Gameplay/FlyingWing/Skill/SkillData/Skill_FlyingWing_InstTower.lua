local SkillActorInst = {
  __parent = "/Game/Library/Res/Skills/FlyingWing/Arts_PlayerBluePrints/Skill/Skill_FlyingWing.Skill_FlyingWing_C",
  Inst = {
    [1] = {
      SetViewLimit01 = {
        MinRotator = {Pitch = 84.0, Yaw = 0.0},
        MaxRotator = {Pitch = 100.0, Yaw = 0.0}
      },
      SetCameraData01 = {
        SkillCameraData = {
          TargetOffset = {X = -150.0}
        }
      }
    },
    [2] = {
      AddCmptToPicker01 = {
        Components = {
          [1] = "/Game/Library/Res/Skills/FlyingWing/Arts_PlayerBluePrints/Skill/BP_PlayerSlideComponent_FlyingWing_Tower.BP_PlayerSlideComponent_FlyingWing_Tower_C"
        }
      },
      SetViewLimit01 = {
        MinRotator = {Pitch = 84.0},
        MaxRotator = {Yaw = 0.0}
      }
    },
    [3] = {
      PhaseData = {PhaseDuration = 45.0},
      SetViewLimit01 = {
        MinRotator = {Pitch = 93.0, Yaw = -90.0},
        MaxRotator = {Pitch = 98.0, Yaw = 90.0}
      }
    }
  }
}
local class = require("class")
local CSkillActorBase = require("GameLua.ExtraModule.SkillCore.Gameplay.FlyingWing.Skill.SkillData.Skill_FlyingWing_Inst")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst