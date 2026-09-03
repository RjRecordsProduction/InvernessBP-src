local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
require("client.slua.config.ClientMacros.UIContainers")
local UIConfig_BattleResult = {
  BattleResultChickenUI = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.BattleResultChickenDraw.BattleResultChickenUI",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Medal_ChickenDinner_UIBP.Medal_ChickenDinner_UIBP",
    uiStat = {
      name = "BattleResultChickenUI"
    },
    closeOnHide = false,
    isMainUI = false
  },
  BattleResultFeedbackTipsUI = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.ShowAvatar.BattleResultFeedbackTipsUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Feedback/Feedback_BattleResult_TIps_UIBP.Feedback_BattleResult_TIps_UIBP",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    zOrder = 19,
    asy = true,
    mountPanel = {
      mountOuterName = "MainControlBaseUI",
      mountName = "CanvasPanel_42"
    },
    uiStat = {
      name = "BattleResultNewFeedbackUI"
    }
  },
  BattleResultNewFeedbackUI = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.ShowAvatar.BattleResultNewFeedbackUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Feedback/Feedback_Popup.Feedback_Popup",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    zOrder = 20,
    asy = true,
    closeOnHide = false,
    mountPanel = {
      mountOuterName = "MainControlBaseUI",
      mountName = "CanvasPanel_42"
    },
    uiStat = {
      name = "BattleResultNewFeedbackUI"
    }
  },
  ResultsRanking_Protect_UIBPNew = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.ResultsRankingProtectUI",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/S20/ResultsRanking_Protect_UIBPNew.ResultsRanking_Protect_UIBPNew",
    uiStat = {
      name = "ResultsRanking_Protect_UIBPNew"
    },
    closeOnHide = false,
    isMainUI = false,
    asy = true
  },
  BattleResultRanking_UIBP = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.ShowAvatar.BattleResultRanking_UICtrl",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BattleResult/BattleResultRanking/BattleResultRanking_UIBP.BattleResultRanking_UIBP",
    uiStat = {
      name = "BattleResultRanking_UIBP"
    },
    closeOnHide = false,
    isMainUI = false,
    isSingleton = true,
    loadFromPool = EUIConfigPoolType.None
  },
  MedalDisplayUI = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.BattleResultMedal.BattleResultMedalDisplay_UICtrl",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Medal_Display_UIBP.Medal_Display_UIBP",
    closeOnHide = false,
    loadFromPool = EUIConfigPoolType.None,
    isSingleton = true,
    isMainUI = false,
    uiStat = {
      name = "MedalDisplayUI"
    }
  },
  ResultsRanking_BattleBriefPanel_UIBP = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.ShowAvatar.ResultsRanking_BattleBriefPanel_UICtrl",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BattleResult/BattleResultRanking/ResultsRanking_BattleBriefPanel_UIBP.ResultsRanking_BattleBriefPanel_UIBP",
    uiStat = {
      name = "ResultsRanking_BattleBriefPanel_UIBP"
    },
    closeOnHide = false,
    isMainUI = false
  },
  ResultsRanking_BattleDetailPanel_UIBP = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.ShowAvatar.ResultsRanking_BattleDetailPanel_UICtrl",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BattleResult/BattleResultRanking/ResultsRanking_BattleDetailPanel_UIBP.ResultsRanking_BattleDetailPanel_UIBP",
    uiStat = {
      name = "ResultsRanking_BattleDetailPanel_UIBP"
    },
    closeOnHide = false,
    isMainUI = false
  },
  BattleResultMedalDisplayUI = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.BattleResultMedal.BattleResultMedalDisplayUI",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Medal_Display_UIBP_New.Medal_Display_UIBP_New",
    uiStat = {
      name = "BattleResultMedalDisplayUI"
    },
    closeOnHide = false,
    isMainUI = false
  },
  ResultsRankingrewardtips_UIBP = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.ShowAvatar.ResultsRankingrewardtips_UICtrl",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BattleResult/BattleResultRanking/ResultsRankingrewardtips_UIBP.ResultsRankingrewardtips_UIBP",
    uiStat = {
      name = "ResultsRankingrewardtips_UIBP"
    },
    closeOnHide = false,
    isMainUI = false
  },
  ResultsRankingBriefItem_UIBP = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.ShowAvatar.ResultsRankingBriefItem_UICtrl",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BattleResult/BattleResultRanking/ResultsRankingBriefItem_UIBP.ResultsRankingBriefItem_UIBP",
    uiStat = {
      name = "ResultsRankingBriefItem_UIBP"
    },
    closeOnHide = false,
    isMainUI = false,
    isSingleton = false,
    containerName = UIContainers.None
  },
  ResultsRankingitem_UIBP = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.ShowAvatar.ResultsRankingitem_UICtrl",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BattleResult/BattleResultRanking/ResultsRankingitem_UIBP.ResultsRankingitem_UIBP",
    uiStat = {
      name = "ResultsRankingitem_UIBP"
    },
    closeOnHide = false,
    isMainUI = false,
    isSingleton = false,
    containerName = UIContainers.None
  },
  PeakGame_ResultsRanking_Protect_UIBPNew = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.PeakGame.PeakGame_ResultsRanking_Protect_UIBPNew",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/PeakGame/PeakGame_ResultsRanking_Protect_UIBPNew.PeakGame_ResultsRanking_Protect_UIBPNew",
    uiStat = {
      name = "PeakGame_ResultsRanking_Protect_UIBPNew"
    },
    closeOnHide = false,
    isMainUI = false,
    asy = true
  },
  ResultsRanking_Promotion_Progress_UIBP = {
    keyName = "ResultsRanking_Promotion_Progress_UIBP",
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.Promotion.ResultsRanking_Promotion_Progress_UIBP",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/S20/ResultsRanking_Promotion_Progress_UIBP.ResultsRanking_Promotion_Progress_UIBP",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155-\231\187\147\230\158\156\231\149\140\233\157\162"
    },
    AndroidBackType = EAndroidBackType.Ban,
    isMainUI = false
  },
  ResultsRanking_Promotion_Unlock_UIBP = {
    keyName = "ResultsRanking_Promotion_Unlock_UIBP",
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.Promotion.ResultsRanking_Promotion_Unlock_UIBP",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/S20/ResultsRanking_Promotion_Unlock_UIBP.ResultsRanking_Promotion_Unlock_UIBP",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155-\232\167\163\233\148\129\231\149\140\233\157\162"
    }
  },
  ResultsRanking_Promotion_Return_UIBP = {
    keyName = "ResultsRanking_Promotion_Return_UIBP",
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.Promotion.ResultsRanking_Promotion_Return_UIBP",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/S20/ResultsRanking_Promotion_Return_UIBP.ResultsRanking_Promotion_Return_UIBP",
    uiStat = {
      name = "\230\153\139\231\186\167\232\181\155-\229\155\158\230\181\129\229\174\154\231\186\167\231\149\140\233\157\162"
    }
  },
  ResultTask_UIBP = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.Task.ResultTask_UIBP",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BattleResult/Task/ResultTask_UIBP.ResultTask_UIBP",
    uiStat = {
      name = "ResultTask_UIBP"
    },
    containerName = UIContainers.Top,
    loadFromPool = EUIConfigPoolType.None,
    asy = true,
    isMainUI = false
  },
  ResultTask_SummaryItem = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.Task.ResultTask_SummaryItem",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BattleResult/Task/ResultTask_SummaryItem.ResultTask_SummaryItem",
    uiStat = {
      name = "ResultTask_SummaryItem"
    },
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.None
  },
  Season_WeponStrenthDetail_Popup_UIBP = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.WeaponStrength.Season_WeponStrenthDetail_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Season_WeaponStrength/Popup/Season_WeponStrenthDetail_Popup_UIBP.Season_WeponStrenthDetail_Popup_UIBP",
    containerName = UIContainers.Default,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "Season_WeponStrenthDetail_Popup_UIBP"
    }
  },
  BattleResultReward_UIBP = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.BattleResultReward_UICtrl",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BattleResult/BattleResultReward_UIBP.BattleResultReward_UIBP",
    uiStat = {
      name = "BattleResultReward_UIBP"
    },
    containerName = UIContainers.Top,
    closeOnHide = false,
    asy = true
  },
  BattleResultReward_Item_UIBP = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.BattleResultReward_Item_UICtrl",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BattleResult/BattleResultReward_Item_UIBP.BattleResultReward_Item_UIBP",
    uiStat = {
      name = "BattleResultReward_Item_UIBP"
    },
    isMainUI = false,
    isSingleton = false
  },
  PeakGame_ResultsRanking_Protect_Tips02_Item = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.PeakGame_ResultsRanking_Protect_Tips02_Item",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/PeakGame/Item/PeakGame_ResultsRanking_Protect_Tips02_Item.PeakGame_ResultsRanking_Protect_Tips02_Item",
    uiStat = {
      name = "PeakGame_ResultsRanking_Protect_Tips02_Item"
    },
    closeOnHide = false,
    isMainUI = false,
    isSingleton = false
  },
  ResultsRanking_Protect_Tips02_Item = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.ResultsRanking_Protect_Tips02_Item",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/S20/ResultsRanking_Protect_Tips02_Item.ResultsRanking_Protect_Tips02_Item",
    uiStat = {
      name = "ResultsRanking_Protect_Tips02_Item"
    },
    closeOnHide = false,
    isMainUI = false,
    isSingleton = false
  },
  ResultPlayerDetailView = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.ResultPlayerDetailView",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Results_Statistics_UIBP.Results_Statistics_UIBP",
    uiStat = {
      name = "ResultPlayerDetailView"
    },
    loadFromPool = EUIConfigPoolType.None
  },
  ResultsRankingrewardtips_Item = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.BattleResultRanking.ResultsRankingrewardtips_Item",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BattleResult/BattleResultRanking/ResultsRankingrewardtips_Item.ResultsRankingrewardtips_Item",
    uiStat = {
      name = "ResultsRankingrewardtips_Item"
    },
    closeOnHide = false,
    isMainUI = false,
    isSingleton = false
  },
  ExtraChallengeScoreTipUI = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.ExtraChallengeScoreTipUI",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/S20/ExtraChallengeScoreTip_UIBP.ExtraChallengeScoreTip_UIBP",
    uiStat = {
      name = "ExtraChallengeScoreTipUI"
    },
    closeOnHide = false,
    isMainUI = false,
    asy = false
  }
}
return UIConfig_BattleResult