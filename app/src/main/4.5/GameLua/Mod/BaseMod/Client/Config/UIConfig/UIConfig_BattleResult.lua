local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_BattleResult = {
  BattleResultMVPImprintUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.BattleResult.ShowMvp.BattleResultMVPImprintUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BattleResult/ShowMvp/BattleResultShowMvpMark_UIBP.BattleResultShowMvpMark_UIBP",
    uiStat = {
      name = "BattleResultMVPImprintUI"
    },
    zOrder = EFixedZOrder.TopZOrder,
    containerName = UIContainers.Top
  },
  BattleResultShowMvp_UIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.BattleResult.ShowMvp.BattleResultShowMvp_UICtrl",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BattleResult/ShowMvp/BattleResultShowMvp_UIBP.BattleResultShowMvp_UIBP",
    uiStat = {
      name = "BattleResultShowMvp_UIBP"
    },
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  DefaultBattleResultUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.BattleResult.DefaultBattleResult.DefaultBattleResultUI",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/BattleResult_GameOverTipsUI.BattleResult_GameOverTipsUI",
    uiStat = {
      name = "DefaultBattleResultUI"
    },
    isSingleton = true,
    isMainUI = false,
    zOrder = 0
  },
  MVPStatueMainRT = {
    moduleName = "GameLua.Mod.BaseMod.Client.MVP.MVPStatueMainRTUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/InteractUI/MVP_Statue_Main_RT.MVP_Statue_Main_RT",
    containerName = UIContainers.Default,
    isMainUI = false,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "MVPStatueMainRT"
    }
  },
  MVPStatuePhotoUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.MVP.MVPPhotoUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/InteractUI/MVP_Photo_UIBP.MVP_Photo_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    uiStat = {
      name = "MVPStatuePhotoUI"
    },
    isMainUI = false
  },
  Mvp_Sequence_Mask = {
    moduleName = "GameLua.Mod.BaseMod.Client.BattleResult.ShowMvp.MvpSequienceMask_UICtrl",
    path = "/Game/Arts_Lobby/CookEntry/Widget3D/BP_LevelSequenceCameraMask.BP_LevelSequenceCameraMask",
    uiStat = {
      name = "Mvp_Sequence_Mask"
    }
  },
  ResultTrainingEnd_UIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.BattleResult.ResultTrainingEnd_UICtrl",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/ResultTrainingEnd_UIBP.ResultTrainingEnd_UIBP",
    uiStat = {
      name = "ResultTrainingEnd_UIBP"
    },
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  ResultsOBUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.OBBattleResult.ResultsOBUI",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/ResultsOB/ResultsOB_UIBP_New.ResultsOB_UIBP_New",
    isWindowsOBHide = false,
    isSingleton = true,
    zOrder = 40,
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "ResultsOBUI"
    }
  },
  ShowMedalUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.MedalUI.ShowMedalUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Medel/ShowMedalUI.ShowMedalUI",
    uiStat = {
      name = "MedalDisplayUI"
    },
    closeOnHide = false,
    isMainUI = false,
    isSingleton = true,
    loadFromPool = EUIConfigPoolType.None
  },
  SingleMedalUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.MedalUI.SingleMedalUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Medel/SingleMedalUI.SingleMedalUI",
    uiStat = {name = "MedalItem"},
    closeOnHide = false,
    isMainUI = false,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.None
  }
}
return UIConfig_BattleResult