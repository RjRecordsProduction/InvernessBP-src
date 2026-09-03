local InputFunctionMap = require("GameLua.GameCore.Module.Input.InputFunctionMap")
local InputConditions = require("GameLua.GameCore.Module.Input.InputConditions")
local UESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local InputMappingConfig = {
  AnyKey = {},
  R = {
    [1] = {
      DisplayName = "\230\141\162\229\188\185",
      PressedFunction = InputFunctionMap.PressedReload
    }
  },
  SpaceBar = {
    [1] = {
      DisplayName = "\232\189\189\229\133\183\229\136\185\232\189\166",
      ActiveCondition = InputConditions.OnVehicleCondition,
      PressedFunction = InputFunctionMap.PressedVehicleBrake,
      ReleasedFunction = InputFunctionMap.ReleasedVehicleBrake
    },
    [2] = {
      DisplayName = "\228\184\138\230\181\174",
      ActiveCondition = InputConditions.SwimInputCondition,
      PressedFunction = InputFunctionMap.PressedSwimUp,
      ReleasedFunction = InputFunctionMap.ReleasedSwimUp
    },
    [3] = {
      DisplayName = "\232\183\179\232\183\131",
      PressedFunction = InputFunctionMap.PressedJump,
      ReleasedFunction = InputFunctionMap.ReleasedJump
    }
  },
  M = {
    [1] = {
      DisplayName = "\229\175\187\232\183\175",
      ActiveCondition = InputConditions.bTestMove,
      PressedFunction = InputFunctionMap.PressedTargetMove
    },
    [2] = {
      DisplayName = "\229\164\167\229\156\176\229\155\190",
      PressedFunction = InputFunctionMap.PressedEntireMap
    }
  },
  Tab = {
    [1] = {
      DisplayName = "\232\131\140\229\140\133Tab",
      PressedFunction = InputFunctionMap.PressedBackPack
    }
  },
  I = {
    [1] = {
      DisplayName = "\232\131\140\229\140\133",
      ActiveCondition = true,
      PressedFunction = InputFunctionMap.PressedBackPack
    }
  },
  C = {
    [1] = {
      DisplayName = "\228\184\139\230\189\156",
      ActiveCondition = InputConditions.SwimInputCondition,
      PressedFunction = InputFunctionMap.PressedSwimDown,
      ReleasedFunction = InputFunctionMap.ReleasedSwimDown
    },
    [2] = {
      DisplayName = "\229\136\135\230\141\162\229\186\167\228\189\141",
      ActiveCondition = InputConditions.OnVehicleCondition,
      PressedFunction = InputFunctionMap.PressedChangeSeat,
      ReleasedFunction = InputFunctionMap.ReleasedChangeSeat
    },
    [3] = {
      DisplayName = "\232\185\178",
      PressedFunction = InputFunctionMap.PressedCrouch
    }
  },
  Z = {
    [1] = {
      DisplayName = "\232\182\180",
      PressedFunction = InputFunctionMap.PressedProne
    }
  },
  V = {
    [1] = {
      DisplayName = "\229\136\135\230\141\162\228\186\186\231\167\176",
      ActiveCondition = InputConditions.CanSwitchScopeCondition,
      PressedFunction = InputFunctionMap.PressedSwitchPMode
    }
  },
  Equals = {
    [1] = {
      DisplayName = "\232\135\170\229\138\168\231\150\190\232\183\145",
      PressedFunction = InputFunctionMap.PressedSprint
    }
  },
  Enter = {
    [1] = {
      DisplayName = "\229\191\171\230\141\183\232\129\138\229\164\169",
      PressedFunction = InputFunctionMap.PressedQuickChatMenu
    }
  },
  One = {
    [1] = {
      DisplayName = "\229\136\135\230\141\162\228\184\187\230\173\166\229\153\168",
      PressedFunction = InputFunctionMap.PressedSwitchWeapon,
      Params = {
        UESurviveWeaponPropSlot.SWPS_MainShootWeapon1
      }
    }
  },
  Two = {
    [1] = {
      DisplayName = "\229\136\135\230\141\162\229\137\175\230\173\166\229\153\168",
      PressedFunction = InputFunctionMap.PressedSwitchWeapon,
      Params = {
        UESurviveWeaponPropSlot.SWPS_MainShootWeapon2
      }
    }
  },
  Three = {
    [1] = {
      DisplayName = "\229\136\135\230\141\162\230\137\139\230\158\170",
      PressedFunction = InputFunctionMap.PressedSwitchWeapon,
      Params = {
        UESurviveWeaponPropSlot.SWPS_SubShootWeapon
      }
    }
  },
  T = {
    [1] = {
      DisplayName = "\229\143\152\232\186\171",
      ActiveCondition = InputConditions.CanVehicleTransform,
      PressedFunction = InputFunctionMap.PressedTransform
    },
    [2] = {
      DisplayName = "\228\184\135\232\131\189\230\160\135\231\130\185",
      PressedFunction = InputFunctionMap.PressedQuickSign
    }
  },
  MiddleMouseButton = {
    [1] = {
      DisplayName = "\228\184\135\232\131\189\230\160\135\231\130\185",
      PressedFunction = InputFunctionMap.PressedQuickSign
    }
  },
  F4 = {
    [1] = {
      DisplayName = "\232\161\168\230\131\133",
      PressedFunction = InputFunctionMap.PressedChangeSight,
      ReleasedFunction = InputFunctionMap.ReleasedChangeSight
    }
  },
  Q = {
    [1] = {
      DisplayName = "\229\183\166\230\142\162\229\164\180",
      ActionFlag = "LeftPeek",
      PressedFunction = InputFunctionMap.PressedPeek,
      ReleasedFunction = InputFunctionMap.ReleasedPeek,
      Params = {true},
      MixOperationThreshold = 0.3
    }
  },
  E = {
    [1] = {
      DisplayName = "\229\143\179\230\142\162\229\164\180",
      ActionFlag = "RightPeek",
      PressedFunction = InputFunctionMap.PressedPeek,
      ReleasedFunction = InputFunctionMap.ReleasedPeek,
      Params = {false},
      MixOperationThreshold = 0.3
    }
  },
  Tilde = {
    [1] = {
      DisplayName = "\230\152\190\231\164\186\233\154\144\232\151\143\233\188\160\230\160\135",
      PressedFunction = InputFunctionMap.SetMouseCursor
    }
  },
  LeftMouseButton = {
    [1] = {
      DisplayName = "\229\188\128\231\129\171",
      PressedFunction = InputFunctionMap.PressedFire,
      ReleasedFunction = InputFunctionMap.ReleasedFire
    }
  },
  RightMouseButton = {
    [1] = {
      DisplayName = "\229\143\150\230\182\136\229\156\176\229\155\190\230\160\135\231\130\185",
      ActiveCondition = InputConditions.EntireMapCondition,
      PressedFunction = InputFunctionMap.EntireMapDeleteMark
    },
    [2] = {
      DisplayName = "\229\188\128\233\149\156",
      ActionFlag = "Aim",
      ActiveCondition = InputConditions.IsWeaponEntityEnableScopeIn,
      PressedFunction = InputFunctionMap.PressedAim,
      ReleasedFunction = InputFunctionMap.ReleasedAim,
      MixOperationThreshold = 0.3
    },
    [3] = {
      DisplayName = "\229\136\135\230\141\162\230\138\149\230\142\183\230\168\161\229\188\143",
      ActiveCondition = InputConditions.IsAGrenadeCondition,
      PressedFunction = InputFunctionMap.PressedChangeThrowMode
    },
    [4] = {
      DisplayName = "\229\136\135\230\141\162\232\191\145\230\136\152\230\168\161\229\188\143",
      PressedFunction = InputFunctionMap.PressedChangeThrowPlus
    }
  },
  ["LeftAlt+RightMouseButton"] = {
    [1] = {
      DisplayName = "\229\136\135\230\141\162\228\190\167\233\157\162\231\158\132\229\133\183",
      PressedFunction = InputFunctionMap.PressedAim,
      ReleasedFunction = InputFunctionMap.ReleasedAim
    }
  },
  B = {
    [1] = {
      DisplayName = "\229\136\135\230\141\162\229\176\132\229\135\187\230\168\161\229\188\143",
      PressedFunction = InputFunctionMap.PressedSetWeaponShootType
    }
  },
  F = {
    [1] = {
      DisplayName = "\229\143\150\230\182\136\230\138\149\230\142\183",
      ActiveCondition = InputConditions.CanCancelCondition,
      PressedFunction = InputFunctionMap.PressedCancelThrow
    },
    [2] = {
      DisplayName = "\228\184\139\232\189\166",
      ActiveCondition = InputConditions.OnVehicleCondition,
      PressedFunction = InputFunctionMap.PressedExitVehicle
    },
    [3] = {
      DisplayName = "\230\149\145\230\143\180",
      ActiveCondition = InputConditions.RescueCondition,
      PressedFunction = InputFunctionMap.PressedRescue
    },
    [4] = {
      DisplayName = "\232\183\179\228\188\158",
      ActiveCondition = InputConditions.OnPlaneCondition,
      PressedFunction = InputFunctionMap.PressedLeavePlane
    },
    [5] = {
      DisplayName = "\229\188\128\228\188\158",
      ActiveCondition = InputConditions.ParachutingCondition,
      PressedFunction = InputFunctionMap.PressedOpenParachute
    },
    [6] = {
      DisplayName = "\230\139\190\229\143\150\230\173\187\228\186\161\231\155\146\229\173\144",
      ActiveCondition = InputConditions.CanCloseDeathBoxCondition,
      PressedFunction = InputFunctionMap.PressedPickUpDeathBox,
      Params = {1}
    },
    [7] = {
      DisplayName = "\230\139\190\229\143\150",
      ActiveCondition = InputConditions.CanClosePickUpListCondition,
      PressedFunction = InputFunctionMap.PressedPickUp,
      Params = {1}
    },
    [8] = {
      DisplayName = "\230\173\187\228\186\161\231\155\146\229\173\144",
      ActiveCondition = InputConditions.CanOpenDeathBoxCondition,
      PressedFunction = InputFunctionMap.PressedOpenDeathBox
    },
    [9] = {
      DisplayName = "\230\139\190\229\143\150\229\136\151\232\161\168",
      ActiveCondition = InputConditions.CanOpenPickUpListCondition,
      PressedFunction = InputFunctionMap.PressedOpenPickUpList
    },
    [10] = {
      DisplayName = "\233\128\154\231\148\168\230\138\128\232\131\1891",
      ActiveCondition = InputConditions.BasicSkillOperationCondition,
      PressedFunction = InputFunctionMap.PressedBasicSkill1
    },
    [11] = {
      DisplayName = "\233\128\154\231\148\168\228\186\164\228\186\146",
      ActiveCondition = InputConditions.BasicSkillInteractCondition,
      PressedFunction = InputFunctionMap.PressedInteractItem
    },
    [12] = {
      DisplayName = "\229\188\128\231\129\171",
      PressedFunction = InputFunctionMap.PressedFire,
      ReleasedFunction = InputFunctionMap.ReleasedFire
    }
  },
  G = {
    [1] = {
      DisplayName = "\232\189\189\229\133\183\230\142\162\229\164\180",
      ActiveCondition = InputConditions.VehiclePassengerCondition,
      PressedFunction = InputFunctionMap.LeanVehicle
    },
    [2] = {
      DisplayName = "\232\189\189\229\133\183\229\150\135\229\143\173",
      ActiveCondition = InputConditions.VehicleDriverCondition,
      PressedFunction = InputFunctionMap.PressedVehicleSpeaker,
      ReleasedFunction = InputFunctionMap.ReleasedVehicleSpeaker
    },
    [3] = {
      DisplayName = "\232\131\140\230\137\182",
      ActiveCondition = InputConditions.CarryBackCondition,
      PressedFunction = InputFunctionMap.PressedCarryBack
    },
    [4] = {
      DisplayName = "\230\139\190\229\143\150\230\173\187\228\186\161\231\155\146\229\173\144",
      ActiveCondition = InputConditions.CanCloseDeathBoxCondition,
      PressedFunction = InputFunctionMap.PressedPickUpDeathBox,
      Params = {2}
    },
    [5] = {
      DisplayName = "\230\139\190\229\143\150",
      ActiveCondition = InputConditions.CanClosePickUpListCondition,
      PressedFunction = InputFunctionMap.PressedPickUp,
      Params = {2}
    },
    [6] = {
      DisplayName = "\233\128\154\231\148\168\230\138\128\232\131\1892",
      ActiveCondition = InputConditions.BasicSkillOperationCondition,
      PressedFunction = InputFunctionMap.PressedBasicSkill2
    }
  },
  H = {
    [1] = {
      DisplayName = "\230\139\190\229\143\150\230\173\187\228\186\161\231\155\146\229\173\144",
      ActiveCondition = InputConditions.CanCloseDeathBoxCondition,
      PressedFunction = InputFunctionMap.PressedPickUpDeathBox,
      Params = {3}
    },
    [2] = {
      DisplayName = "\230\139\190\229\143\150",
      ActiveCondition = InputConditions.CanClosePickUpListCondition,
      PressedFunction = InputFunctionMap.PressedPickUp,
      Params = {3}
    },
    [3] = {
      DisplayName = "\233\128\154\231\148\168\230\138\128\232\131\1893",
      ActiveCondition = InputConditions.BasicSkillOperationCondition,
      PressedFunction = InputFunctionMap.PressedBasicSkill3
    }
  },
  MouseScrollUp = {
    [1] = {
      DisplayName = "\230\148\190\229\164\167\229\156\176\229\155\190",
      ActiveCondition = InputConditions.EntireMapCondition,
      PressedFunction = InputFunctionMap.EntireMapZoomIn
    },
    [2] = {
      DisplayName = "\229\135\134\233\149\156\230\148\190\229\164\167",
      ActiveCondition = InputConditions.ChangeScopeCondition,
      PressedFunction = InputFunctionMap.PressedChangeSightRoomIn
    },
    [3] = {
      DisplayName = "\229\136\135\230\141\162\230\173\166\229\153\168",
      ActiveCondition = InputConditions.ScrollWeaponCondition,
      PressedFunction = InputFunctionMap.MouseWheelUpSwitchWeapon
    }
  },
  MouseScrollDown = {
    [1] = {
      DisplayName = "\231\188\169\229\176\143\229\156\176\229\155\190",
      ActiveCondition = InputConditions.EntireMapCondition,
      PressedFunction = InputFunctionMap.EntireMapZoomOut
    },
    [2] = {
      DisplayName = "\229\135\134\233\149\156\231\188\169\229\176\143",
      ActiveCondition = InputConditions.ChangeScopeCondition,
      PressedFunction = InputFunctionMap.PressedChangeSightRoomOut
    },
    [3] = {
      DisplayName = "\229\136\135\230\141\162\230\173\166\229\153\168",
      ActiveCondition = InputConditions.ScrollWeaponCondition,
      PressedFunction = InputFunctionMap.MouseWheelDownSwitchWeapon
    }
  },
  U = {
    [1] = {
      DisplayName = "\229\150\135\229\143\173\229\188\128\229\133\179",
      PressedFunction = InputFunctionMap.PressedTeamSpeaker
    }
  },
  Y = {
    [1] = {
      DisplayName = "\233\186\166\229\133\139\233\163\142\229\188\128\229\133\179",
      PressedFunction = InputFunctionMap.PressedTeamMicphone
    }
  },
  Four = {
    [1] = {
      DisplayName = "\230\137\139\233\155\183",
      PressedFunction = InputFunctionMap.SelectGrenade
    }
  },
  Five = {
    [1] = {
      DisplayName = "\231\131\159\233\155\190\229\188\185",
      PressedFunction = InputFunctionMap.SelectSmokeGrenade
    }
  },
  Six = {
    [1] = {
      DisplayName = "\231\135\131\231\131\167\231\147\182",
      PressedFunction = InputFunctionMap.SelectMolotovCocktailOrStunGrenade
    }
  },
  Seven = {
    [1] = {
      DisplayName = "\228\189\191\231\148\168\229\189\147\229\137\141\232\141\175\229\147\129",
      PressedFunction = InputFunctionMap.UseCurrentMedicine
    }
  },
  Eight = {
    [1] = {
      DisplayName = "\230\128\165\230\149\145\229\140\133",
      PressedFunction = InputFunctionMap.SelectFirstAidKit
    }
  },
  Nine = {
    [1] = {
      DisplayName = "\231\187\183\229\184\166",
      PressedFunction = InputFunctionMap.SelectBandages
    }
  },
  Zero = {
    [1] = {
      DisplayName = "\232\131\189\233\135\143\233\165\174\230\150\153",
      PressedFunction = InputFunctionMap.SelectEnergyDrink
    }
  },
  X = {
    [1] = {
      DisplayName = "\232\191\145\230\136\152\230\173\166\229\153\168",
      PressedFunction = InputFunctionMap.SelectMelee
    }
  },
  LeftShift = {
    [1] = {
      DisplayName = "\232\189\189\229\133\183\229\138\160\233\128\159",
      ActiveCondition = InputConditions.VehicleCanBoostCondition,
      PressedFunction = InputFunctionMap.PressedVehicleSprint,
      ReleasedFunction = InputFunctionMap.ReleasedVehicleSprint
    },
    [2] = {
      DisplayName = "\230\138\172\233\171\152\232\189\166\229\164\180",
      ActiveCondition = InputConditions.OnVehicleCondition,
      PressedFunction = InputFunctionMap.PressedVehicleAirControlUp,
      ReleasedFunction = InputFunctionMap.ReleasedVehicleAirControlUp
    },
    [3] = {
      DisplayName = "\231\150\190\232\183\145",
      PressedFunction = InputFunctionMap.StartSprint,
      ReleasedFunction = InputFunctionMap.StopSprint
    }
  },
  LeftAlt = {
    [1] = {
      DisplayName = "\229\176\143\231\156\188\231\157\155",
      ActiveCondition = InputConditions.FreeCameraCondition,
      PressedFunction = InputFunctionMap.PressedFreeCamera,
      ReleasedFunction = InputFunctionMap.ReleasedFreeCamera
    }
  },
  LeftControl = {
    [1] = {
      DisplayName = "\229\142\139\228\189\142\232\189\166\229\164\180",
      ActiveCondition = InputConditions.OnVehicleCondition,
      PressedFunction = InputFunctionMap.PressedVehicleAirControlDown,
      ReleasedFunction = InputFunctionMap.ReleasedVehicleAirControlDown
    }
  },
  Escape = {
    [1] = {
      DisplayName = "\229\133\179\233\151\173\230\141\162\229\186\167\228\189\141UI",
      ActiveCondition = InputConditions.OnVehicleCondition,
      PressedFunction = InputFunctionMap.PressedCloseChangeSeat
    },
    [2] = {
      DisplayName = "\229\143\150\230\182\136\230\149\145\230\143\180/\232\131\140\230\137\182",
      ActiveCondition = InputConditions.CancelUseCondition,
      PressedFunction = InputFunctionMap.PressedCancelUse
    },
    [3] = {
      DisplayName = "\229\133\179\233\151\173\230\139\190\229\143\150\229\136\151\232\161\168",
      ActiveCondition = InputConditions.CanCloseDeathBoxCondition,
      PressedFunction = InputFunctionMap.PressedCloseDeathBox
    },
    [4] = {
      DisplayName = "\229\133\179\233\151\173\230\139\190\229\143\150\229\136\151\232\161\168",
      ActiveCondition = InputConditions.CanClosePickUpListCondition,
      PressedFunction = InputFunctionMap.PressedClosePickUpList
    },
    [5] = {
      DisplayName = "\229\133\179\233\151\173UI",
      PressedFunction = InputFunctionMap.CloseUIByAndroidBack
    }
  },
  W = {
    [1] = {
      DisplayName = "\232\189\189\229\133\183\229\137\141\232\191\155",
      ActiveCondition = InputConditions.OnVehicleCondition,
      PressedFunction = InputFunctionMap.PressedVehicleForward,
      ReleasedFunction = InputFunctionMap.ReleasedVehicleForward
    }
  },
  A = {
    [1] = {
      DisplayName = "\232\189\189\229\133\183\229\144\145\229\183\166",
      ActiveCondition = InputConditions.OnVehicleCondition,
      PressedFunction = InputFunctionMap.PressedVehicleTurnLeft,
      ReleasedFunction = InputFunctionMap.ReleasedVehicleTurnLeft
    }
  },
  S = {
    [1] = {
      DisplayName = "\232\189\189\229\133\183\229\135\143\233\128\159",
      ActiveCondition = InputConditions.OnVehicleCondition,
      PressedFunction = InputFunctionMap.PressedVehicleBackward,
      ReleasedFunction = InputFunctionMap.ReleasedVehicleBackward
    },
    [2] = {
      DisplayName = "\233\128\128\229\135\186\231\150\190\232\183\145",
      PressedFunction = InputFunctionMap.StopSprint
    }
  },
  D = {
    [1] = {
      DisplayName = "\232\189\189\229\133\183\229\144\145\229\143\179",
      ActiveCondition = InputConditions.OnVehicleCondition,
      PressedFunction = InputFunctionMap.PressedVehicleTurnRight,
      ReleasedFunction = InputFunctionMap.ReleasedVehicleTurnRight
    }
  },
  Up = {
    [1] = {
      DisplayName = "\233\163\158\232\161\140\229\153\168\229\138\160\233\128\159",
      ActiveCondition = InputConditions.OnVehicleCondition,
      PressedFunction = InputFunctionMap.PressedAircraftThrottle,
      ReleasedFunction = InputFunctionMap.ReleasedAircraftThrottle
    }
  },
  Down = {
    [1] = {
      DisplayName = "\233\163\158\232\161\140\229\153\168\229\135\143\233\128\159",
      ActiveCondition = InputConditions.OnVehicleCondition,
      PressedFunction = InputFunctionMap.PressedAircraftThrottleBackward,
      ReleasedFunction = InputFunctionMap.ReleasedAircraftThrottleBackward
    }
  }
}
return InputMappingConfig