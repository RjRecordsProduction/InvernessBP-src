local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Replay = {
  CompletePlaybackKillInfo = {
    moduleName = "GameLua.Mod.BaseMod.Client.Replay.CompletePlaybackKillInfo",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Item/CompletePlaybackKillInfo_UIBP.CompletePlaybackKillInfo_UIBP",
    isMainUI = false,
    uiStat = {
      name = "CompletePlaybackKillInfo"
    }
  },
  CompletePlaybackReplayStatusInfoUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Replay.CompletePlaybackReplayStatusInfoUI",
    path = "/Game/BluePrints/UI/GMConsole/CompletePlaybackReplayStatusInfoUI.CompletePlaybackReplayStatusInfoUI",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "CompletePlaybackReplayStatusInfoUI"
    },
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.Click_Animation
  },
  CompletePlaybackUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Replay.CompletePlaybackUI",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/CompletePlayback_UIBP.CompletePlayback_UIBP",
    containerName = UIContainers.Default,
    closeOnHide = false,
    zOrder = 42,
    uiStat = {
      name = "CompletePlaybackUI"
    },
    isMainUI = false
  },
  DeathPlaybackNewHeadItem = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.DeathPlaybackNewHeadItem",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/DeathPlaybackNew_Head_Item.DeathPlaybackNew_Head_Item",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    asy = true,
    uiStat = {
      name = "DeathPlaybackNewHeadItem"
    },
    zOrder = 0
  },
  HistoricalNewsUIForReplay = {
    moduleName = "GameLua.Mod.Library.Client.UI.HistoricalNewsUI",
    path = "/Game/BluePrints/ControlInput/HistoricalNewsUI.HistoricalNewsUI",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = false,
    asy = true,
    uiStat = {
      name = "HistoricalNewsUIForReplay"
    },
    zOrder = 0
  },
  ReplayGMUIDSStrategyTimestamp = {
    moduleName = "GameLua.Mod.BaseMod.Client.Replay.ReplayGMUIDSStrategyTimestamp",
    path = "/Game/BluePrints/UI/GMConsole/ReplayGMUIDSStrategyTimestamp.ReplayGMUIDSStrategyTimestamp",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "ReplayGMUIDSStrategyTimestamp"
    },
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.Click_Animation
  },
  ReplayGMUIKillInfo = {
    moduleName = "GameLua.Mod.BaseMod.Client.Replay.ReplayGMUIKillInfo",
    path = "/Game/BluePrints/UI/GMConsole/ReplayGMUIKillInfo.ReplayGMUIKillInfo",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    asy = false,
    closeOnHide = false,
    uiStat = {
      name = "ReplayGMUIKillInfo"
    },
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.Click_Animation
  },
  ReplayGMUISwitchSpectatorUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Replay.ReplayGMUISwitchSpectatorUI",
    path = "/Game/BluePrints/UI/GMConsole/ReplayGMUISwitchSpectatorUI.ReplayGMUISwitchSpectatorUI",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "ReplayGMUISwitchSpectatorUI"
    },
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.Click_Animation
  },
  WonderfulLoadingUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Replay.WonderfulLoadingUI",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Video_Switch_UIBP.Video_Switch_UIBP",
    containerName = UIContainers.Top,
    closeOnHide = false,
    zOrder = EFixedZOrder.TopZOrder - 10,
    uiStat = {
      name = "WonderfulLoadingUI"
    },
    isMainUI = false
  },
  WonderfulReportBug = {
    moduleName = "GameLua.Mod.BaseMod.Client.Replay.WonderfulReportBug",
    path = "/Game/UMG/UI_BP/PopupNotice/ReportBug_UIBP.ReportBug_UIBP",
    asy = true,
    uiStat = {
      name = "WonderfulReportBug"
    },
    containerName = UIContainers.Top
  }
}
return UIConfig_Replay