local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Movement = {
  CarryBackBreakUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.CarryBackBreakUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/CarryBackBreak_UIBP.CarryBackBreak_UIBP",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    zOrder = 20,
    asy = true,
    mountPanel = {
      mountOuterName = "MainControlBaseUI",
      mountName = "CanvasPanel_42"
    },
    uiStat = {
      name = "CarryBackBreakUI"
    }
  },
  DivingSwimPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.DivingSwimPanel",
    path = "/Game/BluePrints/ControlInput/SwimPanel_UIBP.SwimPanel_UIBP",
    uiStat = {name = "SwimPanel"},
    asy = true,
    isMainUI = false,
    containerName = UIContainers.Bottom
  },
  SwimPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.SwimPanel",
    path = "/Game/BluePrints/ControlInput/SwimPanel_UIBP.SwimPanel_UIBP",
    uiStat = {name = "SwimPanel"},
    asy = true,
    isMainUI = false,
    containerName = UIContainers.Bottom
  },
  PetSpectateUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.PetSpectateUI.PetSpectateUI_Main",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/PetSpectate_UIBP.PetSpectate_UIBP",
    isSingleton = true,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "PetSpectateUI"
    },
    zOrder = 0
  },
  PetSpectateSubPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.PetSpectateUI.PetSpectateSubPanel",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/PetSpectateSubPanel.PetSpectateSubPanel",
    uiStat = {
      name = "PetSpectateSubPanel"
    },
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    AndroidBackType = EAndroidBackType.Skip
  },
  LungUIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.LungUIBP",
    path = "/Game/BluePrints/ControlInput/Lung_UIBP.Lung_UIBP",
    uiStat = {name = "LungUIBP"},
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0,
    autoCreate = true
  }
}
return UIConfig_Movement