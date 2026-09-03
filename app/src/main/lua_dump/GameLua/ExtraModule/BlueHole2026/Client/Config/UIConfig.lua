local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local Config = {
  UIConfig = {
    BHFAPlayerPhotoUI = {
      moduleName = "GameLua.ExtraModule.BlueHole2026.Client.UI.BHFAPlayerPhotoUI",
      path = "/Game/Mod/BlueHole2026/BluePrints/UI/PlayerPhoto_UIBP.PlayerPhoto_UIBP",
      isMainUI = false,
      isSingleton = true,
      zOrder = 10,
      asy = true,
      closeOnHide = false,
      loadFromPool = EUIConfigPoolType.None,
      AndroidBackType = EAndroidBackType.Ban
    },
    SpecialWinShowButtonUI = {
      moduleName = "GameLua.Mod.Library.Client.BattleResultLib.SpecialShow.UI.BattleResultSpecialShowMainUI",
      path = "/Game/Mod/BlueHole2026/BluePrints/UI/SpecialWin_NameInfo_UIBP.SpecialWin_NameInfo_UIBP",
      uiStat = {
        name = "SpecialWinShowButtonUI"
      },
      containerName = UIContainers.Default,
      isSingleton = true,
      asy = true,
      isMainUI = false,
      zOrder = 0
    },
    SpecialWinShowTransitionUI = {
      moduleName = "GameLua.Mod.Library.Client.BattleResultLib.SpecialShow.UI.BattleResultSpecialShowTransitionUI",
      path = "/Game/Mod/BlueHole2026/BluePrints/UI/SpecialWin_Transition_UIBP.SpecialWin_Transition_UIBP",
      uiStat = {
        name = "SpecialWinShowTransitionUI"
      },
      containerName = UIContainers.Default,
      isSingleton = true,
      asy = true,
      isMainUI = false,
      zOrder = 0
    }
  }
}
return Config