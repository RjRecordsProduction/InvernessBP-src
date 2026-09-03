local ConfigUGC = require("client.slua.logic.ugc.config_ugc")
local Util_UGC = require("client.slua.logic.ugc.util_ugc")
local guide_flow_config = {
  [ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadLvSix_1] = {
    DelayTime = 0.5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "ugc_mine_edit_noromal_work"
          }
        }
      }
    },
    bRepeated = true,
    bRepeatedOnAborted = true,
    Condition = function()
      local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
      if logic_ugc_newbie_guide and logic_ugc_newbie_guide:IsTeachingRoadUGCLv6NewbieGuide() then
        return true
      end
      return false
    end,
    AfterActionEnded = function()
      local UIConfig = UIManager.UI_Config.ugc_mine_edit_noromal_work
      local UI = UIManager.GetUI(UIConfig)
      if UI then
        UI.UIRoot.Button_Close:SetIsEnabled(true)
        UI.UIRoot.Button_Close2:SetIsEnabled(true)
      end
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionPopMaskedBubble",
      Params = {
        TargetUIName = "ugc_mine_edit_noromal_work",
        TargetWidgetName = "ScrollBox_0",
        BubbleConfigID = 16
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadLvSix_1
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
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadLvSix_1
          }
        }
      }
    }
  },
  [ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadLvSix_2] = {
    DelayTime = 0.5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_END",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadLvSix_1
          }
        }
      }
    },
    bRepeated = true,
    bRepeatedOnAborted = true,
    Condition = function()
      local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
      if logic_ugc_newbie_guide then
        return true
      end
      return false
    end,
    AfterActionEnded = function()
      local LogicUGCCCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
      local listData = LogicUGCCCenter:GetNoviceTeachingData()
      log_tree("[v_chenxxue] listData ", listData)
      if listData[6] ~= nil and listData[6].MissionProgress == 0 then
        LogicUGCCCenter:ReqGetTeachingLevelAward(6, true, true)
        log(bWriteLog and "[v_chenxxue] LogicUGCCCenter:ReqGetTeachingLevelAward().. Level six MissionProgress == 0")
        local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
        LogicUGCAuthor:RequestAuthorInfo(DataMgr.roleData.uid)
      end
      LogicUGCCCenter:SetShowLv6Guide(false)
      local UIConfig = UIManager.UI_Config.ugc_mine_edit_noromal_work
      local UI = UIManager.GetUI(UIConfig)
      if UI then
        UI.UIRoot.Button_Close:SetIsEnabled(true)
        UI.UIRoot.Button_Close2:SetIsEnabled(true)
      end
      log(bWriteLog and "[v_chenxxue] LogicUGCCCenter:ReqGetTeachingLevelAward().. Level six MissionProgress ~= 0 ")
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local UIConfig = UIManager.UI_Config.ugc_mine_edit_noromal_work
          local UIUtil = require("client.common.ui_util")
          local UI = UIManager.GetUI(UIConfig)
          if UI and UIUtil.IsValid(UI.UIRoot.Button_Publish) then
            return UI.UIRoot.Button_Publish, UI
          end
        end,
        BubbleConfigID = 17
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadLvSix_2
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
            [1] = ConfigUGC.Newbie_Guide_Type_Key.WeakTeachingRoadLvSix_2
          }
        }
      }
    }
  }
}
return guide_flow_config