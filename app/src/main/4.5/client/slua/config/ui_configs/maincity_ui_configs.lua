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
local maincity_ui_configs = {
  Moment_MainCity_Tab_Photo_Detail = {
    keyName = "Moment_MainCity_Tab_Photo_Detail",
    moduleName = "client.slua.umg.moment.Moment_MainCity_Tab_Photo_Detail",
    path = "/Game/UMG/UI_BP/Moment/Moment_Photo_Detail_UIBP.Moment_Photo_Detail_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142\231\155\184\229\134\140\233\161\181\231\173\190-\229\155\190\231\137\135\232\175\166\230\131\133"
    }
  },
  MainCity_ModeSelection_PingList_UIBP = {
    keyName = "MainCity_ModeSelection_PingList_UIBP",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_PingList_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Item/MainCity_PingList_Item_UIBP.MainCity_PingList_Item_UIBP",
    uiStat = {
      name = "\233\152\159\228\188\141\229\140\185\233\133\141\229\187\182\232\191\159\231\149\140\233\157\162-\228\184\187\229\159\142"
    }
  },
  MainCity_Main_UIBP = {
    keyName = "MainCity_Main_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.MainCity_Main_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/MainCity_Main_UIBP.MainCity_Main_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\228\184\187\229\159\142-\228\184\187\231\149\140\233\157\162"
    },
    containerName = UIContainers.Bottom
  },
  MainCity_Operation_UIBP = {
    keyName = "MainCity_Operation_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.MainCity_Operation_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/MainCity_Operation_UIBP.MainCity_Operation_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\230\147\141\228\189\156\231\149\140\233\157\162"
    },
    asy = true,
    isMainUI = false
  },
  MainCity_Info_UIBP = {
    keyName = "MainCity_Info_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.MainCity_Info_UIBP",
    path = "/Game/UMG/UI_BP/LobbyChat/Personal_Info_UIBP.Personal_Info_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\231\142\169\229\174\182\228\191\161\230\129\175\229\141\161\231\149\140\233\157\162"
    }
  },
  MainCity_PositionPanel_UIBP = {
    keyName = "MainCity_PositionPanel_UIBP",
    moduleName = "client.slua.umg.MainCity.Position.MainCity_PositionPanel_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Position/MainCity_PositionPanel_UIBP.MainCity_PositionPanel_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\231\142\169\229\174\182\229\164\180\233\161\182\228\191\161\230\129\175\231\149\140\233\157\162"
    },
    asy = true,
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false
  },
  MainCity_Main_Tab_UIBP = {
    keyName = "MainCity_Main_Tab_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.Tab.MainCity_Main_Tab_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Tab/MainCity_Main_Tab_UIBP.MainCity_Main_Tab_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\229\183\166\228\184\138\232\167\146\231\149\140\233\157\162"
    },
    asy = true,
    isMainUI = false
  },
  MainCity_Shop_UIBP = {
    keyName = "MainCity_Shop_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.MainCity_Shop_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/MainCity_Shop_UIBP.MainCity_Shop_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\229\143\179\228\184\138\232\167\146\229\149\134\229\159\142\231\149\140\233\157\162"
    },
    asy = true,
    isMainUI = false
  },
  MainCity_System_UIBP = {
    keyName = "MainCity_System_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.MainCity_System_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/MainCity_System_UIBP.MainCity_System_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\228\184\187\229\159\142-\231\179\187\231\187\159\231\149\140\233\157\162"
    }
  },
  MainCity_Multi_Interactive_UIBP = {
    keyName = "MainCity_Multi_Interactive_UIBP",
    moduleName = "GameLua.Mod.MainCity.Client.UI.Interact.MainCity_Multi_Interactive_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Interact/MainCity_Multi_Interactive_UIBP.MainCity_Multi_Interactive_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\228\186\164\228\186\146\231\137\169\228\187\182-UI\230\140\137\233\146\174"
    },
    isMainUI = false
  },
  MainCity_Dance_Customize_UIBP = {
    keyName = "MainCity_Dance_Customize_UIBP",
    moduleName = "GameLua.Mod.MainCity.Client.UI.Dance.MainCity_Dance_Customize_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Dance/MainCity_Dance_Customize_UIBP.MainCity_Dance_Customize_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\184\187\229\159\142-\232\136\158\232\185\136\229\174\154\229\136\182\231\149\140\233\157\162"
    }
  },
  MainCity_DanceSelect_UIBP = {
    keyName = "MainCity_DanceSelect_UIBP",
    moduleName = "GameLua.Mod.MainCity.Client.UI.Dance.MainCity_DanceSelect_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Dance/MainCity_DanceSelect_UIBP.MainCity_DanceSelect_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\184\187\229\159\142-\232\136\158\232\185\136\233\128\137\230\139\169\231\149\140\233\157\162"
    }
  },
  MainCity_Main_Dance_UIBP = {
    keyName = "MainCity_Main_Dance_UIBP",
    moduleName = "GameLua.Mod.MainCity.Client.UI.Dance.MainCity_Main_Dance_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Dance/MainCity_Console_Main_UIBP.MainCity_Console_Main_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\232\136\158\232\185\136\228\184\187\231\149\140\233\157\162"
    }
  },
  MainCity_Dance_Status_UIBP = {
    keyName = "MainCity_Dance_Status_UIBP",
    moduleName = "GameLua.Mod.MainCity.Client.UI.Dance.MainCity_Dance_Status_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Dance/MainCity_Dance_Status_UIBP.MainCity_Dance_Status_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\232\136\158\232\185\136\231\138\182\230\128\129\231\149\140\233\157\162"
    }
  },
  MainCity_Newbie_Slide_UIBP = {
    keyName = "MainCity_Newbie_Slide_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.MainCity_Newbie_Slide_UIBP",
    path = "/Game/UMG/UI_BP/MainCity/Main/MainCity_Newbie_Slide_UIBP.MainCity_Newbie_Slide_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\229\133\165\229\143\163\229\188\149\229\175\188\231\149\140\233\157\162"
    }
  },
  MainCity_DanceMusic_Interactive_UIBP = {
    keyName = "MainCity_DanceMusic_Interactive_UIBP",
    moduleName = "GameLua.Mod.MainCity.Client.UI.Interact.MainCity_DanceMusic_Interactive_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Interact/MainCity_DanceMusic_Interactive_UIBP.MainCity_DanceMusic_Interactive_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\232\136\158\232\185\136\233\159\179\228\185\144\228\186\164\228\186\146\231\149\140\233\157\162"
    }
  },
  MainCity_Seesaw_QTE_UIBP = {
    keyName = "MainCity_Seesaw_QTE_UIBP",
    moduleName = "GameLua.Mod.MainCity.Client.UI.Seesaw.MainCity_Seesaw_QTE_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Seesaw/MainCity_Seesaw_QTE_UIBP.MainCity_Seesaw_QTE_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\232\183\183\232\183\183\230\157\191-QTE\230\184\184\230\136\143\228\184\187\231\149\140\233\157\162"
    },
    ays = true,
    AndroidBackType = EAndroidBackType.Skip
  },
  MainCity_Seesaw_QTE_Item_UIBP = {
    keyName = "MainCity_Seesaw_QTE_Item_UIBP",
    moduleName = "GameLua.Mod.MainCity.Client.UI.Seesaw.Items.MainCity_Seesaw_QTE_Item_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Seesaw/Items/MainCity_Seesaw_QTE_Item_UIBP.MainCity_Seesaw_QTE_Item_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\232\183\183\232\183\183\230\157\191-QTE\230\184\184\230\136\143\230\140\137\233\146\174"
    }
  },
  MainCity_Seesaw_Rule_UIBP = {
    keyName = "MainCity_Seesaw_Rule_UIBP",
    moduleName = "GameLua.Mod.MainCity.Client.UI.Seesaw.Popup.MainCity_Seesaw_Rule_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Seesaw/Popup/MainCity_Seesaw_Rule_UIBP.MainCity_Seesaw_Rule_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\232\183\183\232\183\183\230\157\191-\232\167\132\229\136\153\228\187\139\231\187\141\231\149\140\233\157\162"
    },
    asy = true,
    AndroidBackType = EAndroidBackType.Skip
  },
  MainCity_Invite_Popup_UIBP = {
    keyName = "MainCity_Invite_Popup_UIBP",
    moduleName = "client.slua.umg.MainCity.Popup.MainCity_Invite_Popup_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Popup/MainCity_Invite_Popup_UIBP.MainCity_Invite_Popup_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\233\130\128\232\175\183\231\149\140\233\157\162"
    }
  },
  MainCity_SeesawInvite_Popup_UIBP = {
    keyName = "MainCity_SeesawInvite_Popup_UIBP",
    moduleName = "client.slua.umg.MainCity.Popup.MainCity_SeesawInvite_Popup_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Popup/MainCity_Invite_Popup_UIBP.MainCity_Invite_Popup_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\232\183\183\232\183\183\230\157\191\233\130\128\232\175\183\231\149\140\233\157\162"
    }
  },
  MainCity_WebgameInvite_Popup_UIBP = {
    keyName = "MainCity_WebgameInvite_Popup_UIBP",
    moduleName = "client.slua.umg.MainCity.Popup.MainCity_WebgameInvite_Popup_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Popup/MainCity_Invite_Popup_UIBP.MainCity_Invite_Popup_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-H5\230\163\139\231\137\140\233\130\128\232\175\183\231\149\140\233\157\162"
    }
  },
  MainCity_Tab_Entrance_UIBP = {
    keyName = "MainCity_Tab_Entrance_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.Tab.MainCity_Tab_Entrance_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Tab/MainCity_Tab_Entrance_UIBP.MainCity_Tab_Entrance_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\229\183\165\229\157\138"
    }
  },
  MainCity_Invite_Tips_UIBP = {
    keyName = "MainCity_Invite_Tips_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.Match.PopUp.MainCity_Invite_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/MainCity_Invite_Tips_UIBP.MainCity_Invite_Tips_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\228\184\187\229\159\142-\233\152\159\228\188\141\230\142\168\232\141\144\231\149\140\233\157\162"
    }
  },
  MainCity_Tab_DefaultEntrance_UIBP = {
    keyName = "MainCity_Tab_DefaultEntrance_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.Tab.MainCity_Tab_DefaultEntrance_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Tab/MainCity_Tab_DefaultEntrance_UIBP.MainCity_Tab_DefaultEntrance_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\232\174\190\231\189\174\229\188\149\229\175\188\231\149\140\233\157\162"
    },
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Skip,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE
  },
  MainCity_Gameplay_Popup_UIBP = {
    keyName = "MainCity_Gameplay_Popup_UIBP",
    moduleName = "GameLua.Mod.MainCity.Client.UI.Popup.MainCity_Gameplay_Popup_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Popup/MainCity_Gameplay_Popup_UIBP.MainCity_Gameplay_Popup_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-H5\231\142\169\230\179\149\229\185\179\229\143\176\231\149\140\233\157\162"
    }
  },
  ModeSelection_Opening_MainCity = {
    keyName = "ModeSelection_Opening_MainCity",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Opening_MainCity",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/ModeSelection_Opening_MainCity.ModeSelection_Opening_MainCity",
    uiStat = {
      name = "\228\184\187\229\159\142-\232\191\155\229\133\165\229\138\168\231\148\187"
    },
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Skip
  },
  main_city_report_bug = {
    keyName = "main_city_report_bug",
    moduleName = "client.slua.umg.report_error.main_city_report_bug",
    path = "/Game/UMG/UI_BP/PopupNotice/ReportBug_UIBP.ReportBug_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\228\184\187\229\159\142\229\143\141\233\166\136"
    },
    containerName = UIContainers.Top
  },
  ui_complaint_main_city = {
    keyName = "ui_complaint_main_city",
    moduleName = "client.slua.umg.MainCity.Report.ui_complaint_main_city",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Item_UIBP2.Inform_Item_UIBP2",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\228\184\187\229\159\142\231\142\169\229\174\182"
    },
    isSingleton = false
  },
  MainCity_Main_Switch_UIBP = {
    keyName = "MainCity_Main_Switch_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.MainCity_Main_Switch_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/MainCity_Main_Switch_UIBP.MainCity_Main_Switch_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\233\161\182\233\131\168\229\136\135\230\141\162\231\149\140\233\157\162"
    },
    asy = true,
    isMainUI = false
  },
  MainCity_SkipSeq_UIBP = {
    keyName = "MainCity_SkipSeq_UIBP",
    moduleName = "GameLua.Mod.MainCity.Client.UI.Common.MainCity_SkipSeq_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Common/MainCity_SkipSeq_UIBP.MainCity_SkipSeq_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142 - \232\183\179\232\191\135\229\138\168\231\148\187"
    }
  },
  MainCity_IngameImmersion_UIBP = {
    keyName = "MainCity_IngameImmersion_UIBP",
    moduleName = "client.slua.umg.MainCity.Immersion.MainCity_IngameImmersion_UIBP",
    path = "/Game/BluePrints/ControlInput/IngameUI/MainCity_IngameImmersion_UIBP.MainCity_IngameImmersion_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142 - \229\183\166\228\184\139\232\167\146\230\178\137\230\181\184\230\168\161\229\188\143"
    },
    asy = true,
    isMainUI = false
  },
  MainCity_Connecting_Tips_UIBP = {
    keyName = "MainCity_Connecting_Tips_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.Tips.MainCity_Connecting_Tips_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Tips/MainCity_Connecting_Tips_UIBP.MainCity_Connecting_Tips_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\228\184\187\229\159\142-\233\147\190\230\142\165\230\143\144\231\164\186"
    }
  },
  MainCity_Connecting_UIBP = {
    keyName = "MainCity_Connecting_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.Tips.MainCity_Connecting_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Tips/MainCity_Connecting_UIBP.MainCity_Connecting_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\229\136\135\230\141\162\230\143\144\231\164\186"
    },
    containerName = UIContainers.Top
  }
}
return maincity_ui_configs