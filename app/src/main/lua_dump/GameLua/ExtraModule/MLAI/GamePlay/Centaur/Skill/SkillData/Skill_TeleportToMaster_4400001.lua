local SkillActorInst = {
  __parent = "/Game/Library/Res/Skills/Mercenary/Skill_TeleportToMaster.Skill_TeleportToMaster_C",
  Inst = {
    [1] = {
      TeleportTo01 = {
        OffsetVec = {Z = 100.0},
        FindSafeLocationResolveParams = {
          bLineTracePassWall = true,
          IterationRounds = 3,
          AdjustRadius = 100.0
        }
      },
      TeleportTo02 = {
        LocationPicker = {OffsetFromGroundUpward = 150.0}
      }
    }
  }
}
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst