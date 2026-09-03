local ConfigUtils = require("GameLua.GameCore.Module.Vehicle.Config.ConfigUtils")
local UKismetMathLibrary = import("KismetMathLibrary")
local EPhysicalSurface = import("EPhysicalSurface")
local EEffectType = ConfigUtils.EEffectType
local VehicleConfig = {
  Components = {
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
            ParticleOffsetY = 50,
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