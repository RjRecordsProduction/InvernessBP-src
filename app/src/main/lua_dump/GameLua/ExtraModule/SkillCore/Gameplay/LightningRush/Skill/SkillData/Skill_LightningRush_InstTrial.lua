local SkillActorInst = {
  __parent = "/Game/Library/Res/Skills/LightningRush/Arts_PlayerBluePrints/Skill/Skill_LightningRush.Skill_LightningRush_C",
  Inst = {}
}
local class = require("class")
local CSkillActorBase = require("GameLua.ExtraModule.SkillCore.Gameplay.LightningRush.Skill.SkillData.Skill_LightningRush_Inst")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst