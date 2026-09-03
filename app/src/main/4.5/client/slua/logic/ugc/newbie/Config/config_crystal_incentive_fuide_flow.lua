local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local Util_UGC = require("client.slua.logic.ugc.util_ugc")
local guide_flow_config = {
  [Config_UGC.Newbie_Guide_Type_Key.UGCCrystalIncentiveJoinGuide] = {
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.UGCCrystalIncentiveJoinGuide
          }
        }
      }
    },
    DelayTime = 0.5,
    Condition = function()
      local LogicUGCCrystalIncentive = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_crystal_incentive)
      if LogicUGCCrystalIncentive:CheckShowJoinGuide() then
        return true
      end
      return false
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local UIUtil = require("client.common.ui_util")
          local UIConfig = UIManager.UI_Config.UGC_Center_CrystalIncentive
          local UI = UIManager.GetUI(UIConfig)
          if UI and UIUtil.IsValid(UI.UIRoot.Button_OK) then
            return UI.UIRoot.Button_OK, UI
          end
        end,
        BubbleConfigID = 24
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.UGCCrystalIncentiveJoinGuide
          }
        }
      }
    }
  },
  [Config_UGC.Newbie_Guide_Type_Key.UGCCrystalIncentiveWithdrawalGuide] = {
    DelayTime = 0.5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.UGCCrystalIncentiveWithdrawalGuide
          }
        }
      }
    },
    Condition = function()
      local LogicUGCCrystalIncentive = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_crystal_incentive)
      if LogicUGCCrystalIncentive:CheckWithdrawalGuide() then
        return true
      end
      return false
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local UIUtil = require("client.common.ui_util")
          local UIConfig = UIManager.UI_Config.UGC_Center_CrystalIncentive
          local UI = UIManager.GetUI(UIConfig)
          if UI and UIUtil.IsValid(UI.UIRoot.Button_CashWithdrawl) then
            return UI.UIRoot.Button_CashWithdrawl, UI
          end
        end,
        BubbleConfigID = 25
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.UGCCrystalIncentiveWithdrawalGuide
          }
        }
      }
    }
  },
  [Config_UGC.Newbie_Guide_Type_Key.UGCCrystalIncentivePayPropGuide] = {
    DelayTime = 0.5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.UGCCrystalIncentivePayPropGuide
          }
        }
      }
    },
    Condition = function()
      local LogicUGCCrystalIncentive = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_crystal_incentive)
      if LogicUGCCrystalIncentive:CheckShowPayPropGuide() then
        return true
      end
      return false
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local UIUtil = require("client.common.ui_util")
          local UIConfig = UIManager.UI_Config.UGC_Center_CrystalIncentive
          local UI = UIManager.GetUI(UIConfig)
          if UI and UIUtil.IsValid(UI.UIRoot.Button_CreateWork) then
            return UI.UIRoot.Button_CreateWork, UI
          end
        end,
        BubbleConfigID = 26
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.UGCCrystalIncentivePayPropGuide
          }
        }
      }
    }
  }
}
return guide_flow_config