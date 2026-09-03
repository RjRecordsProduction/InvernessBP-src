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
local ugc_ui_configs = {
  UGC_Download_Button_UIBP = {
    keyName = "UGC_Download_Button_UIBP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/UGC/UGC_Download_Button_UIBP.UGC_Download_Button_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.downloadui_pool
  },
  UGC_Download_Corner_UIBP = {
    keyName = "UGC_Download_Corner_UIBP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/UGC/UGC_Download_Corner_UIBP.UGC_Download_Corner_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.downloadui_pool
  },
  UGC_Download_TeamButton_UIBP = {
    keyName = "UGC_Download_TeamButton_UIBP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/UGC/UGC_Download_TeamButton_UIBP.UGC_Download_TeamButton_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.downloadui_pool
  },
  ModeSelection_UGC_Item_UIBP = {
    keyName = "ModeSelection_UGC_Item_UIBP",
    moduleName = "client.slua.umg.ugc.Commercialization.ModeSelection_UGC_Item_UIBP",
    path = "/Game/UMG/UI_BP/ModeSelection/Item/ModeSelection_UGC_List_UIBP.ModeSelection_UGC_List_UIBP",
    uiStat = {
      name = "\230\181\174\231\170\151\230\140\137\233\146\174tips"
    }
  },
  UGC_MineEverydayDataTips = {
    keyName = "UGC_MineEverydayDataTips",
    moduleName = "client.slua.umg.ugc.comment.UGC_Common_Msg_Box",
    path = "/Game/UMG/UI_BP/UGC/UGC_BlankMount_UIBP.UGC_BlankMount_UIBP",
    closeOnSwitch = false,
    containerName = UIContainers.Top,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "UGC-\230\136\145\231\154\132\228\184\187\233\161\181-\230\175\143\230\151\165\230\150\176\229\162\158\230\143\144\231\164\186\229\188\185\231\170\151"
    }
  },
  UGC_AutoTranslate_Popup_UIBP = {
    keyName = "UGC_AutoTranslate_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.comment.UGC_Common_Msg_Box",
    path = "/Game/UMG/UI_BP/UGC/UGC_BlankMount_UIBP.UGC_BlankMount_UIBP",
    closeOnSwitch = false,
    containerName = UIContainers.Top,
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "UGC-\232\135\170\229\138\168\231\191\187\232\175\145\229\188\185\231\170\151"
    }
  },
  UGC_ShareFriends_Popup_UIBP = {
    keyName = "UGC_ShareFriends_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGC_ShareFriends_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/ShareFriends_Popup_UIBP.ShareFriends_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "UGC\232\175\166\230\131\133\229\136\134\228\186\171\229\188\185\231\170\151"
    }
  },
  ui_complaint_ugc = {
    keyName = "ui_complaint_ugc",
    moduleName = "client.slua.umg.complaint.ui_complaint_ugc",
    path = "/Game/UMG/UI_BP/UGC/UGC_Inform_Item_UIBP2.UGC_Inform_Item_UIBP2",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-UGC"
    },
    isSingleton = false
  },
  ui_complaint_ugc_rank = {
    keyName = "ui_complaint_ugc_rank",
    moduleName = "client.slua.umg.complaint.ui_complaint_ugc_rank",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Chat_UIBP.Inform_Chat_UIBP",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-UGC\230\142\146\232\161\140\230\166\156"
    }
  },
  ui_complaint_ugc_recommend_video = {
    keyName = "ui_complaint_ugc_recommend_video",
    moduleName = "client.slua.umg.complaint.ui_complaint_ugc_recommend_video",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Chat_UIBP.Inform_Chat_UIBP",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-UGC\231\167\141\232\141\137\232\167\134\233\162\145"
    }
  },
  NewbieGuide_Mask_UIBP = {
    keyName = "NewbieGuide_Mask_UIBP",
    moduleName = "client.slua.umg.ugc.newbie.NewbieGuide_Mask_UIBP",
    path = "/Game/UMG/UI_BP/Newbie/NewbieGuide_Mask_UIBP.NewbieGuide_Mask_UIBP",
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\188\149\229\175\188mask \233\152\187\230\140\161\231\148\168\230\136\183\232\190\147\229\133\165"
    }
  },
  NewbieGuideBubbleUI = {
    keyName = "NewbieGuideBubbleUI",
    moduleName = "client.slua.umg.ugc.newbie.NewbieGuideBubbleUI",
    path = "/Game/UMG/UI_BP/Newbie/NewbieGuide_Bubble_UIBP.NewbieGuide_Bubble_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\188\149\229\175\188\230\176\148\230\179\161\230\143\144\231\164\186"
    },
    loadFromPool = EUIConfigPoolType.None,
    AndroidBackType = EAndroidBackType.Ban,
    asy = true
  },
  NewbieGuideCommonBubbleUI = {
    keyName = "NewbieGuideCommonBubbleUI",
    moduleName = "client.slua.umg.ugc.newbie.NewbieGuideCommonBubbleUI",
    path = "/Game/Mod/CreativeBase/UMG/NewbieGuide/NewbieGuide_Slider_Bubble_UIBP.NewbieGuide_Slider_Bubble_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\187\145\229\138\168\230\157\161\229\188\149\229\175\188\230\176\148\230\179\161\230\143\144\231\164\186"
    },
    loadFromPool = EUIConfigPoolType.None,
    AndroidBackType = EAndroidBackType.Ban,
    asy = true
  },
  MomentUGCReleaseMessage = {
    keyName = "MomentUGCReleaseMessage",
    moduleName = "client.slua.umg.moment.ui_moment_wowsquare_release_message",
    path = "/Game/UMG/UI_BP/Moment/Popup/Moment_Ugc_ReleaseMessage_UIBP.Moment_Ugc_ReleaseMessage_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\228\189\156\229\147\129\229\185\191\229\156\186\229\143\145\229\184\131\229\138\168\230\128\129\231\149\140\233\157\162"
    }
  },
  UGCMainTabUIBP = {
    keyName = "UGCMainTabUIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGCMainTab",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/New_UGC_Main_Tab_UIBP.New_UGC_Main_Tab_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {name = "WOW-\233\161\181\231\173\190"}
  },
  NewUGCMainPanel = {
    keyName = "NewUGCMainPanel",
    moduleName = "client.slua.umg.ugc.lobby.NewUGCMainPanel",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/New_UGC_Main_UIBP.New_UGC_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "UGC-\230\150\176\228\184\187\231\149\140\233\157\162"
    }
  },
  New_UGC_Main_Lobby_HotTheme_UIBP = {
    keyName = "New_UGC_Main_Lobby_HotTheme_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.hotTheme.New_UGC_Main_Lobby_HotTheme_UIBP",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/New_UGC_Main_Lobby_HotTheme_UIBP.New_UGC_Main_Lobby_HotTheme_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\230\150\176\231\137\136\229\164\167\229\142\133-\230\150\176\232\175\157\233\162\152\231\131\173\233\151\168\233\161\181"
    }
  },
  UGC_Main_Lobby_FineMod_UIBP = {
    keyName = "UGC_Main_Lobby_FineMod_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGCFineMod.UGC_Main_Lobby_FineMod_UIBP",
    path = "/Game/UMG/UI_BP/UGC/UGC_Main_Search_Sub_UIBP.UGC_Main_Search_Sub_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "UGC-\230\137\190\229\155\190\233\161\181\231\173\190"
    }
  },
  NewUGCCommonModItem = {
    keyName = "NewUGCCommonModItem",
    moduleName = "client.slua.umg.ugc.lobby.NewUGCCommonModItem",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/Item/New_UGC_Common_Mod_Item_UIBP.New_UGC_Common_Mod_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\230\150\176-\230\153\174\233\128\154MOD\231\188\169\231\149\165\229\155\190"
    }
  },
  New_UGC_TopMod_ThemeAuthor_UIBP = {
    keyName = "New_UGC_TopMod_ThemeAuthor_UIBP",
    moduleName = "client.slua.umg.ugc.HotTheme.UGC_TopMod_ThemeAuthor_UIBP",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/Item/New_UGC_TopMod_ThemeAuthor_UIBP.New_UGC_TopMod_ThemeAuthor_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\230\150\176-UGC-banner-match\229\146\140author\229\134\133\229\174\185"
    }
  },
  New_UGC_TopMod_HotBanner_MultiPage_Item_UIBP = {
    keyName = "New_UGC_TopMod_HotBanner_MultiPage_Item_UIBP",
    moduleName = "client.slua.umg.ugc.HotTheme.UGC_TopMod_HotBanner_MultiPage_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/Item/New_UGC_TopMod_HotCompilation_UIBP.New_UGC_TopMod_HotCompilation_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\230\150\176-UGC-banner \228\189\156\229\147\129\229\146\140\229\144\136\233\155\134"
    }
  },
  UGC_NewSearchFilter_UIBP = {
    keyName = "UGC_NewSearchFilter_UIBP",
    moduleName = "client.slua.umg.ugc.item.UGC_NewSearchFilter_UIBP",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/New_UGC_Lobby_SubTag_UIBP.New_UGC_Lobby_SubTag_UIBP",
    asy = true,
    uiStat = {
      name = "\230\150\176-UGC-\231\173\155\233\128\137\229\153\168"
    }
  },
  UGC_TopMod_SeasonTheme_UIBP = {
    keyName = "UGC_TopMod_SeasonTheme_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGCSeason.UGC_TopMod_SeasonTheme_UIBP",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/Item/New_UGC_TopMod_ThemeAuthor_UIBP.New_UGC_TopMod_ThemeAuthor_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\230\150\176-UGC-banner-\229\136\155\230\184\184\229\173\163\229\133\165\229\155\180\228\189\156\229\147\129"
    }
  },
  UGC_AuthorRecommended_DetailsPage_UIBP = {
    keyName = "UGC_AuthorRecommended_DetailsPage_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGC_AuthorRecommended_DetailsPage_UIBP",
    path = "/Game/UMG/UI_BP/UGC/HotTheme/UGC_AuthorRecommended_DetailsPage_UIBP.UGC_AuthorRecommended_DetailsPage_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "UGC-\229\133\168\233\131\168\230\142\168\232\141\144\229\146\140\228\189\156\232\128\133\230\142\168\232\141\144\232\175\166\230\131\133"
    }
  },
  UGC_AllAuthorRecommended_DetailsPage_UIBP = {
    keyName = "UGC_AllAuthorRecommended_DetailsPage_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.HotAuthor.UGC_AllAuthorRecommended_DetailsPage_UIBP",
    path = "/Game/UMG/UI_BP/UGC/HotTheme/UGC_AllAuthorRecommended_DetailsPage_UIBP.UGC_AllAuthorRecommended_DetailsPage_UIBP",
    uiStat = {
      name = "UGC-\228\189\156\232\128\133\230\142\168\232\141\144"
    }
  },
  UGC_FirstBecomeCreator_Guide = {
    keyName = "UGC_FirstBecomeCreator_Guide",
    moduleName = "client.slua.umg.ugc.creator.UGC_FirstBecomeCreator_Guide",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Explain_UIBP.Common_Popup_Theme_Explain_UIBP",
    containerName = UIContainers.Top,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\233\166\150\230\172\161\230\136\144\228\184\186\229\136\155\228\189\156\232\128\133\229\188\149\229\175\188\229\188\185\231\170\151"
    }
  },
  UGC_Author_Levelup_Popup_UIBP = {
    keyName = "UGC_Author_Levelup_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.creator.UGC_Author_Levelup_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Levelup_Popup_UIBP.UGC_Levelup_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\136\155\228\189\156\232\128\133\231\173\137\231\186\167\230\143\144\229\141\135\229\188\185\231\170\151"
    }
  },
  UGC_Author_Levelup_Share_UIBP = {
    keyName = "UGC_Author_Levelup_Share_UIBP",
    moduleName = "client.slua.umg.ugc.creator.UGC_Author_Levelup_Share_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Levelup_Popup_UIBP_2.UGC_Levelup_Popup_UIBP_2",
    uiStat = {
      name = "\229\136\155\228\189\156\232\128\133\231\173\137\231\186\167\230\143\144\229\141\135\229\188\185\231\170\151-\229\136\134\228\186\171"
    }
  },
  UGC_Author_Levelup_Popup_UIBP2 = {
    keyName = "UGC_Author_Levelup_Popup_UIBP2",
    moduleName = "client.slua.umg.ugc.creator.UGC_Author_Levelup_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Levelup_Popup_UIBP_2.UGC_Levelup_Popup_UIBP_2",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\136\155\228\189\156\232\128\133\231\173\137\231\186\167\230\143\144\229\141\135\229\188\185\231\170\1512"
    }
  },
  UGC_Main_Lobby_NewMap_UIBP = {
    keyName = "UGC_Main_Lobby_NewMap_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGCNewMap.UGC_Main_Lobby_NewMap_UIBP",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/New_UGC_Main_Lobby_NewMap_UIBP.New_UGC_Main_Lobby_NewMap_UIBP",
    isMainUI = false,
    uiStat = {
      name = "UGC-\230\150\176\231\137\136\229\164\167\229\142\133-\230\150\176\229\155\190\233\161\181\231\173\190"
    }
  },
  UGC_TopMod_NewMap_Banner_MultiPage_UIBP = {
    keyName = "UGC_TopMod_NewMap_Banner_MultiPage_UIBP",
    moduleName = "client.slua.umg.ugc.NewMap.UGC_TopMod_NewMap_Banner_MultiPage_UIBP",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/Item/New_UGC_TopMod_HotCompilation_UIBP.New_UGC_TopMod_HotCompilation_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\230\150\176\229\155\190-UGC-banner \228\189\156\229\147\129\229\146\140\229\144\136\233\155\134"
    }
  },
  UGC_NewMapMod_Author_UIBP = {
    keyName = "UGC_NewMapMod_Author_UIBP",
    moduleName = "client.slua.umg.ugc.NewMap.UGC_NewMapMod_Author_UIBP",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/Item/New_UGC_TopMod_ThemeAuthor_UIBP.New_UGC_TopMod_ThemeAuthor_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\230\150\176-UGC-banner-match\229\146\140author\229\134\133\229\174\185-\230\150\176\229\155\190\233\161\181\231\173\190"
    }
  },
  UGC_CompetitionFinalist_DetailsPage_UIBP = {
    keyName = "UGC_CompetitionFinalist_DetailsPage_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGCSeason.UGC_CompetitionFinalist_DetailsPage_UIBP",
    path = "/Game/UMG/UI_BP/UGC/HotTheme/UGC_CompetitionFinalist_DetailsPage_UIBP.UGC_CompetitionFinalist_DetailsPage_UIBP",
    uiStat = {
      name = "UGC-\229\133\172\231\164\186\230\156\159\228\189\156\229\147\129\229\177\149\231\164\186-\232\181\155\228\186\139\233\161\181\231\173\190"
    }
  },
  Newbie_NoviceProcessGuidance_UIBP = {
    keyName = "Newbie_NoviceProcessGuidance_UIBP",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Newbie_NoviceProcessGuidance_UIBP",
    path = "/Game/UMG/UI_BP/UGC/UGC_NoviceProcessGuidance_UIBP.UGC_NoviceProcessGuidance_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\229\188\149\229\175\188-\230\168\161\229\188\143\233\128\137\230\139\169"
    }
  },
  Newbie_WoWTips_UIBP = {
    keyName = "Newbie_WoWTips_UIBP",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Newbie_WoWTips_UIBP",
    path = "/Game/UMG/UI_BP/UGC/UGC_NewbieGuide_UIBP.UGC_NewbieGuide_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\229\188\149\229\175\188-WoWTip"
    },
    isMainUI = true,
    containerName = UIContainers.Top,
    isSingleton = true,
    AndroidBackType = EAndroidBackType.Ban
  },
  UGCEdit_Loading_Attach_UIBP = {
    keyName = "UGCEdit_Loading_Attach_UIBP",
    moduleName = "client.slua.umg.LoginLoading.UGCEdit_Loading_Attach_UIBP",
    path = "/Game/UMG/UI_BP/LoginLoading/UGCEdit_Loading_Attach_UIBP.UGCEdit_Loading_Attach_UIBP",
    uiStat = {
      name = "UGC\231\188\150\232\190\145-loading\226\128\148\230\140\130\232\189\189"
    },
    isMainUI = false,
    closeOnSwitch = false,
    loadFromPool = EUIConfigPoolType.None
  },
  UGCMulti_Loading_Attach_UIBP = {
    keyName = "UGCMulti_Loading_Attach_UIBP",
    moduleName = "client.slua.umg.LoginLoading.UGCMulti_Loading_Attach_UIBP",
    path = "/Game/UMG/UI_BP/LoginLoading/UGCMulti_Loading_Attach_UIBP.UGCMulti_Loading_Attach_UIBP",
    uiStat = {
      name = "UGC\231\188\150\232\190\145-loading\226\128\148\230\140\130\232\189\189"
    },
    isMainUI = false,
    closeOnSwitch = false,
    loadFromPool = EUIConfigPoolType.None
  },
  UGCMainPanel = {
    keyName = "UGCMainPanel",
    moduleName = "client.slua.umg.ugc.lobby.UGCMainPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Main_UIBP.UGC_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "UGC-\228\184\187\231\149\140\233\157\162"
    }
  },
  ugc_mine_main = {
    keyName = "ugc_mine_main",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcMineMainPanel",
    jumpModuleID = BP_ENUM_MODULE_UGC_MINE,
    path = "/Game/UMG/UI_BP/UGC/UGC_Mine_MainPanel_UIBP.UGC_Mine_MainPanel_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\230\136\145\231\154\132\228\189\156\229\147\129\228\184\187\233\161\181"
    }
  },
  UGC_Mine_WorksPanel_Item_UIBP = {
    keyName = "UGC_Mine_WorksPanel_Item_UIBP",
    moduleName = "client.slua.umg.ugc.creator.personal.UGC_Mine_WorksPanel_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Item/UGC_Mine_WorksPanel_Item_UIBP.UGC_Mine_WorksPanel_Item_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-\230\136\145\231\154\132\228\189\156\229\147\129\228\184\187\233\161\181-left"
    }
  },
  UGC_Mine_MessagePanel = {
    keyName = "UGC_Mine_MessagePanel",
    moduleName = "client.slua.umg.ugc.creator.personal.UGC_Mine_MessagePanel",
    path = "/Game/UMG/UI_BP/Mail/Sub_UIBP/Mail_List_Right_UIBP.Mail_List_Right_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-\230\136\145\231\154\132\228\189\156\229\147\129\228\184\187\233\161\181-\230\182\136\230\129\175"
    }
  },
  UGC_HotRank_DetailMainPanel = {
    keyName = "UGC_HotRank_DetailMainPanel",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGC_HotRank_DetailMainPanel",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/New_UGC_LeaderboardList_UIBP.New_UGC_LeaderboardList_UIBP",
    uiStat = {
      name = "UGC\231\131\173\231\142\169\230\142\146\232\161\140\230\166\156\232\175\166\230\131\133"
    }
  },
  UGC_HotRank_DetailRoot = {
    keyName = "UGC_HotRank_DetailRoot",
    moduleName = "client.slua.umg.ugc.lobby.HotRank.UGC_HotRank_DetailRoot",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/New_UGC_LeaderboardList_Sub_UIBP.New_UGC_LeaderboardList_Sub_UIBP",
    isMainUI = false,
    uiStat = {
      name = "UGC\231\131\173\231\142\169\230\142\146\232\161\140\230\166\156\232\175\166\230\131\133\230\149\176\230\141\174\233\161\181"
    }
  },
  UGC_Center_Main = {
    keyName = "UGC_Center_Main",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Main",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_Main_UIBP.UGC_Center_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UGC_CENTER,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131"
    }
  },
  UGC_Center_Level = {
    keyName = "UGC_Center_Level",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Level",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_Level_UIBP.UGC_Center_Level_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\231\173\137\231\186\167"
    }
  },
  UGC_Center_CrystalIncentive = {
    keyName = "UGC_Center_CrystalIncentive",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_CrystalIncentive",
    path = "/Game/UMG/UI_BP/UGC/CrystalStimulate/UGC_CrystalStimulate_IncentivePlan_UIBP.UGC_CrystalStimulate_IncentivePlan_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\231\187\147\230\153\182\230\191\128\229\138\177"
    }
  },
  UGC_Center_Video = {
    keyName = "UGC_Center_Video",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Video",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_Tab_UIBP.UGC_Center_Tab_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\230\149\153\229\173\166\232\167\134\233\162\145\233\161\181\231\173\190"
    }
  },
  UGC_Center_Video_Page = {
    keyName = "UGC_Center_Video_Page",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Video_Page",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_Video_UIBP.UGC_Center_Video_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\230\149\153\229\173\166\232\167\134\233\162\145"
    }
  },
  UGC_Center_Video_Award = {
    keyName = "UGC_Center_Video_Award",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Video_Award",
    path = "/Game/UMG/UI_BP/UGC/Center/Popup/UGC_Center_Award_Popup_UIBP.UGC_Center_Award_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\230\149\153\229\173\166\232\167\134\233\162\145\229\165\150\229\138\177\233\162\132\232\167\136"
    }
  },
  UGC_Center_Challenge = {
    keyName = "UGC_Center_Challenge",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Challenge",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_Tab_UIBP.UGC_Center_Tab_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\229\173\181\229\140\150\232\144\165"
    }
  },
  UGC_Center_Challenge_Page = {
    keyName = "UGC_Center_Challenge_Page",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Challenge_Page",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_IncubationArea_Card_UIBP.UGC_IncubationArea_Card_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\229\173\181\229\140\150\232\144\165\239\188\136\230\153\174\233\128\154\239\188\137"
    }
  },
  UGC_Center_Home = {
    keyName = "UGC_Center_Home",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Home",
    path = "/Game/UMG/UI_BP/UGC/Commercialization/UGC_Lobby_Commercialization_Home_UIBP.UGC_Lobby_Commercialization_Home_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\233\166\150\233\161\181"
    }
  },
  UGC_Center_Home_MatchList_Item = {
    keyName = "UGC_Center_Home_MatchList_Item",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Home_MatchList_Item",
    path = "/Game/UMG/UI_BP/UGC/Commercialization/Item/UGC_Commercialization_CreationCompetition_Item_UIBP.UGC_Commercialization_CreationCompetition_Item_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\233\166\150\233\161\181-\232\181\155\228\186\139Item"
    }
  },
  UGC_Center_Store = {
    keyName = "UGC_Center_Store",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Store",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_Store_UIBP.UGC_Center_Store_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\231\173\137\231\186\167"
    }
  },
  UGC_Center_Event = {
    keyName = "UGC_Center_Event",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Event",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_Event_UIBP.UGC_Center_Event_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\230\180\187\229\138\168\233\161\181\231\173\190"
    }
  },
  UGCCenterData_Overview = {
    keyName = "UGCCenterData_Overview",
    moduleName = "client.slua.umg.ugc.creator.center.UGCCenterData_Overview",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_DataGeneralView_UIBP.UGC_Center_DataGeneralView_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\230\149\176\230\141\174\228\184\173\229\191\131-\230\128\187\232\167\136"
    }
  },
  UGCCenterData_Mod = {
    keyName = "UGCCenterData_Mod",
    moduleName = "client.slua.umg.ugc.creator.center.UGCCenterData_Mod",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_Works_UIBP.UGC_Center_Works_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\230\149\176\230\141\174\228\184\173\229\191\131-\228\189\156\229\147\129"
    }
  },
  UGCCenterData_Fans = {
    keyName = "UGCCenterData_Fans",
    moduleName = "client.slua.umg.ugc.creator.center.UGCCenterData_Fans",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_FanData_UIBP.UGC_Center_FanData_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\230\149\176\230\141\174\228\184\173\229\191\131-\231\178\137\228\184\157"
    }
  },
  UGCCenterData_ModPopup = {
    keyName = "UGCCenterData_ModPopup",
    moduleName = "client.slua.umg.ugc.creator.center.UGCCenterData_ModPopup",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_SwitchMap_UIBP.UGC_Center_SwitchMap_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\230\149\176\230\141\174\228\184\173\229\191\131-\228\189\156\229\147\129- \229\136\135\230\141\162\228\189\156\229\147\129\233\161\181"
    }
  },
  UGC_Center_Event_Page = {
    keyName = "UGC_Center_Event_Page",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Event_Page",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_Event_Page_UIBP.UGC_Center_Event_Page_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\230\180\187\229\138\168\229\177\149\231\164\186"
    }
  },
  UGC_Center_Mission = {
    keyName = "UGC_Center_Mission",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Mission",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_Tab_UIBP.UGC_Center_Tab_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\228\187\187\229\138\161\228\184\173\229\191\131\233\161\181\231\173\190"
    }
  },
  UGC_Center_Mission_Page = {
    keyName = "UGC_Center_Mission_Page",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Mission_Page",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_Task_UIBP.UGC_Center_Task_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\228\187\187\229\138\161\228\184\173\229\191\131\229\134\133\229\174\185\239\188\136\230\153\174\233\128\154\239\188\137"
    }
  },
  UGC_Center_Mission_DailyPage = {
    keyName = "UGC_Center_Mission_DailyPage",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Mission_DailyPage",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_Task_UIBP.UGC_Center_Task_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\228\187\187\229\138\161\228\184\173\229\191\131\229\134\133\229\174\185\239\188\136\230\151\165\229\184\184\239\188\137"
    }
  },
  UGC_Center_Mission_Detail = {
    keyName = "UGC_Center_Mission_Detail",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Mission_Detail",
    path = "/Game/UMG/UI_BP/UGC/Center/Popup/UGC_Center_Task_Popup_UIBP.UGC_Center_Task_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\228\187\187\229\138\161\232\175\166\230\131\133"
    }
  },
  UGC_EquityInstructions_Popup_UIBP = {
    keyName = "UGC_EquityInstructions_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.creator.personal.UGC_EquityInstructions_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_EquityInstructions_Popup_UIBP.UGC_EquityInstructions_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131\232\167\132\229\136\153\230\143\144\231\164\186"
    }
  },
  UGC_Player_PlayData_UIBP = {
    keyName = "UGC_Player_PlayData_UIBP",
    moduleName = "client.slua.umg.ugc.UGC_Player_PlayData_UIBP",
    path = "/Game/UMG/UI_BP/UGC/UGC_Player_PlayData_UIBP.UGC_Player_PlayData_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\228\184\170\228\186\186\230\184\184\231\142\169\230\149\176\230\141\174"
    }
  },
  UGC_AuthorBehavior_CreativeCenter_UIBP = {
    keyName = "UGC_AuthorBehavior_CreativeCenter_UIBP",
    moduleName = "client.slua.umg.ugc.UGC_AuthorBehavior_CreativeCenter_UIBP",
    path = "/Game/UMG/UI_BP/UGC/UGC_AuthorBehavior_CreativeCenter_UIBP.UGC_AuthorBehavior_CreativeCenter_UIBP",
    isMainUI = false,
    uiStat = {
      name = "UGC-\228\184\170\228\186\186\229\136\155\228\189\156\230\149\176\230\141\174--\229\174\162\230\128\129"
    }
  },
  UGC_AuthorMasterstate_CreativeCenter_UIBP = {
    keyName = "UGC_AuthorMasterstate_CreativeCenter_UIBP",
    moduleName = "client.slua.umg.ugc.UGC_AuthorMasterstate_CreativeCenter_UIBP",
    path = "/Game/UMG/UI_BP/UGC/UGC_AuthorMasterstate_CreativeCenter_UIBP.UGC_AuthorMasterstate_CreativeCenter_UIBP",
    isMainUI = false,
    uiStat = {
      name = "UGC-\228\184\170\228\186\186\229\136\155\228\189\156\230\149\176\230\141\174--\228\184\187\230\128\129"
    }
  },
  UGC_PlayMap_Popup_UIBP = {
    keyName = "UGC_PlayMap_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_PlayMap_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_PlayMap_Popup_UIBP.UGC_PlayMap_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "UGC-\228\184\170\228\186\186\229\136\155\228\189\156\230\149\176\230\141\174--\232\174\190\231\189\174\231\189\174\233\161\182\230\149\176\230\141\174\231\154\132\229\188\185\231\170\151"
    }
  },
  UGC_FollowAuthor_Popup_UIBP = {
    keyName = "UGC_FollowAuthor_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_FollowAuthor_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_FollowAuthor_Popup_UIBP.UGC_FollowAuthor_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "UGC-\228\184\170\228\186\186\230\184\184\231\142\169\230\149\176\230\141\174--\229\133\179\230\179\168\228\189\156\232\128\133\231\154\132\229\188\185\231\170\151"
    }
  },
  ugc_mine_works = {
    keyName = "ugc_mine_works",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcMineWorksPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Mine_WorksPanel_UIBP.UGC_Mine_WorksPanel_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\230\136\145\231\154\132\228\189\156\229\147\129"
    }
  },
  ugc_mine_edit_noromal_work = {
    keyName = "ugc_mine_edit_noromal_work",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcMineEditNormalWorkPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Mine_EditNormalWork_UIBP.UGC_Mine_EditNormalWork_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    asy = true,
    uiStat = {
      name = "UGC-\231\188\150\232\190\145\233\161\181-MOD\231\188\150\232\190\145"
    }
  },
  ugc_input_check_popup = {
    keyName = "ugc_input_check_popup",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcInputCheckPanel",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_EditNormalWork_Variable_Popup_UIBP.UGC_EditNormalWork_Variable_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\231\188\150\232\190\145\233\161\181-MOD\230\155\180\230\150\176-\232\190\147\229\133\165\230\150\135\229\173\151\231\161\174\232\174\164\229\188\185\231\170\151"
    }
  },
  ugc_mine_edit_public_work = {
    keyName = "ugc_mine_edit_public_work",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcMineEditPublicWorkPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Mine_EditPublicWork_UIBP.UGC_Mine_EditPublicWork_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\231\188\150\232\190\145\233\161\181-\229\143\145\229\184\131MOD\231\188\150\232\190\145"
    }
  },
  ugc_mine_photo = {
    keyName = "ugc_mine_photo",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcMinePhotoPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Mine_PhotoPanel_UIBP.UGC_Mine_PhotoPanel_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {name = "UGC-\231\155\184\229\134\140"}
  },
  ugc_mine_photo_new = {
    keyName = "ugc_mine_photo_new",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcMinePhotoPanelNew",
    path = "/Game/UMG/UI_BP/UGC/CustomPhoto/UGC_Photo_New_Main_UIBP.UGC_Photo_New_Main_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-\230\150\176\231\137\136\231\155\184\229\134\140"
    }
  },
  ugc_mine_photo_album_detail = {
    keyName = "ugc_mine_photo_album_detail",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcMinePhotoAlbumDetails",
    path = "/Game/UMG/UI_BP/UGC/CustomPhoto/UGC_Album_Details_UIBP.UGC_Album_Details_UIBP",
    asy = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "UGC-\231\155\184\229\134\140\232\175\166\230\131\133"
    }
  },
  ugc_mine_photo_album_detail_select = {
    keyName = "ugc_mine_photo_album_detail_select",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcMinePhotoAlbumDetailsSelect",
    path = "/Game/UMG/UI_BP/UGC/CustomPhoto/UGC_Album_Details_UIBP.UGC_Album_Details_UIBP",
    asy = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "UGC-\231\155\184\229\134\140\233\128\137\230\139\169"
    }
  },
  ugc_mine_photo_import_from_prefab_shop = {
    keyName = "ugc_mine_photo_import_from_prefab_shop",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcMinePhotoImportFromPrefabShop",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/UGC_PrivateRepository_ViewPageNew_UIBP.UGC_PrivateRepository_ViewPageNew_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\231\155\184\229\134\140\228\187\142\232\181\132\230\186\144\228\184\173\229\191\131\229\175\188\229\133\165"
    }
  },
  ugc_select_photo_main = {
    keyName = "ugc_select_photo_main",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcSelectPhotoPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Select_Photo_MainPanel_UIBP.UGC_Select_Photo_MainPanel_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\231\155\184\229\134\140\233\128\137\230\139\169\231\149\140\233\157\162"
    }
  },
  ugc_mine_photo_detail = {
    keyName = "ugc_mine_photo_detail",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcMinePhotoDetailPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Mine_PhotoDetail_UIBP.UGC_Mine_PhotoDetail_UIBP",
    asy = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "UGC-\231\155\184\229\134\140\231\133\167\231\137\135\232\175\166\230\131\133"
    }
  },
  ugc_mine_photo_picture_item = {
    keyName = "ugc_mine_photo_picture_item",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcMinePhotoPicutreItem",
    path = "/Game/UMG/UI_BP/UGC/Item/UGC_Mine_Picture_Item_UIBP.UGC_Mine_Picture_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\231\155\184\229\134\140\231\133\167\231\137\135-\231\133\167\231\137\135Item"
    }
  },
  UgcCustomPhotoAlbumPanel = {
    keyName = "UgcCustomPhotoAlbumPanel",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcCustomPhotoAlbumPanel",
    path = "/Game/UMG/UI_BP/UGC/CustomPhoto/UGC_Mine_CustomPhoto_Album_UIBP.UGC_Mine_CustomPhoto_Album_UIBP",
    uiStat = {
      name = "UGC-\231\155\184\229\134\140\231\133\167\231\137\135-\230\156\172\229\156\176\228\184\138\228\188\160"
    }
  },
  UgcCustomPhotoEditPanel = {
    keyName = "UgcCustomPhotoEditPanel",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcCustomPhotoEditPanel",
    path = "/Game/UMG/UI_BP/UGC/CustomPhoto/UGC_Mine_CustomPhoto_Edit_UIBP.UGC_Mine_CustomPhoto_Edit_UIBP",
    uiStat = {
      name = "UGC-\231\155\184\229\134\140\231\133\167\231\137\135-\231\188\150\232\190\145\231\133\167\231\137\135"
    }
  },
  UgcCustomPhotoNoticeMsgBox = {
    keyName = "UgcCustomPhotoNoticeMsgBox",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcCustomPhotoNoticeMsgBox",
    path = "/Game/UMG/UI_BP/UGC/CustomPhoto/popup/UGC_Mine_UploadPhoto_Popup_UIBP.UGC_Mine_UploadPhoto_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\231\155\184\229\134\140\231\133\167\231\137\135-\228\184\138\228\188\160\229\188\185\231\170\151\230\143\144\233\134\146"
    }
  },
  UgcCustomPhotoNoticeMsgBoxDetail = {
    keyName = "UgcCustomPhotoNoticeMsgBoxDetail",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcCustomPhotoNoticeMsgBoxDetail",
    path = "/Game/UMG/UI_BP/UGC/CustomPhoto/popup/UGC_Mine_SafetyRules_Popup_UIBP.UGC_Mine_SafetyRules_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\231\155\184\229\134\140\231\133\167\231\137\135-\228\184\138\228\188\160\229\188\185\231\170\151\232\175\166\230\131\133"
    }
  },
  ugc_edit_review_detail = {
    keyName = "ugc_edit_review_detail",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcMineEditReviewWorkPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Mine_EditReviewWork_UIBP.UGC_Mine_EditReviewWork_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\231\188\150\232\190\145\233\161\181-\229\143\145\229\184\131MOD\231\188\150\232\190\145"
    }
  },
  ugc_mine_edit_reason_detail = {
    keyName = "ugc_mine_edit_reason_detail",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcMineEditReasonDetailPanel",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Mine_ReasonDetail_Panel_Popup_UIBP.UGC_Mine_ReasonDetail_Panel_Popup_UIBP",
    uiStat = {name = "UGC-\229\174\161\230\160\184"}
  },
  ugc_guest_work_panel = {
    keyName = "ugc_guest_work_panel",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcGuestWorksPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Guest_WorksPanel_UIBP.UGC_Guest_WorksPanel_UIBP",
    asy = true,
    jumpModuleID = BP_ENUM_MODULE_UGC_GUEST,
    uiStat = {
      name = "UGC-\229\133\182\228\187\150\231\142\169\229\174\182\228\189\156\229\147\129\228\184\187\233\161\181"
    }
  },
  ugc_create_main = {
    keyName = "ugc_create_main_new",
    moduleName = "client.slua.umg.ugc.creator.works.UgcCreateMainPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_CreateMain_UIBP.UGC_CreateMain_UIBP",
    asy = true,
    jumpModuleID = BP_ENUM_MODULE_UGC_CREATE_MAIN,
    uiStat = {
      name = "UGC-\229\136\155\229\187\186-\228\184\187\231\149\140\233\157\162 - new"
    }
  },
  ugc_create_mod = {
    keyName = "ugc_create_mod_new",
    moduleName = "client.slua.umg.ugc.creator.works.UgcCreateModPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_CreateMod_UIBP_2.UGC_CreateMod_UIBP_2",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-\229\136\155\229\187\186-MOD\229\136\155\229\187\186 - NEW"
    }
  },
  ugc_duplicate_mod = {
    keyName = "ugc_duplicate_mod",
    moduleName = "client.slua.umg.ugc.creator.works.UgcDuplicateModPanel",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_DuplicateMod_Confirm_Popup_UIBP.UGC_DuplicateMod_Confirm_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\231\188\150\232\190\145\233\161\181-MOD\229\164\141\229\136\182"
    }
  },
  UGCRecommendPanel = {
    keyName = "UGCRecommendPanel",
    moduleName = "client.slua.umg.ugc.lobby.recommend.UGCRecommendPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_Recommend_UIBP.UGC_Lobby_Recommend_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\230\142\168\232\141\144\233\161\181"
    }
  },
  UGC_MapSelect_Popup_UIBP = {
    keyName = "UGC_MapSelect_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_MapSelect_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_MapSelect_Popup_UIBP.UGC_MapSelect_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-WOW\232\181\155\229\173\163\231\166\129\233\128\137\231\149\140\233\157\162"
    }
  },
  UGC_Feedback_Tips_Item_UIBP = {
    keyName = "UGC_Feedback_Tips_Item_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGC_Feedback_Tips_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/HotTheme/UGC_Feedback_Tips_Item_UIBP.UGC_Feedback_Tips_Item_UIBP",
    isSingleton = false,
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.TopZOrder,
    uiStat = {
      name = "UGC-\229\143\141\233\166\136tips\233\157\162\230\157\191"
    }
  },
  UGC_Feedback_Tips_Item_Option_UIBP = {
    keyName = "UGC_Feedback_Tips_Item_Option_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGC_Feedback_Tips_Item_Option_UIBP",
    path = "/Game/UMG/UI_BP/UGC/HotTheme/UGC_Feedback_Tips_Item_Option_UIBP.UGC_Feedback_Tips_Item_Option_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\143\141\233\166\136tips\233\157\162\230\157\191 - \233\128\137\233\161\185"
    }
  },
  UGC_TopMod_HotBanner_MultiPage_Item_UIBP = {
    keyName = "UGC_TopMod_HotBanner_MultiPage_Item_UIBP",
    moduleName = "client.slua.umg.ugc.HotTheme.UGC_TopMod_HotBanner_MultiPage_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/HotTheme/UGC_TopMod_HotCompilation_UIBP.UGC_TopMod_HotCompilation_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-banner \228\189\156\229\147\129\229\146\140\229\144\136\233\155\134"
    }
  },
  UGC_RankMod_Hot_UIBP = {
    keyName = "UGC_RankMod_Hot_UIBP",
    moduleName = "client.slua.umg.ugc.HotTheme.UGC_RankMod_Hot_UIBP",
    path = "/Game/UMG/UI_BP/UGC/HotTheme/UGC_RankMod_Hot_UIBP.UGC_RankMod_Hot_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-banner01-WOW\232\181\155\229\173\163"
    }
  },
  UGC_TopMod_ThemeAuthor_UIBP = {
    keyName = "UGC_TopMod_ThemeAuthor_UIBP",
    moduleName = "client.slua.umg.ugc.HotTheme.UGC_TopMod_ThemeAuthor_UIBP",
    path = "/Game/UMG/UI_BP/UGC/HotTheme/UGC_TopMod_ThemeAuthor_UIBP.UGC_TopMod_ThemeAuthor_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-banner03-WOW\232\181\155\229\173\163\228\184\139-match\229\146\140author\229\134\133\229\174\185"
    }
  },
  UGC_SelectRecommend_Hot_UIBP = {
    keyName = "UGC_SelectRecommend_Hot_UIBP",
    moduleName = "client.slua.umg.ugc.HotTheme.UGC_SelectRecommend_Hot_UIBP",
    path = "/Game/UMG/UI_BP/UGC/HotTheme/UGC_SelectRecommend_Hot_UIBP.UGC_SelectRecommend_Hot_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-banner02"
    }
  },
  UGC_TopMod_HotBanner03_Item_UIBP = {
    keyName = "UGC_TopMod_HotBanner03_Item_UIBP",
    moduleName = "client.slua.umg.ugc.HotTheme.UGC_TopMod_HotBanner03_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/HotTheme/UGC_TopMod_HotBanner03_Item_UIBP.UGC_TopMod_HotBanner03_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-banner03"
    }
  },
  UGC_SelectRecommend_Hot01_UIBP = {
    keyName = "UGC_SelectRecommend_Hot01_UIBP",
    moduleName = "client.slua.umg.ugc.HotTheme.UGC_SelectRecommend_Hot01_UIBP",
    path = "/Game/UMG/UI_BP/UGC/HotTheme/UGC_SelectRecommend_Hot01_UIBP.UGC_SelectRecommend_Hot01_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-banner03-item"
    }
  },
  UGC_TopSelectRecommend_DetailsPage_UIBP = {
    keyName = "UGC_TopSelectRecommend_DetailsPage_UIBP",
    moduleName = "client.slua.umg.ugc.HotTheme.UGC_TopSelectRecommend_DetailsPage_UIBP",
    path = "/Game/UMG/UI_BP/UGC/HotTheme/UGC_TopSelectRecommend_DetailsPage_UIBP.UGC_TopSelectRecommend_DetailsPage_UIBP",
    uiStat = {
      name = "UGC-\228\184\187\233\162\152\233\161\181"
    }
  },
  UGCDetailMainPanel = {
    keyName = "UGCDetailMainPanel",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGCDetailMainPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_DetailMain_UIBP.UGC_Lobby_DetailMain_UIBP",
    asy = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133\230\161\134\230\158\182"
    }
  },
  UGCDetailMainPanelSeason = {
    keyName = "UGCDetailMainPanelSeason",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGCDetailMainPanelSeason",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_DetailMain_UIBP.UGC_Lobby_DetailMain_UIBP",
    asy = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "UGC-\232\181\155\229\173\163\232\175\166\230\131\133\230\161\134\230\158\182"
    }
  },
  UGC_PersonalDetail_UIBP = {
    keyName = "UGC_PersonalDetail_UIBP",
    moduleName = "client.slua.umg.ugc.Commercialization.UGC_PersonalDetail_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Commercialization/UGC_PersonalHomepage_UIBP.UGC_PersonalHomepage_UIBP",
    asy = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "UGC-\228\184\170\228\186\186\228\184\187\233\161\181\232\175\166\230\131\133\230\161\134\230\158\182"
    }
  },
  UGC_PersonalMainDetail_Sub_UIBP = {
    keyName = "UGC_PersonalMainDetail_Sub_UIBP",
    moduleName = "client.slua.umg.ugc.Commercialization.UGC_PersonalMainDetail_Sub_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Commercialization/UGC_Lobby_Commercialization_Sub_UIBP.UGC_Lobby_Commercialization_Sub_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\149\134\228\184\154\229\140\150\228\184\170\228\186\186\228\184\187\233\161\181"
    }
  },
  UGC_Lobby_Card_Share_UIBP = {
    keyName = "UGC_Lobby_Card_Share_UIBP",
    moduleName = "client.slua.umg.ugc.Commercialization.UGC_Lobby_Card_Share_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Commercialization/UGC_Lobby_Card_Share_UIBP.UGC_Lobby_Card_Share_UIBP",
    asy = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "UGC-\229\149\134\228\184\154\229\140\150\228\184\170\228\186\186\228\184\187\233\161\181-\229\136\134\228\186\171"
    }
  },
  UGC_Lobby_RankMode_Sub_UIBP = {
    keyName = "UGC_Lobby_RankMode_Sub_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGC_Lobby_RankMode_Sub_UIBP",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_RankMode_Sub_UIBP.UGC_Lobby_RankMode_Sub_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-WOW\232\181\155\229\173\163\232\175\166\230\131\133\233\161\181"
    }
  },
  UGC_SeasonMap_UpdateTips_UIBP = {
    keyName = "UGC_SeasonMap_UpdateTips_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGC_SeasonMap_UpdateTips_UIBP",
    path = "/Game/UMG/UI_BP/UGC/PlayPreference/UGC_SeasonMap_UpdateTips_UIBP.UGC_SeasonMap_UpdateTips_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-WOW\229\136\155\230\184\184\232\174\176\230\155\180\230\150\176\229\156\176\229\155\190\230\139\141\232\132\184"
    }
  },
  UGCDetailOperateSubPanel = {
    keyName = "UGCDetailOperateSubPanel",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGCDetailOperateSubPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_DetailOperate_Sub_UIBP.UGC_Lobby_DetailOperate_Sub_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133-\230\147\141\228\189\156"
    }
  },
  UGCDetailInfoSubPanel = {
    keyName = "UGCDetailInfoSubPanel",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGCDetailInfoSubPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_DetailInfo_Sub_UIBP.UGC_Lobby_DetailInfo_Sub_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133-\228\191\161\230\129\175"
    }
  },
  UGCDetailInfoCoauthorItem = {
    keyName = "UGCDetailInfoCoauthorItem",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGCDetailInfoCoauthorItem",
    path = "/Game/UMG/UI_BP/UGC/Item/UGC_Detail_Auther_Item_UIBP.UGC_Detail_Auther_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133-\229\133\177\229\136\155 \230\157\161\231\155\174"
    }
  },
  UGC_Rank_UIBP = {
    keyName = "UGC_Rank_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGC_Rank_UIBP",
    path = "/Game/UMG/UI_BP/UGC/UGC_Rank_UIBP.UGC_Rank_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133-\230\142\146\232\161\140\230\166\156"
    }
  },
  UGC_Rank_Tips_Item_UIBP = {
    keyName = "UGC_Rank_Tips_Item_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGC_Rank_Tips_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Item/UGC_Rank_Tips_Item_UIBP.UGC_Rank_Tips_Item_UIBP",
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133-\230\142\146\232\161\140\230\166\156-tips"
    }
  },
  UGCDetailUpdateLogPanel = {
    keyName = "UGCDetailUpdateLogPanel",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGCDetailUpdateLogPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_Detail_UpdateLog_UIBP.UGC_Lobby_Detail_UpdateLog_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133-\230\155\180\230\150\176\230\151\165\229\191\151"
    }
  },
  UGCUpdateLog_Popup_UIBP = {
    keyName = "UGCUpdateLog_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGCUpdateLog_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Update_Popup_UIBP.UGC_Update_Popup_UIBP",
    containerName = UIContainers.Top,
    isSingleton = false,
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133-\230\155\180\230\150\176\230\151\165\229\191\151\229\188\185\230\161\134"
    }
  },
  UGCDetailPlayHistorySubPanel = {
    keyName = "UGCDetailPlayHistorySubPanel",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGCDetailPlayHistorySubPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Play_Review_UIBP.UGC_Play_Review_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\228\189\156\229\147\129\232\175\166\230\131\133\230\184\184\231\142\169\229\155\158\233\161\190\233\161\181"
    }
  },
  UGC_PlayHistory_Item_UIBP = {
    keyName = "UGC_PlayHistory_Item_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGC_PlayHistory_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Item/UGC_PlayHistory_Item_UIBP.UGC_PlayHistory_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\228\189\156\229\147\129\232\175\166\230\131\133\230\184\184\231\142\169\229\155\158\233\161\190item"
    }
  },
  UGC_UpdateLog_Item_UIBP = {
    keyName = "UGC_UpdateLog_Item_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGC_UpdateLog_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Item/UGC_UpdateLog_Item_UIBP.UGC_Update_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133-\230\155\180\230\150\176\230\151\165\229\191\151\229\188\185\231\170\151item"
    }
  },
  UGC_UnpublishReleaseVersion_Popup_UIBP = {
    keyName = "UGC_UnpublishReleaseVersion_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGC_UnpublishReleaseVersion_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_UnpublishReleaseVersion_Popup_UIBP.UGC_UnpublishReleaseVersion_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133-\230\155\180\230\150\176\230\151\165\229\191\151-\229\173\152\230\161\163\231\188\150\232\190\145\232\166\134\231\155\150\229\188\185\231\170\151"
    }
  },
  UGC_Update_Log_Item_UIBP = {
    keyName = "UGC_Update_Log_Item_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGC_Update_Log_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Item/UGC_Update_Log_Item_UIBP.UGC_Update_Log_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133-\230\155\180\230\150\176\230\151\165\229\191\151item"
    }
  },
  UGC_ModShare_Popup_UIBP = {
    keyName = "UGC_ModShare_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_ModShare_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_ModShare_Popup_UIBP.UGC_ModShare_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133-\229\136\134\228\186\171\228\189\156\229\147\129\230\173\165\233\170\1642"
    }
  },
  UGC_SendFriends_Popup_UIBP = {
    keyName = "UGC_SendFriends_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_SendFriends_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_SendFriends_Popup_UIBP.UGC_SendFriends_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "UGC-\229\144\136\233\155\134\229\136\134\228\186\171\230\173\165\233\170\1642-\229\174\182\229\155\173\232\175\166\230\131\133\229\136\134\228\186\171"
    }
  },
  UGCDetailCoAutherListPanel = {
    keyName = "UGCDetailCoAutherListPanel",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGCDetailCoAutherListPanel",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Detail_CoAutherList_Popup_UIBP.UGC_Detail_CoAutherList_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\229\133\177\229\136\155\228\189\156\232\128\133\229\188\185\230\161\134"
    }
  },
  ugc_mod_report = {
    keyName = "ugc_mod_report",
    moduleName = "client.slua.umg.ugc.detail.UgcModReportBaseInGame",
    path = "/Game/UMG/UI_BP/UGC/UGC_Report_Content_UIBP.UGC_Report_Content_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-UGC\229\177\128\229\134\133"
    },
    isSingleton = false
  },
  ugc_collections_report = {
    keyName = "ugc_collections_report",
    moduleName = "client.slua.umg.ugc.lobby.collection.UgcCollectionsReport",
    path = "/Game/UMG/UI_BP/UGC/CollectionList/UGC_CollectionReport_Popup_UIBP.UGC_CollectionReport_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\228\189\156\229\147\129\229\144\136\233\155\134"
    }
  },
  ugc_select_tag = {
    keyName = "ugc_select_tag",
    moduleName = "client.slua.umg.ugc.tag.ugc_select_tag",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_SelectTag_Popup_UIBP.UGC_SelectTag_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\231\142\169\230\179\149\230\160\135\231\173\190-\233\128\137\230\139\169\230\160\135\231\173\190"
    }
  },
  ugc_search_tag = {
    keyName = "ugc_search_tag",
    moduleName = "client.slua.umg.ugc.tag.ugc_search_tag",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_SelectTag_Popup_UIBP.UGC_SelectTag_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\230\144\156\231\180\162-\233\128\137\230\139\169\230\160\135\231\173\190"
    }
  },
  UGC_Lobby_FilterTab_Item_UIBP = {
    keyName = "UGC_Lobby_FilterTab_Item_UIBP",
    moduleName = "client.slua.umg.ugc.tag.UGC_Lobby_FilterTab_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Item/UGC_Lobby_FilterTab_Item_UIBP.UGC_Lobby_FilterTab_Item_UIBP",
    isSingleton = false,
    isWindowsOBHide = true,
    uiStat = {
      name = "UGC-\231\142\169\230\179\149\230\160\135\231\173\190-\230\160\135\231\173\190item"
    }
  },
  UGCCreateRoomPanel = {
    keyName = "UGCCreateRoomPanel",
    moduleName = "client.slua.umg.ugc.lobby.room.UGCCreateRoomPanel",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Lobby_CreateRoom_Popup_UIBP.UGC_Lobby_CreateRoom_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\229\187\186\230\136\191\233\151\180"
    }
  },
  UGCRoomWaitingPanel = {
    keyName = "UGCRoomWaitingPanel",
    moduleName = "client.slua.umg.ugc.lobby.room.UGCRoomWaitingPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_RoomWaiting_UIBP.UGC_Lobby_RoomWaiting_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UGC_ROOM_WAITING,
    asy = true,
    uiStat = {
      name = "UGC-\230\136\191\233\151\180\231\173\137\229\190\133\231\149\140\233\157\162"
    }
  },
  UGCHistoryPanel = {
    keyName = "UGCHistoryPanel",
    moduleName = "client.slua.umg.ugc.lobby.history.UGCHistoryPanel",
    path = "/Game/UMG/UI_BP/UGC/WowPage/UGC_Wow_Secondary_Page_02_UIBP.UGC_Wow_Secondary_Page_02_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\230\184\184\231\142\169\229\142\134\229\143\178\233\161\181"
    }
  },
  UGCCollectPanel = {
    keyName = "UGCCollectPanel",
    moduleName = "client.slua.umg.ugc.lobby.collect.UGCCollectPanel",
    path = "/Game/UMG/UI_BP/UGC/WowPage/UGC_Wow_Secondary_Page_03_UIBP.UGC_Wow_Secondary_Page_03_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\230\148\182\232\151\143\233\161\181"
    }
  },
  UGCFollowPanel = {
    keyName = "UGCFollowPanel",
    moduleName = "client.slua.umg.ugc.lobby.follow.UGCFollowPanel",
    path = "/Game/UMG/UI_BP/UGC/WowPage/UGC_Wow_Secondary_Page_UIBP.UGC_Wow_Secondary_Page_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\133\179\230\179\168\233\161\181"
    }
  },
  UGCCollectionListPanel = {
    keyName = "UGCCollectionListPanel",
    moduleName = "client.slua.umg.ugc.lobby.collection.UGCCollectionListPanel",
    path = "/Game/UMG/UI_BP/UGC/WowPage/UGC_Wow_Secondary_Page_03_UIBP.UGC_Wow_Secondary_Page_03_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC\230\136\145\231\154\132-\229\144\136\233\155\134-\230\136\145\231\154\132"
    }
  },
  UGCCreateCollectionListPopup = {
    keyName = "UGCCreateCollectionListPopup",
    moduleName = "client.slua.umg.ugc.lobby.collection.UGCCreateCollectionListPopup",
    path = "/Game/UMG/UI_BP/UGC/CollectionList/UGC_CreateCollectionList_Popup_UIB.UGC_CreateCollectionList_Popup_UIB",
    uiStat = {
      name = "UGC\230\136\145\231\154\132-\229\136\155\229\187\186/\231\188\150\232\190\145\228\189\156\229\147\129\229\144\136\233\155\134"
    }
  },
  UGCCollectionListEditPopup = {
    keyName = "UGCCollectionListEditPopup",
    moduleName = "client.slua.umg.ugc.lobby.collection.UGCCollectionListEditPopup",
    path = "/Game/UMG/UI_BP/UGC/CollectionList/UGC_CollectionAdd_Popup_UIBP.UGC_CollectionAdd_Popup_UIBP",
    uiStat = {
      name = "UGC\230\136\145\231\154\132-\229\144\136\233\155\134-\230\183\187\229\138\160\229\136\160\233\153\164\229\144\136\233\155\134"
    }
  },
  UGCCollectionListDetailsPanelUI = {
    keyName = "UGCCollectionListDetailsPanelUI",
    moduleName = "client.slua.umg.ugc.lobby.collection.UGCCollectionListDetailsPanelUI",
    path = "/Game/UMG/UI_BP/UGC/CollectionList/UGC_CollectionList_DetailsPanel_UIBP.UGC_CollectionList_DetailsPanel_UIBP",
    uiStat = {
      name = "UGC-\229\144\136\233\155\134\232\175\166\230\131\133-\228\184\187/\229\174\162\230\128\129"
    }
  },
  UGC_Share_CollectionList_Popup_UIBP = {
    keyName = "UGC_Share_CollectionList_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.collection.popup.UGC_Share_CollectionList_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Share_CollectionList_Popup_UIBP.UGC_Share_CollectionList_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133-\229\136\134\228\186\171\228\189\156\229\147\129\229\144\136\233\155\134\230\173\165\233\170\1641"
    }
  },
  UGC_SendFriends_CollectionList_Popup_UIBP = {
    keyName = "UGC_SendFriends_CollectionList_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.collection.popup.UGC_SendFriends_CollectionList_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_SendFriends_CollectionList_Popup_UIBP.UGC_SendFriends_CollectionList_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133-\229\136\134\228\186\171\228\189\156\229\147\129\229\144\136\233\155\134\230\173\165\233\170\1642"
    }
  },
  UGCFriendPanel = {
    keyName = "UGCFriendPanel",
    moduleName = "client.slua.umg.ugc.lobby.friend.UGCFriendPanel",
    path = "/Game/UMG/UI_BP/UGC/WowPage/UGC_Wow_Secondary_Page_UIBP.UGC_Wow_Secondary_Page_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\165\189\229\143\139\228\189\156\229\147\129\233\161\181"
    }
  },
  UGCRoomListPanel = {
    keyName = "UGCRoomListPanel",
    moduleName = "client.slua.umg.ugc.lobby.room.UGCRoomListPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_RoomList_Panel_UIBP.UGC_Lobby_RoomList_Panel_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\230\136\191\233\151\180\229\136\151\232\161\168"
    }
  },
  UGCRoomSharePanel = {
    keyName = "UGCRoomSharePanel",
    moduleName = "client.slua.umg.ugc.popup.UGC_RoomShare_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_RoomShare_Popup_UIBP.UGC_RoomShare_Popup_UIBP",
    uiStat = {
      name = "UGC-\230\136\191\233\151\180\230\139\155\229\139\159"
    }
  },
  UGCRandomPanel = {
    keyName = "UGCRandomPanel",
    moduleName = "client.slua.umg.ugc.lobby.random.UGCRandomPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_Collect_UIBP.UGC_Lobby_Collect_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\233\154\143\230\156\186\230\142\168\232\141\144\233\161\181"
    }
  },
  UGCChatShareInvitePanel = {
    keyName = "UGCChatShareInvitePanel",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGCChatShareInvitePanel",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_ChatShare_Popup_UIBP.UGC_ChatShare_Popup_UIBP",
    uiStat = {
      name = "UGC-\229\136\134\228\186\171\229\136\176\232\129\138\229\164\169"
    }
  },
  UGCExtraSharePanel = {
    keyName = "UGCExtraSharePanel",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGCExtraSharePanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_ExtraShare_UIBP.UGC_ExtraShare_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\164\150\233\131\168\229\136\134\228\186\171"
    }
  },
  UGCExtraShareCollectionPanel = {
    keyName = "UGCExtraShareCollectionPanel",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGCExtraShareCollectionPanel",
    path = "/Game/UMG/UI_BP/UGC/CollectionList/UGC_Compilation_ShareInterface_UIBP.UGC_Compilation_ShareInterface_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\164\150\233\131\168\229\144\136\233\155\134\229\136\134\228\186\171"
    }
  },
  UGCLobbyGuideBubble = {
    keyName = "UGCLobbyGuideBubble",
    moduleName = "client.slua.umg.ugc.lobby.UGCLobbyGuideBubble",
    path = "/Game/UMG/UI_BP/UGC/UGC_Guide_Bubble_UIBP.UGC_Guide_Bubble_UIBP",
    uiStat = {
      name = "UGC-\229\188\149\229\175\188\230\176\148\230\179\161\230\143\144\231\164\186"
    }
  },
  UGCSearchReoirt = {
    keyName = "UGCSearchReoirt",
    moduleName = "client.slua.umg.ugc.lobby.UGCSearchReoirt",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_TopSearchReport_Popup_UIBP.UGC_TopSearchReport_Popup_UIBP",
    uiStat = {
      name = "UGC-\230\144\156\231\180\162\228\184\190\230\138\165\229\188\185\231\170\151"
    }
  },
  UGCReportBug = {
    keyName = "UGCReportBug",
    moduleName = "client.slua.umg.report_error.ugc_lobby_report_bug",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_ReportBug_Copy_Popup_UIBP.UGC_ReportBug_Copy_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\230\136\152\230\150\151\230\138\165\233\148\153"
    }
  },
  UGCReportWorkCopy = {
    keyName = "UGCReportWorkCopy",
    moduleName = "client.slua.umg.ugc.detail.ugc_mod_report",
    path = "/Game/UMG/UI_BP/UGC/UGC_Report_Content_Copy_UIBP.UGC_Report_Content_Copy_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-UGC\229\177\128\229\164\150"
    },
    isSingleton = false
  },
  UGC_RandomPlay_Popup_UIBP = {
    keyName = "UGC_RandomPlay_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.multi.UGC_RandomPlay_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CollectionList/UGC_Compilation_Popup_UIBP.UGC_Compilation_Popup_UIBP",
    uiStat = {
      name = "UGC-\233\154\143\230\156\186\230\184\184\231\142\169\232\175\166\230\131\133"
    }
  },
  UGC_ConcernManage_Popup_UIBP = {
    keyName = "UGC_ConcernManage_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_ConcernManage_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_ConcernManage_Popup_UIBP.UGC_ConcernManage_Popup_UIBP",
    uiStat = {
      name = "UGC-\229\133\179\230\179\168\228\189\156\232\128\133\229\136\151\232\161\168\229\188\185\231\170\151"
    }
  },
  UGC_Monster_CaptureShow_Item = {
    keyName = "UGC_Monster_CaptureShow_Item",
    moduleName = "client.slua.umg.ugc.Item.UGC_Monster_CaptureShow_Item",
    path = "/Game/UMG/UI_BP/UGC/Item/UGC_Monster_CaptureShow_Item.UGC_Monster_CaptureShow_Item",
    isMainUI = false,
    uiStat = {
      name = "UGC-\230\128\170\231\137\1692D\230\138\147\229\143\150\230\152\190\231\164\186\230\142\167\228\187\182"
    }
  },
  UGCSendRankingCommentUI = {
    keyName = "UGCSendRankingCommentUI",
    moduleName = "client.slua.umg.ugc.comment.UGCSendRankingCommentUI",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Feedback_Popup_UIBP.UGC_Feedback_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\228\189\156\229\147\129\232\175\132\228\187\183Popup-UGC\229\177\128\229\134\133"
    }
  },
  UGCSendRankingCommentUI_Lobby = {
    keyName = "UGCSendRankingCommentUI_Lobby",
    moduleName = "client.slua.umg.ugc.comment.UGCSendRankingCommentUI_Lobby",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Feedback_Popup_UIBP.UGC_Feedback_Popup_UIBP",
    uiStat = {
      name = "UGC-\228\189\156\229\147\129\232\175\132\228\187\183Popup-\229\164\167\229\142\133"
    }
  },
  UGC_Lobby_HotTheme_UIBP = {
    keyName = "UGC_Lobby_HotTheme_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.hotTheme.UGC_Lobby_HotTheme_UIBP",
    path = "/Game/UMG/UI_BP/UGC/HotTheme/UGC_Lobby_HotTheme_UIBP.UGC_Lobby_HotTheme_UIBP",
    isMainUI = false,
    uiStat = {
      name = "UGC-\229\164\167\229\142\133-\232\175\157\233\162\152\231\131\173\233\151\168\233\161\181"
    }
  },
  UGC_CWOW_Invite_Notify_UIBP = {
    keyName = "UGC_CWOW_Invite_Notify_UIBP",
    moduleName = "client.slua.umg.creative_wow.CreativeWoWInviteNotifyUIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Universal_Popup_UGC_WOW_Invite_UIBP.Universal_Popup_UGC_WOW_Invite_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\165\135\229\166\153\228\184\150\231\149\140-\233\130\128\232\175\183\233\128\154\231\159\165"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  UGCExposureCouponUsePopupUI = {
    keyName = "UGCExposureCouponUsePopupUI",
    moduleName = "client.slua.umg.ugc.lobby.exposure.UGCExposureCouponUsePopupUI",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_ExposureCouponUse_Popup_UIBP.UGC_ExposureCouponUse_Popup_UIBP",
    uiStat = {
      name = "UGC-\228\189\191\231\148\168\230\155\157\229\133\137\229\136\184"
    }
  },
  UGCExposureCouponPopupUI = {
    keyName = "UGCExposureCouponPopupUI",
    moduleName = "client.slua.umg.ugc.lobby.exposure.UGCNewExposureCouponPopupUI",
    path = "/Game/UMG/UI_BP/UGC/UGC_ExposureCoupon_UIBP.UGC_ExposureCoupon_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "UGC-\230\159\165\231\156\139\230\155\157\229\133\137\229\136\184"
    }
  },
  UGCExposureRecordSubUI = {
    keyName = "UGCExposureRecordSubUI",
    moduleName = "client.slua.umg.ugc.lobby.exposure.UGCNewExposureRecordSubUI",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_Extend_Sub_UIBP.UGC_Lobby_Extend_Sub_UIBP",
    isMainUI = false,
    uiStat = {
      name = "UGC-\230\142\168\229\185\191\232\174\176\229\189\149"
    }
  },
  UGCCollectionSubUI = {
    keyName = "UGCCollectionSubUI",
    moduleName = "client.slua.umg.ugc.lobby.collection.UGCCollectionSubUI",
    path = "/Game/UMG/UI_BP/UGC/CollectionList/UGC_Lobby_CollectionList_Sub_UIBP.UGC_Lobby_CollectionList_Sub_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\189\156\229\147\129\232\175\166\230\131\133-\229\144\136\233\155\134"
    }
  },
  UGCPlayTaskUI = {
    keyName = "UGCPlayTaskUI",
    moduleName = "client.slua.umg.ugc.lobby.task.UGCPlayTaskUI",
    path = "/Game/UMG/UI_BP/Task/Task_Integration/Task_New/Lobby_Integration_Wow_Task_UIBP.Lobby_Integration_Wow_Task_UIBP",
    isMainUI = false,
    uiStat = {
      name = "UGC\230\184\184\231\142\169\228\187\187\229\138\161"
    }
  },
  UGCShowCollectionsPopUI = {
    keyName = "UGCShowCollectionsPopUI",
    moduleName = "client.slua.umg.ugc.lobby.collection.UGCShowCollectionsPopUI",
    path = "/Game/UMG/UI_BP/UGC/CollectionList/UGC_CreateCollection_Popup_UIBP.UGC_CreateCollection_Popup_UIBP",
    uiStat = {
      name = "\229\136\155\229\187\186\231\154\132\228\189\156\229\147\129\229\136\151\232\161\168"
    }
  },
  UGCMatchRoom_Main = {
    keyName = "UGCMatchRoom_Main",
    moduleName = "client.slua.umg.ugc.lobby.UGCMatchRoom.UGCMatchRoom_Main",
    path = "/Game/UMG/UI_BP/UGC/UGCMapMatchRoom/UGC_Match_Room_UIBP.UGC_Match_Room_UIBP",
    asy = true,
    uiStat = {
      name = "UGC\228\189\156\229\147\129\229\164\167\229\142\133"
    }
  },
  UGCMatchRoom_Main_Preview = {
    keyName = "UGCMatchRoom_Main_Preview",
    moduleName = "client.slua.umg.ugc.lobby.UGCMatchRoom.UGCMatchRoom_Main_Preview",
    path = "/Game/UMG/UI_BP/UGC/Store/Item/Inventory_RoomDecoration_Item_UIBP.Inventory_RoomDecoration_Item_UIBP",
    asy = true,
    uiStat = {
      name = "UGC\228\189\156\229\147\129\229\164\167\229\142\133Preview"
    },
    isSingleton = false,
    isMainUI = false
  },
  UGCMatchRoom_ModItem = {
    keyName = "UGCMatchRoom_ModItem",
    moduleName = "client.slua.umg.ugc.lobby.UGCMatchRoom.UGCMatchRoom_ModItem",
    path = "/Game/UMG/UI_BP/UGC/UGCMapMatchRoom/UGC_Match_RoomName_UIBP.UGC_Match_RoomName_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC\228\189\156\229\147\129\229\164\167\229\142\133-\228\191\161\230\129\175"
    }
  },
  UGCMatchRoom_Chat = {
    keyName = "UGCMatchRoom_Chat",
    moduleName = "client.slua.umg.ugc.lobby.UGCMatchRoom.UGCMatchRoom_Chat",
    path = "/Game/UMG/UI_BP/UGC/UGCMapMatchRoom/UGC_Match_Room_Chat.UGC_Match_Room_Chat",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC\228\189\156\229\147\129\229\164\167\229\142\133-\232\129\138\229\164\169"
    }
  },
  UGCMatchRoom_ReadyTips = {
    keyName = "UGCMatchRoom_ReadyTips",
    moduleName = "client.slua.umg.ugc.lobby.UGCMatchRoom.UGCMatchRoom_ReadyTips",
    path = "/Game/UMG/UI_BP/UGC/UGCMapMatchRoom/UGC_Match_Room_ReadyTips_UIBP.UGC_Match_Room_ReadyTips_UIBP",
    isSingleton = true,
    isMainUI = false,
    asy = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "ugc\228\189\156\229\147\129\229\164\167\229\142\133\229\140\185\233\133\141\230\136\144\229\138\159Tips"
    }
  },
  UGCMatchRoom_Start = {
    keyName = "UGCMatchRoom_Start",
    moduleName = "client.slua.umg.ugc.lobby.UGCMatchRoom.UGCMatchRoom_Start",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_RoomMaster_ShowRoundStart_UIBP.UGC_Lobby_RoomMaster_ShowRoundStart_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "ugc\228\189\156\229\147\129\229\164\167\229\142\133\229\140\185\233\133\141\230\136\144\229\138\159Tips"
    }
  },
  UGCMatchRoom_MatchSelect = {
    keyName = "UGCMatchRoom_MatchSelect",
    moduleName = "client.slua.umg.ugc.lobby.UGCMatchRoom.UGCMatchRoom_MatchSelect",
    path = "/Game/UMG/UI_BP/UGC/UGCMapMatchRoom/UGC_Match_Room_Tab_UIBP.UGC_Match_Room_Tab_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC\228\189\156\229\147\129\229\164\167\229\142\133-\233\128\137\230\139\169\230\136\191\233\151\180"
    }
  },
  UGCMatchRoom_MatchSelect_Item = {
    keyName = "UGCMatchRoom_MatchSelect_Item",
    moduleName = "client.slua.umg.ugc.lobby.UGCMatchRoom.UGCMatchRoom_MatchSelect_Item",
    path = "/Game/UMG/UI_BP/UGC/UGCMapMatchRoom/UGC_Match_Room_Tab_Item_UIBP.UGC_Match_Room_Tab_Item_UIBP",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC\228\189\156\229\147\129\229\164\167\229\142\133-\233\128\137\230\139\169\230\136\191\233\151\180"
    }
  },
  UGCMatchRoom_Select_Popup = {
    keyName = "UGCMatchRoom_Select_Popup",
    moduleName = "client.slua.umg.ugc.lobby.UGCMatchRoom.UGCMatchRoom_Select_Popup",
    path = "/Game/UMG/UI_BP/UGC/UGCMapMatchRoom/Popup/UGC_Wait_Popup_UIBP.UGC_Wait_Popup_UIBP",
    uiStat = {
      name = "UGC\228\189\156\229\147\129\229\164\167\229\142\133-\230\184\133\231\144\134\228\189\156\229\147\129"
    }
  },
  Creative_Revive_Count_Down_Item = {
    keyName = "Creative_Revive_Count_Down_Item",
    moduleName = "client.slua.umg.ugc.ingame.UGC_Revive_Cutdown_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true
  },
  Comment_Manage_AllWork_UIBP = {
    keyName = "Comment_Manage_AllWork_UIBP",
    moduleName = "client.slua.umg.ugc.comment.Comment_Manage_AllWork_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Comment/Comment_Manage_AllWork_UIBP.Comment_Manage_AllWork_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC\232\175\132\228\187\183-\230\137\128\230\156\137\228\189\156\229\147\129\231\154\132\232\175\132\228\187\183\231\174\161\231\144\134"
    }
  },
  Comment_Manage_OneWork_UIBP = {
    keyName = "Comment_Manage_OneWork_UIBP",
    moduleName = "client.slua.umg.ugc.comment.Comment_Manage_OneWork_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Comment/Comment_Manage_OneWork_UIBP.Comment_Manage_OneWork_UIBP",
    uiStat = {
      name = "UGC\232\175\132\228\187\183-\229\141\149\228\184\170\228\189\156\229\147\129\231\154\132\232\175\132\228\187\183\231\174\161\231\144\134"
    },
    jumpModuleID = BP_ENUM_MODULE_RARE_ONE_WORK_COMMENT_MANAGE
  },
  UGC_Comment_Reply_UIBP = {
    keyName = "UGC_Comment_Reply_UIBP",
    moduleName = "client.slua.umg.ugc.comment.UGC_Comment_Reply_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Comment/UGC_Comment_Reply_UIBP.UGC_Comment_Reply_UIBP",
    uiStat = {
      name = "UGC\232\175\132\228\187\183-\229\155\158\229\164\141"
    }
  },
  Comment_Author_Release_UIBP = {
    keyName = "Comment_Author_Release_UIBP",
    moduleName = "client.slua.umg.ugc.comment.Comment_Author_Release_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Comment/Comment_Author_Release_UIBP.Comment_Author_Release_UIBP",
    uiStat = {
      name = "UGC\232\175\132\228\187\183-\228\189\156\232\128\133\231\149\153\232\168\128"
    }
  },
  ModeSelection_Home_UIBP = {
    keyName = "ModeSelection_Home_UIBP",
    moduleName = "client.slua.umg.ugc.phome.ModeSelection_Home_UIBP",
    path = "/Game/UMG/UI_BP/Home/ModeSelection/ModeSelection_Home_UIBP.ModeSelection_Home_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {name = "UGC-\229\174\182\229\155\173"}
  },
  manor_lobby_report_bug = {
    keyName = "manor_lobby_report_bug",
    moduleName = "client.slua.umg.report_error.manor_lobby_report_bug",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_ReportBug_Copy_Popup_UIBP.UGC_ReportBug_Copy_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\229\174\182\229\155\173\228\184\190\230\138\165"
    }
  },
  home_report = {
    keyName = "home_report",
    moduleName = "client.slua.umg.Home.Report.home_report",
    path = "/Game/UMG/UI_BP/UGC/UGC_Report_Content_Copy_UIBP.UGC_Report_Content_Copy_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\229\174\182\229\155\173\230\149\180\228\189\147\239\188\136\229\177\128\229\164\150\229\174\182\229\155\173\232\175\166\230\131\133\227\128\129\229\155\190\231\186\184\239\188\137"
    },
    isSingleton = false
  },
  home_mod_report = {
    keyName = "home_mod_report",
    moduleName = "client.slua.umg.Home.Report.home_mod_report",
    path = "/Game/UMG/UI_BP/UGC/UGC_Report_Content_UIBP.UGC_Report_Content_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\229\174\182\229\155\173\229\177\128\229\134\133\239\188\136\231\133\167\231\137\135\229\162\153\227\128\129\229\174\182\229\155\173\232\175\166\230\131\133\227\128\129\228\184\187\231\149\140\233\157\162\228\184\190\230\138\165\229\133\165\229\143\163\239\188\137"
    },
    isSingleton = false
  },
  UGC_WorkEditTag_Popup_UIBP = {
    keyName = "UGC_WorkEditTag_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGC_WorkEditTag_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_WorkEditTag_Popup_UIBP.UGC_WorkEditTag_Popup_UIBP",
    uiStat = {
      name = "UGC-\231\142\169\229\174\182\231\187\153\228\189\156\229\147\129\230\183\187\229\138\160\230\160\135\231\173\190"
    }
  },
  UGC_AIOptimizeTag_Popup_UIBP = {
    keyName = "UGC_AIOptimizeTag_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.creator.personal.UGC_AIOptimizeTag_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_AIOptimizeTag_Popup_UIBP.UGC_AIOptimizeTag_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\232\128\133-\230\160\135\231\173\190\229\188\185\231\170\151"
    }
  },
  ugc_player_select_tag = {
    keyName = "ugc_player_select_tag",
    moduleName = "client.slua.umg.ugc.tag.ugc_player_select_tag",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_SelectTag_Popup_UIBP.UGC_SelectTag_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\231\142\169\230\179\149\230\160\135\231\173\190-\231\142\169\229\174\182\231\187\153\228\189\156\229\147\129\232\135\170\233\128\137\230\160\135\231\173\190"
    }
  },
  Collect_Milestone_SharePopup_UIBP = {
    keyName = "Collect_Milestone_SharePopup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Milestone.Collect_Milestone_SharePopup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_ChatShare_Popup_UIBP.UGC_ChatShare_Popup_UIBP",
    uiStat = {
      name = "\229\136\134\228\186\171\232\129\138\229\164\169\231\149\140\233\157\162"
    }
  },
  UGC_Main_Search_UIBP = {
    keyName = "UGC_Main_Search_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGC_Main_Search_UIBP",
    path = "/Game/UMG/UI_BP/UGC/UGC_Main_Search_UIBP.UGC_Main_Search_UIBP",
    asy = true,
    uiStat = {name = "UGC-\230\144\156\231\180\162"}
  },
  UGC_Main_Search_Sub_UIBP = {
    keyName = "UGC_Main_Search_Sub_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGC_Main_Search_Sub_UIBP",
    path = "/Game/UMG/UI_BP/UGC/UGC_Main_Search_Sub_UIBP.UGC_Main_Search_Sub_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-\233\128\154\231\148\168\231\173\155\233\128\137\233\161\181\233\157\162"
    }
  },
  UGC_PlayPreference_TipsMenu_UIBP = {
    keyName = "UGC_PlayPreference_TipsMenu_UIBP",
    moduleName = "client.slua.umg.ugc.PlayPreference.UGC_PlayPreference_TipsMenu_UIBP",
    path = "/Game/UMG/UI_BP/UGC/PlayPreference/UGC_PlayPreference_TipsMenu_UIBP.UGC_PlayPreference_TipsMenu_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "UGC-\230\184\184\231\142\169\229\129\143\229\165\189-\230\187\161\230\132\143\229\186\166\229\188\185\231\170\151"
    }
  },
  UGC_PlayPreference_Setting_Popup_UIBP = {
    keyName = "UGC_PlayPreference_Setting_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.PlayPreference.UGC_PlayPreference_Settings_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/PlayPreference/Popup/UGC_PlayPreference_Settings_Popup_UIBP.UGC_PlayPreference_Settings_Popup_UIBP",
    asy = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "UGC-\230\184\184\231\142\169\229\129\143\229\165\189-\232\174\190\231\189\174"
    }
  },
  UGC_RecommendFilter_Tag = {
    keyName = "UGC_RecommendFilter_Tag",
    moduleName = "client.slua.umg.ugc.PlayPreference.UGC_RecommendFilter_Tag",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_SelectTag_Popup_UIBP.UGC_SelectTag_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\229\129\143\229\165\189\232\174\190\231\189\174-\230\160\135\231\173\190\232\174\190\231\189\174"
    }
  },
  UGC_Recommend_FavorMap_Popup_UIBP = {
    keyName = "UGC_Recommend_FavorMap_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.PlayPreference.UGC_Recommend_FavorMap_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/PlayPreference/Popup/UGC_PlayPreference_FavoriteMap_Popup_UIBP.UGC_PlayPreference_FavoriteMap_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    asy = true,
    uiStat = {
      name = "UGC-\229\129\143\229\165\189\232\174\190\231\189\174-\229\150\156\231\136\177\229\156\176\229\155\190\229\188\185\231\170\151"
    }
  },
  UGC_Recommend_SearchAddFavor_Popup_UIBP = {
    keyName = "UGC_Recommend_SearchAddFavor_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.PlayPreference.UGC_Recommend_SearchAddFavor_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CollectionList/UGC_CollectionAdd_Popup_UIBP.UGC_CollectionAdd_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "UGC-\229\129\143\229\165\189\232\174\190\231\189\174-\229\150\156\231\136\177\229\156\176\229\155\190\230\144\156\231\180\162\230\183\187\229\138\160\229\188\185\231\170\151"
    }
  },
  UGC_Inventory_UIBP = {
    keyName = "UGC_Inventory_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGCInventory.UGC_Inventory_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Store/UGC_Inventory_UIBP.UGC_Inventory_UIBP",
    useBatchOptimization = true,
    jumpModuleID = BP_ENUM_MODULE_UGC_DEPOT,
    uiStat = {name = "UGC-\228\187\147\229\186\147"}
  },
  UGC_Center_Wallet = {
    keyName = "UGC_Center_Wallet",
    moduleName = "client.slua.umg.ugc.Commercialization.UGC_Center_Wallet",
    path = "/Game/UMG/UI_BP/UGC/Commercialization/UGC_Lobby_Commercialization_Wallet_UIBP.UGC_Lobby_Commercialization_Wallet_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\229\136\155\228\189\156\233\146\177\229\140\133\233\161\181\231\173\190"
    }
  },
  UGC_AuthorHome_TagEdit_UIBP = {
    keyName = "UGC_AuthorHome_TagEdit_UIBP",
    moduleName = "client.slua.umg.ugc.AuthorHome.popup.UGC_AuthorHome_TagEdit_UIBP",
    path = "/Game/UMG/UI_BP/RoleInfo/Popup/RoleInfo_Popup_CardLabel_UIBP.RoleInfo_Popup_CardLabel_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\136\155\228\189\156\232\128\133\228\184\187\233\161\181-\228\184\187\233\161\181-\230\160\135\231\173\190\231\188\150\232\190\145\229\188\185\231\170\151"
    }
  },
  UGC_Author_Homepage_Signature_Popup_UIBP = {
    keyName = "UGC_Author_Homepage_Signature_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.AuthorHome.popup.UGC_Author_Homepage_Signature_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Author_Homepage_Signature_Popup_UIBP.UGC_Author_Homepage_Signature_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\136\155\228\189\156\232\128\133\228\184\187\233\161\181-\228\184\187\233\161\181-\228\184\170\231\173\190\231\188\150\232\190\145\229\188\185\231\170\151"
    }
  },
  UGC_Author_EditHonourWall_Popup_UIBP = {
    keyName = "UGC_Author_EditHonourWall_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.AuthorHome.popup.UGC_Author_EditHonourWall_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Author_EditHonourWall_Popup_UIBP.UGC_Author_EditHonourWall_Popup_UIBP",
    uiStat = {
      name = "\229\136\155\228\189\156\232\128\133\228\184\187\233\161\181-\228\184\187\233\161\181-\232\141\163\232\170\137\229\162\153\231\188\150\232\190\145\229\188\185\231\170\151"
    }
  },
  UGC_Author_Homepage_EditorialWall_Popup_UIBP = {
    keyName = "UGC_Author_Homepage_EditorialWall_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.AuthorHome.popup.UGC_Author_Homepage_EditorialWall_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Author_Homepage_EditorialWall_Popup_UIBP.UGC_Author_Homepage_EditorialWall_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\136\155\228\189\156\232\128\133\228\184\187\233\161\181-\228\184\187\233\161\181-\228\189\156\229\147\129\229\162\153\231\188\150\232\190\145\229\188\185\231\170\151"
    }
  },
  UGC_Mine_Creative_Homepage_UIBP = {
    keyName = "UGC_Mine_Creative_Homepage_UIBP",
    moduleName = "client.slua.umg.ugc.AuthorHome.UGC_Mine_Creative_Homepage_UIBP",
    path = "/Game/UMG/UI_BP/UGC/UGC_Mine_Creative_Homepage_UIBP.UGC_Mine_Creative_Homepage_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\229\136\155\228\189\156\232\128\133\228\184\187\233\161\181"
    }
  },
  UGC_AuthorHomePage = {
    keyName = "UGC_AuthorHomePage",
    moduleName = "client.slua.umg.ugc.AuthorHome.UGC_AuthorHomePage",
    path = "/Game/UMG/UI_BP/UGC/UGC_Author_Homepage_Content_UIBP.UGC_Author_Homepage_Content_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\136\155\228\189\156\232\128\133\228\184\187\233\161\181-\228\184\187\233\161\181"
    }
  },
  UGC_AuthorModPage = {
    keyName = "UGC_AuthorModPage",
    moduleName = "client.slua.umg.ugc.AuthorHome.UGC_AuthorModPage",
    path = "/Game/UMG/UI_BP/UGC/UGC_Author_Homepage_Map_UIBP.UGC_Author_Homepage_Map_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\136\155\228\189\156\232\128\133\228\184\187\233\161\181-\228\189\156\229\147\129"
    }
  },
  UGC_HonorDetail_Popup_UIBP = {
    keyName = "UGC_HonorDetail_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.AuthorHome.popup.UGC_HonorDetail_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Author_View_Honor_Details_Popup_UIBP.UGC_Author_View_Honor_Details_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\136\155\228\189\156\232\128\133\228\184\187\233\161\181-\232\141\163\232\170\137-\232\141\163\232\170\137\232\175\166\230\131\133\233\161\181"
    }
  },
  UGC_AuthorHomeSkinUI = {
    keyName = "UGC_AuthorHomeSkinUI",
    moduleName = "client.slua.umg.ugc.AuthorHome.UGC_AuthorHomeSkinUI",
    path = "/Game/UMG/UI_BP/UGC/UGC_Author_HomeSkin_UIBP.UGC_Author_HomeSkin_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\136\155\228\189\156\232\128\133\228\184\187\233\161\181-\228\184\187\233\161\181-\228\184\187\233\161\181\231\154\174\232\130\164"
    }
  },
  UGC_Center_ActiveMotivation = {
    keyName = "UGC_Center_ActiveMotivation",
    moduleName = "client.slua.umg.ugc.Commercialization.UGC_Center_ActiveMotivation",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_IncentivePlan_Entrance_UIBP.UGC_Center_IncentivePlan_Entrance_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\230\180\187\232\183\131\230\191\128\229\138\177\233\161\181\231\173\190"
    }
  },
  UGC_Event_Theme_UIBP = {
    keyName = "UGC_Event_Theme_UIBP",
    moduleName = "client.slua.umg.ugc.SeasonTemplate.UGC_Event_Theme_UIBP",
    path = "/Game/UMG/UI_BP/UGC/EventActivityCenter/UGC_Event_Theme_UIBP.UGC_Event_Theme_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\230\180\187\229\138\168\228\184\173\229\191\131-\232\181\155\228\186\139\230\180\187\229\138\168"
    }
  },
  UGC_SeasonTemplate_UIBP = {
    keyName = "UGC_SeasonTemplate_UIBP",
    moduleName = "client.slua.umg.ugc.SeasonTemplate.UGC_SeasonTemplate_UIBP",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/New_UGC_LeaderboardList_UIBP.New_UGC_LeaderboardList_UIBP",
    asy = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "UGC-\232\181\155\228\186\139\230\168\161\230\157\191"
    }
  },
  UGC_SeasonTemplate_Main = {
    keyName = "UGC_SeasonTemplate_Main",
    moduleName = "client.slua.umg.ugc.SeasonTemplate.UGC_SeasonTemplate_Main",
    path = "/Game/UMG/UI_BP/UGC/EventActivityCenter/UGC_Event_CreationCompetition_UIBP.UGC_Event_CreationCompetition_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\232\181\155\228\186\139\230\168\161\230\157\191-\229\165\150\229\138\177_\232\167\132\229\136\153\233\161\181"
    }
  },
  UGC_SeasonTemplate_Mod = {
    keyName = "UGC_SeasonTemplate_Mod",
    moduleName = "client.slua.umg.ugc.SeasonTemplate.UGC_SeasonTemplate_Mod",
    path = "/Game/UMG/UI_BP/UGC/EventActivityCenter/UGC_Event_Entries_UIBP.UGC_Event_Entries_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\232\181\155\228\186\139\230\168\161\230\157\191-\230\136\145\231\154\132\229\143\130\232\181\155\228\189\156\229\147\129"
    }
  },
  UGC_EventSelect_Submit_Popup_UIBP = {
    keyName = "UGC_EventSelect_Submit_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.SeasonTemplate.Popup.UGC_EventSelect_Submit_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/EventActivityCenter/Popup/UGC_EventSelect_Submit_Popup_UIBP.UGC_EventSelect_Submit_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "UGC-\232\181\155\228\186\139\230\168\161\230\157\191-\230\136\145\231\154\132\229\143\130\232\181\155\228\189\156\229\147\129-\230\143\144\228\186\164\233\147\190\230\142\165\229\188\185\231\170\151"
    }
  },
  UGC_SeasonTemplate_AllMod = {
    keyName = "UGC_SeasonTemplate_AllMod",
    moduleName = "client.slua.umg.ugc.SeasonTemplate.UGC_SeasonTemplate_AllMod",
    path = "/Game/UMG/UI_BP/UGC/EventActivityCenter/UGC_Event_Entries_UIBP.UGC_Event_Entries_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\232\181\155\228\186\139\230\168\161\230\157\191-\230\137\128\230\156\137\229\143\130\232\181\155\228\189\156\229\147\129"
    }
  },
  UGC_SeasonTemplate_AllMod_Prefab = {
    keyName = "UGC_SeasonTemplate_AllMod_Prefab",
    moduleName = "client.slua.umg.ugc.SeasonTemplate.UGC_SeasonTemplate_AllMod_Prefab",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/PrefabShop_Match_Works_UIBP.PrefabShop_Match_Works_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\232\181\155\228\186\139\230\168\161\230\157\191-\231\187\132\228\187\182\232\181\155\230\137\128\230\156\137\229\143\130\232\181\155\228\189\156\229\147\129"
    }
  },
  UGC_SeasonTag_Popup_UIBP = {
    keyName = "UGC_SeasonTag_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.SeasonTemplate.Popup.UGC_SeasonTag_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/EventActivityCenter/Popup/UGC_EventSelect_Popup_UIBP.UGC_EventSelect_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "UGC-\232\181\155\228\186\139\230\160\135\231\173\190\233\128\137\230\139\169\229\188\185\231\170\151"
    }
  },
  UGC_Inventory_EffectSkin_Item_UIBP = {
    keyName = "UGC_Inventory_EffectSkin_Item_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGCInventory.UGC_Inventory_EffectSkin_Item_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.item_pool,
    {
      name = "\231\137\185\230\149\136\231\154\174\232\130\164"
    }
  },
  UGC_Inventory_UpInRoomEffect_Item_UIBP = {
    keyName = "UGC_Inventory_UpInRoomEffect_Item_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGCInventory.UGC_Inventory_UpInRoomEffect_Item_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.item_pool,
    {
      name = "\229\133\165\230\136\191\231\137\185\230\149\136"
    }
  },
  UGC_Assistant_Main_UIBP = {
    keyName = "UGC_Assistant_Main_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Assistant_Main",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/UGC_CreativeAssistant_Main_UIBP.UGC_CreativeAssistant_Main_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    asy = true,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139"
    }
  },
  UGC_Assistant_GuideEntrance_Sub_UIBP = {
    keyName = "UGC_Assistant_GuideEntrance_Sub_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Assistant_GuideEntrance",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/UGC_CreativeAssistant_GuideEntrance_Sub_UIBP.UGC_CreativeAssistant_GuideEntrance_Sub_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-\229\136\155\228\189\156\230\140\135\229\188\149"
    }
  },
  UGC_Assistant_Copilot_Sub_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Assistant_Copilot",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/SmartAssistant_Main_UIBP.SmartAssistant_Main_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot"
    }
  },
  UGC_Assistant_Copilot_QuickCardItem = {
    keyName = "UGC_Assistant_Copilot_QuickCardItem",
    moduleName = "client.slua.umg.ugc.creator.center.CopilotItems.UGC_Assistant_Copilot_TopicCardItem",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_SmartAssistant_NewTopicItem_UIBP.UGC_SmartAssistant_NewTopicItem_UIBP",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC_Assistant_Copilot_QuickCardItem"
    }
  },
  UGC_Assistant_Copilot_Sub_TextBlock_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_TextBlock_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_TextBlock_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Copilot_TextBlock.UGC_Copilot_TextBlock",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-TextBlock"
    }
  },
  UGC_Assistant_Copilot_Sub_BlockyEdit_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_BlockyEdit_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_BlockyEdit_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Copilot_BlockyEdit.UGC_Copilot_BlockyEdit",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-BlockyEdit"
    }
  },
  UGC_Assistant_Copilot_Sub_InGen_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_InGen_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_InGen_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_Loading02_UIBP.UGC_Smart_Assistant_Loading02_UIBP",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-InGen"
    }
  },
  UGC_Assistant_Copilot_Sub_System_TextBlock_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_System_TextBlock_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_System_TextBlock_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Copilot_SysMsg_TextBlock.UGC_Copilot_SysMsg_TextBlock",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-SystemTextBlock"
    }
  },
  UGC_Assistant_Copilot_Sub_Image_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_Image_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_Image_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Copilot_ImageBlock.UGC_Copilot_ImageBlock",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-ImageBlock"
    }
  },
  UGC_Assistant_Copilot_Sub_UserRefImage_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_UserRefImage_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_UserRefImage_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Copilot_UserRefImage.UGC_Copilot_UserRefImage",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-UserRefImage"
    }
  },
  UGC_Assistant_Copilot_Loading_UIBP = {
    keyName = "UGC_Assistant_Copilot_Loading_UIBP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_Loading_UIBP.UGC_Smart_Assistant_Loading_UIBP",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-ImageBlock"
    }
  },
  UGC_Assistant_Copilot_CodeBlock_UIBP = {
    keyName = "UGC_Assistant_Copilot_CodeBlock_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_CodeBlock_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Copilot_CodeBLock.UGC_Copilot_CodeBlock",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-CodeBlock"
    }
  },
  UGC_Assistant_Copilot_Censor_Failed_UIBP = {
    keyName = "UGC_Assistant_Copilot_Censor_Failed_UIBP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_WarningBubbles_Item_UIBP.UGC_Smart_Assistant_WarningBubbles_Item_UIBP",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-\230\150\135\230\156\172\229\174\161\230\160\184\228\184\141\233\128\154\232\191\135"
    }
  },
  UGC_Assistant_Copilot_Sub_Questions_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_Questions_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_Questions_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Copilot_Questions.UGC_Copilot_Questions",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-Questions"
    }
  },
  UGC_Assistant_Copilot_Sub_QuestionItem_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_QuestionItem_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_QuestionItem_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Copilot_Question.UGC_Copilot_Question",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-Question-Item"
    }
  },
  UGC_Assistant_Copilot_Sub_Citations_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_Citations_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_Citations_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Copilot_Citations.UGC_Copilot_Citations",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-Citations"
    }
  },
  UGC_Assistant_Copilot_Sub_CitationItem_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_CitationItem_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_CitationItem_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Copilot_Citation.UGC_Copilot_Citation",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-Citation-Item"
    }
  },
  UGC_Assistant_Copilot_Sub_ModGen_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_ModGen_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_ModGen_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_Place_Item_UIBP.UGC_Smart_Assistant_Place_Item_UIBP",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-Citation-Item"
    }
  },
  UGC_Assistant_Copilot_Gen_Pre_Check = {
    keyName = "UGC_Assistant_Copilot_Gen_Pre_Check",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Gen_Pre_Check",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_Place_Item_UIBP.UGC_Smart_Assistant_Place_Item_UIBP",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-Citation-Item"
    }
  },
  UGC_Assistant_Copilot_Sub_AnimGen_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_AnimGen_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_AnimGen_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_AnimationBubble_UIBP.UGC_Smart_Assistant_AnimationBubble_UIBP",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      ame = "UGC-\229\176\143\229\138\169\230\137\139-Copilot-Citation-Item"
    }
  },
  UGC_Assistant_Copilot_Sub_FullScreenAnim_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_FullScreenAnim_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_FullScreenAnim_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_Full_AnimationViwer_UIBP.UGC_Smart_Assistant_Full_AnimationViwer_UIBP",
    asy = true,
    isMainUI = true,
    isSingleton = true,
    containerName = UIContainers.Top,
    uiStat = {
      ame = "UGC_Assistant_Copilot_Sub_FullScreenAnim_UIBP"
    }
  },
  UGC_Assistant_Copilot_VideoPreview_UIBP = {
    keyName = "UGC_Assistant_Copilot_VideoPreview_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Assistant_VideoPreview",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_Image_Upload_UIBP.UGC_Smart_Assistant_Image_Upload_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-Copilot-VideoPreview"
    }
  },
  UGC_Assistant_Copilot_ModelPreview_UIBP = {
    keyName = "UGC_Assistant_Copilot_ModelPreview_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_ModelPreview_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_Full_ModelViwer_UIBP.UGC_Smart_Assistant_Full_ModelViwer_UIBP",
    asy = true,
    isMainUI = true,
    isSingleton = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "UGC-Copilot-ModelPreview"
    }
  },
  UGC_Assistant_Copilot_Sub_Think_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_Think_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_Think_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_Think_Progress_Item_UIBP.UGC_Smart_Assistant_Think_Progress_Item_UIBP",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC_Assistant_Copilot_Sub_Think_UIBP"
    }
  },
  UGC_Assistant_Copilot_Sub_CheckAsset_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_CheckAsset_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_CheckAsset_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_CheckAsset_UIBP.UGC_Smart_Assistant_CheckAsset_UIBP",
    asy = true,
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-small assistant-CheckAsset"
    }
  },
  UGC_Assistant_Copilot_Sub_CheckAsset_Row_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_CheckAsset_Row_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_CheckAsset_Row_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_CheckAsset_Row_UIBP.UGC_Smart_Assistant_CheckAsset_Row_UIBP",
    asy = true,
    isMainUI = false,
    isSingleton = false
  },
  UGC_Assistant_Copilot_Sub_CheckAsset_Item_UIBP = {
    keyName = "UGC_Assistant_Copilot_Sub_CheckAsset_Item_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.CopilotSubItem.UGC_Assistant_Copilot_Sub_CheckAsset_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_CheckAsset_Item_UIBP.UGC_Smart_Assistant_CheckAsset_Item_UIBP",
    asy = true,
    isMainUI = false,
    isSingleton = false
  },
  UGC_ResourceDetail_Animation_UIBP = {
    keyName = "UGC_ResourceDetail_Animation_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.DetailPanel.UGC_ResourceDetail_Animation_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_ResourceDetail_Animation_UIBP.UGC_ResourceDetail_Animation_UIBP",
    asy = true,
    isMainUI = true,
    isSingleton = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "UGC_ResourceDetail_Animation_UIBP"
    }
  },
  UGC_ResourceDetail_FullScreenAnim_UIBP = {
    keyName = "UGC_ResourceDetail_FullScreenAnim_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.DetailPanel.UGC_ResourceDetail_FullScreenAnim_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_Full_AnimationViwer_UIBP.UGC_Smart_Assistant_Full_AnimationViwer_UIBP",
    asy = true,
    isMainUI = true,
    isSingleton = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "UGC_ResourceDetail_FullScreenAnim_UIBP"
    }
  },
  UGC_Lobby_Balance_Popup_UIBP = {
    keyName = "UGC_Lobby_Balance_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.Commercialization.UGC_Lobby_Balance_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Commercialization/Popup/UGC_Lobby_Balance_Popup_UIBP.UGC_Lobby_Balance_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\233\146\177\229\140\133-\230\143\144\231\142\176\229\188\185\231\170\151"
    }
  },
  UGC_Center_Gamelet_Container_UIBP = {
    keyName = "UGC_Center_Gamelet_Container_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Gamelet_Container",
    path = "/Game/UMG/UI_BP/UGC/Center/GameletContainer/UGC_Center_Gamelet_Container_UIBP.UGC_Center_Gamelet_Container_UIBP",
    asy = true,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\229\176\143\229\186\148\231\148\168\229\174\185\229\153\168"
    }
  },
  UGC_Main_Lobby_NewMap_TrafficPool_UIBP = {
    keyName = "UGC_Main_Lobby_NewMap_TrafficPool_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGCNewMap.UGC_Main_Lobby_NewMap_TrafficPool_UIBP",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/New_UGC_Main_Lobby_NewMap02_UIBP.New_UGC_Main_Lobby_NewMap02_UIBP",
    isMainUI = false,
    uiStat = {
      name = "UGC-\230\150\176\231\137\136\229\164\167\229\142\133-400\231\137\136\230\156\172\230\150\176\229\155\190\233\161\181\231\173\190"
    }
  },
  UGC_Beginner_Level_UIBP = {
    keyName = "UGC_Beginner_Level_UIBP",
    moduleName = "client.slua.umg.ugc.creator.UGC_Beginner_Level_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Beginner_Level_UIBP.UGC_Beginner_Level_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UGC_BEGINNER_LEVEL,
    asy = true,
    uiStat = {
      name = "UGC-\228\189\156\232\128\133\230\157\131\233\153\144\232\174\164\232\175\129-\230\150\176\230\137\139\229\133\179\229\141\161"
    }
  },
  UGC_Beginner_Level_NEW_UIBP = {
    keyName = "UGC_Beginner_Level_NEW_UIBP",
    moduleName = "client.slua.umg.ugc.creator.UGC_Beginner_Level_NEW_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_BeginnerLevel_UIBP.UGC_BeginnerLevel_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\228\189\156\232\128\133\230\157\131\233\153\144\232\174\164\232\175\129-\230\150\176\230\137\139\229\133\179\229\141\161-new"
    }
  },
  UGC_ColdBoot_Popup_UIBP = {
    keyName = "UGC_ColdBoot_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_ColdBoot_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_IncreasePopularity_Popup_UIBP.UGC_IncreasePopularity_Popup_UIBP",
    asy = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "UGC-\229\134\183\229\144\175\229\138\168\229\188\185\231\170\151"
    }
  },
  WOW_Team_Invite_Tip_UIBP = {
    keyName = "WOW_Team_Invite_Tip_UIBP",
    moduleName = "client.slua.umg.teamup.WOW_Team_Invite_Tip_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/UGC_PlayerInvite_Tip_UIBP.UGC_PlayerInvite_Tip_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "WOW-\233\130\128\232\175\183\231\187\132\233\152\159\230\181\174\231\170\151"
    }
  },
  UGCMatchRoom_InviteTip = {
    keyName = "UGCMatchRoom_InviteTip",
    moduleName = "client.slua.umg.ugc.lobby.UGCMatchRoom.UGCMatchRoom_InviteTip",
    path = "/Game/UMG/UI_BP/Universal_Popup/UGC_PlayerInvite_Tip_UIBP.UGC_PlayerInvite_Tip_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "UGC\230\153\186\232\131\189\229\188\128\229\177\128\230\181\129\231\168\139-\228\189\156\229\147\129\229\164\167\229\142\133\233\130\128\232\175\183"
    }
  },
  UGC_SharingGift_Popup_UIBP = {
    keyName = "UGC_SharingGift_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.creator.personal.UGC_SharingGift_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_SharingGift_Popup_UIBP.UGC_SharingGift_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\228\189\156\229\147\129\229\136\134\228\186\171\232\181\139\232\131\189-\229\136\134\228\186\171\231\164\188\229\188\185\231\170\151"
    }
  },
  CreativeModePrefabMallMainUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallMainUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/CreativeMode_PrefabShop_Main_UIBP.CreativeMode_PrefabShop_Main_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallMainUI"
    },
    asy = true,
    isMainUI = true,
    closeOnHide = false
  },
  CreativeModePrefabMallOfficalTabUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallOfficalTabUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/PrefabShop_Stats_UIBP.PrefabShop_Stats_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallOfficalTabUI"
    },
    asy = true,
    isMainUI = false,
    closeOnHide = false
  },
  CreativeModePrefabMallCollectionTabUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallCollectionTabUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/PrefabShop_Stats_UIBP.PrefabShop_Stats_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallCollectionTabUI"
    },
    asy = true,
    isMainUI = false,
    closeOnHide = false
  },
  CreativeModePrefabMallPrefabTabUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallPrefabTabUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/PrefabShop_PrefabTab_UIBP.PrefabShop_PrefabTab_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallPrefabTabUI"
    },
    asy = true,
    isMainUI = false,
    closeOnHide = false
  },
  CreativeModePrefabMallCodeShopUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallCodeShopUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/PrefabShop_PrefabTab_UIBP.PrefabShop_PrefabTab_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallCodeShopUI"
    },
    asy = true,
    isMainUI = false,
    closeOnHide = false
  },
  CreativeModePrefabMallAnimShopUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallAnimShopUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/PrefabShop_PrefabTab_UIBP.PrefabShop_PrefabTab_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallAnimShopUI"
    },
    asy = true,
    isMainUI = false,
    closeOnHide = false
  },
  CreativeModePrefabMallSoundShopUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallSoundShopUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/PrefabShop_PrefabTab_UIBP.PrefabShop_PrefabTab_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallSoundShopUI"
    },
    asy = true,
    isMainUI = false,
    closeOnHide = false
  },
  CreativeModePrefabMallImageShopUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallImageShopUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/PrefabShop_PrefabTab_UIBP.PrefabShop_PrefabTab_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallImageShopUI"
    },
    asy = true,
    isMainUI = false,
    closeOnHide = false
  },
  CreativeModePrefabMallCustomUIShopUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallCustomUIShopUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/PrefabShop_PrefabTab_UIBP.PrefabShop_PrefabTab_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallCustomUIShopUI"
    },
    asy = true,
    isMainUI = false,
    closeOnHide = false
  },
  CreativeModePrefabMallCollectionPopUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.Pop.CreativeModePrefabMallCollectionPopUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/Popup/PrefabShop_Item_Popup_UIBP.PrefabShop_Item_Popup_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallCollectionPopUI"
    },
    isMainUI = true,
    asy = true
  },
  CreativeModePrefabMallSelectTagPopUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.Pop.CreativeModePrefabMallSelectTagPopUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/Popup/PrefabShop_Tag_Popup_UIBP.PrefabShop_Tag_Popup_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallSelectTagPopUI"
    },
    isMainUI = true,
    asy = true
  },
  CreativeModePrefabMallPublishDetailPopUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.Pop.New.CreativeModePrefabMallPublishDetailPopUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/Popup/PrefabShop_Item_Popup_Tips_UIBP.PrefabShop_Item_Popup_Tips_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallPublishDetailPopUI"
    },
    isMainUI = true,
    asy = true,
    loadFromPool = EUIConfigPoolType.None
  },
  CreativeModePrefabMallPrivateDetailPopUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.Pop.New.CreativeModePrefabMallPrivateDetailPopUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/Popup/PrefabShop_Item_Popup_Tips_UIBP.PrefabShop_Item_Popup_Tips_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallPrivateDetailPopUI"
    },
    isMainUI = true,
    asy = true,
    loadFromPool = EUIConfigPoolType.None
  },
  CreativeModePrefabMallMyShareDetailPopUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.Pop.New.CreativeModePrefabMallMyShareDetailPopUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/Popup/PrefabShop_Item_Popup_Tips_UIBP.PrefabShop_Item_Popup_Tips_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallMyShareDetailPopUI"
    },
    isMainUI = true,
    asy = true,
    loadFromPool = EUIConfigPoolType.None
  },
  CreativeModePrefabMallMyFavoriteDetailPopUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.Pop.New.CreativeModePrefabMallMyFavoriteDetailPopUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/Popup/PrefabShop_Item_Popup_Tips_UIBP.PrefabShop_Item_Popup_Tips_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallMyFavoriteDetailPopUI"
    },
    isMainUI = true,
    asy = true,
    loadFromPool = EUIConfigPoolType.None
  },
  CreativeModePrefabMallPrefabMainUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallPrefabMainUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/PrefabShop_ResourceManage_UIBP.PrefabShop_ResourceManage_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallPrefabMainUI"
    },
    asy = true,
    isMainUI = true,
    closeOnHide = false
  },
  CreativeModePrefabMallItemPreviewUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.Item.CreativeModePrefabMallItemPreviewUI",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_Full_ModelViwer_UIBP.UGC_Smart_Assistant_Full_ModelViwer_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallItemPreviewUI"
    },
    asy = true,
    isMainUI = true,
    isSingleton = true,
    closeOnHide = false
  },
  CreativeModePrefabMallMyShareUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallMyShareUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/PrefabShop_Match_Share_UIBP.PrefabShop_Match_Share_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallMyShareUI"
    },
    asy = true,
    isMainUI = false,
    closeOnHide = false
  },
  CreativeModePrefabMallMyFavoriteUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallMyFavoriteUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/UGC_PrivateRepository_ViewPage_UIBP.UGC_PrivateRepository_ViewPage_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallMyFavoriteUI"
    },
    asy = true,
    isMainUI = false,
    closeOnHide = false
  },
  CreativeModePrefabMallMyPrivateUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallMyPrivateUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/UGC_PrivateRepository_ViewPage_UIBP.UGC_PrivateRepository_ViewPage_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallMyPrivateUI"
    },
    asy = true,
    isMainUI = false,
    closeOnHide = false
  },
  CreativeModePrefabMallUploadPopup = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.Pop.CreativeModePrefabMallUploadPopup",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/Popup/PrefabShop_Upload_Popup_UIBP.PrefabShop_Upload_Popup_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallUploadPopup"
    },
    asy = true,
    isMainUI = true,
    closeOnHide = false
  },
  CreativeModePrefabMallUploadConfirmPopup = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.Pop.CreativeModePrefabMallUploadConfirmPopup",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/Popup/PrefabShop_Upload_Detail_Info_Popup_UIBP.PrefabShop_Upload_Detail_Info_Popup_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallUploadConfirmPopup"
    },
    asy = true,
    isMainUI = true,
    closeOnHide = false
  },
  CreativeModePrefabMallUploadErrorPopup = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.Pop.CreativeModePrefabMallUploadErrorPopup",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/Popup/PrefabShop_Upload_Check_Popup_UIBP.PrefabShop_Upload_Check_Popup_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallUploadErrorPopup"
    },
    asy = true,
    isMainUI = true,
    closeOnHide = false
  },
  CreativeModePrefabMallGuestShareUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallGuestShareUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/PrefabShop_Match_Share_Main_UIBP.PrefabShop_Match_Share_Main_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallGuestShareUI"
    },
    asy = true,
    isMainUI = true,
    closeOnHide = false
  },
  CreativeModePrefabMallSearchUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallSearchUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/PrefabShop_SearchPage_UIBP.PrefabShop_SearchPage_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallSearchUI"
    },
    asy = true,
    isMainUI = true,
    closeOnHide = false
  },
  CreativeModePrefabMallPriorLoadUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallPriorLoadUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/PrefabShop_MultiSelect_UIBP.PrefabShop_MultiSelect_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallPriorLoadUI"
    },
    asy = true,
    isMainUI = true,
    closeOnHide = false
  },
  CreativeModePrefabMallBatchDeletionUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.CreativeModePrefabMallBatchDeletionUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/PrefabShop_MultiSelect_UIBP.PrefabShop_MultiSelect_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallBatchDeletionUI"
    },
    asy = true,
    isMainUI = true,
    closeOnHide = false
  },
  CreativeModePrefabMallPrivateModifyPopUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.Pop.New.CreativeModePrefabMallPrivateModifyPopUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/Popup/PrefabShop_EditInfo_Popup_UIBP.PrefabShop_EditInfo_Popup_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallPrivateModifyPopUI"
    },
    isMainUI = true,
    asy = true,
    loadFromPool = EUIConfigPoolType.None
  },
  CreativeModePrefabMallStaticMeshPreviewUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.Item.CreativeModePrefabMallStaticMeshPreviewUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/Item/PrefabShop_StaticMeshPreview_Item_UIBP.PrefabShop_StaticMeshPreview_Item_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallStaticMeshPreviewUI"
    },
    isMainUI = true,
    asy = true,
    containerName = UIContainers.Top
  },
  CreativeModePrefabMallSoundPreviewUI = {
    moduleName = "client.slua.umg.ugc.lobby.UGCPrefabMall.Item.CreativeModePrefabMallSoundPreviewUI",
    path = "/Game/UMG/UI_BP/UGC/PrefabShop/Item/PrefabShop_AudioPreview_Item_UIBP.PrefabShop_AudioPreview_Item_UIBP",
    uiStat = {
      name = "CreativeModePrefabMallSoundPreviewUI"
    },
    isMainUI = true,
    asy = true,
    isSingleton = true,
    containerName = UIContainers.Top
  },
  WoW_CommonEnterRoomTips_UIBP = {
    keyName = "WoW_CommonEnterRoomTips_UIBP",
    moduleName = "client.slua.umg.ugc.WoW_CommonEnterRoomTips_UIBP",
    path = "/Game/UMG/UI_BP/UGC/EnterRoomTips/WoW_CommonEnterRoomTips_UIBP.WoW_CommonEnterRoomTips_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\164\167\229\142\133-\229\133\165\230\136\191\231\137\185\230\149\136\230\181\174\231\170\151"
    }
  },
  UGC_IncentiveRevenue_Tips = {
    keyName = "UGC_IncentiveRevenue_Tips",
    moduleName = "client.slua.umg.ugc.Commercialization.UGC_IncentiveRevenue_Tips",
    path = "/Game/UMG/UI_BP/UGC/Center/Popup/UGC_Center_Award_DataTips_UIBP.UGC_Center_Award_DataTips_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\191\128\229\138\177\232\174\161\229\136\146tips"
    }
  },
  WOWTeamPlatform_UIBP = {
    keyName = "WOWTeamPlatform_UIBP",
    moduleName = "client.slua.umg.teamup.WoWTeamPlatform_UIBP",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_WOW/TeamPlatform_Main_UIBP.TeamPlatform_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\187\132\233\152\159\229\164\167\229\142\133-\228\184\187\231\149\140\233\157\162-WOW"
    }
  },
  UGC_Match_Room_Recruit_UIBP = {
    keyName = "UGC_Match_Room_Recruit_UIBP",
    moduleName = "client.slua.umg.teamup.UGC_Match_Room_Recruit_UIBP",
    path = "/Game/UMG/UI_BP/UGC/UGCMapMatchRoom/UGC_Match_Room_Recruit_UIBP.UGC_Match_Room_Recruit_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\187\132\233\152\159\229\164\167\229\142\133-\228\189\156\229\147\129\229\164\167\229\142\133-WOW"
    }
  },
  Championship_India_FloatTips_UIBP = {
    keyName = "Championship_India_FloatTips_UIBP",
    moduleName = "client.slua.umg.tournament.Championship_India_FloatTips_UIBP",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_India_FloatTips_UIBP_NEW.Championship_India_FloatTips_UIBP_NEW",
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\229\137\141\229\190\128\230\160\135\231\173\190"
    }
  },
  Championship_India_Popup01_UIBP = {
    keyName = "Championship_India_Popup01_UIBP",
    moduleName = "client.slua.umg.tournament.Championship_India_Popup01_UIBP",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_India_Popup01_UIBP_NEW.Championship_India_Popup01_UIBP_NEW",
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\230\175\148\232\181\155\229\137\141\232\191\155\229\133\165\230\136\152\230\150\151\229\188\185\231\170\151"
    }
  },
  Championship_India_Popup_UIBP = {
    keyName = "Championship_India_Popup_UIBP",
    moduleName = "client.slua.umg.tournament.Championship_India_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_India_Popup_UIBP_2.Championship_India_Popup_UIBP_2",
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\230\138\165\229\144\141"
    }
  },
  Championship_India_QuickTips_UIBP = {
    keyName = "Championship_India_QuickTips_UIBP",
    moduleName = "client.slua.umg.tournament.Championship_India_QuickTips_UIBP",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_India_QuickTips_UIBP_NEW.Championship_India_QuickTips_UIBP_NEW",
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\230\143\144\231\164\186\230\160\135\231\173\190"
    }
  },
  Common_NewbieGuide_Ban_Masked_UIBP = {
    keyName = "Common_NewbieGuide_Ban_Masked_UIBP",
    moduleName = "client.slua.umg.ugc.newbie.Common_NewbieGuide_Ban_Masked_UIBP",
    path = "/Game/UMG/UI_BP/Common/Newbie/Strong/Common_Newbie_FullScreenBan_UIBP.Common_Newbie_FullScreenBan_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\229\188\149\229\175\188 - \229\133\168\229\177\143\229\177\143\232\148\189"
    },
    isSingleton = true,
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Ban
  },
  Common_NewbieGuide_Bubble_Masked_UIBP = {
    keyName = "Common_NewbieGuide_Bubble_Masked_UIBP",
    moduleName = "client.slua.umg.ugc.newbie.EditMain_Common_NewbieGuide_Bubble_UIBP",
    path = "/Game/UMG/UI_BP/Common/Newbie/Strong/Common_Newbie_Strong_Bubble_UIBP.Common_Newbie_Strong_Bubble_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\229\188\149\229\175\188 - \233\128\154\231\148\168 - \233\171\152\228\186\174\233\128\137\228\184\173 - \233\129\174\231\189\169"
    },
    isSingleton = false,
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Ban
  },
  Common_Tips_Buttom_UIBP = {
    keyName = "Common_Tips_Buttom_UIBP",
    moduleName = "client.slua.umg.ugc.comment.Common_Tips_Buttom_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/Common_Tips_Buttom_UIBP.Common_Tips_Buttom_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\233\128\154\231\148\168-\230\143\144\231\164\186\233\161\181\233\157\162"
    }
  },
  Login_GameplayName_UIBP = {
    keyName = "Login_GameplayName_UIBP",
    moduleName = "client.slua.umg.loading.Login_GameplayName_UIBP",
    path = "/Game/UMG/UI_BP/LoginLoading/Login_GameplayName_UIBP.Login_GameplayName_UIBP",
    closeOnSwitch = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "LoadingUI-UGC-mod"
    }
  },
  Rank_Incentive_main_BP = {
    keyName = "Rank_Incentive_main_BP",
    moduleName = "client.slua.umg.activity.rank_Creativity.Rank_Incentive_main_BP",
    path = "/Game/UMG/UI_BP/UGC/EventActivityCenter/UGC_InnovationReward_RankingList_UIBP.UGC_InnovationReward_RankingList_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\230\191\128\229\138\177\232\174\161\229\136\146\230\142\146\232\161\140\230\166\156"
    }
  },
  New_Rank_Incentive_main_BP = {
    keyName = "New_Rank_Incentive_main_BP",
    moduleName = "client.slua.umg.activity.rank_Creativity.New_Rank_Incentive_main_BP",
    path = "/Game/UMG/UI_BP/UGC/EventActivityCenter/UGC_InnovationReward_RankingList_New_UIBP.UGC_InnovationReward_RankingList_New_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\230\191\128\229\138\177\232\174\161\229\136\146\230\142\146\232\161\140\230\166\156--\230\150\176\231\137\136"
    }
  },
  New_Rank_Incentive_Tips_UI = {
    keyName = "New_Rank_Incentive_Tips_UI",
    moduleName = "client.slua.umg.activity.rank_Creativity.New_Rank_Incentive_Tips_UI",
    path = "/Game/UMG/UI_BP/UGC/EventActivityCenter/Item/UGC_InnovationReward_RankingList_New_Tips_UIBP01.UGC_InnovationReward_RankingList_New_Tips_UIBP01",
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\230\191\128\229\138\177\232\174\161\229\136\146\230\142\146\232\161\140\230\166\156--\230\150\176\231\137\136tips\229\188\185\231\170\151"
    }
  },
  UGCAuthorProgressPopUI = {
    keyName = "UGCAuthorProgressPopUI",
    moduleName = "client.slua.umg.ugc.creator.personal.UGCAuthorProgressPopUI",
    path = "/Game/UMG/UI_BP/UGC/UGC_AuthorProgress_UIBP.UGC_AuthorProgress_UIBP",
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\232\138\130\231\130\185\231\149\140\233\157\162"
    }
  },
  UGCAuthorProgressShareUI = {
    keyName = "UGCAuthorProgressShareUI",
    moduleName = "client.slua.umg.ugc.creator.personal.UGCAuthorProgressShareUI",
    path = "/Game/UMG/UI_BP/UGC/UGC_AuthorProgress_UIBP.UGC_AuthorProgress_UIBP",
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\232\138\130\231\130\185\231\149\140\233\157\162-\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  UGCCommonModItem = {
    keyName = "UGCCommonModItem",
    moduleName = "client.slua.umg.ugc.lobby.UGCCommonModItem",
    path = "/Game/UMG/UI_BP/UGC/Item/UGC_Common_Mod_Item_UIBP.UGC_Common_Mod_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\230\153\174\233\128\154MOD\231\188\169\231\149\165\229\155\190"
    }
  },
  UGCDetailShowCoverPanel = {
    keyName = "UGCDetailShowCoverPanel",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGCDetailShowCoverPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_Detail_ShowCover_UIBP.UGC_Lobby_Detail_ShowCover_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-MOD\232\175\166\230\131\133-\230\159\165\231\156\139\229\176\129\233\157\162"
    }
  },
  UGCMatchRoom_ClearRoom_Popup = {
    keyName = "UGCMatchRoom_ClearRoom_Popup",
    moduleName = "client.slua.umg.ugc.lobby.UGCMatchRoom.UGCMatchRoom_ClearRoom_Popup",
    path = "/Game/UMG/UI_BP/UGC/UGCMapMatchRoom/Popup/UGC_Wow_Pass_Popup_UIBP.UGC_Wow_Pass_Popup_UIBP",
    uiStat = {
      name = "UGC\228\189\156\229\147\129\229\164\167\229\142\133-\230\184\133\231\144\134\228\189\156\229\147\129"
    }
  },
  UGCPubMod_Tip_UIBP = {
    keyName = "UGCPubMod_Tip_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGCPubMod_Tip_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\230\150\176\228\189\156\229\147\129\229\143\145\229\184\131\230\136\144\229\138\159-\232\190\185\231\149\140\230\181\174\231\170\151"
    }
  },
  UGCRecommendModItem = {
    keyName = "UGCRecommendModItem",
    moduleName = "client.slua.umg.ugc.lobby.recommend.UGCRecommendModItem",
    path = "/Game/UMG/UI_BP/UGC/Item/UGC_Common_Mod_Item_UIBP.UGC_Common_Mod_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\230\142\168\232\141\144MOD\231\188\169\231\149\165\229\155\190"
    }
  },
  UGC_AuthorHonorPage = {
    keyName = "UGC_AuthorHonorPage",
    moduleName = "client.slua.umg.ugc.AuthorHome.UGC_AuthorHonorPage",
    path = "/Game/UMG/UI_BP/UGC/UGC_Author_Homepage_Medal_UIBP.UGC_Author_Homepage_Medal_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\136\155\228\189\156\232\128\133\228\184\187\233\161\181-\232\141\163\232\170\137"
    }
  },
  UGC_Center_Guide = {
    keyName = "UGC_Center_Guide",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_Guide",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Explain_UIBP.Common_Popup_Theme_Explain_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\136\155\228\189\156\228\184\173\229\191\131\229\188\149\229\175\188\229\188\185\231\170\151"
    }
  },
  UGC_Center_RewardIncentives = {
    keyName = "UGC_Center_RewardIncentives",
    moduleName = "client.slua.umg.ugc.Commercialization.UGC_Center_RewardIncentives",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_Reward_Incentive_Backstage_Msg_UIBP.UGC_Center_Reward_Incentive_Backstage_Msg_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\229\136\155\228\189\156\228\184\173\229\191\131-\230\137\147\232\181\143\230\191\128\229\138\177\233\161\181\231\173\190"
    }
  },
  UGC_CreatorForum_Guide = {
    keyName = "UGC_CreatorForum_Guide",
    moduleName = "client.slua.umg.ugc.creator.UGC_CreatorForum_Guide",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Explain_UIBP.Common_Popup_Theme_Explain_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\136\155\228\189\156\232\128\133\232\174\186\229\157\155\233\166\150\230\172\161\229\188\185\231\170\151"
    }
  },
  UGC_AiCopilot_Tutorial = {
    keyName = "UGC_CreatorForum_Tutorial",
    moduleName = "client.slua.umg.ugc.creator.UGC_AiCopilot_Tutorial",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Explain_UIBP.Common_Popup_Theme_Explain_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "Ai\229\176\143\229\138\169\230\137\139\229\155\190\230\150\135\230\149\153\231\168\139\229\188\185\231\170\151"
    }
  },
  UGC_AiCopilot_Report = {
    keyName = "UGC_CreatorForum_Tutorial",
    moduleName = "client.slua.umg.ugc.creator.UGC_AiCopilot_Report",
    path = "WidgetBlueprint'/Game/UMG/UI_BP/UGC/CreativeAssistant/Popup/AIAssistantReporting_Popup_UIBP.AIAssistantReporting_Popup_UIBP'",
    containerName = UIContainers.Default,
    zOrder = EFixedZOrder.TopZOrder,
    uiStat = {
      name = "Ai\229\176\143\229\138\169\230\137\139\228\184\190\230\138\165"
    }
  },
  UGC_DownloadRewards_Popup_UIBP = {
    keyName = "UGC_DownloadRewards_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_DownloadRewards_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_DownloadRewards_Popup_UIBP.UGC_DownloadRewards_Popup_UIBP",
    uiStat = {
      name = "UGC-\228\184\139\232\189\189\228\191\161\230\129\175\229\165\150\229\138\177\229\188\185\231\170\151(\230\152\190\231\164\186\229\165\150\229\138\177)"
    }
  },
  UGC_Download_Details_UIBP = {
    keyName = "UGC_Download_Details_UIBP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/UGC/UGC_Download_Map_Style_Two_UIBP.UGC_Download_Map_Style_Two_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.downloadui_pool
  },
  UGC_Download_LoadMapUI_UIBP = {
    keyName = "UGC_Download_LoadMapUI_UIBP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/UGC/UGC_Download_Map_UIBP.UGC_Download_Map_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.downloadui_pool
  },
  UGC_Download_LoadMapUI_UIBP2 = {
    keyName = "UGC_Download_LoadMapUI_UIBP2",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/UGC/UGC_Download_Map_UIBP_2.UGC_Download_Map_UIBP_2",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.downloadui_pool
  },
  UGC_Download_Button_UIBP_New = {
    keyName = "UGC_Download_Button_UIBP_New",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/UGC/UGC_Download_Button_UIBP_2.UGC_Download_Button_UIBP_2",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.downloadui_pool
  },
  UGC_Download_Popup_UIBP = {
    keyName = "UGC_Download_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_Download_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Download_Popup_UIBP.UGC_Download_Popup_UIBP",
    uiStat = {
      name = "UGC-\228\184\139\232\189\189\228\191\161\230\129\175\229\188\185\231\170\151"
    }
  },
  UGC_Download_Update_Popup_UIBP = {
    keyName = "UGC_Download_Update_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_Dowmload_Update_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Download_Popup_UIBP.UGC_Download_Popup_UIBP",
    uiStat = {
      name = "UGC-\228\184\139\232\189\189\228\191\161\230\129\175\229\188\185\231\170\151"
    }
  },
  UGC_Download_TipsMenu_UIBP = {
    keyName = "UGC_Download_TipsMenu_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGC_Download_TipsMenu_UIBP",
    path = "/Game/UMG/UI_BP/UGC/UGC_Download_TipsMenu_UIBP.UGC_Download_TipsMenu_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\228\184\139\232\189\189\228\191\161\230\129\175\229\165\150\229\138\177tips"
    }
  },
  UGC_EditAICoverImage_UIBP = {
    keyName = "UGC_EditAICoverImage_UIBP",
    moduleName = "client.slua.umg.ugc.creator.personal.UGC_EditAICoverImage_UIBP",
    path = "/Game/UMG/UI_BP/UGC/UGC_EditAICoverPanel_UIBP.UGC_EditAICoverPanel_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UGC_AICOVER,
    asy = true,
    uiStat = {
      name = "AI\229\176\129\233\157\162\229\155\190"
    }
  },
  UGC_FaceSlap_Popup_UIBP = {
    keyName = "UGC_FaceSlap_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_FaceSlap_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Explain_UIBP.Common_Popup_Theme_Explain_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\229\165\150\229\138\177\229\177\149\231\164\186\229\188\185\231\170\151"
    }
  },
  UGC_HotRank_Detail_ModItem = {
    keyName = "UGC_HotRank_Detail_ModItem",
    moduleName = "client.slua.umg.ugc.lobby.HotRank.UGC_HotRank_Detail_ModItem",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/Item/New_UGC_Common_Mod_Item_UIBP.New_UGC_Common_Mod_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "UGC\231\131\173\231\142\169\230\142\146\232\161\140\230\166\156moditem"
    }
  },
  UGC_IncentiveRevenue_Guide = {
    keyName = "UGC_IncentiveRevenue_Guide",
    moduleName = "client.slua.umg.ugc.creator.UGC_IncentiveRevenue_Guide",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Explain_UIBP.Common_Popup_Theme_Explain_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\191\128\229\138\177\232\174\161\229\136\146\230\139\141\232\132\184\229\155\190"
    }
  },
  UGC_IncentiveRevenue_AuthorReward_Guide = {
    keyName = "UGC_IncentiveRevenue_AuthorReward_Guide",
    moduleName = "client.slua.umg.ugc.creator.UGC_IncentiveRevenue_AuthorReward_Guide",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Welfare_UIBP1.Common_Popup_Theme_Welfare_UIBP1",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\191\128\229\138\177\232\174\161\229\136\146\230\150\176\228\186\186\228\189\156\232\128\133\229\165\150\229\138\177\230\139\141\232\132\184\229\155\190"
    }
  },
  UGC_Level_Guide = {
    keyName = "UGC_Level_Guide",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Level_Guide",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Explain_UIBP.Common_Popup_Theme_Explain_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\229\136\155\228\189\156\228\184\173\229\191\131-\229\136\155\228\189\156\232\128\133\231\173\137\231\186\167-\229\188\149\229\175\188\229\188\185\231\170\151"
    }
  },
  UGC_Main_Lobby_LeaderboardSeason_History_UIBP = {
    keyName = "UGC_Main_Lobby_LeaderboardSeason_History_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGCLeaderboardSeason.UGC_Main_Lobby_LeaderboardSeason_History_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Challenge/UGC_Challenge_History_UIBP.UGC_Challenge_History_UIBP",
    isMainUI = true,
    uiStat = {
      name = "UGC-\230\150\176\231\137\136\229\164\167\229\142\133-380\230\140\145\230\136\152\233\161\181 - \229\142\134\229\143\178\228\189\156\229\147\129"
    }
  },
  UGC_Main_Lobby_LeaderboardSeason_UIBP = {
    keyName = "UGC_Main_Lobby_LeaderboardSeason_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGCLeaderboardSeason.UGC_Main_Lobby_LeaderboardSeason_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Challenge/UGC_Main_Challenge_Sub_UIBP.UGC_Main_Challenge_Sub_UIBP",
    isMainUI = false,
    uiStat = {
      name = "UGC-\230\150\176\231\137\136\229\164\167\229\142\133-380\230\140\145\230\136\152\233\161\181(\230\142\146\232\161\140\230\166\156\229\136\155\230\184\184\229\173\163\239\188\140\233\157\158370\228\188\160\231\187\159\228\187\187\229\138\161\233\169\177\229\138\168\229\136\155\230\184\184\229\173\163)"
    }
  },
  UGC_Main_Lobby_Tournament_UIBP = {
    keyName = "UGC_Main_Lobby_Tournament_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGCSeason.UGC_Main_Lobby_Tournament_UIBP",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/New_UGC_Main_Lobby_Season_UIBP.New_UGC_Main_Lobby_Season_UIBP",
    isMainUI = false,
    uiStat = {
      name = "UGC-\230\150\176\231\137\136\229\164\167\229\142\133-\232\181\155\228\186\139\233\161\181\231\173\190"
    }
  },
  UGC_RankReward_Popup_UIBP = {
    keyName = "UGC_RankReward_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_RankReward_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_RankReward_Popup_UIBP.UGC_RankReward_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "UGC-\228\184\170\228\186\186\230\184\184\231\142\169\230\149\176\230\141\174-\231\173\137\231\186\167\229\165\150\229\138\177"
    }
  },
  UGC_Season_Achievement_UIBP = {
    keyName = "UGC_Season_Achievement_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGC_Season_Achievement_UIBP",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_CreativeSeasonStats_Sub_UIBP.UGC_Lobby_CreativeSeasonStats_Sub_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-WOW\232\181\155\229\173\163\230\136\152\231\187\169\233\161\181"
    }
  },
  UGC_TournamentMod_ThemeAuthor_UIBP = {
    keyName = "UGC_TournamentMod_ThemeAuthor_UIBP",
    moduleName = "client.slua.umg.ugc.ugc_tournament.UGC_TournamentMod_ThemeAuthor_UIBP",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/Item/New_UGC_TopMod_ThemeAuthor_Season_UIBP.New_UGC_TopMod_ThemeAuthor_Season_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\230\150\176-UGC-banner-match\229\146\140author\229\134\133\229\174\185-\232\181\155\228\186\139"
    }
  },
  UGC_WOW_PASS_Award = {
    keyName = "UGC_WOW_PASS_Award",
    moduleName = "client.slua.umg.ugc.lobby.WOWPass.UGC_WOW_PASS_Award",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/UGC_WoWPass_UIBP.UGC_WoWPass_UIBP",
    uiStat = {
      name = "WOW\233\128\154\232\161\140\232\175\129\229\165\150\229\138\177"
    }
  },
  UGC_WOW_PASS_BuyLevel = {
    keyName = "UGC_WOW_PASS_BuyLevel",
    moduleName = "client.slua.umg.ugc.lobby.WOWPass.UGC_WOW_PASS_BuyLevel",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/UGC_WoWPass_BuyLv_UIBP.UGC_WoWPass_BuyLv_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UGC_WOWPASS_BUYLEVEL,
    uiStat = {
      name = "WOW\233\128\154\232\161\140\232\175\129\232\180\173\228\185\176\231\173\137\231\186\167"
    },
    asy = true
  },
  UGC_WOW_PASS_CommentDecoration_UIBP = {
    keyName = "UGC_WOW_PASS_CommentDecoration_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.WOWPass.UGC_WOW_PASS_CommentDecoration_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Store/Item/Inventory_CommentDecoration_Item_UIBP.Inventory_CommentDecoration_Item_UIBP",
    uiStat = {
      name = "WOW\232\175\132\232\174\186\232\163\133\230\137\174"
    },
    isSingleton = false,
    isMainUI = false
  },
  UGC_WOW_PASS_Decorate_UIBP = {
    keyName = "UGC_WOW_PASS_Decorate_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.WOWPass.UGC_WOW_PASS_Decorate_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Store/Item/Inventory_HomepageDecoration_Item_UIBP.Inventory_HomepageDecoration_Item_UIBP",
    uiStat = {
      name = "WOW\232\163\133\230\137\174\231\187\132\228\187\182"
    },
    isSingleton = false,
    isMainUI = false
  },
  UGC_WOW_PASS_MainUI = {
    keyName = "UGC_WOW_PASS_MainUI",
    moduleName = "client.slua.umg.ugc.lobby.WOWPass.UGC_WOW_PASS_MainUI",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/UGC_WoWPass_Lobby_UIBP.UGC_WoWPass_Lobby_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UGC_WOWPass,
    uiStat = {
      name = "WOW\233\128\154\232\161\140\232\175\129\228\184\187\231\149\140\233\157\162"
    }
  },
  UGC_WOW_PASS_Pop_BuyPassGuide = {
    keyName = "UGC_WOW_PASS_Pop_BuyPassGuide",
    moduleName = "client.slua.umg.ugc.lobby.WOWPass.UGC_WOW_PASS_Pop_BuyPassGuide",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/UGC_WoWPass_Popup_UIBP.UGC_WoWPass_Popup_UIBP",
    uiStat = {
      name = "WOW\233\128\154\232\161\140\232\175\129\232\180\173\228\185\176Pass\230\139\141\232\132\184\229\188\149\229\175\188\229\188\185\231\170\151"
    },
    asy = false
  },
  UGC_ThemePlay_ActivityTemplate_FaceSlap_UIBP = {
    keyName = "UGC_ThemePlay_ActivityTemplate_FaceSlap_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.WOWPass.UGC_ThemePlay_ActivityTemplate_FaceSlap_UIBP",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/UGC_WoWPass_Popup_UIBP_01.UGC_WoWPass_Popup_UIBP_01",
    uiStat = {
      name = "\228\184\187\233\162\152\230\184\184\231\142\169\230\180\187\229\138\168\230\168\161\230\157\191\230\139\141\232\132\184\229\155\190"
    }
  },
  UGC_WOW_PASS_Pop_BuySuccess = {
    keyName = "UGC_WOW_PASS_Pop_BuySuccess",
    moduleName = "client.slua.umg.ugc.lobby.WOWPass.UGC_WOW_PASS_Pop_BuySuccess",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/UGC_WoWPass_LevelUp_Unlock_UIBP.UGC_WoWPass_LevelUp_Unlock_UIBP",
    uiStat = {
      name = "WOW\233\128\154\232\161\140\232\175\129\232\180\173\228\185\176Pass\230\136\144\229\138\159\229\188\185\231\170\151"
    },
    asy = true
  },
  UGC_WOW_PASS_Pop_UpLevel = {
    keyName = "UGC_WOW_PASS_Pop_UpLevel",
    moduleName = "client.slua.umg.ugc.lobby.WOWPass.UGC_WOW_PASS_Pop_UpLevel",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/UGC_WoWPass_LevelUp_UIBP.UGC_WoWPass_LevelUp_UIBP",
    uiStat = {
      name = "WOW\233\128\154\232\161\140\232\175\129\232\180\173\228\185\176\231\173\137\231\186\167\230\136\144\229\138\159\229\188\185\231\170\151"
    },
    asy = true
  },
  UGC_WOW_PASS_Privilege_Award_Preview_UIBP = {
    keyName = "UGC_WOW_PASS_Privilege_Award_Preview_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.WOWPass.UGC_WOW_PASS_Privilege_Award_Tab",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/UGC_WOW_PASS_Privilege_AWARD_UIBP.UGC_WOW_PASS_Privilege_AWARD_UIBP",
    uiStat = {
      name = "WOW\233\128\154\232\161\140\232\175\129\231\137\185\230\157\131-\229\165\150\229\138\177\233\162\132\232\167\136\229\136\135\229\141\161"
    },
    asy = true
  },
  UGC_WOW_PASS_Privilege_MainUIBP = {
    keyName = "UGC_WOW_PASS_Privilege_MainUIBP",
    moduleName = "client.slua.umg.ugc.lobby.WOWPass.UGC_WOW_PASS_Privilege_MainUI",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/UGC_WOW_PASS_Privilege_MainUIBP.UGC_WOW_PASS_Privilege_MainUIBP",
    jumpModuleID = BP_ENUM_MODULE_UGC_WOWPASS_PRIVILEGE,
    isSingleton = true,
    isMainUI = true,
    uiStat = {
      name = "WOW\233\128\154\232\161\140\232\175\129\231\137\185\230\157\131\228\184\187\231\149\140\233\157\162"
    }
  },
  UGC_WOW_PASS_Privilege_Success = {
    keyName = "UGC_WOW_PASS_Privilege_Success",
    moduleName = "client.slua.umg.ugc.lobby.WOWPass.UGC_WOW_PASS_Privilege_Success",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/Popup/WoWPass_PrivilegeTips_Popup_Item_UIBP.WoWPass_PrivilegeTips_Popup_Item_UIBP",
    uiStat = {
      name = "WOW\233\128\154\232\161\140\232\175\129\232\180\173\228\185\176Pass\230\136\144\229\138\159\229\165\150\229\138\177\229\188\185\231\170\151"
    },
    asy = true
  },
  UGC_WOW_PASS_Privilege_UIBP = {
    keyName = "UGC_WOW_PASS_Privilege_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.WOWPass.UGC_WOW_PASS_Privilege_Tab",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/UGC_WoWPass_LevelPass_UIBP.UGC_WoWPass_LevelPass_UIBP",
    uiStat = {
      name = "WOW\233\128\154\232\161\140\232\175\129\231\137\185\230\157\131-\231\137\185\230\157\131\229\136\135\229\141\161"
    },
    asy = true
  },
  UGC_WOW_PASS_Rule_PopUp = {
    keyName = "UGC_WOW_PASS_Rule_PopUp",
    moduleName = "client.slua.umg.ugc.lobby.WOWPass.UGC_WOW_PASS_Rule_PopUp",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/Popup/WoWPass_Common_Popup_Item_UIBP.WoWPass_Common_Popup_Item_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "WOW\233\128\154\232\161\140\232\175\129-\232\167\132\229\136\153"
    }
  },
  UGC_WoWPass_BuyTogether_UIBP = {
    keyName = "UGC_WoWPass_BuyTogether_UIBP",
    moduleName = "client.slua.umg.ugc.WoWPass.UGC_WoWPass_BuyTogether_UIBP",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/UGC_WoWPass_BuyTogether_UIBP.UGC_WoWPass_BuyTogether_UIBP",
    uiStat = {
      name = "WOW\233\128\154\232\161\140\232\175\129\229\144\136\228\185\176\231\149\140\233\157\162"
    }
  },
  UGC_WoWPass_Cover_UIBP = {
    keyName = "UGC_WoWPass_Cover_UIBP",
    moduleName = "client.slua.umg.ugc.WoWPass.UGC_WoWPass_Cover_UIBP",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/UGC_WoWPass_Cover_UIBP.UGC_WoWPass_Cover_UIBP",
    uiStat = {
      name = "WOW\233\128\154\232\161\140\232\175\129\229\144\136\228\185\176\230\139\141\232\132\184\231\149\140\233\157\162"
    }
  },
  UGC_WOW_PASS_Task = {
    keyName = "UGC_WOW_PASS_Task",
    moduleName = "client.slua.umg.ugc.lobby.WOWPass.UGC_WOW_PASS_Task",
    path = "/Game/UMG/UI_BP/UGC/WoWPass/UGC_WoWPass_Task_UIBP.UGC_WoWPass_Task_UIBP",
    uiStat = {
      name = "WOW\233\128\154\232\161\140\232\175\129\228\187\187\229\138\161"
    }
  },
  egame_entry = {
    keyName = "egame_entry",
    moduleName = "client.slua.umg.tournament.egame_entry",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_Entrance_Bounty_UIBP.Championship_Entrance_Bounty_UIBP",
    uiStat = {
      name = "\232\181\155\228\186\139-\229\133\165\229\143\163"
    }
  },
  qualifying_match = {
    keyName = "qualifying_match",
    moduleName = "client.slua.umg.tournament.qualifying_match",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_Bounty_UIBP.Championship_Bounty_UIBP",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155-\228\184\187\231\149\140\233\157\162"
    }
  },
  qualifying_rank = {
    keyName = "qualifying_rank",
    moduleName = "client.slua.umg.tournament.qualifying_rank",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_Bounty_Rank_UIBP.Championship_Bounty_Rank_UIBP",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155-\230\142\146\229\144\141"
    }
  },
  qualifying_regist = {
    keyName = "qualifying_regist",
    moduleName = "client.slua.umg.tournament.qualifying_regist",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_Bounty_Register_UIBP.Championship_Bounty_Register_UIBP",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155-\230\179\168\229\134\140"
    }
  },
  qualifying_winner = {
    keyName = "qualifying_winner",
    moduleName = "client.slua.umg.tournament.qualifying_winner",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_Bounty_Winning_name_UIBP.Championship_Bounty_Winning_name_UIBP",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155-\229\144\141\229\141\149"
    }
  },
  tournament_buy_india_ticket = {
    keyName = "tournament_buy_india_ticket",
    moduleName = "client.slua.umg.tournament.tournament_buy_india_ticket",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_India_Buy_IndiaTicket_BP.Championship_India_Buy_IndiaTicket_BP",
    uiStat = {
      name = "\233\148\166\230\160\135\232\181\155-\232\180\173\228\185\176\229\143\130\232\181\155\229\136\184"
    }
  },
  tournament_history_record = {
    keyName = "tournament_history_record",
    moduleName = "client.slua.umg.tournament.tournament_history_record",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_India_NewHistory_UIBP.Championship_India_NewHistory_UIBP",
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\229\142\134\229\143\178\232\174\176\229\189\149"
    }
  },
  tournament_introduce = {
    keyName = "tournament_introduce",
    moduleName = "client.slua.umg.tournament.tournament_introduce",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_India_NewIntroduce_UIBP.Championship_India_NewIntroduce_UIBP",
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\232\181\155\228\186\139\228\187\139\231\187\141"
    }
  },
  tournament_main = {
    keyName = "tournament_main",
    moduleName = "client.slua.umg.tournament.tournament_main",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_India_New_UIBP.Championship_India_New_UIBP",
    jumpModuleID = BP_ENUM_MODULE_TOURNAMENT_MAIN,
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\228\184\187\231\149\140\233\157\162"
    }
  },
  tournament_teamup = {
    keyName = "tournament_teamup",
    moduleName = "client.slua.umg.tournament.tournament_teamup",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_India_Prepare_UIBP.Championship_India_Prepare_UIBP",
    jumpModuleID = BP_ENUM_MODULE_TOURNAMENT_TEAM_UP,
    uiStat = {
      name = "\232\181\143\233\135\145\232\181\155-\231\187\132\233\152\159"
    }
  },
  ugc_mine_edit_coauthor_select = {
    keyName = "ugc_mine_edit_coauthor_select",
    moduleName = "client.slua.umg.ugc.creator.personal.UgcMineEditCoauthorPanel",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Work_Creation_Popup_UIBP.UGC_Work_Creation_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\231\188\150\232\190\145\233\161\181-MOD\231\188\150\232\190\145-\229\133\177\229\136\155\228\189\156\232\128\133\229\188\185\231\170\151"
    }
  },
  ImageTestUI = {
    moduleName = "GameLua.Mod.CreativeBase.Client.ImageTest.ImageTestUI",
    path = "/Game/Mod/CreativeBase/UMG/ImageTest/ImageTestUI.ImageTestUI",
    uiStat = {
      name = "ImageTestUI"
    },
    asy = true,
    isMainUI = false
  },
  ImageClipper = {
    moduleName = "GameLua.Mod.CreativeBase.Client.ImageTest.ImageClipper",
    path = "/Game/UMG/UI_BP/UGC/CustomPhoto/UGC_ImageClipper.UGC_ImageClipper",
    uiStat = {
      name = "ImageClipper"
    },
    asy = true,
    isMainUI = true
  },
  ImageCost = {
    moduleName = "GameLua.Mod.CreativeBase.Client.ImageTest.ImageCost",
    path = "/Game/UMG/UI_BP/UGC/CustomPhoto/UIBP_CustomPohto_Cost.UIBP_CustomPohto_Cost",
    uiStat = {name = "ImageCost"},
    containerName = UIContainers.Top,
    isSingleton = true,
    asy = true,
    isMainUI = false
  },
  UGCReportPrefabBug = {
    keyName = "UGCReportBug",
    moduleName = "client.slua.umg.report_error.ugc_prefab_bug",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Report_Prefab_Popup_UIBP.UGC_Report_Prefab_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC\233\162\132\229\136\182\228\189\147 \228\184\190\230\138\165"
    }
  },
  UGC_Event_CollectionPage_UIBP = {
    keyName = "UGC_Event_CollectionPage_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGCEventCollection.UGC_Event_CollectionPage_UIBP",
    path = "/Game/UMG/UI_BP/UGC/EventActivityCenter/UGC_Event_CollectionPage_UIBP.UGC_Event_CollectionPage_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\230\180\187\229\138\168\228\184\173\229\191\131-\232\181\155\228\186\139\233\155\134\229\144\136\233\161\181"
    }
  },
  UGC_ThemePlay_ActivityTemplate_UIBP = {
    keyName = "UGC_ThemePlay_ActivityTemplate_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.UGCEventCollection.UGC_ThemePlay_ActivityTemplate_UIBP",
    path = "/Game/UMG/UI_BP/UGC/EventActivityCenter/UGC_ThemeActivity_UIBP.UGC_ThemeActivity_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\228\184\187\233\162\152\230\184\184\231\142\169\230\180\187\229\138\168\230\168\161\230\157\191"
    }
  },
  UGC_ThemePlay_ActivityTemplate_ModItem = {
    keyName = "UGC_ThemePlay_ActivityTemplate_ModItem",
    moduleName = "client.slua.umg.ugc.lobby.UGCEventCollection.UGC_ThemePlay_ActivityTemplate_ModItem",
    path = "/Game/UMG/UI_BP/UGC/NewMainOptimize/Item/New_UGC_Common_Mod_Item_UIBP.New_UGC_Common_Mod_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "UGC\228\184\187\233\162\152\230\184\184\231\142\169\230\180\187\229\138\168\230\168\161\230\157\191moditem"
    }
  },
  UGC_AssetHub_Cleanup_Popup_UIBP = {
    keyName = "UGC_AssetHub_Cleanup_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_AssetHub_Cleanup_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Download/Popup/Download_Cleanup_Popup_UIBP.Download_Cleanup_Popup_UIBP",
    uiStat = {
      name = "UGC_AssetHub_Cleanup_Popup_UIBP"
    },
    asy = true
  },
  UGC_AssetHub_Clear_Popup_UIBP = {
    keyName = "UGC_AssetHub_Clear_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.popup.UGC_AssetHub_Clear_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Download/Clear_Popup_UIBP.Clear_Popup_UIBP",
    uiStat = {
      name = "UGC_AssetHub_Clear_Popup_UIBP"
    },
    asy = true
  },
  UGC_TeamDownload_Popup_UIBP = {
    keyName = "UGC_TeamDownload_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.team.UGC_TeamDownload_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_Download_Popup_01_UIBP.UGC_Download_Popup_01_UIBP",
    uiStat = {
      name = "UGC_TeamDownload_Popup_UIBP"
    },
    asy = true
  },
  UGC_PropShopUI = {
    moduleName = "client.slua.umg.ugc.lobby.PropShop.UGC_PropShopUI",
    path = "/Game/UMG/UI_BP/UGC/PlayAppStore/PlayAppStore_MainPanel_UIBP.PlayAppStore_MainPanel_UIBP",
    uiStat = {
      name = "UGC_PropShopUI"
    },
    asy = true,
    isMainUI = true,
    closeOnHide = false
  },
  UGC_PropPurchasePopup = {
    moduleName = "client.slua.umg.ugc.lobby.PropShop.Popup.UGC_PropPurchasePopUp",
    path = "/Game/UMG/UI_BP/UGC/PlayAppStore/Popup/PlayAppStore_Purchase_Popup_UIBP.PlayAppStore_Purchase_Popup_UIBP",
    uiStat = {
      name = "UGC_PropPurchasePopup"
    },
    asy = true,
    isMainUI = true,
    closeOnHide = false,
    containerName = UIContainers.Default
  },
  UGC_Incentive_History_Rank = {
    keyName = "UGC_Incentive_History_Rank",
    moduleName = "client.slua.umg.activity.rank_Creativity.Rank_Incentive_History",
    path = "/Game/UMG/UI_BP/UGC/EventActivityCenter/Popup/UGC_History_Ranking_Popup_UIBP.UGC_History_Ranking_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\230\191\128\229\138\177\230\142\146\232\161\140\230\166\156-\229\142\134\229\143\178\230\142\146\232\161\140"
    }
  },
  UGC_Main_Mine_UI = {
    keyName = "UGC_Main_Mine_UI",
    moduleName = "client.slua.umg.ugc.lobby.UGCMine.UGC_Main_Mine_UI",
    path = "/Game/UMG/UI_BP/UGC/WowPage/UGC_Wow_MyPage_UIBP.UGC_Wow_MyPage_UIBP",
    isMainUI = false,
    uiStat = {
      name = "UGC-V420-\230\136\145\231\154\132\233\161\181\231\173\190"
    }
  },
  UGC_Main_Mine_Sub_UI = {
    keyName = "UGC_Main_Mine_Sub_UI",
    moduleName = "client.slua.umg.ugc.lobby.UGCMine.UGC_Main_Mine_Sub_UI",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    path = "/Game/UMG/UI_BP/UGC/UGC_Main_Mine_Sub_UIBP.UGC_Main_Mine_Sub_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\230\136\145\231\154\132\233\161\181\231\173\190-\228\186\140\231\186\167\231\149\140\233\157\162-\228\184\128\231\186\167\233\161\181\231\173\190"
    }
  },
  UGC_WoW_Mine_Secondary_UI = {
    keyName = "UGC_WoW_Mine_Secondary_UI",
    moduleName = "client.slua.umg.ugc.lobby.UGCMine.UGC_WoW_Mine_Secondary_UI",
    path = "/Game/UMG/UI_BP/UGC/Center/UGC_Center_Tab_UIBP.UGC_Center_Tab_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "UGC-\230\136\145\231\154\132\233\161\181\231\173\190-\228\186\140\231\186\167\231\149\140\233\157\162-\228\186\140\231\186\167\233\161\181\231\173\190"
    }
  },
  UGCLikeCollectionListPanel = {
    keyName = "UGCLikeCollectionListPanel",
    moduleName = "client.slua.umg.ugc.lobby.collection.UGCLikeCollectionListPanel",
    path = "/Game/UMG/UI_BP/UGC/WowPage/UGC_Wow_Secondary_Page_03_UIBP.UGC_Wow_Secondary_Page_03_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC\230\136\145\231\154\132-\229\144\136\233\155\134-\230\148\182\232\151\143"
    }
  },
  UGCFriendUpdatesPanel = {
    keyName = "UGCFriendUpdatesPanel",
    moduleName = "client.slua.umg.ugc.lobby.UGCMine.UGCFriendUpdatesPanel",
    path = "/Game/UMG/UI_BP/UGC/WowPage/UGC_Wow_Secondary_Page_UIBP.UGC_Wow_Secondary_Page_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC\230\136\145\231\154\132-\229\165\189\229\143\139\229\138\168\230\128\129"
    }
  },
  UGC_ShareChallenge_Tips_Item_UIBP = {
    keyName = "UGC_ShareChallenge_Tips_Item_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGC_ShareChallenge_Tips_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Item/UGC_ShareChallenge_Tips_Item_UIBP.UGC_ShareChallenge_Tips_Item_UIBP",
    asy = true,
    uiStat = {
      name = "UGC-\229\136\134\228\186\171\230\140\145\230\136\152-tips"
    }
  },
  UGC_TemplateMods_Popup_UIBP = {
    keyName = "UGC_TemplateMods_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.creator.works.UGC_TemplateMods_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/popup/UGC_PlayMap_Popup_01_UIBP.UGC_PlayMap_Popup_01_UIBP",
    asy = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "UGC-\229\136\155\229\187\186-\230\168\161\230\157\191\228\189\156\229\147\129\229\188\185\231\170\151"
    }
  },
  OldUGCHistoryPanel = {
    keyName = "OldUGCHistoryPanel",
    moduleName = "client.slua.umg.ugc.lobby.UGCMine.OldMine.OldUGCHistoryPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_Collect_UIBP.UGC_Lobby_Collect_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\230\184\184\231\142\169\229\142\134\229\143\178\233\161\181"
    }
  },
  OldUGCCollectPanel = {
    keyName = "OldUGCCollectPanel",
    moduleName = "client.slua.umg.ugc.lobby.UGCMine.OldMine.OldUGCCollectPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_Collect_UIBP.UGC_Lobby_Collect_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\230\148\182\232\151\143\233\161\181"
    }
  },
  OldUGCFollowPanel = {
    keyName = "OldUGCFollowPanel",
    moduleName = "client.slua.umg.ugc.lobby.UGCMine.OldMine.OldUGCFollowPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_Collect_UIBP.UGC_Lobby_Collect_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\133\179\230\179\168\233\161\181"
    }
  },
  OldUGCFriendPanel = {
    keyName = "OldUGCFriendPanel",
    moduleName = "client.slua.umg.ugc.lobby.UGCMine.OldMine.OldUGCFriendPanel",
    path = "/Game/UMG/UI_BP/UGC/UGC_Lobby_Collect_UIBP.UGC_Lobby_Collect_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\165\189\229\143\139\228\189\156\229\147\129\233\161\181"
    }
  },
  OldUGCCollectionListPanel = {
    keyName = "OldUGCCollectionListPanel",
    moduleName = "client.slua.umg.ugc.lobby.UGCMine.OldMine.OldUGCCollectionListPanel",
    path = "/Game/UMG/UI_BP/UGC/CollectionList/UGC_Lobby_CollectList_UIBP.UGC_Lobby_CollectList_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "UGC\230\136\145\231\154\132-\229\144\136\233\155\134-\230\136\145\231\154\132"
    }
  },
  UGC_AlbumThemeSelect_Popup_UIBP = {
    keyName = "UGC_AlbumThemeSelect_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.AlbumTheme.Popup.UGC_AlbumThemeSelect_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/EventActivityCenter/Popup/UGC_EventSelect_Popup_UIBP.UGC_EventSelect_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "UGC-\228\184\147\232\190\145\228\184\187\233\162\152\233\128\137\230\139\169\229\188\185\231\170\151"
    }
  },
  UGC_Smart_Assistant_MusicPlayer_UIBP = {
    keyName = "UGC_Smart_Assistant_MusicPlayer_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.Audio.UGC_Smart_Assistant_MusicPlayer_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_MusicPlayer_UIBP.UGC_Smart_Assistant_MusicPlayer_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\176\143\229\138\169\230\137\139\233\159\179\228\185\144\230\146\173\230\148\190\229\153\168"
    }
  },
  UGC_PropShopPanel = {
    keyName = "UGC_PropShopPanel",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGC_PropShop_UIBP",
    path = "/Game/UMG/UI_BP/UGC/PlayAppStore/PlayAppStore_MapShop_Panel_UIBP.PlayAppStore_MapShop_Panel_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\229\156\176\229\155\190\229\149\134\229\159\142"
    }
  },
  UGCCrystallizedIncomeSubUI = {
    keyName = "UGCCrystallizedIncomeSubUI",
    moduleName = "client.slua.umg.ugc.lobby.detail.UGCCrystallizedIncomeSubUI",
    path = "/Game/UMG/UI_BP/UGC/CrystalStimulate/UGC_CrystalStimulate_AuthorIncome_UIBP.UGC_CrystalStimulate_AuthorIncome_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\228\189\156\229\147\129\232\175\166\230\131\133\233\161\181-\230\148\182\229\133\165\232\174\176\229\189\149"
    }
  },
  UGC_Smart_Assistant_Full_LyricsView_UIBP = {
    keyName = "UGC_Smart_Assistant_Full_LyricsView_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.item.Audio.UGC_Smart_Assistant_Full_LyricsView_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CreativeAssistant/Item/UGC_Smart_Assistant_Full_LyricsView_UIBP.UGC_Smart_Assistant_Full_LyricsView_UIBP",
    uiStat = {
      name = "\229\176\143\229\138\169\230\137\139\230\173\140\232\175\141\230\159\165\231\156\139"
    }
  },
  UGC_PropWarehouse = {
    keyName = "UGC_PropWarehouse",
    moduleName = "client.slua.umg.ugc.lobby.PropShop.Popup.UGC_PropWarehousePopUp",
    path = "/Game/UMG/UI_BP/UGC/PlayAppStore/Popup/PlayAppStore_Warehouse_Popup_UIBP.PlayAppStore_Warehouse_Popup_UIBP",
    containerName = UIContainers.Top,
    isSingleton = false,
    uiStat = {
      name = "UGC-\233\129\147\229\133\183\228\187\147\229\186\147"
    }
  },
  UGC_Crystal_Coin_Tips_UIBP = {
    keyName = "UGC_Crystal_Coin_Tips_UIBP",
    moduleName = "client.slua.umg.ugc.Commercialization.UGC_Crystal_Coin_Tips_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Commercialization/Item/UGC_Commercialization_CurrencyTips_Item_UIBP.UGC_Commercialization_CurrencyTips_Item_UIBP",
    uiStat = {
      name = "UGC\231\187\147\230\153\182\232\180\167\229\184\129\230\143\144\231\164\186\230\161\134"
    }
  },
  UGC_WOWCoin_Exchange_Popup_UIBP = {
    keyName = "UGC_PropWarehouse",
    moduleName = "client.slua.umg.ugc.Commercialization.UGC_WOWCoin_Exchange_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/CrystalStimulate/Popup/UGC_CrystalStimulate_Exchange_Popup_UIBP.UGC_CrystalStimulate_Exchange_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "UGC-WOW\229\184\129\229\133\145\230\141\162\229\188\185\231\170\151"
    }
  },
  UGC_AppreciationGroup_Join = {
    keyName = "UGC_AppreciationGroup_Join",
    moduleName = "client.slua.umg.ugc.AppreciationGroup.UGC_AppreciationGroup_Join",
    path = "/Game/UMG/UI_BP/UGC/AppreciationGroup/UGC_AppreciationGroup_Recruitment_UIBP.UGC_AppreciationGroup_Recruitment_UIBP",
    isSingleton = true,
    uiStat = {
      name = "UGC-\233\137\180\232\181\143\229\155\162\229\138\160\229\133\165\231\149\140\233\157\162"
    }
  },
  UGC_AppreciationGroup_Queue = {
    keyName = "UGC_AppreciationGroup_Queue",
    moduleName = "client.slua.umg.ugc.AppreciationGroup.UGC_AppreciationGroup_Queue",
    path = "/Game/UMG/UI_BP/UGC/AppreciationGroup/UGC_AppreciationGroup_Queue_UIBP.UGC_AppreciationGroup_Queue_UIBP",
    isSingleton = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-\233\137\180\232\181\143\229\155\162\228\184\187\231\149\140\233\157\162"
    }
  },
  UGC_AppreciationGroup_Queue_SubItem = {
    keyName = "UGC_AppreciationGroup_Queue_SubItem",
    moduleName = "client.slua.umg.ugc.AppreciationGroup.UGC_AppreciationGroup_Queue_SubItem",
    path = "/Game/UMG/UI_BP/UGC/AppreciationGroup/Item/UGC_AppreciationGroup_Queue_Item_UIBP.UGC_AppreciationGroup_Queue_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\233\137\180\232\181\143\233\152\159\229\136\151\228\189\156\229\147\129\232\175\166\230\131\133\229\173\144\233\161\185"
    }
  },
  UGC_AppreciationGroup_Task = {
    keyName = "UGC_AppreciationGroup_Task",
    moduleName = "client.slua.umg.ugc.AppreciationGroup.UGC_AppreciationGroup_Task",
    path = "/Game/UMG/UI_BP/UGC/AppreciationGroup/UGC_AppreciationGroup_Task_UIBP.UGC_AppreciationGroup_Task_UIBP",
    isSingleton = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-\233\137\180\232\181\143\229\155\162\228\184\187\231\149\140\233\157\162"
    }
  },
  UGC_AppreciationGroup_Task_SubItem = {
    keyName = "UGC_AppreciationGroup_Task_SubItem",
    moduleName = "client.slua.umg.ugc.AppreciationGroup.UGC_AppreciationGroup_Task_SubItem",
    path = "/Game/UMG/UI_BP/UGC/AppreciationGroup/Item/UGC_AppreciationGroup_Task_Item_UIBP.UGC_AppreciationGroup_Task_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\233\137\180\232\181\143\228\187\187\229\138\161\229\173\144\233\161\185"
    }
  },
  UGC_AppreciationGroup_Main = {
    keyName = "UGC_AppreciationGroup_Main",
    moduleName = "client.slua.umg.ugc.AppreciationGroup.UGC_AppreciationGroup_Main",
    path = "/Game/UMG/UI_BP/UGC/AppreciationGroup/UGC_AppreciationGroup_Main_UIBP.UGC_AppreciationGroup_Main_UIBP",
    isSingleton = true,
    uiStat = {
      name = "UGC-\233\137\180\232\181\143\229\155\162\228\184\187\231\149\140\233\157\162"
    }
  },
  UGC_AppreciationGroup_TotalRewardDetail = {
    keyName = "UGC_AppreciationGroup_TotalRewardDetail",
    moduleName = "client.slua.umg.ugc.AppreciationGroup.UGC_AppreciationGroup_TotalRewardDetail",
    path = "/Game/UMG/UI_BP/UGC/AppreciationGroup/Popup/UGC_AppreciationGroup_Level_Popup_UIBP.UGC_AppreciationGroup_Level_Popup_UIBP",
    isSingleton = true,
    uiStat = {
      name = "UGC-\233\137\180\232\181\143\229\155\162\228\184\187\231\149\140\233\157\162"
    }
  },
  CommonTextTips_UIBP = {
    keyName = "CommonTextTips_UIBP",
    moduleName = "client.slua.umg.common.CommonTextTips_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/CommonTextTips_UIBP.CommonTextTips_UIBP",
    uiStat = {
      name = "UGC-tips\229\188\185\231\170\151"
    }
  },
  Common_Guide_Tips_UIBP = {
    keyName = "Common_Guide_Tips_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Guide_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/Common_Guide_Tips_UIBP.Common_Guide_Tips_UIBP",
    uiStat = {
      name = "UGC\229\188\149\229\175\188-\228\184\138\228\184\139\229\183\166\229\143\179tips"
    },
    isSingleton = false,
    AndroidBackType = EAndroidBackType.Skip
  },
  NewLobbyReportBug = {
    keyName = "NewLobbyReportBug",
    moduleName = "client.slua.umg.report_error.new_ugc_lobby_report_bug",
    path = "/Game/UMG/UI_BP/PopupNotice/ReportBug_UIBP.ReportBug_UIBP",
    uiStat = {
      name = "UGC-\229\164\167\229\142\133\228\184\190\230\138\165\229\188\185\231\170\151"
    }
  },
  UGCCenterConfirmTips = {
    keyName = "UGCCenterConfirmTips",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_Center_ConfirmTips",
    path = "/Game/UMG/UI_BP/UGC/Center/Popup/UGC_Center_Guide_Popup_UIBP.UGC_Center_Guide_Popup_UIBP",
    uiStat = {
      name = "UGC-\230\149\176\230\141\174\228\184\173\229\191\131\229\188\185\231\170\151"
    }
  },
  UGC_Main_Intention_Panel_UI = {
    keyName = "UGC_Main_Intention_Panel_UI",
    moduleName = "client.slua.umg.ugc.lobby.Intention.UGC_Main_Intention_Panel_UI",
    path = "/Game/UMG/UI_BP/UGC/HotTheme/UGC_PreferenceSelection_UIBP.UGC_PreferenceSelection_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "UGC-\230\132\143\229\155\190\233\128\137\230\139\169\231\149\140\233\157\162"
    }
  },
  UGC_CrystalIncentive_Popup_UIBP = {
    keyName = "UGC_CrystalIncentive_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.creator.center.UGC_CrystalIncentive_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Explain_UIBP.Common_Popup_Theme_Explain_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\231\187\147\230\153\182\230\191\128\229\138\177\229\188\185\231\170\151"
    }
  },
  UGC_AppreciationGroup_Evaluate_Popup = {
    keyName = "UGC_AppreciationGroup_Evaluate_Popup",
    moduleName = "client.slua.umg.ugc.AppreciationGroup.EvaluatePopup.UGC_AppreciationGroup_Evaluate_Popup",
    path = "/Game/UMG/UI_BP/UGC/AppreciationGroup/Popup/UGC_AppreciationGroup_Evaluate_Popup_UIBP.UGC_AppreciationGroup_Evaluate_Popup_UIBP",
    isSingleton = true,
    uiStat = {
      name = "UGC-\233\137\180\232\181\143\229\155\162\232\175\132\228\187\183\229\188\185\231\170\151"
    }
  },
  UGC_AppreciationGroup_Submit_UIBP = {
    keyName = "UGC_AppreciationGroup_Submit_UIBP",
    moduleName = "client.slua.umg.ugc.AppreciationGroup.EvaluatePopup.UGC_AppreciationGroup_Submit_UIBP",
    path = "/Game/UMG/UI_BP/UGC/AppreciationGroup/UGC_AppreciationGroup_Submit_UIBP.UGC_AppreciationGroup_Submit_UIBP",
    isSingleton = true,
    uiStat = {
      name = "UGC-\233\137\180\232\181\143\229\155\162\229\174\140\230\136\144\232\175\132\228\187\183\231\161\174\232\174\164\229\188\185\231\170\151"
    }
  },
  UGC_AppreciationGroup_HistoryData = {
    keyName = "UGC_AppreciationGroup_HistoryData",
    moduleName = "client.slua.umg.ugc.AppreciationGroup.UGC_AppreciationGroup_HistoryData",
    path = "/Game/UMG/UI_BP/UGC/AppreciationGroup/UGC_ApprecitionGroup_Histroy_UIBP.UGC_ApprecitionGroup_Histroy_UIBP",
    isSingleton = true,
    isMainUI = false,
    uiStat = {
      name = "UGC-\233\137\180\232\181\143\229\155\162\229\142\134\229\143\178\230\149\176\230\141\174\231\149\140\233\157\162"
    }
  },
  UGC_AppreciationGroup_HistoryData_DetailPopup = {
    keyName = "UGC_AppreciationGroup_HistoryData_DetailPopup",
    moduleName = "client.slua.umg.ugc.AppreciationGroup.UGC_AppreciationGroup_HistoryData_DetailPopup",
    path = "/Game/UMG/UI_BP/UGC/AppreciationGroup/Popup/UGC_AppreciationGroup_Histroy_Popup_UIBP.UGC_AppreciationGroup_Histroy_Popup_UIBP",
    isSingleton = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "UGC-\233\137\180\232\181\143\229\155\162\229\142\134\229\143\178\230\149\176\230\141\174\231\149\140\233\157\162-\232\175\166\230\131\133\229\188\185\231\170\151"
    }
  },
  UGCResultSharePanel = {
    keyName = "UGCResultSharePanel",
    moduleName = "GameLua.Mod.CreativeBase.Client.Result.UGCResultSharePanel",
    path = "/Game/Mod/CreativeBase/UMG/Result/Share_WoWMap_UIBP.Share_WoWMap_UIBP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\231\187\147\231\174\151\229\136\134\228\186\171"
    }
  },
  UGC_PropShopItemGetPanel = {
    keyName = "UGC_PropShopItemGetPanel",
    moduleName = "client.slua.umg.ugc.lobby.PropShop.Popup.UGC_PropItemGetPanel",
    path = "/Game/UMG/UI_BP/UGC/PlayAppStore/Popup/PlayAppStore_ItemGet_UIBP.PlayAppStore_ItemGet_UIBP",
    containerName = UIContainers.Top,
    isSingleton = true,
    uiStat = {
      name = "UGC-\233\129\147\229\133\183\232\142\183\229\190\151\231\149\140\233\157\162"
    }
  },
  UGC_PropShopGetItem = {
    keyName = "UGC_PropShopGetItem",
    moduleName = "client.slua.umg.ugc.lobby.PropShop.Popup.UGC_PropGetItem",
    path = "/Game/UMG/UI_BP/UGC/PlayAppStore/Item/PlayAppStore_Get_Item_BP.PlayAppStore_Get_Item_BP",
    isSingleton = false,
    uiStat = {
      name = "UGC-\233\129\147\229\133\183\232\142\183\229\190\151Item"
    }
  },
  UGC_PropDetailPanel = {
    keyName = "UGC_PropDetailPanel",
    moduleName = "client.slua.umg.ugc.lobby.PropShop.Popup.UGC_PropDetailPanel",
    path = "/Game/UMG/UI_BP/UGC/PlayAppStore/Item/PlayAppStore_ItemTips_UIBP.PlayAppStore_ItemTips_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "UGC\233\129\147\229\133\183\228\191\161\230\129\175\231\149\140\233\157\162"
    }
  },
  UGC_Hall_UIBP = {
    keyName = "UGC_Hall_UIBP",
    moduleName = "client.slua.umg.ugc.Hall.UGC_Hall_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Hall/UGC_Hall_UIBP.UGC_Hall_UIBP",
    uiStat = {
      name = "UGC-\229\164\167\229\142\133\228\184\187\231\149\140\233\157\162"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  UGC_Hall_Top_Item_UIBP = {
    keyName = "UGC_Hall_Top_Item_UIBP",
    moduleName = "client.slua.umg.ugc.Hall.Item.UGC_Hall_Top_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Hall/Item/UGC_Hall_Top_Item_UIBP.UGC_Hall_Top_Item_UIBP",
    uiStat = {
      name = "UGC-\229\164\167\229\142\133\233\161\182\233\131\168\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  UGC_Hall_Left_Item_UIBP = {
    keyName = "UGC_Hall_Left_Item_UIBP",
    moduleName = "client.slua.umg.ugc.Hall.Item.UGC_Hall_Left_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Hall/Item/UGC_Hall_Left_Item_UIBP.UGC_Hall_Left_Item_UIBP",
    uiStat = {
      name = "UGC-\229\183\166\232\190\185\231\164\190\228\186\164\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  UGC_HallTips_Item_UIBP = {
    keyName = "UGC_HallTips_Item_UIBP",
    moduleName = "client.slua.umg.ugc.Hall.Item.UGC_HallTips_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Hall/Item/UGC_HallTips_Item_UIBP.UGC_HallTips_Item_UIBP",
    uiStat = {
      name = "UGC-\229\183\166\228\190\167\231\164\190\228\186\164\231\149\140\233\157\162-\230\140\130\232\189\189\229\136\155\228\189\156\229\133\179\230\128\128tips"
    },
    containerName = UIContainers.Top
  },
  UGC_Hall_Map_Info_Item_UIBP = {
    keyName = "UGC_Hall_Map_Info_Item_UIBP",
    moduleName = "client.slua.umg.ugc.Hall.Item.UGC_Hall_Map_Info_Item_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Hall/Item/UGC_Hall_Map_Info_Item_UIBP.UGC_Hall_Map_Info_Item_UIBP",
    uiStat = {
      name = "UGC-\229\143\179\228\190\167\229\156\176\229\155\190\232\175\166\230\131\133\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  UGCMainPanelFindWorksHall = {
    keyName = "UGCMainPanelFindWorksHall",
    moduleName = "client.slua.umg.ugc.lobby.NewLobby.UGCMainPanelFindWorksHall",
    path = "/Game/UMG/UI_BP/UGC/Hall/New_UGC_SocialMain_UIBP.New_UGC_SocialMain_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UGC_NEW_MAIN_PANEL,
    uiStat = {
      name = "\230\150\176\230\168\161\229\188\143\233\128\137\230\139\169-\228\184\187\231\149\140\233\157\162-\230\137\190\229\155\190\229\164\167\229\142\133"
    }
  },
  UGC_WoWGudie_Introduce_UIBP = {
    keyName = "UGC_WoWGudie_Introduce_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.NewbieGuide.UGC_WoWGudie_Introduce_UIBP",
    path = "/Game/UMG/UI_BP/UGC/WoWGuide/UGC_WoWGudie_Introduce_UIBP.UGC_WoWGudie_Introduce_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "UGC-\230\150\176\230\137\139\229\188\149\229\175\188-\228\187\139\231\187\141"
    }
  },
  UGC_WoWGudie_Video_UIBP = {
    keyName = "UGC_WoWGudie_Video_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.NewbieGuide.UGC_WoWGudie_Video_UIBP",
    path = "/Game/UMG/UI_BP/UGC/WoWGuide/UGC_WoWGudie_Video_UIBP.UGC_WoWGudie_Video_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "UGC-\230\150\176\230\137\139\229\188\149\229\175\188-\232\167\134\233\162\145"
    }
  },
  UGC_WoWGudie_RecommendedWorks_UIBP = {
    keyName = "UGC_WoWGudie_RecommendedWorks_UIBP",
    moduleName = "client.slua.umg.ugc.lobby.NewbieGuide.UGC_WoWGudie_RecommendedWorks_UIBP",
    path = "/Game/UMG/UI_BP/UGC/WoWGuide/UGC_WoWGudie_RecommendedWorks_UIBP.UGC_WoWGudie_RecommendedWorks_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "UGC-\230\150\176\230\137\139\229\188\149\229\175\188-\230\142\168\232\141\144\228\189\156\229\147\129"
    }
  },
  UGC_AppreciationGroup_Explanation_Popup_UIBP = {
    keyName = "UGC_AppreciationGroup_Explanation_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.AppreciationGroup.UGC_AppreciationGroup_Explanation_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/AppreciationGroup/Popup/UGC_AppreciationGroup_Explanation_Popup_UIBP.UGC_AppreciationGroup_Explanation_Popup_UIBP",
    isSingleton = true,
    uiStat = {
      name = "UGC-\233\137\180\232\181\143\229\155\162\232\175\180\230\152\142\229\188\185\231\170\151"
    }
  },
  UGC_AppreciationGroup_Exit_UIBP = {
    keyName = "UGC_AppreciationGroup_Exit_UIBP",
    moduleName = "client.slua.umg.ugc.AppreciationGroup.UGC_AppreciationGroup_Exit_UIBP",
    path = "/Game/UMG/UI_BP/UGC/AppreciationGroup/UGC_AppreciationGroup_Exit_UIBP.UGC_AppreciationGroup_Exit_UIBP",
    isSingleton = true,
    uiStat = {
      name = "UGC-\233\137\180\232\181\143\229\155\162\230\184\133\233\128\128\231\149\140\233\157\162"
    }
  },
  UGC_AppreciationGroup_Tips_Popup_UIBP = {
    keyName = "UGC_AppreciationGroup_Tips_Popup_UIBP",
    moduleName = "client.slua.umg.ugc.AppreciationGroup.UGC_AppreciationGroup_Tips_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UGC/AppreciationGroup/Popup/UGC_AppreciationGroup_Tips_Popup_UIBP.UGC_AppreciationGroup_Tips_Popup_UIBP",
    isSingleton = true,
    uiStat = {
      name = "UGC-\233\137\180\232\181\143\229\155\162\231\161\174\232\174\164\229\188\185\231\170\151"
    }
  }
}
return ugc_ui_configs