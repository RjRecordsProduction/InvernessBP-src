local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_OB = {
  ButtonKickPlayer = {
    moduleName = "GameLua.Mod.BaseMod.Client.OBUI.ButtonKickPlayerWrap",
    path = "/Game/BluePrints/ControlInput/Buttons/ButtonKickPlayer.ButtonKickPlayer",
    isMainUI = false,
    asy = true,
    isWindowsOBHide = true,
    zOrder = 121,
    mountPanel = {
      mountOuterName = "MainControlPanelTochButton",
      mountName = "CanvasPanel_IPX"
    },
    uiStat = {
      name = "ButtonKickPlayer"
    }
  },
  HawkEyeDistanceUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.HawkEyeDistanceUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/EagleEye_Inspection/EagleEyeDistance_UIBP.EagleEyeDistance_UIBP",
    containerName = UIContainers.Bottom,
    closeOnHide = false,
    isWindowsOBHide = true,
    asy = true,
    uiStat = {
      name = "HawkEyeDistanceUI"
    }
  },
  HawkEyeNextPatrolWindow = {
    moduleName = "GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.HawkEyeNextPatrolWindow",
    path = "/Game/Mod/EvoBase/BluePrints/UI/EagleEye_Inspection/EagleEye_Inspection_Popup_UIBP.EagleEye_Inspection_Popup_UIBP",
    containerName = UIContainers.Top,
    isWindowsOBHide = true,
    asy = true,
    uiStat = {
      name = "HawkEyeNextPatrolWindow"
    }
  },
  HawkEyeReportWindow = {
    moduleName = "GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.HawkEyeReportWindow",
    path = "/Game/Mod/EvoBase/BluePrints/UI/EagleEye_Inspection/EagleEye_Inspection_Judgment_UIBP.EagleEye_Inspection_Judgment_UIBP",
    containerName = UIContainers.Top,
    closeOnHide = false,
    isWindowsOBHide = true,
    asy = true,
    uiStat = {
      name = "HawkEyeReportWindow"
    }
  },
  InspectionSystemReportButton = {
    moduleName = "GameLua.Mod.BaseMod.Client.InspectionSystem.InspectionSystemReportButton",
    path = "/Game/Mod/EvoBase/BluePrints/UI/InspectionSystem/InspectionSystemReportButton.InspectionSystemReportButton",
    isSingleton = true,
    uiStat = {
      name = "InspectionSystemReportButton"
    },
    isMainUI = false,
    zOrder = 0
  },
  OBMapPlayerListBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.OBUI.OBMapPlayerListBP",
    path = "/Game/BluePrints/UI/OBUI/OB_MapPlayerList_BP.OB_MapPlayerList_BP",
    uiStat = {
      name = "OBMapPlayerListBP"
    },
    closeOnHide = false,
    isMainUI = false,
    zOrder = 20
  },
  OBReplayKillInfoUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.OBUI.OBReplayKillInfoUI",
    path = "/Game/BluePrints/UI/OBUI/OB_ReplayKillInfo_BP.OB_ReplayKillInfo_BP",
    uiStat = {
      name = "OB_ReplayKillInfo_BP"
    },
    closeOnHide = false,
    isMainUI = false,
    zOrder = 20
  },
  OBTabListUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.OBUI.OBTabListUI",
    path = "/Game/BluePrints/UI/OBUI/OB_TabList_UIBP.OB_TabList_UIBP",
    isWindowsOBHide = false,
    isSingleton = true,
    zOrder = 30,
    uiStat = {
      name = "OBTabListUI"
    }
  },
  OBTeammateList = {
    moduleName = "GameLua.Mod.BaseMod.Client.OBUI.OBTeammateList",
    path = "/Game/BluePrints/UI/OBUI/OB_TeammateList_BP.OB_TeammateList_BP",
    isWindowsOBHide = false,
    isSingleton = true,
    uiStat = {
      name = "OBTeammateList"
    }
  },
  OBPlayerInfoUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.OBUI.OBPlayerInfoUI",
    path = "/Game/BluePrints/UI/OBUI/OB_PlayerInfoPanel_BP.OB_PlayerInfoPanel_BP",
    isWindowsOBHide = false,
    isSingleton = true,
    uiStat = {
      name = "OBPlayerInfoUI"
    }
  },
  OBVehicleInfoUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.OBUI.OBVehicleInfoUI",
    path = "/Game/BluePrints/UI/OBUI/OB_VehicleInfoPanel_BP.OB_VehicleInfoPanel_BP",
    isWindowsOBHide = false,
    isSingleton = true,
    uiStat = {
      name = "OBVehicleInfoUI"
    }
  }
}
return UIConfig_OB