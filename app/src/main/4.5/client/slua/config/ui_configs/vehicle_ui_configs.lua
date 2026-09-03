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
local vehicle_ui_configs = {
  vehicle_main = {
    keyName = "vehicle_main",
    moduleName = "client.slua.umg.vehicle.vehicle_main",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_Preview_Main_UIBP.Vehicle_Preview_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\189\189\229\133\183-\228\184\187\231\149\140\233\157\162"
    }
  },
  Vehicle_Preview_Main_NewBie_UIBP = {
    keyName = "Vehicle_Preview_Main_NewBie_UIBP",
    moduleName = "client.slua.umg.vehicle.Vehicle_Preview_Main_NewBie_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_Preview_Main_NewBie_UIBP.Vehicle_Preview_Main_NewBie_UIBP",
    uiStat = {
      name = "\232\189\166\232\190\134\230\148\185\232\163\133-\229\188\149\229\175\188\231\149\140\233\157\162"
    }
  },
  vehicle_refit_main = {
    keyName = "vehicle_refit_main",
    moduleName = "client.slua.umg.vehicle.vehicle_refit_main",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_Refit_Main_UIBP.Vehicle_Refit_Main_UIBP",
    uiStat = {
      name = "\232\189\166\232\190\134\230\148\185\232\163\133-\228\184\187\231\149\140\233\157\162"
    }
  },
  vehicle_refit_save = {
    keyName = "vehicle_refit_save",
    moduleName = "client.slua.umg.vehicle.vehicle_refit_save",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_Refit_Save_UIBP.Vehicle_Refit_Save_UIBP",
    asy = true,
    uiStat = {
      name = "\232\189\166\232\190\134\230\148\185\232\163\133-\228\191\157\229\173\152\228\184\187\231\149\140\233\157\162 -- \229\186\159\229\188\131"
    }
  },
  Vehicle_UpGrade_Popup_UIBP = {
    keyName = "Vehicle_UpGrade_Popup_UIBP",
    moduleName = "client.slua.umg.vehicle.Vehicle_UpGrade_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_UpGrade_Popup_UIBP.Vehicle_UpGrade_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\232\189\166\232\190\134\230\148\185\232\163\133-\232\180\173\228\185\176\231\149\140\233\157\162"
    }
  },
  vehicle_refit_lack = {
    keyName = "vehicle_refit_lack",
    moduleName = "client.slua.umg.vehicle.vehicle_refit_lack",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_Refit_Lack_UIBP.Vehicle_Refit_Lack_UIBP",
    asy = true,
    uiStat = {
      name = "\232\189\166\232\190\134\230\148\185\232\163\133-\230\157\144\230\150\153\228\184\141\232\182\179"
    }
  },
  Vehicle_UpGrade_Main_UIBP = {
    keyName = "Vehicle_UpGrade_Main_UIBP",
    moduleName = "client.slua.umg.vehicle.Vehicle_UpGrade_Main_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_UpGrade_Main_UIBP.Vehicle_UpGrade_Main_UIBP",
    uiStat = {
      name = "\232\189\166\232\190\134\230\148\185\232\163\133-\229\141\135\231\186\167\228\184\187\231\149\140\233\157\162"
    }
  },
  VehicleSystem_Main_UIBP = {
    keyName = "VehicleSystem_Main_UIBP",
    moduleName = "client.slua.umg.vehicle.VehicleSystem_Main_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/VehicleSystem_Main_UIBP.VehicleSystem_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_VEHICLE_NEW,
    uiStat = {
      name = "\232\189\189\229\133\183\229\183\165\229\157\138-\228\184\187\231\149\140\233\157\162"
    }
  },
  Vehicle_Collect_Main_UIBP = {
    keyName = "Vehicle_Collect_Main_UIBP",
    moduleName = "client.slua.umg.vehicle.Vehicle_Collect_Main_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_Collect_Main_UIBP.Vehicle_Collect_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\189\189\229\133\183\230\148\182\233\155\134-\228\184\187\231\149\140\233\157\162"
    }
  },
  Vehicle_CollectUI_UIBP = {
    keyName = "Vehicle_CollectUI_UIBP",
    moduleName = "client.slua.umg.vehicle.Vehicle_CollectUI_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/CollectItem/Vehicle_CollectUI_UIBP.Vehicle_CollectUI_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\189\189\229\133\183\230\148\182\233\155\134-\232\175\166\230\131\133"
    }
  },
  Vehicle_Collect_VoiceList_Item = {
    keyName = "Vehicle_Collect_VoiceList_Item",
    moduleName = "client.slua.umg.vehicle.Vehicle_Collect_VoiceList_Item",
    path = "/Game/UMG/UI_BP/Vehicle/CollectItem/Vehicle_Collect_VoiceList_Item.Vehicle_Collect_VoiceList_Item",
    isMainUI = false,
    uiStat = {
      name = "\232\189\189\229\133\183\230\148\182\233\155\134-\232\175\173\233\159\179"
    }
  },
  Vehicle_LicensePlate_Item = {
    keyName = "Vehicle_LicensePlate_Item",
    moduleName = "client.slua.umg.vehicle.Vehicle_LicensePlate_Item",
    path = "/Game/UMG/UI_BP/Vehicle/CollectItem/Vehicle_LicensePlate_Item.Vehicle_LicensePlate_Item",
    isMainUI = false,
    uiStat = {
      name = "\232\189\189\229\133\183\230\148\182\233\155\134-\232\189\166\231\137\140"
    }
  },
  Vehicle_Collect_Box_Item = {
    keyName = "Vehicle_Collect_Box_Item",
    moduleName = "client.slua.umg.vehicle.Vehicle_Collect_Box_Item",
    path = "/Game/UMG/UI_BP/Vehicle/CollectItem/Vehicle_Collect_Box_Item.Vehicle_Collect_Box_Item",
    isMainUI = false,
    uiStat = {
      name = "\232\189\189\229\133\183\230\148\182\233\155\134-\229\135\187\230\157\128\231\155\146\229\173\144"
    }
  },
  Vehicle_Collect_Garage_Item = {
    keyName = "Vehicle_Collect_Garage_Item",
    moduleName = "client.slua.umg.vehicle.Vehicle_Collect_Garage_Item",
    path = "/Game/UMG/UI_BP/Vehicle/CollectItem/Vehicle_Collect_Garage_Item.Vehicle_Collect_Garage_Item",
    isMainUI = false,
    uiStat = {
      name = "\232\189\189\229\133\183\230\148\182\233\155\134-\232\183\145\232\189\166\232\189\166\229\186\147"
    }
  },
  Vehicle_Preview_Item = {
    keyName = "Vehicle_Preview_Item",
    moduleName = "client.slua.umg.vehicle.Vehicle_Preview_Item",
    path = "/Game/UMG/UI_BP/Vehicle/CollectItem/Vehicle_Preview_Item.Vehicle_Preview_Item",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\189\189\229\133\183\230\148\182\233\155\134-\233\162\132\232\167\136\229\155\190\230\160\135"
    }
  },
  Vehicle_CollectBenefit_UIBP = {
    keyName = "Vehicle_CollectBenefit_UIBP",
    moduleName = "client.slua.umg.vehicle.Vehicle_CollectBenefit_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_CollectBenefit_UIBP.Vehicle_CollectBenefit_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\189\189\229\133\183\230\148\182\233\155\134\229\188\185\231\170\151-\229\138\159\232\131\189\228\187\139\231\187\141"
    }
  },
  Vehicle_CollectBenefit_Item = {
    keyName = "Vehicle_CollectBenefit_Item",
    moduleName = "client.slua.umg.vehicle.Vehicle_CollectBenefit_Item",
    path = "/Game/UMG/UI_BP/Vehicle/CollectItem/Vehicle_CollectBenefit_Item.Vehicle_CollectBenefit_Item",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\232\189\189\229\133\183\230\148\182\233\155\134\229\188\185\231\170\151-\231\164\186\230\132\143\229\176\143\232\143\177\229\189\162"
    }
  },
  Vehicle_Unlock_In_Advance_Popup_UIBP = {
    keyName = "Vehicle_Unlock_In_Advance_Popup_UIBP",
    moduleName = "client.slua.umg.vehicle.Vehicle_Unlock_In_Advance_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_Unlock_In_Advance_Popup_UIBP.Vehicle_Unlock_In_Advance_Popup_UIBP",
    isMainUI = false,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\189\189\229\133\183\230\148\182\233\155\134-\232\191\148\232\191\152\229\165\150\229\138\177\233\162\134\229\143\150\229\188\185\231\170\151"
    }
  },
  Vehicle_Accessory_Preview_UIBP = {
    keyName = "Vehicle_Accessory_Preview_UIBP",
    moduleName = "client.slua.umg.vehicle.Accessory.Vehicle_Accessory_Preview_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_Accessory_Preview_UIBP.Vehicle_Accessory_Preview_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\189\189\229\133\183-\233\133\141\228\187\182\231\149\140\233\157\162"
    }
  },
  Vehicle_Container_UIBP_0 = {
    keyName = "Vehicle_Container_UIBP_0",
    moduleName = "client.slua.umg.vehicle.Vehicle_Container_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_Container_UIBP_0.Vehicle_Container_UIBP_0",
    uiStat = {
      name = "\232\183\145\232\189\166\231\169\186\230\138\149\231\174\177-\229\167\147\229\144\141\230\152\190\231\164\186"
    }
  },
  Vehicle_Container_UIBP_1 = {
    keyName = "Vehicle_Container_UIBP_1",
    moduleName = "client.slua.umg.vehicle.Vehicle_Container_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_Container_UIBP_1.Vehicle_Container_UIBP_1",
    uiStat = {
      name = "\232\183\145\232\189\166\231\169\186\230\138\149\231\174\177-\229\167\147\229\144\141\230\152\190\231\164\186"
    }
  },
  Vehicle_Container_UIBP_2 = {
    keyName = "Vehicle_Container_UIBP_2",
    moduleName = "client.slua.umg.vehicle.Vehicle_Container_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_Container_UIBP_2.Vehicle_Container_UIBP_2",
    uiStat = {
      name = "\232\183\145\232\189\166\231\169\186\230\138\149\231\174\177-\229\167\147\229\144\141\230\152\190\231\164\186"
    }
  },
  Vehicle_Container_UIBP_3 = {
    keyName = "Vehicle_Container_UIBP_3",
    moduleName = "client.slua.umg.vehicle.Vehicle_Container_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_Container_UIBP_3.Vehicle_Container_UIBP_3",
    uiStat = {
      name = "\232\183\145\232\189\166\231\169\186\230\138\149\231\174\177-\229\167\147\229\144\141\230\152\190\231\164\186"
    }
  },
  Vehicle_Container_UIBP_4 = {
    keyName = "Vehicle_Container_UIBP_4",
    moduleName = "client.slua.umg.vehicle.Vehicle_Container_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_Container_UIBP_4.Vehicle_Container_UIBP_4",
    uiStat = {
      name = "\232\183\145\232\189\166\231\169\186\230\138\149\231\174\177-\229\167\147\229\144\141\230\152\190\231\164\186"
    }
  },
  Vehicle_Collect_Use_Item = {
    keyName = "Vehicle_Collect_Use_Item",
    moduleName = "client.slua.umg.vehicle.Vehicle_Collect_Use_Item",
    path = "/Game/UMG/UI_BP/Vehicle/CollectItem/Vehicle_Collect_Use_Item.Vehicle_Collect_Use_Item",
    isMainUI = false,
    uiStat = {
      name = "\232\183\145\232\189\166\230\148\182\233\155\134-\228\189\191\231\148\168\230\136\144\229\176\177"
    }
  },
  Vehicle_Collect_Tyre_Item = {
    keyName = "Vehicle_Collect_Tyre_Item",
    moduleName = "client.slua.umg.vehicle.Vehicle_Collect_Tyre_Item",
    path = "/Game/UMG/UI_BP/Vehicle/CollectItem/Vehicle_Collect_Tyre_Item.Vehicle_Collect_Tyre_Item",
    isMainUI = false,
    uiStat = {
      name = "\232\183\145\232\189\166\230\148\182\233\155\134-\233\171\152\231\186\167\232\189\174\232\131\142"
    }
  },
  Vehicle_Preview_Select_UIBP = {
    keyName = "Vehicle_Preview_Select_UIBP",
    moduleName = "client.slua.umg.vehicle.Vehicle_Preview_Select_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_Preview_Select_UIBP.Vehicle_Preview_Select_UIBP",
    uiStat = {
      name = "\232\189\189\229\133\183-\229\136\135\230\141\162\231\149\140\233\157\162"
    }
  },
  Vehicle_DetailShow_UIBP = {
    keyName = "Vehicle_DetailShow_UIBP",
    moduleName = "client.slua.umg.vehicle.Vehicle_DetailShow_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/DetailShow/Vehicle_DetailShow_UIBP.Vehicle_DetailShow_UIBP",
    jumpModuleID = BP_ENUM_MODULE_VEHICLE_NEW_MODIFY,
    uiStat = {
      name = "\232\189\189\229\133\183\230\139\147\229\177\149\231\137\185\230\128\167\228\184\187\231\149\140\233\157\162"
    }
  },
  Vehicle_DetailShow_Applique_UIBP = {
    keyName = "Vehicle_DetailShow_Applique_UIBP",
    moduleName = "client.slua.umg.vehicle.DIY.Vehicle_DetailShow_Applique_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/DetailShow/Vehicle_DetailShow_Applique_UIBP.Vehicle_DetailShow_Applique_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\232\189\189\229\133\183\232\180\180\232\138\177\230\147\141\228\189\156\231\149\140\233\157\162"
    }
  },
  Vehicle_DetailShow_AppliqueEdit_UIBP = {
    keyName = "Vehicle_DetailShow_AppliqueEdit_UIBP",
    moduleName = "client.slua.umg.vehicle.DIY.Vehicle_DetailShow_AppliqueEdit_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/DetailShow/Vehicle_DetailShow_AppliqueEdit_UIBP.Vehicle_DetailShow_AppliqueEdit_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\232\189\189\229\133\183\232\180\180\232\138\177\230\147\141\228\189\156UI"
    }
  },
  Vehicle_NotUnlockAppliqueTips_Popup_UIBP = {
    keyName = "Vehicle_NotUnlockAppliqueTips_Popup_UIBP",
    moduleName = "client.slua.umg.vehicle.DIY.Vehicle_NotUnlockAppliqueTips_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/DetailShow/Vehicle_NotUnlockAppliqueTips_Popup_UIBP.Vehicle_NotUnlockAppliqueTips_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\232\189\189\229\133\183\232\180\180\232\138\177\228\191\157\229\173\152\230\156\170\230\139\165\230\156\137\230\143\144\231\164\186"
    }
  },
  ui_complaint_vehicle = {
    keyName = "ui_complaint_vehicle",
    moduleName = "client.slua.umg.complaint.ui_complaint_vehicle",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Item_UIBP2.Inform_Item_UIBP2",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\232\189\189\229\133\183"
    },
    isSingleton = false
  },
  Vehicle_CollectAward_Main_UIBP = {
    keyName = "Vehicle_CollectAward_Main_UIBP",
    moduleName = "client.slua.umg.vehicle.feature_unlock.Vehicle_CollectAward_Main_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_CollectAward_Main_UIBP.Vehicle_CollectAward_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_LEVEL_VEHICLE_NEW_MODIFY,
    uiStat = {
      name = "\232\189\189\229\133\183\229\183\165\229\157\138 - \231\137\185\230\174\138\230\149\136\230\158\156"
    }
  },
  Spray_Shop_Exchange_Popup_UIBP = {
    keyName = "Spray_Shop_Exchange_Popup_UIBP",
    moduleName = "client.slua.umg.vehicle.SprayShop.Popup.Spray_Shop_Exchange_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/SprayShop/Popup/Spray_Shop_Exchange_Popup_UIBP.Spray_Shop_Exchange_Popup_UIBP",
    uiStat = {
      name = "\232\189\189\229\133\183\232\180\180\232\138\177\229\133\145\230\141\162\229\136\151\232\161\168"
    }
  },
  Spray_Shop_Exchange_Popup02_UIBP = {
    keyName = "Spray_Shop_Exchange_Popup02_UIBP",
    moduleName = "client.slua.umg.vehicle.SprayShop.Popup.Spray_Shop_Exchange_Popup02_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/SprayShop/Popup/Spray_Shop_Exchange_Popup02_UIBP.Spray_Shop_Exchange_Popup02_UIBP",
    uiStat = {
      name = "\232\189\189\229\133\183\232\180\180\232\138\177\229\133\145\230\141\162\232\175\166\230\131\133"
    }
  },
  privilege_buy_pop = {
    keyName = "privilege_buy_pop",
    moduleName = "client.slua.umg.esports_privileges.privilege_buy_pop",
    path = "/Game/UMG/UI_BP/GamingEsportVIP/EsportVIP_buy_privilege_UIBP.EsportVIP_buy_privilege_UIBP",
    uiStat = {
      name = "\231\148\181\231\171\158\231\137\185\230\157\131-\232\180\173\228\185\176"
    }
  },
  privilege_buy_ticket = {
    keyName = "privilege_buy_ticket",
    moduleName = "client.slua.umg.esports_privileges.privilege_buy_ticket",
    path = "/Game/UMG/UI_BP/GamingEsportVIP/EsportVIP_cheerquan_ups_UIBP.EsportVIP_cheerquan_ups_UIBP",
    uiStat = {
      name = "\231\148\181\231\171\158\231\137\185\230\157\131-\229\138\169\229\168\129\229\136\184"
    }
  },
  privilege_buy_coin = {
    keyName = "privilege_buy_coin",
    moduleName = "client.slua.umg.esports_privileges.privilege_buy_coin",
    path = "/Game/UMG/UI_BP/GamingEsportVIP/EsportVIP_buy_currency_UIBP.EsportVIP_buy_currency_UIBP",
    uiStat = {
      name = "\231\148\181\231\171\158\231\137\185\230\157\131-\232\180\167\229\184\129"
    }
  },
  privilege_cheer = {
    keyName = "privilege_cheer",
    moduleName = "client.slua.umg.esports_privileges.privilege_cheer",
    path = "/Game/UMG/UI_BP/GamingEsportVIP/EsportVIP_cheer_UIBP.EsportVIP_cheer_UIBP",
    uiStat = {
      name = "\231\148\181\231\171\158\231\137\185\230\157\131-\229\138\169\229\168\129"
    }
  },
  privilege_cheer_pop = {
    keyName = "privilege_cheer_pop",
    moduleName = "client.slua.umg.esports_privileges.privilege_cheer_pop",
    path = "/Game/UMG/UI_BP/GamingEsportVIP/EsportVIP_cheer_ups_UIBP.EsportVIP_cheer_ups_UIBP",
    uiStat = {
      name = "\231\148\181\231\171\158\231\137\185\230\157\131-\229\138\169\229\168\129\229\188\185\231\170\151"
    }
  },
  privilege_detail_pop = {
    keyName = "privilege_detail_pop",
    moduleName = "client.slua.umg.esports_privileges.privilege_detail_pop",
    path = "/Game/UMG/UI_BP/GamingEsportVIP/EsportVIP_Pop_ups_UIBP.EsportVIP_Pop_ups_UIBP",
    uiStat = {
      name = "\231\148\181\231\171\158\231\137\185\230\157\131-\232\175\166\230\131\133"
    }
  },
  privilege_main = {
    keyName = "privilege_main",
    moduleName = "client.slua.umg.esports_privileges.privilege_main",
    path = "/Game/UMG/UI_BP/GamingEsportVIP/EsportVIP_buy_UIBP.EsportVIP_buy_UIBP",
    uiStat = {
      name = "\231\148\181\231\171\158\231\137\185\230\157\131"
    }
  },
  privilege_sign = {
    keyName = "privilege_sign",
    moduleName = "client.slua.umg.esports_privileges.privilege_sign",
    path = "/Game/UMG/UI_BP/GamingEsportVIP/EsportVIP_sign_in_UIBP.EsportVIP_sign_in_UIBP",
    uiStat = {
      name = "\231\148\181\231\171\158\231\137\185\230\157\131-\231\173\190\229\136\176"
    }
  },
  CustomCare_CoinRecord_Popup_UIBP = {
    keyName = "CustomCare_CoinRecord_Popup_UIBP",
    moduleName = "client.slua.umg.CustomCare.CustomCare_CoinRecord_Popup_UIBP",
    path = "/Game/UMG/UI_BP/CustomCare/CustomCare_CoinRecord_Popup_UIBP.CustomCare_CoinRecord_Popup_UIBP",
    uiStat = {
      name = "\232\128\129\229\143\139\229\133\179\230\128\128-\231\167\175\229\136\134\232\174\176\229\189\149"
    }
  },
  CustomCare_TeamUp_Popup_UIBP = {
    keyName = "CustomCare_TeamUp_Popup_UIBP",
    moduleName = "client.slua.umg.CustomCare.CustomCare_TeamUp_Popup_UIBP",
    path = "/Game/UMG/UI_BP/CustomCare/CustomCare_TeamUp_Popup_UIBP.CustomCare_TeamUp_Popup_UIBP",
    uiStat = {
      name = "\232\128\129\229\143\139\229\133\179\230\128\128-\233\155\134\231\187\147\231\187\132\233\152\159"
    }
  },
  Career_InformationCard_UIBP = {
    keyName = "Career_InformationCard_UIBP",
    moduleName = "GameLua.Mod.Library.Client.Career.Career_InformationCard_UIBP",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Career/Career_InformationCard_UIBP.Career_InformationCard_UIBP",
    uiStat = {
      name = "\231\148\159\230\182\175\230\151\151\229\184\156\229\177\149\231\164\186UI"
    }
  },
  TeamUp_Member_SportsCar_UIBP = {
    keyName = "TeamUp_Member_SportsCar_UIBP",
    moduleName = "client.slua.umg.team.TeamUp_Member_SportsCar_UIBP",
    path = "/Game/UMG/UI_BP/TeamUp/TeamUp_Member_SportsCar_UIBP.TeamUp_Member_SportsCar_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\229\133\165\233\152\159\232\183\145\232\189\166\229\177\149\231\164\186"
    }
  },
  BestPartner_Main_UIBP = {
    keyName = "BestPartner_Main_UIBP",
    moduleName = "client.slua.umg.best_partner.BestPartner_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_BEST_PARTNER,
    path = "/Game/Arts_UI/AFD/3300/AirdropCarnival/BestPartner/BestPartner_Main_UIBP.BestPartner_Main_UIBP",
    uiStat = {
      name = "\230\156\128\228\189\179\230\144\173\230\161\163\228\184\187\231\149\140\233\157\162"
    }
  },
  BestPartner_PartnerInvite_Invite = {
    keyName = "BestPartner_PartnerInvite_Invite",
    moduleName = "client.slua.umg.best_partner.BestPartner_PartnerInvite_Invite",
    path = "/Game/Arts_UI/AFD/3300/AirdropCarnival/BestPartner/BestPartner_PartnerInvite_Invite.BestPartner_PartnerInvite_Invite",
    uiStat = {
      name = "\233\130\128\232\175\183\230\144\173\230\161\163"
    }
  },
  Placard_UIBP = {
    keyName = "Placard_UIBP",
    moduleName = "client.slua.umg.ShowBrand.Placard_UIBP",
    path = "/Game/UMG/UI_BP/ShowBrand/Placard_UIBP.Placard_UIBP",
    uiStat = {
      name = "\228\184\190\231\137\140\231\149\140\233\157\162"
    }
  },
  Placard_MedalSelection_UIBP = {
    keyName = "Placard_MedalSelection_UIBP",
    moduleName = "client.slua.umg.ShowBrand.Placard_MedalSelection_UIBP",
    path = "/Game/UMG/UI_BP/ShowBrand/Placard_MedalSelection_UIBP.Placard_MedalSelection_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\184\190\231\137\140\232\174\190\231\189\174\231\149\140\233\157\162"
    }
  },
  Vehicle_Return_UIBP = {
    keyName = "Vehicle_Return_UIBP",
    moduleName = "client.slua.umg.vehicle.traits.Vehicle_Return_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/Vehicle_Return_UIBP.Vehicle_Return_UIBP",
    uiStat = {
      name = "\229\183\165\229\157\138\229\133\168\229\177\143\232\191\148\229\155\158\231\149\140\233\157\162"
    }
  }
}
return vehicle_ui_configs