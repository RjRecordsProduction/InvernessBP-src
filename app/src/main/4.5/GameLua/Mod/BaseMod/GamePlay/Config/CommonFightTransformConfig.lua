local EAvatarSlotType = import("EAvatarSlotType")
local EAvatarDamagePosition = import("EAvatarDamagePosition")
local EPawnState = import("EPawnState")
local CommonFightTransformConfig = {
  LeftTimeBeforPlane = 15,
  CommonransformConfig = {
    [UEnums.HeroID.Liquid] = {
      TransformDuration = 150,
      ItemID = 150016,
      ChangeItemID = 604122,
      CapsuleHalfHeight = 88,
      CapsuleRadius = 70,
      SpringArmLength = 800,
      ChangeAnimMontage = "",
      SkillID = 1014675,
      TransformPawnState = EPawnState.Variation
    },
    [UEnums.HeroID.Werewolf] = {
      ConsiderFeature = {
        "WerewolfFeature"
      },
      BackpackClearAndRecoverStrategy = "WerewolfTransform",
      TransformDuration = 75,
      SkillCDIndex = 2,
      ItemID = 150014,
      ChangeItemID = 604120,
      CapsuleHalfHeight = 88,
      CapsuleRadius = 55,
      SpringArmLength = 350,
      bChangeAnimMontage = true,
      bChangeBackAnimMontage = true,
      SkillID = 1014676,
      ChangeSlotID = EAvatarSlotType.EAvatarSlotType_HeadEquipemtSlot,
      DisablePet = true,
      TransformPawnState = EPawnState.ShapeShifting,
      OnlySkillCall = true,
      CannInWater = true,
      CannInSpecialWater = false,
      HurtAudioPath = "/Game/Library/Res/Hero/Werewolf/WwiseEvent/Halloween4_Werewolf_340/Play_Halloween4_Werewolf_Hit.Play_Halloween4_Werewolf_Hit",
      DeathAudioPath = "/Game/Library/Res/Hero/Werewolf/WwiseEvent/Halloween4_Werewolf_340/Play_Halloween4_Werewolf_Die.Play_Halloween4_Werewolf_Die",
      AvatarCaptureAnimPath = "/Game/Library/Res/Hero/Werewolf/BluePrints/PlayerInfo/AvatarOBInfo_AvatarAnim.AvatarOBInfo_AvatarAnim",
      AddHitBodyPosMap = {
        [1] = {
          Key = "Bip001-L-Thigh",
          Value = EAvatarDamagePosition.BigLimbs
        },
        [2] = {
          Key = "Bip001-L-Calf",
          Value = EAvatarDamagePosition.BigLimbs
        },
        [3] = {
          Key = "Bip001-L-HorseLink",
          Value = EAvatarDamagePosition.BigLimbs
        },
        [4] = {
          Key = "Bip001-R-Thigh",
          Value = EAvatarDamagePosition.BigLimbs
        },
        [5] = {
          Key = "Bip001-R-Calf",
          Value = EAvatarDamagePosition.BigLimbs
        },
        [6] = {
          Key = "Bip001-R-HorseLink",
          Value = EAvatarDamagePosition.BigLimbs
        },
        [7] = {
          Key = "Bone008",
          Value = EAvatarDamagePosition.BigLimbs
        },
        [8] = {
          Key = "Bip001-Spine2",
          Value = EAvatarDamagePosition.BigBody
        },
        [9] = {
          Key = "Bip001-R-UpperArm",
          Value = EAvatarDamagePosition.BigLimbs
        },
        [10] = {
          Key = "Bip001-R-Forearm",
          Value = EAvatarDamagePosition.BigLimbs
        },
        [11] = {
          Key = "Bip001-Head",
          Value = EAvatarDamagePosition.BigHead
        },
        [12] = {
          Key = "Bip001-L-UpperArm",
          Value = EAvatarDamagePosition.BigLimbs
        },
        [13] = {
          Key = "Bip001-L-Forearm",
          Value = EAvatarDamagePosition.BigLimbs
        }
      },
      IgnoreSkillID = {
        [1014676] = true,
        [1014691] = true,
        [1014689] = true
      },
      IgnoreBuffIDs = {
        [60451] = true,
        [60452] = true,
        [60453] = true,
        [60383] = true,
        [10003] = true,
        [10007] = true
      },
      TlogInfo = {
        UseItem = 1239,
        UseItem2 = 1264,
        BecomeOtherFigure = 1240,
        BecomeOtherFigure2 = 1268,
        KillPeopleNum = 1241,
        KillPeopleNum2 = 1233,
        ChangeBeKillNum = 1261,
        ChangeBeKillNum2 = 1263
      }
    },
    [UEnums.HeroID.Vampire] = {
      ConsiderFeature = {
        "HeroFlyFeature"
      },
      BackpackClearAndRecoverStrategy = "VampireTransform",
      TransformDuration = 60,
      SkillCDIndex = 2,
      ItemID = 150015,
      BePreAddItem = true,
      ChangeItemID = 604121,
      CapsuleHalfHeight = 88,
      CapsuleRadius = 70,
      SpringArmLength = 350,
      SkillID = 1014677,
      ExitSkillID = 1014692,
      ChangeSlotID = EAvatarSlotType.EAvatarSlotType_MechaChestSlot,
      DisablePet = true,
      TransformPawnState = EPawnState.Variation,
      bChangeMoveLayer = true,
      OnlySkillCall = true,
      CannInSpecialWater = false,
      AvatarCaptureAnimPath = "/Game/Library/Res/Hero/Vampire/BluePrints/PlayerInfo/AvatarOBInfo_AvatarAnim.AvatarOBInfo_AvatarAnim",
      AddHitBodyPosMap = {
        [1] = {
          Key = "wing_R_07",
          Value = EAvatarDamagePosition.BigHand
        },
        [2] = {
          Key = "wing_R_04",
          Value = EAvatarDamagePosition.BigHand
        },
        [3] = {
          Key = "wing_R_01",
          Value = EAvatarDamagePosition.BigHand
        },
        [4] = {
          Key = "wing_L_07",
          Value = EAvatarDamagePosition.BigHand
        },
        [5] = {
          Key = "wing_L_04",
          Value = EAvatarDamagePosition.BigHand
        },
        [6] = {
          Key = "wing_L_01",
          Value = EAvatarDamagePosition.BigHand
        },
        [7] = {
          Key = "wing",
          Value = EAvatarDamagePosition.BigHand
        }
      },
      IgnoreSkillID = {
        [1014677] = true,
        [1014692] = true,
        [1014695] = true,
        [1014690] = true
      },
      IgnoreBuffIDs = {
        [60454] = true,
        [60383] = true,
        [10003] = true,
        [10007] = true
      },
      PermanentEffect = {
        [1] = {
          Path = "/Game/Library/Res/Hero/Vampire/Arts_Effect/Par/P_Vampire_Hand_Magic_01.P_Vampire_Hand_Magic_01",
          AttachBone = "hand_rSocket"
        }
      },
      TlogInfo = {
        UseItem = 1230,
        UseItem2 = 1264,
        BecomeOtherFigure = 1231,
        BecomeOtherFigure2 = 1268,
        KillPeopleNum = 1232,
        KillPeopleNum2 = 1233,
        ChangeBeKillNum = 1262,
        ChangeBeKillNum2 = 1263
      }
    },
    [UEnums.HeroID.SnowBall] = {
      TransformDuration = 6000,
      BePreAddItem = true,
      DisablePet = true,
      TransformPawnState = EPawnState.Variation,
      bNotClearSaveBackpack = true,
      bTransformToVehicle = true,
      BallSize = 20,
      FinishedStateBack = true,
      IgnoreSkillID = {
        [1038835] = true,
        [1038836] = true,
        [1038837] = true
      },
      ConsiderFeature = {
        "PlayerCharacterTransformVehicle"
      },
      bOnlyFPP = true,
      RadiusScaleWhenCheckPassWall = 0.1,
      HeightScaleWhenCheckPassWall = 0.1
    },
    [UEnums.HeroID.Titan] = {
      ConsiderVehicleFeature = {
        "VehicleTransformFeature"
      },
      TransformDuration = 60,
      NearExpirationLowerPercent = 0.2,
      SkillCDIndex = 2,
      SkillID = 3800002,
      DisablePet = true,
      bNotClearSaveBackpack = true,
      bExitHeroNotResetCharacterAttr = true,
      FinishedStateBack = true,
      bTransformToVehicle = true,
      TryAddOneSkillNotDelete = 3800002,
      ExitSkillID = 3800003,
      DefaultExitDelayDestroyTime = 1,
      ExitAnimTime = 2.5,
      TransformToVehicleParams = {
        bCacheVehicle = true,
        SoftActorTemplates = {
          ["/Game/Library/Res/Vehicles/Giant/Arts_PlayerBlueprints/BP_Giant.BP_Giant"] = 15,
          ["/Game/Library/Res/Vehicles/Giant/Arts_PlayerBlueprints/BP_Giant2.BP_Giant2"] = 15,
          ["/Game/Library/Res/Vehicles/Giant/Arts_PlayerBlueprints/BP_Giant3.BP_Giant3"] = 35,
          ["/Game/Library/Res/Vehicles/Giant/Arts_PlayerBlueprints/BP_Giant4.BP_Giant4"] = 35
        },
        SelectedKeyName = "TargetVehicleLocation",
        bSetCharacterHide = false,
        bHideStopTick = false
      },
      ExitAddBuffID = 600409,
      bDisableUseConsumables = true,
      bDetachPassengersWhenStartBack = true,
      PassengersLimitSkillIDs = {
        1001001,
        1001003,
        1001004,
        1001005,
        1001007,
        1001008,
        1001009,
        1001012,
        1001013,
        1001014,
        1001015,
        1001016,
        3800023,
        3800024,
        3800025,
        3800026
      },
      TlogInfo = {
        UseItem = 1549,
        BecomeOtherFigure = 1550,
        BecomeOtherFigure2 = 1584,
        BecomeOtherFigure2Reset = true,
        VehicleDestroyed = 1554
      }
    },
    [UEnums.HeroID.AttackOnTitan] = {
      ConsiderVehicleFeature = {
        "VehicleTransformFeature"
      },
      TransformDuration = 90,
      NearExpirationLowerPercent = 0.2,
      SkillCDIndex = 2,
      SkillID = 3800006,
      DisablePet = true,
      bNotClearSaveBackpack = true,
      bExitHeroNotResetCharacterAttr = true,
      FinishedStateBack = true,
      bTransformToVehicle = true,
      TryAddOneSkillNotDelete = 3800006,
      ExitSkillID = 3800003,
      DefaultExitDelayDestroyTime = 1,
      ExitAnimTime = 2.5,
      TransformToVehicleParams = {
        bCacheVehicle = true,
        SoftActorTemplate = "/Game/Library/Res/Vehicles/Giant/Arts_PlayerBlueprints/BP_SpecialGiant.BP_SpecialGiant",
        SelectedKeyName = "TargetVehicleLocation",
        bSetCharacterHide = false,
        bHideStopTick = false
      },
      ExitAddBuffID = 600409,
      bDisableUseConsumables = true,
      bDetachPassengersWhenStartBack = true,
      PassengersLimitSkillIDs = {
        1001001,
        1001003,
        1001004,
        1001005,
        1001007,
        1001008,
        1001009,
        1001012,
        1001013,
        1001014,
        1001015,
        1001016,
        3800023,
        3800024,
        3800025,
        3800026
      },
      TlogInfo = {
        UseItem = 1549,
        BecomeOtherFigure = 1550,
        BecomeOtherFigure2 = 1584,
        BecomeOtherFigure2Reset = true,
        VehicleDestroyed = 1554
      }
    },
    [UEnums.HeroID.GhostHero] = {
      ConsiderFeature = {
        "GhostFeature"
      },
      TransformDuration = 75,
      MeshOffsetZ = 100,
      SkillCDIndex = 2,
      ItemID = 1500022,
      ChangeItemID = 604120,
      CapsuleHalfHeight = 88,
      CapsuleRadius = 55,
      SpringArmLength = 350,
      bChangeAnimMontage = true,
      bChangeBackAnimMontage = true,
      SkillID = 4000005,
      ExitSkillID = 4000006,
      ChangeSlotID = EAvatarSlotType.EAvatarSlotType_HeadEquipemtSlot,
      DisablePet = true,
      TransformPawnState = EPawnState.ShapeShifting,
      OnlySkillCall = true,
      CannInWater = true,
      CannInSpecialWater = false,
      AvatarCaptureAnimPath = "/Game/Library/Res/Hero/Werewolf/BluePrints/PlayerInfo/AvatarOBInfo_AvatarAnim.AvatarOBInfo_AvatarAnim",
      IgnoreSkillID = {
        [4000005] = true,
        [4000006] = true
      },
      IgnoreBuffIDs = {},
      TlogInfo = {}
    },
    [UEnums.HeroID.FlowerWing] = {
      ConsiderFeature = {
        "FlowerWingFeature"
      },
      TransformDuration = 0,
      SkillID = 4201001,
      SkillCDIndex = 2,
      TransformPawnState = EPawnState.FlowerWing,
      ExitWhenStateInterrupt = true,
      bNotClearSaveBackpack = true,
      DisablePet = true,
      SpringArmLength = 400,
      SocketOffset = FVector(0, 0, 20),
      TargetOffset = FVector(0, 0, 0),
      CannInWater = true,
      FinishedStateBack = true,
      EnableInteractDoor = true,
      CapsuleHalfHeight = 100,
      CapsuleRadius = 30,
      bNeedUnableDoAutoSprintOperation = false,
      ActiveSkills = {4201003, 4201005}
    }
  }
}
function CommonFightTransformConfig:CheckFightTransform(CheckHeroID)
  if not CheckHeroID then
    return false
  end
  if self.CommonransformConfig[CheckHeroID] then
    return true
  end
  return false
end
function CommonFightTransformConfig:GetChangeHeroIDByChangeItemID(ChangeItemID)
  for k, v in pairs(self.CommonransformConfig) do
    if v.ChangeItemID == ChangeItemID then
      return k, v
    end
  end
end
function CommonFightTransformConfig:GetHalloween4CanChangeHeroId()
  return {
    UEnums.HeroID.Liquid,
    UEnums.HeroID.Werewolf,
    UEnums.HeroID.Vampire,
    UEnums.HeroID.SnowBall,
    UEnums.HeroID.GhostHero
  }
end
function CommonFightTransformConfig:CheckTransformAvartLoad(ItemId, SlotID)
  for k, v in pairs(self.CommonransformConfig) do
    if v.ItemID == ItemId and v.ChangeSlotID == SlotID then
      return true
    end
  end
  return false
end
return CommonFightTransformConfig