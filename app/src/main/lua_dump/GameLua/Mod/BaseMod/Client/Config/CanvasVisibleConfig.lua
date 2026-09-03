local EPawnState = import("EPawnState")
local EStateType = import("EStateType")
local EGameReplayType = import("EGameReplayType")
local ESpectatorReplayFlag = import("ESpectatorReplayFlag")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local ShowHideUIFlag = require("GameLua.Mod.BaseMod.Client.Config.ShowHideUIFlag")
local VehicleControlUIFlag = require("GameLua.Mod.BaseMod.Client.Config.VehicleControlUIFlag")
local CommonTransformConfig = require("GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.Config.CommonBornLandTransformConfig")
local CanvasVisibleConfig = {
  ShoulderCanvasPanel = {
    ControllerStateChanged = {
      Show = {
        EStateType.State_Fight,
        EStateType.State_Finish
      }
    },
    WeaponStateChanged = {
      Show = {
        ESurviveWeaponPropSlot.SWPS_MainShootWeapon1,
        ESurviveWeaponPropSlot.SWPS_MainShootWeapon2,
        ESurviveWeaponPropSlot.SWPS_SubShootWeapon
      },
      FuncName = "OnCanvasPanelPlayerWeaponChanged"
    },
    GameModeID = {
      Hide = {
        24001,
        24002,
        24003,
        24004
      }
    },
    SettingSwitch = {
      ParamName = "ShoulderEnable",
      FuncName = "RefreshShoulderBtnShow"
    }
  },
  ShootingUIPanel_SkillLayer = {
    ControllerStateChanged = {
      Show = {
        EStateType.State_Fight,
        EStateType.State_Finish
      }
    },
    SpectatorReplay = {
      Hide = ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay
    },
    PlayerStateChanged = {
      Hide = {
        EPawnState.InActivityActor
      }
    }
  },
  SkillBtnShowConfig = {
    SwitchUIOperation = {
      Show = {
        UEnums.UIOperation.Shoot
      }
    }
  },
  SkillBtnShowConfig2 = {
    SwitchUIOperation = {
      Show = {
        UEnums.UIOperation.Shoot
      }
    },
    PlayerStateChanged = {
      Hide = {
        EPawnState.Swim
      }
    }
  },
  TransformVehicleSkillBtnShowConfig = {
    TransformVehicleBtnShowOperation = {
      Show = {
        UEnums.UIOperation.Shoot
      }
    }
  },
  ShootingUIPanel_CustomWeaponUI = {
    SpectatorReplay = {
      Hide = ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay
    }
  },
  ShootingUIPanelCanvasPanelBtnGroup = {
    SpectatorReplay = {
      Hide = ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay
    },
    PetSpectator = {Show = false}
  },
  BasicSkillsMenu_BP = {
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bInteractWithHumanConnon] = true,
        [ShowHideUIFlag.bOnHumanConnon] = true
      }
    },
    PlayerStateChanged = {
      Hide = {
        EPawnState.Arrest
      }
    }
  },
  CanvasPanelBackpackPanel = {
    PlayerStateChanged = {
      Hide = {
        EPawnState.InZipline,
        EPawnState.InActivityActor,
        EPawnState.ControlUnmannedVehicle,
        EPawnState.RemoteControlVehicle
      }
    },
    ControllerStateChanged = {
      Hide = {
        EStateType.State_InPlane,
        EStateType.State_InExPlane,
        EStateType.State_ParachuteJump,
        EStateType.State_ParachuteOpen,
        EStateType.State_Dead,
        EStateType.State_PlaneJumpShow
      }
    },
    SpectatorReplay = {
      Hide = ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay
    }
  },
  EmoteSwimingControl = {
    GameModeID = {
      Hide = {
        50029,
        50030,
        50031,
        50032,
        50033,
        50034,
        50035,
        50036,
        50037,
        50038,
        50039,
        50040,
        50041,
        50042,
        50043,
        50044,
        50045,
        50046,
        50057,
        50048,
        50049,
        50050,
        50051,
        50052,
        50053
      }
    },
    SpectatorReplay = {
      Hide = ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay
    }
  },
  MainControlBaseUI_CanvasPanel_MiniMapAndSetting = {
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.ShowWinnerTime] = true,
        [ShowHideUIFlag.HideMiniMapAndSettingForUGC] = true
      }
    },
    SpectatorReplay = {
      Hide = ESpectatorReplayFlag.ESpectatorReplayFlag_Global | ESpectatorReplayFlag.ESpectatorReplayFlag_ClientRecord | ESpectatorReplayFlag.ESpectatorReplayFlag_ObservingReplay
    }
  },
  MainControlBaseUI_CircleChasingProgress = {
    GameModeID = {
      Hide = {
        60011,
        60012,
        60013,
        60014,
        60031,
        60032
      }
    }
  },
  MainControlBaseUI_PlayerInfoPanel = {
    SpectatorReplay = {
      Hide = ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay
    }
  },
  ShootingUIPanel_ShoulderBtnPanel = {},
  ShootingUIPanel_MultiLayer_LeftWeaponSlot = {
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnTank] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bHideWeaponSlot] = true,
        [ShowHideUIFlag.bEnterHalloWeen2Drive] = true,
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true
      }
    },
    PhotoGrapherState = {Hide = true}
  },
  ShootingUIPanel_MultiLayer_RightWeaponSlot = {
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnTank] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bHideWeaponSlot] = true,
        [ShowHideUIFlag.bEnterHalloWeen2Drive] = true,
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true
      }
    },
    PhotoGrapherState = {Hide = true}
  },
  ShootingUIPanel_MultiLayer_Pistol = {
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnTank] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bHideWeaponSlot] = true,
        [ShowHideUIFlag.bEnterHalloWeen2Drive] = true,
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true
      }
    },
    PhotoGrapherState = {Hide = true}
  },
  ShootingUIPanel_MultiLayer_PMode = {
    PhotoGrapherState = {Hide = true},
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bHideUIForPlanAP] = true,
        [ShowHideUIFlag.bShowDeathMatchUI] = true,
        [ShowHideUIFlag.bHideUIForLivikPlanA] = true,
        [ShowHideUIFlag.bEnterCelebrateWorldCup] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true,
        [ShowHideUIFlag.bEnterVehicleFighterState] = true
      }
    }
  },
  ShootingUIPanel_MultiLayer_AimCanvas = {
    PhotoGrapherState = {Hide = true},
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bEnterHalloWeen2Drive] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true,
        [ShowHideUIFlag.bSwimmingWhenCarryBack] = true
      }
    },
    ControllerStateChanged = {
      Hide = {
        EStateType.State_InPlane,
        EStateType.State_InExPlane,
        EStateType.State_ParachuteJump,
        EStateType.State_ParachuteOpen
      }
    },
    WeaponStateChanged = {
      Hide = {
        ESurviveWeaponPropSlot.SWPS_None,
        ESurviveWeaponPropSlot.SWPS_MeleeWeapon,
        ESurviveWeaponPropSlot.SWPS_HandProp
      },
      FuncName = "VehicleWeaponEnableScope"
    }
  },
  ShootingUIPanel_CanvasPanel_Root = {
    SpectatorReplay = {
      Hide = ESpectatorReplayFlag.ESpectatorReplayFlag_Global | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay | ESpectatorReplayFlag.ESpectatorReplayFlag_Pure
    }
  },
  ShootingUIPanel_MultiLayer_ReloadCanvas = {
    PhotoGrapherState = {Hide = true},
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnTank] = true,
        [ShowHideUIFlag.bOnMTLB] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true,
        [ShowHideUIFlag.bSwimmingWhenCarryBack] = true
      }
    }
  },
  ShootingUIPanel_MultiLayer_SprintPanel = {
    PhotoGrapherState = {Hide = true},
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true,
        [ShowHideUIFlag.bMortarPlaced] = true
      }
    },
    EnterResultCountDown = {Show = false},
    PlayerStateChanged = {
      Hide = {
        EPawnState.AttachToOther
      }
    }
  },
  ShootingUIPanel_MultiLayer_CancelGrenadeCanvas = {
    PhotoGrapherState = {Hide = true},
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true
      }
    }
  },
  ShootingUIPanel_MultiLayer_ChatCanvas = {
    PhotoGrapherState = {Hide = true},
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true
      }
    }
  },
  ShootingUIPanel_MultiLayer_ConsumableCanvas = {
    PhotoGrapherState = {Hide = true},
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true
      }
    },
    SwimStateChanged = {Show = false}
  },
  ShootingUIPanel_MultiLayer_GrenadeCanvas = {
    PhotoGrapherState = {Hide = true},
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bEnterHalloWeen2Drive] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true
      }
    }
  },
  ShootingUIPanel_MultiLayer_ThemePropCanvas = {
    PhotoGrapherState = {Hide = true},
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bEnterHalloWeen2Drive] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true
      }
    }
  },
  ShootingUIPanel_MultiLayer_LeanCanvas_Lside = {
    PhotoGrapherState = {Hide = true},
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bEnterHalloWeen2Drive] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true,
        [ShowHideUIFlag.bMortarPlaced] = true
      }
    },
    PlayerStateChanged = {
      Hide = {
        EPawnState.AttachToOther
      }
    }
  },
  ShootingUIPanel_MultiLayer_LungCanvas = {
    PhotoGrapherState = {Hide = true},
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true
      }
    },
    SpectatorReplay = {
      Hide = ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay
    },
    PlayerStateChanged = {
      Hide = {
        EPawnState.Dead
      }
    }
  },
  ShootingUIPanel_MultiLayer_SwitchThrowCanvas = {
    PhotoGrapherState = {Hide = true},
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true
      }
    }
  },
  ShootingUIPanel_MultiLayer_LeanCanvas_Rside = {
    PhotoGrapherState = {Hide = true},
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bEnterHalloWeen2Drive] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true,
        [ShowHideUIFlag.bMortarPlaced] = true
      }
    },
    PlayerStateChanged = {
      Hide = {
        EPawnState.AttachToOther
      }
    }
  },
  ShootingUIPanel_MultiLayer_CrouchCanvas = {
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bEnterFly] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bStartDriveHalloWeen2Drive] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true,
        [ShowHideUIFlag.bMortarPlaced] = true
      }
    },
    SwimStateChanged = {Show = false},
    PlayerStateChanged = {
      Hide = {
        EPawnState.AttachToOther
      }
    }
  },
  ShootingUIPanel_MultiLayer_JumpCanvas = {
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bEnterFly] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bForbiddenPlayerJump] = true,
        [ShowHideUIFlag.bStartDriveHalloWeen2Drive] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true,
        [ShowHideUIFlag.bMortarPlaced] = true
      }
    },
    PlayerStateChanged = {
      Hide = {
        EPawnState.AttachToOther
      }
    }
  },
  ShootingUIPanel_JumpVault_Canvas = {
    PlayerStateChanged = {
      Hide = {
        EPawnState.AttachToOther
      }
    }
  },
  ShootingUIPanel_AICommand_Canvas = {},
  ShootingUIPanel_MultiLayer_LeftFireCanvas = {
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bHideLeftHandFire] = true,
        [ShowHideUIFlag.bEnterHalloWeen2Drive] = true,
        [ShowHideUIFlag.bEnterVehicleShooting] = true,
        [ShowHideUIFlag.bGrenadeLaunchEnterNoUIMode] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true,
        [ShowHideUIFlag.bSwimmingWhenCarryBack] = true
      }
    },
    SwimStateChanged = {Show = false}
  },
  ShootingUIPanel_MultiLayer_ProneCanvas = {
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bEnterHalloWeen2Drive] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true,
        [ShowHideUIFlag.bMortarPlaced] = true
      }
    },
    SwimStateChanged = {Show = false},
    PlayerStateChanged = {
      Hide = {
        EPawnState.AttachToOther
      }
    }
  },
  ShootingUIPanel_MultiLayer_RightFireCanvas = {
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bEnterVehicleShooting] = true,
        [ShowHideUIFlag.bEnterHalloWeen2Drive] = true,
        [ShowHideUIFlag.bGrenadeLaunchEnterNoUIMode] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true,
        [ShowHideUIFlag.bSwimmingWhenCarryBack] = true
      }
    }
  },
  ShootingUIPanel_MultiLayer_VaultCanvas = {
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnEmergencyCall] = true,
        [ShowHideUIFlag.bEnterAreaFly] = true,
        [ShowHideUIFlag.bStartDriveHalloWeen2Drive] = true,
        [ShowHideUIFlag.bHideShootingUIPanelForNoviceGuidance] = true
      }
    },
    SwimStateChanged = {Show = false},
    PlayerStateChanged = {
      Hide = {
        EPawnState.AttachToOther
      }
    }
  },
  VehicleControlPanel_LeaveVehicle = {
    VehicleUIChanged = {
      Show = {
        [VehicleControlUIFlag.VehicleExitOperation] = true
      }
    },
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bHideLeaveVehicle] = true
      }
    }
  },
  BuffListPanel = {
    PhotoGrapherState = {Hide = true},
    ShowHideUIWithFlag = {
      Hide = {}
    }
  },
  VehicleSeatUI = {
    PlayerStateChanged = {
      Hide = {
        EPawnState.Dying
      }
    },
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bHideVehicleSeat] = true
      }
    }
  },
  VehicleMiscellaneous = {
    PhotoGrapherState = {Hide = true}
  },
  IslandSurviveCountPanel = {
    SpectatorReplay = {
      Hide = ESpectatorReplayFlag.ESpectatorReplayFlag_Replay
    }
  },
  PickUpListPanel_BP_Root = {
    PlayerStateChanged = {
      Hide = {
        EPawnState.AttachToOther
      }
    }
  },
  ShootingUIPanel_Border_Throw = {
    PhotoGrapherState = {Hide = true}
  },
  BattlePassCoatingMes02ItemUI_CanvasPanel_BattlePassRoot = {
    SpectatorReplay = {
      Hide = ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay
    }
  },
  AutoParachuteUI_CanvasPanel_AutoJump = {
    SpectatorReplay = {
      Hide = ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay
    }
  },
  SkillBuildMVPButtonSlot_BP = {},
  MainControlBaseUI_CanvasPanel_FreeCamera = {},
  MainControlBaseUI_CanvasPanel_QuickSign = {
    PhotoGrapherState = {Hide = true},
    SpectatorReplay = {
      Hide = ESpectatorReplayFlag.ESpectatorReplayFlag_Spectator | ESpectatorReplayFlag.ESpectatorReplayFlag_Replay
    }
  },
  MainControlBaseUI_CanvasPanel_ChangeSight = {},
  NavigatorPanel_CanvasPanelRoot = {},
  QuickExpressionDecalUI_CanvasPanelRoot = {
    PlayerStateChanged = {
      Hide = {
        EPawnState.AttachToOther
      }
    }
  },
  CDBarUI_BP = {
    ShowHideUIWithFlag = {
      Hide = {
        [ShowHideUIFlag.bOnDrone] = true
      }
    }
  }
}
CanvasVisibleConfig.CommonHideHeroID = CommonTransformConfig:GetBornLandCanChangeHeroId()
CanvasVisibleConfig.ShootingUIPanel_SkillLayer.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.CanvasPanelBackpackPanel.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.EmoteSwimingControl.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_ShoulderBtnPanel.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_LeftWeaponSlot.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_RightWeaponSlot.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_Pistol.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_PMode.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_AimCanvas.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_ReloadCanvas.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_SprintPanel.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_ChatCanvas.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_ConsumableCanvas.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_GrenadeCanvas.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_LeanCanvas_Lside.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_SwitchThrowCanvas.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_LeanCanvas_Rside.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_CrouchCanvas.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_LeftFireCanvas.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_ProneCanvas.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_RightFireCanvas.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_MultiLayer_VaultCanvas.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
if not CanvasVisibleConfig.CreativeModePetSpectateUI_Main then
  CanvasVisibleConfig.CreativeModePetSpectateUI_Main = {}
end
CanvasVisibleConfig.CreativeModePetSpectateUI_Main.HeroIDChanged = {
  Hide = CanvasVisibleConfig.CommonHideHeroID
}
CanvasVisibleConfig.ShootingUIPanel_CanvasPanel_Root.Skill = {
  Hide = {1014711}
}
CanvasVisibleConfig.MainControlBaseUI_CanvasPanel_FreeCamera.Skill = {
  Hide = {1014711}
}
CanvasVisibleConfig.CanvasPanelBackpackPanel.Skill = {
  Hide = {1014711}
}
CanvasVisibleConfig.NavigatorPanel_CanvasPanelRoot.Skill = {
  Hide = {1014711}
}
CanvasVisibleConfig.QuickExpressionDecalUI_CanvasPanelRoot.Skill = {
  Hide = {1014711}
}
CanvasVisibleConfig.PickUpListPanel_BP_Root.Skill = {
  Hide = {1014711}
}
CanvasVisibleConfig.MainControlBaseUI_HelmetArmor = {}
return CanvasVisibleConfig