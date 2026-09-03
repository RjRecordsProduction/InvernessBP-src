local Config_UGC = require("client.slua.logic.ugc.config_ugc")
local Util_UGC = require("client.slua.logic.ugc.util_ugc")
local guide_flow_config = {
  [Config_UGC.Newbie_Guide_Type_Key.EnterGameNewbieTheme] = {
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_END",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.EnterGameNewbieThemeTip
          }
        }
      }
    },
    Condition = function()
      local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
      if logic_ugc_newbie_guide and logic_ugc_newbie_guide:IsEnterGameUGCNewbieGuideOn() then
        return true
      end
      return false
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local UIConfig
          if Config_UGC.NewWOWHall ~= 2 then
            UIConfig = UIManager.UI_Config.UGC_Lobby_HotTheme_UIBP
          else
            UIConfig = UIManager.UI_Config.New_UGC_Main_Lobby_HotTheme_UIBP
          end
          local ui = UIManager.GetUI(UIConfig)
          if ui then
            ui:ScrollToFirstTheme()
            local uictrl = ui:GetCurFirstThemeGuideItem()
            return uictrl.UIRoot, uictrl
          end
        end,
        BubbleConfigID = 7
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "UGCDetailInfoSubPanel"
          }
        }
      }
    }
  },
  [Config_UGC.Newbie_Guide_Type_Key.EnterGameNewbieThemeTip] = {
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "UGC_Lobby_HotTheme_UIBP_First_Theme"
          }
        }
      }
    },
    Condition = function()
      local UI = UIManager.GetUI(UIManager.UI_Config.mode_selection_main)
      if UI and UI.bHasOverlayUI then
        print(bWriteLog and "[NewbieGuide] mode_selection_main has overlay UI")
        return false
      end
      local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
      if logic_ugc_newbie_guide and logic_ugc_newbie_guide:IsEnterGameUGCNewbieGuideOn() then
        return true
      end
      return false
    end,
    OnStepTick = function(Step)
      print(bWriteLog and "Config_UGC.Newbie_Guide_Type_Key.EnterGameNewbieThemeTip [NewbieGuide] OnStepTick")
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
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionPopWoWTips",
      Params = {TextID = 9604006}
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.EnterGameNewbieThemeTip
          }
        }
      }
    }
  },
  [Config_UGC.Newbie_Guide_Type_Key.EnterGameOpenDetail] = {
    DelayTime = 0.5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "UGCDetailInfoSubPanel"
          }
        }
      }
    },
    bRepeatedOnAborted = true,
    Condition = function()
      local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
      if logic_ugc_newbie_guide and logic_ugc_newbie_guide:IsEnterGameUGCNewbieGuideOn() and Util_UGC.IsUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.EnterGameNewbieTheme) then
        local UIConfig = UIManager.UI_Config.UGCDetailMainPanel
        local UI = UIManager.GetUI(UIConfig)
        if UI then
          local opsubpanel = UI.insUGCLobbyDetailOperate
          if opsubpanel then
            return not opsubpanel:IsAtDownloadStatus()
          end
        else
          return false
        end
      end
      return false
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local UIConfig = UIManager.UI_Config.UGCDetailMainPanel
          local UI = UIManager.GetUI(UIConfig)
          if UI then
            local opsubpanel = UI.subUIs[1]
            return opsubpanel.UIRoot.Button_StarGame, opsubpanel
          end
        end,
        BubbleConfigID = 8
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.EnterGameOpenDetail
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
            [1] = Config_UGC.Newbie_Guide_Type_Key.EnterGameOpenDetail
          }
        }
      }
    }
  },
  [Config_UGC.Newbie_Guide_Type_Key.EnterGameOpenDetailDownloadRes] = {
    DelayTime = 0.5,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "UGCDetailInfoSubPanel"
          }
        }
      }
    },
    bRepeatedOnAborted = true,
    Condition = function()
      local logic_ugc_newbie_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_newbie_guide)
      if logic_ugc_newbie_guide and logic_ugc_newbie_guide:IsEnterGameUGCNewbieGuideOn() and Util_UGC.IsUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.EnterGameNewbieTheme) then
        local UIConfig = UIManager.UI_Config.UGCDetailMainPanel
        local UI = UIManager.GetUI(UIConfig)
        if UI then
          local opsubpanel = UI.insUGCLobbyDetailOperate
          if opsubpanel then
            return opsubpanel:IsAtDownloadStatus()
          end
        else
          return false
        end
      end
      return false
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local UIConfig = UIManager.UI_Config.UGCDetailMainPanel
          local UI = UIManager.GetUI(UIConfig)
          if UI then
            local opsubpanel = UI.subUIs[1]
            local downloadPanel = opsubpanel.UIRoot.CanvasPanelDownload
            if downloadPanel then
              local downloadBtn = downloadPanel:GetChildAt(0)
              if downloadBtn then
                return downloadBtn.Button_LoadState, opsubpanel
              end
            end
          end
        end,
        BubbleConfigID = 10
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.EnterGameOpenDetailDownloadRes
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
            [1] = Config_UGC.Newbie_Guide_Type_Key.EnterGameOpenDetailDownloadRes
          }
        }
      }
    }
  },
  [Config_UGC.Newbie_Guide_Type_Key.EnterGameWoWModeATestEnd] = {
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_UGC",
          EventID = "EVENTID_UGC_NEWBIE_AFTERENTERGAME",
          Conditions = {
            [1] = Config_UGC.C_EnterGameNewbieScheme.A_NoMoreGuidance
          }
        }
      }
    },
    Condition = function()
      return true
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionEndWoWEnterGuide",
      Params = {}
    },
    EndEvent = {}
  },
  [Config_UGC.Newbie_Guide_Type_Key.CustomPhotoEdit] = {
    DelayTime = 1,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "UI_UGC_Mine_Photo"
          }
        }
      }
    },
    Condition = function()
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      if PublishRegionMacros.IsBLUEHOLE() then
        return false
      end
      local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
      local ModeList = LogicUGCCRUD:GetModeList()
      if #ModeList <= 0 then
        return false
      else
        return DataMgr.ugc_author_info.custom_pic_auth
      end
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local UIConfig = UIManager.UI_Config.ugc_mine_photo
          local UI = UIManager.GetUI(UIConfig)
          if not UI then
            return
          end
          local ReuseListMultiSize = UI.ReuseListMultiSize
          if not ReuseListMultiSize then
            return
          end
          local Photo_Item = ReuseListMultiSize:GetIndexOfWidget(1)
          if Photo_Item then
            return Photo_Item.CanvasPanel_Upload, Photo_Item
          end
        end,
        BubbleConfigID = 18
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "UgcCustomPhotoAlbumPanel"
          }
        }
      }
    }
  },
  [Config_UGC.Newbie_Guide_Type_Key.UGCDataCenterNewbieGuide] = {
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "UGCDataCenterNewbieGuide"
          }
        }
      }
    },
    Condition = function()
      local UIUtil = require("client.common.ui_util")
      local UIConfig = UIManager.UI_Config.ugc_mine_works
      local UI = UIManager.GetUI(UIConfig)
      if UI and UIUtil.IsValid(UI.UIRoot.WidgetSwitcher_Tips) and UI.UIRoot.WidgetSwitcher_Tips.ActiveWidgetIndex == 0 then
        return true
      end
      return false
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local UIUtil = require("client.common.ui_util")
          local UIConfig = UIManager.UI_Config.ugc_mine_works
          local UI = UIManager.GetUI(UIConfig)
          if UI and UIUtil.IsValid(UI.UIRoot.Button_DataCenter) then
            return UI.UIRoot.Button_DataCenter, UI
          end
        end,
        BubbleConfigID = 19
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = "UGCDataCenterNewbieGuide"
          }
        }
      }
    }
  },
  [Config_UGC.Newbie_Guide_Type_Key.UGCActiveMotivationRewardGuide1] = {
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "UGCActiveMotivationRewardGuide1"
          }
        }
      }
    },
    Condition = function()
      return true
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local UIUtil = require("client.common.ui_util")
          local UIConfig = UIManager.UI_Config.UGC_Center_Wallet
          local UI = UIManager.GetUI(UIConfig)
          if UI and UIUtil.IsValid(UI.UIRoot.TextBlock_Balance) then
            return UI.UIRoot.TextBlock_Balance, UI
          end
        end,
        BubbleConfigID = 20
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = "UGCActiveMotivationRewardGuide1"
          }
        }
      }
    }
  },
  [Config_UGC.Newbie_Guide_Type_Key.UGCActiveMotivationRewardGuide2] = {
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "UGCActiveMotivationRewardGuide2"
          }
        }
      }
    },
    Condition = function()
      return true
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local UIUtil = require("client.common.ui_util")
          local UIConfig = UIManager.UI_Config.UGC_Center_Main
          local UI = UIManager.GetUI(UIConfig)
          if UI and UI.Common_Tab then
            local Config_UGC_Center = require("client.slua.logic.ugc.center.config_ugc_center")
            local Index = UI:GetTabIndexByID(Config_UGC_Center.Config_UGC_Center_TabID.IncentivePlan)
            local aaa = UI.Common_Tab.ExtendedLoopScrollBox_Tab:GetIndexOfWidget(Index)
            return aaa, UI
          end
        end,
        BubbleConfigID = 21
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = "UGCActiveMotivationRewardGuide2"
          }
        }
      }
    }
  },
  [Config_UGC.Newbie_Guide_Type_Key.UGCPropShopNewbieGuide] = {
    DelayTime = 0.1,
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "UGCPropShopNewbieGuide"
          }
        }
      }
    },
    Condition = function()
      local UIUtil = require("client.common.ui_util")
      local UIConfig = UIManager.UI_Config.UGCDetailMainPanel
      local UI = UIManager.GetUI(UIConfig)
      if UI then
        local Config_UGC = require("client.slua.logic.ugc.config_ugc")
        local PropShopUI = UI.subUIs[Config_UGC.Config_UGC_DetailTabID.PropShop]
        if PropShopUI and PropShopUI.ShopTabList then
          local Index = PropShopUI.ShopTabList:GetSelectedIndex()
          if Index and PropShopUI.GoodsList and PropShopUI.GoodsList[Index] and #PropShopUI.GoodsList[Index] > 0 then
            return true
          end
        end
      end
      return false
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local UIUtil = require("client.common.ui_util")
          local UIConfig = UIManager.UI_Config.UGCDetailMainPanel
          local UI = UIManager.GetUI(UIConfig)
          if UI then
            local Config_UGC = require("client.slua.logic.ugc.config_ugc")
            local PropShopUI = UI.subUIs[Config_UGC.Config_UGC_DetailTabID.PropShop]
            if PropShopUI and PropShopUI.PropGoodsScrollGrid then
              local Item = PropShopUI.PropGoodsScrollGrid:GetIndexOfWidget(1)
              local IsTextMirror = LocUtil.IsClientTextMirror()
              local Button = IsTextMirror and Item.WidgetSwitcher_3 or Item.WidgetSwitcher_BuyBtn
              if Item and Button then
                return Button, Item
              end
            end
          end
        end,
        BubbleConfigID = 22
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = "UGCPropShopNewbieGuide"
          }
        }
      }
    }
  },
  [Config_UGC.Newbie_Guide_Type_Key.UGCWalletMoneyNewbieGuide] = {
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "UGCWalletMoneyNewbieGuide"
          }
        }
      }
    },
    Condition = function()
      return true
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local UIUtil = require("client.common.ui_util")
          local UIConfig = UIManager.UI_Config.UGC_Center_Wallet
          local UI = UIManager.GetUI(UIConfig)
          if UI and UIUtil.IsValid(UI.UIRoot.TextBlock_Balance) then
            return UI.UIRoot.Button_Make_Money, UI
          end
        end,
        BubbleConfigID = 23
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.UGCWalletMoneyNewbieGuide
          }
        }
      }
    }
  },
  [Config_UGC.Newbie_Guide_Type_Key.UGCNewFilterTag] = {
    TriggerEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_UI_OPEN",
          Conditions = {
            [1] = "UGCNewFilterTag"
          }
        }
      }
    },
    Condition = function()
      return false
    end,
    Action = {
      LuaPath = "client.slua.logic.ugc.newbie.Actions.NGLobbyActionCustomUIBubble",
      Params = {
        GetUIFunc = function()
          local UIUtil = require("client.common.ui_util")
          local UIConfig = UIManager.UI_Config.ugc_mine_edit_noromal_work
          local UI = UIManager.GetUI(UIConfig)
          if UI and UIUtil.IsValid(UI.UIRoot.Button_EditTag) then
            return UI.UIRoot.Button_EditTag, UI
          end
        end,
        BubbleConfigID = 27
      }
    },
    EndEvent = {
      Events = {
        {
          EventType = "EVENTTYPE_NEWBIE_GUIDE",
          EventID = "EVENTID_NEWBIE_GUIDE_BTN_CLICK",
          Conditions = {
            [1] = Config_UGC.Newbie_Guide_Type_Key.UGCNewFilterTag
          }
        }
      }
    }
  }
}
return guide_flow_config