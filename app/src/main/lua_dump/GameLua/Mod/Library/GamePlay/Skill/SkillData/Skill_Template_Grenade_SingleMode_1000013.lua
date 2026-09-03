local ECharacterAnimType = import("ECharacterAnimType")
local EPawnState = import("EPawnState")
local ESkillCanBePlayedResult = import("ESkillCanBePlayedResult")
local SkillInstData = {
  Inst = {
    SkillData = {
      CastFailTipsIDMap = {
        [ESkillCanBePlayedResult.Fail_Default] = 66486
      }
    },
    [0] = {
      PhaseData = {PhaseDuration = 1.0},
      HandleItemLimit01 = {ItemID = 602210, ItemId = 602210},
      CurrentWeapon01 = {
        ItemType = 6,
        ItemID = 602210,
        ItemId = 602210
      },
      SpawnActor01 = {
        SpawnActorData = {
          SoftActorTemplate = "/Game/Arts_PlayerBluePrints/Weapon/Grenade/TarotCard/BP_Grenade_GrimReaperCard.BP_Grenade_GrimReaperCard_C"
        }
      },
      PlayMontage_Pose01 = {
        PoseMontageData = {
          AnimMontage_Stand = "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/Combat_Stand_Card_Aim_Montage.Combat_Stand_Card_Aim_Montage",
          AnimMontage_Crouch = "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/Combat_Crouch_Card_Aim_Montage.Combat_Crouch_Card_Aim_Montage"
        },
        FPPPoseMontageData = {
          AnimMontage_Stand = "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/Combat_Stand_Card_Aim_Montage.Combat_Stand_Card_Aim_Montage",
          AnimMontage_Crouch = "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/Combat_Crouch_Card_Aim_Montage.Combat_Crouch_Card_Aim_Montage"
        }
      },
      ReplaceCharAnim01 = {
        AnimDataList = {
          {
            CharacterAnimType = ECharacterAnimType.ECharAnim_Move
          },
          {
            CharacterAnimType = ECharacterAnimType.ECharAnim_Aim,
            PoseAnimList = {
              "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/BS_Card_Aim_Stand.BS_Card_Aim_Stand",
              "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/BS_Card_Aim_Crouch.BS_Card_Aim_Crouch"
            },
            FPPPoseAnimList = {
              "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/BS_Card_Aim_Stand.BS_Card_Aim_Stand",
              "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/BS_Card_Aim_Crouch.BS_Card_Aim_Crouch"
            }
          }
        }
      },
      ["/Script/Addons.UAESkillCondition_PlayerState"] = {
        ArrFatalPlayerState = {
          EPawnState.Prone,
          EPawnState.Picth
        }
      }
    },
    [1] = {
      HandleItemLimit01 = {ItemID = 602210, ItemId = 602210},
      ["/Script/Addons.UAESkillCondition_PlayerState"] = {
        ArrFatalPlayerState = {
          EPawnState.Prone,
          EPawnState.Picth
        }
      }
    },
    [2] = {
      PhaseData = {PhaseDuration = 1.86},
      ShowWeapon01 = {
        BaseData = {DelayTime = 0.65}
      },
      CustomEvent01 = {
        BaseData = {DelayTime = 0.65}
      },
      ConsumeHandleItem01 = {
        ItemID = 602210,
        ItemId = 602210,
        BaseData = {DelayTime = 0.71}
      },
      AttrModify01 = {
        AttrModifier = {ModifierValue = 602210}
      },
      PlayMontage_Pose01 = {
        PoseMontageData = {
          AnimMontage_Stand = "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/Combat_Stand_Card_End_Montage_Battle.Combat_Stand_Card_End_Montage_Battle",
          AnimMontage_Crouch = "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/Combat_Crouch_Card_End_Montage.Combat_Crouch_Card_End_Montage"
        },
        FPPPoseMontageData = {
          AnimMontage_Stand = "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/Combat_Stand_Card_End_Montage_Battle.Combat_Stand_Card_End_Montage_Battle",
          AnimMontage_Crouch = "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/Combat_Crouch_Card_End_Montage.Combat_Crouch_Card_End_Montage"
        }
      },
      ["/Script/Addons.UAESkillCondition_PlayerState"] = {
        ArrFatalPlayerState = {
          EPawnState.Prone,
          EPawnState.Picth
        }
      },
      ["/Script/Addons.UAESkillAction_ReplaceCharAnim"] = {
        AnimDataList = {
          {
            CharacterAnimType = ECharacterAnimType.ECharAnim_Move,
            PoseAnimList = {
              "/Game/Arts_PlayerBluePrints/Characters/Animation/Shared_Anim/WeaponType_Anim/Grenade/Locomotion/BS_Grenade_Stand_Idle-Run-Sprint.BS_Grenade_Stand_Idle-Run-Sprint",
              "/Game/Arts_PlayerBluePrints/Characters/Animation/Shared_Anim/WeaponType_Anim/Grenade/Locomotion/BS_Grenade_Crouch_Idle-Run-Sprint.BS_Grenade_Crouch_Idle-Run-Sprint"
            },
            FPPPoseAnimList = {
              "/Game/Arts_PlayerBluePrints/Characters/Animation/Shared_Anim/WeaponType_Anim/Grenade/Locomotion/BS_Grenade_Stand_Idle-Run-Sprint.BS_Grenade_Stand_Idle-Run-Sprint",
              "/Game/Arts_PlayerBluePrints/Characters/Animation/Shared_Anim/WeaponType_Anim/Grenade/Locomotion/BS_Grenade_Crouch_Idle-Run-Sprint.BS_Grenade_Crouch_Idle-Run-Sprint"
            }
          },
          {
            CharacterAnimType = ECharacterAnimType.ECharAnim_Aim,
            PoseAnimList = {
              "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/BS_Card_Stand.BS_Card_Stand",
              "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/BS_Card_Crouch.BS_Card_Crouch"
            },
            FPPPoseAnimList = {
              "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/BS_Card_Stand.BS_Card_Stand",
              "/Game/Arts_PlayerBluePrints/Characters/Animation/Commerial/TarotCard/Throwing_Cards/BS_Card_Crouch.BS_Card_Crouch"
            }
          }
        }
      }
    },
    [3] = {
      ConsumeHandleItem01 = {ItemID = 602210, ItemId = 602210}
    }
  }
}
return SkillInstData