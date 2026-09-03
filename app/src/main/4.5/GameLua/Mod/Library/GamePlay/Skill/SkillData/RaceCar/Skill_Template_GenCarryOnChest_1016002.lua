local SkillActorInst = {
  __parent = "/Game/Library/Res/Actors/RaceCar/Arts_PlayerBluePrints/Skill/Template/Skill_GenCarryOnChest.Skill_GenCarryOnChest_C",
  Inst = {
    SkillData = {
      PawnState = "EPawnState::Skill"
    },
    [0] = {
      HandleItemLimit01 = {ItemID = 43060001}
    },
    [1] = {
      AttrModify01 = {bWidgetEnabled = false},
      PlayMontage_Pose01 = {
        PoseMontageData = {
          AnimMontage_Stand = "/Game/Library/Res/Actors/RaceCar/Arts_Player/Characters/Anim/Open_Sheep_Gift_Montage.Open_Sheep_Gift_Montage"
        },
        FPPPoseMontageData = {
          AnimMontage_Stand = "/Game/Library/Res/Actors/RaceCar/Arts_Player/Characters/Anim/Open_Sheep_Gift_Montage.Open_Sheep_Gift_Montage"
        }
      },
      AttachActor01 = {
        AttachActorData = {
          ActorTemplate = "/Game/Library/Res/Actors/RaceCar/Arts_PlayerBluePrints/Items/BP_RaceCarChestMesh_01.BP_RaceCarChestMesh_01_C"
        }
      }
    },
    [2] = {
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Library/Res/Actors/RaceCar/Arts_PlayerBluePrints/Items/BP_RaceCarChest_01.BP_RaceCarChest_01_C"
        }
      },
      ConsumeHandleItem01 = {ItemID = 43060001}
    }
  }
}
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillActorInst)
return CSkillActorInst