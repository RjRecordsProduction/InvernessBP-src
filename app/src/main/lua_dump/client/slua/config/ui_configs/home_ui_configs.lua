local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
require("client.slua.config.ClientMacros.bp_macros")
require("client.common.game_status")
require("client.slua.config.ClientMacros.EFixedZOrder")
require("client.slua.config.ClientMacros.UIContainers")
require("client.common.SlateUI_ID")
local home_ui_configs = {
  PlanPH_Store_Main_UIBP = {
    keyName = "PlanPH_Store_Main_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PlanPH_Store_Main_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_Main_UIBP.PlanPH_Store_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_PLANPH_HOME_STORE,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142-\229\149\134\229\186\151\228\184\187\231\149\140\233\157\162"
    }
  },
  PlanPH_Store_Money_UIBP = {
    keyName = "PlanPH_Store_Money_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PlanPH_Store_Money_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_Money_UIBP.PlanPH_Store_Money_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142-\232\180\167\229\184\129"
    }
  },
  PlanPH_Store_Recommend_UIBP = {
    keyName = "PlanPH_Store_Recommend_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PlanPH_Store_Recommend_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_Recommend_UIBP.PlanPH_Store_Recommend_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142-\230\142\168\232\141\144"
    }
  },
  PlanPH_Store_Discount_UIBP = {
    keyName = "PlanPH_Store_Discount_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PlanPH_Store_Discount_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_Discount_UIBP.PlanPH_Store_Discount_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142-\230\142\168\232\141\144-\230\138\152\230\137\163"
    }
  },
  PlanPH_Store_Set_UIBP = {
    keyName = "PlanPH_Store_Set_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PlanPH_Store_Set_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_Set_UIBP.PlanPH_Store_Set_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142-\229\165\151\228\187\182"
    }
  },
  PlanPH_Store_Product_UIBP = {
    keyName = "PlanPH_Store_Product_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PlanPH_Store_Product_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_Product_UIBP.PlanPH_Store_Product_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142-\231\187\147\230\158\132\232\163\133\233\165\176\229\162\153\231\186\184"
    }
  },
  PlanPH_Store_Props_UIBP = {
    keyName = "PlanPH_Store_Props_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PlanPH_Store_Props_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_Props_UIBP.PlanPH_Store_Props_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142-\233\129\147\229\133\183"
    }
  },
  PlanPH_Store_Module_UIBP = {
    keyName = "PlanPH_Store_Module_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PlanPH_Store_Module_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_Module_UIBP.PlanPH_Store_Module_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142-\230\168\161\231\187\132"
    }
  },
  PlanPH_Store_AnniversaryChest_UIBP = {
    keyName = "PlanPH_Store_AnniversaryChest_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PlanPH_Store_AnniversaryChest_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_AnniversaryChest_UIBP.PlanPH_Store_AnniversaryChest_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142-\229\174\157\231\174\177"
    }
  },
  PlanPH_Store_Detail_Goods_UIBP = {
    keyName = "PlanPH_Store_Detail_Goods_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PlanPH_Store_Detail_Goods_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_Detail_Goods_UIBP.PlanPH_Store_Detail_Goods_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142-\229\149\134\229\147\129\232\175\166\230\131\133"
    }
  },
  PlanPH_Store_LuckySpin_Detail_Goods_UIBP = {
    keyName = "PlanPH_Store_LuckySpin_Detail_Goods_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.Item.PlanPH_Store_LuckySpin_Detail_Goods_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_Detail_Goods_UIBP.PlanPH_Store_Detail_Goods_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\174\182\229\155\173\232\189\172\231\155\152\229\133\145\230\141\162\229\149\134\229\159\142-\229\149\134\229\147\129\232\175\166\230\131\133"
    }
  },
  PlanPH_Store_Popup_UIBP = {
    keyName = "PlanPH_Store_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PlanPH_Store_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/popup/PlanPH_Store_Popup_UIBP.PlanPH_Store_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142-\229\165\151\228\187\182\229\188\185\231\170\151"
    }
  },
  PlanPH_BuyPopup_UIBP = {
    keyName = "PlanPH_BuyPopup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PlanPH_BuyPopup_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/popup/PlanPH_BuyPopup_UIBP.PlanPH_BuyPopup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142-\232\180\173\228\185\176\229\188\185\231\170\151"
    }
  },
  PlanPH_FloatAir_Popup_UIBP = {
    keyName = "PlanPH_FloatAir_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.popup.PlanPH_FloatAir_Popup_UIBP",
    containerName = UIContainers.Top,
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/popup/PlanPH_FloatAir_Popup_UIBP.PlanPH_FloatAir_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\230\181\174\231\169\186\231\137\169\228\187\182\232\175\166\230\131\133"
    }
  },
  PlanPH_DrawingHall_Main_UIBP = {
    keyName = "PlanPH_DrawingHall_Main_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.PlanPH_DrawingHall_Main_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Drawing/PlanPH_DrawingHall_Main_UIBP.PlanPH_DrawingHall_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_PLANPH_DRAWING,
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133\228\184\187\231\149\140\233\157\162"
    }
  },
  PlanPH_DrawingHall_Drawing_UIBP = {
    keyName = "PlanPH_DrawingHall_Drawing_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.PlanPH_DrawingHall_Drawing_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Drawing/PlanPH_DrawingHall_Drawing_UIBP.PlanPH_DrawingHall_Drawing_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\155\190\231\186\184\229\136\151\232\161\168"
    }
  },
  PlanPH_Drawing_Detail_Goods_UIBP = {
    keyName = "PlanPH_Drawing_Detail_Goods_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.PlanPH_Drawing_Detail_Goods_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Drawing/PlanPH_Drawing_Detail_Goods_UIBP.PlanPH_Drawing_Detail_Goods_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\183\166\228\190\167\232\175\166\230\131\133"
    }
  },
  PlanPH_Drawing_Item_UIBP = {
    keyName = "PlanPH_Drawing_Item_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.Item.PlanPH_Drawing_Item_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Drawing/Item/PlanPH_Drawing_Item_UIBP.PlanPH_Drawing_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\155\190\231\186\184\230\150\185\230\161\136Item"
    }
  },
  PlanPH_DrawingHall_Popup_UIBP = {
    keyName = "PlanPH_DrawingHall_Popup_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.PlanPH_DrawingHall_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Drawing/Popup/PlanPH_DrawingHall_Popup_UIBP.PlanPH_DrawingHall_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\232\180\173\228\185\176\229\155\190\231\186\184\229\188\185\231\170\151"
    }
  },
  PlanPH_Drawing_Tips_UIBP = {
    keyName = "PlanPH_Drawing_Tips_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.PlanPH_Drawing_Tips_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Drawing/Tips/PlanPH_Drawing_Tips_UIBP.PlanPH_Drawing_Tips_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\231\155\184\228\188\188\229\186\166\232\175\166\230\131\133\230\152\190\231\164\186"
    }
  },
  PlanPH_Drawing_HaveReleased_Popup_UIBP = {
    keyName = "PlanPH_Drawing_HaveReleased_Popup_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.PlanPH_Drawing_HaveReleased_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Drawing/Popup/PlanPH_Drawing_HaveReleased_Popup_UIBP.PlanPH_Drawing_HaveReleased_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\183\178\229\143\145\229\184\131\229\155\190\231\186\184"
    }
  },
  PlanPH_Save_Popups_UIBP = {
    keyName = "PlanPH_Save_Popups_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.PlanPH_Save_Popups_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/PlanPH_Save_Popups_UIBP.PlanPH_Save_Popups_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\228\191\157\229\173\152\228\184\142\233\128\128\229\135\186"
    }
  },
  PlanPH_Apply_Popups_UIBP = {
    keyName = "PlanPH_Apply_Popups_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.PlanPH_Apply_Popups_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/PlanPH_Save_Popups_UIBP.PlanPH_Save_Popups_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\228\184\128\233\148\174\229\186\148\231\148\168\229\188\185\231\170\151"
    }
  },
  PlanPH_HirePurchase_Popup_UIBP = {
    keyName = "PlanPH_HirePurchase_Popup_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.HirePurchase.Popup.PlanPH_HirePurchase_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/HirePurchase/Popup/PlanPH_HirePurchase_Popup_UIBP.PlanPH_HirePurchase_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\136\134\230\156\159\228\187\152\230\172\190-\228\184\187\231\149\140\233\157\162"
    }
  },
  PlanPH_HirePurchase_Preview_UIBP = {
    keyName = "PlanPH_HirePurchase_Preview_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.HirePurchase.Popup.PlanPH_HirePurchase_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/HirePurchase/Popup/PlanPH_HirePurchase_Preview_UIBP.PlanPH_HirePurchase_Preview_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\136\134\230\156\159\228\187\152\230\172\190-\228\187\152\230\172\190\233\162\132\232\167\136"
    }
  },
  PlanPH_HirePurchase_Popup_Info_Item_UIBP = {
    keyName = "PlanPH_HirePurchase_Popup_Info_Item_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.HirePurchase.Item.PlanPH_HirePurchase_Popup_Info_Item_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/HirePurchase/Item/PlanPH_HirePurchase_Popup_Info_Item_UIBP.PlanPH_HirePurchase_Popup_Info_Item_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\136\134\230\156\159\228\187\152\230\172\190-\228\184\187\231\149\140\233\157\162-\229\173\144item"
    }
  },
  PlanPH_HirePurchase_Rules_Popup_UIBP = {
    keyName = "PlanPH_HirePurchase_Rules_Popup_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.HirePurchase.Popup.PlanPH_HirePurchase_Rules_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/HirePurchase/Popup/PlanPH_HirePurchase_Rules_Popup_UIBP.PlanPH_HirePurchase_Rules_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\136\134\230\156\159\228\187\152\230\172\190-\231\161\174\232\174\164"
    }
  },
  PlanPH_HirePurchase_Prompt_Popup_UIBP = {
    keyName = "PlanPH_HirePurchase_Prompt_Popup_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.HirePurchase.Popup.PlanPH_HirePurchase_Prompt_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/HirePurchase/Popup/PlanPH_HirePurchase_Prompt_Popup_UIBP.PlanPH_HirePurchase_Prompt_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\136\134\230\156\159\228\187\152\230\172\190-\233\128\190\230\156\159\230\143\144\231\164\186"
    }
  },
  PlanPH_HirePurchase_InAdvance_Popup_UIBP = {
    keyName = "PlanPH_HirePurchase_InAdvance_Popup_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.HirePurchase.Popup.PlanPH_HirePurchase_InAdvance_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/HirePurchase/Popup/PlanPH_HirePurchase_InAdvance_Popup_UIBP.PlanPH_HirePurchase_InAdvance_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\136\134\230\156\159\228\187\152\230\172\190-\230\143\144\229\137\141\232\191\152\230\172\190"
    }
  },
  PlanPH_HirePurchase_DeductionList_Popup_UIBP = {
    keyName = "PlanPH_HirePurchase_DeductionList_Popup_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.HirePurchase.Popup.PlanPH_HirePurchase_DeductionList_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/HirePurchase/Popup/PlanPH_HirePurchase_DeductionList_Popup_UIBP.PlanPH_HirePurchase_DeductionList_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\136\134\230\156\159\228\187\152\230\172\190-\230\138\181\230\137\163\232\175\166\230\131\133"
    }
  },
  PlanPH_HirePurchase_Get_Popup_UIBP = {
    keyName = "PlanPH_HirePurchase_Get_Popup_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.HirePurchase.Popup.PlanPH_HirePurchase_Get_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/HirePurchase/Popup/PlanPH_HirePurchase_Get_Popup_UIBP.PlanPH_HirePurchase_Get_Popup_UIBP",
    uiStat = {
      name = "\229\136\134\230\156\159\228\187\152\230\172\190-\230\129\173\229\150\156\232\142\183\229\190\151-\230\138\181\230\137\163\232\175\180\230\152\142"
    }
  },
  PlanPH_Drawing_UsagePlan_Popup_UIBP = {
    keyName = "PlanPH_Drawing_UsagePlan_Popup_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.PlanPH_Drawing_UsagePlan_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Drawing/Popup/PlanPH_Drawing_UsagePlan_Popup_UIBP.PlanPH_Drawing_UsagePlan_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\155\190\231\186\184\230\150\185\230\161\136\229\177\149\231\164\186"
    },
    containerName = UIContainers.Top,
    zOrder = 20
  },
  PlanPH_Drawing_Publish_UIBP = {
    keyName = "PlanPH_Drawing_Publish_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.PlanPH_Drawing_Publish_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Drawing/PlanPH_Drawing_Publish_UIBP.PlanPH_Drawing_Publish_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\183\178\229\143\145\229\184\131\229\155\190\231\186\184"
    }
  },
  PlanPH_Publish_Item_UIBP = {
    keyName = "PlanPH_Publish_Item_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.Item.PlanPH_Publish_Item_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Drawing/Item/PlanPH_Publish_Item_UIBP.PlanPH_Publish_Item_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\183\178\229\143\145\229\184\131\229\155\190\231\186\184-\229\173\144Item"
    }
  },
  PlanPH_Drawing_Creation_Level_UIBP = {
    keyName = "PlanPH_Drawing_Creation_Level_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.PlanPH_Drawing_Creation_Level_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Drawing/PlanPH_Drawing_Creation_Level_UIBP.PlanPH_Drawing_Creation_Level_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\136\155\228\189\156\230\191\128\229\138\177"
    }
  },
  PlanPH_Drawing_Creation_Level_Item_UIBP = {
    keyName = "PlanPH_Drawing_Creation_Level_Item_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.Item.PlanPH_Drawing_Creation_Level_Item_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Drawing/Item/PlanPH_Drawing_Creation_Level_Item_UIBP.PlanPH_Drawing_Creation_Level_Item_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\229\136\155\228\189\156\230\191\128\229\138\177-\229\173\144Item"
    }
  },
  PlanPH_ConfirmBlueprint_Popups_UIBP = {
    keyName = "PlanPH_ConfirmBlueprint_Popups_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Popup.PlanPH_ConfirmBlueprint_Popups_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Popup/PlanPH_ConfirmBlueprint_Popups_UIBP.PlanPH_ConfirmBlueprint_Popups_UIBP",
    uiStat = {
      name = "\229\155\190\231\186\184\228\184\128\233\148\174\229\143\145\229\184\131\231\161\174\232\174\164\229\188\185\231\170\151"
    }
  },
  PlanPH_EditPlan_Blueprint_UIBP = {
    keyName = "PlanPH_EditPlan_Blueprint_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.EditPlan.PlanPH_EditPlan_Blueprint_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/EditPlan/PlanPH_EditPlan_Blueprint_UIBP.PlanPH_EditPlan_Blueprint_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\229\155\190\231\186\184\229\188\185\231\170\151"
    }
  },
  PlanPH_CRAFTMANPass_Award_UIBP_LOBBY = {
    keyName = "PlanPH_CRAFTMANPass_Award_UIBP_LOBBY",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.CRAFTMANPass.PlanPH_CRAFTMANPass_Award_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/CRAFTMANPass/PlanPH_CRAFTMANPass_Award_UIBP.PlanPH_CRAFTMANPass_Award_UIBP",
    jumpModuleID = BP_ENUM_MODULE_HOME_PASS,
    uiStat = {
      name = "\229\174\182\229\155\173-\229\183\167\229\140\160\232\182\133\229\128\188\233\128\154-\228\184\187\231\149\140\233\157\162"
    }
  },
  PlanPH_CRAFTMANPass_Buy_Popup_UIBP_LOBBY = {
    keyName = "PlanPH_CRAFTMANPass_Buy_Popup_UIBP_LOBBY",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.CRAFTMANPass.Popup.PlanPH_CRAFTMANPass_Buy_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/CRAFTMANPass/Popup/PlanPH_CRAFTMANPass_Buy_Popup_UIBP.PlanPH_CRAFTMANPass_Buy_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\183\167\229\140\160\232\182\133\229\128\188\233\128\154-\232\180\173\228\185\176\231\149\140\233\157\162"
    }
  },
  PlanPH_CRAFTMANPass_Buy_Cover_Popup_UIBP = {
    keyName = "PlanPH_CRAFTMANPass_Buy_Cover_Popup_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.CRAFTMANPass.Popup.PlanPH_CRAFTMANPass_Buy_Cover_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/CRAFTMANPass/Popup/PlanPH_CRAFTMANPass_Buy_Cover_Popup_UIBP.PlanPH_CRAFTMANPass_Buy_Cover_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\183\167\229\140\160\232\182\133\229\128\188\233\128\154-\229\144\136\228\185\176\231\149\140\233\157\162"
    }
  },
  PlanPH_Store_LuckySpin2D_UIBP = {
    keyName = "PlanPH_Store_LuckySpin2D_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PlanPH_Store_LuckySpin2D_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_LuckySpin2D_UIBP.PlanPH_Store_LuckySpin2D_UIBP",
    jumpModuleID = BP_ENUM_MODULE_JUMP_HOME_STORE_SPIN_2D,
    asy = true,
    uiStat = {
      name = "\229\174\182\229\155\173\230\138\189\229\165\150\231\149\140\233\157\1622D"
    }
  },
  PlanPH_Store_LuckySpin2D_Child_UIBP = {
    keyName = "PlanPH_Store_LuckySpin2D_Child_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.PlanPH_Store_LuckySpin2D_Child_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_LuckySpin2D_UIBP.PlanPH_Store_LuckySpin2D_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\230\138\189\229\165\150\231\149\140\233\157\1622D(\229\174\182\229\155\173\228\184\187\233\161\181\230\140\130\232\189\189\231\148\168)"
    }
  },
  PlanPH_Exchange_Box_Rewards_UIBP = {
    keyName = "PlanPH_Exchange_Box_Rewards_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.ExchangeDealer.PlanPH_Exchange_Box_Rewards_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_LuckySpin_Rewards_UIBP.PlanPH_Store_LuckySpin_Rewards_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\229\133\145\230\141\162\229\149\134\228\186\186\229\165\150\229\138\177\233\162\132\232\167\136\231\149\140\233\157\162"
    }
  },
  PlanPH_Spin2D_Popup_UIBP = {
    keyName = "PlanPH_Spin2D_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.popup.PlanPH_Spin2D_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/popup/PlanPH_Spin2D_Popup_UIBP.PlanPH_Spin2D_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\231\161\174\232\174\164\232\180\167\229\184\129\228\189\191\231\148\168pop"
    }
  },
  PlanPH_Store_MG_Popup_UIBP = {
    keyName = "PlanPH_Store_MG_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.popup.PlanPH_Store_MG_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/popup/PlanPH_Store_MG_Popup_UIBP.PlanPH_Store_MG_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\232\189\172\231\155\152\228\191\157\229\186\149\229\165\150\229\138\177\233\162\134\229\143\150"
    }
  },
  PlanPH_PDP_Popup_UIBP = {
    keyName = "PlanPH_PDP_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Home.PHomeStore.popup.PlanPH_PDP_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/popup/PlanPH_PDP_Popup_UIBP.PlanPH_PDP_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-PDP\231\149\140\233\157\162"
    }
  },
  PlanPH_AnniversaryActivity_Popup_UIBP = {
    keyName = "PlanPH_AnniversaryActivity_Popup_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.AnniversaryActivity.Popup.PlanPH_AnniversaryActivity_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/AnniversaryActivity/Popup/PlanPH_AnniversaryActivity_Popup_UIBP.PlanPH_AnniversaryActivity_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\174\182\229\155\173\230\150\176\228\184\187\233\162\152-\228\184\137\233\128\137\228\184\128\231\149\140\233\157\162"
    }
  },
  PlanPH_MultiEdit_Invite_UIBP = {
    keyName = "PlanPH_MultiEdit_Invite_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.MultiEdit.PlanPH_MultiEdit_Invite_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/MultiEdit/PlanPH_MultiEdit_Invite_UIBP.PlanPH_MultiEdit_Invite_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\164\154\228\186\186\231\188\150\232\190\145-\233\130\128\232\175\183\231\149\140\233\157\162"
    }
  },
  PlanPH_Majordomo_Role_Par_UIBP = {
    keyName = "PlanPH_Majordomo_Role_Par_UIBP",
    moduleName = "client.slua.umg.Home.Housekeeper.PlanPH_Majordomo_Role_Par_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Majordomo/PlanPH_Majordomo_Role_Par_UIBP.PlanPH_Majordomo_Role_Par_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\229\174\182\229\155\173-\231\174\161\229\174\182-\228\186\178\229\175\134\229\186\166\231\137\185\230\149\136"
    }
  },
  PlanPH_Majordomo_Role_UIBP = {
    keyName = "PlanPH_Majordomo_Role_UIBP",
    moduleName = "client.slua.umg.Home.Housekeeper.PlanPH_Majordomo_Role_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Majordomo/PlanPH_Majordomo_Role_UIBP.PlanPH_Majordomo_Role_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\231\174\161\229\174\182-\231\171\139\231\187\152"
    }
  },
  PlanPH_Majordomo_LevelUP_UIBP = {
    keyName = "PlanPH_Majordomo_LevelUP_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Housekeeper.PlanPH_Majordomo_LevelUP_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Majordomo/PlanPH_Majordomo_LevelUP_UIBP.PlanPH_Majordomo_LevelUP_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\231\174\161\229\174\182-\229\141\135\231\186\167"
    }
  },
  PlanPH_Chat_AI_Popups_UIBP = {
    keyName = "PlanPH_Chat_AI_Popups_UIBP",
    moduleName = "client.slua.umg.Home.Housekeeper.PlanPH_Chat_AI_Popups_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Chat/Popup/PlanPH_Chat_AI_Popups_UIBP.PlanPH_Chat_AI_Popups_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\231\174\161\229\174\182-\229\141\135\231\186\167"
    }
  },
  PlanPH_Party_HistoricalRecord_Popup_UIBP = {
    keyName = "PlanPH_Party_HistoricalRecord_Popup_UIBP",
    moduleName = "client.slua.umg.Home.Party.PlanPH_Party_HistoricalRecord_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Party/Popup/PlanPH_Party_HistoricalRecord_Popup_UIBP.PlanPH_Party_HistoricalRecord_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\230\180\190\229\175\185\229\155\158\229\191\134\229\136\151\232\161\168"
    }
  },
  PlanPH_Party_Memories_UIBP = {
    keyName = "PlanPH_Party_Memories_UIBP",
    moduleName = "client.slua.umg.Home.Party.PlanPH_Party_Memories_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Party/PartyMemories/PlanPH_Party_Memories_UIBP.PlanPH_Party_Memories_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\230\180\190\229\175\185\229\155\158\229\191\134\229\177\149\231\164\186\231\149\140\233\157\162"
    }
  },
  PlanPH_Party_Memories_Share_UIBP = {
    keyName = "PlanPH_Party_Memories_Share_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Party.PartyMemories.PlanPH_Party_Memories_Share_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Party/PartyMemories/PlanPH_Party_Memories_Share_UIBP.PlanPH_Party_Memories_Share_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\230\180\190\229\175\185\229\155\158\229\191\134\229\136\134\228\186\171-\228\184\187\231\149\140\233\157\162"
    }
  },
  PlanPH_Party_SignIn_Popup_UIBP = {
    keyName = "PlanPH_Party_SignIn_Popup_UIBP",
    moduleName = "client.slua.umg.Home.Party.PlanPH_Party_SignIn_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Party/Popup/PlanPH_Party_SignIn_Popup_UIBP.PlanPH_Party_SignIn_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\174\182\229\155\173-\230\180\190\229\175\185-\233\130\128\232\175\183\229\135\189"
    }
  },
  PlanPH_Cohabit_ReleaseRule_UIBP = {
    keyName = "PlanPH_Cohabit_ReleaseRule_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Popup.PlanPH_Cohabit_ReleaseRule_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Cohabit/PlanPH_Cohabit_ReleaseRule_UIBP.PlanPH_Cohabit_ReleaseRule_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\232\167\163\233\153\164\229\144\140\228\189\143\228\184\187\231\149\140\233\157\162-\229\141\143\232\174\174\233\161\181\231\173\190"
    },
    isSingleton = false
  },
  PlanPH_AI_Chat_UIBP = {
    keyName = "PlanPH_AI_Chat_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Housekeeper.PlanPH_AI_Chat_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Chat/PlanPH_AI_Chat_UIBP.PlanPH_AI_Chat_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\231\174\161\229\174\182-AI\229\175\185\232\175\157"
    },
    AndroidBackType = EAndroidBackType.Defalut
  },
  PlanPH_Chat_AI_InformedConsentStatement_Popups_UIBP = {
    keyName = "PlanPH_Chat_AI_InformedConsentStatement_Popups_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Housekeeper.PlanPH_Chat_AI_InformedConsentStatement_Popups_UIBP",
    path = "/Game/UMG/UI_BP/Home/Rule/PlanPH_Chat_AI_InformedConsentStatement_Popups_UIBP.PlanPH_Chat_AI_InformedConsentStatement_Popups_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-AI\231\174\161\229\174\182-\229\188\185\231\170\151"
    }
  },
  PlanPH_Chat_AI_Rule_Popups_UIBP = {
    keyName = "PlanPH_Chat_AI_Rule_Popups_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Housekeeper.PlanPH_Chat_AI_Rule_Popups_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Chat/Popup/PlanPH_Chat_AI_Rule_Popups_UIBP.PlanPH_Chat_AI_Rule_Popups_UIBP",
    uiStat = {
      name = "\231\174\161\229\174\182-\230\153\186\232\131\189\229\175\185\232\175\157\232\167\132\229\136\153"
    }
  },
  PlanPH_Majordomo_Select_UIBP = {
    keyName = "PlanPH_Majordomo_Select_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Housekeeper.PlanPH_Majordomo_Select_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Majordomo/PlanPH_Majordomo_Select_UIBP.PlanPH_Majordomo_Select_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\231\174\161\229\174\182-\231\174\161\229\174\182\229\136\151\232\161\168"
    }
  },
  PlanPH_Chat_AI_Report_Popups_UIBP = {
    keyName = "PlanPH_Chat_AI_Report_Popups_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Housekeeper.PlanPH_Chat_AI_Report_Popups_UIBP",
    path = "/Game/UMG/UI_BP/Home/Rule/PlanPH_Chat_AI_Report_Popups_UIBP.PlanPH_Chat_AI_Report_Popups_UIBP",
    uiStat = {
      name = "\228\184\190\230\138\165\231\149\140\233\157\162-\231\174\161\229\174\182AI"
    }
  },
  PlanPH_Lobby_Cohabit_Main_UIBP = {
    keyName = "PlanPH_Lobby_Cohabit_Main_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Popup.PlanPH_Lobby_Cohabit_Main_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Cohabit/PlanPH_Lobby_Cohabit_Main_UIBP.PlanPH_Lobby_Cohabit_Main_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\232\167\163\233\153\164\229\144\140\228\189\143\231\148\179\232\175\183\228\184\187\231\149\140\233\157\162"
    }
  },
  PlanPH_Party_Gift_Popup_UIBP = {
    keyName = "PlanPH_Party_Gift_Popup_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.PartyGift.PlanPH_Party_Gift_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Party/Popup/PlanPH_Party_Gift_Popup_UIBP.PlanPH_Party_Gift_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\230\180\190\229\175\185\231\164\188\231\155\146-\232\181\160\233\128\129"
    }
  },
  PlanPH_Party_GiftRecord_Popup_UIBP = {
    keyName = "PlanPH_Party_GiftRecord_Popup_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.PartyGift.PlanPH_Party_GiftRecord_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Party/Popup/PlanPH_Party_GiftRecord_Popup_UIBP.PlanPH_Party_GiftRecord_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\230\180\190\229\175\185\231\164\188\231\155\146-\232\174\176\229\189\149"
    }
  },
  PlanPH_Friend_Verify_Popup_UIBP = {
    keyName = "PlanPH_Friend_Verify_Popup_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.PlanPH_Friend_Verify_Popup_UIBP",
    path = "/Game/Mod/PlanPH/BluePrints/UI/HomingPigeon/Popup/PlanPH_Friend_Verify_Popup_UIBP.PlanPH_Friend_Verify_Popup_UIBP",
    asy = true,
    uiStat = {
      name = "\229\165\189\229\143\139-\231\149\153\232\168\128\232\175\183\230\177\130\230\183\187\229\138\160\229\165\189\229\143\139-\229\144\140\228\189\143\228\186\140\233\128\137\228\184\128"
    }
  },
  PlanPH_Store_Exchange_UIBP = {
    keyName = "PlanPH_Store_Exchange_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.ParkingLot.PlanPH_Store_Exchange_UIBP",
    path = "/Game/Mod/Lobby/Split/Home/PHomeStore/PlanPH_Store_Exchange_UIBP.PlanPH_Store_Exchange_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\230\138\162\232\189\166\228\189\141-\229\133\145\230\141\162\229\149\134\229\186\151"
    }
  },
  HomePK_Main_UIBP = {
    keyName = "HomePK_Main_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.PK.HomePK_Main_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/HomePK_Main_UIBP.HomePK_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_HOMEPK_MAIN,
    uiStat = {
      name = "\229\174\182\229\155\173PK-\228\184\187\231\149\140\233\157\162"
    }
  },
  HomePK_Main_Child_UIBP = {
    keyName = "HomePK_Main_Child_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.PK.HomePK_Main_Child_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/HomePK_Main_UIBP.HomePK_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173pk-\228\184\187\231\149\140\233\157\162(\229\174\182\229\155\173\228\184\187\233\161\181\230\140\130\232\189\189\231\148\168)"
    }
  },
  HomePK_Popular_Enroll_UIBP = {
    keyName = "HomePK_Popular_Enroll_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.PK.HomePK_Popular_Enroll_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/HomePK_Popular_Enroll_UIBP.HomePK_Popular_Enroll_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173PK-\230\138\165\229\144\141\231\149\140\233\157\162"
    }
  },
  HomePK_Match_UIBP = {
    keyName = "HomePK_Match_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.PK.HomePK_Match_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/HomePK_Match_UIBP.HomePK_Match_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173PK-\229\140\185\233\133\141\231\149\140\233\157\162"
    }
  },
  HomePK_Condition_Tips_UIBP = {
    keyName = "HomePK_Condition_Tips_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.PK.HomePK_Condition_Tips_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/HomePK_Condition_Tips_UIBP.HomePK_Condition_Tips_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\174\182\229\155\173PK-\229\133\165\229\143\163tips"
    }
  },
  HomePK_MyPK_UIBP = {
    keyName = "HomePK_MyPK_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.PK.HomePK_MyPK_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/HomePK_MyPK_UIBP.HomePK_MyPK_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173PK-PK\231\149\140\233\157\162"
    }
  },
  HomePK_Settlement_Popup_UIBP = {
    keyName = "HomePK_Settlement_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.PK.Popup.HomePK_Settlement_Popup_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/Popup/HomePK_Settlement_Popup_UIBP.HomePK_Settlement_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173PK-\231\187\147\231\174\151\231\149\140\233\157\162"
    }
  },
  HomePK_Selection_UIBP = {
    keyName = "HomePK_Selection_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.PK.HomePK_Selection_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/HomePK_Selection_UIBP.HomePK_Selection_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173PK-\232\175\132\233\128\137\229\185\191\229\156\186\231\149\140\233\157\162"
    }
  },
  HomePK_StyleSelection_UIBP = {
    keyName = "HomePK_StyleSelection_UIBP",
    moduleName = "client.slua.umg.HomePK_StyleSelection_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/HomePK_StyleSelection_UIBP.HomePK_StyleSelection_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173PK-\233\163\142\230\160\188\232\175\132\233\128\137\231\149\140\233\157\162"
    }
  },
  HomePK_PopularityLevel_UIBP = {
    keyName = "HomePK_PopularityLevel_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.PK.HomePK_PopularityLevel_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/HomePK_PopularityLevel_UIBP.HomePK_PopularityLevel_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173PK-\229\165\150\229\138\177\229\146\140\230\142\146\232\161\140\230\166\156\231\149\140\233\157\162"
    }
  },
  HomePK_CashLottery_UIBP = {
    keyName = "HomePK_CashLottery_UIBP",
    moduleName = "client.slua.umg.HomePK_CashLottery_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/Popup/HomePK_CashLottery_UIBP.HomePK_CashLottery_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173PK-\233\163\142\230\160\188\232\175\132\233\128\137-\231\142\176\233\135\145\230\138\189\229\165\150\231\149\140\233\157\162"
    }
  },
  HomePK_ShareChat_Popup_UIBP = {
    keyName = "HomePK_ShareChat_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.PK.Popup.HomePK_ShareChat_Popup_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/Popup/HomePK_ShareChat_Popup_UIBP.HomePK_ShareChat_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173PK-\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  HomePK_Explanation_Popup_UIBP = {
    keyName = "HomePK_Explanation_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.PK.Popup.HomePK_Explanation_Popup_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/Popup/HomePK_Explanation_Popup_UIBP.HomePK_Explanation_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173PK-\232\175\180\230\152\142\231\149\140\233\157\162"
    }
  },
  HomePK_PkRecord_Popup_UIBP = {
    keyName = "HomePK_PkRecord_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.PK.Popup.HomePK_PkRecord_Popup_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/Popup/HomePK_PkRecord_Popup_UIBP.HomePK_PkRecord_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173PK-\229\175\185\229\134\179\232\174\176\229\189\149\231\149\140\233\157\162"
    }
  },
  HomePK_Votes_Content_Popup_UIBP = {
    keyName = "HomePK_Votes_Content_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.PK.Popup.HomePK_Votes_Content_Popup_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/Popup/HomePK_Votes_Content_Popup_UIBP.HomePK_Votes_Content_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173PK-\232\142\183\229\143\150\233\128\137\231\165\168\231\149\140\233\157\162"
    }
  },
  HomePK_Forecast_Popup_UIBP = {
    keyName = "HomePK_Forecast_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.PK.Popup.HomePK_Forecast_Popup_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/PK/Popup/HomePK_Forecast_Popup_UIBP.HomePK_Forecast_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173PK\233\162\132\232\167\136\231\167\175\229\136\134\231\149\140\233\157\162"
    }
  },
  Home_MsgBoard_Main_UIBP = {
    keyName = "Home_MsgBoard_Main_UIBP",
    moduleName = "client.slua.umg.Home.MessageBoard.Home_MsgBoard_Main_UIBP",
    path = "/Game/UMG/UI_BP/Home/MessageBoard/Home_MsgBoard_Main_UIBP.Home_MsgBoard_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_PLANPH_HOME_MESSAGEBOARD,
    uiStat = {
      name = "\229\174\182\229\155\173-\231\149\153\232\168\128\230\157\191\228\184\187\231\149\140\233\157\162"
    }
  },
  Home_MsgBoard_My_GuestBook_UIBP = {
    keyName = "Home_MsgBoard_My_GuestBook_UIBP",
    moduleName = "client.slua.umg.Home.MessageBoard.Home_MsgBoard_My_GuestBook_UIBP",
    path = "/Game/UMG/UI_BP/Home/MessageBoard/Home_MsgBoard_My_GuestBook_UIBP.Home_MsgBoard_My_GuestBook_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173-\231\149\153\232\168\128\230\157\191-\228\184\187\230\128\129\232\174\191\229\174\162\231\149\153\232\168\128\231\149\140\233\157\162"
    }
  },
  Home_MsgBoard_VisitorRecord_UIBP = {
    keyName = "Home_MsgBoard_VisitorRecord_UIBP",
    moduleName = "client.slua.umg.Home.MessageBoard.Home_MsgBoard_VisitorRecord_UIBP",
    path = "/Game/UMG/UI_BP/Home/MessageBoard/Home_MsgBoard_VisitorRecord_UIBP.Home_MsgBoard_VisitorRecord_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173-\231\149\153\232\168\128\230\157\191-\228\184\187\230\128\129\232\174\191\229\174\162\232\174\176\229\189\149\231\149\140\233\157\162"
    }
  },
  Home_MsgBoard_MsgList_UIBP = {
    keyName = "Home_MsgBoard_MsgList_UIBP",
    moduleName = "client.slua.umg.Home.MessageBoard.Home_MsgBoard_MsgList_UIBP",
    path = "/Game/UMG/UI_BP/Home/MessageBoard/Home_MsgBoard_MsgList_UIBP.Home_MsgBoard_MsgList_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\174\182\229\155\173-\231\149\153\232\168\128\230\157\191-\231\149\153\232\168\128\229\134\133\229\174\185\231\149\140\233\157\162"
    }
  },
  Home_MsgBoard_ReplyList_UIBP = {
    keyName = "Home_MsgBoard_ReplyList_UIBP",
    moduleName = "client.slua.umg.Home.MessageBoard.Home_MsgBoard_ReplyList_UIBP",
    path = "/Game/UMG/UI_BP/Home/MessageBoard/Home_MsgBoard_MsgList_UIBP.Home_MsgBoard_MsgList_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173-\231\149\153\232\168\128\230\157\191-\229\155\158\229\164\141\229\134\133\229\174\185\231\149\140\233\157\162"
    }
  },
  Home_MsgBoard_Visitor_GuestBook_UIBP = {
    keyName = "Home_MsgBoard_Visitor_GuestBook_UIBP",
    moduleName = "client.slua.umg.Home.MessageBoard.Home_MsgBoard_Visitor_GuestBook_UIBP",
    path = "/Game/UMG/UI_BP/Home/MessageBoard/Home_MsgBoard_Visitor_GuestBook_UIBP.Home_MsgBoard_Visitor_GuestBook_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\231\149\153\232\168\128\230\157\191-\229\174\162\230\128\129\232\174\191\229\174\162\231\149\153\232\168\128\231\149\140\233\157\162"
    }
  },
  Home_MsgBoard_Reply_UIBP = {
    keyName = "Home_MsgBoard_Reply_UIBP",
    moduleName = "client.slua.umg.Home.MessageBoard.PopUI.Home_MsgBoard_Reply_UIBP",
    path = "/Game/UMG/UI_BP/Home/MessageBoard/Popup/Home_MsgBoard_Reply_UIBP.Home_MsgBoard_Reply_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\231\149\153\232\168\128\230\157\191-\229\155\158\229\164\141\231\149\140\233\157\162"
    }
  },
  Home_MsgBoard_Operate_Menu = {
    keyName = "Home_MsgBoard_Operate_Menu",
    moduleName = "client.slua.umg.Home.MessageBoard.Home_MsgBoard_Operate_Menu",
    path = "/Game/UMG/UI_BP/PersonSpace/item/Lobby_RoleInfo_Menu_UIBP.Lobby_RoleInfo_Menu_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\231\149\153\232\168\128\230\157\191-\230\147\141\228\189\156\231\149\153\232\168\128\232\143\156\229\141\149"
    }
  },
  Home_MsgBoard_Msg_Item_Child_UIBP = {
    keyName = "Home_MsgBoard_Msg_Item_Child_UIBP",
    moduleName = "client.slua.umg.Home.MessageBoard.Item.Home_MsgBoard_Msg_Item_Child_UIBP",
    path = "/Game/UMG/UI_BP/Home/MessageBoard/Item/Home_MsgBoard_Msg_Item_Child_UIBP.Home_MsgBoard_Msg_Item_Child_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\174\182\229\155\173-\232\175\166\230\131\133\231\149\140\233\157\162-\231\174\161\229\174\182\231\149\153\232\168\128-tips"
    }
  },
  Home_Verify_Popups_UIBP = {
    keyName = "Home_Verify_Popups_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.Home_Verify_Popups_UIBP",
    path = "/Game/UMG/UI_BP/Home/Common/Popup/Small/Home_Verify_Popups_UIBP.Home_Verify_Popups_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\230\143\144\231\164\186\231\161\174\232\174\164\229\176\143\229\188\185\231\170\151"
    }
  },
  Home_Verify_Popups_UIBP_Keeper = {
    keyName = "Home_Verify_Popups_UIBP_Keeper",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.Home_Verify_Popups_UIBP_Keeper",
    path = "/Game/UMG/UI_BP/Home/Common/Popup/Small/Home_Verify_Popups_UIBP.Home_Verify_Popups_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\231\174\161\229\174\182-\230\155\191\230\141\162\229\188\185\231\170\151"
    }
  },
  Home_Tab_Horizontal_LevelOne_Text_Item_UIBP = {
    keyName = "Home_Tab_Horizontal_LevelOne_Text_Item_UIBP",
    moduleName = "client.slua.umg.Home.Common.Home_Tab_Horizontal_LevelOne_Text_Item_UIBP",
    path = "/Game/UMG/UI_BP/Home/Common/Tab/Item/Home_Tab_Horizontal_LevelOne_Text_Item_UIBP.Home_Tab_Horizontal_LevelOne_Text_Item_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\233\128\154\231\148\168\230\168\170\229\144\145\228\184\128\231\186\167\233\161\181\231\173\190Item"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.item_pool
  },
  Home_Prompt_Popups_UIBP = {
    keyName = "Home_Prompt_Popups_UIBP",
    moduleName = "client.slua.umg.Home.SafetyAudit.Home_Prompt_Popups_UIBP",
    path = "/Game/UMG/UI_BP/Home/Audit/Home_Prompt_Popups_UIBP.Home_Prompt_Popups_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\232\191\155\229\133\165\229\174\182\229\155\173\229\141\143\232\174\174\231\161\174\232\174\164\229\188\185\231\170\151"
    }
  },
  Home_Visit_Popup_UIBP = {
    keyName = "Home_Visit_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.Lobby.Popup.Home_Visit_Popup_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Popup/Home_Visit_Popup_UIBP.Home_Visit_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\230\139\156\232\174\191\229\188\149\229\175\188\229\188\128\233\128\154"
    }
  },
  Home_Input_Popups_UIBP = {
    keyName = "Home_Input_Popups_UIBP",
    moduleName = "GameLua.Mod.PlanPH.Client.UI.Drawing.Home_Input_Popups_UIBP",
    path = "/Game/UMG/UI_BP/Home/Common/Popup/Small/Home_Input_Popups_UIBP.Home_Input_Popups_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\229\155\190\231\186\184\229\164\167\229\142\133-\233\135\141\229\145\189\229\144\141\232\190\147\229\133\165\229\188\185\231\170\151"
    }
  },
  Home_NewTheme_Update_UIBP = {
    keyName = "Home_NewTheme_Update_UIBP",
    moduleName = "client.slua.umg.Home.AnniversaryActivity.Home_NewTheme_Update_UIBP",
    path = "/Game/UMG/UI_BP/Home/AnniversaryActivity/Home_NewTheme_Update_UIBP.Home_NewTheme_Update_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\229\164\167\229\142\133-\229\174\182\229\155\173\230\150\176\228\184\187\233\162\152-\230\139\141\232\132\184\229\173\144\232\147\157\229\155\190"
    }
  },
  Home_NewTheme_Banner_UIBP = {
    keyName = "Home_NewTheme_Banner_UIBP",
    moduleName = "client.slua.umg.Home.AnniversaryActivity.Home_NewTheme_Banner_UIBP",
    path = "/Game/UMG/UI_BP/Home/AnniversaryActivity/Home_NewTheme_Banner_UIBP.Home_NewTheme_Banner_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\229\164\167\229\142\133-\229\174\182\229\155\173\230\150\176\228\184\187\233\162\152-\230\180\187\229\138\168\229\173\144\231\149\140\233\157\162"
    }
  },
  Home_Collection_AnniversaryReward_UIBP = {
    keyName = "Home_Collection_AnniversaryReward_UIBP",
    moduleName = "client.slua.umg.Home.AnniversaryCollection.Home_Collection_AnniversaryReward_UIBP",
    path = "/Game/UMG/UI_BP/Home/AnniversaryCollection/Home_Collection_AnniversaryReward_UIBP.Home_Collection_AnniversaryReward_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\145\168\229\185\180\229\186\134\230\180\187\229\138\168-\229\165\150\229\138\177\231\149\140\233\157\162"
    }
  },
  Home_Anniversary_Reward_Popup_UIBP = {
    keyName = "Home_Anniversary_Reward_Popup_UIBP",
    moduleName = "client.slua.umg.Home.AnniversaryCollection.popup.Home_Anniversary_Reward_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Home/AnniversaryCollection/popup/Home_Anniversary_Reward_Popup_UIBP.Home_Anniversary_Reward_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\229\145\168\229\185\180\229\186\134\230\180\187\229\138\168-\231\173\137\231\186\167\229\165\150\229\138\177\229\188\185\231\170\151"
    }
  },
  Home_Draw_Reward_Detail_UIBP = {
    keyName = "Home_Draw_Reward_Detail_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.Loot.Home_Draw_Reward_Detail_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/loot/Home_Draw_Reward_Detail_UIBP.Home_Draw_Reward_Detail_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\230\138\189\229\165\150-\229\165\150\229\138\177\232\175\166\230\131\133"
    }
  },
  Home_DoubleOccupancy_Popups_UIBP = {
    keyName = "Home_DoubleOccupancy_Popups_UIBP",
    moduleName = "client.slua.umg.Home.Lobby.Popup.Home_DoubleOccupancy_Popups_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Popup/Home_DoubleOccupancy_Popups_UIBP.Home_DoubleOccupancy_Popups_UIBP",
    uiStat = {
      name = "\228\186\178\229\175\134\229\133\179\231\179\187-\233\130\128\232\175\183\229\144\140\228\189\143"
    }
  },
  Home_DoubleOccupancy_Popups02_UIBP = {
    keyName = "Home_DoubleOccupancy_Popups02_UIBP",
    moduleName = "client.slua.umg.Home.Lobby.Popup.Home_DoubleOccupancy_Popups02_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Popup/Home_DoubleOccupancy_Popups02_UIBP.Home_DoubleOccupancy_Popups02_UIBP",
    uiStat = {
      name = "\228\186\178\229\175\134\229\133\179\231\179\187-\229\144\140\228\189\143\230\136\144\229\138\159"
    },
    isMainUI = false
  },
  Home_DoubleOccupancy_Book_Popups_Small_UIBP = {
    keyName = "Home_DoubleOccupancy_Book_Popups_Small_UIBP",
    moduleName = "client.slua.umg.Home.Lobby.Popup.Home_DoubleOccupancy_Book_Popups_Small_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Popup/Home_DoubleOccupancy_Book_Popups_Small_UIBP.Home_DoubleOccupancy_Book_Popups_Small_UIBP",
    uiStat = {
      name = "\228\186\178\229\175\134\229\133\179\231\179\187-\233\130\128\232\175\183\229\144\140\228\189\143\231\161\174\232\174\164\229\188\185\231\170\151"
    }
  },
  Home_Task_Loot_UIBP = {
    keyName = "Home_Task_Loot_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.Loot.Home_Task_Loot_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/loot/Home_Task_Loot_UIBP.Home_Task_Loot_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\230\138\189\229\165\150"
    }
  },
  Home_Loot_GetRecord_popup_UIBP = {
    keyName = "Home_Loot_GetRecord_popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.Loot.Home_Loot_GetRecord_popup_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/loot/popup/Home_Loot_GetRecord_popup_UIBP.Home_Loot_GetRecord_popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\229\174\182\229\155\173\230\138\189\229\165\150\232\174\176\229\189\149"
    }
  },
  Home_Popup_Cohabit_Invite_UIBP = {
    keyName = "Home_Popup_Cohabit_Invite_UIBP",
    moduleName = "client.slua.umg.Home.Lobby.Popup.Home_Popup_Cohabit_Invite_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Home_Popup_Cohabit_Invite_UIBP.Home_Popup_Cohabit_Invite_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\174\182\229\155\173-\229\143\151\233\130\128\231\187\132\230\136\144\229\144\140\228\189\143\229\174\182\229\155\173"
    }
  },
  Home_ShareFriends_Popup_UIBP = {
    keyName = "Home_ShareFriends_Popup_UIBP",
    moduleName = "client.slua.umg.common.share.Home_ShareFriends_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/ShareFriends_Popup_UIBP.ShareFriends_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\229\174\182\229\155\173\232\175\166\230\131\133\229\136\134\228\186\171\229\188\185\231\170\151"
    }
  },
  HomePK_Style_ShareFriends_Popup_UIBP = {
    keyName = "HomePK_Style_ShareFriends_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.PK.HomePK_Style_ShareFriends_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/ShareFriends_Popup_UIBP.ShareFriends_Popup_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\229\174\182\229\155\173\233\163\142\230\160\188\232\175\132\233\128\137\229\136\134\228\186\171\229\188\185\231\170\151"
    }
  },
  Lobby_Home_Door_Entrance_UIBP = {
    keyName = "Lobby_Home_Door_Entrance_UIBP",
    moduleName = "client.slua.umg.lobby.Left.Lobby_Home_Door_Entrance_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Lobby_Home_Door_Entrance_UIBP.Lobby_Home_Door_Entrance_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173-\233\151\168\231\137\140"
    }
  },
  Lobby_Home_Door_Entrance_BG_UIBP = {
    keyName = "Lobby_Home_Door_Entrance_BG_UIBP",
    moduleName = "client.slua.umg.lobby.Left.Lobby_Home_Door_Entrance_BG_UIBP",
    path = "/Game/UMG/UI_BP/Home/Lobby/Item/Lobby_Home_Door_Entrance_BG_Item_01_UIBP.Lobby_Home_Door_Entrance_BG_Item_01_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\174\182\229\155\173-\233\151\168\231\137\140\232\131\140\230\153\175"
    }
  },
  Lobby_Home_Party_Entrance_UIBP = {
    keyName = "Lobby_Home_Party_Entrance_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.Lobby.Lobby_Home_Party_Entrance_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Lobby_Home_Party_Entrance_UIBP.Lobby_Home_Party_Entrance_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\229\183\166\228\190\167\231\164\190\228\186\164\231\149\140\233\157\162-\229\174\182\229\155\173\230\180\190\229\175\185\229\188\128\229\144\175\229\128\146\232\174\161\230\151\182\230\143\144\231\164\186"
    }
  },
  Lobby_Home_ParkingLot_UIBP = {
    keyName = "Lobby_Home_ParkingLot_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.Lobby.Lobby_Home_ParkingLot_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Lobby_Home_ParkingLot_UIBP.Lobby_Home_ParkingLot_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\164\167\229\142\133-\229\183\166\228\190\167\231\164\190\228\186\164\231\149\140\233\157\162-\229\174\182\229\155\173\229\129\156\232\189\166\229\156\186\229\133\165\229\143\163\230\143\144\231\164\186"
    }
  },
  Lobby_Home_Friend_UIBP = {
    keyName = "Lobby_Home_Friend_UIBP",
    moduleName = "client.slua.umg.Home.Lobby.Lobby_Home_Friend_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Lobby_Home_Friend_UIBP.Lobby_Home_Friend_UIBP",
    jumpModuleID = BP_ENUM_MODULE_PLANPH_HOME_FRIEND,
    uiStat = {
      name = "\229\174\182\229\155\173-\229\136\151\232\161\168\230\181\143\232\167\136\229\188\185\231\170\151"
    }
  },
  Lobby_Home_Entrance_Item_UIBP = {
    keyName = "Lobby_Home_Entrance_Item_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.Lobby_Home_Entrance_Item_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Mid/Item/Lobby_Home_Item_UIBP.Lobby_Home_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\184\187\231\149\140\233\157\162\229\164\167\229\142\133\229\174\182\229\155\173\229\133\165\229\143\163"
    }
  },
  Lobby_Home_Details_UIBP = {
    keyName = "Lobby_Home_Details_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.Lobby.Lobby_Home_Details_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Lobby_Home_Details_UIBP.Lobby_Home_Details_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\228\184\187\231\149\140\233\157\162\229\164\167\229\142\133\229\133\165\229\143\163\232\175\166\230\131\133\233\161\181"
    }
  },
  Lobby_Home_Main_UIBP = {
    keyName = "Lobby_Home_Main_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.Lobby.Lobby_Home_Main_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Lobby_Home_Main_UIBP.Lobby_Home_Main_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    jumpModuleID = BP_ENUM_MODULE_HOME_LOBBY_ENTRY,
    asy = true,
    uiStat = {
      name = "\229\164\167\229\142\133\229\174\182\229\155\173\228\184\187\231\149\140\233\157\162"
    }
  },
  Lobby_Home_Details_New_UIBP = {
    keyName = "Lobby_Home_Details_New_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Home.Lobby.Lobby_Home_Details_New_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Lobby_Home_Details_New_UIBP.Lobby_Home_Details_New_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\174\128\229\140\150\231\137\136\229\174\182\229\155\173\232\175\166\230\131\133\233\161\181"
    }
  },
  Lobby_Home_Door_Entrance_Anniversary_Item_UIBP = {
    keyName = "Lobby_Home_Door_Entrance_Anniversary_Item_UIBP",
    moduleName = "client.slua.umg.Home.Lobby.Item.Lobby_Home_Door_Entrance_Anniversary_Item_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Item/Lobby_Home_Door_Entrance_Anniversary_Item_UIBP.Lobby_Home_Door_Entrance_Anniversary_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\174\182\229\155\173\228\184\128\229\145\168\229\185\180\230\180\187\229\138\168-\231\164\190\228\186\164\229\164\167\229\142\133\230\180\187\229\138\168\229\133\165\229\143\163"
    }
  },
  Lobby_Home_AnniversaryActivity_UIBP = {
    keyName = "Lobby_Home_AnniversaryActivity_UIBP",
    moduleName = "client.slua.umg.Lobby_Home_AnniversaryActivity_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Lobby_Home_AnniversaryActivity_UIBP.Lobby_Home_AnniversaryActivity_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\229\164\167\229\142\133-\229\174\182\229\155\173\230\150\176\228\184\187\233\162\152-\228\184\170\228\186\186\231\169\186\233\151\180\229\133\165\229\143\163"
    }
  },
  Common_Home_Details_Lobby_UIBP = {
    keyName = "Common_Home_Details_Lobby_UIBP",
    moduleName = "client.slua.umg.Home.Detail.Common_Home_Details_Lobby_UIBP",
    path = "/Game/UMG/UI_BP/Home/Detail/Common_Home_Details_UIBP.Common_Home_Details_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\174\182\229\155\173-\232\175\166\230\131\133\231\149\140\233\157\162-\229\164\167\229\142\133"
    }
  },
  Common_Home_Details_InGame_UIBP = {
    keyName = "Common_Home_Details_InGame_UIBP",
    moduleName = "client.slua.umg.Home.Detail.Common_Home_Details_InGame_UIBP",
    path = "/Game/UMG/UI_BP/Home/Detail/Common_Home_Details_UIBP.Common_Home_Details_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\232\175\166\230\131\133\231\149\140\233\157\162-\229\177\128\229\134\133"
    }
  },
  Common_Home_Feature_Item_Large_UIBP = {
    keyName = "Common_Home_Feature_Item_Large_UIBP",
    moduleName = "client.slua.umg.Home.Detail.Item.Common_Home_Feature_Item_Large_UIBP",
    path = "/Game/UMG/UI_BP/Home/Detail/Item/Common_Home_Feature_Item_Large_UIBP.Common_Home_Feature_Item_Large_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\231\142\169\230\179\149 - \230\136\145\231\154\132\229\174\182\229\155\173\231\149\140\233\157\162 - \229\138\159\232\131\189Item1"
    },
    isSingleton = false
  },
  Common_Home_Feature_Item_UIBP = {
    keyName = "Common_Home_Feature_Item_UIBP",
    moduleName = "client.slua.umg.Home.Detail.Item.Common_Home_Feature_Item_UIBP",
    path = "/Game/UMG/UI_BP/Home/Detail/Item/Common_Home_Feature_Item_UIBP.Common_Home_Feature_Item_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\231\142\169\230\179\149 - \230\136\145\231\154\132\229\174\182\229\155\173\231\149\140\233\157\162 - \229\138\159\232\131\189Item2"
    },
    isSingleton = false
  },
  Common_Home_Modify_Item_UIBP = {
    keyName = "Common_Home_Modify_Item_UIBP",
    moduleName = "client.slua.umg.Home.Detail.Item.Common_Home_Modify_Item_UIBP",
    path = "/Game/UMG/UI_BP/Home/Detail/Item/Common_Home_Modify_Item_UIBP.Common_Home_Modify_Item_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\232\175\166\230\131\133\231\149\140\233\157\162-Item-\228\191\174\230\148\185\231\187\132\228\187\182"
    },
    isSingleton = false
  },
  Common_Home_Party_Item_UIBP = {
    keyName = "Common_Home_Party_Item_UIBP",
    moduleName = "client.slua.umg.Home.Detail.Item.Common_Home_Party_Item_UIBP",
    path = "/Game/UMG/UI_BP/Home/Detail/Item/Common_Home_Party_Item_UIBP.Common_Home_Party_Item_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\233\128\154\231\148\168\230\180\190\229\175\185\230\152\190\231\164\186\231\187\132\228\187\182"
    }
  },
  Common_Info_Home_Large_Item = {
    keyName = "Common_Info_Home_Large_Item",
    moduleName = "client.slua.umg.common.Info.Common_Info_Home_Large_Item",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_Home_Large_Item.Common_Info_Home_Large_Item",
    uiStat = {
      name = "\228\184\170\228\186\186\228\191\161\230\129\175 - \232\135\170\229\174\154\228\185\137\231\164\190\228\186\164\229\144\141\231\137\135 - \229\174\182\229\155\173 - \229\164\167"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool
  },
  Common_Info_Home_Large_Item_V_UIBP = {
    keyName = "Common_Info_Home_Large_Item_V_UIBP",
    moduleName = "client.slua.umg.common.Info.Common_Info_Home_Large_Item_V_UIBP",
    path = "/Game/UMG/UI_BP/Common/Info/Common_Info_Home_Large_Item_V_UIBP.Common_Info_Home_Large_Item_V_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\229\144\141\231\137\135-\231\164\190\228\186\164\229\144\141\231\137\135-\231\171\150\229\144\145\229\174\182\229\155\173\231\149\140\233\157\162-\229\164\167"
    },
    loadFromPool = EUIConfigPoolType.other_pool
  },
  Common_Popup_Theme_Home_UIBP = {
    keyName = "Common_Popup_Theme_Home_UIBP",
    moduleName = "client.slua.umg.Common.Common_Popup_Reward_Base",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Home_UIBP.Common_Popup_Theme_Home_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\229\174\182\229\155\173-\229\165\150\229\138\177\229\177\149\231\164\186\229\188\185\231\170\151"
    }
  },
  HomeActivity_Style_C_UIBP = {
    keyName = "HomeActivity_Style_C_UIBP",
    moduleName = "client.slua.umg.Home.Elegant_Ancient_Capital.HomeActivity_Style_UIBP",
    path = "/Game/UMG/UI_BP/Home/Activity/HomeActivity_Style_C_UIBP.HomeActivity_Style_C_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142\230\180\187\229\138\168\228\184\128\230\156\159\229\174\164\229\164\150\231\149\140\233\157\162"
    }
  },
  Home_Collection_AnniversaryActivity_UIBP = {
    keyName = "Home_Collection_AnniversaryActivity_UIBP",
    moduleName = "client.slua.umg.Home.AnniversaryCollection.Home_Collection_AnniversaryActivity_UIBP",
    path = "/Game/UMG/UI_BP/Home/AnniversaryCollection/Home_Collection_AnniversaryActivity_UIBP.Home_Collection_AnniversaryActivity_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\145\168\229\185\180\229\186\134\230\180\187\229\138\168-\229\173\144\230\180\187\229\138\168\231\149\140\233\157\162"
    }
  },
  Shareinterface_Home_UIBP = {
    keyName = "Shareinterface_Home_UIBP",
    moduleName = "client.slua.umg.Lobby.Shareinterface_Home_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/Shareinterface_Home_UIBP.Shareinterface_Home_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\230\180\190\229\175\185\229\155\158\229\191\134\229\136\134\228\186\171-\230\172\161\231\186\167\231\149\140\233\157\162"
    }
  },
  ReputationSystem_Homepage_UIBP = {
    keyName = "ReputationSystem_Homepage_UIBP",
    moduleName = "client.slua.umg.ReputationSystem.ReputationSystem_Homepage_UIBP",
    path = "/Game/UMG/UI_BP/ReputationSystem/ReputationSystem_Homepage_UIBP.ReputationSystem_Homepage_UIBP",
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\228\191\161\232\170\137\231\179\187\231\187\159"
    },
    isMainUI = false,
    asy = true
  },
  Photo_Share_UIBP = {
    keyName = "Photo_Share_UIBP",
    moduleName = "client.slua.umg.Home.Photo.Photo_Share_UIBP",
    path = "/Game/UMG/UI_BP/Home/Photo/Photo_Share_UIBP.Photo_Share_UIBP",
    jumpModuleID = BP_ENUM_MODULE_PLANPH_PHOTO_CONFIRM,
    uiStat = {
      name = "\229\174\182\229\155\173\231\155\184\229\134\140-\231\133\167\231\137\135\229\136\134\228\186\171\231\161\174\232\174\164\231\149\140\233\157\162"
    }
  },
  Photo_Album_UIBP = {
    keyName = "Photo_Album_UIBP",
    moduleName = "client.slua.umg.Home.Photo.Photo_Album_UIBP",
    path = "/Game/UMG/UI_BP/Home/Photo/Photo_Album_UIBP.Photo_Album_UIBP",
    jumpModuleID = BP_ENUM_MODULE_PLANPH_ALBUM,
    asy = true,
    uiStat = {
      name = "\229\174\182\229\155\173\231\155\184\229\134\140\231\149\140\233\157\162"
    }
  },
  Photo_Share_02_UIBP = {
    keyName = "Photo_Share_02_UIBP",
    moduleName = "client.slua.umg.Home.Photo.Photo_Share_02_UIBP",
    path = "/Game/UMG/UI_BP/Home/Photo/Photo_Share_02_UIBP.Photo_Share_02_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\231\155\184\229\134\140-\233\128\154\231\148\168\229\136\134\228\186\171\230\140\130\232\189\189\231\149\140\233\157\162"
    }
  },
  Home_GoldenTree_Tips_UIBP = {
    keyName = "Home_GoldenTree_Tips_UIBP",
    moduleName = "client.slua.umg.Home.GoldenTree.Home_GoldenTree_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Home/Detail/Home_GoldenTree_Tips_UIBP.Home_GoldenTree_Tips_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\230\160\145-\228\191\161\230\129\175\230\143\144\231\164\186tips"
    }
  },
  Home_Prompt_Popup_UIBP = {
    keyName = "Home_Prompt_Popup_UIBP",
    moduleName = "client.slua.umg.Home.Rule.Home_Prompt_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Home/Rule/Home_Prompt_Popup_UIBP.Home_Prompt_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173-\231\149\153\232\168\128\232\167\132\229\136\153\232\175\180\230\152\142\229\188\185\231\170\151"
    }
  },
  Party_Share_UIBP = {
    keyName = "Party_Share_UIBP",
    moduleName = "client.slua.umg.Home.Party.Party_Share_UIBP",
    path = "/Game/UMG/UI_BP/Home/Party/Party_Share_UIBP.Party_Share_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\229\174\182\229\155\173-\230\180\190\229\175\185-\228\186\140\231\187\180\231\160\129\229\136\134\228\186\171\229\174\182\229\155\173"
    }
  },
  Home_Collection_AnniversaryMain_UIBP = {
    keyName = "Home_Collection_AnniversaryMain_UIBP",
    moduleName = "client.slua.umg.Home.AnniversaryCollection.Home_Collection_AnniversaryMain_UIBP",
    path = "/Game/UMG/UI_BP/Home/AnniversaryCollection/Home_Collection_AnniversaryMain_UIBP.Home_Collection_AnniversaryMain_UIBP",
    jumpModuleID = BP_ENUM_MODULE_HOME_ANNIVERSARY_MAIN,
    uiStat = {
      name = "\229\174\182\229\155\173\229\145\168\229\185\180\229\186\134\230\180\187\229\138\168-\228\184\187\231\149\140\233\157\162"
    }
  },
  Home_Collection_AnniversaryNew_UIBP = {
    keyName = "Home_Collection_AnniversaryNew_UIBP",
    moduleName = "client.slua.umg.Home.AnniversaryCollection.Home_Collection_AnniversaryNew_UIBP",
    path = "/Game/UMG/UI_BP/Home/AnniversaryCollection/Home_Collection_AnniversaryNew_UIBP.Home_Collection_AnniversaryNew_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\145\168\229\185\180\229\186\134\230\180\187\229\138\168-\231\178\190\229\189\169\228\184\138\230\150\176\231\149\140\233\157\162"
    }
  },
  Home_Collection_Anniversary_Popup_UIBP = {
    keyName = "Home_Collection_Anniversary_Popup_UIBP",
    moduleName = "client.slua.umg.Home.AnniversaryCollection.popup.Home_Collection_Anniversary_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Home/AnniversaryCollection/popup/Home_Collection_Anniversary_Popup_UIBP.Home_Collection_Anniversary_Popup_UIBP",
    jumpModuleID = BP_ENUM_MODULE_HOME_ANNIVERSARY_SLAP,
    uiStat = {
      name = "\229\174\182\229\155\173\229\145\168\229\185\180\229\186\134\230\180\187\229\138\168-\230\180\187\229\138\168\230\139\141\232\132\184"
    }
  },
  Home_Download_Store_Popup_UIBP = {
    keyName = "Home_Download_Store_Popup_UIBP",
    moduleName = "client.slua.umg.Home.Download.Popups.Home_Download_Store_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Home/Download/Popups/Home_Download_Store_Popup_UIBP.Home_Download_Store_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142/\229\174\182\229\155\173\228\184\187\231\149\140\233\157\162+\229\174\182\229\155\173\228\184\139\232\189\189\231\149\140\233\157\162"
    },
    isMainUI = true,
    isSingleton = true
  },
  Home_Download_Entrance_Popup_UIBP = {
    keyName = "Home_Download_Entrance_Popup_UIBP",
    moduleName = "client.slua.umg.Home.Download.Popups.Home_Download_Entrance_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Home/Download/Popups/Home_Download_Entrance_Popup_UIBP.Home_Download_Entrance_Popup_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\228\184\139\232\189\189\231\149\140\233\157\162"
    },
    isMainUI = true,
    isSingleton = true
  },
  Lobby_Home_Download_Reward_UIBP = {
    keyName = "Lobby_Home_Download_Reward_UIBP",
    moduleName = "client.slua.umg.Lobby_Home_Download_Reward_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Item/Lobby_Home_Download_Reward_UIBP.Lobby_Home_Download_Reward_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173\233\128\154\231\148\168\228\184\139\232\189\189\229\165\150\229\138\177\231\149\140\233\157\162"
    },
    isMainUI = false,
    isSingleton = false
  },
  Lobby_Home_PK_UIBP = {
    keyName = "Lobby_Home_PK_UIBP",
    moduleName = "client.slua.umg.Lobby_Home_PK_UIBP",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Lobby_Home_PK_UIBP.Lobby_Home_PK_UIBP",
    uiStat = {
      name = "\229\174\182\229\155\173PK, tips\231\149\140\233\157\162"
    },
    isMainUI = false,
    isSingleton = false
  },
  Lobby_Home_Entrance_Tips_Item = {
    keyName = "Lobby_Home_Entrance_Tips_Item",
    moduleName = "client.slua.umg.Lobby_Home_Entrance_Tips_Item",
    path = "/Game/Mod/Lobby/Base/Home/Lobby/Item/Lobby_Home_Entrance_Tips_Item.Lobby_Home_Entrance_Tips_Item",
    uiStat = {
      name = "\229\174\182\229\155\173\233\128\154\231\148\168Tips\231\149\140\233\157\162"
    },
    isMainUI = false,
    isSingleton = false
  }
}
return home_ui_configs