local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_UI = {
  AITakeOverGuideUI = {
    moduleName = "GameLua.Mod.BaseMod.GamePlay.AI.AITakeOverGuideUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/TeammateTakeOver/Entrustment_Popup_UIBP.Entrustment_Popup_UIBP",
    uiStat = {
      name = "AITakeOverGuideUI"
    },
    containerName = UIContainers.Top,
    isSingleton = true,
    asy = true,
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None
  },
  BIDHourUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.BIDHourUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BattleResult/BattleResultBattleID_UIBP.BattleResultBattleID_UIBP",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = false,
    asy = true,
    uiStat = {name = "BIDHourUI"},
    zOrder = 9999,
    loadFromPool = EUIConfigPoolType.None,
    containerName = UIContainers.Top
  },
  CDBarUIPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.CDBarUIPanel",
    path = "/Game/BluePrints/ControlInput/IngameCDBarUI/CDBarUI_BP.CDBarUI_BP",
    uiStat = {
      name = "CDBarUIPanel"
    },
    containerName = UIContainers.Bottom,
    asy = true,
    isMainUI = false
  },
  Common_Logo_UIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.CommonLogoUI",
    path = "/Game/UMG/UI_BP/Common/Common_Logo_UIBP.Common_Logo_UIBP",
    isSingleton = true,
    isMainUI = false,
    asy = true,
    autoCreate = true,
    uiStat = {name = "Logo UI"},
    showVisibility = UIContainers.ShowVisibilityAction.DontCare,
    zOrder = -1
  },
  DebugShowFPS = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.DebugShowFPS",
    path = "/Game/BluePrints/ControlInput/DebugShowFPS_UIBP.DebugShowFPS_UIBP",
    isMainUI = false,
    isWindowsOBHide = true,
    asy = true,
    uiStat = {
      name = "DebugShowFPS"
    }
  },
  EnterGameFaceGuide = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.FaceIntroUIBase",
    path = "/Game/Mod/EvoBase/BluePrints/UI/NewbieGuide/EnterGameGuide_UIBP.EnterGameGuide_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    uiStat = {
      name = "EnterGameFaceGuide"
    },
    isMainUI = false,
    closeOnHide = true,
    asy = true,
    isWindowsOBHide = true,
    loadFromPool = EUIConfigPoolType.None
  },
  FaceGuideBtn = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.FaceButtonMain",
    path = "/Game/Mod/EvoBase/BluePrints/UI/NewbieGuide/FaceGuideBtn_UIBP.FaceGuideBtn_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    uiStat = {
      name = "FaceGuideBtn"
    },
    isMainUI = false,
    closeOnHide = true,
    asy = true,
    isWindowsOBHide = true,
    loadFromPool = EUIConfigPoolType.None
  },
  EnterGamePromotionNotice = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.Promotion.EnterGamePromotionNotice",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Promotion/EnterGame_Promotion_Progress_UIBP.EnterGame_Promotion_Progress_UIBP",
    containerName = UIContainers.Default,
    zOrder = 120,
    uiStat = {
      name = "EnterGamePromotionNotice"
    },
    closeOnHide = true,
    loadFromPool = EUIConfigPoolType.None,
    asy = true,
    isWindowsOBHide = true,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  HistoricalNewsUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.HistoricalNewsUI",
    path = "/Game/BluePrints/ControlInput/HistoricalNewsUI.HistoricalNewsUI",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = false,
    asy = true,
    uiStat = {
      name = "HistoricalNewsUI"
    },
    zOrder = 0,
    autoCreate = true,
    mountPanel = {
      mountOuterName = "ShootingUIPanel",
      mountName = "HistoricalNewsCanvasPanel"
    }
  },
  IngameWidgetOutlinerUI = {
    moduleName = "GameLua.Dev.WidgetOutliner.IngameWidgetOutlinerUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/WidgetOutliner/IngameWidgetOutlinerUI.IngameWidgetOutlinerUI",
    uiStat = {
      name = "IngameWidgetOutlinerUI"
    },
    isMainUI = false,
    closeOnHide = false,
    loadFromPool = EUIConfigPoolType.ui_pool,
    zOrder = 100000000,
    containerName = UIContainers.Top
  },
  LogoGuideUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.LogoGuideUI",
    path = "/Game/UMG/UI_BP/Common/LogoGuideUI.LogoGuideUI",
    isSingleton = true,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "LogoGuideUI"
    },
    zOrder = -2
  },
  MedicineChooseWidgetNew = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseMedicineNew",
    path = "/Game/BluePrints/ControlInput/CircleChooseWidget/RingThrowButUI_UIBP.RingThrowButUI_UIBP",
    uiStat = {
      name = "MedicineChooseWidgetNew"
    },
    containerName = UIContainers.Default,
    closeOnHide = false,
    isSingleton = true,
    AndroidBackType = EAndroidBackType.Skip,
    asy = true,
    showVisibility = UIContainers.ShowVisibilityAction.DontCare
  },
  PhoneStateUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.IngamePhoneStateUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngamePhoneState_UIBP.IngamePhoneState_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    uiStat = {
      name = "MiniTvBannerTipsUI"
    },
    isMainUI = false
  },
  ThemePropsChooseWidgetNew = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.ThemePropsChooseWidgetNew",
    path = "/Game/BluePrints/ControlInput/CircleChooseWidget/ThemePropsUI_UIBP.ThemePropsUI_UIBP",
    uiStat = {
      name = "ThemePropsChooseWidgetNew"
    },
    containerName = UIContainers.Default,
    closeOnHide = false,
    isSingleton = true,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Skip
  },
  TimeCountingUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.TimeCountingUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/MapItem/TimeCounting_UIBP.TimeCounting_UIBP",
    uiStat = {
      name = "TimeCountingUI"
    },
    closeOnHide = true,
    loadFromPool = EUIConfigPoolType.None,
    isMainUI = false,
    zOrder = 0,
    asy = true,
    showVisibility = UIContainers.ShowVisibilityAction.DontCare
  },
  WeakNetworkUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.WeakNetworkIcon",
    path = "/Game/BluePrints/ControlInput/IngameUI/Signal_UIBP.Signal_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    uiStat = {
      name = "ClassicStoreUI"
    },
    isMainUI = false,
    asy = true
  },
  ValuePropertyDetailItem = {
    moduleName = "GameLua.Dev.WidgetOutliner.PropertyDetailItem",
    path = "/Game/BluePrints/ControlInput/IngameUI/WidgetOutliner/ValuePropertyDetailItem.ValuePropertyDetailItem",
    uiStat = {
      name = "ValuePropertyDetailItem"
    },
    isSingleton = false,
    isMainUI = false,
    closeOnHide = false,
    loadFromPool = EUIConfigPoolType.ui_pool,
    zOrder = 1
  },
  WidgetTreeItem = {
    moduleName = "GameLua.Dev.WidgetOutliner.WidgetTreeItem",
    path = "/Game/BluePrints/ControlInput/IngameUI/WidgetOutliner/WidgetTreeItem.WidgetTreeItem",
    uiStat = {
      name = "WidgetTreeItem"
    },
    isSingleton = false,
    isMainUI = false,
    closeOnHide = false,
    loadFromPool = EUIConfigPoolType.ui_pool,
    zOrder = 1
  }
}
return UIConfig_UI