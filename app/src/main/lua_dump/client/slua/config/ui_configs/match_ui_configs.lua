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
local match_ui_configs = {
  match_mode_option_t_plan = {
    keyName = "match_mode_option_t_plan",
    moduleName = "client.slua.umg.match.match_mode_option_t_plan",
    path = "/Game/Mod/TPlan/XMission/UMG/Popup/Match_SelectMap_01_UIBP1.Match_SelectMap_01_UIBP1",
    asy = true,
    uiStat = {
      name = "\230\168\161\229\188\143\233\128\137\230\139\169-\229\140\185\233\133\141\232\174\190\231\189\174-T\231\142\169\230\179\149"
    }
  },
  match_zone_menu = {
    keyName = "match_zone_menu",
    moduleName = "client.slua.umg.match.match_zone_menu",
    path = "/Game/UMG/UI_BP/Match/Match_Item/ChooseZone_Menu_UIBP.ChooseZone_Menu_UIBP",
    isSingleton = false
  },
  ChooseZone_Delay_Tips_UIBP = {
    keyName = "ChooseZone_Delay_Tips_UIBP",
    moduleName = "client.slua.umg.match.ChooseZone_Delay_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Match/Match_Item/ChooseZone_Delay_Tips_UIBP.ChooseZone_Delay_Tips_UIBP"
  },
  mode_selection_main = {
    keyName = "mode_selection_main",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Main_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Main_UIBP.ModeSelection_Main_UIBP",
    ODPackID = PufferConst.EODPackID.ModeSelect,
    jumpModuleID = BP_ENUM_MODULE_MATCH_MODE_SELECTION,
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\228\184\187\231\149\140\233\157\162"
    }
  },
  mode_selection_anim = {
    keyName = "mode_selection_anim",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Opening_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Opening_UIBP.ModeSelection_Opening_UIBP",
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\229\138\168\231\148\187"
    }
  },
  item_big_mode_selection_main = {
    keyName = "item_big_mode_selection_main",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Main_Map01_Item",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Main_Map01_Item.ModeSelection_Main_Map01_Item",
    isSingleton = false,
    isWindowsOBHide = true,
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\229\164\167\232\167\134\229\155\190item"
    }
  },
  item_peak_mode_selection_main = {
    keyName = "item_peak_mode_selection_main",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Main_Map_Item_Peak",
    path = "/Game/UMG/UI_BP/PeakGame/ModeSelection_Map_Peak_Item.ModeSelection_Map_Peak_Item",
    isSingleton = false,
    isWindowsOBHide = true,
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\229\183\133\229\179\176\232\181\155\232\167\134\229\155\190item"
    }
  },
  ModeSelection_Map_Asymmetric_Item = {
    keyName = "ModeSelection_Map_Asymmetric_Item",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Map_Asymmetric_Item",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Main_Map03_Item.ModeSelection_Main_Map03_Item",
    isSingleton = false,
    isWindowsOBHide = true,
    uiStat = {
      name = "\233\157\158\229\175\185\231\167\176-\232\182\133\229\164\167\232\167\134\229\155\190item"
    }
  },
  ModeSelection_EscapeCampSelection_Popup_UIBP = {
    keyName = "ModeSelection_EscapeCampSelection_Popup_UIBP",
    moduleName = "client.slua.umg.ModeSelection.Popup.ModeSelection_EscapeCampSelection_Popup_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/Popup/ModeSelection_EscapeCampSelection_Popup_UIBP.ModeSelection_EscapeCampSelection_Popup_UIBP",
    uiStat = {
      name = "\233\157\158\229\175\185\231\167\176-\233\152\181\232\144\165\233\128\137\230\139\169"
    }
  },
  ModeSelection_EscapeCampSelection_Popup01_UIBP = {
    keyName = "ModeSelection_EscapeCampSelection_Popup01_UIBP",
    moduleName = "client.slua.umg.ModeSelection.Popup.ModeSelection_EscapeCampSelection_Popup01_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/Popup/ModeSelection_EscapeCampSelection_Popup01_UIBP.ModeSelection_EscapeCampSelection_Popup01_UIBP",
    uiStat = {
      name = "\233\157\158\229\175\185\231\167\176-\232\191\189\230\157\128\233\152\181\232\144\165"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  ModeSelection_EscapeCampSelection_Popup02_UIBP = {
    keyName = "ModeSelection_EscapeCampSelection_Popup02_UIBP",
    moduleName = "client.slua.umg.ModeSelection.Popup.ModeSelection_EscapeCampSelection_Popup02_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/Popup/ModeSelection_EscapeCampSelection_Popup02_UIBP.ModeSelection_EscapeCampSelection_Popup02_UIBP",
    uiStat = {
      name = "\233\157\158\229\175\185\231\167\176-\229\185\184\229\173\152\233\152\181\232\144\165"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  MainBackPack_Tips_MaterialBox_Outside_BP = {
    keyName = "MainBackPack_Tips_MaterialBox_Outside_BP",
    moduleName = "client.slua.umg.ModeSelection.Item.MainBackPack_Tips_MaterialBox_Outside_BP",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/MainBackPack_Tips_MaterialBox_Outside_BP.MainBackPack_Tips_MaterialBox_Outside_BP",
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\229\143\139\229\150\132\229\128\188\229\188\185\231\170\151"
    }
  },
  mode_selection_option = {
    keyName = "mode_selection_option",
    moduleName = "client.slua.umg.ModeSelection.Match_SelectMap_01_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/Match_SelectMap_01_UIBP.Match_SelectMap_01_UIBP",
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\229\140\185\233\133\141\232\174\190\231\189\174"
    }
  },
  item_small_mode_selection_main = {
    keyName = "item_small_mode_selection_main",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Main_Map01_Item",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Main_Map02_Item.ModeSelection_Main_Map02_Item",
    isSingleton = false,
    isWindowsOBHide = true,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\229\176\143\232\167\134\229\155\190item"
    }
  },
  ModeSelection_Custom_Item_UIBP = {
    keyName = "ModeSelection_Custom_Item_UIBP",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Custom_Item_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/Item/ModeSelection_Custom_Item_UIBP.ModeSelection_Custom_Item_UIBP",
    isSingleton = false,
    isWindowsOBHide = true,
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\229\143\179\228\190\167\232\167\134\229\155\190item"
    }
  },
  item_newbie_small_mode_selection_main = {
    keyName = "item_newbie_small_mode_selection_main",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Main_Map03_Item",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Main_Map02_Item.ModeSelection_Main_Map02_Item",
    isSingleton = false,
    isWindowsOBHide = true,
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\230\150\176\230\137\139\232\174\173\231\187\131\229\176\143\232\167\134\229\155\190item"
    }
  },
  ModeSelection_Custom_WowMap_Item = {
    keyName = "ModeSelection_Custom_WowMap_Item",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Custom_WowMap_Item",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Main_WowMap_Item_UIBP.ModeSelection_Main_WowMap_Item_UIBP",
    isSingleton = false,
    isWindowsOBHide = true,
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-Wow\229\156\176\229\155\190\229\176\143\232\167\134\229\155\190item"
    }
  },
  item_double_small_mode_selection_main = {
    keyName = "item_double_small_mode_selection_main",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Main_Map_Item",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Main_Map_Item.ModeSelection_Main_Map_Item",
    isSingleton = false,
    isWindowsOBHide = true,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\229\143\140\229\176\143\232\167\134\229\155\190item"
    }
  },
  item_multi_big_mode_selection_main = {
    keyName = "item_multi_big_mode_selection_main",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Main_MultiMap01_Item",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Main_MultiMap01_Item.ModeSelection_Main_MultiMap01_Item",
    isSingleton = false,
    isWindowsOBHide = true,
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\229\155\162\231\171\158\229\164\167Item"
    }
  },
  item_multi_small_mode_selection_main = {
    keyName = "item_multi_small_mode_selection_main",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Main_MultiMap01_Item",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Main_MultiMap02_Item.ModeSelection_Main_MultiMap02_Item",
    isSingleton = false,
    isWindowsOBHide = true,
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\229\155\162\231\171\158\229\176\143Item"
    }
  },
  mode_selection_multi_popup = {
    keyName = "mode_selection_multi_popup",
    moduleName = "client.slua.umg.ModeSelection.multi_select.ModeSelection_Multi_Popup",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_ArmsRaceMap_UIBP.ModeSelection_ArmsRaceMap_UIBP",
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\229\164\154\233\128\137\229\188\185\231\170\151"
    }
  },
  ModeSelection_Guide_UIBP = {
    keyName = "ModeSelection_Guide_UIBP",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Guide_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Guide_UIBP.ModeSelection_Guide_UIBP",
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169\228\184\187\231\149\140\233\157\162-\230\168\161\229\188\143\232\175\166\231\187\134\228\187\139\231\187\141"
    }
  },
  ModeSelection_Guide_UIBP02 = {
    keyName = "ModeSelection_Guide_UIBP02",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Guide_UIBP02",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Guide_UIBP02.ModeSelection_Guide_UIBP02",
    uiStat = {
      name = "\229\164\167\229\142\133-\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\228\184\187\231\149\140\233\157\162-\230\168\161\229\188\143\232\175\166\231\187\134\228\187\139\231\187\141\228\187\133\230\150\135\230\156\172"
    }
  },
  GamePlayGuide_Popup_UIBP = {
    keyName = "GamePlayGuide_Popup_UIBP",
    moduleName = "client.slua.umg.ModeSelection.GamePlayGuide_Popup_UIBP",
    path = "/Game/BluePrints/Game/BluePrints/UI/GamePlayGuide_Popup_UIBP.GamePlayGuide_Popup_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\228\184\187\231\149\140\233\157\162-\230\168\161\229\188\143\232\175\166\231\187\134\228\187\139\231\187\141GAMEGUIDE"
    }
  },
  mode_selection_filter = {
    keyName = "mode_selection_filter",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Main_Person_Tips",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Main_Person_Tips.ModeSelection_Main_Person_Tips",
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169\228\184\187\231\149\140\233\157\162-\232\191\135\230\187\164"
    }
  },
  ModeSelection_Popup_level_UIBP = {
    keyName = "ModeSelection_Popup_level_UIBP",
    moduleName = "client.slua.umg.ModeSelection.Popup.ModeSelection_Popup_level_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/Popup/ModeSelection_Popup_level_UIBP.ModeSelection_Popup_level_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\232\191\155\233\152\182\232\174\173\231\187\131\229\133\179 - \230\149\153\231\168\139\229\133\179\229\141\161\229\188\185\231\170\151"
    }
  },
  ModeSelection_Popup_Video_UIBP = {
    keyName = "ModeSelection_Popup_Video_UIBP",
    moduleName = "client.slua.umg.ModeSelection.Popup.ModeSelection_Popup_Video_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/Popup/ModeSelection_Popup_Video_UIBP.ModeSelection_Popup_Video_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\232\191\155\233\152\182\232\174\173\231\187\131\229\133\179 - \232\167\134\233\162\145\229\133\179\229\141\161\229\188\185\231\170\151"
    }
  },
  room_list_create_match_select = {
    keyName = "room_list_create_match_select",
    moduleName = "client.slua.umg.room.list.room_list_create_match_select",
    path = "/Game/UMG/UI_BP/Room/Room_CreateRoom_UIBP_Item.Room_CreateRoom_UIBP_Item",
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\229\136\155\229\187\186\232\181\155\228\186\139\233\128\137\230\139\169"
    }
  },
  arena_main = {
    keyName = "arena_main",
    moduleName = "client.slua.umg.arena.arena_main",
    path = "/Game/UMG/UI_BP/Match/match_Evolutionary_bp.match_Evolutionary_bp",
    uiStat = {
      name = "\231\171\158\230\138\128\229\156\186-\228\184\187\231\149\140\233\157\162"
    },
    jumpModuleID = BP_ENUM_MODULE_ARENA_MAIN
  },
  arena_info = {
    keyName = "arena_info",
    moduleName = "client.slua.umg.arena.arena_info",
    path = "/Game/UMG/UI_BP/Match/Match_Item/match_Evolutionary_item.match_Evolutionary_item",
    isSingleton = false,
    uiStat = {
      name = "\231\171\158\230\138\128\229\156\186-\228\184\187\231\149\140\233\157\162-\230\174\181\228\189\141\229\177\149\231\164\186"
    }
  },
  mentor_match_option_entry = {
    keyName = "mentor_match_option_entry",
    moduleName = "client.slua.umg.mentor.mentor_match_option_entry",
    path = "/Game/UMG/UI_BP/PartnerReadiness/Item/PartnerReadiness_MapSelect_UIBP.PartnerReadiness_MapSelect_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\229\140\185\233\133\141\232\174\190\231\189\174\229\133\165\229\143\163"
    }
  },
  mentor_match_option_new = {
    keyName = "mentor_match_option_new",
    moduleName = "client.slua.umg.mentor.mentor_match_option_new",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_SelectSetting_UIBP.PartnerReadiness_SelectSetting_UIBP",
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\229\140\185\233\133\141\232\174\190\231\189\174\231\149\140\233\157\162-\230\150\176"
    }
  },
  ui_complaint_deathmatch = {
    keyName = "ui_complaint_deathmatch",
    moduleName = "client.slua.umg.complaint.ui_complaint_deathmatch",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Item_UIBP2.Inform_Item_UIBP2",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\229\155\162\231\171\158"
    },
    isSingleton = false
  },
  allstar_match_team = {
    keyName = "allstar_match_team",
    moduleName = "client.slua.umg.esport.allstar.match.allstar_match_team",
    path = "/Game/UMG/UI_BP/ESport/AllStar/Enter_the_game/ESport_enter_team_UIBP.ESport_enter_team_UIBP",
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\230\175\148\232\181\155-\233\152\159\228\188\141\231\174\161\231\144\134"
    }
  },
  ModeSelection_Opening_UIBP = {
    keyName = "ModeSelection_Opening_UIBP",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Opening_UIBP",
    isMainUI = false
  },
  LudoInvite_UIBP = {
    keyName = "LudoInvite_UIBP",
    moduleName = "client.slua.umg.ludo.LudoInvite_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Popup/PlanPH_LudoInvite_Popup_UIBP.PlanPH_LudoInvite_Popup_UIBP",
    uiStat = {
      name = "ludo\230\163\139\233\130\128\232\175\183"
    }
  },
  ModeSelection_Custom_UIBP = {
    keyName = "ModeSelection_Custom_UIBP",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Custom_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Custom_UIBP.ModeSelection_Custom_UIBP",
    zOrder = 0,
    uiStat = {
      name = "\229\143\179\228\190\167\229\191\171\230\141\183\230\168\161\229\188\143\232\135\170\229\174\154\228\185\137\230\168\161\229\188\143\231\149\140\233\157\162"
    }
  },
  ModeSelection_Select_UIBP = {
    keyName = "ModeSelection_Select_UIBP",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Select_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Select_UIBP.ModeSelection_Select_UIBP",
    zOrder = 0,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\229\143\179\228\190\167\229\191\171\230\141\183\229\184\184\233\169\187\230\168\161\229\188\143\233\128\137\230\139\169\231\149\140\233\157\162"
    }
  },
  ModeSelection_Wow_UIBP = {
    keyName = "ModeSelection_Wow_UIBP",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Wow_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Wow_UIBP.ModeSelection_Wow_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UGC_ModeSelection_Wow,
    zOrder = 0,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\229\143\179\229\177\143Wow\228\184\187\231\149\140\233\157\162"
    }
  },
  mode_selection_main_4_Wow = {
    keyName = "mode_selection_main_4_Wow",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Main_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Main_UIBP.ModeSelection_Main_UIBP",
    ODPackID = PufferConst.EODPackID.ModeSelect,
    isMainUI = false,
    uiStat = {
      name = "\228\189\156\228\184\186\229\173\144UI\230\140\130\232\189\189\229\156\168ModeSelection_Wow_UIBP\228\184\139"
    }
  },
  ModeSelection_Custom_Popup_UIBP = {
    keyName = "ModeSelection_Custom_Popup_UIBP",
    moduleName = "client.slua.umg.ModeSelection.Popup.ModeSelection_Custom_Popup_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/Popup/ModeSelection_Custom_Popup_UIBP.ModeSelection_Custom_Popup_UIBP",
    uiStat = {
      name = "\229\143\179\228\190\167\229\191\171\230\141\183\229\184\184\233\169\187\230\168\161\229\188\143\233\128\137\230\139\169\229\188\185\231\170\151"
    }
  },
  ModeSelection_Custom_Popup_Wow_UIBP = {
    keyName = "ModeSelection_Custom_Popup_Wow_UIBP",
    moduleName = "client.slua.umg.ModeSelection.Popup.ModeSelection_Custom_Popup_Wow_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/Popup/ModeSelection_Custom_Popup_Wow_UIBP.ModeSelection_Custom_Popup_Wow_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\143\179\228\190\167\229\191\171\230\141\183\229\184\184\233\169\187\230\168\161\229\188\143\233\128\137\230\139\169\229\188\185\231\170\151-Wow\229\173\144\233\161\181\231\173\190"
    }
  },
  ModeSelection_Set_Item_UIBP = {
    keyName = "ModeSelection_Set_Item_UIBP",
    moduleName = "client.slua.umg.ModeSelection.Item.ModeSelection_Set_Item_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/Item/ModeSelection_Set_Item_UIBP.ModeSelection_Set_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\143\179\229\177\143-\232\174\190\231\189\174"
    }
  },
  ModeSelection_Opening_Train_UIBP = {
    keyName = "ModeSelection_Opening_Train_UIBP",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Opening_Train_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_Opening_Train_UIBP.ModeSelection_Opening_Train_UIBP",
    zOrder = EFixedZOrder.TopZOrder,
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\143\179\229\177\143-\232\191\135\230\184\161\229\138\168\231\148\187"
    }
  },
  Com_Match_Black_UIBP = {
    keyName = "Com_Match_Black_UIBP",
    moduleName = "client.slua.umg.Common.Com_Match_Black_UIBP",
    path = "/Game/UMG/UI_BP/Common/Com_Match_Black_UIBP.Com_Match_Black_UIBP",
    uiStat = {
      name = "\230\139\137\233\187\145tips\231\149\140\233\157\162"
    }
  },
  ModeSelection_PingList_UIBP = {
    keyName = "ModeSelection_PingList_UIBP",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_PingList_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/ModeSelection_PingList_UIBP.ModeSelection_PingList_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\233\152\159\228\188\141\229\140\185\233\133\141\229\187\182\232\191\159\231\149\140\233\157\162"
    }
  },
  ModeSelection_Map_Team_Item = {
    keyName = "ModeSelection_Map_Team_Item",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Map_Team_Item",
    path = "/Game/UMG/UI_BP/Team_competition/ModeSelection_Map_Team_Item.ModeSelection_Map_Team_Item",
    isSingleton = false,
    isWindowsOBHide = true,
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\229\155\162\231\171\158\232\167\134\229\155\190item"
    }
  },
  newbie_mode_select = {
    keyName = "newbie_mode_select",
    moduleName = "client.slua.umg.newbie.newbie_mode_select",
    path = "/Game/UMG/UI_BP/Newbie/Newbie_ModeSelect_UIBP.Newbie_ModeSelect_UIBP",
    AndroidBackType = EAndroidBackType.Ban
  },
  newbie_mode_select_entry = {
    keyName = "newbie_mode_select_entry",
    moduleName = "client.slua.umg.newbie.newbie_mode_select_entry",
    path = "/Game/UMG/UI_BP/Newbie/Newbie_ModeSelect_Entry_UIBP.Newbie_ModeSelect_Entry_UIBP",
    AndroidBackType = EAndroidBackType.Ban
  },
  arena_levelup = {
    moduleName = "client.slua.umg.arena.arena_levelup",
    path = "/Game/UMG/UI_BP/Match/match_SeasonGet_UIBP.match_SeasonGet_UIBP",
    uiStat = {
      name = "\231\171\158\230\138\128\229\156\186-\228\184\187\231\149\140\233\157\162-\229\139\139\231\171\160\232\167\163\233\148\129"
    }
  }
}
return match_ui_configs