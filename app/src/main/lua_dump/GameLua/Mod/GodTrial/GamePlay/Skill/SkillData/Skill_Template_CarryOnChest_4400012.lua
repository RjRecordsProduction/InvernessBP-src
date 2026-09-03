local SkillActorInst = {
  __parent = "/Game/Mod/VersionRes/440/Arts_PlayerBluePrints/Skill/Skill_GenCarryOnChest.Skill_GenCarryOnChest_C",
  Inst = {
    [0] = {
      HandleItemLimit01 = {ItemID = 440001}
    },
    [1] = {
      AttachActor01 = {
        AttachActorData = {
          ActorTemplate = "/Game/Mod/VersionRes/440/Arts_PlayerBluePrints/Items/BP_CarryOnChestMesh_01.BP_CarryOnChestMesh_01_C"
        },
        BaseData = {DelayTime = 0.33}
      }
    },
    [2] = {
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Mod/VersionRes/440/Arts_PlayerBluePrints/Items/BP_CarryOnChest_01.BP_CarryOnChest_01_C"
        }
      },
      ConsumeHandleItem01 = {ItemID = 440001},
      ["/Script/ShadowTrackerExtra.UAESkillCondition_HandleItemLimit"] = {
        __InsertIndex = 0,
        OperatorType = "EOperatorType::EOperator_GreaterEqual",
        ItemID = 440001,
        __NewClassPath = "/Script/ShadowTrackerExtra.UAESkillCondition_HandleItemLimit"
      }
    }
  }
}
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst