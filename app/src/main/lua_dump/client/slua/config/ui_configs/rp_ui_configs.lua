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
local rp_ui_configs = {
  BlackFriday_Pass_ExtraAward_Use_UIBP = {
    keyName = "BlackFriday_Pass_ExtraAward_Use_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Pass.BlackFriday_Pass_ExtraAward_Use_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Pass/BlackFriday_ExtraAward_Use_UIBP.BlackFriday_ExtraAward_Use_UIBP",
    asy = true,
    uiStat = {
      name = "\233\187\145\228\186\148-\230\138\189\229\165\150\233\128\154\232\161\140\232\175\129-\233\162\157\229\164\150\229\165\150\229\138\177\228\189\191\231\148\168\229\188\185\231\170\151"
    }
  },
  BlackFriday_Pass_LotteryRoll_UIBP = {
    keyName = "BlackFriday_Pass_LotteryRoll_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Pass.BlackFriday_Pass_LotteryRoll_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Pass/BlackFriday_Pass_LotteryRoll_UIBP.BlackFriday_Pass_LotteryRoll_UIBP",
    asy = true,
    uiStat = {
      name = "\233\187\145\228\186\148-\230\138\189\229\165\150\233\128\154\232\161\140\232\175\129-\230\145\135\229\165\150"
    }
  },
  BlackFriday_Pass_Probability_UIBP = {
    keyName = "BlackFriday_Pass_Probability_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Pass.BlackFriday_Pass_Probability_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Pass/BlackFriday_Pass_Probability_UIBP.BlackFriday_Pass_Probability_UIBP",
    asy = true,
    uiStat = {
      name = "\233\187\145\228\186\148-\230\138\189\229\165\150\233\128\154\232\161\140\232\175\129-\230\151\165\233\159\169\230\166\130\231\142\135\229\188\185\231\170\151"
    }
  },
  BlackFriday_Pass_SelectReward_UIBP = {
    keyName = "BlackFriday_Pass_SelectReward_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Pass.BlackFriday_Pass_SelectReward_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Pass/BlackFriday_Pass_SelectReward_UIBP.BlackFriday_Pass_SelectReward_UIBP",
    isMainUI = false,
    showVisibility = Collapsed,
    uiStat = {
      name = "\233\187\145\228\186\148-\230\138\189\229\165\150\233\128\154\232\161\140\232\175\129-\229\164\167\229\165\150\230\138\189\229\165\150\229\138\168\230\149\136"
    }
  },
  BlackFriday_Pass_UIBP = {
    keyName = "BlackFriday_Pass_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.BlackFriday.UMG.Pass.BlackFriday_Pass_UIBP",
    path = "/Game/Mod/Lobby/Split/BlackFriday/Pass/BlackFriday_Pass_UIBP.BlackFriday_Pass_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\233\187\145\228\186\148-\230\138\189\229\165\150\233\128\154\232\161\140\232\175\129-\228\184\187UI"
    }
  },
  BoxLottery_BanSelectItem = {
    keyName = "BoxLottery_BanSelectItem",
    moduleName = "client.slua.umg.unknow_pass.140_back_box.BoxLottery_BanSelectItem",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Exchange/BoxLotteryItem/BoxLottery_BanSelectItem.BoxLottery_BanSelectItem",
    isSingleton = true,
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\232\191\148\229\156\186\229\174\157\231\174\177ban\233\128\137\230\156\186\229\136\182\230\140\130\232\189\189item"
    }
  },
  BoxLottery_Line_Item = {
    keyName = "BoxLottery_Line_Item",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Exchange/BoxLotteryItem/BoxLottery_Line_Item.BoxLottery_Line_Item",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\232\191\148\229\156\186\229\174\157\231\174\177\230\156\186\229\136\182\229\136\134\229\137\178\231\186\191"
    }
  },
  BoxLottery_MustItem = {
    keyName = "BoxLottery_MustItem",
    moduleName = "client.slua.umg.unknow_pass.140_back_box.BoxLottery_MustItem",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Exchange/BoxLotteryItem/BoxLottery_MustItem.BoxLottery_MustItem",
    isSingleton = true,
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\232\191\148\229\156\186\229\174\157\231\174\177\229\191\133\229\190\151\230\156\186\229\136\182\230\140\130\232\189\189item"
    }
  },
  BoxLottery_PrizeDrawItem = {
    keyName = "BoxLottery_PrizeDrawItem",
    moduleName = "client.slua.umg.unknow_pass.140_back_box.BoxLottery_PrizeDrawItem",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Exchange/BoxLotteryItem/BoxLottery_PrizeDrawItem.BoxLottery_PrizeDrawItem",
    isSingleton = true,
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\232\191\148\229\156\186\229\174\157\231\174\177\233\154\143\230\156\186\230\156\186\229\136\182\230\140\130\232\189\189item"
    }
  },
  BoxLottery_RateUpItem = {
    keyName = "BoxLottery_RateUpItem",
    moduleName = "client.slua.umg.unknow_pass.140_back_box.BoxLottery_RateUpItem",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Exchange/BoxLotteryItem/BoxLottery_RateUpItem.BoxLottery_RateUpItem",
    isSingleton = true,
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\232\191\148\229\156\186\229\174\157\231\174\177\230\166\130\231\142\135up\230\156\186\229\136\182\230\140\130\232\189\189item"
    }
  },
  BoxLottery_SelfSelectItem = {
    keyName = "BoxLottery_SelfSelectItem",
    moduleName = "client.slua.umg.unknow_pass.RPEncoreBox.BoxLottery_SelfSelectItem",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Exchange/BoxLotteryItem/BoxLottery_SelfSelectItem.BoxLottery_SelfSelectItem",
    isSingleton = true,
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\232\135\170\233\128\137\229\174\157\231\174\177\232\135\170\233\128\137\230\140\130\232\189\189item"
    }
  },
  BranchRP_Task_UIBP = {
    keyName = "BranchRP_Task_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Mission.BranchRP_Task_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/BonusPass/BranchRP_Task_UIBP.BranchRP_Task_UIBP",
    uiStat = {
      name = "RP\233\128\154\232\161\140\232\175\129\229\136\134\230\148\175\226\128\148\226\128\148\228\187\187\229\138\161\231\149\140\233\157\162\231\149\140\233\157\162"
    }
  },
  Lobby_UnknowPass_UIBP_1_0_0 = {
    keyName = "Lobby_UnknowPass_UIBP_1_0_0",
    moduleName = "client.slua.umg.UnknowPass.Lobby_UnknowPass_UIBP_1_0_0",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Lobby_UnknowPass_UIBP.Lobby_UnknowPass_UIBP",
    asy = true,
    jumpModuleID = BP_ENUM_MODULE_UNKNOW_PASS,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\233\161\181\231\173\190"
    },
    useBatchOptimization = true
  },
  UPassIntroduceUIBP = {
    keyName = "UPassIntroduceUIBP",
    moduleName = "client.slua.umg.UnknowPass.UPassIntroduceUIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UPassIntroduceUIBP.UPassIntroduceUIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\229\188\128\229\156\186\229\138\168\231\148\187"
    },
    asy = true
  },
  UnKnowPass_2Choose1_Item_UIBP = {
    keyName = "UnKnowPass_2Choose1_Item_UIBP",
    moduleName = "client.slua.umg.unknow_pass.award.UnKnowPass_2Choose1_Item_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnKnowPass_2Choose1_Item_UIBP.UnKnowPass_2Choose1_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "BonusPass\232\180\173\228\185\176\231\167\175\229\136\134\231\149\140\233\157\162\229\165\150\229\138\177\228\186\140\233\128\137\228\184\128item"
    }
  },
  UnKnowPass_BuyScoreRwardItem_UIBP = {
    keyName = "UnKnowPass_BuyScoreRwardItem_UIBP",
    moduleName = "client.slua.umg.unknow_pass.award.UnKnowPass_BuyScoreRwardItem_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnKnowPass_BuyScoreRwardItem_UIBP.UnKnowPass_BuyScoreRwardItem_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "BonusPass\232\180\173\228\185\176\231\167\175\229\136\134\231\149\140\233\157\162\229\165\150\229\138\177item"
    }
  },
  UnKnowPass_IN_H5_BuyShow_UIBP = {
    keyName = "UnKnowPass_IN_H5_BuyShow_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Presale.UnKnowPass_IN_H5_BuyShow_UIBP",
    path = "",
    isMainUI = false,
    uiStat = {
      name = "RP\233\162\132\232\180\173\230\180\187\229\138\168-\232\180\173\228\185\176\230\152\190\231\164\186"
    }
  },
  UnKnowPass_IN_H5_UIBP = {
    keyName = "UnKnowPass_IN_H5_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Presale.UnKnowPass_IN_H5_UIBP",
    path = "",
    uiStat = {
      name = "RP\233\162\132\232\180\173\230\180\187\229\138\168"
    }
  },
  UnKnowPass_PerSale_IN_ChooseBuy_Popup_UIBP = {
    keyName = "UnKnowPass_PerSale_IN_ChooseBuy_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Presale.UnKnowPass_PerSale_IN_ChooseBuy_Popup_UIBP",
    path = "/Game/UMG/UI_BP/UnknowPass/Popup/UnKnowPass_PerSale_IN_ChooseBuy_Popup_UIBP.UnKnowPass_PerSale_IN_ChooseBuy_Popup_UIBP",
    isMainUI = true,
    uiStat = {
      name = "RP\233\162\132\232\180\173\230\180\187\229\138\168-\232\180\173\228\185\176\230\152\190\231\164\186"
    }
  },
  UnKnowPass_Special2Choose1_Item_UIBP = {
    keyName = "UnKnowPass_Special2Choose1_Item_UIBP",
    moduleName = "client.slua.umg.unknow_pass.award.UnKnowPass_Special2Choose1_Item_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnKnowPass_Special2Choose1_Item_UIBP.UnKnowPass_Special2Choose1_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "BonusPass\230\160\184\229\191\131\233\162\132\232\167\136Item"
    }
  },
  UnknowPass_ActivePackGet_UIBP = {
    keyName = "UnknowPass_ActivePackGet_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_ActivePackGet_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/ActivePack/UnknowPass_ActivePackGet_UIBP.UnknowPass_ActivePackGet_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\231\167\175\229\136\134\230\180\187\232\183\131\231\164\188\229\140\133\232\191\148\229\136\169\230\143\144\233\134\146\231\149\140\233\157\162"
    },
    asy = true
  },
  UnknowPass_ActivePackSlap_UIBP = {
    keyName = "UnknowPass_ActivePackSlap_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_ActivePackSlap_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/ActivePack/UnknowPass_ActivePackSlap_UIBP.UnknowPass_ActivePackSlap_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\231\167\175\229\136\134\230\180\187\232\183\131\231\164\188\229\140\133\230\139\141\232\132\184\229\155\190"
    },
    containerName = UIContainers.Top,
    asy = true
  },
  UnknowPass_ActivePack_Item_UIBP = {
    keyName = "UnknowPass_ActivePack_Item_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Item.UnknowPass_ActivePack_Item_UIBP",
    path = "/Game/UMG/UI_BP/Common/Items/UnknowPass_ActivePack_Item_UIBP.UnknowPass_ActivePack_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "RP-\231\167\175\229\136\134\230\180\187\232\183\131\231\164\188\229\140\133\229\133\165\229\143\163"
    }
  },
  UnknowPass_ActivePack_StrongGuide_UIBP = {
    keyName = "UnknowPass_ActivePack_StrongGuide_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_ActivePack_StrongGuide_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/ActivePack/UnknowPass_ActivityPopup_UIBP.UnknowPass_ActivityPopup_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129\231\164\188\229\140\133-\229\188\186\229\188\149\229\175\188\231\149\140\233\157\162"
    },
    asy = true
  },
  UnknowPass_ActivePack_UIBP = {
    keyName = "UnknowPass_ActivePack_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_ActivePack_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/ActivePack/UnknowPass_ActivePack_UIBP.UnknowPass_ActivePack_UIBP",
    jumpModuleID = BP_ENUM_MODULE_RP_GIFT,
    uiStat = {
      name = "RP-\231\167\175\229\136\134\230\180\187\232\183\131\231\164\188\229\140\133\228\184\187\231\149\140\233\157\162"
    },
    asy = true
  },
  UnknowPass_ActivePack_UIBP_GUIDE = {
    keyName = "UnknowPass_ActivePack_UIBP_GUIDE",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_ActivePack_UIBP_GUIDE",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/ActivePack/UnknowPass_ActivePackGuide_UIBP.UnknowPass_ActivePackGuide_UIBP",
    uiStat = {
      name = "RP-\231\167\175\229\136\134\230\180\187\232\183\131\231\164\188\229\140\133\228\184\187\231\149\140\233\157\162\230\150\176\230\137\139\229\188\149\229\175\188"
    },
    asy = true
  },
  UnknowPass_ActivePack_UnlockPopup_UIBP = {
    keyName = "UnknowPass_ActivePack_UnlockPopup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_ActivePack_UnlockPopup_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/ActivePack/UnknowPass_ActivePack_UnlockPopup_UIBP.UnknowPass_ActivePack_UnlockPopup_UIBP",
    uiStat = {
      name = "RP-\231\167\175\229\136\134\230\180\187\232\183\131\232\167\163\233\148\129\230\143\144\231\164\186\229\155\190"
    },
    asy = true
  },
  UnknowPass_Award_Branch_BP = {
    keyName = "UnknowPass_Award_Branch_BP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_Award_Branch_BP",
    path = "",
    AndroidBackType = EAndroidBackType.Skip,
    containerName = UIContainers.Bottom,
    uiStat = {
      name = "RP\233\128\154\232\161\140\232\175\129\229\136\134\230\148\175\226\128\148\226\128\148\229\165\150\229\138\177\231\149\140\233\157\162"
    },
    asy = true
  },
  UnknowPass_Award_New_Popup_UIBP = {
    keyName = "UnknowPass_Award_New_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Popup.UnknowPass_Award_New_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Popup/UnknowPass_Award_New_Popup_UIBP.UnknowPass_Award_New_Popup_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\231\178\190\231\187\134\229\140\150\228\187\187\229\138\161"
    }
  },
  UnknowPass_BP_ColorSuitUnlock_Popup_UIBP = {
    keyName = "UnknowPass_BP_ColorSuitUnlock_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Popup.UnknowPass_BP_ColorSuitUnlock_Popup_UIBP",
    path = "/Game/UMG/UI_BP/ColorShapePopup/UnknowPass_BP_ColorSuitUnlock_Popup_UIBP.UnknowPass_BP_ColorSuitUnlock_Popup_UIBP",
    uiStat = {
      name = "RP\233\128\154\232\161\140\232\175\129\229\136\134\230\148\175\226\128\148\233\128\137\230\139\169\229\188\130\232\137\178\229\165\151\232\163\133\232\167\163\233\148\129\229\188\185\231\170\151"
    }
  },
  UnknowPass_BP_DoubleColorSuit_Popup_UIBP = {
    keyName = "UnknowPass_BP_DoubleColorSuit_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Popup.UnknowPass_BP_DoubleColorSuit_Popup_UIBP",
    path = "/Game/UMG/UI_BP/ColorShapePopup/UnknowPass_BP_DoubleColorSuit_Popup_UIBP.UnknowPass_BP_DoubleColorSuit_Popup_UIBP",
    uiStat = {
      name = "RP\233\128\154\232\161\140\232\175\129\229\136\134\230\148\175BP\226\128\148\229\188\130\232\137\178\229\165\151\232\163\133\232\167\163\233\148\129\233\129\147\229\133\183\231\154\132\229\189\147\229\137\141\229\143\175\232\167\163\233\148\129\229\188\185\231\170\151"
    }
  },
  UnknowPass_BranchRP_NewGuide_ForcedClick_UIBP = {
    keyName = "UnknowPass_BranchRP_NewGuide_ForcedClick_UIBP",
    moduleName = "client.slua.umg.UnknowPass.RP_Newbie.UnknowPass_BranchRP_NewGuide_ForcedClick_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Newbie/UnknowPass_BranchRP_NewGuide_ForcedClick_UIBP.UnknowPass_BranchRP_NewGuide_ForcedClick_UIBP",
    uiStat = {
      name = "BonusPass\230\150\176\230\137\139\229\188\149\229\175\188"
    }
  },
  UnknowPass_BranchRP_RewardsPreview_UIBP = {
    keyName = "UnknowPass_BranchRP_RewardsPreview_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_BranchRP_RewardsPreview_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/BonusPass/UnknowPass_BranchRP_RewardsPreview_UIBP.UnknowPass_BranchRP_RewardsPreview_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UNKNOW_PASS_REWARD_PREVIEW,
    uiStat = {
      name = "BonusPass\230\160\184\229\191\131\233\162\132\232\167\136"
    },
    asy = true
  },
  UnknowPass_Branch_Theme_PushBuy_Popup_UIBP = {
    keyName = "UnknowPass_Branch_Theme_PushBuy_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Popup.UnknowPass_Branch_Theme_PushBuy_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Popup/UnknowPass_Branch_Theme_PushBuy_Popup_UIBP.UnknowPass_Branch_Theme_PushBuy_Popup_UIBP",
    uiStat = {
      name = "RP\233\128\154\232\161\140\232\175\129\229\136\134\230\148\175\226\128\148\226\128\148\231\173\137\231\186\167\230\142\168\233\128\129\229\188\185\231\170\151"
    }
  },
  UnknowPass_ButtonPrompt_UIBP = {
    keyName = "UnknowPass_ButtonPrompt_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Item.UnknowPass_ButtonPrompt_UIBP",
    path = "/Game/UMG/UI_BP/Common/Items/UnknowPass_ButtonPrompt_UIBP.UnknowPass_ButtonPrompt_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "\229\136\134\228\186\171-\233\128\154\232\161\140\232\175\129"
    }
  },
  UnknowPass_Buy_1to100_UIBP = {
    keyName = "UnknowPass_Buy_1to100_UIBP",
    moduleName = "client.slua.umg.unknow_pass.buy.UnknowPass_Buy_1to100_UIBP",
    path = "/Game/Arts_UI/UnknowPass/4_0_0/RP_Buy/UnknowPass_Buy_1to100_UIBP.UnknowPass_Buy_1to100_UIBP",
    asy = true,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\232\180\173\228\185\176-1-100\231\186\167"
    }
  },
  UnknowPass_Buy_1to100_Item_UIBP = {
    keyName = "UnknowPass_Buy_1to100_Item_UIBP",
    moduleName = "client.slua.umg.unknow_pass.buy.UnknowPass_Buy_1to100_Item_UIBP",
    path = "/Game/Arts_UI/UnknowPass/4_3_0/RP_Buy/UnknowPass_Buy_1to100_Item_UIBP.UnknowPass_Buy_1to100_Item_UIBP",
    asy = true,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\230\150\176\231\148\168\230\136\183\230\140\130\232\189\189\229\138\168\231\148\187item"
    }
  },
  UnknowPass_Buy_1to50_UIBP = {
    keyName = "UnknowPass_Buy_1to50_UIBP",
    moduleName = "client.slua.umg.unknow_pass.buy.UnknowPass_Buy_1to50_UIBP",
    path = "/Game/Arts_UI/UnknowPass/4_0_0/RP_Buy/UnknowPass_Buy_1to50_UIBP.UnknowPass_Buy_1to50_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\232\180\173\228\185\176-1-50\231\186\167"
    },
    asy = true
  },
  UnknowPass_Buy_Choose_UIBP = {
    keyName = "UnknowPass_Buy_Choose_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_Buy_Choose_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/Itemchoose_UIBP.Itemchoose_UIBP",
    jumpModuleID = BP_ENUM_MODULE_CHOOSE_UNKNOW_PASS,
    uiStat = {
      name = "RP\229\138\168\228\189\156\233\128\137\230\139\169\231\149\140\233\157\162"
    },
    asy = true
  },
  UnknowPass_Buy_Num_ActAnim = {
    keyName = "UnknowPass_Buy_Num_ActAnim",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_Buy_Num_ActAnim",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Activity_BuyUPass_NumUIBP1.Activity_BuyUPass_NumUIBP1",
    isSingleton = false,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\229\138\168\231\148\187"
    }
  },
  UnknowPass_ContinuousBuy_BranchRP_UIBP = {
    keyName = "UnknowPass_ContinuousBuy_BranchRP_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Common_UnknowPass.UnknowPass_ContinuousBuy_BranchRP_UIBP",
    path = "/Game/UMG/UI_BP/Common/UnknowPass_ContinuousBuy/UnknowPass_ContinuousBuy_UIBP.UnknowPass_ContinuousBuy_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\229\136\134\230\148\175RP\229\190\189\231\171\160"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.None,
    asy = true
  },
  UnknowPass_ContinuousBuy_History_UIBP = {
    keyName = "UnknowPass_ContinuousBuy_History_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Common_UnknowPass.UnknowPass_ContinuousBuy_History_UIBP",
    path = "/Game/UMG/UI_BP/Common/UnknowPass_ContinuousBuy/UnknowPass_ContinuousBuy_UIBP.UnknowPass_ContinuousBuy_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168\229\142\134\229\143\178RP\229\190\189\231\171\160"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.None,
    asy = true
  },
  UnknowPass_ContinuousBuy_UIBP = {
    keyName = "UnknowPass_ContinuousBuy_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Common_UnknowPass.UnknowPass_ContinuousBuy_UIBP",
    path = "/Game/UMG/UI_BP/Common/UnknowPass_ContinuousBuy/UnknowPass_ContinuousBuy_UIBP.UnknowPass_ContinuousBuy_UIBP",
    uiStat = {
      name = "\233\128\154\231\148\168RP\229\190\189\231\171\160"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.None,
    asy = true
  },
  UnknowPass_Discount_Buy_UIBP = {
    keyName = "UnknowPass_Discount_Buy_UIBP",
    moduleName = "client.slua.umg.unknow_pass.buy.UnknowPass_Discount_Buy_UIBP",
    path = "/Game/Arts_UI/UnknowPass/4_0_0/RP_Discount/UnknowPass_Discount_Buy_UIBP.UnknowPass_Discount_Buy_UIBP",
    uiStat = {
      name = "RP\231\153\190\229\136\134\230\175\148\230\138\152\230\137\163\229\136\184\232\180\173\228\185\176RP\231\149\140\233\157\162"
    },
    asy = true
  },
  UnknowPass_Discount_Fixed_UIBP = {
    keyName = "UnknowPass_Discount_Fixed_UIBP",
    moduleName = "client.slua.umg.unknow_pass.buy.UnknowPass_Discount_Fixed_UIBP",
    path = "/Game/Arts_UI/UnknowPass/4_0_0/RP_Discount/UnknowPass_Discount_Fixed_UIBP.UnknowPass_Discount_Fixed_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "RP\229\155\186\229\174\154\230\138\152\230\137\163\229\136\184\230\138\149\230\148\190\233\128\154\231\159\165\229\188\185\231\170\151"
    },
    asy = true
  },
  UnknowPass_Discount_Percentage_UIBP = {
    keyName = "UnknowPass_Discount_Percentage_UIBP",
    moduleName = "client.slua.umg.unknow_pass.buy.UnknowPass_Discount_Percentage_UIBP",
    path = "",
    containerName = UIContainers.Top,
    uiStat = {
      name = "RP\229\155\186\229\174\154\230\138\152\230\137\163\229\136\184\230\138\149\230\148\190\233\128\154\231\159\165\229\188\185\231\170\151"
    },
    asy = true
  },
  UnknowPass_EncoreBoxBoxLottery_SuitItem_TitleNew_UIBP = {
    keyName = "UnknowPass_EncoreBoxBoxLottery_SuitItem_TitleNew_UIBP",
    moduleName = "client.slua.umg.unknow_pass.RPEncoreBox.UnknowPass_EncoreBoxBoxLottery_SuitItem_TitleNew_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Exchange/UnknowPass_EncoreBoxBoxLottery_SuitItem_TitleNew_UIBP.UnknowPass_EncoreBoxBoxLottery_SuitItem_TitleNew_UIBP",
    isSingleton = false,
    isMainUI = false,
    uiStat = {
      name = "RP380\232\135\170\233\128\137\229\174\157\231\174\177\229\165\150\229\138\177\231\149\140\233\157\162\230\152\190\231\164\186\232\181\155\229\173\163\230\160\135\233\162\152\239\188\140\230\156\170\229\177\149\229\188\128\231\138\182\230\128\129\228\184\139\231\154\132item"
    },
    asy = true
  },
  UnknowPass_EncoreBoxLottery_Old_UIBP = {
    keyName = "UnknowPass_EncoreBoxLottery_Old_UIBP",
    moduleName = "client.slua.umg.unknow_pass.RPEncoreBox.UnknowPass_EncoreBoxLottery_New_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Exchange/UnknowPass_EncoreBoxLottery_New_UIBP.UnknowPass_EncoreBoxLottery_New_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UNKNOW_ENCOREBOXLOTTERY,
    uiStat = {
      name = "RP380\232\135\170\233\128\137\229\174\157\231\174\177\230\138\189\229\165\150\231\149\140\233\157\162"
    },
    asy = true
  },
  UnknowPass_EncoreBoxLottery_New_UIBP = {
    keyName = "UnknowPass_EncoreBoxLottery_New_UIBP",
    moduleName = "client.slua.umg.unknow_pass.RPEncoreBox.UnknowPass_EncoreBoxLottery_New_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Exchange/UnknowPass_EncoreBoxLottery_New_UIBP.UnknowPass_EncoreBoxLottery_New_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "RP380\232\135\170\233\128\137\229\174\157\231\174\177\230\138\189\229\165\150\231\149\140\233\157\162"
    },
    asy = true
  },
  UnknowPass_Exchange_Item_UIBP = {
    keyName = "UnknowPass_Exchange_Item_UIBP",
    moduleName = "client.slua.umg.unknow_pass.exchange.UnknowPass_Exchange_Item_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Exchange/UnknowPass_Exchange_Item_UIBP.UnknowPass_Exchange_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\229\133\145\230\141\162\231\149\140\233\157\162item"
    },
    asy = true
  },
  UnknowPass_FriendRequest_Popup_UIBP = {
    keyName = "UnknowPass_FriendRequest_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Popup.UnknowPass_FriendRequest_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnknowPass_FriendRequest_Popup_UIBP.UnknowPass_FriendRequest_Popup_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\232\180\173\228\185\176\229\188\149\229\175\188\230\150\176\231\137\185\230\157\131"
    }
  },
  UnknowPass_GroupBuy_popups_UIBP = {
    keyName = "UnknowPass_GroupBuy_popups_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_GroupBuy_popups_UIBP",
    path = "/Game/Arts_UI/UnknowPass_BannerActivity/3_7_0/RP_GroupBuy/UnknowPass_GroupBuy_popups_UIBP.UnknowPass_GroupBuy_popups_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\229\133\168\230\156\141\232\180\173\228\185\176\230\180\187\229\138\168-\231\179\187\231\187\159\230\142\168\232\141\144"
    }
  },
  UnknowPass_NewBranchBuy_Item3_UIBP = {
    keyName = "UnknowPass_NewBranchBuy_Item3_UIBP",
    moduleName = "client.slua.umg.unknow_pass.award.UnknowPass_NewBranchBuy_Item3_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnknowPass_NewBranchBuy_Item3_UIBP.UnknowPass_NewBranchBuy_Item3_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "BonusPass\230\160\184\229\191\131\233\162\132\232\167\136Item"
    }
  },
  UnknowPass_NewBranchBuy_Item_UIBP = {
    keyName = "UnknowPass_NewBranchBuy_Item_UIBP",
    moduleName = "client.slua.umg.unknow_pass.buy.UnknowPass_NewBranchBuy_Item_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnknowPass_NewBranchBuy_Item_UIBP.UnknowPass_NewBranchBuy_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\232\180\173\228\185\176"
    },
    asy = true
  },
  UnknowPass_NewBranchBuy_UIBP = {
    keyName = "UnknowPass_NewBranchBuy_UIBP",
    moduleName = "client.slua.umg.unknow_pass.buy.UnknowPass_NewBranchBuy_UIBP",
    path = "/Game/Arts_UI/UnknowPass/4_0_0/RP_BranchBuy/UnknowPass_NewBranchBuy_UIBP.UnknowPass_NewBranchBuy_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\232\180\173\228\185\176"
    },
    asy = true
  },
  UnknowPass_Popup_Theme_PushBuy_UIBP = {
    keyName = "UnknowPass_Popup_Theme_PushBuy_UIBP",
    moduleName = "client.slua.umg.UnknowPass.FaceSlap.UnknowPass_Popup_Theme_PushBuy_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Popup/UnknowPass_Popup_Theme_PushBuy_UIBP.UnknowPass_Popup_Theme_PushBuy_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "RP\231\173\137\231\186\167\230\142\168\233\128\129\233\128\154\231\159\165-280"
    }
  },
  UnknowPass_Privilege_UIBP = {
    keyName = "UnknowPass_Privilege_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_Privilege_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnknowPass_Privilege_UIBP.UnknowPass_Privilege_UIBP",
    jumpModuleID = BP_ENUM_MODULE_PRIVILEGE_UNKNOW_PASS,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\231\137\185\230\157\131"
    },
    asy = true
  },
  UnknowPass_Privilege_New_UIBP = {
    keyName = "UnknowPass_Privilege_New_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_Privilege_New_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnknowPass_Privilege_New_UIBP.UnknowPass_Privilege_New_UIBP",
    jumpModuleID = BP_ENUM_MODULE_PRIVILEGE_NEW_UNKNOW_PASS,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\231\137\185\230\157\131\230\150\176\231\137\136\230\156\172\231\149\140\233\157\162"
    },
    asy = true
  },
  UnknowPass_Purchase_Guidance_UIBP = {
    keyName = "UnknowPass_Purchase_Guidance_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_Purchase_Guidance_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Newbie/UnknowPass_Purchase_Guidance_UIBP.UnknowPass_Purchase_Guidance_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\232\180\173\228\185\176\231\149\140\233\157\162\230\150\176\230\137\139\229\188\149\229\175\188"
    },
    asy = true
  },
  UnknowPass_RankTitleItem_UIBP = {
    keyName = "UnknowPass_RankTitleItem_UIBP",
    moduleName = "client.slua.umg.unknow_pass.rank.UnknowPass_RankTitleItem_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/FirstRankAward/UnknowPass_RankTitleItem_UIBP.UnknowPass_RankTitleItem_UIBP",
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.other_pool,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\233\166\150\229\145\168\230\142\146\232\161\140\231\149\140\233\157\162\229\173\144Item"
    }
  },
  UnknowPass_Rank_Next = {
    keyName = "UnknowPass_Rank_Next",
    moduleName = "client.slua.umg.unknow_pass.rank.UnknowPass_Rank_Next",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/FirstRankAward/UnknowPass_Rank_Next.UnknowPass_Rank_Next",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\233\166\150\229\145\168\230\142\146\232\161\140\231\149\140\233\157\162\230\149\172\232\175\183\230\156\159\229\190\133Item"
    }
  },
  UnknowPass_RecordMain_UIBP = {
    keyName = "UnknowPass_RecordMain_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_RecordMain_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Record/UnknowPass_RecordMain_UIBP.UnknowPass_RecordMain_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\230\161\163\230\161\136"
    },
    asy = true
  },
  UnknowPass_RecordPreview_UIBP = {
    keyName = "UnknowPass_RecordPreview_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_RecordPreview_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Record/UnknowPass_RecordPreview_UIBP.UnknowPass_RecordPreview_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UNKNOW_RECORD_PREVIEW,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\230\161\163\230\161\136\229\165\150\229\138\177\233\162\132\232\167\136"
    },
    asy = true
  },
  UnknowPass_Record_Tips_UIBP = {
    keyName = "UnknowPass_Record_Tips_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Item.UnknowPass_Record_Tips_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnknowPass_Record_Tips_UIBP.UnknowPass_Record_Tips_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-RP\229\128\188\229\162\158\229\138\160"
    },
    asy = true
  },
  UnknowPass_Slap_UIBP = {
    keyName = "UnknowPass_Slap_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_Slap_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Popup/UnknowPass_Slap_UIBP.UnknowPass_Slap_UIBP",
    closeOnHide = false,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\230\139\141\232\132\184\229\155\190"
    }
  },
  UnknowPass_Subscribe_New_Popup_UIBP = {
    keyName = "UnknowPass_Subscribe_New_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_Subscribe_New_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Popup/UnknowPass_Subscribe_New_Popup_UIBP.UnknowPass_Subscribe_New_Popup_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-Rp\232\191\158\231\187\173\229\188\128\233\128\154\229\165\150\229\138\177\231\137\185\230\157\131\229\188\185\231\170\151"
    },
    asy = true
  },
  UnknowPass_Subscription_Confirm = {
    keyName = "UnknowPass_Subscription_Confirm",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_Subscription_Confirm",
    path = "/Game/UMG/UI_BP/Common/Common_MessageBox_115_UIBP.Common_MessageBox_115_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\232\174\162\233\152\133\231\161\174\232\174\164"
    },
    asy = true
  },
  UnknowPass_V2RewardsPreview_UIBP = {
    keyName = "UnknowPass_V2RewardsPreview_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_V2RewardsPreview_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnknowPass_V2RewardsPreview_UIBP.UnknowPass_V2RewardsPreview_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UNKNOW_PASS_REWARD_PREVIEW,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\233\162\132\232\167\136\230\160\184\229\191\131\229\165\150\229\138\177"
    },
    asy = true
  },
  UnknowPass_Voucher_Item_UIBP = {
    keyName = "UnknowPass_Voucher_Item_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Item.UnknowPass_Voucher_Item_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnknowPass_Voucher_Item_UIBP.UnknowPass_Voucher_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\230\138\181\230\137\163\229\136\184\231\187\132\229\144\136\229\133\165\229\143\163"
    }
  },
  UnknowPass_Voucher_UIBP = {
    keyName = "UnknowPass_Voucher_UIBP",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_Voucher_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnknowPass_Voucher_UIBP.UnknowPass_Voucher_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\230\138\181\230\137\163\229\136\184\231\187\132\229\144\136"
    }
  },
  Unknowpass_EncoreBox_Shop_UIBP = {
    keyName = "Unknowpass_EncoreBox_Shop_UIBP",
    moduleName = "client.slua.umg.unknow_pass.RPEncoreBox.Unknowpass_EncoreBox_Shop_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Exchange/Unknowpass_EncoreBox_Shop_UIBP.Unknowpass_EncoreBox_Shop_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UNKNOW_ENCOREBOXSHOP,
    uiStat = {
      name = "RP380\232\135\170\233\128\137\229\174\157\231\174\177\232\135\170\233\128\137\229\165\150\229\138\177\231\149\140\233\157\162"
    },
    asy = true
  },
  Unknowpass_LimitTime_Activity = {
    keyName = "Unknowpass_LimitTime_Activity",
    moduleName = "client.slua.umg.UnknowPass.Unknowpass_LimitTime_Activity",
    path = "/Game/UMG/UI_BP/NewActivty/RP_Activity_Novice_Reward_UIBP.RP_Activity_Novice_Reward_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\233\153\144\230\151\182\230\180\187\229\138\168\228\187\187\229\138\161"
    }
  },
  Unknowpass_XYearBox_Preview_UIBP = {
    keyName = "Unknowpass_XYearBox_Preview_UIBP",
    moduleName = "client.slua.umg.unknow_pass.140_back_box.Unknowpass_XYearBox_Preview_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Exchange/Unknowpass_XYearBox_Preview_UIBP.Unknowpass_XYearBox_Preview_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UNKNOW_XYEARBOX_PREVIEW,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129 - RP\232\191\148\229\156\186\229\174\157\231\174\177\233\154\143\230\156\186\230\156\186\229\136\182\229\174\157\231\174\177\232\175\166\230\131\133"
    },
    asy = true
  },
  Unknowpass_XYearBox_ProgressRate_Popup = {
    keyName = "Unknowpass_XYearBox_ProgressRate_Popup",
    moduleName = "client.slua.umg.unknow_pass.140_back_box.Unknowpass_XYearBox_ProgressRate_Popup",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Exchange/Unknowpass_XYearBox_ProgressRate_Popup.Unknowpass_XYearBox_ProgressRate_Popup",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129 - RP\232\191\148\229\156\186\229\174\157\231\174\177\229\191\133\229\190\151\230\156\186\229\136\182\228\184\173N\230\172\161\229\191\133\229\190\151\229\188\185\231\170\151"
    },
    asy = true
  },
  activity_buy_upass = {
    keyName = "activity_buy_upass",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_BuyAct",
    path = "/Game/Arts_UI/UnknowPass_BannerActivity/3_7_0/RP_GroupBuy/UnknowPass_GroupBuy_UIBP.UnknowPass_GroupBuy_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\229\133\168\230\156\141\232\180\173\228\185\176\230\180\187\229\138\168-\228\184\187\231\149\140\233\157\162"
    }
  },
  activity_buy_upass_detail = {
    keyName = "activity_buy_upass_detail",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_BuyActDetail",
    path = "/Game/Arts_UI/UnknowPass_BannerActivity/3_7_0/RP_GroupBuy/UnknowPass_TeamContentPopup_UIBP.UnknowPass_TeamContentPopup_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\229\133\168\230\156\141\232\180\173\228\185\176\230\180\187\229\138\168-\232\175\166\230\131\133\231\149\140\233\157\162"
    }
  },
  activity_buy_upass_invite = {
    keyName = "activity_buy_upass_invite",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_BuyActInvite",
    path = "/Game/Arts_UI/UnknowPass_BannerActivity/3_7_0/RP_GroupBuy/UnknowPass_TeamInvitePopup_UIBP.UnknowPass_TeamInvitePopup_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\229\133\168\230\156\141\232\180\173\228\185\176\230\180\187\229\138\168-\233\130\128\232\175\183\231\149\140\233\157\162"
    }
  },
  activity_buy_upass_share_ui = {
    keyName = "activity_buy_upass_share_ui",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_BuyActShareUI",
    path = "/Game/Arts_UI/UnknowPass_BannerActivity/3_7_0/RP_GroupBuy/UnknowPass_GroupBuyShare_UIBP.UnknowPass_GroupBuyShare_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\229\133\168\230\156\141\232\180\173\228\185\176\230\180\187\229\138\168-\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  },
  bonuspass_levelup = {
    keyName = "bonuspass_levelup",
    moduleName = "client.slua.umg.unknow_pass.bonuspass_levelup",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Unlock_Level/UnknowPass_LevelUp_UIBP.UnknowPass_LevelUp_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "RP\229\136\134\230\148\175BonusPass \233\128\154\232\161\140\232\175\129-\229\141\135\231\186\167"
    },
    asy = true
  },
  quick_team_up = {
    keyName = "quick_team_up",
    moduleName = "client.slua.umg.teamup.quick_teamup",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Task/UnknowPass_Teamtask_UIBP.UnknowPass_Teamtask_UIBP",
    uiStat = {
      name = "\228\187\187\229\138\161-\229\191\171\233\128\159\231\187\132\233\152\159"
    }
  },
  suit_dye_main = {
    keyName = "suit_dye_main",
    moduleName = "client.slua.umg.suit_dye.suit_dye_main",
    path = "/Game/UMG/UI_BP/UnknowPass/ClothesChange/ClothesChange_Main_UIBP.ClothesChange_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_SUIT_DIY,
    uiStat = {
      name = "\230\156\141\232\163\133\230\148\185\232\137\178-\228\184\187\231\149\140\233\157\162"
    }
  },
  suit_dye_upgrade_confirm = {
    keyName = "suit_dye_upgrade_confirm",
    moduleName = "client.slua.umg.suit_dye.suit_dye_upgrade_confirm",
    path = "/Game/UMG/UI_BP/UnknowPass/ClothesChange/Upgrade_Confirmationrint_Popoup_UIBP.Upgrade_Confirmationrint_Popoup_UIBP",
    uiStat = {
      name = "\230\156\141\232\163\133\230\148\185\232\137\178-\229\141\135\231\186\167\231\161\174\232\174\164"
    }
  },
  unknowpass_DecomposePopups_UIBP = {
    keyName = "unknowpass_DecomposePopups_UIBP",
    moduleName = "client.slua.umg.unknow_pass.unknowpass_DecomposePopups_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/unknowpass_DecomposePopups_UIBP.unknowpass_DecomposePopups_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\231\167\175\229\136\134\229\141\161\230\137\185\233\135\143\228\189\191\231\148\168"
    },
    asy = true
  },
  unknowpass_activity_collection_page = {
    keyName = "unknowpass_activity_collection_page",
    moduleName = "client.slua.umg.unknow_pass.activity_collection.unknowpass_activity_collection_page",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/ActivityCollect/ActivityCollect_UIBP.ActivityCollect_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UNKNOWPASS_ACTIVITY_COLLECTION,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\230\180\187\229\138\168\233\155\134\229\144\136\233\161\181\229\177\149\231\164\186\231\149\140\233\157\162"
    },
    asy = true
  },
  unknowpass_activity_crt_score = {
    keyName = "unknowpass_activity_crt_score",
    moduleName = "client.slua.umg.unknow_pass.activity_rp_crt.unknowpass_activity_crt_score",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_integral_crit/UnknowPass_integral_crit_UIBP.UnknowPass_integral_crit_UIBP",
    jumpModuleID = BP_ENUM_MODULE_RP_CRT_SCORE,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-RP\231\167\175\229\136\134\230\154\180\229\135\187\231\149\140\233\157\162"
    },
    asy = true
  },
  unknowpass_award = {
    keyName = "unknowpass_award",
    moduleName = "client.slua.umg.UnknowPass.UnknowPass_Award_New_BP",
    path = "/Game/Arts_UI/UnknowPass/4_0_0/UIBP_Main/UnknowPass_Award_New_BP.UnknowPass_Award_New_BP",
    AndroidBackType = EAndroidBackType.Skip,
    containerName = UIContainers.Bottom,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\229\165\150\229\138\177"
    },
    asy = true
  },
  unknowpass_award_buyscore = {
    keyName = "unknowpass_award_buyscore",
    moduleName = "client.slua.umg.unknow_pass.award.unknowpass_award_buyscore",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnknowPass_Buy_Score_UIBP.UnknowPass_Buy_Score_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UNKNOW_PASS_BUY_SCORE,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\232\180\173\228\185\176\231\173\137\231\186\167"
    },
    asy = true
  },
  unknowpass_backbox_ban = {
    keyName = "unknowpass_backbox_ban",
    moduleName = "client.slua.umg.unknow_pass.140_back_box.unknowpass_backbox_ban",
    path = "/Game/UMG/UI_BP/Store/Store_Banbox_UIBP.Store_Banbox_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-140\232\191\148\229\156\186\229\174\157\231\174\177ban\231\149\140\233\157\162"
    },
    asy = true
  },
  unknowpass_branch_award_buyscore = {
    keyName = "unknowpass_branch_award_buyscore",
    moduleName = "client.slua.umg.unknow_pass.award.unknowpass_branch_award_buyscore",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnknowPass_Buy_Score_UIBP.UnknowPass_Buy_Score_UIBP",
    jumpModuleID = BP_ENUM_MODULE_UNKNOW_PASS_BUY_SCORE,
    uiStat = {
      name = "RP\233\128\154\232\161\140\232\175\129\230\148\175\231\186\191-\232\180\173\228\185\176\231\173\137\231\186\167"
    },
    asy = true
  },
  unknowpass_buy_super = {
    keyName = "unknowpass_buy_super",
    moduleName = "client.slua.umg.unknow_pass.buy.unknowpass_buy_super",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnknowPass_BuyElite_UIBP.UnknowPass_BuyElite_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\230\153\174\233\128\154100\231\186\167RP\231\180\162\232\166\129\229\188\185\231\170\151"
    },
    asy = true
  },
  unknowpass_easy_ticket = {
    keyName = "unknowpass_easy_ticket",
    moduleName = "client.slua.umg.unknow_pass.unknowpass_easy_ticket",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/Unknowpass_EasyTicket_UIBP.Unknowpass_EasyTicket_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\231\149\133\231\142\169\229\141\161"
    },
    asy = true
  },
  unknowpass_exchange = {
    keyName = "unknowpass_exchange",
    moduleName = "client.slua.umg.unknow_pass.exchange.unknowpass_exchange",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UnknowPass_Exchange_BP.UnknowPass_Exchange_BP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\229\133\145\230\141\162"
    },
    asy = true
  },
  unknowpass_levelup = {
    keyName = "unknowpass_levelup",
    moduleName = "client.slua.umg.unknow_pass.unknowpass_levelup",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Unlock_Level/UnknowPass_LevelUp_UIBP.UnknowPass_LevelUp_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\229\141\135\231\186\167"
    },
    asy = true
  },
  unknowpass_mission_sec = {
    keyName = "unknowpass_mission_sec",
    moduleName = "client.slua.umg.UnknowPass.Mission.unknowpass_mission_sec",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/RP_Task_UIBP.RP_Task_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\229\145\168\228\187\187\229\138\161"
    },
    asy = true
  },
  unknowpass_rank = {
    keyName = "unknowpass_rank",
    moduleName = "client.slua.umg.unknow_pass.rank.unknowpass_rank",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UnknowPass_Rank_BP.UnknowPass_Rank_BP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\230\142\146\232\161\140\230\166\156"
    },
    asy = true
  },
  unknowpass_rank_first_week_awards = {
    keyName = "unknowpass_rank_first_week_awards",
    moduleName = "client.slua.umg.unknow_pass.rank.unknowpass_rank_first_week_awards",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/FirstRankAward/UnknowPass_RankTitle_UIBP.UnknowPass_RankTitle_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\233\166\150\229\145\168\230\142\146\232\161\140\229\165\150\229\138\177"
    },
    asy = true
  },
  unknowpass_rank_first_week_awards_preview = {
    keyName = "unknowpass_rank_first_week_awards_preview",
    moduleName = "client.slua.umg.unknow_pass.rank.unknowpass_rank_first_week_awards_preview",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/FirstRankAward/UnknowPass_RankAward_UIBP.UnknowPass_RankAward_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\233\166\150\229\145\168\230\142\146\232\161\140\229\165\150\229\138\177\233\162\132\232\167\136"
    },
    asy = true
  },
  unknowpass_rank_first_week_items = {
    keyName = "unknowpass_rank_first_week_items",
    moduleName = "client.slua.umg.unknow_pass.rank.unknowpass_rank_first_week_items",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/FirstRankAward/UnknowPass_RankItem_UIBP.UnknowPass_RankItem_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\233\166\150\229\145\168\230\142\146\232\161\140\229\165\150\229\138\177\229\134\133\229\174\185"
    }
  },
  unknowpass_share = {
    keyName = "unknowpass_share",
    moduleName = "client.slua.umg.unknow_pass.unknowpass_share",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Unlock_Level/UnknowPass_Share_UIBP.UnknowPass_Share_UIBP",
    uiStat = {
      name = "\229\136\134\228\186\171-\233\128\154\232\161\140\232\175\129"
    },
    asy = true
  },
  unknowpass_toy_get = {
    keyName = "unknowpass_toy_get",
    moduleName = "client.slua.umg.unknow_pass.unknowpass_toy_get",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UIBP_Other/UnknowPass_ToysGet_UIBP.UnknowPass_ToysGet_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-\231\142\169\229\133\183\228\185\139\229\138\155\232\167\163\233\148\129"
    },
    asy = true
  },
  Annual_Crit_Popup_UIBP = {
    keyName = "Annual_Crit_Popup_UIBP",
    moduleName = "client.slua.umg.unknow_pass.buy.Annual_Crit_Popup_UIBP",
    path = "/Game/Arts_UI/UnknowPass/4_3_0/Annual_Sales/Annual_Crit_Popup_UIBP.Annual_Crit_Popup_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-RP\229\185\180\229\186\166\230\154\180\229\135\187\229\188\185\231\170\151"
    },
    asy = true
  },
  Annual_Crit_Award_Popup_UIBP = {
    keyName = "Annual_Crit_Award_Popup_UIBP",
    moduleName = "client.slua.umg.unknow_pass.buy.Annual_Crit_Award_Popup_UIBP",
    path = "/Game/Arts_UI/UnknowPass/4_3_0/Annual_Sales/Annual_Crit_Award_Popup_UIBP.Annual_Crit_Award_Popup_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-RP\229\185\180\229\186\166\230\154\180\229\135\187\233\135\141\232\166\129\229\165\150\229\138\177\229\188\185\231\170\151"
    },
    asy = true
  },
  Annual_Crit_Share_UIBP = {
    keyName = "Annual_Crit_Share_UIBP",
    moduleName = "client.slua.umg.unknow_pass.buy.Annual_Crit_Share_UIBP",
    path = "/Game/Arts_UI/UnknowPass/4_3_0/Annual_Sales/Annual_Crit_Share_UIBP.Annual_Crit_Share_UIBP",
    uiStat = {
      name = "\233\128\154\232\161\140\232\175\129-RP\229\185\180\229\186\166\230\154\180\229\135\187\233\135\141\232\166\129\229\165\150\229\138\177\229\136\134\228\186\171\229\188\185\231\170\151"
    },
    asy = true
  },
  UnknowPass_Award_UC_Retuen_Popup_UIBP = {
    keyName = "UnknowPass_Award_UC_Retuen_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Popup.UnknowPass_Award_UC_Retuen_Popup_UIBP",
    path = "/Game/Arts_UI/UnknowPass/4_3_0/UIBP_Main/Popup/UnknowPass_Award_UC_Retuen_Popup_UIBP.UnknowPass_Award_UC_Retuen_Popup_UIBP",
    uiStat = {
      name = "RP\229\145\168\229\185\180\229\186\134\231\137\136\230\156\172UC\232\191\148\229\155\158\232\175\180\230\152\142\229\188\185\231\170\151"
    },
    asy = true
  },
  UnknowPass_Exchange_New_BP = {
    keyName = "UnknowPass_Exchange_New_BP",
    moduleName = "client.slua.umg.unknow_pass.exchange.UnknowPass_Exchange_New_BP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/UnknowPass_Exchange_New_BP.UnknowPass_Exchange_New_BP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "RP\229\133\145\230\141\162\229\149\134\229\186\151"
    },
    asy = true
  },
  UnknowPass_Privilege_Sign_Popup_UIBP = {
    keyName = "UnknowPass_Privilege_Sign_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Popup.UnknowPass_Privilege_Sign_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Privilege/UnknowPass_Privilege_Sign_Popup_UIBP.UnknowPass_Privilege_Sign_Popup_UIBP",
    uiStat = {
      name = "RP\231\137\185\230\157\131\229\188\185\231\170\151-\228\184\147\229\177\158RP\230\160\135\229\191\151"
    },
    asy = true
  },
  UnknowPass_Privilege_Invitation_Popup_UIBP = {
    keyName = "UnknowPass_Privilege_Invitation_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Popup.UnknowPass_Privilege_Invitation_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Privilege/UnknowPass_Privilege_Invitation_Popup_UIBP.UnknowPass_Privilege_Invitation_Popup_UIBP",
    uiStat = {
      name = "RP\231\137\185\230\157\131\229\188\185\231\170\151-\233\130\128\232\175\183\229\188\185\231\170\151"
    },
    asy = true
  },
  UnknowPass_Privilege_Appreciation2_Popup_UIBP = {
    keyName = "UnknowPass_Privilege_Appreciation2_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Popup.UnknowPass_Privilege_Appreciation2_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Privilege/UnknowPass_Privilege_Appreciation2_Popup_UIBP.UnknowPass_Privilege_Appreciation2_Popup_UIBP",
    uiStat = {
      name = "RP\231\137\185\230\157\131\229\188\185\231\170\151-\232\181\158\232\181\143\231\137\185\230\157\131"
    },
    asy = true
  },
  UnknowPass_Privilege_PictureExplan2_Popup_UIBP = {
    keyName = "UnknowPass_Privilege_PictureExplan2_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Popup.UnknowPass_Privilege_PictureExplan2_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Privilege/UnknowPass_Privilege_PictureExplan2_Popup_UIBP.UnknowPass_Privilege_PictureExplan2_Popup_UIBP",
    uiStat = {
      name = "RP\231\137\185\230\157\131\229\188\185\231\170\151-\231\187\147\231\174\151\231\130\185\232\181\158\228\184\147\229\177\158\231\164\188\231\137\169/\228\188\153\228\188\180\230\144\186\229\184\166\230\167\189\228\189\141\229\162\158\229\138\160/\230\157\144\230\150\153\231\164\188\229\140\133\233\153\144\232\180\173\230\172\161\230\149\176\229\162\158\229\138\160"
    },
    asy = true
  },
  UnknowPass_Privilege_ActivationReward_Popup_UIBP = {
    keyName = "UnknowPass_Privilege_ActivationReward_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Popup.UnknowPass_Privilege_ActivationReward_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Privilege/UnknowPass_Privilege_ActivationReward_Popup_UIBP.UnknowPass_Privilege_ActivationReward_Popup_UIBP",
    uiStat = {
      name = "RP\231\137\185\230\157\131\229\188\185\231\170\151-\232\191\158\231\187\173\229\188\128\233\128\154\229\164\167\229\165\150"
    },
    asy = true
  },
  UnknowPass_Privilege_GivePoints_Popup_UIBP = {
    keyName = "UnknowPass_Privilege_GivePoints_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Popup.UnknowPass_Privilege_GivePoints_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Privilege/UnknowPass_Privilege_GivePoints_Popup_UIBP.UnknowPass_Privilege_GivePoints_Popup_UIBP",
    uiStat = {
      name = "RP\231\137\185\230\157\131\229\188\185\231\170\151-\232\181\160\233\128\129RP\231\167\175\229\136\134"
    },
    asy = true
  },
  UnknowPass_Privilege_PictureExplan_Popup_UIBP = {
    keyName = "UnknowPass_Privilege_PictureExplan_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Popup.UnknowPass_Privilege_PictureExplan_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Privilege/UnknowPass_Privilege_PictureExplan_Popup_UIBP.UnknowPass_Privilege_PictureExplan_Popup_UIBP",
    uiStat = {
      name = "RP\231\137\185\230\157\131\229\188\185\231\170\151-\230\175\143\229\145\168\230\140\145\230\136\152\233\162\157\229\164\15050%\231\167\175\229\136\134\229\138\160\230\136\144/\229\149\134\229\159\1425\230\138\152\230\157\131\231\155\138"
    },
    asy = true
  },
  UnknowPass_Privilege_Discount_Popup_UIBP = {
    keyName = "UnknowPass_Privilege_Discount_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Popup.UnknowPass_Privilege_Discount_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Privilege/UnknowPass_Privilege_Discount_Popup_UIBP.UnknowPass_Privilege_Discount_Popup_UIBP",
    uiStat = {
      name = "RP\231\137\185\230\157\131\229\188\185\231\170\151-BONUS PASS\230\138\152\230\137\163"
    },
    asy = true
  },
  UnknowPass_Award_RepurchaseStatement_Popup_UIBP = {
    keyName = "UnknowPass_Award_RepurchaseStatement_Popup_UIBP",
    moduleName = "client.slua.umg.UnknowPass.Popup.UnknowPass_Award_RepurchaseStatement_Popup_UIBP",
    path = "/Game/Arts_UI/FromUMG/UnknowPass/Popup/UnknowPass_Award_RepurchaseStatement_Popup_UIBP.UnknowPass_Award_RepurchaseStatement_Popup_UIBP",
    uiStat = {
      name = "RP\230\138\152\230\137\163\230\157\131\231\155\138\229\188\185\231\170\151"
    },
    asy = true
  }
}
return rp_ui_configs