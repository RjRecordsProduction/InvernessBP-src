local SkillActorInst = {
  __parent = "/Game/Library/Res/AI/Centaur/BluePrints/Skill/Skill_Centaur_Stomp.Skill_Centaur_Stomp_C",
  Inst = {
    [0] = {
      ["/Script/Skill.UTSkillCondition_Lua"] = {
        LuaFilePath = "GameLua.ExtraModule.MLAI.Gameplay.Centaur.Skill.SkillCondition.SkillCondition_CentaurCanUseSkill"
      }
    }
  }
}
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst