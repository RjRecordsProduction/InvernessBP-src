local NeonConfig = {
  ElectromagneticPulseConfig = {
    ElectromagneticInfo = {
      [1] = {
        DelayTipTime = 315,
        DelayCreateTime = 355,
        DelayDestoryTime = 400,
        MaxDistance = 300000,
        ElectromagneticMinDistance = 200000,
        ElectromagneticNum = 2,
        ElectromagneticNumPer = {
          [1] = 50,
          [2] = 50
        }
      },
      [2] = {
        DelayTipTime = 415,
        DelayCreateTime = 455,
        DelayDestoryTime = 500,
        MaxDistance = 300000,
        ElectromagneticNum = 2,
        ElectromagneticMinDistance = 200000,
        ElectromagneticNumPer = {
          [1] = 50,
          [2] = 50
        }
      },
      [3] = {
        DelayTipTime = 515,
        DelayCreateTime = 555,
        DelayDestoryTime = 600,
        MaxDistance = 200000,
        ElectromagneticNum = 2,
        ElectromagneticMinDistance = 200000,
        ElectromagneticNumPer = {
          [1] = 50,
          [2] = 50
        }
      },
      [4] = {
        DelayTipTime = 615,
        DelayCreateTime = 655,
        DelayDestoryTime = 700,
        MaxDistance = 200000,
        ElectromagneticNum = 2,
        ElectromagneticMinDistance = 200000,
        ElectromagneticNumPer = {
          [1] = 100,
          [2] = 0
        }
      }
    },
    SpecialModeID = {
      [90025] = true,
      [90026] = true,
      [90027] = true,
      [90028] = true
    },
    SpecialElectromagneticInfo = {
      [1] = {
        DelayTipTime = 225,
        DelayCreateTime = 265,
        DelayDestoryTime = 310,
        MaxDistance = 300000,
        ElectromagneticMinDistance = 200000,
        ElectromagneticNum = 2,
        ElectromagneticNumPer = {
          [1] = 50,
          [2] = 50
        }
      },
      [2] = {
        DelayTipTime = 325,
        DelayCreateTime = 365,
        DelayDestoryTime = 410,
        MaxDistance = 300000,
        ElectromagneticNum = 2,
        ElectromagneticMinDistance = 200000,
        ElectromagneticNumPer = {
          [1] = 50,
          [2] = 50
        }
      },
      [3] = {
        DelayTipTime = 425,
        DelayCreateTime = 465,
        DelayDestoryTime = 510,
        MaxDistance = 200000,
        ElectromagneticNum = 2,
        ElectromagneticMinDistance = 200000,
        ElectromagneticNumPer = {
          [1] = 50,
          [2] = 50
        }
      },
      [4] = {
        DelayTipTime = 525,
        DelayCreateTime = 565,
        DelayDestoryTime = 610,
        MaxDistance = 200000,
        ElectromagneticNum = 2,
        ElectromagneticMinDistance = 200000,
        ElectromagneticNumPer = {
          [1] = 100,
          [2] = 0
        }
      }
    },
    WarningTipsID = 112038,
    CreateTipsID = 112039,
    FinishTipsID = 112040,
    ProtectElectromagneticPath = "/Game/Mod/Neon/BluePrints/Actor/ProtectElectromagneticActor.ProtectElectromagneticActor",
    ExplosionEffectPath = "/Game/Mod/Neon/Actor_Timeliness/CG030/CG030_EMPZone/Arts_Effect/Particle/P_030_EMP_Explode.P_030_EMP_Explode",
    ElectromagneticCanntUseTipsID = 112041,
    ExplosionAudioPath = "/Game/Mod/Neon/WwiseEvent/CG030_Neon_EMPZone/Play_CG030_Neon_EMPZone_Explosion.Play_CG030_Neon_EMPZone_Explosion",
    ElectromagneticLoopAudioPath = "/Game/Mod/Neon/WwiseEvent/CG030_Neon_EMPZone/Play_CG030_Neon_EMPZone_Loop.Play_CG030_Neon_EMPZone_Loop",
    ElectromagneticStopLoopAudioPath = "/Game/Mod/Neon/WwiseEvent/CG030_Neon_EMPZone/Stop_CG030_Neon_EMPZone_Loop.Stop_CG030_Neon_EMPZone_Loop",
    EnterExplosionAudioPath = "/Game/Mod/Neon/WwiseEvent/CG030_Neon_EMPZone/Play_UI_CG030_Neon_EMPZone_In.Play_UI_CG030_Neon_EMPZone_In",
    OutExplosionAudioPath = "/Game/Mod/Neon/WwiseEvent/CG030_Neon_EMPZone/Play_UI_CG030_Neon_EMPZone_Out.Play_UI_CG030_Neon_EMPZone_Out",
    SafeCreateCenter = FVector(402908, 375000, 254500),
    SafeCreateRadius = 100000,
    ExplosionEffectHight = 30000
  },
  AirDropShelterConfig = {
    DelayTime = 2,
    SpawnHeight = 3000,
    Radius = 1000
  },
  ShockedSensitivityRate = 0.1,
  PickAxeDiggingConfig = {
    PickAxeDiggingDist = 400,
    PickAxeDiggingRadius = 200,
    PickAxeDiggingPathSuccess = "/Game/Library/Res/Weapons/PickAxe/Arts_Effect/Par/P_Pickaxe_02.P_Pickaxe_02",
    PickAxeDiggingPathFailed = "/Game/Library/Res/Weapons/PickAxe/Arts_Effect/Par/P_Pickaxe_01.P_Pickaxe_01"
  },
  FishingStateType = {
    None = 0,
    ReadyToFish = 1,
    StartFish = 2,
    PullFish = 3,
    FishSuccess = 4,
    FishFail = 5,
    FishQET = 6
  },
  FishingSkillID = 1014704,
  ReadyToStartFishTime = 1,
  WaitToPullTimeMin = 10,
  WaitToPullTimeMax = 20,
  BeforPullShowTipTime = 1,
  PullFishToSuccessTime = 10,
  FishSuccessToNone = 5,
  FishFailToNone = 2,
  FishingShowLineTime = 1.5,
  FishingShowStartFishWaterEffectTime = 2,
  FishingSuccessShowWaterEffectTime = 1.5,
  FishingUIRadian = 70,
  FishingUISmallRadian = 12.5,
  FishingUIRadius = 115,
  FishingUIArrowRadius = 145,
  FishingUIArrowSpeed = 20,
  FishingSuccessTip = 12184,
  FishingFailTip = 12185,
  FishingWaterTip = 112041,
  FishingFishInRodTip = 12186,
  FishingSuccessGift = {
    [1] = {
      ItemID = 203001,
      Num = 1,
      Per = 13
    },
    [2] = {
      ItemID = 203015,
      Num = 1,
      Per = 8
    },
    [3] = {
      ItemID = 3000324,
      Num = 15,
      Per = 8
    },
    [4] = {
      ItemID = 601001,
      Num = 1,
      Per = 12
    },
    [5] = {
      ItemID = 601004,
      Num = 5,
      Per = 14
    },
    [6] = {
      ItemID = 601005,
      Num = 1,
      Per = 10
    },
    [7] = {
      ItemID = 106007,
      Num = 1,
      Per = 1
    },
    [8] = {
      ItemID = 502002,
      Num = 1,
      Per = 12
    },
    [9] = {
      ItemID = 502003,
      Num = 1,
      Per = 5
    },
    [10] = {
      ItemID = 503002,
      Num = 1,
      Per = 12
    },
    [11] = {
      ItemID = 503003,
      Num = 1,
      Per = 5
    }
  },
  TeleportConfigID = 1040001,
  FishingWaitWaterEffectPath = "/Game/Mod/Neon/Arts_Effect/Gofishing/Par/P_FishWater_Spray_03.P_FishWater_Spray_03",
  FishingPullWaterEffectPath = "/Game/Mod/Neon/Arts_Effect/Gofishing/Par/P_FishWater_Spray_04.P_FishWater_Spray_04",
  FishingPullOutWaterEffectPath = "/Game/Mod/Neon/Arts_Effect/Gofishing/Par/P_FishWater_Spray_01.P_FishWater_Spray_01",
  FishingStartFishWaterEffectPath = "/Game/Mod/Neon/Arts_Effect/Gofishing/Par/P_FishWater_Spray_02.P_FishWater_Spray_02"
}
return NeonConfig