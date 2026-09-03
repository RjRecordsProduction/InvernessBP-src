local UESTExtraVehicleType = import("ESTExtraVehicleType")
local VehicleSkillConfig = {
  [UESTExtraVehicleType.VT_TyrannosaurusRex] = {
    [1] = {
      [1] = {
        SkillDebugName = "\233\156\184\231\142\139\233\190\153\229\146\134\229\147\174",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Roar_png.ZD_Icon_Roar_png",
        SkillNameLocID = 48793,
        AntiFalseTouchTime = 1
      }
    },
    [2] = {
      [1] = {
        SkillDebugName = "\233\156\184\231\142\139\233\190\153\231\139\130\229\165\148",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Gllop_png.ZD_Icon_Gllop_png",
        SkillNameLocID = 48794,
        AntiFalseTouchTime = 1,
        SkillIconSize = FVector2D(62, 62)
      }
    }
  },
  [UESTExtraVehicleType.VT_RaptorDinosaur] = {
    [1] = {
      [1] = {
        SkillDebugName = "\232\191\133\231\140\155\233\190\153\232\183\179\232\183\131",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
        SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
        SkillNameLocID = 48790
      }
    }
  },
  [UESTExtraVehicleType.VT_Pterosaur] = {
    [1] = {
      [1] = {
        SkillDebugName = "\231\191\188\233\190\153\229\134\178\229\136\186",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Srint_png.ZD_Icon_Srint_png",
        SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Srint_png.ZD_Icon_Srint_png",
        SkillNameLocID = 49392
      }
    },
    [2] = {
      [1] = {
        SkillDebugName = "\231\191\188\233\190\153\230\138\147\228\186\186",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Image_Cursor_Promptst02_png.ZD_Image_Cursor_Promptst02_png",
        SkillNameLocID = 49391,
        bIsPassMouseEvent = true,
        SkillIconSize = FVector2D(94, 94)
      },
      [2] = {
        SkillDebugName = "\231\191\188\233\190\153\233\135\138\230\148\190",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Disengage_png.ZD_Icon_Disengage_png",
        SkillNameLocID = 49077
      },
      [3] = {
        SkillDebugName = "\231\191\188\233\190\153\230\140\163\232\132\177",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Disengage_png.ZD_Icon_Disengage_png",
        SkillNameLocID = 49078
      }
    }
  },
  [UESTExtraVehicleType.VT_Tiger] = {
    [1] = {
      [1] = {
        SkillDebugName = "\229\137\145\233\189\191\232\153\142\232\183\179\232\183\131",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/VehileControlPanel_New/Frames/ZD_Icon_Skill_Tiger_Pounce_png.ZD_Icon_Skill_Tiger_Pounce_png",
        SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/VehileControlPanel_New/Frames/ZD_Icon_Skill_Tiger_Pounce_png.ZD_Icon_Skill_Tiger_Pounce_png",
        SkillNameLocID = 6350031
      }
    },
    [2] = {
      [1] = {
        SkillDebugName = "\229\137\145\233\189\191\232\153\142\230\188\130\231\167\187\231\129\176\230\142\137",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skill_Tiger_Drift_02_png.ZD_Icon_Skill_Tiger_Drift_02_png",
        SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skill_Tiger_Drift_02_png.ZD_Icon_Skill_Tiger_Drift_02_png",
        SkillNameLocID = 6350029
      },
      [2] = {
        SkillDebugName = "\229\137\145\233\189\191\232\153\142\230\188\130\231\167\187\228\186\174\228\186\134",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skill_Tiger_Drift_02_png.ZD_Icon_Skill_Tiger_Drift_02_png",
        SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skill_Tiger_Drift_png.ZD_Icon_Skill_Tiger_Drift_png",
        SkillNameLocID = 6350029
      },
      [3] = {
        SkillDebugName = "\229\137\145\233\189\191\232\153\142\230\188\130\231\167\187\228\184\173",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skill_Tiger_Drift_png.ZD_Icon_Skill_Tiger_Drift_png",
        SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skill_Tiger_Drift_png.ZD_Icon_Skill_Tiger_Drift_png",
        SkillNameLocID = 6350029
      }
    },
    [3] = {
      [1] = {
        SkillDebugName = "\229\137\145\233\189\191\232\153\142\232\135\170\229\138\168\229\137\141\232\191\155",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skill_Tiger_Run_02_png.ZD_Icon_Skill_Tiger_Run_02_png",
        SkillNameLocID = 6350028
      },
      [2] = {
        SkillDebugName = "\229\137\145\233\189\191\232\153\142\229\129\156\230\173\162\232\135\170\229\138\168\229\137\141\232\191\155",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skill_Tiger_Run_png.ZD_Icon_Skill_Tiger_Run_png",
        SkillNameLocID = 6350028
      }
    },
    [4] = {
      [1] = {
        SkillDebugName = "\229\137\145\233\189\191\232\153\142\233\170\145\229\176\132\232\191\148\229\155\158",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
        SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
        SkillNameLocID = 69817
      }
    }
  },
  [UESTExtraVehicleType.VT_RubberDuck] = {
    [1] = {
      [1] = {
        SkillDebugName = "\229\176\143\233\187\132\233\184\173\233\147\190\230\142\165",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_png.ZD_Icon_Link_png",
        SkillNameLocID = 49995
      },
      [2] = {
        SkillDebugName = "\229\176\143\233\187\132\233\184\173\230\150\173\229\188\128\233\147\190\230\142\165",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Separate_png.ZD_Icon_Separate_png",
        SkillNameLocID = 49996
      },
      [3] = {
        SkillDebugName = "\229\176\143\233\187\132\233\184\173\232\191\158\230\142\165\228\184\173",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Separate_png.ZD_Icon_Separate_png",
        SkillIconColor = FLinearColor(1, 1, 1, 0.5)
      }
    },
    [2] = {
      [1] = {
        SkillDebugName = "\229\176\143\233\187\132\233\184\173\230\140\170\229\136\176\229\137\141\232\189\166",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png",
        SkillNameLocID = 49997
      }
    }
  },
  [UESTExtraVehicleType.VT_CapsuleVehicle] = {
    [1] = {
      [1] = {
        SkillDebugName = "\232\131\182\229\155\138\232\189\189\229\133\183\230\176\174\230\176\148",
        SkillNormalIconPath = "/Game/Mod/PlanDB/Arts/UI/Atlas/Frames/ZD_Icon_Jet_png.ZD_Icon_Jet_png",
        AntiFalseTouchTime = 1
      }
    }
  },
  [UESTExtraVehicleType.VT_Horse] = {
    [1] = {
      [1] = {
        SkillDebugName = "\233\169\172\229\140\185\232\183\159\233\154\143",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Follow_png.ZD_Icon_Follow_png",
        SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Follow_png.ZD_Icon_Follow_png",
        SkillNameLocID = 69812
      },
      [2] = {
        SkillDebugName = "\229\143\150\230\182\136\233\169\172\229\140\185\232\183\159\233\154\143",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Follow02_png.ZD_Icon_Follow02_png",
        SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Follow02_png.ZD_Icon_Follow02_png",
        SkillNameLocID = 69813
      }
    }
  },
  [UESTExtraVehicleType.VT_WarHorse] = {
    [1] = {
      [1] = {
        SkillDebugName = "\233\169\172\229\140\185\232\183\159\233\154\143",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Follow_png.ZD_Icon_Follow_png",
        SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Follow_png.ZD_Icon_Follow_png",
        SkillNameLocID = 69812
      },
      [2] = {
        SkillDebugName = "\229\143\150\230\182\136\233\169\172\229\140\185\232\183\159\233\154\143",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Follow02_png.ZD_Icon_Follow02_png",
        SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Follow02_png.ZD_Icon_Follow02_png",
        SkillNameLocID = 69813
      }
    }
  },
  [UESTExtraVehicleType.VT_HorseLiquid] = {
    [1] = {
      [1] = {
        SkillDebugName = "\230\175\146\230\182\178\233\169\172-\232\191\145\230\136\152\230\148\187\229\135\187",
        SkillNormalIconPath = "/Game/Mod/Hw4Liquid/Arts/UI/Atlas/Frames/ZD_Icon_Attack_png.ZD_Icon_Attack_png",
        SkillHighLightIconPath = "/Game/Mod/Hw4Liquid/Arts/UI/Atlas/Frames/ZD_Icon_Attack_png.ZD_Icon_Attack_png",
        SkillNameLocID = 18775
      }
    },
    [2] = {
      [1] = {
        SkillDebugName = "\230\175\146\230\182\178\233\169\172-\232\191\156\231\168\139\230\148\187\229\135\187",
        SkillNormalIconPath = "/Game/Mod/Hw4Liquid/Arts/UI/Atlas/Frames/ZD_Icon_Throwing_png.ZD_Icon_Throwing_png",
        SkillHighLightIconPath = "/Game/Mod/Hw4Liquid/Arts/UI/Atlas/Frames/ZD_Icon_Throwing_png.ZD_Icon_Throwing_png",
        SkillNameLocID = 18373,
        bIsPassMouseEvent = true
      }
    }
  },
  [UESTExtraVehicleType.VT_SnowBall] = {
    [1] = {
      [1] = {
        SkillDebugName = "\233\155\170\231\144\131\232\189\166-\232\183\179\232\183\131",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/Snowball_Icon_Jump_png.Snowball_Icon_Jump_png",
        SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/Snowball_Icon_Jump_png.Snowball_Icon_Jump_png",
        SkillNameLocID = 48790
      }
    },
    [2] = {
      [1] = {
        SkillDebugName = "\233\155\170\231\144\131\232\189\166-\229\138\160\233\128\159",
        SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/Snowball_Icon_Accelerate_png.Snowball_Icon_Accelerate_png",
        SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/NewAtlas/Frames/Snowball_Icon_Accelerate_png.Snowball_Icon_Accelerate_png",
        SkillNameLocID = 9161
      }
    },
    [3] = {
      [1] = {
        SkillDebugName = "\233\155\170\231\144\131\232\189\166-\232\132\177\229\155\176",
        SkillNormalIconPath = "/Game/Mod/PlanPH/Arts/Atlas/PlanPH_Redact_Atlas/Frames/ZD_Icon_Offline_png.ZD_Icon_Offline_png",
        SkillHighLightIconPath = "/Game/Mod/PlanPH/Arts/Atlas/PlanPH_Redact_Atlas/Frames/ZD_Icon_Offline_png.ZD_Icon_Offline_png",
        SkillNameLocID = 655368
      }
    }
  },
  [UESTExtraVehicleType.VT_Panda] = {
    [1] = {
      [1] = {
        SkillDebugName = "\231\134\138\231\140\171\229\143\152\231\144\131",
        SkillNormalIconPath = "/Game/Library/Res/Vehicles/Panda/Arts/UI/Atlas/Frames/ZD_Icon_Rolling_png.ZD_Icon_Rolling_png",
        SkillHighLightIconPath = "/Game/Library/Res/Vehicles/Panda/Arts/UI/Atlas/Frames/ZD_Icon_Rolling_02_png.ZD_Icon_Rolling_02_png",
        SkillNameLocID = 76679
      },
      [2] = {
        SkillDebugName = "\231\144\131\229\143\152\231\134\138\231\140\171",
        SkillNormalIconPath = "/Game/Library/Res/Vehicles/Panda/Arts/UI/Atlas/Frames/ZD_Icon_Panda_png.ZD_Icon_Panda_png",
        SkillHighLightIconPath = "/Game/Library/Res/Vehicles/Panda/Arts/UI/Atlas/Frames/ZD_Icon_Panda_02_png.ZD_Icon_Panda_02_png",
        SkillNameLocID = 76680
      }
    },
    [2] = {
      [1] = {
        SkillDebugName = "\231\134\138\231\140\171\232\183\179\232\183\131",
        SkillNormalIconPath = "/Game/Library/Res/Vehicles/Panda/Arts/UI/Atlas/Frames/ZD_Icon_Panda_Jump_png.ZD_Icon_Panda_Jump_png",
        SkillHighLightIconPath = "/Game/Library/Res/Vehicles/Panda/Arts/UI/Atlas/Frames/ZD_Icon_Panda_Jump_png.ZD_Icon_Panda_Jump_png",
        SkillNameLocID = 6350031
      }
    }
  },
  [UESTExtraVehicleType.VT_Camel] = {
    [1] = {
      [1] = {
        SkillDebugName = "\233\170\134\233\169\188\232\183\159\233\154\143",
        SkillNormalIconPath = "/Game/Library/Res/Vehicles/Camel/Arts/UI/Atlas/Frames/Camel_Icon_Follow_png.Camel_Icon_Follow_png",
        SkillHighLightIconPath = "/Game/Library/Res/Vehicles/Camel/Arts/UI/Atlas/Frames/Camel_Icon_Follow_Activate_png.Camel_Icon_Follow_Activate_png",
        SkillNameLocID = 76997
      },
      [2] = {
        SkillDebugName = "\229\143\150\230\182\136\233\170\134\233\169\188\232\183\159\233\154\143",
        SkillNormalIconPath = "/Game/Library/Res/Vehicles/Camel/Arts/UI/Atlas/Frames/Camel_Icon_Follow_Activate_png.Camel_Icon_Follow_Activate_png",
        SkillHighLightIconPath = "/Game/Library/Res/Vehicles/Camel/Arts/UI/Atlas/Frames/Camel_Icon_Follow_Activate_png.Camel_Icon_Follow_Activate_png",
        SkillNameLocID = 69813
      }
    }
  },
  [UESTExtraVehicleType.VT_Broom] = {
    [1] = {
      [1] = {
        SkillDebugName = "\230\137\171\229\184\154\232\147\132\229\138\155\230\145\134\229\176\190",
        SkillNormalIconPath = "/Game/Library/Res/Vehicles/Broom/Arts/UI/Atlas/Frames/ZD_Icon_Drifting_01_png.ZD_Icon_Drifting_01_png",
        SkillHighLightIconPath = "/Game/Library/Res/Vehicles/Broom/Arts/UI/Atlas/Frames/ZD_Icon_Drifting_png.ZD_Icon_Drifting_png",
        SkillNameLocID = 86397,
        bIsPassMouseEvent = true
      }
    }
  }
}
return VehicleSkillConfig