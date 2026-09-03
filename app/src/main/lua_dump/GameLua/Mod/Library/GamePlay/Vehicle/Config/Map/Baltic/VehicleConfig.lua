local ConfigUtils = require("GameLua.GameCore.Module.Vehicle.Config.ConfigUtils")
local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
local VehicleConfig = {}
VehicleConfig.ConfigMap = {
  [ESTExtraVehicleShapeType.VST_LootTruck] = {
    VehicleFeatures = {
      AttributeModifier = {
        "GameLua.Mod.Library.GamePlay.Vehicle.VehicleFeatures.AttributeModifierFeature",
        ConfigUtils.ENetSide.Server,
        {
          ComponentName = "VehicleCommon",
          Attributes = {
            HPMax = {Value = 6720},
            HP = {Value = 6720}
          }
        },
        ConfigUtils.EFeaturePolicy.Addition
      }
    }
  },
  default = {
    STExtraWheeledVehicle = {
      bCanFreezePhysics = false,
      VehicleFeatures = {
        AttributeModifier = {
          "GameLua.Mod.Library.GamePlay.Vehicle.VehicleFeatures.AttributeModifierFeature",
          ConfigUtils.ENetSide.Both,
          {
            Attributes = {
              DestroyedSetup = {
                Value = {bStopAnim = false}
              }
            }
          },
          ConfigUtils.EFeaturePolicy.Addition
        }
      }
    },
    VehicleTank = {bCanFreezePhysics = false},
    TrackedVehicle = {bCanFreezePhysics = false}
  }
}
return VehicleConfig