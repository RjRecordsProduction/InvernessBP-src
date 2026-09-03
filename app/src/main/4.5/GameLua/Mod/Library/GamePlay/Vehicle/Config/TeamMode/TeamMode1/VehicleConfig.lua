local ConfigUtils = require("GameLua.GameCore.Module.Vehicle.Config.ConfigUtils")
local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
local VehicleConfig = {}
VehicleConfig.ConfigMap = {
  [ESTExtraVehicleShapeType.VST_Optimus] = {
    ComponentsAttrModify = {
      VehicleCommon = {
        NetSide = ConfigUtils.ENetSide.Server,
        Attrs = {HPMax = 3000.0, HP = 3000.0}
      }
    }
  },
  [ESTExtraVehicleShapeType.VST_OptimusVehicle] = {
    ComponentsAttrModify = {
      VehicleCommon = {
        NetSide = ConfigUtils.ENetSide.Server,
        Attrs = {HPMax = 3000.0, HP = 3000.0}
      }
    }
  },
  [ESTExtraVehicleShapeType.VST_Megatron] = {
    ComponentsAttrModify = {
      VehicleCommon = {
        NetSide = ConfigUtils.ENetSide.Server,
        Attrs = {HPMax = 2520.0, HP = 2520.0}
      }
    }
  },
  [ESTExtraVehicleShapeType.VST_MegatronVehicle] = {
    ComponentsAttrModify = {
      VehicleCommon = {
        NetSide = ConfigUtils.ENetSide.Server,
        Attrs = {HPMax = 2520.0, HP = 2520.0}
      }
    }
  },
  [ESTExtraVehicleShapeType.VST_MTLB] = {
    ComponentsAttrModify = {
      VehicleCommon = {
        NetSide = ConfigUtils.ENetSide.Server,
        Attrs = {HPMax = 2400.0, HP = 2400.0}
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
            HPMax = {Factor = 0.475},
            HP = {Factor = 0.475}
          }
        },
        ConfigUtils.EFeaturePolicy.Addition
      }
    }
  }
}
return VehicleConfig