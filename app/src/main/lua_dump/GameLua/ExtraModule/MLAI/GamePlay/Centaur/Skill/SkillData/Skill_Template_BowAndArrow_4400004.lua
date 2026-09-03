local SkillActorInst = {
  __parent = "/Game/Library/Res/Skills/Mercenary/Skill_Template_BowAndArrow.Skill_Template_BowAndArrow_C",
  Inst = {
    SkillData = {
      SkillName = "\232\147\132\229\138\155\231\136\134\231\130\184\231\174\173",
      SkillBlackboardParamList = {
        [2] = {
          DefaultValue = {DefaultInt = 2000}
        },
        [3] = {
          DefaultValue = {DefaultFloat = 2.0}
        },
        [5] = {
          ResetRuleArray = {
            [1] = "ESkillBlackboardResetRule::ESBBRR_SkillStart",
            [2] = "ESkillBlackboardResetRule::ESBBRR_SkillEnd"
          },
          Name = "TargetPlayer",
          Type = "EUAEBlackboardType::EBT_WeakObjectPtr"
        }
      }
    },
    [0] = {
      ["/Script/Addons.UAESkillAction_SetBlackboardV"] = {
        __InsertIndex = 0,
        Key = {
          SelectedKeyName = "AccumulatedTimeUInt"
        },
        Type = "EUAEBlackboardType::EBT_UInt",
        ExpectedInt = 2000,
        __NewClassPath = "/Script/Addons.UAESkillAction_SetBlackboardV"
      },
      ["/Script/Skill.UTSkillCondition_Lua"] = {
        __InsertIndex = 1,
        LuaFilePath = "GameLua.ExtraModule.MLAI.Gameplay.Centaur.Skill.SkillCondition.SkillCondition_CentaurCanUseSkill",
        __NewClassPath = "/Script/Skill.UTSkillCondition_Lua"
      }
    },
    [1] = {
      PhaseData = {
        SyncBBKArray = {
          [1] = {
            SelectedKeyName = "TargetPlayer"
          }
        }
      },
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Library/Res/AI/Centaur/BluePrints/Weapon/BP_Projectile_CentaurArrow_Explosion.BP_Projectile_CentaurArrow_Explosion_C"
        }
      },
      ["/Script/Addons.UAESkillAction_SetBlackboardV"] = {
        __InsertIndex = 2,
        Key = {
          SelectedKeyName = "AccumulatedTime"
        },
        SetType = "ESetType::Multiply",
        Type = "EUAEBlackboardType::EBT_Float",
        ExpectedFloat = 0.001,
        __NewClassPath = "/Script/Addons.UAESkillAction_SetBlackboardV"
      },
      ["/Script/Addons.UAESkillAction_FindTarget"] = {
        __InsertIndex = 3,
        TargetPicker = {
          CapsuleData = {
            Radius = 5000.0,
            HalfHeight = 5000.0,
            MinCosValue = -1.0
          },
          BaseData = {
            PickerType = "UTSkillPickerType::SPT_BLACKBOARD",
            PickerOriginBlackboardKey = {
              SelectedKeyName = "TargetLocation"
            },
            bOnlyHero = true
          },
          Filters = {
            [1] = {
              CareActorClass = {
                [1] = "/Script/ShadowTrackerExtra.STExtraBaseCharacter"
              },
              __NewClassPath = "/Script/ShadowTrackerExtra.UAESkillPickerFilter_CareActorClass"
            }
          },
          __NewClassPath = "/Script/ShadowTrackerExtra.UAESkillPicker_Capsule"
        },
        TargetKeySelector = {
          SelectedKeyName = "TargetPlayer"
        },
        BaseData = {
          ActionRole = "ESkillActionRole::ESAR_Authority"
        },
        __NewClassPath = "/Script/Addons.UAESkillAction_FindTarget"
      }
    },
    [2] = {
      PhaseData = {
        SyncBBKArray = {
          [1] = {
            SelectedKeyName = "TargetPlayer"
          }
        }
      },
      ["/Script/Skill.UTSkillAction_Lua"] = {
        __InsertIndex = 5,
        LuaParams = {
          LocationBBKey = "TargetLocation",
          PlayerBBKey = "TargetPlayer"
        },
        bEnableLuaPrivateData = true,
        LuaFilePath = "GameLua.ExtraModule.MLAI.Gameplay.Centaur.Skill.SkillAction.SkillAction_CentaurArrowTickAim",
        __NewClassPath = "/Script/Skill.UTSkillAction_Lua"
      }
    }
  }
}
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst