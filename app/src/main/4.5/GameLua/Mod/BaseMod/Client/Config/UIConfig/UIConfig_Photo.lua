local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Photo = {
  DummyCheckPointShowUI = {
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/Mod/BRMod/BluePrints/Actor/DummyCheckPoint/DummyCheckPoint_UIBP.DummyCheckPoint_UIBP",
    uiStat = {
      name = "DummyCheckPointShowUI"
    },
    containerName = UIContainers.Top,
    isSingleton = true,
    asy = true,
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None,
    zOrder = -10
  },
  Ingame_Photo_UIBP = {
    moduleName = "GameLua.Mod.Library.Client.Photo.Ingame_Photo_UIBP",
    path = "/Game/Mod/EvoBase/BluePrints/UI/PhotoUI/Ingame_Photo_UIBP.Ingame_Photo_UIBP",
    containerName = UIContainers.Default,
    asy = true,
    uiStat = {
      name = "Ingame_Photo_UIBP"
    }
  },
  Ingame_Photo_Popup_1_UIBP = {
    moduleName = "GameLua.Mod.Library.Client.Photo.Ingame_Photo_Popup_1_UIBP",
    path = "/Game/Mod/EvoBase/BluePrints/UI/PhotoUI/PopUp/Ingame_Photo_Popup_1_UIBP.Ingame_Photo_Popup_1_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "Ingame_Photo_Popup_1_UIBP"
    }
  },
  Ingame_Photo_Popup_2_UIBP = {
    moduleName = "GameLua.Mod.Library.Client.Photo.Ingame_Photo_Popup_2_UIBP",
    path = "/Game/Mod/EvoBase/BluePrints/UI/PhotoUI/PopUp/Ingame_Photo_Popup_2_UIBP.Ingame_Photo_Popup_2_UIBP",
    containerName = UIContainers.Top,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "Ingame_Photo_Popup_2_UIBP"
    }
  },
  Ingame_Photo_Popup_3_UIBP = {
    moduleName = "GameLua.Mod.Library.Client.Photo.Ingame_Photo_Popup_3_UIBP",
    path = "/Game/Mod/EvoBase/BluePrints/UI/PhotoUI/PopUp/Ingame_Photo_Popup_2_UIBP.Ingame_Photo_Popup_2_UIBP",
    containerName = UIContainers.Top,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "Ingame_Photo_Popup_3_UIBP"
    }
  },
  LevelSequencePhotoAndExitUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.LevelSequencePhotoAndExitUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/LevelSequencePhotoAndExit_UIBP.LevelSequencePhotoAndExit_UIBP",
    uiStat = {
      name = "LevelSequencePhotoAndExitUI"
    },
    containerName = UIContainers.Top,
    isSingleton = true,
    asy = true,
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None,
    zOrder = 0
  },
  LevelSequenceInteractiveExitUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.LevelSequenceInteractiveExitUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/LevelSequenceInteractiveExit_UIBP.LevelSequenceInteractiveExit_UIBP",
    uiStat = {
      name = "LevelSequenceInteractiveExitUI"
    },
    containerName = UIContainers.Top,
    isSingleton = true,
    asy = true,
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None,
    zOrder = 0
  },
  FlauntBtnPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.FlauntBtnPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/FlauntBtn_UIBP.FlauntBtn_UIBP",
    uiStat = {
      name = "FlauntBtnPanel"
    },
    isMainUI = false,
    isSingleton = true,
    zOrder = EFixedZOrder.BottomZOrder,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Skip
  },
  NewCommonFlauntDynamicUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.NewCommonFlauntDynamicUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/Flaunt_BattlefieldMaster_UIBP.Flaunt_BattlefieldMaster_UIBP",
    isMainUI = true,
    isAndroidBack = false,
    isWindowsOBHide = false,
    zOrder = 60,
    isSingleton = true,
    uiStat = {
      name = "NewCommonFlauntDynamicUI"
    }
  },
  KatanaRapidKillStreakFlauntDynamicUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.FlauntDynamicUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/Flaunt_Dynamic_UIBP.Flaunt_Dynamic_UIBP",
    isMainUI = true,
    isAndroidBack = false,
    isWindowsOBHide = false,
    zOrder = 60,
    isSingleton = true,
    uiStat = {
      name = "KatanaRapidKillStreakFlauntDynamicUI"
    }
  },
  KingEliminationFlauntDynamicUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.FlauntDynamicUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/Flaunt_Eliminate_King_UIBP.Flaunt_Eliminate_King_UIBP",
    isMainUI = true,
    isAndroidBack = false,
    isWindowsOBHide = false,
    zOrder = 60,
    isSingleton = true,
    uiStat = {
      name = "KingEliminationFlauntDynamicUI"
    }
  },
  VehicleMultiKillFlauntDynamicUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.FlauntDynamicUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/Flaunt_CarHightLight_Normal_UIBP.Flaunt_CarHightLight_Normal_UIBP",
    isMainUI = true,
    isAndroidBack = false,
    isWindowsOBHide = false,
    zOrder = 60,
    isSingleton = true,
    uiStat = {
      name = "VehicleMultiKillFlauntDynamicUI"
    }
  },
  UpgradedWeaponKillFlauntDynamicUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.FlauntDynamicUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/Flaunt_WeaponHighlight_UIBP.Flaunt_WeaponHighlight_UIBP",
    isMainUI = true,
    isAndroidBack = false,
    isWindowsOBHide = false,
    zOrder = 60,
    isSingleton = true,
    asy = true,
    uiStat = {
      name = "UpgradedWeaponKillFlauntDynamicUI"
    }
  },
  VehicleMultiKillFlauntDynamicUI_Bee = {
    moduleName = "GameLua.Mod.BaseMod.Client.FlauntDynamicUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/Flaunt_CarHightLight_Bumblebee_UIBP.Flaunt_CarHightLight_Bumblebee_UIBP",
    isMainUI = true,
    isAndroidBack = false,
    isWindowsOBHide = false,
    zOrder = 60,
    isSingleton = true,
    asy = false,
    uiStat = {
      name = "VehicleMultiKillFlauntDynamicUI_Bee"
    }
  },
  VehicleMultiKillFlauntDynamicUI_MP = {
    moduleName = "GameLua.Mod.BaseMod.Client.FlauntDynamicUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/Flaunt_CarHightLight_Megatron_UIBP.Flaunt_CarHightLight_Megatron_UIBP",
    isMainUI = true,
    isAndroidBack = false,
    isWindowsOBHide = false,
    zOrder = 60,
    isSingleton = true,
    asy = false,
    uiStat = {
      name = "VehicleMultiKillFlauntDynamicUI_MP"
    }
  },
  VehicleMultiKillFlauntDynamicUI_OP = {
    moduleName = "GameLua.Mod.BaseMod.Client.FlauntDynamicUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/Flaunt/Flaunt_CarHightLight_OptimusPrime_UIBP.Flaunt_CarHightLight_OptimusPrime_UIBP",
    isMainUI = true,
    isAndroidBack = false,
    isWindowsOBHide = false,
    zOrder = 60,
    isSingleton = true,
    asy = false,
    uiStat = {
      name = "VehicleMultiKillFlauntDynamicUI_OP"
    }
  }
}
return UIConfig_Photo