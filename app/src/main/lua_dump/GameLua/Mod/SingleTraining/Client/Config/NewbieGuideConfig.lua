local NewbieGuide = {
  SingleTraining002 = {
    GuideGroup = Enums_GuidGroup.Unique,
    TotalTriggerRound = 999,
    TriggerDelayTime = 0.1,
    SingleRoundTriggerNumber = 3,
    RuningMaxTime = 0,
    EndExtraNumber = 1,
    MinPlayerLv = 0,
    MaxPlayerLv = 999,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_SOUND_BTN_FIRST_SHOW"
        }
      },
      Conditions = {}
    },
    Actions = {
      {
        LuaPath = "GameLua.GameCore.Module.NewbieGuide.Actions.NGActionShowUI",
        Params = {
          AttachParentWindow = "SingleTraining_Sound_Btn",
          AttachParentSlot = "CanvasPanel_5",
          RegisterButtonName = "Button_6",
          HighlightOutlineType = 0,
          bEnableCircleEffect = false,
          TextID = -1,
          RegisterButtonEventName = "OnClicked",
          ClickEndReason = "ButtonClick",
          ForceDirection = "LU"
        }
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EVENTID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = "SingleTraining002"
          }
        }
      }
    }
  }
}
return NewbieGuide