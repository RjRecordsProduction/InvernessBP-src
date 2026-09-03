local ConfigUtils = require("GameLua.GameCore.Module.Vehicle.Config.ConfigUtils")
local VehicleConfig = {
  ExplosionDelaySeconds = 4,
  Components = {
    VehicleAudioComponent = {
      "/Game/Mod/EvoBase/Arts_PlayerBluePrints/Vehicle/Components/BP_VehicleAudioComponent.BP_VehicleAudioComponent_C",
      ConfigUtils.ENetSide.Client,
      true,
      ConfigUtils.MergeTable,
      {
        [ConfigUtils.EAudioType.Audio_Burning] = {
          "VehicleAudioBurning",
          {
            AssetAudioEvent = "/Game/WwiseEvent/Vehicle/Vehicle_Common/Play_Vehicle_Explosion_FireLoop_01.Play_Vehicle_Explosion_FireLoop_01"
          }
        },
        [ConfigUtils.EAudioType.Audio_Burning_Destroyed] = {
          "VehicleAudioDestroyedBurning",
          {
            AssetAudioEvent = "/Game/WwiseEvent/Vehicle/Vehicle_Common_New/Play_Vehicle_Car_Fire_Loop_320.Play_Vehicle_Car_Fire_Loop_320",
            AssetStopEvent = "/Game/WwiseEvent/Vehicle/Vehicle_Common_New/Stop_Vehicle_Car_Fire_Loop_320.Stop_Vehicle_Car_Fire_Loop_320"
          }
        }
      }
    }
  },
  ComponentsAttrModify = {
    VehicleSpringArm = {
      NetSide = ConfigUtils.ENetSide.Client,
      Attrs = {
        bOpenCameraLagAgainstVelocity = false,
        CameraLagCurve_BPPath = "/Game/Arts_PlayerBluePrints/Vehicle/Components/SpringArmCurveData/VehicleCameraLagCurve.VehicleCameraLagCurve",
        bOpenCameraShakeAgainstVelocity = false,
        bOpenCameraFOVChangedAgainstVelocity = false,
        bOpenCameraShiftAgainstRoll = false,
        bOpenCamereRotateAginstRoll = false,
        bOpenSpringArmLengthChangedAgainstVelocity = false,
        SpringArmLengthRateCurve_BPPath = "/Game/Arts_PlayerBluePrints/Vehicle/Components/SpringArmCurveData/VehicleCameraSpringArmLengthRateCurve.VehicleCameraSpringArmLengthRateCurve",
        bSpeedDecreaseUpdateUseLerp = false,
        SpeedDecreaseUpdateInterpSpeed = 10
      }
    }
  }
}
return VehicleConfig