local SkillActorInst = {
  __parent = "/Game/Mod/EvoBase/Arts_PlayerBluePrints/Skill/Template/Skill_Template_HangGlider.Skill_Template_HangGlider_C",
  Inst = {
    [1] = {
      PlayMontage01 = {
        AnimMontage = "/Game/Library/Res/Skills/HangGlider/Arts_Player/Animation/Hangglider_Open_Montage.Hangglider_Open_Montage"
      },
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Mod/EasternRealm/Arts_PlayerBluePrints/HangGlider/HangGlider.HangGlider_C"
        }
      },
      UTSkillEventEffectMapForEditor02 = {
        SkillEffect = {
          in_pAkEvent = "/Game/Library/Res/Skills/HangGlider/WwiseEvent/Stop_Turkey_HangGlider_Wind_Loop.Stop_Turkey_HangGlider_Wind_Loop"
        }
      }
    },
    [2] = {
      ReplaceCharAnim01 = {
        AnimDataList = {
          [1] = {
            PoseAnimList = {
              [1] = "/Game/Library/Res/Skills/HangGlider/Arts_Player/Animation/BS_M_Hangglider.BS_M_Hangglider"
            },
            FPPPoseAnimList = {
              [1] = "/Game/Library/Res/Skills/HangGlider/Arts_Player/Animation/BS_M_Hangglider.BS_M_Hangglider"
            }
          },
          [2] = {
            PoseAnimList = {
              [1] = "/Game/Library/Res/Skills/HangGlider/Arts_Player/Animation/Hangglider_Hit_F.Hangglider_Hit_F"
            },
            FPPPoseAnimList = {
              [1] = "/Game/Library/Res/Skills/HangGlider/Arts_Player/Animation/Hangglider_Hit_F.Hangglider_Hit_F"
            }
          }
        }
      },
      ScreenParticle01 = {
        ParticleTemplates = {
          [1] = "/Game/Library/Res/Skills/HangGlider/Arts_Effect/ParticleSystems/P_Glider_airflow_screen_effect_Teq_zxw.P_Glider_airflow_screen_effect_Teq_zxw"
        },
        ParticleTemplate_Ints = {
          [1] = "/Game/Library/Res/Skills/HangGlider/Arts_Effect/ParticleSystems/P_Glider_airflow_screen_effect_Teq_zxw.P_Glider_airflow_screen_effect_Teq_zxw"
        }
      },
      UTSkillEventEffectMapForEditor03 = {
        SkillEffect = {
          in_pAkEvent = "/Game/Library/Res/Skills/HangGlider/WwiseEvent/Stop_Turkey_HangGlider_Wind_Loop.Stop_Turkey_HangGlider_Wind_Loop"
        }
      }
    },
    [3] = {
      PlayMontage01 = {
        AnimMontage = "/Game/Library/Res/Skills/HangGlider/Arts_Player/Animation/Hangglider_Down_Montage.Hangglider_Down_Montage"
      },
      PostEventAtLoc01 = {
        in_pAkEvent = "/Game/Library/Res/Skills/HangGlider/WwiseEvent/Stop_Turkey_HangGlider_Wind_Loop.Stop_Turkey_HangGlider_Wind_Loop"
      }
    }
  }
}
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst