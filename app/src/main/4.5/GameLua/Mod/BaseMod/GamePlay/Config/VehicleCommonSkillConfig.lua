local UESTExtraVehicleType = import("ESTExtraVehicleType")
local VehicleSkillState = {
  Default = 0,
  Active = 1,
  CoolDown = 2,
  Disable = 3
}
local VehicleCommonSkillConfig = {
  [UESTExtraVehicleType.VT_ReindeerBio] = {
    [11701] = {
      UIConfig = {
        SkillDebugName = "\233\169\175\233\185\191\232\189\166\232\183\179\232\183\131",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Jump",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 48790,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Fawn_Jump_png.ZD_Icon_Fawn_Jump_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Fawn_Jump_02_png.ZD_Icon_Fawn_Jump_02_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 48790,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Fawn_Jump_png.ZD_Icon_Fawn_Jump_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Fawn_Jump_02_png.ZD_Icon_Fawn_Jump_02_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 48790,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Fawn_Jump_png.ZD_Icon_Fawn_Jump_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Fawn_Jump_02_png.ZD_Icon_Fawn_Jump_02_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 48790,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Fawn_Jump_png.ZD_Icon_Fawn_Jump_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Fawn_Jump_02_png.ZD_Icon_Fawn_Jump_02_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    },
    [11702] = {
      UIConfig = {
        SkillDebugName = "\233\169\175\233\185\191\232\189\166\233\147\190\230\142\165",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Link",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 49995,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_png.ZD_Icon_Link_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_02_png.ZD_Icon_Link_02_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 49995,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_png.ZD_Icon_Link_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_02_png.ZD_Icon_Link_02_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 49995,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_png.ZD_Icon_Link_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_02_png.ZD_Icon_Link_02_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 49995,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_png.ZD_Icon_Link_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_02_png.ZD_Icon_Link_02_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    },
    [11703] = {
      UIConfig = {
        SkillDebugName = "\233\169\175\233\185\191\232\189\166\230\141\162\229\186\167\228\189\141",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_MovePre",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 49997,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 49997,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 49997,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 49997,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    }
  },
  [UESTExtraVehicleType.VT_ReindeerCart] = {
    [11702] = {
      UIConfig = {
        SkillDebugName = "\233\169\175\233\185\191\232\189\166\233\147\190\230\142\165",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Link",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 49995,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_png.ZD_Icon_Link_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_02_png.ZD_Icon_Link_02_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 49995,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_png.ZD_Icon_Link_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_02_png.ZD_Icon_Link_02_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 49995,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_png.ZD_Icon_Link_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_02_png.ZD_Icon_Link_02_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 49995,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_png.ZD_Icon_Link_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Link_02_png.ZD_Icon_Link_02_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    },
    [11703] = {
      UIConfig = {
        SkillDebugName = "\233\169\175\233\185\191\232\189\166\230\141\162\229\186\167\228\189\141",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_MovePre",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 49997,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 49997,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 49997,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 49997,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Change_Seat_png.ZD_Icon_Change_Seat_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    }
  },
  [UESTExtraVehicleType.VT_Snowboard] = {
    [5001] = {
      UIConfig = {
        SkillDebugName = "\230\187\145\233\155\170\230\157\191\232\183\179\232\183\131",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Jump",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 48790,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skateboard_03_png.ZD_Icon_Skateboard_03_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skateboard_04_png.ZD_Icon_Skateboard_04_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 48790,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skateboard_03_png.ZD_Icon_Skateboard_03_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skateboard_04_png.ZD_Icon_Skateboard_04_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 48790,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skateboard_03_png.ZD_Icon_Skateboard_03_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skateboard_04_png.ZD_Icon_Skateboard_04_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 48790,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skateboard_03_png.ZD_Icon_Skateboard_03_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Skateboard_04_png.ZD_Icon_Skateboard_04_png"
        }
      },
      BigJumpUIConfig = {
        SkillDebugName = "\230\187\145\233\155\170\230\157\191\232\183\179\232\183\131",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Jump",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 48790,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Platform_png.ZD_Icon_Platform_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Platform_02_png.ZD_Icon_Platform_02_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 48790,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Platform_png.ZD_Icon_Platform_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Platform_02_png.ZD_Icon_Platform_02_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 48790,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Platform_png.ZD_Icon_Platform_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Platform_02_png.ZD_Icon_Platform_02_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 48790,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Platform_png.ZD_Icon_Platform_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Platform_02_png.ZD_Icon_Platform_02_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    }
  },
  [UESTExtraVehicleType.VT_Bike_Valentine] = {
    [10901] = {
      UIConfig = {
        SkillDebugName = "\230\191\128\230\180\187\230\131\133\228\186\186\232\138\130\231\137\185\230\149\136",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_ShowEffect",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNormalIconPath = "/Game/Mod/ValentinesDay/Arts/UI/Atlas/Frames/ZD_Icon_ValentineDay_Effects_png.ZD_Icon_ValentineDay_Effects_png",
          SkillHighLightIconPath = "/Game/Mod/ValentinesDay/Arts/UI/Atlas/Frames/ZD_Icon_ValentineDay_Effects_png.ZD_Icon_ValentineDay_Effects_png",
          SkillIconSize = FVector2D(40, 40),
          HideDefaultBgImage = true
        },
        [VehicleSkillState.Active] = {
          SkillNormalIconPath = "/Game/Mod/ValentinesDay/Arts/UI/Atlas/Frames/ZD_Icon_ValentineDay_Effects_png.ZD_Icon_ValentineDay_Effects_png",
          SkillHighLightIconPath = "/Game/Mod/ValentinesDay/Arts/UI/Atlas/Frames/ZD_Icon_ValentineDay_Effects_png.ZD_Icon_ValentineDay_Effects_png",
          SkillIconSize = FVector2D(40, 40),
          HideDefaultBgImage = true
        },
        [VehicleSkillState.CoolDown] = {
          SkillNormalIconPath = "/Game/Mod/ValentinesDay/Arts/UI/Atlas/Frames/ZD_Icon_ValentineDay_Effects_png.ZD_Icon_ValentineDay_Effects_png",
          SkillHighLightIconPath = "/Game/Mod/ValentinesDay/Arts/UI/Atlas/Frames/ZD_Icon_ValentineDay_Effects_png.ZD_Icon_ValentineDay_Effects_png",
          SkillIconSize = FVector2D(40, 40),
          HideDefaultBgImage = true
        },
        [VehicleSkillState.Disable] = {
          SkillNormalIconPath = "/Game/Mod/ValentinesDay/Arts/UI/Atlas/Frames/ZD_Icon_ValentineDay_Effects_png.ZD_Icon_ValentineDay_Effects_png",
          SkillHighLightIconPath = "/Game/Mod/ValentinesDay/Arts/UI/Atlas/Frames/ZD_Icon_ValentineDay_Effects_png.ZD_Icon_ValentineDay_Effects_png",
          SkillIconSize = FVector2D(40, 40),
          HideDefaultBgImage = true
        }
      },
      CoolDownTime = 10,
      DurationTime = 0
    }
  },
  [UESTExtraVehicleType.VT_OceanVehicle] = {
    [13001] = {
      UIConfig = {
        SkillDebugName = "\229\143\145\229\176\132\230\176\180\230\179\161",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Pao",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNormalIconPath = "/Game/Library/Res/Weapons/BubbleLauncher/Art/UI/Atlas/Frames/ZD_Icon_Water_Polo_png.ZD_Icon_Water_Polo_png",
          SkillHighLightIconPath = "/Game/Library/Res/Weapons/BubbleLauncher/Art/UI/Atlas/Frames/ZD_Icon_Water_Polo_png.ZD_Icon_Water_Polo_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Active] = {
          SkillNormalIconPath = "/Game/Library/Res/Weapons/BubbleLauncher/Art/UI/Atlas/Frames/ZD_Icon_Water_Polo_png.ZD_Icon_Water_Polo_png",
          SkillHighLightIconPath = "/Game/Library/Res/Weapons/BubbleLauncher/Art/UI/Atlas/Frames/ZD_Icon_Water_Polo_png.ZD_Icon_Water_Polo_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.CoolDown] = {
          SkillNormalIconPath = "/Game/Library/Res/Weapons/BubbleLauncher/Art/UI/Atlas/Frames/ZD_Icon_Water_Polo_png.ZD_Icon_Water_Polo_png",
          SkillHighLightIconPath = "/Game/Library/Res/Weapons/BubbleLauncher/Art/UI/Atlas/Frames/ZD_Icon_Water_Polo_png.ZD_Icon_Water_Polo_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Disable] = {
          SkillNormalIconPath = "/Game/Library/Res/Weapons/BubbleLauncher/Art/UI/Atlas/Frames/ZD_Icon_Water_Polo_png.ZD_Icon_Water_Polo_png",
          SkillHighLightIconPath = "/Game/Library/Res/Weapons/BubbleLauncher/Art/UI/Atlas/Frames/ZD_Icon_Water_Polo_png.ZD_Icon_Water_Polo_png",
          SkillIconSize = FVector2D(68, 68)
        }
      },
      CoolDownTime = 7,
      DurationTime = 0
    }
  },
  [UESTExtraVehicleType.VT_BlanketVehicle] = {
    [12001] = {
      UIConfig = {
        SkillDebugName = "\233\163\158\230\175\175\229\134\178\229\136\186",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Dive",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 48791,
          SkillNormalIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_Sprint_png.ZD_Icon_Sprint_png",
          SkillHighLightIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_Select_Sprint_png.ZD_Icon_Select_Sprint_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 48791,
          SkillNormalIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_Sprint_png.ZD_Icon_Sprint_png",
          SkillHighLightIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_Select_Sprint_png.ZD_Icon_Select_Sprint_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 48791,
          SkillNormalIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_Sprint_png.ZD_Icon_Sprint_png",
          SkillHighLightIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_Select_Sprint_png.ZD_Icon_Select_Sprint_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 48791,
          SkillNormalIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_Sprint_png.ZD_Icon_Sprint_png",
          SkillHighLightIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_Select_Sprint_png.ZD_Icon_Select_Sprint_png",
          SkillIconSize = FVector2D(68, 68)
        }
      },
      CoolDownTime = 8,
      DurationTime = 0
    },
    [12002] = {
      UIConfig = {
        SkillDebugName = "\233\163\158\230\175\175\229\136\135\230\141\162\233\163\158\232\161\140",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Switch",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 9834,
          SkillNormalIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_HandOff_png.ZD_Icon_HandOff_png",
          SkillHighLightIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_Select_HandOff_png.ZD_Icon_Select_HandOff_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 9834,
          SkillNormalIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_HandOff_png.ZD_Icon_HandOff_png",
          SkillHighLightIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_Select_HandOff_png.ZD_Icon_Select_HandOff_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 9834,
          SkillNormalIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_HandOff_png.ZD_Icon_HandOff_png",
          SkillHighLightIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_Select_HandOff_png.ZD_Icon_Select_HandOff_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 9834,
          SkillNormalIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_HandOff_png.ZD_Icon_HandOff_png",
          SkillHighLightIconPath = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_Select_HandOff_png.ZD_Icon_Select_HandOff_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    }
  },
  [UESTExtraVehicleType.VT_Horse] = {
    [14001] = {
      UIConfig = {
        SkillDebugName = "\233\169\172\229\140\185-\232\183\179\232\183\131",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Jump",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 69815,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 69815,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 69815,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 69815,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    },
    [14002] = {
      UIConfig = {
        SkillDebugName = "\233\169\172\229\140\185-\229\150\130\233\163\159",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Feed",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 69814,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 69814,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 69814,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 69814,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    },
    [14003] = {
      UIConfig = {
        SkillDebugName = "\233\169\172\229\140\185-\232\191\148\229\155\158\233\170\145\229\176\132",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_ReturnBack",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    }
  },
  [UESTExtraVehicleType.VT_Panda] = {
    [14003] = {
      UIConfig = {
        SkillDebugName = "\231\134\138\231\140\171-\232\191\148\229\155\158\233\170\145\229\176\132",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_ReturnBack",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    }
  },
  [UESTExtraVehicleType.VT_WarHorse] = {
    [14001] = {
      UIConfig = {
        SkillDebugName = "\233\169\172\229\140\185-\232\183\179\232\183\131",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Jump",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 69815,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 69815,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 69815,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 69815,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Horse_Jump_png.ZD_Icon_Horse_Jump_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    },
    [14002] = {
      UIConfig = {
        SkillDebugName = "\233\169\172\229\140\185-\229\150\130\233\163\159",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Feed",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 69814,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 69814,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 69814,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 69814,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Feeding_png.ZD_Icon_Feeding_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    },
    [14003] = {
      UIConfig = {
        SkillDebugName = "\233\169\172\229\140\185-\232\191\148\229\155\158\233\170\145\229\176\132",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_ReturnBack",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    }
  },
  [UESTExtraVehicleType.VT_HorseLiquid] = {
    [15001] = {
      UIConfig = {
        SkillDebugName = "\230\175\146\230\182\178\233\169\172-\232\183\179\232\183\131",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Jump",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 69815,
          SkillNormalIconPath = "/Game/Mod/Hw4Liquid/Arts/UI/Atlas/Frames/ZD_Icon_Horse_png.ZD_Icon_Horse_png",
          SkillHighLightIconPath = "/Game/Mod/Hw4Liquid/Arts/UI/Atlas/Frames/ZD_Icon_Horse_png.ZD_Icon_Horse_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 69815,
          SkillNormalIconPath = "/Game/Mod/Hw4Liquid/Arts/UI/Atlas/Frames/ZD_Icon_Horse_png.ZD_Icon_Horse_png",
          SkillHighLightIconPath = "/Game/Mod/Hw4Liquid/Arts/UI/Atlas/Frames/ZD_Icon_Horse_png.ZD_Icon_Horse_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 69815,
          SkillNormalIconPath = "/Game/Mod/Hw4Liquid/Arts/UI/Atlas/Frames/ZD_Icon_Horse_png.ZD_Icon_Horse_png",
          SkillHighLightIconPath = "/Game/Mod/Hw4Liquid/Arts/UI/Atlas/Frames/ZD_Icon_Horse_png.ZD_Icon_Horse_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 69815,
          SkillNormalIconPath = "/Game/Mod/Hw4Liquid/Arts/UI/Atlas/Frames/ZD_Icon_Horse_png.ZD_Icon_Horse_png",
          SkillHighLightIconPath = "/Game/Mod/Hw4Liquid/Arts/UI/Atlas/Frames/ZD_Icon_Horse_png.ZD_Icon_Horse_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    }
  },
  [UESTExtraVehicleType.VT_Mammoth] = {
    [13101] = {
      UIConfig = {
        SkillDebugName = "\231\140\155\231\138\184\232\177\161-\232\183\179\232\136\158",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Feed",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 6350035,
          SkillNormalIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Elephant_Dance_png.Setting_Icon_Elephant_Dance_png",
          SkillHighLightIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Elephant_Dance_png.Setting_Icon_Elephant_Dance_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 6350035,
          SkillNormalIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Elephant_Dance_png.Setting_Icon_Elephant_Dance_png",
          SkillHighLightIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Elephant_Dance_png.Setting_Icon_Elephant_Dance_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 6350035,
          SkillNormalIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Elephant_Dance_png.Setting_Icon_Elephant_Dance_png",
          SkillHighLightIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Elephant_Dance_png.Setting_Icon_Elephant_Dance_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 6350035,
          SkillNormalIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Elephant_Dance_png.Setting_Icon_Elephant_Dance_png",
          SkillHighLightIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_Icon_Elephant_Dance_png.Setting_Icon_Elephant_Dance_png",
          SkillIconSize = FVector2D(68, 68)
        }
      },
      CoolDownTime = 5,
      DurationTime = 0
    }
  },
  [UESTExtraVehicleType.VT_Camel] = {
    [13701] = {
      UIConfig = {
        SkillDebugName = "\233\170\134\233\169\188-\232\183\179\232\183\131",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Jump",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 6350031,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/Camel/Arts/UI/Atlas/Frames/Camel_Icon_Jumping_png.Camel_Icon_Jumping_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/Camel/Arts/UI/Atlas/Frames/Camel_Icon_Jumping_png.Camel_Icon_Jumping_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 6350031,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/Camel/Arts/UI/Atlas/Frames/Camel_Icon_Jumping_png.Camel_Icon_Jumping_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/Camel/Arts/UI/Atlas/Frames/Camel_Icon_Jumping_png.Camel_Icon_Jumping_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 6350031,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/Camel/Arts/UI/Atlas/Frames/Camel_Icon_Jumping_png.Camel_Icon_Jumping_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/Camel/Arts/UI/Atlas/Frames/Camel_Icon_Jumping_png.Camel_Icon_Jumping_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 6350031,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/Camel/Arts/UI/Atlas/Frames/Camel_Icon_Jumping_png.Camel_Icon_Jumping_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/Camel/Arts/UI/Atlas/Frames/Camel_Icon_Jumping_png.Camel_Icon_Jumping_png",
          SkillIconSize = FVector2D(68, 68)
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    },
    [14003] = {
      UIConfig = {
        SkillDebugName = "\233\170\134\233\169\188-\232\191\148\229\155\158\233\170\145\229\176\132",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_ReturnBack",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 69817,
          SkillNormalIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png",
          SkillHighLightIconPath = "/Game/Arts/UI/Atlas/BattleUI/VehileControlPanel/Frames/ZD_Icon_Shoot_png.ZD_Icon_Shoot_png"
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    }
  },
  [UESTExtraVehicleType.VT_Titan] = {
    [3800009] = {
      UIConfig = {
        SkillDebugName = "\229\183\168\228\186\186-\233\135\141\230\148\187\229\135\187",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_HeavyAttack",
        bIsPassMouseEvent = true,
        [VehicleSkillState.Default] = {
          SkillNormalIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_icon_Whack_png.Setting_icon_Whack_png",
          SkillHighLightIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_icon_Whack_png.Setting_icon_Whack_png"
        },
        [VehicleSkillState.Active] = {
          SkillNormalIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_icon_Whack_png.Setting_icon_Whack_png",
          SkillHighLightIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_icon_Whack_png.Setting_icon_Whack_png"
        },
        [VehicleSkillState.CoolDown] = {
          SkillNormalIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_icon_Whack_png.Setting_icon_Whack_png",
          SkillHighLightIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_icon_Whack_png.Setting_icon_Whack_png"
        },
        [VehicleSkillState.Disable] = {
          SkillNormalIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_icon_Whack_png.Setting_icon_Whack_png",
          SkillHighLightIconPath = "/Game/UMG/Texture_200/Atlas/SettingUI/Frames/Setting_icon_Whack_png.Setting_icon_Whack_png"
        }
      },
      CoolDownTime = 1.5,
      DurationTime = 0
    }
  },
  [UESTExtraVehicleType.VT_Optimus] = {
    [14201] = {
      UIConfig = {
        SkillDebugName = "\229\143\152\229\189\162\233\135\145\229\136\154-\232\183\179\232\183\131",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Jump",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 6350031,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 6350031,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 6350031,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 6350031,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillIconSize = FVector2D(68, 68)
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    },
    [3900002] = {
      UIConfig = {
        SkillDebugName = "TF \229\134\178\233\148\139\231\160\184\229\135\187",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Rush",
        bIsPassMouseEvent = true,
        [VehicleSkillState.Default] = {
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Smash_png.ZD_Icon_Smash_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Smash_png.ZD_Icon_Smash_png",
          SkillIconSize = FVector2D(68, 68),
          SkillIconColor = FLinearColor(1, 1, 1, 1),
          bCollapseStopIcon = true
        },
        [VehicleSkillState.Active] = {
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Smash_png.ZD_Icon_Smash_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Smash_png.ZD_Icon_Smash_png",
          SkillIconSize = FVector2D(68, 68),
          SkillIconColor = FLinearColor(1, 1, 1, 1),
          bCollapseStopIcon = true
        },
        [VehicleSkillState.CoolDown] = {
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Smash_png.ZD_Icon_Smash_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Smash_png.ZD_Icon_Smash_png",
          SkillIconColor = FLinearColor(1, 1, 1, 1),
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Disable] = {
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Smash_03_png.ZD_Icon_Smash_03_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Smash_03_png.ZD_Icon_Smash_03_png",
          SkillIconSize = FVector2D(68, 68),
          SkillIconAlpha = 0.7
        }
      },
      CoolDownTime = 15,
      DurationTime = 2.5
    }
  },
  [UESTExtraVehicleType.VT_Megatron] = {
    [14201] = {
      UIConfig = {
        SkillDebugName = "\229\143\152\229\189\162\233\135\145\229\136\154-\232\183\179\232\183\131",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Jump",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 6350031,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_02_png.ZD_Icon_Jump_02_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_02_png.ZD_Icon_Jump_02_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 6350031,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_02_png.ZD_Icon_Jump_02_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_02_png.ZD_Icon_Jump_02_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 6350031,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_02_png.ZD_Icon_Jump_02_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_02_png.ZD_Icon_Jump_02_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 6350031,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_02_png.ZD_Icon_Jump_02_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_02_png.ZD_Icon_Jump_02_png",
          SkillIconSize = FVector2D(68, 68)
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    },
    [3900005] = {
      UIConfig = {
        SkillDebugName = "\231\148\181\231\163\129\231\130\174",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Cannon",
        bIsPassMouseEvent = true,
        [VehicleSkillState.Default] = {
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Hand_Cannons_png.ZD_Icon_Hand_Cannons_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Hand_Cannons_png.ZD_Icon_Hand_Cannons_png",
          SkillIconSize = FVector2D(68, 68),
          SkillIconColor = FLinearColor(1, 1, 1, 1)
        },
        [VehicleSkillState.Active] = {
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Hand_Cannons_png.ZD_Icon_Hand_Cannons_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Hand_Cannons_png.ZD_Icon_Hand_Cannons_png",
          SkillIconSize = FVector2D(68, 68),
          SkillIconColor = FLinearColor(1, 1, 1, 1),
          bCollapseStopIcon = true
        },
        [VehicleSkillState.CoolDown] = {
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Hand_Cannons_png.ZD_Icon_Hand_Cannons_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Hand_Cannons_png.ZD_Icon_Hand_Cannons_png",
          SkillIconSize = FVector2D(68, 68),
          SkillIconColor = FLinearColor(1, 1, 1, 1)
        },
        [VehicleSkillState.Disable] = {
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Hand_Cannons_02_png.ZD_Icon_Hand_Cannons_02_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Hand_Cannons_02_png.ZD_Icon_Hand_Cannons_02_png",
          SkillIconSize = FVector2D(68, 68),
          SkillIconAlpha = 0.7
        }
      },
      CoolDownTime = 13,
      DurationTime = 0
    }
  },
  [UESTExtraVehicleType.VT_Broom] = {
    [13801] = {
      UIConfig = {
        SkillDebugName = "\230\137\171\229\184\154\229\138\160\233\128\159",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_Sprint",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 86039,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/Broom/Arts/UI/Atlas/Frames/ZD_Icon_Accelerate_01_png.ZD_Icon_Accelerate_01_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/Broom/Arts/UI/Atlas/Frames/ZD_Icon_Accelerate_png.ZD_Icon_Accelerate_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 86039,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/Broom/Arts/UI/Atlas/Frames/ZD_Icon_Accelerate_png.ZD_Icon_Accelerate_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/Broom/Arts/UI/Atlas/Frames/ZD_Icon_Accelerate_png.ZD_Icon_Accelerate_png",
          SkillIconSize = FVector2D(68, 68),
          bCollapseStopIcon = true
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 86039,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/Broom/Arts/UI/Atlas/Frames/ZD_Icon_Accelerate_01_png.ZD_Icon_Accelerate_01_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/Broom/Arts/UI/Atlas/Frames/ZD_Icon_Accelerate_png.ZD_Icon_Accelerate_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 86039,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/Broom/Arts/UI/Atlas/Frames/ZD_Icon_Accelerate_01_png.ZD_Icon_Accelerate_01_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/Broom/Arts/UI/Atlas/Frames/ZD_Icon_Accelerate_png.ZD_Icon_Accelerate_png",
          SkillIconSize = FVector2D(68, 68)
        }
      },
      CoolDownTime = 10,
      DurationTime = 5
    }
  },
  [UESTExtraVehicleType.VT_PenguinCart] = {
    [14802] = {
      UIConfig = {
        SkillDebugName = "\228\188\129\233\185\133\233\155\170\230\169\135-\229\138\169\230\142\168",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_HelpPushOn",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 87009,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 87009,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 87009,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 87009,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/TFMecha/Arts/UI/Atlas/Frames/ZD_Icon_Jump_png.ZD_Icon_Jump_png",
          SkillIconSize = FVector2D(68, 68)
        }
      },
      CoolDownTime = 0,
      DurationTime = 0
    },
    [14803] = {
      UIConfig = {
        SkillDebugName = "\228\188\129\233\185\133\233\155\170\230\169\135-\230\142\168\233\155\170\231\144\131",
        AntiFalseTouchTime = 1,
        ParentSlot = "CanvasPanel_SnowBall",
        bIsPassMouseEvent = false,
        [VehicleSkillState.Default] = {
          SkillNameLocID = 86488,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/PenguinCart/Arts/UI/Atlas/Frames/ZD_icon_SnowballSkill_png.ZD_icon_SnowballSkill_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/PenguinCart/Arts/UI/Atlas/Frames/ZD_icon_SnowballSkill_png.ZD_icon_SnowballSkill_png",
          SkillIconSize = FVector2D(68, 68),
          SkillIconColor = FLinearColor(1, 1, 1, 1),
          bCollapseStopIcon = true
        },
        [VehicleSkillState.Active] = {
          SkillNameLocID = 86489,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/PenguinCart/Arts/UI/Atlas/Frames/ZD_icon_Snowballaunch_png.ZD_icon_Snowballaunch_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/PenguinCart/Arts/UI/Atlas/Frames/ZD_icon_Snowballaunch_png.ZD_icon_Snowballaunch_png",
          SkillIconSize = FVector2D(68, 68),
          SkillIconColor = FLinearColor(1, 1, 1, 1),
          bCollapseStopIcon = true
        },
        [VehicleSkillState.CoolDown] = {
          SkillNameLocID = 86488,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/PenguinCart/Arts/UI/Atlas/Frames/ZD_icon_SnowballSkill_png.ZD_icon_SnowballSkill_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/PenguinCart/Arts/UI/Atlas/Frames/ZD_icon_SnowballSkill_png.ZD_icon_SnowballSkill_png",
          SkillIconColor = FLinearColor(1, 1, 1, 1),
          SkillIconSize = FVector2D(68, 68)
        },
        [VehicleSkillState.Disable] = {
          SkillNameLocID = 86488,
          SkillNormalIconPath = "/Game/Library/Res/Vehicles/PenguinCart/Arts/UI/Atlas/Frames/ZD_icon_SnowballSkill_png.ZD_icon_SnowballSkill_png",
          SkillHighLightIconPath = "/Game/Library/Res/Vehicles/PenguinCart/Arts/UI/Atlas/Frames/ZD_icon_SnowballSkill_png.ZD_icon_SnowballSkill_png",
          SkillIconSize = FVector2D(68, 68),
          SkillIconAlpha = 0.7
        }
      },
      CoolDownTime = 40,
      DurationTime = 20
    },
    [14804] = {
      UIConfig = {
        SkillDebugName = "\228\188\129\233\185\133\233\155\170\230\169\135-\229\138\169\229\138\155\232\147\132\229\138\155"
      },
      CoolDownTime = 0,
      DurationTime = 0
    }
  }
}
return VehicleCommonSkillConfig