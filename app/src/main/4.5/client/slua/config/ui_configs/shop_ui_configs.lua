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
local shop_ui_configs = {
  Store_EventPhoto_Item_UIBP = {
    keyName = "Store_EventPhoto_Item_UIBP",
    moduleName = "client.slua.umg.version_album.Store_EventPhoto_Item_UIBP",
    path = "/Game/UMG/UI_BP/Store/Item/Store_EventPhoto_Item_UIBP.Store_EventPhoto_Item_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\231\155\184\229\134\140\232\131\140\230\153\175-\233\162\132\232\167\136\229\173\144\231\149\140\233\157\162"
    }
  },
  SpecialOffer_Main_UIBP = {
    keyName = "SpecialOffer_Main_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.SpecialOffer.UMG.SpecialOffer_Main_UIBP",
    path = "/Game/Mod/Lobby/Base/SpecialOffer/SpecialOffer_Main_UIBP.SpecialOffer_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_SPECIAL_OFFER,
    asy = true,
    uiStat = {
      name = "\231\137\185\230\131\160\228\184\187\231\149\140\233\157\162"
    }
  },
  ScrapGold_Exchange_UIBP = {
    keyName = "ScrapGold_Exchange_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.ScrapGold.Exchange.ScrapGold_Exchange_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/ScrapGold/UIBP/ScrapGold_Exchange_UIBP.ScrapGold_Exchange_UIBP",
    jumpModuleID = BP_ENUM_MODULE_SCRAPGOLD_EXCHANGE,
    asy = true,
    uiStat = {
      name = "\231\165\158\232\175\157\229\183\165\229\157\138\231\137\169\229\147\129\229\133\145\230\141\162\231\149\140\233\157\162"
    }
  },
  ScrapGold_CountDownTips = {
    keyName = "ScrapGold_CountDownTips",
    moduleName = "client.slua.umg.SpecialOffer.ScrapGold.Widget.ScrapGold_CountDownTips",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/ScrapGold/UIBP/ScrapGold_CountDownTips.ScrapGold_CountDownTips",
    uiStat = {
      name = "\231\165\158\232\175\157\229\183\165\229\157\138 \232\174\161\230\151\182tips"
    }
  },
  SpecialOffer_ValueRebate_UIBP = {
    keyName = "SpecialOffer_ValueRebate_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.SpecialOffer.UMG.SpecialOffer_ValueRebate_UIBP",
    path = "/Game/Mod/Lobby/Base/SpecialOffer/ValueRebate/SpecialOffer_ValueRebate_UIBP.SpecialOffer_ValueRebate_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\230\182\136\232\180\185\232\191\148\229\136\169"
    }
  },
  SpecialOffer_ValueRebate_Item_UIBP = {
    keyName = "SpecialOffer_ValueRebate_Item_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.SpecialOffer.UMG.Item.SpecialOffer_ValueRebate_Item_UIBP",
    path = "/Game/Mod/Lobby/Base/SpecialOffer/Item/SpecialOffer_ValueRebate_Item_UIBP.SpecialOffer_ValueRebate_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\230\182\136\232\180\185\232\191\148\229\136\169Item"
    }
  },
  SpecialOffer_Coin_Item_UIBP = {
    keyName = "SpecialOffer_Coin_Item_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.SpecialOffer.UMG.Item.SpecialOffer_Coin_Item_UIBP",
    path = "/Game/Mod/Lobby/Base/SpecialOffer/Item/SpecialOffer_Coin_Item_UIBP.SpecialOffer_Coin_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\231\137\185\230\131\160\228\184\187\232\180\167\229\184\129item"
    }
  },
  SpecialOffer_Material_UIBP = {
    keyName = "SpecialOffer_Material_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.MaterialGift.SpecialOffer_Material_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Material/UIBP/SpecialOffer_Material_UIBP.SpecialOffer_Material_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\230\157\144\230\150\153\231\164\188\229\140\133\231\149\140\233\157\162"
    }
  },
  SpecialOffer_Material_Item_UIBP = {
    keyName = "SpecialOffer_Material_Item_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.MaterialGift.SpecialOffer_Material_Item_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Material/UIBP/Item/SpecialOffer_Material_Item_UIBP.SpecialOffer_Material_Item_UIBP",
    isSingleton = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\157\144\230\150\153\231\164\188\229\140\133"
    }
  },
  SpecialOffer_PackagePreview_Popup_UIBP = {
    keyName = "SpecialOffer_PackagePreview_Popup_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.Common.SpecialOffer_PackagePreview_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Popup/SpecialOffer_PackagePreview_Popup_UIBP.SpecialOffer_PackagePreview_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\231\137\185\230\131\160\231\164\188\229\140\133\233\162\132\232\167\136\229\188\185\231\170\151"
    }
  },
  SpecialOffer_Quality_Probability_Tips_UIBP = {
    keyName = "SpecialOffer_Quality_Probability_Tips_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.Common.SpecialOffer_Quality_Probability_Tips_UIBP",
    path = "/Game/Mod/Lobby/Base/SpecialOffer/SpecialOffer_Quality_Probability_Tips_UIBP.SpecialOffer_Quality_Probability_Tips_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\231\137\185\230\131\160\231\164\188\229\140\133\230\166\130\231\142\135\229\188\185\231\170\151"
    }
  },
  SpecialOffer_Material_Item_02_UIBP = {
    keyName = "SpecialOffer_Material_Item_02_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.MaterialGift.SpecialOffer_Material_Item_02_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Material/UIBP/Item/SpecialOffer_Material_Item_02_UIBP.SpecialOffer_Material_Item_02_UIBP",
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\157\144\230\150\153\231\164\188\229\140\133\229\173\144item"
    }
  },
  SpecialOffer_Conditions_Popup_UIBP = {
    keyName = "SpecialOffer_Conditions_Popup_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.ConditionGift.SpecialOffer_Conditions_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Conditions/UIBP/Popup/SpecialOffer_Conditions_Popup_UIBP.SpecialOffer_Conditions_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\157\161\228\187\182\231\164\188\229\140\133\231\164\188\229\140\133\232\175\166\230\131\133"
    }
  },
  Subscribe_Coupons_Detail = {
    keyName = "Subscribe_Coupons_Detail",
    moduleName = "client.slua.umg.subscribe.Subscribe_Coupons_Detail",
    path = "/Game/Mod/Lobby/Base/SpecialOffer/PopUp/Subscribe_Coupons_Detail.Subscribe_Coupons_Detail",
    uiStat = {
      name = "\232\174\162\233\152\133-\230\187\161\229\135\143\229\136\184\230\159\165\231\156\139\231\149\140\233\157\162"
    }
  },
  Subscribe_Rule_UIBP = {
    keyName = "Subscribe_Rule_UIBP",
    moduleName = "client.slua.umg.subscribe.Subscribe_Rule_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/SubScribe/PopUp/Subscribe_Rule_UIBP.Subscribe_Rule_UIBP",
    uiStat = {
      name = "210\230\150\176\231\137\136\232\174\162\233\152\133\232\167\132\229\136\153\229\188\185\231\170\151"
    }
  },
  Subscribe_SubPage_UIBP = {
    keyName = "Subscribe_SubPage_UIBP",
    moduleName = "client.slua.umg.subscribe.Subscribe_SubPage_UIBP",
    path = "/Game/Mod/Lobby/Base/SpecialOffer/Subscribe_SubPage_UIBP.Subscribe_SubPage_UIBP",
    isMainUI = false,
    uiStat = {
      name = "210\230\150\176\231\137\136\232\174\162\233\152\133-\229\133\133\229\128\188\231\149\140\233\157\162\229\183\166\228\190\167\232\174\162\233\152\133\229\176\143\231\149\140\233\157\162"
    }
  },
  Subscribe_Coupons_Detail_New = {
    keyName = "Subscribe_Coupons_Detail_New",
    moduleName = "client.slua.umg.subscribe.Subscribe_Coupons_Detail_New",
    path = "/Game/Mod/Lobby/Base/SpecialOffer/PopUp/Subscribe_Coupons_Detail_New.Subscribe_Coupons_Detail_New",
    uiStat = {
      name = "\232\174\162\233\152\133-\230\187\161\229\135\143\229\136\184\230\159\165\231\156\139\231\149\140\233\157\162"
    }
  },
  Subscribe_Coupons_Detail_item_old = {
    keyName = "Subscribe_Coupons_Detail_item_old",
    moduleName = "client.slua.umg.subscribe.Subscribe_Coupons_Detail_item_old",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/SubScribe/Item/Subscribe_Coupons_Detail_item_old.Subscribe_Coupons_Detail_item_old",
    uiStat = {
      name = "\232\174\162\233\152\133\230\151\165\233\159\169\226\128\148\226\128\148\230\138\181\230\137\163\229\136\184item"
    },
    isMainUI = false,
    isSingleton = false
  },
  ui_mvp_motion = {
    keyName = "ui_mvp_motion",
    moduleName = "client.slua.umg.mvp_motion.ui_mvp_motion",
    path = "/Game/UMG/UI_BP/Store/Show_MVP_UIBP.Show_MVP_UIBP",
    uiStat = {
      name = "MVP\229\138\168\228\189\156\229\188\185\231\170\151"
    }
  },
  ui_ask_for_lookfor = {
    keyName = "ui_ask_for_lookfor",
    moduleName = "client.slua.umg.store.AskFor.ui_ask_for_lookfor",
    path = "/Game/UMG/UI_BP/Store/ask_for/AskForLookFor.AskForLookFor",
    uiStat = {
      name = "\231\180\162\232\166\129-\230\159\165\231\156\139\231\149\140\233\157\162"
    }
  },
  ui_ask_for_history = {
    keyName = "ui_ask_for_history",
    moduleName = "client.slua.umg.store.AskFor.ui_ask_for_history",
    path = "/Game/UMG/UI_BP/Store/ask_for/MyAskForHistory.MyAskForHistory",
    uiStat = {
      name = "\231\180\162\232\166\129-\230\136\145\231\154\132\231\180\162\232\166\129\231\149\140\233\157\162"
    }
  },
  Coupon_PopupUI_General = {
    keyName = "Coupon_PopupUI_General",
    moduleName = "client.slua.umg.coupon.Coupon_PopupUI_General",
    path = "/Game/UMG/UI_BP/Coupon/Coupon_PopupUI_UIBP.Coupon_PopupUI_UIBP",
    asy = true,
    uiStat = {
      name = "\228\188\152\230\131\160\229\136\184-\228\186\140\230\172\161\231\161\174\232\174\164\228\189\191\231\148\168\229\188\185\231\170\151-340\232\181\183\230\150\176\231\137\136"
    }
  },
  ui_coupon_combobox = {
    keyName = "ui_coupon_combobox",
    moduleName = "client.slua.umg.coupon.ui_coupon_combobox",
    path = "/Game/UMG/UI_BP/Coupon/Coupon_Combobox.Coupon_Combobox",
    isSingleton = false,
    uiStat = {
      name = "\228\188\152\230\131\160\229\136\184-\228\184\139\230\139\137\233\128\137\230\139\169\230\161\134_\228\184\138\230\150\185\230\152\190\231\164\186"
    }
  },
  ui_coupon_combobox_down = {
    keyName = "ui_coupon_combobox_down",
    moduleName = "client.slua.umg.coupon.ui_coupon_combobox",
    path = "/Game/UMG/UI_BP/Coupon/Coupon_Combobox_Down.Coupon_Combobox_Down",
    isSingleton = false,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\228\188\152\230\131\160\229\136\184-\228\184\139\230\139\137\233\128\137\230\139\169\230\161\134_\228\184\139\230\150\185\230\152\190\231\164\186"
    }
  },
  Activty_PeriodicCrate_UIBP = {
    keyName = "Activty_PeriodicCrate_UIBP",
    moduleName = "client.slua.umg.DailyActivity.PeriodicCrate.Activty_PeriodicCrate_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Activty_PeriodicCrate_UIBP.Activty_PeriodicCrate_UIBP",
    uiStat = {
      name = "\229\145\168\230\156\159\229\174\157\231\174\177\230\180\187\229\138\168"
    },
    isMainUI = false
  },
  Paint_UIBP = {
    keyName = "Paint_UIBP",
    moduleName = "client.slua.umg.Paint.Paint_UIBP",
    path = "/Game/UMG/UI_BP/NewStore/store/Paint_UIBP.Paint_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\233\128\154\231\148\168\229\150\183\230\182\130\233\162\132\232\167\136\231\149\140\233\157\162"
    }
  },
  gdpr_creditcard_verify = {
    keyName = "gdpr_creditcard_verify",
    moduleName = "client.slua.umg.GDPR.minor_verify.gdpr_creditcard_verify",
    path = "/Game/UMG/UI_BP/AgeGate/AgeGate_Popup6_UIBP.AgeGate_Popup6_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "gdpr-\228\191\161\231\148\168\229\141\161\233\170\140\232\175\129"
    }
  },
  gdpr_wait_creditcard_verify = {
    keyName = "gdpr_wait_creditcard_verify",
    moduleName = "client.slua.umg.GDPR.minor_verify.gdpr_wait_creditcard_verify",
    path = "/Game/UMG/UI_BP/AgeGate/AgeGate_Popup1_UIBP.AgeGate_Popup1_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "gdpr-\231\173\137\229\190\133\233\130\174\231\174\177\233\170\140\232\175\129\231\187\147\230\158\156"
    }
  },
  Appstore_AppRaise = {
    keyName = "Appstore_AppRaise",
    moduleName = "client.slua.umg.Appraise.Appraise",
    path = "/Game/UMG/UI_BP/PopupNotice/Evaluate_UIBP.Evaluate_UIBP",
    uiStat = {
      name = "\229\188\149\229\175\188app\229\149\134\229\186\151\232\175\132\232\174\186"
    }
  },
  Crate_ProgressRate_Popup = {
    keyName = "Crate_ProgressRate_Popup",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.supply.Crate_ProgressRate_Popup",
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_ProgressRate_Popup.Crate_ProgressRate_Popup",
    uiStat = {
      name = "\232\161\165\231\187\153\229\174\157\231\174\177\229\164\154\230\156\186\229\136\182 - N\230\172\161\229\191\133\229\190\151\229\188\185\231\170\151"
    }
  },
  Crate_Consume_ProgressRate_Popup = {
    keyName = "Crate_Consume_ProgressRate_Popup",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.supply.Crate_Consume_ProgressRate_Popup",
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_ProgressRate_Popup.Crate_ProgressRate_Popup",
    uiStat = {
      name = "\232\161\165\231\187\153\229\174\157\231\174\177\229\164\154\230\156\186\229\136\182 - \230\151\165\233\159\169\232\183\145\232\189\166\230\182\136\232\180\185\230\180\187\229\138\168\229\188\185\231\170\151"
    }
  },
  Subscribe_HomePage_New_UIBP = {
    keyName = "Subscribe_HomePage_New_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.Subscribe.Subscribe_HomePage_New_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/SubScribe/Subscribe_HomePage_New_UIBP.Subscribe_HomePage_New_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\232\174\162\233\152\133-260\230\150\176\231\137\136\232\174\162\233\152\133\232\180\173\228\185\176\231\149\140\233\157\162"
    }
  },
  Subscribe_HomePage_AwardItem = {
    keyName = "Subscribe_HomePage_AwardItem",
    moduleName = "client.slua.umg.SpecialOffer.Subscribe.Subscribe_HomePage_AwardItem",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/SubScribe/Item/Subscribe_HomePage_AwardItem.Subscribe_HomePage_AwardItem",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\174\162\233\152\133-\231\137\185\230\157\131item"
    },
    loadFromPool = EUIConfigPoolType.other_pool
  },
  Subscribed_Policy_Popup_JK_UIBP = {
    keyName = "Subscribed_Policy_Popup_JK_UIBP",
    moduleName = "client.slua.umg.common.Japan.Subscribed_Policy_Popup_JK_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/SubScribe/PopUp/Subscribed_Policy_Popup_JK_UIBP.Subscribed_Policy_Popup_JK_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\151\165\230\156\172\230\148\191\231\173\150-\232\181\132\233\135\145\230\179\149\228\184\142\229\149\134\228\184\154\230\179\149"
    }
  },
  Subscribe_Slap_UIBP = {
    keyName = "Subscribe_Slap_UIBP",
    moduleName = "client.slua.umg.subscribe.Subscribe_Slap_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/SubScribe/PopUp/Subscribe_Slap_UIBP.Subscribe_Slap_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\232\174\162\233\152\133-\230\139\141\232\132\184\229\155\190"
    }
  },
  KeyPointDesign_UIBP = {
    keyName = "KeyPointDesign_UIBP",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.store.KeyPointDesign_UIBP",
    path = "/Game/UMG/UI_BP/NewStore/store/Store_Preview_UIBP.Store_Preview_UIBP",
    uiStat = {
      name = "\232\174\190\232\174\161\232\166\129\231\130\185\231\149\140\233\157\162"
    }
  },
  NewStoreSystem = {
    keyName = "NewStoreSystem",
    moduleName = "client.slua.umg.NewStoreV280.Main.NewStoreSystem",
    jumpModuleID = BP_ENUM_MODULE_MALL_CHILD,
    path = "/Game/UMG/UI_BP/NewStore/store/Store_Main_V280_UIBP.Store_Main_V280_UIBP",
    uiStat = {
      name = "\229\149\134\229\159\142-\229\149\134\229\159\142\228\184\187\231\149\140\233\157\162-V280"
    },
    useBatchOptimization = true
  },
  GiveStoreSystem = {
    keyName = "GiveStoreSystem",
    moduleName = "client.slua.umg.NewStoreV280.Main.GiveStoreSystem",
    jumpModuleID = BP_ENUM_MODULE_MALL_GIVE,
    path = "/Game/UMG/UI_BP/NewStore/store/Store_Main_V280_UIBP.Store_Main_V280_UIBP",
    uiStat = {
      name = "\229\149\134\229\159\142-\232\181\160\233\128\129\229\149\134\229\159\142-V280"
    },
    asy = true,
    useBatchOptimization = true
  },
  NewSupplySystem = {
    keyName = "NewSupplySystem",
    moduleName = "client.slua.umg.NewStoreV280.Main.NewSupplySystem",
    jumpModuleID = BP_ENUM_MODULE_SUPPLY,
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_Main_02_UIBP.Crate_Main_02_UIBP",
    uiStat = {
      name = "\232\161\165\231\187\153-\228\184\187\231\149\140\233\157\162-V280"
    },
    useBatchOptimization = true,
    showVisibility = Collapsed
  },
  NewSupplySystemJK = {
    keyName = "NewSupplySystemJK",
    moduleName = "client.slua.umg.NewStoreV280.Main.NewSupplySystemJK",
    jumpModuleID = BP_ENUM_MODULE_SUPPLY,
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_Main_02_UIBP.Crate_Main_02_UIBP",
    uiStat = {
      name = "\232\161\165\231\187\153-\230\151\165\233\159\169\229\149\134\229\159\142-V280"
    },
    asy = true,
    useBatchOptimization = true,
    showVisibility = Collapsed
  },
  NewSupplyWorkshop = {
    keyName = "NewSupplyWorkshop",
    moduleName = "client.slua.umg.NewStoreV280.Main.NewSupplyWorkshop",
    jumpModuleID = BP_ENUM_MODULE_SUPPLY_WORKSHOP,
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_Main_02_UIBP.Crate_Main_02_UIBP",
    uiStat = {
      name = "\232\161\165\231\187\153-\229\183\165\229\157\138\232\161\165\231\187\153-V280"
    },
    asy = true,
    useBatchOptimization = true,
    showVisibility = Collapsed
  },
  NewSupplyWorkshopJK = {
    keyName = "NewSupplyWorkshopJK",
    moduleName = "client.slua.umg.NewStoreV280.Main.NewSupplyWorkshopJK",
    jumpModuleID = BP_ENUM_MODULE_SUPPLY_WORKSHOP,
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_Main_02_UIBP.Crate_Main_02_UIBP",
    uiStat = {
      name = "\230\151\165\233\159\169\232\161\165\231\187\153-\229\183\165\229\157\138\232\161\165\231\187\153-V280"
    },
    asy = true,
    useBatchOptimization = true,
    showVisibility = Collapsed
  },
  StoreGeneralPage = {
    keyName = "StoreGeneralPage",
    moduleName = "client.slua.umg.NewStoreV280.Pages.StoreGeneralPage",
    path = "/Game/UMG/UI_BP/NewStore/store/Store_GeneralPage_UIBP.Store_GeneralPage_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142-\233\128\154\231\148\168\233\161\181\231\173\190-V280"
    }
  },
  StoreRecommendPage = {
    keyName = "StoreRecommendPage",
    moduleName = "client.slua.umg.NewStoreV280.Pages.StoreRecommendPage",
    path = "/Game/UMG/UI_BP/NewStore/store/Store_RecommendPage_UIBP.Store_RecommendPage_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142-\230\150\176\230\142\168\232\141\144\233\161\181\231\173\190-V280"
    }
  },
  StoreDirectPurchasePage = {
    keyName = "StoreDirectPurchasePage",
    moduleName = "client.slua.umg.NewStoreV280.Pages.StoreDirectPurchasePage",
    path = "/Game/UMG/UI_BP/NewStore/store/Store_Direct_Purchase_UIBP.Store_Direct_Purchase_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142-\231\155\180\232\180\173\233\161\181\231\173\190-V280"
    }
  },
  StoreCollectPage = {
    keyName = "StoreCollectPage",
    moduleName = "client.slua.umg.NewStoreV280.Pages.StoreCollectPage",
    path = "/Game/UMG/UI_BP/NewStore/store/Store_CollectionPage_UIBP.Store_CollectionPage_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142-\230\148\182\232\151\143\233\161\181\231\173\190-V280"
    }
  },
  StoreLimitedSubscribePage = {
    keyName = "StoreLimitedSubscribePage",
    moduleName = "client.slua.umg.NewStoreV280.Pages.StoreLimitedSubscribePage",
    path = "/Game/UMG/UI_BP/NewStore/store/Store_CollectionPage_UIBP.Store_CollectionPage_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142-\233\153\144\232\180\173\232\174\162\233\152\133\233\161\181\231\173\190-V280"
    }
  },
  StoreEquipmentPage = {
    keyName = "StoreEquipmentPage",
    moduleName = "client.slua.umg.NewStoreV280.Pages.StoreEquipmentPage",
    path = "/Game/UMG/UI_BP/NewStore/store/Store_EquipmentPage_UIBP.Store_EquipmentPage_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142-\232\163\133\229\164\135\233\161\181\231\173\190-V280"
    }
  },
  StorePetPage = {
    keyName = "StorePetPage",
    moduleName = "client.slua.umg.NewStoreV280.Pages.StorePetPage",
    path = "/Game/UMG/UI_BP/NewStore/store/Store_GeneralPage_UIBP.Store_GeneralPage_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142-\229\174\160\231\137\169\233\161\181\231\173\190-V280"
    }
  },
  StoreTabPanel = {
    keyName = "StoreTabPanel",
    moduleName = "client.slua.umg.NewStoreV280.TabPanel.Store.StoreTabPanel",
    path = "/Game/UMG/UI_BP/NewStore/store/Store_TabPanel_V280_UIBP.Store_TabPanel_V280_UIBP",
    asy = true,
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\229\149\134\229\159\142-\229\149\134\229\159\142\228\184\187\231\149\140\233\157\162-\229\143\179\228\190\167\233\161\181\231\173\190\229\136\151\232\161\168-V280"
    },
    useBatchOptimization = true,
    isMainUI = false
  },
  GiveStoreTabPanel = {
    keyName = "GiveStoreTabPanel",
    moduleName = "client.slua.umg.NewStoreV280.TabPanel.Store.GiveStoreTabPanel",
    path = "/Game/UMG/UI_BP/NewStore/store/Store_TabPanel_V280_UIBP.Store_TabPanel_V280_UIBP",
    asy = true,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\229\149\134\229\159\142-\232\181\160\233\128\129\229\149\134\229\159\142\233\157\162-\229\143\179\228\190\167\233\161\181\231\173\190\229\136\151\232\161\168-V280"
    },
    useBatchOptimization = true
  },
  SupplyTabPanel = {
    keyName = "SupplyTabPanel",
    moduleName = "client.slua.umg.NewStoreV280.TabPanel.Supply.SupplyTabPanel",
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_Right_2_UIBP.Crate_Right_2_UIBP",
    asy = true,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\232\161\165\231\187\153-\232\161\165\231\187\153\229\143\179\232\190\185-V280"
    },
    useBatchOptimization = true,
    showVisibility = Collapsed
  },
  SupplyJKTabPanel = {
    keyName = "SupplyJKTabPanel",
    moduleName = "client.slua.umg.NewStoreV280.TabPanel.Supply.SupplyJKTabPanel",
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_Right_2_UIBP.Crate_Right_2_UIBP",
    asy = true,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\230\151\165\233\159\169\232\161\165\231\187\153-\232\161\165\231\187\153\229\143\179\232\190\185-V280"
    },
    useBatchOptimization = true
  },
  SupplyGeneralPage = {
    keyName = "SupplyGeneralPage",
    moduleName = "client.slua.umg.NewStoreV280.Pages.SupplyGeneralPage",
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_GeneralPage_UIBP_2.Crate_GeneralPage_UIBP_2",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\232\161\165\231\187\153-\233\128\154\231\148\168\233\161\181\231\173\190-V280"
    }
  },
  new_crate_onekey_popup = {
    keyName = "new_crate_onekey_popup",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.crate.new_crate_onekey_popup",
    path = "/Game/UMG/UI_BP/Store/Popup/Store_Onekey_Popup_01_UIBP.Store_Onekey_Popup_01_UIBP",
    uiStat = {
      name = "\232\161\165\231\187\153-\229\174\157\231\174\177\229\134\133\228\184\128\233\148\174\230\138\189\229\165\150\229\188\185\231\170\151"
    }
  },
  crate_credit_ui = {
    keyName = "crate_credit_ui",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.crate.crate_credit_ui",
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_JK_Box_Integral_Popup.Crate_JK_Box_Integral_Popup",
    uiStat = {
      name = "\232\161\165\231\187\153-\231\167\175\229\136\134\229\133\145\230\141\162"
    }
  },
  crate_multi_currency_coupon = {
    keyName = "crate_multi_currency_coupon",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.crate.crate_multi_currency_coupon",
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_Multi_Currency_Coupon_UIBP.Crate_Multi_Currency_Coupon_UIBP",
    uiStat = {
      name = "\232\161\165\231\187\153-\229\164\154\232\180\167\229\184\129\228\188\152\230\131\160\229\136\184\233\128\137\230\139\169\230\161\134"
    }
  },
  store_jump_chest = {
    keyName = "store_jump_chest",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.store.store_jump_chest",
    path = "/Game/UMG/UI_BP/NewStore/store/Store_JumpChest_BP.Store_JumpChest_BP",
    AndroidBackType = EAndroidBackType.Skip,
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142/\232\161\165\231\187\153-\232\183\179\232\189\172\231\164\188\229\140\133\230\140\130\228\187\182"
    }
  },
  select_optional_chest = {
    keyName = "select_optional_chest",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.crate.select_optional_chest",
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_WelfareOption_Popup_UIBP.Crate_WelfareOption_Popup_UIBP",
    asy = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\232\135\170\229\136\182\229\174\157\231\174\177"
    }
  },
  ui_crate_voucher = {
    keyName = "ui_crate_voucher",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.crate.ui_crate_voucher",
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_Voucher_UIBP.Crate_Voucher_UIBP",
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142UC\230\138\152\230\137\163\231\149\140\233\157\162"
    }
  },
  ui_crate_voucher_jk = {
    keyName = "ui_crate_voucher_jk",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.crate.ui_crate_voucher_jk",
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_Voucher_UIBP.Crate_Voucher_UIBP",
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142UC\230\138\152\230\137\163\231\149\140\233\157\162-\230\151\165\233\159\169"
    }
  },
  supply_gradually_improve_panel = {
    keyName = "supply_gradually_improve_panel",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.supply.supply_gradually_improve_panel",
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_GraduallyImprove_Box_UIBP.Crate_GraduallyImprove_Box_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\232\161\165\231\187\153-\230\151\165\233\159\169\233\128\144\230\173\165\230\138\189\229\165\150\230\180\187\229\138\168"
    }
  },
  supply_wish_detail = {
    keyName = "supply_wish_detail",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.supply.supply_wish_detail",
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_Wish_Popup.Crate_Wish_Popup",
    uiStat = {
      name = "\232\161\165\231\187\153-\232\174\184\230\132\191\229\188\185\231\170\151"
    }
  },
  supply_wish_simple_detail = {
    keyName = "supply_wish_simple_detail",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.supply.supply_wish_simple_detail",
    path = "/Game/UMG/UI_BP/NewStore/crate/Crate_Wish_Simple_Popup.Crate_Wish_Simple_Popup",
    uiStat = {
      name = "\232\161\165\231\187\153-\232\174\184\230\132\191\231\174\128\229\141\149\229\188\185\231\170\151"
    }
  },
  supply_optional_container = {
    keyName = "supply_optional_container",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.supply.Mechanism.Optional.supply_optional_container",
    path = "/Game/Mod/Lobby/Base/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false,
    uiStat = {
      name = "\232\161\165\231\187\153\232\167\146\232\137\178\229\174\157\231\174\177\229\174\185\229\153\168"
    }
  },
  supply_optional_decompose = {
    keyName = "supply_optional_decompose",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.supply.Mechanism.Optional.supply_optional_decompose",
    path = "/Game/UMG/UI_BP/NewStore/Character/Character_Lottery_Decompose_popup_UIBP.Character_Lottery_Decompose_popup_UIBP",
    uiStat = {
      name = "\232\161\165\231\187\153\232\167\146\232\137\178\229\174\157\231\174\177-\229\136\134\232\167\163"
    }
  },
  supply_optional_exchange = {
    keyName = "supply_optional_exchange",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.supply.Mechanism.Optional.supply_optional_exchange",
    jumpModuleID = BP_ENUM_MODULE_CHARACTER_EXCHANGE,
    path = "/Game/UMG/UI_BP/NewStore/Character/Character_Exchange_Page.Character_Exchange_Page",
    uiStat = {
      name = "\232\161\165\231\187\153\232\167\146\232\137\178\229\174\157\231\174\177-\229\133\145\230\141\162"
    }
  }
}
return shop_ui_configs