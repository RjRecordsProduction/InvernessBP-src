local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Common = {
  CommonExitTransformUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.BornlandExitTransformUI",
    path = "/Game/Mod/EvoBase/BluePrints/UIBP/CommonTransform_UIBP.CommonTransform_UIBP",
    uiStat = {
      name = "CommonExitTransformUI"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0,
    autoCreate = true,
    closeOnHide = true,
    loadFromPool = EUIConfigPoolType.None,
    mountPanel = {
      mountOuterName = "MainControlBaseUI",
      mountName = "CanvasPanel_42"
    }
  },
  IslandSurviveCountPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.IslandSurviveCountPanel",
    path = "/Game/BluePrints/ControlInput/IslandSurviveCountPanel.IslandSurviveCountPanel",
    uiStat = {
      name = "IslandSurviveCountPanel"
    },
    containerName = UIContainers.Default,
    zOrder = 0,
    asy = true,
    isMainUI = false
  },
  JumpToMapModDetailUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.JumpToMapModDetailUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/NewbieGuide/JumpToMapModDesc_UIBP.JumpToMapModDesc_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    isMainUI = false,
    closeOnHide = true,
    isWindowsOBHide = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "JumpToMapModDetailUI"
    }
  },
  NavigatorPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.NavigatorPanel",
    path = "/Game/BluePrints/ControlInput/NavigatorPanel.NavigatorPanel",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = false,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "NavigatorPanel"
    },
    autoCreate = true
  },
  TeleportScreenEffectUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.LoadingScreenEffectUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/TeleportScreenEffectUI_UIBP.TeleportScreenEffectUI_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "TeleportScreenEffectUI"
    },
    containerName = UIContainers.Top
  },
  TurnplateUIControl = {
    moduleName = "GameLua.Mod.BaseMod.Client.TurnplateUI.TurnplateUIControl",
    path = "/Game/BluePrints/ControlInput/IngameUI/Turnplate_UIBP.Turnplate_UIBP",
    isMainUI = false,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "TurnplateUIControl"
    }
  },
  TurnplateQuickMsgTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.GuideTipsUI.TurnplateQuickMsgTips",
    path = "/Game/BluePrints/ControlInput/GuideTipsUI/TurnplateQuickMsgTips.TurnplateQuickMsgTips",
    isMainUI = false,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "TurnplateQuickMsgTips"
    }
  },
  QuickSignUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.QuickSignUI.QuickSignUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/QuickSign/QuickSign_UIBP.QuickSign_UIBP",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 0,
    asy = true,
    isSingleton = true,
    uiStat = {
      name = "QuickSignUI"
    }
  },
  QuickSignCircleUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.QuickSignUI.QuickSignCircleUIWrap",
    path = "/Game/BluePrints/ControlInput/IngameUI/QuickSign/QuickSignCircle_UIBP.QuickSignCircle_UIBP",
    uiStat = {
      name = "QuickSignCircleUI"
    },
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 0,
    isSingleton = true,
    asy = true,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  QuickSignRadialMenu = {
    moduleName = "GameLua.Mod.BaseMod.Client.QuickSignUI.QuickSignRadialMenu",
    path = "/Game/BluePrints/ControlInput/IngameUI/QuickSign/QuickSignRadialMenu.QuickSignRadialMenu",
    uiStat = {
      name = "QuickSignRadialMenu"
    },
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 0,
    asy = true,
    isSingleton = true,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  AutoSprintPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.MainControlUI.AutoSprintPanel",
    path = "/Game/BluePrints/ControlInput/AutoSprintPanel.AutoSprintPanel",
    isMainUI = false,
    zOrder = 0,
    asy = true
  },
  XSuitPlatform_SwitchCamera_UIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.XSuitPlatform_SwitchCamera_UIBP",
    path = "/Game/Mod/EvoBase/BluePrints/UI/InteractUI/XSuitPlatform_SwitchCamera_UIBP.XSuitPlatform_SwitchCamera_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    isMainUI = false,
    closeOnHide = true,
    isWindowsOBHide = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "XSuitPlatform_SwitchCamera_UIBP"
    }
  }
}
return UIConfig_Common