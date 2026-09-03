local SkillActorInst = {
  __parent = "/Game/Library/Res/Skills/Mercenary/Skill_Template_BowAndArrow.Skill_Template_BowAndArrow_C",
  Inst = {
    SkillData = {
      SkillName = "\228\186\186\233\169\172\232\147\132\229\138\155\230\142\162\230\181\139\231\174\173"
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
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Library/Res/AI/Centaur/BluePrints/Weapon/BP_Projectile_CentaurArrow_Detection.BP_Projectile_CentaurArrow_Detection_C"
        }
      },
      PlayMontage01 = {
        AnimMontage = "/Game/Library/Res/AI/Centaur/Arts_Player/Animations/Centaur/Zombie170_int_Skill04_Montage_Detection.Zombie170_int_Skill04_Montage_Detection"
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
      }
    },
    [3] = {
      ["/Script/Skill.UTSkillAction_Lua"] = {
        __InsertIndex = 2,
        LuaParams = {
          TlogTypeName = "TlogForRound",
          TlogID = 711,
          nValue = 1
        },
        LuaFilePath = "GameLua.Mod.Library.GamePlay.Skill.SkillAction.SkillAction_ReportToTLog",
        BaseData = {
          ActionRole = "ESkillActionRole::ESAR_Authority"
        },
        Commend = "\230\138\128\232\131\189\228\189\191\231\148\168\230\172\161\230\149\176Tlog\228\184\138\230\138\165",
        __NewClassPath = "/Script/Skill.UTSkillAction_Lua"
      }
    }
  }
}
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst