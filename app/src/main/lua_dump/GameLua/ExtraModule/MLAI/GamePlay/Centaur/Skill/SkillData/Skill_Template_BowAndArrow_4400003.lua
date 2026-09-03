local SkillActorInst = {
  __parent = "/Game/Library/Res/Skills/Mercenary/Skill_Template_BowAndArrow.Skill_Template_BowAndArrow_C",
  Inst = {
    [0] = {
      ["/Script/Skill.UTSkillCondition_Lua"] = {
        __InsertIndex = 1,
        LuaFilePath = "GameLua.ExtraModule.MLAI.Gameplay.Centaur.Skill.SkillCondition.SkillCondition_CentaurCanUseSkill",
        __NewClassPath = "/Script/Skill.UTSkillCondition_Lua"
      }
    },
    [1] = {
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Library/Res/AI/Centaur/BluePrints/Weapon/BP_Projectile_CentaurArrow_Lite.BP_Projectile_CentaurArrow_Lite_C"
        }
      },
      PlayMontage01 = {
        AnimMontage = "/Game/Library/Res/AI/Centaur/Arts_Player/Animations/Centaur/Zombie170_int_Attack01_Montage.Zombie170_int_Attack01_Montage"
      }
    },
    [3] = {
      PlayMontage01 = {
        AnimMontage = "/Game/Library/Res/AI/Centaur/Arts_Player/Animations/Centaur/Zombie170_int_Attack01_Montage.Zombie170_int_Attack01_Montage"
      },
      ["/Script/Addons.UAESkillAction_CoolDown"] = {
        __InsertIndex = 2,
        bResetCD = true,
        BaseData = {DelayTime = 0.9},
        __NewClassPath = "/Script/Addons.UAESkillAction_CoolDown"
      }
    }
  }
}
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst