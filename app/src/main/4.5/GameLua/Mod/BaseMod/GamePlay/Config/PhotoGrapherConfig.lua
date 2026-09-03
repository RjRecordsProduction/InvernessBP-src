local EGameModeType = import("EGameModeType")
local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
local PhotoGrapherConfig = {
  GreenSkyClass = "/Game/Arts_Scenes/Meshs/Sky/BP_NoUI_ChromaSky.BP_NoUI_ChromaSky_C",
  TipsWhiteList = {
    48364,
    27679,
    45741,
    48384,
    7108,
    30121,
    34434,
    48775,
    49084,
    30169,
    44703,
    49356,
    14077,
    66481,
    48532,
    69081,
    69082,
    73239
  },
  SpecialPetID = {50023},
  EffectConfig = {
    [1] = {
      EffectPath = "/Game/Mod/EvoBase/Arts_Effect/ParticleSystems/P_Evobase_CameraAfterEffect_01.P_Evobase_CameraAfterEffect_01",
      ThumbnailPath = "/Game/Mod/EvoBase/Atlas/Photo/Frames/Photo_Icon_03_png.Photo_Icon_03_png"
    },
    [2] = {
      EffectPath = "/Game/Mod/EvoBase/Arts_Effect/ParticleSystems/P_Evobase_CameraAfterEffect_02.P_Evobase_CameraAfterEffect_02",
      ThumbnailPath = "/Game/Mod/EvoBase/Atlas/Photo/Frames/Photo_Icon_01_png.Photo_Icon_01_png"
    }
  },
  PhotographerOptype = {
    Open = 0,
    TakePhoto = 1,
    Template = 2,
    EmotePlayRate = 3,
    SceneEffect = 4,
    ChangeWear = 5,
    ChangedWeather = 6,
    UseInVehicle = 7
  },
  PhotographerFeatureState = {ChangeWeather = 1},
  PhotographerDisableModeType = {
    EGameModeType.EDeathMatchGameMode
  },
  PhotographerDisableMainModType = {"WarGame"},
  PhotographerDisableModeID = {},
  PhotographerDisableWeatherMainModType = {
    "TPlan",
    "TPlanPVE",
    "TPlanEBR"
  },
  ButtonTypeToButton = {
    Type_DriverEnter = "Button_Drive",
    Type_BikeEnter = "Button_Drive",
    Type_PassengerEnter = "Button_Ride",
    Type_BikePick = "Button_Ride",
    Type_TireRepair = "Button_Ride"
  },
  BasicSkillButtonType = {
    Vehicle = {
      "Type_DriverEnter",
      "Type_BikeEnter",
      "Type_PassengerEnter",
      "Type_BikePick",
      "Type_TireRepair",
      "Type_MechaDance",
      "Type_PandaDance"
    },
    Other = {
      "Type_MVPStatueCelerbrate",
      "Type_LeaveForwardEmote"
    }
  },
  ForbiddenVehicleType = {
    ESTExtraVehicleShapeType.VST_Unknown,
    ESTExtraVehicleShapeType.VST_HeavyDacia,
    ESTExtraVehicleShapeType.VST_HeavyPickup,
    ESTExtraVehicleShapeType.VST_HeavyBuggy,
    ESTExtraVehicleShapeType.VST_HeavyUAZ,
    ESTExtraVehicleShapeType.VST_HeavyUH60,
    ESTExtraVehicleShapeType.VST_MediumTank,
    ESTExtraVehicleShapeType.VST_LightTank,
    ESTExtraVehicleShapeType.VST_HeavyTank,
    ESTExtraVehicleShapeType.VST_Fighter,
    ESTExtraVehicleShapeType.VST_HeavyMecha
  },
  EnterPhotographerTipsShowTime = 2.5
}
return PhotoGrapherConfig