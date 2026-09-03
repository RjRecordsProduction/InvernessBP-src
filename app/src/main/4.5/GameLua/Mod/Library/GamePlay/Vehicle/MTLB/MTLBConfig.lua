local ConfigUtils = require("GameLua.GameCore.Module.Vehicle.Config.ConfigUtils")
local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
local EPhysicalSurface = import("EPhysicalSurface")
local VehicleConfig = {
  VehicleFeatures = {
    TLog = {
      "GameLua.GameCore.Module.Vehicle.VehicleFeatures.TLog.VehicleTLogFeature",
      ConfigUtils.ENetSide.Server,
      {TLogID_Enter = 2080}
    },
    AudiosFeature = {
      "GameLua.Mod.Library.Gameplay.Vehicle.VehicleFeatures.VehicleAudiosFeature",
      ConfigUtils.ENetSide.Client,
      {
        UpdateInterval = 0.1,
        AudioSetups = {
          [ConfigUtils.EAudioType.Audio_TrackSlip] = {
            ClassPath = "GameLua.Mod.Library.GamePlay.Vehicle.TrackedVehicle.TrackSlipAudio",
            Attributes = {
              AudioPath = "/Game/Library/Res/Vehicles/MTLB/WwiseEvent/Vehicle_MTLB/Play_Vehicle_MTLB_Brake.Play_Vehicle_MTLB_Brake",
              StopAudioPath = "/Game/Library/Res/Vehicles/MTLB/WwiseEvent/Vehicle_MTLB/Stop_Vehicle_MTLB_Brake.Stop_Vehicle_MTLB_Brake",
              bShouldActivate = true,
              MinSpeed = 1
            }
          },
          [ConfigUtils.EAudioType.Audio_WaterSplash] = {
            ClassPath = "GameLua.Mod.Library.GamePlay.Vehicle.VehicleAudios.SimVehicleWaterSplashAudio",
            Attributes = {
              AudioPath = "/Game/Library/Res/Vehicles/MTLB/WwiseEvent/Vehicle_MTLB/Play_Vehicle_MTLB_RunWaterLoop_Team.Play_Vehicle_MTLB_RunWaterLoop_Team",
              bShouldActivate = true,
              MinSpeed = 1
            }
          }
        }
      }
    },
    EffectsFeature = {
      "GameLua.Mod.Library.Gameplay.Vehicle.VehicleFeatures.VehicleEffectsFeature",
      ConfigUtils.ENetSide.Client,
      {
        UpdateInterval = 0.1,
        EffectSetups = {
          [ConfigUtils.EEffectType.Effect_Dust] = {
            ClassPath = "GameLua.Mod.Library.GamePlay.Vehicle.TrackedVehicle.TrackDustEffect",
            Attributes = {
              EffectMap = {
                [EPhysicalSurface.SurfaceType_Default] = "/Game/Library/Res/Vehicles/MTLB/Arts_Effect/Par/P_Sceneltem_int_1929_S_Track_Smoke_01_L2.P_Sceneltem_int_1929_S_Track_Smoke_01_L2",
                [EPhysicalSurface.SurfaceType1] = "/Game/Library/Res/Vehicles/MTLB/Arts_Effect/Par/P_Sceneltem_int_1929_S_Track_Smoke_01_L2.P_Sceneltem_int_1929_S_Track_Smoke_01_L2",
                [EPhysicalSurface.SurfaceType2] = "/Game/Library/Res/Vehicles/MTLB/Arts_Effect/Par/P_Sceneltem_int_1929_S_Track_Smoke_02_L2.P_Sceneltem_int_1929_S_Track_Smoke_02_L2",
                [EPhysicalSurface.SurfaceType11] = "/Game/Library/Res/Vehicles/MTLB/Arts_Effect/Par/P_Sceneltem_int_1929_S_Track_Smoke_02_L2.P_Sceneltem_int_1929_S_Track_Smoke_02_L2",
                [EPhysicalSurface.SurfaceType6] = "/Game/Library/Res/Vehicles/MTLB/Arts_Effect/Par/P_Sceneltem_int_1929_S_Track_Smoke_02_L2.P_Sceneltem_int_1929_S_Track_Smoke_02_L2",
                [EPhysicalSurface.SurfaceType18] = "/Game/Library/Res/Vehicles/MTLB/Arts_Effect/Par/P_Sceneltem_int_1929_S_Track_Smoke_03_L2.P_Sceneltem_int_1929_S_Track_Smoke_03_L2",
                [EPhysicalSurface.SurfaceType25] = "/Game/Library/Res/Vehicles/MTLB/Arts_Effect/Par/P_Sceneltem_int_1929_S_Track_Smoke_03_L2.P_Sceneltem_int_1929_S_Track_Smoke_03_L2"
              },
              ForwardSocketNames = {"L_Track05", "R_Track05"},
              BackwardSocketNames = {"L_Track01", "R_Track01"},
              bShouldActivate = true,
              MinSpeed = 2
            }
          }
        }
      }
    }
  },
  Components = {
    VehicleBackpackComponent = {
      "/Game/Mod/EvoBase/Arts_PlayerBluePrints/Vehicle/Components/BP_VehicleBackpackComponent.BP_VehicleBackpackComponent_C",
      ConfigUtils.ENetSide.Server,
      true,
      ConfigUtils.MergeTable,
      {Capacity = 900}
    }
  }
}
return VehicleConfig