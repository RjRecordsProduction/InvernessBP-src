local ConfigUGC = require("client.slua.logic.ugc.config_ugc")
local Util_UGC = require("client.slua.logic.ugc.util_ugc")
local guide_flow_config = {
  [ConfigUGC.Newbie_Guide_Type_Key.DailyTask01] = {
    DelayTime = 0.5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "NewUGCMainPanel"
          }
        }
      }
    },
    bRepeatedOnAborted = true,
    Condition = function()
      local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
      if logic_ugc_newbie_guide and logic_ugc_newbie_guide:IsUGCNewbieGuideOn() then
        return true
      end
      return false
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionPopMaskedBubble",
      Params = {
        TargetUIName = "mode_selection_main",
        TargetWidgetName = "Button_Task",
        BubbleConfigID = 1
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.DailyTask01
          }
        }
      }
    },
    AbortEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_DAEMON_UI_HIDDEN",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.DailyTask01
          }
        }
      }
    }
  },
  [ConfigUGC.Newbie_Guide_Type_Key.DailyTaskGetAll] = {
    DelayTime = 0.5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "UGCPlayTaskUI"
          }
        }
      }
    },
    bRepeatedOnAborted = true,
    Condition = function()
      local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
      if Util_UGC.IsUGCNewbieGuideFinish(ConfigUGC.Newbie_Guide_Type_Key.DailyTask01) and logic_ugc_newbie_guide and logic_ugc_newbie_guide:HasDailyOrRPAward() then
        return true
      end
      return false
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionPopMaskedBubble",
      Params = {
        TargetUIName = "UGCPlayTaskUI",
        TargetWidgetName = "Button_GetAll",
        BubbleConfigID = 2
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.DailyTaskGetAll
          }
        }
      }
    },
    AbortEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_DAEMON_UI_HIDDEN",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.DailyTaskGetAll
          }
        }
      }
    }
  }
}
return guide_flow_config