local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local Util_UGC = require("client.slua.logic.ugc.util_ugc")
if IsEditor and Client then
  require("client.slua.config.ClientMacros.bp_macros")
end
local MoviesPath = "./MoviesPakDir/wow_newbie.mp4"
local guide_flow_config = {
  [Config_UGC.Newbie_Guide_Type_Key.UGCOpenTitleIntroduction] = {
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "NewbieGuideFirstIntroduction"
          }
        }
      }
    },
    Condition = function()
      local logic_ugc_new_process = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_process)
      local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
      local EnterGameNewbieThemeTipState = Util_UGC.IsUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.EnterGameNewbieThemeTip)
      if EnterGameNewbieThemeTipState then
        print(bWriteLog and "Config_UGC.Newbie_Guide_Type_Key.UGCOpenTitleIntroduction EnterGameNewbieThemeTipState is true")
        return false
      end
      if logic_ugc_new_process:CheckIsOpen() then
        local lobbyMainLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
        local curPage = lobbyMainLogic.curPage
        if curPage == ENUM_LobbyPageType.Right then
          if logic_ugc_newbie_guide and logic_ugc_newbie_guide:IsEnterWOWHallNewbieGuideOn() then
            return true
          end
          return false
        end
      end
      if logic_ugc_newbie_guide and logic_ugc_newbie_guide:IsEnterGameUGCNewbieGuideOn() then
        return true
      end
      return false
    end,
    OnStepTick = function(Step)
      print(bWriteLog and "Config_UGC.Newbie_Guide_Type_Key.UGCOpenTitleIntroduction [NewbieGuide] OnStepTick")
      local UI = UIManager.GetUI(UIManager.UI_Config.UGC_Center_Main)
      if UI then
        Step:OnAbortedEventsTriggered()
      end
      UI = UIManager.GetUI(UIManager.UI_Config.UGC_Beginner_Level_UIBP)
      if UI then
        Step:OnAbortedEventsTriggered()
      end
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionPopWoWShowUI",
      Params = {
        UIConfig = UIManager.UI_Config.UGC_WoWGudie_Introduce_UIBP
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_UI_CLOSE",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.UGCOpenTitleIntroduction
          }
        }
      }
    }
  },
  [Config_UGC.Newbie_Guide_Type_Key.EnterPlayVideo] = {
    DelayTime = 0.5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_UI_CLOSE",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.UGCOpenTitleIntroduction
          }
        }
      }
    },
    Condition = function()
      print(bWriteLog and "Config_UGC.Newbie_Guide_Type_Key.EnterPlayVideo [NewbieGuide] Condition")
      if Util_UGC.IsUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.UGCOpenTitleIntroduction) then
        print(bWriteLog and "Config_UGC.Newbie_Guide_Type_Key.EnterPlayVideo [NewbieGuide] Condition true")
        return true
      end
      return false
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionPlayUGCVideo",
      Params = {
        videoPath = MoviesPath,
        extra = {
          time = 3,
          animation = false,
          topRightClose = false,
          bRestoreLobbyMusic = true,
          bPauseOnEnd = false,
          bDoNotChangeCameraSetting = true
        },
        bMask = true
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_UI_CLOSE",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.EnterPlayVideo
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
            [1] = Config_UGC.Newbie_Guide_Type_Key.EnterPlayVideo
          }
        }
      }
    }
  },
  [Config_UGC.Newbie_Guide_Type_Key.EnterOpenRecommendedWorks] = {
    DelayTime = 0.5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_UI_CLOSE",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.EnterPlayVideo
          }
        }
      }
    },
    Condition = function()
      if Util_UGC.IsUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.EnterPlayVideo) then
        return true
      end
      return false
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionPopWoWShowUI",
      Params = {
        UIConfig = UIManager.UI_Config.UGC_WoWGudie_RecommendedWorks_UIBP
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_UI_CLOSE",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.EnterOpenRecommendedWorks
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
            [1] = Config_UGC.Newbie_Guide_Type_Key.EnterOpenRecommendedWorks
          }
        }
      }
    }
  },
  [Config_UGC.Newbie_Guide_Type_Key.EnterOpenIntention] = {
    DelayTime = 0.5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_UI_CLOSE",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.EnterOpenRecommendedWorks
          }
        }
      }
    },
    Condition = function()
      if Util_UGC.IsUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.EnterOpenRecommendedWorks) then
        return true
      end
      return false
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionPopWoWShowUI",
      Params = {
        UIConfig = UIManager.UI_Config.UGC_Main_Intention_Panel_UI
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_UI_CLOSE",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.EnterOpenIntention
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
            [1] = Config_UGC.Newbie_Guide_Type_Key.EnterOpenIntention
          }
        }
      }
    }
  }
}
return guide_flow_config