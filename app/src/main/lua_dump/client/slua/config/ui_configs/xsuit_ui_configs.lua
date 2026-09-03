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
local xsuit_ui_configs = {
  AsyncXSuitSpinContainer = {
    keyName = "AsyncXSuitSpinContainer",
    moduleName = "client.slua.umg.lobby_activity.xsuit_spin.Container.AsyncXSuitSpinContainer",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    asy = true,
    uiStat = {
      name = "\229\156\163\232\163\133-\230\138\189\229\165\150\228\184\187\231\149\140\233\157\162"
    }
  },
  AsyncXSuitPreviewContainer = {
    keyName = "AsyncXSuitPreviewContainer",
    moduleName = "client.slua.umg.lobby_activity.xsuit_spin.Container.AsyncXSuitPreviewContainer",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    asy = true,
    jumpModuleID = BP_ENUM_MODULE_XSUIT_PREVIEW,
    uiStat = {
      name = "\229\156\163\232\163\133-\230\138\189\229\165\150\233\162\132\232\167\136"
    }
  },
  AsyncXSuitExchangeContainer = {
    keyName = "AsyncXSuitExchangeContainer",
    moduleName = "client.slua.umg.lobby_activity.xsuit_spin.Container.AsyncXSuitExchangeContainer",
    path = "/Game/Arts_UI/LuckyWidget/Lucky_Common_Async_Form_UIBP.Lucky_Common_Async_Form_UIBP",
    asy = true,
    jumpModuleID = BP_ENUM_MODULE_XSUIT_EXCHANGE,
    uiStat = {
      name = "\229\156\163\232\163\133-\230\138\189\229\165\150\229\133\145\230\141\162"
    }
  },
  XSuit_Get_UIBP = {
    keyName = "XSuit_Get_UIBP",
    moduleName = "client.slua.umg.lobby_activity.xsuit_spin.NormalUI.XSuit_Get_UIBP",
    path = "/Game/Arts_UI/FromUMG/XSuit/XSuitSpin/Xsuit_Get_UIBP.Xsuit_Get_UIBP",
    asy = true,
    uiStat = {
      name = "\229\156\163\232\163\133\230\138\189\229\165\150-\232\142\183\229\190\151"
    }
  },
  XSuit_Upgrade_Tips_UIBP = {
    keyName = "XSuit_Upgrade_Tips_UIBP",
    moduleName = "client.slua.umg.golden_suit.XSuit_Upgrade_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Setting/item/Throw_Tips_UIBP.Throw_Tips_UIBP",
    asy = true,
    uiStat = {
      name = "\229\156\163\232\163\133\229\141\135\230\152\159-\230\143\144\231\164\186"
    }
  },
  Xsuit_Gift_Confirm_UIBP = {
    keyName = "Xsuit_Gift_Confirm_UIBP",
    moduleName = "client.slua.umg.lobby_activity.xsuit_spin.NormalUI.Xsuit_Gift_Confirm_UIBP",
    path = "/Game/Arts_UI/FromUMG/XSuit/XSuitSpin/Xsuit_Gift_Confirm_UIBP.Xsuit_Gift_Confirm_UIBP",
    asy = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\156\163\232\163\133\232\181\160\233\128\129-\230\136\144\229\138\159\230\143\144\231\164\186"
    }
  },
  golden_suit_upgrade = {
    keyName = "golden_suit_upgrade",
    moduleName = "client.slua.umg.golden_suit.golden_suit_upgrade",
    jumpModuleID = BP_ENUM_MODULE_GOLDENSUIT_UPGRADE,
    path = "/Game/Arts_UI/FromUMG/XSuit/XsuitWorkShop/XSuit_Main_UIBP.XSuit_Main_UIBP",
    asy = true,
    uiStat = {
      name = "\229\156\163\232\163\133-\229\141\135\230\152\159\231\149\140\233\157\162"
    }
  },
  xsuit_spin_video_player_system = {
    keyName = "xsuit_spin_video_player_system",
    moduleName = "client.slua.umg.lobby_activity.xsuit_spin.Pool.xsuit_spin_video_player_system",
    path = "/Game/Arts_UI/FromUMG/XSuit/XSuitSpin/XSuit_Video.XSuit_Video",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\229\156\163\232\163\133\232\189\172\231\155\152-\232\167\134\233\162\145\230\146\173\230\148\190"
    }
  },
  xsuit_video_player_mask = {
    keyName = "xsuit_video_player_mask",
    moduleName = "client.slua.umg.common.video_player_mask",
    path = "/Game/UMG/UI_BP/Common/VideoMask.VideoMask",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\229\156\163\232\163\133\232\189\172\231\155\152-\232\167\134\233\162\145\230\146\173\230\148\190-\232\146\153\231\137\136"
    }
  },
  golden_suit_translation = {
    keyName = "golden_suit_translation",
    moduleName = "client.slua.umg.golden_suit.golden_suit_translation",
    path = "/Game/Arts_UI/LuckySpin/2800/Global/Electro/Electro_Transition_UIBP.Electro_Transition_UIBP",
    uiStat = {
      name = "\233\135\145\232\163\133-\232\189\172\229\156\186"
    }
  },
  golden_suit_EnterVideo = {
    keyName = "golden_suit_EnterVideo",
    moduleName = "client.slua.umg.golden_suit.golden_suit_EnterVideo",
    path = "",
    uiStat = {
      name = "\233\135\145\232\163\133-\229\133\165\229\156\186\232\167\134\233\162\145"
    }
  },
  XSuitPreview_RPPlane_Item = {
    moduleName = "client.slua.umg.PharaohRises.Item.XSuitPreview_RPPlane_Item",
    path = "/Game/Arts_UI/FromUMG/XSuit/XsuitWorkShop/Item/XSuitPreview_RPPlane_Item.XSuitPreview_RPPlane_Item",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\183\165\229\157\138-\229\144\141\231\137\140\229\177\149\231\164\186"
    }
  },
  XSuitPreview_Enter_Item = {
    keyName = "XSuitPreview_Enter_Item",
    moduleName = "client.slua.umg.PharaohRises.Item.XSuitPreview_Enter_Item",
    path = "/Game/Arts_UI/FromUMG/XSuit/XsuitWorkShop/Item/XSuitPreview_Enter_Item.XSuitPreview_Enter_Item",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\183\165\229\157\138-\229\133\165\229\156\186\230\146\173\230\138\165\229\177\149\231\164\186"
    }
  },
  golden_suit_upgrade_detail = {
    keyName = "golden_suit_upgrade_detail",
    moduleName = "client.slua.umg.golden_suit.golden_suit_upgrade_detail",
    path = "/Game/Arts_UI/FromUMG/XSuit/XsuitWorkShop/XSuit_Details_UIBP.XSuit_Details_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\233\135\145\232\163\133-\229\141\135\230\152\159\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  golden_suit_upgrade_popup = {
    keyName = "golden_suit_upgrade_popup",
    moduleName = "client.slua.umg.golden_suit.golden_suit_upgrade_popup",
    path = "/Game/UMG/UI_BP/Common/XSuit/XSuit_Upgrade_Popup_UIBP.XSuit_Upgrade_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\233\135\145\232\163\133-\229\141\135\230\152\159\230\136\144\229\138\159\231\149\140\233\157\162"
    }
  },
  XSuitGlideUnLock = {
    keyName = "XSuitGlideUnLock",
    moduleName = "client.slua.umg.golden_suit.XSuitGlideUnLock",
    path = "/Game/Arts_UI/FromUMG/XSuit/XsuitWorkShop/XSuit_Glide_Unlock_Popup_UIBP.XSuit_Glide_Unlock_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\229\156\163\232\163\133-\232\167\163\233\148\129\233\163\158\232\161\140\229\153\168\229\188\185\231\170\151"
    }
  },
  chat_xsuit_gift_tips = {
    keyName = "chat_xsuit_gift_tips",
    moduleName = "client.slua.umg.lobby_chat.chat_xsuit_gift_tips",
    path = "/Game/Arts_UI/FromUMG/XSuit/XSuitLobby/GiftBroadcast_Mermaid_UIBP.GiftBroadcast_Mermaid_UIBP",
    asy = true,
    uiStat = {
      name = "\232\129\138\229\164\169-\229\156\163\232\163\133\232\181\160\233\128\129\230\143\144\231\164\186"
    }
  },
  XSuit_EnterAction = {
    keyName = "XSuit_EnterAction",
    moduleName = "client.slua.umg.golden_suit.golden_suit_enter_action",
    path = "/Game/UMG/UI_BP/Common/XSuit_EnterAction_UIBP.XSuit_EnterAction_UIBP",
    uiStat = {
      name = "\229\156\163\232\163\133\230\138\152\230\137\163\229\138\168\231\148\187"
    }
  },
  golden_suit_invite_tip = {
    keyName = "golden_suit_invite_tip",
    moduleName = "client.slua.umg.golden_suit.golden_suit_invite_tip",
    path = "/Game/UMG/UI_BP/Universal_Popup/XSuit_Popup.XSuit_Popup",
    AndroidBackType = EAndroidBackType.Ban,
    asy = true,
    uiStat = {
      name = "\233\135\145\232\163\133-\233\130\128\232\175\183\232\161\168\230\131\133"
    }
  },
  XSuitGiftReceiveTips = {
    keyName = "XSuitGiftReceiveTips",
    moduleName = "client.slua.umg.golden_suit.XSuitGiftReceiveTips",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\231\164\188\231\137\169\228\184\173\229\191\131\229\188\185\229\135\186\230\161\134(\233\135\145\232\163\133)"
    }
  },
  xsuit_unlock_component = {
    keyName = "xsuit_unlock_component",
    moduleName = "client.slua.umg.golden_suit.component.xsuit_unlock_component",
    path = "/Game/Arts_UI/FromUMG/XSuit/XsuitWorkShop/Item/XSuitUnlockComponent.XSuitUnlockComponent",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\229\156\163\232\163\133\229\141\135\230\152\159\232\167\163\233\148\129"
    }
  }
}
return xsuit_ui_configs