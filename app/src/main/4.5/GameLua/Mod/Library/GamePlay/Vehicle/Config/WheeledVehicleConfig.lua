local ConfigUtils = require("GameLua.GameCore.Module.Vehicle.Config.ConfigUtils")
local UKismetMathLibrary = import("KismetMathLibrary")
local EPhysicalSurface = import("EPhysicalSurface")
local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
local EEffectType = ConfigUtils.EEffectType
local VehicleConfig = {
  SyncBoostStateTime = 0.2,
  VehicleFeatures = {
    DriftTLog = {
      "GameLua.GameCore.Module.Vehicle.VehicleFeatures.TLog.DriftTLogFeature",
      ConfigUtils.ENetSide.Server,
      {
        TLogID_NumDrifts = 1391,
        TLogID_MaxDriftDuration = 1427,
        TLogID_NumDonutDrifts = 1428,
        TipsID_DonutDriftTips = 12154
      }
    },
    VehicleEffects = {
      "GameLua.Mod.Library.Gameplay.Vehicle.VehicleFeatures.VehicleEffectsFeature",
      ConfigUtils.ENetSide.Client,
      {
        UpdateInterval = 0.1,
        EffectSetups = {
          [ConfigUtils.EEffectType.Effect_Exhuast] = {
            ClassPath = "GameLua.Mod.Library.GamePlay.Vehicle.VehicleEffects.WheeledVehicleBoostEffect",
            Attributes = {}
          }
        }
      }
    },
    HitImpulse = {
      "GameLua.Mod.Library.GamePlay.Vehicle.VehicleFeatures.VehicleHitImpulseFeature",
      ConfigUtils.ENetSide.Server,
      {
        TLogID_HitDamage = 696,
        DamageAttributes = {
          [ESTExtraVehicleShapeType.VST_UAZ_0] = {
            {
              ComponentName = "VehicleDamage",
              Attributes = {ImpactAbsorption = 3150000}
            }
          },
          [ESTExtraVehicleShapeType.VST_UAZ_1] = {
            {
              ComponentName = "VehicleDamage",
              Attributes = {ImpactAbsorption = 3150000}
            }
          },
          [ESTExtraVehicleShapeType.VST_UAZ_2] = {
            {
              ComponentName = "VehicleDamage",
              Attributes = {ImpactAbsorption = 3150000}
            }
          },
          [ESTExtraVehicleShapeType.VST_UAZ_PS] = {
            {
              ComponentName = "VehicleDamage",
              Attributes = {ImpactAbsorption = 3150000}
            }
          },
          [ESTExtraVehicleShapeType.VST_Mirado_1] = {
            {
              ComponentName = "VehicleDamage",
              Attributes = {ImpactAbsorption = 1600000}
            }
          },
          [ESTExtraVehicleShapeType.VST_PickUp] = {
            {
              ComponentName = "VehicleDamage",
              Attributes = {ImpactAbsorption = 3300000}
            }
          },
          [ESTExtraVehicleShapeType.VST_PickUp_1] = {
            {
              ComponentName = "VehicleDamage",
              Attributes = {ImpactAbsorption = 3300000}
            }
          },
          [ESTExtraVehicleShapeType.VST_CoupeRB] = {
            {
              ComponentName = "VehicleDamage",
              Attributes = {ImpactAbsorption = 900000}
            }
          },
          [ESTExtraVehicleShapeType.VST_HeavyPickup] = {
            {
              ComponentName = "VehicleDamage",
              Attributes = {ImpactAbsorption = 3300000}
            }
          }
        }
      }
    },
    SpeedMaterialFeature = {
      "GameLua.GameCore.Module.Vehicle.Features.VehicleSpeedMaterialFeature",
      ConfigUtils.ENetSide.Client,
      {bEnabled = true, UpdateInterval = 0.016}
    }
  },
  ComponentsAttrModify = {
    VehicleSyncComponent = {
      NetSide = ConfigUtils.ENetSide.Both,
      Attrs = {MinCorrectionDistanceSqAtClient = 2500, MinSendingStateChangedIntervalAtClient = 0.016}
    },
    VehicleMovement = {
      NetSide = ConfigUtils.ENetSide.Both,
      Attrs = {bUpdateKinematicBodies = true}
    },
    VehicleSeats = {
      NetSide = ConfigUtils.ENetSide.Client,
      Attrs = {bTryExitAndBrake = true}
    }
  },
  Components = {
    VehicleBackpackComponent = {
      "/Game/Mod/EvoBase/Arts_PlayerBluePrints/Vehicle/Components/BP_VehicleBackpackComponent.BP_VehicleBackpackComponent_C",
      ConfigUtils.ENetSide.Server,
      true,
      ConfigUtils.MergeTable,
      {Capacity = 600}
    },
    VehicleEffectsComponent = {
      "/Game/Mod/EvoBase/Arts_PlayerBluePrints/Vehicle/Components/BP_VehicleEffectsComponent.BP_VehicleEffectsComponent_C",
      ConfigUtils.ENetSide.Client,
      true,
      ConfigUtils.MergeTable,
      {
        [EEffectType.Effect_Drift] = {
          "WheeledVehicleDriftParticles",
          {
            bShouldActivate = true,
            AssetParticles = {
              WheelParticles = {
                [EPhysicalSurface.SurfaceType_Default] = {
                  AssetDustParticle = "/Game/Arts_Effect/ParticleSystems/Share/P_Car_CommonDrifting01.P_Car_CommonDrifting01",
                  AssetTrailParticle = "/Game/Arts_Effect/ParticleSystems/Share/P_Car_CommonDrifting_SP.P_Car_CommonDrifting_SP"
                },
                [EPhysicalSurface.SurfaceType2] = {
                  AssetDustParticle = "/Game/Arts_Effect/ParticleSystems/Share/P_Car_DesertDrifting01.P_Car_DesertDrifting01",
                  AssetTrailParticle = "/Game/Arts_Effect/ParticleSystems/Share/P_Car_DesertDrifting_SP.P_Car_DesertDrifting_SP"
                },
                [EPhysicalSurface.SurfaceType6] = {
                  AssetDustParticle = "/Game/Arts_Effect/ParticleSystems/Share/P_Car_DesertDrifting01.P_Car_DesertDrifting01",
                  AssetTrailParticle = "/Game/Arts_Effect/ParticleSystems/Share/P_Car_DesertDrifting_SP.P_Car_DesertDrifting_SP"
                },
                [EPhysicalSurface.SurfaceType18] = {
                  AssetDustParticle = "/Game/Arts_Effect/ParticleSystems/Share/P_Car_snowfieldDrifting02.P_Car_snowfieldDrifting02",
                  AssetTrailParticle = "/Game/Arts_Effect/ParticleSystems/Share/P_Car_snowfieldDrifting02_SP.P_Car_snowfieldDrifting02_SP"
                },
                [EPhysicalSurface.SurfaceType25] = {
                  AssetDustParticle = "/Game/Arts_Effect/ParticleSystems/Share/P_Car_snowfieldDrifting02.P_Car_snowfieldDrifting02",
                  AssetTrailParticle = "/Game/Arts_Effect/ParticleSystems/Share/P_Car_snowfieldDrifting02_SP.P_Car_snowfieldDrifting02_SP"
                }
              },
              WheelHubParticle = ""
            },
            AssetAudioEvent = "/Game/WwiseEvent/Vehicle/Vehicle_Common_New/Play_Vehicle_Common_Drift.Play_Vehicle_Common_Drift",
            AudioStates = {
              [EPhysicalSurface.SurfaceType_Default] = "Common",
              [EPhysicalSurface.SurfaceType2] = "Dirt"
            },
            WheelRefRadius = 25,
            ParticleOffsetY = 0,
            AssetCurveDustAlpha = "/Game/Arts_PlayerBluePrints/Vehicle/VehicleDriftEffectOpacity_2.VehicleDriftEffectOpacity_2",
            AssetCurveTrailAlpha = "/Game/Arts_PlayerBluePrints/Vehicle/VehicleDriftEffectOpacity.VehicleDriftEffectOpacity",
            ParamName_Alpha = "Alpha",
            ParamName_DriftAngle = "Drift_VD",
            ParamName_DriftSwitchGroup = "Vehicle_Common_Drift"
          }
        }
      }
    }
  }
}
return VehicleConfig