local NewbieGuideConfig = {
  FlyingWingItemGuide = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 5,
    SingleRoundTriggerNumber = 1,
    TriggerIntervalTime = 0,
    TriggerDelayTime = 0.1,
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
            [1] = 44060803
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPostEvent",
        Params = {
          StartEventType = "EVENTTYPE_INGAME_BACKPACK",
          StartEventID = "EVENTID_BACKPACK_SELECT_THEME_PROP_BY_ID",
          StartEventParam1 = 44060803
        }
      },
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ThemePropsChooseWidgetNew",
          AttachParentSlot = "CanvasPanel_RingThrowNewBie",
          RegisterButtonName = "Button_RingThrowGuide",
          TextID = 4404045,
          HighlightOutlineType = 1,
          ForceDirection = "RU"
        }
      }
    }
  },
  FlyingWingTowerItemGuide = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 10,
    SingleRoundTriggerNumber = 1,
    TriggerIntervalTime = 0,
    TriggerDelayTime = 0.1,
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
            [1] = 44060804
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPostEvent",
        Params = {
          StartEventType = "EVENTTYPE_INGAME_BACKPACK",
          StartEventID = "EVENTID_BACKPACK_SELECT_THEME_PROP_BY_ID",
          StartEventParam1 = 44060804
        }
      },
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "ThemePropsChooseWidgetNew",
          AttachParentSlot = "CanvasPanel_RingThrowNewBie",
          RegisterButtonName = "Button_RingThrowGuide",
          TextID = 4404046,
          HighlightOutlineType = 1,
          ForceDirection = "RU"
        }
      }
    }
  },
  FlyingWingTowerMoveGuide = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 10,
    SingleRoundTriggerNumber = 1,
    TriggerIntervalTime = 0,
    TriggerDelayTime = 0.1,
    RuningMaxTime = 5,
    EndExtraNumber = nil,
    MinPlayerLv = 0,
    MaxPlayerLv = 9999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_SKILLCORE_NORMAL",
          EVENTID = "EVENTID_FLYINGWING_SKILL_PHASE_CHANGE",
          Conditions = {
            [1] = 4401006,
            [2] = 3
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowCustomUI",
        Params = {
          GuideCanvasTag = "NewbieGuide_MainControlMoveJoyStick",
          CustomUIPath = "/Game/BluePrints/ControlInput/NewbieItem/120NewbieTips_Joystick.120NewbieTips_Joystick_C"
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_MOVE_JOY_STICK"
        }
      }
    }
  },
  LightningRushItemGuide = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 999999,
    SingleRoundTriggerNumber = 1,
    TriggerIntervalTime = 0,
    TriggerDelayTime = 0.1,
    RuningMaxTime = 5,
    EndExtraNumber = nil,
    MinPlayerLv = 0,
    MaxPlayerLv = 9999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_SKILL",
          EVENTID = "EVENTID_INGAME_SKILL_BTN_INIT",
          Conditions = {
            [1] = 4401007
          }
        }
      }
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionPostEvent",
        Params = {
          StartEventType = "EVENTTYPE_SKILLCORE_NORMAL",
          StartEventID = "EVENTID_LIGHTNINGRUSH_DIFFUSION",
          EndEventType = "EVENTTYPE_SKILLCORE_NORMAL",
          EndEventID = "EVENTID_LIGHTNINGRUSH_DIFFUSION_END"
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_INGAME_SKILL",
          EVENTID = "EVENTID_INGAME_SKILL_BTN_UI_DOWN",
          Conditions = {
            [1] = 4401007
          }
        }
      }
    }
  },
  BattleFlagArmorGuide = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 999999,
    SingleRoundTriggerNumber = 999999,
    TriggerIntervalTime = 0,
    TriggerDelayTime = 0.1,
    RuningMaxTime = 5,
    EndExtraNumber = nil,
    MinPlayerLv = 0,
    MaxPlayerLv = 9999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_BATTLEFLAG_ARMOR"
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
          TextID = 4404035,
          HighlightOutlineType = 1,
          ForceDirection = "LU"
        }
      }
    }
  },
  GodTrialFaceIntroGuide = {
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
          UIConfigName = "EnterGameFaceGuide"
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
  }
}
return NewbieGuideConfig