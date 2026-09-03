local VehicleSystem_Main_Show_Config = {
  ENUM_TabType = {SPORTSCAR = 1001},
  ENUM_Vehicle_UITYPE = {
    COLLECT = 1,
    REFIT = 2,
    ACCESSORY = 3,
    EXTENDED_FEATURE = 6
  },
  ENUM_Vehicle_ExtendedFeatureType = {
    CHASSIS_LIGHT = 1,
    VEHICLE_SWITCH_EFFECT = 2,
    VEHICLE_DIY = 3,
    VEHICLE_PLATE_BG = 4
  }
}
local reddotVehicle = require("client.slua.logic.vehicle.reddot_vehicle")
VehicleSystem_Main_Show_Config.UITabConfig = {
  {
    TabType = VehicleSystem_Main_Show_Config.ENUM_Vehicle_UITYPE.COLLECT,
    UIConfigName = "Vehicle_Collect_Main_UIBP",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyVehicle_Atlas/Frames/VehicleTab_IP_01_png.VehicleTab_IP_01_png",
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyVehicle_Atlas/Frames/VehicleTab_IP_02_png.VehicleTab_IP_02_png",
    CheckShowFunc = "CheckShowCollectTab",
    ReddotType = reddotVehicle.SubSysID.VehicleCollect
  },
  {
    TabType = VehicleSystem_Main_Show_Config.ENUM_Vehicle_UITYPE.ACCESSORY,
    UIConfigName = "Vehicle_Accessory_Preview_UIBP",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyVehicle_Atlas/Frames/VehicleTab_VehicleSkin_png.VehicleTab_VehicleSkin_png",
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyVehicle_Atlas/Frames/VehicleTab_VehicleSkin_Xuanzhong_png.VehicleTab_VehicleSkin_Xuanzhong_png"
  },
  {
    TabType = VehicleSystem_Main_Show_Config.ENUM_Vehicle_UITYPE.REFIT,
    UIConfigName = "vehicle_main",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyVehicle_Atlas/Frames/VehicleTab_VehicleWorkshop_01_png.VehicleTab_VehicleWorkshop_01_png",
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyVehicle_Atlas/Frames/VehicleTab_VehicleWorkshop_02_png.VehicleTab_VehicleWorkshop_02_png"
  }
}
VehicleSystem_Main_Show_Config.Vehicle_Process_Config = {
  {
    FeatureType = VehicleSystem_Main_Show_Config.ENUM_Vehicle_ExtendedFeatureType.CHASSIS_LIGHT,
    NameId = 74115,
    OnSelected = "OnSelectChassisLightTab",
    OnItemRefresh = "OnExtendedFeatureItemRefresh",
    OnselectItem = "OnSelectExtendedFeatureItem",
    OnDeselected = "OnDeselectedChassisLightTab",
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyVehicle_Atlas/Frames/VehicleTab_Underbody_Light01_png.VehicleTab_Underbody_Light01_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyVehicle_Atlas/Frames/VehicleTab_Underbody_Light01_png.VehicleTab_Underbody_Light01_png"
  },
  {
    FeatureType = VehicleSystem_Main_Show_Config.ENUM_Vehicle_ExtendedFeatureType.VEHICLE_SWITCH_EFFECT,
    NameId = 74116,
    OnSelected = "OnSelectedSwitchEffectTab",
    OnItemRefresh = "OnExtendedFeatureItemRefresh",
    OnselectItem = "OnSelectExtendedFeatureItem",
    OnDeselected = "OnDeselectedSwitchEffectTab",
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyVehicle_Atlas/Frames/VehicleTab_SwitchingEffect01_png.VehicleTab_SwitchingEffect01_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyVehicle_Atlas/Frames/VehicleTab_SwitchingEffect01_png.VehicleTab_SwitchingEffect01_png"
  },
  {
    FeatureType = VehicleSystem_Main_Show_Config.ENUM_Vehicle_ExtendedFeatureType.VEHICLE_DIY,
    NameId = 74117,
    CheckShowFunc = "CheckShowDIYTab",
    OnSelected = "OnSelectedDIYTab",
    OnItemRefresh = "OnDIYItemRefresh",
    OnselectItem = "OnselectDIYItem",
    OnDeselected = "OnDeselectedVehicleDIY",
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyVehicle_Atlas/Frames/VehicleTab_SideDecal01_png.VehicleTab_SideDecal01_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyVehicle_Atlas/Frames/VehicleTab_SideDecal01_png.VehicleTab_SideDecal01_png"
  }
}
return VehicleSystem_Main_Show_Config