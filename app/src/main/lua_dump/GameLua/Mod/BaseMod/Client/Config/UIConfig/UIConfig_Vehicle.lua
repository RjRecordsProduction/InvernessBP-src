local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Vehicle = {
  AircraftVehicleUI = {
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Aircraft/AircraftVehicle_UIBP.AircraftVehicle_UIBP",
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.AircraftVehicle_UIBP",
    isSingleton = true,
    uiStat = {
      name = "AircraftVehicleUI"
    },
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  BackToDriverButton = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.ControlUI.BackToDriverButton",
    path = "/Game/BluePrints/ControlInput/BackToDriverButton.BackToDriverButton",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "BackToDriverButton"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  BallVehicleControlPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.BallVehicleControlPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/WorldCup_Main_UIBP.WorldCup_Main_UIBP",
    isSingleton = true,
    uiStat = {
      name = "BallVehicleControlPanel"
    },
    isMainUI = false,
    containerName = UIContainers.Default,
    zOrder = 0,
    asy = true,
    isWindowsOBHide = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  BlanketUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.BlanketVehicleUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Blanket/BlanketUI.BlanketUI",
    isSingleton = true,
    uiStat = {name = "BlanketUI"},
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  BoomThrottleUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.VehicleItem.BoomThrottleUI",
    path = "/Game/BluePrints/ControlInput/BoomThrottle_UIBP.BoomThrottle_UIBP",
    isSingleton = true,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "BoomThrottleUI"
    }
  },
  CabrioletUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.VehicleItem.CabrioletUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/CommonItem/Cabriolet_UIBP.Cabriolet_UIBP",
    isSingleton = true,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "CabrioletUI"
    }
  },
  CapsuleVehicleUI = {
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/CapsuleVehicle/CapsuleVehicle_SkillBtn_UIBP.CapsuleVehicle_SkillBtn_UIBP",
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.CapsuleVehicleUI",
    isSingleton = true,
    uiStat = {
      name = "CapsuleVehicleUI"
    },
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  DefaultSeatGeneralUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.Seat.DefaultSeatGeneralUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Seat/DefaultSeatGeneralUI.DefaultSeatGeneralUI",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "DefaultSeatGeneralUI"
    }
  },
  DefaultSeatPopupUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.Seat.DefaultSeatPopupUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Seat/DefaultSeatPopupUI.DefaultSeatPopupUI",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 1,
    asy = true,
    uiStat = {
      name = "DefaultSeatPopupUI"
    }
  },
  DriverLastWeaponUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.DriverLastWeaponUI",
    path = "/Game/BluePrints/ControlInput/Carrier_WeaponIconButton.Carrier_WeaponIconButton",
    uiStat = {
      name = "DriverLastWeaponUI"
    },
    containerName = UIContainers.Default,
    showVisibility = UEnums.ESlateVisibility.Collapsed,
    isSingleton = true,
    asy = true,
    isMainUI = false,
    zOrder = 0
  },
  FighterControlUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.ControlUI.VehicleControlUIFighter",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Fighter/FighterControlUI.FighterControlUI",
    isSingleton = true,
    uiStat = {
      name = "FighterControlUI"
    },
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  FighterControlUI_Line = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.ControlUI.FighterControlUI_Line",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Fighter/FighterControlUI_Line.FighterControlUI_Line",
    isSingleton = true,
    uiStat = {
      name = "FighterControlUI_Line"
    },
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  FighterLeaveBtn = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.ControlUI.FighterLeaveBtn",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Fighter/FighterLeaveBtn.FighterLeaveBtn",
    isSingleton = true,
    uiStat = {
      name = "FighterLeaveBtn"
    },
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  FlyVehicleHeightUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.FlyVehicleHeightUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/FlyVehicleHeightUI.FlyVehicleHeightUI",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 1,
    asy = true,
    uiStat = {
      name = "FlyVehicleHeightUI"
    }
  },
  FuelCapacityUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.FuelCapacityUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/FuelCapacityUI.FuelCapacityUI",
    isMainUI = false,
    isWindowsOBHide = true,
    closeOnHide = false,
    bPermanentDuringThisBattle = true,
    zOrder = 1,
    asy = true,
    uiStat = {
      name = "FuelCapacityUI"
    }
  },
  VehicleSpeedUpUI = {
    moduleName = "GameLua.Mod.Library.GamePlay.Vehicle.PenguinCart.VehicleSpeedUpUI",
    path = "/Game/Library/Res/Vehicles/PenguinCart/Blueprints/UI/VehicleSpeedUpUI.VehicleSpeedUpUI",
    isMainUI = false,
    isWindowsOBHide = true,
    closeOnHide = false,
    bPermanentDuringThisBattle = true,
    zOrder = 1,
    asy = true,
    uiStat = {
      name = "VehicleSpeedUpUI"
    }
  },
  VehicleFuelEcoModeIUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleFuelEcoModeIUI",
    path = "/Game/Library/Res/Skills/PSKillSprint/BluePrints/UI/VehicleFuelEcoModeI_UI.VehicleFuelEcoModeI_UI",
    isMainUI = false,
    isWindowsOBHide = true,
    closeOnHide = false,
    bPermanentDuringThisBattle = true,
    zOrder = 1,
    asy = true,
    uiStat = {
      name = "VehicleFuelEcoModeIUI"
    }
  },
  VehicleShieldUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleFuelEcoModeIUI",
    path = "/Game/Library/Res/Skills/PSKillSprint/BluePrints/UI/VehicleShield_UI.VehicleShield_UI",
    isMainUI = false,
    isWindowsOBHide = true,
    closeOnHide = false,
    bPermanentDuringThisBattle = true,
    zOrder = 1,
    asy = true,
    uiStat = {
      name = "VehicleShieldUI"
    }
  },
  NitroInstallUI = {
    moduleName = "GameLua.Mod.ZNQ8th.Client.UI.NitroInstallUI",
    path = "/Game/Mod/ZNQ8th/Arts_PlayerBluePrints/Vehicle/NitroBoost/UI/NitrogenInstall_UI.NitrogenInstall_UI",
    isMainUI = false,
    isWindowsOBHide = true,
    closeOnHide = false,
    bPermanentDuringThisBattle = true,
    zOrder = 1,
    asy = true,
    uiStat = {
      name = "NitroInstallUI"
    }
  },
  NoFuelNitroInstallUI = {
    moduleName = "GameLua.Mod.ZNQ8th.Client.UI.NitroInstallUI",
    path = "/Game/Mod/ZNQ8th/Arts_PlayerBluePrints/Vehicle/NitroBoost/UI/NoFuelNitrogenInstall_UI.NoFuelNitrogenInstall_UI",
    isMainUI = false,
    isWindowsOBHide = true,
    closeOnHide = false,
    bPermanentDuringThisBattle = true,
    zOrder = 1,
    asy = true,
    uiStat = {
      name = "NoFuelNitroInstallUI"
    }
  },
  NitroBoostUI = {
    moduleName = "GameLua.Mod.ZNQ8th.Client.UI.NitroBoostUI",
    path = "/Game/Mod/ZNQ8th/Arts_PlayerBluePrints/Vehicle/NitroBoost/UI/NitrogenEnergy_UI.NitrogenEnergy_UI",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = -1,
    asy = true,
    uiStat = {
      name = "NitroBoostUI"
    }
  },
  HelicopterSeatGeneralUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.Seat.HelicopterSeatGeneralUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Seat/HelicopterSeatGeneralUI.HelicopterSeatGeneralUI",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "HelicopterSeatGeneralUI"
    }
  },
  HelicopterSeatPopupUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.Seat.HelicopterSeatPopupUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Seat/HelicopterSeatPopupUI.HelicopterSeatPopupUI",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 1,
    asy = true,
    uiStat = {
      name = "HelicopterSeatPopupUI"
    }
  },
  HomeSeat_Interaction_Action_UIBP = {
    moduleName = "GameLua.Mod.Library.Client.Home.HomeSeat_Interaction_Action_UIBP",
    path = "/Game/Library/Res/Actors/HomeSeat/UI/HomeSeat_Interaction_Action_UIBP.HomeSeat_Interaction_Action_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "HomeSeat_Interaction_Action_UIBP"
    }
  },
  HorseControlUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.ControlUI.HorseControlUI",
    path = "/Game/Library/Res/Vehicles/Horse/BluePrints/UI/HorseControlUI.HorseControlUI",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "HorseControlUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  HoveringMechaControlUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.ControlUI.HoveringMechaControlUI",
    path = "/Game/Library/Res/Vehicles/Mecha/BluePrints/UI/HoveringMechaControlUI.HoveringMechaControlUI",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "HoveringMechaControlUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  MechaCancelUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.MechaCancelUI",
    path = "/Game/Library/Res/Vehicles/Mecha/BluePrints/UI/MechaCancelUI.MechaCancelUI",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "MechaCancelUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  MechaVehicleControlUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.ControlUI.MechaVehicleControlUI",
    path = "/Game/Library/Res/Vehicles/Mecha/BluePrints/UI/MechaVehicleControlUI.MechaVehicleControlUI",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "MechaVehicleControlUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  MegatronControlPanel = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.MegatronControl.MegatronControlPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Tank/TankControl_UIBP.TankControl_UIBP",
    isSingleton = true,
    uiStat = {
      name = "MegatronControlPanel"
    },
    isMainUI = false,
    containerName = UIContainers.Default,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  MegatronUIPanel = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.MegatronControl.MegatronUIPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Tank/TankUI_UIBP.TankUI_UIBP",
    isSingleton = true,
    uiStat = {
      name = "MegatronUIPanel"
    },
    isMainUI = false,
    containerName = UIContainers.Bottom,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  NewVehicleControlUIMotorglider = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.ControlUI.NewVehicleControlUIMotorglider",
    path = "/Game/BluePrints/ControlInput/GliderUI/Glider_Motorglider_UIBP.Glider_Motorglider_UIBP",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "NewVehicleControlUIMotorglider"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  PterosaurControlUI = {
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/DinosaurUI/Pterosaur_SkillBtn_UIBP.Pterosaur_SkillBtn_UIBP",
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.DinosaurUI.PterosaurControlUI",
    isSingleton = true,
    uiStat = {
      name = "PterosaurControlUI"
    },
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  RaptorDinosaurControlPanel = {
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/DinosaurUI/RaptorVehicleControlUI.RaptorVehicleControlUI",
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.DinosaurUI.RaptorVehicleExtraUI",
    isSingleton = true,
    uiStat = {
      name = "RaptorDinosaurControlPanel"
    },
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  ReindeerCartUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.Reindeer.ReindeerCartUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Reindeer/ReindeerCartUI.ReindeerCartUI",
    isSingleton = true,
    uiStat = {
      name = "ReindeerCartUI"
    },
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  ReindeerUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.Reindeer.ReindeerUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Reindeer/ReindeerUI.ReindeerUI",
    isSingleton = true,
    uiStat = {name = "ReindeerUI"},
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  RubberDuckUI = {
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/RubberDuck/RubberDuck_SkillBtn_UIBP.RubberDuck_SkillBtn_UIBP",
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.RubberDuckUI",
    isSingleton = true,
    uiStat = {
      name = "RubberDuckUI"
    },
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  SkateUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.SkateVehicleUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Skate/SkateUI.SkateUI",
    asy = true,
    isMainUI = false,
    isSingleton = true,
    uiStat = {name = "SkateUI"},
    AndroidBackType = EAndroidBackType.Ban
  },
  SnowBallVehicleControlPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.SnowBallVehicleControlPanel",
    path = "/Game/Library/Res/Hero/SnowBall/UI/SnowBallVehicle.SnowBallVehicle",
    isSingleton = true,
    uiStat = {
      name = "SnowBallVehicleControlPanel"
    },
    isMainUI = false,
    isWindowsOBHide = true,
    containerName = UIContainers.Default,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  SnowBoardUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.SnowBoardUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/SnowBoard/SnowBoardUI.SnowBoardUI",
    isSingleton = true,
    uiStat = {
      name = "SnowBoardUI"
    },
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  TankControlPanel = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.TankControl.TankControlPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Tank/TankControl_UIBP.TankControl_UIBP",
    isSingleton = true,
    uiStat = {
      name = "TankControlPanel"
    },
    isMainUI = false,
    containerName = UIContainers.Default,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  TankUIPanel = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.TankControl.TankUIPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Tank/TankUI_UIBP.TankUI_UIBP",
    isSingleton = true,
    uiStat = {
      name = "TankUIPanel"
    },
    isMainUI = false,
    containerName = UIContainers.Bottom,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  TigerControlUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.TigerVehicleUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Tiger/TigerVehicleControlUI.TigerVehicleControlUI",
    asy = true,
    isMainUI = false,
    isSingleton = true,
    uiStat = {
      name = "TigerControlUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  TitanControlUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.ControlUI.TitanControlUI",
    path = "/Game/Library/Res/Vehicles/Giant/UI/GiantControlUI.GiantControlUI",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "TitanControlUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  TyrannosaurusControlUI = {
    path = "/Game/Library/Res/Vehicles/TRex/Blueprints/UI/TyrannosaurusControlPanel_UIBP.TyrannosaurusControlPanel_UIBP",
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.DinosaurUI.TyrannosaurusControlUI",
    isSingleton = true,
    uiStat = {
      name = "TyrannosaurusControlUI"
    },
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  UH60ControlUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.ControlUI.VehicleControlUIUH60",
    path = "/Game/BluePrints/ControlInput/IngameUI/UH60/UH60ControlUI.UH60ControlUI",
    isSingleton = true,
    uiStat = {
      name = "UH60ControlUI"
    },
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  ValentineBikeUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.SpecialVehicleControlUI.ValentineBikeUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/ValentineBike/ValentineBikeUI.ValentineBikeUI",
    isSingleton = true,
    uiStat = {
      name = "ValentineBikeUI"
    },
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  VehicleBackpack = {
    moduleName = "GameLua.Mod.Library.Client.UI.Backpack.VehicleBackpack",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/VehicleBackpack/VehicleBackpack.VehicleBackpack",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 1,
    asy = true,
    uiStat = {
      name = "VehicleBackpack"
    }
  },
  VehicleControlPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleControlPanelMain",
    path = "/Game/BluePrints/ControlInput/VehileControlPanel.VehileControlPanel",
    isSingleton = true,
    isMainUI = false,
    asy = false,
    autoCreate = true,
    isWindowsOBHide = true,
    uiStat = {
      name = "VehicleControlPanel"
    },
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  VehicleControlUIBike = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.ControlUI.VehicleControlUIBike",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/ControlUI/VehicleControlUIBike.VehicleControlUIBike",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "VehicleControlUIBike"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  VehicleControlUIFourButtons = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.ControlUI.VehicleControlUIFourButtons",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/ControlUI/VehicleControlUIFourButtons.VehicleControlUIFourButtons",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "VehicleControlUIFourButtons"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  VehicleControlUISpeed = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.ControlUI.VehicleControlUISpeed",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/ControlUI/VehicleControlUISpeed.VehicleControlUISpeed",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "VehicleControlUISpeed"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  BioVehicleControlUIAutoMove = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.ControlUI.BioVehicleControlUIAutoMove",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/ControlUI/BioVehicleControlUIAutoMove.BioVehicleControlUIAutoMove",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "BioVehicleControlUIAutoMove"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  VehicleControlUISteering = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.ControlUI.VehicleControlUISteering",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/ControlUI/VehicleControlUISteering.VehicleControlUISteering",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "VehicleControlUISteering"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  VehicleControlUIVTOL = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.ControlUI.VehicleControlUIVTOL",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/ControlUI/VehicleControlUIVTOL.VehicleControlUIVTOL",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "VehicleControlUIVTOL"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  VehicleFlyInfoUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.ControlUI.VehicleFlyInfoUI",
    path = "/Game/Library/Res/Vehicles/Mecha/BluePrints/UI/VehicleFlyInfoUI.VehicleFlyInfoUI",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "VehicleFlyInfoUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  VehicleGuideSlideTips = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.Tips.VehicleGuideSlideTips",
    path = "/Game/BluePrints/ControlInput/NewbieItem/VehicleGuideTips03_UIBP.VehicleGuideTips03_UIBP",
    uiStat = {
      name = "VehicleGuideSlideTips"
    },
    asy = true,
    isMainUI = false,
    containerName = UIContainers.Bottom
  },
  VehicleInteractUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleInteractUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/VehicleInteractUI.VehicleInteractUI",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "VehicleInteractUI"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  VehicleSkinAndMusicButton = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleSkinAndMusicButton",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/VehicleSkinAndMusicButton.VehicleSkinAndMusicButton",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "VehicleSkinAndMusicButton"
    }
  },
  VehicleSkinAndMusicPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleSkinAndMusicPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/VehicleSkinAndMusicPanel.VehicleSkinAndMusicPanel",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "VehicleSkinAndMusicPanel"
    }
  },
  MissileMarkerItem = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.ControlUI.MissileMarkerItem",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Fighter/MissileMarkerItem.MissileMarkerItem",
    isSingleton = false,
    uiStat = {
      name = "MissileMarkerItem"
    },
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  VehicleSkillItemBase = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleSkill.VehicleSkillItemBase",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/CommonItem/VehicleSkillItemBase_UIBP.VehicleSkillItemBase_UIBP",
    isMainUI = false,
    isSingleton = false,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "VehicleSkillItemBase"
    }
  },
  MTLBUIPanel = {
    moduleName = "GameLua.Mod.Library.GamePlay.Vehicle.MTLB.MTLBUIPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/Tank/TankUI_UIBP.TankUI_UIBP",
    isSingleton = true,
    uiStat = {
      name = "MTLBUIPanel"
    },
    isMainUI = false,
    containerName = UIContainers.Bottom,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  VehicleTurboUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleTurboUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/VehicleTurbocharged_UIBP.VehicleTurbocharged_UIBP",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "VehicleTurboUI"
    }
  }
}
return UIConfig_Vehicle