local StoreConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.StoreConfig")
local NewbieGuide = {
  Base001 = {
    GuideGroup = Enums_GuidGroup.EntireMap,
    SingleRoundTriggerNumber = 99,
    RuningMaxTime = 15,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_MAP",
          EVENTID = "EVENTID_ENTIRE_MAP_SHOW_STATE",
          Conditions = {
            [1] = true
          }
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionCircleInfo",
          Params = {
            MinBlueCircleIndex = 0,
            MaxBlueCircleIndex = 4,
            LegalCircleStat = {
              0,
              1,
              2
            }
          }
        },
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsInWhiteCircle",
          Params = {bNeedInCircle = false}
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowWhiteCircleMapGuid"
      }
    }
  },
  Base002 = {
    GuideGroup = Enums_GuidGroup.EntireMap,
    SingleRoundTriggerNumber = 4,
    RuningMaxTime = 20,
    TriggerDelayTime = 0,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_SYNC_CIRCILE_LOCATION"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionCircleInfo",
          Params = {
            MinBlueCircleIndex = 0,
            MaxBlueCircleIndex = 4,
            LegalCircleStat = {0, 1}
          }
        },
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsInWhiteCircle",
          Params = {bNeedInCircle = false}
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowCustomUI",
        Params = {
          GuideCanvasTag = "GuideCanvasPanel_SafeAreaCountDown",
          CustomUIPath = "/Game/BluePrints/ControlInput/NewbieItem/NGAction_BlueCircleRemainTime.NGAction_BlueCircleRemainTime_C"
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_MAP",
          EVENTID = "EVENTID_ENTIRE_MAP_SHOW_STATE",
          Conditions = {
            [1] = true
          }
        }
      }
    }
  },
  Base003 = {
    GuideGroup = Enums_GuidGroup.EntireMap,
    SingleRoundTriggerNumber = 3,
    RuningMaxTime = 20,
    TriggerDelayTime = 0,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_SYNC_CIRCILE_INFO",
          Conditions = {
            [1] = 2
          }
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionCircleInfo",
          Params = {
            MinBlueCircleIndex = 0,
            MaxBlueCircleIndex = 4,
            LegalCircleStat = {2}
          }
        },
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsInWhiteCircle",
          Params = {bNeedInCircle = false}
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowCustomUI",
        Params = {
          GuideCanvasTag = "GuideCanvasPanel_SafeAreaDistance",
          CustomUIPath = "/Game/BluePrints/ControlInput/NewbieItem/NGAction_BlueCircleDistance.NGAction_BlueCircleDistance_C"
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_MAP",
          EVENTID = "EVENTID_ENTIRE_MAP_SHOW_STATE",
          Conditions = {
            [1] = true
          }
        }
      }
    }
  },
  Base004 = {
    GuideGroup = Enums_GuidGroup.Unique,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 9999,
    SyncGuideDataAtStart = true,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_ENTER_GAME",
          Conditions = {}
        }
      },
      Conditions = {}
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowBlueCircleRunWarning",
        Params = {PopTipInterval = 20}
      }
    }
  },
  Base006 = {
    GuideGroup = Enums_GuidGroup.Normal,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 20,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_TICK_GUIDE_CHECK"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsInGameStatus",
          Params = {
            LegalGameStat = {"ReadyState"}
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "GridPanel_SmallMap",
          RegisterButtonName = "EntireMapTrigger",
          TextID = 12522
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_PARACHUTING",
          EVENTID = "EVENTID_PARACHUTING_ENTER_PLANE"
        }
      }
    }
  },
  Base007 = {
    GuideGroup = Enums_GuidGroup.EntireMap,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 20,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_MAP",
          EVENTID = "EVENTID_ENTIRE_MAP_SHOW_STATE",
          Conditions = {
            [1] = true
          }
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsInGameStatus",
          Params = {
            LegalGameStat = {"ReadyState"}
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowAirLineTips"
      }
    }
  },
  Base008 = {
    GuideGroup = Enums_GuidGroup.Parachute,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 180,
    EndExtraNumber = 1,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_PARACHUTING",
          EVENTID = "EVENTID_PARACHUTING_SHOW_JUMP_OUT_PLANE_BTN"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "NewbieGuide_ParachutingBtn",
          RegisterButtonName = "Button_LeavePlane",
          bEnableCircleEffect = true,
          HighlightOutlineType = 0,
          ClickEndReason = "RecieveEndEventExtra",
          TextID = 12524
        }
      }
    }
  },
  Base009 = {
    GuideGroup = Enums_GuidGroup.Unique,
    SingleRoundTriggerNumber = 1,
    EndExtraNumber = 3,
    RuningMaxTime = 25,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_PARACHUTING",
          EVENTID = "EVENTID_PARACHUTING_LEAVE_PLANE"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowCustomUI",
        Params = {
          GuideCanvasTag = "NewbieGuide_ParachutingMoveJoyStick",
          CustomUIPath = "/Game/BluePrints/ControlInput/NewbieItem/120NewbieTips_Joystick.120NewbieTips_Joystick_C"
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_PARACHUTING",
          EVENTID = "EVENTID_PLAYER_ENTER_PARACHUTE"
        },
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_MOVE_JOY_STICK"
        }
      }
    }
  },
  Base010 = {
    GuideGroup = Enums_GuidGroup.Unique,
    SingleRoundTriggerNumber = 1,
    EndExtraNumber = 3,
    RuningMaxTime = 25,
    TriggerDelayTime = 2,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_END",
          Conditions = {
            [1] = "Base009"
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowCustomUI",
        Params = {
          GuideCanvasTag = "NewbieGuide_ParachutingMoveCamera",
          CustomUIPath = "/Game/BluePrints/ControlInput/NewbieItem/120NewbieTips_direction_2.120NewbieTips_direction_2_C"
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_PARACHUTING",
          EVENTID = "EVENTID_PLAYER_ENTER_PARACHUTE"
        },
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_MOVE_CAMERA"
        }
      }
    }
  },
  Base011 = {
    GuideGroup = Enums_GuidGroup.Normal,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 20,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_PARACHUTING",
          EVENTID = "EVENTID_PARACHUTING_ENTER_PARACHUTE"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "CanvasPanel_FreeCamera",
          RegisterButtonName = "AimControlGrid",
          HighlightOutlineType = 0,
          TextID = 12527
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_CHARACTER",
          EVENTID = "EVENTID_PLAYEREVENT_ENTER_FREECAMERA"
        },
        {
          EventType = "EVENTTYPE_PLAYEREVENT_CHARACTER",
          EVENTID = "EVENTID_PLAYEREVENT_ENTER_FIGHTING_STATE"
        }
      }
    }
  },
  Base012 = {
    RuningMaxTime = 350,
    EndExtraNumber = 1,
    GuideGroup = Enums_GuidGroup.Unique,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_CHARACTER",
          EVENTID = "EVENTID_PLAYEREVENT_ENTER_FIGHTING_STATE"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPopTips",
        Params = {
          TipID = 10137,
          TipIntervalTime = 60,
          TipType = 2,
          TipMaxCount = 5,
          bShowTipImmediately = true
        }
      }
    },
    EndEventExtra = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_UPDATE_ITEM_LIST"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionHasItemInBackpack",
          Params = {
            CheckItemList = {},
            BackpackSoreArea = 0
          }
        }
      }
    }
  },
  Base013 = {
    SingleRoundTriggerNumber = 3,
    TriggerIntervalTime = 180,
    RuningMaxTime = 10,
    EndExtraNumber = 3,
    GuideGroup = Enums_GuidGroup.Normal,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_KEEP_ON_STATUS",
          Conditions = {
            [1] = true,
            [2] = 1
          }
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsKeepOnStatus",
          Params = {
            CharacterState = 1,
            TriggerThresholdTime = 3.0,
            CheckIntervalTime = 1.0
          }
        },
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsInGameStatus",
          Params = {
            LegalGameStat = {
              "FightingState"
            }
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "CanvasPanel_FreeCamera",
          RegisterButtonName = "AimControlGrid",
          HighlightOutlineType = 0,
          TextID = 12527
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_KEEP_ON_STATUS",
          Conditions = {
            [1] = false,
            [2] = 1
          }
        }
      }
    },
    EndEventExtra = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_CHARACTER",
          EVENTID = "EVENTID_PLAYEREVENT_ENTER_FREECAMERA"
        }
      }
    }
  },
  Base014 = {
    GuideGroup = Enums_GuidGroup.Normal,
    EndExtraNumber = 1,
    TriggerIntervalTime = 60,
    RuningMaxTime = 30,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_TEAMMATE_PANEL",
          EVENTID = "EVENTID_TEAMMATE_LIVE_STATE_CHANGE",
          Conditions = {
            [2] = 4
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionRescueTeammate",
        Params = {MaxDistance = 100}
      }
    },
    EndEventExtra = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_START_RESCUE_TEAMMATE"
        }
      }
    }
  },
  Base015 = {
    GuideGroup = Enums_GuidGroup.Normal,
    SingleRoundTriggerNumber = 3,
    EndExtraNumber = 1,
    TriggerIntervalTime = 30,
    RuningMaxTime = 10,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL",
          EVENTID = "EVENTID_VEHICLE_CONTROL_PANEL_INIT",
          Conditions = {
            [1] = 2
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "CanvasPanel_Button_L_UpArrow",
          RegisterButtonName = "DriveUp",
          TextID = 12531,
          ClickEndReason = "RecieveEndEventExtra",
          RegisterButtonEventName = "OnPressed",
          ForceDirection = "LU"
        }
      },
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "DriveDown",
          RegisterButtonName = "DriveDown"
        }
      }
    }
  },
  Base016 = {
    GuideGroup = Enums_GuidGroup.Unique,
    SingleRoundTriggerNumber = 3,
    EndExtraNumber = 1,
    TriggerIntervalTime = 30,
    TriggerDelayTime = 2,
    RuningMaxTime = 10,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_END",
          Conditions = {
            [1] = "Base015"
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "CanvasPanel_DriveLeft_0",
          RegisterButtonName = "DriveLeft",
          TextID = 12530,
          ClickEndReason = "RecieveEndEventExtra",
          RegisterButtonEventName = "OnPressed"
        }
      },
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "DriveRight",
          RegisterButtonName = "DriveRight"
        }
      }
    }
  },
  Base017 = {
    GuideGroup = Enums_GuidGroup.UITips,
    SingleRoundTriggerNumber = 1,
    TotalTriggerRound = 5,
    EndExtraNumber = 1,
    RuningMaxTime = 3,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_SKILLBUFF",
          EVENTID = "EVENTID_PLAYEREVENT_GRENADE_BASE_SPAWN"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsUsingWeapon",
          Params = {
            WeaponList = {
              602001,
              602002,
              602004
            }
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionListenThrowGrenade",
        Params = {TimeThreshold = 4}
      },
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "ThrowTimeInfo",
          RegisterButtonName = "ThrowTimeInfo",
          HighlightOutlineType = 1,
          TextID = 12533
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_END_GUIDE_BY_ACTION",
          Conditions = {
            [1] = "Base018",
            [2] = "RecieveEndEventExtra"
          }
        }
      }
    }
  },
  Base018 = {
    GuideGroup = Enums_GuidGroup.Normal,
    SingleRoundTriggerNumber = 1,
    TotalTriggerRound = 5,
    EndExtraNumber = 1,
    RuningMaxTime = 3,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_SKILLBUFF",
          EVENTID = "EVENTID_PLAYEREVENT_GRENADE_BASE_SPAWN"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionGuideTriggerTimes",
          Params = {
            GuideID = "Base017",
            LegalTimes = {1}
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "GridPanel_CancelThrowGrenade",
          RegisterButtonName = "Button_CancelThrowGrenade",
          RegisterButtonEventName = "OnPressed",
          HighlightOutlineType = -1,
          ClickEndReason = "RecieveEndEventExtra",
          TextID = 12532
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_SKILLBUFF",
          EVENTID = "EVENTID_PLAYEREVENT_GRENADE_BASE_THROW"
        }
      }
    }
  },
  Base019 = {
    GuideGroup = Enums_GuidGroup.PopTips,
    SingleRoundTriggerNumber = 9999,
    TriggerIntervalTime = 30,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_TICK_GUIDE_CHECK"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsInAirAttackZone"
        },
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsCharacterOutBuilding"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPopTips",
        Params = {TipID = 10138, TipType = 2}
      }
    }
  },
  Base020 = {
    GuideGroup = Enums_GuidGroup.PopTips,
    SingleRoundTriggerNumber = 9999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_ON_PLAYERNUM_CHANGED"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionNeedShowRemainPlayersTip",
          Params = {}
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPopTips",
        Params = {
          TipID = 10139,
          TipType = 2,
          bShowTipImmediately = true
        }
      }
    }
  },
  Base022 = {
    GuideGroup = Enums_GuidGroup.Unique,
    RuningMaxTime = 10,
    SingleRoundTriggerNumber = 1,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_SHOW_VOICE_BAN_GUIDE"
        }
      },
      Conditions = {}
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowCustomUI",
        Params = {
          GuideCanvasTag = "GuideCanvas_VoiceBan",
          CustomUIPath = "/Game/BluePrints/ControlInput/IngameUI/Ban/VoiceBanGuide_UIBP.VoiceBanGuide_UIBP_C"
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_ON_REPORTBTN_DOWN"
        }
      }
    }
  },
  Base023 = {
    GuideGroup = Enums_GuidGroup.Normal,
    SingleRoundTriggerNumber = 3,
    EndExtraNumber = 1,
    RuningMaxTime = 100,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_NEWBIE_GUIDE_SWIM_PANEL",
          Conditions = {
            [1] = true
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "SwimPanel",
          AttachParentSlot = "SwimDown",
          HighlightOutlineType = 0,
          RegisterButtonName = "SwimDown",
          TextID = 19126,
          ClickEndReason = "RecieveEndEventExtra"
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_NEWBIE_GUIDE_SWIM_PANEL",
          Conditions = {
            [1] = false
          }
        }
      }
    }
  },
  Base024 = {
    GuideGroup = Enums_GuidGroup.Normal,
    SingleRoundTriggerNumber = 3,
    EndExtraNumber = 1,
    RuningMaxTime = 100,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_UPDATE_BREATH_AMOUNT"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "SwimPanel",
          AttachParentSlot = "SwimUp",
          HighlightOutlineType = 0,
          RegisterButtonName = "SwimUp",
          TextID = 19127,
          ClickEndReason = "RecieveEndEventExtra"
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_NEWBIE_GUIDE_SWIM_PANEL",
          Conditions = {
            [1] = false
          }
        }
      }
    }
  },
  Base025 = {
    GuideGroup = Enums_GuidGroup.Normal,
    SingleRoundTriggerNumber = 1,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_UPDATE_BREATH_AMOUNT",
          Conditions = {
            [1] = {Operator = ">", Value = 0.5}
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowCustomUI",
        Params = {
          GuideCanvasTag = "LungIcon_GuideCanvas",
          CustomUIPath = "/Game/BluePrints/ControlInput/NewbieItem/140NewbieGuide_Lung.140NewbieGuide_Lung_C"
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_NEWBIE_GUIDE_SWIM_PANEL",
          Conditions = {
            [1] = false
          }
        },
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_UPDATE_BREATH_AMOUNT",
          Conditions = {
            [1] = {Operator = "<", Value = 0.5}
          }
        }
      }
    }
  },
  Base026 = {
    GuideGroup = Enums_GuidGroup.PopTips,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 15,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_ENTER_GAME"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsInGameStatus",
          Params = {
            LegalGameStat = {"ReadyState"}
          }
        },
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionSettingConfig",
          Params = {
            KeyString = "IslandBroadCast",
            ExpectValue = false
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPopTips",
        Params = {TipID = 10166, TipType = 2}
      },
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPlayAudio",
        Params = {
          sAudioPath = "/Game/WwiseEvent/VoiceTutorial/ZH/Play_NEW_stage_voice106_en.Play_NEW_stage_voice106_en"
        }
      }
    }
  },
  Base031 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    MaxPlayerLv = 999,
    RuningMaxTime = 5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_REPLAY",
          EVENTID = "EVENTID_SHOW_WONDERFUL_ENTRY"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ResultsRanking_Protect_UIBPNew",
          AttachParentSlot = "CanvasPanel_WonderfulTips",
          RegisterButtonName = "Button_PlayWonderful",
          HighlightOutlineType = 1,
          TextID = 25168,
          RegisterButtonEventName = "OnClicked",
          ClickEndReason = "RecieveEndEventExtra"
        }
      }
    }
  },
  Base032 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 3,
    SingleRoundTriggerNumber = 2,
    MaxPlayerLv = 999,
    RuningMaxTime = 5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_SHILED_SKILL",
          Conditions = {
            [1] = 605008
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "CanvasPanel_Skill1",
          RegisterButtonName = "CanvasPanel_Skill1",
          HighlightOutlineType = 0,
          TextID = 24221
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_LIBRARY_GUIDE_SHILED_SKILL_END"
        }
      }
    }
  },
  Base033 = {
    GuideGroup = Enums_GuidGroup.Backpack,
    SingleRoundTriggerNumber = 2,
    RuningMaxTime = 5,
    EndExtraNumber = 1,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_CHANGE_STATE",
          Conditions = {
            [1] = true
          }
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionNeedShowBackpackFoldTip"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "CanvasPanel_ToggleItemList",
          RegisterButtonName = "Button_ToggleItemList",
          HighlightOutlineType = 1,
          TextID = 36706,
          RegisterButtonEventName = "OnClicked",
          ClickEndReason = "RecieveEndEventExtra"
        }
      }
    }
  },
  Base034 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 2,
    RuningMaxTime = 5,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    SyncGuideDataAtStart = false,
    EndExtraNumber = 1,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL",
          EVENTID = "EVENTID_VEHICLE_CONTROL_SHOW_NEWBIE"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionWithIgnoreMod",
          Params = {ignoreMod = "NewbieGame"}
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          HighlightOutlineType = 1,
          TextID = 33523,
          RegisterButtonEventName = "OnPressed",
          ClickEndReason = "RecieveEndEventExtra",
          GetButtonAndSlotFunc = function()
            local VehicleSkinAndMusicButton = UIManager.GetUI(UIManager.UI_Config.VehicleSkinAndMusicButton)
            if VehicleSkinAndMusicButton then
              return VehicleSkinAndMusicButton.UIRoot.Button_VehicleMusic, VehicleSkinAndMusicButton.UIRoot.CanvasPanel_InButton
            end
          end
        }
      }
    }
  },
  Base035 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 3,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    SyncGuideDataAtStart = false,
    EndExtraNumber = 1,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_SPECTATING",
          EVENTID = "EVENTID_USER_CLICK_CARD"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "watchgame",
          AttachParentSlot = "Canvas_PlayerInfoCard",
          HighlightOutlineType = 1,
          RegisterButtonName = "NewButton_Change",
          TextID = 38568
        }
      }
    }
  },
  Base036 = {
    GuideGroup = Enums_GuidGroup.Normal,
    RuningMaxTime = 15,
    SingleRoundTriggerNumber = 1,
    EndExtraNumber = 1,
    MinPlayerLv = 6,
    MaxPlayerLv = 10,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_TICK_GUIDE_CHECK"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsInGameStatus",
          Params = {
            LegalGameStat = {"ReadyState"}
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          HighlightOutlineType = 0,
          AttachParentWindow = "ingame",
          AttachParentSlot = "ChatAndChatPanelCanvas",
          RegisterButtonName = "TurnplateBtn_UIBP_0",
          ClickEndReason = "RecieveEndEventExtra",
          RegisterButtonEventName = "ED_TurnplateBtnTouchStart",
          TextID = 6893
        }
      }
    }
  },
  Base039 = {
    GuideGroup = Enums_GuidGroup.Normal,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 2,
    RuningMaxTime = 8,
    MaxPlayerLv = 99999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_WEAPON",
          EVENTID = "EVENTID_PLAYEREVENT_WEAPON_SWITCHWEAPON_FINISHED"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsUsingWeapon",
          Params = {
            WeaponList = {104102}
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowNeosteadGuide"
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_WEAPON",
          EVENTID = "EVENTID_PLAYEREVENT_WEAPON_SWITCHWEAPON_FINISHED"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsNotUsingWeapon",
          Params = {
            WeaponList = {104102}
          }
        }
      }
    }
  },
  Base041 = {
    GuideGroup = Enums_GuidGroup.Normal,
    TotalTriggerRound = 2,
    SingleRoundTriggerNumber = 1,
    TriggerDelayTime = 10,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_TICK_GUIDE_CHECK"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsInGameStatus",
          Params = {
            LegalGameStat = {"ReadyState"}
          }
        },
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsInStandalone",
          Params = {bNeedStandalone = false, ignoreMod = "NewbieGame"}
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowShareSkinGuide",
        Params = {}
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_PARACHUTING",
          EVENTID = "EVENTID_PARACHUTING_ENTER_PLANE"
        },
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_CHANGE_STATE",
          Conditions = {
            [1] = true
          }
        }
      }
    }
  },
  Base042 = {
    GuideGroup = Enums_GuidGroup.Normal,
    TotalTriggerRound = 2,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 8,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_TICK_GUIDE_CHECK"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsInGameStatus",
          Params = {
            LegalGameStat = {"ReadyState"}
          }
        },
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionWithIgnoreMod",
          Params = {ignoreMod = "NewbieGame"}
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowClickShareSkinGuide",
        Params = {}
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_PARACHUTING",
          EVENTID = "EVENTID_PARACHUTING_ENTER_PLANE"
        },
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_CHANGE_STATE",
          Conditions = {
            [1] = true
          }
        }
      }
    }
  },
  Turkey2FaceIntro = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 3,
    SingleRoundTriggerNumber = 1,
    MaxPlayerLv = 999,
    RuningMaxTime = -1,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_TURKEY_2_FACE_INTRO"
        }
      }
    },
    Actions = {},
    EndEventExtra = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_TURKEY_2_FACE_INTRO_FINISHED"
        }
      }
    }
  },
  BoomThrottleUIGuide = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 10,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    SyncGuideDataAtStart = false,
    EndExtraNumber = 1,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_THROTTLE"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowCustomUI",
        Params = {
          GuideCanvasTag = "GuideCanvasPanel_BoomThrottle",
          CustomUIPath = "/Game/BluePrints/ControlInput/NewbieItem/NewbieTips_Boom_throttle.NewbieTips_Boom_Throttle_C"
        }
      }
    }
  },
  GameGuideEntrance = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 3,
    RuningMaxTime = 10,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    SyncGuideDataAtStart = false,
    EndExtraNumber = 1,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_WEAPON",
          EVENTID = "EVENTID_PLAYEREVENT_WEAPON_EQUIP"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionCheckGameGuideItem",
          Params = {}
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowGameGuideEntrance",
        Params = {}
      }
    }
  },
  GameGuideBtn = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 3,
    RuningMaxTime = 10,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    SyncGuideDataAtStart = false,
    EndExtraNumber = 1,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_WEAPON",
          EVENTID = "EVENTID_PLAYEREVENT_WEAPON_EQUIP"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionCheckGameGuideItem",
          Params = {}
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowCustomUI",
        Params = {
          GuideCanvasTag = "GuideCanvasPanel_GamePlayGuide",
          CustomUIPath = "/Game/BluePrints/ControlInput/NewbieItem/NewbieTips_GameGuide.NewbieTips_GameGuide_C"
        }
      }
    }
  },
  Base043 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 5,
    SingleRoundTriggerNumber = 1,
    MaxPlayerLv = 999,
    RuningMaxTime = 10,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_CHANGE_STATE",
          Conditions = {
            [1] = true
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPostEvent",
        Params = {
          StartEventType = "EVENTTYPE_INGAME_BACKPACK",
          StartEventID = "EVENTID_BACKPACK_SHOW_BEZEL_ANIM",
          EndEventType = "EVENTTYPE_INGAME_BACKPACK",
          EndEventID = "EVENTID_BACKPACK_HIDE_BEZEL_ANIM"
        }
      }
    },
    EndEventExtra = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_BEZEL_ANIM_COMPLETE"
        }
      }
    }
  },
  Base044 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    TriggerIntervalTime = 0,
    TriggerDelayTime = 0.1,
    RuningMaxTime = 3,
    EndExtraNumber = nil,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    SyncGuideDataAtStart = false,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_QUICK_EXPRESSION_DECAL_CLICK"
        }
      },
      Conditions = {},
      ConditionsJudgment = "And"
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "CanvasPanel_Sight",
          RegisterButtonName = "Button_PetFeature",
          RegisterButtonEventName = "OnClicked",
          bEnableCircleEffect = true,
          HighlightOutlineType = 1,
          ClickEndReason = "RecieveEndEventExtra"
        }
      }
    },
    EndEvent = {
      Events = {},
      Conditions = {},
      ConditionsJudgment = "Or"
    },
    EndEventExtra = {
      Events = {},
      Conditions = {},
      ConditionsJudgment = "Or"
    }
  },
  Base045 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    TriggerIntervalTime = 0,
    TriggerDelayTime = 0.1,
    RuningMaxTime = 3,
    EndExtraNumber = nil,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    SyncGuideDataAtStart = false,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_QUICK_EXPRESSION_CLICK"
        }
      },
      Conditions = {},
      ConditionsJudgment = "And"
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "QuickExpression",
          AttachParentSlot = "EXCanvasPanel_Ring",
          RegisterButtonName = "Button_PetFeature",
          RegisterButtonEventName = "OnClicked",
          bEnableCircleEffect = true,
          HighlightOutlineType = 1,
          ClickEndReason = "RecieveEndEventExtra"
        }
      }
    },
    EndEvent = {
      Events = {},
      Conditions = {},
      ConditionsJudgment = "Or"
    },
    EndEventExtra = {
      Events = {},
      Conditions = {},
      ConditionsJudgment = "Or"
    }
  },
  BackPackShowGunLockAnim = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 5,
    SingleRoundTriggerNumber = 1,
    MaxPlayerLv = 999,
    RuningMaxTime = 10,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_CHANGE_STATE",
          Conditions = {
            [1] = true
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPostEvent",
        Params = {
          StartEventType = "EVENTTYPE_INGAME_BACKPACK",
          StartEventID = "EVENTID_BACKPACK_SHOW_GUNLOCK_ANIM",
          EndEventType = "EVENTTYPE_INGAME_BACKPACK",
          EndEventID = "EVENTID_BACKPACK_HIDE_GUNLOCK_ANIM"
        }
      }
    },
    EndEventExtra = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_GUNLOCK_ANIM_COMPLETE"
        }
      }
    }
  },
  Base046 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 3,
    SingleRoundTriggerNumber = 999,
    MaxPlayerLv = 999,
    RuningMaxTime = 3,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_SKILLBUFF",
          EVENTID = "EVENTID_PLAYEREVENT_SKILL_UI_INIT",
          Conditions = {
            [1] = 1013300
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "SkillBuildMVPButtonSlot",
          AttachParentSlot = "CustomizeCanvasPanel_BuildMVP",
          RegisterButtonName = "CustomizeCanvasPanel_BuildMVP",
          HighlightOutlineType = 0,
          TextID = 49085
        }
      }
    },
    EndEventExtra = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_SKILLBUFF",
          EVENTID = "EVENTID_PLAYEREVENT_SKILL_START_CLIENT",
          Conditions = {
            [1] = 1013300
          }
        }
      }
    }
  },
  Base114 = {
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    MaxPlayerLv = 99999,
    RuningMaxTime = 10,
    TriggerIntervalTime = 0,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_SINGLE_ITEM_ADD_NEWBIE_GUIDE",
          Conditions = {
            [1] = 150063
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionBackPackGuide"
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_CHANGE_STATE",
          Conditions = {
            [1] = true
          }
        }
      }
    }
  },
  Base115 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 2,
    SingleRoundTriggerNumber = 2,
    MaxPlayerLv = 999,
    RuningMaxTime = 4,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_START_PLAY_MOVABLE_EMOTE"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowCustomUI",
        Params = {
          GuideCanvasTag = "NewbieGuide_MainControlMoveJoyStick",
          CustomUIPath = "/Game/BluePrints/ControlInput/NewbieItem/120NewbieTips_JoystickForMarchingEmote.120NewbieTips_JoystickForMarchingEmote_C"
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_MOVE_JOY_STICK"
        },
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_END_PLAY_MOVABLE_EMOTE"
        }
      }
    }
  },
  Base116 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 2,
    SingleRoundTriggerNumber = 2,
    MaxPlayerLv = 999,
    RuningMaxTime = 4,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_SHOW_RUN_STATE_WHEN_MARCHING_EMOTE"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "CanvasPanel_RunState",
          RegisterButtonName = "CanvasPanel_RunState",
          HighlightOutlineType = 0,
          TextID = 64259
        }
      }
    },
    EndEventExtra = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_END_PLAY_MOVABLE_EMOTE"
        }
      }
    }
  },
  BackPackShowTacticalAttachAnim = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 5,
    SingleRoundTriggerNumber = 1,
    MaxPlayerLv = 999,
    RuningMaxTime = 10,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_CHANGE_STATE",
          Conditions = {
            [1] = true
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPostEvent",
        Params = {
          StartEventType = "EVENTTYPE_INGAME_BACKPACK",
          StartEventID = "EVENTID_BACKPACK_SHOW_TACTICALATTACH_ANIM",
          EndEventType = "EVENTTYPE_INGAME_BACKPACK",
          EndEventID = "EVENTID_BACKPACK_HIDE_TACTICALATTACH_ANIM"
        }
      }
    },
    EndEventExtra = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_TACTICALATTACH_ANIM_COMPLETE"
        }
      }
    }
  },
  HelicopterSeatGeneralUI = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    MaxPlayerLv = 999,
    RuningMaxTime = 5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_SHOW_HELICOPTER_SEAT_GENERAL_UI"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPostEvent",
        Params = {
          StartEventType = "EVENTTYPE_INGAME",
          StartEventID = "EVENTID_INGAME_SHOW_HELICOPTER_SEAT_GENERAL_UI_NEWBIE_GUIDE_TIPS",
          EndEventType = "EVENTTYPE_INGAME",
          EndEventID = "EVENTID_INGAME_HIDE_HELICOPTER_SEAT_GENERAL_UI_NEWBIE_GUIDE_TIPS"
        }
      }
    }
  },
  MVPDaneceCamera = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    MaxPlayerLv = 999,
    RuningMaxTime = 5,
    TriggerIntervalTime = 0,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_UI",
          EVENTID = "EVENTID_INGAME_MVPCAMERAUI_SET",
          Conditions = {
            [1] = true
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "MVPStatueMainRT",
          AttachParentSlot = "CanvasPanel_EnterSelfie",
          RegisterButtonName = "Button_EnterSelfie",
          RegisterButtonEventName = "OnPressed",
          HighlightOutlineType = 0,
          TextID = 64739
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_UI",
          EVENTID = "EVENTID_INGAME_MVPCAMERAUI_SET",
          Conditions = {
            [1] = false
          }
        }
      }
    }
  },
  SlideChangeSeatGuide = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    MaxPlayerLv = 999,
    RuningMaxTime = 5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_SHOW_SEAT_GENERAL_UI"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPostEvent",
        Params = {
          StartEventType = "EVENTTYPE_INGAME",
          StartEventID = "EVENTID_INGAME_SHOW_SEAT_GENERAL_UI_NEWBIE_GUIDE_TIPS",
          EndEventType = "EVENTTYPE_INGAME",
          EndEventID = "EVENTID_INGAME_HIDE_SEAT_GENERAL_UI_NEWBIE_GUIDE_TIPS"
        }
      }
    }
  },
  Base117 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 2,
    SingleRoundTriggerNumber = 1,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_NORMAL",
          EVENTID = "EVENTID_SET_SHOW_DROP_MELEE_GUIDE"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPopTips",
        Params = {
          TipID = 69259,
          TipIntervalTime = 60,
          TipType = 0,
          TipMaxCount = 1,
          bShowTipImmediately = true
        }
      }
    }
  },
  Base118 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 2,
    SingleRoundTriggerNumber = 1,
    MaxPlayerLv = 999,
    RuningMaxTime = 10,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_NORMAL",
          EVENTID = "EVENTID_SET_HIGH_LIGHT_SETTING_BTN"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "CanvasPanel_Setting",
          RegisterButtonName = "Button_Setting",
          RegisterButtonEventName = "OnClicked",
          HighlightOutlineType = 0,
          TextID = 69260,
          Offset = {3, 2},
          Size = {1, 2}
        }
      }
    }
  },
  RecallItemGuide = {
    GuideGroup = Enums_GuidGroup.Normal,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    TriggerIntervalTime = 0,
    TriggerDelayTime = 0,
    RuningMaxTime = 5,
    EndExtraNumber = nil,
    MinPlayerLv = 0,
    MaxPlayerLv = 9999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_SINGLE_ITEM_ADD_NEWBIE_GUIDE",
          Conditions = {
            [1] = 604123
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "CanvasPanel_RingThrowNewBie",
          RegisterButtonName = "Button_RingThrowGuide",
          TextID = 71138,
          HighlightOutlineType = 1,
          Size = {0, 34},
          Offset = {0, -34}
        }
      }
    }
  },
  Base121 = {
    GuideGroup = Enums_GuidGroup.Unique,
    SingleRoundTriggerNumber = 2,
    TotalTriggerRound = 1,
    RuningMaxTime = 5,
    MinPlayerLv = 0,
    MaxPlayerLv = 9999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_BACKPACK_SHOW_DROP_SLIDER_GUIDE"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "BackPackPanelUI",
          AttachParentSlot = "Button_Drop",
          RegisterButtonName = "Button_Drop",
          TextID = 76275
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_BACKPACK_HIDE_DROP_SLIDER_GUIDE"
        }
      }
    }
  },
  BaseDriftGuide = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 8,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_VEHICLE_CONTROL_DRIFT_UI"
        },
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_END",
          Conditions = {
            [1] = "Base015"
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          HighlightOutlineType = 1,
          TextID = 876158,
          GetButtonAndSlotFunc = function()
            local VehicleControlUISpeed = UIManager.GetUI(UIManager.UI_Config.VehicleControlUISpeed)
            if VehicleControlUISpeed then
              return VehicleControlUISpeed.UIRoot.Button_Brake, VehicleControlUISpeed.UIRoot.Canvas_Left_Brake
            end
          end
        }
      }
    }
  },
  BaseVehicleAutoForwardGuide = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 8,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_END",
          Conditions = {
            [1] = "BaseDriftGuide"
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "Node_AutoAcc",
          RegisterButtonName = "MultiEventsButton_AutomaticAcceleration",
          HighlightOutlineType = 1,
          TextID = 876159
        }
      }
    }
  },
  NewTakeOverLostConnectionTeammate_01 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 8,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerDelayTime = 5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_TAKEOVER_TEAMMATE"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsInGameStatus",
          Params = {
            LegalGameStat = {"ReadyState"}
          }
        },
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionReadyTime",
          Params = {LeftTime = 21}
        },
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionMsgBoxEmpty",
          Params = {}
        }
      },
      ConditionsJudgment = "And"
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPostEvent",
        Params = {
          StartEventType = "EVENTTYPE_NEWBIE_GUIDE",
          StartEventID = "EVENTID_NEWBIE_SHOW_TAKEOVER_TEAMMATE_UI"
        }
      }
    }
  },
  TreatmentDeviceUIGuide_01 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 2,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 5,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    SyncGuideDataAtStart = false,
    EndExtraNumber = 1,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_TREATMENT_DEVICE"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "MedicineChooseWidgetNew",
          AttachParentSlot = "CanvasPanel_RingThrowNewBie",
          RegisterButtonName = "Button_RingThrowGuide",
          HighlightOutlineType = 1,
          TextID = 792212
        }
      }
    }
  },
  TreatmentDeviceUIGuide_02 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 2,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 5,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    SyncGuideDataAtStart = false,
    EndExtraNumber = 1,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_TREATMENT_DEVICE"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "TreatmentDeviceRightUI",
          AttachParentSlot = "CanvasPanel_Root",
          RegisterButtonName = "FireButton",
          HighlightOutlineType = 1,
          TextID = 792210
        }
      }
    }
  },
  SuggestParachutePosGuide = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 3,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 200,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_MAP",
          EVENTID = "EVENTID_ENTIRE_MAP_SHOW_STATE"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionGuideMarkParacheCanOpen"
      }
    }
  },
  SuggestParachutePosGuideTip = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 3,
    SingleRoundTriggerNumber = 3,
    RuningMaxTime = 2,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_MAP",
          EVENTID = "EVENTID_MAP_IMMEDIATE_GUIDE"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowEntireUI",
        Params = {
          UIConfigName = "AirLineGuidWidget"
        }
      }
    }
  },
  TFSkillUnlockGuide = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 8,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_VEHICLE_CONTROL_SKILLUNLOCK"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "CannonBtn",
          RegisterButtonName = "CannonBtn",
          HighlightOutlineType = 1,
          TextID = 390079
        }
      }
    }
  },
  TFOpSkillUnlockGuide = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 8,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME",
          EVENTID = "EVENTID_INGAME_VEHICLE_CONTROL_SKILLUNLOCKOP"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "RushBtn",
          RegisterButtonName = "RushBtn",
          HighlightOutlineType = 1,
          TextID = 390302
        }
      }
    }
  },
  ReviveTicketInBackpackGuide1 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 15,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_CHANGE_STATE",
          Conditions = {
            [1] = true
          }
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionHasItemInBackpack",
          Params = {
            CheckItemList = {
              StoreConfig.ExchangeTicketConfig.ReviveTicket.TicketItemID
            },
            BackpackSoreArea = 0
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          HighlightOutlineType = 1,
          GetButtonAndSlotFunc = function()
            local BackPackPanelUI = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackPanelUI)
            if not BackPackPanelUI or not BackPackPanelUI.tScrollListItemsUI then
              print(bWriteLog and "ReviveTicketGuide:GetButtonAndSlotFunc BackPackPanelUI not found")
              return nil, nil
            end
            for nIndex, ListItem in pairs(BackPackPanelUI.tScrollListItemsUI) do
              if ListItem and ListItem.ItemData and ListItem.ItemData.DefineID then
                local ItemID = ListItem.ItemData.DefineID.TypeSpecificID
                if ItemID == StoreConfig.ExchangeTicketConfig.ReviveTicket.TicketItemID then
                  print(bWriteLog and "ReviveTicketGuide:GetButtonAndSlotFunc Found revive ticket UI at index:" .. nIndex)
                  local ItemButton = ListItem.UIRoot.GridPanel_Right
                  local AttachSlot = ListItem.UIRoot.GridPanel_Right
                  return ItemButton, AttachSlot
                end
              end
            end
            print(bWriteLog and "ReviveTicketGuide:GetButtonAndSlotFunc Revive ticket UI not found")
            return nil, nil
          end
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_CHANGE_STATE",
          Conditions = {
            [1] = false
          }
        }
      }
    }
  },
  ReviveTicketInBackpackGuide2 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 15,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_RECORD_CLICK_ITEM"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionCheckClickedBackpackItemID",
          Params = {
            CheckItemID = StoreConfig.ExchangeTicketConfig.ReviveTicket.TicketItemID
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          HighlightOutlineType = 1,
          TextID = StoreConfig.ExchangeTicketConfig.ReviveTicket.GuideTextID,
          AttachParentWindow = "PickUpItemTips",
          AttachParentSlot = "GridPanel_0",
          RegisterButtonName = "GridPanel_0"
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_RECORD_CLICK_ITEM"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionCheckClickedBackpackItemID",
          Params = {
            CheckItemID = StoreConfig.ExchangeTicketConfig.ReviveTicket.TicketItemID,
            IsNot = true
          }
        }
      }
    }
  },
  AdvancedWeaponTicketInBackpackGuide1 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 15,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_CHANGE_STATE",
          Conditions = {
            [1] = true
          }
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionHasItemInBackpack",
          Params = {
            CheckItemList = {
              StoreConfig.ExchangeTicketConfig.AdvancedWeaponTicket.TicketItemID
            },
            BackpackSoreArea = 0
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          HighlightOutlineType = 1,
          GetButtonAndSlotFunc = function()
            local BackPackPanelUI = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackPanelUI)
            if not BackPackPanelUI or not BackPackPanelUI.tScrollListItemsUI then
              print(bWriteLog and "AdvancedWeaponTicketGuide:GetButtonAndSlotFunc BackPackPanelUI not found")
              return nil, nil
            end
            for nIndex, ListItem in pairs(BackPackPanelUI.tScrollListItemsUI) do
              if ListItem and ListItem.ItemData and ListItem.ItemData.DefineID then
                local ItemID = ListItem.ItemData.DefineID.TypeSpecificID
                if ItemID == StoreConfig.ExchangeTicketConfig.AdvancedWeaponTicket.TicketItemID then
                  print(bWriteLog and "AdvancedWeaponTicketGuide:GetButtonAndSlotFunc Found advanced weapon ticket UI at index:" .. nIndex)
                  local ItemButton = ListItem.UIRoot.GridPanel_Right
                  local AttachSlot = ListItem.UIRoot.GridPanel_Right
                  return ItemButton, AttachSlot
                end
              end
            end
            print(bWriteLog and "AdvancedWeaponTicketGuide:GetButtonAndSlotFunc Advanced weapon ticket UI not found")
            return nil, nil
          end
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_CHANGE_STATE",
          Conditions = {
            [1] = false
          }
        }
      }
    }
  },
  AdvancedWeaponTicketInBackpackGuide2 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 15,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_RECORD_CLICK_ITEM"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionCheckClickedBackpackItemID",
          Params = {
            CheckItemID = StoreConfig.ExchangeTicketConfig.AdvancedWeaponTicket.TicketItemID
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          HighlightOutlineType = 1,
          TextID = StoreConfig.ExchangeTicketConfig.AdvancedWeaponTicket.TipTextID,
          AttachParentWindow = "PickUpItemTips",
          AttachParentSlot = "GridPanel_0",
          RegisterButtonName = "GridPanel_0"
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_RECORD_CLICK_ITEM"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionCheckClickedBackpackItemID",
          Params = {
            CheckItemID = StoreConfig.ExchangeTicketConfig.AdvancedWeaponTicket.TicketItemID,
            IsNot = true
          }
        }
      }
    }
  },
  AdvancedWeaponTicketTip = {
    GuideGroup = Enums_GuidGroup.Normal,
    TotalTriggerRound = StoreConfig.ExchangeTicketConfig.AdvancedWeaponTicket.TipTimes or 3,
    SingleRoundTriggerNumber = 1,
    TriggerIntervalTime = 0,
    TriggerDelayTime = 0.1,
    RuningMaxTime = 5,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_UPDATE_ITEM_LIST"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionHasItemInBackpack",
          Params = {
            CheckItemList = {
              StoreConfig.ExchangeTicketConfig.AdvancedWeaponTicket.TicketItemID
            },
            BackpackSoreArea = 0
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPopTips",
        Params = {
          TipID = StoreConfig.ExchangeTicketConfig.AdvancedWeaponTicket.TipTextID,
          TipIntervalTime = 1,
          TipType = 0,
          TipMaxCount = 1,
          bShowTipImmediately = true
        }
      }
    }
  },
  ReviveTicketTip = {
    GuideGroup = Enums_GuidGroup.Normal,
    TotalTriggerRound = StoreConfig.ExchangeTicketConfig.ReviveTicket.TipTimes or 3,
    SingleRoundTriggerNumber = 1,
    TriggerIntervalTime = 0,
    TriggerDelayTime = 0.1,
    RuningMaxTime = 5,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_BACKPACK_UPDATE_ITEM_LIST"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionHasItemInBackpack",
          Params = {
            CheckItemList = {
              StoreConfig.ExchangeTicketConfig.ReviveTicket.TicketItemID
            },
            BackpackSoreArea = 0
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPopTips",
        Params = {
          TipID = StoreConfig.ExchangeTicketConfig.ReviveTicket.TipTextID,
          TipIntervalTime = 1,
          TipType = 0,
          TipMaxCount = 1,
          bShowTipImmediately = true
        }
      }
    }
  },
  WeaponFeatureTip = {
    GuideGroup = Enums_GuidGroup.Normal,
    TotalTriggerRound = 3,
    SingleRoundTriggerNumber = 1,
    TriggerIntervalTime = 0,
    TriggerDelayTime = 0.1,
    RuningMaxTime = 5,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_WEAPONDETIAL_BACKPACK_WeaponFeature_HAS_SHOWED"
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionHasWeaponInBackpack",
          Params = {}
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "CanvasPanel_DetailGuide",
          RegisterButtonName = "Button_Detail",
          TextID = 33020034
        }
      }
    }
  },
  EnterGamePromotionGuide = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 99999,
    SingleRoundTriggerNumber = 1,
    MaxPlayerLv = 999,
    RuningMaxTime = -1,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_NORMAL",
          EVENTID = "EVENTID_GAME_MODE_STATE_CHANGE",
          Conditions = {
            [1] = "ReadyState"
          }
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsInGameStatus",
          Params = {
            LegalGameStat = {"ReadyState"}
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowEntireUI",
        Params = {
          UIConfigName = "EnterGamePromotionNotice"
        }
      }
    },
    EndEventExtra = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_NORMAL",
          EVENTID = "EVENTID_GAME_MODE_STATE_CHANGE",
          Conditions = {
            [1] = "FightingState"
          }
        }
      }
    }
  },
  ScorpionVehicleSkillTip = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 3,
    SingleRoundTriggerNumber = 1,
    TriggerIntervalTime = 0,
    TriggerDelayTime = 0.1,
    RuningMaxTime = 5,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_VEHICLE",
          EVENTID = "EVENTID_SCORPION_VEHICLE_UI_SHOWED",
          Conditions = {
            [1] = true
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          TextID = 81563,
          HighlightOutlineType = 0,
          GetButtonAndSlotFunc = function()
            local ScorpionControlUI = UIManager.GetUI(UIManager.UI_Config_InGame.ScorpionControlUI)
            if not ScorpionControlUI then
              return nil, nil
            end
            local StealthSkillID = 4200006
            local StealthSkillUI = ScorpionControlUI:GetSkillUIBySkillID(StealthSkillID)
            if not StealthSkillUI then
              return nil, nil
            end
            if not StealthSkillUI.UIRoot then
              return nil, nil
            end
            local CanvasPanel_Button = StealthSkillUI.UIRoot.CanvasPanel_Button
            local Button_Skill = CanvasPanel_Button and StealthSkillUI.UIRoot.Button_Skill
            if not Button_Skill then
              return nil, nil
            end
            return Button_Skill, CanvasPanel_Button
          end
        }
      }
    }
  },
  ScorpionStealthDrillOutTip = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 3,
    SingleRoundTriggerNumber = 1,
    TriggerIntervalTime = 0,
    TriggerDelayTime = 0.1,
    RuningMaxTime = 5,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_VEHICLE",
          EVENTID = "EVENTID_SCORPION_STEALTH_ACTIVATED"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          TextID = 81564,
          HighlightOutlineType = 0,
          GetButtonAndSlotFunc = function()
            local ScorpionControlUI = UIManager.GetUI(UIManager.UI_Config_InGame.ScorpionControlUI)
            if not ScorpionControlUI then
              return nil, nil
            end
            local StealthSkillID = 4200006
            local StealthSkillUI = ScorpionControlUI:GetSkillUIBySkillID(StealthSkillID)
            if not StealthSkillUI then
              return nil, nil
            end
            if not StealthSkillUI.UIRoot then
              return nil, nil
            end
            local CanvasPanel_Button = StealthSkillUI.UIRoot.CanvasPanel_Button
            local Button_Skill = CanvasPanel_Button and StealthSkillUI.UIRoot.Button_Skill
            if not Button_Skill then
              return nil, nil
            end
            return Button_Skill, CanvasPanel_Button
          end
        }
      }
    },
    EndEventExtra = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_VEHICLE",
          EVENTID = "EVENTID_SCORPION_STEALTH_END"
        }
      }
    }
  },
  ScorpionPassengerEvacuateTip = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 3,
    SingleRoundTriggerNumber = 1,
    TriggerIntervalTime = 0,
    TriggerDelayTime = 0.1,
    RuningMaxTime = 5,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_PLAYEREVENT_VEHICLE",
          EVENTID = "EVENTID_SCORPION_VEHICLE_UI_SHOWED",
          Conditions = {
            [1] = false
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          TextID = 81565,
          HighlightOutlineType = 0,
          GetButtonAndSlotFunc = function()
            local ScorpionControlUI = UIManager.GetUI(UIManager.UI_Config_InGame.ScorpionControlUI)
            if not ScorpionControlUI then
              return nil, nil
            end
            local PassengerEvacuateSkillUI = ScorpionControlUI.UIRoot.VehicleSkill_Evacuate
            if not PassengerEvacuateSkillUI then
              return nil, nil
            end
            local CanvasPanel_Button = PassengerEvacuateSkillUI.CanvasPanel_Button
            local Button_Skill = CanvasPanel_Button and PassengerEvacuateSkillUI.Button_Skill_CanPass
            if not Button_Skill then
              return nil, nil
            end
            return Button_Skill, CanvasPanel_Button
          end
        }
      }
    }
  },
  CoopVaultGuide1 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 5,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_NORMAL",
          EVENTID = "EVENTID_COOPVAULT_UI_TRIGGER_ACTIVATED"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "CooperationVaultRightUI",
          AttachParentSlot = "FireButton",
          RegisterButtonName = "FireButton",
          HighlightOutlineType = 1,
          TextID = 81551,
          ForceDirection = "RU"
        }
      }
    }
  },
  CoopVaultGuide2 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 5,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_NORMAL",
          EVENTID = "EVENTID_COOPVAULT_UI_RECEIVER_ACTIVATED"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "CoopVaultBtn",
          AttachParentSlot = "CoopVaultBtnPanel",
          RegisterButtonName = "VaultBtn",
          HighlightOutlineType = 1,
          TextID = 81557,
          ForceDirection = "RD"
        }
      }
    }
  },
  EntireMapLegendGuide = {
    GuideGroup = Enums_GuidGroup.EntireMap,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 10,
    MinPlayerLv = 6,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_MAP",
          EVENTID = "EVENTID_ENTIRE_MAP_SHOW_STATE",
          Conditions = {
            [1] = true
          }
        }
      },
      Conditions = {
        {
          LuaPath = "GameLua.GameCore.Module.NewbieGuide.Conditions.NGConditionIsHideMapLegend",
          Params = {}
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowMapLegendTip",
        Params = {
          AttachParentWindow = "EntireMapLegend",
          AttachParentSlot = "CanvasPanel_Legend",
          RegisterButtonName = "LoopScrollBox_Legend",
          TextID = 612401114,
          ForceDirection = "LU"
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_MAP",
          EVENTID = "EVENTID_ENTIRE_MAP_TOUCH"
        },
        {
          EventType = "EVENTTYPE_INGAME_MAP",
          EVENTID = "EVENTID_CHANGE_MAP_BUTTON_SHOW",
          Conditions = {
            [1] = false
          }
        }
      }
    }
  },
  EntireMapAutoLockGuide = {
    GuideGroup = Enums_GuidGroup.EntireMap,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 10,
    MinPlayerLv = 5,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_MAP",
          EVENTID = "EVENTID_ENTIRE_MAP_TOUCH"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "EntireMapWindow",
          AttachParentSlot = "CanvasPanel_AutoLock",
          RegisterButtonName = "Button_AutoLock",
          TextID = 612401115,
          ForceDirection = "RU"
        }
      }
    }
  },
  PickupGuideForTombBox = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 1,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 1,
    MinPlayerLv = 0,
    MaxPlayerLv = 5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_PICKUPGUIDE_FOR_TOMBBOX",
          Conditions = {
            [1] = true
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          TextID = 15273,
          HighlightOutlineType = 1,
          GetButtonAndSlotFunc = function()
            local PickUpListPanel = UIManager.GetUI(UIManager.UI_Config_InGame.PickUpListPanel)
            if not (PickUpListPanel and PickUpListPanel.UIRoot) or not PickUpListPanel.UIRoot.ShortcutMenu_BP then
              print(bWriteLog and "PickupGuideForTombBox:GetButtonAndSlotFunc PickUpListPanel not found")
              return nil, nil
            end
            return PickUpListPanel.UIRoot.ShortcutMenu_BP.PickUpBtnItem_BP.CanvasPanel_PickUpBtnItemGuide, PickUpListPanel.UIRoot.ShortcutMenu_BP.PickUpBtnItem_BP.CanvasPanel_PickUpBtnItemGuide
          end
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_BACKPACK",
          EVENTID = "EVENTID_PICKUPGUIDE_FOR_TOMBBOX",
          Conditions = {
            [1] = false
          }
        }
      }
    }
  },
  TacticalSpreadBtnGuide = {
    GuideGroup = Enums_GuidGroup.Parachute,
    TotalTriggerRound = 10,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 10,
    EndExtraNumber = 1,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_PARACHUTING",
          EVENTID = "EVENTID_PARACHUTING_SHOW_TACTICAL_SPREAD_BTN"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ingame",
          AttachParentSlot = "CustomPanel_Disband",
          RegisterButtonName = "Button_TacticalSpread",
          bEnableCircleEffect = true,
          HighlightOutlineType = 0,
          ClickEndReason = "RecieveEndEventExtra",
          TextID = 817401
        }
      }
    }
  },
  MicrophoneUseGuide = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 3,
    SingleRoundTriggerNumber = 1,
    RuningMaxTime = 15,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_UI",
          EVENTID = "EVENTID_MIC_BUTTON_SHOW"
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowCustomUI",
        Params = {
          GuideCanvasTag = "CanvasPanel_MicrophoneGuide",
          CustomUIPath = "/Game/BluePrints/ControlInput/NewbieItem/MicrophoneGuide_UIBP.MicrophoneGuide_UIBP_C",
          TextBlockName = "TextBlock_GuideText",
          nTextId = 87632
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_UI",
          EVENTID = "EVENTID_MIC_BUTTON_TOUCH_END"
        }
      }
    }
  }
}
return NewbieGuide