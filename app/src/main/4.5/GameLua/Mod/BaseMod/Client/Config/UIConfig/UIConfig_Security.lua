local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Security = {
  BattleReportBug = {
    moduleName = "client.slua.umg.report_error.battle_report_bug",
    path = "/Game/UMG/UI_BP/PopupNotice/ReportBug_UIBP.ReportBug_UIBP",
    asy = true,
    uiStat = {
      name = "BattleReportBug"
    },
    containerName = UIContainers.Top
  },
  LowMatchBanItem = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.LowMatchBanItem",
    path = "/Game/BluePrints/ControlInput/LowMatchBanItem.LowMatchBanItem",
    isSingleton = true,
    isMainUI = false,
    asy = true,
    autoCreate = true,
    uiStat = {
      name = "LowMatchBanItem"
    },
    showVisibility = UIContainers.ShowVisibilityAction.DontCare
  },
  MiniTvBannerUI = {
    moduleName = "GameLua.Mod.Library.Client.MiniTv.MiniTvBannerUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/MiniTv/MiniTvBanner_UIBP.MiniTvBanner_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    uiStat = {
      name = "MiniTvBannerUI"
    },
    isMainUI = false
  },
  VoiceForbidBtn = {
    moduleName = "GameLua.Mod.BaseMod.Client.Ban.VoiceForbidBtn",
    path = "/Game/BluePrints/ControlInput/IngameUI/Ban/VoiceForbidStatu_UIBP.VoiceForbidStatu_UIBP",
    uiStat = {
      name = "VoiceForbidBtn"
    },
    zOrder = 0,
    isMainUI = false,
    isSingleton = false
  }
}
return UIConfig_Security