local HighlightMomentConfig = {}
local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
HighlightMomentConfig.CommonCheckConfig = {
  HorizontalCheckAngle = 10,
  BoxConfig = {
    {
      Offset = FVector(0, 0, 150),
      RotateZ = 0,
      Extent = FVector(300, 180, 70)
    },
    {
      Offset = FVector(310, -58, 150),
      RotateZ = 0,
      Extent = FVector(175, 250, 140)
    },
    {
      Offset = FVector(-239, 85, 100),
      RotateZ = -33,
      Extent = FVector(100, 200, 20)
    },
    {
      Offset = FVector(337, 94, 160),
      RotateZ = -45,
      Extent = FVector(438, 150, 55)
    }
  },
  FloorCheckPoint = {
    {
      StartPoint = FVector(0, 0, 100),
      EndPoint = FVector(0, 0, -50)
    },
    {
      StartPoint = FVector(139, -135, 100),
      EndPoint = FVector(139, -135, -50)
    },
    {
      StartPoint = FVector(288, -9, 100),
      EndPoint = FVector(288, -9, -50)
    },
    {
      StartPoint = FVector(224, -248, 100),
      EndPoint = FVector(224, -248, -50)
    },
    {
      StartPoint = FVector(321, -182, 100),
      EndPoint = FVector(321, -182, -50)
    },
    {
      StartPoint = FVector(431, -140, 100),
      EndPoint = FVector(431, -140, -50)
    },
    {
      StartPoint = FVector(311, 114, 100),
      EndPoint = FVector(311, 114, -50)
    }
  }
}
HighlightMomentConfig.VehicleCheckConfig = {
  [1] = {
    HorizontalCheckAngle = 10,
    BoxConfig = {
      {
        Offset = FVector(227, -352, 150),
        RotateZ = 0,
        Extent = FVector(500, 500, 70)
      }
    },
    FloorCheckPoint = {
      {
        StartPoint = FVector(0, 0, 100),
        EndPoint = FVector(0, 0, -50)
      },
      {
        StartPoint = FVector(139, -135, 100),
        EndPoint = FVector(139, -135, -50)
      },
      {
        StartPoint = FVector(288, -9, 100),
        EndPoint = FVector(288, -9, -50)
      },
      {
        StartPoint = FVector(79, -203, 100),
        EndPoint = FVector(79, -203, -50)
      },
      {
        StartPoint = FVector(240, -151, 100),
        EndPoint = FVector(240, -151, -50)
      },
      {
        StartPoint = FVector(209, -21, 100),
        EndPoint = FVector(209, -21, -50)
      },
      {
        StartPoint = FVector(275, 70, 100),
        EndPoint = FVector(275, 70, -50)
      }
    }
  },
  [2] = {
    HorizontalCheckAngle = 10,
    BoxConfig = {
      {
        Offset = FVector(227, -352, 150),
        RotateZ = 0,
        Extent = FVector(560, 560, 70)
      }
    },
    FloorCheckPoint = {
      {
        StartPoint = FVector(0, 0, 100),
        EndPoint = FVector(0, 0, -50)
      },
      {
        StartPoint = FVector(139, -135, 100),
        EndPoint = FVector(139, -135, -50)
      },
      {
        StartPoint = FVector(288, -9, 100),
        EndPoint = FVector(288, -9, -50)
      },
      {
        StartPoint = FVector(79, -203, 100),
        EndPoint = FVector(79, -203, -50)
      },
      {
        StartPoint = FVector(240, -151, 100),
        EndPoint = FVector(240, -151, -50)
      },
      {
        StartPoint = FVector(209, -21, 100),
        EndPoint = FVector(209, -21, -50)
      },
      {
        StartPoint = FVector(275, 70, 100),
        EndPoint = FVector(275, 70, -50)
      }
    }
  },
  [3] = {
    HorizontalCheckAngle = 10,
    BoxConfig = {
      {
        Offset = FVector(0, 0, 150),
        RotateZ = 0,
        Extent = FVector(300, 180, 70)
      },
      {
        Offset = FVector(409, -134, 150),
        RotateZ = 0,
        Extent = FVector(150, 200, 100)
      },
      {
        Offset = FVector(-514, 174, 100),
        RotateZ = -33,
        Extent = FVector(100, 300, 20)
      },
      {
        Offset = FVector(445, 145, 120),
        RotateZ = -50,
        Extent = FVector(465, 150, 7)
      }
    },
    FloorCheckPoint = {
      {
        StartPoint = FVector(0, 0, 100),
        EndPoint = FVector(0, 0, -50)
      },
      {
        StartPoint = FVector(139, -135, 100),
        EndPoint = FVector(139, -135, -50)
      },
      {
        StartPoint = FVector(288, -9, 100),
        EndPoint = FVector(288, -9, -50)
      },
      {
        StartPoint = FVector(289, -248, 100),
        EndPoint = FVector(289, -248, -50)
      },
      {
        StartPoint = FVector(420, -174, 100),
        EndPoint = FVector(420, -174, -50)
      },
      {
        StartPoint = FVector(536, -151, 100),
        EndPoint = FVector(536, -151, -50)
      },
      {
        StartPoint = FVector(468, 26, 100),
        EndPoint = FVector(468, 26, -50)
      }
    }
  },
  [4] = {
    HorizontalCheckAngle = 10,
    BoxConfig = {
      {
        Offset = FVector(0, 0, 150),
        RotateZ = 0,
        Extent = FVector(300, 180, 70)
      },
      {
        Offset = FVector(409, -134, 150),
        RotateZ = 0,
        Extent = FVector(150, 200, 100)
      },
      {
        Offset = FVector(-514, 174, 100),
        RotateZ = -33,
        Extent = FVector(100, 300, 20)
      },
      {
        Offset = FVector(445, 145, 120),
        RotateZ = -50,
        Extent = FVector(465, 150, 7)
      }
    },
    FloorCheckPoint = {
      {
        StartPoint = FVector(0, 0, 100),
        EndPoint = FVector(0, 0, -50)
      },
      {
        StartPoint = FVector(139, -135, 100),
        EndPoint = FVector(139, -135, -50)
      },
      {
        StartPoint = FVector(288, -9, 100),
        EndPoint = FVector(288, -9, -50)
      },
      {
        StartPoint = FVector(289, -248, 100),
        EndPoint = FVector(289, -248, -50)
      },
      {
        StartPoint = FVector(420, -174, 100),
        EndPoint = FVector(420, -174, -50)
      },
      {
        StartPoint = FVector(536, -151, 100),
        EndPoint = FVector(536, -151, -50)
      },
      {
        StartPoint = FVector(468, 26, 100),
        EndPoint = FVector(468, 26, -50)
      }
    }
  }
}
HighlightMomentConfig.VehicleSpecialSkinConfig = {
  [1903213] = {
    LevelSeq = "/Game/Res/IG3900/Arts_Player/Vehicle/Levelsequence/Bee/SEQ_VehicleLight_BEE.SEQ_VehicleLight_BEE",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    Type = "Bee"
  },
  [1903212] = {
    LevelSeq = "/Game/Res/IG3900/Arts_Player/Vehicle/Levelsequence/Bee/SEQ_VehicleLight_BEE_2.SEQ_VehicleLight_BEE_2",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    Type = "Bee"
  },
  [1915017] = {
    LevelSeq = "/Game/Res/IG3900/Arts_Player/Vehicle/Levelsequence/MP/SEQ_VehicleLight_MP.SEQ_VehicleLight_MP",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    Type = "MP"
  },
  [1915018] = {
    LevelSeq = "/Game/Res/IG3900/Arts_Player/Vehicle/Levelsequence/MP/SEQ_VehicleLight_MP_2.SEQ_VehicleLight_MP_2",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    Type = "MP"
  },
  [1953012] = {
    LevelSeq = "/Game/Res/IG3900/Arts_Player/Vehicle/Levelsequence/OP/SEQ_VehicleLight_OP.SEQ_VehicleLight_OP",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[2],
    Type = "OP"
  },
  [1953011] = {
    LevelSeq = "/Game/Res/IG3900/Arts_Player/Vehicle/Levelsequence/OP/SEQ_VehicleLight_OP_2.SEQ_VehicleLight_OP_2",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[2],
    Type = "OP"
  },
  [1953010] = {
    LevelSeq = "/Game/Res/IG3900/Arts_Player/Vehicle/Levelsequence/OP/SEQ_VehicleLight_OP_3.SEQ_VehicleLight_OP_3",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[2],
    Type = "OP"
  },
  [19102001] = {
    LevelSeq = "/Game/Arts_Player/Characters/Animation/Shared_Anim/Hightlight/Vehicle/SEQ_VehicleLight_Universal_OP.SEQ_VehicleLight_Universal_OP",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[3],
    ActorPath = "/Game/Library/Res/Vehicles/TFMecha/BluePrints/Highlight_Vehicle_OP.Highlight_Vehicle_OP"
  },
  [19103001] = {
    LevelSeq = "/Game/Arts_Player/Characters/Animation/Shared_Anim/Hightlight/Vehicle/SEQ_VehicleLight_Universal_OP.SEQ_VehicleLight_Universal_OP",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[3],
    ActorPath = "/Game/Library/Res/Vehicles/TFMecha/BluePrints/Highlight_Vehicle_OP.Highlight_Vehicle_OP"
  },
  [19104001] = {
    LevelSeq = "/Game/Arts_Player/Characters/Animation/Shared_Anim/Hightlight/Vehicle/SEQ_VehicleLight_Universal_MT.SEQ_VehicleLight_Universal_MT",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[4],
    ActorPath = "/Game/Library/Res/Vehicles/TFMecha/BluePrints/Highlight_Vehicle_MT.Highlight_Vehicle_MT"
  },
  [19105001] = {
    LevelSeq = "/Game/Arts_Player/Characters/Animation/Shared_Anim/Hightlight/Vehicle/SEQ_VehicleLight_Universal_MT.SEQ_VehicleLight_Universal_MT",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[4],
    ActorPath = "/Game/Library/Res/Vehicles/TFMecha/BluePrints/Highlight_Vehicle_MT.Highlight_Vehicle_MT"
  },
  [1903218] = {
    LevelSeq = "/Game/Res/IG4100/Arts_Player/Vehicle/LevelSequence/SportsCar25_int_06/SEQ_VehicleLight_SportsCar25_06.SEQ_VehicleLight_SportsCar25_06",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/SportsCarFeatures/Flaunt_CarHightLight_F_UIBP.Flaunt_CarHightLight_F_UIBP"
  },
  [1903219] = {
    LevelSeq = "/Game/Res/IG4100/Arts_Player/Vehicle/LevelSequence/SportsCar25_int_06/SEQ_VehicleLight_SportsCar25_06_2.SEQ_VehicleLight_SportsCar25_06_2",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/SportsCarFeatures/Flaunt_CarHightLight_E_UIBP.Flaunt_CarHightLight_E_UIBP"
  },
  [1908108] = {
    LevelSeq = "/Game/Res/IG4100/Arts_Player/Vehicle/LevelSequence/SportsCar25_int_07/SEQ_VehicleLight_SportsCar25_07.SEQ_VehicleLight_SportsCar25_07",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/SportsCarFeatures/Flaunt_CarHightLight_C_UIBP.Flaunt_CarHightLight_C_UIBP"
  },
  [1908109] = {
    LevelSeq = "/Game/Res/IG4100/Arts_Player/Vehicle/LevelSequence/SportsCar25_int_07/SEQ_VehicleLight_SportsCar25_07_2.SEQ_VehicleLight_SportsCar25_07_2",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/SportsCarFeatures/Flaunt_CarHightLight_D_UIBP.Flaunt_CarHightLight_D_UIBP"
  },
  [1915021] = {
    LevelSeq = "/Game/Res/IG4100/Arts_Player/Vehicle/LevelSequence/SportsCar25_int_08/SEQ_VehicleLight_SportsCar25_08.SEQ_VehicleLight_SportsCar25_08",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/SportsCarFeatures/Flaunt_CarHightLight_B_UIBP.Flaunt_CarHightLight_B_UIBP"
  },
  [1915022] = {
    LevelSeq = "/Game/Res/IG4100/Arts_Player/Vehicle/LevelSequence/SportsCar25_int_08/SEQ_VehicleLight_SportsCar25_08_2.SEQ_VehicleLight_SportsCar25_08_2",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/SportsCarFeatures/Flaunt_CarHightLight_A_UIBP.Flaunt_CarHightLight_A_UIBP"
  },
  [1961064] = {
    LevelSeq = "/Game/Res/IG4100/Arts_Player/Vehicle/LevelSequence/SportsCar25_int_09/SEQ_VehicleLight_SportsCar25_09.SEQ_VehicleLight_SportsCar25_09",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/SportsCarFeatures/Flaunt_CarHightLight_H_UIBP.Flaunt_CarHightLight_H_UIBP"
  },
  [1961062] = {
    LevelSeq = "/Game/Res/IG4100/Arts_Player/Vehicle/LevelSequence/SportsCar25_int_09/SEQ_VehicleLight_SportsCar25_09_2.SEQ_VehicleLight_SportsCar25_09_2",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/SportsCarFeatures/Flaunt_CarHightLight_G_UIBP.Flaunt_CarHightLight_G_UIBP"
  },
  [1961063] = {
    LevelSeq = "/Game/Res/IG4100/Arts_Player/Vehicle/LevelSequence/SportsCar25_int_09/SEQ_VehicleLight_SportsCar25_09_3.SEQ_VehicleLight_SportsCar25_09_3",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/SportsCarFeatures/Flaunt_CarHightLight_I_UIBP.Flaunt_CarHightLight_I_UIBP"
  },
  [1903220] = {
    LevelSeq = "/Game/Res/IG4300/Arts_Player/Vehicle/LevelSequence/SportsCar26_int_02/SEQ_SportsCar26_int_02_4.SEQ_SportsCar26_int_02_4",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/430/Flaunt_CarHightLight_UIBP.Flaunt_CarHightLight_UIBP"
  },
  [1903221] = {
    LevelSeq = "/Game/Res/IG4300/Arts_Player/Vehicle/LevelSequence/SportsCar26_int_02/SEQ_SportsCar26_int_02_3.SEQ_SportsCar26_int_02_3",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/430/Flaunt_CarHightLight_01_UIBP.Flaunt_CarHightLight_01_UIBP"
  },
  [1903222] = {
    LevelSeq = "/Game/Res/IG4300/Arts_Player/Vehicle/LevelSequence/SportsCar26_int_02/SEQ_SportsCar26_int_02_2.SEQ_SportsCar26_int_02_2",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/430/Flaunt_CarHightLight_02_UIBP.Flaunt_CarHightLight_02_UIBP"
  },
  [1903223] = {
    LevelSeq = "/Game/Res/IG4300/Arts_Player/Vehicle/LevelSequence/SportsCar26_int_02/SEQ_SportsCar26_int_02_1.SEQ_SportsCar26_int_02_1",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/430/Flaunt_CarHightLight_03_UIBP.Flaunt_CarHightLight_03_UIBP"
  },
  [1961065] = {
    LevelSeq = "/Game/Res/IG4300/Arts_Player/Vehicle/LevelSequence/SportsCar26_int_03/SEQ_SportsCar26_int_03_3.SEQ_SportsCar26_int_03_3",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/430/Flaunt_CarHightLight_04_UIBP.Flaunt_CarHightLight_04_UIBP"
  },
  [1961066] = {
    LevelSeq = "/Game/Res/IG4300/Arts_Player/Vehicle/LevelSequence/SportsCar26_int_03/SEQ_SportsCar26_int_03_2.SEQ_SportsCar26_int_03_2",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/430/Flaunt_CarHightLight_05_UIBP.Flaunt_CarHightLight_05_UIBP"
  },
  [1961067] = {
    LevelSeq = "/Game/Res/IG4300/Arts_Player/Vehicle/LevelSequence/SportsCar26_int_03/SEQ_SportsCar26_int_03_1.SEQ_SportsCar26_int_03_1",
    CheckConfig = HighlightMomentConfig.VehicleCheckConfig[1],
    UIPath = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/430/Flaunt_CarHightLight_06_UIBP.Flaunt_CarHightLight_06_UIBP"
  }
}
HighlightMomentConfig.VehicleReplaceMap = {
  [19102001] = 19103001,
  [19104001] = 19105001
}
HighlightMomentConfig.ValidVehicleShapeList = {
  ESTExtraVehicleShapeType.VST_Motorbike,
  ESTExtraVehicleShapeType.VST_Motorbike_SideCart,
  ESTExtraVehicleShapeType.VST_Dacia,
  ESTExtraVehicleShapeType.VST_MiniBus,
  ESTExtraVehicleShapeType.VST_PickUp,
  ESTExtraVehicleShapeType.VST_PickUp_1,
  ESTExtraVehicleShapeType.VST_Buggy_0,
  ESTExtraVehicleShapeType.VST_UAZ_0,
  ESTExtraVehicleShapeType.VST_UAZ_1,
  ESTExtraVehicleShapeType.VST_UAZ_2,
  ESTExtraVehicleShapeType.VST_UAZ_3,
  ESTExtraVehicleShapeType.VST_Mirado,
  ESTExtraVehicleShapeType.VST_Mirado_1,
  ESTExtraVehicleShapeType.VST_Rony,
  ESTExtraVehicleShapeType.VST_Scooter,
  ESTExtraVehicleShapeType.VST_TukTukTuk,
  ESTExtraVehicleShapeType.VST_SnowBike,
  ESTExtraVehicleShapeType.VST_Amphibious,
  ESTExtraVehicleShapeType.VST_LadaNiva,
  ESTExtraVehicleShapeType.VST_LootTruck,
  ESTExtraVehicleShapeType.VST_ATGMotorCycle,
  ESTExtraVehicleShapeType.VST_ModelY,
  ESTExtraVehicleShapeType.VST_ATV,
  ESTExtraVehicleShapeType.VST_UAZ_PS,
  ESTExtraVehicleShapeType.VST_Lamborghini,
  ESTExtraVehicleShapeType.VST_Lamborghini_1,
  ESTExtraVehicleShapeType.VST_GoldMirado,
  ESTExtraVehicleShapeType.VST_BigFoot,
  ESTExtraVehicleShapeType.VST_HeavyDacia,
  ESTExtraVehicleShapeType.VST_HeavyPickup,
  ESTExtraVehicleShapeType.VST_HeavyBuggy,
  ESTExtraVehicleShapeType.VST_HeavyUAZ,
  ESTExtraVehicleShapeType.VST_HeavyUH60,
  ESTExtraVehicleShapeType.VST_CoupeRB,
  ESTExtraVehicleShapeType.VST_MediumTank,
  ESTExtraVehicleShapeType.VST_Bike,
  ESTExtraVehicleShapeType.VST_UTV,
  ESTExtraVehicleShapeType.VST_Bike_WithRack,
  ESTExtraVehicleShapeType.VST_LightTank,
  ESTExtraVehicleShapeType.VST_HeavyTank,
  ESTExtraVehicleShapeType.VST_StoreBus,
  ESTExtraVehicleShapeType.VST_PicoBus,
  ESTExtraVehicleShapeType.VST_Blanc,
  ESTExtraVehicleShapeType.VST_OptimusVehicle,
  ESTExtraVehicleShapeType.VST_MegatronVehicle,
  ESTExtraVehicleShapeType.VST_AmphibiousBoat,
  ESTExtraVehicleShapeType.VST_Optimus,
  ESTExtraVehicleShapeType.VST_OptimusVehicle,
  ESTExtraVehicleShapeType.VST_Megatron,
  ESTExtraVehicleShapeType.VST_MegatronVehicle
}
return HighlightMomentConfig