local SkillCDDefine = require("GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCDDefine")
local ESkillIconStatus = import("ESkillIconStatus")
local Config = {
  [1013461] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 3}
      }
    },
    SkillWidgetParams = {
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/Skills/WebShooters/Arts_PlayerBluePrints/UI/PMode_Zombie59_Silk_UIBP.PMode_Zombie59_Silk_UIBP",
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
      }
    }
  },
  [1013710] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 1}
      }
    },
    SkillWidgetParams = {
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Delete/tutuwzhang/BluePrints/UI/SoccerSkill_UIBP.SoccerSkill_UIBP",
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
        [ESkillIconStatus.IconBtnNormal] = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_SkillIcon0168_png.ZD_icon_SkillIcon0168_png",
        [ESkillIconStatus.IconBtnInCD] = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_SkillIcon0168_png.ZD_icon_SkillIcon0168_png",
        [ESkillIconStatus.IconBtnActive] = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_icon_SkillIcon0168_png.ZD_icon_SkillIcon0168_png"
      }
    }
  },
  [1014272] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 60}
      }
    }
  },
  [1014419] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 5}
      }
    }
  },
  [1014633] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 8}
      }
    }
  },
  [1014634] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 5}
      }
    }
  },
  [1018701] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 5}
      }
    }
  },
  [1014674] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 5}
      }
    }
  },
  [1014201] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 1}
      }
    },
    SkillWidgetParams = {
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.Mod.BaseMod.GamePlay.Weapon.UI.ShootingWeaponMeleeSkillButton",
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
        MountName = "SkillShootingWeaponMelee",
        ModMountPanel = "SkillShootingWeaponMeleeButtonSlot"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Arts/UI/Atlas/BattleUI/General_Ver2/Frames/ZD_icon_GarandBayonet_png.ZD_icon_GarandBayonet_png",
        [ESkillIconStatus.IconBtnDown] = "/Game/Arts/UI/Atlas/BattleUI/General_Ver2/Frames/ZD_icon_GarandBayonetSel_png.ZD_icon_GarandBayonetSel_png",
        [ESkillIconStatus.IconBtnUp] = "/Game/Arts/UI/Atlas/BattleUI/General_Ver2/Frames/ZD_icon_GarandBayonet_png.ZD_icon_GarandBayonet_png"
      }
    }
  },
  [4301100] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 15}
      }
    },
    SkillRandomType = {
      [1] = 15,
      [2] = 60,
      [3] = 25
    },
    SkillWidgetParams = {
      CDType = SkillCDDefine.ECDType.CDT_Timer,
      CDTypeStr = "%.f",
      bRefreshCDProcessAnticlockwise = false,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.Mod.Library.Client.UI.SkillButton.SpecialSuitSkillButton",
      MountData = {
        MountName = "CanvasPanel_SkillSlot1"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/InflatableSuit/Arts/Atlas/Frames/ZD_Icon_FartMan_png.ZD_Icon_FartMan_png",
        [ESkillIconStatus.IconBtnActive] = "/Game/Library/Res/Skills/InflatableSuit/Arts/Atlas/Frames/ZD_Icon_FartMan_png.ZD_Icon_FartMan_png",
        [ESkillIconStatus.IconBtnInCD] = "/Game/Library/Res/Skills/InflatableSuit/Arts/Atlas/Frames/ZD_Icon_FartMan_png.ZD_Icon_FartMan_png"
      }
    }
  },
  [4301101] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 10}
      }
    },
    SkillWidgetParams = {
      CDIndex = 1,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.GameCore.Module.Skill.SkillUI.SkillUIWidgetTemplate",
      MountData = {
        MountName = "CanvasPanel_SkillSlot",
        ModMountPanel = "ThemePropsChooseWidgetNew"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Skills/InflatableSuit/Arts/UI/Icon/ZD_Icon_FartMan_128.ZD_Icon_FartMan_128"
      }
    }
  },
  [4521100] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 10}
      }
    },
    SkillWidgetParams = {
      CDIndex = 1,
      WidgetPath = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillButton_UIBP.CommonSkillButton_UIBP",
      WidgetClass = "GameLua.GameCore.Module.Skill.SkillUI.SkillUIWidgetTemplate",
      MountData = {
        MountName = "CanvasPanel_SkillSlot",
        ModMountPanel = "ThemePropsChooseWidgetNew"
      },
      SkillIcon = {
        [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Hero/HeroSP/Arts/UI/NoAtlas/Icon_Spider_BattleSuit_128.Icon_Spider_BattleSuit_128"
      }
    }
  },
  [1016004] = {
    SkillCDParams = {
      [1] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_Time",
        Params = {nCD = 0.5}
      },
      [2] = {
        SkillCDClass = "GameLua.Mod.Library.GamePlay.Skill.SkillCD.SkillCD_CastEnergyWithCount",
        Params = {
          nDeletaEnergy = 1,
          nMaxEnergy = 2,
          nMaxCount = 5,
          nInitCount = 5
        }
      }
    }
  },
  SkillTemplateConfig = {
    [10012] = {
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
        WidgetPath = "/Game/Mod/EvoBase/BluePrints/Skill/SkillTemplate_BuildButton_UIBP.SkillTemplate_BuildButton_UIBP",
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
          MountName = "Border_BuildMVP",
          ModMountPanel = "SkillBuildMVPButtonSlot"
        },
        SkillIcon = {
          [ESkillIconStatus.IconBtnNormal] = "/Game/Mod/EvoBase/Atlas/Statue/Frames/EvoBase_icon_Statue_png.EvoBase_icon_Statue_png",
          [ESkillIconStatus.IconBtnInCD] = "/Game/Mod/EvoBase/Atlas/Statue/Frames/EvoBase_icon_Statue_png.EvoBase_icon_Statue_png",
          [ESkillIconStatus.IconBtnActive] = "/Game/Mod/EvoBase/Atlas/Statue/Frames/EvoBase_icon_Statue_png.EvoBase_icon_Statue_png"
        }
      }
    },
    [10013] = {
      SkillWidgetParams = {
        CanvasVisibleConfigKey = "SkillBtnShowConfig",
        CDType = SkillCDDefine.ECDType.CDT_Timer,
        CDTypeStr = "%.f",
        bRefreshCDProcessAnticlockwise = false,
        WidgetPath = "/Game/Library/Res/Actors/Shield/BluePrints/Skill_Shield_BuildButton_UIBP_New.Skill_Shield_BuildButton_UIBP_New",
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
          MountName = "Border_SkillShield",
          ModMountPanel = "SkillShieldButtonSlot"
        },
        SkillIcon = {
          [ESkillIconStatus.IconBtnNormal] = "/Game/Library/Res/Actors/Shield/NoAtals/Icon_Shield.Icon_Shield",
          [ESkillIconStatus.IconBtnInCD] = "/Game/Library/Res/Actors/Shield/NoAtals/Icon_Shield.Icon_Shield",
          [ESkillIconStatus.IconBtnActive] = "/Game/Library/Res/Actors/Shield/NoAtals/Icon_Shield.Icon_Shield"
        }
      }
    }
  }
}
return Config