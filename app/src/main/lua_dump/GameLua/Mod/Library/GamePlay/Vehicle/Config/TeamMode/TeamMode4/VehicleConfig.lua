local ConfigUtils = require("GameLua.GameCore.Module.Vehicle.Config.ConfigUtils")
local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
local VehicleConfig = {}
VehicleConfig.ConfigMap = {
  [ESTExtraVehicleShapeType.VST_Optimus] = {
    ComponentsAttrModify = {
      VehicleCommon = {
        NetSide = ConfigUtils.ENetSide.Server,
        Attrs = {HPMax = 5000, HP = 5000}
      }
    }
  },
  [ESTExtraVehicleShapeType.VST_OptimusVehicle] = {
    ComponentsAttrModify = {
      VehicleCommon = {
        NetSide = ConfigUtils.ENetSide.Server,
        Attrs = {HPMax = 5000, HP = 5000}
      }
    }
  },
  [ESTExtraVehicleShapeType.VST_Megatron] = {
    ComponentsAttrModify = {
      VehicleCommon = {
        NetSide = ConfigUtils.ENetSide.Server,
        Attrs = {HPMax = 4200, HP = 4200}
      }
    }
  },
  [ESTExtraVehicleShapeType.VST_MegatronVehicle] = {
    ComponentsAttrModify = {
      VehicleCommon = {
        NetSide = ConfigUtils.ENetSide.Server,
        Attrs = {HPMax = 4200, HP = 4200}
      }
    }
  },
  [ESTExtraVehicleShapeType.VST_MTLB] = {
    ComponentsAttrModify = {
      VehicleCommon = {
        NetSide = ConfigUtils.ENetSide.Server,
        Attrs = {HPMax = 4000, HP = 4000}
      }
    }
  },
  [ESTExtraVehicleShapeType.VST_LootTruck] = {
    VehicleFeatures = {
      AttributeModifier = {
        "GameLua.Mod.Library.GamePlay.Vehicle.VehicleFeatures.AttributeModifierFeature",
        ConfigUtils.ENetSide.Server,
        {
          ComponentName = "VehicleCommon",
          Attributes = {
            HPMax = {Factor = 1},
            HP = {Factor = 1}
          }
        },
        ConfigUtils.EFeaturePolicy.Addition
      }
    }
  }
}
return VehicleConfig