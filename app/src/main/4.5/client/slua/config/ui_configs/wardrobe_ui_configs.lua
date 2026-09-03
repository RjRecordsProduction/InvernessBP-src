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
local wardrobe_ui_configs = {
  wardrobe_compose = {
    keyName = "wardrobe_compose",
    moduleName = "client.slua.umg.Wardrobe.compose",
    path = "/Game/UMG/UI_BP/Common/CommonUseGoods_UIBP.CommonUseGoods_UIBP",
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147-\229\144\136\230\136\144"
    }
  },
  wardrobe = {
    keyName = "wardrobe",
    moduleName = "client.slua.umg.Wardrobe.wardrobe_main",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Wardrobe_140_UIBP.Wardrobe_140_UIBP",
    jumpModuleID = BP_ENUM_MODULE_WARDROBE,
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147-\228\184\187\231\149\140\233\157\162"
    },
    useBatchOptimization = false
  },
  wardrobe_buy_item = {
    keyName = "wardrobe_buy_item",
    moduleName = "client.slua.umg.Wardrobe.Wardrobe_Buy_Item_14",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Wardrobe_Buy_Item_14.Wardrobe_Buy_Item_14",
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147-\232\180\173\228\185\176\233\129\147\229\133\183"
    }
  },
  fashion_bag_overview = {
    keyName = "fashion_bag_overview",
    moduleName = "client.slua.umg.Wardrobe.wardrobe_fashion_bag",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Ward_beibao_UIBP.Ward_beibao_UIBP",
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147-\230\151\182\232\163\133\232\131\140\229\140\133"
    }
  },
  fashion_bag_item_overview = {
    keyName = "fashion_bag_item_overview",
    moduleName = "client.slua.umg.Wardrobe.wardrobe_fashion_bag_item_overview",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Wardrobe_Decompose_qiangxie_UIBP.Wardrobe_Decompose_qiangxie_UIBP",
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147-\230\151\182\232\163\133\232\131\140\229\140\133-\229\183\178\232\163\133\229\164\135\231\154\132\230\158\170\230\162\176\229\146\140\232\189\189\229\133\183\229\188\185\231\170\151"
    }
  },
  Wardrobe_ShareBackpack_Popup_UIBP = {
    keyName = "Wardrobe_ShareBackpack_Popup_UIBP",
    moduleName = "client.slua.umg.Wardrobe.Popup.Wardrobe_ShareBackpack_Popup_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Popup/Wardrobe_ShareBackpack_Popup_UIBP.Wardrobe_ShareBackpack_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147-\230\151\182\232\163\133\232\131\140\229\140\133-\232\174\162\233\152\133\229\133\177\228\186\171\232\131\140\229\140\133\232\174\190\231\189\174\229\188\185\231\170\151"
    }
  },
  Wardrobe_Expression_Popup_UIBP = {
    keyName = "Wardrobe_Expression_Popup_UIBP",
    moduleName = "client.slua.umg.Wardrobe.Popup.Wardrobe_Expression_Popup_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Popup/Wardrobe_Expression_Popup_UIBP.Wardrobe_Expression_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147-\231\137\185\230\149\136\232\161\168\230\131\133\229\141\135\231\186\167\229\188\185\231\170\151"
    }
  },
  Wardrobe_Tag_NewGuide_Tips_05_UIBP = {
    keyName = "Wardrobe_Tag_NewGuide_Tips_05_UIBP",
    moduleName = "client.slua.umg.Wardrobe.WardrobeItem.Wardrobe_Tag_NewGuide_Tips_05_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/WardrobeItem/Wardrobe_Tag_NewGuide_Tips_05_UIBP.Wardrobe_Tag_NewGuide_Tips_05_UIBP",
    asy = true,
    uiStat = {
      name = "\230\141\162\232\137\178\229\188\149\229\175\188\231\149\140\233\157\162"
    }
  },
  Ward_beibao_Popup_UIBP = {
    keyName = "Ward_beibao_Popup_UIBP",
    moduleName = "client.slua.umg.Wardrobe.Popup.Ward_beibao_Popup_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Popup/Ward_beibao_Popup_UIBP.Ward_beibao_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147-\230\151\182\232\163\133\232\131\140\229\140\133-\229\164\141\229\136\182\229\133\177\228\186\171\232\131\140\229\140\133\229\188\185\231\170\151"
    }
  },
  displaysetting = {
    keyName = "displaysetting",
    moduleName = "client.slua.umg.Wardrobe.entry_icon_display_setting",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Displayset_UIBP.Displayset_UIBP",
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147-\230\152\190\231\164\186\232\174\190\231\189\174"
    }
  },
  ui_interactive_action = {
    keyName = "ui_interactive_action",
    moduleName = "client.slua.umg.Wardrobe.ui_interactive_action",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Show_Interactive_UIBP.Show_Interactive_UIBP",
    uiStat = {
      name = "\228\187\147\229\186\147-\228\186\164\228\186\146\229\138\168\228\189\156\228\191\161\230\129\175\231\149\140\233\157\162"
    }
  },
  EmoteUpgrade_Popup_UIBP = {
    keyName = "EmoteUpgrade_Popup_UIBP",
    moduleName = "client.slua.umg.Wardrobe.Popup.EmoteUpgrade_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PopupNotice/EmoteUpgrade_Popup_UIBP.EmoteUpgrade_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147-\231\137\185\230\149\136\232\161\168\230\131\133\229\141\135\231\186\167\229\188\185\231\170\151\239\188\136\232\161\168\230\131\133\229\133\165\229\143\163\239\188\137"
    }
  },
  item_tips_tiny_tips = {
    keyName = "item_tips_tiny_tips",
    moduleName = "client.slua.umg.Wardrobe.tips.item_tips_tiny_tips",
    path = "/Game/Mod/Lobby/Base/Wardrobe/TipsPanel_UIBP.TipsPanel_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147-item_tips_tiny_tips"
    }
  },
  ParticleEmoteUpgradePopup = {
    keyName = "ParticleEmoteUpgradePopup",
    moduleName = "client.slua.umg.Wardrobe.Popup.ParticleEmoteUpgradePopup",
    path = "/Game/UMG/UI_BP/Common/XSuit/XSuit_Upgrade_Popup_UIBP.XSuit_Upgrade_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\231\137\185\230\149\136\232\161\168\230\131\133\229\141\135\231\186\167\231\149\140\233\157\162"
    }
  },
  TopTipsPanel_UIBP = {
    keyName = "TopTipsPanel_UIBP",
    moduleName = "client.slua.umg.Wardrobe.TopTipsPanel_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/TopTipsPanel_UIBP.TopTipsPanel_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147-top\230\143\144\231\164\186\231\149\140\233\157\162"
    }
  },
  guest_find_password_post = {
    keyName = "guest_find_password_post",
    moduleName = "client.slua.umg.guest_bind.Guest_FindPassward_BP",
    path = "/Game/UMG/UI_BP/GuestBind/Guest_FindPassward_BP.Guest_FindPassward_BP",
    asy = true,
    uiStat = {
      name = "\230\184\184\229\174\162\232\180\166\229\143\183\230\137\190\229\155\158\232\175\183\230\177\130"
    }
  },
  item_tips_prop_tips = {
    keyName = "item_tips_prop_tips",
    moduleName = "client.slua.umg.Wardrobe.tips.item_tips_prop_tips",
    path = "/Game/Mod/Lobby/Base/Wardrobe/TipsPanel_UIBP_2.TipsPanel_UIBP_2",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147-item_tips_prop_tips"
    }
  },
  item_tips_suit_tips = {
    keyName = "item_tips_suit_tips",
    moduleName = "client.slua.umg.Wardrobe.tips.item_tips_suit_tips",
    path = "/Game/Mod/Lobby/Base/Wardrobe/TipsPanel_UIBP.TipsPanel_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147-item_tips_suit_tips"
    }
  },
  sub_tab_supercar_buttons = {
    keyName = "sub_tab_supercar_buttons",
    moduleName = "client.slua.umg.Wardrobe.sub_tab_supercar_buttons",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Wardrobe_CarButton_Item1.Wardrobe_CarButton_Item1",
    isMainUI = false
  },
  EmojiBubblePreview = {
    keyName = "EmojiBubblePreview",
    moduleName = "client.slua.umg.Wardrobe.EmojiBubblePreview",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\228\187\147\229\186\147-\232\161\168\230\131\133"
    }
  },
  arena_award_item = {
    keyName = "arena_award_item",
    moduleName = "client.slua.umg.arena.arena_award_item",
    path = "/Game/Mod/Lobby/Split/ModeSelection/Match/Match_Item/match_Evolutionary_1_item.match_Evolutionary_1_item",
    isSingleton = false,
    uiStat = {
      name = "\231\171\158\230\138\128\229\156\186-\228\184\187\231\149\140\233\157\162-\229\165\150\229\138\177Item"
    }
  },
  SharePackage_Edit_UIBP = {
    keyName = "SharePackage_Edit_UIBP",
    moduleName = "client.slua.umg.Wardrobe.SharePackage.SharePackage_Edit_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/SharePackage/SharePackage_Edit_UIBP.SharePackage_Edit_UIBP",
    jumpModuleID = BP_ENUM_MODULE_SUBSCRIBE_SHARE_USING,
    uiStat = {
      name = "\231\187\132\233\152\159-\232\174\162\233\152\133\229\133\177\228\186\171\232\131\140\229\140\133\228\189\191\231\148\168"
    }
  },
  pubgm_music_wardrobe = {
    keyName = "pubgm_music_wardrobe",
    moduleName = "client.slua.umg.pubgm_music.pubgm_music_wardrobe",
    path = "/Game/UMG/UI_BP/Music_Player/Music_Player_Give_away_UIBP.Music_Player_Give_away_UIBP",
    asy = true,
    uiStat = {
      name = "\233\159\179\228\185\144\231\155\146-\228\187\147\229\186\147"
    }
  },
  revise_name = {
    keyName = "revise_name",
    moduleName = "client.slua.umg.WarDrobe.revise_name",
    path = "/Game/UMG/UI_BP/RoleInfo/ReviseName_UIBP.ReviseName_UIBP",
    uiStat = {
      name = "\230\148\185\229\144\141\229\141\161\231\149\140\233\157\162"
    }
  },
  Wardrobe_New_DecomposePopups_Secondary_UIBP = {
    keyName = "Wardrobe_New_DecomposePopups_Secondary_UIBP",
    moduleName = "client.slua.umg.decompose.Wardrobe_New_DecomposePopups_Secondary_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Wardrobe_New_DecomposePopups_Secondary_UIBP.Wardrobe_New_DecomposePopups_Secondary_UIBP",
    uiStat = {
      name = "\228\187\147\229\186\147-\229\136\134\232\167\163\229\188\185\231\170\151\230\143\144\231\164\186"
    }
  },
  Wardrobe_New_DecomposePopups_UIBP = {
    keyName = "Wardrobe_New_DecomposePopups_UIBP",
    moduleName = "client.slua.umg.decompose.Wardrobe_New_DecomposePopups_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Wardrobe_New_DecomposePopups_UIBP.Wardrobe_New_DecomposePopups_UIBP",
    uiStat = {
      name = "\228\187\147\229\186\147-\229\136\134\232\167\163"
    }
  },
  Wardrobe_DecomposePopups_ChildPopups_UIBP = {
    keyName = "Wardrobe_DecomposePopups_ChildPopups_UIBP",
    moduleName = "client.slua.umg.decompose.Wardrobe_DecomposePopups_ChildPopups_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Popup/Wardrobe_DecomposePopups_ChildPopups_UIBP.Wardrobe_DecomposePopups_ChildPopups_UIBP",
    uiStat = {
      name = "\228\187\147\229\186\147-\229\136\134\232\167\163\232\180\167\229\184\129\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  Wardrobe_DecomposePopups_ChildPopups_Item_UIBP = {
    keyName = "Wardrobe_DecomposePopups_ChildPopups_Item_UIBP",
    moduleName = "client.slua.umg.decompose.Wardrobe_DecomposePopups_ChildPopups_Item_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Wardrobe_DecomposePopups_ChildPopups_Item_UIBP.Wardrobe_DecomposePopups_ChildPopups_Item_UIBP",
    uiStat = {
      name = "\228\187\147\229\186\147-\229\136\134\232\167\163\232\180\167\229\184\129\232\175\166\230\131\133\231\149\140\233\157\162item"
    }
  },
  forward_wonderful_replay_pop = {
    keyName = "forward_wonderful_replay_pop",
    moduleName = "client.slua.umg.replay.forward_wonderful_replay_pop",
    path = "/Game/UMG/UI_BP/WonderfulReplay/Popup/forwarding_Wonderfulvideo_UIBP.forwarding_Wonderfulvideo_UIBP",
    uiStat = {
      name = "\232\189\172\229\143\145\231\178\190\229\189\169\232\167\134\233\162\145\229\165\189\229\143\139\229\136\151\232\161\168\229\188\185\231\170\151"
    }
  },
  PlayGame_Award_Sub_UIBP = {
    keyName = "PlayGame_Award_Sub_UIBP",
    moduleName = "client.slua.umg.return_activity.PlayGame_Award_Sub_UIBP",
    isSingleton = false,
    path = "/Game/UMG/UI_BP/ReturnActivity/Return_Award_Sub_UIBP.Return_Award_Sub_UIBP",
    uiStat = {
      name = "200\229\155\158\230\181\129\230\180\187\229\138\168-\229\175\185\229\177\128\229\165\150\229\138\177\231\149\140\233\157\162"
    }
  },
  PlayGame_Award_Sub_UIBP_2 = {
    keyName = "PlayGame_Award_Sub_UIBP_2",
    moduleName = "client.slua.umg.ReturnActivity.Return_Award_Sub_UIBP_03",
    path = "/Game/UMG/UI_BP/ReturnActivity/Return_Award_Sub_UIBP_03.Return_Award_Sub_UIBP_03",
    uiStat = {
      name = "\229\155\158\230\181\129\231\137\185\230\157\131\231\149\140\233\157\162-\229\175\185\229\177\128\231\137\185\230\157\131"
    },
    isMainUI = false
  },
  Return_Award_Sub_UIBP_03 = {
    keyName = "Return_Award_Sub_UIBP_03",
    moduleName = "client.slua.umg.ReturnActivity.Return_Award_Sub_UIBP_03",
    path = "/Game/UMG/UI_BP/ReturnActivity/Return_Award_Sub_UIBP_03.Return_Award_Sub_UIBP_03",
    uiStat = {
      name = "\229\155\158\230\181\129\231\137\185\230\157\131\231\149\140\233\157\162-\230\174\181\228\189\141\231\155\174\230\160\135\229\165\150\229\138\177"
    },
    isMainUI = false
  },
  Subscribed_Award_Popup_UIBP = {
    keyName = "Subscribed_Award_Popup_UIBP",
    moduleName = "client.slua.umg.subscribe.Subscribed_Award_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/SubScribe/PopUp/Subscribed_Award_Popup_UIBP.Subscribed_Award_Popup_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\174\162\233\152\133-\230\175\143\230\151\165\229\165\150\229\138\177\233\162\134\229\143\150\231\149\140\233\157\162"
    }
  },
  Wardrobe_Popup_QuickMessage_UIBP = {
    keyName = "Wardrobe_Popup_QuickMessage_UIBP",
    moduleName = "client.slua.umg.Wardrobe.Popup.Wardrobe_Popup_QuickMessage_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Setting_Popup_QuickMessage_BP_UIBP.Setting_Popup_QuickMessage_BP_UIBP",
    uiStat = {
      name = "\228\187\147\229\186\147-\231\137\185\230\128\167\232\175\173\233\159\179-\230\155\180\229\164\154"
    }
  },
  Wardrobe_EditTag_Popup_UIBP = {
    keyName = "Wardrobe_EditTag_Popup_UIBP",
    moduleName = "client.slua.umg.Wardrobe.Popup.Wardrobe_EditTag_Popup_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Popup/Wardrobe_EditTag_Popup_UIBP.Wardrobe_EditTag_Popup_UIBP",
    uiStat = {
      name = "\228\187\147\229\186\147\230\160\135\231\173\190\231\188\150\232\190\145\229\188\185\231\170\151"
    }
  },
  Wardrobe_Sift_Suit_Popup_UIBP = {
    keyName = "Wardrobe_Sift_Suit_Popup_UIBP",
    moduleName = "client.slua.umg.Wardrobe.Popup.Wardrobe_Sift_Suit_Popup_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Popup/Wardrobe_Sift_Suit_Popup_UIBP.Wardrobe_Sift_Suit_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147\230\160\135\231\173\190\231\173\155\233\128\137\229\188\185\231\170\151"
    }
  },
  Wardrobe_Sift_Suit_Random_Match_Popup_UIBP = {
    keyName = "Wardrobe_Sift_Suit_Random_Match_Popup_UIBP",
    moduleName = "client.slua.umg.Wardrobe.Popup.Wardrobe_Sift_Suit_Random_Match_Popup_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Popup/Wardrobe_Sift_Suit_Popup_UIBP.Wardrobe_Sift_Suit_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147\230\160\135\231\173\190\231\173\155\233\128\137\229\188\185\231\170\151-\229\165\151\232\163\133\233\154\143\230\156\186\230\144\173\233\133\141"
    }
  },
  Wardrobe_TipsPanel_Favorites_UIBP = {
    keyName = "Wardrobe_TipsPanel_Favorites_UIBP",
    moduleName = "client.slua.umg.Wardrobe.WardrobeItem.Wardrobe_TipsPanel_Favorites_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/WardrobeItem/Wardrobe_TipsPanel_Favorites_UIBP.Wardrobe_TipsPanel_Favorites_UIBP",
    asy = true,
    uiStat = {
      name = "\228\187\147\229\186\147\230\160\135\231\173\190\232\174\190\231\189\174\233\128\137\229\188\185\231\170\151"
    }
  },
  Wardrobe_Tag_NewGuide_Tips_UIBP = {
    keyName = "Wardrobe_Tag_NewGuide_Tips_UIBP",
    moduleName = "client.slua.umg.Wardrobe.WardrobeItem.Wardrobe_Tag_NewGuide_Tips_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/WardrobeItem/Wardrobe_Tag_NewGuide_Tips_UIBP.Wardrobe_Tag_NewGuide_Tips_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "\231\137\169\229\147\129\228\191\161\230\129\175\233\157\162\230\157\191-\230\160\135\231\173\190tips\231\149\140\233\157\162"
    }
  },
  NewGuide_Tips_02_UIBP = {
    keyName = "NewGuide_Tips_02_UIBP",
    moduleName = "client.slua.umg.Wardrobe.WardrobeItem.NewGuide_Tips_02_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/WardrobeItem/NewGuide_Tips_02_UIBP.NewGuide_Tips_02_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\229\188\149\229\175\188Tips\230\160\135\231\173\190"
    }
  },
  Wardrobe_Placard_Item_UIBP = {
    keyName = "Wardrobe_Placard_Item_UIBP",
    moduleName = "client.slua.umg.Wardrobe.Wardrobe_Placard_Item_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Wardrobe_Placard_Item_UIBP.Wardrobe_Placard_Item_UIBP",
    uiStat = {
      name = "\228\184\190\231\137\140\232\174\190\231\189\174\231\149\140\233\157\162-item"
    }
  },
  Wardrobe_SprayPaint_UIBP1 = {
    keyName = "Wardrobe_SprayPaint_UIBP1",
    moduleName = "client.slua.umg.Wardrobe.Wardrobe_SprayPaint_UIBP1",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Wardrobe_SprayPaint_UIBP1.Wardrobe_SprayPaint_UIBP1",
    isMainUI = false,
    uiStat = {
      name = "\228\187\147\229\186\147\232\161\168\230\131\133/\229\150\183\230\188\134\232\189\174\231\155\152\232\174\190\231\189\174\231\149\140\233\157\162"
    }
  },
  Wardrobe_ChangeHead_Popup_UIBP = {
    keyName = "Wardrobe_ChangeHead_Popup_UIBP",
    moduleName = "client.slua.umg.Wardrobe.Popup.Wardrobe_ChangeHead_Popup_UIBP",
    path = "/Game/Mod/Lobby/Base/Wardrobe/Popup/Wardrobe_ChangeHead_Popup_UIBP.Wardrobe_ChangeHead_Popup_UIBP",
    uiStat = {
      name = "\233\135\145\232\163\133\230\141\162\229\164\180\230\177\160"
    }
  }
}
return wardrobe_ui_configs