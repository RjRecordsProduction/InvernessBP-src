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
local mail_ui_configs = {
  Mail_UIBP = {
    keyName = "Mail_UIBP",
    moduleName = "client.slua.umg.mail.Mail_UIBP",
    path = "/Game/UMG/UI_BP/Mail/Mail_NewMain_UIBP.Mail_NewMain_UIBP",
    asy = true,
    jumpModuleID = BP_ENUM_MODULE_MAIL,
    uiStat = {
      name = "\233\130\174\228\187\182-\228\184\187\231\149\140\233\157\162"
    }
  },
  Mail_Msg_Sub_UIBP = {
    keyName = "Mail_Msg_Sub_UIBP",
    moduleName = "client.slua.umg.mail.Mail_Msg_Sub_UIBP",
    path = "/Game/UMG/UI_BP/Mail/Sub_UIBP/Mail_List_Right_UIBP.Mail_List_Right_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\233\130\174\228\187\182-\229\173\144\231\149\140\233\157\162"
    }
  },
  mail_item_detail = {
    keyName = "mail_item_detail",
    moduleName = "client.slua.umg.mail.mail_item_detail",
    path = "/Game/UMG/UI_BP/Mail/Sub_UIBP/Mail_Message_Lfte_UIBP.Mail_Message_Lfte_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\233\130\174\231\174\177\226\128\148\233\130\174\228\187\182\232\175\166\230\131\133\231\170\151"
    }
  },
  Mail_Picture_Item = {
    keyName = "Mail_Picture_Item",
    moduleName = "client.slua.umg.mail.mail_item.Mail_Picture_Item",
    path = "/Game/UMG/UI_BP/Mail/Item/Mail_Picture_Item.Mail_Picture_Item",
    isSingleton = false,
    isMainUI = false
  },
  Gift_Item_Detail_UIBP = {
    keyName = "Gift_Item_Detail_UIBP",
    moduleName = "client.slua.umg.mail.Gift_Item_Detail_UIBP",
    path = "/Game/UMG/UI_BP/Mail/Sub_UIBP/Gift_Item_Detail_UIBP.Gift_Item_Detail_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\233\130\174\231\174\177\226\128\148\231\164\188\231\137\169\228\184\173\229\191\131\232\175\166\230\131\133\231\170\151"
    }
  },
  secure_mail = {
    keyName = "secure_mail",
    moduleName = "client.slua.umg.mail.secure_mail",
    path = "/Game/UMG/UI_BP/Mail/Sub_UIBP/Mail_List_Right_UIBP.Mail_List_Right_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\233\130\174\228\187\182-\229\174\137\229\133\168\233\130\174\228\187\182"
    }
  },
  ui_shop_gift_msgcenter = {
    keyName = "ui_shop_gift_msgcenter",
    moduleName = "client.slua.umg.mail.ui_shop_gift_msgcenter",
    path = "/Game/UMG/UI_BP/Mail/Sub_UIBP/Mail_List_Right_UIBP.Mail_List_Right_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\149\134\229\159\142-\231\164\188\229\140\133\228\184\173\229\191\131"
    }
  },
  store_uc_direct_purchase_gift_popup = {
    keyName = "store_uc_direct_purchase_gift_popup",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.popup.store_uc_direct_purchase_gift_popup",
    path = "/Game/UMG/UI_BP/NewStore/store/Store_Popup_UIBP.Store_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142-UC\231\164\188\229\140\133\231\155\180\232\180\173\229\134\133\229\174\185\229\188\185\231\170\151"
    }
  },
  GivingGifts_Popup_UIBP = {
    keyName = "GivingGifts_Popup_UIBP",
    moduleName = "client.slua.umg.GiftGivePopup.GivingGifts_Popup_UIBP",
    path = "/Game/UMG/UI_BP/GiftGivePopup/GivingGifts_Popup_UIBP.GivingGifts_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\233\128\154\231\148\168\231\177\187\232\181\160\233\128\129\229\188\185\231\170\151"
    }
  },
  GiftMessage_Popup_UIBP = {
    keyName = "GiftMessage_Popup_UIBP",
    moduleName = "client.slua.umg.GiftGivePopup.GiftMessage_Popup_UIBP",
    path = "/Game/UMG/UI_BP/GiftGivePopup/GiftMessage_Popup_UIBP.GiftMessage_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\233\128\154\231\148\168\231\177\187\231\180\162\232\166\129\229\188\185\231\170\151"
    }
  },
  SpaceGift_ExchangeRecord_UIBP = {
    keyName = "SpaceGift_ExchangeRecord_UIBP",
    moduleName = "client.slua.umg.PersonSpace.SpaceGift_Exchange.Item.SpaceGift_ExchangeRecord_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/SpaceGift_Exchange/Item/SpaceGift_ExchangeRecord_UIBP.SpaceGift_ExchangeRecord_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148\231\164\188\231\137\169\228\186\164\230\141\162-\229\142\134\229\143\178\232\174\176\229\189\149\231\149\140\233\157\162"
    }
  },
  SpaceGift_Exchange_Popup_UIBP = {
    keyName = "SpaceGift_Exchange_Popup_UIBP",
    moduleName = "client.slua.umg.PersonSpace.SpaceGift_Exchange.SpaceGift_Exchange_Popup_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/SpaceGift_Exchange/SpaceGift_Exchange_Popup_UIBP.SpaceGift_Exchange_Popup_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148\231\164\188\231\137\169\228\186\164\230\141\162-\229\143\145\232\181\183\228\186\164\230\141\162\231\164\188\231\137\169\228\191\161\230\129\175"
    }
  },
  roleinfo_send_gift_ani = {
    keyName = "roleinfo_send_gift_ani",
    moduleName = "client.slua.umg.person_space.roleinfo_send_gift_ani",
    isSingleton = false,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175-\232\181\160\233\128\129\231\164\188\231\137\169-Gif\229\138\168\231\148\187"
    }
  },
  roleinfo_recent_gift_ani = {
    keyName = "roleinfo_recent_gift_ani",
    moduleName = "client.slua.umg.person_space.roleinfo_recent_gift_ani",
    path = "/Game/UMG/UI_BP/PersonSpace/PersonSpace_Animation/Gift_ani_UIBP.Gift_ani_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isSingleton = false,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175-\230\156\128\232\191\145\231\164\188\231\137\169\229\138\168\231\148\187"
    }
  },
  roleinfo_send_gift_ani_ex = {
    keyName = "roleinfo_send_gift_ani_ex",
    moduleName = "client.slua.umg.person_space.roleinfo_send_gift_ani_ex",
    path = "/Game/UMG/UI_BP/PersonSpace/PersonSpace_Animation/Ani_GiftTips_UIBP.Ani_GiftTips_UIBP",
    ODPackID = PufferConst.EODPackID.SocialLobby,
    isSingleton = false,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175-\233\128\129\231\164\188\229\138\168\231\148\187"
    }
  },
  SpecialOffer_Conditions_Container = {
    keyName = "SpecialOffer_Conditions_Container",
    moduleName = "client.slua.umg.SpecialOffer.ConditionGift.SpecialOffer_Conditions_Container",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Conditions/UIBP/SpecialOffer_AnniversaryCelebration_UIBP.SpecialOffer_AnniversaryCelebration_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\230\157\161\228\187\182\231\164\188\229\140\133\229\174\185\229\153\168"
    }
  },
  SpecialOffer_Conditions_UIBP = {
    keyName = "SpecialOffer_Conditions_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.ConditionGift.SpecialOffer_Conditions_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Conditions/UIBP/SpecialOffer_Conditions_UIBP.SpecialOffer_Conditions_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\157\161\228\187\182\231\164\188\229\140\133\231\149\140\233\157\162"
    }
  },
  SpecialOffer_Conditions_AnniversaryCelebration_UIBP = {
    keyName = "SpecialOffer_Conditions_AnniversaryCelebration_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.ConditionGift.SpecialOffer_Conditions_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Conditions/UIBP/SpecialOffer_Conditions_AnniversaryCelebration_UIBP.SpecialOffer_Conditions_AnniversaryCelebration_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\145\168\229\185\180\230\157\161\228\187\182\231\164\188\229\140\133\231\149\140\233\157\162"
    }
  },
  SpecialOffer_Conditions_Item_UIBP = {
    keyName = "SpecialOffer_Conditions_Item_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.ConditionGift.SpecialOffer_Conditions_Item_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Conditions/UIBP/Item/SpecialOffer_Conditions_Item_UIBP.SpecialOffer_Conditions_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\230\157\161\228\187\182\231\164\188\229\140\133\231\149\140\233\157\162item"
    }
  },
  SpecialOffer_Conditions_Item_02_UIBP = {
    keyName = "SpecialOffer_Conditions_Item_02_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.ConditionGift.SpecialOffer_Conditions_Item_02_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Conditions/UIBP/Item/SpecialOffer_Conditions_Item_02_UIBP.SpecialOffer_Conditions_Item_02_UIBP",
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\157\161\228\187\182\231\164\188\229\140\133item"
    }
  },
  SpecialOffer_Conditions_Item_03_UIBP = {
    keyName = "SpecialOffer_Conditions_Item_03_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.ConditionGift.SpecialOffer_Conditions_Item_02_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Conditions/UIBP/Item/SpecialOffer_Conditions_Item_03_UIBP.SpecialOffer_Conditions_Item_03_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\145\168\229\185\180\230\157\161\228\187\182\231\164\188\229\140\133item"
    }
  },
  SpecialOffer_Conditions_Item_04_UIBP = {
    keyName = "SpecialOffer_Conditions_Item_04_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.ConditionGift.SpecialOffer_Conditions_Item_04_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Conditions/UIBP/Item/SpecialOffer_Conditions_Item_04_UIBP.SpecialOffer_Conditions_Item_04_UIBP",
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\230\157\161\228\187\182\231\164\188\229\140\133 \232\183\145\233\169\172\231\129\175item"
    }
  },
  Setting_Bind_Email_Popup_UIBP = {
    keyName = "Setting_Bind_Email_Popup_UIBP",
    moduleName = "client.slua.umg.setting.Account.Popup.Setting_Bind_Email_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Account/Popup/Setting_Bind_Email_Popup_UIBP.Setting_Bind_Email_Popup_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\232\180\166\229\143\183\230\149\143\230\132\159\230\147\141\228\189\156-\233\130\174\231\174\177\232\167\132\229\136\153\232\175\180\230\152\142"
    }
  },
  New_Shop_gift_All_UIBP = {
    keyName = "New_Shop_gift_All_UIBP",
    moduleName = "client.slua.umg.NewStoreV280.NewStoreMove.handsel.New_Shop_gift_All_UIBP",
    path = "/Game/UMG/UI_BP/Shop/SHOP_GIFT/New_Shop_gift_All_UIBP.New_Shop_gift_All_UIBP",
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142-\230\150\176\231\137\136\232\181\160\233\128\129\232\180\186\229\141\161"
    }
  },
  ShopGift_Share = {
    keyName = "ShopGift_Share",
    moduleName = "client.slua.umg.shareChild.share_shopGift",
    path = "/Game/UMG/UI_BP/Shop/SHOP_GIFT/Shop_GiftShare_UIBP.Shop_GiftShare_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\136\134\228\186\171-\229\149\134\229\186\151\232\181\160\231\164\188"
    }
  },
  pubgm_music_gift_friend_list = {
    keyName = "pubgm_music_gift_friend_list",
    moduleName = "client.slua.umg.pubgm_music.pubgm_music_gift_friend_list",
    path = "/Game/UMG/UI_BP/Music_Player/Music_Player_Friend_UIBP.Music_Player_Friend_UIBP",
    asy = true,
    uiStat = {
      name = "\233\159\179\228\185\144\231\155\146-\229\165\189\229\143\139\229\136\151\232\161\168"
    }
  },
  gdpr_email_verify = {
    keyName = "gdpr_email_verify",
    moduleName = "client.slua.umg.GDPR.minor_verify.gdpr_email_verify",
    path = "/Game/UMG/UI_BP/AgeGate/AgeGate_Popup5_UIBP.AgeGate_Popup5_UIBP",
    uiStat = {
      name = "gdpr-\233\130\174\231\174\177\233\170\140\232\175\129"
    }
  },
  gdpr_wait_email_verify = {
    keyName = "gdpr_wait_email_verify",
    moduleName = "client.slua.umg.GDPR.minor_verify.gdpr_wait_email_verify",
    path = "/Game/UMG/UI_BP/AgeGate/AgeGate_Popup1_UIBP.AgeGate_Popup1_UIBP",
    uiStat = {
      name = "gdpr-\233\130\174\231\174\177\233\170\140\232\175\129\231\187\147\230\158\156"
    }
  },
  activity_gift_animation = {
    keyName = "activity_gift_animation",
    moduleName = "client.slua.umg.activity.activity_gift_animation",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\229\149\134\229\159\142\230\180\187\229\138\168-\231\164\188\231\137\169"
    }
  },
  StoreUCGiftPage = {
    keyName = "StoreUCGiftPage",
    moduleName = "client.slua.umg.NewStoreV280.Pages.StoreUCGiftPage",
    path = "/Game/UMG/UI_BP/NewStore/store/Store_GiftBag_UIBP.Store_GiftBag_UIBP",
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "\229\149\134\229\159\142-UC\231\164\188\229\140\133\231\155\180\232\180\173-V280"
    }
  },
  SpaceGift_DiscountPacket_AutoOpen_UIBP = {
    keyName = "SpaceGift_DiscountPacket_AutoOpen_UIBP",
    moduleName = "client.slua.umg.person_space.gift_discount.SpaceGift_DiscountPacket_AutoOpen_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/SpaceGift_DiscountPacket/SpaceGift_DiscountPacket_AutoOpen_UIBP.SpaceGift_DiscountPacket_AutoOpen_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148\231\164\188\231\137\169\229\176\143R\228\187\152\232\180\185-\232\135\170\229\138\168\230\137\147\229\188\128\229\138\168\231\148\187\231\149\140\233\157\162"
    }
  },
  SpaceGift_DiscountPacket_Buy_UIBP = {
    keyName = "SpaceGift_DiscountPacket_Buy_UIBP",
    moduleName = "client.slua.umg.person_space.gift_discount.SpaceGift_DiscountPacket_Buy_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/SpaceGift_DiscountPacket/SpaceGift_DiscountPacket_Buy_UIBP.SpaceGift_DiscountPacket_Buy_UIBP",
    uiStat = {
      name = "\228\186\186\230\176\148\231\164\188\231\137\169\229\176\143R\228\187\152\232\180\185-\232\180\173\228\185\176\231\149\140\233\157\162"
    }
  },
  SpaceGift_DiscountPacket_Entrance_UIBP = {
    keyName = "SpaceGift_DiscountPacket_Entrance_UIBP",
    moduleName = "client.slua.umg.person_space.gift_discount.SpaceGift_DiscountPacket_Entrance_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/SpaceGift_DiscountPacket/SpaceGift_DiscountPacket_Entrance_UIBP.SpaceGift_DiscountPacket_Entrance_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\186\186\230\176\148\231\164\188\231\137\169\229\176\143R\228\187\152\232\180\185-\230\180\187\229\138\168\229\133\165\229\143\163\231\149\140\233\157\162"
    }
  },
  VersionAlbum_GivingGifts_Popup_UIBP = {
    keyName = "VersionAlbum_GivingGifts_Popup_UIBP",
    moduleName = "client.slua.umg.EventPhoto.Popup.VersionAlbum_GivingGifts_Popup_UIBP",
    path = "/Game/UMG/UI_BP/EventPhoto/Popup/VersionAlbum_GivingGifts_Popup_UIBP.VersionAlbum_GivingGifts_Popup_UIBP",
    uiStat = {
      name = "\232\181\160\233\128\129\229\141\161\231\137\140"
    }
  },
  Activty_AdditionRecord_Popup_UIBP = {
    keyName = "Activty_AdditionRecord_Popup_UIBP",
    moduleName = "client.slua.umg.popular_gift_pk.Activty_AdditionRecord_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Popup/Activty_AdditionRecord_Popup_UIBP.Activty_AdditionRecord_Popup_UIBP",
    uiStat = {
      name = "\228\186\178\229\175\134\229\186\166\229\143\140\229\128\141\230\180\187\229\138\168-\232\174\176\229\189\149"
    }
  },
  PopularGift_SelectPlayer_UIBP = {
    keyName = "PopularGift_SelectPlayer_UIBP",
    moduleName = "client.slua.umg.PersonSpace.PopularGift_SelectPlayer_UIBP",
    path = "/Game/UMG/UI_BP/PersonSpace/PopularGift_SelectPlayer_UIBP.PopularGift_SelectPlayer_UIBP",
    uiStat = {
      name = "\232\181\160\231\164\188\233\157\162\230\157\191-\233\128\137\230\139\169\231\142\169\229\174\182\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  Setting_BindMailbox_Panel_UIBP = {
    keyName = "Setting_BindMailbox_Panel_UIBP",
    moduleName = "client.slua.umg.setting.Account.Popup.Setting_BindMailbox_Panel_UIBP",
    path = "/Game/UMG/UI_BP/Setting/Account/Popup/Setting_BindMailbox_Panel_UIBP.Setting_BindMailbox_Panel_UIBP",
    uiStat = {
      name = "\232\180\166\229\143\183\231\187\145\229\174\154-\230\184\184\229\174\162\229\188\149\229\175\188"
    },
    isMainUI = false
  }
}
return mail_ui_configs