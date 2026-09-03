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
local common_ui_configs = {
  CommonItem_DiyClothingIcon_UIBP = {
    keyName = "CommonItem_DiyClothingIcon_UIBP",
    moduleName = "client.slua.component.item.ItemChildren.CommonItem_DiyClothingIcon_UIBP",
    path = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_DiyClothingIcon_UIBP.CommonItem_DiyClothingIcon_UIBP",
    isSingleton = false,
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.item_pool,
    asy = true,
    uiStat = {
      name = "CommonItem\232\161\163\230\156\141Diy\230\160\135\232\175\134"
    }
  },
  CommonItem_Decompose_UIBP = {
    keyName = "CommonItem_Decompose_UIBP",
    moduleName = "client.slua.component.item.ItemChildren.CommonItem_Decompose_UIBP",
    path = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_Decompose_UIBP.CommonItem_Decompose_UIBP",
    isSingleton = false,
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.item_pool,
    asy = true,
    uiStat = {
      name = "CommonItem\229\136\134\232\167\163\229\138\168\231\148\187\232\138\130\231\130\185"
    }
  },
  common_exchange = {
    keyName = "common_exchange",
    moduleName = "client.slua.umg.common.common_exchange",
    jumpModuleID = BP_ENUM_MODULE_COMMON_EXCHANGE,
    path = "/Game/UMG/UI_BP/Common/Common_Exchange_UIBP.Common_Exchange_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\229\149\134\229\186\151"
    }
  },
  Common_Exchange_Confirm_UIBP = {
    keyName = "Common_Exchange_Confirm_UIBP",
    moduleName = "client.slua.umg.common.CommonExchangePopupUI.Common_Exchange_Confirm_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Exchange_Confirm_UIBP.Common_Exchange_Confirm_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\231\177\187-\232\180\173\228\185\176\229\133\145\230\141\162\228\186\140\230\172\161\231\161\174\232\174\164\231\149\140\233\157\162"
    }
  },
  Common_Mask_UIBP = {
    keyName = "Common_Mask_UIBP",
    moduleName = "client.slua.umg.common.Common_Mask_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Mask_UIBP.Common_Mask_UIBP",
    isMainUI = false,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\128\154\231\148\168\233\129\174\231\189\169"
    }
  },
  mvp_loading_mask = {
    keyName = "mvp_loading_mask",
    moduleName = "client.slua.umg.mvp_motion.mvp_loading_mask",
    path = "/Game/UMG/UI_Logic/Reconnect/Reconnect_BP.Reconnect_BP",
    closeOnSwitch = false,
    closeOnHide = false,
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "MVP\229\138\168\228\189\156\229\138\160\232\189\189\232\143\138\232\138\177"
    }
  },
  Common_Slap_Face_Base = {
    keyName = "Common_Slap_Face_Base",
    moduleName = "client.slua.umg.common.Common_Slap_Face_Base",
    isMainUI = false,
    isSingleton = false,
    {
      name = "\233\128\154\231\148\168\230\139\141\232\132\184\229\159\186\231\177\187"
    }
  },
  DetailComponentMain = {
    keyName = "DetailComponentMain",
    moduleName = "client.slua.traits.DetailComponent.DetailComponentMain",
    path = "/Game/UMG/UI_BP/Common/Common_Detail_Goods_UIBP.Common_Detail_Goods_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142/\232\161\165\231\187\153-NEW\232\175\166\230\131\133\231\187\132\228\187\182"
    }
  },
  ItemListComponent = {
    keyName = "ItemListComponent",
    moduleName = "client.slua.traits.DetailComponent.ItemListComponent.ItemListComponent",
    path = "/Game/UMG/UI_BP/Common/Common_Detail_ItemList_UIBP.Common_Detail_ItemList_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\175\166\230\131\133\231\187\132\228\187\182-\231\137\169\229\147\129\229\136\151\232\161\168"
    }
  },
  BuyButtonComponent = {
    keyName = "BuyButtonComponent",
    moduleName = "client.slua.traits.DetailComponent.BuyButtonComponent.BuyButtonComponent",
    path = "/Game/UMG/UI_BP/NewStore/item/Store_Buy_Item_UIBP.Store_Buy_Item_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142-\232\180\173\228\185\176\230\140\137\233\146\174\231\187\132\228\187\182"
    }
  },
  FeatureComponent = {
    keyName = "FeatureComponent",
    moduleName = "client.slua.traits.DetailComponent.FeatureComponent.FeatureComponent",
    path = "/Game/UMG/UI_BP/Common/Common_Detail_Feature.Common_Detail_Feature",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\175\166\230\131\133\231\187\132\228\187\182-\231\137\185\230\128\167\230\160\143\231\187\132\228\187\182"
    }
  },
  special_feature_component = {
    keyName = "special_feature_component",
    moduleName = "client.slua.traits.DetailComponent.SpecialFeatureComponent.special_feature_component",
    path = "/Game/UMG/UI_BP/NewStore/item/Store_Banner_Show.Store_Banner_Show",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\175\166\230\131\133\231\187\132\228\187\182-\228\184\138\230\150\176\231\137\185\230\174\138\232\175\166\230\131\133\231\187\132\228\187\182\231\137\185\230\174\138\229\177\149\231\164\186"
    }
  },
  FeatureItem_Name_Bp = {
    keyName = "FeatureItem_Name_Bp",
    moduleName = "client.slua.traits.DetailComponent.FeatureComponent.FeatureItem_Name_Bp",
    path = "/Game/UMG/UI_BP/NewStore/item/FeatureItem_Name_Bp.FeatureItem_Name_Bp",
    asy = true,
    uiStat = {
      name = "\232\175\166\230\131\133\231\187\132\228\187\182-\231\187\132\229\144\136\231\137\185\230\128\167"
    }
  },
  Common_FullScreenView_UIBP = {
    keyName = "Common_FullScreenView_UIBP",
    moduleName = "client.slua.umg.common.Common_FullScreenView_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_FullScreenView_New_UIBP.Common_FullScreenView_New_UIBP",
    uiStat = {
      name = "\229\133\168\229\177\143\233\162\132\232\167\136avatar\231\149\140\233\157\162"
    }
  },
  Common_FullScreenView_Weapon_UIBP = {
    keyName = "Common_FullScreenView_Weapon_UIBP",
    moduleName = "client.slua.umg.common.Common_FullScreenView_Weapon_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_FullScreenView_New_UIBP.Common_FullScreenView_New_UIBP",
    uiStat = {
      name = "\229\133\168\229\177\143\233\162\132\232\167\136\230\158\170\230\162\176\231\149\140\233\157\162"
    }
  },
  AvatarDisplayComponent = {
    keyName = "AvatarDisplayComponent",
    moduleName = "client.slua.traits.DetailComponent.AvatarDisplay.AvatarDisplayComponent",
    path = "/Game/UMG/UI_BP/Common/AvatarDisplay_UIBP.AvatarDisplay_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "avatar\229\177\149\231\164\186"
    }
  },
  ViewComponent = {
    keyName = "ViewComponent",
    moduleName = "client.slua.traits.DetailComponent.ViewComponent.ViewComponent",
    path = "/Game/UMG/UI_BP/Common/Common_Detail_View_UIBP.Common_Detail_View_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\175\166\230\131\133\231\187\132\228\187\182-\232\167\134\232\167\146\231\187\132\228\187\182"
    }
  },
  UseButtonComponent = {
    keyName = "UseButtonComponent",
    moduleName = "client.slua.traits.DetailComponent.UseButtonComponent.UseButtonComponent",
    path = "/Game/Arts_UI/LuckyWidget/LuckySpinTarotTemplate/Item/LuckySpinTarotTemplate_Btn_Item.LuckySpinTarotTemplate_Btn_Item",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\137\169\229\147\129\232\175\166\230\131\133-\228\189\191\231\148\168\230\140\137\233\146\174\231\187\132\228\187\182"
    }
  },
  CharacterComponent = {
    keyName = "CharacterComponent",
    moduleName = "client.slua.traits.DetailComponent.CharacterComponent.CharacterComponent",
    path = "/Game/UMG/UI_BP/NewStore/Character/Item/Character_Jump_Comp.Character_Jump_Comp",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\137\169\229\147\129\232\175\166\230\131\133-\232\167\146\232\137\178\232\183\179\232\189\172\231\187\132\228\187\182"
    }
  },
  Common_Download_Map_Style_One = {
    keyName = "Common_Download_Map_Style_One",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/Common/Common_Download_Map_Style_One.Common_Download_Map_Style_One",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.downloadui_pool
  },
  Common_Download_Map_Style_Two = {
    keyName = "Common_Download_Map_Style_Two",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/Common/Common_Download_Map_Style_Two.Common_Download_Map_Style_Two",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.downloadui_pool
  },
  Common_Download_Store_Style = {
    keyName = "Common_Download_Store_Style",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/Common/Common_Download_Store_Style.Common_Download_Store_Style",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.downloadui_pool
  },
  ChildUIWithoutBpPath = {
    keyName = "ChildUIWithoutBpPath",
    moduleName = "client.slua_ui_framework.base",
    isMainUI = false,
    isSingleton = false
  },
  ChildUIWithoutBpPathForChat = {
    keyName = "ChildUIWithoutBpPathForChat",
    moduleName = "client.slua.umg.effect_item.Lobby_RoleInfo_EffectSkin_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.chat_pool
  },
  ChildUIWithoutBpPathAsy = {
    keyName = "ChildUIWithoutBpPathAsy",
    moduleName = "client.slua_ui_framework.base",
    isMainUI = false,
    isSingleton = false,
    asy = true
  },
  ChildUIWithoutLuaAndBpPath = {
    keyName = "ChildUIWithoutLuaAndBpPath",
    isSingleton = false,
    isMainUI = false
  },
  ChildUIWithoutLuaAndBpPathAsy = {
    keyName = "ChildUIWithoutLuaAndBpPathAsy",
    isSingleton = false,
    isMainUI = false,
    asy = true
  },
  ChildUIWithoutBpPathNonePool = {
    keyName = "ChildUIWithoutBpPathNonePool",
    moduleName = "client.slua_ui_framework.base",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.None
  },
  MainUIWithoutLuaAndBpPathAsy = {
    keyName = "MainUIWithoutLuaAndBpPathAsy",
    asy = true
  },
  AsyncBackgroundBase = {
    keyName = "AsyncBackgroundBase",
    moduleName = "client.slua.traits.Background.AsyncBackgroundBase",
    isMainUI = false,
    isSingleton = false,
    asy = true
  },
  PreorderBackGround = {
    keyName = "PreorderBackGround",
    moduleName = "client.slua.umg.lobby_activity.SpinPreorder.Traits.PreorderBackGround",
    isMainUI = false,
    isSingleton = false,
    asy = true
  },
  Fighting_Watermark_BP = {
    keyName = "Fighting_Watermark_BP",
    moduleName = "client.slua.umg.Fighting_Watermark.Fighting_Watermark_BP",
    path = "/Game/UMG/UI_BP/Lobby_Watermark/Lobby_Watermark_BP.Lobby_Watermark_BP",
    containerName = UIContainers.Top,
    closeOnSwitch = false,
    zOrder = EFixedZOrder.WaterMark,
    uiStat = {
      name = "\230\136\152\230\150\151-\230\136\152\230\150\151\230\176\180\229\141\176"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  jk_common_exchange_high = {
    keyName = "jk_common_exchange_high",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.store.jk_common_exchange_high",
    jumpModuleID = BP_ENUM_MODULE_COMMON_EXCHANGE,
    path = "/Game/UMG/UI_BP/Common/Common_Exchange_JK_High_UIBP.Common_Exchange_JK_High_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\229\149\134\229\186\151 -- \233\171\152\231\186\167"
    }
  },
  BuyButtonComponent_Suit = {
    keyName = "BuyButtonComponent_Suit",
    moduleName = "client.slua.traits.DetailComponent.BuyButtonComponent.BuyButtonComponent_Suit",
    path = "/Game/Arts_UI/FromUMG/XSuit/XSuitSpin/XSuit_Buy_Btn_Item.XSuit_Buy_Btn_Item",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\229\156\163\232\163\133-\232\180\173\228\185\176\230\140\137\233\146\174\231\187\132\228\187\182"
    }
  },
  store_feature_popup = {
    keyName = "store_feature_popup",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.component.store_feature_popup",
    path = "/Game/UMG/UI_BP/Common/Common_Detail_Goods_Popup_Attribute_UIBP.Common_Detail_Goods_Popup_Attribute_UIBP",
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142/\232\161\165\231\187\153-\231\137\185\230\128\167\231\187\132\228\187\182\230\143\143\232\191\176\229\188\185\231\170\151"
    }
  },
  store_voice_component = {
    keyName = "store_voice_component",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.component.store_voice_component",
    path = "/Game/UMG/UI_BP/NewStore/component/Common_Voice_Main_Item_UIBP.Common_Voice_Main_Item_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142-\232\175\173\233\159\179\231\187\132\228\187\182"
    }
  },
  connect_wait = {
    keyName = "connect_wait",
    moduleName = "client.slua.umg.lobby.connection_waiting",
    path = "/Game/UMG/UI_Logic/Reconnect/Reconnect_BP.Reconnect_BP",
    closeOnSwitch = false,
    closeOnHide = false,
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Skip
  },
  connect_wait_without_block = {
    keyName = "connect_wait_without_block",
    moduleName = "client.slua.umg.lobby.connect_wait_without_block",
    path = "/Game/UMG/UI_BP/Reconnect/Reconnect_NoBlock_UIBP.Reconnect_NoBlock_UIBP",
    containerName = UIContainers.Top,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Skip,
    asy = true
  },
  Team_Share_Tips_UIBP = {
    keyName = "Team_Share_Tips_UIBP",
    moduleName = "client.slua.umg.teamup.Team_Share_Tips_UIBP",
    path = "/Game/UMG/UI_BP/TeamUp/Team_Share_Tips_UIBP.Team_Share_Tips_UIBP",
    uiStat = {
      name = "\232\174\162\233\152\133-\229\133\177\228\186\171\230\136\144\229\138\159\230\143\144\231\164\186"
    }
  },
  levelup_panel = {
    keyName = "levelup_panel",
    moduleName = "client.slua.umg.levelup.levelup_panel",
    path = "/Game/UMG/UI_BP/Lobby/Leve_UpUIBP.Leve_UpUIBP",
    showVisibility = Visible,
    uiStat = {
      name = "\229\141\135\231\186\167\231\149\140\233\157\162-PVP"
    }
  },
  pve_levelup_panel = {
    keyName = "pve_levelup_panel",
    moduleName = "client.slua.umg.levelup.pve_levelup_panel",
    path = "/Game/UMG/UI_BP/LevelUp/PVELevelUp_UIBP.PVELevelUp_UIBP",
    uiStat = {
      name = "\229\141\135\231\186\167\231\149\140\233\157\162-PVE"
    }
  },
  package_preview_panel = {
    keyName = "package_preview_panel",
    moduleName = "client.slua.umg.lobby_item.package_preview_panel",
    path = "/Game/UMG/UI_BP/Lobby/PackagePreview_UIBP.PackagePreview_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\162\132\232\167\136\231\149\140\233\157\162-\230\153\174\233\128\154\231\164\188\229\140\133"
    }
  },
  common_messagebox_timer = {
    keyName = "common_messagebox_timer",
    moduleName = "client.slua.umg.common.common_messagebox_timer",
    path = "/Game/UMG/UI_BP/Common/Common_MessageBox_YueNan_UIBP.Common_MessageBox_YueNan_UIBP",
    closeOnSwitch = false,
    containerName = UIContainers.Top
  },
  common_messagebox_nevershow = {
    keyName = "common_messagebox_nevershow",
    moduleName = "client.slua.umg.common.common_messagebox_nevershow",
    path = "/Game/UMG/UI_BP/Common/Common_MessageBox_AD_UIBP.Common_MessageBox_AD_UIBP",
    closeOnSwitch = false,
    containerName = UIContainers.Top
  },
  common_float_tips = {
    keyName = "common_float_tips",
    moduleName = "client.slua.umg.common.common_float_tips",
    path = "/Game/UMG/UI_BP/Common/Tips/CommonFloatTips.CommonFloatTips",
    uiStat = {
      name = "\233\128\154\231\148\168\230\181\174\231\170\151tips"
    }
  },
  Teamup_Avatar_Notice = {
    keyName = "Teamup_Avatar_Notice",
    moduleName = "client.slua.umg.common.Teamup_Avatar_Notice",
    path = "/Game/UMG/UI_BP/Common/Tips/Teamup_Avatar_Notice.Teamup_Avatar_Notice",
    isSingleton = false,
    uiStat = {
      name = "Avatar\229\133\165\229\156\186\229\138\168\228\189\156\228\188\180\231\148\159Tips"
    }
  },
  Common_Explain_Tips_UIBP = {
    keyName = "Common_Explain_Tips_UIBP",
    moduleName = "client.slua.umg.common.Common_Explain_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/Common_Explain_Tips_UIBP.Common_Explain_Tips_UIBP",
    uiStat = {
      name = "\229\162\158\229\138\160\233\153\144\232\180\173\230\172\161\232\183\179\232\189\172\229\188\185\231\170\151"
    }
  },
  ItemPreview_UIBP = {
    keyName = "ItemPreview_UIBP",
    moduleName = "client.slua.umg.common.ItemPreview.ItemPreview_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/ItemPreview_UIBP.ItemPreview_UIBP",
    uiStat = {
      name = "\233\162\132\232\167\136\231\149\140\233\157\162-\231\137\169\229\147\129"
    }
  },
  ItemPreview_ActList_UIBP = {
    keyName = "ItemPreview_ActList_UIBP",
    moduleName = "client.slua.umg.common.ItemPreview.ItemPreviewChild.ItemPreview_ActList_UIBP",
    isSingleton = false,
    isMainUI = false,
    path = "/Game/UMG/UI_BP/Lobby/ItemPreviewChild/ItemPreview_ActList_UIBP.ItemPreview_ActList_UIBP",
    uiStat = {
      name = "\233\162\132\232\167\136\231\149\140\233\157\162-\230\180\187\229\138\168\232\175\149\231\169\191\229\136\151\232\161\168"
    },
    asy = true
  },
  ItemPreview_ModelList_UIBP = {
    keyName = "ItemPreview_ModelList_UIBP",
    moduleName = "client.slua.umg.common.ItemPreview.ItemPreviewChild.ItemPreview_ModelList_UIBP",
    isSingleton = false,
    isMainUI = false,
    path = "/Game/UMG/UI_BP/Lobby/ItemPreviewChild/ItemPreview_ModelList_UIBP.ItemPreview_ModelList_UIBP",
    uiStat = {
      name = "\233\162\132\232\167\136\231\149\140\233\157\162-\230\168\161\229\158\139\229\136\151\232\161\168"
    },
    asy = true
  },
  ItemPreview_BoxDropList_UIBP = {
    keyName = "ItemPreview_BoxDropList_UIBP",
    moduleName = "client.slua.umg.common.ItemPreview.ItemPreviewChild.ItemPreview_BoxDropList_UIBP",
    isSingleton = false,
    isMainUI = false,
    path = "/Game/UMG/UI_BP/Lobby/ItemPreviewChild/ItemPreview_BoxDropList_UIBP.ItemPreview_BoxDropList_UIBP",
    uiStat = {
      name = "\233\162\132\232\167\136\231\149\140\233\157\162-\229\174\157\231\174\177\230\142\137\232\144\189\233\162\132\232\167\136\229\136\151\232\161\168"
    },
    asy = true
  },
  ItemPreview_ThreeColumn_UIBP = {
    keyName = "ItemPreview_ThreeColumn_UIBP",
    moduleName = "client.slua.umg.common.ItemPreview.ItemPreviewChild.ItemPreview_ThreeColumn_UIBP",
    isSingleton = false,
    isMainUI = false,
    path = "/Game/UMG/UI_BP/Lobby/ItemPreviewChild/ItemPreview_ThreeColumn_UIBP.ItemPreview_ThreeColumn_UIBP",
    uiStat = {
      name = "\233\162\132\232\167\136\231\149\140\233\157\162-\228\184\137\229\136\151\229\136\151\232\161\168\233\135\145\232\163\133\228\184\147\231\148\168"
    },
    asy = true
  },
  ItemPreview_MultiPool_UIBP = {
    keyName = "ItemPreview_MultiPool_UIBP",
    moduleName = "client.slua.umg.common.ItemPreview.ItemPreviewChild.ItemPreview_MultiPool_UIBP",
    isSingleton = false,
    isMainUI = false,
    path = "/Game/UMG/UI_BP/Lobby/ItemPreviewChild/ItemPreview_MultiPool_UIBP.ItemPreview_MultiPool_UIBP",
    uiStat = {
      name = "\233\162\132\232\167\136\231\149\140\233\157\162-\229\164\154\229\165\150\230\177\160\229\143\175\232\142\183\229\190\151\233\162\132\232\167\136"
    },
    asy = true
  },
  itemtips_panel = {
    keyName = "itemtips_panel",
    moduleName = "client.slua.umg.common.itemtips_panel",
    containerName = UIContainers.Top,
    path = "/Game/UMG/UI_BP/Common/Tips_200/Common_TaskTips_UIBP.Common_TaskTips_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\231\137\169\229\147\129\230\143\144\231\164\186"
    }
  },
  Common_VerticalTips_UIBP = {
    keyName = "Common_VerticalTips_UIBP",
    moduleName = "client.slua.umg.common.Common_VerticalTips_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips_200/Common_VerticalTips_UIBP.Common_VerticalTips_UIBP",
    containerName = UIContainers.Top,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\231\148\168\231\137\169\229\147\129\230\143\144\231\164\186\229\158\130\231\155\180\231\137\136"
    }
  },
  common_item_list = {
    keyName = "common_item_list",
    moduleName = "client.slua.umg.common.common_item_list",
    path = "/Game/UMG/UI_BP/Common/Common_Roomcard_UIBP.Common_Roomcard_UIBP",
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\230\136\191\229\141\161\229\136\151\232\161\168"
    }
  },
  common_item_list_quick_use = {
    keyName = "common_item_list_quick_use",
    moduleName = "client.slua.umg.common.common_item_list_quick_use",
    path = "/Game/UMG/UI_BP/Common/Common_Roomcard_UIBP.Common_Roomcard_UIBP",
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\230\136\191\229\141\161\229\136\151\232\161\168-\229\191\171\233\128\159\228\189\191\231\148\168"
    }
  },
  common_treasurebox_popup = {
    keyName = "common_treasurebox_popup",
    moduleName = "client.slua.umg.common.common_treasurebox_popup",
    path = "/Game/UMG/UI_BP/Common/BigTreasureChest_BP.BigTreasureChest_BP",
    uiStat = {
      name = "\233\128\154\231\148\168\229\174\157\231\174\177\233\162\132\232\167\136\233\161\181\233\157\162"
    }
  },
  common_use_items = {
    keyName = "common_use_items",
    moduleName = "client.slua.umg.common.common_use_items",
    path = "/Game/UMG/UI_BP/Common/CommonUseGoods_UIBP.CommonUseGoods_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\128\154\231\148\168\228\189\191\231\148\168\233\129\147\229\133\183\233\161\181\233\157\162"
    }
  },
  video_player_system_pure = {
    keyName = "video_player_system_pure",
    moduleName = "client.slua.umg.common.video_player_system_pure",
    path = "/Game/UMG/UI_BP/Common/VideoPlayerSystemPure.VideoPlayerSystemPure",
    containerName = UIContainers.Bottom,
    uiStat = {
      name = "\232\167\134\233\162\145\230\146\173\230\148\190_\231\186\175\229\135\128\231\137\136"
    }
  },
  video_player_system = {
    keyName = "video_player_system",
    moduleName = "client.slua.umg.common.video_player_system",
    path = "/Game/UMG/UI_BP/Common/VideoPlayerSystem.VideoPlayerSystem",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\232\167\134\233\162\145\230\146\173\230\148\190"
    }
  },
  level_sequence_player_system = {
    keyName = "level_sequence_player_system",
    moduleName = "client.slua.umg.common.level_sequence_player_system",
    path = "/Game/UMG/UI_BP/Common/LevelSequencePlayerSystem.LevelSequencePlayerSystem",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\231\137\185\230\128\167\229\138\168\231\148\187\230\146\173\230\148\190"
    }
  },
  video_player_mask = {
    keyName = "video_player_mask",
    moduleName = "client.slua.umg.common.video_player_mask",
    path = "/Game/UMG/UI_BP/Common/VideoMask.VideoMask",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\167\134\233\162\145\230\146\173\230\148\190-\232\146\153\231\137\136"
    }
  },
  ItemGet_Root_UIBP = {
    keyName = "ItemGet_Root_UIBP",
    moduleName = "client.slua.umg.lobby_item.ItemGet_Root_UIBP",
    path = "/Game/UMG/UI_BP/Common/ItemGet/ItemGet_Root_UIBP.ItemGet_Root_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\231\168\128\230\156\137\230\129\173\229\150\156\232\142\183\229\190\151root"
    }
  },
  Rare_Item4_Child = {
    keyName = "Rare_Item4_Child",
    moduleName = "client.slua.umg.lobby_item.Rare_Item4_Child",
    path = "/Game/UMG/UI_BP/Common/ItemGet/Rare_Item4_01_UIBP.Rare_Item4_01_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\168\128\230\156\137\230\129\173\229\150\156\232\142\183\229\190\151-4\231\186\167-\229\138\168\230\149\136"
    }
  },
  Rare_Item4_UIBP = {
    keyName = "Rare_Item4_UIBP",
    moduleName = "client.slua.umg.lobby_item.Rare_Item4_UIBP",
    path = "/Game/UMG/UI_BP/Common/ItemGet/Rare_Item4_02_UIBP.Rare_Item4_02_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\168\128\230\156\137\230\129\173\229\150\156\232\142\183\229\190\151-4\231\186\167"
    }
  },
  ItemGet_Gold_UIBP = {
    keyName = "ItemGet_Gold_UIBP",
    moduleName = "client.slua.umg.lobby_item.ItemGet_Gold_UIBP",
    path = "/Game/UMG/UI_BP/Common/ItemGet/ItemGet_Gold_UIBP.ItemGet_Gold_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\168\128\230\156\137\230\129\173\229\150\156\232\142\183\229\190\151-5\231\186\167"
    }
  },
  ItemGet_PlayEmote_UIBP = {
    keyName = "ItemGet_PlayEmote_UIBP",
    moduleName = "client.slua.umg.lobby_item.ItemGet_PlayEmote_UIBP",
    path = "/Game/UMG/UI_BP/Common/ItemGet/ItemGet_PlayEmote_UIBP.ItemGet_PlayEmote_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\168\128\230\156\137\230\129\173\229\150\156\232\142\183\229\190\151-5\231\186\167-\229\138\168\228\189\156\228\184\147\229\177\158"
    }
  },
  ShareinterfaceFull_Gold_UIBP = {
    keyName = "ShareinterfaceFull_Gold_UIBP",
    moduleName = "client.slua.umg.lobby_item.ShareinterfaceFull_Gold_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/ShareinterfaceFull_Gold_UIBP.ShareinterfaceFull_Gold_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\168\128\230\156\137\231\137\169\229\147\129-5\231\186\167\229\136\134\228\186\171"
    }
  },
  ShareinterfaceFull_Rare4_Item_UIBP = {
    keyName = "ShareinterfaceFull_Rare4_Item_UIBP",
    moduleName = "client.slua.umg.lobby_item.ShareinterfaceFull_Rare4_Item_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Item/ShareinterfaceFull_Rare4_Item_UIBP.ShareinterfaceFull_Rare4_Item_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\168\128\230\156\137\231\137\169\229\147\129-4\231\186\167\229\136\134\228\186\171"
    }
  },
  ShareinterfaceFull_Rare3_Item_UIBP = {
    keyName = "ShareinterfaceFull_Rare3_Item_UIBP",
    moduleName = "client.slua.umg.lobby_item.ShareinterfaceFull_Rare3_Item_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Item/ShareinterfaceFull_Rare3_Item_UIBP.ShareinterfaceFull_Rare3_Item_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\168\128\230\156\137\231\137\169\229\147\129-3\231\186\167\229\136\134\228\186\171"
    }
  },
  Rare_Item3_UIBP = {
    keyName = "Rare_Item3_UIBP",
    moduleName = "client.slua.umg.lobby_item.Rare_Item3_UIBP",
    path = "/Game/UMG/UI_BP/Common/ItemGet/Rare_Item3_UIBP.Rare_Item3_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\168\128\230\156\137\230\129\173\229\150\156\232\142\183\229\190\151-3\231\186\167"
    }
  },
  Rare_Item2_UIBP = {
    keyName = "Rare_Item2_UIBP",
    moduleName = "client.slua.umg.lobby_item.Rare_Item2_UIBP",
    path = "/Game/UMG/UI_BP/Common/ItemGet/Rare_Item2_UIBP.Rare_Item2_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\168\128\230\156\137\230\129\173\229\150\156\232\142\183\229\190\151-2\231\186\167"
    }
  },
  ItemGetSeqChild_UIBP = {
    keyName = "ItemGetSeqChild_UIBP",
    moduleName = "client.slua.umg.lobby_item.ItemGetSeqChild_UIBP",
    path = "/Game/UMG/UI_BP/Common/ItemGet/ItemGetSeqChild_UIBP.ItemGetSeqChild_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\168\128\230\156\137\230\129\173\229\150\156\232\142\183\229\190\151sequence\229\173\144\231\149\140\233\157\162"
    }
  },
  com_msg_box_slua = {
    keyName = "com_msg_box_slua",
    moduleName = "client.slua.umg.common.com_msg_box_slua",
    path = "/Game/UMG/UI_BP/Common/Com_MsgBox_Slua_UIBP.Com_MsgBox_Slua_UIBP",
    closeOnSwitch = false,
    containerName = UIContainers.Top,
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\233\128\154\231\148\168\229\188\185\231\170\151"
    }
  },
  com_msg_box_ingame_slua = {
    keyName = "com_msg_box_slua",
    moduleName = "client.slua.umg.common.com_msg_box_slua",
    path = "/Game/Mod/CreativeBase/UMG/Common/Com_UGC_MsgBox_Slua_UIBP.Com_UGC_MsgBox_Slua_UIBP",
    closeOnSwitch = false,
    containerName = UIContainers.Top,
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\233\128\154\231\148\168\229\188\185\231\170\151-WoW\229\177\128\229\134\133"
    }
  },
  Com_MsgBox_Middle_Slua_UIBP = {
    keyName = "Com_MsgBox_Middle_Slua_UIBP",
    moduleName = "client.slua.umg.common.com_msg_box_slua",
    path = "/Game/UMG/UI_BP/Common/Com_MsgBox_Middle_Slua_UIBP.Com_MsgBox_Middle_Slua_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\228\184\173\229\158\139\229\188\185\231\170\151"
    }
  },
  Com_MsgBox_Ingame_Middle_Slua_UIBP = {
    keyName = "Com_MsgBox_Ingame_Middle_Slua_UIBP",
    moduleName = "client.slua.umg.common.com_msg_box_slua",
    path = "/Game/UMG/UI_BP/UGC/Common/Popup/Com_Ugc_MsgBox_Middle_Slua_UIBP.Com_Ugc_MsgBox_Middle_Slua_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\228\184\173\229\158\139\229\188\185\231\170\151-WoW\229\177\128\229\134\133"
    }
  },
  com_msg_small_box_slua = {
    keyName = "com_msg_small_box_slua",
    moduleName = "client.slua.umg.common.com_msg_box_slua",
    path = "/Game/UMG/UI_BP/Common/Com_MsgBox_Small_Slua_UIBP.Com_MsgBox_Small_Slua_UIBP",
    closeOnSwitch = false,
    containerName = UIContainers.Top,
    loadFromPool = EUIConfigPoolType.None,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\233\128\154\231\148\168\229\188\185\231\170\151"
    }
  },
  com_msg_small_box_ingame_slua = {
    keyName = "com_msg_small_box_ingame_slua",
    moduleName = "client.slua.umg.common.com_msg_box_slua",
    path = "/Game/UMG/UI_BP/UGC/Common/Popup/Com_Ugc_MsgBox_Small_Slua_UIBP.Com_Ugc_MsgBox_Small_Slua_UIBP",
    closeOnSwitch = false,
    containerName = UIContainers.Top,
    loadFromPool = EUIConfigPoolType.None,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\233\128\154\231\148\168\229\188\185\231\170\151"
    }
  },
  com_msg_box_5s = {
    keyName = "com_msg_box_5s",
    moduleName = "client.slua.umg.common.com_msg_box_slua",
    path = "/Game/UMG/UI_BP/NewUpdate/Com_MsgBox_Small_5S_UIBP.Com_MsgBox_Small_5S_UIBP",
    closeOnSwitch = false,
    containerName = UIContainers.Top,
    loadFromPool = EUIConfigPoolType.None,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\233\128\154\231\148\168\229\188\185\231\170\151-5S"
    }
  },
  Common_RechargeMsgBox_UIBP = {
    keyName = "Common_RechargeMsgBox_UIBP",
    moduleName = "client.slua.umg.common.Common_RechargeMsgBox_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_UCPurchase_Popup_UIBP.Common_UCPurchase_Popup_UIBP",
    closeOnSwitch = false,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\143\144\231\164\186\229\133\133\229\128\188\229\188\185\231\170\151"
    }
  },
  lobby_sequence_mask = {
    keyName = "lobby_sequence_mask",
    moduleName = "client.slua.umg.lobby_camera.lobby_levelSequenceCameraMask",
    path = "/Game/Arts_Lobby/CookEntry/Widget3D/BP_LevelSequenceCameraMask.BP_LevelSequenceCameraMask",
    uiStat = {
      name = "levelsequence\228\189\191\231\148\168\231\154\132mask\231\149\140\233\157\162"
    }
  },
  Com_MsgBox_Slua_checkout__UIBP = {
    keyName = "Com_MsgBox_Slua_checkout__UIBP",
    moduleName = "client.slua.umg.common.Com_MsgBox_Slua_checkout__UIBP",
    path = "/Game/UMG/UI_BP/Common/Com_MsgBox_Slua_checkout__UIBP.Com_MsgBox_Slua_checkout__UIBP",
    containerName = UIContainers.Top,
    closeOnSwitch = false,
    uiStat = {
      name = "\233\128\154\231\148\168\229\188\185\231\170\151-\231\153\187\229\135\186\230\137\128\230\156\137\232\174\190\229\164\135"
    }
  },
  Common_HelpTips_UIBP = {
    keyName = "Common_HelpTips_UIBP",
    moduleName = "client.slua.umg.common.Common_HelpTips_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_HelpTips_UIBP.Common_HelpTips_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\128\154\231\148\168\229\184\174\229\138\169\230\143\144\231\164\186"
    }
  },
  Common_HelpTips_Ingame_UIBP = {
    keyName = "Common_HelpTips_Ingame_UIBP",
    moduleName = "client.slua.umg.common.Common_HelpTips_UIBP",
    path = "/Game/UMG/UI_BP/UGC/Common/Popup/Tips/Common_Ugc_HelpTips_UIBP.Common_Ugc_HelpTips_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\128\154\231\148\168\229\184\174\229\138\169\230\143\144\231\164\186-WoW\229\177\128\229\134\133"
    }
  },
  Common_Announcement_UIBP = {
    keyName = "Common_Announcement_UIBP",
    moduleName = "client.slua.umg.common.Common_Announcement_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Announcement_UIBP.Common_Announcement_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\229\133\172\229\145\138\229\188\185\231\170\151"
    }
  },
  Common_Announcement_Item = {
    keyName = "Common_Announcement_Item",
    moduleName = "client.slua.umg.common.Common_Announcement_Item",
    path = "/Game/UMG/UI_BP/Common/Items/Common_Announcement_Item.Common_Announcement_Item",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\230\174\181\228\189\141\229\136\135\230\141\162\230\140\137\233\146\174"
    }
  },
  Lobby_IntimacyItem_UIBP = {
    keyName = "Lobby_IntimacyItem_UIBP",
    moduleName = "client.slua.umg.common.Lobby.Lobby_IntimacyItem_UIBP",
    path = "/Game/UMG/UI_BP/Common/Items/Lobby_IntimacyItem_UIBP.Lobby_IntimacyItem_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\228\186\178\229\175\134\229\133\179\231\179\187Item"
    },
    isMainUI = false,
    isSingleton = false,
    AndroidBackType = EAndroidBackType.Skip
  },
  Common_Tab_Horizontal_LevelOne_Text_Item_UIBP = {
    keyName = "Common_Tab_Horizontal_LevelOne_Text_Item_UIBP",
    moduleName = "client.slua.umg.common.Common_Tab_Horizontal_LevelOne_Text_Item_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tab/Horizontal/LevelOne/Text/Item/Common_Tab_Horizontal_LevelOne_Text_Item_UIBP.Common_Tab_Horizontal_LevelOne_Text_Item_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\230\168\170\229\144\145\228\184\128\231\186\167\233\161\181\231\173\190Item"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  Common_Tab_Horizontal_LevelTwo_Text_Item_UIBP = {
    keyName = "Common_Tab_Horizontal_LevelTwo_Text_Item_UIBP",
    moduleName = "client.slua.umg.common.Common_Tab_Horizontal_LevelTwo_Text_Item_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tab/Horizontal/LevelTwo/Text/Item/Common_Tab_Horizontal_LevelTwo_Text_Item_UIBP.Common_Tab_Horizontal_LevelTwo_Text_Item_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\230\168\170\229\144\145\228\186\140\231\186\167\233\161\181\231\173\190Item"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  Common_Tab_Horizontal_LevelThree_Text_Item_UIBP = {
    keyName = "Common_Tab_Horizontal_LevelThree_Text_Item_UIBP",
    moduleName = "client.slua.umg.common.Common_Tab_Horizontal_LevelThree_Text_Item_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tab/Horizontal/LevelThree/Text/Item/Common_Tab_Horizontal_LevelThree_Text_Item_UIBP.Common_Tab_Horizontal_LevelThree_Text_Item_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\230\168\170\229\144\145\228\184\137\231\186\167\231\186\167\233\161\181\231\173\190Item"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  Common_Tab_Horizontal_LevelThree_Text_Padding_Item_UIBP = {
    keyName = "Common_Tab_Horizontal_LevelThree_Text_Padding_Item_UIBP",
    moduleName = "client.slua.umg.common.Common_Tab_Horizontal_LevelThree_Text_Padding_Item_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tab/Horizontal/LevelThree/Text/Item/Common_Tab_Horizontal_LevelThree_Text_Padding_Item_UIBP.Common_Tab_Horizontal_LevelThree_Text_Padding_Item_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\230\168\170\229\144\145\228\184\137\231\186\167\231\186\167\233\161\181\231\173\190Item"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  Common_Tab_Horizontal_LevelOne_Icon_Item_UIBP = {
    keyName = "Common_Tab_Horizontal_LevelOne_Icon_Item_UIBP",
    moduleName = "client.slua.umg.common.Common_Tab_Horizontal_LevelOne_Icon_Item_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tab/Horizontal/LevelOne/Horizontal_Icon/Item/Common_Tab_Horizontal_LevelOne_Icon_Item_UIBP.Common_Tab_Horizontal_LevelOne_Icon_Item_UIBP",
    uiStat = {
      name = "ICON\231\177\187\229\158\139\231\154\132\233\128\154\231\148\168\230\168\170\229\144\145\228\184\128\231\186\167\233\161\181\231\173\190Item"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  Common_Tab_Horizontal_Small_Text_Item_UIBP = {
    keyName = "Common_Tab_Horizontal_Small_Text_Item_UIBP",
    moduleName = "client.slua.umg.common.Common_Tab_Horizontal_Text_Item_Base",
    path = "/Game/UMG/UI_BP/Common/Tab/Horizontal/Small/Common_Tab_Horizontal_Small_Text_Item_UIBP.Common_Tab_Horizontal_Small_Text_Item_UIBP",
    uiStat = {
      name = "Common_Tab_Horizontal_Small_Text_Item_UIBP"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  Common_Tab_Horizontal_Custom_Item_UIBP = {
    keyName = "Common_Tab_Horizontal_Custom_Item_UIBP",
    moduleName = "client.slua.umg.common.Common_Tab_Horizontal_Custom_Item_Base",
    path = "/Game/UMG/UI_BP/Common/Tab/Horizontal/LevelOne/Text/Item/Common_Tab_Horizontal_LevelOne_Text_Item_UIBP.Common_Tab_Horizontal_LevelOne_Text_Item_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\230\168\170\229\144\145\228\184\128\231\186\167\233\161\181\231\173\190Item"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  dropdown_menu_component = {
    keyName = "dropdown_menu_component",
    moduleName = "client.slua.umg.common.dropdown_menu_component",
    path = "/Game/UMG/UI_BP/Lobby/Item/DropDown_Menu_UIBP.DropDown_Menu_UIBP",
    isSingleton = false
  },
  integral_float_tips = {
    keyName = "integral_float_tips",
    moduleName = "client.slua.umg.person_space.integral_float_tips",
    path = "/Game/UMG/UI_BP/PersonSpace/item/RisesAstral_Tips_UIBP.RisesAstral_Tips_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\230\174\181\228\189\141\230\181\174\231\170\151"
    }
  },
  recharge_help_pay = {
    keyName = "recharge_help_pay",
    moduleName = "client.slua.umg.recharge.recharge_help_pay",
    path = "/Game/UMG/UI_BP/Lobby_Store_Int/Lobby_Store_Int_CentauriBuy.Lobby_Store_Int_CentauriBuy"
  },
  invite_team = {
    keyName = "invite_team",
    moduleName = "client.slua.umg.friend.invite_team",
    path = "/Game/UMG/UI_BP/Common/Common_Invite_UIBP.Common_Invite_UIBP",
    asy = true
  },
  community_commercial_uibp = {
    keyName = "ReturnActivity_Player_Tag_Item",
    moduleName = "client.slua.umg.community.community_commercial_uibp",
    path = "/Game/UMG/UI_BP/Common/ComponentEntrance/ComponentCommercial_UIBP.ComponentCommercial_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    asy = true,
    uiStat = {
      name = "\229\149\134\228\184\154\229\140\150\231\187\132\228\187\182\229\133\165\229\143\163"
    }
  },
  Lobby_Popup_Theme_FriendGift_UIBP = {
    keyName = "Lobby_Popup_Theme_FriendGift_UIBP",
    moduleName = "client.slua.umg.lobby.Lobby_Popup_Theme_FriendGift_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Lobby_Popup_Theme_FriendGift_UIBP.Lobby_Popup_Theme_FriendGift_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\229\165\189\229\143\139\228\190\167\230\160\143-\229\191\171\230\141\183\232\181\160\231\164\188"
    }
  },
  data_migration = {
    keyName = "data_migration",
    moduleName = "client.slua.umg.data_migration.data_migration_ui",
    path = "/Game/UMG/UI_BP/Common/Common_AccountMigration_UIBP.Common_AccountMigration_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\230\149\176\230\141\174\232\191\129\231\167\187"
    }
  },
  CreateRoleAvatarSelect = {
    keyName = "CreateRoleAvatarSelect",
    moduleName = "client.slua.umg.create_role.avatar_select",
    path = "/Game/UMG/UI_BP/Lobby/SelectRoles_UIBP.SelectRoles_UIBP",
    uiStat = {
      name = "\229\136\155\229\187\186\232\167\146\232\137\178\229\164\180\229\131\143\233\128\137\230\139\169"
    }
  },
  login_download_choice = {
    keyName = "login_download_choice",
    moduleName = "client.slua.umg.login.login_download_choice",
    path = "/Game/UMG/UI_BP/Lobby/DownloadPopupNotice_BP.DownloadPopupNotice_BP"
  },
  supply_guarantee_awardInfo = {
    keyName = "supply_guarantee_awardInfo",
    moduleName = "client.slua.umg.shop.supply_guarantee_awardInfo",
    path = "/Game/UMG/UI_BP/Store/Item/Store_PROT_Reward_Popup_UIBP.Store_PROT_Reward_Popup_UIBP",
    uiStat = {
      name = "\232\161\165\231\187\153-\228\191\157\229\186\149\229\165\150\229\138\177\233\162\132\232\167\136"
    }
  },
  ShapeTrans_ColorChangeCloth_UIBP = {
    keyName = "ShapeTrans_ColorChangeCloth_UIBP",
    moduleName = "client.slua.traits.DetailComponent.DetailChild.ShapeTrans_ColorChangeCloth_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_AvatarDetail/ShapeTrans_ColorChangeCloth_UIBP.ShapeTrans_ColorChangeCloth_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "AvatarDetail - \232\161\163\230\156\141\231\177\187\229\189\162\230\128\129\232\189\172\230\141\162"
    }
  },
  ColorChangeWeaponComponent = {
    keyName = "ColorChangeWeaponComponent",
    moduleName = "client.slua.traits.DetailComponent.ColorChangeWeaponComponenet.ColorChangeWeaponComponent",
    path = "/Game/UMG/UI_BP/Common/Common_Detail_Feature02.Common_Detail_Feature02",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\229\161\148\231\189\151\229\188\130\232\137\178\230\158\170\231\154\174"
    }
  },
  SupplyActivityComp = {
    keyName = "SupplyActivityComp",
    moduleName = "client.slua.umg.NewStoreV280.Components.SupplyActivityComp.SupplyActivityComp",
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_GuaranteeMechanism_UIBP.Crate_GuaranteeMechanism_UIBP",
    isSingleton = false,
    asy = false,
    uiStat = {
      name = "\232\161\165\231\187\153-\230\180\187\229\138\168\230\156\186\229\136\182\231\187\132\228\187\182"
    }
  },
  supply_ban_component = {
    keyName = "supply_ban_component",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.supply.supply_ban_component",
    path = "/Game/UMG/UI_BP/Store/Item/Crate_GuaranteeMechanism_ban_UIBP.Crate_GuaranteeMechanism_ban_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\232\161\165\231\187\153-Ban\230\156\186\229\136\182\231\187\132\228\187\182"
    }
  },
  supply_select_panel = {
    keyName = "supply_select_panel",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.supply.supply_select_panel",
    path = "/Game/UMG/UI_BP/Store/Store_Common_Child2_Panel.Store_Common_Child2_Panel",
    isSingleton = false,
    uiStat = {
      name = "\232\161\165\231\187\153-\233\128\137\230\139\169\231\149\140\233\157\162"
    }
  },
  common_selection_setting = {
    keyName = "common_selection_setting",
    moduleName = "client.slua.umg.common.common_selection_setting",
    path = "/Game/UMG/UI_BP/ModeSelection/Match_SelectMap_01_UIBP.Match_SelectMap_01_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\232\174\190\231\189\174"
    }
  },
  Common_Gift_Info_UIBP = {
    keyName = "Common_Gift_Info_UIBP",
    moduleName = "client.slua.umg.gift.Common_Gift_Info_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Common_Gift_Info_UIBP.Common_Gift_Info_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\231\164\188\231\137\169\228\191\161\230\129\175\229\177\149\231\164\186"
    }
  },
  Common_Gift_Notice_UIBP = {
    keyName = "Common_Gift_Notice_UIBP",
    moduleName = "client.slua.umg.gift.Common_Gift_Notice_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Common_Gift_Notice_UIBP.Common_Gift_Notice_UIBP",
    isSingleton = false,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\181\160\231\164\188\230\143\144\231\164\186\230\181\174\231\170\151"
    }
  },
  avatar_social_island_status = {
    keyName = "avatar_social_island_status",
    moduleName = "client.slua.umg.person_space.avatar_social_island_status",
    path = "/Game/UMG/UI_BP/PersonSpace/Lobby_Space_SocialIsland_UIBP.Lobby_Space_SocialIsland_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isMainUI = false,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\229\178\155\229\177\191\231\138\182\230\128\129"
    }
  },
  SpecialOffer_DownloadTip_UIBP = {
    keyName = "SpecialOffer_DownloadTip_UIBP",
    moduleName = "client.slua.umg.special_offer.SpecialOffer_DownloadTip_UIBP",
    path = "/Game/UMG/UI_BP/SpecialOffer/SpecialOffer_DownloadTip_UIBP.SpecialOffer_DownloadTip_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\137\185\230\131\160-\228\184\139\232\189\189\231\149\140\233\157\162"
    }
  },
  SpecialOffer_ValueRebate_Common_Item_UIBP = {
    keyName = "SpecialOffer_ValueRebate_Common_Item_UIBP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/SpecialOffer/Item/SpecialOffer_ValueRebate_Common_Item_UIBP.SpecialOffer_ValueRebate_Common_Item_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\182\136\232\180\185\232\191\148\229\136\169Item_\230\140\130\232\189\189common_item"
    }
  },
  SpecialOffer_Material_Popup_UIBP = {
    keyName = "SpecialOffer_Material_Popup_UIBP",
    moduleName = "client.slua.umg.special_offer.acts.SpecialOffer_Material_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Exchange_Confirm_UIBP.Common_Exchange_Confirm_UIBP",
    asy = true,
    uiStat = {
      name = "\230\157\144\230\150\153\231\164\188\229\140\133\232\180\173\228\185\176\229\188\185\231\170\151"
    }
  },
  SpecialOffer_Conditions_Reward_Tips_UIBP = {
    keyName = "SpecialOffer_Conditions_Reward_Tips_UIBP",
    moduleName = "client.slua.umg.special_offer.condition_gift.SpecialOffer_Conditions_Reward_Tips_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Conditions/UIBP/Item/SpecialOffer_Conditions_Reward_Tips_UIBP.SpecialOffer_Conditions_Reward_Tips_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\230\157\161\228\187\182\231\164\188\229\140\133 \232\180\173\228\185\176\229\144\142\229\143\175\231\171\139\229\141\179\232\142\183\229\190\151\231\154\132\229\165\150\229\138\177"
    }
  },
  common_vehicle_get_panel = {
    keyName = "common_vehicle_get_panel",
    moduleName = "client.slua.umg.lobby_item.common_vehicle_get_panel",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Form_UIBP.Lucky_Common_Form_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\128\154\231\148\168\232\189\189\229\133\183\232\142\183\229\190\151\231\149\140\233\157\162"
    }
  },
  common_vehicle_give_panel = {
    keyName = "common_vehicle_give_panel",
    moduleName = "client.slua.umg.lobby_item.common_vehicle_give_panel",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Form_UIBP.Lucky_Common_Form_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\232\189\189\229\133\183\232\181\160\233\128\129\231\149\140\233\157\162"
    }
  },
  Common_Popup_Permissionsprompt_UIBP = {
    keyName = "Common_Popup_Permissionsprompt_UIBP",
    moduleName = "client.slua.umg.common.Common_Popup_Permissionsprompt_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Popup_Permissionsprompt_UIBP.Common_Popup_Permissionsprompt_UIBP",
    closeOnSwitch = false,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\128\154\231\148\168\230\157\131\233\153\144\229\188\185\231\170\151"
    }
  },
  ui_subscribe_confirm_buy = {
    keyName = "ui_subscribe_confirm_buy",
    moduleName = "client.slua.umg.subscribe.ui_subscribe_confirm_buy",
    path = "/Game/UMG/UI_BP/Common/Common_MessageBox_115_UIBP.Common_MessageBox_115_UIBP"
  },
  LobbyAndroidGuestBind = {
    keyName = "LobbyAndroidGuestBind",
    moduleName = "client.slua.umg.guest_bind.guest_bind_form",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Form_UIBP.Lucky_Common_Form_UIBP",
    uiStat = {
      name = "\229\188\149\229\175\188\229\174\137\229\141\147\230\184\184\229\174\162\231\148\168\230\136\183\231\187\145\229\174\154\231\149\140\233\157\162 - \231\169\186"
    }
  },
  ui_subscribe_carnival_reward = {
    keyName = "ui_subscribe_carnival_reward",
    moduleName = "client.slua.umg.subscribe_activity.ui_subscribe_carnival_reward",
    path = "/Game/UMG/UI_BP/Lobby_Store_Int/Store_3/Lobby_Subscription_Reward_UIBP.Lobby_Subscription_Reward_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\232\174\162\233\152\133\231\139\130\230\172\162\232\138\130\230\180\187\229\138\168-\229\143\179\228\190\167\229\165\150\229\138\177\229\173\144\231\149\140\233\157\162"
    }
  },
  Setting_ChangeServerHint = {
    keyName = "Setting_ChangeServerHint",
    moduleName = "client.slua.umg.setting.Setting_ChangeServerHint",
    path = "/Game/UMG/UI_BP/Common/Popup/Common_Popup_ChangeServer_UIBP.Common_Popup_ChangeServer_UIBP",
    asy = true,
    uiStat = {
      name = "\232\174\190\231\189\174-\232\174\190\231\189\174\230\136\152\230\150\151\230\156\141\229\188\185\231\170\151-\229\136\135\230\141\162\230\156\141\229\138\161\229\153\168\231\161\174\232\174\164\231\149\140\233\157\162"
    }
  },
  Setting_Common_Popup_Large_UIBP = {
    keyName = "Setting_Common_Popup_Large_UIBP",
    moduleName = "client.slua.umg.setting.Popup.Setting_Common_Popup_Large_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Popup/Setting_Common_Popup_Large_UIBP.Setting_Common_Popup_Large_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\180\166\229\143\183\230\149\143\230\132\159\230\147\141\228\189\156-\228\184\187\231\149\140\233\157\162"
    }
  },
  Vehicle_Accessory_ItemList_UIBP = {
    keyName = "Vehicle_Accessory_ItemList_UIBP",
    moduleName = "client.slua.umg.vehicle.Accessory.Vehicle_Accessory_ItemList_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/AccessoryItem/Vehicle_Accessory_ItemList_UIBP.Vehicle_Accessory_ItemList_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\189\189\229\133\183-\233\133\141\228\187\182\231\149\140\233\157\162-\229\186\149\233\131\168\233\133\141\228\187\182"
    }
  },
  new_player_gifts_panel = {
    keyName = "new_player_gifts_panel",
    moduleName = "client.slua.umg.growth_project.new_player_gifts_panel",
    path = "/Game/UMG/UI_BP/Guide/Common_Return_Popup_UIBP.Common_Return_Popup_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\229\188\149\229\175\188-\228\184\137\233\128\137\228\184\128\231\149\140\233\157\162"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  Common_NewbieGuide_Tips_UIBP = {
    keyName = "Common_NewbieGuide_Tips_UIBP",
    moduleName = "client.slua.umg.Universal_Popup.Common_NewbieGuide_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_NewbieGuide_Tips_UIBP.Common_NewbieGuide_Tips_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\230\150\176\230\137\139\233\166\150\229\177\128\230\142\146\228\189\141-\230\143\144\231\164\186\229\188\185\231\170\151"
    }
  },
  Common_Item_Guide_BP = {
    keyName = "Common_Item_Guide_BP",
    moduleName = "client.slua.umg.growth_project.Common_Item_Guide_BP",
    path = "/Game/UMG/UI_BP/Guide/Common_Item_Guide_BP.Common_Item_Guide_BP",
    uiStat = {
      name = "\229\162\158\233\149\191\228\184\147\233\161\185-\230\150\176\230\137\139\229\188\149\229\175\188-\228\187\147\229\186\147\229\188\149\229\175\188Item"
    }
  },
  Common_Item_GuideHand_BP = {
    keyName = "Common_Item_GuideHand_BP",
    moduleName = "client.slua.umg.growth_project.Common_Item_GuideHand_BP",
    path = "/Game/UMG/UI_BP/Guide/Common_Item_GuideHand_BP.Common_Item_GuideHand_BP",
    isSingleton = false,
    uiStat = {
      name = "\229\162\158\233\149\191\228\184\147\233\161\185-\230\137\139\230\140\135\231\137\185\230\149\136"
    }
  },
  Common_Item_GuideSweepGlow_BP = {
    keyName = "Common_Item_GuideHand_BP",
    moduleName = "client.slua.umg.growth_project.Common_Item_GuideSweepGlow_BP",
    path = "/Game/UMG/UI_BP/Guide/Common_Item_GuideSweepGlow_BP.Common_Item_GuideSweepGlow_BP",
    isSingleton = false,
    uiStat = {
      name = "\229\162\158\233\149\191\228\184\147\233\161\185-\230\137\171\229\133\137\231\137\185\230\149\136"
    }
  },
  Common_Welcome_UIBP = {
    keyName = "Common_Welcome_UIBP",
    moduleName = "client.slua.umg.growth_project.Common_Welcome_UIBP",
    path = "/Game/UMG/UI_BP/Guide/Common_Welcome_UIBP.Common_Welcome_UIBP",
    asy = true,
    uiStat = {
      name = "\230\150\176\230\137\139\228\184\137\233\128\137\228\184\128-Common_Welcome_UIBP"
    }
  },
  assembly_share_component_jk = {
    keyName = "assembly_share_component_jk",
    moduleName = "client.slua.umg.activity.assembly.jk.assembly_share_component_jk",
    path = "/Game/UMG/UI_BP/Lobby/Shareinterface_UIBP_New.Shareinterface_UIBP_New",
    uiStat = {
      name = "\229\143\172\229\155\158\230\180\187\229\138\168-\230\151\165\233\159\169\231\139\172\231\171\139\229\143\172\229\155\158-\229\136\134\228\186\171\231\187\132\228\187\182"
    }
  },
  webview_share_component = {
    keyName = "webview_share_component",
    moduleName = "client.slua.umg.common.webview_share_component",
    path = "/Game/UMG/UI_BP/Lobby/Shareinterface_UIBP_New.Shareinterface_UIBP_New",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\136\134\228\186\171-Webview\231\189\145\233\161\181"
    }
  },
  assembly_share_component = {
    keyName = "assembly_share_component",
    moduleName = "client.slua.umg.activity.assembly.assembly_share_component",
    path = "/Game/UMG/UI_BP/Lobby/Shareinterface_UIBP_New.Shareinterface_UIBP_New"
  },
  share_component = {
    keyName = "share_component",
    moduleName = "client.slua.umg.common.share.Shareinterface",
    path = "/Game/UMG/UI_BP/Lobby/Shareinterface_UIBP_New.Shareinterface_UIBP_New",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\233\128\154\231\148\168\229\136\134\228\186\171\231\187\132\228\187\182"
    }
  },
  watermark_share_component = {
    keyName = "watermark_share_component",
    moduleName = "client.slua.umg.common.watermark_share_component",
    path = "/Game/UMG/UI_BP/Lobby/Shareinterface_WaterMark_UIBP.Shareinterface_WaterMark_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\128\154\231\148\168\229\136\134\228\186\171\230\176\180\229\141\176\231\187\132\228\187\182"
    }
  },
  Common_MessageBox_News_UIBP = {
    keyName = "Common_MessageBox_News_UIBP",
    moduleName = "client.slua.umg.common.Common_MessageBox_News_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_MessageBox_News_UIBP_new.Common_MessageBox_News_UIBP_new",
    uiStat = {
      name = "pass-\232\174\162\233\152\133\229\146\140New\228\189\191\231\148\168\231\154\132\229\188\185\231\170\151"
    },
    asy = true
  },
  RoomModeListItem_BP = {
    keyName = "RoomModeListItem_BP",
    moduleName = "client.slua.umg.room.item.RoomModeListItem_BP",
    path = "/Game/UMG/UI_BP/Room/Item/RoomModeListItem_BP.RoomModeListItem_BP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\230\168\161\229\188\143\228\184\139\230\139\137Item"
    }
  },
  item_upgrade_material_component = {
    keyName = "item_upgrade_material_component",
    moduleName = "client.slua.umg.upgrade.item_upgrade_material_component",
    path = "/Game/UMG/UI_Logic/Wardrobe/Item_Upgrade_Material_Component.Item_Upgrade_Material_Component",
    isSingleton = false,
    isMainUI = false
  },
  item_upgrade_material_component2 = {
    keyName = "item_upgrade_material_component2",
    moduleName = "client.slua.umg.upgrade.item_upgrade_material_component2",
    path = "/Game/UMG/UI_Logic/Wardrobe/Item_Upgrade_Material_Comp2.Item_Upgrade_Material_Comp2",
    isSingleton = false,
    isMainUI = false
  },
  BlackFriday_Gun_BoxExchange_UIBP = {
    keyName = "BlackFriday_Gun_BoxExchange_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Gun.BlackFriday_Gun_BoxExchange_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Exchange_New_UIBP.Common_Exchange_New_UIBP",
    jumpModuleID = BP_ENUM_MODULE_BLACK_FRIDAY_GUN_CHOOSE,
    asy = true,
    uiStat = {
      name = "\233\187\1455-\232\189\172\231\155\152-\229\133\145\230\141\162\231\149\140\233\157\162"
    }
  },
  BlackFriday_SubscribeImmediateReward_UIBP = {
    keyName = "BlackFriday_SubscribeImmediateReward_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Subscribe.Item.BlackFriday_SubscribeImmediateReward_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Subscribe/Item/BlackFriday_SubscribeImmediateReward_UIBP.BlackFriday_SubscribeImmediateReward_UIBP",
    isSingleton = false,
    isMainUI = false,
    asyasy = true,
    uiStat = {
      name = "\233\187\145\228\186\148-\232\174\162\233\152\133\231\171\139\229\190\151\229\165\150\229\138\177item"
    }
  },
  Common_Popup_Chat_Poke = {
    keyName = "Common_Popup_Chat_Poke",
    moduleName = "client.slua.umg.lobby_chat.Common_Popup_Chat_Poke",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Explain_UIBP.Common_Popup_Theme_Explain_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\136\179\228\184\128\230\136\179\230\150\176\230\137\139\229\188\149\229\175\188"
    }
  },
  privilege_shop = {
    keyName = "privilege_shop",
    moduleName = "client.slua.umg.esports_privileges.privilege_shop",
    path = "/Game/UMG/UI_BP/GamingEsportVIP/EsportVIP_reward_exchange_UIBP.EsportVIP_reward_exchange_UIBP",
    uiStat = {
      name = "\231\148\181\231\171\158\231\137\185\230\157\131-\229\149\134\229\159\142"
    }
  },
  barrage_main = {
    keyName = "barrage_main",
    moduleName = "client.slua.umg.barrage.barrage_main",
    path = "/Game/UMG/UI_BP/Common/Common_Barrage_UIBP.Common_Barrage_UIBP",
    containerName = UIContainers.Top,
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\231\148\168-\229\188\185\229\185\149"
    }
  },
  barrage_entity = {
    keyName = "barrage_entity",
    moduleName = "client.slua.umg.barrage.barrage_entity",
    path = "/Game/UMG/UI_BP/Common/Common_Barrage_Item_UIBP.Common_Barrage_Item_UIBP",
    isSingleton = false,
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.item_pool,
    showVisibility = Collapsed,
    uiStat = {
      name = "\233\128\154\231\148\168-\229\188\185\229\185\149-Item"
    }
  },
  Weapon_Diy_Operate_Circle = {
    keyName = "Weapon_Diy_Operate_Circle",
    moduleName = "client.slua.umg.WeaponDIY.component.weapon_diy_oprate_circle",
    path = "/Game/UMG/UI_BP/GunDIY/GunDIY_RingSetting_UIBP.GunDIY_RingSetting_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\230\158\170\230\162\176diy\226\128\148circle"
    }
  },
  weapon_diy_edit_component = {
    keyName = "weapon_diy_edit_component",
    moduleName = "client.slua.umg.WeaponDIY.component.weapon_diy_edit_component",
    path = "/Game/UMG/UI_BP/GunDIY/GunDiy_EditDetail_Component.GunDiy_EditDetail_Component",
    uiStat = {
      name = "\230\158\170\230\162\176diy-\231\188\150\232\190\145\231\149\140\233\157\162\228\184\139\230\150\185\231\187\132\228\187\182"
    }
  },
  weapon_diy_component_layer = {
    keyName = "weapon_diy_component_layer",
    moduleName = "client.slua.umg.WeaponDIY.component.weapon_diy_component_layer",
    path = "/Game/UMG/UI_BP/GunDIY/GunDIY_CustomLayer_UIBP.GunDIY_CustomLayer_UIBP",
    uiStat = {
      name = "\230\158\170\230\162\176diy-\229\155\190\229\177\130\231\187\132\228\187\182\231\149\140\233\157\162"
    }
  },
  gesture_operate_component = {
    keyName = "gesture_operate_component",
    moduleName = "client.slua.umg.WeaponDIY.component.gesture_operate_component",
    path = "/Game/UMG/UI_BP/Vehicle/DetailShow/Gesture_Operate_Component_UIBP.Gesture_Operate_Component_UIBP",
    isSingleton = false,
    isMainUI = false
  },
  GestureOperateComp = {
    keyName = "GestureOperateComp",
    moduleName = "client.slua.umg.ugc.creator.personal.Component.GestureOperateComp",
    path = "/Game/UMG/UI_BP/Vehicle/DetailShow/Gesture_Operate_Component_UIBP.Gesture_Operate_Component_UIBP",
    isSingleton = false,
    isMainUI = false
  },
  ItemUpgrade_KillCounter_UIBP = {
    keyName = "ItemUpgrade_KillCounter_UIBP",
    moduleName = "client.slua.umg.upgrade.ItemUpgrade_KillCounter_UIBP",
    path = "/Game/UMG/UI_BP/NewItemUpgrade/ItemUpgrade_UI_CollectRewards_UIBP.ItemUpgrade_UI_CollectRewards_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\160\148\231\169\182\230\137\128-\229\135\187\230\157\128\231\137\185\230\128\167\229\173\144\233\161\181\233\157\162"
    }
  },
  Collect_Award_Preview_KillCounter_Item = {
    keyName = "Collect_Award_Preview_KillCounter_Item",
    moduleName = "client.slua.umg.KillCounter.Common_KillCounter_Item",
    path = "/Game/UMG/UI_BP/NewItemUpgrade/Common_KillCounter_Item.Common_KillCounter_Item",
    isMainUI = false,
    uiStat = {
      name = "\229\135\187\230\157\128\232\174\161\230\149\176\229\153\168\233\162\132\232\167\136item"
    }
  },
  ItemUpgrade_LastKillEffects_UIBP = {
    keyName = "ItemUpgrade_LastKillEffects_UIBP",
    moduleName = "client.slua.umg.upgrade.ItemUpgrade_LastKillEffects_UIBP",
    path = "/Game/UMG/UI_BP/NewItemUpgrade/ItemUpgrade_UI_CollectRewards_UIBP.ItemUpgrade_UI_CollectRewards_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\160\148\231\169\182\230\137\128-\229\141\142\228\184\189\232\176\162\229\185\149\229\173\144\233\161\181\233\157\162"
    }
  },
  ItemUpgrade_EliminationKing_UIBP = {
    keyName = "ItemUpgrade_EliminationKing_UIBP",
    moduleName = "client.slua.umg.upgrade.ItemUpgrade_EliminationKing_UIBP",
    path = "/Game/UMG/UI_BP/NewItemUpgrade/ItemUpgrade_UI_CollectRewards_UIBP.ItemUpgrade_UI_CollectRewards_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\160\148\231\169\182\230\137\128-\230\183\152\230\177\176\231\142\139\230\146\173\230\138\165\229\173\144\233\161\181\233\157\162"
    }
  },
  AsyncSpinContainerBack = {
    keyName = "AsyncSpinContainerBack",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Container.AsyncSpinContainerBack",
    jumpModuleID = BP_ENUM_MODULE_LUCKY_BACK,
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150-2300\231\137\136\233\128\154\231\148\168\229\188\130\230\173\165\229\174\185\229\153\168-\230\148\190\229\155\158"
    }
  },
  AttachedAsyncSpinContainerBack = {
    keyName = "AttachedAsyncSpinContainerBack",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Container.AsyncSpinContainerBack",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\143\175\230\140\130\232\189\189\230\148\190\229\155\158\230\138\189\229\165\150-2300\231\137\136\233\128\154\231\148\168\229\188\130\230\173\165\229\174\185\229\153\168-\230\148\190\229\155\158"
    }
  },
  AsyncSpinContainerMulti = {
    keyName = "AsyncSpinContainerMulti",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Container.AsyncSpinContainerMulti",
    jumpModuleID = BP_ENUM_MODULE_LUCKY_MULTI,
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150-2300\231\137\136\233\128\154\231\148\168\229\188\130\230\173\165\229\174\185\229\153\168-\229\164\154\229\165\150\230\177\160"
    }
  },
  AsyncSpinContainerMix = {
    keyName = "AsyncSpinContainerMix",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Container.AsyncSpinContainerMix",
    jumpModuleID = BP_ENUM_MODULE_LUCKY_MIX,
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150-2300\231\137\136\233\128\154\231\148\168\229\188\130\230\173\165\229\174\185\229\153\168-\230\183\183\229\144\136"
    }
  },
  AsyncSpinContainerTarotCard = {
    keyName = "AsyncSpinContainerTarotCard",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Container.AsyncSpinContainerTarotCard",
    jumpModuleID = BP_ENUM_MODULE_TAROTCARD_DARWCARD,
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    uiStat = {
      name = "\229\161\148\231\189\151\233\135\145\232\163\133-2800\231\137\136\233\128\154\231\148\168\229\188\130\230\173\165\229\174\185\229\153\168"
    }
  },
  ExchangeContainerMix = {
    keyName = "ExchangeContainerMix",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Container.AsyncExchangeContainerMix",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150-\229\133\145\230\141\162\229\149\134\229\186\151"
    }
  },
  ExchangeContainerBack = {
    keyName = "ExchangeContainerBack",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Container.AsyncExchangeContainerBack",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    jumpModuleID = BP_ENUM_MODULE_LUCKY_BACK_EXCHANGE,
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150-\229\133\145\230\141\162\229\149\134\229\186\151"
    }
  },
  ExchangeContainerBack_Supply = {
    keyName = "ExchangeContainerBack_Supply",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Container.AsyncExchangeContainerBack",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    jumpModuleID = BP_ENUM_MODULE_LUCKY_BACK_EXCHANGE,
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150-\229\133\145\230\141\162\229\149\134\229\186\151"
    }
  },
  ExchangeContainerMulti = {
    keyName = "ExchangeContainerMulti",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Container.AsyncExchangeContainerMulti",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150-\229\133\145\230\141\162\229\149\134\229\186\151"
    }
  },
  AsyncExchangeContainerTarotCard = {
    keyName = "AsyncExchangeContainerTarotCard",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Container.AsyncExchangeContainerTarotCard",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    jumpModuleID = BP_ENUM_MODULE_TAROTCARD_EXCHANGE,
    uiStat = {
      name = "\229\161\148\231\189\151\233\135\145\232\163\133-\229\133\145\230\141\162\229\149\134\229\186\151"
    }
  },
  LuckySpinExchangeDynamicForm = {
    keyName = "LuckySpinExchangeDynamicForm",
    moduleName = "client.slua.umg.lobby_activity.LuckySpin.TraitClassStyle.TC_LuckybackDynamicExchangeForm",
    jumpModuleID = BP_ENUM_MODULE_LUCKY_BACK_EXCHANGE,
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150\229\133\145\230\141\162\230\180\187\229\138\168-2500\231\137\136\233\128\154\231\148\168\229\138\168\230\128\129\230\140\130\232\189\189\233\157\162\230\157\191"
    }
  },
  TC_LuckybackDynamicMainForm_Supply = {
    keyName = "TC_LuckybackDynamicMainForm_Supply",
    moduleName = "client.slua.umg.lobby_activity.LuckySpin.TraitClassStyle.Supply.TC_LuckybackDynamicMainForm_Supply",
    isMainUI = false,
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150-2900\231\137\136\232\161\165\231\187\153\229\138\168\230\128\129\230\140\130\232\189\189\233\157\162\230\157\191"
    }
  },
  LuckySpinRewardBox = {
    keyName = "LuckySpinRewardBox",
    moduleName = "client.slua.umg.lobby_activity.LuckySpin.LuckySpinRewardBox",
    path = "/Game/UMG/UI_BP/Common/LuckyDraw_Reward_popup_item.LuckyDraw_Reward_popup_item",
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150-\231\180\175\232\174\161\229\174\157\231\174\177"
    }
  },
  LuckyMixSpinRewardBox = {
    keyName = "LuckyMixSpinRewardBox",
    moduleName = "client.slua.umg.lobby_activity.LuckySpin.LuckyMixSpinRewardBox",
    path = "/Game/UMG/UI_BP/Common/LuckyDraw_Reward_popup_item.LuckyDraw_Reward_popup_item",
    uiStat = {
      name = "\230\183\183\229\144\136\230\138\189\229\165\150-\231\180\175\232\174\161\229\174\157\231\174\177"
    }
  },
  LuckySpinExchange = {
    keyName = "LuckySpinExchange",
    moduleName = "client.slua.umg.lobby_activity.LuckySpin.LuckySpinExchange",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Activity_Common_LuckyDraw_01.Activity_Common_LuckyDraw_01",
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150-\229\133\145\230\141\162\229\149\134\229\186\151"
    }
  },
  UnbackTraitClassDynamicMainForm = {
    keyName = "UnbackTraitClassDynamicMainForm",
    moduleName = "client.slua.umg.lobby_activity.LuckyUnback.TraitClassStyle.TC_UnbackDynamicMainForm",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150-2400\231\137\136\233\128\154\231\148\168\229\188\130\230\173\165\229\174\185\229\153\168-\228\184\141\230\148\190\229\155\158"
    }
  },
  UnbackTraitClassDynamicEggForm = {
    keyName = "UnbackTraitClassDynamicEggForm",
    moduleName = "client.slua.umg.lobby_activity.LuckyUnback.TraitClassStyle.TC_UnbackDynamicEggForm",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150-\229\189\169\232\155\139-2400\231\137\136\233\128\154\231\148\168\229\188\130\230\173\165\229\174\185\229\153\168-\228\184\141\230\148\190\229\155\158"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  LukcyOptionalTurntableContainer = {
    keyName = "LukcyOptionalTurntableContainer",
    moduleName = "client.slua.umg.lobby_activity.LukcyOptionalTurntable.LukcyOptionalTurntableContainer",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    isMainUI = false,
    BP_ENUM_MODULE_OPTIONAL_TURNTABLE_MAIN,
    uiStat = {
      name = "\232\161\165\231\187\153\232\135\170\233\128\137\229\174\157\231\174\177\232\189\172\231\155\152-\233\128\154\231\148\168\231\169\186\231\153\189\232\147\157\229\155\190\230\161\134\230\158\182"
    }
  },
  TC_LuckyDoubleBlankBase_Supply = {
    keyName = "TC_LuckyDoubleBlankBase_Supply",
    moduleName = "client.slua.umg.lobby_activity.LuckyDouble.TC_LuckyDoubleBlankBase",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\143\140\229\177\130\228\184\141\230\148\190\229\155\158\232\189\172\231\155\152-\233\128\154\231\148\168\231\169\186\231\153\189\232\147\157\229\155\190\230\161\134\230\158\182_\232\161\165\231\187\153"
    }
  },
  LuckyDouble_Discount_Main_UIBP = {
    keyName = "LuckyDouble_Discount_Main_UIBP",
    moduleName = "client.slua.umg.lobby_activity.LuckyDouble.Template.LuckyDouble_Discount_Main_UIBP",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LuckyDoubleTemplate/LuckyDouble_RightLeft_Template/LuckyDouble_Discount_Main_UIBP.LuckyDouble_Discount_Main_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\229\143\140\229\177\130\228\184\141\230\148\190\229\155\158\232\189\172\231\155\152-\231\191\187\231\137\140\230\138\152\230\137\163"
    }
  },
  Common_RightBottom_Tip_Child_UIBP = {
    keyName = "Common_RightBottom_Tip_Child_UIBP",
    moduleName = "client.slua.umg.common.Common_RightBottom_Tip_Child_UIBP",
    path = "",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\143\179\228\184\139\232\167\146\229\188\185\231\170\151-\230\140\130\232\189\189\229\173\144\231\149\140\233\157\162"
    }
  },
  lobby_downloader_btn = {
    keyName = "lobby_downloader_btn",
    moduleName = "client.slua.umg.lobby.Main.lobby_downloader_btn",
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_Downloader_Btn_UIBP.Lobby_Downloader_Btn_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\164\167\229\142\133-\228\184\139\232\189\189\230\130\172\230\181\174\231\170\151\230\140\137\233\146\174"
    }
  },
  Common_Normal_Tips_UIBP = {
    keyName = "Common_Normal_Tips_UIBP",
    moduleName = "client.slua.umg.common.Tips.Common_Normal_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/Common_Normal_Tips_UIBP.Common_Normal_Tips_UIBP",
    uiStat = {
      name = "\229\188\149\229\175\188\230\181\129\231\168\139\230\153\174\233\128\154\230\176\148\230\179\161"
    },
    isSingleton = false
  },
  Common_Special_Tips_UIBP = {
    keyName = "Common_Special_Tips_UIBP",
    moduleName = "client.slua.umg.common.Tips.Common_Special_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/Common_Special_Tips_UIBP.Common_Special_Tips_UIBP",
    uiStat = {
      name = "\229\188\149\229\175\188\230\181\129\231\168\139\233\171\152\231\186\167\230\176\148\230\179\161"
    },
    isSingleton = false
  },
  Common_Popup_02_Item = {
    keyName = "Common_Popup_02_Item",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/Universal_Popup/Item/Common_Popup_02_Item.Common_Popup_02_Item",
    isSingleton = false,
    isMainUI = false
  },
  Common_MsgBox_With_TimeOut_UIBP = {
    keyName = "Common_MsgBox_With_TimeOut_UIBP",
    moduleName = "GameLua.Mod.SocialIsland.Client.UI.Tips.CommonMsgBoxWithTimeOutUIBP",
    path = "/Game/UMG/UI_BP/Common/Popup/Common_MsgBox_With_TimeOut_UIBP.Common_MsgBox_With_TimeOut_UIBP",
    uiStat = {
      name = "\228\186\164\229\143\139\229\178\155-\233\128\154\231\148\168\229\128\146\232\174\161\230\151\182\229\175\185\232\175\157\230\161\134"
    }
  },
  ResultsAddFriendsPopUp = {
    keyName = "ResultsAddFriendsPopUp",
    moduleName = "client.slua.umg.lobby.ResultsAddFriendsPopUp",
    path = "/Game/UMG/UI_BP/Common/Common_AddFriend_UIBP.Common_AddFriend_UIBP",
    uiStat = {
      name = "\231\187\147\231\174\151\229\138\160\229\165\189\229\143\139\229\188\185\231\170\151"
    }
  },
  Music_Player_Musicdownload_Popups_UIBP = {
    keyName = "Music_Player_Musicdownload_Popups_UIBP",
    moduleName = "client.slua.umg.pubgm_music.Music_Player_Musicdownload_Popups_UIBP",
    path = "/Game/UMG/UI_BP/Music_Player/Music_Player_Musicdownload_Popups_UIBP.Music_Player_Musicdownload_Popups_UIBP",
    asy = true,
    uiStat = {
      name = "\233\159\179\228\185\144\231\155\146-\233\159\179\228\185\144\228\191\157\229\173\152\232\191\155\229\186\166\229\188\185\231\170\151"
    }
  },
  Moment_Emoji_Item_BP = {
    keyName = "Moment_Emoji_Item_BP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/Moment/Item/Moment_Emoji_Item_BP.Moment_Emoji_Item_BP",
    isSingleton = false,
    isMainUI = false
  },
  Moment_Edit_Operate_Circle = {
    keyName = "Moment_Edit_Operate_Circle",
    moduleName = "client.slua.umg.moment.component.Moment_Edit_Operate_Circle",
    path = "/Game/UMG/UI_BP/Moment/Moment_RingSetting_UIBP.Moment_RingSetting_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\184\184\230\136\143\231\155\184\229\134\140\231\188\150\232\190\145-Circle"
    }
  },
  Moment_Sticker = {
    keyName = "Moment_Sticker",
    moduleName = "client.slua.umg.moment.component.Moment_Sticker",
    path = "/Game/UMG/UI_BP/Moment/Moment_Sticker.Moment_Sticker",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\184\184\230\136\143\231\155\184\229\134\140\231\188\150\232\190\145-Sticker"
    }
  },
  Common_ItemGet_UIBP = {
    keyName = "Common_ItemGet_UIBP",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_UIBP",
    path = "/Game/UMG/UI_BP/Common/Get/Common_ItemGet_UIBP.Common_ItemGet_UIBP",
    asy = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151"
    }
  },
  Common_ItemGet_BtnChild_TicketGuide = {
    keyName = "Common_ItemGet_BtnChild_TicketGuide",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_BtnChild_TicketGuide",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_BtnChild_TicketGuide.Common_ItemGet_BtnChild_TicketGuide",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\229\165\150\229\136\184\231\177\187\232\142\183\229\190\151\229\144\142\231\154\132\229\137\141\229\190\128\230\140\135\229\188\149"
    }
  },
  Common_ItemGet_CheckBox = {
    keyName = "Common_ItemGet_CheckBox",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_CheckBox",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_CheckBox.Common_ItemGet_CheckBox",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\229\141\149\233\128\137\230\161\134"
    }
  },
  Common_ItemGet_RightTopNum = {
    keyName = "Common_ItemGet_RightTopNum",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_RightTopNum",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_RightTopNum.Common_ItemGet_RightTopNum",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\230\140\137\233\146\174\229\143\179\228\184\138\232\167\146Num\232\167\146\230\160\135"
    }
  },
  Common_ItemGet_BtnStyle_1 = {
    keyName = "Common_ItemGet_BtnStyle_1",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_BtnStyle_1",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_BtnStyle_1.Common_ItemGet_BtnStyle_1",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\230\140\137\233\146\174\231\177\187\229\158\1391"
    }
  },
  Common_ItemGet_BtnStyle_2 = {
    keyName = "Common_ItemGet_BtnStyle_2",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_BtnStyle_2",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_BtnStyle_2.Common_ItemGet_BtnStyle_2",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\230\140\137\233\146\174\231\177\187\229\158\1392"
    }
  },
  Common_ItemGet_BtnStyle_3 = {
    keyName = "Common_ItemGet_BtnStyle_3",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_BtnStyle_3",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_BtnStyle_3.Common_ItemGet_BtnStyle_3",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\230\140\137\233\146\174\231\177\187\229\158\1393"
    }
  },
  Common_ItemGet_ItemListStyle_1 = {
    keyName = "Common_ItemGet_ItemListStyle_1",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_ItemListStyle_1",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_ItemListStyle_1.Common_ItemGet_ItemListStyle_1",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\229\141\149\229\136\151\232\161\168\232\138\130\231\130\185"
    }
  },
  Common_ItemGet_ItemListStyle_2 = {
    keyName = "Common_ItemGet_ItemListStyle_2",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_ItemListStyle_2",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_ItemListStyle_2.Common_ItemGet_ItemListStyle_2",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\229\143\140\229\136\151\232\161\168\232\138\130\231\130\185"
    }
  },
  Common_ItemGet_ItemListStyle_3 = {
    keyName = "Common_ItemGet_ItemListStyle_3",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_ItemListStyle_3",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_ItemListStyle_3.Common_ItemGet_ItemListStyle_3",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\228\184\137\229\136\151\232\161\168\232\138\130\231\130\185"
    }
  },
  Common_ItemGet_AllRewardGroup_UIBP = {
    keyName = "Common_ItemGet_AllRewardGroup_UIBP",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_AllRewardGroup_UIBP",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_AllRewardGroup_UIBP.Common_ItemGet_AllRewardGroup_UIBP",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\229\165\150\229\138\177\229\136\134\231\187\132\229\177\149\231\164\186\233\157\162\230\157\191"
    }
  },
  Common_ItemGet_RewardGroup_UIBP = {
    keyName = "Common_ItemGet_RewardGroup_UIBP",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_RewardGroup_UIBP",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_RewardGroup_UIBP.Common_ItemGet_RewardGroup_UIBP",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\231\177\187\229\136\171\231\187\132\232\138\130\231\130\185"
    }
  },
  Common_ItemGet_PageBtn = {
    keyName = "Common_ItemGet_PageBtn",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_PageBtn",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_PageBtn1.Common_ItemGet_PageBtn1",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\229\143\140\229\136\151\232\161\168\232\138\130\231\130\185"
    }
  },
  Common_ItemGet_RichText = {
    keyName = "Common_ItemGet_RichText",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_RichText",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_RichText.Common_ItemGet_RichText",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\229\175\140\230\150\135\230\156\172\230\142\167\228\187\182"
    }
  },
  Common_ItemGet_SeasonTip = {
    keyName = "Common_ItemGet_SeasonTip",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_SeasonTip",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_SeasonTip.Common_ItemGet_SeasonTip",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\232\181\155\229\173\163\229\136\135\230\141\162\231\177\187\231\167\176\229\143\183\232\142\183\229\190\151Tip"
    }
  },
  Common_ItemGet_RankTitle = {
    keyName = "Common_ItemGet_RankTitle",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_ItemGet_RankTitle",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_ItemGet_RankTitle.Common_ItemGet_RankTitle",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\231\137\185\230\174\138\231\167\176\229\143\183"
    }
  },
  Common_StageRewardsRate_UIBP = {
    keyName = "Common_StageRewardsRate_UIBP",
    moduleName = "client.slua.umg.common.RateShowPanel.Common_StageRewardsRate_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_StageRewardsRate_UIBP.Common_StageRewardsRate_UIBP",
    uiStat = {
      name = "\229\133\172\229\133\177\229\188\185\231\170\151-\229\174\157\231\174\177\230\166\130\231\142\135"
    }
  },
  CoupleAvatar_UIBP = {
    keyName = "CoupleAvatar_UIBP",
    moduleName = "client.logic.avatar.CoupleAvatarUI.CoupleAvatar_UIBP",
    path = "/Game/UMG/UI_BP/Common/CoupleAvatarUI/CoupleAvatar_UIBP.CoupleAvatar_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\231\148\168\230\142\167\228\187\182-CoupleAvatarUI"
    }
  },
  MultiplayerAvatar_UIBP = {
    keyName = "MultiplayerAvatar_UIBP",
    moduleName = "client.logic.avatar.MultiplayerAvatarUI.MultiplayerAvatar_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/MultiplayerAvatar_UIBP.MultiplayerAvatar_UIBP",
    isSingleton = true,
    isMainUI = false,
    uiStat = {
      name = "\229\164\154\228\186\186\228\186\178\229\175\134\229\133\179\231\179\187"
    }
  },
  KillInfoItem_BP = {
    keyName = "KillInfoItem_BP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/BluePrints/ControlInput/IngameUI/TipsItem/KillInfoItem_BP.KillInfoItem_BP",
    isSingleton = false,
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None
  },
  lobby_mini_tv_download = {
    keyName = "lobby_mini_tv_download",
    moduleName = "client.slua.umg.mini_tv.lobby_mini_download",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Lobby_Mid_MiniTv_FaceSlap_UIBP.Lobby_Mid_MiniTv_FaceSlap_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\231\148\181\232\167\134\230\156\186\228\186\186-\228\184\139\232\189\189\230\139\141\232\132\184"
    }
  },
  lobby_common_news = {
    keyName = "lobby_common_news",
    moduleName = "client.slua.umg.lobby.Mid.Tips.lobby_common_news",
    path = "/Game/UMG/UI_BP/Common/Common_News_UIBP.Common_News_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133news\230\142\168\233\128\129\229\188\185\231\170\151"
    }
  },
  Common_Tips_NoArrow_UIBP = {
    keyName = "Common_Tips_NoArrow_UIBP",
    moduleName = "client.slua.umg.common.bubble.Common_Tips_NoArrow_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/Common_Tips_NoArrow_UIBP.Common_Tips_NoArrow_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\231\148\168\230\176\148\230\179\161-\230\151\160\231\174\173\229\164\180"
    }
  },
  Common_Tips_Left_UIBP = {
    keyName = "Common_Tips_Left_UIBP",
    moduleName = "client.slua.umg.common.bubble.Common_Tips_Left_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/Common_Tips_Left_UIBP.Common_Tips_Left_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\233\128\154\231\148\168\230\176\148\230\179\161-\229\183\166\228\190\167\230\150\135\230\156\172"
    }
  },
  Common_Tips_Right_UIBP = {
    keyName = "Common_Tips_Right_UIBP",
    moduleName = "client.slua.umg.common.bubble.Common_Tips_Right_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/Common_Tips_Right_UIBP.Common_Tips_Right_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\231\148\168\230\176\148\230\179\161-\229\143\179\228\190\167\230\150\135\230\156\172"
    }
  },
  Common_Tips_Top_NoAnim_UIBP = {
    keyName = "Common_Tips_Top_NoAnim_UIBP",
    moduleName = "client.slua.umg.common.bubble.Common_Tips_Top_NoAnim_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/Common_Tips_Top_UIBP.Common_Tips_Top_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\231\148\168\230\176\148\230\179\161-\228\184\138\230\150\185\230\150\135\230\156\172-\230\151\160\229\138\168\231\148\187"
    }
  },
  Common_Tips_Down_UIBP = {
    keyName = "Common_Tips_Down_UIBP",
    moduleName = "client.slua.umg.common.bubble.Common_Tips_Down_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/Common_Tips_Down_UIBP.Common_Tips_Down_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\231\148\168\230\176\148\230\179\161-\228\184\139\230\150\185\230\150\135\230\156\172"
    }
  },
  commonTabTest = {
    keyName = "commonTabTest",
    moduleName = "client.slua.umg.GM.GM_Common_Tabs",
    path = "/Game/UMG/UI_BP/GM/GM_Common_Tabs.GM_Common_Tabs",
    uiStat = {
      name = "GM_Common_Tabs"
    }
  },
  Newbie_Guide_Welcome = {
    keyName = "Newbie_Guide_Welcome",
    moduleName = "client.slua.umg.newbie_guide.newbie_guide_welcome",
    path = "/Game/UMG/UI_BP/Guide/Common_Welcome_UIBP.Common_Welcome_UIBP",
    uiStat = {
      name = "\229\162\158\233\149\191\228\184\147\233\161\185-\228\184\137\233\128\137\228\184\128\230\148\185\231\137\136"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  Newbie_Guide_Welcome_UI25 = {
    keyName = "Newbie_Guide_Welcome_UI25",
    moduleName = "client.slua.umg.newbie_guide.Newbie_Guide_Welcome_UI25",
    path = "/Game/UMG/UI_BP/Guide/Common_Welcome_UIBP_4.Common_Welcome_UIBP_4",
    uiStat = {
      name = "\229\162\158\233\149\191\228\184\147\233\161\185-\228\184\137\233\128\137\228\184\128\230\148\185\231\137\136-UI2.5"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  GMTestImageDownload = {
    keyName = "GMTestImageDownload",
    moduleName = "client.slua.umg.GM.GMTestImageDownload",
    path = "/Game/UMG/UI_BP/Setting/item/Throw_Tips_UIBP.Throw_Tips_UIBP",
    asy = true,
    uiStat = {
      name = "\229\155\190\231\137\135\228\184\139\232\189\189\230\181\139\232\175\149"
    }
  },
  Explore_Linkage_RewardPreview_UIBP = {
    keyName = "Explore_Linkage_RewardPreview_UIBP",
    moduleName = "client.slua.umg.explore.Explore_Linkage_RewardPreview_UIBP",
    path = "/Game/Arts_UI/AlwaysSplit/Explore_Linkage/Explore_Linkage_RewardPreview_UIBP.Explore_Linkage_RewardPreview_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\142\162\231\180\162\230\180\187\229\138\168\229\174\157\231\174\177\231\149\140\233\157\162"
    }
  },
  ReturnActivity_Reward_UIBP = {
    keyName = "ReturnActivity_Reward_UIBP",
    moduleName = "client.slua.umg.return_activity.ReturnActivity_Reward_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Reward_UIBP.ReturnActivity_Reward_UIBP",
    uiStat = {
      name = "310\229\155\158\230\181\129\230\180\187\229\138\168-\228\184\187\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  ReturnActivity_Reward_New_UIBP = {
    keyName = "ReturnActivity_Reward_New_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_Reward_New_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Reward_New_UIBP.ReturnActivity_Reward_New_UIBP",
    uiStat = {
      name = "400\229\155\158\230\181\129\230\180\187\229\138\168-\228\184\187\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  Common_Other_Tips_UIBP = {
    keyName = "Common_Other_Tips_UIBP",
    moduleName = "client.slua.umg.common.Common_Other_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/Common_Other_Tips_UIBP.Common_Other_Tips_UIBP",
    asy = true,
    uiStat = {
      name = "\229\133\182\228\187\150tips\229\188\185\231\170\151"
    }
  },
  Common_Other_Tips_InGame_UIBP = {
    keyName = "Common_Other_Tips_InGame_UIBP",
    moduleName = "client.slua.umg.common.Common_Other_Tips_UIBP",
    path = "/Game/Mod/CreativeBase/UMG/Common/Common_UGC_Other_Tips_UIBP.Common_UGC_Other_Tips_UIBP",
    uiStat = {
      name = "\229\177\128\229\134\133tips\229\188\185\231\170\151"
    }
  },
  Common_ComboBox_List = {
    keyName = "Common_ComboBox_List",
    moduleName = "client.slua.umg.common.Common_ComboBox_List",
    path = "/Game/UMG/UI_BP/Common/ComboBox/Common_ComboBox_List.Common_ComboBox_List",
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\228\184\139\230\139\137\230\161\134-\228\184\139\230\139\137\229\136\151\232\161\168"
    }
  },
  luckySpinGoldExchange = {
    keyName = "luckySpinGoldExchange",
    moduleName = "client.slua.umg.lobby_activity.LuckySpin.luckySpinGoldExchange",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Activity_Common_LuckyDraw_01.Activity_Common_LuckyDraw_01",
    uiStat = {
      name = "\230\148\190\229\155\158\230\138\189\229\165\150-\228\184\187\233\162\152\229\133\145\230\141\162\229\149\134\229\186\151"
    }
  },
  Common_Tips_Top_UIBP = {
    keyName = "Common_Tips_Top_UIBP",
    moduleName = "client.slua.umg.common.Common_Tips_Top_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/Common_Tips_Top_UIBP.Common_Tips_Top_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168-\230\176\148\230\179\161\233\161\182\233\131\168tips"
    },
    AndroidBackType = EAndroidBackType.Skip
  },
  LuckySpinScrapGold = {
    keyName = "LuckySpinScrapGold",
    moduleName = "client.slua.umg.lobby_activity.LuckySpin.MainScense.PoolStyle_2300ScrapGold",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Form_UIBP.Lucky_Common_Form_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\230\138\189\229\165\150-\229\184\184\233\169\187-\233\135\145\231\162\142\231\137\135\230\138\189\229\165\150"
    }
  },
  ScrapGold_Reward_UIBP = {
    keyName = "ScrapGold_Reward_UIBP",
    moduleName = "client.slua.umg.lobby_activity.scrapgold_draw.ScrapGold_Reward_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/ScrapGold/UIBP/ScrapGold_Reward_UIBP.ScrapGold_Reward_UIBP",
    asy = true,
    uiStat = {
      name = "\233\135\145\231\162\142\231\137\135\230\129\173\229\150\156\232\142\183\229\190\151"
    }
  },
  Common_Exchange_New_UIBP = {
    keyName = "Common_Exchange_New_UIBP",
    moduleName = "client.slua.umg.common.Common_Exchange_New_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Exchange_New_UIBP.Common_Exchange_New_UIBP",
    jumpModuleID = BP_ENUM_MODULE_COMMON_PREVIEW_EXCHANGE,
    asy = true,
    uiStat = {
      name = "2300-\233\128\154\231\148\168\232\189\172\231\155\152\230\138\189\229\165\150\229\133\145\230\141\162\231\149\140\233\157\162"
    }
  },
  PreChurn_LoginReward_UIBP = {
    keyName = "PreChurn_LoginReward_UIBP",
    moduleName = "client.slua.umg.PreChurn.PreChurn_LoginReward_UIBP",
    path = "/Game/UMG/UI_BP/PreChurn/PreChurn_Popup_UIBP.PreChurn_Popup_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\233\162\132\230\181\129\229\164\177-\231\153\187\229\189\149\229\165\150\229\138\177\229\188\185\231\170\151"
    }
  },
  store_voice_pack_panel = {
    keyName = "store_voice_pack_panel",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.component.store_voice_pack_panel",
    path = "/Game/UMG/UI_BP/Store/Item/Store_QuickMessage_UIBP.Store_QuickMessage_UIBP",
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142-\232\175\173\233\159\179\229\140\133\232\175\166\230\131\133\233\157\162\230\157\191"
    }
  },
  common_item_get_multi_mechanism = {
    keyName = "common_item_get_multi_mechanism",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.supply.common_item_get_multi_mechanism",
    path = "/Game/UMG/UI_BP/Store/Item/Crate_GuaranteeMechanism_011_UIBP.Crate_GuaranteeMechanism_011_UIBP",
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151\231\149\140\233\157\162 - \233\153\132\229\138\160\231\149\140\233\157\162\239\188\136\232\161\165\231\187\153\229\174\157\231\174\177\229\143\160\229\138\160\230\156\186\229\136\182\239\188\137"
    },
    isMainUI = false,
    asy = true
  },
  Common_Popup_Edit_Voice_UIBP = {
    keyName = "Common_Popup_Edit_Voice_UIBP",
    moduleName = "client.slua.umg.common.Common_Popup_Edit_Voice_UIBP",
    path = "/Game/UMG/UI_BP/Common/Popup/Common_Popup_Edit_Voice_UIBP.Common_Popup_Edit_Voice_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\128\154\231\148\168\229\189\149\229\136\182\232\175\173\233\159\179\229\188\185\231\170\151"
    }
  },
  Common_Medium_Share_Popup_UIBP = {
    keyName = "Common_Medium_Share_Popup_UIBP",
    moduleName = "client.slua.umg.common.Common_Medium_Share_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Medium_Share_Popup_UIBP.Common_Medium_Share_Popup_UIBP",
    uiStat = {
      name = "\229\136\134\228\186\171\229\188\185\231\170\151"
    }
  },
  Lobby_RoleInfo_PopularityGift_RewardDesc_Popup_UIBP = {
    keyName = "Lobby_RoleInfo_PopularityGift_RewardDesc_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Lobby_RoleInfo_PopularityGift_RewardDesc_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/AnnualCelebration/Popup/Lobby_RoleInfo_PopularityGift_RewardDesc_Popup_UIBP.Lobby_RoleInfo_PopularityGift_RewardDesc_Popup_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    uiStat = {
      name = "\228\186\186\230\176\148PK-\228\186\186\230\176\148\231\155\155\229\133\184-\230\138\165\229\144\141\233\161\181\233\157\162-\231\137\185\230\174\138\229\165\150\229\138\177\231\137\169\229\147\129CDN\233\162\132\232\167\136\229\188\185\231\170\151"
    }
  },
  Lobby_RoleInfo_Popularity_PlayerAvatar_Item_UIBP = {
    keyName = "Lobby_RoleInfo_Popularity_PlayerAvatar_Item_UIBP",
    moduleName = "client.slua.umg.PersonSpace.item.Lobby_RoleInfo_Popularity_PlayerAvatar_Item_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/item/Lobby_RoleInfo_Popularity_PlayerAvatar_Item_UIBP.Lobby_RoleInfo_Popularity_PlayerAvatar_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148PK-\228\186\186\230\176\148\231\155\155\229\133\184-\230\153\139\231\186\167\228\185\139\232\183\175-\230\142\146\229\144\141\229\164\180\229\131\143"
    }
  },
  Subscribe_Common_item = {
    keyName = "Subscribe_Common_item",
    moduleName = "client.slua.umg.subscribe.Subscribe_Common_item",
    path = "/Game/UMG/UI_BP/SpecialOffer/Item/Subscribe_Common_item.Subscribe_Common_item",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\174\162\233\152\133-\230\175\143\230\151\165\233\162\134\229\143\150item"
    },
    loadFromPool = EUIConfigPoolType.other_pool
  },
  RewardGet_UIBP = {
    keyName = "RewardGet_UIBP",
    moduleName = "client.slua.umg.SmartAssistant.RewardGet_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistant/RewardGet_UIBP.RewardGet_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139\228\184\128\233\148\174\233\162\134\229\143\150\230\129\173\229\150\156\232\142\183\229\190\151"
    },
    asy = true
  },
  RewardGet_Item_UIBP = {
    keyName = "RewardGet_Item_UIBP",
    moduleName = "client.slua.umg.SmartAssistant.RewardGet_Item_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistant/Item/RewardGet_Item_UIBP.RewardGet_Item_UIBP",
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139\228\184\128\233\148\174\233\162\134\229\143\150\230\129\173\229\150\156\232\142\183\229\190\151\228\184\128\228\184\170\231\177\187\229\158\139item"
    },
    isMainUI = false,
    isSingleton = false
  },
  RewardSource_Popup_UIBP = {
    keyName = "RewardSource_Popup_UIBP",
    moduleName = "client.slua.umg.SmartAssistant.RewardSource_Popup_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistant/RewardSource_Popup_UIBP.RewardSource_Popup_UIBP",
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139-\230\129\173\229\150\156\232\142\183\229\190\151\230\180\187\229\138\168\230\157\165\230\186\144\229\177\149\231\164\186"
    }
  },
  SportsCarSpinContainer = {
    keyName = "SportsCarSpinContainer",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.Container.SportsCarSpinContainer",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    jumpModuleID = BP_ENUM_MODULE_LADDER_DRAW,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\232\183\145\232\189\166\232\189\172\231\155\152-\233\152\191\230\150\175\233\161\191\233\169\172\228\184\129"
    }
  },
  SportsCarSpinNovice = {
    keyName = "SportsCarSpinNovice",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.Container.SportsCarSpinNoviceContainer",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    asy = true,
    uiStat = {
      name = "\232\183\145\232\189\166\232\189\172\231\155\152-\230\150\176\230\137\139\229\188\149\229\175\188"
    }
  },
  SportsCarExchangeContainer = {
    keyName = "SportsCarExchangeContainer",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.Container.SportsCarExchangeContainer",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    jumpModuleID = BP_ENUM_MODULE_LADDER_DRAW_CAR_STORE,
    loadFromPool = EUIConfigPoolType.None,
    asy = true,
    uiStat = {
      name = "\232\183\145\232\189\166\229\149\134\229\159\142-\230\161\134\230\158\182"
    }
  },
  SportsCarExchangeSpecialActiveTipContainer = {
    keyName = "SportsCarExchangeSpecialActiveTipContainer",
    moduleName = "client.slua.umg.lobby_activity.SportsCarSpin.Container.SportsCarExchangeSpecialActiveTipContainer",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\232\183\145\232\189\166\229\149\134\229\159\142-\233\154\144\232\151\143\230\172\190\232\183\145\232\189\166\230\191\128\230\180\187\233\161\181\231\173\190\229\174\185\229\153\168"
    }
  },
  StoreMoneyComponent = {
    keyName = "StoreMoneyComponent",
    moduleName = "client.slua.umg.NewStoreV280.Components.StoreMoneyComponent",
    path = "/Game/UMG/UI_BP/NewStore/component/Store_Money_UIBP.Store_Money_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142-\232\180\167\229\184\129\231\187\132\228\187\182-V280"
    }
  },
  SupplyNewCrateOneKey = {
    keyName = "SupplyNewCrateOneKey",
    moduleName = "client.slua.umg.NewStoreV280.Components.SupplyNewCrateOneKey",
    path = "/Game/UMG/UI_BP/Store/Store_Onekey_UIBP.Store_Onekey_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\232\161\165\231\187\153-\229\174\157\231\174\177\229\134\133\228\184\128\233\148\174\230\138\189\229\165\150-V290"
    }
  },
  SupplyBanPanel = {
    keyName = "SupplyBanPanel",
    moduleName = "client.slua.umg.NewStoreV280.Components.SupplyBanPanel",
    path = "/Game/UMG/UI_BP/Store/Store_Banbox_02_UIBP.Store_Banbox_02_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\232\161\165\231\187\153-\232\135\170\229\136\182\229\174\157\231\174\177-v290"
    }
  },
  MixItemMainContainer = {
    keyName = "MixItemMainContainer",
    moduleName = "client.slua.umg.MixItem.MixItemMainContainer",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\161\165\231\187\153-\230\183\183\229\144\136\231\137\169-\233\128\154\231\148\168\231\169\186\231\153\189\232\147\157\229\155\190\230\161\134\230\158\182"
    }
  },
  Common_PlaneShow_Tips = {
    keyName = "Common_PlaneShow_Tips",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.component.Common_PlaneShow_Tips",
    path = "/Game/UMG/UI_BP/Common/Common_PlaneShow_Tips.Common_PlaneShow_Tips",
    uiStat = {
      name = "\233\163\158\230\156\186\231\154\174\232\130\164\229\133\172\229\145\138"
    }
  },
  StoreCoinItem = {
    keyName = "StoreCoinItem",
    moduleName = "client.slua.umg.NewStoreV280.Components.StoreCoinComponent.StoreCoinItem",
    path = "/Game/UMG/UI_BP/Common/Coin/Coin_Item_UIBP.Coin_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\233\128\154\231\148\168\232\180\167\229\184\129\231\187\132\228\187\182-\229\149\134\229\186\151Item"
    }
  },
  Common_Lottery_MustItem_UIBP = {
    keyName = "Common_Lottery_MustItem_UIBP",
    moduleName = "client.slua.umg.common.LotteryMechanism.Common_Lottery_MustItem_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_LotteryMechanism/Common_Lottery_MustItem_UIBP.Common_Lottery_MustItem_UIBP",
    isSingleton = true,
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\231\148\168\231\177\187-\230\138\189\229\165\150\229\174\157\231\174\177\229\191\133\229\190\151\230\156\186\229\136\182\230\140\130\232\189\189item"
    }
  },
  Common_Lottery_PrizeDrawItem_UIBP = {
    keyName = "Common_Lottery_PrizeDrawItem_UIBP",
    moduleName = "client.slua.umg.common.LotteryMechanism.Common_Lottery_PrizeDrawItem_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_LotteryMechanism/Common_Lottery_PrizeDrawItem_UIBP.Common_Lottery_PrizeDrawItem_UIBP",
    isSingleton = true,
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\231\148\168\231\177\187-\230\138\189\229\165\150\229\174\157\231\174\177\233\162\157\229\164\150\229\174\157\231\174\177\230\156\186\229\136\182\230\140\130\232\189\189item"
    }
  },
  CommonLottery_BanSelectMode_UIBP = {
    keyName = "CommonLottery_BanSelectMode_UIBP",
    moduleName = "client.slua.umg.common.LotteryMechanism.CommonLottery_BanSelectMode_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_LotteryMechanism/CommonLottery_BanSelectMode_UIBP.CommonLottery_BanSelectMode_UIBP",
    isSingleton = true,
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\231\148\168\231\177\187-\230\138\189\229\165\150\229\174\157\231\174\177ban\233\128\137\229\174\157\231\174\177\230\156\186\229\136\182\230\140\130\232\189\189item"
    }
  },
  Common_Lottery_LineItem_UIBP = {
    keyName = "Common_Lottery_LineItem_UIBP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/Common/Common_LotteryMechanism/Common_Lottery_LineItem_UIBP.Common_Lottery_LineItem_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\231\148\168\231\177\187-\230\138\189\229\165\150\229\174\157\231\174\177\230\156\186\229\136\182\229\136\134\229\137\178\231\186\191"
    }
  },
  Common_SelectUseItem_UIBP = {
    keyName = "Common_SelectUseItem_UIBP",
    moduleName = "client.slua.umg.common.UseItemSelect.Common_SelectUseItem_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_SelectUseItem/Common_SelectUseItem_UIBP.Common_SelectUseItem_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\231\177\187-\229\164\154\231\137\169\229\147\129\228\189\191\231\148\168\233\128\137\230\139\169\230\161\134"
    }
  },
  Common_MultiChooseOne_UIBP = {
    keyName = "Common_MultiChooseOne_UIBP",
    moduleName = "client.slua.umg.common.MultipleChoiceInterface.Common_MultiChooseOne_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Award_2Choose1_UIBP.Common_Award_2Choose1_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\231\177\187-\229\164\154\233\128\137\228\184\128\233\128\137\230\139\169\232\142\183\229\190\151\231\137\169\229\147\129"
    }
  },
  ReplayGMUIFileListItem = {
    keyName = "ReplayGMUIFileListItem",
    moduleName = "GameLua.Mod.BaseMod.Client.Replay.ReplayGMUIFileListItem",
    path = "/Game/BluePrints/UI/GMConsole/CompleteReplayListItem_BP.CompleteReplayListItem_BP",
    isMainUI = false,
    isSingleton = false,
    asy = false,
    uiStat = {
      name = "ReplayGMUI\230\150\135\228\187\182\229\136\151\232\161\168Item"
    }
  },
  PHomeStore_Detail_Feature = {
    keyName = "PHomeStore_Detail_Feature",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PHomeStore_Detail_Feature",
    path = "/Game/UMG/UI_BP/Common/Common_Detail_Feature.Common_Detail_Feature",
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142-\232\175\166\230\131\133-\231\137\185\230\128\167\231\187\132\228\187\182"
    }
  },
  Common_Y_Tips_LeftContent_UIBP = {
    keyName = "Common_Y_Tips_LeftContent_UIBP",
    moduleName = "client.slua.umg.common.Tips.Common_Y_Tips_LeftContent_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/Common_Y_Tips_LeftContent_UIBP.Common_Y_Tips_LeftContent_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\136\134\230\156\159\228\187\152\230\172\190-\229\136\134\230\156\159tips"
    }
  },
  PlanPH_Store_LuckySpin_Rewards_UIBP = {
    keyName = "PlanPH_Store_LuckySpin_Rewards_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PlanPH_Store_LuckySpin_Rewards_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_LuckySpin_Rewards_UIBP.PlanPH_Store_LuckySpin_Rewards_UIBP",
    uiStat = {
      name = "\232\129\154\228\185\144\229\155\173-\229\149\134\229\186\151-\232\189\172\231\155\152\229\165\150\229\138\177\233\162\132\232\167\136\231\149\140\233\157\162"
    }
  },
  Common_Home_NamePlate_Item_UIBP = {
    keyName = "Common_Home_NamePlate_Item_UIBP",
    moduleName = "client.slua.umg.Home.Detail.Item.Common_Home_NamePlate_Item_UIBP",
    path = "/Game/UMG/UI_BP/Home/Detail/Item/Common_Home_NamePlate_Item_UIBP.Common_Home_NamePlate_Item_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\232\175\166\230\131\133\231\149\140\233\157\162-Item-\233\151\168\231\137\140\231\187\132\228\187\182"
    }
  },
  Home_Common_Tips_Left_UIBP = {
    keyName = "Home_Common_Tips_Left_UIBP",
    moduleName = "client.slua.umg.Home.Common.Home_Common_Tips_Left_UIBP",
    path = "/Game/UMG/UI_BP/Home/Common/Tips/Home_Common_Tips_Left_UIBP.Home_Common_Tips_Left_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173-tips"
    }
  },
  Home_Common_Tips_Left_02_UIBP = {
    keyName = "Home_Common_Tips_Left_02_UIBP",
    moduleName = "client.slua.umg.Home.Common.Tips.Home_Common_Tips_Left_02_UIBP",
    path = "/Game/UMG/UI_BP/Home/Common/Tips/Home_Common_Tips_Left_02_UIBP.Home_Common_Tips_Left_02_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-tips-\230\150\135\229\173\151\229\144\145\228\184\139\230\142\146"
    }
  },
  Common_NewbieGuide_Bubble_UIBP = {
    keyName = "Common_NewbieGuide_Bubble_UIBP",
    moduleName = "client.slua.umg.Home.Common.NewbieGuide.Common_NewbieGuide_Bubble_UIBP",
    path = "/Game/UMG/UI_BP/Home/Common/NewbieGuide/Common_NewbieGuide_Bubble_UIBP.Common_NewbieGuide_Bubble_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\229\188\149\229\175\188 - \233\128\154\231\148\168 - \233\171\152\228\186\174\233\128\137\228\184\173"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  Common_NewbieGuide_Mask_UIBP = {
    keyName = "Common_NewbieGuide_Mask_UIBP",
    moduleName = "client.slua.umg.Home.Common.NewbieGuide.Common_NewbieGuide_Mask_UIBP",
    path = "/Game/UMG/UI_BP/Home/Common/NewbieGuide/Common_NewbieGuide_Mask_UIBP.Common_NewbieGuide_Mask_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\229\188\149\229\175\188 - \233\128\154\231\148\168- \233\129\174\231\189\169"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  Wardrobe_Avatar_Tips_UIBP = {
    keyName = "Wardrobe_Avatar_Tips_UIBP",
    moduleName = "client.slua.umg.Wardrobe.Wardrobe_Avatar_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_Avatar_Tips_UIBP.Wardrobe_Avatar_Tips_UIBP",
    uiStat = {
      name = "\230\141\162\229\164\180\232\175\180\230\152\142tips\233\157\162\230\157\191"
    }
  },
  Theme_RewardContent_Popop_UIBP = {
    keyName = "Theme_RewardContent_Popop_UIBP",
    moduleName = "client.slua.umg.Theme.New.Popup.Theme_RewardContent_Popop_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Popup/Theme_RewardContent_Popop_UIBP.Theme_RewardContent_Popop_UIBP",
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\228\187\187\229\138\161\229\165\150\229\138\177\232\175\180\230\152\142\229\188\185\231\170\151"
    }
  },
  CollectUnlockComponent = {
    keyName = "CollectUnlockComponent",
    moduleName = "client.slua.traits.DetailComponent.CollectUnlock.CollectUnlockComponent",
    path = "/Game/UMG/UI_BP/Lobby_Store_Int/Lobby_Store_CollectUnlock_UIBP.Lobby_Store_CollectUnlock_UIBP",
    uiStat = {
      name = "\232\175\166\230\131\133\230\141\162\229\164\180\233\157\162\230\157\191"
    }
  },
  Common_Material_Popup_UIBP = {
    keyName = "Common_Material_Popup_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.Popup.Common_Material_Popup_UIBP",
    path = "/Game/UMG/UI_BP/SpecialOffer/Popup/Common_Material_Popup_UIBP.Common_Material_Popup_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\231\164\188\229\140\133\232\180\173\228\185\176-\229\143\175\233\162\132\232\167\136\229\134\133\229\174\185"
    }
  },
  PlanPH_Lobby_Common_Popups_Small_UIBP = {
    keyName = "PlanPH_Lobby_Common_Popups_Small_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Popup.PlanPH_Lobby_Common_Popups_Small_UIBP",
    path = "/Game/UMG/UI_BP/Home/Common/Popup/Small/PlanPH_Lobby_Common_Popups_Small_UIBP.PlanPH_Lobby_Common_Popups_Small_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\233\128\154\231\148\168\229\176\143\229\188\185\231\170\151-\229\177\128\229\164\150"
    },
    containerName = UIContainers.Top
  },
  Lobby_PeakGame_Weekly_Reward_UIBP = {
    keyName = "Lobby_PeakGame_Weekly_Reward_UIBP",
    moduleName = "client.slua.umg.PeakGame.Rank.Reward.Lobby_PeakGame_Weekly_Reward_UIBP",
    path = "/Game/UMG/UI_BP/PeakGame/Rank/Lobby_PeakGame_Reward_Base_UIBP.Lobby_PeakGame_Reward_Base_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\229\183\133\229\179\176\230\174\191\229\160\130-\229\145\168\230\166\156\229\165\150\229\138\177"
    }
  },
  Lobby_PeakGame_Hof_Reward_UIBP = {
    keyName = "Lobby_PeakGame_Hof_Reward_UIBP",
    moduleName = "client.slua.umg.PeakGame.Rank.Reward.Lobby_PeakGame_Hof_Reward_UIBP",
    path = "/Game/UMG/UI_BP/PeakGame/Rank/Lobby_PeakGame_Reward_Base_UIBP.Lobby_PeakGame_Reward_Base_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\229\183\133\229\179\176\230\174\191\229\160\130-\229\144\141\228\186\186\229\160\130\229\165\150\229\138\177"
    }
  },
  Lobby_PeakGame_Ability_Reward_UIBP = {
    keyName = "Lobby_PeakGame_Ability_Reward_UIBP",
    moduleName = "client.slua.umg.PeakGame.Rank.Reward.Lobby_PeakGame_Ability_Reward_UIBP",
    path = "/Game/UMG/UI_BP/PeakGame/Rank/Lobby_PeakGame_Ability_Reward_UIBP.Lobby_PeakGame_Ability_Reward_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\229\183\133\229\179\176\230\174\191\229\160\130-\229\144\141\228\186\186\229\160\130\229\165\150\229\138\177"
    }
  },
  PeakGame_Empty_Reward_UIBP = {
    keyName = "PeakGame_Empty_Reward_UIBP",
    moduleName = "client.slua.umg.PeakGame.Rank.PeakGame_Empty_Reward_UIBP",
    path = "/Game/UMG/UI_BP/PeakGame/Rank/PeakGame_Empty_Reward_UIBP.PeakGame_Empty_Reward_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\229\183\133\229\179\176\230\174\191\229\160\130-\231\169\186\231\149\140\233\157\162"
    }
  },
  FeaturePanelG_BP = {
    keyName = "FeaturePanelG_BP",
    moduleName = "client.slua.traits.DetailComponent.FeatureComponent.FeaturePanelG_BP",
    path = "/Game/UMG/UI_BP/NewStore/item/FeaturePanelG_BP.FeaturePanelG_BP",
    uiStat = {
      name = "\229\149\134\229\159\142-\233\171\152\231\186\167\231\137\185\230\128\167-\233\135\145\232\163\133"
    }
  },
  FeatureItem_BP = {
    keyName = "FeatureItem_BP",
    moduleName = "client.slua.traits.DetailComponent.FeatureComponent.FeatureItem_BP",
    path = "/Game/UMG/UI_BP/NewStore/item/FeatureItem_BP.FeatureItem_BP",
    isSingleton = false,
    uiStat = {
      name = "\229\149\134\229\159\142-\233\171\152\231\186\167\231\137\185\230\128\167-\231\136\182\231\137\185\230\128\167"
    }
  },
  Download_Main_UIBP = {
    keyName = "Download_Main_UIBP",
    moduleName = "client.slua.umg.download.Download_Main_UIBP",
    path = "/Game/UMG/UI_BP/Download/Download_Main_UIBP.Download_Main_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    asy = true,
    uiStat = {
      name = "\230\150\176\229\164\167\229\142\133\228\184\139\232\189\189\229\153\168\231\149\140\233\157\162"
    }
  },
  Download_Setting_UIBP = {
    keyName = "Download_Setting_UIBP",
    moduleName = "client.slua.umg.download.Popup.Download_Setting_UIBP",
    path = "/Game/UMG/UI_BP/Download/Popup/Download_Setting_UIBP.Download_Setting_UIBP",
    uiStat = {
      name = "\228\184\139\232\189\189\229\153\168\232\174\190\231\189\174\231\149\140\233\157\162"
    }
  },
  Download_Cleanup_Popup_UIBP = {
    keyName = "Download_Cleanup_Popup_UIBP",
    moduleName = "client.slua.umg.download.Popup.Download_Cleanup_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Download/Popup/Download_Cleanup_Popup_UIBP.Download_Cleanup_Popup_UIBP",
    uiStat = {
      name = "\228\184\139\232\189\189\229\153\168\230\184\133\231\144\134\233\128\137\230\139\169\229\188\185\231\170\151"
    }
  },
  Download_Loading_Item_UIBP = {
    keyName = "Download_Loading_Item_UIBP",
    moduleName = "client.slua.umg.download.Item.Download_Loading_Item_UIBP",
    path = "/Game/UMG/UI_BP/Download/Item/Download_Loading_Item_UIBP.Download_Loading_Item_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\228\184\139\232\189\189\229\153\168\232\174\161\230\151\182\231\149\140\233\157\162"
    }
  },
  Download_Delete_Progress_UIBP = {
    keyName = "Download_Delete_Progress_UIBP",
    moduleName = "client.slua.umg.download.Popup.Download_Delete_Progress_UIBP",
    path = "/Game/UMG/UI_BP/Download/Popup/Download_Delete_Progress_UIBP.Download_Delete_Progress_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\136\160\233\153\164\232\191\155\229\186\166"
    }
  },
  Lobby_RoleInfo_AnnualCelebration_BoxRewardItem_UIBP = {
    keyName = "Lobby_RoleInfo_AnnualCelebration_BoxRewardItem_UIBP",
    moduleName = "client.slua.umg.PersonSpace.AnnualCelebration.Item.Lobby_RoleInfo_AnnualCelebration_BoxRewardItem_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/AnnualCelebration/Item/Lobby_RoleInfo_AnnualCelebration_BoxRewardItem_UIBP.Lobby_RoleInfo_AnnualCelebration_BoxRewardItem_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148\229\175\185\229\134\179 \229\185\180\229\186\166\231\155\155\229\133\184 -> \228\187\139\231\187\141 -> \229\174\157\231\174\177\229\165\150\229\138\177"
    }
  },
  Lobby_RoleInfo_PopularityGift_BoxRewardRule_Popup_Item_02_UIBP = {
    keyName = "Lobby_RoleInfo_PopularityGift_BoxRewardRule_Popup_Item_02_UIBP",
    moduleName = "client.slua.umg.PersonSpace.AnnualCelebration.Item.Lobby_RoleInfo_PopularityGift_BoxRewardRule_Popup_Item_02_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/AnnualCelebration/Item/Lobby_RoleInfo_PopularityGift_BoxRewardRule_Popup_Item_02_UIBP.Lobby_RoleInfo_PopularityGift_BoxRewardRule_Popup_Item_02_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148\229\175\185\229\134\179 \229\185\180\229\186\166\231\155\155\229\133\184 -> \231\142\169\230\179\149\232\175\180\230\152\142 -> \229\174\157\231\174\177\229\165\150\229\138\177"
    }
  },
  Lobby_RoleInfo_PopularityGift_BoxRewardRule_Popup_UIBP = {
    keyName = "Lobby_RoleInfo_PopularityGift_BoxRewardRule_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.AnnualCelebration.Popup.Lobby_RoleInfo_PopularityGift_BoxRewardRule_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/AnnualCelebration/Popup/Lobby_RoleInfo_PopularityGift_BoxRewardRule_Popup_UIBP.Lobby_RoleInfo_PopularityGift_BoxRewardRule_Popup_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148\229\175\185\229\134\179 \229\185\180\229\186\166\231\155\155\229\133\184 -> \229\175\185\229\134\179 & \229\174\157\231\174\177 -> \232\175\166\230\131\133\232\175\180\230\152\142\229\188\185\231\170\151"
    }
  },
  Lobby_RoleInfo_Popularity_Streak_Rewards_Popup_UIBP = {
    keyName = "Lobby_RoleInfo_Popularity_Streak_Rewards_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.Popup.Lobby_RoleInfo_Popularity_Streak_Rewards_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/Popup/Lobby_RoleInfo_Popularity_Streak_Rewards_Popup_UIBP.Lobby_RoleInfo_Popularity_Streak_Rewards_Popup_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148\229\175\185\229\134\179-\232\191\158\232\131\156\229\165\150\229\138\177\229\188\185\231\170\151"
    }
  },
  Common_ScreenBox_List_UIBP = {
    keyName = "Common_ScreenBox_List_UIBP",
    moduleName = "client.slua_ui_framework.component.Common_ScreenBox_List_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/Common_ScreenBox_List_UIBP.Common_ScreenBox_List_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\231\187\132\228\187\182-\228\184\139\230\139\137\229\136\151\232\161\168\229\184\166\233\151\174\229\143\183"
    }
  },
  PeakGame_RankSmall_Star_Name_UIBP_2 = {
    keyName = "PeakGame_RankSmall_Star_Name_UIBP_2",
    moduleName = "client.slua.component.peakgame.Item.PeakGame_RankSmall_Star_Name_UIBP_2",
    path = "/Game/UMG/UI_BP/Common/PeakGame/PeakGame_RankSmall_Star_Name_UIBP_2.PeakGame_RankSmall_Star_Name_UIBP_2",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1908-\231\164\190\228\186\164\232\135\170\229\174\154\228\185\137\229\144\141\231\137\135\228\184\147\231\148\168"
    }
  },
  PeakGame_RankSmall_Star_Name_Tips_UIBP = {
    keyName = "PeakGame_RankSmall_Star_Name_Tips_UIBP",
    moduleName = "client.slua.component.peakgame.Item.PeakGame_RankSmall_Star_Name_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Common/PeakGame/PeakGame_RankSmall_Star_Name_Tips_UIBP.PeakGame_RankSmall_Star_Name_Tips_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1909-\231\164\190\228\186\164\232\135\170\229\174\154\228\185\137\229\144\141\231\137\135-\229\176\143\230\168\161\229\157\151tips\228\184\147\231\148\168"
    }
  },
  PeakGame_RankSmall_Integral_Name_Star_UIBP = {
    keyName = "PeakGame_RankSmall_Integral_Name_Star_UIBP",
    moduleName = "client.slua.component.peakgame.Item.PeakGame_RankSmall_Integral_Name_Star_UIBP",
    path = "/Game/UMG/UI_BP/Common/PeakGame/PeakGame_RankSmall_Integral_Name_Star_UIBP.PeakGame_RankSmall_Integral_Name_Star_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1901"
    }
  },
  PeakGame_RankSmall_Name_Star_UIBP = {
    keyName = "PeakGame_RankSmall_Name_Star_UIBP",
    moduleName = "client.slua.component.peakgame.Item.PeakGame_RankSmall_Name_Star_UIBP",
    path = "/Game/UMG/UI_BP/Common/PeakGame/PeakGame_RankSmall_Name_Star_UIBP.PeakGame_RankSmall_Name_Star_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1902"
    }
  },
  PeakGame_RankSmall_Integral_Star_UIBP = {
    keyName = "PeakGame_RankSmall_Integral_Star_UIBP",
    moduleName = "client.slua.component.peakgame.Item.PeakGame_RankSmall_Integral_Star_UIBP",
    path = "/Game/UMG/UI_BP/Common/PeakGame/PeakGame_RankSmall_Integral_Star_UIBP.PeakGame_RankSmall_Integral_Star_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1903"
    }
  },
  PeakGame_RankSmall_Integral_UIBP = {
    keyName = "PeakGame_RankSmall_Integral_UIBP",
    moduleName = "client.slua.component.peakgame.Item.PeakGame_RankSmall_Integral_UIBP",
    path = "/Game/UMG/UI_BP/Common/PeakGame/PeakGame_RankSmall_Integral_UIBP.PeakGame_RankSmall_Integral_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1904"
    }
  },
  PeakGame_RankSmall_Star_UIBP = {
    keyName = "PeakGame_RankSmall_Star_UIBP",
    moduleName = "client.slua.component.peakgame.Item.PeakGame_RankSmall_Star_UIBP",
    path = "/Game/UMG/UI_BP/Common/PeakGame/PeakGame_RankSmall_Star_UIBP.PeakGame_RankSmall_Star_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1905"
    }
  },
  PeakGame_RankSmall_Integral_Name_UIBP = {
    keyName = "PeakGame_RankSmall_Integral_Name_UIBP",
    moduleName = "client.slua.component.peakgame.Item.PeakGame_RankSmall_Integral_Name_UIBP",
    path = "/Game/UMG/UI_BP/Common/PeakGame/PeakGame_RankSmall_Integral_Name_UIBP.PeakGame_RankSmall_Integral_Name_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1906"
    }
  },
  PeakGame_RankSmall_Star_Name_UIBP = {
    keyName = "PeakGame_RankSmall_Star_Name_UIBP",
    moduleName = "client.slua.component.peakgame.Item.PeakGame_RankSmall_Star_Name_UIBP",
    path = "/Game/UMG/UI_BP/Common/PeakGame/PeakGame_RankSmall_Star_Name_UIBP.PeakGame_RankSmall_Star_Name_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\232\181\155\229\173\163-\229\176\143\230\174\181\228\189\141\229\173\144\232\147\157\229\155\1907"
    }
  },
  Download_Guide_Popup_UIBP = {
    keyName = "Download_Guide_Popup_UIBP",
    moduleName = "client.slua.umg.download.Popup.Download_Guide_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Download/Popup/Download_Guide_Popup_UIBP.Download_Guide_Popup_UIBP",
    uiStat = {
      name = "\228\184\139\232\189\189\229\188\149\229\175\188\231\149\140\233\157\162"
    }
  },
  Common_Exquisite_Collect_Level_UIBP = {
    keyName = "Common_Exquisite_Collect_Level_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CollectBadge.umg.ChildBadge.Common_Exquisite_Collect_Level_UIBP",
    path = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_1_UIBP.Common_Collect_Achievement_Level_1_UIBP",
    isMainUI = false,
    isSingleton = false,
    Prepass = true,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\231\143\141\232\151\143\230\140\130\232\189\189\229\190\189\231\171\160\229\173\144\232\147\157\229\155\190\239\188\136\229\164\167\239\188\137"
    }
  },
  Common_Collect_Level_UIBP = {
    keyName = "Common_Collect_Level_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CollectBadge.umg.ChildBadge.Common_Collect_Level_UIBP",
    path = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Level_UIBP.Common_Collect_Level_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\231\143\141\232\151\143\230\140\130\232\189\189\229\190\189\231\171\160\229\173\144\232\147\157\229\155\190\239\188\136\229\176\143\239\188\137"
    }
  },
  Common_Collect_Level_Bright_UIBP = {
    keyName = "Common_Collect_Level_Bright_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CollectBadge.umg.ChildBadge.Common_Collect_Level_Bright_UIBP",
    path = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Level_Bright_UIBP.Common_Collect_Level_Bright_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\231\143\141\232\151\143\230\140\130\232\189\189\229\190\189\231\171\160\229\173\144\232\147\157\229\155\190-\229\133\137\230\149\136\239\188\136\229\176\143\239\188\137"
    }
  },
  Common_Exquisite_Collect_Level_Bright_UIBP = {
    keyName = "Common_Exquisite_Collect_Level_Bright_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.CollectBadge.umg.ChildBadge.Common_Exquisite_Collect_Level_Bright_UIBP",
    path = "/Game/Mod/Lobby/Split/CollectBadge/Common_Exquisite_Collect_Level_Bright_UIBP.Common_Exquisite_Collect_Level_Bright_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\231\143\141\232\151\143\230\140\130\232\189\189\229\190\189\231\171\160\229\173\144\232\147\157\229\155\190-\229\133\137\230\149\136\239\188\136\229\164\167\239\188\137"
    }
  },
  Common_Info_RankIntegralLevel_Large_Item = {
    keyName = "Common_Info_RankIntegralLevel_Large_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_RankIntegralLevel_Large_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_RankIntegralLevel_Large_Item.Common_Info_RankIntegralLevel_Large_Item",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - \230\142\146\228\189\141\231\167\175\229\136\134\231\173\137\231\186\167 - \229\164\167"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.rank_integral_pool
  },
  Common_Info_RankIntegralLevel_Small_Item = {
    keyName = "Common_Info_RankIntegralLevel_Small_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_RankIntegralLevel_Small_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_RankIntegralLevel_Small_Item.Common_Info_RankIntegralLevel_Small_Item",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - \230\142\146\228\189\141\231\167\175\229\136\134\231\173\137\231\186\167 - \229\176\143"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.rank_integral_pool
  },
  Common_Info_WowLevel_Large_Item = {
    keyName = "Common_Info_WowLevel_Large_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_WowLevel_Large_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_WowLevel_Large_Item.Common_Info_WowLevel_Large_Item",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - WOW\229\136\155\228\189\156 - \229\164\167"
    },
    isMainUI = false,
    isSingleton = false
  },
  Common_Info_WowLevel_Small_Item = {
    keyName = "Common_Info_WowLevel_Small_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_WowLevel_Small_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_WowLevel_Small_Item.Common_Info_WowLevel_Small_Item",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - WOW\229\136\155\228\189\156 - \229\176\143"
    },
    isMainUI = false,
    isSingleton = false
  },
  Common_Info_WowPlay_Large_Item = {
    keyName = "Common_Info_WowPlay_Large_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_WowPlay_Large_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_WowLevel_Large_Item.Common_Info_WowLevel_Large_Item",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - WOW\229\136\155\228\189\156 - \229\164\167"
    },
    isMainUI = false,
    isSingleton = false
  },
  Common_Info_WowPlay_Small_Item = {
    keyName = "Common_Info_WowPlay_Small_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_WowPlay_Small_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_WowLevel_Small_Item.Common_Info_WowLevel_Small_Item",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - WOW\229\136\155\228\189\156 - \229\176\143"
    },
    isMainUI = false,
    isSingleton = false
  },
  Common_Info_Home_Small_Item = {
    keyName = "Common_Info_Home_Small_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_Home_Small_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_Home_Small_Item.Common_Info_Home_Small_Item",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - \229\174\182\229\155\173 - \229\176\143"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool
  },
  Common_Info_CollectLevel_Large_Item = {
    keyName = "Common_Info_CollectLevel_Large_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_CollectLevel_Large_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_CollectLevel_Large_Item.Common_Info_CollectLevel_Large_Item",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - \231\143\141\232\151\143\231\173\137\231\186\167 - \229\164\167"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool
  },
  Common_Info_CollectLevel_Small_Item = {
    keyName = "Common_Info_CollectLevel_Small_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_CollectLevel_Small_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_CollectLevel_Small_Item.Common_Info_CollectLevel_Small_Item",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - \231\143\141\232\151\143\231\173\137\231\186\167 - \229\176\143"
    },
    isMainUI = false,
    isSingleton = false
  },
  Common_Info_Relation_Large_Item = {
    keyName = "Common_Info_Relation_Large_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_Relation_Large_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_Relation_Large_Item.Common_Info_Relation_Large_Item",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - \228\186\178\229\175\134\229\133\179\231\179\187 - \229\164\167"
    },
    isMainUI = false,
    isSingleton = false
  },
  Common_Info_Relation_Small_Item = {
    keyName = "Common_Info_Relation_Small_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_Relation_Small_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_Relation_Small_Item.Common_Info_Relation_Small_Item",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - \228\186\178\229\175\134\229\133\179\231\179\187 - \229\176\143"
    },
    isMainUI = false,
    isSingleton = false
  },
  MainCity_DownloadGuide_Popup_UIBP = {
    keyName = "MainCity_DownloadGuide_Popup_UIBP",
    moduleName = "client.slua.umg.MainCity.Popup.MainCity_DownloadGuide_Popup_UIBP",
    path = "/Game/UMG/UI_BP/MainCity/Popup/MainCity_DownloadGuide_Popup_UIBP.MainCity_DownloadGuide_Popup_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\228\184\187\229\159\142\228\184\139\232\189\189\229\188\185\231\170\151"
    }
  },
  MainCity_DownloadGuide_ThemePopup_UIBP = {
    keyName = "MainCity_DownloadGuide_ThemePopup_UIBP",
    moduleName = "client.slua.umg.MainCity.Popup.MainCity_DownloadGuide_ThemePopup_UIBP",
    path = "/Game/UMG/UI_BP/MainCity/Popup/MainCity_DownloadGuide_ThemePopup_UIBP.MainCity_DownloadGuide_ThemePopup_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\228\184\187\229\159\142\228\184\139\232\189\189\229\164\167\231\174\161\229\174\182\229\188\185\231\170\151"
    }
  },
  Download_LightweightDownload_UIBP = {
    keyName = "Download_LightweightDownload_UIBP",
    moduleName = "client.slua.umg.download.Popup.Download_LightweightDownload_UIBP",
    path = "/Game/UMG/UI_BP/Download/Popup/Download_LightweightDownload_UIBP.Download_LightweightDownload_UIBP",
    uiStat = {
      name = "\232\189\187\233\135\143\229\140\150\228\184\139\232\189\189\230\143\144\231\164\186"
    }
  },
  Download_Preference_Popup_UIBP = {
    keyName = "Download_Preference_Popup_UIBP",
    moduleName = "client.slua.umg.download.Popup.Download_Preference_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Download/Popup/Download_Preference_Popup_UIBP.Download_Preference_Popup_UIBP",
    uiStat = {
      name = "\230\153\186\232\131\189\228\184\139\232\189\189\233\133\141\231\189\174\229\188\185\231\170\151"
    }
  },
  Download_Lightweight_Popup_UIBP = {
    keyName = "Download_Lightweight_Popup_UIBP",
    moduleName = "client.slua.umg.download.Popup.Download_Lightweight_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Download/Popup/Download_Lightweight_Popup_UIBP.Download_Lightweight_Popup_UIBP",
    uiStat = {
      name = "\232\189\187\233\135\143\229\140\150\228\184\139\232\189\189\233\128\137\230\139\169\229\188\185\231\170\151"
    }
  },
  Lobby_Download_Recommend_Popup_UIBP = {
    keyName = "Lobby_Download_Recommend_Popup_UIBP",
    moduleName = "client.slua.umg.lobby.Popup.Lobby_Download_Recommend_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Popup/Lobby_Download_Recommend_Popup_UIBP.Lobby_Download_Recommend_Popup_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\229\176\143\229\140\133\230\142\168\232\141\144\228\184\139\232\189\189\229\188\185\231\170\151"
    }
  },
  SpecialOffer_Temu_Container = {
    keyName = "SpecialOffer_Temu_Container",
    moduleName = "client.slua.umg.SpecialOffer.Temu.SpecialOffer_Temu_Container",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\229\141\176\229\186\166\230\139\188\229\164\154\229\164\154\231\164\188\229\140\133\229\174\185\229\153\168"
    }
  },
  Common_Popup_ShareCard_UIBP = {
    keyName = "Common_Popup_ShareCard_UIBP",
    moduleName = "client.slua.umg.common.Popup.Common_Popup_ShareCard_UIBP",
    path = "/Game/UMG/UI_BP/Common/Popup/Common_Popup_ShareCard_UIBP.Common_Popup_ShareCard_UIBP",
    uiStat = {
      name = "\229\138\160\229\136\134\229\141\161\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  Common_Tips_Return_UIBP = {
    keyName = "Common_Tips_Return_UIBP",
    moduleName = "client.slua.umg.common.Tips.Common_Tips_Return_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tips/Common_Tips_Return_UIBP.Common_Tips_Return_UIBP",
    uiStat = {
      name = "\229\155\158\230\181\129\231\187\132\233\152\159\229\165\150\229\138\177tips"
    }
  },
  PeakGame_RankIntegralLevel_Small_Switch_UIBP = {
    keyName = "PeakGame_RankIntegralLevel_Small_Switch_UIBP",
    moduleName = "client.slua.component.peakgame.PeakGame_RankIntegralLevel_Small_Switch_UIBP",
    path = "/Game/UMG/UI_BP/Common/PeakGame/PeakGame_RankIntegralLevel_Small_Switch_UIBP.PeakGame_RankIntegralLevel_Small_Switch_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\231\187\143\229\133\184\230\142\146\228\189\141\229\176\143\229\155\190\230\160\135\231\187\132\228\187\182"
    }
  },
  Avatar_Item_UIBP = {
    keyName = "Avatar_Item_UIBP",
    moduleName = "client.slua.umg.Lobby_SeasonUI.NewSeason.NewItem.Avatar_Item_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_SeasonUI/NewSeason/NewItem/Avatar_Item_UIBP.Avatar_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\138\168\230\128\129\229\164\180\229\131\143-\231\149\140\233\157\162"
    }
  },
  share_suit_invite_tip = {
    keyName = "share_suit_invite_tip",
    moduleName = "client.slua.umg.team.share_suit_invite_tip",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    asy = true,
    uiStat = {
      name = "\230\156\141\232\163\133\229\136\134\228\186\171\233\130\128\232\175\183"
    }
  },
  Common_Notify_UIBP = {
    keyName = "Common_Notify_UIBP",
    moduleName = "client.slua.umg.lobby.Common_Notify_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\143\179\228\184\139\229\188\185\231\170\151-\233\129\147\229\133\183\231\177\187\230\143\144\231\164\186"
    }
  },
  Notify_Invite_UIBP = {
    keyName = "Notify_Invite_UIBP",
    moduleName = "client.slua.umg.lobby.Notify_Invite_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\143\179\228\184\139\229\188\185\231\170\151-\233\130\128\232\175\183\231\177\187\230\143\144\231\164\186"
    }
  },
  one_more_team_tip = {
    keyName = "one_more_team_tip",
    moduleName = "client.slua.umg.teamup.One_More_Team_Tip_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\233\130\128\232\175\183\229\134\141\230\157\165\228\184\128\229\177\128"
    }
  },
  Common_RightBottom_Tip_UIBP = {
    keyName = "Common_RightBottom_Tip_UIBP",
    moduleName = "client.slua.umg.common.Common_RightBottom_Tip_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    closeOnHide = false,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\233\128\154\231\148\168\229\143\179\228\184\139\229\188\185\231\170\151"
    }
  },
  Common_RightBottom_NoPic_UIBP = {
    keyName = "Common_RightBottom_NoPic_UIBP",
    moduleName = "client.slua.umg.common.Common_RightBottom_NoPic_UIBP",
    closeOnHide = false,
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\233\128\154\231\148\168\229\143\179\228\184\139\229\188\185\231\170\151-\228\184\141\229\184\166\229\155\190\231\137\135"
    }
  },
  Common_RightBottom_Tip_Download = {
    keyName = "Common_RightBottom_Tip_Download",
    moduleName = "client.slua.umg.common.Common_RightBottom_Tip_Download",
    closeOnHide = false,
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP_2.Common_Popup_UIBP_2",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\143\179\228\184\139\229\188\185\231\170\151-\228\184\139\232\189\189\230\143\144\231\164\186"
    }
  },
  Group_Buy_Popup = {
    keyName = "Group_Buy_Popup",
    moduleName = "client.slua.umg.common.Group_Buy_Popup",
    closeOnHide = false,
    path = "/Game/UMG/UI_BP/Universal_Popup/Group_Buy_Popup.Group_Buy_Popup",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\143\179\228\184\139\229\188\185\231\170\151-\229\155\162\232\180\173\230\143\144\231\164\186"
    }
  },
  Common_ServerSwitch = {
    keyName = "Common_ServerSwitch",
    moduleName = "client.slua.umg.common.Common_ServerSwitch",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP_3.Common_Popup_UIBP_3",
    closeOnHide = false,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\143\179\228\184\139\229\188\185\231\170\151-\229\136\135\230\141\162\230\156\141\229\138\161\229\153\168\230\143\144\231\164\186"
    }
  },
  Common_InviteInteraction_Tips_UIBP = {
    keyName = "Common_InviteInteraction_Tips_UIBP",
    moduleName = "client.slua.umg.Universal_Popup.Common_InviteInteraction_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_InviteInteraction_Tips_UIBP.Common_InviteInteraction_Tips_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\233\128\154\231\148\168-\228\186\164\228\186\146-\233\130\128\232\175\183\229\188\185\231\170\151"
    }
  },
  Common_Receive_UIBP = {
    keyName = "Common_Receive_UIBP",
    moduleName = "client.slua.umg.Common.Common_Receive_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\231\164\188\231\137\169\228\184\173\229\191\131\229\188\185\229\135\186\230\161\134(\233\135\145\232\163\133)"
    }
  },
  TarotCardGiftReceiveTips = {
    keyName = "TarotCardGiftReceiveTips",
    moduleName = "client.slua.umg.lobby_activity.AsyncLuckySpin.Exchange.TarotCard.TarotCardGiftReceiveTips",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\231\164\188\231\137\169\228\184\173\229\191\131\229\188\185\229\135\186\230\161\134(\229\161\148\231\189\151\233\135\145\232\163\133)"
    }
  },
  Championship_Invite_Tip = {
    keyName = "Championship_Invite_Tip",
    moduleName = "client.slua.umg.championship_india.championship_invite_tip",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\233\130\128\232\175\183\229\188\185\231\170\151"
    }
  },
  Achievement_Tip_UIBP = {
    keyName = "Achievement_Tip_UIBP",
    moduleName = "client.slua.umg.task.Achievement_Tip_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\230\136\144\229\176\177-\232\190\185\231\149\140\230\181\174\231\170\151"
    }
  },
  Common_Reward_UIBP = {
    keyName = "Common_Reward_UIBP",
    moduleName = "client.slua.umg.common.Common_Reward_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\233\128\154\231\148\168\232\142\183\229\190\151\229\165\150\229\138\177\229\188\185\231\170\151"
    }
  },
  Common_Reward_UIBP_InFighting = {
    keyName = "Common_Reward_UIBP_InFighting",
    moduleName = "client.slua.umg.common.Common_Reward_UIBP_InFighting",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\233\128\154\231\148\168\232\142\183\229\190\151\229\165\150\229\138\177\229\188\185\231\170\151-\229\177\128\229\134\133"
    }
  },
  Common_Right_Reward_UIBP = {
    keyName = "Common_Right_Reward_UIBP",
    moduleName = "client.slua.umg.common.Common_Right_Reward_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\233\128\154\231\148\168-\229\143\179\228\190\167\229\165\150\229\138\177-\229\188\185\231\170\151"
    }
  },
  esport_center_tip = {
    keyName = "esport_center_tip",
    moduleName = "client.slua.umg.esport.esport_center_tip",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\231\148\181\231\171\158\228\184\173\229\191\131-\232\174\162\233\152\133\233\128\154\231\159\165"
    }
  },
  Newbie_Death_Recommend_RightBottom_Tip = {
    keyName = "Newbie_Death_Recommend_RightBottom_Tip",
    moduleName = "client.slua.umg.newbie.Newbie_Death_Recommend_RightBottom_Tip",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\232\191\155\233\152\182\232\174\173\231\187\131\230\173\187\228\186\161\230\142\168\232\141\144\229\188\185\231\170\151"
    }
  },
  EmoteDanceInviteUI = {
    keyName = "EmoteDanceInviteUI",
    moduleName = "client.slua.umg.Emote.EmoteDanceInviteUI",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    asy = true,
    uiStat = {
      name = "\229\133\177\232\136\158\233\130\128\232\175\183"
    }
  },
  Common_ProBarTip_UIBP = {
    keyName = "Common_ProBarTip_UIBP",
    moduleName = "client.slua.umg.common.CommonProBarTip.Common_ProBarTip_UIBP",
    path = "/Game/UMG/UI_BP/Common/CommonProBarTip/Common_ProBarTip_UIBP.Common_ProBarTip_UIBP",
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Skip,
    zOrder = EFixedZOrder.Click_Animation,
    uiStat = {
      name = "\233\128\154\231\148\168\231\177\187-\232\191\155\229\186\166\230\157\161\231\173\137\231\186\167Tip\229\177\149\231\164\186"
    }
  },
  Common_Tab_Vertical_LevelOne_CountDown_Item_UIBP = {
    keyName = "Common_Tab_Vertical_LevelOne_CountDown_Item_UIBP",
    moduleName = "client.slua.umg.Common.Tab.Vertical.LevelOne.LevelOne_Text.Item.Common_Tab_Vertical_LevelOne_CountDown_Item_UIBP",
    path = "/Game/UMG/UI_BP/Common/Tab/Vertical/LevelOne/LevelOne_Text/Item/Common_Tab_Vertical_LevelOne_CountDown_Item_UIBP.Common_Tab_Vertical_LevelOne_CountDown_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\233\128\154\231\148\168\231\171\150\229\144\145\233\161\181\231\173\190\229\128\146\232\174\161\230\151\182item"
    }
  },
  Common_Info_RankIntegralLevel_Large_New_Item = {
    keyName = "Common_Info_RankIntegralLevel_Large_New_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_RankIntegralLevel_Large_New_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_RankIntegralLevel_Large_New_Item.Common_Info_RankIntegralLevel_Large_New_Item",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.rank_integral_pool,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\231\164\190\228\186\164\229\144\141\231\137\135-\230\174\181\228\189\141\229\164\167\231\149\140\233\157\162-\231\171\150\229\144\145"
    }
  },
  Common_Info_small_New_Item = {
    keyName = "Common_Info_small_New_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_small_New_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_small_New_Item.Common_Info_small_New_Item",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\231\164\190\228\186\164\229\144\141\231\137\135-\229\176\143\231\149\140\233\157\162-\230\168\170\229\144\145-\231\177\187\229\158\139\232\175\180\230\152\142"
    }
  },
  Common_Info_CollectLevel_Large_Item_V_UIBP = {
    keyName = "Common_Info_CollectLevel_Large_Item_V_UIBP",
    moduleName = "client.slua.umg.common.Info.Common_Info_CollectLevel_Large_Item_V_UIBP",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_CollectLevel_Large_Item_V_UIBP.Common_Info_CollectLevel_Large_Item_V_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\229\144\141\231\137\135-\231\164\190\228\186\164\229\144\141\231\137\135-\231\171\150\229\144\145\231\143\141\232\151\143\231\149\140\233\157\162-\229\164\167"
    },
    loadFromPool = EUIConfigPoolType.other_pool
  },
  Common_Info_WowLevel_Large_Item_V_UIBP = {
    keyName = "Common_Info_WowLevel_Large_Item_V_UIBP",
    moduleName = "client.slua.umg.common.Info.Common_Info_WowLevel_Large_Item_V_UIBP",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_WowLevel_Large_Item_V_UIBP.Common_Info_WowLevel_Large_Item_V_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\229\144\141\231\137\135-\231\164\190\228\186\164\229\144\141\231\137\135-\231\171\150\229\144\145WOW\229\136\155\228\189\156-\229\164\167"
    },
    loadFromPool = EUIConfigPoolType.other_pool
  },
  Common_Info_WowPlay_Large_Item_V_UIBP = {
    keyName = "Common_Info_WowPlay_Large_Item_V_UIBP",
    moduleName = "client.slua.umg.common.Info.Common_Info_WowPlay_Large_Item_V_UIBP",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_WowLevel_Large_Item_V_UIBP.Common_Info_WowLevel_Large_Item_V_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\229\144\141\231\137\135-\231\164\190\228\186\164\229\144\141\231\137\135-\231\171\150\229\144\145WOW\230\184\184\231\142\169-\229\164\167"
    },
    loadFromPool = EUIConfigPoolType.other_pool
  },
  Common_Info_Relation_Large_Item_V_UIBP = {
    keyName = "Common_Info_Relation_Large_Item_V_UIBP",
    moduleName = "client.slua.umg.common.Info.Common_Info_Relation_Large_Item_V_UIBP",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_Relation_Large_Item_V_UIBP.Common_Info_Relation_Large_Item_V_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\229\144\141\231\137\135-\231\164\190\228\186\164\229\144\141\231\137\135-\231\171\150\229\144\145\228\186\178\229\175\134\229\133\179\231\179\187\231\149\140\233\157\162-\229\164\167"
    },
    loadFromPool = EUIConfigPoolType.other_pool
  },
  Common_Google_Play_Point_UIBP = {
    keyName = "Common_Google_Play_Point_UIBP",
    moduleName = "client.slua.umg.common.CommonItemGet.Common_Google_Play_Point_UIBP",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Common_Google_Play_Point_UIBP.Common_Google_Play_Point_UIBP",
    uiStat = {name = "XX\231\149\140\233\157\162"}
  },
  Common_Items_UIBP = {
    keyName = "Common_Items_UIBP",
    moduleName = "client.slua.component.item.Common_Items_UIBP",
    path = "/Game/UMG/UI_Logic/Common/CommonItem/Common_Items_UIBP.Common_Items_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  Common_Avatar_CollectLevel = {
    keyName = "Common_Avatar_CollectLevel",
    moduleName = "client.slua.component.avatar.Common_Avatar_CollectLevel",
    path = "/Game/UMG/UI_BP/Common/Common_Avatar_Collect_Level_UIBP.Common_Avatar_Collect_Level_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.avatar_pool
  },
  Common_Avatar_Reddot_UIBP = {
    keyName = "Common_Avatar_Reddot_UIBP",
    moduleName = "client.slua.component.avatar.Common_Avatar_Reddot_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Avatar_Reddot_UIBP.Common_Avatar_Reddot_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.avatar_pool
  },
  Common_Avatar_DynamicAvatar = {
    keyName = "Common_Avatar_DynamicAvatar",
    moduleName = "client.slua.component.avatar.Common_Avatar_DynamicAvatar",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.avatar_pool
  },
  Common_Avatar_ChildUIWithoutBpPath = {
    keyName = "Common_Avatar_ChildUIWithoutBpPath",
    moduleName = "client.slua_ui_framework.base",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.avatar_pool
  },
  Reddot_Anchor_Item = {
    keyName = "Reddot_Anchor_Item",
    moduleName = "client.slua.component.reddot.Reddot_Anchor_Item",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.reddot_pool
  },
  Common_Download_UI = {
    keyName = "Common_Download_UI",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/Common/Common_Download_UI.Common_Download_UI",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.downloadui_pool
  },
  CommonBaseComponent_TextButton_UIBP = {
    keyName = "CommonBaseComponent_TextButton_UIBP",
    moduleName = "client.slua.umg.common.BaseComponent.CommonBaseComponent_TextButton_UIBP",
    path = "/Game/UMG/UI_BP/Common/BaseComponent/CommonBaseComponent_TextButton_UIBP.CommonBaseComponent_TextButton_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\233\128\154\231\148\168\229\159\186\231\161\128\230\142\167\228\187\182-\230\150\135\230\156\172\230\140\137\233\146\174"
    }
  },
  CommonItemChildUIWithoutBpPath = {
    keyName = "CommonItemChildUIWithoutBpPath",
    moduleName = "client.slua.component.item.ItemChildren.CommonItem_ChildUIBase",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  CommonItem_Signature_UIBP = {
    keyName = "CommonItem_Signature_UIBP",
    moduleName = "client.slua.umg.lobby_item.CommonItem_Signature_UIBP",
    path = "/Game/UMG/UI_Logic/Common/CommonItem/CommonItem_Signature_UIBP.CommonItem_Signature_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\173\190\229\144\141\230\142\167\228\187\182"
    }
  },
  friend_item_menu = {
    keyName = "friend_item_menu",
    moduleName = "client.slua.umg.friend.friend_item_menu",
    path = "/Game/UMG/UI_BP/Friend/Friend_Apply_Report_Tips_UIBP.Friend_Apply_Report_Tips_UIBP",
    uiStat = {
      name = "\229\165\189\229\143\139-\231\148\179\232\175\183\229\136\151\232\161\168-\229\188\185\231\170\151"
    }
  },
  common_protocol_msg = {
    keyName = "common_protocol_msg",
    moduleName = "client.slua.umg.common.common_protocol_msg",
    path = "/Game/UMG/UI_BP/Common/Common_Protocol_Msg_UIBP.Common_Protocol_Msg_UIBP",
    containerName = UIContainers.Top,
    closeOnSwitch = false,
    uiStat = {
      name = "\233\128\154\231\148\168\229\141\143\232\174\174\229\188\185\231\170\151"
    }
  },
  common_protocol_msg_ingame = {
    keyName = "common_protocol_msg_ingame",
    moduleName = "client.slua.umg.common.common_protocol_msg",
    path = "/Game/Mod/CreativeBase/UMG/Common/Creative_Protocol_Msg_UIBP.Creative_Protocol_Msg_UIBP",
    containerName = UIContainers.Top,
    closeOnSwitch = false,
    uiStat = {
      name = "\233\128\154\231\148\168\229\141\143\232\174\174\229\188\185\231\170\151"
    }
  },
  common_rule_link_msg = {
    keyName = "common_rule_link_msg",
    moduleName = "client.slua.umg.common.common_rule_link_msg",
    path = "/Game/UMG/UI_BP/Common/Common_Protocol_Msg1_UIBP.Common_Protocol_Msg1_UIBP",
    containerName = UIContainers.Top,
    closeOnSwitch = false,
    uiStat = {
      name = "\233\128\154\231\148\168\232\167\132\229\136\153\232\175\180\230\152\142-\232\183\179\232\189\172\233\147\190\230\142\165"
    }
  },
  common_legal_sure = {
    keyName = "common_legal_sure",
    moduleName = "client.slua.umg.common.common_legal_sure",
    path = "/Game/UMG/UI_BP/Common/Common_Legal_UIBP.Common_Legal_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\231\148\168\230\136\183\231\161\174\232\174\164\230\179\149\229\138\161\231\155\184\229\133\179\229\188\185\231\170\151"
    }
  },
  Common_Legal_01_UIBP = {
    keyName = "Common_Legal_01_UIBP",
    moduleName = "client.slua.umg.common.Common_Legal_01_UIBP",
    path = "/Game/UMG/UI_BP/Common/Common_Legal_01_UIBP.Common_Legal_01_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\150\176-\231\148\168\230\136\183\231\161\174\232\174\164\230\179\149\229\138\161\231\155\184\229\133\179\229\188\185\231\170\151"
    }
  },
  new_supply_get_panel = {
    keyName = "new_supply_get_panel",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.crate.new_supply_get_panel",
    path = "/Game/UMG/UI_BP/NewStore/crate/Supply_ItemGet_UIBP.Supply_ItemGet_UIBP",
    asy = true,
    uiStat = {
      name = "\232\161\165\231\187\153-\229\174\157\231\174\177\230\129\173\229\150\156\232\142\183\229\190\151"
    }
  },
  common_pickonebox = {
    keyName = "common_pickonebox",
    moduleName = "client.slua.umg.common.common_pickonebox",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Activity_Godzilla_DaoJu_UIBP.Activity_Godzilla_DaoJu_UIBP",
    uiStat = {
      name = "\229\164\154\233\128\137\228\184\128\231\149\140\233\157\162"
    }
  },
  button_recorder = {
    keyName = "button_recorder",
    moduleName = "client.slua.umg.common.button_recorder",
    path = "/Game/UMG/UI_BP/GM/BP_GM_RecordTouchEvent.BP_GM_RecordTouchEvent",
    containerName = UIContainers.Top
  },
  Common_Popup_Reward_Base = {
    keyName = "Common_Popup_Reward_Base",
    moduleName = "client.slua.umg.Common.Common_Popup_Reward_Base",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Explain_UIBP.Common_Popup_Theme_Explain_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\229\165\150\229\138\177\229\177\149\231\164\186\229\188\185\231\170\151"
    }
  },
  CommonPopup_RewardTipParent_UIBP = {
    keyName = "CommonPopup_RewardTipParent_UIBP",
    moduleName = "client.slua.umg.common.CommonPopup_RewardTipParent_UIBP",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/CommonPopup_RewardTipParent_UIBP.CommonPopup_RewardTipParent_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\233\128\154\231\148\168\231\177\187\229\165\150\229\138\177\232\142\183\229\190\151\228\185\139\229\144\142\231\154\132Tip\229\188\185\231\170\151-\231\136\182UI"
    }
  },
  Common_Popup_Theme_Explain_Picture08_Item_UIBP = {
    keyName = "Common_Popup_Theme_Explain_Picture08_Item_UIBP",
    moduleName = "client.slua.umg.Common.Common_Popup_Theme_Explain_Picture08_Item_UIBP",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Item/Common_Popup_Theme_Explain_Picture08_Item_UIBP.Common_Popup_Theme_Explain_Picture08_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\165\150\229\138\177\233\162\134\229\143\150\230\140\130\232\189\189\231\137\169\229\147\129"
    }
  },
  Hall_Picture_Popup_UIBP = {
    keyName = "Hall_Picture_Popup_UIBP",
    moduleName = "client.slua.umg.Common.Tips.Hall_Picture_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Hall_Picture_Popup_UIBP.Hall_Picture_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\184\167\231\142\135\232\174\190\231\189\174\229\187\186\232\174\174\229\188\185\231\170\151"
    }
  },
  notify_recommend_download = {
    keyName = "notify_recommend_download",
    moduleName = "client.slua.umg.download.notify_recommend_download",
    isMainUI = false,
    path = "/Game/UMG/UI_BP/Lobby/Main/Lobby_DownloaderSpecial_Btn_UIBP1.Lobby_DownloaderSpecial_Btn_UIBP1"
  },
  notify_recommend_delete = {
    keyName = "notify_recommend_delete",
    moduleName = "client.slua.umg.download.notify_recommend_delete",
    path = "/Game/UMG/UI_BP/Download/Popup/Download_Popup_Cleanup_UIBP.Download_Popup_Cleanup_UIBP",
    uiStat = {
      name = "\230\142\168\232\141\144\229\136\160\233\153\164"
    }
  },
  download_space_alert = {
    keyName = "download_space_alert",
    moduleName = "client.slua.umg.download.download_space_alert",
    path = "/Game/UMG/UI_BP/Download/Download_Popup_Item_BP.Download_Popup_Item_BP"
  },
  downloader = {
    keyName = "downloader",
    moduleName = "client.slua.umg.download.downloader",
    path = "/Game/UMG/UI_BP/Download/Download_Popup_UIBP_2.Download_Popup_UIBP_2",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    asy = true,
    uiStat = {
      name = "\228\184\139\232\189\189\231\149\140\233\157\162"
    }
  },
  downloader_prefetch_tips = {
    keyName = "downloader_prefetch_tips",
    moduleName = "client.slua.umg.download.downloader_prefetch_tips",
    path = "/Game/UMG/UI_BP/Download/Download_Popup_Item_BP2.Download_Popup_Item_BP2"
  },
  guest_find_password_result = {
    keyName = "guest_find_password_result",
    moduleName = "client.slua.umg.guest_bind.Guest_RetrieveAccount_BP",
    path = "/Game/UMG/UI_BP/GuestBind/Guest_RetrieveAccount_BP.Guest_RetrieveAccount_BP",
    asy = true,
    uiStat = {
      name = "\230\184\184\229\174\162\232\180\166\229\143\183\230\137\190\229\155\158\231\187\147\230\158\156\229\177\149\231\164\186"
    }
  },
  guest_find_password_popup = {
    keyName = "guest_find_password_popup",
    moduleName = "client.slua.umg.guest_bind.Guest_ConnectAccount_BP",
    path = "/Game/UMG/UI_BP/GuestBind/Guest_ConnectAccount_BP.Guest_ConnectAccount_BP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\230\184\184\229\174\162\232\180\166\229\143\183\230\137\190\229\155\158\230\136\144\229\138\159\229\188\185\231\170\151"
    }
  },
  guest_bind_main = {
    keyName = "guest_bind_main",
    moduleName = "client.slua.umg.guest_bind.guest_bind_main",
    path = "/Game/UMG/UI_BP/GuestBind/Guest_Bind_BP.Guest_Bind_BP",
    isSingleton = false,
    isMainUI = false,
    asy = true
  },
  play_return_UC_got = {
    keyName = "play_return_UC_got",
    moduleName = "client.slua.umg.player_return.New_ComeBack_itemGet_UIBP",
    path = "/Game/UMG/UI_BP/PlayerReturn/New_ComeBack_itemGet_2_UIBP.New_ComeBack_itemGet_2_UIBP",
    asy = true,
    uiStat = {
      name = "\229\155\158\230\181\129\231\142\169\229\174\182-UC\232\142\183\229\190\151"
    }
  },
  championship_teamup = {
    keyName = "championship_teamup",
    moduleName = "client.slua.umg.Championship_India.championship_teamup",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_India_Prepare_1_UIBP.Championship_India_Prepare_1_UIBP",
    uiStat = {
      name = "\232\181\158\229\138\169\232\181\155-\231\187\132\233\152\159"
    }
  },
  Championship_Sponsor_Mgr_UIBP = {
    keyName = "Championship_Sponsor_Mgr_UIBP",
    moduleName = "client.slua.umg.championship_india.championship_sponsor_mgr_ui_bp",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_Sponsor_Mgr_UIBP.Championship_Sponsor_Mgr_UIBP",
    uiStat = {
      name = "\231\171\158\230\138\128\232\181\155-\233\161\181\231\173\190\231\174\161\231\144\134"
    }
  },
  Championship_Sponsor_OneMain_UIBP = {
    keyName = "Championship_Sponsor_OneMain_UIBP",
    moduleName = "client.slua.umg.championship_india.championship_sponsor_one_main_ui_bp",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_Sponsor_OneMain_UIBP.Championship_Sponsor_OneMain_UIBP",
    uiStat = {
      name = "\231\171\158\230\138\128\232\181\155-\228\184\187\233\161\181"
    }
  },
  Championship_Sponsor_One_Desc_UIBP = {
    keyName = "Championship_Sponsor_One_Desc_UIBP",
    moduleName = "client.slua.umg.championship_india.championship_sponsor_one_desc_ui_bp",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_Sponsor_One_Desc_UIBP.Championship_Sponsor_One_Desc_UIBP",
    uiStat = {
      name = "\231\171\158\230\138\128\232\181\155-\232\175\166\230\131\133\228\187\139\231\187\141"
    }
  },
  Championship_Sponsor_One_Desc_Tips_UIBP = {
    keyName = "Championship_Sponsor_One_Desc_Tips_UIBP",
    moduleName = "client.slua.umg.championship_india.championship_sponsor_one_desc_tips_ui_bp",
    path = "/Game/UMG/UI_BP/Championship_India/Sponsor_One_desc_tips_UIBP.Sponsor_One_desc_tips_UIBP",
    uiStat = {
      name = "\231\171\158\230\138\128\232\181\155-\232\175\166\230\131\133\228\187\139\231\187\141Tips"
    }
  },
  Championship_Rule_UIBP = {
    keyName = "Championship_Rule_UIBP",
    moduleName = "client.slua.umg.championship_india.Championship_India_Rule",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_India_jiesuan_1_BP.Championship_India_jiesuan_1_BP",
    uiStat = {
      name = "\233\148\166\230\160\135\232\181\155-\231\167\175\229\136\134\232\167\132\229\136\153"
    }
  },
  Championship_Rule2_UIBP = {
    keyName = "Championship_Rule2_UIBP",
    moduleName = "client.slua.umg.championship_india.Championship_India_Rule2",
    path = "/Game/UMG/UI_BP/Championship_India/Championship_India_jiesuan_2_BP.Championship_India_jiesuan_2_BP",
    uiStat = {
      name = "\233\148\166\230\160\135\232\181\155-\231\167\175\229\136\134\232\167\132\229\136\153"
    }
  },
  Championship_Popup_SignUp = {
    keyName = "Championship_Popup_SignUp",
    moduleName = "client.slua.umg.championship_india.championship_popup_signup",
    path = "/Game/UMG/UI_BP/Championship_India/Champior_Entrance_Zijian_UIPB.Champior_Entrance_Zijian_UIPB",
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\230\138\165\229\144\141\229\188\185\231\170\151"
    }
  },
  Championship_Apply_List = {
    keyName = "Championship_Apply_List",
    moduleName = "client.slua.umg.championship_india.championship_apply_list",
    path = "/Game/UMG/UI_BP/Championship_India/Champior_Entrance_Zijian_UIPB_01.Champior_Entrance_Zijian_UIPB_01",
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\231\187\132\233\152\159\231\148\179\232\175\183"
    }
  },
  Championship_Find_List = {
    keyName = "Championship_Find_List",
    moduleName = "client.slua.umg.championship_india.championship_find_list",
    path = "/Game/UMG/UI_BP/Championship_India/Champior_Entrance_Zijian_UIPB_01.Champior_Entrance_Zijian_UIPB_01",
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\229\143\145\231\142\176\229\165\189\229\143\139\233\152\159\228\188\141"
    }
  },
  Championship_Entrance_SignUp = {
    keyName = "Championship_Entrance_SignUp",
    moduleName = "client.slua.umg.championship_india.championship_entrance_signup",
    path = "/Game/UMG/UI_BP/Championship_India/Champior_Entrance_Signup_UIPB.Champior_Entrance_Signup_UIPB",
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\230\138\165\229\144\141\229\133\165\229\143\163"
    }
  },
  Championship_Select_Area = {
    keyName = "Championship_Select_Area",
    moduleName = "client.slua.umg.championship_india.championship_select_area",
    path = "/Game/UMG/UI_BP/Championship_India/Sponsor_Popup_Select_UIBP.Sponsor_Popup_Select_UIBP",
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\230\138\165\229\144\141\232\181\155\229\140\186\233\128\137\230\139\169"
    }
  },
  Championship_Result_Popup = {
    keyName = "Championship_Result_Popup",
    moduleName = "client.slua.umg.championship_india.championship_result_popup",
    path = "/Game/UMG/UI_BP/Championship_India/Champion_Enter_Successful_promotion_UIBP.Champion_Enter_Successful_promotion_UIBP",
    uiStat = {
      name = "\232\135\170\229\187\186\232\181\155-\232\181\155\228\186\139\230\153\139\231\186\167\229\188\185\231\170\151"
    }
  },
  pandora_loading = {
    keyName = "pandora_loading",
    moduleName = "client.slua.umg.pandora.pandora_loading",
    path = "/Game/UMG/UI_BP/Pandora/Pandora_Loading_UIBP.Pandora_Loading_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\189\152\229\164\154\230\139\137-\229\138\160\232\189\189"
    },
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.TopZOrder
  },
  pandora_Exchange = {
    keyName = "pandora_Exchange",
    moduleName = "client.slua.umg.pandora.Exchange_UIBP",
    path = "/Game/UMG/UI_BP/Pandora/Pandora_Exchange_UIBP.Pandora_Exchange_UIBP",
    jumpModuleID = BP_ENUM_MODULE_PANDORA_EXCHANGE,
    uiStat = {
      name = "\230\189\152\229\164\154\230\139\137-\229\133\145\230\141\162\229\149\134\229\186\151"
    }
  },
  Pandora_Popular_UIBP = {
    keyName = "Pandora_Popular_UIBP",
    moduleName = "client.slua.umg.pandora.Pandora_Popular_UIBP",
    path = "/Game/UMG/UI_BP/SpecialOffer/Pandora/Pandora_Main_UIBP.Pandora_Main_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\137\185\230\131\160-\230\189\152\229\164\154\230\139\137\231\131\173\233\151\168\230\180\187\229\138\168"
    }
  },
  Pandora_Item_UIBP = {
    keyName = "Pandora_Item_UIBP",
    moduleName = "client.slua.umg.pandora.Pandora_Item_UIBP",
    path = "/Game/UMG/UI_BP/SpecialOffer/Pandora/Item/Pandora_Item_UIBP.Pandora_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\231\137\185\230\131\160-\230\189\152\229\164\154\230\139\137\231\131\173\233\151\168\230\180\187\229\138\168-\229\133\165\229\143\163item"
    }
  },
  PandoraContainer_UIBP = {
    keyName = "PandoraContainer_UIBP",
    moduleName = "client.slua.umg.pandora.PandoraContainer_UIBP",
    path = "/Game/UMG/UI_BP/Pandora/PandoraContainer_UIBP.PandoraContainer_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\189\152\229\164\154\230\139\137-\230\180\187\229\138\168\228\184\173\229\191\131\229\174\185\229\153\168"
    }
  },
  LuckyAirDrop_Main_UIBP = {
    keyName = "LuckyAirDrop_Main_UIBP",
    moduleName = "client.slua.umg.LuckyAirDrop.LuckyAirDrop_Main_UIBP",
    path = "/Game/UMG/UI_BP/LuckyAirDrop/LuckyAirDrop_Main_UIBP.LuckyAirDrop_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_AIR_DROP,
    uiStat = {
      name = "\229\185\184\232\191\144\231\169\186\230\138\149-\229\149\134\229\159\142"
    }
  },
  LuckyAirDrop_Item_UIBP = {
    keyName = "LuckyAirDrop_Item_UIBP",
    moduleName = "client.slua.umg.LuckyAirDrop.LuckyAirDrop_Item_UIBP",
    path = "/Game/UMG/UI_BP/LuckyAirDrop/Item/LuckyAirDrop_Item_UIBP.LuckyAirDrop_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\185\184\232\191\144\231\169\186\230\138\149-\229\149\134\229\159\142Item"
    }
  },
  LuckyAirDrop_SubItem_UIBP = {
    keyName = "LuckyAirDrop_SubItem_UIBP",
    moduleName = "client.slua.umg.LuckyAirDrop.LuckyAirDrop_SubItem_UIBP",
    path = "/Game/UMG/UI_BP/LuckyAirDrop/Item/LuckyAirDrop_SubItem_UIBP.LuckyAirDrop_SubItem_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\185\184\232\191\144\231\169\186\230\138\149-\229\149\134\229\159\142SubItem"
    }
  },
  LuckyAirDrop_FaceSlap_UIBP = {
    keyName = "LuckyAirDrop_FaceSlap_UIBP",
    moduleName = "client.slua.umg.LuckyAirDrop.LuckyAirDrop_FaceSlap_UIBP",
    path = "/Game/UMG/UI_BP/LuckyAirDrop/LuckyAirDrop_FaceSlap_UIBP.LuckyAirDrop_FaceSlap_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\185\184\232\191\144\231\169\186\230\138\149-\232\167\166\229\143\145\230\139\141\232\132\184"
    }
  },
  LuckyAirDrop_Video_UIBP = {
    keyName = "LuckyAirDrop_Video_UIBP",
    moduleName = "client.slua.umg.LuckyAirDrop.LuckyAirDrop_Video_UIBP",
    path = "/Game/UMG/UI_BP/LuckyAirDrop/LuckyAirDrop_Video_UIBP.LuckyAirDrop_Video_UIBP",
    uiStat = {
      name = "\229\185\184\232\191\144\231\169\186\230\138\149-\232\167\134\233\162\145"
    }
  },
  LuckyAirDrop_Item_Star_UIBP = {
    keyName = "LuckyAirDrop_Item_Star_UIBP",
    moduleName = "client.slua.umg.LuckyAirDrop.LuckyAirDrop_Item_Star_UIBP",
    path = "/Game/UMG/UI_BP/LuckyAirDrop/Item/LuckyAirDrop_Item_Star_UIBP.LuckyAirDrop_Item_Star_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\185\184\232\191\144\231\169\186\230\138\149-\229\149\134\229\159\142Item-\232\175\132\228\187\183"
    }
  },
  ui_room_waiting = {
    keyName = "ui_room_waiting",
    moduleName = "client.slua.umg.room.room_waiting",
    path = "/Game/UMG/UI_BP/Room/NewRoomWaiting.NewRoomWaiting",
    jumpModuleID = BP_ENUM_MODULE_ROOM_WAITING,
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\231\173\137\229\190\133\231\149\140\233\157\162"
    }
  },
  ui_room_waiting_test = {
    keyName = "ui_room_waiting_test",
    moduleName = "client.slua.umg.room.room_waiting_test",
    path = "/Game/UMG/UI_BP/Room/NewRoomWaiting_2.NewRoomWaiting_2",
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\231\173\137\229\190\133\231\149\140\233\157\162-\230\181\139\232\175\149"
    }
  },
  ui_room_ob = {
    keyName = "ui_room_ob",
    moduleName = "client.slua.umg.room.room_ob",
    path = "/Game/UMG/UI_BP/Room/RoomWaiting_Ob_BP.RoomWaiting_Ob_BP",
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-Ob\229\136\151\232\161\168"
    }
  },
  ui_room_ob_allstar = {
    keyName = "ui_room_ob_allstar",
    moduleName = "client.slua.umg.room.room_ob_allstar",
    path = "/Game/UMG/UI_BP/Room/RoomWaiting_Ob_BP.RoomWaiting_Ob_BP",
    asy = true,
    uiStat = {
      name = "\229\133\168\230\176\145\232\181\155-\230\136\191\233\151\180Ob\229\136\151\232\161\168"
    },
    isMainUI = false
  },
  Room_Owner_Setting_UIBP = {
    keyName = "Room_Owner_Setting_UIBP",
    moduleName = "client.slua.umg.room.Room_Owner_Setting_UIBP",
    path = "/Game/UMG/UI_BP/Room/Room_Owner_Setting_UIBP.Room_Owner_Setting_UIBP",
    isMainUI = true,
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\230\136\191\228\184\187\232\176\131\230\149\180\233\152\159\228\188\141\231\149\140\233\157\162"
    }
  },
  Room_Owner_TeamList_Player_Item_UIBP = {
    keyName = "Room_Owner_TeamList_Player_Item_UIBP",
    moduleName = "client.slua.umg.room.Room_Owner_TeamList_Player_Item_UIBP",
    path = "/Game/UMG/UI_BP/Room/Item/Room_Owner_TeamList_Player_Item_UIBP.Room_Owner_TeamList_Player_Item_UIBP",
    isMainUI = false,
    asy = false,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\230\136\191\228\184\187\232\176\131\230\149\180\233\152\159\228\188\141\231\149\140\233\157\162\233\152\159\228\188\141\230\136\144\229\145\152\229\173\144\231\149\140\233\157\162"
    }
  },
  Room_Owner_InTeam_Setting_UIBP = {
    keyName = "Room_Owner_InTeam_Setting_UIBP",
    moduleName = "client.slua.umg.room.Room_Owner_InTeam_Setting_UIBP",
    path = "/Game/UMG/UI_BP/Room/Item/Room_Owner_InTeam_Setting_UIBP.Room_Owner_InTeam_Setting_UIBP",
    isMainUI = true,
    asy = false,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\233\152\159\228\188\141\230\136\144\229\145\152\230\147\141\228\189\156\231\149\140\233\157\162\239\188\136\231\167\187\229\135\186\233\152\159\228\188\141\230\136\150\232\184\162\229\135\186\230\136\191\233\151\180\239\188\137"
    }
  },
  Room_Owner_Waiting_Tips_UIBP = {
    keyName = "Room_Owner_Waiting_Tips_UIBP",
    moduleName = "client.slua.umg.room.Room_Owner_Waiting_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Room/Room_Owner_Waiting_Tips_UIBP.Room_Owner_Waiting_Tips_UIBP",
    isMainUI = true,
    asy = false,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\230\136\191\228\184\187\232\176\131\233\133\141\233\152\159\228\188\141\231\173\137\229\190\133\231\149\140\233\157\162"
    }
  },
  ui_room_change_pswd = {
    keyName = "ui_room_change_pswd",
    moduleName = "client.slua.umg.room.Room_Change_psrd_PopUp",
    path = "/Game/UMG/UI_BP/Room/Room_Change_psrd_PopUp.Room_Change_psrd_PopUp",
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\230\148\185\229\175\134\231\160\129"
    }
  },
  ui_room_change_name = {
    keyName = "ui_room_change_name",
    moduleName = "client.slua.umg.room.Room_Change_Name_PopUp",
    path = "/Game/UMG/UI_BP/Room/Room_Change_psrd_PopUp.Room_Change_psrd_PopUp",
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\230\148\185\230\152\181\231\167\176(\228\186\154\232\191\144\230\168\161\229\188\143)"
    }
  },
  ui_room_creat_bonus = {
    keyName = "ui_room_creat_bonus",
    moduleName = "client.slua.umg.room.Room_CreatRoom_Bonus",
    path = "/Game/UMG/UI_BP/Room/Item/Room_CreatRoom_Item_1_UIBP.Room_CreatRoom_Item_1_UIBP",
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\229\136\155\229\187\186bonus\230\136\191\233\151\180"
    }
  },
  room_create = {
    keyName = "room_create",
    moduleName = "client.slua.umg.room.create.room_create_main",
    path = "/Game/UMG/UI_BP/Room/Room_CreateRoom_UIBP.Room_CreateRoom_UIBP",
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\229\136\155\229\187\186\230\136\191\233\151\180"
    }
  },
  room_create_normal_page = {
    keyName = "room_create_normal_page",
    moduleName = "client.slua.umg.room.create.room_create_normal_page",
    path = "/Game/UMG/UI_BP/Room/Room_CreateRoom_NormalPage.Room_CreateRoom_NormalPage",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\229\136\155\229\187\186\230\136\191\233\151\180-\229\159\186\231\161\128\232\174\190\229\174\154"
    }
  },
  room_create_asian_game_page = {
    keyName = "room_create_asian_game_page",
    moduleName = "client.slua.umg.room.asian_games.room_create_asian_game_page",
    path = "/Game/UMG/UI_BP/Room/Room_CreateRoom_AsianGamesPage.Room_CreateRoom_AsianGamesPage",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\229\136\155\229\187\186\230\136\191\233\151\180-\228\186\154\232\191\144\232\174\190\229\174\154"
    }
  },
  room_create_advance_page = {
    keyName = "room_create_advance_page",
    moduleName = "client.slua.umg.room.create.room_create_advance_page",
    path = "/Game/UMG/UI_BP/Room/Room_CreateRoom_AdvancePage.Room_CreateRoom_AdvancePage",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\229\136\155\229\187\186\230\136\191\233\151\180-\232\191\155\233\152\182\232\174\190\229\174\154"
    }
  },
  room_create_circle_page = {
    keyName = "room_create_circle_page",
    moduleName = "client.slua.umg.room.create.room_create_circle_page",
    path = "/Game/UMG/UI_BP/Room/Room_CreateRoom_AdvancePage.Room_CreateRoom_AdvancePage",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\229\136\155\229\187\186\230\136\191\233\151\180-\230\175\146\229\156\136\232\174\190\229\174\154"
    }
  },
  room_option = {
    keyName = "room_option",
    moduleName = "client.slua.umg.room.option.room_option_main",
    path = "/Game/UMG/UI_BP/Room/Room_Option_UIBP.Room_Option_UIBP",
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\230\136\191\233\151\180\232\174\190\231\189\174"
    }
  },
  room_option_advance_page = {
    keyName = "room_option_advance_page",
    moduleName = "client.slua.umg.room.option.room_option_advance_page",
    path = "/Game/UMG/UI_BP/Room/Room_Option_AdvancePage.Room_Option_AdvancePage",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\230\136\191\233\151\180\232\174\190\231\189\174-\232\191\155\233\152\182\232\174\190\229\174\154"
    }
  },
  room_list = {
    keyName = "room_list",
    moduleName = "client.slua.umg.room.list.room_list_main",
    jumpModuleID = BP_ENUM_MODULE_ROOM_LIST,
    path = "/Game/UMG/UI_BP/Room/Room_List_UIBP.Room_List_UIBP",
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\230\136\191\233\151\180\229\136\151\232\161\168"
    }
  },
  room_list_password_popup = {
    keyName = "room_list_password_popup",
    moduleName = "client.slua.umg.room.list.room_list_password_popup",
    path = "/Game/UMG/UI_BP/Room/Room_Change_psrd_PopUp.Room_Change_psrd_PopUp",
    asy = true,
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\232\190\147\229\133\165\229\175\134\231\160\129"
    }
  },
  Room_Microphone_UIBP = {
    keyName = "Room_Microphone_UIBP",
    moduleName = "client.slua.umg.room.Room_Microphone_UIBP",
    path = "/Game/UMG/UI_BP/Room/Room_Microphone_UIBP.Room_Microphone_UIBP",
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\232\181\155\228\186\139\230\136\191\233\151\180\232\175\173\233\159\179-\233\186\166\229\133\139\233\163\142"
    }
  },
  Room_Speaker_UIBP = {
    keyName = "Room_Speaker_UIBP",
    moduleName = "client.slua.umg.room.Room_Speaker_UIBP",
    path = "/Game/UMG/UI_BP/Room/Room_Microphone_UIBP.Room_Microphone_UIBP",
    uiStat = {
      name = "\230\136\191\233\151\180\231\179\187\231\187\159-\232\181\155\228\186\139\230\136\191\233\151\180\232\175\173\233\159\179-\230\137\172\229\163\176\229\153\168"
    }
  },
  Room_Map_Tips = {
    keyName = "Room_Map_Tips",
    moduleName = "client.slua.umg.room.item.Room_Map_Tips",
    path = "/Game/UMG/UI_BP/Room/Item/Room_Map_Tips.Room_Map_Tips",
    isSingleton = false,
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None
  },
  ingame_process_webview = {
    keyName = "ingame_process_webview",
    moduleName = "client.slua.umg.common.ingame_process_webview",
    path = "/Game/UMG/UI_BP/Common/InGameProcessWebviewSystem.InGameProcessWebviewSystem",
    uiStat = {
      name = "\229\133\172\229\133\177-\229\141\138\229\177\143\231\189\145\233\161\181"
    }
  },
  arena_boom = {
    keyName = "arena_boom",
    moduleName = "client.slua.umg.arena.arena_boom",
    path = "/Game/UMG/UI_BP/Team_competition/BoomSet/Team_competition_gun_item2.Team_competition_gun_item2",
    jumpModuleID = BP_ENUM_MODULE_ARENA_BOOM,
    uiStat = {
      name = "\231\171\158\230\138\128\229\156\186-\230\137\139\233\155\183"
    }
  },
  mentor_mentee_change = {
    keyName = "mentor_mentee_change",
    moduleName = "client.slua.umg.mentor.mentor_mentee_change",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_Main_UIBP.PartnerReadiness_Main_UIBP",
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\233\161\181\231\173\190\229\136\135\230\141\162"
    },
    isMainUI = false
  },
  mentor_main = {
    keyName = "mentor_main",
    moduleName = "client.slua.umg.mentor.mentor_main",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_Veteran_UIBP.PartnerReadiness_Veteran_UIBP",
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\232\128\129\229\133\181\228\184\187\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  mentor_info_item = {
    keyName = "mentor_info_item",
    moduleName = "client.slua.umg.mentor.item.mentor_info_item",
    path = "/Game/UMG/UI_BP/PartnerReadiness/Item/PartnerReadiness_PlayerDetail_UIBP.PartnerReadiness_PlayerDetail_UIBP",
    isSingleton = false
  },
  PartnerReadiness_PlayerDetail02_UIBP = {
    keyName = "PartnerReadiness_PlayerDetail02_UIBP",
    moduleName = "client.slua.umg.mentor.item.PartnerReadiness_PlayerDetail02_UIBP",
    path = "/Game/UMG/UI_BP/PartnerReadiness/Item/PartnerReadiness_PlayerDetail02_UIBP.PartnerReadiness_PlayerDetail02_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\231\137\185\232\174\173\232\144\165\229\156\176-\232\128\129\229\133\181\232\144\165\229\156\176-\231\142\169\229\174\182\232\175\166\230\131\133"
    }
  },
  mentor_level_up = {
    keyName = "mentor_level_up",
    moduleName = "client.slua.umg.mentor.mentor_level_up",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_Get_UIBP.PartnerReadiness_Get_UIBP",
    asy = true,
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\229\141\135\231\186\167\230\143\144\231\164\186"
    }
  },
  mentor_level_award = {
    keyName = "mentor_level_award",
    moduleName = "client.slua.umg.mentor.mentor_level_award",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_Level_UIBP.PartnerReadiness_Level_UIBP",
    asy = true,
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\229\141\135\231\186\167\229\165\150\229\138\177"
    }
  },
  mentor_identity_select = {
    keyName = "mentor_identity_select",
    moduleName = "client.slua.umg.mentor.mentor_identity_select",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_IDSelect_UIBP.PartnerReadiness_IDSelect_UIBP",
    asy = true,
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\232\186\171\228\187\189\233\128\137\230\139\169"
    }
  },
  mentee_invite_wait = {
    keyName = "mentee_invite_wait",
    moduleName = "client.slua.umg.mentor.mentee_invite_wait",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_Experience3_UIBP.PartnerReadiness_Experience3_UIBP",
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\229\134\141\230\172\161\233\130\128\232\175\183\231\173\137\229\190\133\229\155\158\229\164\141"
    }
  },
  mentor_main_guide = {
    keyName = "mentor_main_guide",
    moduleName = "client.slua.umg.mentor.mentor_main_guide",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_Introduction_VeteranGuide_UIBP.PartnerReadiness_Introduction_VeteranGuide_UIBP",
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\232\128\129\229\133\181\229\188\149\229\175\188"
    }
  },
  mentor_record = {
    keyName = "mentor_record",
    moduleName = "client.slua.umg.mentor.mentor_record",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_RecordPopup_UIBP.PartnerReadiness_RecordPopup_UIBP",
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\232\174\176\229\189\149"
    }
  },
  mentee_evaluate = {
    keyName = "mentee_evaluate",
    moduleName = "client.slua.umg.mentor.mentee_evaluate",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_Experience2_UIBP.PartnerReadiness_Experience2_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\230\150\176\229\133\181\232\175\132\228\187\183\231\149\140\233\157\162"
    }
  },
  mentee_evaluate_UI25 = {
    keyName = "mentee_evaluate",
    moduleName = "client.slua.umg.mentor.PartnerReadiness_Experience2_02_UIBP",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_Experience2_02_UIBP.PartnerReadiness_Experience2_02_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\230\150\176\229\133\181\232\175\132\228\187\183\231\149\140\233\157\162-UI2.5"
    }
  },
  GunDIY_Pic_Examine_UI = {
    keyName = "GunDIY_Pic_Examine_UI",
    moduleName = "client.slua.umg.GunDIY.GunDIY_Pic_Examine_UI",
    path = "/Game/UMG/UI_BP/GunDIY/GunDIY_Pic_Examine_UI.GunDIY_Pic_Examine_UI",
    uiStat = {
      name = "\230\158\170\230\162\176diy-\229\155\190\231\137\135\230\163\128\230\181\139\230\181\139\232\175\149UI"
    }
  },
  item_upgrade = {
    keyName = "item_upgrade",
    moduleName = "client.slua.umg.upgrade.item_upgrade",
    jumpModuleID = BP_ENUM_MODULE_ITEM_UPGRADE,
    path = "/Game/UMG/UI_BP/NewItemUpgrade/ItemUpgrade_UI_3.ItemUpgrade_UI_3",
    asy = true,
    sceneID = 1,
    uiStat = {
      name = "\231\160\148\231\169\182\230\137\128-\228\184\187\231\149\140\233\157\162"
    }
  },
  item_upgrade_bottom = {
    keyName = "item_upgrade_bottom",
    moduleName = "client.slua.umg.upgrade.item_upgrade_bottom",
    path = "/Game/UMG/UI_BP/ItemUpgrade/ItemUpgrade_AccessorySkin_UIBP.ItemUpgrade_AccessorySkin_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\231\160\148\231\169\182\230\137\128-\229\186\149\233\131\168\233\133\141\228\187\182"
    }
  },
  ItemUp_Mat_Tips_UIBP = {
    keyName = "ItemUp_Mat_Tips_UIBP",
    moduleName = "client.slua.umg.upgrade.item_upgrade_material_tips",
    path = "/Game/UMG/UI_BP/ItemUpgrade/ItemUp_Mat_Tips_UIBP.ItemUp_Mat_Tips_UIBP",
    asy = true,
    uiStat = {
      name = "\231\160\148\231\169\182\230\137\128-\230\157\144\230\150\153\229\188\185\231\170\151"
    }
  },
  item_upgrade_effect = {
    keyName = "item_upgrade_effect",
    moduleName = "client.slua.umg.upgrade.item_upgrade_effect",
    path = "/Game/UMG/UI_BP/Common/ItemUpgrade_Effect_UI.ItemUpgrade_Effect_UI",
    AndroidBackType = EAndroidBackType.Skip,
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.BottomZOrder,
    uiStat = {
      name = "\228\187\147\229\186\147-\229\141\135\231\186\167\231\137\185\230\149\136"
    }
  },
  item_upgrade_animation = {
    keyName = "item_upgrade_animation",
    moduleName = "client.slua.umg.upgrade.item_upgrade_animation",
    path = "/Game/UMG/UI_BP/NewItemUpgrade/ItemUpgrade_Get_UIBP.ItemUpgrade_Get_UIBP",
    asy = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\228\187\147\229\186\147-\229\141\135\231\186\167\230\158\170ui\229\138\168\230\149\136"
    }
  },
  ItemUpgrade_Get_UIBP1 = {
    keyName = "ItemUpgrade_Get_UIBP1",
    moduleName = "client.slua.umg.upgrade.ItemUpgrade_Get_UIBP1",
    path = "/Game/UMG/UI_BP/NewItemUpgrade/ItemUpgrade_Get_UIBP1.ItemUpgrade_Get_UIBP1",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\228\187\147\229\186\147-\229\141\135\231\186\167\230\158\170\229\141\135\231\186\167Get\233\157\162\230\157\1911"
    }
  },
  ItemUpgrade_Get_UIBP2 = {
    keyName = "ItemUpgrade_Get_UIBP2",
    moduleName = "client.slua.umg.upgrade.ItemUpgrade_Get_UIBP2",
    path = "/Game/UMG/UI_BP/NewItemUpgrade/ItemUpgrade_Get_UIBP2.ItemUpgrade_Get_UIBP2",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\228\187\147\229\186\147-\229\141\135\231\186\167\230\158\170\229\141\135\231\186\167Get\233\157\162\230\157\1912"
    }
  },
  lua_global_ui = {
    keyName = "lua_global_ui",
    moduleName = "client.slua.umg.global.lua_global_ui",
    path = "/Game/UMG/UI_Utility/GlobalLuaWidget.GlobalLuaWidget",
    isMainUI = false
  },
  ItemUpgrade_Audio_UIBP = {
    keyName = "ItemUpgrade_Audio_UIBP",
    moduleName = "client.slua.umg.upgrade.ItemUpgrade_Audio_UIBP",
    path = "/Game/UMG/UI_BP/NewItemUpgrade/ItemUpgrade_Audio_UIBP.ItemUpgrade_Audio_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\141\135\231\186\167\230\158\170\231\154\174\232\130\164\233\159\179\230\149\136item"
    }
  },
  TeamPlatform_UIBP = {
    keyName = "TeamPlatform_UIBP",
    moduleName = "client.slua.umg.teamup.TeamPlatform_UIBP",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/TeamPlatform_Main_UIBP.TeamPlatform_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\187\132\233\152\159\229\164\167\229\142\133-\228\184\187\231\149\140\233\157\162-\230\150\176"
    }
  },
  Peak_TeamPlatform_UIBP = {
    keyName = "Peak_TeamPlatform_UIBP",
    moduleName = "client.slua.umg.teamup.Peak_TeamPlatform_UIBP",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/TeamPlatform_Main_UIBP.TeamPlatform_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\187\132\233\152\159\229\164\167\229\142\133-\228\184\187\231\149\140\233\157\162-\229\183\133\229\179\176\232\181\155"
    }
  },
  ui_mic_evaluation = {
    keyName = "ui_mic_evaluation",
    moduleName = "client.slua.umg.teamup.ui_mic_evaluation",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_Experience_UIBP.TeamPlatform_Experience_UIBP",
    uiStat = {
      name = "\231\187\132\233\152\159\232\175\132\228\187\183\231\149\140\233\157\162"
    }
  },
  TeamPlatform_Filter_UIBP = {
    keyName = "TeamPlatform_Filter_UIBP",
    moduleName = "client.slua.umg.teamup.TeamPlatform_Filter_UIBP",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/Item/TeamPlatform_Dropdown_Item.TeamPlatform_Dropdown_Item",
    isMainUI = false,
    uiStat = {
      name = "\231\187\132\233\152\159\229\164\167\229\142\133\231\173\155\233\128\137\231\149\140\233\157\162"
    }
  },
  Peak_TeamPlatform_Filter_UIBP = {
    keyName = "Peak_TeamPlatform_Filter_UIBP",
    moduleName = "client.slua.umg.teamup.Peak_TeamPlatform_Filter_UIBP",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/Item/TeamPlatform_Dropdown_Item.TeamPlatform_Dropdown_Item",
    isMainUI = false,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\231\187\132\233\152\159\229\164\167\229\142\133\231\173\155\233\128\137\231\149\140\233\157\162"
    }
  },
  TeamPlatform_FilterLanguage_UIBP = {
    keyName = "TeamPlatform_FilterLanguage_UIBP",
    moduleName = "client.slua.umg.teamup.TeamPlatform_FilterLanguage_UIBP",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/TeamPlatform_FilterLanguage_UIBP.TeamPlatform_FilterLanguage_UIBP",
    uiStat = {
      name = "\231\187\132\233\152\159\229\164\167\229\142\133\231\173\155\233\128\137\232\175\173\232\168\128\231\149\140\233\157\162"
    }
  },
  TeamPlatform_MyTeam_UIBP = {
    keyName = "TeamPlatform_MyTeam_UIBP",
    moduleName = "client.slua.umg.teamup.TeamPlatform_MyTeam_UIBP",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/TeamPlatform_MyTeam_UIBP.TeamPlatform_MyTeam_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\187\132\233\152\159\229\164\167\229\142\133-\233\152\159\228\188\141\231\174\161\231\144\134\231\149\140\233\157\162-\230\150\176"
    }
  },
  TeamPlatform_MyTeam_Item = {
    keyName = "TeamPlatform_MyTeam_Item",
    moduleName = "client.slua.umg.teamup.TeamPlatform_MyTeam_Item",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/Item/TeamPlatform_8p_Myteam_Item.TeamPlatform_8p_Myteam_Item",
    isMainUI = false,
    uiStat = {
      name = "\231\187\132\233\152\159\229\164\167\229\142\133\233\152\159\228\188\141\231\174\161\231\144\134\231\149\140\233\157\162\233\161\182\233\131\168item"
    }
  },
  TeamPlatForm_Member_Detail_UIBP = {
    keyName = "TeamPlatForm_Member_Detail_UIBP",
    moduleName = "client.slua.umg.teamup.TeamPlatForm_Member_Detail_UIBP",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_New/TeamPlatForm_Member_Detail_UIBP.TeamPlatForm_Member_Detail_UIBP",
    uiStat = {
      name = "\231\187\132\233\152\159\229\164\167\229\142\133\228\191\161\230\129\175\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  CustomPack_Main_UIBP = {
    keyName = "CustomPack_Main_UIBP",
    moduleName = "client.slua.umg.special_offer.acts.CustomPack_Main_UIBP",
    path = "/Game/UMG/UI_BP/SpecialOffer/CustomPack/CustomPack_Main_UIBP.CustomPack_Main_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "300\229\174\154\229\136\182\231\164\188\229\140\133-\228\184\187\231\149\140\233\157\162"
    }
  },
  AccessRestriction = {
    keyName = "AccessRestriction",
    moduleName = "client.slua.umg.AccessRestriction.AccessRestriction",
    path = "/Game/UMG/UI_BP/AccessRestriction/AccessRestriction.AccessRestriction",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\184\184\229\174\162\232\180\166\229\143\183\229\143\151\233\153\144\232\175\180\230\152\142"
    }
  },
  result_player_detail_view = {
    keyName = "result_player_detail_view",
    moduleName = "GameLua.Mod.BaseMod.Client.BattleResult.ResultPlayerDetailView",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Results_Statistics_UIBP.Results_Statistics_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175-\228\184\170\228\186\186\230\149\176\230\141\174\232\175\166\230\131\133"
    },
    loadFromPool = EUIConfigPoolType.None
  },
  ui_complaint_infection = {
    keyName = "ui_complaint_infection",
    moduleName = "client.slua.umg.complaint.ui_complaint_infection",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Item_UIBP2.Inform_Item_UIBP2",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\230\132\159\230\159\147"
    },
    isSingleton = false
  },
  ui_complaint_classic = {
    keyName = "ui_complaint_classic",
    moduleName = "client.slua.umg.complaint.ui_complaint_classic",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Item_UIBP2.Inform_Item_UIBP2",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\231\187\143\229\133\184"
    },
    isSingleton = false
  },
  ui_complaint_deathreplay = {
    keyName = "ui_complaint_deathreplay",
    moduleName = "client.slua.umg.complaint.ui_complaint_deathreplay",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Item_UIBP2.Inform_Item_UIBP2",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\230\183\152\230\177\176\229\155\158\230\148\190"
    },
    isSingleton = false
  },
  ui_complaint_escape = {
    keyName = "ui_complaint_escape",
    moduleName = "client.slua.umg.complaint.ui_complaint_escape",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Item_UIBP2.Inform_Item_UIBP2",
    uiStat = {
      name = "ReportPanel-Escape"
    },
    isSingleton = false
  },
  ui_complaint_moment = {
    keyName = "ui_complaint_moment",
    moduleName = "client.slua.umg.complaint.ui_complaint_moment",
    path = "/Game/UMG/UI_BP/Moment/Popup/Moment_Inform_Item_UIBP.Moment_Inform_Item_UIBP",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\230\156\139\229\143\139\229\156\136"
    }
  },
  ui_complaint_team_quick = {
    keyName = "ui_complaint_team_quick",
    moduleName = "client.slua.umg.complaint.ui_complaint_team_quick",
    path = "/Game/UMG/UI_BP/Moment/Popup/Moment_Inform_Item_UIBP.Moment_Inform_Item_UIBP",
    uiStat = {
      name = "\233\151\170\233\133\141\229\176\143\233\152\159-\233\152\159\229\144\141\228\184\190\230\138\165\231\149\140\233\157\162"
    }
  },
  ui_complaint_wonderful = {
    keyName = "ui_complaint_wonderful",
    moduleName = "client.slua.umg.complaint.ui_complaint_wonderful",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Item_UIBP2.Inform_Item_UIBP2",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\231\178\190\229\189\169\230\151\182\229\136\187"
    },
    isSingleton = false
  },
  crew_safety_detection_peak = {
    keyName = "crew_safety_detection_peak",
    moduleName = "client.slua.umg.crew.crew_safety_detection_peak",
    path = "/Game/UMG/UI_BP/PeakGame/PeakGame_Detection_UIBP.PeakGame_Detection_UIBP",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\229\174\137\229\133\168\230\163\128\230\181\139"
    }
  },
  MedalDisplayUI = {
    keyName = "MedalDisplayUI",
    moduleName = "GameLua.Mod.BaseMod.Client.BattleResult.BattleResultMedal.BattleResultMedalDisplay_UICtrl",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Medal_Display_UIBP.Medal_Display_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "MedalDisplayUI"
    }
  },
  NewbieGuide_UIBP = {
    keyName = "NewbieGuide_UIBP",
    moduleName = "client.slua.umg.newbie.NewbieGuide_UIBP",
    path = "/Game/UMG/UI_BP/Newbie/NewbieGuide_UIBP.NewbieGuide_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\230\150\176\230\137\139\229\188\149\229\175\188-\230\168\161\230\157\191\231\149\140\233\157\162"
    }
  },
  Share_BG_UIBP = {
    keyName = "Share_BG_UIBP",
    moduleName = "client.slua.umg.shareChild.Share_BG_UIBP",
    path = "/Game/UMG/UI_BP/Share/Share_BG_UIBP.Share_BG_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\136\134\228\186\171-\231\137\169\229\147\129"
    }
  },
  Share_BG_04_UIBP = {
    keyName = "Share_BG_04_UIBP",
    moduleName = "client.slua.umg.shareChild.Share_BG_04_UIBP",
    path = "/Game/UMG/UI_BP/Share/Share_BG_04_UIBP.Share_BG_04_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\136\134\228\186\171-\231\137\169\229\147\129-\229\129\154\229\174\140\228\186\134\231\173\150\229\136\146\229\143\136\228\184\141\232\166\129\228\186\134\239\188\140\229\133\136\231\149\153\231\157\128"
    }
  },
  pubgm_music_main = {
    keyName = "pubgm_music_main",
    moduleName = "client.slua.umg.pubgm_music.pubgm_music_main",
    path = "/Game/UMG/UI_BP/Music_Player/Music_Player_UIBP.Music_Player_UIBP",
    jumpModuleID = BP_ENUM_MODULE_PUBGM_MUSIC,
    enableCDNCompress = true,
    asy = true,
    uiStat = {
      name = "\233\159\179\228\185\144\231\155\146-\228\184\187\231\149\140\233\157\162"
    }
  },
  music_player = {
    keyName = "music_player",
    moduleName = "client.slua.umg.pubgm_music.music_player",
    path = "/Game/UMG/UI_BP/Music_Player/Music_Player_CD_UIBP.Music_Player_CD_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\233\159\179\228\185\144\231\155\146-\230\146\173\230\148\190\229\153\168"
    }
  },
  pubgm_music_first_present = {
    keyName = "pubgm_music_first_present",
    moduleName = "client.slua.umg.pubgm_music.pubgm_music_first_present",
    path = "/Game/UMG/UI_BP/Music_Player/Music_Player_Popups_UIBP.Music_Player_Popups_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\233\159\179\228\185\144\231\155\146-\231\179\187\231\187\159\233\166\150\232\181\160"
    }
  },
  pubgm_music_message_box = {
    keyName = "pubgm_music_message_box",
    moduleName = "client.slua.umg.pubgm_music.pubgm_music_message_box",
    path = "/Game/UMG/UI_BP/Music_Player/Music_Player_CD_Tips_UIBP.Music_Player_CD_Tips_UIBP",
    asy = true,
    uiStat = {
      name = "\233\159\179\228\185\144\231\155\146-\232\191\135\230\156\159\229\136\151\232\161\168"
    }
  },
  pubgm_music_option = {
    keyName = "pubgm_music_option",
    moduleName = "client.slua.umg.pubgm_music.pubgm_music_option",
    path = "/Game/UMG/UI_BP/Music_Player/Music_Player_Option_UIBP.Music_Player_Option_UIBP",
    asy = true,
    uiStat = {
      name = "\233\159\179\228\185\144\231\155\146-\233\159\179\228\185\144\229\136\151\232\161\168\232\174\190\231\189\174"
    }
  },
  team_main = {
    keyName = "team_main",
    moduleName = "client.slua.umg.team.team_main",
    path = "/Game/UMG/UI_BP/TeamUp/Team_Main_UIBP.Team_Main_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    containerName = UIContainers.Bottom,
    uiStat = {
      name = "\229\164\167\229\142\133\231\187\132\233\152\159-\229\174\185\229\153\168"
    }
  },
  TeamUp_Member_Menu_UIBP = {
    keyName = "TeamUp_Member_Menu_UIBP",
    moduleName = "client.slua.umg.team.TeamUp_Member_Menu_UIBP",
    path = "/Game/UMG/UI_BP/TeamUp/TeamUp_Member_Menu_UIBP.TeamUp_Member_Menu_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\164\167\229\142\133\231\187\132\233\152\159-\228\191\161\230\129\175\231\137\140"
    }
  },
  team_member_detail = {
    keyName = "team_member_detail",
    moduleName = "client.slua.umg.team.team_member_detail",
    path = "/Game/UMG/UI_BP/TeamUp/TeamUp_Member_Detail_UIBP.TeamUp_Member_Detail_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133\231\187\132\233\152\159-\228\191\161\230\129\175\232\175\166\230\131\133"
    }
  },
  MomentMessage = {
    keyName = "MomentMessage",
    moduleName = "client.slua.umg.moment.ui_moment_active_message",
    path = "/Game/UMG/UI_BP/Moment/Moment_Message_UIBP.Moment_Message_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\229\138\168\230\128\129\230\182\136\230\129\175\231\149\140\233\157\162"
    }
  },
  MomentPhoto = {
    keyName = "MomentPhoto",
    moduleName = "client.slua.umg.moment.ui_moment_album",
    path = "/Game/UMG/UI_BP/Moment/Moment_Photo_UIBP.Moment_Photo_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\231\155\184\229\134\140\231\149\140\233\157\162"
    }
  },
  MomentPhoto_SubPhoto = {
    keyName = "MomentPhoto_SubPhoto",
    moduleName = "client.slua.umg.moment.ui_moment_album_sub_photo",
    path = "/Game/UMG/UI_BP/Moment/Moment_SubPanel_Photo_UIBP.Moment_SubPanel_Photo_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\231\155\184\229\134\140\231\133\167\231\137\135\229\173\144\231\149\140\233\157\162"
    }
  },
  MomentPhoto_SubVideo = {
    keyName = "MomentPhoto_SubVideo",
    moduleName = "client.slua.umg.moment.ui_moment_album_sub_video",
    path = "/Game/UMG/UI_BP/Moment/Moment_SubPanel_Video_UIBP.Moment_SubPanel_Video_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\231\155\184\229\134\140\232\167\134\233\162\145\229\173\144\231\149\140\233\157\162"
    }
  },
  MomentReply = {
    keyName = "MomentReply",
    moduleName = "client.slua.umg.moment.ui_moment_reply_popup",
    path = "/Game/UMG/UI_BP/Moment/Popup/Moment_Reply_UIBP.Moment_Reply_UIBP",
    uiStat = {
      name = "\230\156\139\229\143\139\229\156\136\232\175\132\232\174\186\229\188\185\231\170\151\231\149\140\233\157\162"
    }
  },
  Moment_Emoji_UIBP = {
    keyName = "Moment_Emoji_UIBP",
    moduleName = "client.slua.umg.moment.Popup.Moment_Emoji_UIBP",
    path = "/Game/UMG/UI_BP/Moment/Item/Moment_Emoji_UIBP.Moment_Emoji_UIBP",
    uiStat = {
      name = "\229\165\189\229\143\139\229\156\136\232\161\168\230\131\133\231\130\185\232\181\158\231\149\140\233\157\162"
    }
  },
  MomentEmoji_BP = {
    keyName = "MomentEmoji_BP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/Moment/Item/MomentEmoji_BP.MomentEmoji_BP",
    isSingleton = false,
    isMainUI = false
  },
  QuestionMark_Popup_01_Item = {
    keyName = "QuestionMark_Popup_01_Item",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/PopupNotice/QuestionMark/Item/QuestionMark_Popup_01_Item01.QuestionMark_Popup_01_Item01",
    isSingleton = false,
    isMainUI = false
  },
  QuestionMark_Popup_02_Item = {
    keyName = "QuestionMark_Popup_02_Item",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/PopupNotice/QuestionMark/Item/QuestionMark_Popup_02_Item02.QuestionMark_Popup_02_Item02",
    isSingleton = false,
    isMainUI = false
  },
  Comon_ItemGet_MustGetTip = {
    keyName = "Comon_ItemGet_MustGetTip",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/Common/Get/Item/Comon_ItemGet_MustGetTip.Comon_ItemGet_MustGetTip",
    asy = false,
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\230\129\173\229\150\156\232\142\183\229\190\151-\229\191\133\229\190\151\229\165\150\229\138\177Tip"
    }
  },
  Fight_PlayerInteract_Confirm_UIBP = {
    keyName = "Fight_PlayerInteract_Confirm_UIBP",
    moduleName = "client.slua.umg.Fight.PlayerInteract.Fight_PlayerInteract_Confirm_UIBP",
    path = "/Game/UMG/UI_BP/Fight/PlayerInteract/Fight_PlayerInteract_Confirm_UIBP.Fight_PlayerInteract_Confirm_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\136\152\230\150\151\229\156\186\230\153\175\231\142\169\229\174\182\228\186\164\228\186\146-\231\161\174\232\174\164\231\149\140\233\157\162"
    }
  },
  Ingame_Like_UIBP = {
    keyName = "Ingame_Like_UIBP",
    moduleName = "client.slua.umg.Fight.Like.Ingame_Like_UIBP",
    path = "/Game/BluePrints/ControlInput/IngameUI/Like/Ingame_Like_UIBP.Ingame_Like_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\136\152\230\150\151-\231\130\185\232\181\158"
    }
  },
  BattlePopTips_InLobby = {
    moduleName = "GameLua.Mod.BaseMod.Client.BattlePopTipsUI.BattlePopTips",
    path = "/Game/BluePrints/ControlInput/BattlePopTips/BattlePopTips.BattlePopTips",
    isSingleton = false,
    uiStat = {
      name = "BattlePopTips_InLobby"
    },
    isMainUI = false
  },
  TDMKillInfo = {
    keyName = "TDMKillInfo",
    moduleName = "GameLua.Mod.TDM.Client.UI.TDMKillInfo",
    path = "/Game/Mod/TDM/BluePrints/UI/TDM_KillInfo_UIBP.TDM_KillInfo_UIBP",
    uiStat = {
      name = "TDMKillInfo"
    },
    closeOnHide = false,
    isMainUI = true,
    isSingleton = true
  },
  KingEliminationInfoItem = {
    keyName = "KingEliminationInfoItem",
    moduleName = "GameLua.Mod.BaseMod.Client.KillInfoTips.KingEliminationInfoItem",
    path = "/Game/BluePrints/ControlInput/IngameUI/TipsItem/KingEliminationItem_UIBP.KingEliminationItem_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "KingEliminationInfoItem"
    },
    asy = true
  },
  teammate_evaluation_ui = {
    keyName = "teammate_evaluation_ui",
    moduleName = "GameLua.Mod.BaseMod.Client.BattleResult.TeammateEvaluationUI",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Item/Teammate_Evaluation_UIBP.Teammate_Evaluation_UIBP",
    uiStat = {
      name = "\229\175\185\229\177\128\232\175\132\228\187\183"
    }
  },
  minor_verification_phone = {
    keyName = "minor_verification_phone",
    moduleName = "client.slua.umg.minor_verification.minor_verification_phone",
    path = "/Game/UMG/UI_BP/MinorVerification/India_Minor_Phone_UIBP.India_Minor_Phone_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\141\176\229\186\166VONAGE\230\156\170\230\136\144\229\185\180\228\186\186\232\174\164\232\175\129-\230\137\139\230\156\186\229\143\183\231\149\140\233\157\162"
    }
  },
  minor_verification_code = {
    keyName = "minor_verification_code",
    moduleName = "client.slua.umg.minor_verification.minor_verification_code",
    path = "/Game/UMG/UI_BP/MinorVerification/India_Minor_Code_UIBP.India_Minor_Code_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\141\176\229\186\166VONAGE\230\156\170\230\136\144\229\185\180\228\186\186\232\174\164\232\175\129-\233\170\140\232\175\129\231\160\129\231\149\140\233\157\162"
    }
  },
  gdpr_verify_result = {
    keyName = "gdpr_verify_result",
    moduleName = "client.slua.umg.GDPR.minor_verify.gdpr_verify_result",
    path = "/Game/UMG/UI_BP/AgeGate/AgeGate_Popup1_UIBP.AgeGate_Popup1_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "gdpr-\233\128\137\230\139\169\233\170\140\232\175\129\230\150\185\229\188\143"
    }
  },
  gdpr_select_verify_process = {
    keyName = "gdpr_select_verify_process",
    moduleName = "client.slua.umg.GDPR.minor_verify.gdpr_select_verify_process",
    path = "/Game/UMG/UI_BP/AgeGate/AgeGate_Popup3_UIBP.AgeGate_Popup3_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "gdpr-\233\128\137\230\139\169\233\170\140\232\175\129\230\150\185\229\188\143"
    }
  },
  gdpr_self_verify = {
    keyName = "gdpr_self_verify",
    moduleName = "client.slua.umg.GDPR.minor_verify.gdpr_self_verify",
    path = "/Game/UMG/UI_BP/AgeGate/AgeGate_Popup7_UIBP.AgeGate_Popup7_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "gdpr-\232\135\170\230\136\145\232\174\164\232\175\129"
    }
  },
  agegate_select_age = {
    keyName = "agegate_select_age",
    moduleName = "client.slua.umg.GDPR.agegate_select_age",
    path = "/Game/UMG/UI_BP/AgeGate/AgeGate_Popup8_UIBP.AgeGate_Popup8_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "agegate-\233\128\137\230\139\169\229\185\180\233\190\132"
    }
  },
  ui_lbs_select_region = {
    keyName = "ui_lbs_select_region",
    moduleName = "client.slua.umg.LBS.ui_lbs_select_region",
    path = "/Game/UMG/UI_BP/LBS/UI_LBS_Select_Region.UI_LBS_Select_Region",
    uiStat = {
      name = "\230\136\152\229\140\186/LBS-lbs\229\140\186\229\159\159\233\128\137\230\139\169\231\149\140\233\157\162"
    }
  },
  share_replay_pop = {
    keyName = "share_replay_pop",
    moduleName = "client.slua.umg.replay.share_replay_pop",
    path = "/Game/UMG/UI_BP/WonderfulReplay/Popup/Replay_Forwarding_UIBP.Replay_Forwarding_UIBP",
    uiStat = {
      name = "\232\189\172\229\143\145\229\136\134\228\186\171\231\178\190\229\189\169\230\151\182\229\136\187reply\229\188\185\231\170\151"
    }
  },
  choose_share_channel = {
    keyName = "choose_share_channel",
    moduleName = "client.slua.umg.replay.choose_share_channel",
    path = "/Game/UMG/UI_BP/WonderfulReplay/Popup/Generate_Grand_Share.Generate_Grand_Share",
    uiStat = {
      name = "\229\136\134\228\186\171\230\184\160\233\129\147\233\128\137\230\139\169\231\149\140\233\157\162"
    }
  },
  Financial_Template_UIBP = {
    keyName = "Financial_Template_UIBP",
    moduleName = "client.slua.umg.Financial.Financial_Template_UIBP",
    path = "/Game/UMG/UI_BP/SpecialOffer/Financial_Main_UIBP.Financial_Main_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\144\134\232\180\162\232\174\161\229\136\146-\228\184\187\231\149\140\233\157\162"
    }
  },
  Financial_Commodity_Item_UIBP = {
    keyName = "Financial_Commodity_Item_UIBP",
    moduleName = "client.slua.umg.Financial.Financial_Commodity_Item_UIBP",
    path = "/Game/UMG/UI_BP/SpecialOffer/Item/Financial_Commodity_Item_UIBP.Financial_Commodity_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\231\144\134\232\180\162\232\174\161\229\136\146-\229\174\157\231\174\177item"
    }
  },
  SmallPayment_Exchange_New_UIBP = {
    keyName = "SmallPayment_Exchange_New_UIBP",
    moduleName = "client.slua.umg.SmallPayment.SmallPayment_Exchange_New_UIBP",
    path = "/Game/UMG/UI_BP/SmallPayment/SmallPayment_Exchange_New_UIBP.SmallPayment_Exchange_New_UIBP",
    jumpModuleID = BP_SMALL_PAYMENT_EXCHANGE,
    uiStat = {
      name = "\229\176\143\233\162\157\228\187\152\232\180\185-280\230\150\176\229\133\145\230\141\162\231\149\140\233\157\162"
    }
  },
  ReputationSystem_Popup_UIBP = {
    keyName = "ReputationSystem_Popup_UIBP",
    moduleName = "client.slua.umg.ReputationSystem.ReputationSystem_Popup_UIBP",
    path = "/Game/UMG/UI_BP/ReputationSystem/ReputationSystem_Popup_UIBP.ReputationSystem_Popup_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\228\191\161\232\170\137\231\179\187\231\187\159\230\139\141\232\132\184"
    }
  },
  ReputationSystem_Popup02_UIBP = {
    keyName = "ReputationSystem_Popup02_UIBP",
    moduleName = "client.slua.umg.ReputationSystem.ReputationSystem_Popup02_UIBP",
    path = "/Game/UMG/UI_BP/ReputationSystem/ReputationSystem_Popup02_UIBP.ReputationSystem_Popup02_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\191\161\232\170\137\231\179\187\231\187\159-\228\191\161\232\170\137\229\136\134\232\175\180\230\152\142"
    }
  },
  ReputationSystem_History_Popup_UIBP = {
    keyName = "ReputationSystem_History_Popup_UIBP",
    moduleName = "client.slua.umg.ReputationSystem.ReputationSystem_History_Popup_UIBP",
    path = "/Game/UMG/UI_BP/ReputationSystem/ReputationSystem_History_Popup_UIBP.ReputationSystem_History_Popup_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\191\161\232\170\137\231\179\187\231\187\159-\229\142\134\229\143\178\230\159\165\232\175\162"
    }
  },
  ReputationSystem_Punish_Popup_UIBP = {
    keyName = "ReputationSystem_Punish_Popup_UIBP",
    moduleName = "client.slua.umg.ReputationSystem.ReputationSystem_Punish_Popup_UIBP",
    path = "/Game/UMG/UI_BP/ReputationSystem/ReputationSystem_Punish_Popup_UIBP.ReputationSystem_Punish_Popup_UIBP",
    uiStat = {
      name = "\233\128\128\232\181\155\229\175\188\232\135\180\231\154\132\231\166\129\232\181\155\229\188\185\231\170\151"
    }
  },
  Battle_Report_Video_Player = {
    keyName = "Battle_Report_Video_Player",
    moduleName = "client.slua.umg.battle_report_video.battle_report_video_player",
    path = "/Game/UMG/UI_BP/BattleReportVideo/Live_Video_Full_Screen_Player.Live_Video_Full_Screen_Player",
    uiStat = {
      name = "\229\159\186\228\186\142\230\189\152\229\164\154\230\139\137LiveVideo\231\154\132\229\133\168\229\177\143\230\146\173\230\148\190\229\153\168"
    }
  },
  Battle_Report_Video_Share_UIBP = {
    keyName = "Battle_Report_Video_Share_UIBP",
    moduleName = "client.slua.umg.battle_report_video.battle_report_video_share",
    path = "/Game/UMG/UI_BP/BattleReportVideo/Battle_Report_Video_Share_UIBP.Battle_Report_Video_Share_UIBP",
    uiStat = {
      name = "\232\167\134\233\162\145\230\136\152\230\138\165\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  level_unlock_icon_item = {
    keyName = "level_unlock_icon_item",
    moduleName = "client.slua.umg.level_unlock.level_unlock_icon_item",
    path = "/Game/UMG/UI_BP/LevelUnlock/LevelUnlock_Icon_Item.LevelUnlock_Icon_Item",
    uiStat = {
      name = "\231\173\137\231\186\167\232\167\163\233\148\129-icon"
    }
  },
  level_unlock_bubble = {
    keyName = "level_unlock_bubble",
    moduleName = "client.slua.umg.level_unlock.level_unlock_bubble",
    path = "/Game/UMG/UI_BP/LevelUnlock/LevelUnlock_Bubble_Item.LevelUnlock_Bubble_Item",
    uiStat = {
      name = "\231\173\137\231\186\167\232\167\163\233\148\129-\230\176\148\230\179\161\230\143\144\231\164\186"
    }
  },
  level_unlock_season = {
    keyName = "level_unlock_season",
    moduleName = "client.slua.umg.level_unlock.level_unlock_season",
    path = "/Game/UMG/UI_BP/LevelUnlock/LevelUnlock_Qualifying_UIBP.LevelUnlock_Qualifying_UIBP",
    uiStat = {
      name = "\231\173\137\231\186\167\232\167\163\233\148\129-\232\181\155\229\173\163\230\143\144\231\164\186"
    }
  },
  Battle_Show_MVP_New_UIBP = {
    keyName = "Battle_Show_MVP_New_UIBP",
    moduleName = "client.slua.umg.shareChild.Battle_Show_MVP_New_UIBP",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/ResultMVP/Battle_Show_MVP_New_UIBP.Battle_Show_MVP_New_UIBP",
    uiStat = {
      name = "3.\231\187\147\231\174\151\229\136\134\228\186\171-MVP"
    }
  },
  MedalDisplay_Share_UIBP = {
    keyName = "MedalDisplay_Share_UIBP",
    moduleName = "client.slua.umg.shareChild.MedalDisplay_Share_UIBP",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Share/MedalDisplay_Share_UIBP.MedalDisplay_Share_UIBP",
    uiStat = {
      name = "10.\231\187\147\231\174\151\229\136\134\228\186\171-\229\190\189\231\171\160\232\142\183\229\190\151"
    }
  },
  Share_Select_Pose_Medal_UIBP = {
    keyName = "Share_Select_Pose_Medal_UIBP",
    moduleName = "client.slua.umg.shareChild.Share_Select_Pose_Medal_UIBP",
    path = "/Game/UMG/UI_BP/Share/Share_Select_Pose_Medal_UIBP.Share_Select_Pose_Medal_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\231\187\147\231\174\151\229\136\134\228\186\171-\229\190\189\231\171\160/Pose\233\128\137\230\139\169\230\160\143"
    }
  },
  TeamPlatform_Tab = {
    keyName = "TeamPlatform_Tab",
    moduleName = "client.slua.umg.mentor.TeamPlatform_Tab",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_Tab.TeamPlatform_Tab",
    jumpModuleID = BP_ENUM_MODULE_TEAM_PLATFORM,
    asy = true,
    uiStat = {
      name = "\229\144\141\231\137\135\229\188\185\231\170\151"
    }
  },
  TeamUp_Member_Wingman_UIBP = {
    keyName = "TeamUp_Member_Wingman_UIBP",
    moduleName = "client.slua.umg.team.TeamUp_Member_Wingman_UIBP",
    path = "/Game/UMG/UI_BP/TeamUp/TeamUp_Member_Wingman_UIBP.TeamUp_Member_Wingman_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\229\133\165\233\152\159\229\131\154\230\156\186\229\177\149\231\164\186"
    }
  },
  Explore_Linkage_Main_UIBP = {
    keyName = "Explore_Linkage_Main_UIBP",
    moduleName = "client.slua.umg.explore.Explore_Linkage_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_APLAN_EXPLORE,
    path = "/Game/Arts_UI/AlwaysSplit/Explore_Linkage/Explore_Linkage_Main_UIBP.Explore_Linkage_Main_UIBP",
    sceneID = 6,
    asy = true,
    uiStat = {
      name = "270\230\142\162\231\180\162\230\180\187\229\138\168\228\184\187\231\149\140\233\157\162"
    }
  },
  Explore_Linkage_UIBP = {
    keyName = "Explore_Linkage_UIBP",
    moduleName = "client.slua.umg.explore.Explore_Linkage_UIBP",
    path = "/Game/Arts_UI/AlwaysSplit/Explore_Linkage/Explore_Linkage_UIBP.Explore_Linkage_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\142\162\231\180\162\231\149\140\233\157\162"
    }
  },
  Explore_Linkage_Buy_Popup_UIBP = {
    keyName = "Explore_Linkage_Buy_Popup_UIBP",
    moduleName = "client.slua.umg.explore.Explore_Linkage_Buy_Popup_UIBP",
    path = "/Game/Arts_UI/AlwaysSplit/Explore_Linkage/Explore_Linkage_Buy_Popup_UIBP.Explore_Linkage_Buy_Popup_UIBP",
    uiStat = {
      name = "\230\142\162\231\180\162\230\180\187\229\138\168\232\180\173\228\185\176\231\167\175\229\136\134\229\188\185\231\170\151"
    }
  },
  Explore_Linkage_Point_Popup_UIBP = {
    keyName = "Explore_Linkage_Point_Popup_UIBP",
    moduleName = "client.slua.umg.explore.Explore_Linkage_Point_Popup_UIBP",
    path = "/Game/Arts_UI/AlwaysSplit/Explore_Linkage/Explore_Linkage_Point_Popup_UIBP.Explore_Linkage_Point_Popup_UIBP",
    uiStat = {
      name = "\230\142\162\231\180\162\230\180\187\229\138\168\231\167\175\229\136\134\232\142\183\229\190\151\232\174\176\229\189\149\229\188\185\231\170\151"
    }
  },
  Explore_Linkage_DirectPurchase_Popup_UIBP = {
    keyName = "Explore_Linkage_DirectPurchase_Popup_UIBP",
    moduleName = "client.slua.umg.explore.Explore_Linkage_DirectPurchase_Popup_UIBP",
    path = "/Game/Arts_UI/AlwaysSplit/Explore_Linkage/Explore_Linkage_DirectPurchase_Popup_UIBP.Explore_Linkage_DirectPurchase_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\142\162\231\180\162\230\180\187\229\138\168\231\137\169\229\147\129\232\180\173\228\185\176\229\188\185\231\170\151"
    }
  },
  Explore_Linkage_Text_Popup_UIBP = {
    keyName = "Explore_Linkage_Text_Popup_UIBP",
    moduleName = "client.slua.umg.explore.Explore_Linkage_Text_Popup_UIBP",
    path = "/Game/Arts_UI/AlwaysSplit/Explore_Linkage/Explore_Linkage_Text_Popup_UIBP.Explore_Linkage_Text_Popup_UIBP",
    uiStat = {
      name = "\230\142\162\231\180\162\230\180\187\229\138\168\232\167\132\229\136\153\232\175\166\230\131\133\229\188\185\231\170\151"
    }
  },
  Explore_Linkage_Prob_Popup_UIBP = {
    keyName = "Explore_Linkage_Prob_Popup_UIBP",
    moduleName = "client.slua.umg.explore.Explore_Linkage_Prob_Popup_UIBP",
    path = "/Game/Arts_UI/AlwaysSplit/Explore_Linkage/Explore_Linkage_Prob_Popup_UIBP.Explore_Linkage_Prob_Popup_UIBP",
    uiStat = {
      name = "\230\142\162\231\180\162\230\180\187\229\138\168\232\161\165\231\187\153\230\166\130\231\142\135\229\188\185\231\170\151"
    }
  },
  Explore_Linkage_OpenBox_Popup_UIBP = {
    keyName = "Explore_Linkage_OpenBox_Popup_UIBP",
    moduleName = "client.slua.umg.explore.Explore_Linkage_OpenBox_Popup_UIBP",
    path = "/Game/Arts_UI/AlwaysSplit/Explore_Linkage/Explore_Linkage_OpenBox_Popup_UIBP.Explore_Linkage_OpenBox_Popup_UIBP",
    uiStat = {
      name = "\230\142\162\231\180\162\230\180\187\229\138\168\229\174\157\231\174\177\229\188\128\229\165\150\233\128\137\230\139\169\230\148\175\228\187\152\230\150\185\229\188\143\231\149\140\233\157\162"
    }
  },
  Explore_Linkage_Item = {
    keyName = "Explore_Linkage_Item",
    moduleName = "client.slua.umg.explore.Explore_Linkage_Item",
    path = "/Game/Arts_UI/AlwaysSplit/Explore_Linkage/Item/Explore_Linkage_Item01.Explore_Linkage_Item01",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\230\142\162\231\180\162\230\180\187\229\138\168\229\165\150\229\138\177item"
    }
  },
  Explore_Whole_Linkage_Item = {
    keyName = "Explore_Whole_Linkage_Item",
    moduleName = "client.slua.umg.explore.Explore_Whole_Linkage_Item",
    path = "/Game/Arts_UI/AlwaysSplit/Global_Server_Exploration/Item/Global_Server_Explore_Item_UIBP.Global_Server_Explore_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = false,
    uiStat = {
      name = "\229\133\168\230\156\141\230\142\162\231\180\162\230\180\187\229\138\168\229\165\150\229\138\177item"
    }
  },
  Explore_Whole_Linkage_Bonus_Item = {
    keyName = "Explore_Whole_Linkage_Bonus_Item",
    moduleName = "client.slua.umg.explore.Explore_Whole_Linkage_Bonus_Item",
    path = "/Game/Arts_UI/AlwaysSplit/Global_Server_Exploration/Item/Global_Server_Explore_Item02_UIBP.Global_Server_Explore_Item02_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = false,
    uiStat = {
      name = "\229\133\168\230\156\141\230\142\162\231\180\162\230\180\187\229\138\168\229\165\150\229\138\177item2"
    }
  },
  Explore_Linkage_Progress_Item = {
    keyName = "Explore_Linkage_Progress_Item",
    moduleName = "client.slua.umg.explore.Explore_Linkage_Progress_Item",
    path = "/Game/Arts_UI/AlwaysSplit/Explore_Linkage/Item/Explore_Linkage_Progress_Item.Explore_Linkage_Progress_Item",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\133\168\230\156\141\230\142\162\231\180\162\230\180\187\229\138\168\231\187\132\229\144\136\229\165\150\229\138\177\232\138\130\231\130\185"
    }
  },
  Explore_Linkage_Whole_Progress_Item = {
    keyName = "Explore_Linkage_Whole_Progress_Item",
    moduleName = "client.slua.umg.explore.Explore_Whole_Linkage_Progress_Item",
    path = "/Game/Arts_UI/AlwaysSplit/Global_Server_Exploration/Item/Global_Server_Explore_Progress_Item_UIBP.Global_Server_Explore_Progress_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    asy = false,
    uiStat = {
      name = "\229\133\168\230\156\141\230\142\162\231\180\162\230\180\187\229\138\168\231\187\132\229\144\136\229\165\150\229\138\177\232\138\130\231\130\185"
    }
  },
  Medal_Item_Tips01 = {
    keyName = "Medal_Item_Tips01",
    moduleName = "client.slua.umg.combat_medal.Medal_Item_Tips01",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Item/Medal_Item_Tips01.Medal_Item_Tips01",
    uiStat = {
      name = "\231\167\176\229\143\183-\229\190\189\231\171\160\231\167\176\229\143\183tips"
    }
  },
  SkillSelectionMain = {
    keyName = "SkillSelectionMain",
    moduleName = "client.slua.umg.skill_selection_system.Skill_Main_UIBP",
    path = "/Game/UMG/UI_BP/Skill/Skill_Main_UIBP.Skill_Main_UIBP",
    uiStat = {
      name = "\230\138\128\232\131\189\233\128\137\230\139\169"
    }
  },
  PreChurn_Popup_UIBP = {
    keyName = "PreChurn_Popup_UIBP",
    moduleName = "client.slua.umg.PreChurn.PreChurn_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PreChurn/PreChurn_Popup_UIBP.PreChurn_Popup_UIBP",
    uiStat = {
      name = "\233\162\132\230\181\129\229\164\177-\230\174\181\228\189\141\229\133\179\230\128\128"
    }
  },
  SaLiveVideoFullScreenPlayer = {
    keyName = "SaLiveVideoFullScreenPlayer",
    moduleName = "client.slua.umg.sa.SaLiveVideoFullScreenPlayer",
    path = "/Game/UMG/UI_BP/SmartAssistant/SaLiveVideoFullScreenPlayer.SaLiveVideoFullScreenPlayer",
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139\232\167\134\233\162\145\230\146\173\230\148\190"
    }
  },
  SmartAssistant_Main_UIBP = {
    keyName = "SmartAssistant_Main_UIBP",
    moduleName = "client.slua.umg.sa.SmartAssistant_Main_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistant/SmartAssistant_Main_UIBP.SmartAssistant_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_SMART_ASSISTANT_MAIN,
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139\228\184\187\231\149\140\233\157\162"
    }
  },
  SmartAssistant_RobotTips_UIBP = {
    keyName = "SmartAssistant_RobotTips_UIBP",
    moduleName = "client.slua.umg.sa.SmartAssistant_RobotTips_UIBP",
    path = "/Game/UMG/UI_BP/SmartAssistant/Robot/SmartAssistant_RobotTips_UIBP.SmartAssistant_RobotTips_UIBP",
    isSingleton = false,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\230\153\186\232\131\189\229\138\169\230\137\139\229\133\165\229\143\163\231\149\140\233\157\162"
    }
  },
  BestPartner_InviteMessage_UIBP = {
    keyName = "BestPartner_InviteMessage_UIBP",
    moduleName = "client.slua.umg.best_partner.BestPartner_InviteMessage_UIBP",
    path = "/Game/Arts_UI/AFD/3300/AirdropCarnival/BestPartner/BestPartner_InviteMessage_UIBP.BestPartner_InviteMessage_UIBP",
    uiStat = {
      name = "\232\162\171\233\130\128\232\171\139\229\136\151\232\161\168\229\188\185\231\170\151"
    }
  },
  GameletSDK_UIBP = {
    keyName = "GameletSDK_UIBP",
    moduleName = "client.slua.umg.GameletSDK.GameletSDK_UIBP",
    path = "/Game/UMG/UI_BP/Gamelet/GameletSDK_UIBP.GameletSDK_UIBP",
    uiStat = {
      name = "Gamelet-\229\133\168\229\177\143UI"
    }
  },
  GameletContainer_UIBP = {
    keyName = "GameletContainer_UIBP",
    moduleName = "client.slua.umg.GameletSDK.GameletContainer_UIBP",
    path = "/Game/UMG/UI_BP/Gamelet/GameletContainer_UIBP.GameletContainer_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "Gamelet-\230\180\187\229\138\168\228\184\173\229\191\131\230\140\130\232\189\189\229\174\185\229\153\168"
    }
  },
  GameletFaceSlapContainer_UIBP = {
    keyName = "GameletContainer_UIBP",
    moduleName = "client.slua.umg.GameletSDK.GameletFaceSlapContainer_UIBP",
    path = "/Game/UMG/UI_BP/Gamelet/GameletFaceSlapContainer_UIBP.GameletFaceSlapContainer_UIBP",
    asy = true,
    uiStat = {
      name = "Gamelet-\230\139\141\232\132\184\229\174\185\229\153\168"
    }
  },
  MixItem_Inventory_UIBP = {
    keyName = "MixItem_Inventory_UIBP",
    moduleName = "client.slua.umg.MixItem.MixItem_Inventory_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/Main/MixItem_Inventory_UIBP.MixItem_Inventory_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "\232\161\165\231\187\153-\230\183\183\229\144\136\231\137\169-\232\131\140\229\140\133\231\149\140\233\157\162"
    }
  },
  MixItem_NumberChooser_UIBP = {
    keyName = "MixItem_NumberChooser_UIBP",
    moduleName = "client.slua.umg.MixItem.MixItem_NumberChooser_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/Main/MixItem_NumberChooser_UIBP.MixItem_NumberChooser_UIBP",
    asy = true,
    isMainUI = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\232\161\165\231\187\153-\230\183\183\229\144\136\231\137\169-\230\149\176\233\135\143\233\128\137\230\139\169\229\153\168"
    }
  },
  MixItem_Rule_UIBP = {
    keyName = "MixItem_Rule_UIBP",
    moduleName = "client.slua.umg.MixItem.MixItem_Rule_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/Main/MixItem_Rule_UIBP.MixItem_Rule_UIBP",
    asy = true,
    isMainUI = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\232\161\165\231\187\153-\230\183\183\229\144\136\231\137\169-\232\167\132\229\136\153\232\175\180\230\152\142"
    }
  },
  MixItem_Probability_UIBP = {
    keyName = "MixItem_Probability_UIBP",
    moduleName = "client.slua.umg.MixItem.MixItem_Probability_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/Main/MixItem_Probability_UIBP.MixItem_Probability_UIBP",
    asy = true,
    isMainUI = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\232\161\165\231\187\153-\230\183\183\229\144\136\231\137\169-\229\174\157\231\174\177\230\166\130\231\142\135"
    }
  },
  MixItem_Cumulative_Confirm_UIBP = {
    keyName = "MixItem_Cumulative_Confirm_UIBP",
    moduleName = "client.slua.umg.MixItem.MixItem_Cumulative_Confirm_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/Main/MixItem_Cumulative_Confirm_UIBP.MixItem_Cumulative_Confirm_UIBP",
    asy = true,
    isMainUI = true,
    containerName = UIContainers.Top,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\232\161\165\231\187\153-\230\183\183\229\144\136\231\137\169-\232\191\155\229\186\166\229\158\171\229\173\144\229\188\185\231\170\151"
    }
  },
  MixItem_Old_EasterEgg_UIBP = {
    keyName = "MixItem_Old_EasterEgg_UIBP",
    moduleName = "client.slua.umg.MixItem.MixItem_Old_EasterEgg_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/Main/MixItem_Old_EasterEgg_UIBP.MixItem_Old_EasterEgg_UIBP",
    asy = true,
    isMainUI = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\232\161\165\231\187\153-\230\183\183\229\144\136\231\137\169-\229\189\169\232\155\139\229\188\185\231\170\151-\230\151\167"
    }
  },
  MixItem_EasterEgg_UIBP = {
    keyName = "MixItem_EasterEgg_UIBP",
    moduleName = "client.slua.umg.MixItem.MixItem_EasterEgg_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/Main/MixItem_EasterEgg_UIBP.MixItem_EasterEgg_UIBP",
    asy = true,
    isMainUI = true,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\232\161\165\231\187\153-\230\183\183\229\144\136\231\137\169-\229\189\169\232\155\139\229\188\185\231\170\151"
    }
  },
  MixItem_EasterEgg_Questionnaire_UIBP = {
    keyName = "MixItem_EasterEgg_Questionnaire_UIBP",
    moduleName = "client.slua.umg.MixItem.MixItem_EasterEgg_Questionnaire_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/Main/MixItem_EasterEgg_Questionnaire_UIBP.MixItem_EasterEgg_Questionnaire_UIBP",
    asy = true,
    uiStat = {
      name = "\232\161\165\231\187\153-\230\183\183\229\144\136\231\137\169-\229\189\169\232\155\139\229\188\185\231\170\151"
    }
  },
  MixItem_AwardPool_UIBP = {
    keyName = "MixItem_AwardPool_UIBP",
    moduleName = "client.slua.umg.MixItem.MixItem_AwardPool_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/Main/MixItem_AwardPool_UIBP.MixItem_AwardPool_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\161\165\231\187\153-\230\183\183\229\144\136\231\137\169-\229\165\150\230\177\160"
    }
  },
  MixItem_Preview_UIBP = {
    keyName = "MixItem_Preview_UIBP",
    moduleName = "client.slua.umg.MixItem.MixItem_Preview_UIBP",
    path = "/Game/Arts_UI/FromUMG/MixItem/Main/MixItem_Preview_UIBP.MixItem_Preview_UIBP",
    uiStat = {
      name = "\232\161\165\231\187\153-\230\183\183\229\144\136\231\137\169-\233\162\132\232\167\136"
    }
  },
  Coin_Panel_UIBP = {
    keyName = "Coin_Panel_UIBP",
    moduleName = "client.slua.umg.common.Coin.Coin_Panel_UIBP",
    path = "/Game/UMG/UI_BP/Common/Coin/Coin_Panel_UIBP.Coin_Panel_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\233\128\154\231\148\168\232\180\167\229\184\129\231\187\132\228\187\182"
    }
  },
  Coin_Item_UIBP = {
    keyName = "Coin_Item_UIBP",
    moduleName = "client.slua.umg.common.Coin.Coin_Item_UIBP",
    path = "/Game/UMG/UI_BP/Common/Coin/Coin_Item_UIBP.Coin_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.item_pool,
    uiStat = {
      name = "\233\128\154\231\148\168\232\180\167\229\184\129\231\187\132\228\187\182-Item"
    }
  },
  ReplayGMUIDecrypt = {
    keyName = "ReplayGMUIDecrypt",
    moduleName = "GameLua.Mod.BaseMod.Client.Replay.ReplayGMUIDecrypt",
    path = "/Game/BluePrints/UI/GMConsole/ReplayGMUIDecrypt.ReplayGMUIDecrypt",
    isMainUI = false,
    isSingleton = true,
    asy = false,
    uiStat = {
      name = "ReplayGMUI\232\167\163\229\175\134\233\173\148\230\156\175\229\173\151"
    },
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.Click_Animation
  },
  ReplayGMUIFileList = {
    keyName = "ReplayGMUIFileList",
    moduleName = "GameLua.Mod.BaseMod.Client.Replay.ReplayGMUIFileList",
    path = "/Game/BluePrints/UI/GMConsole/ReplayGMUIFileList.ReplayGMUIFileList",
    isMainUI = false,
    isSingleton = true,
    asy = false,
    uiStat = {
      name = "ReplayGMUI\230\150\135\228\187\182\229\136\151\232\161\168"
    },
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.Click_Animation
  },
  Comm_Invite_Notify_UIBP = {
    keyName = "Comm_Invite_Notify_UIBP",
    moduleName = "client.slua.umg.Home.EditPlan.Comm_Invite_Notify_UIBP",
    path = "/Game/UMG/UI_BP/Home/Common/Tips/Comm_Invite_Notify_UIBP.Comm_Invite_Notify_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\231\188\150\232\190\145\230\150\185\230\161\136-\233\130\128\232\175\183\229\188\185\231\170\151"
    }
  },
  Warm_Service_Evaluation_UIBP = {
    keyName = "Warm_Service_Evaluation_UIBP",
    moduleName = "client.slua.umg.BattleEvalute.Warm_Service_Evaluation_UIBP",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Item/Warm_Service_Evaluation_UIBP.Warm_Service_Evaluation_UIBP",
    uiStat = {
      name = "\230\184\169\230\154\150\229\177\128\232\175\132\229\136\134"
    }
  },
  ui_complaint_home = {
    keyName = "ui_complaint_home",
    moduleName = "client.slua.umg.Home.Report.ui_complaint_home",
    path = "/Game/UMG/UI_BP/PopupNotice/Inform_Item_UIBP2.Inform_Item_UIBP2",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\229\174\182\229\155\173\231\142\169\229\174\182"
    },
    isSingleton = false
  },
  Home_Tab_Horizontal_LevelTwo_Text_Item_UIBP = {
    keyName = "Home_Tab_Horizontal_LevelTwo_Text_Item_UIBP",
    moduleName = "client.slua.umg.Home.Common.Home_Tab_Horizontal_LevelTwo_Text_Item_UIBP",
    path = "/Game/UMG/UI_BP/Home/Common/Tab/Item/Home_Tab_Horizontal_LevelTwo_Text_Item_UIBP.Home_Tab_Horizontal_LevelTwo_Text_Item_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\230\168\170\229\144\145\228\186\140\231\186\167\233\161\181\231\173\190Item"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  Home_Gvuide_Popup_Item_UIBP = {
    keyName = "Home_Gvuide_Popup_Item_UIBP",
    moduleName = "client.slua.umg.Home.Common.Home_Gvuide_Popup_Item_UIBP",
    path = "/Game/UMG/UI_BP/Home/Detail/Item/Home_Gvuide_Popup_Item_UIBP.Home_Gvuide_Popup_Item_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\233\161\181\229\156\134\231\130\185Item"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  NewFunction_Notes_UIBP = {
    keyName = "NewFunction_Notes_UIBP",
    moduleName = "client.slua.umg.common.NewFunction_Notes_UIBP",
    path = "/Game/UMG/UI_BP/Common/NewFunction_Notes_UIBP.NewFunction_Notes_UIBP",
    asy = true,
    uiStat = {
      name = "\233\128\154\231\148\168-\231\179\187\231\187\159\230\140\135\229\188\149"
    }
  },
  Theme_MainTab_UIBP = {
    keyName = "Theme_MainTab_UIBP",
    moduleName = "client.slua.umg.ThemeSystem.Theme_MainTab_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Theme_MainTab_UIBP.Theme_MainTab_UIBP",
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\228\184\187\231\149\140\233\157\162"
    }
  },
  Theme_PageTurn_Instruction_UIBP = {
    keyName = "Theme_PageTurn_Instruction_UIBP",
    moduleName = "client.slua.umg.ThemeSystem.Theme_PageTurn_Instruction_UIBP",
    path = "/Game/UMG/UI_BP/Theme/Theme_PageTurn_Instruction_UIBP.Theme_PageTurn_Instruction_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\231\137\136\230\156\172\231\142\169\230\179\149"
    }
  },
  Theme_Exchange_UIBP = {
    keyName = "Theme_Exchange_UIBP",
    moduleName = "client.slua.umg.ThemeSystem.Theme_Exchange_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Theme_Exchange_UIBP.Theme_Exchange_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\229\133\145\230\141\162"
    }
  },
  Theme_RateProgress_Main_UIBP = {
    keyName = "Theme_RateProgress_Main_UIBP",
    moduleName = "client.slua.umg.ThemeSystem.Theme_RateProgress_Main_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Theme_RateProgress_Main_UIBP.Theme_RateProgress_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\231\166\187\231\186\191\229\174\157\231\174\177"
    }
  },
  Theme_SkipButton_Item_UIBP = {
    keyName = "Theme_SkipButton_Item_UIBP",
    moduleName = "client.slua.umg.ThemeSystem.Item.Theme_SkipButton_Item_UIBP",
    path = "/Game/UMG/UI_BP/Theme/Item/Theme_SkipButton_Item_UIBP.Theme_SkipButton_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\228\184\187\233\162\152\228\187\139\231\187\141\230\140\145\230\136\152\230\140\137\233\146\174"
    }
  },
  Theme_Preheat_UIBP = {
    keyName = "Theme_Preheat_UIBP",
    moduleName = "client.slua.umg.Theme.New.Theme_Preheat_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Theme_Preheat_UIBP.Theme_Preheat_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\231\137\136\230\156\172\229\156\176\229\155\190"
    }
  },
  Theme_Map_Tab_UIBP = {
    keyName = "Theme_Map_Tab_UIBP",
    moduleName = "client.slua.umg.Theme.New.Theme_Map_Tab_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Theme_Map_Tab_UIBP.Theme_Map_Tab_UIBP",
    isMainUI = true,
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\231\137\136\230\156\172\229\156\176\229\155\190-\229\143\179\228\190\167\233\161\181\231\173\190"
    }
  },
  Theme_Map_Introduction_UIBP = {
    keyName = "Theme_Map_Introduction_UIBP",
    moduleName = "client.slua.umg.Theme.New.Theme_Map_Introduction_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Theme_Map_Introduction_UIBP.Theme_Map_Introduction_UIBP",
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\231\137\136\230\156\172\229\156\176\229\155\190-\232\175\166\230\131\133\229\188\185\231\170\151"
    }
  },
  Theme_GamePlayGuide_UIBP = {
    keyName = "Theme_GamePlayGuide_UIBP",
    moduleName = "client.slua.umg.Theme.New.Theme_GamePlayGuide_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Theme_GamePlayGuide_UIBP.Theme_GamePlayGuide_UIBP",
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\231\137\136\230\156\172\229\156\176\229\155\190-\232\175\166\231\187\134\231\142\169\230\179\149"
    }
  },
  Theme_Overview_UIBP = {
    keyName = "Theme_Overview_UIBP",
    moduleName = "client.slua.umg.Theme.New.Theme_Overview_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Theme_Overview_UIBP.Theme_Overview_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\231\137\136\230\156\172\228\187\139\231\187\141\231\149\140\233\157\162"
    }
  },
  Theme_Achievementn_Popop_UIBP = {
    keyName = "Theme_Achievementn_Popop_UIBP",
    moduleName = "client.slua.umg.Theme.New.Popup.Theme_Achievementn_Popop_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Popup/Theme_Achievementn_Popop_UIBP.Theme_Achievementn_Popop_UIBP",
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\231\137\136\230\156\172\228\187\139\231\187\141-\230\136\144\229\176\177\229\188\185\231\170\151"
    }
  },
  Theme_MatchMod_UIBP = {
    keyName = "Theme_MatchMod_UIBP",
    moduleName = "client.slua.umg.Theme.New.Theme_MatchMod_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Theme_MatchMod_UIBP.Theme_MatchMod_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\231\165\158\229\165\135\230\164\141\231\137\169-\231\167\141\230\164\141\232\175\166\230\131\133"
    }
  },
  Theme_Map_Item_UIBP = {
    keyName = "Theme_Map_Item_UIBP",
    moduleName = "client.slua.umg.Theme.New.Item.Theme_Map_Item_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Theme_Map_Item_UIBP.Theme_Map_Item_UIBP",
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\231\165\158\229\165\135\230\164\141\231\137\169-\229\175\185\229\177\128\231\167\141\230\164\141\232\175\166\230\131\133"
    }
  },
  Theme_TreasureHuntingTask02_UIBP = {
    keyName = "Theme_TreasureHuntingTask02_UIBP",
    moduleName = "client.slua.umg.Theme.New.Theme_TreasureHuntingTask02_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Theme_TreasureHuntingTask02_UIBP.Theme_TreasureHuntingTask02_UIBP",
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\229\175\187\229\174\157\231\142\169\230\179\149-\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  BirthDay_Wish_Popup_UIBP = {
    keyName = "BirthDay_Wish_Popup_UIBP",
    moduleName = "client.slua.umg.birthday.BirthDay_Wish_Popup_UIBP",
    path = "/Game/UMG/UI_BP/BirthDay/BirthDay_Wish_Popup_UIBP.BirthDay_Wish_Popup_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\231\148\159\230\151\165\233\155\134\229\144\136\233\161\181-\230\139\141\232\132\184"
    }
  },
  BirthDay_Information_UIBP = {
    keyName = "BirthDay_Information_UIBP",
    moduleName = "client.slua.umg.birthday.BirthDay_Information_UIBP",
    path = "/Game/UMG/UI_BP/BirthDay/BirthDay_Information_UIBP.BirthDay_Information_UIBP",
    uiStat = {
      name = "\231\148\159\230\151\165\233\155\134\229\144\136\233\161\181-\229\134\133\229\174\185"
    }
  },
  BirthDay_Information_Item_UIBP = {
    keyName = "BirthDay_Information_Item_UIBP",
    moduleName = "client.slua.umg.birthday.BirthDay_Information_Item_UIBP",
    path = "/Game/UMG/UI_BP/BirthDay/BirthDay_Information_Item_UIBP.BirthDay_Information_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\231\148\159\230\151\165\233\155\134\229\144\136\233\161\181-\231\148\159\230\151\165\228\191\161\230\129\175item"
    }
  },
  Peak_Game_Rule_UIBP = {
    keyName = "Peak_Game_Rule_UIBP",
    moduleName = "client.slua.umg.PeakGame.Peak_Game_Rule_UIBP",
    path = "/Game/UMG/UI_BP/PeakGame/Peak_Game_Rule_UIBP.Peak_Game_Rule_UIBP",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\232\167\132\229\136\153\232\175\180\230\152\142\231\149\140\233\157\162"
    }
  },
  Peak_Game_Rule_Tips_UIBP = {
    keyName = "Peak_Game_Rule_Tips_UIBP",
    moduleName = "client.slua.umg.PeakGame.Peak_Game_Rule_Tips_UIBP",
    path = "/Game/UMG/UI_BP/PeakGame/Peak_Game_Rule_Tips_UIBP.Peak_Game_Rule_Tips_UIBP",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\231\142\169\230\179\149\228\187\139\231\187\141\231\149\140\233\157\162"
    }
  },
  Peak_Maps_Rule_UIBP = {
    keyName = "Peak_Maps_Rule_UIBP",
    moduleName = "client.slua.umg.PeakGame.Peak_Maps_Rule_UIBP",
    path = "/Game/UMG/UI_BP/PeakGame/Peak_Maps_Rule_UIBP.Peak_Maps_Rule_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\229\156\176\229\155\190\232\167\132\229\136\153\231\149\140\233\157\162"
    }
  },
  WOWTeamPlatform_MyTeam_Item = {
    keyName = "WOWTeamPlatform_MyTeam_Item",
    moduleName = "client.slua.umg.teamup.WOWTeamPlatform_MyTeam_Item",
    path = "/Game/UMG/UI_BP/TeamPlatform/TeamPlatform_WOW/Item/TeamPlatform_Myteam_Item_UIBP.TeamPlatform_Myteam_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "WOW\231\187\132\233\152\159\229\164\167\229\142\133\233\152\159\228\188\141\231\174\161\231\144\134\231\149\140\233\157\162\233\161\182\233\131\168item"
    }
  },
  ScrapGold_Discount_UIBP = {
    keyName = "ScrapGold_Discount_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.ScrapGold_Discount_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/ScrapGold/UIBP/ScrapGold_Discount_UIBP.ScrapGold_Discount_UIBP",
    jumpModuleID = BP_ENUM_MODULE_SCRAPGOLD_EXCHANGE_DISCOUNT,
    uiStat = {
      name = "\231\165\158\231\167\152\229\183\165\229\157\138\230\138\152\230\137\163\230\138\189\229\143\150\231\149\140\233\157\162"
    }
  },
  EnterBroadcastItem = {
    keyName = "EnterBroadcastItem",
    moduleName = "client.slua.umg.common.EnterBroadcastItem",
    path = "/Game/UMG/UI_BP/Common/EnterBroadcastItem.EnterBroadcastItem",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\133\165\229\156\186\230\146\173\230\138\165"
    }
  },
  ScreenEffect_360_SpeedLine_UIBP = {
    keyName = "ScreenEffect_360_SpeedLine_UIBP",
    moduleName = "client.slua.umg.ScreenEffect.ScreenEffect_360_SpeedLine.ScreenEffect_360_SpeedLine_UIBP",
    path = "/Game/UMG/UI_BP/ScreenEffect/ScreenEffect_360_SpeedLine/ScreenEffect_360_SpeedLine_UIBP.ScreenEffect_360_SpeedLine_UIBP",
    uiStat = {
      name = "\233\128\159\229\186\166\231\186\191\231\137\185\230\149\136\229\173\144\231\149\140\233\157\162"
    }
  },
  SpecialOffer_Temu_UIBP = {
    keyName = "SpecialOffer_Temu_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.Temu.SpecialOffer_Temu_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Temu/UIBP/SpecialOffer_Temu_UIBP.SpecialOffer_Temu_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\141\176\229\186\166\230\139\188\229\164\154\229\164\154\231\149\140\233\157\162"
    }
  },
  SpecialOffer_Temu_UIBP_2 = {
    keyName = "SpecialOffer_Temu_UIBP_2",
    moduleName = "client.slua.umg.SpecialOffer.Temu.SpecialOffer_Temu_UIBP_2",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Temu/UIBP/SpecialOffer_Temu_UIBP_2.SpecialOffer_Temu_UIBP_2",
    isMainUI = false,
    uiStat = {
      name = "\230\139\188\229\164\154\229\164\154\231\164\188\229\140\133\233\128\137\230\139\169\231\149\140\233\157\162"
    }
  },
  SpecialOffer_Temu_Team_UIBP = {
    keyName = "SpecialOffer_Temu_Team_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.Temu.SpecialOffer_Temu_Team_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Temu/UIBP/SpecialOffer_Temu_Team_UIBP.SpecialOffer_Temu_Team_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\141\176\229\186\166\230\139\188\229\164\154\229\164\154\231\149\140\233\157\162 \233\152\159\228\188\141"
    }
  },
  SpecialOffer_TeamInvitePopup_UIBP = {
    keyName = "SpecialOffer_TeamInvitePopup_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.Popup.SpecialOffer_TeamInvitePopup_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Temu/UIBP/SpecialOffer_TeamInvitePopup_UIBP.SpecialOffer_TeamInvitePopup_UIBP",
    uiStat = {
      name = "\229\141\176\229\186\166\230\139\188\229\164\154\229\164\154\233\130\128\232\175\183\231\149\140\233\157\162"
    }
  },
  SpecialOffer_Purchase_UIBP = {
    keyName = "SpecialOffer_Purchase_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.Temu.SpecialOffer_Purchase_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Temu/UIBP/SpecialOffer_Purchase_UIBP.SpecialOffer_Purchase_UIBP",
    uiStat = {
      name = "\229\141\176\229\186\166\230\139\188\229\164\154\229\164\154\233\152\159\228\188\141\230\138\152\230\137\163\231\149\140\233\157\162"
    }
  },
  SpecialOffer_Temu_Infoitem_Menu_UIBP = {
    keyName = "SpecialOffer_Temu_Infoitem_Menu_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.Temu.Item.SpecialOffer_Temu_Infoitem_Menu_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Temu/UIBP/SpecialOffer_Temu_Infoitem_Menu_UIBP.SpecialOffer_Temu_Infoitem_Menu_UIBP",
    uiStat = {
      name = "\229\141\176\229\186\166\230\139\188\229\164\154\229\164\154\229\164\180\229\131\143\232\143\156\229\141\149\231\149\140\233\157\162"
    }
  },
  CrazyWeekend_PopupItem_UIBP = {
    keyName = "CrazyWeekend_PopupItem_UIBP",
    moduleName = "client.slua.umg.CrazyWeekend.CrazyWeekend_PopupItem_UIBP",
    path = "/Game/UMG/UI_BP/CrazyWeekend/CrazyWeekend_PopupItem_UIBP.CrazyWeekend_PopupItem_UIBP",
    isSingleton = false,
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.Click_Animation,
    uiStat = {
      name = "\232\191\155\229\133\165\230\136\152\230\150\151\230\151\182\239\188\140\231\150\175\231\139\130\229\145\168\230\156\171\228\186\178\229\175\134\229\186\166\231\191\187\229\128\141tips\231\149\140\233\157\162"
    }
  },
  CrazyWeekend_LuckyDraw_UIBP = {
    keyName = "CrazyWeekend_LuckyDraw_UIBP",
    moduleName = "client.slua.umg.CrazyWeekend.CrazyWeekend_LuckyDraw_UIBP",
    path = "/Game/UMG/UI_BP/CrazyWeekend/CrazyWeekend_LuckyDraw_UIBP.CrazyWeekend_LuckyDraw_UIBP",
    sSingleton = true,
    uiStat = {
      name = "\231\150\175\231\139\130\229\145\168\230\156\171-\230\138\189\229\165\150"
    }
  },
  CrazyWeekend_Info_Popup_UIBP = {
    keyName = "CrazyWeekend_Info_Popup_UIBP",
    moduleName = "client.slua.umg.CrazyWeekend.Popup.CrazyWeekend_Info_Popup_UIBP",
    path = "/Game/UMG/UI_BP/CrazyWeekend/Popup/CrazyWeekend_Info_Popup_UIBP.CrazyWeekend_Info_Popup_UIBP",
    uiStat = {
      name = "\231\150\175\231\139\130\229\145\168\230\156\171-\230\138\189\229\165\150-\232\175\166\230\131\133\229\188\185\231\170\151"
    }
  },
  CrazyWeekend_Get_UIBP = {
    keyName = "CrazyWeekend_Get_UIBP",
    moduleName = "client.slua.umg.CrazyWeekend.CrazyWeekend_Get_UIBP",
    path = "/Game/UMG/UI_BP/CrazyWeekend/CrazyWeekend_Get_UIBP.CrazyWeekend_Get_UIBP",
    uiStat = {
      name = "\231\150\175\231\139\130\229\145\168\230\156\171-\230\138\189\229\165\150-\230\129\173\229\150\156\228\184\173\229\165\150"
    }
  },
  Team_Open_Share_Bag_UIBP = {
    keyName = "Team_Open_Share_Bag_UIBP",
    moduleName = "client.slua.umg.teamup.Team_Open_Share_Bag_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Team_Open_Share_Bag_UIBP.Team_Open_Share_Bag_UIBP",
    uiStat = {
      name = "\231\187\132\233\152\159-\233\152\159\229\143\139\229\188\128\233\128\154\232\174\162\233\152\133\229\133\177\228\186\171\232\131\140\229\140\133\233\128\154\231\159\165"
    }
  },
  PeakGame_Guide_UIBP = {
    keyName = "PeakGame_Guide_UIBP",
    moduleName = "client.slua.umg.PeakGame.PeakGame_Guide_UIBP",
    path = "/Game/UMG/UI_BP/PeakGame/PeakGame_Guide_UIBP.PeakGame_Guide_UIBP",
    asy = true,
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155\229\188\149\229\175\188\231\149\140\233\157\162"
    }
  },
  Team_Appoint_Result_Tip_UIBP = {
    keyName = "Team_Appoint_Result_Tip_UIBP",
    moduleName = "client.slua.umg.teamup.Team_Appoint_Result_Tip_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Team_Appoint_Result_Tip_UIBP.Team_Appoint_Result_Tip_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\233\162\132\231\186\166\231\187\132\233\152\159-\233\162\132\231\186\166\231\187\147\230\158\156\230\181\174\231\170\151"
    }
  },
  Team_Invite_Tip_UIBP = {
    keyName = "Team_Invite_Tip_UIBP",
    moduleName = "client.slua.umg.teamup.Team_Invite_Tip_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Team_Invite_Tip_UIBP.Team_Invite_Tip_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    asy = true,
    uiStat = {
      name = "\229\133\172\229\133\177-\233\130\128\232\175\183\231\187\132\233\152\159\230\181\174\231\170\151"
    }
  },
  Assembly_Team_Invite_Tip_UIBP = {
    keyName = "Assembly_Team_Invite_Tip_UIBP",
    moduleName = "client.slua.umg.teamup.Assembly_Team_Invite_Tip_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Team_Invite_Tip_UIBP.Team_Invite_Tip_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\143\172\229\155\158-\233\130\128\232\175\183\231\187\132\233\152\159\230\181\174\231\170\151"
    }
  },
  PartnerReadiness_TeamInvite_Tips_UIBP = {
    keyName = "PartnerReadiness_TeamInvite_Tips_UIBP",
    moduleName = "client.slua.umg.PartnerReadiness.Item.PartnerReadiness_TeamInvite_Tips_UIBP",
    path = "/Game/UMG/UI_BP/PartnerReadiness/Item/PartnerReadiness_TeamInvite_Tips_UIBP.PartnerReadiness_TeamInvite_Tips_UIBP",
    uiStat = {
      name = "\233\130\128\232\175\183\231\187\132\233\152\159-\230\150\176\230\137\139\233\130\128\232\175\183\229\183\166\228\184\138\232\167\146\229\165\150\229\138\177\230\160\135\232\175\134"
    }
  },
  Recommend_Team_Invite_Tip_UIBP = {
    keyName = "Recommend_Team_Invite_Tip_UIBP",
    moduleName = "client.slua.umg.teamup.Recommend_Team_Invite_Tip_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Recommend_Team_Invite_Tip_UIBP.Recommend_Team_Invite_Tip_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\231\187\132\233\152\159\230\142\168\232\141\144-\230\148\182\229\136\176\233\130\128\232\175\183\231\187\132\233\152\159\230\181\174\231\170\151"
    }
  },
  team_recommend = {
    keyName = "team_recommend",
    moduleName = "client.slua.umg.team.team_recommend",
    path = "/Game/UMG/UI_BP/Universal_Popup/Team_Recommend_UIBP.Team_Recommend_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\231\187\132\233\152\159\230\142\168\232\141\144-\230\142\168\232\141\144\229\188\185\231\170\151"
    }
  },
  Return_Team_Recommend_UIBP = {
    keyName = "Return_Team_Recommend_UIBP",
    moduleName = "client.slua.umg.Universal_Popup.Return_Team_Recommend_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Return_Team_Recommend_UIBP.Return_Team_Recommend_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\231\187\132\233\152\159\230\142\168\232\141\144-\229\155\158\230\181\129"
    }
  },
  Return_Team_Recommend_InGame_UIBP = {
    keyName = "Return_Team_Recommend_InGame_UIBP",
    moduleName = "client.slua.umg.Universal_Popup.Return_Team_Recommend_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Return_Team_Recommend_UIBP.Return_Team_Recommend_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\231\187\132\233\152\159\230\142\168\232\141\144-\229\155\158\230\181\129"
    }
  },
  CrazyWeekend_Popup_UIBP = {
    keyName = "CrazyWeekend_Popup_UIBP",
    moduleName = "client.slua.umg.CrazyWeekend.CrazyWeekend_Popup_UIBP",
    path = "/Game/UMG/UI_BP/CrazyWeekend/Popup/CrazyWeekend_Popup_UIBP.CrazyWeekend_Popup_UIBP",
    containerName = UIContainers.Top,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\231\150\175\231\139\130\229\145\168\230\156\171\229\188\149\229\175\188\229\188\185\231\170\151"
    }
  },
  Butcher_Settlement_Popup_UIBP = {
    keyName = "Butcher_Settlement_Popup_UIBP",
    moduleName = "client.slua.umg.Universal_Popup.Butcher_Settlement_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Butcher_Settlement_Popup_UIBP.Butcher_Settlement_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\175\185\229\177\128\231\187\147\231\174\151-\231\139\169\231\140\142\229\175\185\229\177\128\231\187\147\231\174\151\230\143\144\233\134\146"
    }
  },
  Common_Qualifying_Rounds_Item_UIBP = {
    keyName = "Common_Qualifying_Rounds_Item_UIBP",
    moduleName = "client.slua.umg.common.QualifyingRounds.Common_Qualifying_Rounds_Item_UIBP",
    path = "/Game/UMG/UI_BP/Common/QualifyingRounds/Common_Qualifying_Rounds_Item_UIBP.Common_Qualifying_Rounds_Item_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false,
    uiStat = {
      name = "\232\181\132\230\160\188\232\181\155-\232\181\132\230\160\188\232\181\155item"
    }
  },
  Common_Qualifying_Rounds_Tips = {
    keyName = "Common_Qualifying_Rounds_Tips",
    moduleName = "client.slua.umg.common.QualifyingRounds.Common_Qualifying_Rounds_Tips",
    path = "/Game/UMG/UI_BP/Common/QualifyingRounds/Common_Qualifying_Rounds_Tips.Common_Qualifying_Rounds_Tips",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155\228\191\157\230\138\164tip\231\149\140\233\157\162"
    }
  },
  Common_Qualifying_Rounds_Tips_MC = {
    keyName = "Common_Qualifying_Rounds_Tips_MC",
    moduleName = "client.slua.umg.common.QualifyingRounds.Common_Qualifying_Rounds_Tips",
    path = "/Game/Mod/MainCity/BluePrints/UI/Main/Item/Common_Qualifying_Rounds_Tips_MC.Common_Qualifying_Rounds_Tips_MC"
  },
  Room_OfflineStatus_UIBP = {
    keyName = "Room_OfflineStatus_UIBP",
    moduleName = "client.slua.umg.room.Room_OfflineStatus_UIBP",
    path = "/Game/UMG/UI_BP/Room/Room_OfflineStatus_UIBP.Room_OfflineStatus_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\230\136\191\233\151\180\230\142\137\231\186\191\233\135\141\232\191\158\230\143\144\231\164\186\233\157\162\230\157\191"
    }
  },
  Room_WeatherChoose_UIBP = {
    keyName = "Room_WeatherChoose_UIBP",
    moduleName = "client.slua.umg.room.Room_WeatherChoose_UIBP",
    path = "/Game/UMG/UI_BP/Room/Room_WeatherChoose_UIBP.Room_WeatherChoose_UIBP",
    uiStat = {
      name = "\230\136\191\233\151\180\229\164\169\230\176\148\233\128\137\230\139\169\233\157\162\230\157\191"
    }
  },
  Return_Team_Guidance_UIBP = {
    keyName = "Return_Team_Guidance_UIBP",
    moduleName = "client.slua.umg.Universal_Popup.Return_Team_Guidance_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Return_Team_Guidance_UIBP.Return_Team_Guidance_UIBP",
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\155\158\230\181\129\229\188\149\229\175\188\229\143\179\228\184\139\229\188\185\231\170\151"
    }
  },
  SingleTraining_Invite_Notify_UIBP = {
    keyName = "SingleTraining_Invite_Notify_UIBP",
    moduleName = "client.slua.umg.SingleTraining.SingleTraining_Invite_Notify_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/SingleTraining_Invite_Notify_UIBP.SingleTraining_Invite_Notify_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\174\173\231\187\131\229\156\186-\233\130\128\232\175\183\233\128\154\231\159\165"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  WorldToScreenAnchorUIBP = {
    keyName = "WorldToScreenAnchorUIBP",
    moduleName = "client.slua.umg.common.WorldToScreenAnchorUIBP",
    path = "/Game/UMG/UI_BP/Common/WorldToScreenAnchorUIBP.WorldToScreenAnchorUIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\228\184\150\231\149\140\229\157\144\230\160\135\230\138\149\229\189\177\229\136\176\229\177\143\229\185\149(\230\140\130\229\133\182\228\187\150UI\231\148\168)"
    }
  },
  crew_safety_detection_nationesport = {
    keyName = "crew_safety_detection_nationesport",
    moduleName = "client.slua.umg.crew.crew_safety_detection_nationesport",
    path = "/Game/UMG/UI_BP/PeakGame/PeakGame_Detection_UIBP.PeakGame_Detection_UIBP",
    uiStat = {
      name = "crew_safety_detection_nationesport-\229\174\137\229\133\168\230\163\128\230\181\139"
    }
  },
  Common_InformationCustom_Large_Item = {
    keyName = "Common_InformationCustom_Large_Item",
    moduleName = "client.slua.umg.PersonSpace.Popup.Item.Common_InformationCustom_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_InformationCustom_Large_Item.Common_InformationCustom_Large_Item",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - \233\128\154\231\148\168 - \229\164\167"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool
  },
  Common_InformationCustom_Middle_Item = {
    keyName = "Common_InformationCustom_Middle_Item",
    moduleName = "client.slua.umg.PersonSpace.Popup.Item.Common_InformationCustom_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_InformationCustom_Middle_Item.Common_InformationCustom_Middle_Item",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - \233\128\154\231\148\168 - \228\184\173"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool
  },
  Common_InformationCustom_Tiny_Item = {
    keyName = "Common_InformationCustom_Tiny_Item",
    moduleName = "client.slua.umg.PersonSpace.Popup.Item.Common_InformationCustom_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_InformationCustom_Tiny_Item.Common_InformationCustom_Tiny_Item",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - \233\128\154\231\148\168 - \229\176\143"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool
  }
}
return common_ui_configs