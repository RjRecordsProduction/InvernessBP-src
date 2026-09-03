local EUAESkillEvent = import("EUAESkillEvent")
local SkillInstData = {
  Inst = {
    SkillData = {bAutoShowRegisteredSkillUI = true},
    [0] = {
      PhaseData = {PhaseDuration = 2.7},
      PlayMontage_Pose01 = {
        PoseMontageData = {
          AnimMontage_Stand = "/Game/Mod/BRMod/BluePrints/Actor/PicnicMat/Anim/Character_Stand_Eat_Food_Montage.Character_Stand_Eat_Food_Montage",
          AnimMontage_Crouch = "/Game/Mod/BRMod/BluePrints/Actor/PicnicMat/Anim/Character_Prone_Eat_Food_Montage.Character_Prone_Eat_Food_Montage",
          AnimMontage_Prone = "/Game/Mod/BRMod/BluePrints/Actor/PicnicMat/Anim/Character_Prone_Eat_Food_Montage.Character_Prone_Eat_Food_Montage"
        },
        BaseData = {DelayTime = 0.3}
      }
    }
  }
}
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillInstData)
return CSkillActorInst