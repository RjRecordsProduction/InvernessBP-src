local PufferConst = require("client.slua.logic.download.puffer_const")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local LobbyQueuePopUIKeyDefine = require("client.slua.config.LobbyQueuePopUIKeyDefine")
local ESlateVisibility = UEnums and UEnums.ESlateVisibility or {}
local Visible = ESlateVisibility.Visible
local Collapsed = ESlateVisibility.Collapsed
require("client.slua.config.ClientMacros.bp_macros")
require("client.common.game_status")
require("client.slua.config.ClientMacros.EFixedZOrder")
require("client.slua.config.ClientMacros.UIContainers")
require("client.common.SlateUI_ID")
local setting_ui_configs = {
  setting_main = {
    keyName = "setting_main",
    moduleName = "client.slua.umg.NewSetting.Main.setting_main_base",
    path = "/Game/UMG/UI_BP/NewSetting/Setting_Main.Setting_Main",
    jumpModuleID = BP_ENUM_MODULE_SETTING,
    asy = false,
    uiStat = {
      name = "\232\174\190\231\189\174-\228\184\187\231\149\140\233\157\162"
    }
  },
  Setting_ChangeServer_remind = {
    keyName = "Setting_ChangeServer_remind",
    moduleName = "client.slua.umg.NewSetting.Account.Popup.Setting_ChangeServer_remind",
    path = "/Game/UMG/UI_BP/Setting/Setting_ChangeServer_remind.Setting_ChangeServer_remind",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\228\191\174\230\148\185\229\156\176\229\140\186\228\186\140\230\172\161\229\188\185\231\170\151"
    }
  },
  setting_graphics_new = {
    keyName = "setting_graphics_new",
    moduleName = "client.slua.umg.NewSetting.Setting_GraphicsNew_UIBP",
    path = "/Game/UMG/UI_BP/NewSetting/Setting_GraphicsNew_UIBP.Setting_GraphicsNew_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\231\148\187\233\157\162\232\174\190\231\189\174"
    }
  },
  setting_graphics_new_v2 = {
    keyName = "setting_graphics_new_v2",
    moduleName = "client.slua.umg.NewSetting.Setting_GraphicsNew_UIBP",
    path = "/Game/UMG/UI_BP/NewSetting/Setting_GraphicsNew_UIBP.Setting_GraphicsNew_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\231\148\187\233\157\162\232\174\190\231\189\174v2"
    }
  },
  Setting_Picture_Popup_UIBP = {
    keyName = "Setting_Picture_Popup_UIBP",
    moduleName = "client.slua.umg.NewSetting.Popup.Setting_Picture_Popup_UIBP",
    path = "/Game/UMG/UI_BP/NewSetting/Popup/Setting_Picture_Popup_UIBP.Setting_Picture_Popup_UIBP",
    uiStat = {
      name = "\232\174\190\231\189\174-\230\150\176\231\148\187\233\157\162\232\174\190\231\189\174\230\143\144\231\164\186\229\188\185\231\170\151"
    }
  },
  Setting_Sound = {
    keyName = "Setting_Sound",
    moduleName = "client.slua.umg.NewSetting.Sound.setting_sound_main",
    path = "/Game/UMG/UI_BP/NewSetting/NewSetting_Sound_UIBP.NewSetting_Sound_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\229\163\176\233\159\179\232\174\190\231\189\174"
    }
  },
  Setting_QuasiMirror = {
    keyName = "Setting_QuasiMirror",
    moduleName = "client.slua.umg.NewSetting.QuasiMirror.Setting_QuasiMirror_New_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_QuasiMirror_New_UIBP.Setting_QuasiMirror_New_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\174\190\231\189\174-\229\135\134\233\149\156\232\174\190\231\189\174-\230\151\167"
    }
  },
  Setting_Mirror_Main_UIBP = {
    keyName = "Setting_Mirror_Main_UIBP",
    moduleName = "client.slua.umg.setting.SettingMirror.Setting_Mirror_Main_UIBP",
    path = "/Game/UMG/UI_BP/Setting/SettingMirror/Setting_Mirror_Main_UIBP.Setting_Mirror_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\174\190\231\189\174-\229\135\134\233\149\156\232\174\190\231\189\174"
    }
  },
  setting_obs = {
    keyName = "setting_obs",
    moduleName = "client.slua.umg.NewSetting.Obs.setting_obs_main",
    path = "/Game/UMG/UI_BP/Setting/Setting_NewOBS_UIBP.Setting_NewOBS_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\174\190\231\189\174-\232\167\130\230\136\152\231\137\185\230\149\136"
    }
  },
  setting_ob_custom = {
    keyName = "setting_ob_custom",
    moduleName = "client.slua.umg.NewSetting.OBCustom.setting_ob_custom_main",
    path = "/Game/UMG/UI_BP/Setting/Setting_NewOBCustom_UIBP.Setting_NewOBCustom_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\232\167\130\230\136\152\229\184\131\229\177\128"
    }
  },
  setting_other = {
    keyName = "setting_other",
    moduleName = "client.slua.umg.setting.setting_other",
    path = "/Game/UMG/UI_BP/Setting/Setting_Others_UIBP.Setting_Others_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\229\133\182\228\187\150"
    }
  },
  setting_set_region = {
    keyName = "setting_set_region",
    moduleName = "client.slua.umg.setting.setting_set_region",
    path = "/Game/UMG/UI_BP/Setting/State_MessageBox.State_MessageBox",
    uiStat = {
      name = "\232\174\190\231\189\174-\232\174\190\231\189\174\229\155\189\229\174\182/\229\156\176\229\140\186"
    }
  },
  setting_platform_popup = {
    keyName = "setting_platform_popup",
    moduleName = "client.slua.umg.setting.setting_platform_popup",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_PlatformPopup_UIBP.Setting_PlatformPopup_UIBP",
    closeOnSwitch = false,
    uiStat = {
      name = "\232\174\190\231\189\174-\229\185\179\229\143\176\230\142\136\230\157\131\229\188\185\231\170\151"
    }
  },
  setting_unbind_popup = {
    keyName = "setting_unbind_popup",
    moduleName = "client.slua.umg.setting.setting_unbind_popup",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_UnbindPopup.Setting_UnbindPopup",
    closeOnSwitch = false,
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\231\153\187\229\189\149\230\150\185\229\188\143\232\167\163\233\153\164\229\188\185\231\170\151"
    }
  },
  setting_layout_share = {
    keyName = "setting_layout_share",
    moduleName = "client.slua.umg.setting.setting_layout_share",
    path = "/Game/UMG/UI_BP/NewSetting/UIElem_NewShareSchemeTips_UIBP.UIElem_NewShareSchemeTips_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\230\147\141\228\189\156\232\174\190\231\189\174-\229\136\134\228\186\171\229\184\131\229\177\128"
    }
  },
  setting_layout_selection_new = {
    keyName = "setting_layout_selection_new",
    moduleName = "client.slua.umg.setting.setting_layout_selection_new",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_Selection_New_UIBP.Setting_Selection_New_UIBP",
    uiStat = {
      name = "\232\174\190\231\189\174-\230\147\141\228\189\156\232\174\190\231\189\174-\229\184\131\229\177\128\231\174\161\231\144\134"
    }
  },
  setting_layout_search_result = {
    keyName = "setting_layout_search_result",
    moduleName = "client.slua.umg.setting.setting_layout_search_result",
    path = "/Game/UMG/UI_BP/Setting/UIElemShare/UIElem_SearchResult_UIBP.UIElem_SearchResult_UIBP",
    uiStat = {
      name = "setting_layout_search_result"
    }
  },
  setting_usingtips_new = {
    keyName = "setting_usingtips_new",
    moduleName = "client.slua.umg.setting.Setting_UsingTips_New",
    path = "/Game/UMG/UI_BP/Setting/UIElemShare/UIElem_UsingTips_New_UIBP.UIElem_UsingTips_New_UIBP",
    uiStat = {
      name = "\232\174\190\231\189\174-\230\147\141\228\189\156\232\174\190\231\189\174-\229\184\131\229\177\128\229\186\148\231\148\168\229\188\185\231\170\151"
    }
  },
  Setting_ChangeServer = {
    keyName = "Setting_ChangeServer",
    moduleName = "client.slua.umg.setting.Setting_ChangeServer",
    path = "/Game/UMG/UI_BP/Setting/Setting_ChangeServer.Setting_ChangeServer",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\232\174\190\231\189\174\230\136\152\230\150\151\230\156\141\229\188\185\231\170\151"
    }
  },
  setting_effect = {
    keyName = "setting_effect",
    moduleName = "client.slua.umg.setting.setting_effect",
    path = "/Game/UMG/UI_BP/Setting/Setting_Effect_UIBP.Setting_Effect_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\231\137\185\230\149\136\232\174\190\231\189\174"
    }
  },
  GraphicsQuality_Guide_UIBP = {
    keyName = "GraphicsQuality_Guide_UIBP",
    moduleName = "client.slua.umg.NewSetting.GraphicsNew.GraphicsQuality_Guide_UIBP",
    path = "/Game/UMG/UI_BP/NewSetting/GraphicsQuality_Guide_UIBP.GraphicsQuality_Guide_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\231\148\187\233\157\162\229\147\129\232\180\168\232\176\131\230\149\180\229\188\149\229\175\188"
    }
  },
  antiaddction_notice = {
    keyName = "antiaddction_notice",
    moduleName = "client.slua.umg.antiaddction.anti_addction_notice",
    path = "/Game/UMG/UI_BP/PopupNotice/Anti_addiction_UIBP.Anti_addiction_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\233\152\178\230\178\137\232\191\183-\233\128\154\231\159\165"
    }
  },
  antiaddction_kick = {
    keyName = "antiaddction_kick",
    moduleName = "client.slua.umg.antiaddction.anti_addction_kick",
    path = "/Game/UMG/UI_BP/PopupNotice/Anti_addiction2_UIBP.Anti_addiction2_UIBP",
    containerName = UIContainers.Top,
    loadFromPool = EUIConfigPoolType.None,
    asy = true,
    uiStat = {
      name = "\233\152\178\230\178\137\232\191\183-\232\184\162\228\184\139\231\186\191"
    }
  },
  Setting_Cloud_Manage_Popups_UIBP = {
    keyName = "Setting_Cloud_Manage_Popups_UIBP",
    moduleName = "client.slua.umg.setting.Setting_Cloud_Manage_Popups_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_Cloud_Manage_Popups_UIBP.Setting_Cloud_Manage_Popups_UIBP",
    uiStat = {
      name = "\232\174\190\231\189\174-\228\186\145\231\171\175\231\129\181\230\149\143\229\186\166\231\174\161\231\144\134"
    }
  },
  setting_cloud_sharecode_popups = {
    keyName = "setting_cloud_sharecode_popups",
    moduleName = "client.slua.umg.setting.Setting_Cloud_ShareCode_Popups_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_Cloud_ShareCode_Popups_UIBP.Setting_Cloud_ShareCode_Popups_UIBP",
    uiStat = {
      name = "\232\174\190\231\189\174-\231\129\181\230\149\143\229\186\166\229\136\134\228\186\171\231\160\129"
    }
  },
  setting_cloud_search_popups = {
    keyName = "setting_cloud_search_popups",
    moduleName = "client.slua.umg.setting.Setting_Cloud_Search_Popups_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_Cloud_Search_Popups_UIBP.Setting_Cloud_Search_Popups_UIBP",
    uiStat = {
      name = "\232\174\190\231\189\174-\231\129\181\230\149\143\229\186\166\230\144\156\231\180\162"
    }
  },
  setting_cloud_sensibility_preview = {
    keyName = "setting_cloud_sensibility_preview",
    moduleName = "client.slua.umg.setting.Setting_Cloud_Sensibility_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_Cloud_Sensibility_UIBP.Setting_Cloud_Sensibility_UIBP",
    uiStat = {
      name = "\232\174\190\231\189\174-\231\129\181\230\149\143\229\186\166\232\174\190\231\189\174"
    }
  },
  setting_cloud_custom_preview = {
    keyName = "setting_cloud_custom_preview",
    moduleName = "client.slua.umg.setting.Setting_Sensibility_Program_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_Sensibility_Program_UIBP.Setting_Sensibility_Program_UIBP",
    uiStat = {
      name = "\232\174\190\231\189\174-\231\129\181\230\149\143\229\186\166\233\162\132\232\167\136"
    }
  },
  SettingSaveToCloud_TipsUIBP = {
    keyName = "SettingSaveToCloud_TipsUIBP",
    moduleName = "client.slua.umg.setting.SettingSaveToCloud_TipsUIBP",
    path = "/Game/UMG/UI_BP/Setting/item/SettingSaveToCloud_TipsUIBP.SettingSaveToCloud_TipsUIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\231\129\181\230\149\143\229\186\166\228\184\138\228\188\160\231\161\174\232\174\164"
    }
  },
  ui_select_language = {
    keyName = "ui_select_language",
    moduleName = "client.slua.umg.setting.ui_select_language",
    path = "/Game/UMG/UI_BP/Setting/Setting_Language_Popup_UIBP.Setting_Language_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\229\164\154\232\175\173\232\168\128\233\128\137\233\161\185"
    }
  },
  setting_language = {
    keyName = "setting_language",
    moduleName = "client.slua.umg.setting.setting_language",
    path = "/Game/UMG/UI_BP/Setting/Setting_language_UIBP.Setting_language_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\232\175\173\232\168\128\232\174\190\231\189\174"
    }
  },
  Setting_ToKickOut_Popup = {
    keyName = "Setting_ToKickOut_Popup",
    moduleName = "client.slua.umg.setting.Popup.Setting_ToKickOut_Popup",
    path = "/Game/UMG/UI_BP/Setting/Popup/Setting_ToKickOut_Popup.Setting_ToKickOut_Popup",
    uiStat = {
      name = "\231\153\187\229\189\149-\229\135\134\229\164\135\233\161\182\229\143\183\229\188\185\231\170\151"
    }
  },
  SettingPerspectivePanel = {
    keyName = "SettingPerspectivePanel",
    moduleName = "client.slua.umg.NewSetting.SettingPerspectivePanel",
    path = "/Game/UMG/UI_BP/Setting/item/SettingVisual_control_UIBP.SettingVisual_control_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\232\135\170\229\174\154\228\185\137\233\151\174\229\143\183\229\188\185\231\170\151\231\149\140\233\157\162"
    }
  },
  setting_uielem_layout = {
    keyName = "setting_uielem_layout",
    moduleName = "client.slua.umg.NewSetting.UIElemLayout.Setting_UIElemLayout_Main",
    path = "/Game/UMG/UI_BP/Setting/UILayout/UIElemLayout_BP.UIElemLayout_BP",
    uiStat = {
      name = "\232\174\190\231\189\174-\232\135\170\229\174\154\228\185\137\233\157\162\230\157\191"
    },
    asy = true
  },
  CustomPanelInvisibleDialog = {
    keyName = "CustomPanelInvisibleDialog",
    moduleName = "client.slua.umg.NewSetting.UIElemLayout.CustomPanelInvisibleDialog",
    path = "/Game/UMG/UI_BP/Setting/UILayout/CustomPanelInvisibleDialog.CustomPanelInvisibleDialog",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\232\135\170\229\174\154\228\185\137UI\228\184\141\229\143\175\232\167\129\231\154\132\229\175\185\232\175\157\230\161\134"
    }
  },
  setting_gun_sensitivity_popup = {
    keyName = "setting_gun_sensitivity_popup",
    moduleName = "client.slua.umg.setting.Setting_GunSensitivity_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_GunSensitivity_Popup_UIBP.Setting_GunSensitivity_Popup_UIBP",
    uiStat = {
      name = "\232\174\190\231\189\174-\230\158\170\230\162\176\231\129\181\230\149\143\229\186\166\229\188\185\231\170\151"
    }
  },
  setting_haptics = {
    keyName = "setting_haptics",
    moduleName = "client.slua.umg.NewSetting.Haptics.Setting_Haptics_Main",
    path = "/Game/UMG/UI_BP/NewSetting/Setting_Haptics_UIBP.Setting_Haptics_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\233\156\135\229\138\168\232\174\190\231\189\174"
    }
  },
  setting_gun_accessories_popup = {
    keyName = "setting_gun_accessories_popup",
    moduleName = "client.slua.umg.setting.Setting_GunAccessories_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_GunAccessories_Popup_UIBP.Setting_GunAccessories_Popup_UIBP",
    uiStat = {
      name = "\232\174\190\231\189\174-\230\139\190\229\143\150\232\174\190\231\189\174-\233\128\137\230\139\169\230\173\166\229\153\168\229\188\185\231\170\151"
    }
  },
  setting_gun_accessories_popup2 = {
    keyName = "setting_gun_accessories_popup2",
    moduleName = "client.slua.umg.setting.item.Seeting_GunParts_item_Tips",
    path = "/Game/UMG/UI_BP/Setting/item/Seeting_GunParts_item_Tips.Seeting_GunParts_item_Tips",
    uiStat = {
      name = "\232\174\190\231\189\174-\230\139\190\229\143\150\232\174\190\231\189\174-\233\128\137\230\139\169\229\133\183\228\189\147\233\133\141\228\187\182\229\188\185\231\170\151"
    },
    isMainUI = false
  },
  Setting_GunPart_Item_Guide = {
    keyName = "Setting_GunPart_Item_Guide",
    moduleName = "client.slua.umg.setting.item.Setting_GunPart_Item_Guide",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_GunPart_Item_Guide.Setting_GunPart_Item_Guide",
    uiStat = {
      name = "Setting_GunPart_Item_Guide"
    },
    isMainUI = false
  },
  setting_tv = {
    keyName = "setting_tv",
    moduleName = "client.slua.umg.setting.setting_tv",
    path = "/Game/UMG/UI_BP/Setting/Setting_mirratv_UIBP.Setting_mirratv_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\230\151\165\233\159\169\231\137\136\231\155\180\230\146\173\233\161\181\231\173\190"
    }
  },
  setting_account = {
    keyName = "setting_account",
    moduleName = "client.slua.umg.NewSetting.Account.setting_account",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_AccountSettings_PopupNew_UIBP.Setting_AccountSettings_PopupNew_UIBP",
    asy = false,
    isMainUI = false,
    uiStat = {
      name = "\232\174\190\231\189\174-\232\180\166\229\143\183\228\184\142\229\174\137\229\133\168"
    }
  },
  setting_accountsecurity_popup = {
    keyName = "setting_accountsecurity_popup",
    moduleName = "client.slua.umg.NewSetting.Account.Popup.setting_accountsecurity_popup",
    path = "/Game/UMG/UI_BP/Setting/Setting_AccountSecurity_Popup_UIBP.Setting_AccountSecurity_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\232\180\166\229\143\183\229\174\137\229\133\168\229\188\185\231\170\151"
    }
  },
  Inform_Popup_Abnormal_UIBP = {
    keyName = "Inform_Popup_Abnormal_UIBP",
    moduleName = "client.slua.umg.NewSetting.Account.Popup.Inform_Popup_Abnormal_UIBP",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Popup_Abnormal_UIBP.Inform_Popup_Abnormal_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\232\180\166\229\143\183-\229\188\130\229\184\184\231\153\187\229\189\149\229\188\185\231\170\151"
    }
  },
  AccountBindingChangedPopup = {
    keyName = "AccountBindingChangedPopup",
    moduleName = "client.slua.umg.NewSetting.Account.Popup.AccountBindingChangedPopup",
    path = "/Game/UMG/UI_BP/Setting/Popup/Setting_Bind_UIBP.Setting_Bind_UIBP",
    asy = true,
    uiStat = {
      name = "\229\184\144\229\143\183\229\174\137\229\133\168-\231\187\145\229\174\154\230\141\162\231\187\145\230\151\182\231\154\132\228\191\161\230\129\175\229\145\138\231\159\165"
    }
  },
  choose_flag_code = {
    keyName = "choose_flag_code",
    moduleName = "client.slua.umg.NewSetting.Account.Popup.ChooseFlagAreaCode_UIBP",
    path = "/Game/UMG/UI_BP/Setting/SettingAccount/ChooseFlagAreaCode_UIBP.ChooseFlagAreaCode_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\233\128\137\230\139\169\229\155\189\230\151\151\229\140\186\229\143\183"
    },
    containerName = UIContainers.Top
  },
  setting_account_spare_code = {
    keyName = "setting_account_spare_code",
    moduleName = "client.slua.umg.NewSetting.Account.login_verify_spare_code_panel",
    path = "/Game/UMG/UI_BP/Login/Login_Verify_safely_Confirm_UIBP.Login_Verify_safely_Confirm_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\232\180\166\229\143\183-\229\164\135\231\148\168\233\170\140\232\175\129\231\160\129"
    }
  },
  setting_change_timedisplay = {
    keyName = "setting_change_timedisplay",
    moduleName = "client.slua.umg.setting.Setting_Change_Timedisplay",
    path = "/Game/UMG/UI_BP/Setting/Setting_Change_Timedisplay.Setting_Change_Timedisplay",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\230\151\182\233\151\180\230\152\190\231\164\186\230\150\185\229\188\143\229\188\185\231\170\151"
    }
  },
  setting_notifycations = {
    moduleName = "client.slua.umg.NewSetting.Notify.Setting_Notification_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_Notification_New_UIBP.Setting_Notification_New_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\230\182\136\230\129\175\233\128\154\231\159\165"
    }
  },
  Setting_Notification_Popup_UIBP = {
    keyName = "Setting_Notification_Popup_UIBP",
    moduleName = "client.slua.umg.NewSetting.Notify.Setting_Notification_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Popup/Setting_Notification_Popup_UIBP.Setting_Notification_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\230\182\136\230\129\175\233\128\154\231\159\165\229\138\159\232\131\189\228\187\139\231\187\141\229\188\185\231\170\151"
    }
  },
  guest_bind_password_set = {
    keyName = "guest_bind_password_set",
    moduleName = "client.slua.umg.guest_bind.guest_bind_password_set",
    path = "/Game/UMG/UI_BP/GuestBind/Guest_PasswordSetting_BP.Guest_PasswordSetting_BP",
    isSingleton = false,
    isMainUI = false,
    asy = true
  },
  guest_bind_password_set_success = {
    keyName = "guest_bind_password_set_success",
    moduleName = "client.slua.umg.guest_bind.guest_bind_password_set_success",
    path = "/Game/UMG/UI_BP/GuestBind/Guest_GuestAccountSetting_BP.Guest_GuestAccountSetting_BP",
    isSingleton = false,
    isMainUI = false,
    asy = true
  },
  Setting_BindChoice_Panel_New = {
    keyName = "Setting_BindChoice_Panel_New",
    moduleName = "client.slua.umg.setting.Account.Popup.Setting_BindChoice_Panel_New",
    path = "/Game/UMG/UI_BP/Setting/Account/Popup/Setting_BindChoice_Panel.Setting_BindChoice_Panel",
    isMainUI = false,
    uiStat = {
      name = "\232\180\166\229\143\183\230\149\143\230\132\159\230\147\141\228\189\156-\231\164\190\229\170\146\231\187\145\229\174\154\231\149\140\233\157\162"
    }
  },
  Setting_Verify_Item_UIBP = {
    keyName = "Setting_Verify_Item_UIBP",
    moduleName = "client.slua.umg.setting.item.Setting_Verify_Item_UIBP",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_Verify_Item_UIBP.Setting_Verify_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\180\166\229\143\183\230\149\143\230\132\159\230\147\141\228\189\156-\229\174\137\229\133\168\233\170\140\232\175\129"
    }
  },
  Setting_Result_Item_UIBP = {
    keyName = "Setting_Result_Item_UIBP",
    moduleName = "client.slua.umg.setting.item.Setting_Result_Item_UIBP",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_Verify_Item_UIBP.Setting_Verify_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\180\166\229\143\183\230\149\143\230\132\159\230\147\141\228\189\156-\231\187\147\230\158\156"
    }
  },
  Setting_Verified_Passed_Popup_UIBP = {
    keyName = "Setting_Verified_Passed_Popup_UIBP",
    moduleName = "client.slua.umg.setting.Account.Popup.Setting_Verified_Passed_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Account/Popup/Setting_Verified_Passed_Popup_UIBP.Setting_Verified_Passed_Popup_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\180\166\229\143\183\230\149\143\230\132\159\230\147\141\228\189\156-\232\135\170\229\187\186\233\170\140\232\175\129\231\160\129"
    }
  },
  Setting_Change_Bind_Popup_UIBP = {
    keyName = "Setting_Change_Bind_Popup_UIBP",
    moduleName = "client.slua.umg.setting.Account.Popup.Setting_Change_Bind_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Account/Popup/Setting_Change_Bind_Popup_UIBP.Setting_Change_Bind_Popup_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\180\166\229\143\183\230\149\143\230\132\159\230\147\141\228\189\156-\230\141\162\231\187\145\232\135\170\229\187\186"
    }
  },
  Setting_UnbindFastCond_UIBP = {
    keyName = "Setting_UnbindFastCond_UIBP",
    moduleName = "client.slua.umg.setting.Account.Popup.Setting_UnbindFastCond_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Account/Popup/Setting_UnbindFastCond_UIBP.Setting_UnbindFastCond_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\180\166\229\143\183\230\149\143\230\132\159\230\147\141\228\189\156-\232\167\163\231\187\145\230\157\161\228\187\182"
    }
  },
  Setting_CE_Bind_UIBP = {
    keyName = "Setting_CE_Bind_UIBP",
    moduleName = "client.slua.umg.setting.Account.Popup.Setting_CE_Bind_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Account/Popup/Setting_CE_Bind_UIBP.Setting_CE_Bind_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\180\166\229\143\183\230\149\143\230\132\159\230\147\141\228\189\156-\229\133\136\230\184\184\231\164\190\229\170\146\231\187\145\229\174\154\231\149\140\233\157\162"
    }
  },
  unbind_account_select = {
    keyName = "unbind_account_select",
    moduleName = "client.slua.umg.unbind_account.Setting_UnbindPopup_check",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_UnbindPopup_check.Setting_UnbindPopup_check",
    asy = true,
    uiStat = {
      name = "\232\167\163\231\187\145-\232\180\166\229\143\183\233\128\137\230\139\169"
    }
  },
  unbind_account_notify = {
    keyName = "unbind_account_notify",
    moduleName = "client.slua.umg.unbind_account.Setting_UnbindPopup",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_UnbindPopup.Setting_UnbindPopup",
    asy = true,
    uiStat = {
      name = "\232\167\163\231\187\145-\228\191\161\230\129\175\233\128\154\231\159\165"
    }
  },
  unbind_account_notify2 = {
    keyName = "unbind_account_notify2",
    moduleName = "client.slua.umg.unbind_account.Setting_ImportantReminder",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_ImportantReminder.Setting_ImportantReminder",
    asy = true,
    uiStat = {
      name = "\232\167\163\231\187\145-\228\191\161\230\129\175\233\128\154\231\159\1652"
    }
  },
  unbind_fast_cond = {
    keyName = "unbind_fast_cond",
    moduleName = "client.slua.umg.unbind_account.Setting_UnbindFastCond_UIBP",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_UnbindFastCond_UIBP.Setting_UnbindFastCond_UIBP",
    asy = true,
    uiStat = {
      name = "\232\167\163\231\187\145-\229\191\171\233\128\159\232\167\163\231\187\145\230\157\161\228\187\182"
    }
  },
  unbind_account_result = {
    keyName = "unbind_account_result",
    moduleName = "client.slua.umg.unbind_account.Setting_UnbindResult",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_UnbindResult.Setting_UnbindResult",
    closeOnSwitch = false,
    uiStat = {
      name = "\232\167\163\231\187\145-\231\187\147\230\158\156"
    }
  },
  Throw_Tips_UIBP = {
    keyName = "Throw_Tips_UIBP",
    moduleName = "client.slua.umg.setting.item.Throw_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Setting/item/Throw_Tips_UIBP.Throw_Tips_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\230\138\149\230\142\183\230\143\144\231\164\186"
    }
  },
  Seeting_TwoPicturesPopup_UIBP = {
    keyName = "Seeting_TwoPicturesPopup_UIBP",
    moduleName = "client.slua.umg.setting.item.Seeting_TwoPicturesPopup_UIBP",
    path = "/Game/UMG/UI_BP/Setting/item/Seeting_TwoPicturesPopup_UIBP.Seeting_TwoPicturesPopup_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\229\143\140\229\155\190\230\143\144\231\164\186"
    }
  },
  TeamUp_PKSetting_UIBP = {
    keyName = "TeamUp_PKSetting_UIBP",
    moduleName = "client.slua.umg.teamup.TeamUp_PKSetting_UIBP",
    path = "/Game/UMG/UI_BP/TeamUp/TeamUp_PKSetting_UIBP.TeamUp_PKSetting_UIBP",
    uiStat = {
      name = "Solo-\229\143\130\230\149\176\233\128\137\230\139\169\231\149\140\233\157\162"
    }
  },
  MomentSetting = {
    keyName = "MomentSetting",
    moduleName = "client.slua.umg.moment.ui_moment_settings",
    path = "/Game/UMG/UI_BP/Moment/Popup/Moment_Setting_UIBP.Moment_Setting_UIBP",
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\232\174\190\231\189\174\231\149\140\233\157\162"
    }
  },
  activity_bind_discord_tip = {
    keyName = "activity_bind_discord_tip",
    moduleName = "client.slua.umg.activity.bind_discord.activity_bind_discord_tip",
    path = "/Game/UMG/UI_BP/Setting/item/subItem/BindPop_Item_UIBP.BindPop_Item_UIBP",
    asy = true,
    isSingleton = false,
    uiStat = {
      name = "\231\187\145\229\174\154\230\156\137\231\164\188-discord\231\187\145\229\174\154\230\180\187\229\138\168_\231\187\145\229\174\154\231\149\140\233\157\162\230\143\144\231\164\186"
    }
  },
  setting_bind_discord_tip = {
    keyName = "setting_bind_discord_tip",
    moduleName = "client.slua.umg.activity.bind_discord.setting_bind_discord_tip",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_AccountSettings_PopupNew_Item_UIBP.Setting_AccountSettings_PopupNew_Item_UIBP",
    asy = true,
    uiStat = {
      name = "\231\187\145\229\174\154\230\156\137\231\164\188-discord\231\187\145\229\174\154\230\180\187\229\138\168_\232\174\190\231\189\174\231\149\140\233\157\162\230\143\144\231\164\186"
    }
  },
  setting_other_gameplay_management = {
    keyName = "setting_other_gameplay_management",
    moduleName = "client.slua.umg.setting.setting_other_gameplay_management",
    path = "/Game/UMG/UI_BP/Setting/Setting_Others_GameplayManagement_UIBP.Setting_Others_GameplayManagement_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\141\176\229\186\166VONAGE\230\156\170\230\136\144\229\185\180\228\186\186\232\174\164\232\175\129-\232\174\190\231\189\174\231\149\140\233\157\162"
    }
  },
  gdpr_setting_select = {
    keyName = "gdpr_setting_select",
    moduleName = "client.slua.umg.GDPR.gdpr_setting_select",
    path = "/Game/UMG/UI_BP/PopupNotice/GdprNew/Protection02_BP1.Protection02_BP1",
    asy = true,
    uiStat = {
      name = "gdpr\232\174\190\231\189\174\229\139\190\233\128\137"
    }
  },
  gdpr_setting_notice = {
    keyName = "gdpr_setting_notice",
    moduleName = "client.slua.umg.GDPR.gdpr_setting_notice",
    path = "/Game/UMG/UI_BP/PopupNotice/GdprNew/Protection06_BP.Protection06_BP",
    asy = true,
    uiStat = {
      name = "gdpr\232\174\190\231\189\174\229\188\185\231\170\151"
    }
  },
  setting_korea_delete_account = {
    keyName = "setting_korea_delete_account",
    moduleName = "client.slua.umg.GDPR.setting_korea_delete_account",
    path = "/Game/UMG/UI_BP/PopupNotice/GdprNew/Setting_CancelPUBGM_UIBP.Setting_CancelPUBGM_UIBP",
    asy = true,
    uiStat = {
      name = "kr\229\136\160\233\153\164\232\180\166\229\143\183"
    }
  },
  setting_information_bind = {
    keyName = "setting_information_bind",
    moduleName = "client.slua.umg.setting.setting_information_bind",
    path = "/Game/UMG/UI_BP/Setting/Setting_Informationbinding_UIBP.Setting_Informationbinding_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174\233\135\140\231\154\132\231\187\145\229\174\154\228\191\161\230\129\175UI"
    }
  },
  setting_bindchoice_panel = {
    keyName = "setting_bindchoice_panel",
    moduleName = "client.slua.umg.setting.setting_bindchoice_panel",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_BindChoice_Panel.Setting_BindChoice_Panel",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\231\187\145\229\174\154\229\188\185\231\170\151"
    }
  },
  SmartAssistant_SettingPopup_UIBP = {
    keyName = "SmartAssistant_SettingPopup_UIBP",
    moduleName = "client.slua.umg.SmartAssistantV2.Popup.SmartAssistant_SettingPopup_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistantV2/Popup/SmartAssistant_SettingPopup_UIBP.SmartAssistant_SettingPopup_UIBP",
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139\232\174\190\231\189\174\231\149\140\233\157\162"
    }
  },
  Setting_Code_Authorization_Popup_UIBP = {
    keyName = "Setting_Code_Authorization_Popup_UIBP",
    moduleName = "client.slua.umg.setting.Popup.Setting_Code_Authorization_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Popup/Setting_Code_Authorization_Popup_UIBP.Setting_Code_Authorization_Popup_UIBP",
    uiStat = {
      name = "\230\137\171\231\160\129\231\153\187\229\189\149\233\128\137\230\151\182\233\151\180"
    }
  },
  Setting_ScanningProcessing_UIBP = {
    keyName = "Setting_ScanningProcessing_UIBP",
    moduleName = "client.slua.umg.QRcodeLogin.Setting_ScanningProcessing_UIBP",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_ScanningProcessing_UIBP.Setting_ScanningProcessing_UIBP",
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\230\137\171\231\160\129\231\153\187\229\189\149-\230\137\171\231\160\129\232\143\138\232\138\177\231\149\140\233\157\162"
    }
  },
  Setting_WebPage_Authorization_Popup_UIBP = {
    keyName = "Setting_WebPage_Authorization_Popup_UIBP",
    moduleName = "client.slua.umg.setting.Popup.Setting_WebPage_Authorization_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Popup/Setting_WebPage_Authorization_Popup_UIBP.Setting_WebPage_Authorization_Popup_UIBP",
    uiStat = {
      name = "\230\137\171\231\160\129-\231\189\145\233\161\181\230\137\171\231\160\129\230\142\136\230\157\131"
    }
  },
  VersionAlbum_Setting_Popup = {
    keyName = "VersionAlbum_Setting_Popup",
    moduleName = "client.slua.umg.EventPhoto.Popup.VersionAlbum_Setting_Popup",
    path = "/Game/UMG/UI_BP/EventPhoto/Popup/VersionAlbum_Setting_Popup.VersionAlbum_Setting_Popup",
    uiStat = {
      name = "\231\137\136\230\156\172\231\155\184\229\134\140-\233\155\134\229\141\161\232\181\160\233\128\129\232\174\176\229\189\149\229\188\185\231\170\151-\233\128\154\231\148\168"
    }
  },
  AccountScanList_UIBP = {
    keyName = "AccountScanList_UIBP",
    moduleName = "client.slua.umg.NewSetting.Account.Popup.AccountScanList_UIBP",
    path = "/Game/UMG/UI_BP/Setting/item/subItem/AccountScanList_UIBP.AccountScanList_UIBP",
    uiStat = {
      name = "\232\174\190\231\189\174-\232\180\166\229\143\183\232\174\190\231\189\174-\230\137\171\231\160\129\232\174\176\229\189\149"
    }
  },
  AccountScanLogin_UIBP = {
    keyName = "AccountScanLogin_UIBP",
    moduleName = "client.slua.umg.NewSetting.Account.Popup.AccountScanLogin_UIBP",
    path = "/Game/UMG/UI_BP/Setting/item/subItem/AccountScanLogin_UIBP.AccountScanLogin_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\231\153\187\229\189\149-\230\137\171\231\160\129\232\174\176\229\189\149"
    }
  },
  Setting_TopMark_Popup = {
    keyName = "Setting_TopMark_Popup",
    moduleName = "client.slua.umg.setting.item.Setting_TopMark_Popup",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_TopMark_Popup.Setting_TopMark_Popup",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\231\153\187\229\189\149-\233\161\182\229\143\183\231\149\140\233\157\162"
    }
  },
  Setting_Account_Prompt_Popup_UIBP = {
    keyName = "Setting_Account_Prompt_Popup_UIBP",
    moduleName = "client.slua.umg.Setting.Popup.Setting_Account_Prompt_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Popup/Setting_Account_Prompt_Popup_UIBP.Setting_Account_Prompt_Popup_UIBP",
    uiStat = {
      name = "\232\180\166\229\143\183\230\147\141\228\189\156\231\155\184\229\133\179\233\148\153\232\175\175\231\160\129\230\143\144\231\164\186\229\188\185\231\170\151"
    }
  },
  Setting_Bind_CE_UIBP = {
    keyName = "Setting_Bind_CE_UIBP",
    moduleName = "client.slua.umg.setting.Setting_Bind_CE_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_Bind_CE_UIBP.Setting_Bind_CE_UIBP",
    uiStat = {
      name = "\229\133\136\230\184\184\231\187\145\229\174\154\230\173\163\229\188\143\230\156\141\231\149\140\233\157\162"
    }
  },
  Setting_AccountSecurityTips_Popup_UIBP = {
    keyName = "Setting_AccountSecurityTips_Popup_UIBP",
    moduleName = "client.slua.umg.setting.Popup.Setting_AccountSecurityTips_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Popup/Setting_AccountSecurityTips_Popup_UIBP.Setting_AccountSecurityTips_Popup_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\232\180\166\229\143\183\229\174\137\229\133\168\230\143\144\233\134\146\229\188\185\231\170\151"
    }
  },
  Setting_Hotspot_Popup_UIBP = {
    keyName = "Setting_Hotspot_Popup_UIBP",
    moduleName = "client.slua.umg.setting.Popup.Setting_Hotspot_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_Hotspot_Popup_UIBP.Setting_Hotspot_Popup_UIBP",
    loadFromPool = EUIConfigPoolType.None
  },
  CommonSettingCustomPanelWrapper = {
    keyName = "CommonSettingCustomPanelWrapper",
    moduleName = "client.slua.umg.NewSetting.UIElemLayout.CommonSettingCustomPanelWrapper",
    path = "/Game/UMG/UI_BP/Setting/UILayout/CommonSettingCustomPanelWrapper.CommonSettingCustomPanelWrapper",
    loadFromPool = EUIConfigPoolType.ui_pool,
    isSingleton = false,
    isMainUI = false
  },
  Setting_StackContainer = {
    keyName = "Setting_StackContainer",
    moduleName = "client.slua.umg.NewSetting.Page.Setting_StackContainer",
    path = "/Game/UMG/UI_BP/Setting25/Page/WBP_Setting_StackContainer.WBP_Setting_StackContainer",
    isSingleton = false,
    AndroidBackType = EAndroidBackType.Skip
  },
  Setting_Option_Switcher = {
    keyName = "Setting_Option_Switcher",
    moduleName = "client.slua.umg.NewSetting.Item.Setting_Option_Switcher",
    path = "/Game/UMG/UI_BP/Setting25/Item/WBP_Setting_Option_Switcher.WBP_Setting_Option_Switcher",
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    showVisibility = UIContainers.ShowVisibilityAction.DontCare
  },
  Setting_Option_ImageSwitcher = {
    keyName = "Setting_Option_ImageSwitcher",
    moduleName = "client.slua.umg.NewSetting.Item.Setting_Option_ImageSwitcher",
    path = "/Game/UMG/UI_BP/Setting25/Item/WBP_Setting_Option_ImageSwitcher.WBP_Setting_Option_ImageSwitcher",
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    showVisibility = UIContainers.ShowVisibilityAction.DontCare
  },
  Setting_Option_Compact_Switcher = {
    keyName = "Setting_Option_Compact_Switcher",
    moduleName = "client.slua.umg.NewSetting.Item.Setting_Option_Compact_Switcher",
    path = "/Game/UMG/UI_BP/Setting25/Item/WBP_Setting_Option_Compact_Switcher.WBP_Setting_Option_Compact_Switcher",
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    showVisibility = UIContainers.ShowVisibilityAction.DontCare
  },
  Setting_TitleOption_Switcher = {
    keyName = "Setting_TitleOption_Switcher",
    moduleName = "client.slua.umg.NewSetting.Item.Setting_Option_Switcher",
    path = "/Game/UMG/UI_BP/Setting25/Item/WBP_Setting_TitleOption_Switcher.WBP_Setting_TitleOption_Switcher",
    isSingleton = false,
    showVisibility = UIContainers.ShowVisibilityAction.DontCare
  },
  Setting_TitleOption_MultiSwitcher = {
    keyName = "Setting_TitleOption_MultiSwitcher",
    moduleName = "client.slua.umg.NewSetting.Item.Setting_TitleOption_MultiSwitcher",
    path = "/Game/UMG/UI_BP/Setting25/Item/WBP_Setting_TitleOption_MultiSwitcher.WBP_Setting_TitleOption_MultiSwitcher",
    isSingleton = false,
    showVisibility = UIContainers.ShowVisibilityAction.DontCare
  },
  Setting_Option_Slider = {
    keyName = "Setting_Option_Slider",
    moduleName = "client.slua.umg.NewSetting.Item.Setting_Option_Slider",
    path = "/Game/UMG/UI_BP/Setting25/Item/WBP_Setting_Option_Slider.WBP_Setting_Option_Slider",
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    showVisibility = UIContainers.ShowVisibilityAction.DontCare
  },
  Setting_Spacer = {
    keyName = "Setting_Spacer",
    moduleName = "client.slua.umg.NewSetting.Item.Setting_Spacer",
    path = "/Game/UMG/UI_BP/Setting25/Item/WBP_Setting_Spacer.WBP_Setting_Spacer",
    isSingleton = false,
    showVisibility = UIContainers.ShowVisibilityAction.DontCare
  },
  Setting_Title = {
    keyName = "Setting_Title",
    moduleName = "client.slua.umg.NewSetting.Item.Setting_Title",
    path = "/Game/UMG/UI_BP/Setting25/Item/WBP_Setting_Title.WBP_Setting_Title",
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    showVisibility = UIContainers.ShowVisibilityAction.DontCare
  },
  Setting_Option_OpenWindow = {
    keyName = "Setting_Option_OpenWindow",
    moduleName = "client.slua.umg.NewSetting.Item.Setting_Option_OpenWindow",
    path = "/Game/UMG/UI_BP/Setting25/Item/WBP_Setting_Option_OpenWindow.WBP_Setting_Option_OpenWindow",
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    showVisibility = UIContainers.ShowVisibilityAction.DontCare
  },
  Setting_Page_Game = {
    keyName = "Setting_Page_Game",
    moduleName = "client.slua.umg.NewSetting.Page.Setting_Page_Game",
    path = "/Game/UMG/UI_BP/Setting25/Page/WBP_Setting_Page_Game.WBP_Setting_Page_Game",
    AndroidBackType = EAndroidBackType.Skip
  },
  Setting_Page_Pickup = {
    keyName = "Setting_Page_Pickup",
    moduleName = "client.slua.umg.NewSetting.Page.Setting_Page_Pickup",
    path = "/Game/UMG/UI_BP/Setting25/Page/WBP_Setting_Page_Pickup.WBP_Setting_Page_Pickup",
    AndroidBackType = EAndroidBackType.Skip
  },
  Setting_Page_Attachment = {
    keyName = "Setting_Page_Attachment",
    moduleName = "client.slua.umg.NewSetting.Page.Setting_Page_Attachment",
    path = "/Game/UMG/UI_BP/Setting25/Page/WBP_Setting_Page_Attachment.WBP_Setting_Page_Attachment",
    AndroidBackType = EAndroidBackType.Skip
  },
  Setting_Page_Privacy = {
    keyName = "Setting_Page_Privacy",
    moduleName = "client.slua.umg.NewSetting.Page.Setting_Page_Privacy",
    path = "/Game/UMG/UI_BP/Setting25/Page/WBP_Setting_StackContainer.WBP_Setting_StackContainer",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false
  },
  Setting_Page_Language = {
    keyName = "Setting_Page_Language",
    moduleName = "client.slua.umg.NewSetting.Page.Setting_Page_Language",
    path = "/Game/UMG/UI_BP/Setting25/Page/WBP_Setting_StackContainer.WBP_Setting_StackContainer",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false
  },
  Setting_Page_Sens = {
    keyName = "Setting_Page_Sens",
    moduleName = "client.slua.umg.NewSetting.Page.Setting_Page_Sens",
    path = "/Game/UMG/UI_BP/Setting25/Page/WBP_Setting_Page_Sens.WBP_Setting_Page_Sens",
    AndroidBackType = EAndroidBackType.Skip
  },
  Setting_Page_WeaponSens = {
    keyName = "Setting_Page_WeaponSens",
    moduleName = "client.slua.umg.NewSetting.Page.Setting_Page_WeaponSens",
    path = "/Game/UMG/UI_BP/Setting25/Page/WBP_Setting_Page_WeaponSens.WBP_Setting_Page_WeaponSens",
    AndroidBackType = EAndroidBackType.Skip
  },
  Setting_Page_Layout_Character = {
    keyName = "Setting_Page_Layout_Character",
    moduleName = "client.slua.umg.NewSetting.Page.Setting_Page_Layout_Character",
    path = "/Game/UMG/UI_BP/Setting25/Page/WBP_Setting_Page_Layout_Character.WBP_Setting_Page_Layout_Character",
    AndroidBackType = EAndroidBackType.Skip
  },
  Setting_Page_Layout_Vehicle = {
    keyName = "Setting_Page_Layout_Vehicle",
    moduleName = "client.slua.umg.NewSetting.Page.Setting_Page_Layout_Vehicle",
    path = "/Game/UMG/UI_BP/Setting25/Page/WBP_Setting_Page_Layout_Vehicle.WBP_Setting_Page_Layout_Vehicle",
    AndroidBackType = EAndroidBackType.Skip
  },
  Setting_Page_Layout_Special = {
    keyName = "Setting_Page_Layout_Special",
    moduleName = "client.slua.umg.NewSetting.Page.Setting_Page_Layout_Special",
    path = "/Game/UMG/UI_BP/Setting25/Page/WBP_Setting_Page_Layout_Special.WBP_Setting_Page_Layout_Special",
    AndroidBackType = EAndroidBackType.Skip
  },
  Setting_Item_Recommend = {
    keyName = "Setting_Item_Recommend",
    moduleName = "client.slua.umg.NewSetting.Item.Setting_Item_Recommend",
    path = "/Game/UMG/UI_Logic/Reddot/Reddot_Anchor_Item10.Reddot_Anchor_Item10",
    isSingleton = false
  },
  Setting_Decoration_New = {
    keyName = "Setting_Decoration_New",
    moduleName = "client.slua.umg.NewSetting.Item.Setting_Decoration_New",
    path = "/Game/UMG/UI_BP/Setting25/Decoration/WBP_Seting_Decoration_New.WBP_Seting_Decoration_New",
    isSingleton = false
  },
  Setting_Reddot_New = {
    keyName = "Setting_Reddot_New",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_Logic/Reddot/Reddot_Anchor_Item18.Reddot_Anchor_Item18",
    isSingleton = false
  },
  Setting_Decoration_Beta = {
    keyName = "Setting_Decoration_Beta",
    moduleName = "client.slua.umg.NewSetting.Item.Setting_Decoration_Beta",
    path = "/Game/UMG/UI_BP/Setting25/Decoration/WBP_Seting_Decoration_Beta.WBP_Seting_Decoration_Beta",
    isSingleton = false
  }
}
return setting_ui_configs