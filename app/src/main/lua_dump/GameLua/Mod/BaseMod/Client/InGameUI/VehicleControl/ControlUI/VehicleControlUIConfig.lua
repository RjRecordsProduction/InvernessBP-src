local ESTExtraVehicleType = import("ESTExtraVehicleType")
local VehicleControlUIConfig = {
  [ESTExtraVehicleType.VT_Unknown] = {
    HideAllVehicleUI = false,
    DriverUIGroup = {},
    HideLastWeaponUI = false,
    PassengerUIGroup = {},
    CommonUIGroup = {},
    VehicleMode = 1,
    VModeKey = nil
  },
  [ESTExtraVehicleType.VT_CatapultMachine] = {HideAllVehicleUI = true},
  [ESTExtraVehicleType.VT_SnowBall] = {
    DriverUIGroup = {
      "SnowBallVehicleControlPanel",
      "VehicleControlUIVTOL"
    },
    VehicleMode = 2
  },
  [ESTExtraVehicleType.VT_SciFi] = {
    DriverUIGroup = {
      "BallVehicleControlPanel"
    },
    VehicleMode = 2
  },
  [ESTExtraVehicleType.VT_LionDance] = {
    DriverUIGroup = {
      "LionDanceExtraUI"
    },
    VehicleMode = 3
  },
  [ESTExtraVehicleType.VT_Tank] = {
    CommonUIGroup = {
      "TankControlPanel"
    },
    bIsShowInSpectatorMode = true,
    VehicleMode = 3
  },
  [ESTExtraVehicleType.VT_MegatronVehicle] = {
    CommonUIGroup = {
      "TFVehicleHealthUI",
      "IngameHPUIBase",
      "TF_DuelBeginsUI"
    },
    DriverUIGroup = {
      "MegatronControlPanel"
    },
    bIsShowInSpectatorMode = true,
    VehicleMode = 3,
    HideLastWeaponUI = true
  },
  [ESTExtraVehicleType.VT_RaptorDinosaur] = {
    DriverUIGroup = {
      "RaptorDinosaurControlPanel"
    },
    VehicleMode = 3
  },
  [ESTExtraVehicleType.VT_Pterosaur] = {
    CommonUIGroup = {
      "PterosaurControlUI"
    },
    DriverUIGroup = {
      "VehicleControlUIVTOL"
    },
    VehicleMode = 2
  },
  [ESTExtraVehicleType.VT_Aircraft] = {
    DriverUIGroup = {
      "AircraftVehicleUI",
      "VehicleControlUIVTOL"
    },
    VehicleMode = 2
  },
  [ESTExtraVehicleType.VT_TyrannosaurusRex] = {
    DriverUIGroup = {
      "TyrannosaurusControlUI"
    },
    VehicleMode = 3
  },
  [ESTExtraVehicleType.VT_UAV] = {
    DriverUIGroup = {"UavUIBP"},
    VehicleMode = false
  },
  [ESTExtraVehicleType.VT_UCAV] = {
    DriverUIGroup = {
      "VehicleControlUIUCAV"
    },
    HideLastWeaponUI = true,
    VehicleMode = false
  },
  [ESTExtraVehicleType.VT_Motorglider] = {
    DriverUIGroup = {
      "NewVehicleControlUIMotorglider"
    },
    VehicleMode = 2
  },
  [ESTExtraVehicleType.VT_TrackVehicle] = {
    CommonUIGroup = {
      "VehicleControlUITrack"
    },
    VehicleMode = false
  },
  [ESTExtraVehicleType.VT_RubberDuck] = {
    DriverUIGroup = {
      "RubberDuckUI",
      "VehicleControlUISpeed"
    },
    VehicleMode = "General"
  },
  [ESTExtraVehicleType.VT_CapsuleVehicle] = {
    DriverUIGroup = {
      "CapsuleVehicleUI"
    },
    VehicleMode = "General"
  },
  [ESTExtraVehicleType.VT_ReindeerBio] = {
    DriverUIGroup = {"ReindeerUI"},
    VehicleMode = false
  },
  [ESTExtraVehicleType.VT_ReindeerCart] = {
    CommonUIGroup = {
      "ReindeerCartUI"
    },
    VehicleMode = "General"
  },
  [ESTExtraVehicleType.VT_Snowboard] = {
    DriverUIGroup = {
      "SnowBoardUI"
    },
    VehicleMode = 3
  },
  [ESTExtraVehicleType.VT_Bike_Valentine] = {
    DriverUIGroup = {
      "ValentineBikeUI",
      "VehicleControlUIBike"
    },
    VehicleMode = "General"
  },
  [ESTExtraVehicleType.VT_BlanketVehicle] = {
    DriverUIGroup = {
      "BlanketUI",
      "VehicleControlUIVTOL"
    },
    VehicleMode = 2
  },
  [ESTExtraVehicleType.VT_UH60] = {
    CommonUIGroup = {
      "UH60ControlUI"
    },
    DriverUIGroup = {
      "VehicleControlUIVTOL"
    },
    VehicleMode = 2
  },
  [ESTExtraVehicleType.VT_Fighter] = {
    DriverUIGroup = {
      "FighterControlUI"
    },
    VehicleMode = 2,
    HideLastWeaponUI = true
  },
  [ESTExtraVehicleType.VT_MechaVehicle] = {
    DriverUIGroup = {
      "MechaVehicleControlUI"
    },
    VehicleMode = 2,
    HideLastWeaponUI = true
  },
  [ESTExtraVehicleType.VT_Optimus] = {
    CommonUIGroup = {
      "TFVehicleHealthUI",
      "IngameHPUIBase",
      "TF_DuelBeginsUI"
    },
    DriverUIGroup = {
      "TFVehicleControlUI",
      "OPCrosshairUI"
    },
    VehicleMode = 2,
    HideLastWeaponUI = true
  },
  [ESTExtraVehicleType.VT_OptimusVehicle] = {
    CommonUIGroup = {
      "TFVehicleHealthUI",
      "IngameHPUIBase",
      "TF_DuelBeginsUI"
    },
    DriverUIGroup = {
      "VehicleControlUISpeed"
    },
    HideLastWeaponUI = true,
    VehicleMode = "General"
  },
  [ESTExtraVehicleType.VT_Megatron] = {
    CommonUIGroup = {
      "TFVehicleHealthUI",
      "IngameHPUIBase",
      "TF_DuelBeginsUI"
    },
    DriverUIGroup = {
      "TFVehicleControlUI",
      "MTCrosshairUI"
    },
    VehicleMode = 2,
    HideLastWeaponUI = true
  },
  [ESTExtraVehicleType.VT_HoveringMecha] = {
    DriverUIGroup = {
      "HoveringMechaControlUI"
    },
    VehicleMode = 2,
    HideLastWeaponUI = true
  },
  [ESTExtraVehicleType.VT_Tiger] = {
    CommonUIGroup = {
      "TigerControlUI"
    },
    VehicleMode = 3
  },
  [ESTExtraVehicleType.VT_OceanVehicle] = {
    DriverUIGroup = {
      "SkateUI",
      "VehicleControlUIVTOL"
    },
    VehicleMode = 2
  },
  [ESTExtraVehicleType.VT_Broom] = {
    DriverUIGroup = {
      "BroomControlUI",
      "VehicleControlUIVTOL"
    },
    VehicleMode = 2
  },
  [ESTExtraVehicleType.VT_Horse] = {
    CommonUIGroup = {
      "HorseControlUI"
    },
    DriverUIGroup = {
      "BioVehicleControlUIAutoMove"
    },
    VehicleMode = 3,
    VModeKey = ESTExtraVehicleType.VT_Horse
  },
  [ESTExtraVehicleType.VT_WarHorse] = {
    CommonUIGroup = {
      "HorseControlUI"
    },
    VehicleMode = 3,
    VModeKey = ESTExtraVehicleType.VT_Horse
  },
  [ESTExtraVehicleType.VT_HorseLiquid] = {
    CommonUIGroup = {
      "LiquidHorseControlUI"
    },
    VehicleMode = 3
  },
  [ESTExtraVehicleType.VT_Mammoth] = {
    DriverUIGroup = {
      "MammothControlUI"
    },
    VehicleMode = 3
  },
  [ESTExtraVehicleType.VT_UAVDeer] = {
    DriverUIGroup = {"UavDeerUI"},
    VehicleMode = 3
  },
  [ESTExtraVehicleType.VT_Titan] = {
    DriverUIGroup = {
      "TitanControlUI"
    },
    VehicleMode = 2
  },
  [ESTExtraVehicleType.VT_Camel] = {
    CommonUIGroup = {
      "CamelControlUI"
    },
    DriverUIGroup = {
      "BioVehicleControlUIAutoMove"
    },
    VehicleMode = 3,
    VModeKey = ESTExtraVehicleType.VT_Camel
  },
  [ESTExtraVehicleType.VT_PenguinCart] = {
    CommonUIGroup = {
      "PenguinSledgeControlUI"
    },
    VehicleMode = 3
  },
  [ESTExtraVehicleType.VT_UAVGodView] = {
    CommonUIGroup = {
      "UAVControlUI"
    },
    VehicleMode = 2
  }
}
return VehicleControlUIConfig