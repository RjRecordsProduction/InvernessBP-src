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
local lobby_ui_configs = {
  Lobby_Watermark_BP = {
    keyName = "Lobby_Watermark_BP",
    moduleName = "client.slua.umg.Lobby_Watermark.Lobby_Watermark_BP",
    path = "/Game/UMG/UI_BP/Lobby_Watermark/Lobby_Watermark_BP.Lobby_Watermark_BP",
    containerName = UIContainers.Top,
    closeOnSwitch = false,
    zOrder = EFixedZOrder.WaterMark,
    uiStat = {
      name = "\229\164\167\229\142\133-\230\176\180\229\141\176"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  Lobby_Condition_UIBP = {
    keyName = "Lobby_Condition_UIBP",
    moduleName = "client.slua.umg.Lobby.Lobby_Condition_UIBP",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/Lobby_Condition_UIBP.Lobby_Condition_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\229\165\189\229\143\139\231\138\182\230\128\129"
    }
  },
  Lobby_UpdateGuide_Popup_UIBP = {
    keyName = "Lobby_UpdateGuide_Popup_UIBP",
    moduleName = "client.slua.umg.match.Lobby_UpdateGuide_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Popup/Lobby_UpdateGuide_Popup_UIBP.Lobby_UpdateGuide_Popup_UIBP",
    uiStat = {
      name = "\229\188\185\231\170\151-\229\140\185\233\133\141\231\137\136\230\155\180"
    },
    closeOnHide = true,
    containerName = UIContainers.Top,
    asy = true,
    AndroidBackType = EAndroidBackType.Defalut
  },
  Lobby_Main_UIBP = {
    keyName = "Lobby_Main_UIBP",
    moduleName = "client.slua.umg.lobby.Main.Lobby_Main_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_UIBP.Lobby_Main_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    isWindowsOBHide = true,
    uiStat = {
      name = "\229\164\167\229\142\1331.0\228\184\187\231\149\140\233\157\162"
    },
    zOrder = EFixedZOrder.BottomZOrder
  },
  Lobby_Main_Match_Entry_Select_UIBP = {
    keyName = "Lobby_Main_Match_Entry_Select_UIBP",
    moduleName = "client.slua.umg.lobby.Main.Lobby_Main_Match_Entry_Select_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_Match_Entry_Select_UIBP.Lobby_Main_Match_Entry_Select_UIBP",
    asy = true,
    isMainUI = false
  },
  Lobby_Mid_LobbySystemEntrance_UIBP = {
    keyName = "Lobby_Mid_LobbySystemEntrance_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.LobbySystemEntrance.Lobby_Mid_LobbySystemEntrance_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/LobbySystemEntrance/Lobby_Mid_LobbySystemEntrance_UIBP.Lobby_Mid_LobbySystemEntrance_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\164\167\229\142\133-\228\184\187\231\149\140\233\157\162\229\138\159\232\131\189\231\179\187\231\187\159"
    }
  },
  Lobby_Mid_LobbySystemEntrance_Item_ChildItem = {
    keyName = "Lobby_Mid_LobbySystemEntrance_Item_ChildItem",
    moduleName = "client.slua.umg.lobby.Mid.LobbySystemEntrance.Lobby_Mid_LobbySystemEntrance_Item_ChildItem",
    path = "/Game/UMG/UI_BP/Lobby/Mid/LobbySystemEntrance/Lobby_Mid_LobbySystemEntrance_Item_ChildItem.Lobby_Mid_LobbySystemEntrance_Item_ChildItem",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\164\167\229\142\133-\228\184\187\231\149\140\233\157\162\230\155\180\229\164\154\232\143\156\229\141\149\230\160\143_Item"
    }
  },
  lobby_system_entrance_popup = {
    keyName = "lobby_system_entrance_popup",
    moduleName = "client.slua.umg.lobby.lobby_system_entrance_popup",
    path = "/Game/UMG/UI_BP/Lobby20/Popup/Lobby20_Setting_Popup_UIBP.Lobby20_Setting_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\229\164\167\229\142\133-\229\184\184\233\169\187\233\161\181\231\173\190\232\174\190\231\189\174\229\188\185\231\170\151"
    }
  },
  lobby_main_right_bottom_tab = {
    keyName = "lobby_main_right_bottom_tab",
    moduleName = "client.slua.umg.lobby.Main.lobby_main_right_bottom_tab",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_Tab_UIBP.Lobby_Main_Tab_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\228\184\187\231\149\140\233\157\162\229\143\179\228\184\139\232\167\146"
    },
    isSingleton = false
  },
  Lobby_Main_Wifi_UIBP = {
    keyName = "Lobby_Main_Wifi_UIBP",
    moduleName = "client.slua.umg.lobby.Main.Lobby_Main_Wifi_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_Wifi_UIBP.Lobby_Main_Wifi_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\231\149\140\233\157\162\229\186\149\233\131\168\231\138\182\230\128\129\230\160\143"
    },
    isSingleton = false
  },
  Lobby_Main_Switch_UIBP = {
    keyName = "Lobby_Main_Switch_UIBP",
    moduleName = "client.slua.umg.lobby.Main.Lobby_Main_Switch_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_Switch_UIBP.Lobby_Main_Switch_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\233\161\182\233\131\168\231\191\187\233\161\181"
    },
    isSingleton = false
  },
  Lobby_Main_Money_UIBP = {
    keyName = "Lobby_Main_Money_UIBP",
    moduleName = "client.slua.umg.lobby.Main.Lobby_Main_Money_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_Money_UIBP.Lobby_Main_Money_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\232\180\167\229\184\129\230\152\190\231\164\186"
    },
    isSingleton = false
  },
  lobby_main_chat_entrance = {
    keyName = "lobby_main_chat_entrance",
    moduleName = "client.slua.umg.lobby.Main.lobby_main_chat_entrance",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_Chat_UIBP.Lobby_Main_Chat_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\232\129\138\229\164\169\229\133\165\229\143\163"
    },
    isSingleton = false
  },
  Lobby_Main_SwitchIight_UIBP = {
    keyName = "Lobby_Main_SwitchIight_UIBP",
    moduleName = "client.slua.umg.lobby.Main.Lobby_Main_SwitchIight_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_SwitchIight_UIBP.Lobby_Main_SwitchIight_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\229\156\186\230\153\175\230\149\136\230\158\156\229\136\135\230\141\162"
    },
    isSingleton = false
  },
  Lobby_Mid_Subscribe_UIBP = {
    keyName = "Lobby_Mid_Subscribe_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_Subscribe_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Mid_Subscribe_UIBP.Lobby_Mid_Subscribe_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\232\174\162\233\152\133\230\160\143"
    },
    isSingleton = false
  },
  Lobby_Mid_Message_UIBP = {
    keyName = "Lobby_Mid_Message_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_Message_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Mid_Message_UIBP.Lobby_Mid_Message_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\228\184\173\233\131\168-\228\191\161\230\129\175\230\160\143"
    },
    isSingleton = false
  },
  Lobby_Mid_Friend_UIBP = {
    keyName = "Lobby_Mid_Friend_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_Friend_UIBP",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/Lobby_Mid_Friend_UIBP.Lobby_Mid_Friend_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\228\184\173\233\131\168-\229\165\189\229\143\139\230\160\143"
    },
    isSingleton = false
  },
  Lobby_Mid_Shop_UIBP = {
    keyName = "Lobby_Mid_Shop_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_Shop_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Mid_Shop250_UIBP.Lobby_Mid_Shop250_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\228\184\173\233\131\168-\229\149\134\229\186\151\230\160\143"
    },
    isSingleton = false
  },
  Lobby_Mid_Activity_UIBP = {
    keyName = "Lobby_Mid_Activity_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_Activity_UIBP",
    path = "/Game/Mod/Lobby/Base/Mid/Lobby_Mid_Activity250_UIBP.Lobby_Mid_Activity250_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\228\184\173\233\131\168-\230\180\187\229\138\168\230\160\143"
    },
    isSingleton = false
  },
  Lobby_Mid_Banner_UIBP = {
    keyName = "Lobby_Mid_Banner_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_Banner_UIBP",
    path = "/Game/Mod/Lobby/Base/Mid/Lobby_Mid_Banner250_UIBP.Lobby_Mid_Banner250_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\228\184\173\233\131\168-\229\185\191\229\145\138\230\160\143"
    },
    isSingleton = false
  },
  ClickEffect_Preview_UIBP = {
    keyName = "ClickEffect_Preview_UIBP",
    moduleName = "client.slua.umg.ClickEffect.ClickEffect_Preview_UIBP",
    path = "/Game/Mod/Lobby/Base/Login/ClickEffect_UIBP.ClickEffect_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\231\130\185\229\135\187\229\138\168\230\149\136-\233\162\132\232\167\136\229\174\185\229\153\168"
    }
  },
  ClickEffect_UIBP = {
    keyName = "ClickEffect_UIBP",
    moduleName = "client.slua.umg.ClickEffect.ClickEffect_UIBP",
    path = "/Game/Mod/Lobby/Base/Login/ClickEffect_UIBP.ClickEffect_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    zOrder = EFixedZOrder.Click_Animation,
    containerName = UIContainers.Top,
    closeOnSwitch = false,
    uiStat = {
      name = "\231\130\185\229\135\187\229\138\168\230\149\136-\229\174\185\229\153\168"
    }
  },
  ClickEffect_Effect_UIBP = {
    keyName = "ClickEffect_Effect_UIBP",
    moduleName = "client.slua.umg.ClickEffect.ClickEffect_Effect_UIBP",
    isSingleton = false,
    isMainUI = false,
    closeOnSwitch = false,
    uiStat = {
      name = "\231\130\185\229\135\187\229\138\168\230\149\136-\231\137\185\230\149\136"
    }
  },
  match_tips_guide = {
    keyName = "match_tips_guide",
    moduleName = "client.slua.umg.match.match_tips_guide",
    path = "/Game/UMG/UI_BP/Lobby/Main/Tips/Lobby_Main_Tips_Guide_UIBP.Lobby_Main_Tips_Guide_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\229\188\128\229\167\139\229\140\185\233\133\141\229\188\149\229\175\188"
    }
  },
  friend_choose_gamestate = {
    keyName = "friend_choose_gamestate",
    moduleName = "client.slua.umg.friend.friend_choose_gamestate",
    path = "/Game/UMG/UI_BP/Lobby/Lobby_InviteFriend_Statuslist.Lobby_InviteFriend_Statuslist",
    asy = true
  },
  Lobby_RoleInfo_IntimateRelationship_Popup_Large_UIBP = {
    keyName = "Lobby_RoleInfo_IntimateRelationship_Popup_Large_UIBP",
    moduleName = "client.slua.umg.friend.Lobby_RoleInfo_IntimateRelationship_Popup_Large_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Lobby_Popup_RoleInfo_IntimateRelationship_Large_UIBP.Lobby_Popup_RoleInfo_IntimateRelationship_Large_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    asy = true,
    uiStat = {
      name = "\229\165\189\229\143\139- \230\150\176\228\186\178\229\175\134\229\133\179\231\179\187\228\184\187\231\149\140\233\157\162"
    }
  },
  friend_inner_list = {
    keyName = "friend_inner_list",
    moduleName = "client.slua.umg.friend.friend_inner_list",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_IntimateRelationship_Details_UIBP.Lobby_RoleInfo_IntimateRelationship_Details_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    asy = true,
    uiStat = {
      name = "\229\165\189\229\143\139-\230\184\184\230\136\143\229\165\189\229\143\139\229\136\151\232\161\168"
    }
  },
  SetDisplay_UIBP = {
    keyName = "SetDisplay_UIBP",
    moduleName = "client.slua.umg.lobby.SetDisplay_UIBP",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/SetDisplay_UIBP.SetDisplay_UIBP",
    uiStat = {
      name = "\229\165\189\229\143\139-\232\174\190\231\189\174\229\177\149\231\164\186\229\134\133\229\174\185"
    }
  },
  Lobby_InviteFriend_Tab_Item = {
    keyName = "Lobby_InviteFriend_Tab_Item",
    moduleName = "client.slua.umg.Common.Tab.Vertical.LevelOne.LevelOne_Icon.Item.Common_Tab_Vertical_LevelOne_Icon_Item_UIBP_L",
    path = "/Game/UMG/UI_BP/Common/Tab/Vertical/LevelOne/LevelOne_Icon/Item/Common_Tab_Vertical_LevelOne_Icon_Item_UIBP_L.Common_Tab_Vertical_LevelOne_Icon_Item_UIBP_L",
    uiStat = {
      name = "\229\165\189\229\143\139-\230\184\184\230\136\143\229\165\189\229\143\139\229\136\151\232\161\168\233\161\181\231\173\190Item"
    }
  },
  friend_intimacy_apply = {
    keyName = "friend_intimacy_apply",
    moduleName = "client.slua.umg.friend.friend_intimacy_apply",
    path = "/Game/UMG/UI_BP/PersonSpace/Intimacy/Lobby_RoleInfo_IntimateRelationship_Selective_UIBP.Lobby_RoleInfo_IntimateRelationship_Selective_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    asy = true,
    uiStat = {
      name = "\229\165\189\229\143\139-\228\186\178\229\175\134\229\133\179\231\179\187\231\148\179\232\175\183\231\149\140\233\157\162"
    }
  },
  friend_intimacy_apply_old = {
    keyName = "friend_intimacy_apply_old",
    moduleName = "client.slua.umg.friend.friend_intimacy_apply_old",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_IntimateRelationship_Selective_Old_UIBP.Lobby_RoleInfo_IntimateRelationship_Selective_Old_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    asy = true,
    uiStat = {
      name = "\229\165\189\229\143\139-\228\186\178\229\175\134\229\133\179\231\179\187\231\148\179\232\175\183\231\149\140\233\157\162"
    }
  },
  friend_remark = {
    keyName = "friend_remark",
    moduleName = "client.slua.umg.friend.friend_remark",
    path = "/Game/UMG/UI_BP/Friend/LobbyFriendcomment_UIBP.LobbyFriendcomment_UIBP",
    asy = true,
    uiStat = {
      name = "\229\165\189\229\143\139-\229\164\135\230\179\168\229\144\141"
    }
  },
  FriendComp_Relation = {
    keyName = "FriendComp_Relation",
    moduleName = "client.slua.umg.lobby.FriendList.Comp.FriendComp_Relation",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/FriendComp/FriendComp_Relation.FriendComp_Relation",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false,
    isSingleton = false
  },
  FriendComp_Birth = {
    keyName = "FriendComp_Birth",
    moduleName = "client.slua.umg.lobby.FriendList.Comp.FriendComp_Birth",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/FriendComp/FriendComp_Birth.FriendComp_Birth",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false,
    isSingleton = false
  },
  FriendComp_ActionBtn = {
    keyName = "FriendComp_ActionBtn",
    moduleName = "client.slua.umg.lobby.FriendList.Comp.FriendComp_ActionBtn",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/FriendComp/FriendComp_ActionBtn.FriendComp_ActionBtn",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false,
    isSingleton = false
  },
  FriendComp_InterAction = {
    keyName = "FriendComp_InterAction",
    moduleName = "client.slua.umg.lobby.FriendList.Comp.FriendComp_InterAction",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/FriendComp/FriendComp_InterAction.FriendComp_InterAction",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false,
    isSingleton = false
  },
  FriendComp_Relation2 = {
    keyName = "FriendComp_Relation2",
    moduleName = "client.slua.umg.lobby.FriendList.Comp.FriendComp_Relation2",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/FriendComp/FriendComp_Relation_2.FriendComp_Relation_2",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false,
    isSingleton = false
  },
  FriendComp_Recaller = {
    keyName = "FriendComp_Recaller",
    moduleName = "client.slua.umg.lobby.FriendList.Comp.FriendComp_Recaller",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/FriendComp/FriendComp_Recaller.FriendComp_Recaller",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false,
    isSingleton = false
  },
  FriendComp_Source = {
    keyName = "FriendComp_Source",
    moduleName = "client.slua.umg.lobby.FriendList.Comp.FriendComp_Source",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/FriendComp/FriendComp_Source.FriendComp_Source",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false,
    isSingleton = false
  },
  FriendComp_Status = {
    keyName = "FriendComp_Status",
    moduleName = "client.slua.umg.lobby.FriendList.Comp.FriendComp_Status",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/FriendComp/FriendComp_Status.FriendComp_Status",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false,
    isSingleton = false
  },
  FriendComp_Lucky = {
    keyName = "FriendComp_Lucky",
    moduleName = "client.slua.umg.lobby.FriendList.Comp.FriendComp_Lucky",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/FriendComp/FriendComp_Lucky.FriendComp_Lucky",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false,
    isSingleton = false
  },
  FriendComp_Poke = {
    keyName = "FriendComp_Poke",
    moduleName = "client.slua.umg.lobby.FriendList.Comp.FriendComp_Poke",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/FriendComp/FriendComp_Poke.FriendComp_Poke",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false,
    isSingleton = false
  },
  select_price_popup = {
    keyName = "select_price_popup",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.crate.select_price_popup",
    path = "/Game/UMG/UI_BP/Lobby_Store_Int/Store_2/Store_PriceType_UIBP.Store_PriceType_UIBP",
    uiStat = {
      name = "\229\174\157\231\174\177\230\138\189\229\165\150\229\188\185\231\170\151"
    }
  },
  supply_details_JK_panel = {
    keyName = "supply_details_JK_panel",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.supply.supply_details_panel",
    path = "/Game/UMG/UI_BP/Lobby_Store_Int/Goods_Detail_UIBP.Goods_Detail_UIBP",
    uiStat = {
      name = "\232\161\165\231\187\153-\229\174\157\231\174\177\230\166\130\231\142\135"
    }
  },
  lobby_mode_entry = {
    keyName = "lobby_mode_entry",
    moduleName = "client.slua.umg.ModeSelection.Lobby_Mode_UIBP",
    path = "/Game/Mod/Lobby/Split/ModeSelection/Lobby_Mode_UIBP.Lobby_Mode_UIBP",
    isSingleton = false,
    isWindowsOBHide = true,
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\229\133\165\229\143\163"
    }
  },
  match_new_entry = {
    keyName = "match_new_entry",
    moduleName = "client.slua.umg.match.match_new_entry",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_Match_Entry_UIBP.Lobby_Main_Match_Entry_UIBP",
    isSingleton = false,
    isWindowsOBHide = true,
    uiStat = {
      name = "\230\168\161\229\188\143\228\184\142\229\140\185\233\133\141"
    }
  },
  pet_lobby_action = {
    keyName = "pet_lobby_action",
    moduleName = "client.slua.umg.pet.pet_lobby_action",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_Pet_List_UIBP.Lobby_Main_Pet_List_UIBP",
    isWindowsOBHide = true,
    isCEHideLobbyUI = true,
    asy = true
  },
  Lobby_RoleInfo_Pround_Popup_UIBP = {
    keyName = "Lobby_RoleInfo_Pround_Popup_UIBP",
    moduleName = "client.slua.umg.pround.Lobby_RoleInfo_Pround_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Pround_Popup_UIBP.Lobby_RoleInfo_Pround_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175-\232\177\170\230\176\148\231\173\137\231\186\167"
    }
  },
  Lobby_RoleInfo_Popularity_Level_UIBP = {
    keyName = "Lobby_RoleInfo_Popularity_Level_UIBP",
    moduleName = "client.slua.umg.person_space.popularity.Lobby_RoleInfo_Popularity_Level_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Popularity_Level_UIBP.Lobby_RoleInfo_Popularity_Level_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175-\228\186\186\230\176\148\231\173\137\231\186\167"
    }
  },
  Lobby_RoleInfo_Popularity_Pk_Description_UIBP = {
    keyName = "Lobby_RoleInfo_Popularity_Pk_Description_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Lobby_RoleInfo_Popularity_Pk_Description_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Lobby_RoleInfo_Popularity_Pk_Description_UIBP.Lobby_RoleInfo_Popularity_Pk_Description_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148\231\164\188\231\137\169PK-\231\142\169\230\179\149\232\175\180\230\152\142\229\188\185\231\170\151"
    }
  },
  Lobby_RoleInfo_Popularity_Pk_Record_UIBP = {
    keyName = "Lobby_RoleInfo_Popularity_Pk_Record_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Lobby_RoleInfo_Popularity_Pk_Record_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Lobby_RoleInfo_Popularity_Pk_Record_UIBP.Lobby_RoleInfo_Popularity_Pk_Record_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148\231\164\188\231\137\169PK-PK\232\174\176\229\189\149\229\188\185\231\170\151"
    }
  },
  ingame_send_gift = {
    keyName = "ingame_send_gift",
    moduleName = "client.slua.umg.person_space.ingame_send_gift",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Present_Popup_UIBP.Lobby_RoleInfo_Present_Popup_UIBP",
    uiStat = {
      name = "\229\177\128\229\134\133-\232\181\160\233\128\129\231\164\188\231\137\169"
    }
  },
  roleinfo_exchange_gift = {
    keyName = "roleinfo_exchange_gift",
    moduleName = "client.slua.umg.person_space.roleinfo_exchange_gift",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Present_Popup_UIBP.Lobby_RoleInfo_Present_Popup_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148\231\164\188\231\137\169\228\186\164\230\141\162"
    }
  },
  popularity_reply_popup = {
    keyName = "popularity_reply_popup",
    moduleName = "client.slua.umg.person_space.popularity_reply_popup",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Popularity_Popup_UIBP.Lobby_RoleInfo_Popularity_Popup_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175-\228\186\186\230\176\148\229\128\188\232\175\166\230\131\133-\230\156\128\232\191\145\228\186\146\229\138\168\229\155\158\229\164\141"
    }
  },
  popularity_message_menu = {
    keyName = "popularity_message_menu",
    moduleName = "client.slua.umg.person_space.popularity_message_menu",
    path = "/Game/UMG/UI_BP/PersonSpace/item/Lobby_RoleInfo_Menu_UIBP.Lobby_RoleInfo_Menu_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175-\228\186\186\230\176\148\229\128\188\232\175\166\230\131\133-\231\149\153\232\168\128\232\143\156\229\141\149"
    }
  },
  popularity_reply_menu = {
    keyName = "popularity_reply_menu",
    moduleName = "client.slua.umg.person_space.popularity_reply_menu",
    path = "/Game/UMG/UI_BP/PersonSpace/item/Lobby_RoleInfo_Menu_UIBP.Lobby_RoleInfo_Menu_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175-\228\186\186\230\176\148\229\128\188\232\175\166\230\131\133-\229\155\158\229\164\141\232\143\156\229\141\149"
    }
  },
  popularity_recent_menu = {
    keyName = "popularity_recent_menu",
    moduleName = "client.slua.umg.person_space.popularity_recent_menu",
    path = "/Game/UMG/UI_BP/PersonSpace/item/Lobby_RoleInfo_Menu_UIBP.Lobby_RoleInfo_Menu_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175-\228\186\186\230\176\148\229\128\188\232\175\166\230\131\133-\230\156\128\232\191\145\232\181\160\231\164\188\232\143\156\229\141\149"
    }
  },
  popularity_guest_menu = {
    keyName = "popularity_guest_menu",
    moduleName = "client.slua.umg.person_space.popularity_guest_menu",
    path = "/Game/UMG/UI_BP/PersonSpace/item/Lobby_RoleInfo_Menu_UIBP.Lobby_RoleInfo_Menu_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175-\228\186\186\230\176\148\229\128\188\232\175\166\230\131\133-\230\156\128\232\191\145\232\174\191\229\174\162\232\143\156\229\141\149"
    }
  },
  popularity_contri_menu = {
    keyName = "popularity_contri_menu",
    moduleName = "client.slua.umg.person_space.popularity_contri_menu",
    path = "/Game/UMG/UI_BP/PersonSpace/item/Lobby_RoleInfo_Menu_UIBP.Lobby_RoleInfo_Menu_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175-\228\186\186\230\176\148\229\128\188\232\175\166\230\131\133-\232\180\161\231\140\174\230\142\146\232\161\140\232\143\156\229\141\149"
    }
  },
  Lobby_RoleInfo_EffectSkin_Item_UIBP = {
    keyName = "Lobby_RoleInfo_EffectSkin_Item_UIBP",
    moduleName = "client.slua.umg.effect_item.Lobby_RoleInfo_EffectSkin_Item_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  Lobby_RoleInfo_Chat_Message_Effect_Item_UIBP = {
    keyName = "Lobby_RoleInfo_Chat_Message_Effect_Item_UIBP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/RoleInfo/Item/Lobby_RoleInfo_Chat_Message_Effect_Item_UIBP.Lobby_RoleInfo_Chat_Message_Effect_Item_UIBP",
    isSingleton = false,
    isMainUI = false
  },
  Lobby_RoleInfo_Card_UIBP = {
    keyName = "Lobby_RoleInfo_Card_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Card.Lobby_RoleInfo_Card_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Card_UIBP.Lobby_RoleInfo_Card_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\184\170\228\186\186\229\144\141\231\137\135"
    }
  },
  Lobby_RoleInfo_Card_Show_UIBP = {
    keyName = "Lobby_RoleInfo_Card_Show_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Card.Lobby_RoleInfo_Card_Show_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/item/Lobby_RoleInfo_Card_Mine_Share_Item_UIBP.Lobby_RoleInfo_Card_Mine_Share_Item_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isMainUI = false,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\184\170\228\186\186\229\144\141\231\137\135\229\177\149\231\164\186\230\128\129"
    }
  },
  Lobby_RoleInfo_Card_Editor_UIBP = {
    keyName = "Lobby_RoleInfo_Card_Editor_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Card.Lobby_RoleInfo_Card_Editor_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/item/Lobby_RoleInfo_Card_Mine_Edit_Item_UIBP.Lobby_RoleInfo_Card_Mine_Edit_Item_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isMainUI = false,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\184\170\228\186\186\229\144\141\231\137\135\231\188\150\232\190\145\230\128\129"
    }
  },
  Lobby_Left_Record_Show_UIBP = {
    keyName = "Lobby_Left_Record_Show_UIBP",
    moduleName = "client.slua.umg.lobby.Left.Popup.Lobby_Left_Record_Show_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Left/Popup/Lobby_Left_CustomizeData_Popup_UIBP.Lobby_Left_CustomizeData_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\230\149\176\230\141\174\229\177\149\231\164\186\231\188\150\232\190\145\231\149\140\233\157\162"
    }
  },
  roleinfo_history = {
    keyName = "roleinfo_history",
    moduleName = "client.slua.umg.person_space.roleinfo_history",
    path = "/Game/UMG/UI_BP/RoleInfo/Lobby_RoleInfo_History_UIBP.Lobby_RoleInfo_History_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\229\142\134\229\143\178\230\136\152\231\187\169"
    }
  },
  Lobby_RoleInfo_Weekly_Summary_Popup_UIBP = {
    keyName = "Lobby_RoleInfo_Weekly_Summary_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Lobby_RoleInfo_Weekly_Summary_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Lobby_RoleInfo_Weekly_Summary_Popup_UIBP.Lobby_RoleInfo_Weekly_Summary_Popup_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \228\184\138\229\145\168\231\164\190\228\186\164\230\128\187\231\187\147"
    }
  },
  roleInfo_Relationship_Net = {
    keyName = "roleInfo_Relationship_Net",
    moduleName = "client.slua.umg.person_space.roleInfo_RelationshipNet",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_IntimateRelationship_New01_UIBP.Lobby_RoleInfo_IntimateRelationship_New01_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isMainUI = false,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\186\178\229\175\134\229\133\179\231\179\187-\229\187\186\231\171\139\229\133\179\231\179\187"
    }
  },
  Lobby_RoleInfo_Gift_Popup_UIBP = {
    keyName = "Lobby_RoleInfo_Gift_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_Gift_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Gift_Popup_UIBP.Lobby_RoleInfo_Gift_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\186\186\230\176\148\232\175\166\230\131\133-\229\134\160\229\144\141\231\142\169\229\174\182\232\175\166\230\131\133"
    }
  },
  ScrapGold_AnnualRenew_Item_UIBP = {
    keyName = "ScrapGold_AnnualRenew_Item_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.ScrapGold.Widget.ScrapGold_AnnualRenewTips_Item_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/ScrapGold/UIBP/ScrapGold_AnnualRenewTips_Item_UIBP.ScrapGold_AnnualRenewTips_Item_UIBP",
    asy = true,
    uiStat = {
      name = "\231\165\158\232\175\157\229\183\165\229\157\138\231\137\169\229\147\129\228\184\138\230\150\176\229\136\151\232\161\168"
    }
  },
  Lobby_Direct_Main_UIBP = {
    keyName = "Lobby_Direct_Main_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.DiscountDirect.Lobby_Direct_Main_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Direct/Lobby_Direct_Main_UIBP.Lobby_Direct_Main_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\147\157\230\180\158\230\137\147\230\138\152\231\155\180\232\180\173\231\149\140\233\157\162"
    }
  },
  FITEntrance_UIBP = {
    keyName = "FITEntrance_UIBP",
    moduleName = "client.slua.umg.lobby.FITEntrance_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Item/Lobby_Mid_FITEntrance_Item_UIBP.Lobby_Mid_FITEntrance_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\176\143\229\140\133\230\180\187\229\138\168\229\133\165\229\143\163"
    }
  },
  CondFirstCharge_Banner_UIBP = {
    keyName = "CondFirstCharge_Banner_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.ConditionGift.Banner.CondFirstCharge_Banner_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/CondFirstCharge_Banner_UIBP.CondFirstCharge_Banner_UIBP",
    uiStat = {
      name = "\233\166\150\229\133\133\231\164\188\229\140\133Banner"
    }
  },
  ui_subscribe_carnival_main = {
    keyName = "ui_subscribe_carnival_main",
    moduleName = "client.slua.umg.subscribe_activity.ui_subscribe_carnival_main",
    jumpModuleID = BP_ENUM_MODULE_SUBSCRIBE_CARNIVAL,
    path = "/Game/UMG/UI_BP/Lobby_Store_Int/Store_3/Lobby_Subscription_Main_UIBP.Lobby_Subscription_Main_UIBP",
    uiStat = {
      name = "\232\174\162\233\152\133\231\139\130\230\172\162\232\138\130\230\180\187\229\138\168"
    }
  },
  ui_subscribe_carnival_privilege = {
    keyName = "ui_subscribe_carnival_privilege",
    moduleName = "client.slua.umg.subscribe_activity.ui_subscribe_carnival_privilege",
    path = "/Game/UMG/UI_BP/Lobby_Store_Int/Store_3/Lobby_Subscription_Benefit_UIBP.Lobby_Subscription_Benefit_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\232\174\162\233\152\133\231\139\130\230\172\162\232\138\130\230\180\187\229\138\168-\232\174\162\233\152\133\231\137\185\230\157\131\229\173\144\231\149\140\233\157\162"
    }
  },
  ui_subscribe_carnival_gift = {
    keyName = "ui_subscribe_carnival_gift",
    moduleName = "client.slua.umg.subscribe_activity.ui_subscribe_carnival_gift",
    path = "/Game/UMG/UI_BP/Lobby_Store_Int/Store_3/Lobby_Subscription_Gift_UIBP.Lobby_Subscription_Gift_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\232\174\162\233\152\133\231\139\130\230\172\162\232\138\130\230\180\187\229\138\168-\232\174\162\233\152\133\231\164\188\229\140\133\229\173\144\231\149\140\233\157\162"
    }
  },
  ui_subscribe_carnival_slap = {
    keyName = "ui_subscribe_carnival_slap",
    moduleName = "client.slua.umg.subscribe_activity.ui_subscribe_carnival_slap",
    path = "/Game/UMG/UI_BP/Lobby_Store_Int/Store_3/Lobby_Subscription_AD.Lobby_Subscription_AD",
    uiStat = {
      name = "\232\174\162\233\152\133\231\139\130\230\172\162\232\138\130\230\180\187\229\138\168-\230\139\141\232\132\184\229\155\190"
    }
  },
  Lobby_Subscription_Scroll_UIBP = {
    keyName = "Lobby_Subscription_Scroll_UIBP",
    moduleName = "client.slua.umg.subscribe_activity.Lobby_Subscription_Scroll_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Store_Int/Store_3/Lobby_Subscription_Scroll_UIBP.Lobby_Subscription_Scroll_UIBP",
    uiStat = {
      name = "\232\174\162\233\152\133\231\139\130\230\172\162\232\138\130\230\180\187\229\138\168-\231\164\188\229\140\133\229\136\151\232\161\168\229\140\186\229\159\159"
    },
    isSingleton = false
  },
  Lobby_Subscription_Benefit_Item_UIBP = {
    keyName = "Lobby_Subscription_Benefit_Item_UIBP",
    moduleName = "client.slua.umg.subscribe_activity.Lobby_Subscription_Benefit_Item_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Store_Int/Store_3/Lobby_Subscription_Benefit_Item_UIBP.Lobby_Subscription_Benefit_Item_UIBP",
    uiStat = {
      name = "\232\174\162\233\152\133\231\139\130\230\172\162\232\138\130\230\180\187\229\138\168-\231\137\185\230\157\131\230\157\131\231\155\138item"
    },
    isMainUI = false,
    isSingleton = false
  },
  recharge_purchasePopup = {
    keyName = "recharge_purchasePopup",
    moduleName = "client.slua.umg.recharge.recharge_purchasePopup",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/RechargeDirect/Lobby_DirectPurchase_popup_115_UIBP.Lobby_DirectPurchase_popup_115_UIBP",
    uiStat = {
      name = "\229\133\133\229\128\188-\231\155\180\232\180\173\232\175\166\230\131\133"
    }
  },
  recharge_purchase = {
    keyName = "recharge_purchase",
    moduleName = "client.slua.umg.recharge.recharge_purchase",
    isMainUI = false,
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/RechargeDirect/Lobby_DirectPurchase_115_UIBP.Lobby_DirectPurchase_115_UIBP",
    uiStat = {
      name = "\229\133\133\229\128\188-\231\155\180\232\180\173"
    }
  },
  limited_purchase = {
    keyName = "limited_purchase",
    moduleName = "client.slua.umg.recharge.UC_LimitedPaks_UIBP",
    isMainUI = false,
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/RechargeDirect/UC_LimitedPaks_UIBP.UC_LimitedPaks_UIBP",
    uiStat = {
      name = "\229\133\133\229\128\188-\233\153\144\230\151\182\231\164\188\229\140\133"
    }
  },
  ui_recharge = {
    keyName = "ui_recharge",
    moduleName = "client.slua.umg.recharge.ui_recharge",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Base/SpecialOffer/Lobby_Store_Int_TopBar_UIBP.Lobby_Store_Int_TopBar_UIBP",
    uiStat = {
      name = "\229\133\133\229\128\188-\229\134\133\229\174\185\231\149\140\233\157\162-\229\133\168\231\144\131\231\137\136"
    },
    asy = true
  },
  UGC_WOWCoin_Recharge_UIBP = {
    keyName = "UGC_WOWCoin_Recharge_UIBP",
    moduleName = "client.slua.umg.recharge.UGC_WOWCoin_Recharge_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Base/SpecialOffer/Lobby_Store_Int_TopBar_UIBP.Lobby_Store_Int_TopBar_UIBP",
    uiStat = {
      name = "WOW\229\184\129\229\133\133\229\128\188-\229\134\133\229\174\185\231\149\140\233\157\162-\229\133\168\231\144\131\231\137\136"
    },
    asy = true
  },
  ui_recharge_jk = {
    keyName = "ui_recharge_jk",
    moduleName = "client.slua.umg.recharge.ui_recharge_jk",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Base/SpecialOffer/Lobby_Store_Int_TopBarJK_UIBP.Lobby_Store_Int_TopBarJK_UIBP",
    uiStat = {
      name = "\229\133\133\229\128\188-\229\134\133\229\174\185\231\149\140\233\157\162-\230\151\165\233\159\169\231\137\136"
    },
    asy = true
  },
  UGC_WOWCoin_Recharge_JK_UIBP = {
    keyName = "UGC_WOWCoin_Recharge_JK_UIBP",
    moduleName = "client.slua.umg.recharge.UGC_WOWCoin_Recharge_JK_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Base/SpecialOffer/Lobby_Store_Int_TopBarJK_UIBP.Lobby_Store_Int_TopBarJK_UIBP",
    uiStat = {
      name = "WOW\229\184\129\229\133\133\229\128\188-\229\134\133\229\174\185\231\149\140\233\157\162-\230\151\165\233\159\169\231\137\136"
    },
    asy = true
  },
  ui_recharge_good_item_jk = {
    keyName = "ui_recharge_good_item_jk",
    moduleName = "client.slua.umg.recharge.ui_recharge_good_item_jk",
    path = "/Game/Mod/Lobby/Base/SpecialOffer/Item/Lobby_Store_itemJK_UIBP.Lobby_Store_itemJK_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\229\133\133\229\128\188\231\137\169\229\147\129item-\230\151\165\233\159\169\231\137\136"
    }
  },
  ui_ugc_recharge_good_item_jk = {
    keyName = "ui_ugc_recharge_good_item_jk",
    moduleName = "client.slua.umg.recharge.ui_ugc_recharge_good_item_jk",
    path = "/Game/Mod/Lobby/Base/SpecialOffer/Item/Lobby_Store_itemJK_UIBP.Lobby_Store_itemJK_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "WOW\229\133\133\229\128\188\231\137\169\229\147\129item-\230\151\165\233\159\169\231\137\136"
    }
  },
  ui_recharge_gas_station = {
    keyName = "ui_recharge_gas_station",
    moduleName = "client.slua.umg.activity.LuckyCharge.ui_recharge_gas_station",
    path = "/Game/UMG/UI_BP/Lobby_Activity/LuckyCharge/Lobby_LuckyCharge_UIBP.Lobby_LuckyCharge_UIBP",
    moduleID = BP_ENUM_MODULE_RECHARGE_GAS_STATION,
    jumpModuleID = BP_ENUM_MODULE_RECHARGE_GAS_STATION,
    uiStat = {
      name = "\229\133\133\229\128\188\229\138\160\230\178\185\231\171\153\230\180\187\229\138\168\231\149\140\233\157\162"
    }
  },
  setting_birthday = {
    keyName = "setting_birthday",
    moduleName = "client.slua.umg.NewSetting.Privacy.setting_birthday",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Card_Birthday_UIBP.Lobby_RoleInfo_Card_Birthday_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\231\148\159\230\151\165"
    }
  },
  vng_personalInfo = {
    keyName = "vng_personalInfo",
    moduleName = "client.slua.umg.lobby.vng_personalInfo",
    path = "/Game/UMG/UI_BP/Lobby/LobbyUI_Personal_information_UIBP.LobbyUI_Personal_information_UIBP",
    closeOnSwitch = false,
    uiStat = {
      name = "\232\182\138\229\141\151\228\184\170\228\186\186\228\191\161\230\129\175"
    }
  },
  vehicle_halloween_skin = {
    keyName = "vehicle_halloween_skin",
    moduleName = "client.slua.umg.vehicle.vehicle_halloween_skin",
    jumpModuleID = BP_ENUM_MODULE_ACTIVITY_HALLOWEEN_VEHICLE,
    path = "/Game/UMG/UI_BP/Lobby_Activity/Activity_HalloweenVehile_2.Activity_HalloweenVehile_2",
    uiStat = {
      name = "\232\189\166\232\190\134\229\141\135\231\186\167-\232\189\172\231\155\152\230\180\187\229\138\168-\231\155\174\229\137\141\229\143\170\230\156\137\230\151\165\233\159\169\231\154\132\232\191\148\229\156\186\228\188\154\231\148\168\229\136\176"
    }
  },
  direct_purchase_banner = {
    keyName = "direct_purchase_banner",
    moduleName = "client.slua.umg.shop.direct_purchase_banner",
    path = "/Game/UMG/UI_BP/Lobby_Store_Int/Lobby_Direct_Purchase_Banner.Lobby_Direct_Purchase_Banner",
    asy = true,
    uiStat = {
      name = "\230\150\176\231\137\136\229\164\167\229\142\133\231\164\188\229\140\133\231\155\180\232\180\173"
    }
  },
  sign_in_gift = {
    keyName = "sign_in_gift",
    moduleName = "client.slua.umg.activity.come_back.sign_in_gift",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Cumulative_landing_Activity_UIBP.Cumulative_landing_Activity_UIBP",
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\230\180\187\229\138\168-7\229\164\169\231\153\187\229\189\149\229\165\150\229\138\177"
    }
  },
  sign_fives_in_gift = {
    keyName = "sign_fives_in_gift",
    moduleName = "client.slua.umg.activity.come_back.sign_fives_in_gift",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Cumulative_landing_Activity_fives_UIBP.Cumulative_landing_Activity_fives_UIBP",
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\230\180\187\229\138\168-5\229\164\169\231\153\187\229\189\149\229\165\150\229\138\177"
    }
  },
  sign_nine_in_gift = {
    keyName = "sign_nine_in_gift",
    moduleName = "client.slua.umg.activity.come_back.sign_nine_in_gift",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Cumulative_landing_Activity_nine_UIBP.Cumulative_landing_Activity_nine_UIBP",
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\230\180\187\229\138\168-9\229\164\169\231\153\187\229\189\149\229\165\150\229\138\177"
    }
  },
  recruit_main = {
    keyName = "recruit_main",
    moduleName = "client.slua.umg.recruit.recruit_main",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Lobby_EnrollRecruits_UIBP.Lobby_EnrollRecruits_UIBP",
    uiStat = {
      name = "\230\150\176\229\133\181\230\139\155\229\139\159-\228\184\187\231\149\140\233\157\162"
    }
  },
  recruit_share_ui = {
    keyName = "recruit_share_ui",
    moduleName = "client.slua.umg.recruit.recruit_share_ui",
    isSingleton = false,
    path = "/Game/UMG/UI_BP/Lobby_Activity/Lobby_EnrollRecruits_Share_UIBP.Lobby_EnrollRecruits_Share_UIBP",
    uiStat = {
      name = "\230\150\176\229\133\181\230\139\155\229\139\159-\233\130\128\232\175\183\229\136\134\228\186\171"
    }
  },
  recruit_invitee = {
    keyName = "recruit_invitee",
    moduleName = "client.slua.umg.recruit.recruit_invitee",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Lobby_EnrollRecruits_Reported_UIBP.Lobby_EnrollRecruits_Reported_UIBP",
    uiStat = {
      name = "\230\150\176\229\133\181\230\139\155\229\139\159-\229\143\151\233\130\128\231\149\140\233\157\162"
    }
  },
  webview_share = {
    keyName = "webview_share",
    moduleName = "client.slua.umg.common.webview_share_ui",
    isSingleton = false,
    path = "/Game/UMG/UI_BP/Lobby/WebviewShare_UIBP.WebviewShare_UIBP"
  },
  ShareFriends_Popup_UIBP = {
    keyName = "ShareFriends_Popup_UIBP",
    moduleName = "client.slua.umg.common.share.ShareFriends_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/ShareFriends_Popup_UIBP.ShareFriends_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\233\128\154\231\148\168\229\165\189\229\143\139\229\136\134\228\186\171\229\188\185\231\170\151"
    }
  },
  Shareinterface_highlight = {
    keyName = "Shareinterface_highlight",
    moduleName = "client.slua.umg.common.share.Shareinterface_highlight",
    path = "/Game/UMG/UI_BP/Lobby/Shareinterface_Rusult_UIBP.Shareinterface_Rusult_UIBP",
    uiStat = {
      name = "1.\231\187\147\231\174\151\229\136\134\228\186\171-\229\133\168\233\152\159\230\136\152\231\187\169"
    }
  },
  Shareinterface_lite = {
    keyName = "Shareinterface_lite",
    moduleName = "client.slua.umg.common.share.shareinterface_lite",
    path = "/Game/UMG/UI_BP/Lobby/Shareinterface_UIBP_Lite.Shareinterface_UIBP_Lite",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\128\154\231\148\168\229\136\134\228\186\171\231\187\132\228\187\182-Lite"
    }
  },
  ShareinterfaceFull_UIBP = {
    keyName = "ShareinterfaceFull_UIBP",
    moduleName = "client.slua.umg.common.share.ShareinterfaceFull_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/ShareinterfaceFull_UIBP.ShareinterfaceFull_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\128\154\231\148\168\229\136\134\228\186\171\231\187\132\228\187\182-\229\133\168\229\177\143"
    }
  },
  pandora_package_preview_panel = {
    keyName = "pandora_package_preview_panel",
    moduleName = "client.slua.umg.lobby_item.pandora_package_preview_panel",
    path = "/Game/UMG/UI_BP/Lobby/PackagePreview_UIBP.PackagePreview_UIBP",
    uiStat = {
      name = "\230\189\152\229\164\154\230\139\137-\231\164\188\229\140\133\233\162\132\232\167\136\231\149\140\233\157\162"
    }
  },
  SmallKT_UIBP = {
    keyName = "SmallKT_UIBP",
    moduleName = "client.slua.umg.lobby.SmallKT_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/SmallKT_UIBP.SmallKT_UIBP",
    uiStat = {
      name = "\231\178\190\229\135\134\231\169\186\230\138\149-\232\180\173\228\185\176\231\149\140\233\157\162"
    }
  },
  ShareFriend_SeasonLookBack_UIBP = {
    keyName = "ShareFriend_SeasonLookBack_UIBP",
    moduleName = "client.slua.umg.Lobby.ShareItem.ShareFriend_SeasonLookBack_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/ShareItem/ShareFriend_SeasonLookBack_UIBP.ShareFriend_SeasonLookBack_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\232\181\155\229\173\163-\232\181\155\229\173\163\229\155\158\233\161\190\230\150\176\229\136\134\228\186\171\229\173\144\232\147\157\229\155\190"
    }
  },
  New_Day_Task_UIBP = {
    keyName = "New_Day_Task_UIBP",
    moduleName = "client.slua.umg.task.Task_Integration.New_Day_Task_UIBP",
    path = "/Game/UMG/UI_BP/Task/Task_Integration/Task_New/Lobby_Integration_Day_Task_UIBP_New.Lobby_Integration_Day_Task_UIBP_New",
    isMainUI = false,
    uiStat = {
      name = "\228\187\187\229\138\161-\230\175\143\230\151\165\228\187\187\229\138\161"
    }
  },
  Lobby_Integration_DayTask_Award_Popup_UIBP = {
    keyName = "Lobby_Integration_DayTask_Award_Popup_UIBP",
    moduleName = "client.slua.umg.task.Task_Integration.Lobby_Integration_DayTask_Award_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Task/Task_Integration/Task_New/Lobby_Integration_DayTask_Award_Popup_UIBP.Lobby_Integration_DayTask_Award_Popup_UIBP",
    uiStat = {
      name = "\228\187\187\229\138\161-\230\175\143\230\151\165\228\187\187\229\138\161-\233\162\157\229\164\150\231\153\187\229\189\149\229\165\150\229\138\177\229\188\185\231\170\151"
    }
  },
  Lobby_Integration_DayTask_Limited_Popup_UIBP = {
    keyName = "Lobby_Integration_DayTask_Limited_Popup_UIBP",
    moduleName = "client.slua.umg.task.Task_Integration.Lobby_Integration_DayTask_Limited_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Task/Task_Integration/Task_New/Lobby_Integration_DayTask_Limited_Popup_UIBP.Lobby_Integration_DayTask_Limited_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\228\187\187\229\138\161-\230\175\143\230\151\165\228\187\187\229\138\161-\228\184\147\229\177\158\228\187\187\229\138\161\229\165\150\229\138\177\229\188\185\231\170\151"
    }
  },
  Task_LevelBP = {
    keyName = "Task_LevelBP",
    moduleName = "client.slua.umg.task.Task_LevelBP",
    path = "/Game/UMG/UI_BP/Task/Lobby_Task_LevelBP.Lobby_Task_LevelBP",
    jumpModuleID = BP_ENUM_MODULE_TASK_LEVEL,
    asy = true,
    uiStat = {
      name = "\228\187\187\229\138\161-\230\136\144\233\149\191\228\187\187\229\138\161"
    }
  },
  Task_WeekBP = {
    keyName = "Task_WeekBP",
    moduleName = "client.slua.umg.task.Task_WeekBP",
    path = "/Game/Mod/Lobby/Split/AssemblyComeBack/Lobby_Task_WeekBP.Lobby_Task_WeekBP",
    uiStat = {
      name = "\228\187\187\229\138\161-\230\175\143\229\145\168\228\187\187\229\138\161"
    },
    isMainUI = false
  },
  newbie_task_daily = {
    keyName = "newbie_task_daily",
    moduleName = "client.slua.umg.task.Taskitem.Lobby_NewbieTask_Daily_UIBP",
    path = "/Game/UMG/UI_BP/Task/Taskitem/Lobby_NewbieTask_Daily_UIBP.Lobby_NewbieTask_Daily_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\228\187\187\229\138\161-\230\150\176\229\133\181\232\174\173\231\187\131\232\175\166\230\131\133\229\177\149\231\164\186"
    }
  },
  newbie_task_last_day_brief = {
    keyName = "newbie_task_last_day_brief",
    moduleName = "client.slua.umg.task.Taskitem.Lobby_NewbieTask_LastDay_Brief_UIBP",
    path = "/Game/UMG/UI_BP/Task/Taskitem/Lobby_NewbieTask_LastDay_Brief_UIBP.Lobby_NewbieTask_LastDay_Brief_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\228\187\187\229\138\161-\230\150\176\229\133\181\232\174\173\231\187\131\231\172\172\228\184\131\229\164\169\231\174\128\232\166\129\229\177\149\231\164\186"
    }
  },
  newbie_task_item = {
    keyName = "newbie_task_item",
    moduleName = "client.slua.umg.task.Taskitem.Lobby_NewbieTask_Item_UIBP",
    path = "/Game/UMG/UI_BP/Task/Taskitem/Lobby_NewbieTask_Item_UIBP.Lobby_NewbieTask_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\228\187\187\229\138\161-\230\150\176\229\133\181\232\174\173\231\187\131\229\141\149\230\157\161\228\187\187\229\138\161"
    }
  },
  newbie_task_tips = {
    keyName = "newbie_task_tips",
    moduleName = "client.slua.umg.task.Lobby_NewbieTask_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Task/Lobby_NewbieTask_Tips_UIBP.Lobby_NewbieTask_Tips_UIBP",
    uiStat = {
      name = "\228\187\187\229\138\161-\230\150\176\229\133\181\232\174\173\231\187\131\231\187\147\230\157\159\230\143\144\231\164\186\229\188\185\231\170\151"
    }
  },
  Lobby_Popup_RoleInfo_Slap_UIBP = {
    keyName = "Lobby_Popup_RoleInfo_Slap_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Lobby_Popup_RoleInfo_Slap_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Lobby_Popup_RoleInfo_Slap_UIBP.Lobby_Popup_RoleInfo_Slap_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\186\178\229\175\134\229\133\179\231\179\187-\232\167\163\233\148\129\229\133\177\228\186\171\230\151\182\232\163\133\232\131\140\229\140\133\229\188\185\231\170\151"
    }
  },
  bulletin_board = {
    keyName = "bulletin_board",
    moduleName = "client.slua.umg.activity.bulletin_board.bulletin_board",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Bulletin_Board/Bulletin_Board_Main_BP.Bulletin_Board_Main_BP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\133\172\229\145\138\230\160\143\233\157\162\230\157\191"
    }
  },
  bulletin_board_anniversary = {
    keyName = "bulletin_board_anniversary",
    moduleName = "client.slua.umg.activity.bulletin_board.bulletin_board_anniversary",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Bulletin_Board/Bulletin_Board_Anniversary_Main_BP.Bulletin_Board_Anniversary_Main_BP",
    uiStat = {
      name = "\229\133\172\229\145\138\230\160\143\233\157\162\230\157\191-\229\145\168\229\185\180\229\186\134"
    }
  },
  chat_recruit_panel_new = {
    keyName = "chat_recruit_panel_new",
    moduleName = "client.slua.umg.lobby_chat.recruit.chat_recruit_panel_new",
    path = "/Game/UMG/UI_BP/LobbyChat/Chatteam2_UIBP.Chatteam2_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169-\230\139\155\229\139\159\231\149\140\233\157\162-180\231\137\136\230\156\172"
    }
  },
  chat_recruit_filter_new = {
    keyName = "chat_recruit_filter_new",
    moduleName = "client.slua.umg.lobby_chat.recruit.chat_recruit_filter_new",
    path = "/Game/UMG/UI_BP/LobbyChat/Chatteam_Screen_UIBP.Chatteam_Screen_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169-\230\139\155\229\139\159\231\173\155\233\128\137\231\149\140\233\157\162-180\231\137\136\230\156\172"
    }
  },
  ChatMenu_BP = {
    keyName = "ChatMenu_BP",
    moduleName = "client.slua.umg.lobby_chat.chat_menu_main_city_bp",
    path = "/Game/UMG/UI_BP/LobbyChat/Personal_Info_UIBP.Personal_Info_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169-\229\188\185\229\135\186\232\143\156\229\141\149"
    }
  },
  Personal_Info_UIBP = {
    keyName = "Personal_Info_UIBP",
    moduleName = "client.slua.umg.lobby_chat.Personal_Info_UIBP",
    path = "/Game/UMG/UI_BP/LobbyChat/Personal_Info_UIBP.Personal_Info_UIBP",
    uiStat = {
      name = "\231\142\169\229\174\182\228\191\161\230\129\175\229\141\161\231\149\140\233\157\162"
    }
  },
  ChatGiftNotify = {
    keyName = "ChatGiftNotify",
    moduleName = "client.slua.umg.lobby_chat.chat_gift_notify_ani",
    path = "/Game/UMG/UI_BP/LobbyChat/ChatGiftNotify_BP.ChatGiftNotify_BP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\232\129\138\229\164\169-\231\164\188\231\137\169\233\128\154\231\159\165\229\138\168\231\148\187"
    }
  },
  ui_chat_main = {
    keyName = "ui_chat_main",
    moduleName = "client.slua.umg.lobby_chat.ui_chat_main",
    path = "/Game/Mod/Lobby/Split/LobbyChat/LobbyChat_UIBP.LobbyChat_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\232\129\138\229\164\169-\228\184\187\231\149\140\233\157\162"
    },
    useBatchOptimization = true,
    asy = true
  },
  ui_chat_channel_emoji = {
    keyName = "ui_chat_channel_emoji",
    moduleName = "client.slua.umg.lobby_chat.ui_chat_channel_emoji",
    path = "/Game/Mod/Lobby/Split/LobbyChat/LobbyChatEmoji_UIBP.LobbyChatEmoji_UIBP",
    uiStat = {
      name = "\233\162\145\233\129\147-\232\161\168\230\131\133\231\149\140\233\157\162"
    },
    AndroidBackType = EAndroidBackType.Ban,
    asy = true
  },
  ChatMessage_Achievement_UIBP = {
    keyName = "ChatMessage_Achievement_UIBP",
    moduleName = "client.slua.umg.lobby_chat.item.MessageChild.ChatMessage_Achievement_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/Item/Chat_MessageChild/ChatMessage_Achievement_UIBP.ChatMessage_Achievement_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\232\129\138\229\164\169\230\182\136\230\129\175-\230\136\144\229\176\177\229\136\134\228\186\171"
    },
    loadFromPool = EUIConfigPoolType.chat_pool
  },
  Chat_Message_Report_Tips_UIBP = {
    keyName = "Chat_Message_Report_Tips_UIBP",
    moduleName = "client.slua.umg.lobby_chat.item.MessageChild.Chat_Message_Report_Tips_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/Chat_Message_Report_Tips_UIBP.Chat_Message_Report_Tips_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\232\129\138\229\164\169\230\182\136\230\129\175-\228\184\190\230\138\165and\231\189\174\233\161\182"
    },
    loadFromPool = EUIConfigPoolType.chat_pool
  },
  ui_chat_new = {
    keyName = "ui_chat_new",
    moduleName = "client.slua.umg.lobby_chat.ui_chat_new",
    path = "/Game/Mod/Lobby/Split/LobbyChat/ChatNew_UIBP.ChatNew_UIBP",
    isSingleton = false,
    isMainUI = false
  },
  chat_horn_msg_input = {
    keyName = "chat_horn_msg_input",
    moduleName = "client.slua.umg.lobby_chat.chat_horn_msg_input",
    path = "/Game/Mod/Lobby/Split/LobbyChat/Lobby_Speaker_UIBP.Lobby_Speaker_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169-\229\150\135\229\143\173\229\143\145\232\168\128\231\149\140\233\157\162"
    }
  },
  chat_emoji = {
    keyName = "chat_emoji",
    moduleName = "client.slua.umg.lobby_chat.chat_emoji",
    path = "/Game/Mod/Lobby/Split/LobbyChat/LobbyChatEmoji_02_BP.LobbyChatEmoji_02_BP",
    uiStat = {
      name = "\232\129\138\229\164\169-\229\150\135\229\143\173\229\143\145\232\168\128\231\149\140\233\157\162-\232\129\138\229\164\169\232\161\168\230\131\133"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  ui_chat_room_create = {
    keyName = "ui_chat_room_create",
    moduleName = "client.slua.umg.lobby_chat.chatroom.ui_chat_room_create",
    path = "/Game/Mod/Lobby/Split/LobbyChat/ChatRoom/Chatroomcreat_UIBP.Chatroomcreat_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169-\229\136\155\229\187\186\232\129\138\229\164\169\229\174\164\231\149\140\233\157\162"
    },
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW
  },
  ui_chat_room_password = {
    keyName = "ui_chat_room_password",
    moduleName = "client.slua.umg.lobby_chat.chatroom.ui_chat_room_password",
    path = "/Game/UMG/UI_BP/LobbyChat/ChatroomPassword_UIBP.ChatroomPassword_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169-\229\138\160\229\133\165\232\129\138\229\164\169\229\174\164\229\175\134\231\160\129\232\190\147\229\133\165\231\149\140\233\157\162"
    }
  },
  ui_chat_gift_comfirm = {
    keyName = "ui_chat_gift_comfirm",
    moduleName = "client.slua.umg.lobby_chat.ui_chat_gift_comfirm",
    path = "/Game/Mod/Lobby/Split/LobbyChat/LobbyChat_Radio_UIBP.LobbyChat_Radio_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169-\233\128\129\231\164\188\231\161\174\232\174\164\230\143\144\231\164\186"
    }
  },
  ChatFriend_ReserveMsg_UIBP = {
    keyName = "ChatFriend_ReserveMsg_UIBP",
    moduleName = "client.slua.umg.lobby_chat.ChatFriend_ReserveMsg_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/ChatFriend_ReserveMsg_UIBP.ChatFriend_ReserveMsg_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169-\229\165\189\229\143\139\233\162\132\231\186\166\230\182\136\230\129\175"
    }
  },
  chat_entrance_horn = {
    keyName = "chat_entrance_horn",
    moduleName = "client.slua.umg.lobby_chat.chat_horn_msg_tips",
    path = "/Game/Mod/Lobby/Split/LobbyChat/Lobby_Speaker_Tips_UIBP.Lobby_Speaker_Tips_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\232\129\138\229\164\169\229\133\165\229\143\163\229\150\135\229\143\173"
    }
  },
  chat_channel_world_horn = {
    keyName = "chat_channel_world_horn",
    moduleName = "client.slua.umg.lobby_chat.chat_horn_msg_tips",
    path = "/Game/Mod/Lobby/Split/LobbyChat/Lobby_Speaker_Item_UIBP.Lobby_Speaker_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\228\184\150\231\149\140\232\129\138\229\164\169\229\150\135\229\143\173"
    }
  },
  chat_pround_horn_msg_tips = {
    keyName = "chat_pround_horn_msg_tips",
    moduleName = "client.slua.umg.lobby_chat.chat_pround_horn_msg_tips",
    path = "/Game/UMG/UI_BP/LobbyChat/Lobby_Speaker_Pround_Item_UIBP.Lobby_Speaker_Pround_Item_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169-chat_pround_horn_msg_tips"
    }
  },
  Chat_FriendInfo_HomeStatus_UIBP = {
    keyName = "Chat_FriendInfo_HomeStatus_UIBP",
    moduleName = "client.slua.umg.lobby_chat.item.MemberListSubItem.Chat_FriendInfo_HomeStatus_UIBP",
    path = "/Game/UMG/UI_BP/LobbyChat/Item/Chat_MemberListSubItem/Chat_FriendInfo_HomeStatus_UIBP.Chat_FriendInfo_HomeStatus_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\129\138\229\164\169-\229\165\189\229\143\139\228\191\161\230\129\175-\229\174\182\229\155\173\231\138\182\230\128\129\230\152\190\231\164\186"
    },
    loadFromPool = EUIConfigPoolType.chat_pool
  },
  BlackFriday_Main_UIBP = {
    keyName = "BlackFriday_Main_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.BlackFriday_Main_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Main/BlackFriday_Main_UIBP.BlackFriday_Main_UIBP",
    uiStat = {
      name = "\233\187\145\228\186\148-\228\184\187\231\149\140\233\157\162"
    }
  },
  BlackFriday_WeekSign_UIBP = {
    keyName = "BlackFriday_WeekSign_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.BlackFriday.UMG.WeekSign.BlackFriday_WeekSign_UIBP",
    path = "/Game/Mod/Lobby/Base/BlackFriday/WeekSign/BlackFriday_WeekSign_UIBP.BlackFriday_WeekSign_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\187\145\228\186\148-\229\145\168\231\173\190\229\136\176"
    }
  },
  BlackFriday_WeekSign_Reward_Item_UIBP = {
    keyName = "BlackFriday_WeekSign_Reward_Item_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.BlackFriday.UMG.WeekSign.BlackFriday_WeekSign_Reward_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\233\187\145\228\186\148-\229\145\168\231\173\190\229\136\176item"
    }
  },
  BlackFriday_GroupBuy_UIBP = {
    keyName = "BlackFriday_GroupBuy_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.GroupBuy.BlackFriday_GroupBuy_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/GroupBuy/BlackFriday_GroupBuy_UIBP.BlackFriday_GroupBuy_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\233\187\145\228\186\148-\229\155\162\232\180\173-\228\184\187UI"
    }
  },
  BlackFriday_GroupBuy_Rebate_UIBP = {
    keyName = "BlackFriday_GroupBuy_Rebate_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.GroupBuy.BlackFriday_GroupBuy_Rebate_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/GroupBuy/BlackFriday_GroupBuy_Rebate_UIBP.BlackFriday_GroupBuy_Rebate_UIBP",
    asy = true,
    uiStat = {
      name = "\233\187\145\228\186\148-\229\155\162\232\180\173-\232\191\148\229\136\169UI"
    }
  },
  BlackFriday_GroupBuy_RebateRecord_UIBP = {
    keyName = "BlackFriday_GroupBuy_RebateRecord_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.GroupBuy.BlackFriday_GroupBuy_RebateRecord_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/GroupBuy/BlackFriday_GroupBuy_RebateRecord_UIBP.BlackFriday_GroupBuy_RebateRecord_UIBP",
    asy = true,
    uiStat = {
      name = "\233\187\145\228\186\148-\229\155\162\232\180\173-\232\191\148\229\136\169\232\174\176\229\189\149UI"
    }
  },
  BlackFriday_GroupBuy_UCIncrease_UIBP = {
    keyName = "BlackFriday_GroupBuy_UCIncrease_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.GroupBuy.BlackFriday_GroupBuy_UCIncrease_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/GroupBuy/BlackFriday_GroupBuy_UCIncrease_UIBP.BlackFriday_GroupBuy_UCIncrease_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\233\187\145\228\186\148-\229\155\162\232\180\173-UC\230\177\135\229\133\165\229\138\168\231\148\187"
    }
  },
  BlackFriday_Upgrade_UIBP = {
    keyName = "BlackFriday_Upgrade_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Upgrade.BlackFriday_Upgrade_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Upgrade/BlackFriday_Upgrade_UIBP.BlackFriday_Upgrade_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\233\187\145\228\186\148-\230\180\187\232\183\131\229\141\135\231\186\167-\228\184\187UI"
    }
  },
  BlackFriday_Upgrade_ItemGet_UIBP = {
    keyName = "BlackFriday_Upgrade_ItemGet_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Upgrade.BlackFriday_Upgrade_ItemGet_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Upgrade/BlackFriday_Upgrade_ItemGet_UIBP.BlackFriday_Upgrade_ItemGet_UIBP",
    asy = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\233\187\145\228\186\148-\230\180\187\232\183\131\229\141\135\231\186\167-\230\176\184\228\185\133\229\165\151\232\163\133\230\129\173\229\150\156\232\142\183\229\190\151"
    }
  },
  BlackFriday_Entrance_UIBP = {
    keyName = "BlackFriday_LobbyEntrance_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.BlackFriday.UMG.Entrance.BlackFriday_Entrance_UIBP",
    path = "/Game/Mod/Lobby/Base/BlackFriday/Entrance/BlackFriday_Entrance_UIBP.BlackFriday_Entrance_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\233\187\145\228\186\148-\229\164\167\229\142\133\229\133\165\229\143\163"
    }
  },
  BlackFriday_TaskPanel_UIBP = {
    keyName = "BlackFriday_TaskPanel_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.TaskPanel.BlackFriday_TaskPanel_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/TaskPanel/BlackFriday_TaskPanel_UIBP.BlackFriday_TaskPanel_UIBP",
    asy = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\233\187\145\228\186\148-\233\128\154\231\148\168\229\173\144\228\187\187\229\138\161\233\157\162\230\157\191"
    }
  },
  BlackFriday_Vow_UIBP = {
    keyName = "BlackFriday_Vow_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Vow.BlackFriday_Vow_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Vow/BlackFriday_Vow_UIBP.BlackFriday_Vow_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\233\187\145\228\186\148-\232\174\184\230\132\191\230\138\152\230\137\163-\228\184\187UI"
    }
  },
  BlackFriday_Vow_Vote_UIBP = {
    keyName = "BlackFriday_Vow_Vote_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Vow.BlackFriday_Vow_Vote_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Vow/BlackFriday_Vow_Vote_UIBP.BlackFriday_Vow_Vote_UIBP",
    uiStat = {
      name = "\233\187\145\228\186\148-\232\174\184\230\132\191\230\138\152\230\137\163-\230\138\149\231\165\168\229\188\185\231\170\151"
    }
  },
  BlackFriday_Vow_Canvass_UIBP = {
    keyName = "BlackFriday_Vow_Canvass_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Vow.BlackFriday_Vow_Canvass_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Vow/BlackFriday_Vow_Canvass_UIBP.BlackFriday_Vow_Canvass_UIBP",
    uiStat = {
      name = "\233\187\145\228\186\148-\232\174\184\230\132\191\230\138\152\230\137\163-\232\175\173\229\189\149\231\188\150\232\190\145\229\188\185\231\170\151"
    }
  },
  BlackFriday_Vow_Share_UIBP = {
    keyName = "BlackFriday_Vow_Share_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Vow.BlackFriday_Vow_Share_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Vow/BlackFriday_Vow_Share_UIBP.BlackFriday_Vow_Share_UIBP",
    uiStat = {
      name = "\233\187\145\228\186\148-\232\174\184\230\132\191\230\138\152\230\137\163-\230\139\137\231\165\168\229\136\134\228\186\171\229\188\185\231\170\151"
    }
  },
  BlackFriday_TeamInvitePopup_UIBP = {
    keyName = "BlackFriday_TeamInvitePopup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Common.BlackFriday_TeamInvitePopup_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Common/BlackFriday_TeamInvitePopup_UIBP.BlackFriday_TeamInvitePopup_UIBP",
    uiStat = {
      name = "\233\187\145\228\186\148-\231\187\132\229\155\162\233\130\128\232\175\183\229\165\189\229\143\139\229\188\185\231\170\151"
    }
  },
  BlackFriday_Subscribe_UIBP = {
    keyName = "BlackFriday_Subscribe_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Subscribe.BlackFriday_Subscribe_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Subscribe/BlackFriday_Subscribe_UIBP.BlackFriday_Subscribe_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\233\187\145\228\186\148-\232\174\162\233\152\133\228\184\187\231\149\140\233\157\162"
    }
  },
  BlackFriday_CreateGroupSucPopup_UIBP = {
    keyName = "BlackFriday_CreateGroupSucPopup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Subscribe.BlackFriday_CreateGroupSucPopup_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Subscribe/Popup/BlackFriday_CreateGroupSucPopup_UIBP.BlackFriday_CreateGroupSucPopup_UIBP",
    uiStat = {
      name = "\233\187\145\228\186\148-\232\174\162\233\152\133\229\136\155\229\187\186\230\139\188\229\155\162\233\152\159\228\188\141\230\136\144\229\138\159\229\144\142\231\154\132Tip\229\188\185\231\170\151"
    }
  },
  BlackFriday_SubscribeMyGroupPopup_UIBP = {
    keyName = "BlackFriday_SubscribeMyGroupPopup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Subscribe.BlackFriday_SubscribeMyGroupPopup_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Subscribe/Popup/BlackFriday_SubscribeMyGroupPopup_UIBP.BlackFriday_SubscribeMyGroupPopup_UIBP",
    uiStat = {
      name = "\233\187\145\228\186\148-\232\174\162\233\152\133\231\142\169\229\174\182\230\139\188\229\155\162\232\174\176\229\189\149\229\188\185\231\170\151"
    }
  },
  BlackFriday_SubscribePrivilegeItem_UIBP = {
    keyName = "BlackFriday_SubscribePrivilegeItem_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Subscribe.Item.BlackFriday_SubscribePrivilegeItem_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Subscribe/Item/BlackFriday_SubscribePrivilegeItem_UIBP.BlackFriday_SubscribePrivilegeItem_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\233\187\145\228\186\148-\232\174\162\233\152\133\230\157\131\231\155\138item"
    }
  },
  ui_Envelope_Item1 = {
    keyName = "ui_Envelope_Item1",
    moduleName = "client.slua.umg.red_envelope.ui_Envelope_Item1",
    path = "/Game/UMG/UI_BP/Lobby/Lobby_Redpacket_Item01_UIBP.Lobby_Redpacket_Item01_UIBP",
    uiStat = {name = "\231\186\162\229\140\133\233\155\168"},
    isSingleton = false
  },
  Lobby_Redpacket_FatefulConnection_Item_UIBP = {
    keyName = "Lobby_Redpacket_FatefulConnection_Item_UIBP",
    moduleName = "client.slua.umg.red_envelope.Lobby_Redpacket_FatefulConnection_Item_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Lobby_Redpacket_Item01_UIBP.Lobby_Redpacket_Item01_UIBP",
    uiStat = {
      name = "\231\187\147\231\188\152\231\186\162\229\140\133\233\155\168\231\186\162\229\140\133"
    },
    isSingleton = false
  },
  ui_red_envelope = {
    keyName = "ui_red_envelope",
    moduleName = "client.slua.umg.red_envelope.ui_red_envelope",
    path = "/Game/UMG/UI_BP/Lobby/Lobby_Redpacket_UIBP.Lobby_Redpacket_UIBP",
    uiStat = {name = "\231\186\162\229\140\133\233\155\168"},
    isMainUI = false
  },
  Lobby_Redpacket_FatefulConnection_UIBP = {
    keyName = "Lobby_Redpacket_FatefulConnection_UIBP",
    moduleName = "client.slua.umg.red_envelope.Lobby_Redpacket_FatefulConnection_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Lobby_Redpacket_FatefulConnection_UIBP.Lobby_Redpacket_FatefulConnection_UIBP",
    uiStat = {
      name = "\231\187\147\231\188\152\231\186\162\229\140\133\233\155\168"
    },
    isMainUI = false
  },
  ui_chat_share_achievement = {
    keyName = "ui_chat_share_achievement",
    moduleName = "client.slua.umg.lobby_chat.ui_chat_share_achievement",
    path = "/Game/UMG/UI_BP/RoleInfo/ChatShareAchievement_UIBP.ChatShareAchievement_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169-\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  ui_chat_share_achievement_show = {
    keyName = "ui_chat_share_achievement_show",
    moduleName = "client.slua.umg.lobby_chat.ui_chat_share_achievement_show",
    path = "/Game/UMG/UI_BP/RoleInfo/ChatShareAchievement_Item_UIBP.ChatShareAchievement_Item_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169-\229\136\134\228\186\171\230\143\144\231\164\186"
    }
  },
  mentor_lobby_tips = {
    keyName = "mentor_lobby_tips",
    moduleName = "client.slua.umg.mentor.mentor_lobby_tips",
    path = "/Game/UMG/UI_BP/PartnerReadiness/Item/PartnerReadiness_Tips_UIBP.PartnerReadiness_Tips_UIBP",
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\229\164\167\229\142\133tips"
    },
    isSingleton = false
  },
  mentor_wait_tips = {
    keyName = "mentor_wait_tips",
    moduleName = "client.slua.umg.mentor.mentor_wait_tips",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_LobbyIcon_UIBP.PartnerReadiness_LobbyIcon_UIBP",
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\232\128\129\229\133\181\229\164\167\229\142\133\231\173\137\229\190\133\230\143\144\231\164\186"
    },
    isSingleton = false
  },
  Lobby_Mid_Regression_Item_UIBP = {
    keyName = "Lobby_Mid_Regression_Item_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Item.Lobby_Mid_Regression_Item_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Item/Lobby_Mid_Regression_Item_UIBP.Lobby_Mid_Regression_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\164\167\229\142\133-\232\128\129\229\184\166\230\150\176-\229\133\165\229\143\163"
    }
  },
  Lobby_Mid_Tips_Item_UIBP = {
    keyName = "Lobby_Mid_Tips_Item_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_Tips_Item_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Mid_Tips_Item_UIBP.Lobby_Mid_Tips_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\164\167\229\142\133-tips"
    }
  },
  everyday_uc_activity = {
    keyName = "everyday_uc_activity",
    moduleName = "client.slua.umg.SpecialOffer.EverydayPack.everyday_uc_activity",
    path = "/Game/Arts_UI/LuckyWidget/EveryDayPack_UC/EveryDayPack_UC_UIBP.EveryDayPack_UC_UIBP",
    jumpModuleID = BP_ENUM_MODULE_EVERYDAY_PACK_UC,
    uiStat = {
      name = "\230\175\143\230\151\165UC\231\164\188\229\140\133"
    }
  },
  Exchange_Collect_Award_Popup = {
    keyName = "Exchange_Collect_Award_Popup",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Exchange.TarotCard.Exchange_Collect_Award_Popup",
    path = "/Game/Arts_UI/LuckyWidget/LuckySpinTarotTemplate/Popup/LuckySpinTarotTemplate_Popup_UIBP.LuckySpinTarotTemplate_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\229\161\148\231\189\151\231\137\140\233\152\182\230\174\181\229\165\150\229\138\177\229\188\185\231\170\151"
    }
  },
  LuckySpinTarotTemplate_Popup_02_UIBP = {
    keyName = "LuckySpinTarotTemplate_Popup_02_UIBP",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Exchange.TarotCard.LuckySpinTarotTemplate_Popup_02_UIBP",
    path = "/Game/Arts_UI/LuckyWidget/LuckySpinTarotTemplate/Popup/LuckySpinTarotTemplate_Popup_02_UIBP.LuckySpinTarotTemplate_Popup_02_UIBP",
    containerName = UIContainers.Top,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    asy = true,
    uiStat = {
      name = "\229\161\148\231\189\151\231\137\140\230\148\182\233\155\134\229\165\150\229\138\177\229\188\185\231\170\151"
    }
  },
  TarotFeaturePreview_Popup_UIBP = {
    keyName = "TarotFeaturePreview_Popup_UIBP",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Components.TarotCard.TarotFeaturePreview_Popup_UIBP",
    path = "/Game/Arts_UI/LuckyWidget/LuckySpinTarotTemplate/TarotFeaturePreview_Popup_UIBP.TarotFeaturePreview_Popup_UIBP",
    uiStat = {
      name = "\229\161\148\231\189\151\231\137\185\230\128\167\233\162\132\232\167\136\229\188\185\231\170\151\231\149\140\233\157\162"
    }
  },
  TarotFeaturePreview_Tip = {
    keyName = "TarotFeaturePreview_Tip",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Components.TarotCard.TarotFeaturePreview_Tip",
    path = "/Game/Arts_UI/LuckyWidget/LuckySpinTarotTemplate/TarotFeaturePreview_Tip.TarotFeaturePreview_Tip",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\229\161\148\231\189\151\231\137\185\230\128\167\232\175\180\230\152\142\232\175\166\230\131\133\233\163\152\231\170\151"
    }
  },
  FirstDrawBenefit_Popup_UIBP = {
    keyName = "FirstDrawBenefit_Popup_UIBP",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Components.TarotCard.FirstDrawBenefit_Popup_UIBP",
    path = "",
    asy = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\229\161\148\231\189\151\233\135\145\232\163\133\233\166\150\230\172\161\231\166\143\229\136\169\229\188\185\230\161\134"
    }
  },
  TC_LuckybackHigCarOpenAni_Supply = {
    keyName = "TC_LuckybackHigCarOpenAni_Supply",
    moduleName = "client.slua.umg.lobby_activity.LuckySpin.TraitClassStyle.Supply.TC_LuckybackHigCarOpenAni_Supply",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/CarLuckyPutbackTemplate/LukcyputbackTemplate_LOGO_UIBP.LukcyputbackTemplate_LOGO_UIBP",
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150-\233\171\152\231\186\167\229\144\136\230\136\144\232\189\166\230\137\147\229\188\128\229\138\168\231\148\187"
    }
  },
  BackStyleCarBtn_Supply = {
    keyName = "BackStyleCarBtn_Supply",
    moduleName = "client.slua.umg.lobby_activity.LuckySpin.TraitClassStyle.Supply.T_BackStyleCarUI_Supply",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyputbackTemplateNew/Popup/LukcyputbackTemplate_Popup_Car_UIBP.LukcyputbackTemplate_Popup_Car_UIBP",
    sceneID = 5,
    uiStat = {
      name = "\230\148\190\229\155\158\232\161\165\231\187\153-\230\143\144\232\189\166\231\149\140\233\157\162"
    }
  },
  BackStyleCarSwitchLowCar_Supply = {
    keyName = "BackStyleCarSwitchLowCar_Supply",
    moduleName = "client.slua.umg.lobby_activity.LuckySpin.TraitClassStyle.Supply.T_BackStyleCarSwitchLowCar_Supply",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyputbackTemplateNew/Exchange/LukcyputbackTemplate_Popup_Car_02_UIBP.LukcyputbackTemplate_Popup_Car_02_UIBP",
    uiStat = {
      name = "\230\148\190\229\155\158\232\161\165\231\187\153-\230\143\144\232\189\166\229\188\185\231\170\151\233\128\137\230\139\169"
    }
  },
  T_BackStyleCarComposeTip = {
    keyName = "T_BackStyleCarComposeTip",
    moduleName = "client.slua.umg.lobby_activity.LuckySpin.TraitClassStyle.Supply.T_BackStyleCarComposeTip",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyputbackTemplateNew/Exchange/LukcyputbackTemplate_Popup_Car_03_UIBP.LukcyputbackTemplate_Popup_Car_03_UIBP",
    uiStat = {
      name = "\230\148\190\229\155\158\232\161\165\231\187\153-\230\143\144\232\189\166\230\143\144\231\164\186 --\230\151\160\233\128\137\233\161\185"
    }
  },
  TC_UnbackDynamicRuleForm = {
    keyName = "TC_UnbackDynamicRuleForm",
    moduleName = "client.slua.umg.lobby_activity.LuckyUnback.TraitClassStyle.TC_UnbackRule2700TemplateVersion",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Activity_Rule_Tips_UIBP.Activity_Rule_Tips_UIBP",
    uiStat = {
      name = "\228\184\141\230\148\190\229\155\158\230\138\189\229\165\150-\232\167\132\229\136\153\231\149\140\233\157\162"
    }
  },
  LukcyOptionalTurntable_Pool_UIBP = {
    keyName = "LukcyOptionalTurntable_Pool_UIBP",
    moduleName = "client.slua.umg.lobby_activity.LukcyOptionalTurntable.LukcyOptionalTurntable_Pool_UIBP",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyOptionalTurntable/LukcyOptionalTurntable_Pool_UIBP.LukcyOptionalTurntable_Pool_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\161\165\231\187\153\232\135\170\233\128\137\229\174\157\231\174\177\232\189\172\231\155\152-\230\156\170\232\135\170\233\128\137\228\184\187\231\149\140\233\157\162\229\165\150\230\177\160"
    }
  },
  LukcyOptionalTurntable_SelectionPool_UIBP = {
    keyName = "LukcyOptionalTurntable_SelectionPool_UIBP",
    moduleName = "client.slua.umg.lobby_activity.LukcyOptionalTurntable.LukcyOptionalTurntable_SelectionPool_UIBP",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyOptionalTurntable/LukcyOptionalTurntable_SelectionPool_UIBP.LukcyOptionalTurntable_SelectionPool_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\161\165\231\187\153\232\135\170\233\128\137\229\174\157\231\174\177\232\189\172\231\155\152-\232\135\170\233\128\137\229\174\140\231\154\132\228\184\187\231\149\140\233\157\162\229\165\150\230\177\160"
    }
  },
  LukcyOptionalTurntable_Tips_UIBP = {
    keyName = "LukcyOptionalTurntable_Tips_UIBP",
    moduleName = "client.slua.umg.lobby_activity.LukcyOptionalTurntable.LukcyOptionalTurntable_Tips_UIBP",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyOptionalTurntable/LukcyOptionalTurntable_Tips_UIBP.LukcyOptionalTurntable_Tips_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\161\165\231\187\153\232\135\170\233\128\137\229\174\157\231\174\177\232\189\172\231\155\152-\232\135\170\233\128\137\229\174\140\231\154\132\228\184\187\231\149\140\233\157\162\229\165\150\230\177\160\231\130\185\229\135\187\229\164\154\230\149\176\233\135\143\231\137\169\229\147\129\230\143\144\231\164\186"
    }
  },
  LukcyOptionalTurntable_Tips_Item_UIBP = {
    keyName = "LukcyOptionalTurntable_Tips_Item_UIBP",
    moduleName = "client.slua.umg.lobby_activity.LukcyOptionalTurntable.LukcyOptionalTurntable_Tips_Item_UIBP",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyOptionalTurntable/Item/LukcyOptionalTurntable_Tips_Item_UIBP.LukcyOptionalTurntable_Tips_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\161\165\231\187\153\232\135\170\233\128\137\229\174\157\231\174\177\232\189\172\231\155\152-\232\135\170\233\128\137\229\174\140\231\154\132\228\184\187\231\149\140\233\157\162\229\165\150\230\177\160\231\130\185\229\135\187\229\164\154\230\149\176\233\135\143\231\137\169\229\147\129\230\143\144\231\164\186item"
    }
  },
  Optional_RaffleBox_Popup_UIBP = {
    keyName = "Optional_RaffleBox_Popup_UIBP",
    moduleName = "client.slua.umg.lobby_activity.LukcyOptionalTurntable.Optional_RaffleBox_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyOptionalTurntable/Popup/Optional_RaffleBox_Popup_UIBP.Optional_RaffleBox_Popup_UIBP",
    uiStat = {
      name = "\232\161\165\231\187\153\232\135\170\233\128\137\229\174\157\231\174\177\232\189\172\231\155\152-\232\135\170\233\128\137\229\174\157\231\174\177\229\188\185\231\170\151"
    }
  },
  Optional_Main_UIBP = {
    keyName = "Optional_Main_UIBP",
    moduleName = "client.slua.umg.lobby_activity.LukcyOptionalTurntable.Optional_Main_UIBP",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyOptionalTurntable/Optional_Main_UIBP.Optional_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_OPTIONAL_TURNTABLE_SELECT,
    uiStat = {
      name = "\232\161\165\231\187\153\232\135\170\233\128\137\229\174\157\231\174\177\232\189\172\231\155\152-\232\135\170\233\128\137\229\165\150\229\147\129\231\149\140\233\157\162\233\161\181\231\173\190"
    }
  },
  Optional_Select_Prize_UIBP = {
    keyName = "Optional_Select_Prize_UIBP",
    moduleName = "client.slua.umg.lobby_activity.LukcyOptionalTurntable.Optional_Select_Prize_UIBP",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyOptionalTurntable/Optional_Select_Prize_UIBP.Optional_Select_Prize_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\161\165\231\187\153\232\135\170\233\128\137\229\174\157\231\174\177\232\189\172\231\155\152-\232\135\170\233\128\137\229\165\150\229\147\129\231\149\140\233\157\162"
    }
  },
  Optional_Preview_Prize_UIBP = {
    keyName = "Optional_Preview_Prize_UIBP",
    moduleName = "client.slua.umg.lobby_activity.LukcyOptionalTurntable.Optional_Preview_Prize_UIBP",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyOptionalTurntable/Optional_Preview_Prize_UIBP.Optional_Preview_Prize_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\161\165\231\187\153\232\135\170\233\128\137\229\174\157\231\174\177\232\189\172\231\155\152-\233\162\132\232\167\136\229\183\178\233\128\137\229\165\150\229\147\129\231\149\140\233\157\162"
    }
  },
  Optional_Select_Prize_List_Item_UIBP = {
    keyName = "Optional_Select_Prize_List_Item_UIBP",
    moduleName = "client.slua.umg.lobby_activity.LukcyOptionalTurntable.Optional_Select_Prize_List_Item_UIBP",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyOptionalTurntable/Item/Optional_Select_Prize_List_Item_UIBP.Optional_Select_Prize_List_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\135\170\233\128\137\232\189\172\231\155\152\226\128\148\226\128\148\232\135\170\233\128\137\231\149\140\233\157\162\229\183\178\233\128\137\229\165\150\229\147\129\230\167\189\228\189\141"
    }
  },
  LuckyunbackTemplate_Discount_Main_UIBP = {
    keyName = "LuckyunbackTemplate_Discount_Main_UIBP",
    moduleName = "client.slua.umg.lobby_activity.LuckyUnback.LuckyunbackTemplate_Discount_Main_UIBP",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyunbackTemplate/LuckyunbackTemplate_Discount_Main_UIBP.LuckyunbackTemplate_Discount_Main_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\228\184\141\230\148\190\229\155\158\232\189\172\231\155\152 \230\138\152\230\137\163\231\149\140\233\157\162"
    }
  },
  LuckyDoubleDrawOneConfirm = {
    keyName = "LuckyDoubleDrawOneConfirm",
    moduleName = "client.slua.umg.lobby_activity.LuckyDouble.LuckyDoubleDrawAllBox",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LuckyDoubleTemplate/LuckyDouble_RightLeft_Template/LuckyDouble_Mod_Onekey_UIBP.LuckyDouble_Mod_Onekey_UIBP",
    asy = true,
    uiStat = {
      name = "\229\143\140\229\177\130\228\184\141\230\148\190\229\155\158\232\189\172\231\155\152-\228\184\128\233\148\174\230\138\189\229\165\150\228\186\140\231\186\167\231\161\174\232\174\164\229\188\185\231\170\151"
    }
  },
  LuckyWidgetPrice = {
    keyName = "LuckyWidgetPrice",
    moduleName = "client.slua.umg.lobby_activity.LuckyWidget.LuckyWidgetPrice.LuckyWidgetPrice",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LuckyDoubleTemplate/LuckyDouble_RightLeft_Template/Lucky_Rule_Tips_UIBP.Lucky_Rule_Tips_UIBP",
    uiStat = {
      name = "\232\189\172\231\155\152\231\187\132\228\187\182-\228\187\183\230\160\188\228\184\128\232\167\136"
    }
  },
  Firstcharge_Small_UIBP = {
    keyName = "Firstcharge_Small_UIBP",
    moduleName = "client.slua.umg.recharge.recharge_the_first_charge_small",
    path = "/Game/Mod/Lobby/Base/SpecialOffer/FirstchargeSmall_UIBP.FirstchargeSmall_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\232\181\155\229\173\163-\232\181\155\229\173\163\233\166\150\229\133\133\229\176\143\231\149\140\233\157\162"
    }
  },
  ui_quick_question = {
    keyName = "ui_quick_question",
    moduleName = "client.slua.umg.activity.ui_quick_question",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Quick_Question/Quick_Question_UIBP.Quick_Question_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\229\191\171\230\141\183\233\151\174\229\141\183\231\149\140\233\157\162"
    }
  },
  lobby_lab_entrance = {
    keyName = "lobby_lab_entrance",
    moduleName = "client.slua.umg.lobby.lobby_lab_entrance",
    path = "/Game/UMG/UI_BP/Lobby/Lobby_Lab_Entrance_UIBP.Lobby_Lab_Entrance_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\229\183\165\229\157\138"
    }
  },
  Lobby_Main_FunProp_List_UIBP = {
    keyName = "Lobby_Main_FunProp_List_UIBP",
    moduleName = "client.slua.umg.lobby.Lobby_Main_FunProp_List_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_FunProp_List_UIBP.Lobby_Main_FunProp_List_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\229\164\167\229\142\133-\231\142\169\229\133\183\228\189\191\231\148\168\229\188\185\229\135\186\231\149\140\233\157\162"
    }
  },
  Lobby_Main_Paint_UIBP = {
    keyName = "Lobby_Main_Paint_UIBP",
    moduleName = "client.slua.umg.lobby.Lobby_Main_Paint_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_Paint_UIBP.Lobby_Main_Paint_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    isSingleton = false,
    containerName = UIContainers.Bottom,
    uiStat = {
      name = "\229\164\167\229\142\133-\229\150\183\230\188\134UI"
    }
  },
  Lobby_SimpleUI_Main_UIBP = {
    keyName = "Lobby_SimpleUI_Main_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_SimpleUI_Main_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_SimpleUI_Main_UIBP.Lobby_SimpleUI_Main_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\230\158\129\231\174\128\229\156\186\230\153\175"
    }
  },
  Lobby_SimpleUI_Emote_UIBP = {
    keyName = "Lobby_SimpleUI_Emote_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_SimpleUI_Emote_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_SimpleUI_Emote_UIBP.Lobby_SimpleUI_Emote_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\230\158\129\231\174\128-\231\188\150\232\190\145\232\161\168\230\131\133"
    }
  },
  Lobby_SimpleUI_Clothes_UIBP = {
    keyName = "Lobby_SimpleUI_Clothes_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_SimpleUI_Clothes_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_SimpleUI_Clothes_UIBP.Lobby_SimpleUI_Clothes_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\230\158\129\231\174\128-\231\188\150\232\190\145\230\156\141\232\163\133"
    }
  },
  Lobby_Subhall_Main_UIBP = {
    keyName = "Lobby_Subhall_Main_UIBP",
    moduleName = "client.slua.umg.lobby.Subhall.Lobby_Subhall_Main_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Subhall_Main_UIBP.Lobby_Subhall_Main_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\229\173\144\229\164\167\229\142\133-\228\184\187\233\161\181\233\157\162"
    }
  },
  Lobby_Subhall_Cloth_UIBP = {
    keyName = "Lobby_Subhall_Cloth_UIBP",
    moduleName = "client.slua.umg.lobby.Subhall.Lobby_Subhall_Cloth_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Subhall_Cloth_UIBP.Lobby_Subhall_Cloth_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\229\173\144\229\164\167\229\142\133-\231\188\150\232\190\145\230\156\141\232\163\133"
    }
  },
  MainCity_Lobby_Main_Money_UIBP = {
    keyName = "MainCity_Lobby_Main_Money_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.MainCity_Lobby_Main_Money_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Item/MainCity_Lobby_Main_Money_UIBP.MainCity_Lobby_Main_Money_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\232\180\167\229\184\129\230\152\190\231\164\186"
    },
    asy = true,
    isMainUI = false
  },
  Lobby_Left_Message_UIBP = {
    keyName = "Lobby_Left_Message_UIBP",
    moduleName = "client.slua.umg.lobby.Left.Lobby_Left_Message_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Left/Lobby_Left_Message_UIBP.Lobby_Left_Message_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133-\229\183\166\228\190\167\228\191\161\230\129\175\230\160\143"
    },
    isSingleton = false
  },
  SocialLobby_LeftUI_RelationTip_UIBP = {
    keyName = "SocialLobby_LeftUI_RelationTip_UIBP",
    moduleName = "client.slua.umg.lobby.Left.ChildUI.SocialLobby_LeftUI_RelationTip_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/SocialLobby/ChildUI/SocialLobby_LeftUI_RelationTip_UIBP.SocialLobby_LeftUI_RelationTip_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133-\229\183\166\228\190\167\228\191\161\230\129\175\230\160\143\229\173\144UI\228\186\178\229\175\134\229\133\179\231\179\187\230\140\137\233\146\174Tip"
    },
    isSingleton = false,
    AndroidBackType = EAndroidBackType.Skip
  },
  SocialLobby_LeftUI_PopularPKTop3_UIBP = {
    keyName = "SocialLobby_LeftUI_PopularPKTop3_UIBP",
    moduleName = "client.slua.umg.lobby.Left.ChildUI.SocialLobby_LeftUI_PopularPKTop3_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/SocialLobby/ChildUI/SocialLobby_LeftUI_PopularPKTop3_UIBP.SocialLobby_LeftUI_PopularPKTop3_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133-\229\183\166\228\190\167\228\191\161\230\129\175\230\160\143\229\173\144UI\228\186\186\230\176\148\229\175\185\229\134\179top3\230\152\190\231\164\186"
    },
    isSingleton = false,
    AndroidBackType = EAndroidBackType.Skip
  },
  Lobby_Left_EvaluationGuide_UIBP = {
    keyName = "Lobby_Left_EvaluationGuide_UIBP",
    moduleName = "client.slua.umg.lobby.Left.Lobby_Left_EvaluationGuide_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Left/Tips/Lobby_Left_EvaluationGuide_UIBP.Lobby_Left_EvaluationGuide_UIBP",
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133-\229\183\166\228\184\138\229\176\143\228\191\161\230\129\175\230\160\1432"
    },
    isSingleton = false
  },
  SportCar_Garage_Edit_UIBP = {
    keyName = "SportCar_Garage_Edit_UIBP",
    moduleName = "client.slua.umg.Wardrobe.Popup.SportCar_Garage_Edit_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Left/SportCar_Garage_Edit_UIBP.SportCar_Garage_Edit_UIBP",
    jumpModuleID = BP_ENUM_MODULE_GARAGE_EDITOR,
    uiStat = {
      name = "\232\183\145\232\189\166\232\189\166\229\186\147-\232\189\166\232\190\134\231\188\150\232\190\145"
    }
  },
  SportCar_Instruction_Loop_UIBP = {
    keyName = "SportCar_Instruction_Loop_UIBP",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.Exchange.SportCar_Instruction_Loop_UIBP",
    path = "/Game/UMG/UI_BP/Common/Introduction/SportCar_Instruction_Loop_UIBP.SportCar_Instruction_Loop_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\232\183\145\232\189\166\229\133\145\230\141\162-\229\138\159\232\131\189\228\187\139\231\187\141"
    }
  },
  SportCar_Instruction_UIBP = {
    keyName = "SportCar_Instruction_UIBP",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.Instruction.SportCar_Instruction_UIBP",
    path = "/Game/UMG/UI_BP/Common/Introduction/SportCar_Instruction_UIBP.SportCar_Instruction_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\232\183\145\232\189\166\229\138\159\232\131\189\228\187\139\231\187\141-\232\189\166\230\172\190\230\166\130\232\167\136"
    }
  },
  SportCar_Tuwen_Instruction_UIBP = {
    keyName = "SportCar_Tuwen_Instruction_UIBP",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.Instruction.SportCar_Tuwen_Instruction_UIBP",
    path = "/Game/UMG/UI_BP/Common/Introduction/SportCar_Tuwen_Instruction_UIBP.SportCar_Tuwen_Instruction_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\232\183\145\232\189\166\229\138\159\232\131\189\228\187\139\231\187\141-\233\131\168\228\189\141\228\187\139\231\187\141"
    }
  },
  Lobby_Social_RightBottom_UIBP = {
    keyName = "Lobby_Social_RightBottom_UIBP",
    moduleName = "client.slua.umg.lobby.Left.Lobby_Social_RightBottom_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Left/Lobby_Social_RightBottom_UIBP.Lobby_Social_RightBottom_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133-\229\143\179\228\184\139\232\167\146\230\138\152\229\143\160UI"
    },
    isSingleton = false
  },
  Gift_VideoPlayer_UIBP = {
    keyName = "Gift_VideoPlayer_UIBP",
    moduleName = "client.slua.umg.gift.Gift_VideoPlayer_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Left/Gift_VideoPlayer_UIBP.Gift_VideoPlayer_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\181\160\231\164\188-\231\164\188\231\137\169\229\138\168\231\148\187\229\177\149\231\164\186\231\149\140\233\157\162"
    }
  },
  Lobby_RoleInfo_ProundLevel_Tips = {
    keyName = "Lobby_RoleInfo_ProundLevel_Tips",
    moduleName = "client.slua.umg.lobby.Left.Lobby_RoleInfo_ProundLevel_Tips",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_ProundLevel_Tips.Lobby_RoleInfo_ProundLevel_Tips",
    isMainUI = false,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\230\156\128\232\191\145\232\174\191\229\174\162"
    }
  },
  Lobby_RoleInfo_ProundLevel_Tips_Item = {
    keyName = "Lobby_RoleInfo_ProundLevel_Tips_Item",
    moduleName = "client.slua.umg.lobby.Left.Lobby_RoleInfo_ProundLevel_Tips_Item",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_ProundLevel_Tips_Item.Lobby_RoleInfo_ProundLevel_Tips_Item",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\230\156\128\232\191\145\232\174\191\229\174\162-\229\141\149\228\184\170\232\174\191\229\174\162Item"
    }
  },
  Lobby_SocialLobby_UIBP = {
    keyName = "Lobby_SocialLobby_UIBP",
    moduleName = "client.slua.umg.lobby.Left.Lobby_SocialLobby_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/SocialLobby/Lobby_SocialLobby_UIBP.Lobby_SocialLobby_UIBP",
    isMainUI = false,
    isSingleton = false,
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133-\228\184\187\231\149\140\233\157\162"
    }
  },
  SocialLobby_TopRight_Photo_UIBP = {
    keyName = "SocialLobby_TopRight_Photo_UIBP",
    moduleName = "client.slua.umg.lobby.Left.ChildUI.SocialLobby_TopRight_Photo_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/SocialLobby/ChildUI/SocialLobby_TopRight_Photo_UIBP.SocialLobby_TopRight_Photo_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133-\230\136\170\229\155\190\231\149\140\233\157\162UI"
    }
  },
  Lobby_Left_Record_Newbie_UIBP = {
    keyName = "Lobby_Left_Record_Newbie_UIBP",
    moduleName = "client.slua.umg.lobby.Left.Tips.Lobby_Left_Record_Newbie_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Left/Tips/Lobby_Left_Record_Newbie_UIBP.Lobby_Left_Record_Newbie_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133-\230\150\176\230\137\139\229\188\149\229\175\188"
    }
  },
  SocialLobby_FirstEnter_Guide = {
    keyName = "SocialLobby_FirstEnter_Guide ",
    moduleName = "client.slua.umg.lobby.Left.PlanCH_Guide_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/SocialLobby/Guide/PlanCH_Guide_UIBP.PlanCH_Guide_UIBP",
    showVisibility = UEnums.ESlateVisibility.Visible,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133/\229\177\149\233\166\134-\233\166\150\230\172\161\232\191\155\229\133\165\229\188\149\229\175\188\229\188\185\231\170\151"
    }
  },
  lobby_social_decoration = {
    keyName = "lobby_social_decoration",
    moduleName = "client.slua.umg.lobby.Left.lobby_social_decoration",
    path = "/Game/UMG/UI_BP/Lobby/Left/Lobby_Left_Details_UIBP.Lobby_Left_Details_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133-\229\177\149\231\164\186\231\137\169\229\147\129"
    }
  },
  SocialLobby_SlotEdit_UIBP = {
    moduleName = "client.slua.umg.lobby.Left.SocialLobbySlotEdit.SocialLobby_SlotEdit_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/SocialLobby/EditSlotUI/SocialLobby_SlotEdit_UIBP.SocialLobby_SlotEdit_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133-\230\167\189\228\189\141\231\188\150\232\190\145\231\149\140\233\157\162"
    }
  },
  SCCommon_ModelOperation_UIBP = {
    moduleName = "client.slua.umg.lobby.Left.SCCommon.SCCommon_ModelOperation_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/SocialLobby/SocialAndCollectionCommon/SCCommon_ModelOperation_UIBP.SCCommon_ModelOperation_UIBP",
    isMainUI = true,
    isSingleton = true,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133and\229\177\149\233\166\134-\230\168\161\229\158\139\233\128\137\228\184\173\230\147\141\228\189\156\228\186\140\231\186\167\231\149\140\233\157\162"
    }
  },
  SCCommon_PoseSelectMenu_UIBP = {
    moduleName = "client.slua.umg.lobby.Left.SCCommon.SCCommon_PoseSelectMenu_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/SocialLobby/SocialAndCollectionCommon/SCCommon_PoseSelectMenu_UIBP.SCCommon_PoseSelectMenu_UIBP",
    isMainUI = true,
    isSingleton = true,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133and\229\177\149\233\166\134-Avatar\230\168\161\229\158\139\233\128\137\228\184\173\230\147\141\228\189\1563\231\186\167\231\149\140\233\157\162\228\185\139\229\167\191\229\138\191\233\128\137\230\139\169\232\143\156\229\141\149"
    }
  },
  SCCommon_PetClotheSelectMenu_UIBP = {
    moduleName = "client.slua.umg.lobby.Left.SCCommon.SCCommon_PetClotheSelectMenu_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/SocialLobby/SocialAndCollectionCommon/SCCommon_PetClotheSelectMenu_UIBP.SCCommon_PetClotheSelectMenu_UIBP",
    isMainUI = true,
    isSingleton = true,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133and\229\177\149\233\166\134-\229\174\160\231\137\169\230\168\161\229\158\139\233\128\137\228\184\173\230\147\141\228\189\1563\231\186\167\231\149\140\233\157\162\228\185\139\229\174\160\231\137\169\230\156\141\232\163\133\233\128\137\230\139\169\232\143\156\229\141\149"
    }
  },
  lobby_social_roleInfo_tag = {
    keyName = "lobby_social_roleInfo_tag",
    moduleName = "client.slua.umg.lobby.Left.lobby_social_roleInfo_tag",
    path = "/Game/UMG/UI_BP/RoleInfo/Popup/RoleInfo_Popup_CardLabel_UIBP.RoleInfo_Popup_CardLabel_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\186\164\229\143\139\229\144\141\231\137\135-\233\128\137\230\139\169\230\160\135\231\173\190"
    }
  },
  Lobby_Mid_Bubble_Shop_UIBP = {
    keyName = "Lobby_Mid_Bubble_Shop_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Bubble.Lobby_Mid_Bubble_Shop_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Bubble/Lobby_Mid_Bubble_Shop_UIBP.Lobby_Mid_Bubble_Shop_UIBP",
    asy = true,
    uiStat = {
      name = "\230\150\176\231\137\136\229\164\167\229\142\133\229\149\134\229\159\142\230\176\148\230\179\161"
    }
  },
  Lobby_Mid_Bubble_AD_UIBP = {
    keyName = "Lobby_Mid_Bubble_AD_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Bubble.Lobby_Mid_Bubble_AD_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/AdPieX_Ad.AdPieX_Ad",
    isMainUI = false,
    uiStat = {
      name = "\229\164\167\229\142\133\229\185\191\229\145\138\230\176\148\230\179\161\229\133\165\229\143\163\239\188\136\232\147\157\230\180\158\231\137\136\239\188\137"
    }
  },
  new_banner_list_page = {
    keyName = "new_banner_list_page",
    moduleName = "client.slua.umg.lobby.Mid.FoldPage.new_banner_list_page",
    path = "/Game/Mod/Lobby/Base/Mid/Lobby_Mid_Banner_NewFoldpage_UIBP.Lobby_Mid_Banner_NewFoldpage_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\228\184\173\233\131\168-\229\185\191\229\145\138\230\160\143\230\137\169\229\177\149"
    }
  },
  Lobby_Mid_Binner_More_UIBP = {
    keyName = "Lobby_Mid_Binner_More_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_Binner_More_UIBP",
    path = "/Game/Mod/Lobby/Base/Mid/Lobby_Mid_Bnner_More250_UIBP.Lobby_Mid_Bnner_More250_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\228\184\173\233\151\180-BannerMore"
    },
    isMainUI = false
  },
  Lobby_Mid_Match_Center_Entry_UIBP = {
    keyName = "Lobby_Mid_Match_Center_Entry_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_Match_Center_Entry_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Mid_MatchCenter_Entry_UIBP.Lobby_Mid_MatchCenter_Entry_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\228\184\173\233\151\180--Lobby_Mid_Match_Center_Entry_UIBP"
    },
    isMainUI = false,
    isSingleton = false
  },
  Lobby_Mid_Tips_SocialIsland_Mentor_UIBP = {
    keyName = "Lobby_Mid_Tips_SocialIsland_Mentor_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Tips.Lobby_Mid_Tips_SocialIsland_Mentor_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Tips/Lobby_Mid_Tips_SocialIsland_Mentor_UIBP.Lobby_Mid_Tips_SocialIsland_Mentor_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\228\184\173\233\151\180--Lobby_Mid_MatchCenter_Entry_UIBP"
    },
    isSingleton = false
  },
  Lobby_Mid_PMGC_UIBP = {
    keyName = "Lobby_Mid_PMGC_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_PMGC_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Item/Lobby_Main_PMGC_UIBP.Lobby_Main_PMGC_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\228\184\173\233\151\180-PMGC\229\133\165\229\143\163"
    },
    isMainUI = false,
    isSingleton = false
  },
  lobby_doublecard_entrance = {
    keyName = "lobby_doublecard_entrance",
    moduleName = "client.slua.umg.lobby.lobby_doublecard_entrance",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Mid_DoubleCard_Entrance_UIBP.Lobby_Mid_DoubleCard_Entrance_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\143\140\229\128\141\229\141\161-\229\164\167\229\142\133\229\133\165\229\143\163"
    }
  },
  lobby_peakgame_doublecard_entrance = {
    keyName = "lobby_peakgame_doublecard_entrance",
    moduleName = "client.slua.umg.lobby.lobby_doublecard_entrance",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_PekGame_DoubleCard_Entrance_UIBP.Lobby_PekGame_DoubleCard_Entrance_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\143\140\229\128\141\229\141\161-\229\164\167\229\142\133\229\133\165\229\143\163"
    }
  },
  lobby_doublecard_buff_panel = {
    keyName = "lobby_doublecard_buff_panel",
    moduleName = "client.slua.umg.lobby.lobby_doublecard_buff_panel",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Mid_DoubleCard_Buff_Panel_UIBP.Lobby_Mid_DoubleCard_Buff_Panel_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\143\140\229\128\141\229\141\161-\229\177\149\231\164\186\229\144\132\231\167\141\230\143\144\231\164\186\231\149\140\233\157\162"
    }
  },
  MainCity_Mid_DoubleCard_Buff_Panel_UIBP = {
    keyName = "MainCity_Mid_DoubleCard_Buff_Panel_UIBP",
    moduleName = "client.slua.umg.lobby.lobby_doublecard_buff_panel",
    path = "/Game/Mod/MainCity/BluePrints/UI/Common/Tips/MainCity_Mid_DoubleCard_Buff_Panel_UIBP.MainCity_Mid_DoubleCard_Buff_Panel_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\229\143\140\229\128\141\229\141\161-\229\177\149\231\164\186\229\144\132\231\167\141\230\143\144\231\164\186\231\149\140\233\157\162"
    }
  },
  Lobby_Left_Couple_UIBP = {
    keyName = "Lobby_Left_Couple_UIBP",
    moduleName = "client.slua.umg.lobby.Left.Lobby_Left_Couple_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Left/Lobby_Left_Couple_UIBP.Lobby_Left_Couple_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\230\144\173\230\161\163\229\144\141\231\137\135"
    },
    isSingleton = false
  },
  lobby_social_fashion_bag = {
    keyName = "lobby_social_fashion_bag",
    moduleName = "client.slua.umg.lobby.Left.lobby_social_fashion_bag",
    path = "/Game/UMG/UI_BP/Lobby/Left/FashionBagSwitchSocial.FashionBagSwitchSocial",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133-\232\131\140\229\140\133"
    }
  },
  lobby_social_fashion_bag2 = {
    keyName = "lobby_social_fashion_bag2",
    moduleName = "client.slua.umg.lobby.Left.lobby_social_fashion_bag2",
    path = "/Game/UMG/UI_BP/Lobby/Left/FashionBagSwitchSocial2.FashionBagSwitchSocial2",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133-\232\131\140\229\140\1332"
    }
  },
  lobby_bottom_right_uibp = {
    keyName = "lobby_bottom_right_uibp",
    moduleName = "client.slua.umg.lobby.Main.lobby_bottom_right_uibp",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Bottom_right_UIBP.Lobby_Bottom_right_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\232\161\168\230\131\133\229\174\160\231\137\169\232\138\130\231\130\185"
    },
    isSingleton = false
  },
  lobby_news = {
    keyName = "lobby_news",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_News",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Mid_News.Lobby_Mid_News",
    uiStat = {name = "News\229\155\190\230\160\135"},
    isSingleton = false
  },
  Lobby_Mid_CarOther_UIBP = {
    keyName = "Lobby_Mid_CarOther_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_CarOther_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Mid_CarOther_UIBP.Lobby_Mid_CarOther_UIBP",
    uiStat = {
      name = "\229\156\163\232\163\133-\228\184\187\231\149\140\233\157\162"
    },
    zOrder = 1,
    isMainUI = false
  },
  Lobby_Mid_QMsg_Item_UIBP = {
    keyName = "Lobby_Mid_QMsg_Item_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_QMsg_Item_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Item/Lobby_Mid_QMsg_Item_UIBP.Lobby_Mid_QMsg_Item_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\229\191\171\230\141\183\232\129\138\229\164\169"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  Lobby_Mid_Vehicle_Item_UIBP = {
    keyName = "Lobby_Mid_Vehicle_Item_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_Vehicle_Item_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Item/Lobby_Mid_Vehicle_Item_UIBP.Lobby_Mid_Vehicle_Item_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\231\187\132\233\152\159\233\128\137\230\139\169\232\189\189\229\133\183\229\177\149\231\164\186"
    }
  },
  Lobby_DirectPurchase_LimitedTimeGiftSet = {
    keyName = "Lobby_DirectPurchase_LimitedTimeGiftSet",
    moduleName = "client.slua.umg.recharge.giftset.Lobby_DirectPurchase_LimitedTimeGiftSet",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/LimtedPurchase/Lobby_DirectPurchase_LimitedTimeGiftSet.Lobby_DirectPurchase_LimitedTimeGiftSet",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\164\188\229\140\133\229\149\134\229\186\151-\233\153\144\230\151\182\231\164\188\229\140\133"
    }
  },
  ui_recharge_good_item = {
    keyName = "ui_recharge_good_item",
    moduleName = "client.slua.umg.recharge.ui_recharge_good_item",
    path = "/Game/Mod/Lobby/Base/SpecialOffer/Item/Lobby_Store_item_UIBP.Lobby_Store_item_UIBP",
    isSingleton = false,
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.item_pool,
    uiStat = {
      name = "\229\133\133\229\128\188-\229\133\133\229\128\188\231\137\169\229\147\129item"
    }
  },
  ui_ugc_recharge_good_item = {
    keyName = "ui_ugc_recharge_good_item",
    moduleName = "client.slua.umg.recharge.ui_ugc_recharge_good_item",
    path = "/Game/Mod/Lobby/Base/SpecialOffer/Item/Lobby_Store_item_UIBP.Lobby_Store_item_UIBP",
    isSingleton = false,
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.item_pool,
    uiStat = {
      name = "\229\133\133\229\128\188-\229\133\133\229\128\188\231\137\169\229\147\129item-WOW"
    }
  },
  Lobby_Mid_Tips = {
    keyName = "Lobby_Mid_Tips",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_Tips",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Tips/Lobby_Mid_Tips_PartnerReadiness_UIBP.Lobby_Mid_Tips_PartnerReadiness_UIBP",
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\229\164\167\229\142\133tips"
    },
    isSingleton = false
  },
  Lobby_Care_Tips_UIBP = {
    keyName = "Lobby_Care_Tips_UIBP",
    moduleName = "client.slua.umg.lobby.Lobby_Care_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Lobby_Care_Tips_UIBP.Lobby_Care_Tips_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176\230\176\148\230\179\161"
    }
  },
  ui_chat_language_select = {
    keyName = "ui_chat_language_select",
    moduleName = "client.slua.umg.lobby_chat.ui_chat_language_select",
    path = "/Game/UMG/UI_BP/LobbyChat/SelectLanguage_BP.SelectLanguage_BP",
    uiStat = {
      name = "\232\129\138\229\164\169\232\175\173\232\168\128\233\128\137\230\139\169"
    }
  },
  ui_match_language_select = {
    keyName = "ui_match_language_select",
    moduleName = "client.slua.umg.lobby_chat.ui_match_language_select",
    path = "/Game/UMG/UI_BP/LobbyChat/SelectLanguage_Match_BP.SelectLanguage_Match_BP",
    uiStat = {
      name = "\229\140\185\233\133\141-\232\175\173\232\168\128\233\128\137\230\139\169"
    }
  },
  ui_complaint_lobby = {
    keyName = "ui_complaint_lobby",
    moduleName = "client.slua.umg.complaint.ui_complaint_lobby",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Item_UIBP2.Inform_Item_UIBP2",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\229\164\167\229\142\133"
    },
    isSingleton = false
  },
  lobby_report_bug = {
    keyName = "lobby_report_bug",
    moduleName = "client.slua.umg.report_error.lobby_report_bug",
    path = "/Game/UMG/UI_BP/PopupNotice/LobbyReportBug_UIBP.LobbyReportBug_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\230\138\165\233\148\153"
    }
  },
  Lobby_RoleInfo_PopularityShowDown_Report_Popup_UIBP = {
    keyName = "Lobby_RoleInfo_PopularityShowDown_Report_Popup_UIBP",
    moduleName = "client.slua.umg.popular_gift_pk.Lobby_RoleInfo_PopularityShowDown_Report_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Lobby_RoleInfo_PopularityShowDown_Report_Popup_UIBP.Lobby_RoleInfo_PopularityShowDown_Report_Popup_UIBP",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\228\186\186\230\176\148\229\175\185\229\134\179PK"
    }
  },
  LevelUp_Share = {
    keyName = "LevelUp_Share",
    moduleName = "client.slua.umg.shareChild.share_levelUp",
    path = "/Game/UMG/UI_BP/Lobby/ShareLevelUp_UIBP.ShareLevelUp_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\136\134\228\186\171-\229\141\135\231\186\167"
    }
  },
  Person_Share = {
    keyName = "Person_Share",
    moduleName = "client.slua.umg.shareChild.share_person",
    path = "/Game/UMG/UI_BP/Lobby/Sharerecord_UIBP.Sharerecord_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\136\134\228\186\171-\228\184\170\228\186\186\232\175\166\230\131\133"
    }
  },
  Lobby_Team_competition_Invite_UIBP = {
    keyName = "Lobby_Team_competition_Invite_UIBP",
    moduleName = "client.slua.umg.LoginLoading.Team_competition.Lobby_Team_competition_Invite_UIBP",
    path = "/Game/UMG/UI_BP/LoginLoading/Team_competition/Lobby_Team_competition_Invite_UIBP.Lobby_Team_competition_Invite_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "solo-\233\148\129\229\177\143\231\173\137\229\190\133"
    }
  },
  Lobby_Team_competition1v1_UIBP = {
    keyName = "Lobby_Team_competition1v1_UIBP",
    moduleName = "client.slua.umg.LoginLoading.Team_competition.Lobby_Team_competition1v1_UIBP",
    path = "/Game/UMG/UI_BP/LoginLoading/Team_competition/Lobby_Team_competition1v1_UIBP.Lobby_Team_competition1v1_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    loadFromPool = EUIConfigPoolType.None,
    closeOnSwitch = false,
    zOrder = EFixedZOrder.TopZOrder,
    containerName = UIContainers.Top,
    uiStat = {
      name = "solo-loading"
    }
  },
  Lobby_GoldSpin_Wing_UIBP = {
    keyName = "Lobby_GoldSpin_Wing_UIBP",
    moduleName = "client.slua.umg.team.Lobby_GoldSpin_Wing_UIBP",
    isSingleton = false,
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_GoldSpin_Wing_UIBP.Lobby_GoldSpin_Wing_UIBP",
    uiStat = {
      name = "\233\135\145\232\163\133\229\133\177\228\186\171\230\139\150\230\139\189UI"
    }
  },
  team_extra_main = {
    keyName = "team_extra_main",
    moduleName = "client.slua.umg.team.team_extra.team_extra_main",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_8v8_UIBP.Lobby_Main_8v8_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\164\167\229\142\1338\228\186\186\231\187\132\233\152\159-\233\152\159\228\188\141\229\136\151\232\161\168"
    }
  },
  Lobby_Main_ThemeDownloadUI_UIBP = {
    keyName = "Lobby_Main_ThemeDownloadUI_UIBP",
    moduleName = "client.slua.umg.lobby.Main.Item.Lobby_Main_ThemeDownloadUI_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_ThemeDownloadUI_UIBP.Lobby_Main_ThemeDownloadUI_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\164\167\229\142\133\228\184\187\231\149\140\233\157\162-\228\184\187\233\162\152\228\184\139\232\189\189ui"
    }
  },
  team_extra_member_item = {
    keyName = "team_extra_member_item",
    moduleName = "client.slua.umg.team.team_extra.team_extra_member_item",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_8v8_Item_UIBP.Lobby_Main_8v8_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\164\167\229\142\1338\228\186\186\231\187\132\233\152\159-\233\152\159\228\188\141\230\136\144\229\145\152Item"
    }
  },
  ui_chat_emoji = {
    keyName = "ui_chat_emoji",
    moduleName = "client.slua.umg.lobby_chat.ui_chat_emoji",
    path = "/Game/UMG/UI_BP/Moment/Item/Moment_Reply_Emoji_UIBP.Moment_Reply_Emoji_UIBP",
    isSingleton = false,
    isMainUI = false
  },
  plot_activity_main = {
    keyName = "plot_activity_main",
    moduleName = "client.slua.umg.plot.plot_activity_main",
    path = "/Game/UMG/UI_BP/Lobby_Activity/PlotActivity_JK/PlotActivity_Main_UIBP.PlotActivity_Main_UIBP",
    uiStat = {
      name = "\229\137\167\230\131\133\230\180\187\229\138\168-\228\184\187\231\149\140\233\157\162"
    }
  },
  SpeechToTextLobby = {
    keyName = "SpeechToTextLobby",
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.SpeechToTextUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/SpeechToText_UIBP.SpeechToText_UIBP",
    uiStat = {
      name = "\232\175\173\233\159\179\232\189\172\230\150\135\229\173\151\233\157\162\230\157\191"
    },
    containerName = UIContainers.Default,
    closeOnHide = false,
    isSingleton = true
  },
  Lobby_RoleInfo_IntimateRelationship_Interact_Item_02_UIBP = {
    keyName = "Lobby_RoleInfo_IntimateRelationship_Interact_Item_02_UIBP",
    moduleName = "client.slua.umg.PersonSpace.item.Lobby_RoleInfo_IntimateRelationship_Interact_Item_02_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/item/Lobby_RoleInfo_IntimateRelationship_Interact_Item_02_UIBP.Lobby_RoleInfo_IntimateRelationship_Interact_Item_02_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\164\154\228\186\186\228\186\178\229\175\134\229\133\179\231\179\187-\229\144\141\231\137\140\230\161\134"
    }
  },
  lobby_mini_tv = {
    keyName = "lobby_mini_tv",
    moduleName = "client.slua.umg.mini_tv.lobby_mini_tv",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Mid_MiniTv_UIBP.Lobby_Mid_MiniTv_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\231\148\181\232\167\134\230\156\186\228\186\186"
    },
    containerName = UIContainers.Bottom,
    isMainUI = false
  },
  ui_chat_share_replay = {
    keyName = "ui_chat_share_replay",
    moduleName = "client.slua.umg.lobby_chat.ui_chat_share_replay",
    path = "/Game/UMG/UI_BP/RoleInfo/ChatShareReplay_UIBP.ChatShareReplay_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\136\134\228\186\171\231\178\190\229\189\169\230\151\182\229\136\187\231\149\140\233\157\162-\230\136\144\229\176\177\229\188\185\231\170\151\233\161\181\231\173\190\228\184\139"
    }
  },
  Lobby_Mid_DoubleCard_Buff_Item_UIBP = {
    keyName = "Lobby_Mid_DoubleCard_Buff_Item_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Item.Lobby_Mid_DoubleCard_Buff_Item_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Item/Lobby_Mid_DoubleCard_Buff_Item_UIBP.Lobby_Mid_DoubleCard_Buff_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\229\164\167\229\142\133\231\155\190\231\137\140Tips-\229\173\144Item"
    }
  },
  Lobby_OB_UIBP = {
    keyName = "Lobby_OB_UIBP",
    moduleName = "client.slua.umg.lobby.PCOB.Lobby_OB_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_OB/Lobby_OB_UIBP.Lobby_OB_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "OB\229\164\167\229\142\133\233\135\141\230\158\132"
    }
  },
  Lobby_OB_ReplayList_UIBP = {
    keyName = "Lobby_OB_ReplayList_UIBP",
    moduleName = "client.slua.umg.lobby.PCOB.Lobby_ReplayList_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_OB/Lobby_OB_ReplayList_BP.Lobby_OB_ReplayList_BP",
    uiStat = {
      name = "OB\229\164\167\229\142\133\229\174\158\230\151\182\232\167\130\230\136\152\229\188\185\231\170\151"
    }
  },
  Lobby_OB_ReplayListMode_UIBP = {
    keyName = "Lobby_OB_ReplayListMode_UIBP",
    moduleName = "client.slua.umg.lobby.PCOB.Lobby_ReplayListMode_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_OB/Lobby_OB_ReplayMode_BP.Lobby_OB_ReplayMode_BP",
    uiStat = {
      name = "OB\229\164\167\229\142\133\229\155\158\230\148\190\230\168\161\229\188\143\229\188\185\231\170\151"
    }
  },
  OB_Replay_PlayVideoInfo_UIBP = {
    keyName = "OB_Replay_PlayVideoInfo_UIBP",
    moduleName = "client.slua.umg.lobby.PCOB.OB_Replay_PlayVideoInfo_UIBP",
    path = "/Game/BluePrints/UI/OBUI/ReplayUI/OB_ReplayUI_PlayVideoInfo_UIBP.OB_ReplayUI_PlayVideoInfo_UIBP",
    uiStat = {
      name = "OB\229\155\158\230\148\190\230\168\161\229\188\143\232\167\134\233\162\145\230\146\173\230\148\190\229\153\168"
    }
  },
  OB_Replay_TimeTips_UIBP = {
    keyName = "OB_Replay_TimeTips_UIBP",
    moduleName = "client.slua.umg.lobby.PCOB.OB_Replay_TimeTips_UIBP",
    path = "/Game/BluePrints/UI/OBUI/ReplayUI/Item/OB_ReplayUI_VideoList_Item2_UIBP.OB_ReplayUI_VideoList_Item2_UIBP",
    uiStat = {
      name = "OB\229\155\158\230\148\190\230\168\161\229\188\143-\230\151\182\233\151\180\230\143\144\231\164\186"
    }
  },
  OB_SkipTimeline_Popups_UIBP = {
    keyName = "OB_SkipTimeline_Popups_UIBP",
    moduleName = "client.slua.umg.lobby.PCOB.OB_SkipTimeline_Popups_UIBP",
    path = "/Game/BluePrints/UI/OBUI/ReplayUI/OB_SkipTimeline_Popups_UIBP.OB_SkipTimeline_Popups_UIBP",
    uiStat = {
      name = "OB\229\155\158\230\148\190\230\168\161\229\188\143\232\167\134\233\162\145\230\146\173\230\148\190\229\153\168"
    }
  },
  FADE_UIBP = {
    keyName = "FADE_UIBP",
    moduleName = "client.slua.umg.obresults.slua_fade",
    path = "/Game/UMG/UI_BP/Lobby/Fade_UIBP_2.Fade_UIBP_2",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\229\133\168\229\177\143\233\187\145\232\137\178\233\129\174\231\189\169\230\183\161\229\133\165\230\149\136\230\158\156"
    },
    asy = true
  },
  Sharerecord_Personal_UIBP_New02 = {
    keyName = "Sharerecord_Personal_UIBP_New02",
    moduleName = "client.slua.umg.shareChild.Sharerecord_Personal_UIBP_New02",
    path = "/Game/UMG/UI_BP/Lobby/Sharerecord_SingleBureau02_UIBP_New.Sharerecord_SingleBureau02_UIBP_New",
    uiStat = {
      name = "4.\231\187\147\231\174\151\229\136\134\228\186\171-\231\187\147\231\174\151-\228\184\170\228\186\186\230\149\176\230\141\174"
    }
  },
  Sharerecord_SingleBureau_UIBP_New = {
    keyName = "Sharerecord_SingleBureau_UIBP_New",
    moduleName = "client.slua.umg.shareChild.Sharerecord_SingleBureau_UIBP_New",
    path = "/Game/UMG/UI_BP/Lobby/Sharerecord_SingleBureau_UIBP_New.Sharerecord_SingleBureau_UIBP_New",
    uiStat = {
      name = "5.\231\187\147\231\174\151\229\136\134\228\186\171-\229\164\167\229\142\133-\228\184\170\228\186\186\230\136\152\231\187\169"
    }
  },
  Sharerecord_Personal_UIBP_New = {
    keyName = "Sharerecord_Personal_UIBP_New",
    moduleName = "client.slua.umg.shareChild.Sharerecord_Personal_UIBP_New",
    path = "/Game/UMG/UI_BP/Lobby/Sharerecord_Personal_UIBP_New.Sharerecord_Personal_UIBP_New",
    uiStat = {
      name = "6.\231\187\147\231\174\151\229\136\134\228\186\171-\228\184\170\228\186\186\230\149\176\230\141\174"
    }
  },
  Sharerecord_History_Personal_UIBP_New = {
    keyName = "Sharerecord_History_Personal_UIBP_New",
    moduleName = "client.slua.umg.shareChild.Sharerecord_History_Personal_UIBP_New",
    path = "/Game/UMG/UI_BP/Lobby/Sharerecord_Personal_UIBP_New.Sharerecord_Personal_UIBP_New",
    uiStat = {
      name = "7.\231\187\147\231\174\151\229\136\134\228\186\171-\229\142\134\229\143\178\230\136\152\231\187\169-\228\184\170\228\186\186\230\149\176\230\141\174(\232\128\129)"
    }
  },
  Sharerecord_History_Personal_UIBP_New02 = {
    keyName = "Sharerecord_History_Personal_UIBP_New02",
    moduleName = "client.slua.umg.shareChild.Sharerecord_History_Personal_UIBP_New02",
    path = "/Game/UMG/UI_BP/Lobby/Sharerecord_SingleBureau02_UIBP_New.Sharerecord_SingleBureau02_UIBP_New",
    uiStat = {
      name = "8.\231\187\147\231\174\151\229\136\134\228\186\171-\229\142\134\229\143\178\230\136\152\231\187\169-\228\184\170\228\186\186\230\149\176\230\141\174"
    }
  },
  Lobby_RoleInfo_Card_Share_UIBP = {
    keyName = "Lobby_RoleInfo_Card_Share_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Card.Lobby_RoleInfo_Card_Share_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Card_Share_UIBP.Lobby_RoleInfo_Card_Share_UIBP",
    uiStat = {
      name = "\229\136\134\228\186\171-\229\164\167\229\142\133-\228\184\170\228\186\186\229\144\141\231\137\135"
    }
  },
  Lobby_Recruit_Card_Edit_UIBP = {
    keyName = "Lobby_Recruit_Card_Edit_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_Recruit_Card_Edit_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_Recruit_Card_Edit_UIBP.Lobby_Recruit_Card_Edit_UIBP",
    uiStat = {
      name = "\231\188\150\232\190\145\230\139\155\229\139\159\229\144\141\231\137\135"
    }
  },
  Lobby_RoleInfo_Birthday_Item = {
    keyName = "Lobby_RoleInfo_Birthday_Item",
    moduleName = "client.slua.umg.PersonSpace.PopUpItem.Lobby_RoleInfo_Birthday_Item",
    path = "/Game/UMG/UI_BP/PersonSpace/PopUpItem/Lobby_RoleInfo_Birthday_Item.Lobby_RoleInfo_Birthday_Item",
    isSingleton = false,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175\231\187\132\228\187\182\226\128\148\231\148\159\230\151\165\228\191\161\230\129\175"
    }
  },
  Lobby_RoleInfo_LBS_Item = {
    keyName = "Lobby_RoleInfo_LBS_Item",
    moduleName = "client.slua.umg.PersonSpace.PopUpItem.Lobby_RoleInfo_LBS_Item",
    path = "/Game/UMG/UI_BP/PersonSpace/PopUpItem/Lobby_RoleInfo_LBS_Item.Lobby_RoleInfo_LBS_Item",
    isSingleton = false,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175\231\187\132\228\187\182\226\128\148\228\189\141\231\189\174\228\191\161\230\129\175"
    }
  },
  Lobby_RoleInfo_MyLabel_Item = {
    keyName = "Lobby_RoleInfo_MyLabel_Item",
    moduleName = "client.slua.umg.PersonSpace.PopUpItem.Lobby_RoleInfo_MyLabel_Item",
    path = "/Game/UMG/UI_BP/PersonSpace/PopUpItem/Lobby_RoleInfo_MyLabel_Item.Lobby_RoleInfo_MyLabel_Item",
    isSingleton = false,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175\231\187\132\228\187\182\226\128\148\228\184\170\230\128\167\231\173\190\229\144\141"
    }
  },
  Lobby_RoleInfo_MySign_Item = {
    keyName = "Lobby_RoleInfo_MySign_Item",
    moduleName = "client.slua.umg.PersonSpace.PopUpItem.Lobby_RoleInfo_MySign_Item",
    path = "/Game/UMG/UI_BP/PersonSpace/PopUpItem/Lobby_RoleInfo_MySign_Item.Lobby_RoleInfo_MySign_Item",
    isSingleton = false,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175\231\187\132\228\187\182\226\128\148\230\136\145\231\154\132\230\160\135\231\173\190"
    }
  },
  Lobby_RoleInfo_TwoCombox_Item = {
    keyName = "Lobby_RoleInfo_TwoCombox_Item",
    moduleName = "client.slua.umg.PersonSpace.PopUpItem.Lobby_RoleInfo_TwoCombox_Item",
    path = "/Game/UMG/UI_BP/PersonSpace/PopUpItem/Lobby_RoleInfo_TwoCombox_Item.Lobby_RoleInfo_TwoCombox_Item",
    isSingleton = false,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175\231\187\132\228\187\182\226\128\1482\229\136\151\232\161\168"
    }
  },
  Lobby_RoleInfo_Sex_Item = {
    keyName = "Lobby_RoleInfo_Sex_Item",
    moduleName = "client.slua.umg.PersonSpace.PopUpItem.Lobby_RoleInfo_Sex_Item",
    path = "/Game/UMG/UI_BP/PersonSpace/PopUpItem/Lobby_RoleInfo_Sex_Item.Lobby_RoleInfo_Sex_Item",
    isSingleton = false,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175\231\187\132\228\187\182\226\128\148\230\128\167\229\136\171"
    }
  },
  Lobby_RoleInfo_FourCheckbox_Item = {
    keyName = "Lobby_RoleInfo_FourCheckbox_Item",
    moduleName = "client.slua.umg.PersonSpace.PopUpItem.Lobby_RoleInfo_FourCheckbox_Item",
    path = "/Game/UMG/UI_BP/PersonSpace/PopUpItem/Lobby_RoleInfo_FourCheckbox_Item.Lobby_RoleInfo_FourCheckbox_Item",
    isSingleton = false,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175\231\187\132\228\187\182\226\128\1484\233\128\137"
    }
  },
  Lobby_RoleInfo_ScreenShot_Item = {
    keyName = "Lobby_RoleInfo_ScreenShot_Item",
    moduleName = "client.slua.umg.PersonSpace.PopUpItem.Lobby_RoleInfo_ScreenShot_Item",
    path = "/Game/UMG/UI_BP/PersonSpace/PopUpItem/Lobby_RoleInfo_ScreenShot_Item.Lobby_RoleInfo_ScreenShot_Item",
    isSingleton = false,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175\231\187\132\228\187\182\226\128\148\230\136\170\229\155\190"
    }
  },
  Lobby_RoleInfo_Intimacy_List_UIBP = {
    keyName = "Lobby_RoleInfo_Intimacy_List_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_Intimacy_List_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Intimacy_List_UIBP.Lobby_RoleInfo_Intimacy_List_UIBP",
    uiStat = {
      name = "\230\139\155\229\139\159\230\142\168\232\141\144\230\159\165\231\156\139"
    }
  },
  Lobby_RoleInfo_Share_UIBP = {
    keyName = "Lobby_RoleInfo_Share_UIBP",
    moduleName = "client.slua.umg.person_space.Lobby_RoleInfo_Share_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Share01_UIBP.Lobby_RoleInfo_Share01_UIBP",
    asy = true,
    uiStat = {
      name = "\228\186\178\229\175\134\229\133\179\231\179\187\229\136\134\228\186\171"
    }
  },
  Lobby_CreatRole = {
    keyName = "Lobby_CreatRole",
    moduleName = "client.slua.umg.NewCreateRole.Lobby_CreatRoleNew_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Lobby_CreatRoleNew_UIBP.Lobby_CreatRoleNew_UIBP",
    asy = true,
    uiStat = {
      name = "\229\136\155\229\187\186\232\167\146\232\137\178"
    }
  },
  Lobby_AvatarAnim_UIBP = {
    keyName = "Lobby_AvatarAnim_UIBP",
    moduleName = "client.slua.umg.NewCreateRole.Lobby_AvatarAnim_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Lobby_AvatarAnim_UIBP.Lobby_AvatarAnim_UIBP",
    uiStat = {
      name = "\229\136\155\229\187\186\232\167\146\232\137\178-\229\138\168\231\148\187\231\149\140\233\157\162"
    }
  },
  ResetPurchaseNew_UIBP = {
    keyName = "ResetPurchaseNew_UIBP",
    moduleName = "client.slua.umg.NewCreateRole.ResetPurchaseNew_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Item/ResetPurchaseNew_UIBP.ResetPurchaseNew_UIBP",
    uiStat = {
      name = "\229\136\155\229\187\186\232\167\146\232\137\178-\232\180\173\228\185\176"
    }
  },
  Lobby_Newbie_Guidance_Group = {
    keyName = "Lobby_Newbie_Guidance_Group",
    moduleName = "client.slua.umg.newbie_guide.Lobby_Newbie_Guidance_Group",
    path = "/Game/Mod/Lobby/Base/Newbie/Lobby_Newbie_Guidance_Group.Lobby_Newbie_Guidance_Group",
    asy = true,
    uiStat = {
      name = "\230\150\176\230\137\139\229\188\149\229\175\188-\230\143\144\231\164\1864\230\142\146"
    }
  },
  GM_WhitePoint = {
    keyName = "GM_WhitePoint",
    moduleName = "blacklist.slua.umg.lobby_gm.GM_WhitePoint",
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.Click_Animation,
    AndroidBackType = EAndroidBackType.Skip,
    path = "/Game/UMG/UI_BP/GM/GM_WhitePoint.GM_WhitePoint",
    uiStat = {
      name = "\229\164\167\229\142\133GM-\229\176\143\231\153\189\231\130\185"
    }
  },
  gm_float_buttons = {
    keyName = "gm_float_buttons",
    moduleName = "blacklist.slua.umg.lobby_gm.gm_float_buttons",
    path = "/Game/UMG/UI_BP/GM/GM_Float_Buttons.GM_Float_Buttons",
    uiStat = {
      name = "\229\164\167\229\142\133GM-GM\233\149\191\230\140\137\230\151\182\231\154\132\230\181\174\231\170\151\230\140\137\233\146\174"
    }
  },
  gm_cmd_bunch_popup = {
    keyName = "gm_cmd_bunch_popup",
    moduleName = "blacklist.slua.umg.lobby_gm.gm_cmd_bunch_popup",
    path = "/Game/UMG/UI_BP/GM/GM_Cmd_Bunch_Popup.GM_Cmd_Bunch_Popup",
    uiStat = {
      name = "\229\164\167\229\142\133GM-\230\140\135\228\187\164\233\155\134\229\188\185\231\170\151"
    }
  },
  gm_bunch_name_popup = {
    keyName = "gm_bunch_name_popup",
    moduleName = "blacklist.slua.umg.lobby_gm.gm_bunch_name_popup",
    path = "/Game/UMG/UI_BP/GM/GM_Bunch_Name_Popup_2.GM_Bunch_Name_Popup_2",
    uiStat = {
      name = "\229\164\167\229\142\133GM-\230\140\135\228\187\164\233\155\134\229\145\189\229\144\141\229\188\185\231\170\151"
    }
  },
  gm_circle_search_popup = {
    keyName = "gm_circle_search_popup",
    moduleName = "blacklist.slua.umg.lobby_gm.gm_circle_search_popup",
    path = "/Game/UMG/UI_BP/GM/GM_Circle_Search_UIBP.GM_Circle_Search_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133GM-\232\189\172\231\155\152\230\180\187\229\138\168\230\159\165\232\175\162\229\188\185\231\170\151"
    }
  },
  GM_PerUI = {
    keyName = "GM_PerUI",
    moduleName = "client.slua.umg.GM.GM_PerUI",
    path = "/Game/UMG/UI_BP/GM/GM_PerUI.GM_PerUI",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\164\167\229\142\133GM-\231\149\140\233\157\162GM"
    }
  },
  GM_PerUI_List = {
    keyName = "GM_PerUI_List",
    moduleName = "client.slua.umg.GM.GM_PerUI_List",
    path = "/Game/UMG/UI_BP/GM/GM_PerUI_List.GM_PerUI_List",
    zOrder = EFixedZOrder.Click_Animation,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\164\167\229\142\133GM-\231\149\140\233\157\162GM-\229\136\151\232\161\168"
    }
  },
  GM_UnbackPanel = {
    keyName = "GM_UnbackPanel",
    moduleName = "blacklist.slua.umg.lobby_gm.GM_LuckyUnback",
    jumpModuleID = BP_ENUM_MODULE_LUCKY_UNBACK,
    path = "/Game/Arts_UI/LuckyUnback/Temp/LuckyUnbackGm_UIBP.LuckyUnbackGm_UIBP",
    uiStat = {
      name = "\228\184\141\230\148\190\229\155\158GM\233\157\162\230\157\191"
    }
  },
  GM_FitImageComp = {
    keyName = "GM_FitImageComp",
    moduleName = "blacklist.slua.umg.lobby_gm.GM_FitImageComp",
    path = "/Game/UMG/UI_BP/GM/GM_FitImageComp.GM_FitImageComp"
  },
  gm_unit_testing = {
    keyName = "gm_unit_testing",
    moduleName = "blacklist.slua.umg.lobby_gm.gm_unit_testing",
    path = "/Game/UMG/UI_BP/GM/GM_Unit_Testing_BP.GM_Unit_Testing_BP"
  },
  gm_stream_test = {
    keyName = "gm_stream_test",
    moduleName = "blacklist.slua.umg.lobby_gm.gm_stream_test",
    path = "/Game/UMG/UI_BP/GM/GM_StreamTest_BP.GM_StreamTest_BP"
  },
  ChatVoice_UIBP = {
    keyName = "ChatVoice_UIBP",
    moduleName = "client.slua.umg.chat_voice.ChatVoice_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_ChatVoice_UIBP.Lobby_Main_ChatVoice_UIBP",
    uiStat = {
      "\232\175\173\233\159\179 - \228\184\187\231\187\132\228\187\182"
    },
    isSingleton = false
  },
  ChatVoiceCar_UIBP = {
    keyName = "ChatVoiceCar_UIBP",
    moduleName = "client.slua.umg.chat_voice.ChatVoiceCar_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Mid_CarOther_UIBP.Lobby_Mid_CarOther_UIBP",
    uiStat = {
      name = "\232\175\173\233\159\179 - \232\189\166\232\189\189\229\156\163\232\163\133\231\149\140\233\157\162"
    },
    asy = true,
    isSingleton = false
  },
  ChatRoomInvite_Popup_UIBP = {
    keyName = "ChatRoomInvite_Popup_UIBP",
    moduleName = "client.slua.umg.lobby_chat.chatroom.ChatRoomInvite_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/ChatRoomInvite_Popup_UIBP.ChatRoomInvite_Popup_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169-\232\129\138\229\164\169\229\174\164\233\130\128\232\175\183\231\149\140\233\157\162"
    }
  },
  Lobby_Main_Actor_Voice_UIBP = {
    keyName = "Lobby_Main_Actor_Voice_UIBP",
    moduleName = "client.slua.umg.lobby.Main.Lobby_Main_Actor_Voice_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Mid_QuickMessage_Qipao_UIBP.Lobby_Mid_QuickMessage_Qipao_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\228\184\187\231\149\140\233\157\162-\232\175\173\233\159\179\229\140\133\230\146\173\230\138\165UI"
    },
    isSingleton = false
  },
  Cross_Server_Popup = {
    keyName = "Cross_Server_Popup",
    moduleName = "client.slua.umg.lobby.Cross_Server_Popup",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_Popup_JK_UIBP.Lobby_Main_Popup_JK_UIBP",
    uiStat = {
      name = "\230\151\165\233\159\169-\232\183\168\230\156\141\229\140\185\233\133\141\229\188\185\231\170\151"
    }
  },
  AceMark_MakeUp_UIBP = {
    keyName = "AceMark_MakeUp_UIBP",
    moduleName = "client.slua.umg.ace_imprint.AceMark_MakeUp_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/ACEImprint/AceMark_MakeUp_UIBP.AceMark_MakeUp_UIBP",
    uiStat = {
      name = "\232\181\155\229\173\163-\229\141\176\232\174\176\232\161\165\229\129\191\231\149\140\233\157\162"
    }
  },
  Lobby_Lucky_Teammate_UIBP = {
    keyName = "Lobby_Lucky_Teammate_UIBP",
    moduleName = "client.slua.umg.lucky_star.Lobby_Lucky_Teammate_UIBP",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/Lobby_Lucky_Teammate_UIBP.Lobby_Lucky_Teammate_UIBP",
    uiStat = {
      name = "\229\184\184\233\169\187\231\166\143\230\152\159\231\179\187\231\187\159\231\149\140\233\157\162"
    }
  },
  ScrapGold_Popup_Award_UIBP = {
    keyName = "ScrapGold_Popup_Award_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.ScrapGold.Reward.ScrapGold_Popup_Award_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/ScrapGold/UIBP/ScrapGold_Popup_Award_UIBP.ScrapGold_Popup_Award_UIBP",
    uiStat = {
      name = "\233\135\145\231\162\142\231\137\135\230\138\189\229\165\150-\231\180\175\232\174\161\229\165\150\229\138\177\229\188\185\231\170\151"
    }
  },
  Preorder = {
    keyName = "Preorder",
    moduleName = "client.slua.umg.lobby_activity.SpinPreorder.SpinPreorderContainer",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/GoldSpinPreorder/GoldSpin_Preorder_UIBP.GoldSpin_Preorder_UIBP",
    uiStat = {
      name = "\232\189\172\231\155\152\233\162\132\232\180\173\230\180\187\229\138\168"
    }
  },
  GoldSpin_Preorder_Popup_UIBP = {
    keyName = "GoldSpin_Preorder_Popup_UIBP",
    moduleName = "client.slua.umg.lobby_activity.SpinPreorder.GoldSpin_Preorder_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/GoldSpinPreorder/Popup/GoldSpin_Preorder_Popup_UIBP.GoldSpin_Preorder_Popup_UIBP",
    uiStat = {
      name = "\232\189\172\231\155\152\233\162\132\232\180\173\229\133\145\230\141\162\229\188\185\231\170\151"
    }
  },
  GoldSpin_Preorder_Item_UIBP = {
    keyName = "GoldSpin_Preorder_Item_UIBP",
    moduleName = "client.slua.umg.lobby_activity.SpinPreorder.GoldSpin_Preorder_Item_UIBP",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/GoldSpinPreorder/Item/GoldSpin_Preorder_Item_UIBP.GoldSpin_Preorder_Item_UIBP",
    uiStat = {
      name = "\232\189\172\231\155\152\233\162\132\232\180\173\229\133\145\230\141\162\231\187\132\228\187\182"
    }
  },
  Lobby_RoleInfo_InteractRecord_UIBP = {
    keyName = "Lobby_RoleInfo_InteractRecord_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_InteractRecord_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_InteractRecord_UIBP.Lobby_RoleInfo_InteractRecord_UIBP",
    {
      name = "\229\165\189\229\143\139\228\186\146\229\138\168\232\174\176\229\189\149"
    }
  },
  Lobby_RoleInfo_InteractRecord_Share_UIBP = {
    keyName = "Lobby_RoleInfo_InteractRecord_Share_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_InteractRecord_Share_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_InteractRecord_Share_UIBP.Lobby_RoleInfo_InteractRecord_Share_UIBP",
    uiStat = {
      name = "\229\165\189\229\143\139\228\186\146\229\138\168\232\174\176\229\189\149 - \229\136\134\228\186\171"
    }
  },
  ChatSecurityRemind_UIBP = {
    keyName = "ChatSecurityRemind_UIBP",
    moduleName = "client.slua.umg.lobby_chat.ChatSecurityRemind_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/ChatSecurityRemind_UIBP.ChatSecurityRemind_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169\229\174\137\229\133\168\229\174\163\228\188\160"
    },
    isSingleton = false
  },
  Lobby_Left_PopularityGift_PK_UIBP = {
    keyName = "Lobby_Left_PopularityGift_PK_UIBP",
    moduleName = "client.slua.umg.popular_gift_pk.Lobby_Left_PopularityGift_PK_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Left/Lobby_Left_PopularityGift_PK_UIBP.Lobby_Left_PopularityGift_PK_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isMainUI = false,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133-\229\143\179\228\184\139\232\167\146\228\186\186\230\176\148\231\164\188\231\137\169pk\230\143\144\231\164\186"
    }
  },
  LobbyChat_SharePopup_UIBP = {
    keyName = "LobbyChat_SharePopup_UIBP",
    moduleName = "client.slua.umg.lobby_chat.LobbyChat_SharePopup_UIBP",
    path = "/Game/UMG/UI_BP/LobbyChat/LobbyChat_SharePopup_UIBP.LobbyChat_SharePopup_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169\229\136\134\228\186\171\229\188\185\231\170\151"
    }
  },
  Lobby_RoleInfo_Popularity_Settlement_UIBP = {
    keyName = "Lobby_RoleInfo_Popularity_Settlement_UIBP",
    moduleName = "client.slua.umg.popular_gift_pk.Lobby_RoleInfo_Popularity_Settlement_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Popularity_Settlement_UIBP.Lobby_RoleInfo_Popularity_Settlement_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\228\186\186\230\176\148\231\164\188\231\137\169pk-\231\187\147\231\174\151\231\149\140\233\157\162"
    }
  },
  Lobby_RoleInfo_Popularity_Confrontation_UIBP = {
    keyName = "Lobby_RoleInfo_Popularity_Confrontation_UIBP",
    moduleName = "client.slua.umg.popular_gift_pk.Lobby_RoleInfo_Popularity_Confrontation_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Popularity_Confrontation_UIBP.Lobby_RoleInfo_Popularity_Confrontation_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148PK-\230\138\165\229\144\141\233\161\181\233\157\162"
    }
  },
  Lobby_RoleInfo_AnnualCelebration_UIBP = {
    keyName = "Lobby_RoleInfo_AnnualCelebration_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_AnnualCelebration_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_AnnualCelebration_UIBP.Lobby_RoleInfo_AnnualCelebration_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148PK-\228\186\186\230\176\148\231\155\155\229\133\184-\230\138\165\229\144\141\233\161\181\233\157\162"
    }
  },
  Lobby_RoleInfo_PopularityGift_Description_UIBP = {
    keyName = "Lobby_RoleInfo_PopularityGift_Description_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Lobby_RoleInfo_PopularityGift_Description_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Lobby_RoleInfo_PopularityGift_Description_UIBP.Lobby_RoleInfo_PopularityGift_Description_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148PK-\228\186\186\230\176\148\231\155\155\229\133\184-\232\175\180\230\152\142\229\188\185\231\170\151"
    }
  },
  Popular_TeamPK_PkExplanation_UIBP = {
    keyName = "Popular_TeamPK_PkExplanation_UIBP",
    moduleName = "client.slua.umg.popular_team_pk.Popular_TeamPK_PkExplanation_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/PK_UI/PopUI/Popular_TeamPK_PkExplanation_UIBP.Popular_TeamPK_PkExplanation_UIBP",
    uiStat = {
      name = "\233\152\159\228\188\141PK-\231\142\169\230\179\149\232\175\180\230\152\142\229\188\185\231\170\151"
    }
  },
  Popular_TeamPK_Member_Detail_UIBP = {
    keyName = "Popular_TeamPK_Member_Detail_UIBP",
    moduleName = "client.slua.umg.popular_team_pk.Popular_TeamPK_Member_Detail_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/PK_UI/Popular_TeamPK_Member_Detail_UIBP.Popular_TeamPK_Member_Detail_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\152\159\228\188\141PK-\233\152\159\229\143\139\228\191\161\230\129\175\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  Lobby_RoleInfo_Leisure_Popup_UIBP = {
    keyName = "Lobby_RoleInfo_Leisure_Popup_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Leisure.Popup.Lobby_RoleInfo_Leisure_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Lobby_RoleInfo_PeakGame_Popup_UIBP.Lobby_RoleInfo_PeakGame_Popup_UIBP",
    uiStat = {
      name = "\228\188\145\233\151\178\232\181\155\229\173\163-\228\184\170\228\186\186\232\181\132\230\150\153\230\174\181\228\189\141\229\188\185\231\170\151"
    }
  },
  SportsCarSpinBackground = {
    keyName = "SportsCarSpinBackground",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.BackGround.SportsCarSpinBackgroundBase",
    path = "/Game/Arts_UI/LuckySpin/2700/Global/AstonMartin/AstonMartin_BG_1_UIBP.AstonMartin_BG_1_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\183\145\232\189\166\232\189\172\231\155\152-\232\131\140\230\153\175"
    }
  },
  SportsCarSpinLottery = {
    keyName = "SportsCarSpinLottery",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.Lottery.SportsCarSpinLotteryBase",
    path = "/Game/Arts_UI/LuckySpin/2700/Global/AstonMartin/AstonMartin_Lottery_UIBP_LOD0.AstonMartin_Lottery_UIBP_LOD0",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\183\145\232\189\166\232\189\172\231\155\152-\230\138\189\229\165\150\231\149\140\233\157\162"
    }
  },
  SportsCarSpinResult = {
    keyName = "SportsCarSpinResult",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.Result.SportsCarSpinResult",
    path = "/Game/Arts_UI/LuckySpin/2700/Global/AstonMartin/AstonMartin_Draw_Result_UIBP.AstonMartin_Draw_Result_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\183\145\232\189\166\232\189\172\231\155\152-\230\138\189\229\165\150\231\187\147\230\158\156"
    }
  },
  SportsCarSpinRebate = {
    keyName = "SportsCarSpinRebate",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.Result.SportsCarSpinRebate",
    path = "/Game/Arts_UI/LuckySpin/2900/Global/SportsCar290/SportsCar290_RebateTips_UIBP.SportsCar290_RebateTips_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\183\145\232\189\166\232\189\172\231\155\152-\230\138\189\229\165\150\229\164\177\232\180\165\229\185\184\232\191\144\232\191\148\229\136\169"
    }
  },
  SportsCarLotteryUpgrade = {
    keyName = "SportsCarLotteryUpgrade",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.MainScene.SportsCarLotteryUpgrade",
    path = "/Game/Arts_UI/LuckySpin/2900/Global/SportsCar290/SportsCar290_LotteryUpgrade_UIBP.SportsCar290_LotteryUpgrade_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\183\145\232\189\166\232\189\172\231\155\152-\232\183\145\232\189\166\230\138\189\229\165\150\229\141\135\231\186\167"
    }
  },
  SportsCarSpinBrand = {
    keyName = "SportsCarSpinBrand",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.Brand.SportsCarSpinBrand",
    path = "/Game/Arts_UI/LuckySpin/2700/Global/AstonMartin/AstonMartin_BrandOpen_UIBP.AstonMartin_BrandOpen_UIBP",
    asy = true,
    uiStat = {
      name = "\232\183\145\232\189\166\232\189\172\231\155\152-\229\147\129\231\137\140\229\188\128\229\156\186"
    }
  },
  SportsCarSpinAccelPad = {
    keyName = "SportsCarSpinAccelPad",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.AccelPad.SportsCarSpinAccelPad",
    path = "/Game/Arts_UI/LuckySpin/2700/Global/AstonMartin/AstonMartin_Accel_Pad_UIBP.AstonMartin_Accel_Pad_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      "\232\183\145\232\189\166\232\189\172\231\155\152-\229\138\160\233\128\159\228\186\164\228\186\146\233\157\162\230\157\191"
    }
  },
  SportsCarSpinLotteryGet = {
    keyName = "SportsCarSpinLotteryGet",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.Lottery.SportsCarSpinLotteryGet",
    path = "/Game/Arts_UI/LuckySpin/3100/Global/SportsCar310/SportsCar310_LotteryGet_Item.SportsCar310_LotteryGet_Item",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      "\232\183\145\232\189\166\232\189\172\231\155\152-\230\138\189\229\165\150\231\149\140\233\157\162-\233\162\134\229\165\150\233\157\162\230\157\191"
    }
  },
  SportsCarGet = {
    keyName = "SportsCarGet",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.Get.SportsCarGet",
    path = "/Game/Arts_UI/LuckySpin/2900/Global/SportsCar290/ShareAndGet/SportsCar290_Get_UIBP.SportsCar290_Get_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\183\145\232\189\166\230\129\173\229\150\156\232\142\183\229\190\151"
    }
  },
  SportsCarShareBase = {
    keyName = "SportsCarShareBase",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.Share.SportsCarShareBase",
    path = "/Game/Arts_UI/LuckySpin/2700/Global/AstonMartin/ShareAndGet/AstonMartin_Share_UIBP.AstonMartin_Share_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\233\152\182\230\162\175\232\189\172\231\155\152-\232\183\145\232\189\166\229\136\134\228\186\171"
    }
  },
  LightBoard_Set_UIBP = {
    keyName = "LightBoard_Set_UIBP",
    moduleName = "client.slua.umg.light_board.LightBoard_Set_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/LightBoard/LightBoard_Set_UIBP.LightBoard_Set_UIBP",
    uiStat = {
      name = "\231\187\132\233\152\159PK-\232\174\190\231\189\174\233\152\159\228\188\141\230\152\181\231\167\176"
    }
  },
  LightBoard_Rule_UIBP = {
    keyName = "LightBoard_Rule_UIBP",
    moduleName = "client.slua.umg.light_board.LightBoard_Rule_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/LightBoard/LightBoard_Rule_UIBP.LightBoard_Rule_UIBP",
    uiStat = {
      name = "\231\187\132\233\152\159PK-\231\129\175\231\137\140\232\167\132\229\136\153"
    }
  },
  LightBoard_Manage_UIBP = {
    keyName = "LightBoard_Manage_UIBP",
    moduleName = "client.slua.umg.light_board.LightBoard_Manage_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/LightBoard/LightBoard_Manage_UIBP.LightBoard_Manage_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\187\132\233\152\159PK-\231\129\175\231\137\140\231\174\161\231\144\134"
    }
  },
  Lobby_Mid_AdvertisementTask_UIBP = {
    keyName = "Lobby_Mid_AdvertisementTask_UIBP",
    moduleName = "client.slua.umg.lobby_activity.Advertisement.Lobby_Mid_AdvertisementTask_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Mid_AdvertisementTask_UIBP.Lobby_Mid_AdvertisementTask_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\185\191\229\145\138\229\138\159\232\131\189\239\188\136\229\164\167\229\142\133\239\188\137"
    }
  },
  SpecialOffer_Entrance_UIBP = {
    keyName = "SpecialOffer_Entrance_UIBP",
    moduleName = "client.slua.umg.lobby_activity.LobbyBubble.SpecialOffer_Entrance_UIBP",
    path = "/Game/Mod/Lobby/Base/SpecialOffer/SpecialOffer_Entrance_UIBP.SpecialOffer_Entrance_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\164\167\229\142\133\230\176\148\230\179\161\229\133\165\229\143\163"
    }
  },
  SpecialOffer_Tips_UIBP = {
    keyName = "SpecialOffer_Tips_UIBP",
    moduleName = "client.slua.umg.lobby_activity.LobbyBubble.SpecialOffer_Tips_UIBP",
    path = "/Game/Mod/Lobby/Base/SpecialOffer/SpecialOffer_Tips_UIBP.SpecialOffer_Tips_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\137\185\230\131\160-\230\176\148\230\179\161-\230\180\187\229\138\168\229\128\146\232\174\161\230\151\182"
    }
  },
  Lobby_Mid_Activity_Tips_UIBP = {
    keyName = "Lobby_Mid_Activity_Tips_UIBP",
    moduleName = "client.slua.umg.lobby_activity.LobbyBubble.Lobby_Mid_Activity_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Bubble/Lobby_Mid_Activity_Tips_UIBP.Lobby_Mid_Activity_Tips_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\164\167\229\142\133-\230\180\187\229\138\168-\230\176\148\230\179\161"
    }
  },
  Lobby_Mid_Bottom_Banner_UIBP = {
    keyName = "Lobby_Mid_Bottom_Banner_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Bubble.Lobby_Mid_Bottom_Banner_UIBP",
    path = "/Game/Mod/Lobby/Base/Mid/Bubble/Lobby_Mid_Bottom_Banner_UIBP.Lobby_Mid_Bottom_Banner_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\164\167\229\142\133-\228\184\173\233\131\168-\229\186\149\233\131\168\230\176\148\230\179\161banner"
    }
  },
  itemtips_panel_phome = {
    keyName = "itemtips_panel_phome",
    moduleName = "client.slua.umg.common.itemtips_panel_phome",
    containerName = UIContainers.Top,
    closeOnHide = false,
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_TaskTips_UIBP.PlanPH_Store_TaskTips_UIBP",
    asy = false,
    uiStat = {
      name = "\233\128\154\231\148\168\231\137\169\229\147\129\230\143\144\231\164\186 - PHome"
    }
  },
  FirstLuckyBackGuideTip = {
    keyName = "FirstLuckyBackGuideTip",
    moduleName = "client.slua.umg.lobby_activity.LuckySpin.TraitClassStyle.Supply.LuckyBackGuide.FirstLuckyBackGuideTip",
    path = "/Game/UMG/UI_BP/Common/NewFunction_Notes_UIBP.NewFunction_Notes_UIBP",
    uiStat = {
      name = "\230\148\190\229\155\158\232\189\172\231\155\152\229\188\149\229\175\188setp1"
    }
  },
  SecondLuckyBackGuideTip = {
    keyName = "SecondLuckyBackGuideTip",
    moduleName = "client.slua.umg.lobby_activity.LuckySpin.TraitClassStyle.Supply.LuckyBackGuide.SecondLuckyBackGuideTip",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyputbackTemplateNew/LukcyputbackTemplate_NewGuide_Tips_UIBP.LukcyputbackTemplate_NewGuide_Tips_UIBP",
    uiStat = {
      name = "\230\148\190\229\155\158\232\189\172\231\155\152\229\188\149\229\175\188setp2"
    }
  },
  ChatRoom_Set_Topic_UIBP = {
    keyName = "ChatRoom_Set_Topic_UIBP",
    moduleName = "client.slua.umg.lobby_chat.chatroom.ChatRoom_Set_Topic_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/ChatRoom/ChatRoom_Set_Topic_UIBP.ChatRoom_Set_Topic_UIBP",
    asy = true,
    uiStat = {
      name = "\232\129\138\229\164\169\229\174\164-\232\174\190\231\189\174\232\175\157\233\162\152"
    }
  },
  ChatRoom_Answer_Topic_UIBP = {
    keyName = "ChatRoom_Answer_Topic_UIBP",
    moduleName = "client.slua.umg.lobby_chat.chatroom.ChatRoom_Answer_Topic_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/ChatRoom/ChatRoom_Answer_Topic_UIBP.ChatRoom_Answer_Topic_UIBP",
    asy = true,
    uiStat = {
      name = "\232\129\138\229\164\169\229\174\164-\231\173\148\229\164\141\232\175\157\233\162\152"
    }
  },
  ChatRoom_Audience_UIBP = {
    keyName = "ChatRoom_Audience_UIBP",
    moduleName = "client.slua.umg.lobby_chat.chatroom.ChatRoom_Audience_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/ChatRoom/ChatRoom_Audience_UIBP.ChatRoom_Audience_UIBP",
    asy = true,
    uiStat = {
      name = "\232\129\138\229\164\169\229\174\164-\229\144\172\228\188\151\229\136\151\232\161\168"
    }
  },
  ChatRoom_Language_UIBP = {
    keyName = "ChatRoom_Language_UIBP",
    moduleName = "client.slua.umg.lobby_chat.chatroom.ChatRoom_Language_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/ChatRoom/ChatRoom_Language_UIBP.ChatRoom_Language_UIBP",
    asy = true,
    uiStat = {
      name = "\232\129\138\229\164\169\229\174\164-\233\128\137\230\139\169\232\175\173\232\168\128"
    }
  },
  ChatRoom_BG_UIBP = {
    keyName = "ChatRoom_BG_UIBP",
    moduleName = "client.slua.umg.lobby_chat.chatroom.ChatRoom_BG_UIBP",
    path = "/Game/UMG/UI_BP/LobbyChat/LobbyChat_170/Chatroom/ChatRoom_BG_UIBP.ChatRoom_BG_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\129\138\229\164\169\229\174\164-\229\186\149\230\157\191\231\149\140\233\157\162"
    }
  },
  Lobby_PeakGame_Start_Time_Chart_UIBP = {
    keyName = "Lobby_PeakGame_Start_Time_Chart_UIBP",
    moduleName = "client.slua.umg.PeakGame.Lobby_PeakGame_Start_Time_Chart_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Lobby_PeakGame_Three_Col_Chart_UIBP.Lobby_PeakGame_Three_Col_Chart_UIBP",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\228\184\187\231\149\140\233\157\162\229\188\128\232\181\155\230\151\182\233\151\180\232\161\168\230\160\188\231\149\140\233\157\162"
    },
    isSingleton = false,
    isMainUI = false
  },
  BP_PeakGameUIEffect = {
    keyName = "BP_PeakGameUIEffect",
    moduleName = "client.slua.umg.BP_PeakGameUIEffect",
    path = "/Game/Arts_Lobby/CookEntry/Widget3D/BP_PeakGameUIEffect.BP_PeakGameUIEffect",
    isSingleton = false,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155UI\231\137\185\230\149\136\231\149\140\233\157\162"
    }
  },
  BP_PeakGameUIEffect_New = {
    keyName = "BP_PeakGameUIEffect_New",
    moduleName = "client.slua.umg.BP_PeakGameUIEffect_New",
    path = "/Game/Arts_Lobby/CookEntry/Widget3D/BP_PeakGameUIEffect.BP_PeakGameUIEffect",
    isSingleton = false,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155UI\231\137\185\230\149\136\231\149\140\233\157\162-new"
    }
  },
  Lobby_RoleInfo_PeakGame_Tips_UIBP = {
    keyName = "Lobby_RoleInfo_PeakGame_Tips_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_PeakGame_Tips_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_PeakGame_Tips_UIBP.Lobby_RoleInfo_PeakGame_Tips_UIBP",
    asy = true,
    uiStat = {
      name = "\229\159\186\231\161\128\228\191\161\230\129\175\226\128\148\226\128\148\230\155\180\229\164\154tips\231\149\140\233\157\162"
    }
  },
  LobbyChat_GiftChange_UIBP = {
    keyName = "LobbyChat_GiftChange_UIBP",
    moduleName = "client.slua.umg.LobbyChat.LobbyChat_170.LobbyChat_GiftChange_UIBP",
    path = "/Game/UMG/UI_BP/LobbyChat/LobbyChat_170/LobbyChat_GiftChange_UIBP.LobbyChat_GiftChange_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\228\186\186\230\176\148\231\164\188\231\137\169-\233\161\182\233\131\168\230\160\143"
    }
  },
  Chat_GiftScreen_Popup_UIBP = {
    keyName = "Chat_GiftScreen_Popup_UIBP",
    moduleName = "client.slua.umg.LobbyChat.LobbyChat_170.Chat_GiftScreen_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/Chat_GiftScreen_Popup_UIBP.Chat_GiftScreen_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\228\186\186\230\176\148\231\164\188\231\137\169-\232\174\190\231\189\174\229\188\185\231\170\151"
    }
  },
  Chat_ScintillaDetails_Main_UIBP = {
    keyName = "Chat_ScintillaDetails_Main_UIBP",
    moduleName = "client.slua.umg.LobbyChat.LobbyChat_170.Scintilla.Chat_ScintillaDetails_Main_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/Scintilla/Chat_ScintillaDetails_Main_UIBP.Chat_ScintillaDetails_Main_UIBP",
    uiStat = {
      name = "\229\133\187\231\129\171\232\175\166\230\131\133\231\149\140\233\157\162"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  Chat_ScintillaGrade_UIBP = {
    keyName = "Chat_ScintillaGrade_UIBP",
    moduleName = "client.slua.umg.LobbyChat.LobbyChat_170.Scintilla.Chat_ScintillaGrade_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/Scintilla/Chat_ScintillaGrade_UIBP.Chat_ScintillaGrade_UIBP",
    uiStat = {
      name = "\229\133\187\231\129\171\231\164\188\231\137\169\231\149\140\233\157\162"
    }
  },
  Chat_ScintillaTip_UIBP = {
    keyName = "Chat_ScintillaTip_UIBP",
    moduleName = "client.slua.umg.LobbyChat.LobbyChat_170.Scintilla.Chat_ScintillaTip_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/Scintilla/Chat_ScintillaTip_UIBP.Chat_ScintillaTip_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    isMainUI = false,
    uiStat = {name = "\229\133\187\231\129\171tips"}
  },
  Chat_ScintillaDetails_Popup_UIBP = {
    keyName = "Chat_ScintillaDetails_Popup_UIBP",
    moduleName = "client.slua.umg.LobbyChat.LobbyChat_170.Scintilla.Chat_ScintillaDetails_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/Scintilla/Chat_ScintillaDetails_Popup_UIBP.Chat_ScintillaDetails_Popup_UIBP",
    uiStat = {
      name = "\229\133\187\231\129\171\228\191\161\231\137\169\229\141\135\231\186\167\229\188\185\231\170\151"
    }
  },
  ChatDress_UIBP = {
    keyName = "ChatDress_UIBP",
    moduleName = "client.slua.umg.lobby_chat.chatroom.ChatDress_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/ChatDress_UIBP.ChatDress_UIBP",
    uiStat = {
      name = "\232\129\138\229\164\169\229\174\164-\229\165\189\229\143\139\232\129\138\229\164\169\232\131\140\230\153\175\233\128\137\230\139\169\231\149\140\233\157\162"
    }
  },
  Lobby_RoleInfo_PopularityGift_Contribution_Popup_UIBP = {
    keyName = "Lobby_RoleInfo_PopularityGift_Contribution_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.AnnualCelebration.Popup.Lobby_RoleInfo_PopularityGift_Contribution_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/AnnualCelebration/Popup/Lobby_RoleInfo_PopularityGift_Contribution_Popup_UIBP.Lobby_RoleInfo_PopularityGift_Contribution_Popup_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148\229\175\185\229\134\179 \229\185\180\229\186\166\231\155\155\229\133\184 -> \229\175\185\229\134\179 -> \229\174\157\231\174\177\229\188\185\231\170\151"
    }
  },
  Lobby_RoleInfo_AnnualCelebration_Box_UIBP = {
    keyName = "Lobby_RoleInfo_AnnualCelebration_Box_UIBP",
    moduleName = "client.slua.umg.PersonSpace.AnnualCelebration.Lobby_RoleInfo_AnnualCelebration_Box_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/AnnualCelebration/Lobby_RoleInfo_AnnualCelebration_Box_UIBP.Lobby_RoleInfo_AnnualCelebration_Box_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148\229\175\185\229\134\179 \229\185\180\229\186\166\231\155\155\229\133\184 -> \229\174\157\231\174\177"
    }
  },
  Lobby_RoleInfo_AnnualCelebration_FunAwards_UIBP = {
    keyName = "Lobby_RoleInfo_AnnualCelebration_FunAwards_UIBP",
    moduleName = "client.slua.umg.PersonSpace.AnnualCelebration.Lobby_RoleInfo_AnnualCelebration_FunAwards_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/AnnualCelebration/Lobby_RoleInfo_AnnualCelebration_FunAwards_UIBP.Lobby_RoleInfo_AnnualCelebration_FunAwards_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148\229\175\185\229\134\179 \229\185\180\229\186\166\231\155\155\229\133\184 -> \232\182\163\229\145\179\229\165\150\233\161\185"
    }
  },
  Lobby_RoleInfo_PopularityGift_Task_Popup_UIBP = {
    keyName = "Lobby_RoleInfo_PopularityGift_Task_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.AnnualCelebration.Popup.Lobby_RoleInfo_PopularityGift_Task_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/AnnualCelebration/Popup/Lobby_RoleInfo_PopularityGift_Task_Popup_UIBP.Lobby_RoleInfo_PopularityGift_Task_Popup_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148\229\175\185\229\134\179 \229\185\180\229\186\166\231\155\155\229\133\184 -> \229\174\157\231\174\177 -> \228\187\187\229\138\161\229\188\185\231\170\151"
    }
  },
  Lobby_TSL_UIBP = {
    keyName = "Lobby_TSL_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Turkish_SuperLeague.Lobby_TSL_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/PersonSpace/Turkish_SuperLeague/Lobby_TSL_UIBP.Lobby_TSL_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148\229\175\185\229\134\179 \229\156\159\232\182\133 -> \230\140\130\232\189\189\231\149\140\233\157\162"
    }
  },
  Lobby_TSL_Main = {
    keyName = "Lobby_TSL_Main",
    moduleName = "client.slua.umg.PersonSpace.Turkish_SuperLeague.Lobby_TSL_Main",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/PersonSpace/Turkish_SuperLeague/Lobby_TSL_Main.Lobby_TSL_Main",
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148\229\175\185\229\134\179 \229\156\159\232\182\133 -> \228\184\187\231\149\140\233\157\162"
    }
  },
  Lobby_TSL_Popularity_Pk_UIBP = {
    keyName = "Lobby_TSL_Popularity_Pk_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Turkish_SuperLeague.Lobby_TSL_Popularity_Pk_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/PersonSpace/Turkish_SuperLeague/Lobby_TSL_Popularity_Pk_UIBP.Lobby_TSL_Popularity_Pk_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148\229\175\185\229\134\179 \229\156\159\232\182\133 -> \228\186\186\230\176\148\229\175\185\229\134\179"
    }
  },
  Lobby_TSL_Result_UIBP = {
    keyName = "Lobby_TSL_Result_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Turkish_SuperLeague.Lobby_TSL_Result_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/PersonSpace/Turkish_SuperLeague/Lobby_TSL_Result_UIBP.Lobby_TSL_Result_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148\229\175\185\229\134\179 \229\156\159\232\182\133 -> \231\187\147\230\158\156"
    }
  },
  Lobby_Lottery_TSL_Popup_UIBP = {
    keyName = "Lobby_Lottery_TSL_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Turkish_SuperLeague.Popup.Lobby_Lottery_TSL_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/PersonSpace/Turkish_SuperLeague/Popup/Lobby_Lottery_TSL_Popup_UIBP.Lobby_Lottery_TSL_Popup_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148\229\175\185\229\134\179 \229\156\159\232\182\133 -> \230\138\189\229\165\150\229\188\185\231\170\151"
    }
  },
  Lobby_Notice_TSL_Popup_UIBP = {
    keyName = "Lobby_Notice_TSL_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Turkish_SuperLeague.Popup.Lobby_Notice_TSL_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/PersonSpace/Turkish_SuperLeague/Popup/Lobby_Notice_TSL_Popup_UIBP.Lobby_Notice_TSL_Popup_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148\229\175\185\229\134\179 \229\156\159\232\182\133 -> \230\128\187\230\142\146\232\161\140\230\166\156"
    }
  },
  Lobby_Rank_TSL_Popup_UIBP = {
    keyName = "Lobby_Rank_TSL_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Turkish_SuperLeague.Popup.Lobby_Rank_TSL_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/PersonSpace/Turkish_SuperLeague/Popup/Lobby_Rank_TSL_Popup_UIBP.Lobby_Rank_TSL_Popup_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148\229\175\185\229\134\179 \229\156\159\232\182\133 -> \229\141\149\230\142\146\232\161\140\230\166\156\229\188\185\231\170\151"
    }
  },
  Lobby_RoleInfo_IntimateRelationship_Interact_UIBP = {
    keyName = "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_IntimateRelationship_Interact_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_IntimateRelationship_Interact_UIBP.Lobby_RoleInfo_IntimateRelationship_Interact_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\228\186\178\229\175\134\229\133\179\231\179\187\226\128\148\226\128\148\230\144\173\230\161\163\231\149\140\233\157\162"
    }
  },
  Lobby_RoleInfo_IntimateRelationship_Exhibition_02_UIBP = {
    keyName = "Lobby_RoleInfo_IntimateRelationship_Exhibition_02_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_IntimateRelationship_Exhibition_02_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_IntimateRelationship_Exhibition_02_UIBP.Lobby_RoleInfo_IntimateRelationship_Exhibition_02_UIBP",
    jumpModuleID = BP_ENUM_MODULE_CRYSTALACTION,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\228\186\178\229\175\134\229\133\179\231\179\187\226\128\148\226\128\148\231\188\150\232\190\145\229\138\168\228\189\156\231\149\140\233\157\162"
    }
  },
  Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP = {
    keyName = "Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP.Lobby_RoleInfo_IntimateRelationship_Exhibition_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\228\186\178\229\175\134\229\133\179\231\179\187\226\128\148\226\128\148\229\133\179\231\179\187\229\177\149\231\164\186\228\184\187\231\149\140\233\157\162"
    }
  },
  IntimateRelation_Exhibition_Share = {
    keyName = "IntimateRelation_Exhibition_Share",
    moduleName = "client.slua.umg.PersonSpace.share_roleinfo_exhibition",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_IntimateRelationship_Exhibition_Share_UIBP.Lobby_RoleInfo_IntimateRelationship_Exhibition_Share_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\228\186\178\229\175\134\229\133\179\231\179\187-\229\133\179\231\179\187\229\177\149\231\164\186-\230\139\141\231\133\167\229\136\134\228\186\171"
    }
  },
  Lobby_Couple_Report_UIBP = {
    keyName = "Lobby_Couple_Report_UIBP",
    moduleName = "client.slua.umg.lobby.Left.Tips.Lobby_Couple_Report_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Left/Lobby_Couple_Report_UIBP.Lobby_Couple_Report_UIBP",
    asy = true,
    uiStat = {
      name = "\228\186\178\229\175\134\229\133\179\231\179\187\226\128\148\230\139\141\230\161\163\228\184\190\230\138\165"
    }
  },
  Lobby_RoleInfo_IntimateRelationship_Interact_UIBP_02 = {
    keyName = "Lobby_RoleInfo_IntimateRelationship_Interact_UIBP_02",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_IntimateRelationship_Interact_UIBP_02",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_IntimateRelationship_Interact_UIBP_02.Lobby_RoleInfo_IntimateRelationship_Interact_UIBP_02",
    jumpModuleID = BP_ENUM_MODULE_PARTNER_AWARD,
    uiStat = {
      name = "\230\139\141\230\161\163\229\165\150\229\138\177\231\149\140\233\157\162"
    }
  },
  Lobby_RoleInfo_Relationship_UIBP = {
    keyName = "Lobby_RoleInfo_Relationship_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Lobby_RoleInfo_Relationship_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Lobby_RoleInfo_Relationship_UIBP.Lobby_RoleInfo_Relationship_UIBP",
    uiStat = {
      name = "\229\177\149\231\164\186\230\176\180\230\153\182\232\174\190\231\189\174\231\149\140\233\157\162"
    }
  },
  Lobby_RoleInfo_IntimateRelationship_Exhibition_Popup_UIBP_02 = {
    keyName = "Lobby_RoleInfo_IntimateRelationship_Exhibition_Popup_UIBP_02",
    moduleName = "client.slua.umg.PersonSpace.Popup.Lobby_RoleInfo_IntimateRelationship_Exhibition_Popup_UIBP_02",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Lobby_RoleInfo_IntimateRelationship_Exhibition_Popup_UIBP_02.Lobby_RoleInfo_IntimateRelationship_Exhibition_Popup_UIBP_02",
    uiStat = {
      name = "\228\186\146\229\138\168\230\176\180\230\153\182\229\188\185\231\170\151\231\149\140\233\157\162"
    }
  },
  Lobby_RoleInfo_IntimateRelationship_Cohabit_Popup_UIBP = {
    keyName = "Lobby_RoleInfo_IntimateRelationship_Cohabit_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Lobby_RoleInfo_IntimateRelationship_Cohabit_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Lobby_RoleInfo_IntimateRelationship_Exhibition_Popup_UIBP_02.Lobby_RoleInfo_IntimateRelationship_Exhibition_Popup_UIBP_02",
    uiStat = {
      name = "\229\174\182\229\155\173\229\144\140\228\189\143\228\186\186\233\128\137\230\139\169\229\136\151\232\161\168\231\149\140\233\157\162"
    }
  },
  Lobby_Crystal_Tips_UIBP = {
    keyName = "Lobby_Crystal_Tips_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_Crystal_Tips_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_Crystal_Tips_UIBP.Lobby_Crystal_Tips_UIBP",
    uiStat = {
      name = "\230\176\180\230\153\182\232\175\166\231\187\134\228\191\161\230\129\175\230\143\144\231\164\186\231\149\140\233\157\162"
    }
  },
  Chat_ScintillaGrade_UIBP_02 = {
    keyName = "Chat_ScintillaGrade_UIBP_02",
    moduleName = "client.slua.umg.LobbyChat.LobbyChat_170.Scintilla.Chat_ScintillaGrade_UIBP_02",
    path = "/Game/Mod/Lobby/Split/LobbyChat/Scintilla/Chat_ScintillaGrade_UIBP_02.Chat_ScintillaGrade_UIBP_02",
    uiStat = {
      name = "\232\191\155\229\133\165\228\186\146\229\138\168\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  Lobby_Multiple_Silhouette_Item_UIBP = {
    keyName = "Lobby_Multiple_Silhouette_Item_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_Multiple_Silhouette_Item_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_Multiple_Silhouette_Item_UIBP.Lobby_Multiple_Silhouette_Item_UIBP",
    uiStat = {
      name = "\229\164\154\228\186\186\228\186\178\229\175\134\229\133\179\231\179\187\232\174\190\231\189\174\231\149\140\233\157\162\229\137\170\229\189\177"
    }
  },
  PeakGame_Get_Ace_UIBP = {
    keyName = "PeakGame_Get_Ace_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.S20.PeakGame_Get_Ace_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/S20/PeakGame_Get_Ace_UIBP.PeakGame_Get_Ace_UIBP",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\229\141\176\232\174\176\232\161\165\229\129\191\231\149\140\233\157\162"
    }
  },
  Ace_File_UIBP = {
    keyName = "Ace_File_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.S20.Ace_File_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/ACEImprint/Ace_File_UIBP.Ace_File_UIBP",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\231\187\143\229\133\184\232\181\155\229\173\163-\229\141\176\232\174\176\230\161\163\230\161\136\231\149\140\233\157\162"
    }
  },
  ScrapGold_AnnualDiscountTips_Item_UIBP = {
    keyName = "ScrapGold_AnnualDiscountTips_Item_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.ScrapGold.Widget.ScrapGold_AnnualDiscountTips_Item_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/ScrapGold/UIBP/ScrapGold_AnnualDiscountTips_Item_UIBP.ScrapGold_AnnualDiscountTips_Item_UIBP",
    uiStat = {
      name = "\231\165\158\231\167\152\229\183\165\229\157\138\230\138\152\230\137\163item"
    }
  },
  Chat_Message_Shield_Type_Popup_UIBP = {
    keyName = "Chat_Message_Shield_Type_Popup_UIBP",
    moduleName = "client.slua.umg.LobbyChat.LobbyChat_170.Chat_Message_Shield_Type_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/Chat_Message_Shield_Type_Popup_UIBP.Chat_Message_Shield_Type_Popup_UIBP",
    uiStat = {
      name = "\229\139\190\233\128\137\229\177\143\232\148\189\231\177\187\229\158\139\229\188\185\231\170\151\231\149\140\233\157\162"
    }
  },
  Lobby_Main_Notice_UIBP = {
    keyName = "Lobby_Main_Notice_UIBP",
    moduleName = "client.slua.umg.lobby.Main.Lobby_Main_Notice_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Main_notice_UIBP.Lobby_Main_Notice_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\164\167\229\142\133-\233\128\154\231\159\165\232\181\176\233\169\172\231\129\175"
    }
  },
  MainCity_Lobby_Friend_UIBP = {
    keyName = "MainCity_Lobby_Friend_UIBP",
    moduleName = "client.slua.umg.MainCity.Lobby_Friend.MainCity_Lobby_Friend_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Friend/MainCity_Lobby_Friend_UIBP.MainCity_Lobby_Friend_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\231\187\132\233\152\159\229\165\189\229\143\139\231\149\140\233\157\162"
    },
    asy = true,
    isMainUI = false
  },
  MainCity_Lobby_Friend_Tips_UIBP = {
    keyName = "MainCity_Lobby_Friend_Tips_UIBP",
    moduleName = "client.slua.umg.MainCity.Lobby_Friend.Item.MainCity_Lobby_Friend_Tips_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Friend/Item/MainCity_Lobby_Friend_Tips_UIBP.MainCity_Lobby_Friend_Tips_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\231\187\132\233\152\159\228\186\140\231\186\167\229\188\185\231\170\151"
    }
  },
  MainCity_Lobby_Main_Match_Entry_UIBP = {
    keyName = "MainCity_Lobby_Main_Match_Entry_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.Match.MainCity_Lobby_Main_Match_Entry_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/MainCity_Lobby_Main_Match_Entry_UIBP.MainCity_Lobby_Main_Match_Entry_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\230\168\161\229\188\143\233\128\137\230\139\169\230\149\180\229\144\136"
    },
    asy = true,
    isMainUI = false
  },
  MainCity_Lobby_Mid_Banner_UIBP = {
    keyName = "MainCity_Lobby_Mid_Banner_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.MainCity_Lobby_Mid_Banner_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/MainCity_Lobby_Mid_Banner_UIBP.MainCity_Lobby_Mid_Banner_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\228\184\187\231\149\140\233\157\162-banner"
    },
    asy = true,
    isMainUI = false
  },
  MainCity_Lobby_System_Entry_Item = {
    keyName = "MainCity_Lobby_System_Entry_Item",
    moduleName = "client.slua.umg.MainCity.Main.Item.MainCity_Lobby_System_Entry_Item",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Item/MainCity_Lobby_System_Entry_Item.MainCity_Lobby_System_Entry_Item",
    uiStat = {
      name = "\228\184\187\229\159\142-\228\184\187\231\149\140\233\157\162-\231\179\187\231\187\159\229\133\165\229\143\163-item"
    },
    isMainUI = false,
    isSingleton = false
  },
  MainCity_Lobby_System_Entry_Shop_Item = {
    keyName = "MainCity_Lobby_System_Entry_Shop_Item",
    moduleName = "client.slua.umg.MainCity.Main.Item.MainCity_Lobby_System_Entry_Shop_Item",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Item/MainCity_Lobby_System_Entry_Item.MainCity_Lobby_System_Entry_Item",
    uiStat = {
      name = "\228\184\187\229\159\142-\228\184\187\231\149\140\233\157\162-\231\179\187\231\187\159\229\133\165\229\143\163-\229\149\134\229\159\142-item"
    },
    isMainUI = false,
    isSingleton = false
  },
  MainCity_LobbyPlayer_Popup_UIBP = {
    keyName = "MainCity_LobbyPlayer_Popup_UIBP",
    moduleName = "client.slua.umg.MainCity.Lobby_Friend.Popup.MainCity_LobbyPlayer_Popup_UIBP",
    path = "/Game/UMG/UI_BP/MainCity/Lobby_Friend/Popup/MainCity_LobbyPlayer_Popup_UIBP.MainCity_LobbyPlayer_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\228\184\187\229\159\142-\231\142\169\229\174\182\229\136\151\232\161\168\231\149\140\233\157\162"
    }
  },
  MainCity_PlayerList_Voice_Item = {
    keyName = "MainCity_PlayerList_Voice_Item",
    moduleName = "client.slua.umg.MainCity.Lobby_Chat.MainCity_PlayerList_Voice_Item",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Chat/MainCity_PlayerList_Voice_Item.MainCity_PlayerList_Voice_Item",
    uiStat = {
      name = "\228\184\187\229\159\142-\231\142\169\229\174\182\229\136\151\232\161\168-\233\159\179\233\135\143\233\148\174\230\187\145\230\157\161"
    }
  },
  MainCity_Lobby_Bubble_UIBP = {
    keyName = "MainCity_Lobby_Bubble_UIBP",
    moduleName = "client.slua.umg.MainCity.Main.Item.MainCity_Lobby_Bubble_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Item/MainCity_Lobby_Bubble_UIBP.MainCity_Lobby_Bubble_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\228\184\187\231\149\140\233\157\162-\231\179\187\231\187\159\229\133\165\229\143\163-\230\176\148\230\179\161"
    },
    isMainUI = false
  },
  MainCity_Chat_UIBP = {
    keyName = "MainCity_Chat_UIBP",
    moduleName = "client.slua.umg.MainCity.Lobby_Chat.MainCity_Chat_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Chat/MainCity_Chat_UIBP.MainCity_Chat_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\232\129\138\229\164\169\229\133\165\229\143\163\231\149\140\233\157\162"
    },
    asy = true,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Skip
  },
  MainCity_Lobby_ThemeEntry_Item = {
    keyName = "MainCity_Lobby_ThemeEntry_Item",
    moduleName = "client.slua.umg.MainCity.Main.Item.MainCity_Lobby_ThemeEntry_Item",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Item/MainCity_Lobby_ThemeEntry_Item.MainCity_Lobby_ThemeEntry_Item",
    uiStat = {
      name = "\228\184\187\229\159\142-\230\168\161\229\188\143\229\133\165\229\143\163-\228\184\187\233\162\152\229\174\157\231\174\177"
    },
    isMainUI = false
  },
  MainCity_Lobby_Friend_Item_02_UIBP = {
    keyName = "MainCity_Lobby_Friend_Item_02_UIBP",
    moduleName = "client.slua.umg.MainCity.Lobby_Friend.Item.MainCity_Lobby_Friend_Item_02_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Friend/Item/MainCity_Lobby_Friend_Item_02_UIBP.MainCity_Lobby_Friend_Item_02_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142 - \231\187\132\233\152\159\232\129\138\229\164\169\230\176\148\230\179\161\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  MainCity_Lobby_Mid_QMsg_Item_UIBP = {
    keyName = "MainCity_Lobby_Mid_QMsg_Item_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_QMsg_Item_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Item/Lobby_Mid_QMsg_Item_UIBP.Lobby_Mid_QMsg_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\184\187\229\159\142-\229\191\171\230\141\183\232\129\138\229\164\169"
    }
  },
  MainCity_NetState_Item = {
    keyName = "MainCity_NetState_Item",
    moduleName = "client.slua.umg.MainCity.Lobby_Friend.Item.MainCity_NetState_Item",
    path = "/Game/Mod/MainCity/BluePrints/UI/Friend/Item/MainCity_NetState_Item.MainCity_NetState_Item",
    uiStat = {
      name = "\228\184\187\229\159\142 - \231\189\145\231\187\156\231\138\182\230\128\129 - \229\155\190\230\160\135"
    },
    isMainUI = false,
    isSingleton = false
  },
  MainCity_Lobby_Friend_Explore_UIBP = {
    keyName = "MainCity_Lobby_Friend_Explore_UIBP",
    moduleName = "client.slua.umg.MainCity.Lobby_Friend.Item.MainCity_Lobby_Friend_Explore_UIBP",
    isMainUI = false,
    path = "/Game/Mod/MainCity/BluePrints/UI/Friend/Item/MainCity_Lobby_Friend_Explore_UIBP.MainCity_Lobby_Friend_Explore_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142 - \230\142\162\231\180\162\231\149\140\233\157\162"
    }
  },
  Lobby_RoleInfo_CustomPresentation_Popup_UIBP = {
    keyName = "Lobby_RoleInfo_CustomPresentation_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Lobby_RoleInfo_CustomPresentation_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Lobby_RoleInfo_CustomPresentation_Popup_UIBP.Lobby_RoleInfo_CustomPresentation_Popup_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - \231\188\150\232\190\145\231\170\151\229\143\163"
    }
  },
  Lobby_RoleInfo_CustomInformation_Popup_UIBP = {
    keyName = "Lobby_RoleInfo_CustomInformation_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Lobby_RoleInfo_CustomInformation_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Lobby_RoleInfo_CustomInformation_Popup_UIBP.Lobby_RoleInfo_CustomInformation_Popup_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - \231\188\150\232\190\145\231\170\151\229\143\163"
    }
  },
  MainCity_Speaker_UIBP = {
    keyName = "MainCity_Speaker_UIBP",
    moduleName = "client.slua.umg.MainCity.Lobby_Chat.MainCity_Speaker_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Chat/MainCity_Speaker_UIBP.MainCity_Speaker_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\232\129\138\229\164\169\231\170\151\229\143\163-\230\137\172\229\163\176\229\153\168\231\149\140\233\157\162"
    }
  },
  MainCity_Microphone_UIBP = {
    keyName = "MainCity_Microphone_UIBP",
    moduleName = "client.slua.umg.MainCity.Lobby_Chat.MainCity_Microphone_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Chat/MainCity_Microphone_UIBP.MainCity_Microphone_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\232\129\138\229\164\169\231\170\151\229\143\163-\233\186\166\229\133\139\233\163\142\231\149\140\233\157\162"
    }
  },
  MainCity_Lobby_Mid_DoubleCard_Buff_Panel_160_UIBP = {
    keyName = "MainCity_Lobby_Mid_DoubleCard_Buff_Panel_160_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_DoubleCard_Buff_Panel_new_UIBP",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Item/MainCity_Lobby_Mid_DoubleCard_Buff_Panel_160_UIBP.MainCity_Lobby_Mid_DoubleCard_Buff_Panel_160_UIBP"
  },
  FriendsListItem_MainCity_Tips_UIBP = {
    keyName = "FriendsListItem_MainCity_Tips_UIBP",
    moduleName = "client.slua.umg.lobby.Item.FriendsListItem_MainCity_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Item/FriendsListItem_MainCity_Tips_UIBP.FriendsListItem_MainCity_Tips_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142\229\165\189\229\143\139-\229\165\189\229\143\139\228\190\167\232\190\185\230\160\143\233\130\128\232\175\183tip"
    }
  },
  FriendsListItem_Invitation_Tips_UIBP = {
    keyName = "FriendsListItem_Invitation_Tips_UIBP",
    moduleName = "client.slua.umg.lobby.Item.FriendsListItem_Invitation_Tips_UIBP",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/Item/FriendsListItem_Invitation_Tips_UIBP.FriendsListItem_Invitation_Tips_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142\229\165\189\229\143\139-\229\165\189\229\143\139\230\140\137\233\146\174\230\139\147\229\177\149tips"
    }
  },
  WebPanel_UIBP = {
    keyName = "WebPanel_UIBP",
    moduleName = "client.slua.umg.Lobby.Web.WebPanel_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Web/WebPanel_UIBP.WebPanel_UIBP",
    uiStat = {name = "XX\231\149\140\233\157\162"}
  },
  Goods_DoubleDetail_UIBP = {
    keyName = "Goods_DoubleDetail_UIBP",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.supply.Goods_DoubleDetail_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Store_Int/Goods_DoubleDetail_UIBP.Goods_DoubleDetail_UIBP",
    uiStat = {
      name = "\229\143\140\233\135\141\228\184\141\230\148\190\229\155\158 \230\151\165\233\159\169\230\166\130\231\142\135"
    }
  },
  Lobby_ExpandMatching_Popup_UIBP = {
    keyName = "Lobby_ExpandMatching_Popup_UIBP",
    moduleName = "client.slua.umg.lobby.Popup.Lobby_ExpandMatching_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Popup/Lobby_ExpandMatching_Popup_UIBP.Lobby_ExpandMatching_Popup_UIBP",
    uiStat = {
      name = "\232\183\168\230\156\141\229\140\185\233\133\141\229\188\185\231\170\151"
    }
  },
  Lobby_CrazyWeekend_Entrance_UIBP = {
    keyName = "Lobby_CrazyWeekend_Entrance_UIBP",
    moduleName = "client.slua.umg.lobby.Lobby_CrazyWeekend_Entrance_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Lobby_CrazyWeekend_Entrance_UIBP.Lobby_CrazyWeekend_Entrance_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\231\150\175\231\139\130\229\145\168\230\156\171\229\164\167\229\142\133\230\180\187\229\138\168\229\133\165\229\143\163"
    }
  },
  CrazyWeekend_HomePage_UIBP = {
    keyName = "CrazyWeekend_HomePage_UIBP",
    moduleName = "client.slua.umg.CrazyWeekend.CrazyWeekend_Main_UIBP",
    path = "/Game/UMG/UI_BP/CrazyWeekend/CrazyWeekend_Main_UIBP.CrazyWeekend_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_CRAZY_WEEKEND_MAIN,
    uiStat = {
      name = "\231\150\175\231\139\130\229\145\168\230\156\171\228\184\187\231\149\140\233\157\162"
    },
    isMainUI = true,
    isSingleton = true
  },
  CrazyWeekend_Ticket_Popup_UIBP = {
    keyName = "CrazyWeekend_Ticket_Popup_UIBP",
    moduleName = "client.slua.umg.CrazyWeekend.Popup.CrazyWeekend_Ticket_Popup_UIBP",
    path = "/Game/UMG/UI_BP/CrazyWeekend/Popup/CrazyWeekend_Ticket_Popup_UIBP.CrazyWeekend_Ticket_Popup_UIBP",
    uiStat = {
      name = "\231\150\175\231\139\130\229\145\168\230\156\171-\228\184\173\229\165\150\231\149\140\233\157\162"
    }
  },
  CrazyWeekend_RankPrivilege_UIBP = {
    keyName = "CrazyWeekend_RankPrivilege_UIBP",
    moduleName = "client.slua.umg.CrazyWeekend.HomePage.CrazyWeekend_RankPrivilege_UIBP",
    path = "/Game/UMG/UI_BP/CrazyWeekend/Item/CrazyWeekend_Main_Item01_UIBP.CrazyWeekend_Main_Item01_UIBP",
    uiStat = {
      name = "\231\150\175\231\139\130\229\145\168\230\156\171\229\173\144\230\180\187\229\138\168"
    }
  },
  CrazyWeekend_GroupTitle = {
    keyName = "CrazyWeekend_GroupTitle",
    moduleName = "client.slua.umg.CrazyWeekend.HomePage.CrazyWeekend_GroupTitle",
    path = "/Game/UMG/UI_BP/CrazyWeekend/Item/CrazyWeekend_Main_Item03_UIBP.CrazyWeekend_Main_Item03_UIBP",
    uiStat = {
      name = "\231\150\175\231\139\130\229\145\168\230\156\171\230\180\187\229\138\168\229\136\134\231\187\132\230\160\135\233\162\152"
    }
  },
  Lobby_Exchange_Market_Main_UIBP = {
    keyName = "Lobby_Exchange_Market_Main_UIBP",
    moduleName = "client.slua.umg.NewActivty.NewActivty_Market.Lobby_Exchange_Market_Main_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/NewActivty_Market/Lobby_Exchange_Market_Main_UIBP.Lobby_Exchange_Market_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\229\145\168\230\156\171\233\155\134\229\184\130\230\180\187\229\138\168\228\184\187\231\149\140\233\157\162"
    }
  },
  Lobby_MarketTasks_UIBP = {
    keyName = "Lobby_MarketTasks_UIBP",
    moduleName = "client.slua.umg.NewActivty.NewActivty_Market.Lobby_MarketTasks_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/NewActivty_Market/Lobby_MarketTasks_UIBP.Lobby_MarketTasks_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\229\145\168\230\156\171\233\155\134\229\184\130\230\186\162\228\187\183\229\155\158\230\148\182\229\173\144\231\149\140\233\157\162"
    }
  },
  Lobby_Mid_DoubleCard_Buff_act_entry_Item_UIBP = {
    keyName = "Lobby_Mid_DoubleCard_Buff_act_entry_Item_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Item.Lobby_Mid_DoubleCard_Buff_act_entry_Item_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Item/Lobby_Mid_DoubleCard_Buff_act_entry_Item_UIBP.Lobby_Mid_DoubleCard_Buff_act_entry_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\230\180\187\229\138\168\230\142\146\228\189\141\229\138\160\230\136\144-\229\133\165\229\143\163"
    }
  },
  NickName_Item_UIBP = {
    keyName = "NickName_Item_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.NewItem.NickName_Item_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Item/NickName_Item_UIBP.NickName_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\138\168\230\128\129\230\152\181\231\167\176-\231\149\140\233\157\162"
    }
  },
  friend_reserve_list = {
    keyName = "friend_reserve_list",
    moduleName = "client.slua.umg.friend.friend_reserve_list",
    path = "/Game/UMG/UI_BP/Lobby/Lobby_InviteFriendsTipsUI_yuyue_list_BP.Lobby_InviteFriendsTipsUI_yuyue_list_BP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\143\179\228\184\139\229\188\185\231\170\151-\229\165\189\229\143\139\233\162\132\231\186\166\229\136\151\232\161\168"
    }
  },
  Lobby_Water_Friendly_UIBP = {
    keyName = "Lobby_Water_Friendly_UIBP",
    moduleName = "client.slua.umg.lobby.Lobby_Water_Friendly_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Lobby_Water_Friendly_UIBP.Lobby_Water_Friendly_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\230\176\180\229\143\139\232\181\155\229\188\128\232\181\155\233\128\154\231\159\165"
    }
  },
  SecurityStation = {
    keyName = "SecurityStation",
    moduleName = "client.slua.umg.lobby.SecurityStation",
    path = "/Game/UMG/UI_BP/Lobby/SecurityStation.SecurityStation",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\174\137\229\133\168\231\171\153\230\155\180\230\150\176\233\128\154\231\159\165"
    }
  },
  Lobby_VersionUpdateSlap_UIBP = {
    keyName = "Lobby_VersionUpdateSlap_UIBP",
    moduleName = "client.slua.umg.version_update_slap.Lobby_VersionUpdateSlap_UIBP",
    path = "/Game/Arts_UI/VersionUpdateSlap/Lobby_VersionUpdateSlap_UIBP.Lobby_VersionUpdateSlap_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\231\137\136\230\156\172\230\155\180\230\150\176\230\139\141\232\132\184"
    }
  },
  Lobby_RoleInfo_IntimateRelationship_RecordMain_UIBP = {
    keyName = "Lobby_RoleInfo_IntimateRelationship_RecordMain_UIBP",
    moduleName = "client.slua.umg.PersonSpace.IntimateRelationship.Lobby_RoleInfo_IntimateRelationship_RecordMain_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/IntimateRelationship/Lobby_RoleInfo_IntimateRelationship_RecordMain_UIBP.Lobby_RoleInfo_IntimateRelationship_RecordMain_UIBP",
    uiStat = {
      name = "\228\186\146\229\138\168\232\174\176\229\189\149-\228\184\187\231\149\140\233\157\162"
    },
    jumpModuleID = BP_ENUM_MODULE_MEMORY_RECORD
  },
  Lobby_RoleInfo_IntimateRelationship_MemoryRecord_UIBP = {
    keyName = "Lobby_RoleInfo_IntimateRelationship_MemoryRecord_UIBP",
    moduleName = "client.slua.umg.PersonSpace.IntimateRelationship.Lobby_RoleInfo_IntimateRelationship_MemoryRecord_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/IntimateRelationship/Lobby_RoleInfo_IntimateRelationship_MemoryRecord_UIBP.Lobby_RoleInfo_IntimateRelationship_MemoryRecord_UIBP",
    uiStat = {
      name = "\228\186\146\229\138\168\232\174\176\229\189\149-\233\135\140\231\168\139\231\162\145\231\149\140\233\157\162"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  Lobby_IntimateRelationship_Chat_UIBP = {
    keyName = "Lobby_IntimateRelationship_Chat_UIBP",
    moduleName = "client.slua.umg.LobbyChat.LobbyChat_170.Item.Lobby_IntimateRelationship.Lobby_IntimateRelationship_Chat_UIBP",
    path = "/Game/UMG/UI_BP/LobbyChat/LobbyChat_170/Item/Lobby_IntimateRelationship/Lobby_IntimateRelationship_Chat_UIBP.Lobby_IntimateRelationship_Chat_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\186\146\229\138\168\232\174\176\229\189\149-\229\165\189\229\143\139\232\129\138\229\164\169\231\149\140\233\157\162"
    }
  },
  Lobby_Chat_PlayerRecommand_SideBar_UIBP = {
    keyName = "Lobby_Chat_PlayerRecommand_SideBar_UIBP",
    moduleName = "client.slua.umg.LobbyChat.LobbyChat_170.Item.ChatBar.Lobby_Chat_PlayerRecommand_SideBar_UIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/Item/ChatBar/Lobby_Chat_PlayerRecommand_SideBar_UIBP.Lobby_Chat_PlayerRecommand_SideBar_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\164\167\229\142\133\232\129\138\229\164\169-\228\190\167\232\190\185\230\160\143-\231\142\169\229\174\182\230\142\168\232\141\144"
    }
  },
  Lobby_RoleInfo_CustomPresentation_V_UIBP = {
    keyName = "Lobby_RoleInfo_CustomPresentation_V_UIBP",
    moduleName = "client.slua.umg.PersonSpace.item.Lobby_RoleInfo_CustomPresentation_V_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/item/Lobby_RoleInfo_CustomPresentation_V_UIBP.Lobby_RoleInfo_CustomPresentation_V_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\231\164\190\228\186\164\229\144\141\231\137\135-\228\184\170\230\128\167\229\140\150\229\177\149\231\164\186-\231\171\150\229\144\145"
    }
  },
  Lobby_RoleInfo_CustomPresentation_H_UIBP = {
    keyName = "Lobby_RoleInfo_CustomPresentation_H_UIBP",
    moduleName = "client.slua.umg.PersonSpace.item.Lobby_RoleInfo_CustomPresentation_H_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/item/Lobby_RoleInfo_CustomPresentation_H_UIBP.Lobby_RoleInfo_CustomPresentation_H_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.None,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\231\164\190\228\186\164\229\144\141\231\137\135-\228\184\170\230\128\167\229\140\150\229\177\149\231\164\186-\230\168\170\229\144\145"
    }
  },
  friend_blacklist = {
    keyName = "friend_blacklist",
    moduleName = "client.slua.umg.friend.friend_blacklist",
    path = "/Game/UMG/UI_BP/Friend/Friend_Blacklist_UIBP.Friend_Blacklist_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    asy = true,
    uiStat = {
      name = "\229\165\189\229\143\139-\233\187\145\229\144\141\229\141\149"
    }
  },
  friend_applylist = {
    keyName = "friend_applylist",
    moduleName = "client.slua.umg.friend.friend_applylist",
    path = "/Game/UMG/UI_BP/Friend/Friend_Apply_UIBP.Friend_Apply_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    asy = true,
    uiStat = {
      name = "\229\165\189\229\143\139-\231\148\179\232\175\183\229\136\151\232\161\168"
    }
  },
  friend_new_search = {
    keyName = "friend_new_search",
    moduleName = "client.slua.umg.friend.friend_new_search",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/Friend_New_Search.Friend_New_Search",
    asy = true,
    jumpModuleID = BP_ENUM_MODULE_ADD_FRIEND,
    uiStat = {
      name = "\229\165\189\229\143\139-\230\183\187\229\138\160\229\165\189\229\143\139"
    }
  },
  friend_verify = {
    keyName = "friend_verify",
    moduleName = "client.slua.umg.friend.friend_verify",
    path = "/Game/UMG/UI_BP/Friend/Friend_Verify_UIBP.Friend_Verify_UIBP",
    asy = true,
    uiStat = {
      name = "\229\165\189\229\143\139-\231\149\153\232\168\128\232\175\183\230\177\130\230\183\187\229\138\160\229\165\189\229\143\139"
    }
  },
  ReportSucceed_Slap_UIBP = {
    keyName = "ReportSucceed_Slap_UIBP",
    moduleName = "client.slua.umg.security.ReportSucceed_Slap_UIBP",
    closeOnSwitch = false,
    path = "/Game/UMG/UI_BP/Lobby_Activity/Lobby_TipOff_Popup_UIBP.Lobby_TipOff_Popup_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\228\184\190\230\138\165\230\136\144\229\138\159-\230\139\141\232\132\184"
    }
  },
  ReportSucceed_Slap_Pro_UIBP = {
    keyName = "ReportSucceed_Slap_Pro_UIBP",
    moduleName = "client.slua.umg.security.ReportSucceed_Slap_Pro_UIBP",
    closeOnSwitch = false,
    path = "/Game/UMG/UI_BP/Lobby_Activity/Lobby_Ban_Popup_UIBP.Lobby_Ban_Popup_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\229\183\161\230\159\165\229\145\152\228\184\190\230\138\165\230\136\144\229\138\159-\230\139\141\232\132\184"
    }
  },
  newbie_lobby_task = {
    keyName = "newbie_lobby_task",
    moduleName = "client.slua.umg.newbie.newbie_lobby_task",
    path = "/Game/UMG/UI_BP/Lobby/Main/Tips/Lobby_Main_Tips_Missons_UIBP.Lobby_Main_Tips_Missons_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    containerName = UIContainers.Top
  },
  newbie_lobby_match = {
    keyName = "newbie_lobby_match",
    moduleName = "client.slua.umg.newbie.newbie_lobby_match",
    path = "/Game/UMG/UI_BP/Lobby/Main/Tips/Lobby_Main_Tips_Entry_UIBP.Lobby_Main_Tips_Entry_UIBP",
    AndroidBackType = EAndroidBackType.Ban
  },
  Lab_Main_Newbie_Slide_UIBP = {
    keyName = "Lab_Main_Newbie_Slide_UIBP",
    moduleName = "client.slua.umg.lobby.Main.Lab_Main_Newbie_Slide_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lab_Main_Newbie_Slide_UIBP.Lab_Main_Newbie_Slide_UIBP",
    AndroidBackType = EAndroidBackType.Skip
  },
  Lobby_Mid_Newbie_Tab_Close_UIBP = {
    keyName = "Lobby_Mid_Newbie_Tab_Close_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Newbie.Lobby_Mid_Newbie_Tab_Close_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Newbie/Lobby_Mid_Newbie_Tab_Close_UIBP.Lobby_Mid_Newbie_Tab_Close_UIBP",
    containerName = UIContainers.Top
  },
  ui_complaint_chat = {
    keyName = "ui_complaint_chat",
    moduleName = "client.slua.umg.complaint.ui_complaint_chat",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Chat_UIBP.Inform_Chat_UIBP",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\232\129\138\229\164\169"
    }
  },
  ui_complaint_intimateRelation = {
    keyName = "ui_complaint_intimateRelation",
    moduleName = "client.slua.umg.complaint.ui_complaint_intimateRelation",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Chat_UIBP.Inform_Chat_UIBP",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\228\186\178\229\175\134\229\133\179\231\179\187\232\135\170\229\174\154\228\185\137\231\167\176\229\145\188"
    }
  },
  home_message_report = {
    keyName = "home_message_report",
    moduleName = "client.slua.umg.Home.Report.home_message_report",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Chat_UIBP.Inform_Chat_UIBP",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\229\174\182\229\155\173\230\182\136\230\129\175\231\177\187\239\188\136\231\149\153\232\168\128\230\157\191\227\128\129\228\191\161\233\184\189\239\188\137"
    }
  },
  AchievementScoreAward_UIBP = {
    keyName = "AchievementScoreAward_UIBP",
    moduleName = "client.slua.umg.Achievement.AchievementScoreAward_UIBP",
    path = "/Game/UMG/UI_BP/Achievement/AchievementScoreAward_UIBP.AchievementScoreAward_UIBP",
    asy = true,
    uiStat = {
      name = "\230\136\144\229\176\177-\231\167\175\229\136\134\229\165\150\229\138\177"
    }
  },
  Achievement_Content_PK_UIBP = {
    keyName = "Achievement_Content_PK_UIBP",
    moduleName = "client.slua.umg.Achievement.Achievement_Content_PK_UIBP",
    path = "/Game/UMG/UI_BP/Achievement/Achievement_Content_PK_UIBP.Achievement_Content_PK_UIBP",
    asy = true,
    uiStat = {
      name = "\230\136\144\229\176\1772.0-PK"
    }
  },
  Achievement_Content_UIBP = {
    keyName = "Achievement_Content_UIBP",
    moduleName = "client.slua.umg.Achievement.Achievement_Content_UIBP",
    path = "/Game/UMG/UI_BP/Achievement/Achievement_Content_UIBP.Achievement_Content_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\136\144\229\176\177-\229\164\150\229\163\179"
    }
  },
  Achievement_Detail_1_UIBP = {
    keyName = "Achievement_Detail_1_UIBP",
    moduleName = "client.slua.umg.Achievement.Achievement_Detail_1_UIBP",
    path = "/Game/UMG/UI_BP/Achievement/Achievement_Detail_1_UIBP.Achievement_Detail_1_UIBP",
    asy = true,
    uiStat = {
      name = "\230\136\144\229\176\177-\232\175\166\230\131\1331"
    }
  },
  Achievement_Detail_2_UIBP = {
    keyName = "Achievement_Detail_2_UIBP",
    moduleName = "client.slua.umg.Achievement.Achievement_Detail_2_UIBP",
    path = "/Game/UMG/UI_BP/Achievement/Achievement_Detail_2_UIBP.Achievement_Detail_2_UIBP",
    asy = true,
    uiStat = {
      name = "\230\136\144\229\176\177-\232\175\166\230\131\1332"
    }
  },
  Achievement_Space_UIBP = {
    keyName = "Achievement_Space_UIBP",
    moduleName = "client.slua.umg.Achievement.Achievement_Space_UIBP",
    path = "/Game/UMG/UI_BP/Achievement/Achievement_Space_UIBP.Achievement_Space_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\136\144\229\176\177-\228\184\170\228\186\186\230\136\144\229\176\177-\228\187\150\228\186\186"
    }
  },
  Achievement_Summary_Loop_UIBP = {
    keyName = "Achievement_Summary_Loop_UIBP",
    moduleName = "client.slua.umg.Achievement.Achievement_Summary_Loop_UIBP",
    path = "/Game/UMG/UI_BP/Achievement/Achievement_Summary_Loop_UIBP.Achievement_Summary_Loop_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\136\144\229\176\177-\229\133\168\233\131\168\230\136\144\229\176\177"
    }
  },
  Achievement_Summary_Show_UIBP = {
    keyName = "Achievement_Summary_Show_UIBP",
    moduleName = "client.slua.umg.Achievement.Achievement_Summary_Show_UIBP",
    path = "/Game/UMG/UI_BP/Achievement/Achievement_Summary_Show_UIBP.Achievement_Summary_Show_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\136\144\229\176\177-\230\166\130\232\167\136"
    }
  },
  Achievement_Summary_Task_Item = {
    keyName = "Achievement_Summary_Task_Item",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/Achievement/Achievement_Summary_Task_Item.Achievement_Summary_Task_Item",
    isMainUI = false,
    isSingleton = false
  },
  Achievement_Task_UIBP = {
    keyName = "Achievement_Task_UIBP",
    moduleName = "client.slua.umg.Achievement.Achievement_Task_UIBP",
    path = "/Game/UMG/UI_BP/Achievement/Achievement_Task_UIBP.Achievement_Task_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\136\144\229\176\177-\228\184\170\228\186\186\230\136\144\229\176\177-\232\135\170\229\183\177"
    }
  },
  Common_Announcement_Medium_UIBP = {
    keyName = "Common_Announcement_Medium_UIBP",
    moduleName = "client.slua.umg.common.Common_Announcement_Medium_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Announcement_Medium_UIBP.Common_Announcement_Medium_UIBP",
    uiStat = {
      name = "\228\184\173\229\158\139\233\128\154\231\148\168\231\191\187\233\161\181\232\175\180\230\152\142\229\188\185\231\170\151"
    }
  },
  Common_Avatar_All_UIBP = {
    keyName = "Common_Avatar_All_UIBP",
    moduleName = "client.slua.component.avatar.Common_Avatar_All_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Avatar_All_UIBP.Common_Avatar_All_UIBP",
    isSingleton = false,
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.avatar_pool
  },
  Common_Item_BP = {
    keyName = "Common_Item_BP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_Logic/Common/Common_Item_BP.Common_Item_BP",
    isSingleton = false,
    isMainUI = false
  },
  Common_QR_Scan_UIBP = {
    keyName = "Common_QR_Scan_UIBP",
    moduleName = "client.slua.umg.common.Common_QR_Scan_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_QR_Scan_UIBP.Common_QR_Scan_UIBP",
    uiStat = {
      name = "\230\183\187\229\138\160\229\165\189\229\143\139-\228\186\140\231\187\180\231\160\129\230\137\171\230\143\143\231\149\140\233\157\162"
    }
  },
  Common_Room_Download_Popup_UIBP = {
    keyName = "Common_Room_Download_Popup_UIBP",
    moduleName = "client.slua.umg.common.Popup.Common_Room_Download_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Room_Download_Popup_UIBP.Common_Room_Download_Popup_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168-\230\136\152\230\150\151\229\156\176\229\155\190\228\184\139\232\189\189\230\143\144\231\164\186\233\162\157\229\164\150\229\188\185\231\170\151"
    }
  },
  Common_DownloadPopup_UIBP = {
    keyName = "Common_DownloadPopup_UIBP",
    moduleName = "client.slua.umg.common.Popup.Common_DownloadPopup_UIBP",
    path = "/Game/UMG/UI_BP/Common/Popup/Common_DownloadPopup_UIBP.Common_DownloadPopup_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168-\228\184\139\232\189\189\230\143\144\231\164\186\229\188\185\231\170\151"
    }
  },
  Common_Title_UIBP = {
    keyName = "Common_Title_UIBP",
    moduleName = "client.slua.component.common.Common_Title_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Title_UIBP.Common_Title_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.avatar_pool
  },
  Family_Information_Item = {
    keyName = "Family_Information_Item",
    moduleName = "client.slua.umg.popular_team_pk.item.Family_Information_Item",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/PK_UI/Item/Family_Information_Item.Family_Information_Item",
    isSingleton = false,
    uiStat = {
      name = "\233\152\159\228\188\141PK-\229\174\182\230\151\143\229\175\185\229\134\179\228\191\161\230\129\175item"
    }
  },
  Friendlimit_Tips = {
    keyName = "Friendlimit_Tips",
    moduleName = "client.slua.umg.lobby.Item.Friendlimit_Tips",
    path = "/Game/UMG/UI_BP/Lobby/Item/Friendlimit_Tips.Friendlimit_Tips",
    isMainUI = false,
    uiStat = {
      name = "\229\165\189\229\143\139\232\182\133\228\184\138\233\153\144\230\143\144\231\164\186"
    }
  },
  HomePhoto_Detail_UIBP = {
    keyName = "HomePhoto_Detail_UIBP",
    moduleName = "client.slua.umg.moment.HomePhoto_Detail_UIBP",
    path = "/Game/UMG/UI_BP/Moment/HomePhoto_Detail_UIBP.HomePhoto_Detail_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\231\155\184\229\134\140\233\161\181\231\173\190-\229\155\190\231\137\135\232\175\166\230\131\133"
    }
  },
  Home_Award_Tips_UIBP = {
    keyName = "Home_Award_Tips_UIBP",
    moduleName = "client.slua.umg.Home.Lobby.Home_Award_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Home/Detail/Item/Home_Award_Tips_UIBP.Home_Award_Tips_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\174\182\229\155\173\232\175\166\230\131\133-\229\174\182\229\155\173\229\165\150\229\138\177\230\176\148\230\179\161tip"
    },
    isMainUI = false,
    isSingleton = false
  },
  Home_Collection_Rank_UIBP = {
    keyName = "Home_Collection_Rank_UIBP",
    moduleName = "client.slua.umg.Home.Collection.Rank.Home_Collection_Rank_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/Collection/Rank/Home_Rank_UIBP.Home_Rank_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173-\233\155\134\229\144\136\233\161\181\230\142\146\232\161\140\230\166\156"
    }
  },
  Home_Collection_Task_UIBP = {
    keyName = "Home_Collection_Task_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.Collection.Home_Collection_Task_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Collection/Home_Collection_Task_UIBP.Home_Collection_Task_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173-\233\155\134\229\144\136\233\161\181\228\187\187\229\138\161"
    }
  },
  Home_Details_Tips_UIBP = {
    keyName = "Home_Details_Tips_UIBP",
    moduleName = "client.slua.umg.Home.Lobby.Home_Details_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Home/Detail/Item/Home_Details_Tips_UIBP.Home_Details_Tips_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\174\182\229\155\173\232\175\166\230\131\133-\229\174\182\229\155\173\230\176\148\230\179\161tip"
    }
  },
  Lobby_GoldSpin_Tips_UIBP = {
    keyName = "Lobby_GoldSpin_Tips_UIBP",
    moduleName = "client.slua.umg.team.Lobby_GoldSpin_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_GoldSpin_Tips_UIBP.Lobby_GoldSpin_Tips_UIBP",
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Skip,
    closeOnSwitch = false,
    zOrder = EFixedZOrder.Click_Animation,
    uiStat = {
      name = "\230\129\139\228\186\186\233\135\145\232\163\133tips"
    }
  },
  Lobby_RoleInfo_Gift_Exchange_UIBP = {
    keyName = "Lobby_RoleInfo_Gift_Exchange_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_Gift_Exchange_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Gift_Exchange_UIBP.Lobby_RoleInfo_Gift_Exchange_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148PK-\229\133\145\230\141\162\229\149\134\229\186\151"
    }
  },
  Lobby_RoleInfo_PK_UIBP = {
    keyName = "Lobby_RoleInfo_PK_UIBP",
    moduleName = "client.slua.umg.popular_gift_pk.Lobby_RoleInfo_PK_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_PK_UIBP.Lobby_RoleInfo_PK_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148PK-\228\184\187\233\161\181"
    }
  },
  Lobby_RoleInfo_Popularity_Match_UIBP = {
    keyName = "Lobby_RoleInfo_Popularity_Match_UIBP",
    moduleName = "client.slua.umg.popular_gift_pk.Lobby_RoleInfo_Popularity_Match_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Popularity_Match_UIBP.Lobby_RoleInfo_Popularity_Match_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148PK-\229\140\185\233\133\141\230\136\144\229\138\159"
    }
  },
  Lobby_RoleInfo_Popularity_Pk_UIBP = {
    keyName = "Lobby_RoleInfo_Popularity_Pk_UIBP",
    moduleName = "client.slua.umg.popular_gift_pk.Lobby_RoleInfo_Popularity_Pk_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_Popularity_Pk_UIBP.Lobby_RoleInfo_Popularity_Pk_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148PK-PK\233\161\181\233\157\162"
    }
  },
  MillionUC_Main_UIBP = {
    keyName = "MillionUC_Main_UIBP",
    moduleName = "client.slua.umg.MixItem.EasterEgg.MillionUC.MillionUC_Main_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/MillionUC/MillionUC_Main_UIBP.MillionUC_Main_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\231\153\190\228\184\135UC\229\189\169\232\155\139-\228\184\187\231\149\140\233\157\162"
    }
  },
  MillionUC_Cheque_UIBP = {
    keyName = "MillionUC_Cheque_UIBP",
    moduleName = "client.slua.umg.MixItem.EasterEgg.MillionUC.MillionUC_Cheque_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/MillionUC/MillionUC_Cheque_UIBP.MillionUC_Cheque_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\153\190\228\184\135UC\229\189\169\232\155\139-\230\148\175\231\165\168UI"
    }
  },
  MillionUC_Signature_UIBP = {
    keyName = "MillionUC_Signature_UIBP",
    moduleName = "client.slua.umg.MixItem.EasterEgg.MillionUC.MillionUC_Signature_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/MillionUC/MillionUC_Signature_UIBP.MillionUC_Signature_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\153\190\228\184\135UC\229\189\169\232\155\139-\231\173\190\229\144\141UI"
    }
  },
  MillionUC_PreviewAward_UIBP = {
    keyName = "MillionUC_PreviewAward_UIBP",
    moduleName = "client.slua.umg.MixItem.EasterEgg.MillionUC.MillionUC_PreviewAward_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/MillionUC/MillionUC_PreviewAward_UIBP.MillionUC_PreviewAward_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\153\190\228\184\135UC\229\189\169\232\155\139-\233\162\132\232\167\136\229\165\150\229\138\177"
    }
  },
  MillionUC_SelectAward_UIBP = {
    keyName = "MillionUC_SelectAward_UIBP",
    moduleName = "client.slua.umg.MixItem.EasterEgg.MillionUC.MillionUC_SelectAward_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/MillionUC/MillionUC_SelectAward_UIBP.MillionUC_SelectAward_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\153\190\228\184\135UC\229\189\169\232\155\139-\233\128\137\230\139\169\229\165\150\229\138\177"
    }
  },
  MillionUC_Protocol_UIBP = {
    keyName = "MillionUC_Protocol_UIBP",
    moduleName = "client.slua.umg.MixItem.EasterEgg.MillionUC.MillionUC_Protocol_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/MillionUC/MillionUC_Protocol_UIBP.MillionUC_Protocol_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\153\190\228\184\135UC\229\189\169\232\155\139-\229\141\143\232\174\174UI"
    }
  },
  MixItem_CollectReward_UIBP = {
    keyName = "MixItem_CollectReward_UIBP",
    moduleName = "client.slua.umg.MixItem.MixItem_CollectReward_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/Main/MixItem_CollectReward_UIBP.MixItem_CollectReward_UIBP",
    uiStat = {
      name = "\232\161\165\231\187\153-\230\183\183\229\144\136\231\137\169-\231\137\185\230\174\138\229\189\169\232\155\139\233\162\134\229\165\150"
    }
  },
  MixItem_EasterEggError_UIBP = {
    keyName = "MixItem_EasterEggError_UIBP",
    moduleName = "client.slua.umg.MixItem.MixItem_EasterEggError_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/Main/MixItem_EasterEggError_UIBP.MixItem_EasterEggError_UIBP",
    uiStat = {
      name = "\232\161\165\231\187\153-\230\183\183\229\144\136\231\137\169-\229\189\169\232\155\139-404NotFoundError"
    }
  },
  MixItem_ImagePreview_UIBP = {
    keyName = "MixItem_ImagePreview_UIBP",
    moduleName = "client.slua.umg.MixItem.MixItem_ImagePreview_UIBP",
    path = "/Game/UMG/UI_BP/LobbyChat/LobbyChat_170/Chat_NewBigImage_UIBP.Chat_NewBigImage_UIBP",
    uiStat = {
      name = "\232\161\165\231\187\153-\230\183\183\229\144\136\231\137\169-\229\189\169\232\155\139-\231\173\150\229\136\146\232\129\138\229\164\169\233\162\145\233\129\147-\229\164\167\229\155\190\233\162\132\232\167\136"
    },
    containerName = UIContainers.Top
  },
  MomentAddPhoto = {
    keyName = "MomentAddPhoto",
    moduleName = "client.slua.umg.moment.ui_moment_add_photo",
    path = "/Game/UMG/UI_BP/Moment/Moment_Photo_Add_UIBP.Moment_Photo_Add_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\230\183\187\229\138\160\229\155\190\231\137\135\231\149\140\233\157\162"
    }
  },
  MomentAlbumTab = {
    keyName = "MomentAlbumTab",
    moduleName = "client.slua.umg.moment.ui_moment_album_tab",
    path = "/Game/UMG/UI_BP/Moment/Moment_Photo_Tab_UIBP.Moment_Photo_Tab_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\184\184\230\136\143\231\155\184\229\134\140\233\161\181\231\173\190"
    }
  },
  MomentAlbumTabPhotoDetail = {
    keyName = "MomentAlbumTabPhotoDetail",
    moduleName = "client.slua.umg.moment.ui_moment_tab_photo_detail",
    path = "/Game/UMG/UI_BP/Moment/Moment_Photo_Detail_UIBP.Moment_Photo_Detail_UIBP",
    uiStat = {
      name = "\230\184\184\230\136\143\231\155\184\229\134\140\233\161\181\231\173\190-\229\155\190\231\137\135\232\175\166\230\131\133"
    }
  },
  MomentDetail = {
    keyName = "MomentDetail",
    moduleName = "client.slua.umg.moment.ui_moment_detail",
    path = "/Game/UMG/UI_BP/Moment/Popup/Moment_Detail_UIBP.Moment_Detail_UIBP",
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\229\138\168\230\128\129\232\175\166\231\187\134\228\191\161\230\129\175\231\149\140\233\157\162"
    }
  },
  MomentFriendMessage = {
    keyName = "MomentFriendMessage",
    moduleName = "client.slua.umg.moment.ui_moment_friend_message",
    path = "/Game/UMG/UI_BP/Moment/Moment_Friend_UIBP.Moment_Friend_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\230\156\139\229\143\139\229\138\168\230\128\129\231\149\140\233\157\162"
    }
  },
  MomentHotMessage = {
    keyName = "MomentHotMessage",
    moduleName = "client.slua.umg.moment.ui_moment_hot_message",
    path = "/Game/UMG/UI_BP/Moment/Item/Moment_My_square_Item_UIBP.Moment_My_square_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\230\136\145\231\154\132\231\131\173\233\151\168\229\138\168\230\128\129"
    }
  },
  MomentHotMessageTab = {
    keyName = "MomentHotMessageTab",
    moduleName = "client.slua.umg.moment.ui_moment_hot_message_tab",
    path = "/Game/UMG/UI_BP/Moment/Moment_My_square_UIBP.Moment_My_square_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\231\131\173\231\130\185\230\160\135\231\173\190\230\160\143\231\149\140\233\157\162"
    }
  },
  MomentMain = {
    keyName = "MomentMain",
    moduleName = "client.slua.umg.moment.ui_moment_main",
    path = "/Game/UMG/UI_BP/Moment/Moment_Main_UIBP.Moment_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_MOMENT,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\228\184\187\231\149\140\233\157\162"
    }
  },
  MomentMyMessage = {
    keyName = "MomentMyMessage",
    moduleName = "client.slua.umg.moment.ui_moment_my_message",
    path = "/Game/UMG/UI_BP/Moment/Moment_My_UIBP.Moment_My_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\230\136\145\231\154\132\229\138\168\230\128\129\231\149\140\233\157\162"
    }
  },
  MomentOtherMain = {
    keyName = "MomentOtherMain",
    moduleName = "client.slua.umg.moment.ui_moment_main_other",
    path = "/Game/UMG/UI_BP/Moment/Moment_Main_UIBP.Moment_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_MOMENT_OTHER,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\228\187\150\228\186\186\228\184\187\231\149\140\233\157\162"
    }
  },
  MomentPhotoPreview = {
    keyName = "MomentPhotoPreview",
    moduleName = "client.slua.umg.moment.ui_moment_photo_preview",
    path = "/Game/UMG/UI_BP/Moment/Moment_Photo_Look_UIBP.Moment_Photo_Look_UIBP",
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\229\138\168\230\128\129\230\159\165\231\156\139\229\155\190\231\137\135\231\149\140\233\157\162"
    }
  },
  MomentReleaseMessage = {
    keyName = "MomentReleaseMessage",
    moduleName = "client.slua.umg.moment.ui_moment_release_message",
    path = "/Game/UMG/UI_BP/Moment/Popup/Moment_ReleaseMessage_UIBP.Moment_ReleaseMessage_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\229\143\145\229\184\131\229\138\168\230\128\129\231\149\140\233\157\162"
    }
  },
  MomentSquare = {
    keyName = "MomentSquare",
    moduleName = "client.slua.umg.moment.ui_moment_wowsquare",
    path = "/Game/UMG/UI_BP/Moment/Moment_Main_UIBP.Moment_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_MOMENT,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\229\185\191\229\156\186"
    }
  },
  MomentSquareHotMessage = {
    keyName = "MomentSquareHotMessage",
    moduleName = "client.slua.umg.moment.ui_moment_wowsquare_message",
    path = "/Game/UMG/UI_BP/Moment/Moment_WowSquare_UIBP.Moment_WowSquare_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\189\156\229\147\129\229\185\191\229\156\186\231\154\132\231\131\173\233\151\168\229\138\168\230\128\129"
    }
  },
  MomentSquareMessage = {
    keyName = "MomentSquareMessage",
    moduleName = "client.slua.umg.moment.ui_moment_square_message",
    path = "/Game/UMG/UI_BP/Moment/Item/Moment_My_square_Item_UIBP.Moment_My_square_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\230\136\145\231\154\132\229\185\191\229\156\186\229\138\168\230\128\129"
    }
  },
  MomentTip = {
    keyName = "MomentTip",
    moduleName = "client.slua.umg.moment.ui_moment_tip",
    path = "/Game/UMG/UI_BP/Moment/Moment_Tips_UIBP.Moment_Tips_UIBP",
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\231\130\185\232\181\158\230\143\144\231\164\186"
    }
  },
  Moment_BackGround_Use_UIBP = {
    keyName = "Moment_BackGround_Use_UIBP",
    moduleName = "client.slua.umg.moment.Popup.Moment_BackGround_Use_UIBP",
    path = "/Game/UMG/UI_BP/Moment/Popup/Moment_BackGround_Use_UIBP.Moment_BackGround_Use_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\165\189\229\143\139\229\156\136\228\184\170\230\128\167\229\138\168\230\128\129\232\131\140\230\153\175\228\189\191\231\148\168\231\149\140\233\157\162"
    }
  },
  Moment_KillTime_Tab = {
    keyName = "Moment_KillTime_Tab",
    moduleName = "client.slua.umg.moment.Moment_KillTime_Tab",
    path = "/Game/UMG/UI_BP/WonderfulReplay/Popup/Replay_Forwarding_UIBP.Replay_Forwarding_UIBP",
    uiStat = {
      name = "\231\178\190\229\189\169\230\151\182\229\136\187\229\165\189\229\143\139\229\156\136\229\136\134\228\186\171"
    }
  },
  Moment_KillTime_UIBP = {
    keyName = "Moment_KillTime_UIBP",
    moduleName = "client.slua.umg.moment.Moment_KillTime_UIBP",
    path = "/Game/UMG/UI_BP/WonderfulReplay/Popup/Replay_Forwarding_UIBP.Replay_Forwarding_UIBP",
    uiStat = {
      name = "\231\178\190\229\189\169\230\151\182\229\136\187\230\156\139\229\143\139\229\156\136\229\136\134\228\186\171"
    }
  },
  Moment_My_Item_Bg = {
    keyName = "Moment_My_Item_Bg",
    moduleName = "client.slua.umg.moment.item.BackGround.Moment_My_Item_Bg",
    path = "",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\165\189\229\143\139\229\156\136-\232\131\140\230\153\175\233\129\147\229\133\183-\232\131\140\230\153\175\232\147\157\229\155\190"
    }
  },
  Moment_PopupTip_UIBP = {
    keyName = "Moment_PopupTip_UIBP",
    moduleName = "client.slua.umg.moment.Popup.Moment_PopupTip_UIBP",
    path = "/Game/UMG/UI_BP/Moment/Popup/Moment_PopupTip_UIBP.Moment_PopupTip_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\229\165\189\229\143\139\229\156\136\230\176\148\230\179\161\230\143\144\231\164\186"
    }
  },
  Moment_Shot_Share_UIBP = {
    keyName = "Moment_Shot_Share_UIBP",
    moduleName = "client.slua.umg.moment.Moment_Shot_Share_UIBP",
    path = "/Game/UMG/UI_BP/Moment/Popup/Moment_Shot_Share_UIBP.Moment_Shot_Share_UIBP",
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\230\136\170\229\177\143\231\155\145\229\144\172"
    }
  },
  PlanPH_Download_Popup_UIBP = {
    keyName = "PlanPH_Download_Popup_UIBP",
    moduleName = "client.slua.umg.Home.Lobby.Popup.PlanPH_Download_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Home/Detail/Popup/PlanPH_Download_Popup_UIBP.PlanPH_Download_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\174\182\229\155\173\232\175\166\230\131\133-\229\174\182\229\155\173\229\165\150\229\138\177\229\188\185\231\170\151tips"
    }
  },
  Popular_Forecast_UIBP = {
    keyName = "Popular_Forecast_UIBP",
    moduleName = "client.slua.umg.lobby_activity.Popular_TeamPK.PK_UI.PopUI.Popular_Forecast_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/PK_UI/PopUI/Popular_Forecast_UIBP.Popular_Forecast_UIBP",
    uiStat = {
      name = "\233\152\159\228\188\141PK-\230\156\172\229\177\128\233\162\132\228\188\176\229\190\151\229\136\134"
    }
  },
  Popular_TeamPK_ApplyMsg_UIBP = {
    keyName = "Popular_TeamPK_ApplyMsg_UIBP",
    moduleName = "client.slua.umg.popular_team_pk.Popular_TeamPK_ApplyMsg_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/PK_UI/PopUI/Popular_TeamPK_ApplyMsg_UIBP.Popular_TeamPK_ApplyMsg_UIBP",
    uiStat = {
      name = "\233\152\159\228\188\141PK-\231\187\132\233\152\159\230\182\136\230\129\175\229\136\151\232\161\168\229\188\185\231\170\151"
    }
  },
  Popular_TeamPK_Awards_UIBP = {
    keyName = "Popular_TeamPK_Awards_UIBP",
    moduleName = "client.slua.umg.popular_team_pk.Popular_TeamPK_Awards_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/PK_UI/Popular_TeamPK_Awards_UIBP.Popular_TeamPK_Awards_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\152\159\228\188\141PK-\229\165\150\229\138\177\233\161\181\233\157\162"
    }
  },
  Popular_TeamPK_Enroll_UIBP = {
    keyName = "Popular_TeamPK_Enroll_UIBP",
    moduleName = "client.slua.umg.popular_team_pk.Popular_TeamPK_Enroll_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/PK_UI/Popular_TeamPK_Enroll_UIBP.Popular_TeamPK_Enroll_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\152\159\228\188\141PK-\230\138\165\229\144\141\233\161\181\233\157\162"
    }
  },
  Popular_TeamPK_Family_UIBP = {
    keyName = "Popular_TeamPK_Family_UIBP",
    moduleName = "client.slua.umg.popular_team_pk.Popular_TeamPK_Family_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/PK_UI/Popular_TeamPK_Family_UIBP.Popular_TeamPK_Family_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\152\159\228\188\141PK-\229\174\182\230\151\143\233\161\181\233\157\162"
    }
  },
  Popular_TeamPK_InviteTeam_UIBP = {
    keyName = "Popular_TeamPK_InviteTeam_UIBP",
    moduleName = "client.slua.umg.popular_team_pk.Popular_TeamPK_InviteTeam_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/PK_UI/PopUI/Popular_TeamPK_InviteTeam_UIBP.Popular_TeamPK_InviteTeam_UIBP",
    uiStat = {
      name = "\233\152\159\228\188\141PK-\233\130\128\232\175\183\231\187\132\233\152\159\229\188\185\231\170\151"
    }
  },
  Popular_TeamPK_Main_UIBP = {
    keyName = "Popular_TeamPK_Main_UIBP",
    moduleName = "client.slua.umg.popular_team_pk.Popular_TeamPK_Main_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/PK_UI/Popular_TeamPK_Main_UIBP.Popular_TeamPK_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\152\159\228\188\141PK-\228\184\187\233\161\181"
    }
  },
  Popular_TeamPK_Match_UIBP = {
    keyName = "Popular_TeamPK_Match_UIBP",
    moduleName = "client.slua.umg.popular_team_pk.Popular_TeamPK_Match_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/PK_UI/Popular_TeamPK_Match_UIBP.Popular_TeamPK_Match_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\152\159\228\188\141PK-\229\140\185\233\133\141\231\149\140\233\157\162"
    }
  },
  Popular_TeamPK_PkRecord_UIBP = {
    keyName = "Popular_TeamPK_PkRecord_UIBP",
    moduleName = "client.slua.umg.popular_team_pk.Popular_TeamPK_PkRecord_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/PK_UI/PopUI/Popular_TeamPK_PkRecord_UIBP.Popular_TeamPK_PkRecord_UIBP",
    uiStat = {
      name = "\233\152\159\228\188\141PK-\229\175\185\229\134\179\232\174\176\229\189\149"
    }
  },
  Popular_TeamPK_Pk_UIBP = {
    keyName = "Popular_TeamPK_Pk_UIBP",
    moduleName = "client.slua.umg.popular_team_pk.Popular_TeamPK_Pk_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/PK_UI/Popular_TeamPK_Pk_UIBP.Popular_TeamPK_Pk_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\152\159\228\188\141PK-1V1PK\233\161\181\233\157\162"
    }
  },
  Popular_TeamPK_Settlement_UIBP = {
    keyName = "Popular_TeamPK_Settlement_UIBP",
    moduleName = "client.slua.umg.popular_team_pk.Popular_TeamPK_Settlement_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/PK_UI/Popular_TeamPK_Settlement_UIBP.Popular_TeamPK_Settlement_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\152\159\228\188\141PK-\231\187\147\231\174\151\233\161\181\233\157\162"
    }
  },
  Popular_TeamPK_Tips_UIBP = {
    keyName = "Popular_TeamPK_Tips_UIBP",
    moduleName = "client.slua.umg.popular_team_pk.Popular_TeamPK_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Popular_TeamPK/PK_UI/Popular_TeamPK_Tips_UIBP.Popular_TeamPK_Tips_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\152\159\228\188\141PK-\231\164\190\228\186\164\229\164\167\229\142\133\229\143\179\228\184\139\232\167\146\232\191\155\229\186\166\230\143\144\231\164\186"
    }
  },
  PopupTip = {
    keyName = "PopupTip",
    moduleName = "client.slua.umg.common.notice_tip",
    path = "/Game/UMG/UI_BP/PopupNotice/PopupNoticeNew.PopupNoticeNew",
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Skip,
    closeOnSwitch = false,
    zOrder = EFixedZOrder.TopZOrder + 1,
    uiStat = {
      name = "\230\181\174\229\173\151\230\143\144\231\164\186"
    }
  },
  PopupTipHoldItem = {
    keyName = "PopupTipHoldItem",
    moduleName = "client.slua.umg.common.notice_tip_hold_item",
    path = "/Game/UMG/UI_BP/PopupNotice/ItemPopUpHold.ItemPopUpHold",
    isSingleton = false,
    uiStat = {
      name = "\230\181\174\229\173\151\230\143\144\231\164\186-Item"
    }
  },
  PopupTipItem = {
    keyName = "PopupTipItem",
    moduleName = "client.slua.umg.common.notice_tip_item",
    path = "/Game/UMG/UI_BP/PopupNotice/ItemPopUpItem.ItemPopUpItem",
    isSingleton = false,
    closeOnSwitch = false,
    asy = true,
    uiStat = {
      name = "\230\181\174\229\173\151\230\143\144\231\164\186-Item"
    }
  },
  UpgradeItemPopUpItem = {
    keyName = "PopupTipItem",
    moduleName = "client.slua.umg.common.UpgradeNoticeTipItem",
    path = "/Game/UMG/UI_BP/PopupNotice/ItemPopUpItem.ItemPopUpItem",
    isSingleton = false,
    closeOnSwitch = false,
    asy = true,
    uiStat = {
      name = "\231\160\148\231\169\182\230\137\128\230\181\174\229\173\151\230\143\144\231\164\186-Item"
    }
  },
  Revise_Home_Name_Popup_UIBP = {
    keyName = "Revise_Home_Name_Popup_UIBP",
    moduleName = "client.slua.umg.Home.Detail.Revise_Home_Name_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Home/Detail/Popup/Revise_Home_Name_Popup_UIBP.Revise_Home_Name_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\229\174\182\229\155\173-\228\191\174\230\148\185\229\174\182\229\155\173\229\144\141"
    }
  },
  SelectAchievement_UIBP = {
    keyName = "SelectAchievement_UIBP",
    moduleName = "client.slua.umg.Achievement.SelectAchievement_UIBP",
    path = "/Game/UMG/UI_BP/Achievement/SelectAchievement_UIBP.SelectAchievement_UIBP",
    asy = true,
    uiStat = {
      name = "\230\136\144\229\176\177-\233\128\137\230\139\169"
    }
  },
  Setting_QuickMsgGuide_UIBP = {
    keyName = "Setting_QuickMsgGuide_UIBP",
    moduleName = "client.slua.umg.setting.item.Setting_QuickMsgGuide_UIBP",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_QuickMsgGuide_UIBP.Setting_QuickMsgGuide_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\228\187\147\229\186\147-\229\191\171\230\141\183\232\175\173\233\159\179\233\133\141\231\189\174\230\150\176\230\137\139\229\188\149\229\175\188"
    }
  },
  Setting_UnBindChoice_Panel = {
    keyName = "Setting_UnBindChoice_Panel",
    moduleName = "client.slua.umg.setting.Account.Popup.Setting_UnBindChoice_Panel",
    path = "/Game/UMG/UI_BP/Setting/Account/Popup/Setting_BindChoice_Panel.Setting_BindChoice_Panel",
    isMainUI = false,
    uiStat = {
      name = "\232\180\166\229\143\183\230\149\143\230\132\159\230\147\141\228\189\156-\231\164\190\228\186\164\232\167\163\231\187\145\230\184\160\233\129\147\233\128\137\230\139\169"
    }
  },
  Setting_UnbindPopup_New = {
    keyName = "Setting_UnbindPopup_New",
    moduleName = "client.slua.umg.setting.Account.Popup.Setting_UnbindPopup_New",
    path = "/Game/UMG/UI_BP/Setting/Account/Popup/Setting_UnbindPopup.Setting_UnbindPopup",
    isMainUI = false,
    uiStat = {
      name = "\232\180\166\229\143\183\230\149\143\230\132\159\230\147\141\228\189\156-\231\164\190\228\186\164\232\167\163\231\187\145"
    }
  },
  Setting_Update_Phone_Mail_Verify_UIBP = {
    keyName = "Setting_Update_Phone_Mail_Verify_UIBP",
    moduleName = "client.slua.umg.setting.Setting_Update_Phone_Mail_Verify_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_Update_Phone_Mail_Verify_UIBP.Setting_Update_Phone_Mail_Verify_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\230\137\139\230\156\186\233\130\174\231\174\177\233\170\140\232\175\129"
    }
  },
  Store_Buy_Slua_BP = {
    keyName = "Store_Buy_Slua_BP",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.buy.Store_Buy_Slua_BP",
    path = "/Game/UMG/UI_BP/NewStore/Buy/Store_Buy_Slua_BP.Store_Buy_Slua_BP",
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142-\232\180\173\228\185\176\231\149\140\233\157\162slua"
    }
  },
  bulletin_image = {
    keyName = "bulletin_image",
    moduleName = "client.slua.umg.activity.bulletin_board.bulletin_image",
    isSingleton = false,
    path = "/Game/UMG/UI_BP/Lobby_Activity/Bulletin_Board/Bulletin_Board_Item1.Bulletin_Board_Item1",
    isMainUI = false
  },
  bulletin_image_anniversary = {
    keyName = "bulletin_image_anniversary",
    moduleName = "client.slua.umg.activity.bulletin_board.bulletin_image_anniversary",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Bulletin_Board/Bulletin_Board_Anniversary_Item1.Bulletin_Board_Anniversary_Item1",
    isMainUI = false
  },
  bulletin_reward = {
    keyName = "bulletin_reward",
    moduleName = "client.slua.umg.activity.bulletin_board.bulletin_reward",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Bulletin_Board/Bulletin_Board_Item2.Bulletin_Board_Item2",
    isMainUI = false
  },
  bulletin_reward_anniversary = {
    keyName = "bulletin_reward_anniversary",
    moduleName = "client.slua.umg.activity.bulletin_board.bulletin_reward_anniversary",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Bulletin_Board/Bulletin_Board_Anniversary_Item2.Bulletin_Board_Anniversary_Item2",
    isMainUI = false
  },
  bulletin_share = {
    keyName = "bulletin_share",
    moduleName = "client.slua.umg.activity.bulletin_board.bulletin_share",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Bulletin_Board/Bulletin_Share_BP.Bulletin_Share_BP"
  },
  common_questionmark_style_one = {
    keyName = "common_questionmark_style_one",
    moduleName = "client.slua.umg.common..questionmark.common_questionmark_style_one",
    path = "/Game/UMG/UI_BP/PopupNotice/QuestionMark/QuestionMark_Popup_01_UIBP.QuestionMark_Popup_01_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\151\174\229\143\183\230\152\190\231\164\186\231\149\140\233\157\162-\231\177\187\229\158\1391"
    }
  },
  common_questionmark_style_three = {
    keyName = "common_questionmark_style_three",
    moduleName = "client.slua.umg.common.questionmark.common_questionmark_style_three",
    path = "/Game/UMG/UI_BP/PopupNotice/QuestionMark/QuestionMark_Tips_UIBP.QuestionMark_Tips_UIBP",
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.Click_Animation + 1,
    uiStat = {
      name = "\233\151\174\229\143\183\230\152\190\231\164\186\231\149\140\233\157\162-\231\177\187\229\158\1393"
    }
  },
  common_questionmark_style_two = {
    keyName = "common_questionmark_style_two",
    moduleName = "client.slua.umg.common.questionmark.common_questionmark_style_two",
    path = "/Game/UMG/UI_BP/PopupNotice/QuestionMark/QuestionMark_Popup_02_UIBP.QuestionMark_Popup_02_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\151\174\229\143\183\230\152\190\231\164\186\231\149\140\233\157\162-\231\177\187\229\158\1392"
    }
  },
  common_questionmark_style_three_wowInGame = {
    keyName = "common_questionmark_style_three_wowInGame",
    moduleName = "client.slua.umg.common.questionmark.common_questionmark_style_three",
    path = "/Game/Mod/CreativeEdit/UMG/Common/UGC_QuestionMark_Tips_UIBP.UGC_QuestionMark_Tips_UIBP",
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.Click_Animation + 1,
    uiStat = {
      name = "\233\151\174\229\143\183\230\152\190\231\164\186\231\149\140\233\157\162-\231\177\187\229\158\1393-wow\229\177\128\229\134\133"
    }
  },
  common_questionmark_style_three_wow = {
    keyName = "common_questionmark_style_three_wow",
    moduleName = "client.slua.umg.common.questionmark.common_questionmark_style_three",
    path = "/Game/UMG/UI_BP/UGC/Tips/UGC_QuestionMark_Tips_UIBP.UGC_QuestionMark_Tips_UIBP",
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.Click_Animation + 1,
    uiStat = {
      name = "\233\151\174\229\143\183\230\152\190\231\164\186\231\149\140\233\157\162-\231\177\187\229\158\1393-wow\229\164\167\229\142\133"
    }
  },
  loading = {
    keyName = "loading",
    moduleName = "client.slua.umg.loading.ui_loading",
    path = "/Game/UMG/UI_BP/LoginLoading/Login_LoadingNew_UIBP.Login_LoadingNew_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    closeOnSwitch = false,
    zOrder = EFixedZOrder.TopZOrder,
    containerName = UIContainers.Top,
    loadFromPool = EUIConfigPoolType.None,
    enableCDNCompress = true,
    uiStat = {name = "LoadingUI"}
  },
  lobby_social_attach = {
    keyName = "lobby_social_attach",
    moduleName = "client.slua.umg.lobby.Left.lobby_social_attach",
    path = "/Game/UMG/UI_BP/Lobby/Left/Lobby_Social_Attach_UIBP.Lobby_Social_Attach_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\231\164\190\228\186\164\229\164\167\229\142\133-\233\128\154\231\148\168\230\140\130\232\189\189\231\149\140\233\157\162"
    },
    isSingleton = false
  },
  lobby_social_music = {
    keyName = "lobby_social_music",
    moduleName = "client.slua.umg.lobby.Left.lobby_social_music",
    path = "/Game/UMG/UI_BP/Lobby/Left/Lobby_Left_Music_UIBP.Lobby_Left_Music_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\233\159\179\228\185\144\232\175\149\229\144\172"
    },
    isSingleton = false
  },
  moment_gesture_operate_component = {
    keyName = "moment_gesture_operate_component",
    moduleName = "client.slua.umg.WeaponDIY.component.gesture_operate_component",
    path = "/Game/UMG/UI_BP/Moment/Moment_Gesture_Operate_Component_UIBP.Moment_Gesture_Operate_Component_UIBP",
    isSingleton = false,
    isMainUI = false
  },
  rate_panel_ui = {
    keyName = "rate_panel_ui",
    moduleName = "client.slua.umg.rate.rate_panel_ui",
    path = "/Game/UMG/UI_BP/Lobby_Store_Int/ODDS_UIBP.ODDS_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\128\154\231\148\168\230\166\130\231\142\135\231\149\140\233\157\162"
    }
  },
  setting_associate_mail = {
    keyName = "setting_associate_mail",
    moduleName = "client.slua.umg.NewSetting.Account.Popup.Setting_associate_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_associate_Popup_UIBP.Setting_associate_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\229\133\179\232\129\148\233\130\174\231\174\177\229\185\182\229\188\128\229\144\175\233\170\140\232\175\129"
    }
  },
  Setting_login_phone_UIBP = {
    keyName = "setting_login_phone_UIBP",
    moduleName = "client.slua.umg.setting.Account.Popup.Setting_login_phone_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Account/Popup/Setting_login_phone_UIBP.Setting_login_phone_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\180\166\229\143\183\230\149\143\230\132\159\230\147\141\228\189\156-\233\130\174\231\174\177\231\153\187\229\189\149or\231\187\145\229\174\154"
    }
  },
  setting_phone_mail = {
    keyName = "setting_phone_mail",
    moduleName = "client.slua.umg.setting.setting_phone_mail",
    path = "/Game/UMG/UI_BP/Setting/Setting_login_phone_UIBP.Setting_login_phone_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\230\137\139\230\156\186\233\130\174\231\174\177\231\153\187\229\189\149"
    }
  },
  setting_phone_mail_select = {
    keyName = "setting_phone_mail_select",
    moduleName = "client.slua.umg.setting.setting_phone_mail_select",
    path = "/Game/UMG/UI_BP/Setting/item/Setting_Basic_Phone_Email_UIBP.Setting_Basic_Phone_Email_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\230\137\139\230\156\186\233\130\174\231\174\177\231\153\187\229\189\149\233\128\137\230\139\169"
    }
  },
  setting_update_phone_mail = {
    keyName = "setting_update_phone_mail",
    moduleName = "client.slua.umg.setting.Setting_Update_Phone_Mail_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_Update_Phone_Mail_UIBP.Setting_Update_Phone_Mail_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\230\137\139\230\156\186\233\130\174\231\174\177\228\191\174\230\148\185"
    }
  },
  setting_update_phone_mail_cond = {
    keyName = "setting_update_phone_mail_cond",
    moduleName = "client.slua.umg.setting.Setting_Update_Phone_Mail_Cond_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_Update_Phone_Mail_Cond_UIBP.Setting_Update_Phone_Mail_Cond_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\230\137\139\230\156\186\233\130\174\231\174\177\228\191\174\230\148\185\230\157\161\228\187\182"
    }
  },
  setting_update_phone_mail_fast_cond = {
    keyName = "setting_update_phone_mail_fast_cond",
    moduleName = "client.slua.umg.setting.Setting_Update_Phone_Mail_Fast_Cond_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_Update_Phone_Mail_Fast_Cond_UIBP.Setting_Update_Phone_Mail_Fast_Cond_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\230\137\139\230\156\186\233\130\174\231\174\177\228\191\174\230\148\185\229\191\171\233\128\159\230\157\161\228\187\182"
    }
  },
  team_comp_loading = {
    keyName = "team_comp_loading",
    moduleName = "client.slua.umg.loading.ui_teamcomp_loading",
    path = "/Game/UMG/UI_BP/LoginLoading/Team_competition/Lobby_Team_competitionNew_UIBP.Lobby_Team_competitionNew_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    loadFromPool = EUIConfigPoolType.None,
    closeOnSwitch = false,
    zOrder = EFixedZOrder.TopZOrder,
    containerName = UIContainers.Top,
    uiStat = {
      name = "LoadingUI-\229\155\162\231\171\158"
    }
  },
  Activity_RPTask_UIBP = {
    keyName = "Activity_RPTask_UIBP",
    moduleName = "client.slua.umg.activity.new_activity_center.Activity_RPTask_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Act_RP_Task_UIBP.Act_RP_Task_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-rp\229\145\168\228\187\187\229\138\161"
    }
  },
  Agreement_FairPlay_Popup = {
    keyName = "Agreement_FairPlay_Popup",
    moduleName = "client.slua.umg.common.Agreement_FairPlay_Popup",
    path = "/Game/UMG/UI_BP/Common/Common_FairPlay_UIBP.Common_FairPlay_UIBP",
    containerName = UIContainers.Top,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\229\133\172\229\185\179\231\171\158\230\138\128\229\141\143\232\174\174"
    }
  },
  Arena_Season_Segment_Chart_UIBP = {
    keyName = "Arena_Season_Segment_Chart_UIBP",
    moduleName = "client.slua.umg.ModeSelection.Arena_Season_Segment_Chart_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Lobby_PeakGame_Chart_UIBP.Lobby_PeakGame_Chart_UIBP",
    uiStat = {
      name = "\229\155\162\233\152\159\230\142\146\228\189\141-\232\175\180\230\152\142\229\188\185\231\170\151\230\174\181\228\189\141\231\177\187\229\158\139\232\161\168\230\160\188"
    },
    isMainUI = false,
    isSingleton = false
  },
  BindErrorPopup = {
    keyName = "BindErrorPopup",
    moduleName = "client.slua.umg.NewSetting.Account.Popup.BindErrorPopup",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Popup_Hint_UIBP.Inform_Popup_Hint_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\232\180\166\229\143\183-\231\187\145\229\174\154\229\164\177\232\180\165\229\188\185\231\170\151"
    }
  },
  BlackFriday_InvitationRecordPopup_UIBP = {
    keyName = "BlackFriday_InvitationRecordPopup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Common.BlackFriday_InvitationRecordPopup_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Common/BlackFriday_InvitationRecordPopup_UIBP.BlackFriday_InvitationRecordPopup_UIBP",
    uiStat = {
      name = "\233\187\145\228\186\148-\232\174\162\233\152\133&RP\231\187\132\229\155\162\233\130\128\232\175\183\232\174\176\229\189\149\229\188\185\231\170\151"
    }
  },
  BlackFriday_LinkageReward_Popup_UIBP = {
    keyName = "BlackFriday_LinkageReward_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Common.BlackFriday_LinkageReward_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Common/BlackFriday_LinkageReward_Popup_UIBP.BlackFriday_LinkageReward_Popup_UIBP",
    uiStat = {
      name = "\233\187\145\228\186\148-RP&\232\174\162\233\152\133\232\129\148\229\138\168\229\165\150\229\138\177\229\188\185\231\170\151"
    }
  },
  BlackFriday_QuickGroupFormation_Popup_UIBP = {
    keyName = "BlackFriday_QuickGroupFormation_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Common.BlackFriday_QuickGroupFormation_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Common/BlackFriday_QuickGroupFormation_Popup_UIBP.BlackFriday_QuickGroupFormation_Popup_UIBP",
    uiStat = {
      name = "\233\187\145\228\186\148-\232\174\162\233\152\133&RP\231\187\132\229\155\162\229\191\171\233\128\159\231\187\132\229\155\162\229\188\185\231\170\151"
    }
  },
  BlackFriday_RP_RewardUpgrades_Popup_UIBP = {
    keyName = "BlackFriday_RP_RewardUpgrades_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.RP.BlackFriday_RP_RewardUpgrades_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/RP/Popup/BlackFriday_RP_RewardUpgrades_Popup_UIBP.BlackFriday_RP_RewardUpgrades_Popup_UIBP",
    uiStat = {
      name = "\233\187\145\228\186\148-RP\231\187\132\229\155\162\229\165\150\229\138\177\229\141\135\231\186\167\229\188\185\231\170\151"
    }
  },
  BlackFriday_RP_TeamTips_UIBP = {
    keyName = "BlackFriday_RP_TeamTips_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.RP.BlackFriday_RP_TeamTips_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/RP/Popup/BlackFriday_RP_TeamTips_UIBP.BlackFriday_RP_TeamTips_UIBP",
    uiStat = {
      name = "\233\187\145\228\186\148-RP\231\187\132\229\155\162\229\155\162\229\145\152\228\191\161\230\129\175\229\188\185\231\170\151"
    }
  },
  BlackFriday_RP_UIBP = {
    keyName = "BlackFriday_RP_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.RP.BlackFriday_RP_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/RP/BlackFriday_RP_UIBP.BlackFriday_RP_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\233\187\145\228\186\148-RP\231\187\132\229\155\162-\228\184\187\231\149\140\233\157\162"
    }
  },
  BlackFriday_RewardReceiveTipPopup_UIBP = {
    keyName = "BlackFriday_RewardReceiveTipPopup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Common.BlackFriday_RewardReceiveTipPopup_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Common/BlackFriday_RewardReceiveTipPopup_UIBP.BlackFriday_RewardReceiveTipPopup_UIBP",
    uiStat = {
      name = "\233\187\145\228\186\148-RP&\232\174\162\233\152\133\232\129\148\229\138\168\229\165\150\229\138\177\233\162\134\229\143\150\228\186\140\230\172\161\231\161\174\232\174\164\229\188\185\231\170\151"
    }
  },
  ChatRedpacketDetailUIBP = {
    keyName = "ChatRedpacketDetailUIBP",
    moduleName = "client.slua.umg.crp.ChatRedpacketDetailUIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/RedPacket/LobbyChat_RedPacket_Receive_UIBP.LobbyChat_RedPacket_Receive_UIBP",
    asy = true,
    uiStat = {
      name = "\232\129\138\229\164\169\231\186\162\229\140\133-\233\162\134\229\143\150\232\175\166\230\131\133"
    }
  },
  ChatRedpacketHistoryUIBP = {
    keyName = "ChatRedpacketHistoryUIBP",
    moduleName = "client.slua.umg.crp.ChatRedpacketHistoryUIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/RedPacket/LobbyChat_RedPacket_HistoricalRecord_UIBP.LobbyChat_RedPacket_HistoricalRecord_UIBP",
    asy = true,
    uiStat = {
      name = "\232\129\138\229\164\169\231\186\162\229\140\133-\228\184\170\228\186\186\229\142\134\229\143\178\232\174\176\229\189\149"
    }
  },
  ChatRedpacketListUIBP = {
    keyName = "ChatRedpacketListUIBP",
    moduleName = "client.slua.umg.crp.ChatRedpacketListUIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/RedPacket/LobbyChat_RedPacket_Friend_UIBP.LobbyChat_RedPacket_Friend_UIBP",
    asy = true,
    uiStat = {
      name = "\232\129\138\229\164\169\231\186\162\229\140\133-\231\186\162\229\140\133\229\136\151\232\161\168"
    }
  },
  ChatRedpacketPasswordUIBP = {
    keyName = "ChatRedpacketPasswordUIBP",
    moduleName = "client.slua.umg.crp.ChatRedpacketPasswordUIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/RedPacket/LobbyChat_PasswordRedPacket_UIBP.LobbyChat_PasswordRedPacket_UIBP",
    asy = true,
    uiStat = {
      name = "\232\129\138\229\164\169\231\186\162\229\140\133-\232\190\147\229\133\165\229\143\163\228\187\164"
    }
  },
  ChatRedpacketSendUIBP = {
    keyName = "ChatRedpacketSendUIBP",
    moduleName = "client.slua.umg.crp.ChatRedpacketSendUIBP",
    path = "/Game/Mod/Lobby/Split/LobbyChat/RedPacket/LobbyChat_RedPacket_GiveAway_UIBP.LobbyChat_RedPacket_GiveAway_UIBP",
    asy = true,
    uiStat = {
      name = "\232\129\138\229\164\169\231\186\162\229\140\133-\229\143\145\233\128\129"
    }
  },
  ChildUIWithoutBpPathForUnknowPass = {
    keyName = "ChildUIWithoutBpPathForUnknowPass",
    moduleName = "client.slua.component.item.ItemChildren.CommonItem_ChildUIBase",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  ChildUIWithoutBpPathForUnknowPassSync = {
    keyName = "ChildUIWithoutBpPathForUnknowPassSync",
    moduleName = "client.slua.component.item.ItemChildren.CommonItem_ChildUIBase",
    isMainUI = false,
    isSingleton = false,
    asy = false,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  CommonHome_SharePopup_UIBP = {
    keyName = "CommonHome_SharePopup_UIBP",
    moduleName = "client.slua.umg.Home.Detail.Item.CommonHome_SharePopup_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Lookback/Season_Looback_SharePopup_UIBP.Season_Looback_SharePopup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\174\182\229\155\173\229\136\134\228\186\171\229\188\185\231\170\151"
    }
  },
  Common_FirstPolymorphism_UIBP = {
    keyName = "Common_FirstPolymorphism_UIBP",
    moduleName = "client.slua.umg.common.Common_FirstPolymorphism_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_FirstPolymorphism_UIBP.Common_FirstPolymorphism_UIBP",
    asy = true,
    uiStat = {
      name = "\233\128\154\231\148\168-\231\179\187\231\187\159\230\140\135\229\188\149\239\188\136\229\184\166\231\191\187\233\161\181\239\188\137"
    }
  },
  Common_ItemGet_RPCard = {
    keyName = "Common_ItemGet_RPCard",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_RPCard.Common_ItemGet_RPCard",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-RP\231\167\175\229\136\134\230\152\190\231\164\186"
    }
  },
  Common_ItemGet_RPScore = {
    keyName = "Common_ItemGet_RPScore",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_RPScore",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_RPScore.Common_ItemGet_RPScore",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-RP\231\167\175\229\136\134\230\152\190\231\164\186"
    }
  },
  Common_Popup_Corps_SegmentFire = {
    keyName = "Common_Popup_Corps_SegmentFire",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Common_Popup_Corps_SegmentFire",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Explain_UIBP.Common_Popup_Theme_Explain_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\129\138\229\164\169\231\129\171\232\138\177\230\150\176\230\137\139\229\188\149\229\175\188"
    }
  },
  UnknowPass_NewbieGuide = {
    keyName = "UnknowPass_NewbieGuide",
    moduleName = "client.slua.umg.UnknowPass.RP_Newbie.UnknowPass_NewbieGuide",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Explain_UIBP.Common_Popup_Theme_Explain_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "RP\230\150\176\230\137\139\229\188\149\229\175\188"
    }
  },
  Common_Popup_Theme_Explain_Picture09_Item_UIBP = {
    keyName = "Common_Popup_Theme_Explain_Picture09_Item_UIBP",
    moduleName = "client.slua.umg.common.Popup.Theme.Item.Common_Popup_Theme_Explain_Picture09_Item_UIBP",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Item/Common_Popup_Theme_Explain_Picture09_Item_UIBP.Common_Popup_Theme_Explain_Picture09_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "rp\230\148\185\232\137\178\233\162\134\229\143\150\229\173\144UI"
    }
  },
  Common_RPExchangePopup_UIBP = {
    keyName = "Common_RPExchangePopup_UIBP",
    moduleName = "client.slua.umg.common.CommonExchangePopupUI.Common_RPExchangePopup_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Exchange_Confirm_UIBP.Common_Exchange_Confirm_UIBP",
    uiStat = {
      name = "RP\233\128\154\232\161\140\232\175\129-\232\180\173\228\185\176\229\133\145\230\141\162\228\186\140\230\172\161\231\161\174\232\174\164\231\149\140\233\157\162"
    }
  },
  Coupon_PopupUI_UnknowPass = {
    keyName = "Coupon_PopupUI_UnknowPass",
    moduleName = "client.slua.umg.coupon.Coupon_PopupUI_UnknowPass",
    path = "/Game/UMG/UI_BP/Coupon/Coupon_PopupUI_UIBP.Coupon_PopupUI_UIBP",
    uiStat = {
      name = "\228\188\152\230\131\160\229\136\184-\228\186\140\230\172\161\231\161\174\232\174\164\228\189\191\231\148\168\229\188\185\231\170\151-RP\228\184\147\231\148\168"
    }
  },
  FriendComp_WOWPass = {
    keyName = "FriendComp_WOWPass",
    moduleName = "client.slua.umg.lobby.FriendList.Comp.FriendComp_WOWPass",
    path = "/Game/Mod/Lobby/Split/Friend/UI_BP/FriendComp/FriendComp_WOWPass.FriendComp_WOWPass",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false,
    isSingleton = false
  },
  GiftSmallRP_Mail_Item_UIBP = {
    keyName = "GiftSmallRP_Mail_Item_UIBP",
    moduleName = "client.slua.umg.mail.mail_item.GiftSmallRP_Mail_Item_UIBP",
    path = "/Game/UMG/UI_BP/Mail/Item/GiftSmallRP_Mail_Item_UIBP.GiftSmallRP_Mail_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\233\130\174\231\174\177\226\128\148\231\164\188\231\137\169\228\184\173\229\191\131\229\141\161\231\177\187\231\154\132\231\137\169\229\147\129\229\177\149\231\164\186"
    }
  },
  Guide_UnknowPass_Award_New_BP = {
    keyName = "Guide_UnknowPass_Award_New_BP",
    moduleName = "client.slua.umg.growth_project.Guide_UnknowPass_Award_New_BP",
    path = "/Game/UMG/UI_BP/Guide/Guide_UnknowPass_Award_New_BP.Guide_UnknowPass_Award_New_BP",
    uiStat = {
      name = "\229\162\158\233\149\191\228\184\147\233\161\185-\230\150\176\230\137\139\229\188\149\229\175\188-RP\230\187\145\229\138\168\229\188\149\229\175\188"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  HelpTip = {
    keyName = "HelpTip",
    moduleName = "client.slua.umg.common.common_protocol_msg",
    path = "/Game/Mod/Lobby/Base/Downloader/UMG/UI_BP/Download/Popup/ProtocolTip_UIBP.ProtocolTip_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\233\128\154\231\148\168\232\167\132\229\136\153\233\157\162\230\157\191/\229\141\143\232\174\174\230\143\144\231\164\186"
    }
  },
  HelpTipInGame = {
    keyName = "HelpTipInGame",
    moduleName = "client.slua.umg.common.common_protocol_msg",
    path = "/Game/Mod/CreativeBase/UMG/Common/CreativeBase_ProtocolTip_UIBP.CreativeBase_ProtocolTip_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\233\128\154\231\148\168\232\167\132\229\136\153\233\157\162\230\157\191/\229\141\143\232\174\174\230\143\144\231\164\186-wow\229\177\128\229\134\133"
    }
  },
  Histogram_Item_UIBP = {
    keyName = "Histogram_Item_UIBP",
    moduleName = "client.slua.umg.statistical_charts.Histogram_Item_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/LookBack/Item/Season_Looback_Histogram_UIBP.Season_Looback_Histogram_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\159\177\231\138\182\229\155\190-\230\159\177item"
    }
  },
  IngameRPGiveUIBP = {
    keyName = "IngameRPGiveUIBP",
    moduleName = "GameLua.Mod.BaseMod.Client.Like.QuickMenu_BP_Reward_2",
    path = "/Game/BluePrints/ControlInput/IngameUI/Reward/QuickMenu_BP_Reward_2.QuickMenu_BP_Reward_2",
    zOrder = 1,
    uiStat = {
      name = "\229\177\128\229\134\133RP\232\181\160\233\128\129"
    },
    isMainUI = false
  },
  ItemPopupUCBack_UIBP = {
    keyName = "ItemPopupUCBack_UIBP",
    moduleName = "client.slua.umg.common.ItemPopupUCBack_UIBP",
    path = "/Game/UMG/UI_BP/PopupNotice/ItemPopupUCBack_UIBP.ItemPopupUCBack_UIBP",
    isSingleton = false,
    closeOnSwitch = false,
    asy = true,
    uiStat = {
      name = "UC and RP tips"
    }
  },
  Leisure_Season_Score_Chart_UIBP = {
    keyName = "Leisure_Season_Score_Chart_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Leisure.Leisure_Season_Score_Chart_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Lobby_PeakGame_Chart_UIBP.Lobby_PeakGame_Chart_UIBP",
    uiStat = {
      name = "\228\188\145\233\151\178\232\181\155\229\173\163-\232\175\180\230\152\142\229\188\185\231\170\151\231\167\175\229\136\134\228\184\138\233\153\144\232\161\168\230\160\188"
    },
    isMainUI = false,
    isSingleton = false
  },
  Leisure_Season_Segment_Chart_UIBP = {
    keyName = "Leisure_Season_Segment_Chart_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Leisure.Leisure_Season_Segment_Chart_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Lobby_PeakGame_Chart_UIBP.Lobby_PeakGame_Chart_UIBP",
    uiStat = {
      name = "\228\188\145\233\151\178\232\181\155\229\173\163-\232\175\180\230\152\142\229\188\185\231\170\151\230\174\181\228\189\141\231\177\187\229\158\139\232\161\168\230\160\188"
    },
    isMainUI = false,
    isSingleton = false
  },
  Lobby_Mid_Bubble_RP_Limit_UIBP = {
    keyName = "Lobby_Mid_Bubble_RP_Limit_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Bubble.Lobby_Mid_Bubble_RP_Limit_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Bubble/Lobby_Mid_Bubble_RP_Limit_UIBP.Lobby_Mid_Bubble_RP_Limit_UIBP",
    asy = true,
    uiStat = {
      name = "\230\150\176\231\137\136\229\164\167\229\142\133RP\228\189\147\233\170\140\231\137\136\230\176\148\230\179\161"
    }
  },
  Lobby_Mid_Bubble_RP_UIBP = {
    keyName = "Lobby_Mid_Bubble_RP_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Bubble.Lobby_Mid_Bubble_RP_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Bubble/Lobby_Mid_Bubble_RP_UIBP.Lobby_Mid_Bubble_RP_UIBP",
    asy = true,
    uiStat = {
      name = "\230\150\176\231\137\136\229\164\167\229\142\133RP\230\176\148\230\179\161"
    }
  },
  Lobby_Mid_RPNewbieGuide_UIBP = {
    keyName = "Lobby_Mid_RPNewbieGuide_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Newbie.Lobby_Mid_RPNewbieGuide_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Newbie/Lobby_Mid_RPNewbieGuide_UIBP.Lobby_Mid_RPNewbieGuide_UIBP",
    uiStat = {
      name = "\230\150\176\231\137\136\229\164\167\229\142\133RP\230\150\176\230\137\139\230\140\135\229\188\149"
    },
    isSingleton = false
  },
  Lobby_Mid_Shop_BranchRP_Item_UIBP = {
    keyName = "Lobby_Mid_Shop_BranchRP_Item_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Bubble.Lobby_Mid_Shop_BranchRP_Item_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Item/Lobby_Mid_Shop_BranchRP_Item_UIBP.Lobby_Mid_Shop_BranchRP_Item_UIBP",
    asy = true,
    uiStat = {
      name = "\230\156\170\232\180\173\228\185\176RP\231\154\132\230\187\161\231\186\167\231\142\169\229\174\182\230\176\148\230\179\161"
    }
  },
  Lobby_PeakGame_Segment_Chart_UIBP = {
    keyName = "Lobby_PeakGame_Segment_Chart_UIBP",
    moduleName = "client.slua.umg.PeakGame.Lobby_PeakGame_Segment_Chart_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Lobby_PeakGame_Chart_UIBP.Lobby_PeakGame_Chart_UIBP",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\228\184\187\231\149\140\233\157\162\230\174\181\228\189\141\232\161\168\230\160\188\231\149\140\233\157\162"
    },
    isMainUI = false,
    isSingleton = false
  },
  Lobby_RoleInfo_WoWPassPopup_UIBP = {
    keyName = "Lobby_RoleInfo_WoWPassPopup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Lobby_RoleInfo_WoWPassPopup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_RoleInfo_WoWPassPopup_UIBP.Lobby_RoleInfo_WoWPassPopup_UIBP",
    asy = true,
    uiStat = {
      name = "\229\159\186\231\161\128\228\191\161\230\129\175\226\128\148\226\128\148\233\128\154\232\161\140\232\175\129tips\231\149\140\233\157\162"
    }
  },
  Lobby_Season_AceExcellence_Detail_Temporada_UIBP = {
    keyName = "Lobby_Season_AceExcellence_Detail_Temporada_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_Season_AceExcellence_Detail_Temporada_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Lobby_Season_AceExcellence_Detail_Temporada_UIBP.Lobby_Season_AceExcellence_Detail_Temporada_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\174\181\228\189\141\229\164\180\232\161\148\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  Lobby_Season_AceExcellence_UIBP = {
    keyName = "Lobby_Season_AceExcellence_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_Season_AceExcellence_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Lobby_Season_AceExcellence_UIBP.Lobby_Season_AceExcellence_UIBP",
    uiStat = {
      name = "\232\181\155\229\173\163-\230\174\181\228\189\141\229\141\135\231\186\167\229\164\180\232\161\148\233\128\137\230\139\169\231\149\140\233\157\162"
    }
  },
  Lobby_Season_AceMark_Detail_Other = {
    keyName = "Lobby_Season_AceMark_Detail_Other",
    moduleName = "client.slua.umg.ace_imprint.Lobby_Season_AceMark_Detail_Other",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Lobby_Season_AceMark_Detail_UIBP.Lobby_Season_AceMark_Detail_UIBP",
    asy = true,
    uiStat = {
      name = "\228\187\150\228\186\186-\231\142\139\231\137\140\229\141\176\232\174\176-\232\175\166\230\131\133"
    }
  },
  Lobby_Season_AceMark_Detail_Self = {
    keyName = "Lobby_Season_AceMark_Detail_Self",
    moduleName = "client.slua.umg.ace_imprint.Lobby_Season_AceMark_Detail_Self",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Lobby_Season_AceMark_Detail_UIBP.Lobby_Season_AceMark_Detail_UIBP",
    asy = true,
    uiStat = {
      name = "\232\135\170\229\183\177-\231\142\139\231\137\140\229\141\176\232\174\176-\232\175\166\230\131\133"
    }
  },
  Lobby_Season_AceMark_Summary_Other_UIBP = {
    keyName = "Lobby_Season_AceMark_Summary_Other_UIBP",
    moduleName = "client.slua.umg.ace_imprint.Lobby_Season_AceMark_Summary_Other_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/ACEImprint/Lobby_Season_AceMark_Summary_Other_UIBP.Lobby_Season_AceMark_Summary_Other_UIBP",
    asy = true,
    uiStat = {
      name = "\228\187\150\228\186\186-\231\142\139\231\137\140\229\141\176\232\174\176_\230\166\130\232\166\129"
    }
  },
  Lobby_Season_AceMark_Summary_Self_UIBP = {
    keyName = "Lobby_Season_AceMark_Summary_Self_UIBP",
    moduleName = "client.slua.umg.ace_imprint.Lobby_Season_AceMark_Summary_Self_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/ACEImprint/Lobby_Season_AceMark_Summary_Self_UIBP.Lobby_Season_AceMark_Summary_Self_UIBP",
    asy = true,
    uiStat = {
      name = "\232\181\155\229\173\163-\232\135\170\229\183\177\231\142\139\231\137\140\229\141\176\232\174\176"
    }
  },
  Lobby_Season_Honor_Road_Mark_UIBP = {
    keyName = "Lobby_Season_Honor_Road_Mark_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_Season_Honor_Road_Mark_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/HonorRoad/Lobby_Season_Honor_Road_Mark_UIBP.Lobby_Season_Honor_Road_Mark_UIBP",
    uiStat = {
      name = "\232\141\163\232\170\137\228\185\139\232\183\175\229\188\185\231\170\151\226\128\148\226\128\148\229\141\176\232\174\176\226\128\148\226\128\148\229\137\175\233\161\181\233\157\162"
    },
    isMainUI = false
  },
  Lobby_Season_Honor_Road_Reward_UIBP = {
    keyName = "Lobby_Season_Honor_Road_Reward_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_Season_Honor_Road_Reward_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/HonorRoad/Lobby_Season_Honor_Road_Reward_UIBP.Lobby_Season_Honor_Road_Reward_UIBP",
    uiStat = {
      name = "\232\141\163\232\170\137\228\185\139\232\183\175\229\188\185\231\170\151\226\128\148\226\128\148\229\165\150\229\138\177\226\128\148\226\128\148\229\137\175\233\161\181\233\157\162"
    },
    isMainUI = false
  },
  Lobby_Season_Leisure_Award_UIBP = {
    keyName = "Lobby_Season_Leisure_Award_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Leisure.Lobby_Season_Leisure_Award_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Leisure/Lobby_Season_Leisure_Award_UIBP.Lobby_Season_Leisure_Award_UIBP",
    uiStat = {
      name = "\228\188\145\233\151\178\232\181\155\229\173\163-\229\165\150\229\138\177\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  Lobby_Season_Leisure_Integration_UIBP = {
    keyName = "Lobby_Season_Leisure_Integration_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Leisure.Popup.Lobby_Season_Leisure_Integration_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Leisure/Popup/Lobby_Season_Leisure_Integration_UIBP.Lobby_Season_Leisure_Integration_UIBP",
    asy = true,
    uiStat = {
      name = "\228\188\145\233\151\178\232\181\155\229\173\163-\231\167\175\229\136\134\232\175\166\230\131\133\229\188\185\231\170\151"
    }
  },
  Lobby_Season_Progress_Reward_Sub_UIBP = {
    keyName = "Lobby_Season_Progress_Reward_Sub_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_Season_Progress_Reward_Sub_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Lobby_Season_Progress_Reward_Sub_UIBP.Lobby_Season_Progress_Reward_Sub_UIBP",
    uiStat = {
      name = "\232\181\155\229\173\163\231\155\174\230\160\135\226\128\148\226\128\148\232\181\155\229\173\163\232\191\155\230\173\165\229\165\150\229\138\177\226\128\148\226\128\148\229\137\175\233\161\181\233\157\162"
    },
    isMainUI = false
  },
  Lobby_Season_Review_Package01_UIBP_S20 = {
    keyName = "Lobby_Season_Review_Package01_UIBP_S20",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Item.Lobby_Season_Review_Package01_UIBP_S20",
    path = "/Game/Mod/Lobby/Split/NewSeason/Archive/Item/Lobby_Season_Review_Package01_UIBP.Lobby_Season_Review_Package01_UIBP",
    uiStat = {
      name = "\232\181\155\229\173\163\230\161\163\230\161\136-\229\141\149\228\184\170\232\181\155\229\173\163\232\174\176\229\189\149"
    },
    isSingleton = false
  },
  Lobby_Season_Review_UIBP_S20 = {
    keyName = "Lobby_Season_Review_UIBP_S20",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Lobby_Season_Review_UIBP_S20",
    path = "/Game/Mod/Lobby/Split/NewSeason/Archive/Lobby_Season_Review_UIBP.Lobby_Season_Review_UIBP",
    uiStat = {
      name = "\232\181\155\229\173\163-\230\161\163\230\161\136\228\184\187\231\149\140\233\157\162"
    }
  },
  Lobby_Season_Segment_Target_Tips = {
    keyName = "Lobby_Season_Segment_Target_Tips",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_Season_Segment_Target_Tips",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Segment_Target_Tips.Segment_Target_Tips",
    isMainUI = false,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\174\181\228\189\141\231\155\174\230\160\135\231\138\182\230\128\129\229\173\144\231\149\140\233\157\162"
    }
  },
  Lobby_Season_Shop_UIBP = {
    keyName = "Lobby_Season_Shop_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_Season_Shop_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Lobby_Season_Shop_UIBP.Lobby_Season_Shop_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\181\155\229\173\163-\229\133\145\230\141\162\229\149\134\229\186\151"
    }
  },
  Lobby_Season_Target_Setting_Sub_UIBP = {
    keyName = "Lobby_Season_Target_Setting_Sub_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_Season_Target_Setting_Sub_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/SeasonTarget/Lobby_Season_Target_Setting_Sub_UIBP.Lobby_Season_Target_Setting_Sub_UIBP",
    uiStat = {
      name = "\232\181\155\229\173\163\231\155\174\230\160\135\226\128\148\226\128\148\231\155\174\230\160\135\232\174\190\231\189\174\226\128\148\226\128\148\229\137\175\233\161\181\233\157\162"
    },
    isMainUI = false
  },
  Lobby_Season_Target_Setting_UIBP = {
    keyName = "Lobby_Season_Target_Setting_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_Season_Target_Setting_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/SeasonTarget/Lobby_Season_Target_Setting_UIBP.Lobby_Season_Target_Setting_UIBP",
    asy = true,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\174\181\228\189\141\231\155\174\230\160\135\232\174\190\231\189\174"
    }
  },
  Lobby_Season_Target_Tab_UIBP = {
    keyName = "Lobby_Season_Target_Tab_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_Season_Target_Tab_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/SeasonTarget/Lobby_Season_Target_Tab_UIBP.Lobby_Season_Target_Tab_UIBP",
    jumpModuleID = BP_EMUM_MODULE_CLASSIC_SEASON_TARGET,
    uiStat = {
      name = "\232\181\155\229\173\163\231\155\174\230\160\135\226\128\148\226\128\148tab\233\161\181\233\157\162"
    }
  },
  Lobby_Season_Target_UIBP = {
    keyName = "Lobby_Season_Target_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_Season_Target_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/SeasonTarget/Lobby_Season_Target_UIBP.Lobby_Season_Target_UIBP",
    asy = true,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\174\181\228\189\141\231\155\174\230\160\135"
    }
  },
  LuckyPutBackTemplate_SmallRPLevelTip_UIBP = {
    keyName = "LuckyPutBackTemplate_SmallRPLevelTip_UIBP",
    moduleName = "client.slua.umg.lobby_activity.LuckySpin.TraitClassStyle.Supply.MountNodes.LuckyPutBack_SmallRPLevelTip_UIBP",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyputbackTemplateNew/LuckyPutBack_SmallRPLevelTip_UIBP.LuckyPutBack_SmallRPLevelTip_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150\229\133\145\230\141\162\230\180\187\229\138\168-\229\176\143RP\231\173\137\231\186\167\230\140\130\228\187\182"
    }
  },
  MomentOtherPersonMessage = {
    keyName = "MomentOtherPersonMessage",
    moduleName = "client.slua.umg.moment.ui_moment_otherperson_message",
    path = "/Game/UMG/UI_BP/Moment/Moment_Other_Person_UIBP.Moment_Other_Person_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\228\187\150\228\186\186\229\138\168\230\128\129\231\149\140\233\157\162"
    }
  },
  Notice_FairPlay_Popup = {
    keyName = "Notice_FairPlay_Popup",
    moduleName = "client.slua.umg.common.Notice_FairPlay_Popup",
    path = "/Game/UMG/UI_BP/Common/Common_FairPlay_UIBP.Common_FairPlay_UIBP",
    containerName = UIContainers.Top,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\229\133\172\229\185\179\231\171\158\230\138\128\232\173\166\229\145\138\229\188\185\231\170\151"
    }
  },
  PeakGame_SegmentAward_UIBP = {
    keyName = "PeakGame_SegmentAward_UIBP",
    moduleName = "client.slua.umg.PeakGame.PeakGame_SegmentAward_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/PeakGame_SegmentAward_UIBP.PeakGame_SegmentAward_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\174\181\228\189\141\229\165\150\229\138\177"
    }
  },
  Personalization_HomeDoorPlate_UIBP = {
    keyName = "Personalization_HomeDoorPlate_UIBP",
    moduleName = "client.slua.umg.roleInfoNew.Personalization_HomeDoorPlate_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Personalization/Personalization_HomeDoorPlate_UIBP.Personalization_HomeDoorPlate_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\167\146\232\137\178\228\191\161\230\129\175\230\150\176-\229\174\182\229\155\173\233\151\168\231\137\140"
    }
  },
  SeasonAwardDetail_UIBP = {
    keyName = "SeasonAwardDetail_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.SeasonAwardDetail_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/SeasonAwardDetail_UIBP.SeasonAwardDetail_UIBP",
    asy = true,
    uiStat = {
      name = "\232\181\155\229\173\163-\229\165\150\229\138\177\232\175\166\230\131\133"
    }
  },
  SeasonAwardMain_UIBP = {
    keyName = "SeasonAwardMain_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.SeasonAwardMain_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonAwardMain_UIBP.SeasonAwardMain_UIBP",
    asy = true,
    jumpModuleID = BP_ENUM_MODULE_SEASON_AWARD_MAIN,
    uiStat = {
      name = "\232\181\155\229\173\163-\229\165\150\229\138\177\228\184\187\231\149\140\233\157\162"
    }
  },
  SeasonLookback_ShareFriends_Popup_UIBP = {
    keyName = "SeasonLookback_ShareFriends_Popup_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season_Lookback.SeasonLookback_ShareFriends_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/ShareFriends_Popup_UIBP.ShareFriends_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\232\181\155\229\173\163-\232\181\155\229\173\163\229\155\158\233\161\190\229\136\134\228\186\171-\230\150\176"
    }
  },
  Season_Challenge_UIBP = {
    keyName = "Season_Challenge_UIBP",
    moduleName = "client.slua.umg.season.season_Challenge_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\231\187\147\231\174\151\230\140\145\230\136\152\229\128\188\232\161\165\229\129\191\229\188\185\231\170\151"
    }
  },
  Season_Looback_Main_UIBP = {
    keyName = "Season_Looback_Main_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.LookBack.Season_Looback_Main_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/LookBack/Season_Looback_Main_UIBP.Season_Looback_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_NEW_SEASON_LOOKBACK,
    asy = true,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\155\158\233\161\190"
    }
  },
  Season_Looback_Page1_UIBP = {
    keyName = "Season_Looback_Page1_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.LookBack.Season_Looback_Page1_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/LookBack/Season_Looback_Page1_UIBP.Season_Looback_Page1_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\155\158\233\161\190-\231\172\172\228\184\128\233\161\181"
    }
  },
  Season_Looback_Page2_UIBP = {
    keyName = "Season_Looback_Page2_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.LookBack.Season_Looback_Page2_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/LookBack/Season_Looback_Page2_UIBP.Season_Looback_Page2_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\155\158\233\161\190-\231\172\172\228\186\140\233\161\181"
    }
  },
  Season_Looback_Page3_UIBP = {
    keyName = "Season_Looback_Page3_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.LookBack.Season_Looback_Page3_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/LookBack/Season_Looback_Page3_UIBP.Season_Looback_Page3_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\155\158\233\161\190-\231\172\172\228\184\137\233\161\181"
    }
  },
  Season_Looback_Page4_UIBP = {
    keyName = "Season_Looback_Page4_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.LookBack.Season_Looback_Page4_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/LookBack/Season_Looback_Page4_UIBP.Season_Looback_Page4_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\155\158\233\161\190-\231\172\172\229\155\155\233\161\181"
    }
  },
  Season_Looback_Page5_UIBP = {
    keyName = "Season_Looback_Page5_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.LookBack.Season_Looback_Page5_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/LookBack/Season_Looback_Page5_UIBP.Season_Looback_Page5_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\155\158\233\161\190-\231\172\172\228\186\148\233\161\181"
    }
  },
  Season_Looback_Page6_UIBP = {
    keyName = "Season_Looback_Page6_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.LookBack.Season_Looback_Page6_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/LookBack/Season_Looback_Page6_UIBP.Season_Looback_Page6_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\155\158\233\161\190-\231\172\172\229\133\173\233\161\181"
    }
  },
  Season_Looback_Recent_Gift_Ani = {
    keyName = "Season_Looback_Recent_Gift_Ani",
    moduleName = "client.slua.umg.Lobby_SeasonUI.LookBack.Season_Looback_Recent_Gift_Ani",
    path = "/Game/UMG/UI_BP/PersonSpace/PersonSpace_Animation/Gift_ani_UIBP.Gift_ani_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isSingleton = false,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\155\158\233\161\190-\230\156\128\232\191\145\231\164\188\231\137\169\229\186\149\233\131\168\229\138\168\231\148\187"
    }
  },
  Season_Looback_SharePopup_UIBP = {
    keyName = "Season_Looback_SharePopup_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season_Lookback.Season_Looback_SharePopup_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/LookBack/Season_Looback_SharePopup_UIBP.Season_Looback_SharePopup_UIBP",
    uiStat = {
      name = "\232\181\155\229\173\163-\232\181\155\229\173\163\229\155\158\233\161\190\229\136\134\228\186\171"
    }
  },
  Season_Lookback_LongImage_Preview_UIBP = {
    keyName = "Season_Lookback_LongImage_Preview_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.LookBack.Season_Lookback_LongImage_Preview_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/LookBack/Season_Lookback_LongImage_Preview_UIBP.Season_Lookback_LongImage_Preview_UIBP",
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\155\158\233\161\190-\233\149\191\229\155\190\233\162\132\232\167\136"
    }
  },
  Season_Lookback_LongImage_Share_Component = {
    keyName = "Season_Lookback_LongImage_Share_Component",
    moduleName = "client.slua.umg.Lobby_SeasonUI.LookBack.Season_Lookback_LongImage_Share_Component",
    path = "/Game/UMG/UI_BP/Lobby/Shareinterface_UIBP_New.Shareinterface_UIBP_New",
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\155\158\233\161\190-\233\149\191\229\155\190\229\136\134\228\186\171"
    }
  },
  Season_Lookback_Share_Entrance_Popup_UIBP = {
    keyName = "Season_Lookback_Share_Entrance_Popup_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.LookBack.Season_Lookback_Share_Entrance_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Lookback/Popup/Season_Lookback_Share_Entrance_Popup_UIBP.Season_Lookback_Share_Entrance_Popup_UIBP",
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\155\158\233\161\190-\230\155\180\229\164\154\229\136\134\228\186\171"
    }
  },
  Season_Lookback_SharelongImage_UIBP = {
    keyName = "Season_Lookback_SharelongImage_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.LookBack.Season_Lookback_SharelongImage_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/LookBack/Season_Lookback_SharelongImage_UIBP.Season_Lookback_SharelongImage_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\155\158\233\161\190-\233\149\191\229\155\190\229\136\134\228\186\171\229\173\144\232\147\157\229\155\190"
    }
  },
  Season_WeaponStrength_Display_UIBP = {
    keyName = "Season_WeaponStrength_Display_UIBP",
    moduleName = "client.slua.umg.Season_WeaponStrength.Season_WeaponStrength_Display_UIBP",
    path = "/Game/UMG/UI_BP/Season_WeaponStrength/Season_WeaponStrength_Display_UIBP.Season_WeaponStrength_Display_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\232\141\163\232\170\137-\230\173\166\229\153\168\230\136\152\229\138\155"
    }
  },
  Season_WeekResult_ShareInterface_UIBP = {
    keyName = "Season_WeekResult_ShareInterface_UIBP",
    moduleName = "client.slua.umg.Season_WeaponStrength.Season_WeekResult_ShareInterface_UIBP",
    path = "/Game/UMG/UI_BP/Season_WeaponStrength/Season_WeekResult_ShareInterface_UIBP.Season_WeekResult_ShareInterface_UIBP",
    uiStat = {
      name = "\230\173\166\229\153\168\230\136\152\229\138\155\229\145\168\231\187\147\231\174\151\229\165\150\229\138\177\229\188\185\231\170\151"
    }
  },
  Season_WeponStrenthDetail_Popup_UIBP = {
    keyName = "Season_WeponStrenthDetail_Popup_UIBP",
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.WeaponStrength.Season_WeponStrenthDetail_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Season_WeaponStrength/Popup/Season_WeponStrenthDetail_Popup_UIBP.Season_WeponStrenthDetail_Popup_UIBP",
    uiStat = {
      name = "\231\187\147\231\174\151\231\149\140\233\157\162\230\173\166\229\153\168\230\136\152\229\138\155/\230\158\170\230\162\176\230\136\152\229\138\155\232\175\166\230\131\133\229\188\185\231\170\151-gm\230\181\139\232\175\149\231\148\168"
    }
  },
  Season_WeponStrenthHonorDetail_Popup_UIBP = {
    keyName = "Season_WeponStrenthHonorDetail_Popup_UIBP",
    moduleName = "client.slua.umg.Season_WeaponStrength.Popup.Season_WeponStrenthHonorDetail_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Season_WeaponStrength/Popup/Season_WeponStrenthHonorDetail_Popup_UIBP.Season_WeponStrenthHonorDetail_Popup_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\232\141\163\232\170\137-\230\173\166\229\153\168\230\136\152\229\138\155-\232\141\163\232\170\137\232\175\166\230\131\133"
    }
  },
  SegmentAwardPreview_UIBP = {
    keyName = "SegmentAwardPreview_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.SegmentAwardPreview_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/SegmentAwardPreview_UIBP.SegmentAwardPreview_UIBP",
    uiStat = {
      name = "\232\181\155\229\173\163-\229\165\150\229\138\177\233\162\132\232\167\136"
    },
    isMainUI = false
  },
  Lobby_Promotion_UIBP = {
    keyName = "Lobby_Promotion_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_Promotion_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Lobby_Promotion_UIBP.Lobby_Promotion_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\153\139\231\186\167\232\181\155\233\162\132\232\167\136"
    }
  },
  Lobby_Season_Promotio_Popup_UIBP = {
    keyName = "Lobby_Season_Promotio_Popup_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_Season_Promotio_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Lobby_Season_Promotio_Popup_UIBP.Lobby_Season_Promotio_Popup_UIBP",
    uiStat = {
      name = "\232\181\155\229\173\163-\230\153\139\231\186\167\232\181\155\233\154\144\231\167\129\232\174\190\231\189\174"
    }
  },
  SegmentAward_UIBP = {
    keyName = "SegmentAward_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.SegmentAward_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/SegmentAward_UIBP.SegmentAward_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\174\181\228\189\141\229\165\150\229\138\177"
    }
  },
  Segment_Sync_Notice_UIBP = {
    keyName = "Segment_Sync_Notice_UIBP",
    moduleName = "client.slua.umg.SegmentPromotionSync.Segment_Sync_Notice_UIBP",
    path = "/Game/UMG/UI_BP/SegmentPromotionSync/Segment_Sync_Notice_UIBP.Segment_Sync_Notice_UIBP",
    uiStat = {
      name = "\229\141\149\229\143\140\229\155\155\230\174\181\228\189\141\230\143\144\229\141\135\229\144\140\230\173\165\230\143\144\233\134\146\229\188\185\231\170\151"
    }
  },
  Segment_TeamRestriction_UIBP = {
    keyName = "Segment_TeamRestriction_UIBP",
    moduleName = "client.slua.umg.teamup.Segment_TeamRestriction_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Segment_TeamRestriction_UIBP.Segment_TeamRestriction_UIBP",
    uiStat = {
      name = "\233\162\132\231\187\132\233\152\159\233\153\144\229\136\182\230\143\144\231\164\186\229\188\185\231\170\151"
    }
  },
  SmallRP_Award_Item_UIBP = {
    keyName = "SmallRP_Award_Item_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.SmallRP.SmallRP_Award_Item_UIBP",
    path = "/Game/Arts_UI/FromUMG/SmallRP/Item/SmallRP_Award_Item_UIBP.SmallRP_Award_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\176\143RP\228\184\187\231\149\140\233\157\162-\231\173\137\231\186\167\229\165\150\229\138\177"
    }
  },
  SmallRP_Award_MultiChooseOne_Item_UIBP = {
    keyName = "SmallRP_Award_MultiChooseOne_Item_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.SmallRP.SmallRP_Award_MultiChooseOne_Item_UIBP",
    path = "/Game/Arts_UI/FromUMG/SmallRP/Item/SmallRP_Award_4Choose1_Item_UIBP.SmallRP_Award_4Choose1_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\176\143RP-\229\164\154\233\128\137\228\184\128Item"
    }
  },
  SmallRP_Award_9Choose1_Item03_UIBP = {
    keyName = "SmallRP_Award_9Choose1_Item03_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.SmallRP.SmallRP_Award_9Choose1_Item03_UIBP",
    path = "/Game/Arts_UI/FromUMG/SmallRP/Item/SmallRP_Award_9Choose1_Item03_UIBP.SmallRP_Award_9Choose1_Item03_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\176\143RP-N\233\128\1371\229\164\167\229\165\150\231\188\169\231\149\165\229\155\190Item"
    }
  },
  SmallRP_Award_UIBP = {
    keyName = "SmallRP_Award_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.SmallRP.SmallRP_Award_UIBP",
    path = "/Game/Arts_UI/FromUMG/SmallRP/SmallRP_Award_UIBP.SmallRP_Award_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\137\185\230\131\160-\229\176\143RP"
    }
  },
  SmallRP_BuyScoreRwardItem_UIBP = {
    keyName = "SmallRP_BuyScoreRwardItem_UIBP",
    moduleName = "client.slua.umg.SmallRP.SmallRP_BuyScoreRwardItem_UIBP",
    path = "/Game/Arts_UI/FromUMG/SmallRP/Item/SmallRP_BuyScoreRwardItem_UIBP.SmallRP_BuyScoreRwardItem_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\176\143RP-\232\180\173\228\185\176\231\167\175\229\136\134\231\149\140\233\157\162\231\154\132\229\141\149\233\129\147\229\133\183item"
    }
  },
  SmallRP_Buy_Score_UIBP = {
    keyName = "SmallRP_Buy_Score_UIBP",
    moduleName = "client.slua.umg.SmallRP.SmallRP_Buy_Score_UIBP",
    path = "/Game/Arts_UI/FromUMG/SmallRP/SmallRP_Buy_Score_UIBP.SmallRP_Buy_Score_UIBP",
    uiStat = {
      name = "\229\176\143RP-\231\173\137\231\186\167\231\167\175\229\136\134\232\180\173\228\185\176"
    }
  },
  SmallRP_LevelUp_UIBP = {
    keyName = "SmallRP_LevelUp_UIBP",
    moduleName = "client.slua.umg.SmallRP.SmallRP_LevelUp_UIBP",
    path = "/Game/Arts_UI/FromUMG/SmallRP/SmallRP_LevelUp_UIBP.SmallRP_LevelUp_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\176\143RP-\231\173\137\231\186\167\230\143\144\229\141\135"
    }
  },
  SmallRP_Special_Linkage_Guide_Popup_UIBP = {
    keyName = "SmallRP_Special_Linkage_Guide_Popup_UIBP",
    moduleName = "client.slua.umg.SmallRP.SmallRP_Special_Linkage_Guide_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/SmallRP/Popup/SmallRP_Special_Linkage_Guide_Popup_UIBP.SmallRP_Special_Linkage_Guide_Popup_UIBP",
    isMainUI = true,
    isSingleton = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\176\143RP-IP\230\180\187\229\138\168\233\155\134\229\144\136\233\161\181\229\184\174\229\138\169\229\188\185\231\170\151"
    }
  },
  SmallRP_Special_Linkage_UIBP = {
    keyName = "SmallRP_Special_Linkage_UIBP",
    moduleName = "client.slua.umg.SmallRP.SmallRP_Special_Linkage_UIBP",
    path = "",
    isMainUI = true,
    isSingleton = true,
    uiStat = {
      name = "\229\176\143RP-IP\230\180\187\229\138\168\233\155\134\229\144\136\233\161\181"
    }
  },
  SmallRP_Task_UIBP = {
    keyName = "SmallRP_Task_UIBP",
    moduleName = "client.slua.umg.SmallRP.SmallRP_Task_UIBP",
    path = "/Game/Arts_UI/FromUMG/SmallRP/SmallRP_Task_UIBP.SmallRP_Task_UIBP",
    uiStat = {
      name = "\229\176\143RP-\228\187\187\229\138\161\231\149\140\233\157\162"
    }
  },
  SmallRP_UpLevelMultiItemSelect_UIBP = {
    keyName = "SmallRP_UpLevelMultiItemSelect_UIBP",
    moduleName = "client.slua.umg.SmallRP.SmallRP_UpLevelMultiItemSelect_UIBP",
    path = "/Game/Arts_UI/FromUMG/SmallRP/Item/SmallRP_UpLevelMultiItemSelect_UIBP.SmallRP_UpLevelMultiItemSelect_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\176\143RP-\232\180\173\228\185\176\231\167\175\229\136\134\231\149\140\233\157\162\231\154\132\228\186\140\233\128\137\228\184\128\233\129\147\229\133\183item"
    }
  },
  SpecialOffer_SmallRP_Push_Popup_UIBP = {
    keyName = "SpecialOffer_SmallRP_Push_Popup_UIBP",
    moduleName = "client.slua.umg.SmallRP.SpecialOffer_SmallRP_Push_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/SmallRP/Popup/SpecialOffer_SmallRP_Push_Popup_UIBP.SpecialOffer_SmallRP_Push_Popup_UIBP",
    uiStat = {
      name = "\229\176\143RP-\232\167\163\233\148\129\229\143\175\231\171\139\229\141\179\232\142\183\229\190\151\231\173\137\231\186\167\229\165\150\229\138\177\233\162\132\232\167\136"
    }
  },
  SportsCarRewardPreviewContainer = {
    keyName = "SportsCarRewardPreviewContainer",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.Container.SportsCarPreviewContainer",
    path = "/Game/Mod/Lobby/Base/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\183\145\232\189\166\232\189\172\231\155\152-\233\152\191\230\150\175\233\161\191\233\169\172\228\184\129-\229\165\150\229\138\177\233\162\132\232\167\136"
    }
  },
  TeamPlatform_Recruit_UIBP = {
    keyName = "TeamPlatform_Recruit_UIBP",
    moduleName = "client.slua.umg.teamup.TeamPlatform_Recruit_UIBP",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/TeamPlatform_Recruit_UIBP.TeamPlatform_Recruit_UIBP",
    uiStat = {
      name = "\231\187\132\233\152\159\229\164\167\229\142\133-\230\139\155\229\139\159\231\149\140\233\157\162"
    }
  },
  WeaponStrength_Score_Chart = {
    keyName = "WeaponStrength_Score_Chart",
    moduleName = "client.slua.umg.Season_WeaponStrength.WeaponStrength_Score_Chart",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Lobby_PeakGame_Chart_UIBP.Lobby_PeakGame_Chart_UIBP",
    uiStat = {
      name = "\230\173\166\229\153\168\230\136\152\229\138\155\231\167\175\229\136\134\229\155\190\232\161\168"
    },
    isMainUI = false,
    isSingleton = false
  },
  WeaponStrength_Segment_Chart_UIBP = {
    keyName = "WeaponStrength_Segment_Chart_UIBP",
    moduleName = "client.slua.umg.Season_WeaponStrength.WeaponStrength_Segment_Chart_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Lobby_PeakGame_Three_Col_Chart_UIBP.Lobby_PeakGame_Three_Col_Chart_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\232\141\163\232\170\137-\230\173\166\229\153\168\230\136\152\229\138\155-\230\136\152\229\138\155\231\167\175\229\136\134\232\161\168\230\160\188"
    },
    isMainUI = false,
    isSingleton = false
  },
  WeaponStrength_Title_Select_Popup_UIBP = {
    keyName = "WeaponStrength_Title_Select_Popup_UIBP",
    moduleName = "client.slua.umg.Season_WeaponStrength.Popup.WeaponStrength_Title_Select_Popup_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Title/Popup/Title_Select_Popup_UIBP.Title_Select_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\232\141\163\232\170\137-\230\173\166\229\153\168\230\136\152\229\138\155-\231\167\176\229\143\183\233\128\137\230\139\169"
    }
  },
  level_unlock_levelup = {
    keyName = "level_unlock_levelup",
    moduleName = "client.slua.umg.level_unlock.levelup",
    path = "/Game/Mod/Lobby/Base/LevelUnlock/UIBP/LevelUnlock_Segment_UIBP.LevelUnlock_Segment_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\231\173\137\231\186\167\232\167\163\233\148\129-\229\141\135\231\186\167\230\143\144\231\164\186"
    }
  },
  LevelUnlock_Segment_New_UIBP = {
    keyName = "LevelUnlock_Segment_New_UIBP",
    moduleName = "client.slua.umg.level_unlock.LevelUnlock_Segment_New_UIBP",
    path = "/Game/Mod/Lobby/Base/LevelUnlock/UIBP/LevelUnlock_Segment_New_UIBP.LevelUnlock_Segment_New_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\231\173\137\231\186\167\232\167\163\233\148\129-\229\141\135\231\186\167\230\143\144\231\164\186-\230\150\176"
    }
  },
  loading_anim_mgr = {
    keyName = "loading_anim_mgr",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Anim_Mgr",
    path = "/Game/Mod/Lobby/Base/NewSeason/Lobby_Season_Switch_Root.Lobby_Season_Switch_Root",
    zOrder = EFixedZOrder.Click_Animation + 1,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\191\155\230\136\152\230\150\151\229\133\165\229\156\186\229\138\168\231\148\187"
    }
  },
  match_warm_up_task = {
    keyName = "match_warm_up_task",
    moduleName = "client.slua.umg.match.warm_up.match_warm_up_task",
    path = "/Game/Mod/Lobby/Split/ModeSelection/Match/Match_Season_warm_up_UIBP.Match_Season_warm_up_UIBP",
    asy = true,
    uiStat = {
      name = "\230\168\161\229\188\143\233\128\137\230\139\169-\231\131\173\232\186\171\232\181\155\228\187\187\229\138\161"
    }
  },
  mentee_main = {
    keyName = "mentee_main",
    moduleName = "client.slua.umg.mentor.mentee_main",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_Recruit_UIBP.PartnerReadiness_Recruit_UIBP",
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\230\150\176\229\133\181\233\130\128\232\175\183"
    },
    isSingleton = false
  },
  mentee_main_guide = {
    keyName = "mentee_main_guide",
    moduleName = "client.slua.umg.mentor.mentee_main_guide",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_Introduction_RecruitGuide_UIBP.PartnerReadiness_Introduction_RecruitGuide_UIBP",
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\230\150\176\229\133\181\229\188\149\229\175\188"
    }
  },
  PartnerReadiness_NewTips_UIBP = {
    keyName = "PartnerReadiness_NewTips_UIBP",
    moduleName = "client.slua.umg.PartnerReadiness.Item.PartnerReadiness_NewTips_UIBP",
    path = "/Game/UMG/UI_BP/PartnerReadiness/Item/PartnerReadiness_NewTips_UIBP.PartnerReadiness_NewTips_UIBP",
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176\228\188\152\229\140\150-\230\150\176\230\137\139Tag"
    },
    isSingleton = false,
    isMainUI = false
  },
  TeamPlatform_NewGuide_UIBP = {
    keyName = "TeamPlatform_NewGuide_UIBP",
    moduleName = "client.slua.umg.TeamPlatform.TeamPlatform_New.TeamPlatform_NewGuide_UIBP",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/TeamPlatform_NewGuide_UIBP.TeamPlatform_NewGuide_UIBP",
    isMainUI = false,
    isSingleton = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176\228\188\152\229\140\150-\230\150\176\230\137\139Tag\239\188\136\229\188\149\229\175\188\239\188\137"
    }
  },
  newbie_lobby_rp = {
    keyName = "newbie_lobby_rp",
    moduleName = "client.slua.umg.newbie.newbie_lobby_rp",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Tips/Lobby_Mid_Tips_RP_UIBP.Lobby_Mid_Tips_RP_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    containerName = UIContainers.Top
  },
  season_lookback = {
    keyName = "season_lookback",
    moduleName = "client.slua.umg.season.season_lookback",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Lobby_Season_Lookback_UIBP.Lobby_Season_Lookback_UIBP",
    jumpModuleID = BP_ENUM_MODULE_LOOKBACK,
    uiStat = {
      name = "\232\181\155\229\173\163-\232\181\155\229\173\163\229\155\158\233\161\190"
    }
  },
  season_new_guide = {
    keyName = "season_new_guide",
    moduleName = "client.slua.umg.season.season_new_guide",
    path = "/Game/Mod/Lobby/Split/NewSeason/S20/Lobby_Season_Review_Guide_UIBP.Lobby_Season_Review_Guide_UIBP",
    asy = true,
    uiStat = {
      name = "\232\181\155\229\173\163\229\188\149\229\175\188"
    }
  },
  season_result_share = {
    keyName = "season_result_share",
    moduleName = "client.slua.umg.shareChild.share_season_result",
    path = "/Game/UMG/UI_BP/Share/ShareSeasonResult_UIBP.ShareSeasonResult_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\136\134\228\186\171-\232\181\155\229\173\163\230\136\152\230\138\165"
    }
  },
  segment_protect_tips = {
    keyName = "segment_protect_tips",
    moduleName = "client.slua.umg.lobby.Mid.Lobby_Mid_DoubleCard_Buff_Panel_new_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Mid_DoubleCard_Buff_Panel_160_UIBP.Lobby_Mid_DoubleCard_Buff_Panel_160_UIBP"
  },
  starterPack_messageBox = {
    keyName = "starterPack_messageBox",
    moduleName = "client.slua.umg.lobby_activity.starter_pack.starterpack_messageBox",
    path = "/Game/UMG/UI_BP/Lobby_Activity/StarterPack/Starterpack_MessageBox_item.Starterpack_MessageBox_item",
    uiStat = {
      name = "\230\150\176\230\137\139\231\164\188\229\140\133-\229\188\185\231\170\151"
    }
  },
  starterpack_finaloffer_panel = {
    keyName = "starterpack_finaloffer_panel",
    moduleName = "client.slua.umg.lobby_activity.starter_pack.starterpack_finaloffer_panel",
    path = "/Game/UMG/UI_BP/Lobby_Activity/StarterPack/StarterPack_FinalOffer_UIBP.StarterPack_FinalOffer_UIBP",
    showVisibility = Visible,
    uiStat = {
      name = "\230\150\176\230\137\139\231\164\188\229\140\133"
    }
  },
  starterpack_unlock_panel = {
    keyName = "starterpack_unlock_panel",
    moduleName = "client.slua.umg.lobby_activity.starter_pack.unlockstarterpack_panel",
    path = "/Game/UMG/UI_BP/Lobby_Activity/StarterPack/StarterPack_Unlock_UIBP.StarterPack_Unlock_UIBP",
    showVisibility = Visible,
    uiStat = {
      name = "\230\150\176\230\137\139\231\164\188\229\140\133-\231\164\188\229\140\133\232\175\166\230\131\133"
    }
  },
  ui_season_end_reminder = {
    keyName = "ui_season_end_reminder",
    moduleName = "client.slua.umg.season.season_end_reminder",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Lobby_SeasonUI_End_reminder_UIBP.Lobby_SeasonUI_End_reminder_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\232\181\155\229\173\163-\231\187\147\230\157\159\230\143\144\233\134\146"
    }
  },
  ui_season_slapface = {
    keyName = "ui_season_slapface",
    moduleName = "client.slua.umg.season.season_slap",
    closeOnSwitch = false,
    path = "/Game/UMG/UI_BP/Lobby/Rank_LevelUP_S20_UIBP.Rank_LevelUP_S20_UIBP",
    uiStat = {
      name = "\232\181\155\229\173\163-\230\174\181\228\189\141\230\139\141\232\132\184"
    }
  },
  ui_season_slapface_s47 = {
    keyName = "ui_season_slapface_s47",
    moduleName = "client.slua.umg.season.season_slap_s47",
    closeOnSwitch = false,
    path = "/Game/UMG/UI_BP/Lobby/Rank_LevelUP_S20_UIBP.Rank_LevelUP_S20_UIBP",
    uiStat = {
      name = "\232\181\155\229\173\163-\230\153\139\231\186\167\232\181\155\232\181\155\229\173\163\230\174\181\228\189\141\230\139\141\232\132\184"
    }
  },
  ui_season_imprint_slapface_s47 = {
    keyName = "ui_season_imprint_slapface_s47",
    moduleName = "client.slua.umg.season.season_imprint_slap",
    closeOnSwitch = false,
    path = "/Game/UMG/UI_BP/Lobby/Rank_LevelUP_S20_UIBP.Rank_LevelUP_S20_UIBP",
    uiStat = {
      name = "\232\181\155\229\173\163-\230\153\139\231\186\167\232\181\155\229\141\176\232\174\176\230\139\141\232\132\184"
    }
  },
  ui_season_slapface2 = {
    keyName = "ui_season_slapface2",
    moduleName = "client.slua.umg.season.season_slap2",
    closeOnSwitch = false,
    path = "/Game/UMG/UI_BP/Lobby/Rank_GOVresult_S20_UIBP.Rank_GOVresult_S20_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\136\152\231\165\158\230\139\141\232\132\184"
    }
  },
  ui_season_slapface2_s47 = {
    keyName = "ui_season_slapface2_s47",
    moduleName = "client.slua.umg.season.season_slap2_s47",
    closeOnSwitch = false,
    closeOnHide = false,
    isSingleton = true,
    path = "/Game/UMG/UI_BP/Lobby/Rank_GOVresult_S28_UIBP.Rank_GOVresult_S28_UIBP",
    uiStat = {
      name = "\232\181\155\229\173\163-\230\153\139\231\186\167\232\181\155\232\181\155\229\173\163\230\136\152\231\165\158\230\139\141\232\132\184"
    }
  },
  ui_season_switch_mgr = {
    keyName = "ui_season_switch_mgr",
    moduleName = "client.slua.umg.season.season_switch_mgr",
    path = "/Game/Mod/Lobby/Base/NewSeason/Lobby_Season_Start_Root.Lobby_Season_Start_Root",
    AndroidBackType = EAndroidBackType.Ban,
    limitScene = GameStatus.Lobby,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\136\135\230\141\162"
    }
  },
  ui_season_switch_page1 = {
    keyName = "ui_season_switch_page1",
    moduleName = "client.slua.umg.season.Lobby_Season_Start_UIBP_001",
    path = "/Game/Arts_UI/Season/1_6_0/SeasonStart/Lobby_Season_Start_UIBP_001.Lobby_Season_Start_UIBP_001",
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\136\135\230\141\162-\233\161\1811"
    }
  },
  ui_season_switch_page2 = {
    keyName = "ui_season_switch_page2",
    moduleName = "client.slua.umg.season.Lobby_Season_Start_UIBP_002",
    path = "/Game/Arts_UI/Season/1_6_0/SeasonStart/Lobby_Season_Start_UIBP_002.Lobby_Season_Start_UIBP_002",
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\136\135\230\141\162-\233\161\1812"
    }
  },
  ui_season_switch_page3 = {
    keyName = "ui_season_switch_page3",
    moduleName = "client.slua.umg.season.Lobby_Season_Start_UIBP_003",
    path = "/Game/Arts_UI/Season/1_6_0/SeasonStart/Lobby_Season_Start_UIBP_003.Lobby_Season_Start_UIBP_003",
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\136\135\230\141\162-\233\161\1813"
    }
  },
  ui_season_switch_page4 = {
    keyName = "ui_season_switch_page4",
    moduleName = "client.slua.umg.season.Lobby_Season_Start_UIBP_004",
    path = "/Game/Arts_UI/Season/1_6_0/SeasonStart/Lobby_Season_Start_UIBP_004.Lobby_Season_Start_UIBP_004",
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\136\135\230\141\162-\233\161\1814"
    }
  },
  ui_season_switch_page5 = {
    keyName = "ui_season_switch_page5",
    moduleName = "client.slua.umg.season.Lobby_Season_Start_UIBP_005",
    path = "/Game/Arts_UI/Season/1_6_0/SeasonStart/Lobby_Season_Start_UIBP_005.Lobby_Season_Start_UIBP_005",
    uiStat = {
      name = "\232\181\155\229\173\163-\230\150\176\232\181\155\229\173\163\229\136\135\230\141\162-\233\161\1815"
    }
  },
  ui_subscribe_carnival_detail = {
    keyName = "ui_subscribe_carnival_detail",
    moduleName = "client.slua.umg.subscribe_activity.ui_subscribe_carnival_detail",
    path = "/Game/UMG/UI_BP/Lobby_Store_Int/Store_3/Lobby_RP_Subscription_Popup_UIBP.Lobby_RP_Subscription_Popup_UIBP",
    uiStat = {
      name = "\232\174\162\233\152\133\231\139\130\230\172\162\232\138\130\230\180\187\229\138\168-\232\174\162\233\152\133\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  ui_team_skin_main = {
    keyName = "ui_team_skin_main",
    moduleName = "client.slua.umg.team_vs_skin.ui_team_skin_main",
    path = "/Game/UMG/UI_BP/Team_competition/Season_system/Special_effects_management_UIBP.Special_effects_management_UIBP",
    uiStat = {
      name = "\229\155\162\231\171\158\231\154\174\232\130\164-\228\184\187\231\149\140\233\157\162"
    }
  },
  wardrobe_buy_rp_bag = {
    keyName = "wardrobe_buy_rp_bag",
    moduleName = "client.slua.umg.Wardrobe.Wardrobe_RP_UIBP_14",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Wardrobe_RP_UIBP_14.Wardrobe_RP_UIBP_14",
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147-\232\180\173\228\185\176rp"
    }
  },
  Lobby_Season_Main_UIBP = {
    keyName = "Lobby_Season_Main_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Lobby_Season_Main_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Lobby_Season_Main_UIBP.Lobby_Season_Main_UIBP",
    asy = true,
    isMainUI = true,
    jumpModuleID = BP_ENUM_MODULE_SEASONYEAR,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\232\181\155\229\185\180\228\184\187\231\149\140\233\157\162"
    }
  },
  Lobby_Season_AnnualAchievement_UIBP = {
    keyName = "Lobby_Season_AnnualAchievement_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Lobby_Season_AnnualAchievement_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Lobby_Season_AnnualAchievement_UIBP.Lobby_Season_AnnualAchievement_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\181\155\229\185\180\229\190\189\231\171\160"
    }
  },
  Lobby_SeasonYear_Review_UIBP = {
    keyName = "Lobby_SeasonYear_Review_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Lobby_SeasonYear_Review_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Lobby_SeasonYear_Review_UIBP.Lobby_SeasonYear_Review_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\181\155\229\185\180\230\161\163\230\161\136"
    }
  },
  Lobby_Season_Other_Main_UIBP = {
    keyName = "Lobby_Season_Other_Main_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Lobby_Season_Other_Main_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Lobby_Season_Main_UIBP.Lobby_Season_Main_UIBP",
    isMainUI = true,
    asy = true,
    uiStat = {
      name = "\229\174\162\230\128\129\232\181\155\229\185\180\230\161\163\230\161\136"
    }
  },
  Lobby_SeasonYear_Review_Item_UIBP = {
    keyName = "Lobby_SeasonYear_Review_Item_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Item.Lobby_SeasonYear_Review_Item_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Item/Lobby_SeasonYear_Review_Item_UIBP.Lobby_SeasonYear_Review_Item_UIBP",
    isMainUI = false,
    asy = true,
    isSingleton = false,
    uiStat = {
      name = "\232\181\155\229\185\180\230\161\163\230\161\136-item"
    }
  },
  Lobby_SeasonYear_Review_Share_Item_UIBP = {
    keyName = "Lobby_SeasonYear_Review_Share_Item_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Item.Lobby_SeasonYear_Review_Item_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Item/Lobby_SeasonYear_Review_Share_Item_UIBP.Lobby_SeasonYear_Review_Share_Item_UIBP",
    isMainUI = false,
    asy = true,
    isSingleton = false,
    uiStat = {
      name = "\232\181\155\229\185\180\230\161\163\230\161\136\229\136\134\228\186\171-item"
    }
  },
  Lobby_SeasonYear_TrialIcon_Desc_UIBP = {
    keyName = "Lobby_SeasonYear_TrialIcon_Desc_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Item.Lobby_SeasonYear_TrialIcon_Desc_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Item/Lobby_SeasonYear_TrialIcon_Desc_UIBP.Lobby_SeasonYear_TrialIcon_Desc_UIBP",
    isMainUI = true,
    isSingleton = true,
    uiStat = {
      name = "\232\181\155\229\185\180\230\161\163\230\161\136-\230\140\145\230\136\152\229\190\189\231\171\160\232\175\166\230\131\133"
    }
  },
  Lobby_Season_TrialMission_UIBP = {
    keyName = "Lobby_Season_TrialMission_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Lobby_Season_TrialMission_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Lobby_Season_TrialMission_UIBP.Lobby_Season_TrialMission_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\181\155\229\185\180\232\175\149\231\130\188\228\187\187\229\138\161"
    }
  },
  Lobby_Season_TrialMission_Items_UIBP = {
    keyName = "Lobby_Season_TrialMission_Items_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.item.Lobby_Season_TrialMission_Items_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Item/Lobby_Season_TrialMission_Items_UIBP.Lobby_Season_TrialMission_Items_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\181\155\229\185\180\232\175\149\231\130\188\228\187\187\229\138\161"
    }
  },
  Lobby_Season_Store_UIBP = {
    keyName = "Lobby_Season_Store_UIBP",
    moduleName = "client.slua.umg.Lobby_Season_Store_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Lobby_Season_Store_UIBP.Lobby_Season_Store_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\181\155\229\185\180\228\184\187\231\149\140\233\157\162-\232\181\155\229\185\180\229\174\157\229\186\147"
    }
  },
  Lobby_Season_Guide_UIBP = {
    keyName = "Lobby_Season_Guide_UIBP",
    moduleName = "client.slua.umg.Lobby_Season_Guide_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Lobby_Season_Guide_UIBP.Lobby_Season_Guide_UIBP",
    uiStat = {
      name = "\232\181\155\229\185\180\228\184\187\231\149\140\233\157\162-\229\188\149\229\175\188"
    }
  },
  Matchmaking_Guinness_UIBP = {
    keyName = "Matchmaking_Guinness_UIBP",
    moduleName = "client.slua.umg.lobby_activity.Matchmaking.Matchmaking_Guinness_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Matchmaking/Matchmaking_Guinness_UIBP.Matchmaking_Guinness_UIBP",
    uiStat = {
      name = "\228\184\187\229\159\142-\231\187\147\231\188\152\230\180\187\229\138\168-\229\144\137\229\176\188\230\150\175\231\149\140\233\157\162"
    }
  },
  Lobby_Season_RankTask_UIBP = {
    keyName = "Lobby_Season_RankTask_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Lobby_Season_RankTask_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Lobby_Season_RankTask_UIBP.Lobby_Season_RankTask_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\181\155\229\185\180-\230\174\181\228\189\141\228\187\187\229\138\161\231\149\140\233\157\162"
    }
  },
  Lobby_Season_UseProp_Popup_UIBP = {
    keyName = "Lobby_Season_UseProp_Popup_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Lobby_Season_UseProp_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Popup/Lobby_Season_UseProp_Popup_UIBP.Lobby_Season_UseProp_Popup_UIBP",
    uiStat = {
      name = "\232\181\155\229\185\180-\230\174\181\228\189\141\228\187\187\229\138\161-\232\161\165\231\187\153\229\188\185\231\170\151"
    }
  },
  Lobby_Season_UseProp_Item_UIBP = {
    keyName = "Lobby_Season_UseProp_Item_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Item.Lobby_Season_UseProp_Item_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Item/Lobby_Season_UseProp_Item_UIBP.Lobby_Season_UseProp_Item_UIBP",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\232\181\155\229\185\180-\228\189\191\231\148\168\233\129\147\229\133\183\229\188\185\231\170\151-\228\187\187\229\138\161Item"
    }
  },
  Lobby_Season_Rank_Popup_UIBP = {
    keyName = "Lobby_Season_Rank_Popup_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Popup.Lobby_Season_Rank_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Popup/Lobby_Season_Rank_Popup_UIBP.Lobby_Season_Rank_Popup_UIBP",
    uiStat = {
      name = "\232\181\155\229\185\180\229\190\189\231\171\160\228\189\191\231\148\168\231\149\140\233\157\162"
    }
  },
  Lobby_SeasonYear_Badge_Change_UIBP = {
    keyName = "Lobby_SeasonYear_Badge_Change_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Popup.Lobby_SeasonYear_Badge_Change_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Popup/Lobby_SeasonYear_Badge_Change_UIBP.Lobby_SeasonYear_Badge_Change_UIBP",
    isMainUI = true,
    uiStat = {
      name = "\232\181\155\229\185\180\229\190\189\231\171\160\229\143\152\230\155\180\231\149\140\233\157\162"
    }
  },
  Lobby_SeasonYear_Badge_Share_UIBP = {
    keyName = "Lobby_SeasonYear_Badge_Share_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Lobby_SeasonYear_Badge_Share_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Lobby_SeasonYear_Badge_Share_UIBP.Lobby_SeasonYear_Badge_Share_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\181\155\229\185\180\229\190\189\231\171\160\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  Lobby_Season_UpgradeBadge_UIBP = {
    keyName = "Lobby_Season_UpgradeBadge_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Lobby_Season_UpgradeBadge_UIBP",
    containerName = UIContainers.Top,
    isSingleton = true,
    path = "/Game/Mod/Lobby/Split/NewSeason/SeasonYear/Lobby_Season_UpgradeBadge_UIBP.Lobby_Season_UpgradeBadge_UIBP",
    uiStat = {
      name = "\232\181\155\229\185\180-\230\174\181\228\189\141\230\139\141\232\132\184"
    }
  },
  Lobby_Season_Badge_Item_UIBP = {
    keyName = "Lobby_Season_Badge_Item_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Season2026.Item.Lobby_Season_Badge_Item_UIBP",
    path = "/Game/Mod/Lobby/Base/NewSeason/SeasonYear/Lobby_Season_Badge_Item_UIBP.Lobby_Season_Badge_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\232\181\155\229\185\180-\232\181\155\229\185\180\229\190\189\231\171\160\229\133\165\233\152\159\230\149\136\230\158\156"
    }
  },
  Common_Info_AnnualBadge_Large_Item = {
    keyName = "Common_Info_AnnualBadge_Large_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_AnnualBadge_Large_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_AnnualBadge_Large_Item.Common_Info_AnnualBadge_Large_Item",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\231\164\190\228\186\164\229\144\141\231\137\135\232\181\155\229\185\180\229\190\189\231\171\160\229\164\167\229\155\190\230\160\135"
    }
  },
  Common_Info_AnnualBadge_Small_Item = {
    keyName = "Common_Info_AnnualBadge_Small_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_AnnualBadge_Small_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_AnnualBadge_Small_Item.Common_Info_AnnualBadge_Small_Item",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\231\164\190\228\186\164\229\144\141\231\137\135\232\181\155\229\185\180\229\190\189\231\171\160\229\176\143\229\155\190\230\160\135"
    }
  },
  Common_Info_AnnualBadge_Large_New_Item = {
    keyName = "Common_Info_AnnualBadge_Large_New_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_AnnualBadge_Large_New_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_AnnualBadge_Large_Item_V_UIBP.Common_Info_AnnualBadge_Large_Item_V_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\231\164\190\228\186\164\229\144\141\231\137\135\232\181\155\229\185\180\229\190\189\231\171\160\229\164\167\229\155\190\230\160\135"
    }
  },
  Common_KingMark_UIBP_2 = {
    keyName = "Common_KingMark_UIBP_2",
    moduleName = "client.slua.umg.common.Common_KingMark_UIBP_2",
    path = "/Game/UMG/UI_BP/Common/Common_KingMark_UIBP_2.Common_KingMark_UIBP_2",
    isSingleton = false,
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\229\141\176\232\174\176\229\159\186\231\161\128\231\149\140\233\157\162"
    }
  },
  CardCollection_Main_UIBP = {
    keyName = "CardCollection_Main_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CardCollection_Main_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/CardCollection_Main_UIBP.CardCollection_Main_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161-\228\184\187\231\149\140\233\157\162"
    }
  },
  CardCollection_Signature_Item = {
    keyName = "CardCollection_Signature_Item",
    moduleName = "GameLua.Mod.Lobby.Base.CardCollection.umg.item.CardCollection_Signature_Item",
    isSingleton = false,
    isMainUI = false
  },
  CardCollection_Set_UIBP = {
    keyName = "CardCollection_Set_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CardCollection_Set_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/CardCollection_Set_UIBP.CardCollection_Set_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161-\231\179\187\229\136\151\231\149\140\233\157\162"
    }
  },
  CardCollection_History_UIBP = {
    keyName = "CardCollection_History_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CardCollection_History_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/CardCollection_History_UIBP.CardCollection_History_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\233\155\134\229\141\161-\229\142\134\229\143\178\229\141\161\231\137\140\231\149\140\233\157\162"
    }
  },
  CardCollection_Card_Detail_UIBP = {
    keyName = "CardCollection_Card_Detail_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CardCollection_Card_Detail_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Collection_Card_Detail_UIBP.Collection_Card_Detail_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\233\155\134\229\141\161-\229\141\161\231\137\140\232\175\166\231\187\134\231\149\140\233\157\162"
    }
  },
  CardCollection_Share_UIBP = {
    keyName = "CardCollection_Share_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CardCollection_Share_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/CardCollection_Share_UIBP.CardCollection_Share_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\233\155\134\229\141\161-\229\141\161\231\137\140\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  CardCollection_SwapHistory_Popup_UIBP = {
    keyName = "CardCollection_SwapHistory_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_SwapHistory_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Swap_Popup_UIBP.CardCollection_Swap_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\233\155\134\229\141\161-\231\189\174\230\141\162\232\174\176\229\189\149\229\188\185\231\170\151"
    }
  },
  CardCollection_GivingGifts_Popup_UIBP = {
    keyName = "CardCollection_GivingGifts_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_GivingGifts_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_GivingGifts_Popup_UIBP.CardCollection_GivingGifts_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\233\155\134\229\141\161-\232\181\160\233\128\129\231\164\188\231\137\169\229\188\185\231\170\151"
    }
  },
  CardCollection_Card_Preview_Popup_UIBP = {
    keyName = "CardCollection_Card_Preview_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Card_Preview_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Card_Preview_Popup_UIBP.CardCollection_Card_Preview_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\233\155\134\229\141\161-\229\141\161\231\137\140\233\162\132\232\167\136\229\188\185\231\170\151"
    }
  },
  CardCollection_Fragment_Tips_UIBP = {
    keyName = "CardCollection_Fragment_Tips_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Fragment_Tips_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Fragment_Tips_UIBP.CardCollection_Fragment_Tips_UIBP",
    asy = true,
    uiStat = {
      name = "\233\155\134\229\141\161-\231\162\142\231\137\135\230\157\165\230\186\144Tips"
    }
  },
  CardCollection_Drift_Popup_UIBP = {
    keyName = "CardCollection_Drift_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Drift_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Drift_Popup_UIBP.CardCollection_Drift_Popup_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161-\230\188\130\230\181\129\229\188\185\231\170\151"
    }
  },
  CardCollection_Tips_Popup_UIBP = {
    keyName = "CardCollection_Tips_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Tips_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Tips_Popup_UIBP.CardCollection_Tips_Popup_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161-\230\148\182\232\151\143\229\134\140\230\143\144\231\164\186\229\188\185\231\170\151"
    }
  },
  CardCollection_Dismantle_Popup_UIBP = {
    keyName = "CardCollection_Dismantle_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Dismantle_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Dismantle_Popup_UIBP.CardCollection_Dismantle_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\233\155\134\229\141\161-\229\136\134\232\167\163\229\188\185\231\170\151"
    }
  },
  CardCollection_Dismantle_Panel_UIBP = {
    keyName = "CardCollection_Dismantle_Panel_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.Item.CardCollection_Dismantle_Panel_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/CardCollection_Dismantle_Panel_UIBP.CardCollection_Dismantle_Panel_UIBP"
  },
  CardCollection_Exchange_Panel_UIBP = {
    keyName = "CardCollection_Exchange_Panel_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.Item.CardCollection_Exchange_Panel_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/CardCollection_Exchange_Panel_UIBP.CardCollection_Exchange_Panel_UIBP"
  },
  CardCollection_DirectExchange_Panel_UIBP = {
    keyName = "CardCollection_DirectExchange_Panel_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.Item.CardCollection_DirectExchange_Panel_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/CardCollection_DirectExchange_Panel_UIBP.CardCollection_DirectExchange_Panel_UIBP"
  },
  CardCollection_Swap_Record_UIBP = {
    keyName = "CardCollection_Swap_Record_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.Item.CardCollection_Swap_Record_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/CardCollection_Swap_Record_UIBP.CardCollection_Swap_Record_UIBP"
  },
  CardCollection_Gift_Record_UIBP = {
    keyName = "CardCollection_Gift_Record_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.Item.CardCollection_Gift_Record_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/CardCollection_Gift_Record_UIBP.CardCollection_Gift_Record_UIBP"
  },
  CardCollection_Mutual_Aid_Record_UIBP = {
    keyName = "CardCollection_Mutual_Aid_Record_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.Item.CardCollection_Mutual_Aid_Record_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/CardCollection_Mutual_Aid_Record_UIBP.CardCollection_Mutual_Aid_Record_UIBP"
  },
  CardCollection_Obtain_Way_Popup_UIBP = {
    keyName = "CardCollection_Obtain_Way_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Obtain_Way_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Obtain_Way_Popup_UIBP.CardCollection_Obtain_Way_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\233\155\134\229\141\161-\229\141\161\231\137\140\232\142\183\229\190\151\231\149\140\233\157\162"
    }
  },
  CardCollection_DailyTask_Popup_UIBP = {
    keyName = "CardCollection_DailyTask_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_DailyTask_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_DailyTask_Popup_UIBP.CardCollection_DailyTask_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\233\155\134\229\141\161-\230\175\143\230\151\165\228\187\187\229\138\161"
    }
  },
  CardCollection_DailyTask_Guide_UIBP = {
    keyName = "CardCollection_DailyTask_Guide_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_DailyTask_Guide_UIBP",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Explain_UIBP.Common_Popup_Theme_Explain_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\233\155\134\229\141\161-\228\187\187\229\138\161\229\188\149\229\175\188"
    }
  },
  CardCollection_Level_Popup = {
    keyName = "CardCollection_Level_Popup",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Level_Popup",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Level_Popup.CardCollection_Level_Popup",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\233\155\134\229\141\161-\231\148\159\230\182\175\231\173\137\231\186\167\232\175\180\230\152\142"
    }
  },
  CardCollection_Score_Popup = {
    keyName = "CardCollection_Score_Popup",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Score_Popup",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Score_Popup.CardCollection_Score_Popup",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\233\155\134\229\141\161-\230\148\182\233\155\134\229\136\134\232\175\180\230\152\142"
    }
  },
  CardCollection_MutualAid_Popup_UIBP = {
    keyName = "CardCollection_MutualAid_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_MutualAid_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_MutualAid_Popup_UIBP.CardCollection_MutualAid_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\233\155\134\229\141\161-\228\186\146\229\138\169\229\138\160\230\136\144\232\175\180\230\152\142"
    }
  },
  CardCollection_NarutoGet_Popup_UIBP = {
    keyName = "CardCollection_NarutoGet_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_NarutoGet_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_NarutoGet_Popup_UIBP.CardCollection_NarutoGet_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\155\134\229\141\161-\231\129\171\229\189\177\233\151\170\229\141\161\232\142\183\229\190\151\232\161\168\231\142\176"
    }
  },
  Common_Button_UIBP = {
    keyName = "Common_Button_UIBP",
    moduleName = "client.slua.component.button.Common_Button_UIBP",
    isSingleton = false,
    isMainUI = false
  },
  Common_Button_Buy_UIBP = {
    keyName = "Common_Button_Buy_UIBP",
    moduleName = "client.slua.component.button.Common_Button_Buy_UIBP",
    isSingleton = false,
    isMainUI = false
  },
  ChatRedpacketEntryUIBP = {
    keyName = "ChatRedpacketEntryUIBP",
    moduleName = "client.slua.umg.crp.ChatRedpacketEntryPopup",
    path = "/Game/Mod/Lobby/Split/LobbyChat/ChatRedpacketEntryUIBP.ChatRedpacketEntryUIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\129\138\229\164\169\233\162\145\233\129\147-\231\186\162\229\140\133\229\133\165\229\143\163"
    }
  },
  CardCollection_Swap_Select_Own_Popup_UIBP = {
    keyName = "CardCollection_Swap_Select_Own_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Swap_Select_Own_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Select_Popup_UIBP.CardCollection_Select_Popup_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161-\228\186\164\230\141\162\233\128\137\230\139\169\229\183\178\230\139\165\230\156\137\231\154\132\229\141\161\229\188\185\231\170\151"
    }
  },
  CardCollection_Swap_Req_Popup_UIBP = {
    keyName = "CardCollection_Swap_Req_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Swap_Req_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Swap_Req_Popup_UIBP.CardCollection_Swap_Req_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\233\155\134\229\141\161-\228\186\164\230\141\162\229\143\145\232\181\183\229\188\185\231\170\151"
    }
  },
  CardCollection_Swap_Rsp_Popup_UIBP = {
    keyName = "CardCollection_Swap_Rsp_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Swap_Rsp_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Swap_Rsp_Popup_UIBP.CardCollection_Swap_Rsp_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\233\155\134\229\141\161-\228\186\164\230\141\162\229\155\158\229\186\148\229\188\185\231\170\151"
    }
  },
  UGC_Popup_Guide_UIBP = {
    keyName = "UGC_Popup_Guide_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_Popup_Guide_UIBP",
    path = "/Game/UMG/UI_BP/Common/Guide/Common_Guide_UIBP.Common_Guide_UIBP",
    uiStat = {
      name = "\229\164\167\229\155\190\231\137\136\226\128\148\230\139\141\232\132\184\229\155\190\229\188\149\229\175\188"
    }
  },
  CardCollection_NewGuide_Popup_UIBP = {
    keyName = "CardCollection_NewGuide_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_NewGuide_Popup_UIBP",
    isMainUI = false,
    containerName = UIContainers.Top,
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_NewGuide_Popup_UIBP.CardCollection_NewGuide_Popup_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161-\229\188\149\229\175\188\229\188\185\231\170\151"
    }
  },
  CardCollection_Swap_Select_Want_Popup_UIBP = {
    keyName = "CardCollection_Swap_Select_Want_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Swap_Select_Want_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Select_Popup_UIBP.CardCollection_Select_Popup_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161-\228\186\164\230\141\162\233\128\137\230\139\169\230\131\179\232\166\129\231\154\132\229\141\161\229\188\185\231\170\151"
    }
  },
  CardCollection_Start_Reward_UIBP = {
    keyName = "CardCollection_Start_Reward_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CardCollection_Start_Reward_UIBP",
    isMainUI = false,
    containerName = UIContainers.Top,
    path = "/Game/Mod/Lobby/Split/CardCollection/CardCollection_Start_Reward_UIBP.CardCollection_Start_Reward_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161-\229\188\128\229\167\139\229\165\150\229\138\177\231\149\140\233\157\162"
    }
  },
  CardCollection_Multi_Share_UIBP = {
    keyName = "CardCollection_Multi_Share_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Item.CardCollection_Multi_Share_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/Collection_ShareMultiple_Item.Collection_ShareMultiple_Item",
    uiStat = {
      name = "\233\155\134\229\141\161-\229\164\154\229\188\160\229\141\161\231\137\140\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  CardCollection_Album_UIBP = {
    keyName = "CardCollection_Album_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CardCollection_Album_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/CardCollection_Album_UIBP.CardCollection_Album_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\233\155\134\229\141\161-\230\148\182\232\151\143\229\134\140\231\149\140\233\157\162"
    }
  },
  CardCollection_DirftCard_UIBP = {
    keyName = "CardCollection_DirftCard_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CardCollection_DirftCard_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/CardCollection_DirftCard_UIBP.CardCollection_DirftCard_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161-\230\188\130\230\181\129\231\147\182\232\142\183\229\190\151\231\149\140\233\157\162"
    }
  },
  CardCollection_Drift_Add_Friend_UIBP = {
    keyName = "CardCollection_Drift_Add_Friend_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Drift_Add_Friend_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Drift_Add_Friend_UIBP.CardCollection_Drift_Add_Friend_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161-\230\188\130\230\181\129\231\147\182\230\183\187\229\138\160\229\165\189\229\143\139\229\188\149\229\175\188\229\188\185\231\170\151"
    }
  },
  ReturnActivity_Openning_Page_UIBP = {
    keyName = "ReturnActivity_Openning_Page_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_Openning_Page_UIBP",
    isMainUI = false,
    path = "/Game/UMG/UI_BP/ReturnActivity/Opening/ReturnActivity_Openning_Page_UIBP.ReturnActivity_Openning_Page_UIBP",
    uiStat = {
      name = "\229\155\158\230\181\129\229\188\128\229\177\128\231\164\188\231\137\169"
    }
  },
  ReturnActivity_Openning_Page_Slap_UIBP = {
    keyName = "ReturnActivity_Openning_Page_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_Openning_Page_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/Opening/ReturnActivity_Openning_Page_UIBP.ReturnActivity_Openning_Page_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\229\155\158\230\181\129\229\188\128\229\177\128\231\164\188\231\137\169-\230\139\141\232\132\184"
    }
  },
  SmartAssistantV2_MainDialogue_UIBP = {
    keyName = "SmartAssistantV2_MainDialogue_UIBP",
    moduleName = "client.slua.umg.SmartAssistantV2.SmartAssistantV2_MainDialogue_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistantV2/SmartAssistantV2_MainDialogue_UIBP.SmartAssistantV2_MainDialogue_UIBP",
    jumpModuleID = BP_ENUM_MODULE_SMART_ASSISTANT_V2_CHAT,
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\228\184\187\229\175\185\232\175\157\231\149\140\233\157\162"
    }
  },
  SmartAssistantV2_ReceiveAward_UIBP = {
    keyName = "SmartAssistantV2_ReceiveAward_UIBP",
    moduleName = "client.slua.umg.SmartAssistantV2.SmartAssistantV2_ReceiveAward_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistantV2/SmartAssistantV2_ReceiveAward_UIBP.SmartAssistantV2_ReceiveAward_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\229\165\150\229\138\177\229\146\140\228\186\139\228\187\182\229\188\185\231\170\151"
    }
  },
  SmartAssistantV2_MoreInform_UIBP = {
    keyName = "SmartAssistantV2_MoreInform_UIBP",
    moduleName = "client.slua.umg.SmartAssistantV2.SmartAssistantV2_MoreInform_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistantV2/SmartAssistantV2_MoreInform_UIBP.SmartAssistantV2_MoreInform_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\230\155\180\229\164\154\233\128\154\231\159\165"
    }
  },
  SmartAssistantV2_Feedback_Popup_UIBP = {
    keyName = "SmartAssistantV2_Feedback_Popup_UIBP",
    moduleName = "client.slua.umg.SmartAssistantV2.Popup.SmartAssistantV2_Feedback_Popup_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistantV2/Popup/SmartAssistantV2_Feedback_Popup_UIBP.SmartAssistantV2_Feedback_Popup_UIBP",
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\229\143\141\233\166\136\229\188\185\231\170\151"
    }
  },
  SmartAssistantV2_LobbyDialogue_UIBP = {
    keyName = "SmartAssistantV2_LobbyDialogue_UIBP",
    moduleName = "client.slua.umg.SmartAssistantV2.SmartAssistantV2_LobbyDialogue_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistantV2/SmartAssistantV2_LobbyDialogue_UIBP.SmartAssistantV2_LobbyDialogue_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\228\184\187\229\138\168\229\175\185\232\175\157\230\176\148\230\179\161\232\175\166\230\131\133\233\161\181"
    }
  },
  SmartAssistantV2_Dialogue_Item_UIBP_02 = {
    keyName = "SmartAssistantV2_Dialogue_Item_UIBP_02",
    moduleName = "client.slua.umg.SmartAssistantV2.Item.SmartAssistantV2_Dialogue_Item_UIBP_02",
    path = "/Game/UMG/UI_BP/SmartAssistantV2/Item/SmartAssistantV2_Dialogue_Item_UIBP_02.SmartAssistantV2_Dialogue_Item_UIBP_02",
    isMainUI = false,
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\228\184\187\229\138\168\229\175\185\232\175\157\230\176\148\230\179\161\232\175\166\230\131\133\233\161\181-item"
    }
  },
  SmartAssistantV2_RobotBubble_Item_UIBP = {
    keyName = "SmartAssistantV2_RobotBubble_Item_UIBP",
    moduleName = "client.slua.umg.SmartAssistantV2.Item.SmartAssistantV2_RobotBubble_Item_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistantV2/Item/SmartAssistantV2_RobotBubble_Item_UIBP.SmartAssistantV2_RobotBubble_Item_UIBP",
    containerName = UIContainers.Bottom,
    isMainUI = false,
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\230\156\186\229\153\168\228\186\186\230\176\148\230\179\161"
    }
  },
  SmartAssistantV2_AIChat_Popups_UIBP = {
    keyName = "SmartAssistantV2_AIChat_Popups_UIBP",
    moduleName = "client.slua.umg.SmartAssistantV2.Popup.SmartAssistantV2_AIChat_Popups_UIBP",
    path = "/Game/UMG/UI_BP/Home/Audit/Home_Prompt_Popups_UIBP.Home_Prompt_Popups_UIBP",
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\231\159\165\230\131\133\229\144\140\230\132\143\228\185\166"
    }
  },
  SmartAssistantV2_DailyQuote_Result_UIBP = {
    keyName = "SmartAssistantV2_DailyQuote_Result_UIBP",
    moduleName = "client.slua.umg.SmartAssistantV2.SmartAssistantV2_DailyQuote_Result_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistantV2/SmartAssistantV2_DailyQuote_Result_UIBP.SmartAssistantV2_DailyQuote_Result_UIBP",
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\230\175\143\230\151\165\228\184\128\231\173\190"
    }
  },
  SmartAssistantV2_Develop_UIBP = {
    keyName = "SmartAssistantV2_Develop_UIBP",
    moduleName = "client.slua.umg.SmartAssistantV2.SmartAssistantV2_Develop_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistantV2/SmartAssistantV2_Develop_UIBP.SmartAssistantV2_Develop_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\229\133\187\230\136\144\231\149\140\233\157\162"
    }
  },
  SmartAssistantV2_Lobby_Panel_UIBP = {
    keyName = "SmartAssistantV2_Lobby_Panel_UIBP",
    moduleName = "client.slua.umg.SmartAssistantV2.SmartAssistantV2_Lobby_Panel_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistantV2/SmartAssistantV2_Lobby_Panel_UIBP.SmartAssistantV2_Lobby_Panel_UIBP",
    jumpModuleID = BP_ENUM_MODULE_SMART_ASSISTANT_V2_MAIN,
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\228\184\187\231\149\140\233\157\162"
    }
  },
  SmartAssistant_RobotTips01_UIBP = {
    keyName = "SmartAssistant_RobotTips01_UIBP",
    moduleName = "client.slua.umg.SmartAssistant.Robot.SmartAssistant_RobotTips01_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistant/Robot/SmartAssistant_RobotTips01_UIBP.SmartAssistant_RobotTips01_UIBP",
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\232\174\190\231\189\174\230\130\172\230\181\174\231\149\140\233\157\162"
    }
  },
  SmartAssistant_RobotTips02_UIBP = {
    keyName = "SmartAssistant_RobotTips02_UIBP",
    moduleName = "client.slua.umg.SmartAssistant.Robot.SmartAssistant_RobotTips02_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistant/Robot/SmartAssistant_RobotTips02_UIBP.SmartAssistant_RobotTips02_UIBP",
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\232\174\190\231\189\174\230\130\172\230\181\174\231\149\140\233\157\162\239\188\136\232\163\133\233\133\141\228\184\147\231\148\168\239\188\137"
    }
  },
  SmartAssistant_RobotTips03_UIBP = {
    keyName = "SmartAssistant_RobotTips03_UIBP",
    moduleName = "client.slua.umg.SmartAssistant.Robot.SmartAssistant_RobotTips03_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistant/Robot/SmartAssistant_RobotTips03_UIBP.SmartAssistant_RobotTips03_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\233\128\154\231\148\168\230\156\186\229\153\168\228\186\186\230\143\144\231\164\186"
    }
  },
  SmartAssistant_RobotTips04_UIBP = {
    keyName = "SmartAssistant_RobotTips04_UIBP",
    moduleName = "client.slua.umg.SmartAssistant.Robot.SmartAssistant_RobotTips04_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistant/Robot/SmartAssistant_RobotTips04_UIBP.SmartAssistant_RobotTips04_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\233\128\154\231\148\168\230\156\186\229\153\168\228\186\186\230\143\144\231\164\186"
    }
  },
  SmartAssistantV2_View_Popup_UIBP = {
    keyName = "SmartAssistantV2_View_Popup_UIBP",
    moduleName = "client.slua.umg.SmartAssistantV2.Popup.SmartAssistantV2_View_Popup_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistantV2/Popup/SmartAssistantV2_View_Popup_UIBP.SmartAssistantV2_View_Popup_UIBP",
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139V2-\230\159\165\231\156\139\229\155\190\231\137\135\230\182\136\230\129\175\229\188\185\231\170\151"
    }
  },
  Login_Agreement_UIBP = {
    keyName = "Login_Agreement_UIBP",
    moduleName = "client.slua.umg.NewLogin.Login_Agreement_UIBP",
    path = "/Game/Mod/Lobby/Base/Login/Login_Agreement_UIBP.Login_Agreement_UIBP",
    uiStat = {
      name = "\231\153\187\229\189\149\230\179\149\232\167\132\229\141\143\232\174\174\231\149\140\233\157\162"
    }
  },
  CardCollection_Card_Detail_Unowned_UIBP = {
    keyName = "CardCollection_Card_Detail_Unowned_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Item.CardCollection_Card_Detail_Unowned_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/CardCollection_Card_Detail_Unowned_UIBP.CardCollection_Card_Detail_Unowned_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\230\156\170\230\139\165\230\156\137\229\141\161\231\137\140\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  CardCollection_Card_Detail_Owned_UIBP = {
    keyName = "CardCollection_Card_Detail_Owned_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Item.CardCollection_Card_Detail_Owned_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/CardCollection_Card_Detail_Owned_UIBP.CardCollection_Card_Detail_Owned_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\230\139\165\230\156\137\229\141\161\231\137\140\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  CardCollection_Card_Detail_Owned_Karambit_Perks_UIBP = {
    keyName = "CardCollection_Card_Detail_Owned_Karambit_Perks_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Item.CardCollection_Card_Detail_Owned_Karambit_Perks_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/CardCollection_Card_Detail_Owned_Karambit_Perks_UIBP.CardCollection_Card_Detail_Owned_Karambit_Perks_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\231\136\170\229\136\128\230\157\131\231\155\138"
    }
  },
  CardCollection_Common_Perks_UIBP = {
    keyName = "CardCollection_Common_Perks_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Item.CardCollection_Common_Perks_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/CardCollection_Common_Perks_UIBP.CardCollection_Common_Perks_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\233\128\154\231\148\168\230\157\131\231\155\138"
    }
  },
  CardCollection_Limited_UIBP = {
    keyName = "CardCollection_Limited_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Item.CardCollection_Limited_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/CardCollection_Limited_UIBP.CardCollection_Limited_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\233\153\144\233\135\143\229\141\161\228\191\161\230\129\175"
    }
  },
  CardCollection_Single_Share_UIBP = {
    keyName = "CardCollection_Single_Share_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Item.CardCollection_Single_Share_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/Collection_ShareOne_Item.Collection_ShareOne_Item",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\229\141\149\229\141\161\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  CardCollection_Obtain_Task_List_UIBP = {
    keyName = "CardCollection_Obtain_Task_List_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.Item.CardCollection_Obtain_Task_List_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/CardCollection_Obtain_Task_List_UIBP.CardCollection_Obtain_Task_List_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\231\179\187\229\136\151\232\142\183\229\143\150\233\128\148\229\190\132\228\187\187\229\138\161\229\136\151\232\161\168\231\149\140\233\157\162"
    }
  },
  CardCollection_Obtain_Pack_List_UIBP = {
    keyName = "CardCollection_Obtain_Pack_List_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.Item.CardCollection_Obtain_Pack_List_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/CardCollection_Obtain_Pack_List_UIBP.CardCollection_Obtain_Pack_List_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\231\179\187\229\136\151\232\142\183\229\143\150\233\128\148\229\190\132\229\141\161\229\140\133\229\136\151\232\161\168\231\149\140\233\157\162"
    }
  },
  CardCollection_Obtain_Desc_List_UIBP = {
    keyName = "CardCollection_Obtain_Desc_List_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.Item.CardCollection_Obtain_Desc_List_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/CardCollection_Obtain_Desc_List_UIBP.CardCollection_Obtain_Desc_List_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\231\179\187\229\136\151\232\142\183\229\143\150\233\128\148\229\190\132\228\186\164\230\141\162\232\181\160\233\128\129\232\175\180\230\152\142\231\149\140\233\157\162"
    }
  },
  CardCollection_NewGuide_UpgradeCard_UIBP = {
    keyName = "CardCollection_NewGuide_UpgradeCard_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Newbie.CardCollection_NewGuide_UpgradeCard_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Newbie/CardCollection_NewGuide_UpgradeCard_UIBP.CardCollection_NewGuide_UpgradeCard_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\230\150\176\230\137\139\230\181\129\231\168\139\229\141\135\231\186\167\229\141\161\231\149\140\233\157\162"
    }
  },
  CardCollection_NewGuide_FirstYear_UIBP = {
    keyName = "CardCollection_NewGuide_FirstYear_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Newbie.CardCollection_NewGuide_FirstYear_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Newbie/CardCollection_NewGuide_FirstYear_UIBP.CardCollection_NewGuide_FirstYear_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\230\150\176\230\137\139\230\181\129\231\168\139\230\179\168\229\134\140\229\185\180\233\153\144\231\149\140\233\157\162"
    }
  },
  CardCollection_NewGuide_CollectLevel_UIBP = {
    keyName = "CardCollection_NewGuide_CollectLevel_UIBP",
    isMainUI = false,
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Newbie.CardCollection_NewGuide_CollectLevel_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Newbie/CardCollection_NewGuide_CollectLevel_UIBP.CardCollection_NewGuide_CollectLevel_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\230\150\176\230\137\139\230\181\129\231\168\139\231\143\141\232\151\143\231\173\137\231\186\167\231\149\140\233\157\162"
    }
  },
  Assembly_Main_UIBP = {
    keyName = "Assembly_Main_UIBP",
    moduleName = "client.slua.umg.COMEBACK.Assembly_Main_UIBP",
    path = "/Game/Mod/Lobby/Split/AssemblyComeBack/Assembly_Main_UIBP.Assembly_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_ASSEMBLY,
    uiStat = {
      name = "\233\155\134\231\187\147\231\179\187\231\187\159\228\184\187\231\149\140\233\157\162"
    }
  },
  Lobby_Mid_NewRecruit_Item_UIBP = {
    keyName = "Lobby_Mid_NewRecruit_Item_UIBP",
    moduleName = "client.slua.umg.lobby.Mid.Item.Lobby_Mid_NewRecruit_Item_UIBP",
    path = "/Game/Mod/Lobby/Base/Mid/Item/Lobby_Mid_NewRecruit_Item_UIBP.Lobby_Mid_NewRecruit_Item_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168\229\164\167\229\142\133\229\133\165\229\143\163"
    },
    isMainUI = false
  },
  PSKillSprint_Popup_UIBP = {
    keyName = "PSKillSprint_Popup_UIBP",
    moduleName = "client.slua.umg.PSKillSprint.PSKillSprint_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/PSKillSprint/PSKillSprint_Popup_UIBP.PSKillSprint_Popup_UIBP",
    uiStat = {
      name = "\228\184\187\233\162\152\232\129\140\228\184\154\229\188\185\231\170\151 - \229\164\167\229\142\133"
    }
  },
  CardCollection_Get_Card_UIBP = {
    keyName = "CardCollection_Get_Card_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CardCollection_Get_Card_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/CardGet_Popup_UIBP.CardGet_Popup_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\230\129\173\229\150\156\232\142\183\229\190\151\231\149\140\233\157\162"
    }
  },
  CardCollection_Completion_UIBP = {
    keyName = "CardCollection_Completion_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CardCollection_Completion_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Collection_FeedBack_UIBP.Collection_FeedBack_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\233\155\134\233\189\144\231\149\140\233\157\162"
    }
  },
  CardCollection_Season_Completion_Share_UIBP = {
    keyName = "CardCollection_Season_Completion_Share_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Item.CardCollection_Season_Completion_Share_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/Collection_ShareSet_Item.Collection_ShareSet_Item",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\233\155\134\233\189\144\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  CardCollection_Rare_Card_Get_UIBP = {
    keyName = "CardCollection_Rare_Card_Get_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CardCollection_Rare_Card_Get_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/CardCollection_Rare_Card_Get_UIBP.CardCollection_Rare_Card_Get_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\233\153\144\233\135\143\233\151\170\229\141\161\230\129\173\229\150\156\232\142\183\229\190\151\231\149\140\233\157\162"
    }
  },
  CardCollection_Rare_Card_Share_UIBP = {
    keyName = "CardCollection_Rare_Card_Share_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CardCollection_Rare_Card_Share_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/CardCollection_Rare_Card_Share_UIBP.CardCollection_Rare_Card_Share_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\233\153\144\233\135\143\233\151\170\229\141\161\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  Collection_Card_Naruto_UIBP = {
    keyName = "Collection_Card_Naruto_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.SpecialCard.Collection_Card_Naruto_UIBP",
    isMainUI = false,
    isSingleton = false,
    path = "/Game/Mod/Lobby/Base/CardCollection/Collection_Card_Naruto_UIBP.Collection_Card_Naruto_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\231\129\171\229\189\177\231\137\185\230\174\138\229\141\161\232\147\157\229\155\190"
    }
  },
  CardCollection_SwapShare_UIBP = {
    keyName = "CardCollection_SwapShare_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CardCollection_SwapShare_UIBP",
    isMainUI = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/CardCollection_SwapShare_UIBP.CardCollection_SwapShare_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\228\186\164\230\141\162\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  NewRecruit_NewbieTask_PopUp = {
    keyName = "NewRecruit_NewbieTask_PopUp",
    moduleName = "client.slua.umg.NewRecruit.NewbieTask.PopUp.NewRecruit_NewbieTask_PopUp",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewRecruit/NewbieTask/PopUp/NewRecruit_NewbieTask_PopUp.NewRecruit_NewbieTask_PopUp",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168\228\184\137\233\128\137\228\184\128\229\165\150\229\138\177\231\149\140\233\157\162"
    }
  },
  NewRecruit_DailyWish_Preview = {
    keyName = "NewRecruit_DailyWish_Preview",
    moduleName = "client.slua.umg.NewRecruit.DailyWish.PopUp.NewRecruit_DailyWish_Preview",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewRecruit/DailyWish/PopUp/NewRecruit_DailyWish_Preview.NewRecruit_DailyWish_Preview",
    uiStat = {
      name = "\230\150\176\229\133\181\230\175\143\230\151\165\230\138\189\229\165\150\233\162\132\232\167\136\231\149\140\233\157\162"
    }
  },
  Lobby_SeasonUI_Homepage_New01_Sidebar_UIBP = {
    keyName = "Lobby_SeasonUI_Homepage_New01_Sidebar_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_SeasonUI_Homepage_New01_Sidebar_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Lobby_SeasonUI_Homepage_New01_Sidebar_UIBP.Lobby_SeasonUI_Homepage_New01_Sidebar_UIBP",
    jumpModuleID = BP_ENUM_MODULE_SEASON_NEW,
    limitScene = GameStatus.Lobby,
    uiStat = {
      name = "\230\150\176\232\181\155\229\173\163\228\184\187\231\149\140\233\157\162"
    }
  },
  Lobby_SeasonUI_Homepage_New01_UIBP = {
    keyName = "Lobby_SeasonUI_Homepage_New01_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_SeasonUI_Homepage_New01_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Lobby_SeasonUI_Homepage_New01_UIBP.Lobby_SeasonUI_Homepage_New01_UIBP",
    isMainUI = false,
    enableCDNCompress = true,
    uiStat = {
      name = "\231\187\143\229\133\184\232\181\155\230\150\176\231\149\140\233\157\162"
    }
  },
  Lobby_SeasonUI_Homepage_TopLeft_UIBP = {
    keyName = "Lobby_SeasonUI_Homepage_TopLeft_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Lobby_SeasonUI_Homepage_TopLeft_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Lobby_SeasonUI_Homepage_TopLeft_UIBP.Lobby_SeasonUI_Homepage_TopLeft_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\187\143\229\133\184\232\181\155\230\150\176\231\149\140\233\157\162- \229\183\166\228\184\138\232\167\146\230\140\137\233\146\174"
    }
  },
  Lobby_Season_Leisure_MainInterface_new_UIBP = {
    keyName = "Lobby_Season_Leisure_MainInterface_new_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Leisure.Lobby_Season_Leisure_MainInterface_new_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Leisure/Lobby_Season_Leisure_MainInterface_new_UIBP.Lobby_Season_Leisure_MainInterface_new_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\188\145\233\151\178\232\181\155\230\150\176\231\149\140\233\157\162"
    }
  },
  Lobby_Season_Leisure_MainInterface_new02_UIBP = {
    keyName = "Lobby_Season_Leisure_MainInterface_new02_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.Leisure.Lobby_Season_Leisure_MainInterface_new02_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Leisure/Lobby_Season_Leisure_MainInterface_new02_UIBP.Lobby_Season_Leisure_MainInterface_new02_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\188\145\233\151\178\232\181\155\228\187\187\229\138\161\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  Lobby_PeakGame_Homepage_new_UIBP = {
    keyName = "Lobby_PeakGame_Homepage_new_UIBP",
    moduleName = "client.slua.umg.PeakGame.Lobby_PeakGame_Homepage_new_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Lobby_PeakGame_Homepage_new_UIBP.Lobby_PeakGame_Homepage_new_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\230\150\176\231\149\140\233\157\162"
    }
  },
  CardCollection_Removal_UIBP = {
    keyName = "CardCollection_Removal_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CardCollection_Removal_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/CardCollection_Removal_UIBP.CardCollection_Removal_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\230\139\134\229\141\161\229\140\133\231\149\140\233\157\162"
    }
  },
  CardCollection_Swap_Info_Popup_UIBP = {
    keyName = "CardCollection_Swap_Info_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Swap_Info_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Swap_Rsp_Popup_UIBP.CardCollection_Swap_Rsp_Popup_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\231\189\174\230\141\162\232\174\176\229\189\149\228\186\164\230\141\162\232\175\166\230\131\133\229\188\185\231\170\151"
    }
  },
  CardCollection_SpecialCard_Popup_UIBP = {
    keyName = "CardCollection_SpecialCard_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_SpecialCard_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_SpecialCard_Popup_UIBP.CardCollection_SpecialCard_Popup_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\231\137\185\230\174\138\229\141\161\232\175\180\230\152\142\229\188\185\231\170\151"
    }
  },
  CardCollection_SpecialBuffCard_Popup_UIBP = {
    keyName = "CardCollection_SpecialBuffCard_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_SpecialBuffCard_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_SpecialBuffCard_Popup_UIBP.CardCollection_SpecialBuffCard_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\228\188\160\229\165\135\231\136\170\229\136\128\230\191\128\230\180\187\229\188\185\231\170\151\239\188\136\233\153\144\230\151\182\239\188\137"
    }
  },
  CardCollection_SpecialBuffCard_Popup_UIBP2 = {
    keyName = "CardCollection_SpecialBuffCard_Popup_UIBP2",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_SpecialBuffCard_Popup_UIBP2",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_SpecialBuffCard_Popup_UIBP2.CardCollection_SpecialBuffCard_Popup_UIBP2",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\228\188\160\229\165\135\231\136\170\229\136\128\230\191\128\230\180\187\229\188\185\231\170\151\239\188\136\230\176\184\228\185\133\239\188\137"
    }
  },
  CardCollection_Additonal_Award_Desc_Popup_UIBP = {
    keyName = "CardCollection_Additonal_Award_Desc_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Additonal_Award_Desc_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Additonal_Award_Desc_Popup_UIBP.CardCollection_Additonal_Award_Desc_Popup_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\230\131\138\229\150\156\229\141\161\229\140\133\233\162\157\229\164\150\229\165\150\229\138\177\230\143\143\232\191\176\229\188\185\231\170\151"
    }
  },
  CardCollection_Additional_Award_Tips_UIBP = {
    keyName = "CardCollection_Additional_Award_Tips_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CardCollection_Additional_Award_Tips_UIBP",
    isMainUI = false,
    isSingleton = false,
    path = "/Game/Mod/Lobby/Split/CardCollection/CardCollection_Additional_Award_Tips_UIBP.CardCollection_Additional_Award_Tips_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\230\131\138\229\150\156\229\141\161\229\140\133\233\162\157\229\164\150\229\165\150\229\138\177tips"
    }
  },
  CardCollection_Preview_Popup_UIBP = {
    keyName = "CardCollection_Preview_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Preview_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Preview_Popup_UIBP.CardCollection_Preview_Popup_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-\229\141\161\229\140\133\229\165\150\230\177\160\233\162\132\232\167\136"
    }
  },
  CardCollection_Gun_Popup_UIBP = {
    keyName = "CardCollection_Gun_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Popup.CardCollection_Gun_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/Popup/CardCollection_Gun_Popup_UIBP.CardCollection_Gun_Popup_UIBP",
    uiStat = {
      name = "\233\155\134\229\141\161\231\179\187\231\187\159-5\231\186\167\230\158\170\229\174\163\228\188\160"
    }
  },
  Return_ModeSelect_UIBP = {
    keyName = "Return_ModeSelect_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.Return_ModeSelect_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/Return_ModeSelect_UIBP.Return_ModeSelect_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\155\158\230\181\129\230\168\161\229\188\143\233\128\137\230\139\169-\231\149\140\233\157\162"
    }
  },
  Lobby_BT_Guide_UIBP = {
    keyName = "Lobby_BT_Guide_UIBP",
    moduleName = "client.slua.umg.PlanBT.Lobby_BT_Guide_UIBP",
    path = "/Game/UMG/UI_BP/PlanBT/Lobby_BT_Guide_UIBP.Lobby_BT_Guide_UIBP",
    uiStat = {
      name = "\231\137\185\230\174\138\231\142\169\230\179\149\230\139\141\232\132\184\231\149\140\233\157\162"
    }
  },
  RealTimeCaptureShow_Item = {
    keyName = "RealTimeCaptureShow_Item",
    moduleName = "client.slua.umg.common.Capture.RealTimeCaptureShow_Item",
    path = "/Game/UMG/UI_BP/Common/Capture/RealTimeCaptureShow_Item.RealTimeCaptureShow_Item",
    uiStat = {
      name = "\233\128\154\231\148\168\229\174\158\230\151\182\230\141\149\232\142\183\230\142\167\228\187\182"
    }
  },
  Common_PageGuide_UIBP = {
    keyName = "Common_PageGuide_UIBP",
    moduleName = "client.slua.umg.common.Guide.Common_PageGuide_UIBP",
    path = "/Game/UMG/UI_BP/Common/Guide/Common_PageGuide_UIBP.Common_PageGuide_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\128\154\231\148\168\231\191\187\233\161\181\229\188\149\229\175\188"
    }
  },
  Common_PageGuide_Theme_UIBP = {
    keyName = "Common_PageGuide_Theme_UIBP",
    moduleName = "client.slua.umg.common.Guide.Common_PageGuide_Theme_UIBP",
    path = "/Game/UMG/UI_BP/Common/Guide/Common_PageGuide_Theme_UIBP.Common_PageGuide_Theme_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\231\191\187\233\161\181\229\188\149\229\175\188-\228\184\187\233\162\152"
    }
  },
  Common_PageGuide_Theme_Role_UIBP = {
    keyName = "Common_PageGuide_Theme_Role_UIBP",
    moduleName = "client.slua.umg.common.Guide.Common_PageGuide_Theme_Role_UIBP",
    path = "/Game/UMG/UI_BP/Common/Guide/Common_PageGuide_Theme_Role_UIBP.Common_PageGuide_Theme_Role_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\231\191\187\233\161\181\229\188\149\229\175\188-\228\184\187\233\162\152\227\128\129\229\184\166\232\167\146\232\137\178"
    }
  },
  LobbyChat_InformationCustomDetail_UIBP = {
    keyName = "LobbyChat_InformationCustomDetail_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Item.LobbyChat_InformationCustomDetail_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/InformationCustom/LobbyChat_InformationCustomDetail_UIBP.LobbyChat_InformationCustomDetail_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\231\164\190\228\186\164\229\144\141\231\137\135-\228\184\170\230\128\167\229\140\150\229\177\149\231\164\186-\229\144\141\231\137\135\233\157\162\230\157\191"
    }
  },
  Lobby_Main_Tab_Guide_UIBP = {
    keyName = "Lobby_Main_Tab_Guide_UIBP",
    moduleName = "client.slua.umg.lobby.Main.Item.Lobby_Main_Tab_Guide_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Item/Lobby_Main_Tab_Guide_UIBP.Lobby_Main_Tab_Guide_UIBP",
    isSingleton = false,
    uiStat = {
      name = "430\231\137\136\230\156\172\229\164\167\229\142\133\230\150\176\230\137\139\229\173\144\231\149\140\233\157\162"
    }
  },
  Lobby_NewBie_430_UIBP = {
    keyName = "Lobby_NewBie_430_UIBP",
    moduleName = "client.slua.umg.lobby.Main.Lobby_NewBie_430_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_NewBie_430_UIBP.Lobby_NewBie_430_UIBP",
    uiStat = {
      name = "430\231\137\136\230\156\172\229\164\167\229\142\133\230\150\176\230\137\139\231\149\140\233\157\162"
    }
  },
  CabinCard_MedalSelection_UIBP = {
    keyName = "CabinCard_MedalSelection_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.CabinCard_MedalSelection_UIBP",
    path = "/Game/Mod/Lobby/Split/CardCollection/CabinCard_MedalSelection_UIBP.CabinCard_MedalSelection_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\228\187\147\229\186\147-\230\156\186\232\136\177\229\177\149\231\164\186"
    }
  },
  ModeSelection_Map_Subway_Item = {
    keyName = "ModeSelection_Map_Subway_Item",
    moduleName = "client.slua.umg.ModeSelection.ModeSelection_Map_Subway_Item",
    isSingleton = false,
    isWindowsOBHide = true,
    path = "/Game/Mod/Lobby/Split/ModeSelection/Item/ModeSelection_Map_Subway_Item.ModeSelection_Map_Subway_Item",
    uiStat = {
      name = "\230\168\161\229\188\143\233\128\137\230\139\169-\229\156\176\233\147\129"
    }
  },
  ReturnActivity_Entrance_Item = {
    keyName = "ReturnActivity_Entrance_Item",
    moduleName = "client.slua.umg.ReturnActivity.Items.ReturnActivity_Entrance_Item",
    path = "/Game/Mod/Lobby/Base/ReturnActivity/Items/ReturnActivity_Entrance_Item.ReturnActivity_Entrance_Item",
    isMainUI = false,
    uiStat = {
      name = "\229\155\158\230\181\129\228\184\187\229\133\165\229\143\163"
    }
  },
  Lobby_EnhancedLobbyQualitySlap_UIBP = {
    keyName = "Lobby_EnhancedLobbyQualitySlap_UIBP",
    moduleName = "client.slua.umg.lobby.Popup.Lobby_EnhancedLobbyQualitySlap_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Popup/Lobby_EnhancedLobbyQualitySlap_UIBP.Lobby_EnhancedLobbyQualitySlap_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\231\148\187\232\180\168\229\162\158\229\188\186\230\139\141\232\132\184"
    }
  },
  SpecialOffer_GiftPack_Popup_UIBP = {
    keyName = "SpecialOffer_GiftPack_Popup_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.Common.SpecialOffer_GiftPack_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Material/UIBP/SpecialOffer_GiftPack_Popup_UIBP.SpecialOffer_GiftPack_Popup_UIBP",
    uiStat = {
      name = "\230\157\144\230\150\153\231\164\188\229\140\133\231\137\185\230\157\131\232\175\180\230\152\142\231\149\140\233\157\162"
    }
  },
  HonourCertificate_Main_UIBP = {
    keyName = "HonourCertificate_Main_UIBP",
    moduleName = "client.slua.umg.RoleInfo.HonourCertificate.HonourCertificate_Main_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/HonourCertificate/HonourCertificate_Main_UIBP.HonourCertificate_Main_UIBP",
    isMainUI = false,
    asy = true,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\232\175\129\228\185\166\231\179\187\231\187\159\228\184\187\231\149\140\233\157\162"
    }
  },
  HonourCertificate_Preview_Popup_UIBP = {
    keyName = "HonourCertificate_Preview_Popup_UIBP",
    moduleName = "client.slua.umg.roleInfo.HonourCertificate.HonourCertificate_Preview_Popup_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/HonourCertificate/HonourCertificate_Preview_Popup_UIBP.HonourCertificate_Preview_Popup_UIBP",
    uiStat = {
      name = "\232\175\129\228\185\166\231\179\187\231\187\159\233\162\132\232\167\136\231\149\140\233\157\162"
    }
  },
  HonourCertificate_Obtain_Popup_UIBP = {
    keyName = "HonourCertificate_Obtain_Popup_UIBP",
    moduleName = "client.slua.umg.roleInfo.HonourCertificate.HonourCertificate_Obtain_Popup_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/HonourCertificate/HonourCertificate_Obtain_Popup_UIBP.HonourCertificate_Obtain_Popup_UIBP",
    uiStat = {
      name = "\232\175\129\228\185\166\231\179\187\231\187\159\230\129\173\229\150\156\232\142\183\229\190\151\231\149\140\233\157\162"
    }
  },
  HonourCertificate_Share_UIBP = {
    keyName = "HonourCertificate_Share_UIBP",
    moduleName = "client.slua.umg.roleInfo.HonourCertificate.HonourCertificate_Share_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/HonourCertificate/HonourCertificate_Share_UIBP.HonourCertificate_Share_UIBP",
    uiStat = {
      name = "\232\175\129\228\185\166\231\179\187\231\187\159\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  Lobby_Season_RecordComponent_Popup_UIBP = {
    keyName = "Lobby_Season_RecordComponent_Popup_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Popups.Lobby_Season_RecordComponent_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Popups/Lobby_Season_RecordComponent_Popup_UIBP.Lobby_Season_RecordComponent_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\136\152\231\187\169\231\187\132\228\187\182\230\183\187\229\138\160\231\149\140\233\157\162"
    }
  },
  TeamQuick_SelectFriend_Popup = {
    keyName = "TeamQuick_SelectFriend_Popup",
    moduleName = "client.slua.umg.TeamQuick.Popup.TeamQuick_SelectFriend_Popup",
    path = "/Game/UMG/UI_BP/TeamQuick/Popup/TeamQuick_SelectFriend_Popup.TeamQuick_SelectFriend_Popup",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\229\176\143\233\152\159\228\184\187\233\161\181-\233\130\128\232\175\183\229\165\189\229\143\139"
    }
  },
  TeamQuick_Invite_Tips_UIBP = {
    keyName = "TeamQuick_Invite_Tips_UIBP",
    moduleName = "client.slua.umg.Universal_Popup.TeamQuick_Invite_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/TeamQuick_Invite_Tips_UIBP.TeamQuick_Invite_Tips_UIBP",
    uiStat = {
      name = "\233\130\128\232\175\183\231\187\132\233\152\159"
    }
  },
  PageGuide_Component_Test_UIBP = {
    keyName = "PageGuide_Component_Test_UIBP",
    moduleName = "client.slua.umg.common.Guide.PageGuide_Component_Test_UIBP",
    path = "/Game/UMG/UI_BP/Common/Guide/Test/PageGuide_Component_Test_UIBP.PageGuide_Component_Test_UIBP",
    uiStat = {
      name = "\230\181\139\232\175\149-\233\128\154\231\148\168-\229\188\149\229\175\188\231\187\132\228\187\182"
    }
  },
  GM_UI_Show_Queue_UIBP = {
    keyName = "GM_UI_Show_Queue_UIBP",
    moduleName = "blacklist.slua.umg.lobby_gm.GM_UI_Show_Queue_UIBP",
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.Click_Animation,
    AndroidBackType = EAndroidBackType.Skip,
    path = "/Game/UMG/UI_BP/GM/GM_UI_Show_Queue_UIBP.GM_UI_Show_Queue_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133GM-UI\233\152\159\229\136\151\230\159\165\231\156\139\229\153\168"
    }
  },
  Lobby_Season_PromotionProtection_Popup_UIBP = {
    keyName = "Lobby_Season_PromotionProtection_Popup_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.Popups.Lobby_Season_PromotionProtection_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/Classic/Popups/Lobby_Season_PromotionProtection_Popup_UIBP.Lobby_Season_PromotionProtection_Popup_UIBP",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155\230\140\145\230\136\152\229\128\188"
    }
  },
  Lobby_AbnormalStatus_Popup_UIBP = {
    keyName = "Lobby_AbnormalStatus_Popup_UIBP",
    moduleName = "client.slua.umg.lobby.Main.Lobby_AbnormalStatus_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_AbnormalStatus_Popup_UIBP.Lobby_AbnormalStatus_Popup_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\233\152\159\228\188\141\229\188\130\229\184\184\231\138\182\230\128\129"
    }
  },
  Lobby_MapDownloader_UIBP = {
    keyName = "Lobby_MapDownloader_UIBP",
    moduleName = "client.slua.umg.lobby.Main.Lobby_MapDownloader_UIBP",
    path = "/Game/Mod/Lobby/Split/WoW/Download/UGC_Download_Map_Style_Two_UIBP.UGC_Download_Map_Style_Two_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\233\152\159\228\188\141\229\188\130\229\184\184\231\138\182\230\128\129-\229\156\176\229\155\190\228\184\139\232\189\189"
    }
  },
  TeamPlatform_RecommendedTeam_Tips = {
    keyName = "TeamPlatform_RecommendedTeam_Tips",
    moduleName = "client.slua.umg.TeamPlatform.TeamPlatform_New.TeamPlatform_RecommendedTeam_Tips",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/TeamPlatform_RecommendedTeam_Tips.TeamPlatform_RecommendedTeam_Tips",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\231\187\132\233\152\159\229\185\179\229\143\176\229\188\149\229\175\188Tips"
    }
  },
  CardCollection_OfflineChest_Item = {
    keyName = "CardCollection_OfflineChest_Item",
    moduleName = "GameLua.Mod.Lobby.Split.CardCollection.umg.Item.CardCollection_OfflineChest_Item",
    path = "/Game/Mod/Lobby/Split/CardCollection/Item/CardCollection_OfflineChest_Item.CardCollection_OfflineChest_Item",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\231\166\187\231\186\191\229\174\157\231\174\177\228\187\187\229\138\161item\231\149\140\233\157\162"
    }
  },
  UCG_WoWPass_PassportFile_UIBP = {
    keyName = "UCG_WoWPass_PassportFile_UIBP",
    moduleName = "client.slua.umg.ugc.WoWPass.UCG_WoWPass_PassportFile_UIBP",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/UCG_WoWPass_PassportFile_UIBP.UCG_WoWPass_PassportFile_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "WOWPASS\230\161\163\230\161\136\233\161\181\233\157\162"
    }
  },
  UGC_LabelChange_Popup_UIBP = {
    keyName = "UGC_LabelChange_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_LabelChange_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_LabelChange_Popup_UIBP.UGC_LabelChange_Popup_UIBP",
    uiStat = {
      name = "\228\189\156\232\128\133\230\137\147\230\160\135-\232\135\170\229\138\168\229\140\150\230\160\135\231\173\190\230\155\180\230\148\185\230\143\144\231\164\186\229\188\185\231\170\151"
    }
  },
  Login_PromotionMatch_UIBP = {
    keyName = "Login_PromotionMatch_UIBP",
    moduleName = "client.slua.umg.LoginLoading.Login_PromotionMatch_UIBP",
    path = "/Game/UMG/UI_BP/LoginLoading/Login_PromotionMatch_UIBP.Login_PromotionMatch_UIBP",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155-loading\229\173\144Item"
    },
    closeOnSwitch = false,
    isMainUI = false
  },
  UGC_Lobby_Detail_UpdateLog_Popup_UIBP = {
    keyName = "UGC_Lobby_Detail_UpdateLog_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.UGC_Lobby_Detail_UpdateLog_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/WoW/Detail/UGC_Lobby_Detail_UpdateLog_Popup_UIBP.UGC_Lobby_Detail_UpdateLog_Popup_UIBP",
    containerName = UIContainers.Top,
    isSingleton = false,
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133-\230\155\180\230\150\176\230\151\165\229\191\151\229\188\185\230\161\134"
    }
  },
  UGC_Author_Comment_Skin_Item_UIBP = {
    keyName = "UGC_Author_Comment_Skin_Item_UIBP",
    moduleName = "client.slua.umg.ugc.item.Skin.UGC_Author_Comment_Skin_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Item/Skin/UGC_Author_Comment_Skin_Item_UIBP.UGC_Author_Comment_Skin_Item_UIBP",
    uiStat = {
      name = "WOW\232\175\132\232\174\186\231\154\174\232\130\164\233\162\132\232\167\136\231\187\132\228\187\182"
    },
    isSingleton = false,
    isMainUI = false
  },
  TeamQuick_NewSeason_UIBP = {
    keyName = "TeamQuick_NewSeason_UIBP",
    moduleName = "client.slua.umg.TeamQuick.TeamQuick_NewSeason_UIBP",
    path = "/Game/UMG/UI_BP/TeamQuick/TeamQuick_NewSeason_UIBP.TeamQuick_NewSeason_UIBP",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159\228\184\187\233\161\181\230\150\176\232\181\155\229\173\163\229\188\128\229\144\175\231\149\140\233\157\162"
    }
  },
  Lobby_UserResearch_UIBP = {
    keyName = "Lobby_UserResearch_UIBP",
    moduleName = "client.slua.umg.Lobby.UserResearch.Lobby_UserResearch_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/UserResearch/Lobby_UserResearch_UIBP.Lobby_UserResearch_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\231\148\168\231\160\148\233\151\174\229\141\183"
    }
  },
  SmartAssistantV2_Expression_Item_UIBP = {
    keyName = "SmartAssistantV2_Expression_Item_UIBP",
    moduleName = "client.slua.umg.SmartAssistantV2.Item.SmartAssistantV2_Expression_Item_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistantV2/Item/SmartAssistantV2_Expression_Item_UIBP.SmartAssistantV2_Expression_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139\232\129\138\229\164\169\232\161\168\230\131\133\230\176\148\230\179\161"
    }
  },
  Lobby_ChatRoom_Tip = {
    keyName = "Lobby_ChatRoom_Tip",
    moduleName = "client.slua.umg.LobbyChat.Lobby_ChatRoom_Tip",
    path = "/Game/UMG/UI_BP/LobbyChat/Lobby_ChatRoom_Tip.Lobby_ChatRoom_Tip",
    uiStat = {
      name = "\229\164\167\229\142\133-\232\129\138\229\164\169\229\133\165\229\143\163-\232\129\138\229\164\169\229\174\164\229\133\165\229\143\163"
    },
    isSingleton = false
  },
  Lobby_Mid_CrazyWeekend_Entry = {
    keyName = "Lobby_Mid_CrazyWeekend_Entry",
    moduleName = "client.slua.umg.lobby.Mid.Item.Lobby_Mid_CrazyWeekend_Entry",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Item/Lobby_Mid_CrazyWeekend_Entry.Lobby_Mid_CrazyWeekend_Entry",
    uiStat = {
      name = "\231\150\175\231\139\130\229\145\168\230\156\171-\229\164\167\229\142\133\229\133\165\229\143\163"
    },
    isMainUI = false,
    isSingleton = false
  },
  Lobby_MatchSettingAndStatus_UIBP = {
    keyName = "Lobby_MatchSettingAndStatus_UIBP",
    moduleName = "client.slua.umg.lobby.Main.Lobby_MatchSettingAndStatus_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_MatchSettingAndStatus_UIBP.Lobby_MatchSettingAndStatus_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\229\140\185\233\133\141\232\174\190\231\189\174\229\188\185\231\170\151"
    }
  },
  Guide_NewSeason_Popup = {
    keyName = "Guide_NewSeason_Popup",
    moduleName = "client.slua.umg.Universal_Popup.Guide_NewSeason_Popup",
    path = "/Game/UMG/UI_BP/Universal_Popup/Guide_NewSeason_Popup.Guide_NewSeason_Popup",
    uiStat = {
      name = "\231\187\147\231\174\151-\230\153\139\231\186\167\232\181\155\229\188\149\229\175\188\229\188\185\231\170\151"
    }
  },
  Theme_Entrance_Item = {
    keyName = "Theme_Entrance_Item",
    moduleName = "client.slua.umg.Theme_Entrance_Item",
    path = "/Game/Arts_UI/FromUMG/Theme/Theme_Entrance_Item.Theme_Entrance_Item",
    isMainUI = false,
    uiStat = {
      name = "\229\164\167\229\142\133-\231\129\171\229\189\177\228\184\187\233\162\152\229\133\165\229\143\163\230\142\167\228\187\182"
    }
  },
  Theme_Main_UIBP = {
    keyName = "Theme_Main_UIBP",
    moduleName = "client.slua.umg.Theme_Main_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Theme_Main_UIBP.Theme_Main_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\231\129\171\229\189\177\228\184\187\233\162\152\230\166\130\232\167\136\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  Theme_LimitTime_Item = {
    keyName = "Theme_LimitTime_Item",
    moduleName = "client.slua.umg.Theme_LimitTime_Item",
    path = "/Game/Arts_UI/FromUMG/Theme/Item/Theme_LimitTime_Item.Theme_LimitTime_Item",
    uiStat = {
      name = "\229\164\167\229\142\133-\231\129\171\229\189\177\228\184\187\233\162\152\230\166\130\232\167\136\231\149\140\233\157\162\230\180\187\229\138\168\232\146\153\231\137\136"
    },
    isMainUI = false,
    isSingleton = false
  },
  Lobby_Main_Bubble_Workshop = {
    keyName = "Lobby_Main_Bubble_Workshop",
    moduleName = "client.slua.umg.lobby.Main.Bubble.Lobby_Main_Bubble_Workshop",
    path = "/Game/UMG/UI_BP/Lobby/Main/Bubble/Lobby_Main_Bubble_Workshop.Lobby_Main_Bubble_Workshop",
    uiStat = {
      name = "\229\164\167\229\142\133-\229\183\165\229\157\138tab-bubble\231\149\140\233\157\162"
    },
    isMainUI = false,
    isSingleton = false
  },
  Lobby_Tab_Tip_NewbieGuide_Common = {
    keyName = "Lobby_Tab_Tip_NewbieGuide_Common",
    moduleName = "client.slua.umg.lobby.Main.Tips.Lobby_Tab_Tip_NewbieGuide_Common",
    path = "/Game/UMG/UI_BP/Lobby/Main/Tips/Lobby_Tab_Tip_NewbieGuide_Common.Lobby_Tab_Tip_NewbieGuide_Common",
    uiStat = {
      name = "\229\164\167\229\142\133-tab-tips\233\128\154\231\148\168\231\149\140\233\157\162"
    },
    isMainUI = false,
    isSingleton = false
  },
  Lobby_TeamPlatform_Entry = {
    keyName = "Lobby_TeamPlatform_Entry",
    moduleName = "client.slua.umg.lobby.Mid.Item.Lobby_TeamPlatform_Entry",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Item/Lobby_TeamPlatform_Entry.Lobby_TeamPlatform_Entry",
    uiStat = {
      name = "\229\164\167\229\142\133-\230\139\155\229\139\159\229\133\165\229\143\163-\231\149\140\233\157\162"
    },
    isMainUI = false,
    isSingleton = false
  },
  ResultsRanking_Promotion_Lookback_UIBP = {
    keyName = "ResultsRanking_Promotion_Lookback_UIBP",
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.Promotion.ResultsRanking_Promotion_Lookback_UIBP",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/S20/ResultsRanking_Promotion_Lookback_UIBP.ResultsRanking_Promotion_Lookback_UIBP",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155-\229\155\158\233\161\190\231\149\140\233\157\162"
    }
  },
  ResultsRanking_Promotion_Share_UIBP = {
    keyName = "ResultsRanking_Promotion_Share_UIBP",
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.Promotion.ResultsRanking_Promotion_Share_UIBP",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/S20/ResultsRanking_Promotion_Share_UIBP.ResultsRanking_Promotion_Share_UIBP",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155-\229\155\158\233\161\190\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  FlameShadow_Start_UIBP = {
    keyName = "FlameShadow_Start_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Main/Item/Entry/FlameShadow_Start_UIBP.FlameShadow_Start_UIBP",
    moduleName = "client.slua_ui_framework.base",
    uiStat = {
      name = "\229\164\167\229\142\133-\230\168\161\229\188\143\228\184\142\229\140\185\233\133\141-\231\129\171\229\189\177\228\184\187\233\162\152"
    },
    isMainUI = false,
    isSingleton = false
  },
  SmartAssistantV2_Popup_Medium_HaveTab_UIBP = {
    keyName = "SmartAssistantV2_Popup_Medium_HaveTab_UIBP",
    moduleName = "client.slua.umg.SmartAssistantV2.Popup.SmartAssistantV2_Popup_Medium_HaveTab_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistantV2/Popup/SmartAssistantV2_Popup_Medium_HaveTab_UIBP.SmartAssistantV2_Popup_Medium_HaveTab_UIBP",
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139-\233\155\134\233\148\166\229\188\185\231\170\151"
    }
  }
}
return lobby_ui_configs