local QueueConfig = {}
local _InitSlapList = function()
  local logic_ugc_popupcheck = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_popupcheck)
  local config_ugc = require("client.slua.logic.ugc.config_ugc")
  QueueConfig = {
    {
      ui_cfg = config_ugc.MineWorksPanelTips_Sort.UGC_ColdBoot_Popup_UIBP,
      show_fun = function(data)
        UIManager.ShowUI(UIManager.UI_Config.UGC_ColdBoot_Popup_UIBP, data)
      end,
      check = logic_ugc_popupcheck.CheckShowColdBootTips,
      scene_type = config_ugc.Enum_UGCPopup_Type.MineWorksPanel.scene_type
    },
    {
      ui_cfg = config_ugc.MineWorksPanelTips_Sort.UGC_MineEverydayDataTips,
      show_fun = function(data)
        UIManager.ShowUI(UIManager.UI_Config.UGC_MineEverydayDataTips, data)
      end,
      check = logic_ugc_popupcheck.CheckShowEveryDayTips,
      scene_type = config_ugc.Enum_UGCPopup_Type.MineWorksPanel.scene_type
    },
    {
      ui_cfg = config_ugc.MineWorksPanelTips_Sort.UGC_Author_Levelup_Popup_UIBP,
      show_fun = function(data)
        UIManager.ShowUI(UIManager.UI_Config[data.config.Blueprint], data)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.MineWorksPanel.scene_type,
      check = logic_ugc_popupcheck.CheckShowLevelupTips
    },
    {
      ui_cfg = config_ugc.MineWorksPanelTips_Sort.UGC_Author_Levelup_Popup_UIBP2,
      show_fun = function(data)
        UIManager.ShowUI(UIManager.UI_Config.UGC_Author_Levelup_Popup_UIBP2, data)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.MineWorksPanel.scene_type,
      check = logic_ugc_popupcheck.CheckShowLevelupTips2
    },
    {
      ui_cfg = config_ugc.MineWorksPanelTips_Sort.UGCAuthorProgressPopUI,
      show_fun = function(data)
        UIManager.ShowUI(UIManager.UI_Config.UGCAuthorProgressPopUI, data)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.MineWorksPanel.scene_type,
      check = logic_ugc_popupcheck.CheckShowProgressTips,
      ext_event = {
        type = EVENTTYPE_UGC,
        id = EVENTID_UGC_GETAUTHORPROGRESS_RSP
      }
    },
    {
      ui_cfg = config_ugc.MineWorksPanelTips_Sort.UGC_IncentiveRevenue_AuthorReward_Guide,
      show_fun = function(data)
        UIManager.ShowUI(UIManager.UI_Config.UGC_IncentiveRevenue_AuthorReward_Guide, data)
        local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
        local Record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCWowIncentiveAuthorInspireStage) or {}
        local TimeUtil = require("client.common.time_util")
        Record.SlapShowTime = TimeUtil.GetServerTimeInSec()
        PlayerPrefsSystem.SaveTableToFile_N(Record, PlayerPrefsSystem.ePlayerPrefsType.eUGCWowIncentiveAuthorInspireStage)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.MineWorksPanel.scene_type,
      check = logic_ugc_popupcheck.CheckShowIncentiveAuthorRewardTips,
      ext_event = {
        type = EVENTTYPE_UGC,
        id = EVENTID_UGC_DATA_ACTIVEMOTIVATION_AUTHOR_INSPIRE
      }
    },
    {
      ui_cfg = config_ugc.Enum_WOW_QuickEntry_PopupPriority.UGC_Main_Intention_Panel_UI,
      show_fun = function(data)
        UIManager.ShowUI(UIManager.UI_Config.UGC_Main_Intention_Panel_UI)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.ModeSelection_Wow_UIBP.scene_type,
      check = logic_ugc_popupcheck.CheckShowIntentionUI,
      quit_queue = true,
      ext_event = {
        type = EVENTTYPE_UGC,
        id = EVENTID_UGC_INTENTION_CHECK
      }
    },
    {
      ui_cfg = config_ugc.Enum_WOW_QuickEntry_PopupPriority.UGC_AutoTranslate_Popup_UIBP,
      show_fun = function(data)
        UIManager.ShowUI(UIManager.UI_Config.UGC_AutoTranslate_Popup_UIBP, data)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.ModeSelection_Wow_UIBP.scene_type,
      quit_queue = true,
      check = logic_ugc_popupcheck.CheckShowAutoTranslateWOWQuickEnterUI
    },
    {
      ui_cfg = config_ugc.Enum_WOW_QuickEntry_PopupPriority.UGC_FaceSlap_Popup_UIBP,
      show_fun = function(data)
        local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
        Logic_UGC.bFaceSlapShowing = true
        UIManager.ShowUI(UIManager.UI_Config.UGC_FaceSlap_Popup_UIBP, nil, data)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.ModeSelection_Wow_UIBP.scene_type,
      check = logic_ugc_popupcheck.CheckShowFaceSlapWOWQuickEnteyUI
    },
    {
      ui_cfg = config_ugc.Enum_WOW_QuickEntry_PopupPriority.UGC_WOW_PASS_Pop_BuyPassGuide,
      show_fun = function(data)
        local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
        logic_ugc_WOWPass:OpenWowPassPanel(UIManager.UI_Config.UGC_WOW_PASS_Pop_BuyPassGuide)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.ModeSelection_Wow_UIBP.scene_type,
      check = logic_ugc_popupcheck.CheckShowWOWPassPopup,
      ext_event = {
        type = EVENTTYPE_UGC,
        id = EVENTID_UGC_WOW_PASS_BUY_GUIDE_RSP
      }
    },
    {
      ui_cfg = config_ugc.Enum_WOW_QuickEntry_PopupPriority.UGC_WoWPass_Cover_UIBP,
      show_fun = function(data)
        local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
        logic_ugc_WOWPass:OpenWowPassPanel(UIManager.UI_Config.UGC_WoWPass_Cover_UIBP)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.ModeSelection_Wow_UIBP.scene_type,
      check = logic_ugc_popupcheck.CheckShowWOWPassTogetherPopup,
      ext_event = {
        type = EVENTTYPE_UGC,
        id = EVENTID_UGC_WOW_PASS_BUY_GUIDE_RSP
      }
    },
    {
      ui_cfg = config_ugc.Enum_WOW_QuickEntry_PopupPriority.UGC_CrystalIncentive_Popup_UIBP,
      show_fun = function(data)
        local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
        local TimeUtil = require("client.common.time_util")
        PlayerPrefsSystem.SaveTableToFile_N({
          show_time = TimeUtil.GetServerTimeInSec()
        }, PlayerPrefsSystem.ePlayerPrefsType.eUGCCrystalIncentivePopup)
        local TitleText = LocUtil.GetLocalizeResStr(1050405)
        local ugc_crystal_popup_cfg = require("client.slua.logic.creator.ugc_crystal_popup_cfg")
        UIManager.ShowUI(UIManager.UI_Config.UGC_CrystalIncentive_Popup_UIBP, TitleText, ugc_crystal_popup_cfg, nil, true, true)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.ModeSelection_Wow_UIBP.scene_type,
      check = logic_ugc_popupcheck.CheckShowCrystalPopup
    },
    {
      ui_cfg = config_ugc.Enum_WOW_QuickEntry_PopupPriority.UGC_ThemePlay_ActivityTemplate_FaceSlap_UIBP,
      show_fun = function(data)
        local Logic_UGC_ThemePlay_ActivityTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_theme_play_activity_template)
        local firstValidActID = Logic_UGC_ThemePlay_ActivityTemplate:GetFirstValidActivityID()
        UIManager.ShowUI(UIManager.UI_Config.UGC_ThemePlay_ActivityTemplate_FaceSlap_UIBP, firstValidActID)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.ModeSelection_Wow_UIBP.scene_type,
      check = logic_ugc_popupcheck.CheckShowThemePlayActivityTemplateFaceSlap
    },
    {
      ui_cfg = config_ugc.Enum_WOW_PopupPriority.UGC_Main_Intention_Panel_UI,
      show_fun = function(data)
        UIManager.ShowUI(UIManager.UI_Config.UGC_Main_Intention_Panel_UI)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.ModeSelection_Main_UIBP.scene_type,
      check = logic_ugc_popupcheck.CheckShowIntentionUI,
      quit_queue = true,
      ext_event = {
        type = EVENTTYPE_UGC,
        id = EVENTID_UGC_INTENTION_CHECK
      }
    },
    {
      ui_cfg = config_ugc.Enum_WOW_PopupPriority.UGC_AutoTranslate_Popup_UIBP,
      show_fun = function(data)
        UIManager.ShowUI(UIManager.UI_Config.UGC_AutoTranslate_Popup_UIBP, data)
      end,
      quit_queue = true,
      scene_type = config_ugc.Enum_UGCPopup_Type.ModeSelection_Main_UIBP.scene_type,
      check = logic_ugc_popupcheck.CheckShowAutoTranslateWOWUI
    },
    {
      ui_cfg = config_ugc.Enum_WOW_PopupPriority.UGC_FaceSlap_Popup_UIBP,
      show_fun = function(data)
        local Logic_UGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
        Logic_UGC.bFaceSlapShowing = true
        UIManager.ShowUI(UIManager.UI_Config.UGC_FaceSlap_Popup_UIBP, nil, data)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.ModeSelection_Main_UIBP.scene_type,
      check = logic_ugc_popupcheck.CheckShowFaceSlapWOWUI
    },
    {
      ui_cfg = config_ugc.Enum_WOW_PopupPriority.UGC_WOW_PASS_Pop_BuyPassGuide,
      show_fun = function(data)
        local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
        logic_ugc_WOWPass:OpenWowPassPanel(UIManager.UI_Config.UGC_WOW_PASS_Pop_BuyPassGuide)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.ModeSelection_Main_UIBP.scene_type,
      check = logic_ugc_popupcheck.CheckShowWOWPassPopup,
      ext_event = {
        type = EVENTTYPE_UGC,
        id = EVENTID_UGC_WOW_PASS_BUY_GUIDE_RSP
      }
    },
    {
      ui_cfg = config_ugc.Enum_WOW_PopupPriority.UGC_WoWPass_Cover_UIBP,
      show_fun = function(data)
        local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
        logic_ugc_WOWPass:OpenWowPassPanel(UIManager.UI_Config.UGC_WoWPass_Cover_UIBP)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.ModeSelection_Main_UIBP.scene_type,
      check = logic_ugc_popupcheck.CheckShowWOWPassTogetherPopup,
      ext_event = {
        type = EVENTTYPE_UGC,
        id = EVENTID_UGC_WOW_PASS_BUY_GUIDE_RSP
      }
    },
    {
      ui_cfg = config_ugc.Enum_WOW_PopupPriority.UGC_CrystalIncentive_Popup_UIBP,
      show_fun = function(data)
        local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
        local TimeUtil = require("client.common.time_util")
        PlayerPrefsSystem.SaveTableToFile_N({
          show_time = TimeUtil.GetServerTimeInSec()
        }, PlayerPrefsSystem.ePlayerPrefsType.eUGCCrystalIncentivePopup)
        local TitleText = LocUtil.GetLocalizeResStr(1050405)
        local ugc_crystal_popup_cfg = require("client.slua.logic.creator.ugc_crystal_popup_cfg")
        UIManager.ShowUI(UIManager.UI_Config.UGC_CrystalIncentive_Popup_UIBP, TitleText, ugc_crystal_popup_cfg, nil, true, true)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.ModeSelection_Main_UIBP.scene_type,
      check = logic_ugc_popupcheck.CheckShowCrystalPopup
    },
    {
      ui_cfg = config_ugc.Enum_WOW_PopupPriority.UGC_ThemePlay_ActivityTemplate_FaceSlap_UIBP,
      show_fun = function(data)
        local Logic_UGC_ThemePlay_ActivityTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_theme_play_activity_template)
        local firstValidActID = Logic_UGC_ThemePlay_ActivityTemplate:GetFirstValidActivityID()
        UIManager.ShowUI(UIManager.UI_Config.UGC_ThemePlay_ActivityTemplate_FaceSlap_UIBP, firstValidActID)
      end,
      scene_type = config_ugc.Enum_UGCPopup_Type.ModeSelection_Main_UIBP.scene_type,
      check = logic_ugc_popupcheck.CheckShowThemePlayActivityTemplateFaceSlap
    }
  }
end
_InitSlapList()
return QueueConfig