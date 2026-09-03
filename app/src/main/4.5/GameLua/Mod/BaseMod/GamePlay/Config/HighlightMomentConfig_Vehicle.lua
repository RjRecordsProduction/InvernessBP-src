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
  ESTExtraVehicleShapeType.VST_MegatronVehicle,
  ESTExtraVehicleShapeType.VST_CustomVehicle1
}
local skinTable = CDataTable.GetTable("VehicleHLSkinConfig")
if skinTable then
  local VehicleSpecialSkinConfig = {}
  for _, row in pairs(skinTable) do
    local entry = {
      LevelSeq = row.LevelSeq,
      CheckConfig = HighlightMomentConfig.VehicleCheckConfig[row.CheckConfigId]
    }
    if row.Type and row.Type ~= "" then
      entry.Type = row.Type
    end
    if row.UIPath and row.UIPath ~= "" then
      entry.UIPath = row.UIPath
    end
    if row.ActorPath and row.ActorPath ~= "" then
      entry.ActorPath = row.ActorPath
    end
    if row.PossessLobbyVehicle then
      entry.PossessLobbyVehicle = true
    end
    VehicleSpecialSkinConfig[row.SkinItemID] = entry
  end
  HighlightMomentConfig.end
return HighlightMomentConfig