local ConfigUGC = require("client.slua.logic.ugc.config_ugc")
local Util_UGC = require("client.slua.logic.ugc.util_ugc")
local NEWBIE_LEVEL_ID = 106
local config_teachinglevel_guide_flow_new = {
  [ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_1] = {
    DelayTime = 0.5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_CONTINUE_GUIDE",
          Conditions = {
            [1] = NEWBIE_LEVEL_ID
          }
        }
      }
    },
    bRepeated = true,
    bRepeatedOnAborted = true,
    Condition = function()
      return true
    end,
    AfterActionEnded = function()
      local LogicUGCCCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
      local listData = LogicUGCCCenter:GetNoviceTeachingData()
      if listData[6] ~= nil and listData[6].MissionProgress == 0 then
        LogicUGCCCenter:ReqGetTeachingLevelAward(NEWBIE_LEVEL_ID, true, true)
      end
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomFunction",
      Params = {
        Function = function()
          UIManager.ShowUI(UIManager.UI_Config.ugc_mine_main)
          local time_ticker = require("common.time_ticker")
          time_ticker.AddTimer(2, function()
            local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
            local ui = UIManager.ShowUI(UIManager.UI_Config.ugc_mine_edit_noromal_work, LogicUGCCRUD.NewBieModSlot)
          end)
        end
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_CUSTOMFUNCTION_FINISHED"
        }
      }
    },
    AbortEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_DAEMON_UI_HIDDEN",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_1
          }
        }
      }
    }
  },
  [ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_2] = {
    DelayTime = 4,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_END",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_1
          }
        }
      }
    },
    bRepeated = true,
    bRepeatedOnAborted = true,
    Condition = function()
      return true
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local ui = UIManager.GetUI(UIManager.UI_Config.ugc_mine_edit_noromal_work)
          return ui.UIRoot.CanvasPanel_Name
        end,
        BubbleConfigID = 31
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_2
          }
        }
      }
    }
  },
  [ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_3] = {
    DelayTime = 0,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_END",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_2
          }
        }
      }
    },
    bRepeated = true,
    bRepeatedOnAborted = true,
    Condition = function()
      return true
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local ui = UIManager.GetUI(UIManager.UI_Config.ugc_mine_edit_noromal_work)
          return ui.UIRoot.CanvasPanel_Desc
        end,
        BubbleConfigID = 32
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_3
          }
        }
      }
    }
  },
  [ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_4] = {
    DelayTime = 0,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_END",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_3
          }
        }
      }
    },
    bRepeated = true,
    bRepeatedOnAborted = true,
    Condition = function()
      return true
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local ui = UIManager.GetUI(UIManager.UI_Config.ugc_mine_edit_noromal_work)
          return ui.UIRoot.CanvasPanel_Tag
        end,
        BubbleConfigID = 33
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_4
          }
        }
      }
    }
  },
  [ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_5] = {
    DelayTime = 0,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_END",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_4
          }
        }
      }
    },
    bRepeated = true,
    bRepeatedOnAborted = true,
    Condition = function()
      return true
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local ui = UIManager.GetUI(UIManager.UI_Config.ugc_mine_edit_noromal_work)
          return ui.UIRoot.CanvasPanel_Picture
        end,
        BubbleConfigID = 34
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_5
          }
        }
      }
    }
  },
  [ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_6] = {
    DelayTime = 0,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_END",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_5
          }
        }
      }
    },
    bRepeated = true,
    bRepeatedOnAborted = true,
    Condition = function()
      return true
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local ui = UIManager.GetUI(UIManager.UI_Config.ugc_mine_edit_noromal_work)
          return ui.UIRoot.CanvasPanel_34
        end,
        BubbleConfigID = 35
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_6
          }
        }
      }
    }
  },
  [ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_7] = {
    DelayTime = 0,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_END",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadNewLvSix_6
          }
        }
      }
    },
    bRepeated = true,
    bRepeatedOnAborted = true,
    Condition = function()
      return true
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionPopWoWTips",
      Params = {TextID = 87643}
    }
  }
}
return config_teachinglevel_guide_flow_new