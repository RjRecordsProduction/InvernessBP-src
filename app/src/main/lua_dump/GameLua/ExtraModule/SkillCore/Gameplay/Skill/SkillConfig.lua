local SkillCDDefine = require("GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCDDefine")
local ESkillIconStatus = import("ESkillIconStatus")
local CreateRoadConfig = require("GameLua.Mod.Library.GamePlay.SpecialMove.CreateRoadMove.CreateRoadMoveConfig")
local Config = {
  [3800017] = {
    SkillWidgetParams = {
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.GameCore.Module.Skill.SkillUI.SkillUIWidgetTemplate",
      MountData = {
        MountName = "CanvasPanel_SkillSlot7"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/GasHook/Arts/UI/Atlas/Frames/ZD_Icon_FlyingStrike_png.ZD_Icon_FlyingStrike_png"
      }
    }
  },
  [4000001] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 15}
      }
    },
    SkillWidgetParams = {
      CanvasVisibleConfigKey = "GhostSkillBtnShowConfig",
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/Skills/GhostBalloon/BluePrints/UI/GhostBalloon_SkillButton.GhostBalloon_SkillButton",
      WidgetClass = "GameLua.ExtraModule.SkillCore.Client.GhostBalloon.GhostBalloonSkillButton",
      MountData = {
        MountName = "CanvasPanel_SkillSlot2"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/GhostBalloon/Arts/UI/Atlas/Frames/ZD_Icon_Balloon_Jet_png.ZD_Icon_Balloon_Jet_png",
        [ESkillIconStatus.IconBtnActive] = "/Game/Library/Res/Skills/GhostBalloon/Arts/UI/Atlas/Frames/ZD_Icon_Balloon_Jet_png.ZD_Icon_Balloon_Jet_png",
        [ESkillIconStatus.IconBtnInCD] = "/Game/Library/Res/Skills/GhostBalloon/Arts/UI/Atlas/Frames/ZD_Icon_Balloon_Jet_png.ZD_Icon_Balloon_Jet_png"
      },
      SkillPhaseIcon = {
        [3] = "/Game/Library/Res/Skills/GhostBalloon/Arts/UI/Atlas/Frames/ZD_Icon_Balloon_Available_png.ZD_Icon_Balloon_Available_png",
        [4] = "/Game/Library/Res/Skills/GhostBalloon/Arts/UI/Atlas/Frames/ZD_Icon_Balloon_Unavailable_png.ZD_Icon_Balloon_Unavailable_png"
      }
    }
  },
  [4000002] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 20}
      },
      [2] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {bIgnoreCastSkillCheck = true, nCD = 20.5}
      }
    },
    SkillWidgetParams = {
      ActiveCDIndex = 2,
      CanvasVisibleConfigKey = "GhostSkillBtnShowConfig",
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.ExtraModule.SkillCore.Gameplay.GhostShield.Client.UI.GhostShieldSkillButton",
      MountData = {
        MountName = "CanvasPanel_SkillSlot2"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/GhostShield/Arts/UI/Atlas/Frames/ZD_Icon_Ghost_Shield_png.ZD_Icon_Ghost_Shield_png",
        [ESkillIconStatus.IconBtnActive] = "/Game/Library/Res/Skills/GhostShield/Arts/UI/Atlas/Frames/ZD_Icon_Ghost_Shield_02_png.ZD_Icon_Ghost_Shield_02_png",
        [ESkillIconStatus.IconBtnInCD] = "/Game/Library/Res/Skills/GhostShield/Arts/UI/Atlas/Frames/ZD_Icon_Ghost_Shield_png.ZD_Icon_Ghost_Shield_png"
      }
    },
    KillInfoIcon = "/Game/Arts/UI/NoAtlas/KillInfoTypeIcon/killfeed_cause_punch_r.killfeed_cause_punch_r"
  },
  [4003001] = {
    SkillWidgetParams = {
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/Skills/Vanishing/BluePrints/UI/CommonSkillAttackBtn.CommonSkillAttackBtn",
      WidgetClass = "GameLua.ExtraModule.SkillCore.Client.UI.SkillButton.BeastSkillButton",
      MountData = {
        MountName = "CanvasPanel_BeastCancel"
      },
      SkillIcon = {}
    }
  },
  [4003002] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 2}
      }
    },
    SkillWidgetParams = {
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.ExtraModule.SkillCore.Client.UI.SkillButton.TrampleDashSkillButton",
      MountData = {
        MarginData = {
          Left = 0.0,
          Top = 0.0,
          Right = 0.0,
          Bottom = 0.0
        },
        AnchorsData = {
          Minimum = {0.0, 0.0},
          Maximum = {1.0, 1.0}
        },
        Alignment = {0.0, 0.0},
        MountName = "CanvasPanel_SkillSlot1"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/Vanishing/Arts/UI/Atlas/Frames/ZD_Icon_Vanishing_Increase_png.ZD_Icon_Vanishing_Increase_png",
        [ESkillIconStatus.IconBtnInCD] = "/Game/Library/Res/Skills/Vanishing/Arts/UI/Atlas/Frames/ZD_Icon_Vanishing_Increase_png.ZD_Icon_Vanishing_Increase_png",
        [ESkillIconStatus.IconBtnActive] = "/Game/Library/Res/Skills/Vanishing/Arts/UI/Atlas/Frames/ZD_Icon_Vanishing_Increase02_png.ZD_Icon_Vanishing_Increase02_png"
      }
    },
    KillInfoIcon = "/Game/Library/Res/Skills/Vanishing/Arts/UI/Atlas/Frames/ZD_Icon_Vanishing_Increase_png.ZD_Icon_Vanishing_Increase_png"
  },
  [4100001] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 3}
      },
      [2] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 6}
      }
    },
    SkillWidgetParams = {
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      ActiveCDIndex = 2,
      WidgetPath = "/Game/Library/Res/Weapons/PenguinRocket/Arts_PlayerBlueprints/UI/SkillButton_RocketLaunch.SkillButton_RocketLaunch",
      WidgetClass = "GameLua.Mod.IceWorld4.Gameplay.Weapons.PenguinRocketLaunchButton",
      MountData = {
        MarginData = {
          Left = 0.0,
          Top = 0.0,
          Right = 0.0,
          Bottom = 0.0
        },
        AnchorsData = {
          Minimum = {0.0, 0.0},
          Maximum = {1.0, 1.0}
        },
        Alignment = {0.0, 0.0},
        MountName = "CanvasPanel_Skill3"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Weapons/PenguinRocket/Arts_UI/Atlas/Frames/ZD_icon_PenguinRocket_Eject_png.ZD_icon_PenguinRocket_Eject_png",
        [ESkillIconStatus.IconBtnActive] = "/Game/Library/Res/Weapons/PenguinRocket/Arts_UI/Atlas/Frames/ZD_icon_PenguinRocket_Eject_Light_png.ZD_icon_PenguinRocket_Eject_Light_png",
        [ESkillIconStatus.IconBtnInCD] = "/Game/Library/Res/Weapons/PenguinRocket/Arts_UI/Atlas/Frames/ZD_icon_PenguinRocket_Eject_png.ZD_icon_PenguinRocket_Eject_png"
      }
    }
  },
  [4100004] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 3}
      },
      [2] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 6}
      }
    },
    SkillWidgetParams = {
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      ActiveCDIndex = 2,
      WidgetPath = "/Game/Library/Res/Weapons/PenguinRocket/Arts_PlayerBlueprints/UI/SkillButton_BulletTime.SkillButton_BulletTime",
      WidgetClass = "GameLua.Mod.IceWorld4.Gameplay.Weapons.PenguinRocketLaunchButton",
      MountData = {
        MarginData = {
          Left = 0.0,
          Top = 0.0,
          Right = 0.0,
          Bottom = 0.0
        },
        AnchorsData = {
          Minimum = {0.0, 0.0},
          Maximum = {1.0, 1.0}
        },
        Alignment = {0.0, 0.0},
        MountName = "CanvasPanel_Skill4"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Weapons/PenguinRocket/Arts_UI/Atlas/Frames/ZD_icon_BulletTime_png.ZD_icon_BulletTime_png",
        [ESkillIconStatus.IconBtnActive] = "/Game/Library/Res/Weapons/PenguinRocket/Arts_UI/Atlas/Frames/ZD_icon_BulletTime_Light_png.ZD_icon_BulletTime_Light_png",
        [ESkillIconStatus.IconBtnInCD] = "/Game/Library/Res/Weapons/PenguinRocket/Arts_UI/Atlas/Frames/ZD_icon_BulletTime_png.ZD_icon_BulletTime_png"
      }
    }
  },
  [4100011] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 30}
      },
      [2] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {
          nCD = CreateRoadConfig.CreateRoadStateDuration
        }
      }
    },
    SkillWidgetParams = {
      CanvasVisibleConfigKey = "SkillBtnShowConfig",
      ActiveCDIndex = 2,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.Mod.Library.Client.UI.SkillButton.CreateRoadMoveSkillButton",
      MountData = {
        MarginData = {
          Left = 0.0,
          Top = 0.0,
          Right = 0.0,
          Bottom = 0.0
        },
        AnchorsData = {
          Minimum = {0.0, 0.0},
          Maximum = {1.0, 1.0}
        },
        Alignment = {0.0, 0.0},
        MountName = "CanvasPanel_Skill4"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/IceRoad/Arts_UI/Atlas/Frames/ZD_Icon_Ice4_Skates01_png.ZD_Icon_Ice4_Skates01_png",
        [ESkillIconStatus.IconBtnInCD] = "/Game/Library/Res/Skills/IceRoad/Arts_UI/Atlas/Frames/ZD_Icon_Ice4_Skates01_png.ZD_Icon_Ice4_Skates01_png",
        [ESkillIconStatus.IconBtnActive] = "/Game/Library/Res/Skills/IceRoad/Arts_UI/Atlas/Frames/ZD_Icon_Ice4_Skates02_png.ZD_Icon_Ice4_Skates02_png"
      }
    }
  },
  [4100012] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 1}
      }
    }
  },
  [4201001] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 10}
      },
      [2] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 20}
      },
      [3] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_TickEnergyBySkill",
        Params = {
          nInitEnergy = 100,
          nMaxEnergy = 100,
          nDeletaEnergy = 1.5,
          nCastEnergyDelta = -1.5
        }
      }
    },
    SkillWidgetParams = {
      CDIndex = 1,
      ActiveCDIndex = 2,
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.Mod.Library.Client.Hero.TransformHeroSkillButton",
      MountData = {
        MountName = "CanvasPanel_SkillSlot",
        ModMountPanel = "ThemePropsChooseWidgetNew"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/FlowerWing/Arts/UI/Atlas/Frames/ZD_icon_FlowerWings_Item_png.ZD_icon_FlowerWings_Item_png"
      }
    }
  },
  [4201003] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 5}
      }
    },
    SkillWidgetParams = {
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.GameCore.Module.Skill.SkillUI.SkillUIWidgetTemplate",
      SkillNameTextID = 87055,
      MountData = {
        MountName = "CanvasPanel_SkillSlot2"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/FlowerWing/Arts/UI/Atlas/Frames/ZD_icon_Flap_Wings_png.ZD_icon_Flap_Wings_png"
      }
    }
  },
  [4201004] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 20}
      }
    },
    SkillWidgetParams = {
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.GameCore.Module.Skill.SkillUI.SkillUIWidgetTemplate",
      MountData = {
        MountName = "CanvasPanel_SkillSlot4"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/FlowerWing/Arts/UI/Atlas/Frames/ZD_icon_FiveConsecutive_Flashes_png.ZD_icon_FiveConsecutive_Flashes_png"
      }
    }
  },
  [4201005] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 10}
      }
    },
    SkillWidgetParams = {
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.GameCore.Module.Skill.SkillUI.SkillUIWidgetTemplate",
      SkillNameTextID = 87056,
      MountData = {
        MountName = "CanvasPanel_SkillSlot3"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/FlowerWing/Arts/UI/Atlas/Frames/ZD_icon_Fly_Down_png.ZD_icon_Fly_Down_png"
      }
    }
  },
  [4202005] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_CastEnergyWithCount",
        Params = {
          nInitEnergy = 10,
          nMaxEnergy = 10,
          nDeletaEnergy = 3,
          nMaxCount = 5,
          nInitCount = 5
        }
      },
      [2] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {bIgnoreCastSkillCheck = true, nCD = 1.5}
      }
    },
    SkillWidgetParams = {
      ActiveCDIndex = 2,
      UseCountIndex = 1,
      bShowUseCountCD = true,
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.GameCore.Module.Skill.SkillUI.SkillUIWidgetTemplate",
      MountData = {
        MountName = "CanvasPanel_SkillSlot",
        ModMountPanel = "ThemePropsChooseWidgetNew"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/VineHook/Arts/NoAltas/Icon_Pickup_Vine_256.Icon_Pickup_Vine_256"
      }
    }
  },
  [4202006] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 10}
      },
      [2] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {bIgnoreCastSkillCheck = true, nCD = 20.5}
      }
    },
    SkillWidgetParams = {
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDIndex = 1,
      ActiveCDIndex = 2,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.GameCore.Module.Skill.SkillUI.SkillUIWidgetTemplate",
      bOnlyShowWhenUse = true,
      MountData = {
        MountName = "CanvasPanel_SkillSlot",
        ModMountPanel = "ThemePropsChooseWidgetNew"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/VineHook/Arts/NoAltas/Icon_Pickup_Vine_256.Icon_Pickup_Vine_256"
      }
    }
  },
  [4202004] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_CastEnergyWithCount",
        Params = {
          nInitEnergy = 10,
          nMaxEnergy = 10,
          nDeletaEnergy = 1,
          nMaxCount = 2,
          nInitCount = 2
        }
      }
    },
    SkillWidgetParams = {
      UseCountIndex = 1,
      bShowUseCountCD = true,
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      WidgetPath = "/Game/Library/Res/Skills/NatureBow/Blueprint/UI/CommonSkillButton1_UIBP1.CommonSkillButton1_UIBP1",
      WidgetClass = "GameLua.ExtraModule.SkillCore.Gameplay.NatureBow.Skill.SkillUI.SelectArrowSkillUI",
      MountData = {
        MountName = "CanvasPanel_SkillSlot1"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/NatureBow/Arts/UI/Atlas/Frames/ZD_Icon_BowofNature01_png.ZD_Icon_BowofNature01_png",
        [ESkillIconStatus.IconBtnActive] = "/Game/Library/Res/Skills/NatureBow/Arts/UI/Atlas/Frames/ZD_Icon_BowofNature01_png.ZD_Icon_BowofNature01_png",
        [ESkillIconStatus.IconBtnInCD] = "/Game/Library/Res/Skills/NatureBow/Arts/UI/Atlas/Frames/ZD_Icon_BowofNature01_png.ZD_Icon_BowofNature01_png"
      }
    }
  },
  [4401001] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 30}
      }
    },
    SkillWidgetParams = {
      CDIndex = 1,
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.GameCore.Module.Skill.SkillUI.SkillUIWidgetTemplate",
      MountData = {
        MountName = "CanvasPanel_SkillSlot",
        ModMountPanel = "ThemePropsChooseWidgetNew"
      }
    }
  },
  [4401002] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_CastEnergyWithCount",
        Params = {
          nInitEnergy = 0,
          nMaxEnergy = 25,
          nDeletaEnergy = 1,
          nInitCount = 1,
          nMaxCount = 2
        }
      }
    },
    SkillWidgetParams = {
      CanvasVisibleConfigKey = "SkillBtnShowConfig2",
      CDIndex = 1,
      UseCountIndex = 1,
      bShowUseCountCD = true,
      CDType = SkillCDDefine.ECDType.CDT_Energy,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/Skills/LightningRush/BluePrints/UI/SkillButton/LightningRushSkillButton_UIBP.LightningRushSkillButton_UIBP",
      WidgetClass = "GameLua.ExtraModule.SkillCore.Client.LightningRush.LightningRushSkillButton",
      MountData = {
        MountName = "CanvasPanel_SkillSlot1"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/LightningRush/Arts/UI/Atlas/Frames/ZD_Icon_LightningRush_png.ZD_Icon_LightningRush_png"
      }
    }
  },
  [4401007] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_CastEnergyWithCount",
        Params = {
          nInitEnergy = 0,
          nMaxEnergy = 10,
          nDeletaEnergy = 1,
          nInitCount = 1,
          nMaxCount = 2
        }
      }
    },
    SkillWidgetParams = {
      CanvasVisibleConfigKey = "SkillBtnShowConfig2",
      CDIndex = 1,
      UseCountIndex = 1,
      bShowUseCountCD = true,
      CDType = SkillCDDefine.ECDType.CDT_Energy,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/Skills/LightningRush/BluePrints/UI/SkillButton/LightningRushSkillButton_UIBP.LightningRushSkillButton_UIBP",
      WidgetClass = "GameLua.ExtraModule.SkillCore.Client.LightningRush.LightningRushSkillButton",
      MountData = {
        MountName = "CanvasPanel_SkillSlot1"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/LightningRush/Arts/UI/Atlas/Frames/ZD_Icon_LightningRush_png.ZD_Icon_LightningRush_png"
      }
    }
  },
  [4401003] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 120}
      }
    },
    SkillWidgetParams = {
      CDIndex = 1,
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.GameCore.Module.Skill.SkillUI.SkillUIWidgetTemplate",
      MountData = {
        MountName = "CanvasPanel_SkillSlot",
        ModMountPanel = "ThemePropsChooseWidgetNew"
      }
    }
  },
  [4401004] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 0}
      }
    },
    SkillWidgetParams = {
      CDIndex = 1,
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.ExtraModule.SkillCore.Client.FlyingWing.FlyingWingJumpSkillButton",
      MountData = {
        MarginData = {
          Left = 6.0,
          Top = 6.0,
          Right = 6.0,
          Bottom = 6.0
        },
        AnchorsData = {
          Minimum = {0.0, 0.0},
          Maximum = {1.0, 1.0}
        },
        Alignment = {0.0, 0.0},
        MountName = "JumpVaultPanel",
        ModMountPanel = "JumpVaultBtn"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/FlyingWing/Arts/UI/Atlas/Frames/ZD_icon_Flap_jump_png.ZD_icon_Flap_jump_png",
        [ESkillIconStatus.IconBtnActive] = "/Game/Library/Res/Skills/FlyingWing/Arts/UI/Atlas/Frames/ZD_icon_Flap_jump_02_png.ZD_icon_Flap_jump_02_png"
      }
    }
  },
  [4401006] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 2}
      }
    },
    SkillWidgetParams = {
      CDIndex = 1,
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.GameCore.Module.Skill.SkillUI.SkillUIWidgetTemplate",
      MountData = {
        MountName = "CanvasPanel_SkillSlot",
        ModMountPanel = "ThemePropsChooseWidgetNew"
      }
    }
  },
  [1014300] = {
    SkillWidgetParams = {
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      ActiveCDIndex = 2,
      WidgetPath = "/Game/Library/Res/Skills/Goldenboots/BluePrints/UI/Skill_WorldCup_UIBP.Skill_WorldCup_UIBP",
      WidgetClass = "GameLua.ExtraModule.SkillCore.Client.Goldenboots.GoldenbootsSkillButton",
      MountData = {
        MarginData = {
          Left = 0.0,
          Top = 0.0,
          Right = 0.0,
          Bottom = 0.0
        },
        AnchorsData = {
          Minimum = {0.0, 0.0},
          Maximum = {1.0, 1.0}
        },
        Alignment = {0.0, 0.0},
        MountName = "CanvasPanel_Skill3"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/Goldenboots/Arts/Atlas/WorldCup/Frames/WorldCup_Skill_Icon_01_png.WorldCup_Skill_Icon_01_png"
      }
    },
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 6, nInitCD = 0}
      },
      [2] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 6, bIgnoreCastSkillCheck = true}
      },
      [3] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 1.3, bIgnoreCastSkillCheck = true}
      }
    }
  }
}
return Config